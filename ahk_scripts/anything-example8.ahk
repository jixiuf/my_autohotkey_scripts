#include anything.ahk

;;you can set properties for "Anything" by callling 
;; another function
;;        anything_multiple_sources_with_properties(sources,anything_properties)
;; or
;;      anything_with_properties(source ,anything_properties)
;; about anything_properties ,see
;;               default_anything_properties 
;; in  anything.ahk ,you can overwrite properties defined there .
;;
;; and there is a property named "no_candidate_action"
;; the value of this property is a function accept one parameter
;; the default value is 
;; default_anything_properties["no_candidate_action"]:="anything_do_nothing"
;; that means when no candidates matched your search string ,and you press 
;; "Enter" key ,then this function will be called ,and the search string 
;; will be the parameter 


;;one more  ,even there are matched candidates ,you can 
;; still pass the "search string" to this function 
;; by Ctrl-i


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
anything_properties["no_candidate_action"]:="do_what_you_want_when_no_matched_candidates"

do_what_you_want_when_no_matched_candidates(candidate)
{
MsgBox ,do what you want when no matech candidates ,with your search string : "%candidate%"
}

f1::anything_multiple_sources_with_properties(sources,anything_properties)



