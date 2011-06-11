#include anything.ahk

;;you can set properties for "Anything" by callling 
;; another function
;;        anything_multiple_sources_with_properties(sources,anything_properties)
;; or
;;      anything_with_properties(source ,anything_properties)
;; about anything_properties ,see
;;               default_anything_properties 
;; in  anything.ahk ,you can overwrite properties defined there .


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
source1["name"]:="1111111"

source2 :=Object()
source2["candidate"]:="getCandidates2"
source2["action"]:="action4source2"
source2["name"]:="22222222222"


sources:= Array()
sources.insert(source1)
sources.insert(source2)

anything_properties:=Object()
anything_properties["quit_when_lose_focus"]:="no"
anything_properties["win_width"]:="600"
anything_properties["win_height"]:="300"

f1::anything_multiple_sources_with_properties(sources,anything_properties)



