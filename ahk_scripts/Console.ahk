;;;Ctrl+v Ctrl+Y Shift+Insert: paste 在命令行里有效
;;;Win+v 在所有窗口中有效,

; #NoTrayIcon
; #SingleInstance force
SendMode, Input

; ;// Win+V = "type-paste" for all apps...
; #v::StringTypePaste(Clipboard)

#IfWinActive ahk_class ConsoleWindowClass
^v::StringTypePaste(Clipboard)
#v::StringTypePaste(Clipboard)
^y::StringTypePaste(Clipboard)
^Return::startMsysHere()
^!Return::cmd_explore_here()
#Esc::Send ,^c^cexit`n
Esc::Send ,exit`n

^!f::Send ^{Right}
^!b::Send ^{Left}

^a::Send {Home}
^e::Send {End}
^!a::Send {Home}
^!e::Send {End}
^d::Send {Del}
^f::Send {Right}
^b::Send {Left}

; ^u::Send ^{Home}
^k::Send ^{End}
; 滚屏
^u::Send {WheelUp}
; ^v::Send {WheelDown}
#IfWinActive


StringTypePaste(p_str, p_condensenewlines=1) {
if (p_condensenewlines) {
p_str:=RegExReplace(p_str, "[`r`n]+", "`n")
}
Send, % "{Raw}" p_str
}

;;在cmd.exe 的窗口中Ctrl+Return ,会启用msys ,并将路径定位在相同的目录
;;前提是msys.bat 在Path 路径下，及msys的相应bin 路径也在Path下
cmd_explore_here()
{
    sendInput ,explorer.exe  .`n
}

;;在cmd.exe 的窗口中Ctrl+Return ,会启用msys ,并将路径定位在相同的目录
;;前提是msys.bat 在Path 路径下，及msys的相应bin 路径也在Path下
startMsysHere()
{
    send, pwd >%A_Temp%\pwd `n
    sleep 150
    send msys `n
    FileReadLine,msysPath,%A_Temp%\pwd ,1
    sleep 300
    send cd %msysPath% `n
    send clear`n
}

;;d:\a\b -->d:/a/b
win_2_posixPath(winPath)
{
   StringReplace, posixPath, winPath, \ , /, All
   Return posixPath
}
