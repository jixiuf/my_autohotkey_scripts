
 anything_run_launch_candidates:=Array()

 anything_run_launch_get_candidates()
 {
     global anything_run_launch_candidates
     anything_run_launch_candidates:=Array()
     IniRead, default_scan_path, anything-run-launch_-plugin.ini, Settings, default_scan_path, %UserProfile%\Recent|%A_StartMenuCommon%|%A_StartMenu%|%A_Desktop%
     IniRead, accept_type_list, anything-run-launch_-plugin.ini, Settings, accept_type_list, exe|lnk|ahk|url|mp3|chm
     IniRead, exclude_filename_list,  anything-run-launch_-plugin.ini,Settings, exclude_filename_list, about|history|readme|remove|uninstall|license
     ;scan always updated list
     Loop, Parse, default_scan_path, |
     {
         Loop, %A_LoopField%\*.*, 0, 1
         {
             SplitPath, A_LoopFileFullPath, FName, FDir, FExt, FNameNoExt, FDrive
             ;only filetypes defined are added
             IfNotInString, accept_type_list, %FExt%, Continue

             ;excluding items based on exclude_filename_list
             Continue = 0
             Loop, Parse, exclude_filename_list, |
             {
                 IfInString, FName, %A_LoopField%
                 {
                     Continue = 1
                     Break
                 }
             }
             IfEqual, Continue, 1
             Continue

             ;reaching here means that file is not to be excluded and
             ;has a desired extension
             candidate := Array()
             candidate.Insert(A_LoopFileName ) ; display on anything listview
             candidate.Insert(A_LoopFileFullPath)                         ; the full path of file
             anything_run_launch_candidates.Insert(candidate)
         }
     }
     return anything_run_launch_candidates
 }

; the format of candidate is Array("filename[filepath]","filefullpath")
anything_run_launch(candidate)
{
  filefullpath:=candidate[2]
  Run,%filefullpath%, , UseErrorLevel,pid  ;  don't display dialog if it fails. and populate pid
 if ErrorLevel = ERROR
  {
      anything_MsgBox(" Failed")
  }
 else  ; add this filefullpath to anything-run candidates ,you can treat it as a recently candidates
 {
     if (IsFunc("anything_run_add_new_cmd")) ;  anything_run_add_new_cmd() defined in anything-run.ahk
     {
        anything_run_add_new_cmd(filefullpath)
        anything_run_write2disk()
     }
  }
  }
; when select a candidate ,show the full path of candidate on statusbar
anything_run_launch_on_select(candidate)
{
     ; anything_tooltip_header(candidate[2])
     anything_statusbar(candidate[2])     
}
; when load this file ,run anything_run_launch_get_candidates() to collect candidate 
anything_run_launch_get_candidates()
;;every 5 minute ,save history to disk
anything_SetTimerF("anything_run_launch_get_candidates",60000,Object()) ;create a timer 

 
anything_run_launch_source:=Object()
anything_run_launch_source["name"]:="Launch"
anything_run_launch_source["candidate"]:=  anything_run_launch_candidates
anything_run_launch_source["action"] := Array("anything_run_launch")
anything_run_launch_source["onselect"] := "anything_run_launch_on_select"
; anything_run_launch_source["icon"]:= "anything_run_get_icons"
anything_run_launch_source["anything-execute-action-at-once-if-one"] := "no"
anything_run_launch_source["anything-execute-action-at-once-if-one-even-no-keyword"] := "no"
