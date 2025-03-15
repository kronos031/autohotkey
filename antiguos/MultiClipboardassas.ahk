#SingleInstance Force
#Requires AutoHotkey v2
InstallKeybdHook

;___________________________________________________________________________________________________  
; VARIABLES GLOBALES Y CONFIGURACIÓN INICIAL
;___________________________________________________________________________________________________  
global usuario := "miguelrobles@cbit-online.com"
global contrasena := "Emily@2032"
global hotkeyEnabled := false  ; Para controlar hotkeys básicos
global valorActual := 1        ; Para la función de VPN
global scriptBasicoActivo := true  ; Controla si el script básico está activo

;___________________________________________________________________________________________________  
; CLASE MULTI_CLIPBOARD
;___________________________________________________________________________________________________  
class multi_clipboard {
    static clip_dat := Map()         ; Mapa para almacenar datos
    static active_mode := ""         ; Modo activo (copiar/pegar)
    static gui := 0                  ; Inicializar propiedad gui
    static enabled := false          ; Estado de activación (inactivo por defecto)
    static use_numpad := false       ; Por defecto usar teclado normal
    
    static __New() {
        this.backup()                ; Respaldar contenido del portapapeles
        empty := ClipboardAll()      ; Guardar objeto ClipboardAll vacío
        
        ; Inicializar espacios para números 1-9
        loop 9 {
            this.clip_dat[A_Index] := {str:'', bin:empty}
        }
        
        ; Crear hotkey para activar menú flotante
        Hotkey("XButton1", ObjBindMethod(this, "show_floating_menu"))
        
        ; Configurar hotkeys iniciales (desactivados por defecto)
        this.set_hotkeys()
        
        this.restore()               ; Restaurar contenido original del portapapeles
        
        ; Mostrar notificación de inicio
        TrayTip("Scripts Integrados", "Presiona XButton1 para mostrar el menú de opciones.", 5)
    }
    
    static set_hotkeys() {
        ; Desactivar todos los hotkeys del multiclipboard
        loop 9 {
            try {
                Hotkey(A_Index, "Off")
                Hotkey("Numpad" A_Index, "Off")
            }
        }
        
        ; Solo activar los hotkeys si el multiclipboard está habilitado
        if (this.enabled) {
            loop 9 {
                if (this.use_numpad) {
                    Hotkey("Numpad" A_Index, ObjBindMethod(this, "process_number", A_Index), "On")
                } else {
                    Hotkey(A_Index, ObjBindMethod(this, "process_number", A_Index), "On")
                }
            }
        }
    }
    
    static toggle_keyboard_type(*) {
        if (!this.enabled)
            return
            
        this.use_numpad := !this.use_numpad
        this.set_hotkeys()
        
        keyboard_text := this.use_numpad ? "TECLADO NUMÉRICO" : "TECLADO PRINCIPAL"
        ToolTip("Usando " keyboard_text)
        SetTimer(() => ToolTip(), -2000)  ; Ocultar ToolTip después de 2 segundos
    }
    
    static show_floating_menu(*) {
        ; Crear menú
        my_menu := Menu()
        
        ; Agregar opciones al menú
        my_menu.Add(this.enabled ? "Desactivar Multi_Clipboard" : "Activar Multi_Clipboard", 
            ObjBindMethod(this, "toggle_enabled"))
        
        ; Solo mostrar estas opciones si está habilitado
        if (this.enabled) {
            my_menu.Add("Usar " (this.use_numpad ? "Teclado Principal" : "Teclado Numérico"), 
                ObjBindMethod(this, "toggle_keyboard_type"))
            my_menu.Add()  ; Separador
            my_menu.Add("Copiar", ObjBindMethod(this, "set_copy_mode"))
            my_menu.Add("Pegar", ObjBindMethod(this, "set_paste_mode"))
            my_menu.Add("Mostrar", ObjBindMethod(this, "show_all"))
        }
        
        ; Mostrar menú en la posición actual del cursor
        my_menu.Show()
    }
    
    static toggle_enabled(*) {
        this.enabled := !this.enabled
        
        ; Activar/desactivar script básico en función de multiclipboard
        global scriptBasicoActivo := !this.enabled
        ToggleScriptBasico(scriptBasicoActivo)
        
        ; Actualizar hotkeys del multiclipboard
        this.set_hotkeys()
        
        state_text := this.enabled ? "ACTIVADO" : "DESACTIVADO"
        ToolTip("Multi_Clipboard " state_text)
        SetTimer(() => ToolTip(), -2000)  ; Ocultar ToolTip después de 2 segundos
    }
    
    static set_copy_mode(*) {
        if (!this.enabled)
            return
            
        this.active_mode := "copy"
        keyboard_text := this.use_numpad ? "numpad" : "teclado principal"
        ToolTip("Modo COPIAR activado. Presiona un número del 1-9 (" keyboard_text ") para guardar.")
        SetTimer(() => ToolTip(), -3000)  ; Ocultar ToolTip después de 3 segundos
    }
    
    static set_paste_mode(*) {
        if (!this.enabled)
            return
            
        this.active_mode := "paste"
        keyboard_text := this.use_numpad ? "numpad" : "teclado principal"
        ToolTip("Modo PEGAR activado. Presiona un número del 1-9 (" keyboard_text ") para pegar.")
        SetTimer(() => ToolTip(), -3000)  ; Ocultar ToolTip después de 3 segundos
    }
    
    static process_number(index, *) {
        if (!this.enabled)
            return
            
        if (this.active_mode = "copy")
            this.copy(index)
        else if (this.active_mode = "paste")
            this.paste(index)
        else
            ToolTip("Primero selecciona un modo (Copiar o Pegar) desde el menú (presiona XButton1).")
            SetTimer(() => ToolTip(), -3000)  ; Ocultar ToolTip después de 3 segundos
    }
    
    static copy(index, *) {
        if (!this.enabled)
            return
            
        this.backup()                              ; Respaldar contenido del portapapeles
        SendInput("^c")                            ; Enviar Ctrl+C
        ClipWait(1, 1)                             ; Esperar hasta 1 segundo
        this.clip_dat[index].bin := ClipboardAll() ; Guardar datos binarios
        this.clip_dat[index].str := A_Clipboard    ; Guardar texto
        this.restore()                             ; Restaurar contenido original
        
        ToolTip("Copiado al portapapeles " index)
        SetTimer(() => ToolTip(), -1000)           ; Ocultar ToolTip después de 1 segundo
    }
    
    static paste(index, *) {
        if (!this.enabled)
            return
            
        this.backup()                              ; Respaldar contenido del portapapeles
        A_Clipboard := this.clip_dat[index].bin    ; Poner datos guardados en el portapapeles
        SendInput("^v")                            ; Pegar
        loop 20 {                                  ; Verificar si el portapapeles está en uso
            Sleep(50)
        } Until !DllCall("GetOpenClipboardWindow")
        this.restore()                             ; Restaurar contenido original
        
        ToolTip("Pegado desde portapapeles " index)
        SetTimer(() => ToolTip(), -1000)           ; Ocultar ToolTip después de 1 segundo
    }
    
    static show_all(*) {
        if (!this.enabled)
            return
            
        str := ""
        
        ; Crear un string con el contenido de todos los portapapeles
        for index in this.clip_dat {
            str .= this.format_line(index)
        }
        
        this.make_gui(Trim(str, "`n"))
    }
    
    static format_line(index) {
        dat := this.clip_dat[index]
        
        ; Determinar qué mostrar para este portapapeles
        if (dat.bin.Size = 0) {
            body := "<VACÍO>"
        } else if (StrLen(dat.str)) {
            body := dat.str
        } else {
            body := "<DATOS BINARIOS>"
                . "`n  Tamaño: " dat.bin.Size
        }
        
        header := ";===[Portapapeles " index "]============================================================"
        return header "`n`n" body "`n`n"
    }
    
    static make_gui(str) {
        if this.HasOwnProp("gui") && this.gui != 0 {
            this.destroy_gui()
        }
         
        ; Valores predeterminados
        m := 10                         ; Margen
        edt := {h:400, w:600}           ; Dimensiones del editor
        btn := {w:(edt.w - m) / 2, h:30} ; Dimensiones de botones
        title := "Portapapeles múltiple" ; Título
        bg_col := "101010"              ; Color de fondo
        
        ; Crear GUI
        goo := Gui()
        goo.title := title
        goo.MarginX := goo.MarginY := m
        goo.BackColor := bg_col
        goo.OnEvent("Close", (*) => goo.Destroy())
        goo.OnEvent("Escape", (*) => goo.Destroy())
        goo.SetFont("s10 cWhite Bold", "Consolas")
        
        ; Editor
        opt := " ReadOnly -Wrap +0x300000 -WantReturn -WantTab Background" bg_col
        goo.edit := goo.AddEdit("xm ym w" edt.w " h" edt.h opt, str)
        
        ; Botón Copiar
        goo.copy := goo.AddButton("xm y+" m " w" btn.w " h" btn.h, "Copiar al portapapeles")
        goo.copy.OnEvent("Click", (*) => A_Clipboard := goo.edit.value)
        
        ; Botón Cerrar
        goo.close := goo.AddButton("x+" m " yp w" btn.w " h" btn.h, "Cerrar")
        goo.close.OnEvent("Click", (*) => goo.Destroy())
        goo.close.Focus()
        
        ; Permitir arrastrar ventana
        OnMessage(0x200, (*) => this.WM_MOUSEMOVE)
        
        this.gui := goo
        this.gui.Show()
    }
    
    static WM_MOUSEMOVE(wparam, lparam, msg, hwnd) {
        static WM_NCLBUTTONDOWN := 0xA1
        if (wparam = 1)
            PostMessage(WM_NCLBUTTONDOWN, 2,,, "ahk_id " hwnd)
    }
    
    static destroy_gui() {
        try this.gui.destroy()
    }
    
    static backup() {
        this._backup := ClipboardAll()
        A_Clipboard := ""
    }
    
    static restore() {
        A_Clipboard := this._backup
    }
}

;___________________________________________________________________________________________________  
; FUNCIONES DEL SCRIPT BÁSICO
;___________________________________________________________________________________________________  

; Función para activar/desactivar todas las funciones del script básico
ToggleScriptBasico(enable) {
    global hotkeyEnabled, scriptBasicoActivo
    
    scriptBasicoActivo := enable
    
    ; Hotkeys básicos
    Hotkey("|", enable ? "On" : "Off")
    Hotkey("<", enable ? "On" : "Off")
    Hotkey("::qmr", enable ? "On" : "Off")
    Hotkey("::qmc", enable ? "On" : "Off")
    
    ; Actualizar el estado de los hotkeys 1, 2, 3 según corresponda
    if (enable) {
        ; Solo activar 1, 2, 3 si no está en la ventana de Cisco
        if (!hotkeyEnabled) {
            Hotkey("$1", "On")
            Hotkey("$2", "On")
            Hotkey("$3", "On")
        }
    } else {
        ; Desactivar 1, 2, 3 completamente cuando multiclipboard está activo
        Hotkey("$1", "Off")
        Hotkey("$2", "Off")
        Hotkey("$3", "Off")
    }
}

; Función para habilitar/deshabilitar hotkeys de Cisco específicos
ToggleHotkeys(enable) {
    global hotkeyEnabled, scriptBasicoActivo
    
    if (enable != hotkeyEnabled) {  ; Solo cambia el estado si es necesario
        hotkeyEnabled := enable
        
        ; Solo modificar los hotkeys 1, 2, 3 si el script básico está activo
        if (scriptBasicoActivo) {
            Hotkey("$1", enable ? "Off" : "On")
            Hotkey("$2", enable ? "Off" : "On")
            Hotkey("$3", enable ? "Off" : "On")
        }
    }
}

;___________________________________________________________________________________________________  
; DEFINICIÓN DE HOTKEYS DEL SCRIPT BÁSICO
;___________________________________________________________________________________________________  

; Hotkeys básicos
|::Send("!{Tab}")
<::AppsKey
::qmr::Miguel Angel Robles
::qmc::miguelrobles@cbit-online.com

; Suspendir/Reanudar el script con #F1
#SuspendExempt
#F1:: {
    Suspend
    SetTimer(() => ToolTip(), -800)  ; Oculta el ToolTip después de 800 ms
    ToolTip(A_IsSuspended ? "AutoHotkey`nSuspendido" : "AutoHotkey`nHabilitado", 100, 100)
}
#SuspendExempt False

; Recargar el script con Shift + F1
+F1::Reload

; Hotkeys para Ctrl+A, Ctrl+C, Ctrl+V
$1::Send("^a")
$2::Send("^c")
$3::Send("^v")

; Detectar si la ventana de Cisco Secure Client está activa
#HotIf WinActive("Cisco Secure Client | vpn.periferia-it.com:4443") and WinExist("Cisco Secure Client | vpn.periferia-it.com:4443") or WinActive("ahk_exe acwebhelper.exe")
RButton::{
    global valorActual  ; Acceder a la variable global
    if (valorActual == 1) {
        Send(usuario)
        Send("{Enter}")
        valorActual := 2  ; Cambiar a 2
    } else if(valorActual == 2){
        Send(contrasena)
        Send("{Enter}")
        valorActual := 3  ; Cambiar a 1
    } else {
        Send("^v")
        valorActual := 1
    }
}
#HotIf

;___________________________________________________________________________________________________  
; INICIALIZACIÓN
;___________________________________________________________________________________________________  

; Temporizador para verificar el estado de la ventana
SetTimer(CheckWindow, 1000)  ; Verifica cada segundo

; Función para verificar ventanas
CheckWindow() {
    global scriptBasicoActivo
    
    ; Solo verificar si el script básico está activo
    if (scriptBasicoActivo) {
        ; Verifica si alguna de las ventanas está activa
        if (WinActive("Cisco Secure Client | vpn.periferia-it.com:4443") || WinActive("ahk_exe acwebhelper.exe")) {
            ToggleHotkeys(true)  ; Desactiva los hotkeys 1, 2, 3
        } else {
            ToggleHotkeys(false)  ; Reactiva los hotkeys 1, 2, 3
        }
    }
}

; Iniciar Multi_Clipboard (desactivado por defecto)
multi_clipboard.__New()