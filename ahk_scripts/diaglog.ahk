#NoTrayIcon
#SingleInstance force   
SetKeyDelay 0

#IfWinActive ahk_class #32770
^BS::Send ^+{Left}{Del}
!BS::Send ^+{Left}{Del}
^u::Send +{Home}^c{Del}
^k::Send +{End}^c{Del}
!d::Send ^+{Right}^c{Del}
^q::send {Home}
^a::send {Home}
^e::send  {end}
^i::Send ^{Left}^+{Right}       ; Select the current word
!w::Send ^c
^w::Send ^x
^y::Send ^v
^d::Send {Del}
^/::Send ^z
^j::Send {Enter}

^p::send {Up}
^n::send {Down}
^f::Send {Right}
!f::Send ^{Right}
^b::Send {Left}
!b::Send ^{Left}
^h::Send {BackSpace}
#IfWinActive


