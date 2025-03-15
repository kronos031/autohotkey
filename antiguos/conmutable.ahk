#Requires AutoHotkey v2.0
; Include the MultiClipboard class but don't initialize it directly
#Include MultiClipboard.ahk

; Initialize toggle state and store for Backendconf's PID
toggle_state := false
backendconf_pid := 0
script_suspended := false  ; Estado para saber si el script está suspendido
multi_clipboard_active := false  ; Nuevo estado para MultiClipboard

XButton2::Send("^c")
XButton1::Send("{Enter}")

; Create the hotkey for the ° key
$°::
{
    global toggle_state, backendconf_pid, script_suspended, multi_clipboard_active
    
    ; Si el script está suspendido, no hacer nada
    if (script_suspended) {
        ToolTip("El script está suspendido. Presiona F1 para reactivar.", 100, 100)
        SetTimer () => ToolTip(), -1000
        return
    }
    
    toggle_state := !toggle_state
    
    if (toggle_state) {
        ; Desactivar MultiClipboard si está activo
        if (multi_clipboard_active) {
            multi_clipboard.cleanup()  ; Usa el nuevo método de limpieza
            multi_clipboard_active := false
        }
        
        ; Launch Backendconf
        Try {
            Run("Backendconf.ahk",, "PID", &backendconf_pid)
            ToolTip("Backendconf activado!", 100, 100,1)
            SetTimer () => ToolTip(), -1000  ; Tooltip desaparece después de 1 segundo
        } Catch as err {
            MsgBox("Error al iniciar Backendconf: " err.Message)
        }
        
    } else {
        ; Close Backendconf
        if (backendconf_pid) {
            Try {
                ProcessClose(backendconf_pid)
                backendconf_pid := 0
            }
        }
        
        ; Activar MultiClipboard
        if (!multi_clipboard_active) {
            multi_clipboard.__New()  ; Inicializar MultiClipboard directamente
            multi_clipboard_active := true
            ToolTip("MultiClipboard activado!", 110, 110)
            SetTimer () => ToolTip(), -1000
        }
    }
}

; Hotkey para suspender o reactivar el script activo con F1
#SuspendExempt True
#F1::  
{
    global toggle_state, backendconf_pid, script_suspended, multi_clipboard_active
    
    ; Cambiar el estado de suspensión
    script_suspended := !script_suspended
    
    if (script_suspended) {
        ; Suspender el script activo
        if (toggle_state) {
            ; Si Backendconf está activo, suspéndelo
            if (backendconf_pid) {
                Try {
                    ProcessClose(backendconf_pid)
                    backendconf_pid := 0
                }
            }
            ToolTip("Backendconf suspendido!", 100, 100)
        } else {
            ; Si MultiClipboard está activo, suspéndelo
            if (multi_clipboard_active) {
                multi_clipboard.cleanup()  ; Usa el nuevo método de limpieza
                multi_clipboard_active := false
                ToolTip("MultiClipboard suspendido!", 110, 110)
            }
        }
    } else {
        ; Reactivar el script activo
        if (toggle_state) {
            ; Reactivar Backendconf
            Try {
                Run("Backendconf.ahk",, "PID", &backendconf_pid)
                ToolTip("Backendconf reactivado!", 100, 100)
            } Catch as err {
                MsgBox("Error al reactivar Backendconf: " err.Message)
            }
        } else {
            ; Reactivar MultiClipboard
            if (!multi_clipboard_active) {
                multi_clipboard.__New()  ; Inicializar MultiClipboard directamente
                multi_clipboard_active := true
                ToolTip("MultiClipboard reactivado!", 110, 110)
            }
        }
    }
    
    SetTimer () => ToolTip(), -1000  ; Tooltip desaparece después de 1 segundo
} 
#SuspendExempt False
#SuspendExempt False
#SuspendExempt False