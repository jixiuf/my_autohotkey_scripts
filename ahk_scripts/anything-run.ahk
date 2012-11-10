;;; anything-run.ahk , a replace of Win+r
SetWorkingDir %A_ScriptDir%
;;; anything-run.ahk , a replace of Win+r
;;if you only use this source ,you can bind it like this
;;#include anything.ahk
;;#include anything-run.ahk
; f3::
;    anything(anything_run_source)
; return

 ; read cmd history from ini file
 anything_run_init()
{
    global anything_run_cmd_array
    ;;init anything_run_cmd_array from anything-run.ini
    IfExist,anything-run.ini
    {
        IniRead, history_line, anything-run.ini, main, anything_run_cmd_array
        Loop, Parse,  history_line,,
        {
            if A_LoopField <>
            {
                StringSplit, candidate_, A_LoopField ,
                anything_run_cmd_array.insert(Array(candidate_1,candidate_2,candidate_3)) ; display,cmd,cmd_fullpath
            }
        }
    }
}

;anything_get_file_name("c:\a.txt")==a.txt
;anything_get_file_name("a.txt")==a.txt
;anything_get_file_name("http://www.google.com")==http://www.google.com
anything_get_file_name(fullPath)
{
    if( RegExMatch(fullPath ,"(^https?://)|(^ftp://)"))
    {
        return fullPath
    }else if InStr(FileExist(fullPath), "D") ; if is a directory
    {
        return fullPath
    }
    ; else handle file name
    SplitPath, fullPath , OutFileName,
    return OutFileName
}
; get full path of a process by pid
; for example :return "c:\windows\system32\cmd.exe"
anything_run_get_process_full_path(p_id) {
   for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where ProcessId=" p_id)
      return process.ExecutablePath
}

anything_run_write2disk()
{
  global anything_run_cmd_array
  cmd_text:= ""
  for key ,cmd in anything_run_cmd_array
  {
      cmd_text:=cmd_text . "" . cmd[1] . "" . cmd[2] . "" . cmd[3]
  }
  IniWrite,%cmd_text%,anything-run.ini, main, anything_run_cmd_array
}

; this is a private method ,
; add a new cmd fullpath to anything_run_cmd_array
anything_run_add_new_cmd(new_cmd_candidate)
{
  global anything_run_cmd_array
  if(IsObject(new_cmd_candidate))
  {
      candidate := new_cmd_candidate
  }else
  {
      candidate := Array(new_cmd_candidate,new_cmd_candidate,new_cmd_candidate)
  }

  for key ,cmdFullPath in anything_run_cmd_array
  {
    if (cmdFullPath[2] == candidate[2])
    {
      anything_run_cmd_array.remove(key)
      Break
    }
  }
  anything_run_cmd_array.insert(1,candidate)
  if (directory_history.maxIndex()>150) ;;only record 50 cmd history items
  {
    anything_run_cmd_array.remove(151)
  }
}

; when select a candidate ,show the full path of candidate on statusbar
anything_run_on_select(candidate)
{
    if (IsObject(candidate))  ;  when format of candidate is Array("cmd","full-path-of-cmd")
    {
        fullpath_cmd := candidate[3] ;  use "full-path-of-cmd" as cmd
    }
    else ; when candidate is string
    {
        fullpath_cmd := candidate
    }
     anything_statusbar(fullpath_cmd)
}

; get_candidates fun
; the format of each candidate is Array("cmd","full-path-of-cmd")
; for example : Array("cmd.exe","c:\windows\system32\cmd.exe")
; anything_run_get_candidates()
; {
;     global anything_run_cmd_array
;     ; cmd_candidates:=Array()
;     ; for key ,cmd_no_display in anything_run_cmd_array
;     ; {
;     ;     ; anything_MsgBox(cmd_no_display[1])
;     ;     cmd_candidates.Insert(cmd_no_display[1],cmd_no_display)
;     ; }
;     return anything_run_cmd_array
; }
; get icon from cmd file
anything_run_get_icons()
{
    global anything_run_cmd_array
    global anything_properties
    icons:=IL_Create(5,5,anything_properties["anything_use_large_icon"])       ; init 5 icon ,incremnt by 5 each time,
    for key ,cmd_no_display in anything_run_cmd_array
    {
          anything_add_icon(cmd_no_display[3],icons,anything_properties["anything_use_large_icon"])
    }
    return icons
}

;;the default action function
; the format of candidate can be
; Array("cmd","full-path-of-cmd") or string
anything_run(candidate)
{
    if (IsObject(candidate))  ;  when format of candidate is Array("cmd","full-path-of-cmd")
    {
    cmd := candidate[2]
    }
    else ; when candidate is string
    {
    cmd := candidate
    }
  Run,%cmd%, , UseErrorLevel,pid  ;  don't display default dialog if it fails. and populate pid
 if ErrorLevel = ERROR
  {
      anything_MsgBox(" Failed")
  }else{
         if (pid == "")
         {
             anything_run_add_new_cmd(Array(cmd,cmd,cmd))
         }
         else
         {
             anything_run_add_new_cmd(Array(cmd,cmd,anything_run_get_process_full_path(pid)))
         }
         anything_run_write2disk()
  }
}
; delete selected cmd from candidates
; the format of candidates can be
; Array("cmd","full-path-of-cmd") or string
; for example : Array("cmd.exe","c:\windows\system32\cmd.exe")
anything_run_delete(candidate)
{
  global anything_run_cmd_array
    if (IsObject(candidate))  ;  when format of candidate is Array("display","cmd","full-path-of-cmd")
    {
        cmd := candidate[2]
    }
    else ; when candidate is string
    {
        cmd := candidate
    }
  for key ,cmd1 in anything_run_cmd_array
  {
    if (cmd1[2] == cmd)
    {
      anything_run_cmd_array.remove(key)
      Break
    }
  }
  anything_run_write2disk()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;anything_run_cmd_array is an array ,
; the format of each candidate is Array(display_string,cmd,cmd_fullpath)
; why I  use full path of each cmd :
; I can get icon from the full path of cmd file
; but for some special command ,
;        for example: msconfig
;  Run,%cmd%, , UseErrorLevel,pid  ;
; the value of pid is empty ,
; so I can't set get full path of it by anything_run_get_process_full_path(pid)
; then I store "msconfig" in config file
; so variable "anything_run_cmd_array" not all "fullpath"
anything_run_cmd_array:=Array()
anything_run_init()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;source for anything .
anything_run_source:=Object()
anything_run_source["name"]:="Run"
anything_run_source["candidate"]:= anything_run_cmd_array
anything_run_source["action"] := Array("anything_run","anything_run_delete")
anything_run_source["action_desc"] := Array("Run Cmd","Delete Item")
anything_run_source["onselect"] := "anything_run_on_select"
; anything_run_source["icon"]:= "anything_run_get_icons" ; ;I fount it make it slow  ,so comment it
anything_run_source["anything-execute-action-at-once-if-one"] := "no"
anything_run_source["anything-execute-action-at-once-if-one-even-no-keyword"] := "no"
