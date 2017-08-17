;;;Ctrl+v Ctrl+Y Shift+Insert: paste 在命令行里有效
;;;Win+v 在所有窗口中有效,

; #NoTrayIcon
; #SingleInstance force
SendMode, Input
SetTitleMatchMode Regex ;可以使用正则表达式对标题进行匹配

; ;// Win+V = "type-paste" for all apps...
; #v::StringTypePaste(Clipboard)

#IfWinActive ahk_class PuTTY
#c::return
#v::StringTypePaste(Clipboard)
^BackSpace::Send {Escape}[aa
^;::Send {Escape}[af
^,::Send {Escape}[ad
^.::Send {Escape}[ae
^i::Send {Escape}[ah
^3::Send {Escape}[ai
^4::Send {Escape}[aj
^m::Send {Escape}[am
^f3::Send {Escape}[al
^f2::Send {Escape}[ab
#IfWinActive

; cmder.exe https://github.com/cmderdev/cmder
#IfWinActive ahk_class VirtualConsoleClass
#c::return
#v::StringTypePaste(Clipboard)
^BackSpace::Send {Escape}[aa
^;::Send {Escape}[af
^,::Send {Escape}[ad
^.::Send {Escape}[ae
^i::Send {Escape}[ah
^3::Send {Escape}[ai
^4::Send {Escape}[aj
^m::Send {Escape}[am
^f3::Send {Escape}[al
^f2::Send {Escape}[ab
#IfWinActive



#IfWinActive ahk_class ConsoleWindowClass
^v::StringTypePaste(Clipboard)
#v::StringTypePaste(Clipboard)
^y::StringTypePaste(Clipboard)
^Return::startMsysHere()
^!Return::cmd_explore_here()
#Esc::SendInput ,^c^cexit`n
Esc::Send ,exit`n

^!f::Send ^{Right}
^!b::Send ^{Left}

^n:: Send {Down}
^p:: Send {UP}
^a::Send {Home}
^e::Send {End}
^!a::Send {Home}
^!e::Send {End}
^d::Send {Del}
^f::Send {Right}
^b::Send {Left}

; ^u::Send ^{Home}
; 滚屏
^u::Send {WheelUp}
; ^v::Send {WheelDown}
^k::Send ^{End}
#IfWinActive

#IfWinActive ahk_class mintty
^v::StringTypePaste(Clipboard)
#v::StringTypePaste(Clipboard)
^y::StringTypePaste(Clipboard)
Esc::Send ,exit`n

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

;;c:\a\b -->d:/a/b
win_2_posixPath(winPath)
{
   StringReplace, posixPath, winPath, \ , /, All
   Return posixPath
}
