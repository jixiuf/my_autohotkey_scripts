#NoTrayIcon
#SingleInstance force
SetKeyDelay 0



#IfWinActive ahk_class IEFrame

^BS::Send ^+{Left}{Del}
!BS::Send ^+{Left}{Del}
^u::Send +{Home}^c{Del}
^k::Send +{End}^c{Del}
!d::Send ^+{Right}^c{Del}
^q::send {Home}
^a::send {Home}
^e::send  {end}
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
+!<::Send ^{Home}
+!>::Send ^{End}
!<::Send ^{Home}
!>::Send ^{End}

!s::Send ^f
^h::Send {BackSpace}
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


