 anything_run_launch_get_candidates()
 {
     global anything_run_launch_candidates
     anything_run_launch_candidates:=Array()
     IniRead, default_scan_path_recursively, anything-run-launch-plugin.ini, Settings, default_scan_path_recursively,%A_StartMenuCommon%|%A_StartMenu%
     IniRead, default_scan_path_none_recursively, anything-run-launch-plugin.ini, Settings, default_scan_path_none_recursively,%A_Desktop%|%A_DesktopCommon%
     IniRead, accept_type_list, anything-run-launch-plugin.ini, Settings, accept_type_list, exe|lnk|ahk|url|chm
     IniRead, exclude_filename_list,  anything-run-launch-plugin.ini,Settings, exclude_filename_list, about|history|readme|remove|uninstall|license
     ;scan always updated list
     Loop, Parse, default_scan_path_recursively, |
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
             if(FExt = "lnk"){
                 FileGetShortcut, %A_LoopFileFullPath% ,LnkTarget
                 SplitPath,LnkTarget, FName
                 Display:= parentDirName .  "/" . A_LoopFileName . " " . FName
             }else{
                 Display:= A_ parentDirName .  "/" . A_LoopFileName
             }
             ;reaching here means that file is not to be excluded and
             ;has a desired extension
             candidate := Array()
             SplitPath, A_LoopFileDir,parentDirName
             candidate.Insert(Display ) ; display on anything listview
             candidate.Insert(A_LoopFileFullPath)                         ; the full path of file
             anything_run_launch_candidates.Insert(candidate)
         }
     }
     Loop, Parse, default_scan_path_none_recursively, |
     {
         Loop, %A_LoopField%\*.*, 0, 0
         {
             SplitPath, A_LoopFileFullPath, FName, FDir, FExt, FNameNoExt, FDrive
             ;only filetypes defined are added
             IfNotInString, accept_type_list, %FExt%, Continue
             if (A_LoopFileFullPath )
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
             if(FExt = "lnk"){
                 FileGetShortcut, %A_LoopFileFullPath% ,LnkTarget
                 SplitPath,LnkTarget, FName
                 Display:= parentDirName .  "/" . A_LoopFileName . " " . FName
             }else{
                 Display:= A_ parentDirName .  "/" . A_LoopFileName
             }
             ;reaching here means that file is not to be excluded and
             ;has a desired extension
             candidate := Array()
             SplitPath, A_LoopFileDir,parentDirName
             candidate.Insert(Display ) ; display on anything listview
             candidate.Insert(A_LoopFileFullPath)                         ; the full path of file
             anything_run_launch_candidates.Insert(candidate)
         }
     }

     IniWrite, %default_scan_path_recursively%, anything-run-launch-plugin.ini, Settings, default_scan_path_recursively
     IniWrite, %default_scan_path_none_recursively%, anything-run-launch-plugin.ini, Settings, default_scan_path_none_recursively
     IniWrite, %accept_type_list%, anything-run-launch-plugin.ini, Settings, accept_type_list
     IniWrite, %exclude_filename_list%,  anything-run-launch-plugin.ini,Settings, exclude_filename_list

     ; anything_run_launch_get_icons_fun()
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
         anything_run_add_new_cmd(Array(candidate[1],filefullpath,filefullpath))
        anything_run_write2disk()
     }
  }
  }
; ; ; get icon from cmd file
; anything_run_launch_get_icons_fun()
; {
;      global anything_properties
;      global anything_run_launch_icons
;      global anything_run_launch_candidates
;      IL_Destroy(anything_run_launch_icons)
;      anything_run_launch_icons:= IL_Create(30,50,anything_properties["anything_use_large_icon"])       ; init 5 icon ,incremnt by 10
;     for key ,candidate in anything_run_launch_candidates
;     {
;         cmd_full_path :=  candidate[2]
;         anything_add_icon(cmd_full_path,anything_run_launch_icons,anything_properties["anything_use_large_icon"])
;     }
; }
; anything_run_launch_get_icons()
; {
;      global anything_run_launch_icons
;      return anything_run_launch_icons
; }
; when select a candidate ,show the full path of candidate on statusbar
anything_run_launch_on_select(candidate)
{
    if (IsObject(candidate))  ;  when format of candidate is Array("cmd","full-path-of-cmd")
    {
        fullpath_cmd := candidate[2]         ;  use "full-path-of-cmd" as cmd
    }
    else ; when candidate is string
    {
        fullpath_cmd := candidate
    }
     anything_statusbar(fullpath_cmd)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; format of candidate is  Array("display","cmd")
 anything_run_launch_candidates:=Array()
 ; anything_run_launch_icons:=IL_Create(1,10)       ; init 5 icon ,

; when load this file ,run anything_run_launch_get_candidates() to collect candidate
anything_run_launch_get_candidates()
;;every 5 minute ,collect candidates
anything_SetTimerF("anything_run_launch_get_candidates",60000,Object()) ;create a timer


anything_run_launch_source:=Object()
anything_run_launch_source["name"]:="Launch"
anything_run_launch_source["candidate"]:=  anything_run_launch_candidates
anything_run_launch_source["action"] := Array("anything_run_launch")
anything_run_launch_source["onselect"] := "anything_run_launch_on_select"
; anything_run_launch_source["icon"]:= "anything_run_launch_get_icons"  ;I fount it make it slow  ,so comment it
anything_run_launch_source["anything-execute-action-at-once-if-one"] := "no"
anything_run_launch_source["anything-execute-action-at-once-if-one-even-no-keyword"] := "no"
