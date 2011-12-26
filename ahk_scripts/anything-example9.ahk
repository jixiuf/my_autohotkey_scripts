#include anything.ahk
;;support icon 
action4source1(candidate)
{
  anything_MsgBox("you have select candidate:" . candidate . "from source1")    
}

getCandidates()
{
  candidates:=Array("red","green","blue")
  return candidates
}
icon()
{
  ImageListID := IL_Create(3)  ; Create an ImageList to hold 3 small icons.
Loop 3  ; Load the ImageList with a series of icons from the DLL.
    IL_Add(ImageListID, "shell32.dll", A_Index)
    return ImageListID
}

source1 :=Object()
source1["candidate"]:="getCandidates"
source1["action"]:="action4source1"
source1["name"]:="name"
source1["icon"]:="icon"
f1::anything(source1)


