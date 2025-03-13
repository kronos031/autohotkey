#Requires AutoHotkey 2.0+

; Recargar el script con Shift + F1
+F1::Reload
CambiarIcono()

class multi_clipboard {
    static clip_dat := Map()         ; Mapa para almacenar datos
    static active_mode := "copy"     ; Modo activo (copiar/pegar) - inicializado a "copy" por defecto
    static gui := 0                  ; Inicializar propiedad gui
    static enabled := true           ; Estado de activación (habilitado/deshabilitado)
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
        Hotkey("$-", ObjBindMethod(this, "show_floating_menu"))
        
        ; Configurar hotkeys iniciales (por defecto, números regulares)
        this.set_hotkeys()
        
        this.restore()               ; Restaurar contenido original del portapapeles
        
        ; Mostrar notificación de inicio con modo copiar activado
        TrayTip("Multi_Clipboard", "Modo COPIAR activado. Presiona XButton1 para mostrar el menú de opciones.", 5)
        
        ; Mostrar tooltip informando que el modo copiar está activado por defecto
        keyboard_text := this.use_numpad ? "numpad" : "teclado principal"
        ToolTip("Modo COPIAR activado. Presiona un número del 1-9 (" keyboard_text ") para guardar.")
        SetTimer(() => ToolTip(), -3000)  ; Ocultar ToolTip después de 3 segundos
    }
    
    static set_hotkeys() {
        ; Desactivar todos los hotkeys actuales
        loop 9 {
            try {
                Hotkey(A_Index, "Off")
                Hotkey("Numpad" A_Index, "Off")
            }
        }
        
        ; Activar los hotkeys según la configuración actual
        loop 9 {
            if (this.use_numpad) {
                Hotkey("Numpad" A_Index, ObjBindMethod(this, "process_number", A_Index), "On")
            } else {
                Hotkey(A_Index, ObjBindMethod(this, "process_number", A_Index), "On")
            }
        }
    }
    
    static toggle_keyboard_type(*) {
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
       
        my_menu.Add("Usar " (this.use_numpad ? "Teclado Principal" : "Teclado Numérico"), 
            ObjBindMethod(this, "toggle_keyboard_type"))

        my_menu.Add("🔄 Cambiar a Back", CambiarHotkey)  ; Nueva opción para cambiar el script
        
        my_menu.Add()  ; Separador
       
        ; Solo mostrar estas opciones si está habilitado
        if (this.enabled) {
            my_menu.Add("Copiar", ObjBindMethod(this, "set_copy_mode"))
            my_menu.Add("Pegar", ObjBindMethod(this, "set_paste_mode"))
            my_menu.Add("Mostrar", ObjBindMethod(this, "show_all"))
            my_menu.Add()  ; Separador
        }
        my_menu.Add()  ; Separador
        my_menu.Add()  ; Separador
        my_menu.Add(this.enabled ? "Desactivar" : "Activar", ObjBindMethod(this, "toggle_enabled"))  
        ; Mostrar menú en la posición actual del cursor
        my_menu.Show()
    }
    
    static toggle_enabled(*) {
        this.enabled := !this.enabled
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
    
    ; Métodos para desactivar completamente MultiClipboard
    static disable_all_hotkeys() {
        ; Desactivar el hotkey del menú flotante
        try Hotkey("XButton1", "Off")
        try Hotkey("-", "Off")
        
        ; Desactivar los hotkeys de números
        loop 9 {
            try Hotkey(A_Index, "Off")
            try Hotkey("Numpad" A_Index, "Off")
        }
    }
    
    static cleanup() {
        ; Desactivar todos los hotkeys
        this.disable_all_hotkeys()
        
        ; Cerrar cualquier GUI abierta
        this.destroy_gui()
        
        ; Desactivar la funcionalidad
        this.enabled := false
    }
}

; Verificar si el script se está ejecutando como un archivo independiente
if (A_ScriptName = "MultiClipboard.ahk") {
    ; Iniciar el script como aplicación independiente
    multi_clipboard.__New()
    
    ; Configurar una rutina de salida para limpiar al cerrar
    OnExit((*) => multi_clipboard.cleanup())
} 
; Si se incluye como biblioteca, no se inicializa automáticamente

; =======================
;     CAMBIAR HOTKEY
; =======================
CambiarHotkey(*) {
    global
    Run("C:\Users\miguelrobles\Desktop\AHKSCRIPT\Backendconf.ahk")  ; Ejecuta el nuevo script
    ExitApp()  ; Cierra el script actual
}

CambiarIcono() {
    TraySetIcon("shell32.dll", 266)  ; Ícono de acceso (verde o normal)
}