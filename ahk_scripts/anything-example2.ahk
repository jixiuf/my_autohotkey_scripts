#include anything.ahk

action4source1(candidate)
{
  MsgBox , you have selected: %candidate%
}

getCandidates()
{
  candidates:=Array("red","green")
  return candidates
}

source1 :=Object()
;;candidate can be a function name ,
;;the function must return an array 
source1["candidate"]:="getCandidates"
source1["action"]:="action4source1"

f1::anything(source1)


