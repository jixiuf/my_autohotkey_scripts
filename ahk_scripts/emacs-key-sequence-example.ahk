#Include emacs-key-sequence.ahk

$^x::
map:=Object()
map.insert("^x^f","msg1")
map.insert("^x^e^e","msg2")
map.insert("^xvv","msg3")
prefixKey("^x",map)
return



msg1(){
  MsgBox ,this is function msg1(),will be called when you press ^x^f in this example
}
msg2(){
  MsgBox ,this is function msg2(),will be called when you press ^x^e^e in this example
}
msg3(){
  MsgBox ,this is function msg3(),will be called when you press ^xvv in this example
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;another one

$#x::
map2:=Object()
map2.insert("#x#s" ,"msg5")
map2.insert("#x#f" ,"msg4")
map2.insert("#x{F1}" ,"msg6")
prefixKey("#x", map2)
return 

msg4(){
MsgBox ,msg4 is called when you press "Win+x Win+f"
}

msg5(){
MsgBox ,msg5 is called  when you press "Win+x Win+s"
}
msg6(){
MsgBox ,msg6 is called  when you press "Win+x F1"
}

