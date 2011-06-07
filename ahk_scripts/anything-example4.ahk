#include anything.ahk
;;anything support multiply sources 
action4source1( candidate)
{
msgbox, you have selected: %candidate% from source1 
}


action4source2(candidate)
{
msgbox, you have selected: %candidate% for source2
}

getCandidates()
{
  candidates:=Array("red","green")
  return candidates
}
getCandidates2()
{
  candidates:=Array("white","black")
  return candidates
}
  
source1 :=Object()
source1["candidate"]:="getCandidates"
source1["action"]:="action4source1"

source2 :=Object()
source2["candidate"]:="getCandidates2"
source2["action"]:="action4source2"


sources:= Array()
sources.insert(source1)
sources.insert(source2)

f1::anything_multiple_sources(sources)


