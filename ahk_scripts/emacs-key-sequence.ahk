;;emacs-key-sequence.ahk --   binding GNU/Emacs like key 
        
;; about how to use this emacs-key-sequence.ahk
;; 1. include emacs-key-sequence.ahk in you ahk files
;; like this :
;; #Include emacs-key-sequence.ahk 
;; 2. define a Object() ,a map
;;   and insert("keys" ,"functionNameYouWantToCallWhenYouPresskeys")
;; for example ,
;; map:=Object()
;; map.insert("^x^f","msg1")
;; map.insert("^x^e^e","msg2")
;; map.insert("^xvv","msg3")
;;
;; 3 ,bind  the root key prefix to the root key prefix
;; for example 
;; $^x::
;;      map:=Object()
;;      map.insert("^x^f","msg1")
;;      map.insert("^x^e^e","msg2")
;;      map.insert("^xvv","msg3")
;;    prefixKey("^x",map)
;; return
;; $^d::
;;   map:=Object()
;;      map.insert("^d^f","msg1")
;;      map.insert("^d^e^e","msg2")
;;      map.insert("^dvv","msg3")
;;    prefixKey("^d",map)
;; the "$" ,must be used

;;4 define functions that will be called the some key is pressed
;; msg1(){
;;   MsgBox ,this is function msg1(),will be called when you press ^x^f in this example
;; }
;; msg2(){
;;   MsgBox ,this is function msg2(),will be called when you press ^x^e^e in this example
;; }
;; msg3(){
;;   MsgBox ,this is function msg3(),will be called when you press ^xvv in this example
;; }



setkeydelay 0

prefixKey(prefix ,keyFuncMap){
seq:=prefix
loop,
{
; {LCsontrol}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}{Escape}
Input,input,L1,{Escape}{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}abcdefghijklmnopqrstuvwxyz1234567890{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}{Escape}
    if ErrorLevel = EndKey:Escape
    {
     seq =prefix
    }
if ErrorLevel = EndKey:LControl  
{
continue
}
if ErrorLevel = EndKey:RControl  
{
continue
}
if ErrorLevel = EndKey:LWin  
{
continue
}
if ErrorLevel = EndKey:RWin  
{
continue
}
if ErrorLevel = EndKey:LAlt  
{
continue
}
if ErrorLevel = EndKey:RAlt  
{
continue
}
if ErrorLevel = EndKey:LShift  
{
continue
}
if ErrorLevel = EndKey:RShift  
{
continue
}
if ErrorLevel = EndKey:a  
{
input=a
}
if ErrorLevel = EndKey:b  
{
input=b
}
if ErrorLevel = EndKey:c  
{
input=c
}
if ErrorLevel = EndKey:d  
{
input=d
}
if ErrorLevel = EndKey:e  
{
input=e
}
if ErrorLevel = EndKey:f  
{
input=f
}
if ErrorLevel = EndKey:g  
{
input=g
}
if ErrorLevel = EndKey:h  
{
input=h
}
if ErrorLevel = EndKey:i  
{
input=i
}
if ErrorLevel = EndKey:j  
{
input=j
}
if ErrorLevel = EndKey:k  
{
input=k
}
if ErrorLevel = EndKey:l  
{
input=l
}
if ErrorLevel = EndKey:m  
{
input=m
}
if ErrorLevel = EndKey:n  
{
input=n
}
if ErrorLevel = EndKey:o  
{
input=o
}
if ErrorLevel = EndKey:p  
{
input=p
}
if ErrorLevel = EndKey:q  
{
input=q
}
if ErrorLevel = EndKey:r  
{
input=r
}
if ErrorLevel = EndKey:s  
{
input=s
}
if ErrorLevel = EndKey:t  
{
input=t
}
if ErrorLevel = EndKey:u  
{
input=u
}
if ErrorLevel = EndKey:v  
{
input=v
}
if ErrorLevel = EndKey:w  
{
input=w
}
if ErrorLevel = EndKey:x  
{
input=x
}
if ErrorLevel = EndKey:y  
{
input=y
}
if ErrorLevel = EndKey:z  
{
input=z
}
if ErrorLevel = EndKey:1  
{
input=1
}
if ErrorLevel = EndKey:2  
{
input=2
}
if ErrorLevel = EndKey:3  
{
input=3
}
if ErrorLevel = EndKey:4  
{
input=4
}
if ErrorLevel = EndKey:5  
{
input=5
}
if ErrorLevel = EndKey:6  
{
input=6
}
if ErrorLevel = EndKey:7  
{
input=7
}
if ErrorLevel = EndKey:8  
{
input=8
}
if ErrorLevel = EndKey:9  
{
input=9
}
if ErrorLevel = EndKey:0  
{
input=0
}
if ErrorLevel = EndKey:F1  
{
input={F1}
}
if ErrorLevel = EndKey:F2  
{
input={F2}
}
if ErrorLevel = EndKey:F3  
{
input={F3}
}
if ErrorLevel = EndKey:F4  
{
input={F4}
}
if ErrorLevel = EndKey:F5  
{
input={F5}
}
if ErrorLevel = EndKey:F6  
{
input={F6}
}
if ErrorLevel = EndKey:F7  
{
input={F7}
}
if ErrorLevel = EndKey:F8  
{
input={F8}
}
if ErrorLevel = EndKey:F9  
{
input={F9}
}
if ErrorLevel = EndKey:F10  
{
input={F10}
}
if ErrorLevel = EndKey:F11  
{
input={F11}
}
if ErrorLevel = EndKey:F12  
{
input={F12}
}
if ErrorLevel = EndKey:Down  
{
input={Down}
}
if ErrorLevel = EndKey:Left  
{
input={Left}
}
if ErrorLevel = EndKey:Right  
{
input={Right}
}
if ErrorLevel = EndKey:Up  
{
input={Up}
}
if ErrorLevel = EndKey:Home  
{
input={Home}
}
if ErrorLevel = EndKey:End  
{
input={End}
}
if ErrorLevel = EndKey:PageUp  
{
input={PageUp}
}
if ErrorLevel = EndKey:PageDown  
{
input={PageDown}
}
if ErrorLevel = EndKey:Del  
{
input={Del}
}
if ErrorLevel = EndKey:Ins  
{
input={Ins}
}
if ErrorLevel = EndKey:BS  
{
input={BS}
}
if ErrorLevel = EndKey:Capslock  
{
input={Capslock}
}
if ErrorLevel = EndKey:Numlock  
{
input={Numlock}
}
if ErrorLevel = EndKey:PrintScreen  
{
input={PrintScreen}
}
if ErrorLevel = EndKey:Pause  
{
input={Pause}
}
if ErrorLevel = EndKey:Escape  
{
input={Escape}
}

 tmpStr=
   if (GetKeyState("RWin")=1 ||GetKeyState("LWin")=1){
     tmpStr=#
   }
  if (GetKeyState("RControl")=1 ||GetKeyState("LControl")=1 ){
      tmpStr=%tmpStr%^
   }
  if (GetKeyState("RAlt")=1 ||GetKeyState("LAlt")=1 ){
      tmpStr=%tmpStr%!
   }
  if (GetKeyState("RShift")=1 ||GetKeyState("LShift")=1 ){
      tmpStr=%tmpStr%+
   }
   tmpStr=%tmpStr%%input%
       if tmpStr=^g  ;;Ctrl+g ,cancel ,
           break
      seq=%seq%%tmpStr%
     ;; ToolTip,%seq%
      funcName:= keyFuncMap[seq]
           if funcName<>
            {
              callFuncByName(funcName)
              break
            }else{
              containPrefix=
              For k, v in keyFuncMap
              {
                StringGetPos, pos,k, %seq%
                if pos=0  ;;if k starts with seq
                {
                 containPrefix:=true
                 break
                 }
              }
              ;;if key Prefix you press don't exists in keyFuncMap ,then
              ;;send it to system
              ;;suppose the map is {"^xvd" "function1"
              ;;                    "^xc" "function2"}
              ;; and you have pressed "^xd" , there isn't a key equas "^xd"
              ;; so no function would be called
              ;; and "^xd" will be send to system
              if containPrefix=
              {
              Tooltip ,%seq%
                  sendInput, %seq%
                  break
              }else{
                 continue
              }
            }
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
