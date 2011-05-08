;;;; switchWindow.ahk -- switch to your favourate window 
;;;;@author jixiuf@gmail.com
;;;,此脚本因为含有中文，所以在保存此文本的时候必须保存为utf-8编码，
;;; 其他如gbk的编码应该不可以(未测试)
;;
;;;;这个脚本用于快速定位到特定的窗口
;;;以Win+1键为例
;;;如果没有启动eclipse，按下Win+1键后，会启动一个eclipse,
;;;如果已经有一个启动的eclipse,则按下Win+1键会有两种情况发生
;; 如果eclipse已经获得焦点，则最小化eclipse窗口
;; 如果eclipse没有获得焦点，则最大化之，并聚焦

;;注意，eclipse命令必须在Path 环境变量中,
;;以下用到的程序，除了加了绝对路径的均须如此，
#1::
IfWinExist,ahk_class SWT_Window0
  IfWinActive ,ahk_class SWT_Window0
     WinMinimize ,ahk_class SWT_Window0
  else{
    WinMaximize,ahk_class SWT_Window0
    WinActivate ,ahk_class SWT_Window0
    }
else
  run eclipse
return  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;Win+f toggle Firefox
#f::
IfWinExist,ahk_class MozillaUIWindowClass
  IfWinActive ,ahk_class MozillaUIWindowClass
     WinMinimize ,ahk_class MozillaUIWindowClass
  else{
    WinMaximize,ahk_class MozillaUIWindowClass
    sleep 10
    WinSet, Style, -0xC00000, A ;;full screen
    WinActivate ,ahk_class MozillaUIWindowClass
    }
else
  run firefox
return   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;Win+x ,toggle IE
#x::
IfWinExist,ahk_class IEFrame
  IfWinActive ,ahk_class IEFrame
     WinMinimize ,ahk_class IEFrame
  else{
    WinMaximize,ahk_class IEFrame
    sleep 10
    WinSet, Style, -0xC00000, A ;;full screen
    WinActivate ,ahk_class IEFrame
    }
else
  Run, %A_ProgramFiles%\Internet Explorer\iexplore.exe
return   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


 

;;;;;;;;;;Win+A ,toggle.Eamcs
#a::
IfWinExist,ahk_class Emacs
  IfWinActive ,ahk_class Emacs
     WinMinimize ,ahk_class Emacs
  else{
    WinMaximize,ahk_class Emacs
    WinActivate ,ahk_class Emacs
    }
else
  run runemacs
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;Win+c ,toggle Pl/sql
#c::
IfWinExist,ahk_class TPLSQLDevForm
  IfWinActive ,ahk_class TPLSQLDevForm
     WinMinimize ,ahk_class TPLSQLDevForm
  else{
    WinMaximize,ahk_class TPLSQLDevForm
    WinActivate ,ahk_class TPLSQLDevForm
    }
else
  Run, %A_ProgramFiles%\PLSQL Developer\plsqldev.exe
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;Win+g ,toggle Gtalk
#g::
DetectHiddenWindows, On
IfWinExist,ahk_class Google Talk - Google Xmpp Client GUI Window
  IfWinActive ,ahk_class Google Talk - Google Xmpp Client GUI Window
     WinMinimize ,ahk_class Google Talk - Google Xmpp Client GUI Window
  else{
     WinRestore,ahk_class Chat View
     WinActivate ,ahk_class Google Talk - Google Xmpp Client GUI Window
    }
else
  Run, %A_ProgramFiles%\Google\Google Talk\googletalk.exe
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;Win+b ,toggle Gtalk
#b::
DetectHiddenWindows, On
  IfWinExist,ahk_class Chat View
  IfWinActive ,ahk_class Chat View
     WinMinimize ,ahk_class Chat View
  else{
     WinRestore,ahk_class Chat View
    WinActivate ,ahk_class Chat View
    }
else
  Run, %A_ProgramFiles%\Google\Google Talk\googletalk.exe
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;Win+e 启动资源管理器，

;;与默认的Win+e的不同之处在于,如果已经有一个启动的资源管理器，但是它并
;;没被激活的话，不必重新启动一个，只须激活之，
;;有时资源管理器，需要启动多个，所以，如果当前聚集的窗口已经是一个资源管理器了
;;我们认为用户想重新启用一个资源管理器，为方便计，把目录定位到与这个窗口相同的目录
#e::
MyFavorateDir:="D:\"
SetTitleMatchMode, RegEx 
IfWinExist,ahk_class ahk_class (CabinetWClass|ExploreWClass)
  If WinActive("ahk_class (CabinetWClass|ExploreWClass)"){
      WinGetText, full_path, A  ; 取到地址栏里的路径
      StringSplit, word_array, full_path, `n     ;;因为取到的路径中有换行符，需要却掉它
      full_path = %word_array1%   ; Take the first element from the array
    StringReplace, full_path, full_path, `r, , all   ; 以防万一将尝试却掉回车符returns (`r)

      run, explorer.exe /n`, /e`, "%full_path%"
  }else{
    WinActivate ,ahk_class  (CabinetWClass|ExploreWClass)
  }
else
    run, explorer.exe  /n`, /e`, %MyFavorateDir%
return  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;Win+q  toggle Excel
#q::
IfWinExist,ahk_class XLMAIN
  IfWinActive ,ahk_class XLMAIN
     WinMinimize ,ahk_class XLMAIN
  else{
    WinMaximize,ahk_class XLMAIN
    WinActivate ,ahk_class XLMAIN
    }
else
  run excel
return  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
