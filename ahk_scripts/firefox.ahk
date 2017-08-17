; #SingleInstance force
; #NoTrayIcon
SetTitleMatchMode Regex ;可以使用正则表达式对标题进行匹配
#IfWinActive ahk_class MozillaUIWindowClass|MozillaWindowClass
;;Ctrl+; 定位到地址栏
^;::Send ^l
#t::Send ^t
#n::Send ^{TAB}
#p::Send ^+{TAB}
^h::Send !{Left}
^l::Send !{Right}
^s::Send ^f
#IfWinActive
