;;; anything-window-switch.ahk -- switch window with anything.ahk support 

; source is hosted on
; https://github.com/jixiuf/my_autohotkey_scripts/tree/master/ahk_scripts
; and you can find the forum here
; http://www.autohotkey.com/forum/viewtopic.php?t=72833

;;how to use `anything-window-switch.ahk'
;1 
; if you only have one anything-source :
;         anything_window_switcher_source      (defined in this file )
; you can use it like this :
;
;     #include anything.ahk
;     #include anything-window-switch.ahk' 
;     f3::anything(anything_window_switcher_source)
; if you want automatically switch to a window when there is only 1 search
; result showing
; you can
;     #include anything.ahk
;     #include anything-window-switch.ahk'
;     anything_window_switcher_source["anything-execute-action-at-once-if-one"]:="yes"
;     f3::anything(anything_window_switcher_source)

;
; 2  if you also have other anything-sources ,
;     you just need add
;;        anything_window_switcher_source
;     to the sources
;    for example :
;
;    f3::
;    sources:=Array()
;    sources.insert(anything_window_switcher_source)
;    sources.insert(anything_favorite_directories_source)
;    sources.insert(anything_cmd_source)
;    anything_multiple_sources(sources)
;    return

DetectHiddenWindows, off
;;candidates         
anything_ws_icon_imageListId=
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
  if(candidates.maxIndex() >1)
  {
    candidates.insert(2, candidates.remove(1))
  }
  anything_ws_icon_imageListId := IL_Create(candidates.maxIndex())  
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
global
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

anything_window_switcher_source:=Object()
anything_window_switcher_source["candidate"]:="anything_ws_get_win_candidates"
anything_window_switcher_source["name"]:="Win"
anything_window_switcher_source["icon"]:="anything_ws_get_icon"
anything_window_switcher_source["action"]:=Array("anything_ws_visit", "anything_ws_close")
anything_window_switcher_source["anything-action-when-2-candidates"]:="anything_ws_visit_another_when_2_candidates"
