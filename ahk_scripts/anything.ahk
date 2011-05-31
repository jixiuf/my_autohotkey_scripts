#SingleInstance force
SetBatchLines, -1
SetKeyDelay  -1
        
anything(sources){ 
   candidates_count=0
   search=
   matched_candidates:=Object()
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
     refresh(sources,search,matched_candidates)
     Gui ,Show,,
     WinGet, anything_id, ID, A
     WinSet, AlwaysOnTop, On, ahk_id %anything_id%
     
     exit=0
     loop,
     {
         Input, input, L1, {enter}{esc}{backspace}{up}{down}{pgup}{pgdn}{tab}{left}{right}{LControl}npguh{LAlt}
     
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
           if ErrorLevel = EndKey:g
           {
            if (GetKeyState("LControl", "P")=1){
              exit()
              exit=1
              break
             }else{
                 input=g
             }
      
         }
        ;;Ctrl+u clear "search" string ,just like bash
        if ErrorLevel = EndKey:u
        {
          if (GetKeyState("LControl", "P")=1){
               search=
               GuiControl,, Edit1, %search%
               GuiControl,Focus,Edit1 ;; focus Edit1 ,
               continue
           }else{
                input=u
            }
        }
        if ErrorLevel = EndKey:h
        {
          if (GetKeyState("LControl", "P")=1){
             if search =
              {
                  GuiControl,, Edit1, 
                  return
              }
              StringTrimRight, search, search, 1
              GuiControl,, Edit1, %search%
              GuiControl,Focus,Edit1 ;; focus Edit1 ,
              Send {End} ;;move cursor end 
              continue
           }else{
                input=h
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

refresh(sources,search,matched_candidates){
     for key ,source in sources {
          candidates:= source["candidate"]
          for key ,candidate in candidates{
               matched_candidates:=lv_add_candidate_if_match(candidate,search,matched_candidates)
          }
      }
return matched_candidates
}

;;candidate can be a string, when it is  a string ,it will be
;;displayed on the listview directly
;;and can be an array ,when it is an array
;;the array[1] will show on the listview ,and
;;array[2] will store something useful info.
lv_add_candidate_if_match(candidate,search,matched_candidates){
  if isObject(candidate){ 
    display:=candidate[1]
  }else{
    display:=candidate
  }
   if % anything_match(display,search)=1
   {
      LV_Add("",display)
      matched_candidates.insert(candidate)
   }
   return matched_candidates
}

;;just like google ,the pattern ,are keywords separated by space
;; when string matched all the keywords ,then it return 1
;; else return 0
anything_match(candidate_string,pattern){
   if pattern=
     return 1
   else{
    Loop,parse,pattern ,%A_Space%,%A_Space%%A_TAB%
    {
      if candidate_string not contains %A_LoopField%,
      {
       return 0
      }
    }
    return 1
 }
}
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
candidates:=Array("red" ,"geen")
source1["candidate"]:=candidates
sources.insert(source1)
source2 :=Object()
candidates:=Array("red" ,"green")
source2["candidate"]:=candidates
sources.insert(source2)
anything(sources)
