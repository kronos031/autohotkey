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

# Obtener lista de parámetros
Write-Host "📋 Obteniendo lista de parámetros..." -ForegroundColor Blue
$paramNames = aws ssm describe-parameters --query 'Parameters[].Name' --output text
#FILTRAR POR PATH
#aws ssm describe-parameters --parameter-filters "Key=Name,Option=BeginsWith,Values=/mi/path/" --query 'Parameters[].Name' --output text

if ([string]::IsNullOrWhiteSpace($paramNames)) {
    Write-Host "❌ No se encontraron parámetros" -ForegroundColor Red
    exit 1
}

# Convertir a array
$nameArray = $paramNames -split '\s+'
$total = $nameArray.Count

Write-Host "📊 Encontrados: $total parámetros" -ForegroundColor Green
Write-Host "💾 Guardando en: $OutputFile" -ForegroundColor Yellow

# Crear array para almacenar todos los parámetros
$allParameters = @()

# Procesar en lotes de 10
$batchSize = 10
for ($i = 0; $i -lt $total; $i += $batchSize) {
    $batch = $nameArray[$i..([Math]::Min($i + $batchSize - 1, $total - 1))]
    
    Write-Progress -Activity "Exportando parámetros" -Status "Procesando $($i + 1) - $($i + $batch.Count) de $total" -PercentComplete (($i / $total) * 100)
    
    # Crear comando con nombres entre comillas
    $quotedNames = $batch | ForEach-Object { "`"$_`"" }
    $command = "aws ssm get-parameters --names $($quotedNames -join ' ') --with-decryption --output json"
    
    # Ejecutar y convertir resultado
    try {
        $result = Invoke-Expression $command | ConvertFrom-Json
        
        # Filtrar campos no deseados (ARN y DataType)
        $filteredParams = $result.Parameters | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name
                Type = $_.Type
                Value = $_.Value 
                LastModifiedDate = $_.LastModifiedDate 
            }
        }
        
        $allParameters += $filteredParams
    }
    catch {
        Write-Host "⚠️  Error procesando lote en posición $i" -ForegroundColor Yellow
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