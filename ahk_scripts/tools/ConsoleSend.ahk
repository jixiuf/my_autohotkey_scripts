;in a opened cmd.exe ,run this script ,then it will change this cmd.exe to msys ,and change directory to 
;current directory 
;for example ,you can run 
;      cmd /C cmd /K cd c:\windows  cmd2msys.ahk
;;ConsoleSend("Hooray, it works!", "ahk_class ConsoleWindowClass")
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Sends text to a console's input stream. WinTitle may specify any window in
; the target process. Since each process may be attached to only one console,
; ConsoleSend fails if the script is already attached to a console.
ConsoleSend(text, WinTitle="", WinText="", ExcludeTitle="", ExcludeText="")
{
    WinGet, pid, PID, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if !pid
        return false, ErrorLevel:="window"
    ; Attach to the console belonging to %WinTitle%'s process.
    if !DllCall("AttachConsole", "uint", pid)
        return false, ErrorLevel:="AttachConsole"
    hConIn := DllCall("CreateFile", "str", "CONIN$", "uint", 0xC0000000
                , "uint", 0x3, "uint", 0, "uint", 0x3, "uint", 0, "uint", 0)
    if hConIn = -1
        return false, ErrorLevel:="CreateFile"
   
    VarSetCapacity(ir, 24, 0)       ; ir := new INPUT_RECORD
    NumPut(1, ir, 0, "UShort")      ; ir.EventType := KEY_EVENT
    NumPut(1, ir, 8, "UShort")      ; ir.KeyEvent.wRepeatCount := 1
    ; wVirtualKeyCode, wVirtualScanCode and dwControlKeyState are not needed,
    ; so are left at the default value of zero.
   
    Loop, Parse, text ; for each character in text
    {
        NumPut(Asc(A_LoopField), ir, 14, "UShort")
       
        NumPut(true, ir, 4, "Int")  ; ir.KeyEvent.bKeyDown := true
        gosub ConsoleSendWrite
       
        NumPut(false, ir, 4, "Int") ; ir.KeyEvent.bKeyDown := false
        gosub ConsoleSendWrite
    }
    gosub ConsoleSendCleanup
    return true
   
    ConsoleSendWrite:
        if ! DllCall("WriteConsoleInput", "uint", hconin, "uint", &ir, "uint", 1, "uint*", 0)
        {
            gosub ConsoleSendCleanup
            return false, ErrorLevel:="WriteConsoleInput"
        }
    return
   
    ConsoleSendCleanup:
        if (hConIn!="" && hConIn!=-1)
            DllCall("CloseHandle", "uint", hConIn)
        ; Detach from %WinTitle%'s console.
        DllCall("FreeConsole")
    return
}
