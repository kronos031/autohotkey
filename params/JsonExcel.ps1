# Script para convertir JSON a Excel
# Requiere el módulo ImportExcel: Install-Module -Name ImportExcel -Force

param(
    [Parameter(Mandatory=$true, HelpMessage="Ruta al archivo JSON")]
    [string]$JsonFilePath,
    
    [Parameter(Mandatory=$false)]
    [string]$ExcelFilePath = "Parametros_$(Get-Date -Format 'yyyyMMdd_HHmmss').xlsx"
)

# Función para instalar ImportExcel si no está disponible
function Install-ImportExcelModule {
    if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
        Write-Host "Instalando módulo ImportExcel..." -ForegroundColor Yellow
        try {
            Install-Module -Name ImportExcel -Force -Scope CurrentUser
            Write-Host "Módulo ImportExcel instalado correctamente." -ForegroundColor Green
        }
        catch {
            Write-Error "Error al instalar el módulo ImportExcel: $_"
            exit 1
        }
    }
}

# Instalar módulo si es necesario
Install-ImportExcelModule
Import-Module ImportExcel

try {
    # Verificar que el archivo existe
    if (-not (Test-Path $JsonFilePath)) {
        Write-Error "El archivo JSON no existe: $JsonFilePath"
        Write-Host "Ubicación actual: $(Get-Location)" -ForegroundColor Yellow
        Write-Host "Archivos disponibles:" -ForegroundColor Yellow
        Get-ChildItem -Filter "*.json" | Select-Object Name, Length, LastWriteTime
        exit 1
    }

    # Leer y procesar el archivo JSON
    Write-Host "Leyendo archivo JSON: $JsonFilePath" -ForegroundColor Cyan
    $jsonContent = Get-Content $JsonFilePath -Raw -Encoding UTF8
    
    # Verificar que el contenido no esté vacío
    if ([string]::IsNullOrWhiteSpace($jsonContent)) {
        Write-Error "El archivo JSON está vacío o no se pudo leer correctamente"
        exit 1
    }

    # Convertir de JSON
    $jsonData = $jsonContent | ConvertFrom-Json
    Write-Host "JSON procesado correctamente. Registros encontrados: $($jsonData.Count)" -ForegroundColor Green

    # Convertir a tabla de PowerShell con manejo de propiedades dinámicas
    $table = @()
    
    # Obtener todas las propiedades únicas del JSON
    $allProperties = @()
    foreach ($item in $jsonData) {
        $allProperties += $item.PSObject.Properties.Name
    }
    $allProperties = $allProperties | Sort-Object | Get-Unique
    
    Write-Host "Propiedades encontradas: $($allProperties -join ', ')" -ForegroundColor Yellow
    
    foreach ($item in $jsonData) {
        $row = [PSCustomObject]@{}
        
        # Agregar cada propiedad al objeto
        foreach ($prop in $allProperties) {
            if ($item.PSObject.Properties.Name -contains $prop) {
                $row | Add-Member -NotePropertyName $prop -NotePropertyValue $item.$prop
            } else {
                $row | Add-Member -NotePropertyName $prop -NotePropertyValue $null
            }
        }
        
        $table += $row
    }

    # Exportar a Excel con formato
    Write-Host "Exportando a Excel: $ExcelFilePath" -ForegroundColor Cyan
    $table | Export-Excel -Path $ExcelFilePath -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow -TableStyle Medium2

    Write-Host "¡Conversión completada exitosamente!" -ForegroundColor Green
    Write-Host "Archivo Excel creado: $ExcelFilePath" -ForegroundColor Green
    
    # Mostrar resumen
    Write-Host "`nResumen:" -ForegroundColor Yellow
    Write-Host "- Archivo origen: $JsonFilePath" -ForegroundColor White
    Write-Host "- Archivo destino: $ExcelFilePath" -ForegroundColor White
    Write-Host "- Registros procesados: $($table.Count)" -ForegroundColor White
    Write-Host "- Columnas: $($allProperties.Count)" -ForegroundColor White
    Write-Host "- Ubicación completa: $(Resolve-Path $ExcelFilePath)" -ForegroundColor White

}
catch {
    Write-Error "Error durante la conversión: $_"
    exit 1
}

# Ejemplos de uso:
Write-Host "`n=== EJEMPLOS DE USO ===" -ForegroundColor Magenta
Write-Host "1. Uso básico:" -ForegroundColor Yellow
Write-Host "   .\script.ps1 -JsonFilePath 'datos.json'" -ForegroundColor White
Write-Host "`n2. Especificar archivo de salida:" -ForegroundColor Yellow
Write-Host "   .\script.ps1 -JsonFilePath 'datos.json' -ExcelFilePath 'parametros_aws.xlsx'" -ForegroundColor White
Write-Host "`n3. Con rutas completas:" -ForegroundColor Yellow
Write-Host "   .\script.ps1 -JsonFilePath 'C:\datos\parametros.json' -ExcelFilePath 'C:\salida\resultado.xlsx'" -ForegroundColor White