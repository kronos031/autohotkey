#SingleInstance Force
#Requires AutoHotkey v2
InstallKeybdHook

; Variables globales
global usuario := "miguelrobles@cbit-online.com"
global contrasena := "Emily@2032"
global hotkeyEnabled := false  ; Inicializar la variable
global valorActual := 1

; Hotkeys básicos
|::Send("!{Tab}")
<::AppsKey
::qmr::Miguel Angel Robles
::qmc::miguelrobles@cbit-online.com

; Suspendir/Reanudar el script con #F1
;#SuspendExempt
;#F1:: {
 ;   Suspend
;    SetTimer(() => ToolTip(), -800)  ; Oculta el ToolTip después de 800 ms
 ;   ToolTip(A_IsSuspended ? "AutoHotkey`nSuspendido" : "AutoHotkey`nHabilitado", 100, 100)
;}
;#SuspendExempt False

; Recargar el script con Shift + F1
+F1::Reload

; Hotkeys para Ctrl+A, Ctrl+C, Ctrl+V
$1::Send("^a")
$2::Send("^c")
$3::Send("^v")

; Función para habilitar/deshabilitar hotkeys
ToggleHotkeys(enable) {
    global hotkeyEnabled

    if (enable != hotkeyEnabled) {  ; Solo cambia el estado si es necesario
        Hotkey("1", enable ? "Off" : "On")
        Hotkey("2", enable ? "Off" : "On")
        Hotkey("3", enable ? "Off" : "On")
        hotkeyEnabled := enable  ; Actualiza el estado
    }
}
; Detectar si la ventana de Cisco Secure Client está activa
; Definir el hotkey para el botón derecho
#HotIf WinActive("Cisco Secure Client | vpn.periferia-it.com:4443") and WinExist("Cisco Secure Client | vpn.periferia-it.com:4443")  or WinActive("ahk_exe acwebhelper.exe")
RButton::{
 global valorActual  ; Acceder a la variable global

    if (valorActual == 1) {
	Send(usuario)
	Send ("{Enter}")
        valorActual := 2  ; Cambiar a 2
    } else if(valorActual == 2){
	Send(contrasena)
	Send ("{Enter}")
        valorActual := 3  ; Cambiar a 1
    } else {
	Send ("^v")
	valorActual := 1
	}
}
#HotIf
   

; Temporizador para verificar el estado de la ventana
SetTimer(CheckWindow, 1000)  ; Verifica cada segundo

CheckWindow() {
    ; Verifica si alguna de las ventanas está activa
    if (WinActive("Cisco Secure Client | vpn.periferia-it.com:4443") || WinActive("ahk_exe acwebhelper.exe")) {
        ToggleHotkeys(true)  ; Desactiva los hotkeys 1, 2, 3
    } else {
        ToggleHotkeys(false)  ; Reactiva los hotkeys 1, 2, 3
    }
}

