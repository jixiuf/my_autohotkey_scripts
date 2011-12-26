#include anything.ahk

;;each element of candidates can be an array ,
;;the length of the array is 2 , 
;; first element of array will be displayed on listview and
;;be used to match user's search string .
;; the second element of array can be anything .you can store usefull info here .
;; and it can be passed to "action" function
;;
action4source1(candidate)
{
  display :=candidate[1]
   real :=   candidate[2]
  anything_MsgBox("the string display on listview is :" .display . "and real useful info is " real)
}

getCandidates()
{
  candidates:=Array()
  red:=Array()
  red.insert("red")
  red.insert("reddddddd")
  candidates.insert(red)
  
  green:=Array()
  green.insert("gree")
  green.insert("ggggggggggggg")
  candidates.insert(green)
  
  return candidates
}

source1 :=Object()
;;candidate can be a function name ,
;;the function must return an array 
source1["candidate"]:="getCandidates"
source1["action"]:="action4source1"
source1["name"]:="name"
f1::anything(source1)


