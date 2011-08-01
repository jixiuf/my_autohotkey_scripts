; #SingleInstance force
; #NoTrayIcon
; #NoEnv  ; 


SetBatchLines -1 ;速度最大化
SendMode Input  
SetWorkingDir %A_ScriptDir%

#ifwinactive ahk_class WindowsForms10.Window.8.app.0.33c0d9d
^;::
sleep,10
send,{esc}{end}+{home}{f5}{End}
return

^n::SendInput {Down}
^p::SendInput {Up}
^a::SendInput {Home}
^q::Send ^a
^e::SendInput {End}
^j::SendInput {Return}
^/::Send ^z
^k::Send {esc}+{end}^c{del}
^y::Send ^v
^d::Send {Del}
^m::Send {Home}+{End}^c{End}{Enter}^v ; Duplicate the current line, like R#
^BS::Send ^+{Left}{Del}
!BS::Send ^+{Left}{Del}
^u::Send +{Home}^c{Del}
!d::Send {Del}
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
#IfWinActive 
