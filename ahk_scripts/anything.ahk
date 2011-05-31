#SingleInstance force
SetBatchLines, -1
SetKeyDelay  -1
        
anything(sources){ 
   candidates_count=0
   for key ,source in sources {
     candidates_count += % source["candidate"].maxIndex()
    }
   WinSet, Transparent, 230
   Gui, Color,black,black
   Gui,Font,s13 c7cfc00 bold
   Gui, Add, Text,     x10  y10 w800 h30, Search`:
   Gui, Add, Edit,     x90 y5 w500 h30,
     icon:=source["icon"]
     if icon<>
     {
        Gui, Add, ListView, x0 y40 w800 h510 -VScroll -E0x200 AltSubmit -Hdr -HScroll -Multi  Count10 , icon|candidates
        ImageListID1 := IL_Create(candidates_count,1,1)
        LV_SetImageList(ImageListID1, 1)
     }else{
        Gui, Add, ListView, x0 y40 w800 h510 -VScroll -E0x200 AltSubmit -Hdr -HScroll -Multi  Count10 , candidates
     }
     for key ,source in sources {
          candidates:= source["candidate"]
          for key ,candidate in candidates {
             LV_Add("",candidate)
          }
      }
     Gui ,Show,,
     exit=0
     loop,
     {
         Input, input, L1, {enter}{esc}{backspace}{up}{down}{pgup}{pgdn}{tab}{left}{right}{LControl}npsgukjh{LAlt}
     
         if ErrorLevel = EndKey:enter
         {
             break
         }
         if ErrorLevel = EndKey:escape
         {
           exit()
           exit=1
           break
         }
         if ErrorLevel = EndKey:LControl
            {
               continue
            }
         if ErrorLevel = EndKey:n
           {
            if (GetKeyState("LControl", "P")=1){
               selectNextCandidate(candidates_count)
            }else{
                 input=n
             }
          }
           if ErrorLevel = EndKey:p
           {
            if (GetKeyState("LControl", "P")=1){
              selectPreviousCandidate()
             }else{
                 input=p
             }
      
         }
       
         if ErrorLevel = EndKey:pgup
         {
             Send, {pgup}
             continue
         }
         if exit=0
         {
            search = %search%%input%
            GuiControl,, Edit1, %search%
            GuiControl,Focus,Edit1 ;; focus Edit1 ,
            Send {End} ;;move cursor right ,make it after the new inputed char
         }
     }
} ;; end of anything function

selectNextCandidate(candidates_count){
       rowNum:= LV_GetNext(0)
       if(rowNum< candidates_count){
          LV_Modify(rowNum+1, "Select Focus")
       }else{
          LV_Modify(1, "Select Focus")
       }
}

selectPreviousCandidate(){
            rowNum:= LV_GetNext(0)
              if(rowNum<2){
                 LV_Modify(numwin, "Select Focus") 
              }else{
                 LV_Modify(rowNum-1, "Select Focus")
              }
}
exit(){
Gui Cancel
}
 
sources:= Array()
source1 :=Object()
candidates:=Array("red" ,"green")
source1["candidate"]:=candidates
sources.insert(source1)
source2 :=Object()
candidates:=Array("red" ,"green")
source2["candidate"]:=candidates
sources.insert(source2)
anything(sources)
