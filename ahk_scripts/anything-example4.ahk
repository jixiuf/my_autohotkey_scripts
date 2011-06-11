#include anything.ahk
;;anything support multiply sources
;; the candidate from different source will execute different action 
;; when you select it .
;;
;; and Ctrl-o  will send the First source to Last 
action4source1( candidate)
{
msgbox, you have selected: %candidate% from source111111111
}

getCandidates()
{
  candidates:=Array("red","green")
  return candidates
}

source1 :=Object()
source1["candidate"]:="getCandidates"
source1["action"]:="action4source1"
source1["name"]:="source1"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

action4source2(candidate)
{
msgbox, you have selected: %candidate% from source22222222222
}
getCandidates2()
{
  candidates:=Array("white","black")
  return candidates
}

source2 :=Object()
source2["candidate"]:="getCandidates2"
source2["action"]:="action4source2"
source2["name"]:="source2"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

action4source3(candidate)
{
display:=candidate[1]
real:=candidate[2]
msgbox, you have selected: %display%, the price is %real%
}


getCandidates3()
{
  candidates:=Array()
  book:=Object()
  book.insert("book111111111")
  book.insert("$10.0")
  
  pen:=Object()
  pen.insert("pen22222222222")
  pen.insert("$3.0")
  
  candidates.insert(book)
 candidates.insert(pen)
  return candidates
}
    
source3 :=Object()
source3["candidate"]:="getCandidates3"
source3["action"]:="action4source3"
source3["name"]:="source3"


sources:= Array()
sources.insert(source1)
sources.insert(source2)
sources.insert(source3)

f1::anything_multiple_sources(sources)


