;;; anything-window-switch.ahk -- switch window with anything.ahk support 

; source is hosted on
; https://github.com/jixiuf/my_autohotkey_scripts/tree/master/ahk_scripts
; and you can find the forum here
; http://www.autohotkey.com/forum/viewtopic.php?t=72833

;;how to use `anything-window-switch.ahk'
;#include anything.ahk
;#include anything-window-switch.ahk' 
; !Tab::
; my_anything_properties:=Object()
; my_anything_properties["win_width"]:= 900
; my_anything_properties["win_height"]:= 180

; sources:=Array()
; sources.insert(anything_window_switcher_with_assign_keys_source)
; sources.insert(anything_window_switcher_source)
; anything_multiple_sources_with_properties(sources,my_anything_properties)
; return


DetectHiddenWindows, off
;;candidates         
anything_ws_icon_imageListId =
anything_ws_icon_imageListId_4_assign_keys =
anything_ws_get_win_candidates()
{
  global anything_ws_icon_imageListId
  global anything_wid
  candidates :=Array()
  WinGet, id, list, , , Program Manager
  Loop, %id%
  {
    candidate:=Array()
    StringTrimRight, this_id, id%a_index%, 0
    WinGetTitle, title, ahk_id %this_id%
    
    ; FIXME: windows with empty titles?
     if title =
       continue
       
     if anything_wid and anything_wid = this_id
     {
       continue
     }
    
    ; don't add the switcher window
    ; if switcher_id = %this_id%
    ;   continue
      display:= anything_ws_get_processname(this_id) . " _ " . title
      candidate.insert(display)
      candidate.insert(this_id)
      candidates.insert(candidate)
  }
  if(candidates.MaxIndex() >1)
  {
    candidates.insert(2, candidates.remove(1))
  }
  anything_ws_icon_imageListId := IL_Create(candidates.MaxIndex())  
  for key,candidate in candidates
  {
   this_id:= candidate[2]
   anything_add_window_icon_2_imageList(this_id,0,anything_ws_icon_imageListId)
  }
  return candidates 
}

;;default action : visit selected window
anything_ws_visit(candidate)
{
  win_id:=candidate[2]
         WinGet,wstatus,MinMax,ahk_id %win_id%
        if (wstatus=-1)
        { ;;minimized 
          WinRestore ,ahk_id %window_id%
        }
  WinActivate ,ahk_id  %win_id%
}
;  when only windows left ,then visit another window automatical without press <Enter>
; candidate1 is current activate window
; candidate2 is another window 
anything_ws_visit_another_when_2_candidates(candidate1,candidate2)
{
  win_id:=candidate1[2]
         WinGet,wstatus,MinMax,ahk_id %win_id%
        if (wstatus=-1)
        { ;;minimized 
          WinRestore ,ahk_id %window_id%
        }
  WinActivate ,ahk_id  %win_id%
}
; close selected window
anything_ws_close(candidate)
{
  win_id:=candidate[2]
  WinClose ,ahk_id  %win_id%
}

; (window id, whether to get large icons,ImageListId where to store icon)
anything_add_window_icon_2_imageList(wid, Use_Large_Icons_Current,ImageListId) 
{
  Local NR_temp, h_icon
  ; check status of window - if window is responding or "Not Responding"
  NR_temp =0 ; init
  h_icon =
  Responding := DllCall("SendMessageTimeout", "UInt", wid, "UInt", 0x0, "Int", 0, "Int", 0, "UInt", 0x2, "UInt", 150, "UInt *", NR_temp) ; 150 = timeout in millisecs
  If (Responding)
    {
    ; WM_GETICON values -    ICON_SMALL =0,   ICON_BIG =1,   ICON_SMALL2 =2
    If Use_Large_Icons_Current =1
      {
      SendMessage, 0x7F, 1, 0,, ahk_id %wid%
      h_icon := ErrorLevel
      }
    If ( ! h_icon )
      {
      SendMessage, 0x7F, 2, 0,, ahk_id %wid%
      h_icon := ErrorLevel
        If ( ! h_icon )
          {
          SendMessage, 0x7F, 0, 0,, ahk_id %wid%
          h_icon := ErrorLevel
          If ( ! h_icon )
            {
            If Use_Large_Icons_Current =1
              h_icon := DllCall( "GetClassLong", "uint", wid, "int", -14 ) ; GCL_HICON is -14
            If ( ! h_icon )
              {
              h_icon := DllCall( "GetClassLong", "uint", wid, "int", -34 ) ; GCL_HICONSM is -34
              If ( ! h_icon )
                h_icon := DllCall( "LoadIcon", "uint", 0, "uint", 32512 ) ; IDI_APPLICATION is 32512
              }
            }
          }
        }
      }
  If ! ( h_icon = "" or h_icon = "FAIL") ; Add the HICON directly to the icon list
  	 DllCall("ImageList_ReplaceIcon", UInt, ImageListId, Int, -1, UInt, h_icon)
  Else	; use a generic icon
  	 IL_Add(ImageListId, "shell32.dll" , 3)
}

anything_ws_get_icon()
{
    global anything_ws_icon_imageListId
    return anything_ws_icon_imageListId
}
anything_ws_get_processname(wid){
       ; show process name if enabled
           WinGet, procname, ProcessName, ahk_id %wid%
           stringgetpos, pos, procname, .
           if ErrorLevel <> 1
           {
               stringleft, procname, procname, %pos%
           }
           stringupper, procname, procname
    return procname
}

 
anything_window_switcher_with_assign_keys_candidates:=Object()
 
 ; assign a short key (text) for the selected window ,so that you can visit this window
 ;  with the short key(text).
; ;I am now interested in using your tool to switch between windows using
;  keywords that I could define and assign dynamically. For example, imagine I
;  have Chrome open in one window, and Emacs in another window. I would like to
;  assign keywords to these windows (e.g. Chrome -> Browser, Emacs-> Editor),
;  and then use your tool to switch between them by typing Editor or Browser
;  (with the powerful autocomplete feature your tool already has).
anything_ws_assign_key(candidate)
{
    global 
    old_value_of_quit_when_lose_focus=anything_properties["quit_when_lose_focus"] 
    anything_set_property_4_quit_when_lose_focus("no")    
    InputBox,assigned_key, Assigned Keys, Please enter your Assigned Keys for current window., , 320, 120
    if ErrorLevel
    {
        ;  CANCEL was pressed.
    }
    else
    {
        win_id:=candidate[2]
        new_candidate:=Array()
        new_candidate.Insert(assigned_key)
        new_candidate.Insert(win_id) ;  new candidate with (assignedkey,win_id) as candidate element
        anything_window_switcher_with_assign_keys_candidates.insert(new_candidate)  
    }
    anything_set_property_4_quit_when_lose_focus(old_value_of_quit_when_lose_focus)
}

anything_window_switcher_get_icon_4assign_keys()
{
  global  anything_ws_icon_imageListId_4_assign_keys 
  return  anything_ws_icon_imageListId_4_assign_keys 
}

; delete dead window from candidates ,and return it .
 anything_window_switcher_with_assign_keys_candidates_fun()
 {
     global
    old_value_of_quit_when_lose_focus=anything_properties["quit_when_lose_focus"] 
    anything_set_property_4_quit_when_lose_focus("no")    
     for candidate_index ,candidate in  anything_window_switcher_with_assign_keys_candidates {
         win_id:=candidate[2]
         if not WinExist("ahk_id " . win_id)
         {
              anything_window_switcher_with_assign_keys_candidates.Remove(candidate_index) ; if window doesn't exists anymore ,delete the assigned key (candidate)
         }
     }
     ; update icon 
     anything_ws_icon_imageListId_4_assign_keys := IL_Create(anything_window_switcher_with_assign_keys_candidates.MaxIndex())
     for candidate_index ,candidate in  anything_window_switcher_with_assign_keys_candidates {
         win_id:=candidate[2]
         if WinExist("ahk_id " . win_id)
         { 
             anything_add_window_icon_2_imageList(win_id,0,anything_ws_icon_imageListId_4_assign_keys)
         }
     }
     
  return anything_window_switcher_with_assign_keys_candidates
     
 }

anything_window_switcher_with_assign_keys_source:=Object()
anything_window_switcher_with_assign_keys_source["candidate"]:="anything_window_switcher_with_assign_keys_candidates_fun"
anything_window_switcher_with_assign_keys_source["name"]:="WinKey"
 anything_window_switcher_with_assign_keys_source["icon"]:="anything_window_switcher_get_icon_4assign_keys"
anything_window_switcher_with_assign_keys_source["action"]:="anything_ws_visit"
anything_window_switcher_with_assign_keys_source["anything-execute-action-at-once-if-one"]:="yes"
anything_window_switcher_with_assign_keys_source["anything-execute-action-at-once-if-one-even-no-keyword"]:="yes"
 


anything_window_switcher_source:=Object()
anything_window_switcher_source["candidate"]:="anything_ws_get_win_candidates"
anything_window_switcher_source["name"]:="Win"
anything_window_switcher_source["icon"]:="anything_ws_get_icon"
anything_window_switcher_source["anything-action-when-2-candidates-even-no-keyword"]:="anything_ws_visit_another_when_2_candidates"
anything_window_switcher_source["anything-execute-action-at-once-if-one"]:="yes"
anything_window_switcher_source["anything-execute-action-at-once-if-one-even-no-keyword"]:="yes"
anything_window_switcher_source["action"]:=Array("anything_ws_visit", "anything_ws_close" ,"anything_ws_assign_key")
