#include anything.ahk

action4source1(candidate)
{
  anything_MsgBox("you have select candidate:" . candidate)
}

getCandidates()
{
  candidates:=Array("red","green")
  return candidates
}

source1 :=Object()
;;"candidate" can be a function name ,
;;the function must return an array
;;"action" is a function accept one parameter
;;the parameter is your selected candidate
;;"name" is just a name show behind each candidate

;; when you select a candidate , "Anything" will execute the 
;; "action" function on your selected candidate 
source1["candidate"]:="getCandidates"
source1["action"]:="action4source1"
source1["name"]:="name"
f1::anything(source1)


