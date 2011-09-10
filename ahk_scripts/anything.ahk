;; need AutoHotKey_L         
#SingleInstance force
#NoEnv
SetBatchLines, -1
SetKeyDelay  -1
SendMode Input
AutoTrim, off
;;;;;;;;;;;;;;;;;; 4 public functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; anything(anything-source)
;; anything_with_properties(anything-source,anything-properties)
;; anything_multiple_sources(anything-sources)
;; anything_multiple_sources_with_properties(anything-sources, anything-properties)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;global variable;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; anthing Window Id                                  
anything_wid=
anything_pattern=
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; * how to  write an anything-source;;;;;;;;;;;;;;;;;;;;;;;;
;;   an anything-source is an Object with some defined properties
;;   now it support 5 anything-source-properties :
;;   <name> <action> <candidate> and <icon><anything-execute-action-at-once-if-one>
;;   for example:
;;         my_source:=Object()
;; ** 1 <name>  (needed)
;;    <name> is a string ,it is just a name of this anything-source
;;         my_source["name"]:="my_source_name"
;;
;; ** 2 <candidate>  (needed)
;;    <candidate> is an array of available candidates ,or a function name(string)
;;    without parameter which return an array .
;;    each element of the array can be :
;; *** a string
;;     this string will be displayed on listview , so that you can select one
;;     of the candidates ,and execute action on your selected candidate.
;;    for example:
;;             my_candidates:=Array("red","green")
;;       or
;;             my_candidates_fun()
;;             {
;;                 return Array("red","green")
;;             }
;;             my_candiates:="my_candidates_fun"
;;              
;; *** a array
;;     the first element of this array must be a string ,the string will be
;;     displayed on listview ,and you can selected one of the candidates ,and
;;     execute action on your selected candidate.
;;     other element of this array can be anything , you can store useful info.
;;     there. and when you execute action on your selected candidate,this will
;;     be the parameter . see <action>
;;       for example:
;;             my_candidates:=Array(
;;                       Array("red","useful info ,string ,object or anything"),
;;                       Array("green","useful info ,string ,object or anything")
;;                       )
;;
;; ** 3 <action>  (needed)
;;    <action> is a function name(string) or a list of function name (array).
;;    and those functions must have one parameter. actually the parameter is
;;    the selected <candidate> .
;;          my_action:="my_action_fun"
;;                   my_action_fun(candidate)
;;                 {
;;                   MsgBox , %candidate%
;;                 }
;;       or
;;         my_action:=Array("my_action_fun","my_action_fun2")
;;                   my_action_fun(candidate)
;;                 {
;;                   MsgBox , %candidate%
;;                 }
;;                   my_action_fun2(candidate)
;;                 {
;;                   MsgBox , %candidate%
;;                 }
;;                    
;; ** 4 <icon> (optional)
;;     <icon> is a function(string) which return a ImageList.
;;     this property is optional .if this property isn't empty
;;     <Anything> will display icon before each candidates.
;;      icon_fun()
;;      {
;;          ImageListID := IL_Create(10)  ; Create an ImageList to hold 10 small icons.
;;          Loop 10  ; Load the ImageList with a series of icons from the DLL.
;;          IL_Add(ImageListID, "shell32.dll", A_Index)
;;          return ImageListID
;;      }
;;     my_icon :="icon_fun"

;; ** 5 <anything-execute-action-at-once-if-one> (optional)
;;     if it has value
;;   for example
           my_source["anything-execute-action-at-once-if-one"]:="yes"
;; then if only one candidate left on the listview it will execute the
;;     default action with the candidate  
;;
;; my_source["candidate"]:=my_candidates
;; my_source["action"]:=my_action
;; my_source["icon"]:=my_icon
;;
;; anything(my_source)

;;;;;;;;;;;;;;;;;;;;;;default anything-properties;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;don't change the default value here ,you can use 
;;         anything_with_properties(source,properties)
;; and
;;         anything_multiple_sources_with_properties(sources,properties)
;;
;; overwrite  properties defined here .
;;(just overwrite properties those you are interested in).
;; example:
;;     my_anything_properties:=Object()
;;     my_anything_properties["win_width"]:= 900
;;     anything_with_properties(my-anything-source ,my_anything_properties)

anything_default_properties:=Object()
;; the width and height  of Anything window
anything_default_properties["win_width"]:= 900
anything_default_properties["win_height"]:= 510

;; when Anything window lose focus ,close Anything window automatically.
anything_default_properties["quit_when_lose_focus"]:="yes"

;;the value is a function accpet one parameter ,when no matched candidates
;; the search string will be treated as candidate, 
;; and  this function will be treated as "action" 
anything_default_properties["no_candidate_action"]:="anything_do_nothing"


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
;;main function 
anything_multiple_sources_with_properties(sources,anything_properties){
global anything_default_properties
global anything_wid
global anything_pattern
;; copy all property from anything_default_properties to
;; anything_properties if  anything_properties doen't defined  

for key, default_value in anything_default_properties
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
   ;;;;when window lost focus ,function anything_WM_ACTIVATE()
   ;; will be executed
     OnMessage( 0x06, "anything_WM_ACTIVATE" ) 
   }
   ;; ;;when LButton(mouse) is down ,select use mouse
   ;;anything_WM_LBUTTONDOWN() will be called
   OnMessage(0x201, "anything_WM_LBUTTONDOWN") 
    Gui, Add, ListView, x0 y40 w%win_width% h%win_height% -VScroll -E0x200 AltSubmit -Hdr -HScroll -Multi  Count10 , candidates|source_index|candidate_index|source-name
     
     ;; search string you have typed 
     tabListActions:=""
     matched_candidates:=Object()
     tmpSources:=sources
     matched_candidates:=anything_refresh(tmpSources,anything_pattern,win_width)
     Gui ,Show,,
      ; if matched_candidates.maxIndex()>0
      ; {
      ;    LV_Modify(1, "Select Focus Vis") 
      ; }else{
      ; }

     WinGet, anything_wid, ID, A
     WinSet, AlwaysOnTop, On, ahk_id %anything_wid%
     loop,
     {
         anything_pattern_updated=
       Input, input, L1,{enter}{esc}{backspace}{up}{down}{pgup}{pgdn}{tab}{left}{right}{LControl}npguhjlzimyorv{LAlt}{tab}
       
       if ErrorLevel = EndKey:pgup
       {
         anything_pageUp(matched_candidates.maxIndex())
       }
        
       if ErrorLevel = EndKey:pgdn
       {
         anything_pageDown(matched_candidates.maxIndex())
       }
       ;;Ctrl-v =pageDn
       ;;Alt-v  == anything_pageUp
       if ErrorLevel = EndKey:v
       {
         if (GetKeyState("LControl", "P")=1){
           anything_pageDown(matched_candidates.maxIndex())
        }else if(GetKeyState("LAlt", "P")=1){
            anything_pageUp(matched_candidates.maxIndex())
         }Else{
           input=v
         }
       }
       ;;Ctrl-r  ==anything_pageUp
         if ErrorLevel = EndKey:r
           {
            if (GetKeyState("LControl", "P")=1){
              anything_pageUp(matched_candidates.maxIndex())
          }Else{
               input=r
             }
          }

         if ErrorLevel = EndKey:escape
         {
              if (tabListActions="yes")
            {
              tabListActions:=""
              tmpSources:=sources
                  anything_pattern := previous_anything_pattern
                  matched_candidates:=anything_refresh(tmpSources,anything_pattern,win_width)
                 LV_Modify(previousSelectedIndex, "Select Focus Vis") 
               }else
               {
                 anything_exit()
                 Break
               }
         }
         if ErrorLevel = EndKey:LControl
            {
               continue
            }
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
           
             if (tabListActions = "")
             {
             ;;list available actions for the
             ;;selected candidate . 
                 previousSelectedIndex := selectedRowNum 
                 tabListActions:="yes"
                 LV_GetText(source_index, selectedRowNum,2) ;;populate source_index
                 tmpSources:= anything_build_source_of_actions(tmpSources[source_index] , matched_candidates[selectedRowNum])
                 previous_anything_pattern:= anything_pattern
                 anything_pattern=
                 matched_candidates:=anything_refresh(tmpSources,anything_pattern,win_width)
                 if matched_candidates.maxIndex()>0
                 {
                    LV_Modify(1, "Select Focus Vis") 
                 }
              }else
              ;;reback from listed action 
              {
              tabListActions:=""
              tmpSources:=sources
                  anything_pattern := previous_anything_pattern
                  matched_candidates:=anything_refresh(tmpSources,anything_pattern,win_width)
                 LV_Modify(previousSelectedIndex, "Select Focus Vis") 
               }
       }
       
         if ErrorLevel = EndKey:enter
         {
            selectedRowNum:= LV_GetNext(0)
            LV_GetText(source_index, selectedRowNum,2) ;;populate source_index  
            action:= anything_get_default_action(tmpSources[source_index]["action"])
            if (GetKeyState("LAlt", "P")=1){ ;;LAlt+Enter 
                  anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
            }else
            {
               anything_exit()
               anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
               break
            }
         }
         
         if ErrorLevel = EndKey:z
           {
            if (GetKeyState("LControl", "P")=1){ ;;Ctrl+z
                  selectedRowNum:= LV_GetNext(0)
                  LV_GetText(source_index, selectedRowNum,2) ;;populate source_index  
                  action:= anything_get_default_action(tmpSources[source_index]["action"])
                  anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                 anything_pattern_updated=yes ;;
            }else{
                 input=z
            }
          }
         if ErrorLevel = EndKey:j
           {
            if (GetKeyState("LControl", "P")=1){ ;;Ctrl+j
                 selectedRowNum:= LV_GetNext(0)
                  LV_GetText(source_index, selectedRowNum,2) 
                  action:= anything_get_second_or_defalut_action(tmpSources[source_index]["action"])
                  anything_exit()
                  anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                  break
             }else if (GetKeyState("LAlt", "P")=1){ ;;Alt+j
                 selectedRowNum:= LV_GetNext(0)
                  LV_GetText(source_index, selectedRowNum,2) 
                  action:= anything_get_second_or_defalut_action(tmpSources[source_index]["action"])
                  anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                  anything_pattern_updated=yes
            }else{
                 input=j
            }
          }
         
         if ErrorLevel = EndKey:m
           {
            if (GetKeyState("LControl", "P")=1){ ;; Ctrl+m
                 selectedRowNum:= LV_GetNext(0) 
                       LV_GetText(source_index, selectedRowNum,2) 
                       action:= anything_get_third_or_defalut_action(tmpSources[source_index]["action"])
                       anything_exit()
                       anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                       break
               }else if (GetKeyState("LAlt", "P")=1) ;;Alt+m
               {
                    selectedRowNum:= LV_GetNext(0)
                    LV_GetText(source_index, selectedRowNum,2) 
                    action:= anything_get_third_or_defalut_action(tmpSources[source_index]["action"])
                    anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                    anything_pattern_updated=yes
               }Else{
               input=m
             }
          }
          
         if ErrorLevel = EndKey:l
           {
            if (GetKeyState("LControl", "P")=1){
                                build_no_candidates_source:="yes"
                    Gui, Color,483d8b,483d8b
                    tmpsources:= anything_build_source_4_no_candidates(sources , anything_pattern)
                           matched_candidates:=anything_refresh(tmpSources,"",win_width)
                           if matched_candidates.maxIndex()>0
                           {
                              LV_Modify(1, "Select Focus Vis") 
                           }
            }else{
                 input=l
            }
          }
         

         if ErrorLevel = EndKey:i
           {
            if (GetKeyState("LControl", "P")=1){
                   anything_exit()
                  anything_callFuncByNameWithOneParam(anything_properties["no_candidate_action"], anything_pattern)
                  break
            }else{
                 input=i
             }
          }
          
         if ErrorLevel = EndKey:n
           {
            if (GetKeyState("LControl", "P")=1){
               anything_selectNextCandidate(matched_candidates.maxIndex())
              GuiControl,, Edit1, %anything_pattern%
              Send {End} ;;move cursor end
            }else{
                 input=n
             }
          }
         if ErrorLevel = EndKey:Down
          {
               anything_selectNextCandidate(matched_candidates.maxIndex())
          }
          if ErrorLevel = EndKey:Up
          {
               anything_selectPreviousCandidate(matched_candidates.maxIndex())
          }
           if ErrorLevel = EndKey:p
           {
            if (GetKeyState("LControl", "P")=1){
              anything_selectPreviousCandidate(matched_candidates.maxIndex())
              GuiControl,, Edit1, %anything_pattern%
              Send {End} ;;move cursor end
             }else{
                 input=p
             }
      
         }
           if ErrorLevel = EndKey:g
           {
            if (GetKeyState("LControl", "P")=1){
              anything_exit()
              break
             }else{
                 input=g
             }
      
         }
        ;;Ctrl+u clear "anything_pattern" string ,just like bash
        if ErrorLevel = EndKey:u
        {
          if (GetKeyState("LControl", "P")=1){
               anything_pattern=
               anything_pattern_updated=yes
           }else{
                input=u
            }
        }
;;        backspace
      if ErrorLevel = EndKey:backspace
        {
             if anything_pattern <>
              {
              StringTrimRight, anything_pattern, anything_pattern, 1
              anything_pattern_updated=yes
            }
            
        }
 ;;Ctrl-y ,paste 
        if ErrorLevel = EndKey:y
        {
          if (GetKeyState("LControl", "P")=1){
              clipboard = %clipboard%
              input=%clipboard%
           }else{
                input=y
            }
        }
        if ErrorLevel = EndKey:h
        {
          if (GetKeyState("LControl", "P")=1){
             if anything_pattern <>
              {
              StringTrimRight, anything_pattern, anything_pattern, 1
              anything_pattern_updated=yes
              }
           }else{
                input=h
            }
        }
        ;;send the first source to last 
        if ErrorLevel = EndKey:o
           {
            if (GetKeyState("LControl", "P")=1){
               tmpSources.insert(tmpSources.remove(1))
               anything_pattern_updated=yes
            }else{
                 input=o
             }
          }

           if (input<>"" or  anything_pattern_updated="yes")
           {
             if (build_no_candidates_source="yes" and anything_pattern_updated="yes")
             {
               tmpSources := sources
               build_no_candidates_source:=""
               Gui, Color,black,black
             }
            anything_pattern = %anything_pattern%%input%
            GuiControl,, Edit1, %anything_pattern%
            GuiControl,Focus,Edit1 ;; focus Edit1 ,
            Send {End} ;;move cursor right ,make it after the new inputed char
            selectedRowNum:= LV_GetNext(0)
           ;;TODO: ANYTHING_REFRESH and select needed selected 
            matched_candidates:=anything_refresh(tmpSources,anything_pattern,win_width)
              if  matched_candidates.maxIndex() <1
              {
                    build_no_candidates_source:="yes"
                    Gui, Color,483d8b,483d8b
                    tmpsources:= anything_build_source_4_no_candidates(sources , anything_pattern)
                           matched_candidates:=anything_refresh(tmpSources,"",win_width)
              }
            }
            ;;if only one candidate left automatically execute it
            ;; if source["anything-execute-action-at-once-if-one"]="yes"
            if matched_candidates.maxIndex() = 1
            {
                   selectedRowNum:= LV_GetNext(0)
                  LV_GetText(source_index, selectedRowNum,2) ;;populate source_index  
              if (tmpSources[source_index]["anything-execute-action-at-once-if-one"]="yes")
              {
                  action:= anything_get_default_action(tmpSources[source_index]["action"])
                  anything_exit() ;;first quit .then execute action 
                  anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                  break
                }
              }

     } ;; end of loop
     anything_exit()
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

anything_refresh(sources,anything_pattern,win_width){
     selectedRowNum:= LV_GetNext(0)
     lv_delete()
     matched_candidates:=Object()
     anything_imagelist:= IL_Create()  
     icon_index=0
     for source_index ,source in sources {
         candidates:=  anything_get_candidates_as_array(source) 
         imagelist:=anything_get_imagelist(source)
          if imagelist
          {
            LV_SetImageList(anything_imagelist, 1)
            anything_imagelist_append(anything_imagelist, imagelist)
         }
          source_name:=source["name"]
          for candidate_index ,candidate in candidates{
             if imagelist
              {
                 icon_index += 1
                  matched_candidates:=anything_lv_add_candidate_if_match(candidate,source_index,candidate_index,anything_pattern,source_name,matched_candidates,anything_imagelist,icon_index )
               }else
               {
                  matched_candidates:=anything_lv_add_candidate_if_match(candidate,source_index,candidate_index,anything_pattern,source_name,matched_candidates,anything_imagelist,0)
               }
          }
      }
     LV_ModifyCol(1,win_width*0.88) ;;candidates 
     LV_ModifyCol(2,0) ;;source_index
     LV_ModifyCol(3,0) ;;candidate_index
     LV_ModifyCol(4,win_width*0.10) ;; source_name
     if (selectedRowNum = 0)
     {
       LV_Modify(1, "Select Focus Vis") 
     }else
     {
       if matched_candidates.maxIndex() >= selectedRowNum
       {
         LV_Modify(selectedRowNum, "Select Focus Vis")
       }
       else if matched_candidates.maxIndex() >= selectedRowNum-1
       {
         LV_Modify(selectedRowNum-1, "Select Focus Vis")
       }else if matched_candidates.maxIndex()>0
       {
         LV_Modify(1, "Select Focus Vis") 
       }else{
       }
       
     }


return matched_candidates
}

;;candidate can be a string, when it is  a string ,it will be
;;displayed on the listview directly
;;and can be an array ,when it is an array
;;the array[1] will show on the listview ,and
;;array[2] will store something useful info.
;;and the param `candidate' will be passed to action
anything_lv_add_candidate_if_match(candidate,source_index,candidate_index,anything_pattern,source_name,matched_candidates,imagelistId ,imagelist_index){
  if isObject(candidate){ 
    display:=candidate[1]
  }else{
    display:=candidate
  }
   if % anything_match(display,anything_pattern)=1
   {
     if imagelistId
     {
      LV_Add("Icon" . imagelist_index ,display,source_index,candidate_index,source_name)
     }else
     {
      LV_Add("Icon" . 0 ,display,source_index,candidate_index,source_name)
     }
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
anything_pageDown(candidates_count)
{
  selectedRowNum:= LV_GetNext(0)
  if (selectedRowNum= candidates_count){
        LV_Modify(1, "Select Focus Vis") 
  }else{
        ControlFocus, SysListView321,A
        Send {pgdn}
  }
}
anything_pageUp(candidates_count){
  selectedRowNum:= LV_GetNext(0)
  if (selectedRowNum=1){
        LV_Modify(candidates_count, "Select Focus Vis") 
  }else{
        ControlFocus, SysListView321,A
        Send {pgup}
  }
}
anything_selectNextCandidate(candidates_count){
       selectedRowNum:= LV_GetNext(0)
       if(selectedRowNum< candidates_count){
          LV_Modify(selectedRowNum+1, "Select Focus Vis")
       }else{
          LV_Modify(1, "Select Focus Vis")
       }
}

anything_selectPreviousCandidate(candidates_count){
            selectedRowNum:= LV_GetNext(0)
              if(selectedRowNum<2){
                 LV_Modify(candidates_count, "Select Focus Vis") 
              }else{
                 LV_Modify(selectedRowNum-1, "Select Focus Vis")
              }
}
anything_exit(){
   global anything_pattern
   anything_pattern=
   OnMessage( 0x06, "" ) ;;disable 0x06 OnMessage
   OnMessage(0x201, "") ;;disable 0x201 onMessage ,when anything_exit 
   Gui Destroy
}
anything_callFuncByNameWithOneParam(funcName,param1){
   return %funcName%(param1)
}

anything_callFuncByName(funcName){
   return   %funcName%()
}
anything_get_imagelist(source)
{
    icon:=source["icon"]
   if isFunc(icon)
   {
      icons:= anything_callFuncByName(icon)
      return icons
   }
}

anything_get_candidates_as_array(source)
{
    candidate:=source["candidate"]
   if isFunc(candidate)
   {
      candidates:= anything_callFuncByName(candidate)
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
anything_get_default_action(actionProperty)
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
anything_get_second_or_defalut_action(actionProperty)
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
anything_get_all_actions(actionProperty)
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
anything_get_third_or_defalut_action(actionProperty)
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
anything_build_source_of_actions(source,selected_candidate)
{
actionSources:=Array()
actionSource:=Array()
candidates :=Array()
for key ,action in anything_get_all_actions(source["action"])
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
;; is a function name ,and the "real" of candidate is the anything_pattern_string
;;so this function is used to display(real)
anything_execute_action_on_selected(candidate)
{
  functionName:=candidate[1]
  realCandidate:=candidate[2]
  anything_callFuncByNameWithOneParam(functionName, realCandidate)
}


anything_build_source_4_no_candidates(sources ,anything_pattern)
{
newSources:=Array()
 source:=Object()
 source["name"]:= "Actions"
 candidates:=Array()
 for key ,candidate in sources
 {
   for k,action in anything_get_all_actions(candidate["action"])
   {
   next:=Object()
   next.insert("call action :  "candidate["name"] . "." . action)
   next.insert(action)
   next.insert(anything_pattern)
   candidates.insert(next)
     
   }
 }
 source["candidate"]:=candidates
 source["action"] :="anything_execute_default_action_with_anything_pattern"
 newSources.insert(source)
 return newSources
}
anything_execute_default_action_with_anything_pattern(candidate)
{
  real_candidate :=candidate[3]
  real_action:=candidate[2]
  anything_callFuncByNameWithOneParam(real_action ,real_candidate)
}
;;this  is just a example
;;you can parse a property to anything  
;;anything_default_properties["no_candidate_action"]:="anything_do_nothing"
; anything_properties:=Object()
; anything_properties["no_candidate_action"]:="do_what_you_want_when_no_matched_candidates"
; f1::anything_multiple_sources_with_properties(sources,anything_properties)
 
anything_do_nothing(candidate)
{
  Msgbox , this would be called when you press C-i ,and you have typed in:  %candidate%
}

;; I find this function here .
;;http://www.autohotkey.com/forum/viewtopic.php?p=454619#454619
;;and thanks  maul.esel
anything_imagelist_append(il1, il2)
{
DllCall("LoadLibrary", "str", "Comctl32")

count1 := DllCall("Comctl32.dll\ImageList_GetImageCount", "uint", il1)
count2 := DllCall("Comctl32.dll\ImageList_GetImageCount", "uint", il2)
DllCall("Comctl32.dll\ImageList_SetImageCount", "uint", il1, "uint", count1 + count2)

Loop %count2%
   {
   hIcon := DllCall("Comctl32.dll\ImageList_GetIcon", "uint", il2, "int", A_Index - 1, "uint", 0)
   DllCall("Comctl32.dll\ImageList_ReplaceIcon", "uint", il1, "int", count1 + A_Index - 1, "uint", hIcon)
   DllCall("DestroyIcon", "UInt", hIcon)
   }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
