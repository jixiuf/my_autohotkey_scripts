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

;DetectHiddenWindows, off
;;candidates         
anything_ws_get_win_candidates()
{
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
  return candidates 
}
;;default action : visit selected window
anything_ws_visit(candidate)
{
  win_id:=candidate[2]
  WinActivate ,ahk_id  %win_id%
}
anything_ws_close(candidate)
{
  win_id:=candidate[2]
  WinClose ,ahk_id  %win_id%
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
anything_window_switcher_source["action"]:=Array("anything_ws_visit", "anything_ws_close")

