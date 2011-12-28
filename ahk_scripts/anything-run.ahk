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
    global anything_run_cmd_fullpath_array
    ;;init anything_run_cmd_fullpath_array from anything-run.ini 
    IfExist,anything-run.ini
    {
        IniRead, history_line, anything-run.ini, main, anything_run_cmd_fullpath_array
        Loop, Parse,  history_line,,
        {
            if A_LoopField <>
            {
                anything_run_cmd_fullpath_array.insert(A_LoopField)
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
  global anything_run_cmd_fullpath_array
  cmd_text=
  for key ,cmd in anything_run_cmd_fullpath_array
  {
    cmd_text=%cmd_text%%cmd%
  }
  IniWrite,%cmd_text%,anything-run.ini, main, anything_run_cmd_fullpath_array
}

; this is a private method ,
; add a new cmd fullpath to anything_run_cmd_fullpath_array
anything_run_add_new_cmd(new_cmd_fullPath)
{
  global anything_run_cmd_fullpath_array
  for key ,cmdFullPath in anything_run_cmd_fullpath_array
  {
    if (cmdFullPath == new_cmd_fullPath)
    {
      anything_run_cmd_fullpath_array.remove(key)
      Break
    }
  }
  anything_run_cmd_fullpath_array.insert(1,new_cmd_fullPath)
  if (directory_history.maxIndex()>150) ;;only record 50 cmd history items 
  {
    anything_run_cmd_fullpath_array.remove(151)
  }
}

 
; get_candidates fun
; the format of each candidate is Array("cmd","full-path-of-cmd")
; for example : Array("cmd.exe","c:\windows\system32\cmd.exe")
anything_run_get_candidates()
{
    global anything_run_cmd_fullpath_array
    cmd_candidates:=Array()
    for key ,cmd_full_path in anything_run_cmd_fullpath_array
    {
        cmd_candidates.Insert(Array(anything_get_file_name(cmd_full_path),cmd_full_path))
    }
    return cmd_candidates
}
; get icon from cmd file 
anything_run_get_icons()
{
    global anything_run_cmd_fullpath_array
    global anything_properties
    icons:=IL_Create(5,5,anything_properties["anything_use_large_icon"])       ; init 5 icon ,incremnt by 5 each time, 
    for key ,cmd_full_path in anything_run_cmd_fullpath_array
    {
        If FileExist(cmd_full_path)
        {
          ; IL_Add(icons,cmd_full_path)
          anything_add_icon(cmd_full_path,icons)
        }
        else
        {
        IL_Add(icons, "shell32.dll" , 3) ; 	; use a generic icon
        }
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
    cmd := candidate[2]         ;  use "full-path-of-cmd" as cmd 
    }
    else ; when candidate is string 
    {
    cmd := candidate
    }
  Run,%cmd%, , UseErrorLevel,pid  ;  don't display dialog if it fails. and populate pid 
 if ErrorLevel = ERROR
  {
      anything_MsgBox(" Failed") 
  }else{
    if (pid == "")
    {
        anything_run_add_new_cmd(cmd)     
    }
     else 
    {
        anything_run_add_new_cmd(anything_run_get_process_full_path(pid))     
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
  global anything_run_cmd_fullpath_array
    if (IsObject(candidate))  ;  when format of candidate is Array("cmd","full-path-of-cmd")
    {
        fullpath_cmd := candidate[2]         ;  use "full-path-of-cmd" as cmd 
    }
    else ; when candidate is string 
    {
        fullpath_cmd := candidate
    }
  for key ,cmd in anything_run_cmd_fullpath_array
  {
    if (cmd == fullpath_cmd)
    {
      anything_run_cmd_fullpath_array.remove(key)
      Break
    }
  }
  anything_run_write2disk()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;anything_run_cmd_fullpath_array is an array ,
; its element is the full path of each cmd
; for example ,if you run "cmd" ,then c:\windows\system32\cmd.exe
; will be added to this array
; why I  use full path of each cmd :
; I can get icon from the full path of cmd file
; but for some special command ,
;        for example: msconfig
;  Run,%cmd%, , UseErrorLevel,pid  ;   
; the value of pid is empty ,
; so I can't set get full path of it by anything_run_get_process_full_path(pid)
; then I store "msconfig" in config file
; so variable "anything_run_cmd_fullpath_array" not all "fullpath"  
anything_run_cmd_fullpath_array:=Array()
anything_run_init()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;source for anything .
anything_run_source:=Object()
anything_run_source["name"]:="Run"
anything_run_source["candidate"]:= "anything_run_get_candidates"
anything_run_source["action"] := Array("anything_run","anything_run_delete")
anything_run_source["icon"]:= "anything_run_get_icons"
anything_run_source["anything-execute-action-at-once-if-one"] := "no"
anything_run_source["anything-execute-action-at-once-if-one-even-no-keyword"] := "no"
 
 anything_add_icon(File ,ImageList)
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
        DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "str", File, "uint", 0, "str", sfi, "uint", sfi_size, "uint", 0x101)  ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
        hIcon := NumGet(sfi, 0)
        DllCall("ImageList_ReplaceIcon", UInt, ImageList, Int, -1, UInt, hicon)
        ; DllCall("ImageList_ReplaceIcon", "ptr", ImageList, "int", -1, "ptr", hIcon) 
        DllCall("DestroyIcon", ptr, hicon)
        
    }
}
    
ExtractIcon(Filename, IconNumber, IconSize)
{
   ;most of the code is from Menu Icons v2.21
   ;written by Lexikos http://www.autohotkey.com/forum/topic21991.html
   
    static ExtractIconEx, Ptr, PtrP
   if !Ptr
      Ptr := (A_PtrSize = 8) ? "ptr" : "uint"
   If !PtrP
      PtrP := (A_PtrSize = 8) ? "uptr*" : "uint*"
    ; LoadImage is not used..
    ; ..with exe/dll files because:
    ;   it only works with modules loaded by the current process,
    ;   it needs the resource ordinal (which is not the same as an icon index), and
    ; ..with ico files because:
    ;   it can only load the first icon (of size %IconSize%) from an .ico file.
   
    ; If possible, use PrivateExtractIcons, which supports any size of icon.
    if (IconSize != 16 && IconSize != 32)
        if A_OSVersion in WIN_7,WIN_XP,WIN_VISTA,WIN_2003,WIN_2000
            if DllCall("PrivateExtractIcons", "str", Filename, "int", IconNumber-1, "int", IconSize, "int", IconSize, PtrP, h_icon, "uint*", 0, "uint",1, "uint",0,"int")
                return h_icon
   
    if !ExtractIconEx
      ExtractIconEx := DllCall("GetProcAddress"
                  , ptr, DllCall("GetModuleHandle", str, "shell32", ptr)
                  , A_IsUnicode ? "astr":"str"  ; Always an ANSI string.
                  , "ExtractIconEx" . (A_IsUnicode ? "W":"A"), ptr)   
   
    ; Use ExtractIconEx, which only returns 16x16 or 32x32 icons.
    ; if DllCall(ExtractIconEx, "str", Filename, "int", IconNumber-1, PtrP, h_icon, PtrP, h_icon_small, "uint", 1)
    if DllCall(ExtractIconEx, "str", Filename, "int", IconNumber-1, PtrP, h_icon, PtrP, h_icon_small, "uint", 1)
    {
        SysGet, SmallIconSize, 49
       
        ; Use the best-fit size; delete the other. Defaults to small icon.
        if (IconSize <= SmallIconSize) {
            DllCall("DestroyIcon", ptr, h_icon)
            h_icon := h_icon_small
        } else
            DllCall("DestroyIcon", ptr, h_icon_small)
       
        ; I think PrivateExtractIcons resizes icons automatically,
        ; so resize icons returned by ExtractIconEx for consistency.
        if (h_icon && IconSize)
            h_icon := DllCall("CopyImage", ptr, h_icon, "uint", 1, "int", IconSize, "int", IconSize, "uint", 4|8, ptr)
    }

    return h_icon ? h_icon : 0
}
