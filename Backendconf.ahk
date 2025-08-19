#SingleInstance Force
#Requires AutoHotkey v2
InstallKeybdHook

; =======================
;       VARIABLES
; =======================
global usuario := "miguelrobles@cbit-online.com"
global contrasena := "Emily@2038"
global usuariol := "prv_lherreno@ath.com.co"
global usuariolcbit := "luisherreno@cbit-online.com"
global contrasenal := "Periferia2054*"
global contrasenalcbit := "Periferia2054*"
global hotkeysEnabled := true  ; Estado inicial: activados
global hotkeysForced := false  ; Controla si la desactivación fue manual o automática
global dobleClikForzado := false
global valorActual := 1

; =======================
;       HOTKEYS
; =======================
|::Send("!{Tab}")
AppsKey::Send("{AppsKey}")
::qmr::Miguel Angel Robles
::qmc::miguelrobles@cbit-online.com
::gco::
{
    GitCommit()
    return
}
::gcl::
{
    GitClone()
	
    return
}
; Recargar el script con Shift + F1
+F1::Reload

; Hotkeys para Ctrl+A, Ctrl+C, Ctrl+V
$1::Send("^a")
$2::Send("^c")
$3::Send("^v")

; Nuevo hotkey para segundo portapapeles
$4::CopiarSegundoPortapapeles
$5::PegarSegundoPortapapeles
Xbutton2::Run("C:\Users\miguelrobles\Desktop\autohotkey\compishk.ahk")  ; Ejecuta el nuevo script

; =======================
;    FUNCIONES PORTAPAPELES
; =======================
CopiarSegundoPortapapeles(*) {
    global segundoPortapapeles
    
    ; Guardar el portapapeles actual
    clipboardBackup := A_Clipboard
    
    ; Copiar la selección actual
    A_Clipboard := ""  ; Limpiar para verificar si la copia funciona
    Send("^c")
    ClipWait(1)
    
    if A_Clipboard {
        segundoPortapapeles := A_Clipboard
        ToolTip("✅ Copiado al segundo portapapeles", 100, 100)
        SetTimer(() => ToolTip(), -800)  ; Oculta el ToolTip después de 800 ms
    }
    
    ; Restaurar el portapapeles original
    A_Clipboard := clipboardBackup
}

PegarSegundoPortapapeles(*) {
    global segundoPortapapeles
    
    if segundoPortapapeles {
        ; Guardar el portapapeles actual
        clipboardBackup := A_Clipboard
        
        ; Usar el segundo portapapeles para pegar
        A_Clipboard := segundoPortapapeles
        Send("^v")
        
        ; Restaurar el portapapeles original
        Sleep(100)  ; Pequeña pausa para asegurar que pegue correctamente
        A_Clipboard := clipboardBackup
    } else {
        ToolTip("❌ Segundo portapapeles vacío", 100, 100)
        SetTimer(() => ToolTip(), -800)  ; Oculta el ToolTip después de 800 ms
    }
}


;Send("^")
;Xbutton2


; Suspendir/Reanudar el script con #F1
#SuspendExempt
#F1:: {
   Suspend
    SetTimer(() => ToolTip(), -800)  ; Oculta el ToolTip después de 800 ms
   ToolTip(A_IsSuspended ? "AutoHotkey`nSuspendido" : "AutoHotkey`nHabilitado", 100, 100)
}
#SuspendExempt False

; =======================
;       MENÚ FLOTANTE
; =======================
$-::MostrarMenu  ; 🔥 Siempre activo, incluso si los hotkeys están desactivados
Xbutton1::MostrarMenu

MostrarMenu(*) {
    static MenuFlotante := Menu()
    static SubMenuUsuario := Menu()  
	static SubMenuLuis := Menu()  
	static SubMenuBastion := Menu()  
	static SubMenuEntitysCodes := Menu()  
	static SubMenuEntitys := Menu()  
	static SubMenuSpi := Menu()  
	static SubMenuGit := Menu()  
	
	MenuFlotante.Delete()
	SubMenuUsuario.Delete()	; Limpia el menú antes de mostrarlo
	SubMenuBastion.Delete()
	SubMenuLuis.Delete()
	SubMenuEntitysCodes.Delete()
	SubMenuEntitys.Delete()
	SubMenuSpi.Delete()
	SubMenuGit.Delete()
	
    ; 🔥 Cambia el estilo visual del ítem
    menuItem := hotkeysEnabled ? "🟥 Desactivar Hotkeys" : "🟩 Activar Hotkeys"
	
    MenuFlotante.Add(menuItem, ToggleHotkeysMenu)
	MenuFlotante.Add()  ; Separador
    MenuFlotante.Add("🔄 Cambiar a Multiclip", CambiarHotkey)  ; Nueva opción para cambiar el script
    MenuFlotante.Add()  ; Separador
	MenuFlotante.Add("👤 Miguel Cbit", SubMenuUsuario)  ; 
	MenuFlotante.Add("👤 Luis", SubMenuLuis)  ; 
	MenuFlotante.Add("🌐 Bastion 88", SubMenuBastion)  ; 
	MenuFlotante.Add() 
	MenuFlotante.Add("🏭 LogInsight", LogInsight)  ;  
	MenuFlotante.Add("🔒  SPI", SubMenuSpi)  ; 
	MenuFlotante.Add()
	MenuFlotante.Add("🔒  Git", SubMenuGit)  ; 
	;MenuFlotante.Add("🖱️ Double-Click",  ForzarDobleClick)
    MenuFlotante.Add("🖱️ Compilaciones", AbrirCompilaciones)
	;MenuFlotante.Add("⏱️ Enter Automático", ToggleEnterTimer) 
	MenuFlotante.Add("⏱️ Mouse Mov", ToggleMouseMovement) 
	;MenuFlotante.Add("⚙️ Compile Scr", EjecutarBat)
	MenuFlotante.Add("⚙️ AWS Cred", Credaws)
	 
; =======================
    ; Configuración del submenú "usuario"
    ; =======================
	SubMenuUsuario.Add("📧 Correo", (*) => Send(usuario))
	SubMenuUsuario.Add("🔒 Contraseña", (*) => Send(contrasena))
	SubMenuUsuario.Add("🔒 Actualizar contraseña ", ActualizarContrasenaMiguel)
	SubMenuUsuario.Add("🔑 Credenciales", (*) => MsgBox("Usuario: " usuario "`nContraseña: " contrasena))
	    
	SubMenuBastion.Add("🖥️ IP", (*) => MsgBox("Bastion 10.130.3.88, `nAcceder a PT "))
	SubMenuBastion.Add("👤 UsuarioRem", (*) => A_Clipboard :="Ppaglogic" )
	SubMenuBastion.Add("🔒 Contraseña", (*) => A_Clipboard :="Zaq12wsx.")
    SubMenuBastion.Add("🔒 User spidev", (*) =>A_Clipboard := "spidev" )
    SubMenuBastion.Add("🔒 PassSpi", (*) => A_Clipboard := "T3mp0r4l01*.")
    SubMenuBastion.Add("🔒 DashBoard", (*) => A_Clipboard := "+O0A_kEpQ2AizU0x")
	
	SubMenuLuis.Add("📧 Correo ATH", (*) => Send(usuariol))
	SubMenuLuis.Add("🔒 Contraseña ATH", (*) => Send(contrasenal))
	SubMenuLuis.Add("🔒 Actualizar ATH ", ActualizarContrasenaLuis)
	SubMenuLuis.Add("📧 Correo CBIT", (*) => Send(usuariolcbit))
	SubMenuLuis.Add("🔒 Contraseña CBIT", (*) => Send(contrasenalcbit))
	SubMenuLuis.Add("🔒 Actualizar CBIT ", ActualizarContrasenaLuisCbit)
	SubMenuLuis.Add("🔑 Credenciales", (*) => MsgBox("Correo ATH: " usuariol "`nContraseña: " contrasenal "`n`nCorreo CBIT: " usuariolcbit "`nContraseña CBIT: " contrasenalcbit ))
	MenuFlotante.Add()  ; 
	
	SubMenuSpi.Add("Headers", Headers)
	SubMenuSpi.Add("Creacion", 		Creacion)
	SubMenuSpi.Add("Mod Producto", 	ModProducto)
	SubMenuSpi.Add("Mod Llave", 	ModLLave) 
	SubMenuSpi.Add("Cancelacion", 	Cancelacion)
	SubMenuSpi.Add("Bloqueo", 	Bloqueo)
	
	SubMenuGit.Add("Clone", GitClone)
	SubMenuGit.Add("Commit",GitCommit)
	SubMenuGit.Add("Fetch", (*) => Send("git fetch"))
	SubMenuGit.Add("Pull", (*) => Send("git pull"))
	
	MenuFlotante.Add("↻ Reload ",(*) => Reload())  ; S
	MenuFlotante.Add("🌙 Suspend ",(*) => Suspend()) 
	MenuFlotante.Add("❌ Salir", (*) =>   MenuFlotante.Delete())

    MouseGetPos(&x, &y)  ; Obtiene la posición actual del mouse
    MenuFlotante.Show(x, y)  ; Muestra el menú flotante en la posición del cursor
}



ToggleHotkeys(enable := unset, forced := false) {
    global hotkeysEnabled, hotkeysForced

    if !IsSet(enable) {
        enable := !hotkeysEnabled
    }

    hotkeysEnabled := enable

    if (forced) {
        hotkeysForced := true  ; Se marca como una desactivación manual
        MostrarToolTip(enable) ; 🔥 Solo muestra el ToolTip si el cambio es manual
    } else {
        hotkeysForced := false  ; Se restablece si es una activación automática
    }

    ; 🔥 Mantenemos Ctrl + Shift + M siempre activo
    HotkeyList := ["1", "2", "3", "|", "qmr", "qmc"]

    for key in HotkeyList {
        try {
            Hotkey(key, enable ? "On" : "Off")
        } catch {
            ; Ignorar errores en hotkeys inexistentes
        }
    }

    ; 🔥 Cambia el icono de la bandeja según el estado
    CambiarIcono()
}

ToggleHotkeysMenu(*) {
    ToggleHotkeys(!hotkeysEnabled, true)  ; Forzar la desactivación manual
}

; =======================
; CAMBIAR ICONO EN BANDEJA DEL SISTEMA
; =======================
CambiarIcono() {
    if (hotkeysEnabled) {
        TraySetIcon("shell32.dll", 301)  ; Ícono de acceso (verde o normal)
    } else {
        TraySetIcon("shell32.dll", 110)  ; Ícono de error (rojo)
    }
}

; =======================
; TOOLTIP SOLO SI EL CAMBIO FUE MANUAL
; =======================
MostrarToolTip(estado) {
    ToolTip(estado ? "✅ Hotkeys ACTIVADOS" : "❌ Hotkeys DESACTIVADOS", 100, 100)
    SetTimer(() => ToolTip(), -1000)  ; Oculta el ToolTip después de 1 segundo
}

AbrirCompilaciones(*) {
  Run("D:\Compilaciones")
}
; =======================
; HOTKEY ESPECIAL PARA VPN
; =======================
#HotIf WinActive("Cisco Secure Client - Login | vpn.periferia-it.com:4443") or WinActive("ahk_exe acwebhelper.exe")
RButton::{
    global valorActual  

    if (valorActual == 1) {
        Send(usuario)
        Send("{Enter}")
        valorActual := 2  
    } else if (valorActual == 2) {
        Send(contrasena)
        Send("{Enter}")
        valorActual := 3  
    } else {
        Send("^v")
		Send("{Enter}")
        valorActual := 1
    }
}
#HotIf

; =======================
; MONITOREO DE VENTANA VPN
; =======================
SetTimer(CheckWindow, 1000)  

CheckWindow() {
    global hotkeysEnabled, hotkeysForced

    if (WinActive("Cisco Secure Client | vpn.periferia-it.com:4443") || WinActive("ahk_exe acwebhelper.exe")) {
        ToggleHotkeys(false)  ; Desactiva los hotkeys cuando la VPN está activa
    } else if (!hotkeysForced) {  
        ToggleHotkeys(true)  ; Solo reactiva si NO fueron desactivados manualmente
    }
}

; =======================
; GIT
; =======================
 GitClone(*) {
     Send("git clone ")
	 Send("+{INSERT}")
	 Send("{Enter}")
}
GitCommit(*) {
     Send('git commit -m ""')
	 Send("{LEFT}")
}



; =======================
;     CAMBIAR HOTKEY
; =======================
CambiarHotkey(*) {
    global
    Run("C:\Users\miguelrobles\Desktop\autohotkey\MultiClipboard.ahk")  ; Ejecuta el nuevo script
    ExitApp()  ; Cierra el script actual
}

; =======================
;   UPDATE VARIABLES
; =======================

ActualizarContrasenaMiguel(*) {
    nuevaContrasena := InputBox("Ingrese nueva contraseña:", "Actualizar contraseña Miguel", "w400 h100", contrasena)
    if !nuevaContrasena.Result {
        return
    }
	if ActualizarVariables("contrasena", nuevaContrasena.Value) {
        ActualizarScriptFile("contrasena", nuevaContrasena.Value)
    }
    ActualizarVariables("contrasena", nuevaContrasena.Value)
}
ActualizarContrasenaLuis(*) {
    nuevaContrasena := InputBox("Ingrese nueva contraseña:", "Actualizar contraseña Luis", "w400 h100 ", contrasenal)
	 
    if !nuevaContrasena.Result {
        return
    }
    ActualizarVariables("contrasenal", nuevaContrasena.Value)
}
ActualizarContrasenaLuisCbit(*) {
    nuevaContrasena := InputBox("Ingrese nueva contraseña:", "Actualizar contraseña Luis Cbit", "w400 h100 ", contrasenalcbit)
	 
    if !nuevaContrasena.Result {
        return
    }
    ActualizarVariables("contrasenalcbit", nuevaContrasena.Value)
}
ActualizarVariables(nuevaVariable, nuevoValor) {
    global usuario, contrasena, usuariol, contrasenal,contrasenalcbit
    
  
     if (nuevaVariable = "contrasena") {
        contrasena := nuevoValor
        MostrarToolTip("Contraseña actualizada")
        return true
    }
  
     else if (nuevaVariable = "contrasenalcbit") {
        contrasenalcbit := nuevoValor
        MostrarToolTip("Contraseña Luis Cbit actualizada")
        return true
    }
	 else if (nuevaVariable = "contrasenal") {
        contrasenal := nuevoValor
        MostrarToolTip("Contraseña Luis actualizada")
        return true
    }
    else {
        MostrarToolTip("Variable no reconocida")
        return false
    }
}



ActualizarScriptFile(variable, nuevoValor) {
    scriptPath := A_ScriptFullPath
    fileContent := FileRead(scriptPath)
    
    if (variable = "contrasena") {
        newContent := RegExReplace(fileContent, "global contrasena := `".*`"", "global contrasena := `"" nuevoValor "`"")
    } else if (variable = "contrasenal") {
        newContent := RegExReplace(fileContent, "global contrasenal := `".*`"", "global contrasenal := `"" nuevoValor "`"")
    } else {
        return
    }
    
    FileDelete(scriptPath)
    FileAppend(newContent, scriptPath)
    MostrarToolTip("Script actualizado")
}

;=======================
;    ACTUALIZAR CREDENCIALES AWS 
; =======================
Credaws(*) {
 global aws_account_id := ""
global aws_access_key_id := ""
global aws_secret_access_key := ""
global aws_session_token := ""


 ClipContent := A_Clipboard
 
  if (RegExMatch(ClipContent, "\[(\d+)_", &match)) {
        aws_account_id := match[1]
    }
    
    ; Extraer aws_access_key_id
    if (RegExMatch(ClipContent, "aws_access_key_id\s*=\s*([^\s\r\n]+)", &match)) {
        aws_access_key_id := match[1]
    }
    
    ; Extraer aws_secret_access_key
    if (RegExMatch(ClipContent, "aws_secret_access_key\s*=\s*([^\s\r\n]+)", &match)) {
        aws_secret_access_key := match[1]
    }
    
    ; Extraer aws_session_token
    if (RegExMatch(ClipContent, "aws_session_token\s*=\s*([^\s\r\n]+)", &match)) {
        aws_session_token := match[1]
    }
    
	 comando := 'cmd /c (echo [default] ' .
               '& echo aws_access_key_id = ' . aws_access_key_id . ' ' .
               '& echo aws_secret_access_key = ' . aws_secret_access_key . ' ' .
               '& echo aws_session_token = ' . aws_session_token . ') ' .
               '> "C:\Users\miguelrobles\.aws\credentials"'
     
    ; Ejecutar comando oculto
    Run(comando, , "Hide")
    
				    
   ToolTip("Credenciales Actualizadas"  )
   SetTimer(() => ToolTip(), -3000)
}
;=======================
;     EJECUTAR ARCHIVO BAT
; =======================
EjecutarBat(*) {
    ; Permite seleccionar un archivo .bat para ejecutar
    ;archivoSeleccionado := FileSelect(1, , "Seleccionar archivo BAT", "Archivos BAT (*.bat)")
	archivoSeleccionado := "C:\Users\miguelrobles\Desktop\autohotkey\Compile_SPI.bat" 
    
    if (archivoSeleccionado) {
        try {
            Run(archivoSeleccionado)
            ToolTip("✅ Ejecutando: " . archivoSeleccionado, 100, 100)
        } catch Error as e {
            ToolTip("❌ Error al ejecutar el archivo BAT: " . e.message, 100, 100)
        }
    } else {
        ToolTip("❌ No se seleccionó ningún archivo", 100, 100)
    }
    
    SetTimer(() => ToolTip(), -2000)  ; Ocultar el tooltip después de 2 segundos
}

; =======================
; HEADERS SPI
; =======================  
 Headers(*) {
    global jsonData := '
    (
X-RqUID:32123132432
X-Channel:MB
X-CompanyId:0052
X-GovIssueIdentType:NIT
X-IdentSerialNum:103698745
X-IPAddr:10.132.7.241
X-ClientDt:2024-08-27T15:58:00.792Z
X-CustIdentType:CC
X-CustIdentNum:1098600300
    )'
    A_Clipboard := jsonData
    SendInput("^v")
}  
; =======================
; BODYS SPI
; ======================= 
 Creacion(*) {
    global jsonData := '
    (
   {
    "RefInfo": [
        {
            "RefType": "4",
            "RefId": "@MAREMI002"
        },
        {
            "RefType": "1",
            "RefId": "MAREMI002"
        },
        {
            "RefType": "1",
            "RefId": "REDEBAN"
        }
    ],
    "PersonInfo": {
        "PersonName": {
            "LastName": "Molina",
            "FirstName": "Camila",
            "SecondLastName": "Sarmiento",
            "MiddleName": "Carolina"
        },
        "PersonType": "PN"
    },
    "XferInfo": {
        "CardAcctIdFrom": {
            "CardAcctId": {
                "AcctId": "075850230",
                "AcctType": "CAHO",
                "BankInfo": {
                    "BankId": "0052"
                },
                "PreferredIndicator": "S"
            }
        }
    },
    "BankAcctStatus": {
        "StatusDesc": "ACTIVA",
        "EffDt": "2025-01-20T14:04:17.290Z",
        "EffDtConsent" : "2025-01-20T14:04:17.290Z",
        "Consent": "S"
    }
}
    )'
    A_Clipboard := jsonData
    SendInput("^v")
}  


 ModProducto(*) {
    global jsonData := '
    (
     {
    "RefInfo": [
        {
            "RefType": "4",
            "RefId": "@MAREMI002"
        },
        {
            "RefType": "1",
            "RefId": "Almuerxo"
        },
        {
            "RefType": "1",
            "RefId": "REDEBAN"
        }
    ],
    "XferInfo": {
        "CardAcctIdFrom": {
            "CardAcctId": {
                "AcctId": "9638527410",
                "AcctType": "CCTE",
                "BankInfo": {
                    "BankId": "0052"
                },
                "PreferredIndicator": "S"
            }
        }
    },
    "BankAcctStatus": {
        "StatusDesc": "ACTIVA",
        "EffDt": "2024-08-27T15:58:00.792Z"
    }
}
    )'
    A_Clipboard := jsonData
    SendInput("^v")
}  

ModLlave(*) {
    global jsonData := '
    (
    {
        "RefInfo": [
            {
                "RefType": "4",
                "RefId": "@MAREMI002"
            },
            {
                "RefType": "1",
                "RefId": "Almuerxo"
            },
            {
                "RefType": "1",
                "RefId": "REDEBAN"
            },
              {
                "RefType": "4",
                "RefId": "@MAREMI002"
            }
        ],
        "XferInfo": {
            "CardAcctIdFrom": {
                "CardAcctId": {
                    "AcctId": "3026125134",
                    "AcctType": "DBMO",
                    "BankInfo": {
                        "BankId": "0052" 
                    },
                    "PreferredIndicator": "S"
                }
            }
        },
        "BankAcctStatus": {
            "StatusDesc": "ACTIVA",
            "EffDt": "2024-08-27T15:58:00.792Z"
        }
    } 
    )'
    A_Clipboard := jsonData
    SendInput("^v")
}  

 Cancelacion(*) {
    global jsonData := '
    (
 {
  "RefInfo": {
    "RefType": "4",
    "RefId": "@MAREMI002"
  }
}
    )'
    A_Clipboard := jsonData
    SendInput("^v")
}  

 Bloqueo(*) {
    global jsonData := '
    (
 {
  "RefInfo": {
    "RefType": "4",
    "RefId": "@MAREMI002",
	"KeyStatus":"BLOQUEADA_C"
  }
}
    )'
    A_Clipboard := jsonData
    SendInput("^v")
} 


ForzarDobleClick(*) {
    global dobleClikForzado := !dobleClikForzado
    
    if (dobleClikForzado) {
        Hotkey("LButton", (*) => Click(2), "On")
        ToolTip("✅ Doble Clic ACTIVADO", 100, 100)
    } else {
        Hotkey("LButton", "Off")
        ToolTip("❌ Doble Clic DESACTIVADO", 100, 100)
    }
    
    SetTimer(() => ToolTip(), -1000)
}


; =======================
;     ENTER AUTOMÁTICO
; =======================
global enterTimerActive := false

ToggleEnterTimer(*) {
    global enterTimerActive
    
    enterTimerActive := !enterTimerActive
    
    if (enterTimerActive) {
        SetTimer(PresionarEnterAutomatico, 24000)  ; 4 minutos = 240000 ms
        ToolTip("✅ Presionar Enter automático ACTIVADO", 100, 100)
    } else {
        SetTimer(PresionarEnterAutomatico, 0)  ; Detener el timer
        ToolTip("❌ Presionar Enter automático DESACTIVADO", 100, 100)
    }
    
    SetTimer(() => ToolTip(), -1000)  ; Ocultar el tooltip después de 1 segundo
}

PresionarEnterAutomatico() {
    Send("{Enter}")
    ToolTip("🔄 Enter presionado automáticamente", 100, 100)
    SetTimer(() => ToolTip(), -800)  ; Ocultar el tooltip después de 0.8 segundos
}


; =======================
;     MOVIMIENTO AUTOMÁTICO DEL MOUSE
; =======================
global mouseMovementActive := false
global angle := 0

ToggleMouseMovement(*) {
    global mouseMovementActive
    
    mouseMovementActive := !mouseMovementActive
    
    if (mouseMovementActive) {
        SetTimer(MoverMouseAutomatico, 24000)  ; Cada 24 segundos
        ToolTip("✅ Movimiento automático del mouse ACTIVADO", 100, 100)
    } else {
        SetTimer(MoverMouseAutomatico, 0)  ; Detener el timer
        ToolTip("❌ Movimiento automático del mouse DESACTIVADO", 100, 100)
    }
    
    SetTimer(() => ToolTip(), -1000)  ; Ocultar el tooltip después de 1 segundo
}

MoverMouseAutomatico() {
    global angle
    
    ; Obtener la posición actual del mouse
    MouseGetPos(&currentX, &currentY)
    
    ; Calcular nueva posición en un pequeño círculo
    radius := 10  ; Radio del círculo en píxeles
    newX := currentX + radius * Cos(angle)
    newY := currentY + radius * Sin(angle)
    
    ; Mover el mouse
    MouseMove(newX, newY, 2)  ; Movimiento suave (velocidad 2)
    
    ; Incrementar el ángulo para el próximo movimiento
    angle += 0.5
    if (angle >= 6.28)  ; 2*PI
        angle := 0
        
    ;ToolTip("🔄 Mouse movido automáticamente", 100, 100)
	
    SetTimer(() => ToolTip(), -800)  ; Ocultar el tooltip después de 0.8 segundos
}

LogInsight(*) {
    global jsonData := '
    (
     fields @timestamp, @requestId, @message, @logStream |
filter @message like /4@JSS950/
| sort @timestamp desc 
| limit 20 
    )'
    A_Clipboard := jsonData
    SendInput("^v")
}  