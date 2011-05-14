; iswitchw - Incrementally switch between windows using substrings
;
; Required AutoHotkey version: 1.0.25+
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
; Ctrl+backspace will delete last word in textfield.
; enter ,and Ctrl+j for select
; escape ,and  Ctrl+g for cancel
;
; For the idea of this script the credit goes to the creators of the
; iswitchb package for the Emacs editor
;
;
;----------------------------------------------------------------------
;
#SingleInstance force
#NoTrayIcon
#InstallKeybdHook

Process Priority,,High
SetBatchLines, -1

; User configuration
;

; set this to yes if you want to select the only matching window
; automatically
autoactivateifonlyone =

; set this to yes if you want to enable tab completion (see above)
; it has no effect if firstlettermatch (see below) is enabled
tabcompletion =yes

; set this to yes to enable digit shortcuts when there are ten or
; less items in the list
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
firstlettermatch =

; set this to yes to enable activating the currently selected
; window in the background
activateselectioninbg =

; number of milliseconds to wait for the user become idle, before
; activating the currently selected window in the background
;
; it has no effect if activateselectioninbg is off
;
; if set to blank the current selection is activated immediately
; without delay
bgactivationdelay = 600

; show process name before window title.
showprocessname =yes

; Close switcher window if the user activates an other window.
; It does not work well if activateselectioninbg is enabled, so
; currently they cannot be enabled together.
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
filterlist = asticky|blackbox

; Set this yes to update the list of windows every time the contents of the
; listbox is updated. This is usually not necessary and it is an overhead which
; slows down the update of the listbox, so this feature is disabled by default.
dynamicwindowlist =

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

AutoTrim, off
WS_EX_APPWINDOW = 0x40000
WS_EX_TOOLWINDOW = 0x80
GW_OWNER = 4
DetectHiddenWindows, off
Gui,+LastFound +AlwaysOnTop -Caption ToolWindow   

WinSet, Transparent, 230
Gui, Color,black,black
Gui,Font,s13 c7cfc00 bold
;;Gui, Add, ListView, vindex gListViewClick x-2 y-2 w800 h530 AltSubmit -VScroll
Gui, Add, Text,     x10  y10 w800 h30, Search`:
Gui, Add, Edit,     x90 y5 w500 h30,
Gui, Add, ListView, x0 y40 w800 h510 -VScroll -E0x200 AltSubmit -Hdr -HScroll -Multi  Count10 gListViewClick, Icon|title

if filterlist <>
{
    loop, parse, filterlist, |
    {
        filters%a_index% = %A_LoopField%
    }
}

;----------------------------------------------------------------------
;
; I never use the CapsLock key, that's why I chose it.
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

    Input, input, L1, {enter}{esc}{backspace}{up}{down}{pgup}{pgdn}{tab}{left}{right}{LControl}npgujh{LAlt}

    if closeifinactivated <>
        settimer, CloseIfInactive, off

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
  if ErrorLevel = EndKey:h
    {
       if (GetKeyState("LControl", "P")=1){
          GoSub, DeleteSearchChar
          continue
       }else{
       input=h
       }

    }
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

    if ErrorLevel = EndKey:n
      {
       if (GetKeyState("LControl", "P")=1||GetKeyState("LAlt", "P")=1){
           GoSuB SelectNext
           continue
       }else{
            input=n
        }
     }
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

    if ( dynamicwindowlist = "yes" or numallwin = 0 )
    {
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

            ; show process name if enabled
            if showprocessname <>
            {
                WinGet, procname, ProcessName, ahk_id %this_id%

                stringgetpos, pos, procname, .
                if ErrorLevel <> 1
                {
                    stringleft, procname, procname, %pos%
                }

         ;;       stringupper, procname, procname
                title = %procname%   : %title%
            }

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
            ;; StringReplace, regexpSearch, search, %A_Space%,.*,All
            ;; pos:= RegExMatch(title,regexpSearch) 
            ;;    if pos<1
            ;;    {
            ;;    continue
            ;;    }
            matched=yes
            Loop,parse,search ,%A_Space%,%A_Space%%A_TAB%
            {
                if title not contains %A_LoopField%,
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

        if winlist <>
            winlist = %winlist%|
        winlist = %winlist%%title%`r%this_id%

        numwin += 1
        winarray%numwin% = %title%
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

    ; sort the list alphabetically
    ;;I don't like sort it alphabetically 
   ;;    Sort, winlist, D|

    ;; ; add digit shortcuts if there are ten or less windows
    ;; ; in the list and digit shortcuts are enabled
    ;; if digitshortcuts <>
    ;;     if numwin <= 10
    ;;     {
    ;;         digitlist =
    ;;         digit = 1
    ;;         loop, parse, winlist, |
    ;;         {
    ;;             ; FIXME: windows with empty title?
    ;;             if A_LoopField <>
    ;;             {
    ;;                 if digitlist <>
    ;;                     digitlist = %digitlist%|
    ;;                 digitlist = %digitlist%%digit%%A_Space%%A_Space%%A_Space%%A_LoopField%

    ;;                 digit += 1
    ;;                 if digit = 10
    ;;                     digit = 0
    ;;             }
    ;;         }
    ;;         winlist = %digitlist%
    ;;     }

    ; strip window IDs from the sorted list
    titlelist  := Object()
    arrayindex = 1

    loop, parse, winlist, |
    {
        stringgetpos, pos, A_LoopField, `r

        stringleft, title, A_LoopField, %pos%
        ;; titlelist = %titlelist%|%title%
        titlelist.Insert(title)

        pos += 2 ; skip the separator char
        stringmid, id, A_LoopField, %pos%, 10000
        idarray%arrayindex% = %id%
        ++arrayindex
    }
  ImageListID1 := IL_Create(numwin,1,1)
  ; Attach the ImageLists to the ListView so that it can later display the icons:
  LV_SetImageList(ImageListID1, 1)
LV_Delete()
empty=0
iconIdArray:=Object()
iconIdNum=0
for i ,ele in titlelist
{
     wid := idarray%i%
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
                iconIdNum+=1
                 ; Add the HICON directly to the small-icon and large-icon lists.
                 ; Below uses +1 to convert the returned index from zero-based to one-based:
                 IconNumber := DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, h_icon) + 1
                 LV_Add("Icon" . IconNumber, i-empty, ele) ; spaces added for layout
               }else{
               empty +=1
               }
        }else{
             WinGetClass, Win_Class, ahk_id %wid%
             If Win_Class = #32770 ; fix for displaying control panel related windows (dialog class) that aren't on taskbar
              {
                 iconIdArray.Insert(wid)
                 iconIdNum+=1
                 IconNumber := IL_Add(ImageListID1, "C:\WINDOWS\system32\shell32.dll" , 217) ; generic control panel icon
                 LV_Add("Icon" . IconNumber,i-empty ,ele)
              }else{
                   empty +=1
              }
             }
}
numwin:=iconIdNum
for i ,ele in iconIdArray{
   idarray%i%:=ele
}
 if numwin >1
 {
    LV_Modify(2, "Select") ;;select the first row
    LV_Modify(2, "Focus") ;; focus the first row
 }else{
    LV_Modify(1, "Select") ;;select the secnd row
    LV_Modify(1, "Focus") ;; focus the second row
 }
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
    return

StringTrimRight, search, search, 1
GuiControl,, Edit1, %search%
GuiControl,Focus,Edit1 ;; focus Edit1 ,
Send {End} ;;move cursor end 

GoSub, RefreshWindowList
return

DeleteSearchWord: ;;delete last word of search string ,search string
                  ;; can be Separated by empty space  
if search =
    return 
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

DeleteAllSearchChar:

if search =
    return
search=    
GuiControl,, Edit1, 
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
if (A_GuiControlEvent = "Normal")
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

;; Get_Window_Icon(wid, Use_Large_Icons_Current) ; (window id, whether to get large icons)
;; {
;;   Local NR_temp, h_icon
;;   Window_Found_Count += 1
;;   ; check status of window - if window is responding or "Not Responding"
;;   NR_temp =0 ; init
;;   h_icon =
;;   Responding := DllCall("SendMessageTimeout", "UInt", wid, "UInt", 0x0, "Int", 0, "Int", 0, "UInt", 0x2, "UInt", 150, "UInt *", NR_temp) ; 150 = timeout in millisecs
;;   If (Responding)
;;     {
;;     ; WM_GETICON values -    ICON_SMALL =0,   ICON_BIG =1,   ICON_SMALL2 =2
;;     If Use_Large_Icons_Current =1
;;       {
;;       SendMessage, 0x7F, 1, 0,, ahk_id %wid%
;;       h_icon := ErrorLevel
;;       }
;;     If ( ! h_icon )
;;       {
;;       SendMessage, 0x7F, 2, 0,, ahk_id %wid%
;;       h_icon := ErrorLevel
;;         If ( ! h_icon )
;;           {
;;           SendMessage, 0x7F, 0, 0,, ahk_id %wid%
;;           h_icon := ErrorLevel
;;           If ( ! h_icon )
;;             {
;;             If Use_Large_Icons_Current =1
;;               h_icon := DllCall( "GetClassLong", "uint", wid, "int", -14 ) ; CL_HICON is -14
;;             If ( ! h_icon )
;;               {
;;               h_icon := DllCall( "GetClassLong", "uint", wid, "int", -34 ) ; GCL_HICONSM is -34
;;               If ( ! h_icon )
;;                 h_icon := DllCall( "LoadIcon", "uint", 0, "uint", 32512 ) ; IDI_APPLICATION is 32512
;;               }
;;             }
;;           }
;;         }
;;       }
;;   If ! ( h_icon = "" or h_icon = "FAIL") ; Add the HICON directly to the icon list
;;   	Gui_Icon_Number := DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, h_icon)
;;   Else	; use a generic icon
;;   	Gui_Icon_Number := IL_Add(ImageListID1, "shell32.dll" , 3)
;; }

RemoveToolTip:
  SetTimer, RemoveToolTip, Off
  ToolTip
return

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

CancelSwitch:
        Gui, cancel

        ; restore the originally active window if
        ; activateselectioninbg is enabled
        if activateselectioninbg <>
            WinActivate, ahk_id %orig_active_id%
return
