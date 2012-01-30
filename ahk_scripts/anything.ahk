;; need AutoHotKey_L
#SingleInstance force
; #NoEnv
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
;; you can use these global variable when you write your anything-source
;; anthing Window Id
;readonly
anything_wid=
;; the search you have typed in the search textbox
;readonly
anything_pattern=
 ; previous activated window id
;readonly
anything_previous_activated_win_id=

 ; read only ,don't use this global variable
 ; this is a privatge variable
previous_filtered_anything_pattern:=""
 ; record current anyting_properties
anything_properties :=Object()

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
anything_default_properties["Transparent"]:= 225
anything_default_properties["WindowColor"]:= "black"
anything_default_properties["ControlColor"]:= "black"
anything_default_properties["WindowColor_when_no_matched_candidate"]:= "483d8b"
anything_default_properties["ControlColor_when_no_matched_candidate"]:= "483d8b"
anything_default_properties["FontSize"]:= 12
anything_default_properties["FontColor"]:= "c7cfc00"
anything_default_properties["FontWeight"]:= "bold"  ;bold, italic, strike, underline, and norm
;; when Anything window lose focus ,close Anything window automatically.
anything_default_properties["quit_when_lose_focus"]:="yes"
anything_default_properties["anything_use_large_icon"]:=0 ;  0 for small icon ,1 for large icon

;;the value is a function accpet one parameter ,when no matched candidates
;; the search string will be treated as candidate,
;; and  this function will be treated as "action"
;  you need press Ctrl-i to call this function
;  I haven't use this function util now (2012-01-10 10:53)
anything_default_properties["no_candidate_action"]:="anything_do_nothing"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

anything(source)
{
   anything_with_properties(source,Array())
}

anything_with_properties(source ,anything_tmp_properties)
{
  sources:= Array()
  sources.insert(source)
  anything_multiple_sources_with_properties(sources ,anything_tmp_properties)
}

anything_multiple_sources(sources)
{
  anything_multiple_sources_with_properties(sources ,Array())
}
;;main function
anything_multiple_sources_with_properties(sources,anything_tmp_properties){
    global anything_default_properties
    global anything_wid
    global anything_pattern
    global anything_properties
    global previous_filtered_anything_pattern
    global anything_previous_activated_win_id


    ; store previous activated window id in  global variable
    WinGet, anything_previous_activated_win_id, ID, A
    ;; copy all property from anything_default_properties to
    ;; anything_properties if  anything_properties doen't defined

    for key, default_value in anything_default_properties
    {
        if (anything_tmp_properties[key]=="")
        {
            anything_properties[key]:=default_value ;
        }
        else
        {
            anything_properties[key]:=anything_tmp_properties[key] ;
        }
    }
    if((anything_properties["anything_use_large_icon"]=1) or (anything_properties["anything_use_large_icon"]="1") or (anything_properties["anything_use_large_icon"]="yes"))
    {
        anything_properties["anything_use_large_icon"] :=1
    }
    else
    {
        anything_properties["anything_use_large_icon"] :=0
    }
   win_width:=anything_properties["win_width"]
   win_height:=anything_properties["win_height"]
   Transparent:=anything_properties["Transparent"]
   WindowColor:=anything_properties["WindowColor"]
   ControlColor:=anything_properties["ControlColor"]
   WindowColor_when_no_matched_candidate :=anything_properties["WindowColor_when_no_matched_candidate"]
   ControlColor_when_no_matched_candidate:=anything_properties["ControlColor_when_no_matched_candidate"]
   FontSize:=anything_properties["FontSize"]
   FontColor:=anything_properties["FontColor"]
   FontWeight:=anything_properties["FontWeight"]
   quit_when_lose_focus :=anything_properties["quit_when_lose_focus"]
   StatusHeight := win_height+40 ; a status bar
   ListViewHeight:= win_height
   Gui,+LastFound +AlwaysOnTop -Caption ToolWindow
   WinSet, Transparent, %Transparent%
   Gui, Color,%WindowColor% , %ControlColor%
   Gui,Font,s%FontSize% %FontColor% %FontWeight%
   Gui, Add, Text,     x10  y10 w80 h30, Search`:
   Gui, Add, Edit,     x90 y5 w500 h30,
   Gui +OwnDialogs
   WinSetTitle, Anything.ahk

    Gui, Add, ListView, x0 y40 w%win_width% h%ListViewHeight% -VScroll -E0x200 Background%WindowColor% AltSubmit -Hdr -HScroll -Multi  Count10 , candidates|source_index|candidate_index|source-namee
    Gui, Add, Text,     x1  y%StatusHeight% Cwhite w%win_width% h20

     ;; search string you have typed
     tabListActions:=""
     matched_candidates:=Object()
     tmpSources:=sources
   matched_candidates:=anything_refresh(tmpSources,"",false)
     Gui ,Show,,
   ; ;;;;when window lost focus ,function anything_WM_ACTIVATE()
   ; ;; will be executed
    anything_set_property_4_quit_when_lose_focus(quit_when_lose_focus)
   ;; ;;when LButton(mouse) is down ,select use mouse
   ;;anything_WM_LBUTTONDOWN() will be called
    OnMessage(0x201, "anything_WM_LBUTTONDOWN")

     WinGet, anything_wid, ID, A
     WinSet, AlwaysOnTop, On, ahk_id %anything_wid%
       anything_on_select(tmpSources,matched_candidates) ;  on select event
     loop,
     {
       ;;if only one candidate left automatically execute it
       ;; if source["anything-execute-action-at-once-if-one"]="yes"
       if ( matched_candidates.maxIndex() == 1)
       {
           selectedRowNum:= LV_GetNext(0)
           LV_GetText(source_index, selectedRowNum,2) ;;populate source_index
           if (tmpSources[source_index]["anything-execute-action-at-once-if-one-even-no-keyword"]="yes")
           {
               action:= anything_get_default_action(tmpSources[source_index]["action"])
               anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
               anything_exit() ;;first quit .then execute action
               break
           }
       }

         if matched_candidates.maxIndex() = 2
         {
             selectedRowNum:= LV_GetNext(0)
             LV_GetText(source_index, selectedRowNum,2) ;;populate source_index
             ControlGetText,anything_pattern,Edit1
             if( anything_pattern=="" and  ( not (tmpSources[source_index]["anything-action-when-2-candidates-even-no-keyword"]="")))
             {
                 action:= tmpSources[source_index]["anything-action-when-2-candidates-even-no-keyword"]
                 candidate1 :=matched_candidates[selectedRowNum]
                 candidate2 :=matched_candidates[selectedRowNum+1]
                 anything_callFuncByNameWithTwoParam(action ,candidate1,candidate2)
                 anything_exit() ;;first quit .then execute action
                 break
             }
         }
       anything_pattern_updated=
       
       ; disable beeping ,when press some special key .(it's boring if don't disable it );
       ; for example when you press Ctrl-n ,       
       anything_beep(0)
       Input, input, L1 M T0.2 V,{enter}{esc}{backspace}{up}{down}{pgup}{pgdn}{tab}{left}{right}{LControl}knpgujlzimyoevw{LAlt}{tab}

       if ErrorLevel = EndKey:pgup
       {
         anything_pageUp(matched_candidates.maxIndex())
         GuiControl,Focus,Edit1 ;; focus Edit1 ,
         Send {End} ;;move cursor end
       }

       if ErrorLevel = EndKey:pgdn
       {
         anything_pageDown(matched_candidates.maxIndex())
        GuiControl,Focus,Edit1 ;; focus Edit1 ,
        Send {End} ;;move cursor end
       }
       ;;Ctrl-v =pageDn
       ;;Alt-v  == anything_pageUp
       if ErrorLevel = EndKey:v
       {
           if (GetKeyState("LControl", "P")=1){
               GuiControl,, Edit1, %anything_pattern%
               anything_pageDown(matched_candidates.maxIndex())
              GuiControl,Focus,Edit1 ;; focus Edit1 ,
              Send {End} ;;move cursor end
           }else if(GetKeyState("LAlt", "P")=1){
               ; GuiControl,, Edit1, %anything_pattern%
               anything_pageUp(matched_candidates.maxIndex())
              GuiControl,Focus,Edit1 ;; focus Edit1 ,
              Send {End} ;;move cursor end
           }Else{
               input=v
           }
       }
       ; ;;Ctrl-r  ==anything_pageUp
       ;   if ErrorLevel = EndKey:r
       ;     {
       ;      if (GetKeyState("LControl", "P")=1){
       ;        anything_pageUp(matched_candidates.maxIndex())
       ;    }Else{
       ;         input=r
       ;       }
       ;    }

         if ErrorLevel = EndKey:escape
         {
            ;   if (tabListActions="yes")
            ; {
            ;   tabListActions:=""
            ;   tmpSources:=sources
            ;   anything_pattern := previous_anything_pattern
            ;   matched_candidates:=anything_refresh(tmpSources,anything_pattern,true)
            ;      LV_Modify(previousSelectedIndex, "Select Focus Vis")
            ;    }else
            ;    {
                 anything_exit()
                 Break
               ; }
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

                  ControlGetText,previous_anything_pattern,Edit1
                 ; anything_pattern=
                 ; GuiControl,, Edit1, %anything_pattern%
                 ; set edit1 empty string
                 GuiControl,, Edit1,

                 matched_candidates:=anything_refresh(tmpSources,"",false)
                 ; if matched_candidates.maxIndex()>0
                 ; {
                 ;    LV_Modify(1, "Select Focus Vis")
                 ; }
              }else
              ;;reback from listed action
              {
              tabListActions:=""
              tmpSources:=sources

              ; GuiControl,, Edit1, %anything_pattern%;
              anything_pattern :=previous_anything_pattern
              GuiControl,, Edit1, %previous_anything_pattern%
              GuiControl,Focus,Edit1 ;; focus Edit1 ,
              Send {End} ;;move cursor end

              matched_candidates:=anything_refresh(tmpSources,previous_anything_pattern,true)
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
               anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
               anything_exit()
               break
            }
         }

         if ErrorLevel = EndKey:z
           {
            if (GetKeyState("LControl", "P")=1){ ;;Ctrl+z
                  ; GuiControl,, Edit1, %anything_pattern%
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
                  ; GuiControl,, Edit1, %anything_pattern%
                 selectedRowNum:= LV_GetNext(0)
                  LV_GetText(source_index, selectedRowNum,2)
                  action:= anything_get_second_or_defalut_action(tmpSources[source_index]["action"])
                  anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                  anything_exit()
                  break
             }else if (GetKeyState("LAlt", "P")=1){ ;;Alt+j
                  ; GuiControl,, Edit1, %anything_pattern%
                  selectedRowNum:= LV_GetNext(0)
                  LV_GetText(source_index, selectedRowNum,2)
                  action:= anything_get_second_or_defalut_action(tmpSources[source_index]["action"])
                  anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                  anything_pattern_updated=yes
            }else{
                 input=j
            }
          }
         if ErrorLevel = EndKey:k
           {
            if (GetKeyState("LControl", "P")=1){ ;; Ctrl+k
                  ; GuiControl,, Edit1, %anything_pattern%
                 selectedRowNum:= LV_GetNext(0)
                       LV_GetText(source_index, selectedRowNum,2)
                       action:= anything_get_forth_or_defalut_action(tmpSources[source_index]["action"])
                       anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                       anything_exit()
                       break
               }else if (GetKeyState("LAlt", "P")=1) ;;Alt+k
               {
                  ; GuiControl,, Edit1, %anything_pattern%
                    selectedRowNum:= LV_GetNext(0)
                    LV_GetText(source_index, selectedRowNum,2)
                    action:= anything_get_forth_or_defalut_action(tmpSources[source_index]["action"])
                    anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                    anything_pattern_updated=yes
               }Else{
               input=k
             }
          }
         if ErrorLevel = EndKey:e
           {
            if (GetKeyState("LControl", "P")=1){ ;; Ctrl+e
                  ; GuiControl,, Edit1, %anything_pattern%
                 selectedRowNum:= LV_GetNext(0)
                       LV_GetText(source_index, selectedRowNum,2)
                       action:= anything_get_fifth_or_defalut_action(tmpSources[source_index]["action"])
                       anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                       anything_exit()
                       break
               }else if (GetKeyState("LAlt", "P")=1) ;;Alt+e
               {
                  ; GuiControl,, Edit1, %anything_pattern%
                    selectedRowNum:= LV_GetNext(0)
                    LV_GetText(source_index, selectedRowNum,2)
                    action:= anything_get_fifth_or_defalut_action(tmpSources[source_index]["action"])
                    anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                    anything_pattern_updated=yes
               }Else{
               input=e
             }
          }


         if ErrorLevel = EndKey:m
           {
            if (GetKeyState("LControl", "P")=1){ ;; Ctrl+m
                  ; GuiControl,, Edit1, %anything_pattern%
                 selectedRowNum:= LV_GetNext(0)
                       LV_GetText(source_index, selectedRowNum,2)
                       action:= anything_get_third_or_defalut_action(tmpSources[source_index]["action"])
                       anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                       anything_exit()
                       break
               }else if (GetKeyState("LAlt", "P")=1) ;;Alt+m
               {
                  ; GuiControl,, Edit1, %anything_pattern%
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
                Gui, Color,%WindowColor_when_no_matched_candidate%,%ControlColor_when_no_matched_candidate%
                GuiControl, +Background%WindowColor_when_no_matched_candidate%, SysListView321

                ControlGetText,anything_pattern,Edit1
                tmpsources:= anything_build_source_4_no_candidates(sources , anything_pattern)

                matched_candidates:=anything_refresh(tmpSources,"",false)
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
                  ; GuiControl,, Edit1, %anything_pattern%
                  ControlGetText,anything_pattern,Edit1
                  anything_callFuncByNameWithOneParam(anything_properties["no_candidate_action"], anything_pattern)
                   anything_exit()
                  break
            }else{
                 input=i
             }
          }

         if ErrorLevel = EndKey:n
           {
            if (GetKeyState("LControl", "P")=1){
                anything_selectNextCandidate(matched_candidates.maxIndex())
                ; GuiControl,, Edit1, %anything_pattern%
                ; GuiControl,Focus,Edit1 ;; focus Edit1 ,
                ; Send {End} ;;move cursor end
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
                 GuiControl,Focus,Edit1 ;; focus Edit1 ,
                 Send {End} ;;move cursor end
          }
           if ErrorLevel = EndKey:p
           {
            if (GetKeyState("LControl", "P")=1){
              anything_selectPreviousCandidate(matched_candidates.maxIndex())
              ; GuiControl,, Edit1, %anything_pattern%
              ; GuiControl,Focus,Edit1 ;; focus Edit1 ,
              ; Send {End} ;;move cursor end
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
;
       ; Ctrl-w ,copy
        if ErrorLevel = EndKey:w
       {
           if (GetKeyState("LControl", "P")=1){
                  ; GuiControl,, Edit1, %anything_pattern%
               selectedRowNum:= LV_GetNext(0)
               LV_GetText(source_index, selectedRowNum,2)
               anything_callFuncByNameWithOneParam("anything_copy_selected_candidate_as_string" ,matched_candidates[selectedRowNum])
               anything_exit()
               break
           }
           else if (GetKeyState("LAlt", "P")=1) ;;Alt+w
            {
                  ; GuiControl,, Edit1, %anything_pattern%
                selectedRowNum:= LV_GetNext(0)
                LV_GetText(source_index, selectedRowNum,2)
                anything_callFuncByNameWithOneParam("anything_copy_selected_candidate_as_string" ,matched_candidates[selectedRowNum])
           }else
            {
                    input=w
             }
            }
        ;;Ctrl+u clear "anything_pattern" string ,just like bash
        if ErrorLevel = EndKey:u
        {
          if (GetKeyState("LControl", "P")=1){
               anything_pattern:=""
               GuiControl,, Edit1,
               anything_pattern_updated=yes
           }else{
                input=u
            }
        }
;;        backspace
      if ErrorLevel = EndKey:backspace
        {
            ControlGetText,anything_pattern,Edit1
             if anything_pattern <>
              {
                   ControlGetText,anything_pattern,Edit1
                  ; StringTrimRight, anything_pattern, anything_pattern, 1
                  ; GuiControl,, Edit1, %anything_pattern%
                  anything_pattern_updated=yes
              }

        }
 ;;Ctrl-y ,paste
        if ErrorLevel = EndKey:y
        {
          if (GetKeyState("LControl", "P")=1){
              ControlGetText,anything_pattern,Edit1
              clipboard = %clipboard%
              input=%clipboard%
              GuiControl,, Edit1, %anything_pattern%%input%
                GuiControl,Focus,Edit1 ;; focus Edit1 ,
                Send {End} ;;move cursor end
              
           }else{
                input=y
            }
        }
        ; if ErrorLevel = EndKey:h
        ; {
        ;   if (GetKeyState("LControl", "P")=1){
        ;       ; ControlGetText,anything_pattern,Edit1
        ;       ; if anything_pattern <>
        ;       ; {
        ;       ;     StringTrimRight, anything_pattern, anything_pattern, 1
        ;       ;     GuiControl,, Edit1, %anything_pattern%
        ;       ;     anything_pattern_updated=yes
        ;       ; }
        ;   }else{
        ;       input=h
        ;   }
        ; }
        ;;send the first source to last
        if ErrorLevel = EndKey:o
           {
            if (GetKeyState("LControl", "P")=1){
                  ; GuiControl,, Edit1, %anything_pattern%
               tmpSources.insert(tmpSources.remove(1))
               anything_pattern_updated=yes
            }else{
                 input=o
             }
          }
       if ErrorLevel = Timeout
       {
           ControlGetText,pattern,Edit1
           if ((previous_filtered_anything_pattern = pattern))
           {
               anything_pattern_updated:="no"
           }else
           {
               anything_pattern_updated:="yes"
           }
       }
       
       if (build_no_candidates_source="yes" and anything_pattern_updated="yes")
       {
       tmpSources := sources
       build_no_candidates_source:=""
       Gui, Color,WindowColor,ControlColor
       GuiControl, +Background%WindowColor%, SysListView321
       }
       

           if (input<>"" or  anything_pattern_updated="yes")
           {
               anything_pattern_updated:="no"
               if (build_no_candidates_source="yes" and anything_pattern_updated="yes")
               {
                   tmpSources := sources
                   build_no_candidates_source:=""
                   Gui, Color,WindowColor,ControlColor
                   GuiControl, +Background%WindowColor%, SysListView321
               }
             ; ControlGetText,pattern,Edit1
             ; GuiControl,, Edit1, %pattern%%input%
               ControlGetText,anything_pattern,Edit1

               GuiControl,Focus,Edit1 ;; focus Edit1 ,
               ; Send {End} ;;move cursor right ,make it after the new inputed char
            selectedRowNum:= LV_GetNext(0)
           ;;TODO: ANYTHING_REFRESH and select needed selected
             matched_candidates:=anything_refresh(tmpSources,anything_pattern,true)
              if  matched_candidates.maxIndex() <1
              {
                    build_no_candidates_source:="yes"
                    Gui, Color,%WindowColor_when_no_matched_candidate%,%ControlColor_when_no_matched_candidate%
                    GuiControl, +Background%WindowColor_when_no_matched_candidate%, SysListView321
                    tmpsources:= anything_build_source_4_no_candidates(sources , anything_pattern)
                    matched_candidates:=anything_refresh(tmpSources,"",false)
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
                  anything_callFuncByNameWithOneParam(action ,matched_candidates[selectedRowNum])
                  anything_exit() ;;first quit .then execute action
                  break
                }
              }
       anything_on_select(tmpSources,matched_candidates) ;  on select event
     } ;; end of loop
     anything_exit()
     anything_beep(1)           ;enable beep

} ;; end of anything function

; if state =0 ,disable beep
; if state =1 enable beep
anything_beep(state =0)
{
    ; state=1
    SPI_SETBEEP := 0x2
    DllCall( "SystemParametersInfo", UInt,SPI_SETBEEP, UInt,state, UInt,0, UInt,0 )
}

; OnMessage( 0x06, "anything_WM_ACTIVATE" )
;;when Anything lost focus
; anything_WM_ACTIVATE() will be called
anything_WM_ACTIVATE(wParam, lParam, msg, hwnd)
{
;;Tooltip, % wParam
  If ( wParam =0 and  A_Gui=1)
  {
    Send {esc}
  }
}
;OnMessage(0x201, "anything_WM_LBUTTONDOWN")
;;when lbutton is down ,
; anything_WM_LBUTTONDOWN(w,l) will be called
; so that you can use mouse click on anything window
; though this is not recommended
anything_WM_LBUTTONDOWN(wParam, lParam)
{
  MouseGetPos,,,,controlUnderMouse,
  if(controlUnderMouse="SysListView321")
  {
    send {Enter}
  }
}

;;;anything_pattern will be displayed on Search Textbox
;;; and pattern is used to filter
;; some times when you press Tab or press C-l
;; it will list <Actions> as candidates for you to select
;; then pattern is used to filter <Actions>
;; and anything_pattern will be displayed on Search Textbox always
; @param use_default ,when is true , pattern is ignored
; and the text in textfield are treat as pattern to filter
;  if false , pattern is used 
anything_refresh(sources,pattern,use_default){
     global anything_pattern
     global previous_filtered_anything_pattern
     global anything_properties
     if (use_default=true)
     {
         ControlGetText,pattern,Edit1
         previous_filtered_anything_pattern := pattern
     }
     win_width :=anything_properties["win_width"]
     selectedRowNum:= LV_GetNext(0)
     lv_delete()
     matched_candidates:=Object()
     if(anything_properties["anything_use_large_icon"]=1)
     {
         anything_imagelist:= IL_Create(5,5, true)
     }else
     {
         anything_imagelist:= IL_Create(5,5)
     }
     icon_index=0
     for source_index ,source in sources {
         candidates:=  anything_get_candidates_as_array(source)
         imagelist:=anything_get_imagelist(source)
          if imagelist
          {
              if  (anything_properties["anything_use_large_icon"]=1)
              {
                  LV_SetImageList(anything_imagelist, 1)
              }else
              {
                  LV_SetImageList(anything_imagelist)
              }
            anything_imagelist_append(anything_imagelist, imagelist)
         }
          source_name:=source["name"]
        match_function:= source["match"]
        if(match_function==""){
            match_function:= "anything_match" ; default use anything_match(P1,P2) to match
        }
         for candidate_index ,candidate in candidates{
             if imagelist
              {
                 icon_index += 1
                 matched_candidates:=anything_lv_add_candidate_if_match(match_function,candidate,source_index,candidate_index,pattern,source_name,matched_candidates,anything_imagelist,icon_index )
               }else
               {
                   matched_candidates:=anything_lv_add_candidate_if_match(match_function,candidate,source_index,candidate_index,pattern,source_name,matched_candidates,anything_imagelist,0)
               }
          }
      }
     LV_ModifyCol(1,win_width*0.88) ;;candidates
     LV_ModifyCol(2,0) ;;source_index hidden
     LV_ModifyCol(3,0) ;;candidate_index hidden
     LV_ModifyCol(4, win_width*0.10) ;; source_name width
     LV_ModifyCol(4, "Right") ;; source_name align Right

     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ; ;these line is a bug fix for fast finger ,when you type so fast that
     ; ;,Input() cann't catch what you have typed ,then the TextField catch it
     ; ;but "anything" doesn't treat this char as part of anything_pattern,
     ; ;it will be erased when you type next char if without these lines.
     ; ;these line ,keep the lost char ,and append it to anything_pattern.
     ; ;those this time it can't be used to filter ,but next time it can .
     ; ; but it still not fix very well .
     ; ControlGetText,text,Edit1
     ; AppendedText := ""
     ; if (( InStr(text,anything_pattern)==1) and (StrLen(text) <> StrLen(anything_pattern)) ) ;text starts with anything_pattern
     ; {
     ; AppendedText := SubStr(text,StrLen(anything_pattern)+1)
     ; }
     ; anything_pattern = %anything_pattern%%AppendedText%%input%
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

     ; GuiControl,, Edit1, %anything_pattern%
     GuiControl,Focus,Edit1 ;; focus Edit1 ,
     ; Send {End} ;;move cursor right ,make it after the new inputed char

     if (selectedRowNum = 0)
     {
       LV_Modify(1, "Select Focus Vis") ;  select ,focus and make selected row visiable
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
anything_lv_add_candidate_if_match(match_function,candidate,source_index,candidate_index,anything_pattern,source_name,matched_candidates,imagelistId ,imagelist_index){
  if isObject(candidate){
    display:=candidate[1]
  }else{
    display:=candidate
  }
  if % anything_callFuncByNameWithTwoParam(match_function, candidate,anything_pattern)==1
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
; this function is the default match function for anything-source
; to filter matched candidates
; you can custom  anything-source with anything-source-properties
; [match]
; for example :
; my_anything_source["match"]:= "my_match_fun"
; my_match_fun(candidate,pattern){} ,return 1  if match,or 0
; then my_anything_source will use  my_match_fun to filter
anything_match(candidate,pattern){
    if isObject(candidate){
        candidate_string:=candidate[1]
                   }else{
        candidate_string:=candidate
        }
    result:= 1
    if not (pattern== "")
           {
               StringCaseSense ,Off
               Loop,parse,pattern ,%A_Space%,%A_Space%%A_TAB%
               {
                   if candidate_string not contains %A_LoopField%,
                   {
                       result :=0
                   }
               }
           }
    return result
    }
; same to function anything_match ,but this is case_sensetive
; you must take care ,if you write your own case sensetive match
; function .
; because anything.ahk default use non case sensitive everywhere
; so when the function is finished
; you must run
;               StringCaseSense ,off
; at the end of your match function
anything_match_case_sensetive(candidate,pattern){
    if isObject(candidate){
        candidate_string:=candidate[1]
                   }else{
        candidate_string:=candidate
        }
    result:= 1
    if not (pattern== "")
           {
               StringCaseSense ,On
               Loop,parse,pattern ,%A_Space%,%A_Space%%A_TAB%
               {
                   if candidate_string not contains %A_LoopField%,
                   {
                       result :=0
                   }
               }
               StringCaseSense ,Off
           }
    return result
    }

anything_pageDown(candidates_count)
{
  selectedRowNum:= LV_GetNext(0)
  if (selectedRowNum= candidates_count){
        LV_Modify(1, "Select Focus Vis")
  }else{
         ControlFocus, SysListView321,A
        Send {pgdn}
        
        ; GuiControl,Focus,Edit1 ;; focus Edit1 ,
        ; Send {End} ;;move cursor end
        ;  I don't know why ,if delete this line(sleep) , anything_on_select(tmpSources,matched_candidates) ;  on select event
        sleep ,1
  }
}
anything_pageUp(candidates_count){
  selectedRowNum:= LV_GetNext(0)
  if (selectedRowNum=1){
        LV_Modify(candidates_count, "Select Focus Vis")
  }else{
        ControlFocus, SysListView321,A
        Send {pgup}
        ;  I don't know why ,if delete this line(sleep) , anything_on_select(tmpSources,matched_candidates) ;  on select event
        sleep ,1
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
   global previous_filtered_anything_pattern
   global anything_pattern
   anything_pattern:=""
   previous_filtered_anything_pattern:=""
   OnMessage( 0x06, "" ) ;;disable 0x06 OnMessage
   OnMessage(0x201, "") ;;disable 0x201 onMessage ,when anything_exit
   ToolTip,                ;  clear tooltip
   Gui Destroy
}
anything_callFuncByNameWithOneParam(funcName,param1){
   return %funcName%(param1)
}
anything_callFuncByNameWithTwoParam(funcName,param1,param2){
    return %funcName%(param1,param2)
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
;;if it has the third action then return it ,else
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

;;if it has the forth action then return it ,else
;; return the default action
anything_get_forth_or_defalut_action(actionProperty)
{
  if isObject(actionProperty)
  {
    if (actionProperty.maxIndex()>3)
    {
      Return actionProperty[4]
    }else{
      return actionProperty[1]
    }
 }else{
  return actionProperty
}
}
;;if it has the fifth action then return it ,else
;; return the default action
anything_get_fifth_or_defalut_action(actionProperty)
{
  if isObject(actionProperty)
  {
    if (actionProperty.maxIndex()>4)
    {
      Return actionProperty[5]
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
actionSource["name"]:="Action"
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
  global
  old_value_of_quit_when_lose_focus=anything_properties["quit_when_lose_focus"]
  anything_set_property_4_quit_when_lose_focus("no")
  ;write  your code here ...
  Msgbox , this would be called when you press C-i ,and you have typed in:  %candidate%
  anything_set_property_4_quit_when_lose_focus(old_value_of_quit_when_lose_focus=anything_properties)

}

; this is an global action
; default bind to C-w and M-w ,means copy selected candidate to Clipboard
anything_copy_selected_candidate_as_string(candidate)
{
    if isObject(candidate)
    {
        candidate_string:=candidate[1]
        }
    else
    {
        candidate_string:=candidate
        }
    Clipboard := candidate_string
}

; set or get value of anything_properties["quit_when_lose_focus"]
anything_set_property_4_quit_when_lose_focus(value) ; "yes" or "no"
{
    if(value  == "yes")
    {
        anything_properties["quit_when_lose_focus"]:="yes"
        ;;;;when window lost focus ,function anything_WM_ACTIVATE()
        ;; will be executed
        OnMessage( 0x06, "anything_WM_ACTIVATE" )
    }else {
        anything_properties["quit_when_lose_focus"]:="no"
        OnMessage( 0x06, "" )
    }
}

;; I find this function here .
;;http://www.autohotkey.com/forum/viewtopic.php?p=454619#454619
;;and thanks  maul.esel
; append an ImageList to another
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

; when call MsgBox () ,the Message Box steal the focus from anything
; then anything quit .,and the Message Box is the child window of anything
; so it quit too ,you can't see the Message Box finally
; so you can use this function for test
anything_MsgBox(Msg)
{
  global
  old_value_of_quit_when_lose_focus=anything_properties["quit_when_lose_focus"]
  anything_set_property_4_quit_when_lose_focus("no")
  ;write  your code here ...
  Msgbox % Msg
  anything_set_property_4_quit_when_lose_focus(old_value_of_quit_when_lose_focus=anything_properties)

}
; show a tooltip ,at header of current window
anything_tooltip_header(Text)
{
    global anything_wid
    Tooltip , %Text% ,0,-20
}

anything_tooltip_tail(Text)
{
    global anything_wid
    WinGetPos ,,,,window_height
    Tooltip , %Text% ,0,%window_height%
}
; change the Content of statusbar on anything window window
anything_statusbar(Text)
{
    GuiControl ,Text,Static2,%Text%
}

anything_on_select(tmpSources,matched_candidates)
{
    selectedRowNum:= LV_GetNext(0)
    LV_GetText(source_index, selectedRowNum,2) ;;populate source_index
    if ( not (tmpSources[source_index]["onselect"]==""))
    {
        onselectfun := tmpSources[source_index]["onselect"]
        anything_callFuncByNameWithOneParam(onselectfun,matched_candidates[selectedRowNum])
    }
    else
    {
        ToolTip,                ;  clear tooltip
        anything_statusbar("")  ; set the statusbar content empty
    }


}


/*
 ; http://www.autohotkey.com/forum/viewtopic.php?t=64123
 ; EXAMPLE:
 ; anything_SetTimerF("func",2000,Object(1,1),10) ;create a higher priority timer
 ; anything_SetTimerF("func2",1000,Object(1,2)) ;another timer with low priority
 ; Return
 ; func(p){
 ;    MsgBox % "Timer number: " p
 ; }
 ; func2(p){
 ;    MsgBox % "Timer number: " p
 ; }
 ; anything_SetTimerF:
 ;    An attempt at replicating the entire SetTimer functionality
 ;       for functions. Includes one-time and recurring timers.

 ;    Thanks to SKAN for initial code and conceptual research.
 ;    Modified by infogulch and HotKeyIt to copy SetTimer features

 ; On User Call:
 ;    returns: true if success or false if failure
 ;    Function: Function name
 ;    Period: Delay (int)(0 to stop timer, positive to start, negative to run once)
 ;    ParmObject: (optional) Object of params to pass to function
 ;    dwTime: (used internally)

 ; On Timer: (user)
 ;    ParmObject is expanded into params for the called function
 ;    ErrorLevel is set to the TickCount

 ; On Timer: (internal)
 ;    Function: HWND (unused)
 ;    Period: uMsg (unused)
 ;    ParmObject: idEvent (timer id) used internally
 ;       ( as per http://msdn.microsoft.com/en-us/library/ms644907 )
 ;    dwTime: dwTime (tick count) Set ErrorLevel to this before user's function call
*/
anything_SetTimerF( Function, Period=0, ParmObject=0, Priority=0 ) {
 Static current,tmrs:=Object() ;current will hold timer that is currently running
 If IsFunc( Function ) {
    if IsObject(tmr:=tmrs[Function]) ;destroy timer before creating a new one
       ret := DllCall( "KillTimer", UInt,0, UInt, tmr.tmr)
       , DllCall("GlobalFree", UInt, tmr.CBA)
       , tmrs.Remove(Function)
    if (Period = 0 || Period ? "off")
       return ret ;Return as we want to turn off timer
    ; create object that will hold information for timer, it will be passed trough A_EventInfo when Timer is launched
    tmr:=tmrs[Function]:=Object("func",Function,"Period",Period="on" ? 250 : Period,"Priority",Priority
                        ,"OneTime",(Period<0),"params",IsObject(ParmObject)?ParmObject:Object()
                        ,"Tick",A_TickCount)
    tmr.CBA := RegisterCallback(A_ThisFunc,"F",4,&tmr)
    return !!(tmr.tmr  := DllCall("SetTimer", UInt,0, UInt,0, UInt
                        , (Period && Period!="On") ? Abs(Period) : (Period := 250)
                        , UInt,tmr.CBA)) ;Create Timer and return true if a timer was created
            , tmr.Tick:=A_TickCount
 }
 tmr := Object(A_EventInfo) ;A_Event holds object which contains timer information
 if IsObject(tmr) {
    DllCall("KillTimer", UInt,0, UInt,tmr.tmr) ;deactivate timer so it does not run again while we are processing the function
    If (!tmr.active && tmr.Priority<(current.priority ? current.priority : 0)) ;Timer with higher priority is already current so return
       Return (tmr.tmr:=DllCall("SetTimer", UInt,0, UInt,0, UInt, 100, UInt,tmr.CBA)) ;call timer again asap
    current:=tmr
    tmr.tick:=ErrorLevel :=Priority ;update tick to launch function on time
    tmr.func(tmr.params*) ;call function
    current= ;reset timer
    if (tmr.OneTime) ;One time timer, deactivate and delete it
       return DllCall("GlobalFree", UInt,tmr.CBA)
             ,tmrs.Remove(tmr.func)
    tmr.tmr:= DllCall("SetTimer", UInt,0, UInt,0, UInt ;reset timer
            ,((A_TickCount-tmr.Tick) > tmr.Period) ? 0 : (tmr.Period-(A_TickCount-tmr.Tick)), UInt,tmr.CBA)
 }
}

 ; add the icon of File to ImageList ,
 ; @param Large_Icon can be "yes"/1/,
 ; FileType can be lnk,exe,ico ,and so on
 ; if File doesn't exist ,use a generic icon instead
anything_add_icon(File ,ImageList,Large_Icon)
{
    if (FileExist(File)=="") ; file doesn't exists
    {
        IL_Add(ImageList, "shell32.dll" , 3) ; 	; use a generic icon
    }
    else
    {
        ptr := A_PtrSize = 8 ? "ptr" : "uint"
        sfi_size := A_PtrSize + 8 + (A_IsUnicode ? 680 : 340)
        if !sfi_size   ;for AHK Basic
        sfi_size := 340
        VarSetCapacity(sfi, sfi_size)
        if( (Large_Icon="yes") or (Large_Icon=1 )or (Large_Icon=="1"))
        {
            DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "str", File, "uint", 0, "str", sfi, "uint", sfi_size, "uint", 0x100)  ; 0x100 is SHGFI_ICON+SHGFI_LARGEICON
        }
        else
        {
            DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "str", File, "uint", 0, "str", sfi, "uint", sfi_size, "uint", 0x101)  ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
        }
        hIcon := NumGet(sfi, 0)
        DllCall("ImageList_ReplaceIcon", UInt, ImageList, Int, -1, UInt, hicon)
        ; DllCall("ImageList_ReplaceIcon", "ptr", ImageList, "int", -1, "ptr", hIcon)
        DllCall("DestroyIcon", ptr, hicon)
    }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
