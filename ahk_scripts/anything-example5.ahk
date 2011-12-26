#include anything.ahk
;;multiple actions for one source
;;Enter execute default action
;;Ctrl-j execute second action
;;Ctrl-m execute third action
;;Tab list all available action for the selected candidate
action4source1(candidate)
{
  anything_MsgBox("you  select candidate:" . candidate . "execute the default action ,bind [Enter]")
}
action24source1(candidate)
{
  anything_MsgBox("you select candidate:" . candidate . "`n and execute 2th action {Default bind Ctrl-j}")
  
}
action34source1(candidate)
{
  anything_MsgBox("you select candidate:" . candidate . "`n and execute 3th action {Default bind Ctrl-m}")
}

source1 :=Object()
;;candidates can be an array
candidates:=Array("red","green")
source1["candidate"]:=candidates

actions:=Array("action4source1" ,"action24source1","action34source1")
source1["action"]:=actions
source1["name"]:="example5"
f1::anything(source1)


