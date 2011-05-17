setkeydelay 0
msg1(){
  MsgBox ,this is function msg1(),will be called when you press #x#f in this example
}
msg2(){
  MsgBox ,this is function msg2(),will be called when you press #x#e in this example
}

map:=Object()
map.insert("^x^f","msg1")
map.insert("^x^e","msg2")
^x::prefixKey("^x",map)


prefixKey(prefix ,keyFuncMap){
seq:=prefix
map:=keyFuncMap
loop,
{
; {LCsontrol}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}{Escape}
Input,input,L1,{Escape}{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}
    if ErrorLevel = EndKey:Escape
    {
     seq =prefix
    }
if ErrorLevel = EndKey:LControl  
{
continue
}
if ErrorLevel = EndKey:LAlt  
{
continue
}

;if (InStr(input, "^")=0 and InStr(input, "#")=0 and  InStr(input, "!")=0 and  InStr(input, "+") =0){
       tmpStr=
         if (GetKeyState("RWin", "P")=1 ||GetKeyState("LWin", "P")=1){
           tmpStr=#
         }
        if (GetKeyState("RControl", "P")=1 ||GetKeyState("LControl", "P")=1 ){
            tmpStr=%tmpStr%^
         }
        if (GetKeyState("RAlt", "P")=1 ||GetKeyState("LAlt", "P")=1 ){
            tmpStr=%tmpStr%!
         }
        if (GetKeyState("RShift", "P")=1 ||GetKeyState("LShift", "P")=1 ){
            tmpStr=%tmpStr%+
         }
         tmpStr=%tmpStr%%input%
         ToolTip ,%tmpStr%
     break
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
