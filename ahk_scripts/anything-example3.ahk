#include anything.ahk

action4source1(candidate)
{
  anything_MsgBox("you have select candidate:" . candidate)
}

source1 :=Object()
;;this example is the same to anything-example2.ahk
;;except : 
;;candidates can be an array
;;
candidates:=Array("red","green")
source1["candidate"]:=candidates

source1["action"]:="action4source1"
source1["name"]:="example2"

f1::anything(source1)


