setkeydelay 0
msg1(){
  MsgBox ,this is function msg1(),will be called when you press #x#f in this example
}
msg2(){
  MsgBox ,this is function msg2(),will be called when you press #x#e in this example
}

map:=Object()
map.insert("#x#f","msg1")
map.insert("#x#e","msg2")


#x::prefixKey("#x",map)

prefixKey(prefix ,keyFuncMap){
seq:=prefix
map:=keyFuncMap
; {LCsontrol}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}{Escape}
Input, input, L1,{Escape}  {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}abcdefghijklmnoqprstuvwxyz
    if ErrorLevel = EndKey:Escape
    {
     seq =
    }
if ErrorLevel = EndKey:a  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%a
}
if ErrorLevel = EndKey:b  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%b
}
if ErrorLevel = EndKey:c  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%c
}
if ErrorLevel = EndKey:d  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%d
}
if ErrorLevel = EndKey:e  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%e
}
if ErrorLevel = EndKey:f  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%f
}
if ErrorLevel = EndKey:g  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%g
}
if ErrorLevel = EndKey:h  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%h
}
if ErrorLevel = EndKey:i  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%i
}
if ErrorLevel = EndKey:j  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%j
}
if ErrorLevel = EndKey:k  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%k
}
if ErrorLevel = EndKey:l  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%l
}
if ErrorLevel = EndKey:m  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%m
}
if ErrorLevel = EndKey:n  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%n
}
if ErrorLevel = EndKey:o  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%o
}
if ErrorLevel = EndKey:p  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%p
}
if ErrorLevel = EndKey:q  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%q
}
if ErrorLevel = EndKey:r  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%r
}
if ErrorLevel = EndKey:s  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%s
}
if ErrorLevel = EndKey:t  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%t
}
if ErrorLevel = EndKey:u  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%u
}
if ErrorLevel = EndKey:v  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%v
}
if ErrorLevel = EndKey:w  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%w
}
if ErrorLevel = EndKey:x  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%x
}
if ErrorLevel = EndKey:y  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%y
}
if ErrorLevel = EndKey:z  
{
if (GetKeyState("LWin", "P")=1){
seq=%seq%#
}
if (GetKeyState("RWin", "P")=1){
seq=%seq%#
}
seq=%seq%z
}
 funcName:= map[seq]
    if funcName<>
  {
    callFuncByName(funcName)
  }else{
    seq:=SubStr(seq ,3)
    if prefix<>seq
        send %seq%
  }
}
;;end of func prefixKey(..)
;;param string , funcName is a function
;;without paramters
callFuncByName(funcName){
  fun1:=RegisterCallback(funcName, "F", 0)
  DllCall(fun1)  

}
;; key:=map["^xf"]
;; callFuncByName(key)
