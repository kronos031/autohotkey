# Script simple para exportar parámetros SSM (sin ARN y DataType)
# Uso: .\Simple-SSM-Export-Clean.ps1

$OutputFile = "ssm_parameters_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"

Write-Host "🔍 Exportando parámetros SSM..." -ForegroundColor Green

# Verificar AWS CLI
$awsTest = aws sts get-caller-identity 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: No se puede conectar a AWS" -ForegroundColor Red
    Write-Host "   Verifica: aws configure" -ForegroundColor Yellow
    exit 1
}

# Obtener TODOS los parámetros con paginación (describe-parameters tiene límite de 50)
Write-Host "📋 Obteniendo lista de parámetros..." -ForegroundColor Blue

$allDescribed = @()
$nextToken = $null

do {
    if ($nextToken) {
        $page = aws ssm describe-parameters --output json --next-token $nextToken | ConvertFrom-Json
    } else {
        $page = aws ssm describe-parameters --output json | ConvertFrom-Json
    }

    if ($null -eq $page) {
        Write-Host "❌ Error al llamar describe-parameters" -ForegroundColor Red
        exit 1
    }

    $allDescribed += $page.Parameters
    $nextToken = $page.NextToken

} while ($nextToken)

#FILTRAR POR PATH (descomentar para usar)
# $allDescribed = $allDescribed | Where-Object { $_.Name -like "/mi/path/*" }

if ($allDescribed.Count -eq 0) {
    Write-Host "❌ No se encontraron parámetros" -ForegroundColor Red
    exit 1
}

# Crear diccionario Name -> Description para lookup rápido
$descriptionMap = @{}
foreach ($p in $allDescribed) {
    $descriptionMap[$p.Name] = if ($p.Description) { $p.Description } else { "" }
}

$nameArray = $allDescribed | Select-Object -ExpandProperty Name
$total = $nameArray.Count

Write-Host "📊 Encontrados: $total parámetros" -ForegroundColor Green
Write-Host "💾 Guardando en: $OutputFile" -ForegroundColor Yellow

# Crear array para almacenar todos los parámetros
$allParameters = @()

# Procesar en lotes de 10 (límite de get-parameters)
$batchSize = 10
for ($i = 0; $i -lt $total; $i += $batchSize) {
    $batch = $nameArray[$i..([Math]::Min($i + $batchSize - 1, $total - 1))]

    Write-Progress -Activity "Exportando parámetros" `
                   -Status "Procesando $($i + 1) - $($i + $batch.Count) de $total" `
                   -PercentComplete (($i / $total) * 100)

    try {
        # Usar array directo en lugar de Invoke-Expression (más seguro)
        $result = aws ssm get-parameters --names $batch --with-decryption --output json | ConvertFrom-Json

        if ($LASTEXITCODE -ne 0 -or $null -eq $result) {
            Write-Host "⚠️  AWS CLI error en lote posición $i" -ForegroundColor Yellow
            continue
        }

        # Advertir si algún parámetro no fue encontrado
        if ($result.InvalidParameters -and $result.InvalidParameters.Count -gt 0) {
            Write-Host "⚠️  Parámetros no encontrados: $($result.InvalidParameters -join ', ')" -ForegroundColor Yellow
        }

        # Filtrar campos no deseados (ARN y DataType) y agregar Description
        $filteredParams = $result.Parameters | ForEach-Object {
            [PSCustomObject]@{
                Name             = $_.Name
                Type             = $_.Type
                Value            = $_.Value
                Description      = $descriptionMap[$_.Name]
                LastModifiedDate = $_.LastModifiedDate
            }
        }

        $allParameters += $filteredParams
    }
    catch {
        Write-Host "⚠️  Error en lote posición $i : $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "   Nombres del lote: $($batch -join ', ')" -ForegroundColor Gray
    }
}

# Guardar resultado
$allParameters | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Progress -Completed -Activity "Exportando parámetros"

# Mostrar resumen
Write-Host ""
Write-Host "🎉 ¡Completado!" -ForegroundColor Green
Write-Host "📁 Archivo: $OutputFile" -ForegroundColor Cyan
Write-Host "📊 Parámetros exportados: $($allParameters.Count)" -ForegroundColor White

# Estadísticas por tipo
$stats = $allParameters | Group-Object Type
Write-Host ""
Write-Host "📈 Estadísticas por tipo:" -ForegroundColor Blue
foreach ($stat in $stats) {
    Write-Host "   $($stat.Name): $($stat.Count)" -ForegroundColor White
}

Write-Host ""
Write-Host "✅ Archivo guardado: $(Resolve-Path $OutputFile)" -ForegroundColor Green