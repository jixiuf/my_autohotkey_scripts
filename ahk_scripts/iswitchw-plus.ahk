; iswitchw-plus - Incrementally switch between windows using substrings
; Time-stamp: <Administrator 2011-05-16 12:53:08>
; you can reach me here :<jixiuf@gmail.com>
; Required AutoHotkey version: 1.0.25+


; 中文注释，
; 首先说一说iswitch 是什么以及iswitchw.ahk的由来
; iswitchb.el 是GNU/Emacs 编辑器的一个功能，
; 它用来在你所有打开的文件(Emacs称之为buffer)中进行切换，你只需要输入某个文件名
; 的一部分，它就会只列出文件名匹配你输入的内容的文件供你选择
; 比如，你打开的文件有hello.txt iloveyou.txt ihateyou.txt
; 然后你输入lo ,那么只有hello.txt iloveyou.txt 会被列出，因为它们中包含lo
; 然后你继续输入lov ，此时只列出iloveyou.txt ,回车即可选中这个打开的文件.
; 这是iswitch.el 的功能，而iswitchw.ahk 的灵感就来于此，
; 它不再是选择文件，而是选择某个你打开的窗口.
; keyboardfreak 由此开发了iswitchw.ahk 。我虽然用过GNU/Emacs,但是没使用
; iswitch.el 而是用了一个功能更强大的anything.el
; 所有我做的修改，其键绑定更像anything.el的键键绑定，而不是iswitch.el
; 所以对于是将这个文件命名为iswitchw-plus 是很勉强的，将它叫做
; anything-switch-window.ahk 或许更好.

; 其实你不必非得输入到只剩下一个可选项时，才能回车选中，
; 也可以在多个选项中使用上下键，或者Ctl+n, Ctrl+p 选中你想选中的，然后回车即可

;
; iswitchw.ahk 最初是由keyboardfreak 开发的，后来ezuk对它做了一点
; 简单的修改，主要是界面的修改，功能上的改动几乎无.这两个版本的链接下面会给出。
; 然后我在这两个版本上进行了很大的改动，
; keyboardfreak 的版本快捷键只支持像down up 这样的单键，而Ctrl+n Ctrl+p
; 这样的组合键不支持，另外 keyboardfreak的版本，使用listbox 显示所有的窗口title
; 只能显示一列，我使用了listview ,可以将 title name 及process name 在不同的列
; 进行显示,另外他的版本不显示图标，我增加了图标显示的功能,这样直观一些
; 
; keyboardfreak把键绑定到CapsLK键，我则默认就使用Alt+Tab
; keyboardfreak只能使用上下键进行选择，我的则可以使用
; UP,Ctrl+P Alt+p Shift+Tab,Alt+Shift+Tab 选择上一个
; Down ,Ctrl+n Alt+n  Tab ,Alt+Tab  选择下一个
;
; 因为用惯了Emacs ，习惯让Ctrl+j 做回车键该做的事，
; 所以Ctrl+j 功能与回车一样
; Ctrl+g 具有escape 的功能，cancel

; 因为有个搜索框，所以对搜索框的编辑功能进行了一点增强
; ctrl+u 清空搜索框，类似于bash 的键绑定
; Ctrl+h 功能与backspace 一样
; Ctrl+backspace,Alt+backspace删除一个关键字


; 另外anything.el 与iswitch.el 的不同是，iswitch.el 好像只能使用一个关键字
; 进行过滤，而anything.el可以使用多个关键字，像google 一样，用空格将关键字隔开
; 即可,所以此次修改增加了多个关键字的功能.
; 另外下面的几点的增强，更是"anything.el" 的思考方法，
; 其实我们对于switcher选中的窗口，我们不仅可以将其激活还可以将其关闭，最大化最小化
; 所以除了回车激活选中的窗口外，Ctrl+k 会close 选中的窗口,
; 而Ctrl+s 会在最大化最小化正常显示三个状态间切换
; 
; 另外 keyboardfreak的版本就具有的功能，就是Tab键的补全,这个实例功能不用多说
; 是linux的老传统,emacs ,bash 等都具备，但是Windows用户可能不太清楚，所以简单说一下
; 假如用两个文件iloveyou1.txt iloveyou2.txt
; 这个时候如果你输入了lo，这两个文件都匹配，你需要再输入veyou，变成loveyou
; 之后才能输入它们的不同点1 and 2 , 所以对于veyou 的输入根本没法区分这两个文件
; 所以当你输入lo后，它会自动分析出veyou这几个字是它们共同的部分
; lo[veyou]
; 这个时候你按一下Tab键，它会自动补全上veyou 变成loveyou
; loveyou ,这个时候你只需要输入1 或者2 选中loveyou1 loveyou2 即可
;
; 另外一个原版就有的功能，可以用数字键选中相应的条目。可以选择不启用此功能.
; 
; 
; keyboardfreak's  version
;     http://www.autohotkey.com/forum/viewtopic.php?t=1040
;
; ezuk's version
;     http://www.autohotkey.com/forum/viewtopic.php?t=33353;
; and this file ,my version is hosted on github.com
;     https://github.com/jixiuf/my_autohotkey_scripts/blob/master/ahk_scripts/iswitchw-plus.ahk
;
;    about iswitchb.el
; http://cvs.savannah.gnu.org/viewvc/*checkout*/emacs/emacs/lisp/iswitchb.el
;    about "anything.el" you can find it here .
; http://www.emacswiki.org/emacs/Anything

;
; When this script is triggered via its hotkey the list of titles of
; all visible windows appears. The list can be narrowed quickly to a
; particular window by typing one or more substring of a window title.
; separated by empty space.
;
; When the list is narrowed the desired window can be selected using
; the cursor keys, Enter,and Ctrl+j. If the substring matches exactly
; onewindow that window is activated immediately (configurable, see
; the  "autoactivateifonlyone" variable).
; you can also close the selected window by Ctrl+k,and Alt+k
; the difference is Alt+k ,close the window and quit.
; Ctrl+k close the window and  keep iswitcher running .
;
; The window selection can be cancelled with Esc and Ctrl+g.
;
; The switcher window can be moved horizontally with the left/right
; arrow keys if it blocks the view of windows under it.
;
; The switcher can also be operated with the mouse, although it is
; meant to be used from the keyboard. A mouse click activates the
; currently selected window. Mouse users may want to change the
; activation key to one of the mouse keys.
;
; If enabled possible completions are offered when the same unique
; substring is found in the title of more than one window.
;
; For example, the user typed the string "co" and the list is
; narrowed to two windows: "Windows Commander" and "Command Prompt".
; In this case the "command" substring can be completed automatically,
; so the script offers this completion in square brackets which the
; user can accept with the TAB key:
;
;     co[mmand]
;
; This feature can be confusing for novice users, so it is disabled
; by default.
; 
;
; you can use UP,Ctrl+P Alt+p Shift+Tab,Alt+Shift+Tab
; to select previous item
; and use Down ,Ctrl+n Alt+n  Tab ,Alt+Tab  to select next item .
;
; Ctrl+u will clear all search string in textfield ,
; Ctrl+h ,and backspace will delete a char.
; Ctrl+backspace ,AltBackspace will delete last keyword in textfield.
; enter ,and Ctrl+j for select
; escape ,and Ctrl+g for cancel

; Ctrl+alt+k ,force kill the selected window
; Alt+k      ,kill the selected window and quit.
; Ctrl+k ,    kill the selected window and keep switcher going ,so that
;             you can select other window or kill other window.
;
; Ctrl+s ,  toggle the status of window:minimize,maximize and restore
; you can press Ctrl+s several times
;
; For the idea of this script the credit goes to the creators of the
; iswitchb package for the Emacs editor
;
; 
;
;
;----------------------------------------------------------------------
;
#SingleInstance force
;#NoTrayIcon
#InstallKeybdHook

Process Priority,,High
SetBatchLines, -1
SetKeyDelay  -1
; User configuration
; 用户可配置的选项。

; set this to yes if you want to select the only matching window
; automatically
; 当只有一个候选项的时候是否自动激活它(留空表示no ,yes 表是肯定)
autoactivateifonlyone =

; set this to yes if you want to enable tab completion (see above)
; it has no effect if firstlettermatch (see below) is enabled
;;如果你想使用TAB键补全功能，将这个设为yes 否则留空
tabcompletion =yes

; set this to yes to enable digit shortcuts when there are ten or
; less items in the list
; 是否启用数字键选中功能
digitshortcuts =yes

; set this to yes to enable first letter match mode where the typed
; search string must match the first letter of words in the
; window title (only alphanumeric characters are taken into account)
;
; For example, the search string "ad" matches both of these titles:
;
;  AutoHotkey - Documentation
;  Anne's Diary
;
;是否启用首字母匹配模式，
; 比如，假如有两个窗口，它们的title 是
;  AutoHotkey - Documentation
;  Anne's Diary
;你输入"ad" 它们都会匹配，
firstlettermatch =

; set this to yes to enable activating the currently selected
; window in the background
;在switcher选中某个窗口时（注意此时还没回车，）
; 是否将相应的窗口提到最前面，以便预览之。
;
activateselectioninbg =

; number of milliseconds to wait for the user become idle, before
; activating the currently selected window in the background
;
; it has no effect if activateselectioninbg is off
;
; if set to blank the current selection is activated immediately
; without delay
; 这个是设置停留多长时间时才进行预览，单位毫秒，这个选项只有在
; activateselectioninbg  不为空的时候有效

bgactivationdelay = 600


; Close switcher window if the user activates an other window.
; It does not work well if activateselectioninbg is enabled, so
; currently they cannot be enabled together.
;如果用户激活了其他窗口，是否自动退出iswitcher
closeifinactivated =yes

if activateselectioninbg <>
    if closeifinactivated <>
    {
        msgbox, activateselectioninbg and closeifinactivated cannot be enabled together
        exitapp
    }

; List of subtsrings separated with pipe (|) characters (e.g. carpe|diem).
; Window titles containing any of the listed substrings are filtered out
; from the list of windows.
;;这个相当于黑名单，如果某个窗口标题在这个列表里，则不将它考虑在切换列表中.
filterlist = asticky|blackbox

; Set this yes to update the list of windows every time the contents of the
; listbox is updated. This is usually not necessary and it is an overhead which
; slows down the update of the listbox, so this feature is disabled by default.
;在每一次的过滤时是否检查 是否有新窗口加入或删除，一般没必要检查.
dynamicwindowlist =

;;如果用户输入的关键字不与任何窗口匹配，播放下面的文件对应的声音
; path to sound file played when the user types a substring which
; does not match any of the windows
;
; set this to blank if you don't want a sound
;
nomatchsound = %windir%\Media\ding.wav

if nomatchsound <>
    ifnotexist, %nomatchsound%
        msgbox, Sound file %nomatchsound% not found. No sound will be played.

;----------------------------------------------------------------------
;
; Global variables
;
;     numallwin      - the number of windows on the desktop
;     allwinarray    - array containing the titles of windows on the desktop
;                      dynamicwindowlist is disabled
;     allwinidarray  - window ids corresponding to the titles in allwinarray
;     numwin         - the number of windows in the listbox
;     idarray        - array containing window ids for the listbox items
;     orig_active_id - the window ID of the originally active window
;                      (when the switcher is activated)
;     prev_active_id - the window ID of the last window activated in the
;                      background (only if activateselectioninbg is enabled)
;     switcher_id    - the window ID of the switcher window
;     filters        - array of filters for filtering out titles
;                      from the window list
;
;----------------------------------------------------------------------

AutoTrim, on
DetectHiddenWindows, off
Gui,+LastFound +AlwaysOnTop -Caption ToolWindow   

WinSet, Transparent, 230
Gui, Color,black,black
Gui,Font,s13 c7cfc00 bold
;;Gui, Add, ListView, vindex gListViewClick x-2 y-2 w800 h530 AltSubmit -VScroll
Gui, Add, Text,     x10  y10 w800 h30, Search`:
Gui, Add, Edit,     x90 y5 w500 h30,
Gui, Add, ListView, x0 y40 w800 h510 -VScroll -E0x200 AltSubmit -Hdr -HScroll -Multi  Count10 gListViewClick, index|title|proc
WS_EX_APPWINDOW = 0x40000
WS_EX_TOOLWINDOW = 0x80
GW_OWNER = 4

if filterlist <>
{
    loop, parse, filterlist, |
    {
        filters%a_index% = %A_LoopField%
    }
}

;----------------------------------------------------------------------
;
;
!Tab::
search =
numallwin = 0
GuiControl,, Edit1
GoSub, RefreshWindowList

WinGet, orig_active_id, ID, A
prev_active_id = %orig_active_id%

Gui, Show, Center h550 w800, Window Switcher

; If we determine the ID of the switcher window here then
; why doesn't it appear in the window list when the script is
; run the first time? (Note that RefreshWindowList has already
; been called above).
; Answer: Because when this code runs first the switcher window
; does not exist yet when RefreshWindowList is called.
WinGet, switcher_id, ID, A
WinSet, AlwaysOnTop, On, ahk_id %switcher_id%

Loop
{
    if closeifinactivated <>
        settimer, CloseIfInactive, 200

    Input, input, L1, {enter}{esc}{backspace}{up}{down}{pgup}{pgdn}{tab}{left}{right}{LControl}npsgukjh{LAlt}

    if closeifinactivated <>
        settimer, CloseIfInactive, off

    ;;enter for select
    if ErrorLevel = EndKey:enter
    {
        GoSub, ActivateWindow
        break
    }
    
    ;;Ctrl+j for select
    if ErrorLevel = EndKey:j
    {
       if (GetKeyState("LControl", "P")=1){
           GoSub, ActivateWindow
           break
       }else{
            input=j
        }
    }
    
    ;excape for cancel 
    if ErrorLevel = EndKey:escape
    {
        GoSub, CancelSwitch
        break
    }
    
    ;;control+g for cancel too
    if ErrorLevel = EndKey:g
    {
      if (GetKeyState("LControl", "P")=1){
          GoSub, CancelSwitch
          break
       }else{
            input=g
        }
    }
    
    if ErrorLevel = EndKey:LAlt
    {
       continue
    }
     ;;delete last char 
    if ErrorLevel = EndKey:backspace
    {
       if (GetKeyState("LControl", "P")=1||GetKeyState("LAlt","P")=1){
          GoSub, DeleteSearchWord
          continue
       }else{
        GoSub, DeleteSearchChar
        continue
       }

    }
    ;;ctrl+ h===backspace
  if ErrorLevel = EndKey:h
    {
       if (GetKeyState("LControl", "P")=1){
          GoSub, DeleteSearchChar
          continue
       }else{
       input=h
       }

    }
    ;;toggle the status of selected window
    ;;WinMaximize-> WinMinimize->WinRestore-> 
  if ErrorLevel = EndKey:s
    {
       if (GetKeyState("LControl", "P")=1){
          oldCloseifinactivated =closeifinactivated
          closeifinactivated=
          settimer, CloseIfInactive, off
          GoSub, toggleWinStatus
          WinActivate ,ahk_id %switcher_id%
          GuiControl,, Edit1,%search%
          SendInput {end}
          sleep 10
          closeifinactivated = oldCloseifinactivated
          continue
       }else{
            input=s
       }

    }
    
    ;;Ctrl+alt+k ,force kill the selected window
    ;;Alt+k      ,kill the selected window and quit.
    ;;Ctrl+k ,    kill the selected window and keep switcher running ,so that
    ;;            you can select other window or kill other window.
  if ErrorLevel = EndKey:k
    {
       if (GetKeyState("LControl", "P")=1  and GetKeyState("LAlt", "P")=1){
          GoSub, ForceKillSelectedWindow 
          GoSub, CancelSwitch       ;; quit 
          break
       
       }else if (GetKeyState("LControl", "P")=1){
             GoSub, KillSelectedWindow
             tmpRefresh=yes ;force refresh window list 
       }else if (GetKeyState("LAlt", "P")=1){
          GoSub  KillSelectedWindow ;;kill the select window
          GoSub, CancelSwitch       ;; quit 
          break
       }else{
         input=k
       }

    }
    ;;Ctrl+u clear "search" string ,just like bash
    if ErrorLevel = EndKey:u
    {
      if (GetKeyState("LControl", "P")=1){
              GoSub, DeleteAllSearchChar
              continue
       }else{
            input=u
        }
    }
    
        
    if ErrorLevel = EndKey:tab
        if completion =
        {
          if (GetKeyState("LShift", "P")=1){
                GoSuB SelectPrevious
          }else{
                GoSuB SelectNext
          }
            continue
        }else
            input = %completion%

    ; pass these keys to the selector window

    if ErrorLevel = EndKey:up
    {
        GoSuB SelectPrevious
        continue
    }

    if ErrorLevel = EndKey:down
    {
       GoSuB SelectNext
       continue
    }
    if ErrorLevel = EndKey:LControl
       {
          continue
       }

     ;;ctrl+n ,or Alt+n select next item
    if ErrorLevel = EndKey:n
      {
       if (GetKeyState("LControl", "P")=1||GetKeyState("LAlt", "P")=1){
           GoSuB SelectNext
           continue
       }else{
            input=n
        }
     }
     ;;ctrl+p ,Alt+p select previous item
      if ErrorLevel = EndKey:p
      {
       if (GetKeyState("LControl", "P")=1||GetKeyState("LAlt", "P")=1){
           GoSuB SelectPrevious
           continue
        }else{
            input=p
        }
 
    }
  
    if ErrorLevel = EndKey:pgup
    {
        Send, {pgup}
        GoSuB ActivateWindowInBackgroundIfEnabled
        continue
    }

    if ErrorLevel = EndKey:pgdn
    {
        Send, {pgdn}
        GoSuB ActivateWindowInBackgroundIfEnabled
        continue
    }

    if ErrorLevel = EndKey:left
    {
        direction = -1
        GoSuB MoveSwitcher
        continue
    }

    if ErrorLevel = EndKey:right
    {
        direction = 1
        GoSuB MoveSwitcher
        continue
    }

    ; FIXME: probably other error level cases
    ; should be handled here (interruption?)

    ; invoke digit shortcuts if applicable
    if digitshortcuts <>
        if numwin <= 10
            if input in 1,2,3,4,5,6,7,8,9,0
            {
                if input = 0
                    input = 10

                if numwin < %input%
                {
                    if nomatchsound <>
                        SoundPlay, %nomatchsound%
                    continue
                }

                 LV_Modify(input, "Select") ;;select last line
                 LV_Modify(input, "Focus") ;; focus last line
;;                GuiControl, choose, ListView1, %input%
                GoSub, ActivateWindow
                break
            }

    ; process typed character

    search = %search%%input%
    GuiControl,, Edit1, %search%
    GuiControl,Focus,Edit1 ;; focus Edit1 ,
    Send {End} ;;move cursor right ,make it after the new inputed char 
    GoSub, RefreshWindowList
}

Gosub, CleanExit

return

;----------------------------------------------------------------------
;
; Refresh the list of windows according to the search criteria
;
; Sets: numwin  - see the documentation of global variables
;       idarray - see the documentation of global variables
;
RefreshWindowList:
    ; refresh the list of windows if necessary

    if ( dynamicwindowlist = "yes" or numallwin = 0 or tmpRefresh="yes" )
    {
       tmpRefresh=no ;; reset to no 
        numallwin = 0

        WinGet, id, list, , , Program Manager

        Loop, %id%
        {
            StringTrimRight, this_id, id%a_index%, 0
            WinGetTitle, title, ahk_id %this_id%

            ; FIXME: windows with empty titles?
            if title =
                continue

            ; don't add the switcher window
            if switcher_id = %this_id%
                continue


            ; don't add titles which match any of the filters
            if filterlist <>
            {
                filtered =

                loop
                {
                    stringtrimright, filter, filters%a_index%, 0
                    if filter =
                      break
                    else
                        ifinstring, title, %filter%
                        {
                           filtered = yes
                           break
                        }
                }

                if filtered = yes
                    continue
            }

            ; replace pipe (|) characters in the window title,
            ; because Gui Add uses it for separating listbox items
            StringReplace, title, title, |, -, all

            numallwin += 1
            allwinarray%numallwin% = %title%
            allwinidarray%numallwin% = %this_id%
        }
    }

    ; filter the window list according to the search criteria
    winlist =
    numwin = 0
    Loop, %numallwin%
    {
        StringTrimRight, title, allwinarray%a_index%, 0
        StringTrimRight, this_id, allwinidarray%a_index%, 0

        ; don't add the windows not matching the search string
        ; if there is a search string
        if search <>
            if firstlettermatch =
            {
                matched=yes
                procName:=getProcessname(this_id)
                
                titleAndProcName=%title%%procName%
                Loop,parse,search ,%A_Space%,%A_Space%%A_TAB%
                {
                    if titleAndProcName not contains %A_LoopField%,
                    { matched=no
                      break
                    }
                }
              if matched=no
               {
                  continue
               }
            }
            else
            {
                stringlen, search_len, search

                index = 1
                match =

                loop, parse, title, %A_Space%
                {                   
                    stringleft, first_letter, A_LoopField, 1

                    ; only words beginning with an alphanumeric
                    ; character are taken into account
                    if first_letter not in 1,2,3,4,5,6,7,8,9,0,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
                        continue

                    stringmid, search_char, search, %index%, 1

                    if first_letter <> %search_char%
                        break

                    index += 1

                    ; no more search characters
                    if index > %search_len%
                    {
                        match = yes
                        break
                    }
                }

                if match =
                    continue    ; no match
            }
        numwin += 1
        winarray%numwin% = %title%
        idarray%numwin%= %this_id%
    }
    ; sort the list alphabetically
    ;;I don't like sort it alphabetically 
    ;;Sort, winlist, D|


ImageListID1 := IL_Create(numwin,1,1)
; Attach the ImageLists to the ListView so that it can later display the icons:
LV_SetImageList(ImageListID1, 1)
LV_Delete()
empty=0
iconIdArray:=Object()
iconTitleArray:=Object()
iconIdNum=0
loop,%numwin%,
{
  ele:=winarray%a_index%
     wid := idarray%a_index%
     WinGet, es, ExStyle, ahk_id %wid%
     Use_Large_Icons_Current =1
if( ( ! DllCall( "GetWindow", "uint", wid, "uint", GW_OWNER ) and  ! ( es & WS_EX_TOOLWINDOW ) )
             or ( es & WS_EX_APPWINDOW ) ){
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
                if (h_icon){
                iconIdArray.Insert(wid)
                iconTitleArray.Insert(winarray%a_index%)
                iconIdNum+=1
                 ; Add the HICON directly to the small-icon and large-icon lists.
                 ; Below uses +1 to convert the returned index from zero-based to one-based:
                 IconNumber := DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, h_icon) + 1
                 LV_Add("Icon" . IconNumber, a_index-empty,ele, getProcessName(wid)) ; spaces added for layout
               }else{
               empty +=1
               }
        }else{
             WinGetClass, Win_Class, ahk_id %wid%
             If Win_Class = #32770 ; fix for displaying control panel related windows (dialog class) that aren't on taskbar
              {
                 iconTitleArray.Insert(winarray%a_index%)
                 iconIdArray.Insert(wid)
                 iconIdNum+=1
                 IconNumber := IL_Add(ImageListID1, "C:\WINDOWS\system32\shell32.dll" , 217) ; generic control panel icon
                 LV_Add("Icon" . IconNumber,a_index-empty ,ele,getProcessName(wid))
              }else{
                   empty +=1
              }
             }
}

numwin:=iconIdNum
for i ,ele in iconIdArray{
   idarray%i%:=ele
   winarray%i%:=iconTitleArray[i]
}
    ; if the pattern didn't match any window
    if numwin = 0
        ; if the search string is empty then we can't do much
        if search =
        {
            Gui, cancel
            Gosub, CleanExit
        }
        ; delete the last character
        else
        {
            if nomatchsound <>
                SoundPlay, %nomatchsound%

            GoSub, DeleteSearchChar
            return
        }
 if numwin >1
 {
    LV_Modify(2, "Select") ;;select the first row
    LV_Modify(2, "Focus") ;; focus the first row
 }else{
    LV_Modify(1, "Select") ;;select the secnd row
    LV_Modify(1, "Focus") ;; focus the second row
 }
   ;;LV_ModifyCol()  ; Auto-size each column to fit its contents.
   LV_ModifyCol(1,48)
   LV_ModifyCol(2,652)
   LV_ModifyCol(3,100)
    if numwin = 1
        if autoactivateifonlyone <>
        {
            GoSub, ActivateWindow
            Gosub, CleanExit
        }
    GoSub ActivateWindowInBackgroundIfEnabled

    completion =

    if tabcompletion =
        return

    ; completion is not implemented for first letter match mode
    if firstlettermatch <>
        return

    ; determine possible completion if there is
    ; a search string and there are more than one
    ; window in the list

    if search =
        return
   
    if numwin = 1
        return
     loop
    {
        nextchar =
        loop, %numwin%
        {
            stringtrimleft, title, winarray%a_index%, 0
            if nextchar =
            {
                substr = %search%%completion%
                stringlen, substr_len, substr
                stringgetpos, pos, title, %substr%

                if pos = -1
                    break

                pos += %substr_len%

                ; if the substring matches the end of the
                ; string then no more characters can be completed
                stringlen, title_len, title
                if pos >= %title_len%
                {
                    pos = -1
                    break
                }

                ; stringmid has different position semantics
                ; than stringgetpos. strange...
                pos += 1
                stringmid, nextchar, title, %pos%, 1
                substr = %substr%%nextchar%
             }
             else
             {
                stringgetpos, pos, title, %substr%
                if pos = -1
                    break
             }
        }

        if pos = -1
            break
        else
            completion = %completion%%nextchar%
    }

    if completion <>
    {
        GuiControl,Focus,Edit1 ;; focus Edit1 ,
        GuiControl,, Edit1, %search%[%completion%]
         StringLen ,searchStrLen,search
        ;; Send {Right}
         Send {Home} ;;
         Send {Right %searchStrLen%} ;;move right ,
         ToolTip,You can press <Tab> now `,if you set tabcompletion =yes ,0,-30
         SetTimer, RemoveToolTip, 3000
    }
return

;----------------------------------------------------------------------
;
; Delete last search char and update the window list
;
DeleteSearchChar:
if search =
{
    GuiControl,, Edit1, 
    return
}
StringTrimRight, search, search, 1
GuiControl,, Edit1, %search%
GuiControl,Focus,Edit1 ;; focus Edit1 ,
Send {End} ;;move cursor end 

GoSub, RefreshWindowList
return
;------------------------------------------------------------------
DeleteSearchWord: ;;delete last word of search string ,search string
                  ;; can be Separated by empty space  
GuiControl,, Edit1, 
if search =
 {
    GuiControl,, Edit1,
    return
 }
FoundPos := RegExMatch(search, "(.*) +.*", SubPat)
if FoundPos>0
{
  search:=SubPat1
  GuiControl,,Edit1,%search%
}else{
  search=
  GuiControl,,Edit1,
}
  GuiControl,Focus,Edit1 ;; focus Edit1 ,
  Send {End}
  GoSub, RefreshWindowList
return
;---------------------------------------------------------------------
DeleteAllSearchChar:

GuiControl,, Edit1, 
if search =
    return
search=    
GoSub, RefreshWindowList
return
;----------------------------------------------------------------------
;
; Activate selected window
;
ActivateWindow:
Gui, submit
rowNum:= LV_GetNext(0)
stringtrimleft, window_id, idarray%rowNum%, 0
  IL_Destroy(ImageListID1) ; destroy gui, listview and associated icon imagelist.
  LV_Delete()
WinActivate, ahk_id %window_id%

return
;-------------------------------------------
;Kill the window you selected
KillSelectedWindow:
Gui, submit,NoHide 
rowNum:= LV_GetNext(0)
stringtrimleft, window_id, idarray%rowNum%, 0
WinClose, ahk_id %window_id%
return

;-------------------------------------------
; force kill the window you selected 
ForceKillSelectedWindow:
Gui, submit,NoHide 
rowNum:= LV_GetNext(0)
stringtrimleft, window_id, idarray%rowNum%, 0
WinGet, pid, PId, ahk_id %window_id%
Process ,Close, %pid%
send {escape}
return

;----------------------------------------------------------------------
;
; Activate selected window in the background
;
ActivateWindowInBackground:
  index:=LV_GetNext(0)
  stringtrimleft, window_id, idarray%index%, 0
   
   if prev_active_id <> %window_id%
   {
       WinActivate, ahk_id %window_id%
       WinActivate, ahk_id %switcher_id%
       prev_active_id = %window_id%
   }
return

;----------------------------------------------------------------------
;
; Activate selected window in the background if the option is enabled.
; If an activation delay is set then a timer is started instead of
; activating the window immediately.
;
ActivateWindowInBackgroundIfEnabled:

if activateselectioninbg =
    return

; Don't do it just after the switcher is activated. It is confusing
; if active window is changed immediately.
WinGet, id, ID, ahk_id %switcher_id%
if id =
    return

if bgactivationdelay =
    GoSub ActivateWindowInBackground
else
    settimer, BgActivationTimer, %bgactivationdelay%

return

;----------------------------------------------------------------------
;
; Check if the user is idle and if so activate the currently selected
; window in the background
;
BgActivationTimer:

settimer, BgActivationTimer, off

GoSub ActivateWindowInBackground

return

;----------------------------------------------------------------------
;
; Stop background window activation timer if necessary and exit
;
CleanExit:

settimer, BgActivationTimer, off

exit

;----------------------------------------------------------------------
;
; Cancel keyboard input if GUI is closed.
;
GuiClose:

send, {esc}

return

;----------------------------------------------------------------------
;
; Handle mouse click events on the list box
;
ListViewClick:
if (A_GuiControlEvent = "Normal"
    and !GetKeyState("Down", "P") and !GetKeyState("Up", "P"))

;;    GoSub, ActivateWindow
send ,{enter}
;;    GoSub, BgActivationTimer
return

;----------------------------------------------------------------------
;
; Move switcher window horizontally
;
; Input: direction - 1 for right, -1 for left
;
MoveSwitcher:

direction *= 100
WinGetPos, x, y, width, , ahk_id %switcher_id%
x += %direction%

if x < 0
    x = 0
else
{
   SysGet screensize, MonitorWorkArea
   screensizeRight -= %width%
   if x > %screensizeRight%
      x = %screensizeRight%
}

prevdelay = %A_WinDelay%
SetWinDelay, -1
WinMove, ahk_id %switcher_id%, , %x%, %y%
SetWinDelay, %prevdelay%

return

;----------------------------------------------------------------------
;
; Close the switcher window if the user activated an other window
;
CloseIfInactive:

ifwinnotactive, ahk_id %switcher_id%
    send, {esc}

return
;----------------------------------------------------------------------
RemoveToolTip:
  SetTimer, RemoveToolTip, Off
  ToolTip
return
;----------------------------------------------------------------------
SelectNext:
       rowNum:= LV_GetNext(0)
       if(rowNum<numwin){
          LV_Modify(rowNum+1, "Select") ;;select next line
          LV_Modify(rowNum+1, "Focus") ;; focus next line
       }else{
          LV_Modify(1, "Select") ;;select the first row
          LV_Modify(1, "Focus") ;; focus the first row
       }

        GoSuB ActivateWindowInBackgroundIfEnabled
return
;------------------------------------------------------------------------
SelectPrevious:
              rowNum:= LV_GetNext(0)
              if(rowNum<2){
                 LV_Modify(numwin, "Select") ;;select last line
                 LV_Modify(numwin, "Focus") ;; focus last line
              }else{
                 LV_Modify(rowNum-1, "Select") ;;select previous line
                 LV_Modify(rowNum-1, "Focus") ;; focus previous line
              }
            GoSuB ActivateWindowInBackgroundIfEnabled
return 
;-------------------------------------------------------------------------
CancelSwitch:
        Gui, cancel

        ; restore the originally active window if
        ; activateselectioninbg is enabled
        if activateselectioninbg <>
            WinActivate, ahk_id %orig_active_id%
return
;---------------------------------------------------------------------------
getProcessname(wid){
       ; show process name if enabled
           WinGet, procname, ProcessName, ahk_id %wid%
           stringgetpos, pos, procname, .
           if ErrorLevel <> 1
           {
               stringleft, procname, procname, %pos%
           }
    ;;       stringupper, procname, procname
    return procname
}
;----------------------------------------------------------------------------
previousWinId4toggleStatus=
previousWinStatus4toggleStatus=1
toggleWinStatus:
    rowNum:= LV_GetNext(0)
    stringtrimleft, window_id, idarray%rowNum%, 0
   if (previousWinId4toggleStatus=window_id)
   {
      if (previousWinStatus4toggleStatus=1){
         WinMinimize , ahk_id %window_id% 
         previousWinStatus4toggleStatus=2
      }else if (previousWinStatus4toggleStatus=2){
         WinMaximize , ahk_id %window_id% 
          previousWinStatus4toggleStatus=3
      }else{
         WinRestore ,ahk_id %window_id% 
         previousWinStatus4toggleStatus=1
      }
   }else{
       WinMaximize , ahk_id %window_id% 
       previousWinStatus4toggleStatus=max
   }
   previousWinId4toggleStatus:=window_id
return 
