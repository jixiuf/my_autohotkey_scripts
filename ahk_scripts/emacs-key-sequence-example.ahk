#Include emacs-key-sequence.ahk 
map:=Object()
map.insert("^x^f","msg1")
map.insert("^x^e^e","msg2")
map.insert("^xvv","msg3")
map.insert("#x#f","msg4")


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
$^x::prefixKey("^x",map)

;;another one
map2:=Object()
map2.insert("#x#s" ,"msg5")
map2.insert("#x#f" ,"msg4")
$#x::prefixKey("#x", map2)

msg4(){
MsgBox ,msg4 is called 
}

msg5(){
MsgBox ,msg5 is called 
}
