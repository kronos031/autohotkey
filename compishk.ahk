; MAPEO OPTIMIZADO - Versión mejorada
CrearProyectoMap() {
    proyectos := ["BAVV", "BBOG", "BOCC", "BPOP", "DALE"]
    acciones := Map(
        "Create", "CREATE_DIR",
        "Modify", "MOD_DIR", 
        "Cancel", "CANCEL_DIR",
        "Inquiry", "INQUIRY_DIR",
        "TimeSt","TIME_DIR",
        "ActTime","ACTTIME_DIR",
        "Open", "OPEN_DIR",
		"Cancel_Id", "CANCEL_DIR_ID"
    ) 
    proyectoMap := Map()
    
    for proyecto in proyectos {
        proyectoMap[proyecto] := Map()
        for accion, sufijo in acciones {
            proyectoMap[proyecto][accion] := proyecto . "_" . sufijo
        }
    } 
    return proyectoMap
}

; Inicializar el mapeo optimizado
proyectoMap := CrearProyectoMap()
 
entidades := ["BAVV", "BBOG", "BOCC", "BPOP", "DALE"]
libs := [ "Artefactos","Redeban", "Corner","Commons", "Sync", "Open","Open_BAVV","Open_BBOG","Open_BOCC","Open_BPOP","Open_DALE"]
transv:= ["Create","Modify","Cancel","Run-GLue","PGP","Consent"]
operaciones := ["Create", "Modify", "Cancel", "Inquiry","TimeSt","ActTime","Open","Cancel_Id"]
acciones := ["compile", "update", "branch", "copyzip", "navigate"]
versiones := ["Java", "Micronaut", "MicroMod"]

; Crear GUI
myGui := Gui("+AlwaysOnTop +Resize", "Menú SPI")
myGui.Font := "s10 Segoe UI"
myGui.BackColor := "0xF0F0F0"

; Título
myGui.AddText("x20 y15 w250 Center", "Sistema de Pagos Inmediatos - SPI").Font := "s12 Bold"

; Sección de Entidades
myGui.AddText("x20 y50", "Entidades:").Font := "s10 Bold"
lbEntidades := myGui.AddListBox("x20 y70 w70 r5 Multi", entidades)

; Sección de Operaciones
myGui.AddText("x120 y50", "Operaciones:").Font := "s10 Bold"
lbOperaciones := myGui.AddListBox("x120 y70 w70 r5 Multi", operaciones)

; Sección de Librerías
myGui.AddText("x220 y50", "Librerias:").Font := "s10 Bold"
lbLibrerias := myGui.AddListBox("x220 y70 w90 r6 Multi", libs)

; Sección de Transversales
myGui.AddText("x220 y160", "Transversales:").Font := "s10 Bold"
lbtransv := myGui.AddListBox("x220 y180 w90 r6 Multi", transv)

; Sección de Acciones
myGui.AddText("x20 y160", "Acción:").Font := "s10 Bold"
cbAccion := myGui.AddListBox("x20 y180 w70 r5", acciones)
 
btnSync := myGui.AddButton("x120 y150 w70 h30 Default", "Sync")
btnSync.OnEvent("Click", Sync)

; Botones
btnEjecutar := myGui.AddButton("x120 y185 w70 h30 Default", "Ejecutar")
btnEjecutar.OnEvent("Click", Ejecutar)


btnLimpiar := myGui.AddButton("x120 y220 w70 h30", "Limpiar")
btnLimpiar.OnEvent("Click", LimpiarSelecciones)

myGui.AddText("x240 y15", "Ver.").Font := "s12 Bold"
cbVersion  := myGui.AddComboBox("x265 y13 w70 r6", versiones)
cbVersion.Choose(2)

 
; Área de estado
myGui.AddText("x20 y270", "Estado:").Font := "s10 Bold"
txtEstado := myGui.AddEdit("x20 y290 w330 r8 ReadOnly VScroll", "Listo para ejecutar comandos...")

myGui.Show("x860 w360 h450") 

; Función para limpiar selecciones
LimpiarSelecciones(*) {
    lbEntidades.Choose(0)
    lbOperaciones.Choose(0)
    lbLibrerias.Choose(0)
    lbtransv.Choose(0)
    cbAccion.Choose(0)  
    ActualizarEstado("Selecciones limpiadas")
}

; Función para actualizar el estado
ActualizarEstado(mensaje) {
    tiempo := FormatTime(, "HH:mm:ss")
    txtEstado.Text := tiempo . " - " . mensaje . "`r`n" . txtEstado.Text
}
  
Sync(*) {
    pythonPath := "C:\Users\" . A_UserName . "\AppData\Local\Microsoft\WindowsApps\python3.11.exe"
    scriptPath := "c:\Users\" . A_UserName . "\Desktop\autohotkey\sync.py"
    ;destino := "bavp"
    ;Run('pwsh.exe -NoExit -Command "& \"' . pythonPath . '\" \"' . scriptPath . '\""' . " destino " . destino )
    Run('pwsh.exe -NoExit -Command "& \"' . pythonPath . '\" \"' . scriptPath . '\""'  )
}

; Función principal de ejecución - CORREGIDA
Ejecutar(*) { 
    entidadesSeleccionadas := lbEntidades.Value
    operacionesSeleccionadas := lbOperaciones.Value
    libreriasSeleccionadas :=  lbLibrerias.Value  
    transversalesSeleccionadas :=  lbtransv.Value  
    accionSeleccionada := cbAccion.Text
    versionSeleccionada := cbVersion.Text
     
    
    ; Convertir strings vacíos a arrays vacíos para consistencia
    if (Type(entidadesSeleccionadas) = "String") {
        entidadesSeleccionadas := []
    }
    if (Type(operacionesSeleccionadas) = "String") {
        operacionesSeleccionadas := []
    }
    if (Type(libreriasSeleccionadas) = "String") {
        libreriasSeleccionadas := []
    }
    if (Type(transversalesSeleccionadas) = "String") {
        transversalesSeleccionadas := []
    }

    ; Si hay entidades seleccionadas, debe haber operaciones
    if (entidadesSeleccionadas.Length > 0 && operacionesSeleccionadas.Length = 0) {
        ActualizarEstado("ERROR: Las entidades requieren al menos una operación")
        return
    }
    
    ; Si hay librerías seleccionadas, no necesitan operaciones (solo acciones)
    if (libreriasSeleccionadas.Length > 0 && operacionesSeleccionadas.Length > 0) {
        ActualizarEstado("ADVERTENCIA: Las librerías no usan operaciones, solo acciones")
    }
    
    if (transversalesSeleccionadas.Length > 0 && operacionesSeleccionadas.Length > 0) {
        ActualizarEstado("ADVERTENCIA: Las transversales no usan operaciones, solo acciones")
    }

    if (!accionSeleccionada) {
        ActualizarEstado("ERROR: Selecciona una acción")
        return
    } 

    ; Construir lista de proyectos
    proyectosStr := ConstruirListaProyectos(entidadesSeleccionadas, operacionesSeleccionadas, libreriasSeleccionadas, transversalesSeleccionadas)
    
    if (!proyectosStr) {
        ActualizarEstado("ERROR: No se pudieron mapear los proyectos seleccionados")
        return
    }

    ; Ejecutar comando
    ActualizarEstado("Iniciando ejecución...")
    
    try {
        psCommand := ConstruirComandoPowerShell(accionSeleccionada, proyectosStr, versionSeleccionada)
        ActualizarEstado("Comando: " . psCommand)
        
        ; Ejecutar comando de PowerShell
        RunWait(psCommand,,)
        
        ActualizarEstado("Ejecución completada exitosamente") 
        
    } catch Error as e {
        ActualizarEstado("Error: " . e.Message)
        MsgBox("Error al ejecutar: " . e.Message, "Error", "Icon!")
    }
}
 ;Construir lista de proyectos
ConstruirListaProyectos(entidadesSeleccionadas, operacionesSeleccionadas, libreriasSeleccionadas, transversalesSeleccionadas) {
    proyectos := []
    
    ; Convertir índices a nombres
    entidadesNombres := []
    for indice in entidadesSeleccionadas {
        entidadesNombres.Push(entidades[indice])
    }
    
    operacionesNombres := []
    for indice in operacionesSeleccionadas {
        operacionesNombres.Push(operaciones[indice])
    }
    
    ; Construir combinaciones usando el mapeo optimizado
    for entidad in entidadesNombres {
        for operacion in operacionesNombres {
            if (proyectoMap.Has(entidad) && proyectoMap[entidad].Has(operacion)) {
                proyectos.Push(entidad . "-" . operacion)
            } else {
                ; Log de advertencia para debugging
                ActualizarEstado("Advertencia: Mapeo no encontrado para " . entidad . "-" . operacion)
            }
        }
    }
    
 ; Procesar LIBRERÍAS (NO requieren operaciones, solo acciones)
    if (libreriasSeleccionadas.Length > 0) {
        ; Convertir índices a nombres de librerías
        libreriasNombres := []
        for indice in libreriasSeleccionadas {
            libreriaNombre := libs[indice]
             libreriasNombres.Push("LIBS-" . libreriaNombre)
        }
        
        ; Agregar librerías directamente (sin operaciones)
        for libreria in libreriasNombres {
            proyectos.Push(libreria)
        }
    }
    
    ; Procesar Transversales (NO requieren operaciones, solo acciones)
    if (transversalesSeleccionadas.Length > 0) {
        ; Convertir índices a nombres de librerías
        transversalesNombres := []
        for indice in transversalesSeleccionadas {
            transversalNombre := transv[indice]
             transversalesNombres.Push("TRANSV-" . transversalNombre)
        }
        
        ; Agregar Transversales directamente (sin operaciones)
        for transversal in transversalesNombres {
            proyectos.Push(transversal)
        }
    }

    if (proyectos.Length = 0) {
        return ""
    }
    
    return StrJoin(proyectos, ",")
}

; Función para construir el comando PowerShell
ConstruirComandoPowerShell(accion, proyectosStr, versionSeleccionada) {
    ps1Path := "C:\Users\" . A_UserName . "\Desktop\autohotkey\compile_script.ps1" 
    
    args := Format('-Accion "{1}" -Proyectos "{2}" -VersHot "{3}"', accion, proyectosStr, versionSeleccionada)
    
    comando := Format('pwsh.exe -File "{1}" {2}', ps1Path, args)
    
    ActualizarEstado("DEBUG - Comando completo: " . comando)
    
    return comando
}

; Función auxiliar para unir array con delimitador
StrJoin(arr, delim := ",") {
    if (arr.Length = 0) {
        return ""
    }
    
    result := arr[1]
    if (arr.Length > 1) {
        for i in Range(2, arr.Length) {
            result .= delim . arr[i]
        }
    }
    
    return result
}

; Función para crear un rango de números
Range(start, end) {
    arr := []
    Loop end - start + 1 {
        arr.Push(start + A_Index - 1)
    }
    return arr
}

; Función auxiliar para verificar si un valor existe en un array
HasValue(arr, valor) {
    for item in arr {
        if (item = valor) {
            return true
        }
    }
    return false
}
 