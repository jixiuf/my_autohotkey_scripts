; #NoTrayIcon
; #SingleInstance force   
SetKeyDelay 0

#IfWinActive ahk_class #32770
^BS::Send ^+{Left}{Del}
!BS::Send ^+{Left}{Del}
^u::Send +{Home}^c{Del}
^k::Send +{End}^c{Del}
!d::Send ^+{Right}^c{Del}
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

;;; for all Edit
        
~$^q::
  IfWinActive ,ahk_class MozillaWindowClass
  {
     send  ^v^a
  }else
  IfWinActive ,ahk_class Emacs
  {
  }else
  {
    send  ^a
  }
return
            
$~^a::
ControlGetFocus, focusedControl, A
ifInString ,focusedControl ,Edit
{
  IfWinActive ,ahk_class Emacs
  {
    ; send {Home}
  }
  IfWinActive ,ahk_class MozillaWindowClass
  {
    send {Home}
  }else{
   send ^c{Home}
  }
}
return

        
~^e::
ControlGetFocus, focusedControl, A
ifInString ,focusedControl ,Edit
{
  send {End}
}
return
                
~^k::  
ControlGetFocus, focusedControl, A
ifInString ,focusedControl ,Edit
{
Send +{End}^c{Del}
}
return
        
#Include d:\ahk\ahk_scripts\emacs-key-sequence.ahk
         
         
$#x::
map:=Object()
map.insert("#xh","selectAll")
prefixKey("#x",map)
return


selectAll(){
  IfWinActive ,ahk_class Emacs
  {
     send  ^xh
  }else
  IfWinActive ,ahk_class MozillaWindowClass
  {
     send  ^v^a
  }else{
    send  ^a
  }
}
