#Requires AutoHotkey v2.0

; Variables globales para configuración
global selectedEnv := "pt"
global selectedPath := ""
global deployMode := "ALL" ; "ALL" o "INDIVIDUAL"

; Crear GUI moderna y compacta
MyGui := Gui("  -Caption +Border", "Menú de Opciones")
MyGui.BackColor := "0x1A1A2E"
MyGui.SetFont("s10 c0xEEEEEE", "Segoe UI")

; Header visual
MyGui.Add("Text", "x0 y0 w440 h60 Background0x0F3460 Center 0x200")
MyGui.Add("Text", "x80  y0 w440 h60 BackgroundTrans   0x200", "⚡ AWS").SetFont("s16 Bold c0xE94560")

; Panel de configuración
MyGui.Add("Text", "x15 y70 w225 h160 Background0x16213E")

; Ambiente
MyGui.Add("Text", "x30 y78 w120 h25 BackgroundTrans", "🌐 Ambiente:").SetFont("s10 Bold c0x4ECCA3")
ddlEnvironment := MyGui.Add("DropDownList", "x150 y78 w80 Background0x0F3460", ["pt", "qa", "prd"])
ddlEnvironment.Choose(1)
ddlEnvironment.OnEvent("Change", (*) => UpdateEnvironment())

; Ruta
MyGui.Add("Text", "x30 y115 w120 h25 BackgroundTrans", "📁 Ruta Base:").SetFont("s10 Bold c0x4ECCA3")
edtPath := MyGui.Add("Edit", "x30 y145 w200 h25 Background0x0F3460 c0xEEEEEE", "D:\Compilaciones\")
btnBrowse := MyGui.Add("Button", "x150 y115 w80  h25 Background0xE94560 c0xFFFFFF", "...")
btnBrowse.OnEvent("Click", (*) => BrowseFolder())

; Modo de despliegue
MyGui.Add("Text", "x30 y180 w120 h25 BackgroundTrans", "🎯 Modo:").SetFont("s10 Bold c0x4ECCA3")
ddlMode := MyGui.Add("DropDownList", "x30 y205 w200 Background0x0F3460", ["Todos los bancos", "Banco individual"])
ddlMode.Choose(1)
ddlMode.OnEvent("Change", (*) => UpdateMode())

; Línea separadora
MyGui.Add("Text", "x20 y245 w220 h1 Background0x4ECCA3")

; Título de acciones
MyGui.Add("Text", "x100 y255 w440 h30 BackgroundTrans  ", "ACCIONES").SetFont("s11 Bold c0x4ECCA3")

; Botones de acción compactos
btnY := 290, btnH := 40
CreateButton("📋 CONSULTA", "CONSULTA", btnY)
CreateButton("✏️ MODIFICAR", "MOD", btnY += btnH + 8)
CreateButton("❌ CANCELAR", "CANCEL", btnY += btnH + 8)
CreateButton("➕ CREAR", "CREATE", btnY += btnH + 8)
CreateButton("➕ ACTTIME", "ACTTIME", btnY += btnH + 8)
CreateButton("📅 TIMELINE", "TIMELINE", btnY += btnH + 8)
CreateButton("📅 CANCEL_ID", "CANCEL_ID", btnY += btnH + 8)

; Separador antes del cierre
MyGui.Add("Text", "x20 y" btnY+btnH+15 " w220 h1 Background0x4ECCA3")

; Botón cerrar
btnClose := MyGui.Add("Button", "x40 y" btnY+btnH+25 " w180 h35 Background0xE94560 c0xFFFFFF", "🚪 CERRAR")
btnClose.SetFont("s10 Bold")
btnClose.OnEvent("Click", (*) => MyGui.Hide())
  
; Estilo para todos los botones de acción
for ctrl in MyGui {
    if (ctrl.Type = "Button" && ctrl != btnBrowse && ctrl != btnClose)
        ctrl.SetFont("s10 Bold")
}
btnBrowse.SetFont("s9")

; Función para crear botones
CreateButton(text, option, yPos) {
    global MyGui
    btn := MyGui.Add("Button", "x40 y" yPos " w180 h40 Background0x0F3460 c0xFFFFFF", text)
    btn.OnEvent("Click", (*) => ExecuteAction(option))
    return btn
}

; Actualizar ambiente
UpdateEnvironment() {
    global selectedEnv
    selectedEnv := ddlEnvironment.Text
}

; Actualizar modo de despliegue
UpdateMode() {
    global deployMode
    deployMode := (ddlMode.Value = 1) ? "ALL" : "INDIVIDUAL"
}

; Buscar carpeta
BrowseFolder() {
    global selectedPath
    try {
        selectedFolder := FileSelect("D", selectedPath, "Selecciona carpeta base")
        if (selectedFolder != "") {
            if (!InStr(selectedFolder, "\", , -1)) selectedFolder .= ""
            edtPath.Value := selectedFolder
            selectedPath := selectedFolder
        }
    } catch {
        result := InputBox("Ingresa la ruta manual:", "Ruta", "w350 h130", edtPath.Value)
        if (result.Result = "OK" && result.Value != "") {
            folder := result.Value
            if (!InStr(folder, "\", , -1)) folder .= "\"
            edtPath.Value := folder
            selectedPath := folder
        }
    }
}

; Obtener configuración dinámica
GetConfig(option) {
    global selectedEnv, selectedPath
    selectedPath := edtPath.Value 
    if (!InStr(selectedPath, "\", , -1)) selectedPath .= "\"
    config := Map()
    suffixes := Map(
        "CONSULTA", ["010", "inquiry", ""],
        "MOD", ["08", "val-mod", ""],
        "CANCEL", ["09", "val-cancel", ""],
        "CREATE", ["07", "val-create", ""], 
        "ACTTIME", ["011", "activate-time-line", ""],
        "TIMELINE", ["012", "save-time-line", ""],
		"CANCEL_ID", ["02", "cancel-block-by-id", ""]
    )
    cfg := suffixes[option]
    config["lambda"] := cfg[1]
    config["service"] := cfg[2]
    config["rutaSuffix"] := cfg[3]
    config["environment"] := selectedEnv
    config["environmentMay"] := StrUpper(selectedEnv)
    config["ruta"] := selectedPath . config["rutaSuffix"]
    config["crn"] := "corner/"
    return config
}

; Mostrar selector de banco
SelectBank() {
    bancos := ["BAVV", "BBOG", "BOCC", "BPOP", "DALE"]
    selectedBank := ""
    
    bankGui := Gui("+AlwaysOnTop", "Seleccionar Banco")
    bankGui.BackColor := "0x1A1A2E"
    bankGui.SetFont("s10 c0xEEEEEE", "Segoe UI")
    
    bankGui.Add("Text", "x20 y10 w260 h30 Center Background0x0F3460", "Selecciona un banco:").SetFont("s11 Bold c0x4ECCA3")
    
    yPos := 50
    for index, banco in bancos {
        btn := bankGui.Add("Button", "x50 y" yPos " w200 h35 Background0x0F3460 c0xFFFFFF", banco)
        btn.SetFont("s10 Bold")
        ; Usar el índice para acceder al banco del array
        btn.OnEvent("Click", SelectBankClick.Bind(index))
        yPos += 45
    }
    
    SelectBankClick(idx, *) {
        selectedBank := bancos[idx]
        bankGui.Destroy()
    }
    
    bankGui.Show("w300 h" (yPos + 20))
    WinWaitClose("ahk_id " bankGui.Hwnd)
    return selectedBank
}

; Ejecutar acciones
ExecuteAction(option) {
    global selectedPath, deployMode
    selectedPath := edtPath.Value
    
    ; Validar que la ruta no esté vacía
    if (selectedPath = "" || selectedPath = "D:\Compilaciones\") {
        MsgBox("⚠️ Debes seleccionar una ruta válida antes de continuar.`n`nUsa el botón [...] para seleccionar la carpeta.", "Ruta Requerida", "Icon! OK")
        return
    }
    
    ; Validar que la ruta exista
    if (!DirExist(selectedPath)) {
        result := MsgBox("⚠️ La ruta no existe:`n" selectedPath "`n`n¿Deseas continuar de todas formas?", "Ruta No Encontrada", "YesNo Icon!")
        if (result = "No")
            return
    }
    
    MyGui.Hide()
    cfg := GetConfig(option)
    
    ; Determinar bancos a procesar
    bancos := []
    if (deployMode = "INDIVIDUAL") {
        selectedBank := SelectBank()
        if (selectedBank = "") {
            MyGui.Show()
            return
        }
        bancos.Push(selectedBank)
    } else {
        bancos := ["BAVV", "BBOG", "BOCC", "BPOP", "DALE"]
    }

    ; Generar comandos S3
    s3Commands := ""
    for banco in bancos {
        s3Commands .= 'aws s3 cp "' cfg["ruta"] 'lambda-java-' cfg["service"] '-micro-' StrLower(banco) '-1.0-lambda.zip" '
        s3Commands .= 's3://awue1athspi-' cfg["environment"] '-s3-llaves-01/lambdas/' banco '/v2/'
        s3Commands .= (A_Index < bancos.Length ? '; ' : "`n`n")
    }

    ; Generar comandos Lambda
    lambdaCommands := ""
    for banco in bancos {
        lambdaCommands .= 'aws lambda update-function-code '
        lambdaCommands .= '--function-name AWUE1ATHSPI-' cfg["environmentMay"] '-LAMBDA-' banco '-' cfg["lambda"] ' '
        lambdaCommands .= '--s3-bucket awue1athspi-' cfg["environment"] '-s3-llaves-01 '
        lambdaCommands .= '--s3-key lambdas/' banco '/v2/lambda-java-' cfg["service"] '-micro-' StrLower(banco) '-1.0-lambda.zip'
        lambdaCommands .= (A_Index < bancos.Length ? '; ' : "")
    }

    ; Mensaje de confirmación
    mensaje := "═════════════════════════`n"
    mensaje .= "   CONFIG: " option "`n"
    mensaje .= "═════════════════════════`n`n"
    mensaje .= "⚡ Lambda: " cfg["lambda"] "`n"
    mensaje .= "🔧 Servicio: " cfg["service"] "`n"
    mensaje .= "🌐 Entorno: " cfg["environment"] "`n"
    mensaje .= "🏦 Bancos: " (deployMode = "INDIVIDUAL" ? bancos[1] : "TODOS") "`n"
    mensaje .= "📂 Ruta: " cfg["ruta"] "`n`n" 
    mensaje .= "¿Copiar comandos de Actualizar Lambda?"

    result := MsgBox(mensaje, "🚀 Actualizar Lambdas - " option, "YesNo Icon?")

    if (result = "Yes") {
        fullCommand := s3Commands . lambdaCommands
        A_Clipboard := fullCommand
        tempFile := A_Temp . "\aws_deploy_" option ".ps1"
        try FileDelete(tempFile)
        try FileAppend(fullCommand, tempFile, "UTF-8") 
        rutaBaseEscaped := StrReplace(selectedPath, "'", "''") 
        commandEscaped := StrReplace(fullCommand, '"', '`"')
        psCommand := "pwsh.exe -NoExit -Command `"cd '" . rutaBaseEscaped . "'; Set-Clipboard -Value '" . commandEscaped . "'; Write-Host '✓ PowerShell iniciado' -ForegroundColor Cyan; Write-Host '✓ Comandos S3 + UPDATE-FUNCTION - Ctrl+V' -ForegroundColor Green`""
        Run(psCommand)
    } else {
        fullCommand := s3Commands
        A_Clipboard := fullCommand 
        tempFile := A_Temp . "\aws_deploy_" option ".ps1"
        try FileDelete(tempFile)
        try FileAppend(fullCommand, tempFile, "UTF-8") 
        rutaBaseEscaped := StrReplace(selectedPath, "'", "''") 
        commandEscaped := StrReplace(fullCommand, '"', '`"')
        psCommand := "pwsh.exe -NoExit -Command `"cd '" . rutaBaseEscaped . "'; Set-Clipboard -Value '" . commandEscaped . "'; Write-Host '✓ PowerShell iniciado' -ForegroundColor Cyan; Write-Host '✓ Comandos S3 - Ctrl+V' -ForegroundColor Green`""
        Run(psCommand)
    }
}

MyGui.Show("w270 h750")

; Permitir mover ventana
OnMessage(0x0201, WM_LBUTTONDOWN)
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    if (hwnd = MyGui.Hwnd)
        PostMessage(0xA1, 2)
}