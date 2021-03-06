URL := "http://10.0.2.2:45678/?"

DetectHiddenWindows, On
Script_Hwnd := WinExist("ahk_class AutoHotkey ahk_pid " DllCall("GetCurrentProcessId"))
DetectHiddenWindows, Off

; Register shell hook to detect flashing windows.
DllCall("RegisterShellHookWindow", "uint", Script_Hwnd)
OnMessage(DllCall("RegisterWindowMessage", "str", "SHELLHOOK"), "ShellEvent")

last_blink := A_TickCount

Notify(message) {
    global last_blink
    now := A_TickCount
    if ( ( now - last_blink ) > 3500 )
    {
        last_blink := now
        global URL
        request := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        request.Open("GET", URL . message)
        request.Send()
     }
}

ShellEvent(wParam, lParam) {
    team_white_list := ["Foo - 兴趣组", "Bar - 兴趣组"]

    if (wParam = 0x8006) ; HSHELL_FLASH
    {   ; lParam contains the ID of the window which flashed:

        WinGetTitle, win_title, ahk_id %lParam%
        WinGetClass, win_class, ahk_id %lParam%

        if (win_class = "SessionForm")
        {
            ; MsgBox, %win_title%, %win_class%
            Notify("个人：" . win_title)
            return
        }

        if (win_class = "TeamForm")
        {
            for i, element in team_white_list 
            {
                ; MsgBox, %win_title%, %win_class%, %element%
                if (element = win_title)
                {
                    Notify("兴趣组：" . win_title)
                    return
                }
            }
        }
    }
}
