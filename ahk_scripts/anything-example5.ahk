#include anything.ahk
;;multiple actions for one source
;;Enter execute default action
;;Ctrl-j execute second action
;;Ctrl-m execute third action
;;Tab list all available action for the selected candidate
action4source1(candidate)
{
  Msgbox, you have selected: %candidate%
}
action24source1(candidate)
{
  Msgbox, you have selected: %candidate% ,and execute 2th action
  
}
action34source1(candidate)
{
  Msgbox, you have selected: %candidate% ,and execute 3th action 
}

source1 :=Object()
;;candidates can be an array
candidates:=Array("red","green")
source1["candidate"]:=candidates

actions:=Array("action4source1" ,"action24source1","action34source1")
source1["action"]:=actions
source1["name"]:="example5"
f1::anything(source1)


