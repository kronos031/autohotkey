#Requires AutoHotkey v2.0
#SingleInstance Force

; Crear GUI tipo toolbox
myGui := Gui("+AlwaysOnTop -Resize", "Toolbox")
myGui.AddText("w300", "Escribe tu nota:")
input := myGui.AddEdit("w300 r5 vUserInput")
myGui.AddButton("w100 Default", "Guardar").OnEvent("Click", guardarTexto)

; Definir la función OnChar antes de usarla
OnChar(wParam, lParam, msg, hwnd) {
    global input
    if (hwnd = input.Hwnd && wParam = 13) { ; 13 = Enter
        guardarTexto()
        return 0 ; evita beep y salto de línea
    }
    ; No retornar nada permite el comportamiento normal
}

; Asociar el mensaje WM_CHAR (0x102) al handler OnChar
; En v2.0, pasamos la función directamente sin Func()
OnMessage(0x102, OnChar)

myGui.Show("AutoSize")

guardarTexto(*) {
    global input, myGui
    texto := input.Value
    if (!StrLen(Trim(texto))) {
        MsgBox("El campo está vacío. Escribe algo antes de guardar.", "Error", 48)
        return
    }
    fechaHora := FormatTime(, "yyyy/MM/dd HH:mm")
    espacios := ",     " ; 5 espacios
    linea := '"' fechaHora '"' espacios '"' StrReplace(texto, '"', '""') '"' "`n"
    archivo := "C:\Users\" . A_UserName . "\Desktop\tareas.csv"
    FileAppend linea, archivo, "UTF-8"
    input.Value := ""
    myGui.Hide()
	Send "^+!p"
    ExitApp
}