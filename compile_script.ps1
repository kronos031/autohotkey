$VERSION = ""
$VPATH=""
$ZIPPATH=""
$GRAD=""

function Get-TimeStamp {
    return Get-Date -Format "HH:mm:ss"
}


# Función para mostrar el menú de selección de versión
function MostrarMenuVersion {
    Clear-Host
    Write-Host "Seleccione la version:" -ForegroundColor Yellow
    Write-Host "1: Version 2.0" -ForegroundColor Cyan
    Write-Host "2: Version 3.0" -ForegroundColor Cyan
    Write-Host "3: Mod MICRO 2.0" -ForegroundColor Red
    
    $seleccion = Read-Host "Ingrese su seleccion (1-2)"
    
    switch ($seleccion) {
        '1' {
            $script:VERSION = "2.0"
            $script:VPATH = "-"
            $script:ZIPPATH="build\distributions\*.zip"
            
            Write-Host "Version 2.0 seleccionada" -ForegroundColor Green
        }
        '2' {
            $script:VERSION = "3.0"
            $script:VPATH = "-micro-"
            $script:ZIPPATH="build\libs\*.zip"
            
            Write-Host "Version 3.0 seleccionada" -ForegroundColor Green
        }
         '3' {
            $script:VERSION = "2.0"
            $script:VPATH = "-"
            $script:ZIPPATH="build\libs\*.zip"
     
             Write-Host "Modificacion 2.0 con micro seleccionada" -ForegroundColor Green
        }
        default {
            Write-Host "Opcion no valida. Se utilizara la version 3.0 por defecto." -ForegroundColor Red
            $script:VERSION = "3.0"
        }
    }
    
    # Esperar un momento para mostrar el mensaje
    Start-Sleep -Seconds 1
    return $VERSION
}

# Llamar a la función para seleccionar la versión al inicio
$VERSION = MostrarMenuVersion


# Añadir variable para el directorio destino de los archivos ZIP
$ZIP_DESTINATION_PATH = "D:\Compilaciones\"

$BAVV_PATH = "D:\Repositorios\SPI\BAVV\" + $VERSION + "\"
$BBOG_PATH = "D:\Repositorios\SPI\BBOG\" + $VERSION + "\"
$BOCC_PATH = "D:\Repositorios\SPI\BOCC\" + $VERSION + "\"
$BPOP_PATH = "D:\Repositorios\SPI\BPOP\" + $VERSION + "\"
$DALE_PATH = "D:\Repositorios\SPI\DALE\" + $VERSION + "\"
$LIBS_PATH = 'D:\Repositorios\SPI\LIBS\'

# Corregir las rutas para que sean consistentes (sin backslash extra al principio)


$BAVV_CREATE_DIR = $BAVV_PATH  + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-val-create" + $VPATH + "bavv"
$BBOG_CREATE_DIR = $BBOG_PATH  + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-val-create" + $VPATH + "bbog"
$BOCC_CREATE_DIR = $BOCC_PATH  + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-val-create" + $VPATH + "bocc"
$BPOP_CREATE_DIR = $BPOP_PATH  + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-val-create" + $VPATH + "bpop"
$DALE_CREATE_DIR = $DALE_PATH  + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-val-create" + $VPATH + "dale"

$BAVV_MOD_DIR = $BAVV_PATH     + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-val-mod" + $VPATH + "bavv" 
$BBOG_MOD_DIR = $BBOG_PATH     + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-val-mod" + $VPATH + "bbog"
$BOCC_MOD_DIR = $BOCC_PATH     + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-val-mod" + $VPATH + "bocc"
$BPOP_MOD_DIR = $BPOP_PATH     + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-val-mod" + $VPATH + "bpop"
$DALE_MOD_DIR = $DALE_PATH     + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-val-mod" + $VPATH + "dale"

$BAVV_CANCEL_DIR = $BAVV_PATH  + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-val-cancel" + $VPATH + "bavv"
$BBOG_CANCEL_DIR = $BBOG_PATH  + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-val-cancel" + $VPATH + "bbog"
$BOCC_CANCEL_DIR = $BOCC_PATH  + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-val-cancel" + $VPATH + "bocc"
$BPOP_CANCEL_DIR = $BPOP_PATH  + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-val-cancel" + $VPATH + "bpop"
$DALE_CANCEL_DIR = $DALE_PATH  + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-val-cancel" + $VPATH + "dale"

$BAVV_INQUIRY_DIR = $BAVV_PATH + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-inquiry" + $VPATH + "bavv"
$BBOG_INQUIRY_DIR = $BBOG_PATH + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-inquiry" + $VPATH + "bbog"
$BOCC_INQUIRY_DIR = $BOCC_PATH + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-inquiry" + $VPATH + "bocc"
$BPOP_INQUIRY_DIR = $BPOP_PATH + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-inquiry" + $VPATH + "bpop"
$DALE_INQUIRY_DIR = $DALE_PATH + "SISTEMA-PAGOS-INMEDIATOS-SPI-BACK-lambda-java-inquiry" + $VPATH + "dale"


$LIBS_SYNC_DIR = $LIBS_PATH  + 'SISTEMA-PAGOS-INMEDIATOS-BACK-lambda-java-synch-dyn-open'

$BAVV_LIST = @($BAVV_CREATE_DIR, $BAVV_MOD_DIR, $BAVV_CANCEL_DIR, $BAVV_INQUIRY_DIR)
$BBOG_LIST = @($BBOG_CREATE_DIR, $BBOG_MOD_DIR, $BBOG_CANCEL_DIR, $BBOG_INQUIRY_DIR)
$BOCC_LIST = @($BOCC_CREATE_DIR, $BOCC_MOD_DIR, $BOCC_CANCEL_DIR, $BOCC_INQUIRY_DIR)
$BPOP_LIST = @($BPOP_CREATE_DIR, $BPOP_MOD_DIR, $BPOP_CANCEL_DIR, $BPOP_INQUIRY_DIR)
$DALE_LIST = @($DALE_CREATE_DIR, $DALE_MOD_DIR, $DALE_CANCEL_DIR, $DALE_INQUIRY_DIR)
$LIBS_LIST = @($LIBS_SYNC_DIR)
$INQUIRY_LIST = @($BAVV_INQUIRY_DIR, $BBOG_INQUIRY_DIR, $BOCC_INQUIRY_DIR, $BPOP_INQUIRY_DIR, $DALE_INQUIRY_DIR)
$MODIFY_LIST = @($BAVV_MOD_DIR, $BBOG_MOD_DIR, $BOCC_MOD_DIR, $BPOP_MOD_DIR, $DALE_MOD_DIR)
$CANCEL_LIST = @($BAVV_CANCEL_DIR, $BBOG_CANCEL_DIR, $BOCC_CANCEL_DIR, $BPOP_CANCEL_DIR, $DALE_CANCEL_DIR)

# Dictionary to map project names to their paths for display - Eliminar entradas duplicadas
$PROJECT_NAMES = @{
    # BAVV Projects
    $BAVV_CREATE_DIR = "BAVV - Create"
    $BAVV_MOD_DIR = "BAVV - Modify"  
    $BAVV_CANCEL_DIR = "BAVV - Cancel"
    $BAVV_INQUIRY_DIR = "BAVV - Inquiry"
    
    # BBOG Projects
    $BBOG_CREATE_DIR = "BBOG - Create"
    $BBOG_MOD_DIR = "BBOG - Modify"
    $BBOG_CANCEL_DIR = "BBOG - Cancel"
    $BBOG_INQUIRY_DIR = "BBOG - Inquiry"
    
    # BOCC Projects
    $BOCC_CREATE_DIR = "BOCC - Create"
    $BOCC_MOD_DIR = "BOCC - Modify"
    $BOCC_CANCEL_DIR = "BOCC - Cancel"
    $BOCC_INQUIRY_DIR = "BOCC - Inquiry"
    
    # BPOP Projects
    $BPOP_CREATE_DIR = "BPOP - Create"
    $BPOP_MOD_DIR = "BPOP - Modify"
    $BPOP_CANCEL_DIR = "BPOP - Cancel"
    $BPOP_INQUIRY_DIR = "BPOP - Inquiry"
    
    # DALE Projects
    $DALE_CREATE_DIR = "DALE - Create"
    $DALE_MOD_DIR = "DALE - Modify"
    $DALE_CANCEL_DIR = "DALE - Cancel"
    $DALE_INQUIRY_DIR = "DALE - Inquiry"

    # LIBS Projects
    $LIBS_SYNC_DIR = "SYNC-DYN-OPEN"
}

# Nueva función para copiar los archivos ZIP generados
$horaLog = Get-Date -Format "HH:mm:ss"

function copyZipFiles($projectPath) {
     
    Write-Host "$(Get-TimeStamp) Copiando archivos ZIP generados desde: $($PROJECT_NAMES[$projectPath])" -ForegroundColor Cyan
    
    # Crear el directorio destino si no existe
    if (-not (Test-Path -Path $ZIP_DESTINATION_PATH)) {
        New-Item -ItemType Directory -Path $ZIP_DESTINATION_PATH -Force | Out-Null
        Write-Host "$(Get-TimeStamp) Directorio de destino creado: $ZIP_DESTINATION_PATH" -ForegroundColor Yellow
    }
    
    # Buscar archivos ZIP en la carpeta build/distributions
    $zipPath = Join-Path -Path $projectPath -ChildPath $ZIPPATH
    $zipFiles = Get-ChildItem -Path $zipPath -ErrorAction SilentlyContinue
    
    if ($zipFiles.Count -gt 0) {
        foreach ($zipFile in $zipFiles) {
            $destinationFile = Join-Path -Path $ZIP_DESTINATION_PATH -ChildPath $zipFile.Name
            Copy-Item -Path $zipFile.FullName -Destination $destinationFile -Force
            Write-Host "$(Get-TimeStamp) Copiado: $($zipFile.Name)" -ForegroundColor Green
        }
        Write-Host "$(Get-TimeStamp) Total archivos copiados: $($zipFiles.Count)" -ForegroundColor Green
    } else {
        Write-Host "$(Get-TimeStamp) No se encontraron archivos ZIP para copiar en $projectPath" -ForegroundColor Yellow
    }
}

# Función para copiar todos los ZIPs de una entidad
function copyEntityZips($ENTITY_LIST) {
    foreach($rep in $ENTITY_LIST) {
        copyZipFiles $rep
    }
}

function compileEntity ($ENTITY_LIST){
    foreach($rep in $ENTITY_LIST)
    {
        
        Write-Host "$(Get-TimeStamp) Compiling project : $rep"
        Set-Location $rep
        git branch
        #gradle clean
        #gradle buildDependents
        if ($VERSION -eq "3.0") {
         
            gradle buildNativeLambda
        } elseif ($VERSION -eq "2.0" -and $VPATH -eq "-") {
            
            gradle buildNativeLambda
        }else {
            
            gradle buildZip
        }
               
        #gradle buildZip

        # Copiar los archivos ZIP después de compilar
        copyZipFiles $rep
    }
}

function compileSingleProject($projectPath) {
    Write-Host "$(Get-TimeStamp) Compiling project: $($PROJECT_NAMES[$projectPath])" -ForegroundColor Cyan
    Set-Location $projectPath
    git branch
    #gradle clean
    #gradle buildDependents
    if ($VERSION -eq "3.0") {
         
        gradle buildNativeLambda
    } elseif ($VERSION -eq "2.0" -and $VPATH -eq "-") {
        
        gradle buildNativeLambda
    } else {
        
        gradle buildZip
    }
    # gradle buildZip 
    # Copiar los archivos ZIP después de compilar 
    copyZipFiles $projectPath
    Write-Host "$(Get-TimeStamp) Compilation completed for: $($PROJECT_NAMES[$projectPath])" -ForegroundColor Green
}

function changeBranchEntity ($ENTITY_LIST, $branchName){
    foreach($rep in $ENTITY_LIST)
    {
        Write-Host "$(Get-TimeStamp) Changing branch in repo: $rep to $branchName"
        Set-Location $rep
        git fetch
        git checkout $branchName
        
        # Check if checkout was successful
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$(Get-TimeStamp) Successfully changed to branch $branchName" -ForegroundColor Green
            git pull
        } else {
            Write-Host "$(Get-TimeStamp) Failed to change to branch $branchName" -ForegroundColor Red
        }
    }
}

function changeBranchSingleProject($projectPath, $branchName) {
    Write-Host "$(Get-TimeStamp) Changing branch in project: $($PROJECT_NAMES[$projectPath]) to $branchName" -ForegroundColor Cyan
    Set-Location $projectPath
    git fetch
    git checkout $branchName
    
    # Check if checkout was successful
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$(Get-TimeStamp) Successfully changed to branch $branchName" -ForegroundColor Green
        git pull
    } else {

        Write-Host "$(Get-TimeStamp) Failed to change to branch $branchName" -ForegroundColor Red
    }
}

function updateEntity ($ENTITY_LIST){
    foreach($rep in $ENTITY_LIST)
    {
        Write-Host "$(Get-TimeStamp) Updating repo : $rep" -ForegroundColor Cyan
        Set-Location $rep
        git fetch
        git pull
        gradle publishToMavenLocal
        Write-Host "$(Get-TimeStamp) Update completed for: $rep" -ForegroundColor Green
    }
}

function updateSingleProject($projectPath) {
    Write-Host "$(Get-TimeStamp) Updating project: $($PROJECT_NAMES[$projectPath])" -ForegroundColor Cyan
    Set-Location $projectPath
    git fetch
    git pull
    gradle publishToMavenLocal
    Write-Host "$(Get-TimeStamp) Update completed for: $($PROJECT_NAMES[$projectPath])" -ForegroundColor Green
}

function MostrarMenuPrincipal {
    param (
        [switch]$limpiarPantalla = $true
    )

    if ($limpiarPantalla) {
        Clear-Host
    }
    Write-Host "Version seleccionada $VERSION"    -ForegroundColor Gray
    Write-Host "1: Compilar"    -ForegroundColor Gray
    Write-Host "2: CambiarRama" -ForegroundColor Yellow
    Write-Host "3: Actualizar"  -ForegroundColor Blue
    Write-Host "4: Copiar ZIPs" -ForegroundColor Green # Nueva opcion
    Write-Host "5: Salir"       -ForegroundColor Red
}

function MostrarSubMenu {
    Clear-Host
    Write-Host "Available Entities: "
    Write-Host "1: BAVV"
    Write-Host "2: BBOG"
    Write-Host "3: BOCC"
    Write-Host "4: BPOP"
    Write-Host "5: DALE"
    Write-Host "6: LIBS"
    Write-Host "7: INQUIRY"
    Write-Host "8: MODIFY"
    Write-Host "9: CANCEL"
    Write-Host "10: ALL"
    
}

function MostrarProyectos($projectList) {
    Clear-Host
    Write-Host "Select a project:" -ForegroundColor Yellow
    
    $index = 1
    $projectsMap = @{}
    
    foreach($project in $projectList) {
        Write-Host "$index`: $($PROJECT_NAMES[$project])"
        $projectsMap[$index.ToString()] = $project
        $index++
    }
    
    Write-Host "$index`: ALL projects"
    $index=$index+1
    Write-Host "$index`: MostrarMenuPrincipal"
    return $projectsMap
}

function ManejarSeleccionMenuPrincipal {
    param (
        [int]$seleccion
    )

    switch ($seleccion) {
        '1' {
            ManejarSubMenu "compile"
        }
        '2' {
            ManejarSubMenu "branch"
        }
        '3' {
            ManejarSubMenu "update"
        }
        '4' {
            ManejarSubMenu "copyzip" # Nueva opcion
        }
        '5' {
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

function ManejarSubMenu {
    param (
        [string]$action
    )
    
    $continuarSubMenu = $true

    while ($continuarSubMenu) {
        MostrarSubMenu
        $seleccionSubmenu = Read-Host "Select an Entity"

        switch ($seleccionSubmenu) {
            '1' {
                if ($action -eq "compile") {
                    ManejarSeleccionProyecto $BAVV_LIST "BAVV" "compile"
                } elseif ($action -eq "branch") {
                    ManejarSeleccionProyecto $BAVV_LIST "BAVV" "branch"
                } elseif ($action -eq "copyzip") {
                    ManejarSeleccionProyecto $BAVV_LIST "BAVV" "copyzip"
                } else {
                    ManejarSeleccionProyecto $BAVV_LIST "BAVV" "update"
                }
                $continuarSubMenu = $false
            }
            '2' {
                if ($action -eq "compile") {
                    ManejarSeleccionProyecto $BBOG_LIST "BBOG" "compile"
                } elseif ($action -eq "branch") {
                    ManejarSeleccionProyecto $BBOG_LIST "BBOG" "branch"
                } elseif ($action -eq "copyzip") {
                    ManejarSeleccionProyecto $BBOG_LIST "BBOG" "copyzip"
                } else {
                    ManejarSeleccionProyecto $BBOG_LIST "BBOG" "update"
                }
                $continuarSubMenu = $false
            }
            '3' {
                if ($action -eq "compile") {
                    ManejarSeleccionProyecto $BOCC_LIST "BOCC" "compile"
                } elseif ($action -eq "branch") {
                    ManejarSeleccionProyecto $BOCC_LIST "BOCC" "branch"
                } elseif ($action -eq "copyzip") {
                    ManejarSeleccionProyecto $BOCC_LIST "BOCC" "copyzip"
                } else {
                    ManejarSeleccionProyecto $BOCC_LIST "BOCC" "update"
                }
                $continuarSubMenu = $false
            }
            '4' {
                if ($action -eq "compile") {
                    ManejarSeleccionProyecto $BPOP_LIST "BPOP" "compile"
                } elseif ($action -eq "branch") {
                    ManejarSeleccionProyecto $BPOP_LIST "BPOP" "branch"
                } elseif ($action -eq "copyzip") {
                    ManejarSeleccionProyecto $BPOP_LIST "BPOP" "copyzip"
                } else {
                    ManejarSeleccionProyecto $BPOP_LIST "BPOP" "update"
                }
                $continuarSubMenu = $false
            }
            '5' {
                if ($action -eq "compile") {
                    ManejarSeleccionProyecto $DALE_LIST "DALE" "compile"
                } elseif ($action -eq "branch") {
                    ManejarSeleccionProyecto $DALE_LIST "DALE" "branch"
                } elseif ($action -eq "copyzip") {
                    ManejarSeleccionProyecto $DALE_LIST "DALE" "copyzip"
                } else {
                    ManejarSeleccionProyecto $DALE_LIST "DALE" "update"
                }
                $continuarSubMenu = $false
            }
            '6' {
                 if ($action -eq "compile") {
                     ManejarSeleccionProyecto $LIBS_LIST "LIBS" "compile"
                 } elseif ($action -eq "branch") {
                     ManejarSeleccionProyecto $LIBS_LIST "LIBS" "branch"
                 } elseif ($action -eq "copyzip") {
                     ManejarSeleccionProyecto $LIBS_LIST "LIBS" "copyzip"
                 } else {
                     ManejarSeleccionProyecto $LIBS_LIST "LIBS" "update"
                 }
                 $continuarSubMenu = $false
                }
             '7' {
                if ($action -eq "compile") {
                    ManejarSeleccionProyecto $INQUIRY_LIST "INQUIRY" "compile"
                } elseif ($action -eq "branch") {
                    ManejarSeleccionProyecto $INQUIRY_LIST "INQUIRY" "branch"
                } elseif ($action -eq "copyzip") {
                    ManejarSeleccionProyecto $INQUIRY_LIST "INQUIRY" "copyzip"
                } else {
                    ManejarSeleccionProyecto $INQUIRY_LIST "INQUIRY" "update"
                }
                $continuarSubMenu = $false
                }        
            '8' {
                 if ($action -eq "compile") {
                     ManejarSeleccionProyecto $MODIFY_LIST "MODIFY" "compile"
                 } elseif ($action -eq "branch") {
                     ManejarSeleccionProyecto $MODIFY_LIST "MODIFY" "branch"
                 } elseif ($action -eq "copyzip") {
                     ManejarSeleccionProyecto $MODIFY_LIST "MODIFY" "copyzip"
                 } else {
                     ManejarSeleccionProyecto $MODIFY_LIST "MODIFY" "update"
                 }
                 $continuarSubMenu = $false
                }    
            '9' {
                 if ($action -eq "compile") {
                     ManejarSeleccionProyecto $CANCEL_LIST "CANCEL" "compile"
                 } elseif ($action -eq "branch") {
                     ManejarSeleccionProyecto $CANCEL_LIST "CANCEL" "branch"
                 } elseif ($action -eq "copyzip") {
                     ManejarSeleccionProyecto $CANCEL_LIST "CANCEL" "copyzip"
                 } else {
                     ManejarSeleccionProyecto $CANCEL_LIST "CANCEL" "update"
                 }
                 $continuarSubMenu = $false
                }        
            '10' {
                if ($action -eq "compile") {
                    Write-Host "$horaLog Compiling ALL repositories" -ForegroundColor Yellow
                    compileEntity($BAVV_LIST)
                    compileEntity($BBOG_LIST)
                    compileEntity($BOCC_LIST)
                    compileEntity($BPOP_LIST)
                    compileEntity($DALE_LIST)
                    compileEntity($LIBS_LIST)
                    compileEntity($INQUIRY_LIST)
                    compileEntity($MODIFY_LIST)
                    compileEntity($CANCEL_LIST)
                    Write-Host "$horaLog All compilations completed." -ForegroundColor Green
                } elseif ($(Get-TimeStamp) -eq "branch") {
                    $branchName = Read-Host "Enter the branch name"
                    Write-Host "$(Get-TimeStamp) Changing branch in ALL repositories to $branchName" -ForegroundColor Yellow
                    changeBranchEntity $BAVV_LIST $branchName
                    changeBranchEntity $BBOG_LIST $branchName
                    changeBranchEntity $BOCC_LIST $branchName
                    changeBranchEntity $BPOP_LIST $branchName
                    changeBranchEntity $DALE_LIST $branchName
                    changeBranchEntity $LIBS_LIST $branchName
                    changeBranchEntity $INQUIRY_LIST $branchName
                    changeBranchEntity $MODIFY_LIST $branchName
                    changeBranchEntity $CANCEL_LIST $branchName
                    Write-Host "$(Get-TimeStamp) All branch changes completed." -ForegroundColor Green
                } elseif ($action -eq "copyzip") {
                    Write-Host "$(Get-TimeStamp)horaLog Copiando todos los archivos ZIP" -ForegroundColor Yellow
                    copyEntityZips($BAVV_LIST)
                    copyEntityZips($BBOG_LIST)
                    copyEntityZips($BOCC_LIST)
                    copyEntityZips($BPOP_LIST)
                    copyEntityZips($DALE_LIST)
                    copyEntityZips($LIBS_LIST)
                    copyEntityZips($INQUIRY_LIST)
                    copyEntityZips($MODIFY_LIST)
                    copyEntityZips($CANCEL_LIST)
                    Write-Host "$(Get-TimeStamp)raLog Todos los archivos ZIP han sido copiados." -ForegroundColor Green
                } else {
                    Write-Host "$(Get-TimeStamp) Updating ALL repositories" -ForegroundColor Yellow
                    updateEntity($BAVV_LIST)
                    updateEntity($BBOG_LIST)
                    updateEntity($BOCC_LIST)
                    updateEntity($BPOP_LIST)
                    updateEntity($DALE_LIST)
                    updateEntity($LIBS_LIST)
                    updateEntity($INQUIRY_LIST)
                    updateEntity($MODIFY_LIST)
                    updateEntity($CANCEL_LIST)
                    Write-Host "$(Get-TimeStamp) All updates completed." -ForegroundColor Green
                }
                $continuarSubMenu = $false
                Read-Host "Press Enter to continue to main menu..."
            }
            default {
                Write-Host "Opcion no valida. Por favor, intente nuevamente."
                Read-Host "Presione Enter para continuar..."
            }
        }
    }
}

function ManejarSeleccionProyecto($projectList, $entityName, $action) {
    $projectsMap = MostrarProyectos $projectList
    $totalProjects = $projectList.Count
    
    $seleccionProyecto = Read-Host "Select a project (1-$($totalProjects+2))"
    
    if ($seleccionProyecto -match '^\d+$' -and [int]$seleccionProyecto -ge 1 -and [int]$seleccionProyecto -le $totalProjects+2) {
        if ([int]$seleccionProyecto -eq $totalProjects+1) {
            # Process all projects
            if ($action -eq "compile") {
                Write-Host "$(Get-TimeStamp) Compiling all $entityName projects" -ForegroundColor Yellow
                compileEntity($projectList)
                Write-Host "$(Get-TimeStamp) Compilation finished." -ForegroundColor Green
            } elseif ($action -eq "branch") {
                $branchName = Read-Host "Enter the branch name"
                Write-Host "$(Get-TimeStamp) Changing branch in all $entityName projects to $branchName" -ForegroundColor Yellow
                changeBranchEntity $projectList $branchName
                Write-Host "$(Get-TimeStamp) Branch change operations completed." -ForegroundColor Green
            } elseif ($action -eq "copyzip") {
                Write-Host "$(Get-TimeStamp) Copiando archivos ZIP de todos los proyectos $entityName" -ForegroundColor Yellow
                copyEntityZips($projectList)
                Write-Host "$(Get-TimeStamp) Copia de archivos ZIP completada." -ForegroundColor Green
            } else {
                Write-Host "$(Get-TimeStamp) Updating all $entityName projects" -ForegroundColor Yellow
                updateEntity($projectList)
                Write-Host "$(Get-TimeStamp) Update operations completed." -ForegroundColor Green
            }
            Read-Host "Press Enter to continue to main menu..."
        } elseif ([int]$seleccionProyecto -eq $totalProjects+2) {
            # Volver al menú principal
            Write-Host "$(Get-TimeStamp) Volviendo al menú principal..." -ForegroundColor Cyan
            return
        } else {
            # Process specific project
            $selectedProject = $projectsMap[$seleccionProyecto]
            if ($action -eq "compile") {
                compileSingleProject $selectedProject
                Read-Host "Press Enter to continue to main menu..."
            } elseif ($action -eq "branch") {
                $branchName = Read-Host "Enter the branch name"
                changeBranchSingleProject $selectedProject $branchName
                Read-Host "Press Enter to continue to main menu..."
            } elseif ($action -eq "copyzip") {
                copyZipFiles $selectedProject
                Read-Host "Press Enter to continue to main menu..."
            } else {
                updateSingleProject $selectedProject
                Read-Host "Press Enter to continue to main menu..."
            }
        }
    } else {
        Write-Host "$(Get-TimeStamp) Opción no válida. Volviendo al menú principal." -ForegroundColor Red
        Read-Host "Presione Enter para continuar..."
    }
}

# Verificar y crear el directorio de destino de ZIP al inicio
if (-not (Test-Path -Path $ZIP_DESTINATION_PATH)) {
    New-Item -ItemType Directory -Path $ZIP_DESTINATION_PATH -Force | Out-Null
    Write-Host "$(Get-TimeStamp) Directorio para archivos ZIP creado: $ZIP_DESTINATION_PATH" -ForegroundColor Green
}

# Script principal
$continuar = $true
while ($continuar) {
    MostrarMenuPrincipal
    $seleccion = Read-Host "Ingrese su seleccion (1-5)"
    $continuar = ManejarSeleccionMenuPrincipal $seleccion
}