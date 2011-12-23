;;#include anything.ahk
SetWorkingDir %A_ScriptDir%
;;; anything-run.ahk , a replace of Win+r
;;if you only use this source ,you can bind it like this  
; f3::
;    anything(anything_cmd_source)
; return


cmd_history:=Array()
;;source for anything .
anything_cmd_source:=Object()
anything_cmd_source["name"]:="Run"
anything_cmd_source["candidate"]:= cmd_history
anything_cmd_source["action"] := Array("anything_run","anything_run_delete_from_history")
anything_cmd_source["anything-execute-action-at-once-if-one"] := "yes"
anything_cmd_source["anything-execute-action-at-once-if-one-even-no-keyword"] := "no"


;;init cmd_history from anything-run.ini 
IfExist,anything-run.ini
{
IniRead, history_line, anything-run.ini, main, cmd_history
Loop, Parse,  history_line,,
   {
     if A_LoopField <>
     {
       cmd_history.insert(A_LoopField)
     }
   }
}

;;the action function 
anything_run(candidate)
{
 Run,%candidate%, , UseErrorLevel  ;  don't display dialog if it fails.
 if ErrorLevel = ERROR
  {
    MsgBox Failed 
  }else{
    updateCmdHistory(candidate)
    writeCmdHistory2Disk()
  }
}

anything_run_delete_from_history(candidate)
{
  global cmd_history
  for key ,cmd in cmd_history
  {
    if (cmd = candidate)
    {
      cmd_history.remove(key)
      Break
    }
  }
  writeCmdHistory2Disk()
}


writeCmdHistory2Disk()
{
  global cmd_history
  cmd_text=
  for key ,cmd in cmd_history
  {
    cmd_text=%cmd_text%%cmd%
  }
  IniWrite,%cmd_text%,anything-run.ini, main, cmd_history
}

updateCmdHistory(newCmd)
{
  global cmd_history
  for key ,cmd in cmd_history
  {
    if (cmd = newCmd)
    {
      cmd_history.remove(key)
      Break
    }
  }
  cmd_history.insert(1,newCmd)
  if (directory_history.maxIndex()>150) ;;only record 50 cmd history items 
  {
    cmd_history.remove(51)
  }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;if you only use this source ,you can bind it like this  
; f3::
;    anything(anything_cmd_source)
; return

