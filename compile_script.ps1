param(
    [string]$Accion,
    [string]$Proyectos,
    [string]$Rama
)

$VERSION = ""
$VPATH = ""
$VPATHLIB = ""
$ZIPPATH = ""
$INQUIRY
$SPI = "SISTEMA-PAGOS-INMEDIATOS-"
$GRAD = ""

# Hashtables que se inicializan después de seleccionar versión
$script:MAPEO_PROYECTOS = @{}
$script:NOMBRES_PROYECTOS = @{}
$script:LISTAS_PROYECTOS = @{}

function InicializarConfiguracionRutas {
    $basePath = "C:\Users\miguelrobles\Desktop\SPI\$VERSION"
    $libsPath = "$basePath\LIBS"
    
    # Crear rutas dinámicamente
    $bancos = @("BAVV", "BBOG", "BOCC", "BPOP", "DALE")
    $operaciones = @("CREATE", "MODIFY", "CANCEL", "INQUIRY")
    
    # Limpiar hashtables
    $script:MAPEO_PROYECTOS.Clear()
    $script:NOMBRES_PROYECTOS.Clear()
    $script:LISTAS_PROYECTOS.Clear()
    
    # Generar rutas para bancos
    foreach ($banco in $bancos) {
        $bancoPath = "$basePath\$banco"
        $script:LISTAS_PROYECTOS[$banco] = @()
        
        foreach ($op in $operaciones) {
            $suffix = switch ($op) {
                "CREATE" { "val-create" }
                "MODIFY" { "val-mod" }
                "CANCEL" { "val-cancel" }
                "INQUIRY" { "inquiry" }
            }
            
            $rutaCompleta = "$bancoPath\$SPI" + "SPI-BACK-lambda-java-$suffix$VPATH" + $banco.ToLower()
            $claveMapeo = "$($banco.ToLower())-$($op.ToLower())"
            
            $script:MAPEO_PROYECTOS[$claveMapeo] = $rutaCompleta
            $script:NOMBRES_PROYECTOS[$rutaCompleta] = "$banco - $op"
            $script:LISTAS_PROYECTOS[$banco] += $rutaCompleta
        }
    }
    
    # LIBS
    $libsRutas = @{
        "SYNC" = "$libsPath\$SPI" + "SPI-BACK-libs-java-synch-dyn-open$VPATHLIB"
        "COMMONS" = "$libsPath\$SPI" + "BACK-libs-java-commons"
        "REDEBAN" = "$libsPath\$SPI" + "SPI-BACK-libs-java-vault-connection-red"
        "CORNER" = "$libsPath\$SPI" + "SPI-BACK-libs-java-vault-connection-crn"
        "ARTEFACTOS" = "C:\Users\miguelrobles\Desktop\SISTEMA-PAGOS-INMEDIATOS-BACK-ArtefactosDespliegues"
    }
    
    $script:LISTAS_PROYECTOS["LIBS"] = @()
    foreach ($lib in $libsRutas.GetEnumerator()) {
        $claveMapeo = "libs-$($lib.Key.ToLower())"
        $script:MAPEO_PROYECTOS[$claveMapeo] = $lib.Value
        $script:NOMBRES_PROYECTOS[$lib.Value] = "LIBS - $($lib.Key)"
        $script:LISTAS_PROYECTOS["LIBS"] += $lib.Value
    }
    
    # Listas por operación
    foreach ($op in $operaciones) {
        $script:LISTAS_PROYECTOS[$op] = @()
        foreach ($banco in $bancos) {
            $claveMapeo = "$($banco.ToLower())-$($op.ToLower())"
            $script:LISTAS_PROYECTOS[$op] += $script:MAPEO_PROYECTOS[$claveMapeo]
        }
    }
    
    $script:LISTAS_PROYECTOS["ALL"] = @()
    $claves = $script:LISTAS_PROYECTOS.Keys | Where-Object { $_ -ne "ALL" }
    foreach ($clave in $claves) {
    $script:LISTAS_PROYECTOS["ALL"] += $script:LISTAS_PROYECTOS[$clave]

    $script:BAVV_LIST = $script:LISTAS_PROYECTOS["BAVV"]
$script:BBOG_LIST = $script:LISTAS_PROYECTOS["BBOG"]
$script:BOCC_LIST = $script:LISTAS_PROYECTOS["BOCC"]
$script:BPOP_LIST = $script:LISTAS_PROYECTOS["BPOP"]
$script:DALE_LIST = $script:LISTAS_PROYECTOS["DALE"]
$script:LIBS_LIST = $script:LISTAS_PROYECTOS["LIBS"]
$script:CREATE_LIST = $script:LISTAS_PROYECTOS["CREATE"]
$script:INQUIRY_LIST = $script:LISTAS_PROYECTOS["INQUIRY"]
$script:MODIFY_LIST = $script:LISTAS_PROYECTOS["MODIFY"]
$script:CANCEL_LIST = $script:LISTAS_PROYECTOS["CANCEL"]
$script:LIBS_ARTEFACTOS = $script:MAPEO_PROYECTOS["libs-artefactos"]
}
}


function EjecutarScriptDesdeAutoHotkey {
    param(
        [string]$Accion,
        [string]$Proyectos,
        [string]$Rama
    )

    $VERSION = Mostrar-MenuVersion -AutomaticMode
    InicializarConfiguracionRutas
    Procesar-ComandoAutoHotkey -Accion $Accion -Proyectos $Proyectos -Rama $Rama
    Write-Host "`nPresione Enter para cerrar..." -ForegroundColor Cyan
    Read-Host
}


function Mapear-ProyectoDesdeAutoHotkey {
    param (
        [string]$proyectoAutoHotkey
    )

    if ($MAPEO_PROYECTOS.ContainsKey($proyectoAutoHotkey)) {
        return $MAPEO_PROYECTOS[$proyectoAutoHotkey]
    }

    Write-Host "$(Obtener-HoraActual) Advertencia: Proyecto no encontrado: '$proyectoAutoHotkey'" -ForegroundColor Yellow
    return $null
}

function Obtener-HoraActual {
    return Get-Date -Format "HH:mm:ss"
}

# Funcion para mostrar el menu de seleccion de version
function Mostrar-MenuVersion {
    param(
        [switch]$AutomaticMode
    )
    
    if ($AutomaticMode) {
        # Configuración automática para llamadas desde AutoHotkey
        $script:VERSION = "V3"
        $script:VPATH = "-micro-"
        $script:ZIPPATH = "build\libs\*.zip"
        $script:VPATHLIB = "-micro"
        Write-Host "$(Obtener-HoraActual) Versión V3 seleccionada automáticamente" -ForegroundColor Green
        return $VERSION
    }
    
    Clear-Host
    Write-Host "Seleccione la version:" -ForegroundColor Yellow
    Write-Host "1: Version 2.0" -ForegroundColor Cyan
    Write-Host "2: Version 3.0" -ForegroundColor Cyan
    Write-Host "3: Mod MICRO 2.0" -ForegroundColor Red
    
    $seleccion = Read-Host "Ingrese su seleccion (1-3)"
    
    switch ($seleccion) {
        '1' {
            $script:VERSION = "V2"
            $script:VPATH = "-"
            $script:VPATHLIB = ""
            $script:ZIPPATH = "build\distributions\*.zip"
            Write-Host "Version 2.0 seleccionada" -ForegroundColor Green
        }
        '2' {
            $script:VERSION = "V3"
            $script:VPATH = "-micro-"
            $script:ZIPPATH = "build\libs\*.zip"
            $script:VPATHLIB = "-micro"
            Write-Host "Version 3.0 seleccionada" -ForegroundColor Green
        }
        '3' {
            $script:VERSION = "V2"
            $script:VPATH = "-"
            $script:ZIPPATH = "build\libs\*.zip"
            Write-Host "Modificacion 2.0 con micro seleccionada" -ForegroundColor Green
        }
        default {
            Write-Host "Opcion no valida. Se utilizara la version 3.0 por defecto." -ForegroundColor Red
            $script:VERSION = "3.0"
        }
    }
    
    Start-Sleep -Seconds 1
    return $VERSION
}

# Función para mapear proyectos desde AutoHotkey
function Procesar-ComandoAutoHotkey {
    param(
        [string]$Accion,
        [string]$Proyectos 
    )
    $Accion = $Accion.Trim(" '""")
    Write-Host "$(Obtener-HoraActual) Comando desde AutoHotkey - Acción: $Accion, Proyectos: $Proyectos" -ForegroundColor Cyan
    
    # Parsear la lista de proyectos
    $proyectosList = $Proyectos -split ','
    $rutasProyectos = @()
    
    foreach ($proyecto in $proyectosList) {
    $proyectoLimpio = $proyecto.Trim(" '""") # Elimina espacios, comillas simples y dobles
    $rutaProyecto = Mapear-ProyectoDesdeAutoHotkey $proyectoLimpio
    if ($rutaProyecto) {
        $rutasProyectos += $rutaProyecto
    }
}
    
    if ($rutasProyectos.Count -eq 0) {
        Write-Host "$(Obtener-HoraActual) Error: No se encontraron proyectos válidos" -ForegroundColor Red
        return
    }
    
    # Ejecutar la acción correspondiente
    foreach ($rutaProyecto in $rutasProyectos) {
        Write-Host "$(Obtener-HoraActual) Procesando: $($NOMBRES_PROYECTOS[$rutaProyecto])" -ForegroundColor Yellow
        
        switch ($Accion) {
            "compile" {
                Compilar-Proyecto $rutaProyecto
            }
            "update" {
                Actualizar-Proyecto $rutaProyecto
            }
            "branch" {
        # Siempre pedir la rama cuando viene desde AutoHotkey
        $Rama = Read-Host "Ingrese el nombre de la rama"
        
        if ($Rama -and $Rama.Trim() -ne "") {
            Cambiar-Rama $rutaProyecto $Rama
        }
        else {
            Write-Host "$(Obtener-HoraActual) Error: Se requiere especificar una rama" -ForegroundColor Red
        }
            }
            "copyzip" {
                Copiar-ArchivosZIP $rutaProyecto
            }
            "navigate" {
                NavegarAProyecto $rutaProyecto
            }
            default {
                Write-Host "$(Obtener-HoraActual) Error: Acción no reconocida: $Accion" -ForegroundColor Red
            }
        }
    }
    
    Write-Host "$(Obtener-HoraActual) Procesamiento completado" -ForegroundColor Green
}


# Funcion para copiar archivos ZIP
function Copiar-ArchivosZIP {
    param (
        [string]$rutaProyecto
    )
    
    Write-Host "$(Obtener-HoraActual) Copiando archivos ZIP desde: $($NOMBRES_PROYECTOS[$rutaProyecto])" -ForegroundColor Cyan
    
    if (-not (Test-Path -Path $ZIP_DESTINATION_PATH)) {
        New-Item -ItemType Directory -Path $ZIP_DESTINATION_PATH -Force | Out-Null
        Write-Host "$(Obtener-HoraActual) Directorio de destino creado: $ZIP_DESTINATION_PATH" -ForegroundColor Yellow
    } 
    $rutaZip = Join-Path -Path $rutaProyecto -ChildPath $ZIPPATH
    $archivosZip = Get-ChildItem -Path $rutaZip -ErrorAction SilentlyContinue
    
    if ($archivosZip.Count -gt 0) {
        foreach ($archivo in $archivosZip) {
            $destino = Join-Path -Path $ZIP_DESTINATION_PATH -ChildPath $archivo.Name
            Copy-Item -Path $archivo.FullName -Destination $destino -Force
            Write-Host "$(Obtener-HoraActual) Copiado: $($archivo.Name)" -ForegroundColor Green
        }
        Write-Host "$(Obtener-HoraActual) Total archivos copiados: $($archivosZip.Count)" -ForegroundColor Green
    }
    else {
        Write-Host "$(Obtener-HoraActual) No se encontraron archivos ZIP en $rutaProyecto" -ForegroundColor Yellow
    }
}

# Funcion para compilar un proyecto
function Compilar-Proyecto {
    param (
        [string]$rutaProyecto
    )
    
    Write-Host "$(Obtener-HoraActual) Compilando proyecto: $($NOMBRES_PROYECTOS[$rutaProyecto])" -ForegroundColor Cyan
    Set-Location $rutaProyecto
    git branch
    
    if ($VERSION -eq "V3") {
        gradle buildNativeLambda
    }
    elseif ($VERSION -eq "V2" -and $VPATH -eq "-") {
        gradle buildNativeLambda
    }
    else {
        gradle buildZip
    }
    
    Copiar-ArchivosZIP $rutaProyecto
    Write-Host "$(Obtener-HoraActual) Compilacion completada para: $($NOMBRES_PROYECTOS[$rutaProyecto])" -ForegroundColor Green
}

# Funcion para cambiar rama
function Cambiar-Rama {
    param (
        [string]$rutaProyecto,
        [string]$nombreRama
    )
    
    Write-Host "$(Obtener-HoraActual) Cambiando rama en: $($NOMBRES_PROYECTOS[$rutaProyecto]) a $nombreRama" -ForegroundColor Cyan
    Set-Location $rutaProyecto
    git fetch
    git checkout $nombreRama
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$(Obtener-HoraActual) Cambio a rama $nombreRama exitoso" -ForegroundColor Green
        git pull
    }
    else {
        Write-Host "$(Obtener-HoraActual) Error al cambiar a rama $nombreRama" -ForegroundColor Red
    }
}

# Funcion para actualizar proyecto
function Actualizar-Proyecto {
    param (
        [string]$rutaProyecto
    )
    if ($rutaProyecto -eq $LIBS_ARTEFACTOS) {
        Write-Host "$(Obtener-HoraActual) Actualizando proyecto: $($NOMBRES_PROYECTOS[$rutaProyecto])" -ForegroundColor Cyan
        Set-Location $rutaProyecto
        git fetch
        git pull
        git status        <# Action to perform if the condition is true #>
    }
    else {
        Write-Host "$(Obtener-HoraActual) Actualizando proyecto: $($NOMBRES_PROYECTOS[$rutaProyecto])" -ForegroundColor Cyan
        Set-Location $rutaProyecto
        git fetch
        git pull
        <# Action when all if and elseif conditions are false #>
    }
    #gradle publishToMavenLocal
    Write-Host "$(Obtener-HoraActual) Actualizacion completada para: $($NOMBRES_PROYECTOS[$rutaProyecto])" -ForegroundColor Green
}

# Funcion para navegar a proyecto
function NavegarAProyecto {
    param (
        [string]$rutaProyecto
    )
    if ($rutaProyecto -match "^[a-z]+-[a-z]+$") {
        $rutaProyecto = Mapear-ProyectoDesdeAutoHotkey $rutaProyecto
        if (-not $rutaProyecto) {
            return
        }
    }

    Write-Host "$(Obtener-HoraActual) Navegando a: $($NOMBRES_PROYECTOS[$rutaProyecto])" -ForegroundColor Cyan
    Write-Host "$(Obtener-HoraActual) Ruta: $rutaProyecto" -ForegroundColor Gray
    
    if (Test-Path $rutaProyecto) {
        if (Test-Path "$rutaProyecto\.git") { 
            $ramaActual = git -C $rutaProyecto branch --show-current 2>$null
            Write-Host "- Rama actual: $ramaActual" -ForegroundColor Yellow
        }
        
        Write-Host "`n$(Obtener-HoraActual) Abriendo proyecto en PowerShell..." -ForegroundColor Cyan
        Start-Process pwsh -ArgumentList "-NoExit", "-Command", "Set-Location '$rutaProyecto'; Write-Host '`nTrabajando en: $($NOMBRES_PROYECTOS[$rutaProyecto])`n' -ForegroundColor Green; Write-Host 'Ruta: $rutaProyecto' -ForegroundColor Gray; if (Test-Path '.git') { git branch --show-current 2>`$null | ForEach-Object { Write-Host 'Rama actual: $ramaActual' -ForegroundColor Yellow }; Write-Host 'Actualizando referencias remotas...' -ForegroundColor Cyan; git fetch; git pull}"
        
    }
    else {
        Write-Host "$(Obtener-HoraActual) Error: La ruta no existe: $rutaProyecto" -ForegroundColor Red
    }
    
    Read-Host "`nPresione Enter para volver al menu principal..."
}

# Funcion para mostrar menu principal
function Mostrar-MenuPrincipal {
    param (
        [switch]$limpiarPantalla = $true
    )

    if ($limpiarPantalla) {
        Clear-Host
    }
    Write-Host "Version seleccionada: $VERSION" -ForegroundColor Gray
    Write-Host "1: Compilar" -ForegroundColor Gray
    Write-Host "2: Cambiar rama" -ForegroundColor Yellow
    Write-Host "3: Actualizar" -ForegroundColor Blue
    Write-Host "4: Copiar ZIPs" -ForegroundColor Green
    Write-Host "5: Abrir si" -ForegroundColor Magenta
    Write-Host "6: Salir" -ForegroundColor Red
}

# Funcion para mostrar submenu de entidades
function Mostrar-SubMenuEntidades {
    Clear-Host
    Write-Host "Entidades disponibles:"
    Write-Host "1: BAVV"
    Write-Host "2: BBOG"
    Write-Host "3: BOCC"
    Write-Host "4: BPOP"
    Write-Host "5: DALE"
    Write-Host "6: LIBS"
    Write-Host "7: CREATE"
    Write-Host "8: INQUIRY"
    Write-Host "9: MODIFY"
    Write-Host "10: CANCEL"
    Write-Host "11: ALL PROYECTS"
}

# Funcion para mostrar proyectos con seleccion multiple
function Mostrar-Proyectos {
    param (
        [array]$listaProyectos
    )
    
    Clear-Host
    Write-Host "Seleccione proyectos (separar multiples opciones con comas, ej. 1,3,5):" -ForegroundColor Yellow
    
    $indice = 1
    $mapaProyectos = @{}
    
    foreach ($proyecto in $listaProyectos) {
        Write-Host "$indice`: $($NOMBRES_PROYECTOS[$proyecto])"
        $mapaProyectos[$indice.ToString()] = $proyecto
        $indice++
    }
    
    Write-Host "$indice`: TODOS los proyectos"
    $mapaProyectos["$indice"] = "TODOS"
    $indice++
    Write-Host "$indice`: Volver al menu principal"
    $mapaProyectos["$indice"] = "VOLVER"
    
    return $mapaProyectos
}

# Funcion para procesar selecciones multiples
function Procesar-SeleccionesMultiples {
    param (
        [string]$entrada,
        [int]$maximoIndice
    )
    
    $selecciones = @()
    
    if ($entrada -match ',') {
        $partes = $entrada -split ','
        foreach ($parte in $partes) {
            $parte = $parte.Trim()
            if ($parte -match '^\d+$' -and [int]$parte -ge 1 -and [int]$parte -le $maximoIndice) {
                $selecciones += $parte
            }
        }
    }
    else {
        if ($entrada -match '^\d+$' -and [int]$entrada -ge 1 -and [int]$entrada -le $maximoIndice) {
            $selecciones += $entrada
        }
    }
    
    return $selecciones
}

# Funcion para procesar proyectos seleccionados
function Procesar-ProyectosSeleccionados {
    param (
        [array]$selecciones,
        [hashtable]$mapaProyectos,
        [string]$accion,
        [string]$nombreEntidad
    )
    
    $proyectosAProcesar = @()
    
    foreach ($seleccion in $selecciones) {
        if ($mapaProyectos[$seleccion] -eq "TODOS") {
            $proyectosAProcesar += $mapaProyectos.GetEnumerator() | 
            Where-Object { $_.Value -ne "TODOS" -and $_.Value -ne "VOLVER" } | 
            Select-Object -ExpandProperty Value
            break
        }
        elseif ($mapaProyectos[$seleccion] -ne "VOLVER") {
            $proyectosAProcesar += $mapaProyectos[$seleccion]
        }
    }
    
    if ($proyectosAProcesar.Count -eq 0) {
        Write-Host "$(Obtener-HoraActual) No se seleccionaron proyectos o la seleccion es invalida." -ForegroundColor Yellow
        return
    }
    
    Write-Host "$(Obtener-HoraActual) Procesando $($proyectosAProcesar.Count) proyecto(s) seleccionado(s)" -ForegroundColor Yellow
    
    # Para cambios de rama, pedir nombre de rama una sola vez si hay multiples proyectos
    $nombreRama = $null
    if ($accion -eq "branch" -and $proyectosAProcesar.Count -gt 1) {
        $nombreRama = Read-Host "Ingrese el nombre de la rama para todos los proyectos seleccionados"
    }
    
    foreach ($proyecto in $proyectosAProcesar) {
        Write-Host "`n$(Obtener-HoraActual) Procesando: $($NOMBRES_PROYECTOS[$proyecto])" -ForegroundColor Cyan
        
        switch ($accion) {
            "compile" {
                Compilar-Proyecto $proyecto
            }
            "branch" {
                if (-not $nombreRama) {
                    $nombreRama = Read-Host "Ingrese el nombre de la rama para $($NOMBRES_PROYECTOS[$proyecto])"
                }
                Cambiar-Rama $proyecto $nombreRama
            }
            "copyzip" {
                Copiar-ArchivosZIP $proyecto
            }
            "update" {
                Actualizar-Proyecto $proyecto
            }
            "navigate" {
                NavegarAProyecto $proyecto
            }
        }
    }
    
    Write-Host "`n$(Obtener-HoraActual) Procesamiento de proyectos completado" -ForegroundColor Green
    Read-Host "Presione Enter para volver al menu principal..."
}

# Funcion principal para manejar el menu
function Manejar-MenuPrincipal {
    param (
        [int]$seleccion
    )

    switch ($seleccion) {
        1 { Manejar-SubMenu "compile" }
        2 { Manejar-SubMenu "branch" }
        3 { Manejar-SubMenu "update" }
        4 { Manejar-SubMenu "copyzip" }
        5 { Manejar-SubMenu "navigate" }
        6 { 
            Write-Host "Saliendo..."
            return $false
        }
        default {
            Write-Host "Opcion no valida. Por favor, intente nuevamente."
            Read-Host "Presione Enter para continuar..."
        }
    }

    return $true
}

# Funcion para manejar submenus
function Manejar-SubMenu {
    param (
        [string]$accion
    )
    
    $continuarSubMenu = $true

    while ($continuarSubMenu) {
        Mostrar-SubMenuEntidades
        $seleccionEntidad = Read-Host "Seleccione una entidad (1-10)"

        $listaEntidades = @{
            '1'  = @{ Nombre = "BAVV"; Lista = $BAVV_LIST }
            '2'  = @{ Nombre = "BBOG"; Lista = $BBOG_LIST }
            '3'  = @{ Nombre = "BOCC"; Lista = $BOCC_LIST }
            '4'  = @{ Nombre = "BPOP"; Lista = $BPOP_LIST }
            '5'  = @{ Nombre = "DALE"; Lista = $DALE_LIST }
            '6'  = @{ Nombre = "LIBS"; Lista = $LIBS_LIST }
            '7'  = @{ Nombre = "CREATE"; Lista = $CREATE_LIST }
            '8'  = @{ Nombre = "INQUIRY"; Lista = $INQUIRY_LIST }
            '9'  = @{ Nombre = "MODIFICACIONES"; Lista = $MODIFY_LIST }
            '10' = @{ Nombre = "CANCELACIONES"; Lista = $CANCEL_LIST }
            '11' = @{ Nombre = "TODAS"; Lista = $null }
        }

        if ($listaEntidades.ContainsKey($seleccionEntidad)) {
            $infoEntidad = $listaEntidades[$seleccionEntidad]
            
            if ($infoEntidad.Nombre -eq "TODAS") {
                # Manejar caso de TODAS las entidades
                if ($accion -eq "compile") {
                    Write-Host "$(Obtener-HoraActual) Compilando TODOS los repositorios" -ForegroundColor Yellow
                    foreach ($proyecto in $BAVV_LIST + $BBOG_LIST + $BOCC_LIST + $BPOP_LIST + $DALE_LIST + $LIBS_LIST + $INQUIRY_LIST + $MODIFY_LIST + $CANCEL_LIST) {
                        Compilar-Proyecto $proyecto
                    }
                    Write-Host "$(Obtener-HoraActual) Todas las compilaciones completadas." -ForegroundColor Green
                }
                elseif ($accion -eq "branch") {
                    $nombreRama = Read-Host "Ingrese el nombre de la rama"
                    Write-Host "$(Obtener-HoraActual) Cambiando rama en TODOS los repositorios a $nombreRama" -ForegroundColor Yellow
                    foreach ($proyecto in $BAVV_LIST + $BBOG_LIST + $BOCC_LIST + $BPOP_LIST + $DALE_LIST + $LIBS_LIST + $INQUIRY_LIST + $MODIFY_LIST + $CANCEL_LIST) {
                        Cambiar-Rama $proyecto $nombreRama
                    }
                    Write-Host "$(Obtener-HoraActual) Todos los cambios de rama completados." -ForegroundColor Green
                }
                elseif ($accion -eq "copyzip") {
                    Write-Host "$(Obtener-HoraActual) Copiando todos los archivos ZIP" -ForegroundColor Yellow
                    foreach ($proyecto in $BAVV_LIST + $BBOG_LIST + $BOCC_LIST + $BPOP_LIST + $DALE_LIST + $LIBS_LIST + $INQUIRY_LIST + $MODIFY_LIST + $CANCEL_LIST) {
                        Copiar-ArchivosZIP $proyecto
                    }
                    Write-Host "$(Obtener-HoraActual) Todos los archivos ZIP han sido copiados." -ForegroundColor Green
                }
                elseif ($accion -eq "navigate") {
                    Write-Host "$(Obtener-HoraActual) No se puede abrir todos los proyectos a la vez. Seleccione proyectos individuales." -ForegroundColor Yellow
                }
                else {
                    Write-Host "$(Obtener-HoraActual) Actualizando TODOS los repositorios" -ForegroundColor Yellow
                    foreach ($proyecto in $BAVV_LIST + $BBOG_LIST + $BOCC_LIST + $BPOP_LIST + $DALE_LIST + $LIBS_LIST + $INQUIRY_LIST + $MODIFY_LIST + $CANCEL_LIST) {
                        Actualizar-Proyecto $proyecto
                    }
                    Write-Host "$(Obtener-HoraActual) Todas las actualizaciones completadas." -ForegroundColor Green
                }
                $continuarSubMenu = $false
                Read-Host "Presione Enter para volver al menu principal..."
            }
            else {
                # Mostrar proyectos para la entidad seleccionada
                $mapaProyectos = Mostrar-Proyectos $infoEntidad.Lista
                $maximoIndice = $infoEntidad.Lista.Count + 2
                
                $seleccionProyecto = Read-Host "Seleccione proyectos (1-$($maximoIndice-1), separar con comas"
                
                $selecciones = Procesar-SeleccionesMultiples $seleccionProyecto ($maximoIndice - 1)
                
                if ($selecciones.Count -gt 0) {
                    Procesar-ProyectosSeleccionados $selecciones $mapaProyectos $accion $infoEntidad.Nombre
                    $continuarSubMenu = $false
                }
                else {
                    Write-Host "$(Obtener-HoraActual) Seleccion invalida. Por favor intente nuevamente." -ForegroundColor Red
                    Start-Sleep -Seconds 1
                }
            }
        }
        else {
            Write-Host "$(Obtener-HoraActual) Seleccion de entidad invalida. Por favor intente nuevamente." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}

# Mostrar versión automática si se usa AutoHotkey, manual si no
if ($Accion -and $Proyectos) {
    $VERSION = Mostrar-MenuVersion -AutomaticMode
    InicializarConfiguracionRutas
} else {
    $VERSION = Mostrar-MenuVersion
    InicializarConfiguracionRutas
}

 # Directorio destino de los archivos ZIP
    $ZIP_DESTINATION_PATH = "D:\Compilaciones\"
    

 

    
if (-not (Test-Path -Path $ZIP_DESTINATION_PATH)) {
    New-Item -ItemType Directory -Path $ZIP_DESTINATION_PATH -Force | Out-Null
    Write-Host "$(Obtener-HoraActual) Directorio para archivos ZIP creado: $ZIP_DESTINATION_PATH" -ForegroundColor Green
}
   
if ($Accion -and $Proyectos) {
    EjecutarScriptDesdeAutoHotkey -Accion $Accion -Proyectos $Proyectos -Rama $Rama
    Write-Host "`nPresione Enter para cerrar..." -ForegroundColor Cyan
    Read-Host
} else {
    
    $continuar = $true
    while ($continuar) {
        Mostrar-MenuPrincipal
        $seleccion = Read-Host "Ingrese su seleccion (1-6)"
        $continuar = Manejar-MenuPrincipal $seleccion
    }
} 