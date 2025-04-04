#SingleInstance Force
#Requires AutoHotkey v2
InstallKeybdHook

; =======================
;       VARIABLES
; =======================
global usuario := "miguelrobles@cbit-online.com"
global contrasena := "Emily@2034"
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

Xbutton2::Send("+{Xbutton2}")
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
	MenuFlotante.Add("🏭 Entitys", SubMenuEntitys)  ; 
	MenuFlotante.Add("🏭 EntityCodes", SubMenuEntitysCodes)  ; 
	MenuFlotante.Add("🔒  SPI", SubMenuSpi)  ; 
	MenuFlotante.Add()
	MenuFlotante.Add("🔒  Git", SubMenuGit)  ; 
	MenuFlotante.Add("🖱️ Double-Click",  ForzarDobleClick)
	
; =======================
    ; Configuración del submenú "usuario"
    ; =======================
	SubMenuUsuario.Add("📧 Correo", (*) => Send(usuario))
	SubMenuUsuario.Add("🔒 Contraseña", (*) => Send(contrasena))
	SubMenuUsuario.Add("🔒 Actualizar contraseña ", ActualizarContrasenaMiguel)
	SubMenuUsuario.Add("🔑 Credenciales", (*) => MsgBox("Usuario: " usuario "`nContraseña: " contrasena))
	    
	SubMenuBastion.Add("🖥️ IP", (*) => MsgBox("Bastion 10.130.3.88, Acceder a PT "))
	SubMenuBastion.Add("👤 Usuario", (*) => MsgBox("Ppaglogic"))
	SubMenuBastion.Add("🔒 Contraseña", (*) => Send("Zaq12wsx."))
	
	SubMenuLuis.Add("📧 Correo ATH", (*) => Send(usuariol))
	SubMenuLuis.Add("🔒 Contraseña ATH", (*) => Send(contrasenal))
	SubMenuLuis.Add("🔒 Actualizar ATH ", ActualizarContrasenaLuis)
	SubMenuLuis.Add("📧 Correo CBIT", (*) => Send(usuariolcbit))
	SubMenuLuis.Add("🔒 Contraseña CBIT", (*) => Send(contrasenalcbit))
	SubMenuLuis.Add("🔒 Actualizar CBIT ", ActualizarContrasenaLuisCbit)
	SubMenuLuis.Add("🔑 Credenciales", (*) => MsgBox("Correo ATH: " usuariol "`nContraseña: " contrasenal "`n`nCorreo CBIT: " usuariolcbit "`nContraseña CBIT: " contrasenalcbit ))
	MenuFlotante.Add()  ; S
	SubMenuEntitysCodes.Add("BBOG", (*) => Send("0001"))
	SubMenuEntitysCodes.Add("BPOP", (*) => Send("0002"))
	SubMenuEntitysCodes.Add("BOCC", (*) => Send("0023"))
	SubMenuEntitysCodes.Add("BAVV", (*) => Send("0052"))
	SubMenuEntitysCodes.Add("DALE", (*) => Send("0097"))
	
	SubMenuEntitys.Add("BBOG", (*) => Send("bbog"))
	SubMenuEntitys.Add("BPOP", (*) => Send("bpop"))
	SubMenuEntitys.Add("BOCC", (*) => Send("bocc"))
	SubMenuEntitys.Add("BAVV", (*) => Send("bavv"))
	SubMenuEntitys.Add("DALE", (*) => Send("dale"))
	
	SubMenuSpi.Add("Headers", Headers)
	SubMenuSpi.Add("Creacion", 		Creacion)
	SubMenuSpi.Add("Mod Producto", 	ModProducto)
	SubMenuSpi.Add("Mod Llave", 	ModLLave) 
	SubMenuSpi.Add("Cancelacion", 	Cancelacion)
	
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
 
; =======================
; HEADERS SPI
; =======================  
 Headers(*) {
    global jsonData := '
    (
X-RqUID:32123132432
X-Channel:MB
X-CompanyId:0001
X-GovIssueIdentType:NIT
X-IdentSerialNum:103698745
X-IPAddr:10.132.7.241
X-ClientDt:2024-08-27T15:58:00.792Z
X-CustIdentType:CC
X-CustIdentNum:1098606395
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
            "RefId": "@BACMS771"
        },
        {
            "RefType": "1",
            "RefId": "BACMS771"
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
            "RefId": "@AVJBR22222"
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
                "RefId": "@AVEJB22727"
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
                "RefId": "@AVEJB22728"
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
    "RefId": "@DLLBR542"
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


