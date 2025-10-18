#Requires AutoHotkey v2.0

; Variables globales para configuración
global selectedEnv := "pt"
global selectedPath := ""

; Crear GUI moderna y compacta
MyGui := Gui("  -Caption +Border", "Menú de Opciones")
MyGui.BackColor := "0x1A1A2E"
MyGui.SetFont("s10 c0xEEEEEE", "Segoe UI")

; Header visual
MyGui.Add("Text", "x0 y0 w440 h60 Background0x0F3460 Center 0x200")
MyGui.Add("Text", "x80  y0 w440 h60 BackgroundTrans   0x200", "⚡ AWS").SetFont("s16 Bold c0xE94560")

; Panel de configuración
MyGui.Add("Text", "x15 y70 w225 h100 Background0x16213E")

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

; Línea separadora
MyGui.Add("Text", "x20 y185 w220 h1 Background0x4ECCA3")

; Título de acciones
MyGui.Add("Text", "x100 y195 w440 h30 BackgroundTrans  ", "ACCIONES").SetFont("s11 Bold c0x4ECCA3")

; Botones de acción compactos
btnY := 230, btnH := 40
CreateButton("📋 CONSULTA", "CONSULTA", btnY)
CreateButton("✏️ MODIFICAR", "MOD", btnY += btnH + 8)
CreateButton("❌ CANCELAR", "CANCEL", btnY += btnH + 8)
CreateButton("➕ CREAR", "CREATE", btnY += btnH + 8)
CreateButton("➕ ACTTIME", "ACTTIME", btnY += btnH + 8)
CreateButton("📅 TIMELINE", "TIMELINE", btnY += btnH + 8)

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
    "TIMELINE", ["012", "save-time-line", ""]
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

; Ejecutar acciones
ExecuteAction(option) {
  global selectedPath
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
    bancos := ["BAVV", "BBOG", "BOCC", "BPOP", "DALE"]

    s3Commands := ""
    for banco in bancos {
        s3Commands .= 'aws s3 cp "' cfg["ruta"] 'lambda-java-' cfg["service"] '-micro-' StrLower(banco) '-1.0-lambda.zip" '
        s3Commands .= 's3://awue1athspi-' cfg["environment"] '-s3-llaves-01/lambdas/' banco '/v2/'
        s3Commands .= (A_Index < bancos.Length ? '; ' : "`n`n")
    }

    lambdaCommands := ""
    for banco in bancos {
        lambdaCommands .= 'aws lambda update-function-code '
        lambdaCommands .= '--function-name AWUE1ATHSPI-' cfg["environmentMay"] '-LAMBDA-' banco '-' cfg["lambda"] ' '
        lambdaCommands .= '--s3-bucket awue1athspi-' cfg["environment"] '-s3-llaves-01 '
        lambdaCommands .= '--s3-key lambdas/' banco '/v2/lambda-java-' cfg["service"] '-micro-' StrLower(banco) '-1.0-lambda.zip'
        lambdaCommands .= (A_Index < bancos.Length ? '; ' : "")
    }

   ; Preguntar si también quiere los comandos Lambda
    mensaje := "═════════════════════════`n"
    mensaje .= "   CONFIG: " option "`n"
    mensaje .= "═════════════════════════`n`n"
    mensaje .= "⚡ Lambda: " cfg["lambda"] "`n"
    mensaje .= "🔧 Servicio: " cfg["service"] "`n"
    mensaje .= "🌐 Entorno: " cfg["environment"] "`n"
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
        psCommand := "pwsh.exe -NoExit -Command `"cd '" . rutaBaseEscaped . "'; Set-Clipboard -Value '" . commandEscaped . "'; Write-Host '✓ PowerShell iniciado' -ForegroundColor Cyan; Write-Host '✓ Comandos S3 + UPDATE-FUNCTION  - Ctrl+V' -ForegroundColor Green`""
        Run(psCommand)
    } else {
        fullCommand := s3Commands
		A_Clipboard := fullCommand 
		  tempFile := A_Temp . "\aws_deploy_" option ".ps1"
        try FileDelete(tempFile)
        try FileAppend(fullCommand, tempFile, "UTF-8") 
        rutaBaseEscaped := StrReplace(selectedPath, "'", "''") 
        commandEscaped := StrReplace(fullCommand, '"', '`"')
        psCommand := "pwsh.exe -NoExit -Command `"cd '" . rutaBaseEscaped . "'; Set-Clipboard -Value '" . commandEscaped . "'; Write-Host '✓ PowerShell iniciado' -ForegroundColor Cyan; Write-Host '✓ Comandos S3  - Ctrl+V' -ForegroundColor Green`""
        Run(psCommand)
    }
}
MyGui.Show("w270 h590")
; Atajo teclado
;^+m:: {
 ;   MyGui.Show("w440 h580")
;}

; Permitir mover ventana
OnMessage(0x0201, WM_LBUTTONDOWN)
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    if (hwnd = MyGui.Hwnd)
        PostMessage(0xA1, 2)
}
