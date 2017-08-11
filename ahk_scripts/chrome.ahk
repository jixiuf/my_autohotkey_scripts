; #SingleInstance force
; #NoTrayIcon
SetTitleMatchMode Regex ;可以使用正则表达式对标题进行匹配

#IfWinActive ahk_class Chrome_WidgetWin_1
;;Ctrl+; 定位到地址栏
^;::Send {f6}
#t::Send ^t
#n::Send ^{TAB}
#p::Send ^+{TAB}
^h::Send !{Left}
^l::Send !{Right}
#IfWinActive
