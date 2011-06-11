#SingleInstance force
SetBatchLines, -1
SetKeyDelay  -1
AutoTrim, off

anything(source)
{
  sources:= Array()
  sources.insert(source)
  anything_multiple_sources(sources)
}

anything_multiple_sources(sources){
   win_width=900
   candidates_count=0
   search=
   matched_candidates:=Object()
   tmpSources:=sources
   for key ,source in tmpSources {
       candidate:=source["candidate"]
       source["tmpCandidate"]:= getCandidatesArray(source)
       candidates_count += % source["tmpCandidate"].maxIndex()
    }
   Gui,+LastFound +AlwaysOnTop -Caption ToolWindow   
   WinSet, Transparent, 225
   Gui, Color,black,black
   Gui,Font,s12 c7cfc00 bold
   Gui, Add, Text,     x10  y10 w80 h30, Search`:
   Gui, Add, Edit,     x90 y5 w500 h30,
   OnMessage( 0x06, "anything_WM_ACTIVATE" ) ;;when window lost focus 
   OnMessage(0x201, "anything_WM_LBUTTONDOWN") ;;when LButton(mouse) is down 
   icon:=source["icon"]
     if icon<>
     {
        Gui, Add, ListView, x0 y40 w%win_width% h510 -VScroll -E0x200 AltSubmit -Hdr -HScroll -Multi  Count10 , icon|candidates|source_index|candidate_index|source-name
        ImageListID1 := IL_Create(candidates_count,1,1)
        LV_SetImageList(ImageListID1, 1)
     }else{
        Gui, Add, ListView, x0 y40 w%win_width% h510 -VScroll -E0x200 AltSubmit -Hdr -HScroll -Multi  Count10 , candidates|source_index|candidate_index|source-name
     }
     matched_candidates:=refresh(tmpSources,search,win_width)
     Gui ,Show,,
      if matched_candidates.maxIndex()>0
      {
         LV_Modify(1, "Select Focus Vis") 
      }else{
      }

     WinGet, anything_id, ID, A
     WinSet, AlwaysOnTop, On, ahk_id %anything_id%
     loop,
     {
         Input, input, L1, {enter}{esc}{backspace}{up}{down}{pgup}{pgdn}{tab}{left}{right}{LControl}npguhjmo{LAlt}
     
         if ErrorLevel = EndKey:enter
         {
            selectedRowNum:= LV_GetNext(0)
            if(selectedRowNum=0) ;;no matched candidates 
            {
            ;;if no matched candidates ,then the string you typed in the textfield will
            ;;be treated as the candidate ,and the actions can  be executed on this
            ;;candidate is the collection of each source's  DefaultAction 
              
            }else
            {
              LV_GetText(source_index, selectedRowNum,2) ;;populate source_index  
              action:= getDefaultAction(tmpSources[source_index]["action"])
              exit()
              callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
            }
            break
         }
         if ErrorLevel = EndKey:j
           {
            if (GetKeyState("LControl", "P")=1){
                 selectedRowNum:= LV_GetNext(0)
                  if (selectedRowNum=0)
                  {
                  }else
                  {
                       LV_GetText(source_index, selectedRowNum,2) 
                       action:= getSecondActionorDefalutAction(tmpSources[source_index]["action"])
                       exit()
                       callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                       break
                  }
            
            }else{
                 input=j
             }
          }
         
         if ErrorLevel = EndKey:m
           {
            if (GetKeyState("LControl", "P")=1){
                 selectedRowNum:= LV_GetNext(0)
                  if (selectedRowNum=0)
                  {
                  }else
                  {
                       LV_GetText(source_index, selectedRowNum,2) 
                       action:= getThirdActionorDefalutAction(tmpSources[source_index]["action"])
                       exit()
                       callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                       break
                  }
            
            }else{
                 input=m
             }
          }
          
          ;;send the first source to last 
         if ErrorLevel = EndKey:o
           {
            if (GetKeyState("LControl", "P")=1){
               tmpSources.insert(tmpSources.remove(1))
               matched_candidates:=refresh(tmpSources,search,win_width)
                     if matched_candidates.maxIndex()>0
                      {
                        LV_Modify(1, "Select Focus Vis") 
                      }

            }else{
                 input=o
             }
          }
          
          
         if ErrorLevel = EndKey:escape
         {
           exit()
           break
         }
         if ErrorLevel = EndKey:LControl
            {
               continue
            }
         if ErrorLevel = EndKey:n
           {
            if (GetKeyState("LControl", "P")=1){
               selectNextCandidate(matched_candidates.maxIndex())
              GuiControl,, Edit1, %search%
              Send {End} ;;move cursor end
            }else{
                 input=n
             }
          }
         if ErrorLevel = EndKey:Down
          {
               selectNextCandidate(matched_candidates.maxIndex())
          }
          if ErrorLevel = EndKey:Up
          {
               selectPreviousCandidate(matched_candidates.maxIndex())
          }
           if ErrorLevel = EndKey:p
           {
            if (GetKeyState("LControl", "P")=1){
              selectPreviousCandidate(matched_candidates.maxIndex())
              GuiControl,, Edit1, %search%
              Send {End} ;;move cursor end
             }else{
                 input=p
             }
      
         }
           if ErrorLevel = EndKey:g
           {
            if (GetKeyState("LControl", "P")=1){
              exit()
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
               matched_candidates:=refresh(tmpSources,search ,win_width)
               continue
           }else{
                input=u
            }
        }
;;        backspace
      if ErrorLevel = EndKey:backspace
        {
             if search <>
              {
              StringTrimRight, search, search, 1
              }
              GuiControl,, Edit1, %search%
              GuiControl,Focus,Edit1 ;; focus Edit1 ,
              Send {End} ;;move cursor end
              matched_candidates:=refresh(tmpSources,search,win_width)
              continue
        }

        if ErrorLevel = EndKey:h
        {
          if (GetKeyState("LControl", "P")=1){
             if search <>
              {
              StringTrimRight, search, search, 1
              }
              GuiControl,, Edit1, %search%
              GuiControl,Focus,Edit1 ;; focus Edit1 ,
              Send {End} ;;move cursor end
              refresh(tmpSources,search,win_width)
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
           if input<>
           {
            search = %search%%input%
            GuiControl,, Edit1, %search%
            GuiControl,Focus,Edit1 ;; focus Edit1 ,
            Send {End} ;;move cursor right ,make it after the new inputed char
           ;;TODO: REFRESH and select needed selected 
           matched_candidates:=refresh(tmpSources,search,win_width)
              if matched_candidates.maxIndex()>0
              {
                LV_Modify(1, "Select Focus Vis")
              }
              
         }
     } ;; end of loop
     exit()
} ;; end of anything function


;;when Anything lost focus 
anything_WM_ACTIVATE(wParam, lParam, msg, hwnd)
{
;;Tooltip, % wParam
  If ( wParam =0 and  A_Gui=1)
  {
    Send {esc}
  }
}
;;when lbutton is down ,
anything_WM_LBUTTONDOWN(wParam, lParam)
{
  MouseGetPos,,,,controlUnderMouse,
  if(controlUnderMouse="SysListView321")
  {
    send {Enter}
  }
}

refresh(sources,search,win_width){
     lv_delete()
     matched_candidates:=Object()
     for source_index ,source in sources {
          candidates:= source["tmpCandidate"]
          source_name:=source["name"]
          for candidate_index ,candidate in candidates{
               matched_candidates:=lv_add_candidate_if_match(candidate,source_index,candidate_index,search,source_name,matched_candidates)
          }
      }
     LV_ModifyCol(1,win_width*0.88)
     LV_ModifyCol(2,0)
     LV_ModifyCol(3,0)
     LV_ModifyCol(4,win_width*0.10)

return matched_candidates
}

;;candidate can be a string, when it is  a string ,it will be
;;displayed on the listview directly
;;and can be an array ,when it is an array
;;the array[1] will show on the listview ,and
;;array[2] will store something useful info.
;;and the param `candidate' will be passed to action
lv_add_candidate_if_match(candidate,source_index,candidate_index,search,source_name,matched_candidates){
  if isObject(candidate){ 
    display:=candidate[1]
  }else{
    display:=candidate
  }
   if % anything_match(display,search)=1
   {
      LV_Add("",display,source_index,candidate_index,source_name)
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
       selectedRowNum:= LV_GetNext(0)
       if(selectedRowNum< candidates_count){
          LV_Modify(selectedRowNum+1, "Select Focus Vis")
       }else{
          LV_Modify(1, "Select Focus Vis")
       }
}

selectPreviousCandidate(candidates_count){
            selectedRowNum:= LV_GetNext(0)
              if(selectedRowNum<2){
                 LV_Modify(candidates_count, "Select Focus Vis") 
              }else{
                 LV_Modify(selectedRowNum-1, "Select Focus Vis")
              }
}
exit(){
   OnMessage( 0x06, "" ) ;;disable 0x06 OnMessage
   OnMessage(0x201, "") ;;disable 0x201 onMessage ,when exit 
   Gui Destroy
}
callFuncByNameWithOneParam(funcName,param1){
   return %funcName%(param1)
}

callFuncByName(funcName){
   return   %funcName%()
}

getCandidatesArray(source)
{
    candidate:=source["candidate"]
   if isFunc(candidate)
   {
      candidates:= callFuncByName(candidate)
      return candidates
   }else
   {
      return candidate
   }
}
;; @param actionProperty : the value of source["action"]
;; the "action" property of a source can be a string  and an Array
;; ,when it is a string ,that means there is only one default action for this source
;; and when it is an Array the first element of this array will be treated as the default
;; action of this source .
;; you can press <ENTER> to execute the default action on  your selected a candidate.
;; and press Ctrl+j to execute the second action(if exists) when you have select a candidate .
;; when you selected a candidate ,you can press TAB to list all available "action" for
;; this candidate ,and select one of them to execute .
;; 
;;
getDefaultAction(actionProperty)
{
  if isObject(actionProperty)
  {
    return actionProperty[1]
  }else
  {
    return actionProperty
  }
}

;;if it has the second action then return it ,else 
;; return the default action 
getSecondActionorDefalutAction(actionProperty)
{
  if isObject(actionProperty)
  {
    if (actionProperty.maxIndex()>1)
    {
      Return actionProperty[2]
    }else{
      return actionProperty[1]
    }
 }else{
  return actionProperty
}
}
;;if it has the second action then return it ,else 
;; return the default action 
getThirdActionorDefalutAction(actionProperty)
{
  if isObject(actionProperty)
  {
    if (actionProperty.maxIndex()>2)
    {
      Return actionProperty[3]
    }else{
      return actionProperty[1]
    }
 }else{
  return actionProperty
}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
