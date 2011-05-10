;;;Ctrl+v Ctrl+Y Shift+Insert: paste 在命令行里有效
;;;Win+v 在所有窗口中有效,

#NoTrayIcon
#SingleInstance force
SendMode, Input

;// Win+V = "type-paste" for all apps...
#v::StringTypePaste(Clipboard)

#IfWinActive ahk_class ConsoleWindowClass
^v::StringTypePaste(Clipboard)
#IfWinActive

#IfWinActive ahk_class ConsoleWindowClass
+Insert::StringTypePaste(Clipboard)

#IfWinActive ahk_class ConsoleWindowClass
^y::StringTypePaste(Clipboard)


StringTypePaste(p_str, p_condensenewlines=1) {
if (p_condensenewlines) {
p_str:=RegExReplace(p_str, "[`r`n]+", "`n")
}
Send, % "{Raw}" p_str
}


;;;Ctrl+Alt+c 或者Ctrl+w Cut ,前提是起用快速编辑模式
^!C:: MouseClick, Right
^w:: MouseClick, Right

