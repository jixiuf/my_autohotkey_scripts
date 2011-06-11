;; need AutoHotKey_L         
#SingleInstance force
SetBatchLines, -1
SetKeyDelay  -1
AutoTrim, off

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
default_anything_properties:=Object()
;;the width of Anything window
default_anything_properties["win_width"]:= 900
default_anything_properties["win_height"]:= 510
default_anything_properties["quit_when_lose_focus"]:="yes"

;;the value is a function accpet one parameter ,when no matched candidates
;; the search string will be treated as candidate, 
;; and  this function will be treated as "action" 
default_anything_properties["no_candidate_action"]:="anything_do_nothing"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

anything(source)
{
   anything_with_properties(source,Array())
}

anything_with_properties(source ,anything_properties)
{
  sources:= Array()
  sources.insert(source)
  anything_multiple_sources_with_properties(sources ,anything_properties)
}

anything_multiple_sources(sources)
{
  anything_multiple_sources_with_properties(sources ,Array())
}

anything_multiple_sources_with_properties(sources,anything_properties){
global default_anything_properties

for key, default_value in default_anything_properties
{
  if (anything_properties[key]="")
  {
     anything_properties[key]:=default_value
  }
}
   win_width:=anything_properties["win_width"]
   win_height:=anything_properties["win_height"]
   Gui,+LastFound +AlwaysOnTop -Caption ToolWindow   
   WinSet, Transparent, 225
   Gui, Color,black,black
   Gui,Font,s12 c7cfc00 bold
   Gui, Add, Text,     x10  y10 w80 h30, Search`:
   Gui, Add, Edit,     x90 y5 w500 h30,
   if(anything_properties["quit_when_lose_focus"] = "yes")
   {
     OnMessage( 0x06, "anything_WM_ACTIVATE" ) ;;when window lost focus 
   }
   OnMessage(0x201, "anything_WM_LBUTTONDOWN") ;;when LButton(mouse) is down 
   icon:=source["icon"]
     if icon<>
     {
        Gui, Add, ListView, x0 y40 w%win_width% h%win_height% -VScroll -E0x200 AltSubmit -Hdr -HScroll -Multi  Count10 , icon|candidates|source_index|candidate_index|source-name
        ImageListID1 := IL_Create(candidates_count,1,1)
        LV_SetImageList(ImageListID1, 1)
     }else{
        Gui, Add, ListView, x0 y40 w%win_width% h%win_height% -VScroll -E0x200 AltSubmit -Hdr -HScroll -Multi  Count10 , candidates|source_index|candidate_index|source-name
     }
     
     
     candidates_count=0
     search=
     tabListActions:=""
     matched_candidates:=Object()
     tmpSources:=sources
     for key ,source in tmpSources {
       candidate:=source["candidate"]
       source["tmpCandidate"]:= getCandidatesArray(source)
       candidates_count += % source["tmpCandidate"].maxIndex()
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
       Input, input, L1,{enter}{esc}{backspace}{up}{down}{pgup}{pgdn}{tab}{left}{right}{LControl}npguhjimo{LAlt}{tab}
       
       ;;list all avaiable actions for the selected candidate 
       ;; usual one source only have one action ,
       ;; but some times user can give more than one action.
       ;; <Enter> execute the default action .
       ;; <Ctrl-j> execute the second action .(if only one,it execute the default action)
       ;; <Ctrl-m> execute the third action .(if less than three ,it execute the default action)
       ;;and <tab> list all available actions ,user can select it and execute it .
       if ErrorLevel = EndKey:tab
       {
           selectedRowNum:= LV_GetNext(0)
          if(selectedRowNum=0) ;;no matched candidates 
          {
               exit()
               callFuncByNameWithOneParam(anything_properties["no_candidate_action"], search)
              break
          }else{
             if (tabListActions = "")
             {
                tabListActions="yes"
                 LV_GetText(source_index, selectedRowNum,2) ;;populate source_index
                 tmpSources:= buildSourceofActions(tmpSources[source_index] , matched_candidates[selectedRowNum])
                 for key ,source in tmpSources {
                   candidate:=source["candidate"]
                   source["tmpCandidate"]:= getCandidatesArray(source)
                   candidates_count += % source["tmpCandidate"].maxIndex()
                 }
                 matched_candidates:=refresh(tmpSources,"",win_width)
                if matched_candidates.maxIndex()>0
                {
                   LV_Modify(1, "Select Focus Vis") 
                }else{
                }
             }
         }
       }
         if ErrorLevel = EndKey:enter
         {
            selectedRowNum:= LV_GetNext(0)
          if(selectedRowNum=0) ;;no matched candidates 
          {
              exit()
              callFuncByNameWithOneParam(anything_properties["no_candidate_action"], search)
              break
            ;;if no matched candidates ,then the string you typed in the textfield will
            ;;be treated as the candidate ,and the actions can  be executed on this
            ;;candidate is the collection of each source's  DefaultAction 
              
          }else{
            LV_GetText(source_index, selectedRowNum,2) ;;populate source_index  
            action:= getDefaultAction(tmpSources[source_index]["action"])
            exit()
            callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
            break
          }
            break
         }
         
         if ErrorLevel = EndKey:j
           {
            if (GetKeyState("LControl", "P")=1){
                 selectedRowNum:= LV_GetNext(0)
                  if (selectedRowNum=0)
                  {
                    exit()
                    callFuncByNameWithOneParam(anything_properties["no_candidate_action"], search)
                    break
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
                    exit()
                   callFuncByNameWithOneParam(anything_properties["no_candidate_action"], search)
                   break
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
          

         if ErrorLevel = EndKey:i
           {
            if (GetKeyState("LControl", "P")=1){
                   exit()
                  callFuncByNameWithOneParam(anything_properties["no_candidate_action"], search)
                  break
            }else{
                 input=i
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
     LV_ModifyCol(1,win_width*0.88) ;;candidates 
     LV_ModifyCol(2,0) ;;source_index
     LV_ModifyCol(3,0) ;;candidate_index
     LV_ModifyCol(4,win_width*0.10) ;; source_name 

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
getAllActions(actionProperty)
{
  if isObject(actionProperty)
  {
     return actionProperty
   }else{
     actions:=Array()
     actions.insert(actionProperty)
     return actions
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

;;this function will be used list all available "action"s
;; for selected_candidate 
;; so that you can selected one of the "actions" and execute it .
;; so source["action"] will be used as newSource["candidate"]
;; and the new "action" for newSource is"anything_execute_action_on_selected"
;;
buildSourceofActions(source,selected_candidate)
{
actionSources:=Array()
actionSource:=Array()
candidates :=Array()
for key ,action in getAllActions(source["action"])
{   
   next:=Array()
   next.insert(action)
   next.insert(selected_candidate)
   candidates.insert(next)
}
actionSource["candidate"]:=candidates
actionSource["action"]:="anything_execute_action_on_selected"
actionSource["name"]:="Actions"
actionSources.insert(actionSource)
return actionSources
}

;;this is a inner "action" ,and the candidate is special
;;the "display" of candidate (the first element of this candidate)
;; is a function name ,and the "real" of candidate is the search_string
;;so this function is used to display(real)
anything_execute_action_on_selected(candidate)
{
  functionName:=candidate[1]
  realCandidate:=candidate[2]
  callFuncByNameWithOneParam(functionName, realCandidate)
}
;;this  is just a example 
anything_do_nothing(candidate)
{
   Tooltip % candidate
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
