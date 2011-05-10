/*
ALT-TAB replacement with icons and window titles in a ListView.

  Hotkeys:
  Alt+Tab - move forwards in window stack
  Alt+Shift+Tab - move backwards in window stack
  Alt+Esc - cancel switching window

  Events:
  Single-click a row to select that item and switch to it.
  Columns can be sorted by clicking on their titles.

  To exit: Kill process or remove #NoTrayIcon first
*/

#SingleInstance
#Persistent
#InstallKeybdHook
;#NoTrayIcon

Process Priority,,High
SetBatchLines, -1

WS_EX_APPWINDOW = 0x40000
WS_EX_TOOLWINDOW = 0x80
GW_OWNER = 4

Display_List_Shown =0

Return



;====================================================================



!Tab:: ; alt-tab hotkey
  Critical
  Gosub, Alt_Tab_Common_Stuff
  Selected_Row += 1
  If Selected_Row >  %Listview_Rows%
    {
    Selected_Row =1
    }
  LV_Modify(Selected_Row, "Focus Select")
Return



!+Tab:: ; alt-shift-tab hotkey
  Critical
  Gosub, Alt_Tab_Common_Stuff
  Selected_Row -= 1
  If Selected_Row =0
    {
    Selected_Row =%Listview_Rows%
    }
  LV_Modify(Selected_Row, "Focus Select")
Return



Alt_Esc: ; abort switching
  Critical
  LV_Modify(Active_ID_Loop, "Focus Select") ; set focus/selection on initial item
  Gosub, ListView_Destroy
Return



Alt_Tab_Common_Stuff:
  Hotkey, *~LAlt Up, ListView_Destroy, On
  Hotkey, !Esc, Alt_Esc, On
  If Display_List_Shown =0
    {
    WinGet, Active_ID, ID, A
    Gosub, Display_List

    Active_ID_Loop =0
    Active_ID_Found =0
    Loop, %Listview_Rows% ; select active program in list (not always the top item)
      {
      Active_ID_Loop +=1
      temp_wid := Window%Active_ID_Loop%
      If Active_ID =%temp_wid%
        {
        Active_ID_Found =1
        LV_Modify(Active_ID_Loop, "Focus Select")
        Break
        }
      }
    If Active_ID_Found =0 ; active window has an icon in another main window & was excluded from Alt-Tab list
      {
      WinGet, Active_Process, ProcessName, ahk_id %Active_ID%
      WinGetClass, Active_Class,  ahk_id %Active_ID%
      If (Active_Process ="Explorer.exe" AND (Active_Class ="Progman" OR Active_Class ="WorkerW")) ; desktop selected so select 1st item in alt-tab list
        {
        Active_ID_Loop =1
        Active_ID_Found =1
        LV_Modify(1, "Focus Select")
        }
      Active_ID_Loop =0
      If Active_ID_Found =0
        {
        Loop, %Listview_Rows% ; find top item in window list with same exe name as active window
          {
          Active_ID_Loop +=1
          If Exe_Name%Active_ID_Loop% =%Active_Process%
            {
            Active_ID_Found =1
            LV_Modify(Active_ID_Loop, "Focus Select")
            Break
            }
          }
        }
      }
    }
  Selected_Row := LV_GetNext(0, "F")
Return



;====================================================================



Display_List:
  ; Create the ListView gui
  Gui, +AlwaysOnTop +ToolWindow
  Gui, Font, s13, MS sans serif
  Gui, Margin, 5, 3
  Gui, Add, ListView, w570 -E0x200 -Multi BackgroundE4E2FC AltSubmit Count10 gListView_Event vListView1, #|Window|Exe
  Display_List_Shown =1

  ; Create an ImageList so that the ListView can display some icons:
  ImageListID1 := IL_Create(10,2)

  ; Attach the ImageLists to the ListView so that it can later display the icons:
  LV_SetImageList(ImageListID1, 1)

  ; Gather a list of running programs:
  WinGet, Window_List, List

  Window_Loop_Count =0

  Loop, %Window_List%
    {
    wid := Window_List%A_Index%
    WinGet, es, ExStyle, ahk_id %wid%
      ; Retrieve small icon for desired window styles (i.e. those on the taskbar)
      If ( ( ! DllCall( "GetWindow", "uint", wid, "uint", GW_OWNER ) and  ! ( es & WS_EX_TOOLWINDOW ) )
             or ( es & WS_EX_APPWINDOW ) )
        {
        Window_Loop_Count += 1

        SendMessage, 0x7F, 2, 0,, ahk_id %wid%
        h_icon := ErrorLevel
          If ( ! h_icon )
            {
            SendMessage, 0x7F, 0, 0,, ahk_id %wid%
            h_icon := ErrorLevel
              If ( ! h_icon )
                {
                h_icon := DllCall( "GetClassLong", "uint", wid, "int", -34 ) ; GCL_HICONSM is -34
                  If ( ! h_icon )
                    {
                    h_icon := DllCall( "LoadIcon", "uint", 0, "uint", 32512 ) ; IDI_APPLICATION is 32512
                    }
                }
            }

               ; Add the HICON directly to the small-icon and large-icon lists.
               ; Below uses +1 to convert the returned index from zero-based to one-based:
               IconNumber := DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, h_icon) + 1

    Window%Window_Loop_Count% =%wid% ; store useful windows to a new list
    WinGetTitle, title, ahk_id %wid%
    WinGet, Exe_Name, ProcessName, ahk_id %wid%
    Exe_Name%Window_Loop_Count% =%Exe_Name% ; keep a list for easy checking

     ; Create the new row in the ListView and assign it the icon number determined above:
     LV_Add("Icon" . IconNumber, Window_Loop_Count, A_Space A_Space title, Exe_Name) ; spaces added for layout
    Continue ; begin new loop
    }

    WinGetClass, Win_Class, ahk_id %wid%
    If Win_Class = #32770 ; fix for displaying control panel related windows (dialog class) that aren't on taskbar
      {
      Window_Loop_Count += 1
      IconNumber := IL_Add(ImageListID1, "C:\WINDOWS\system32\shell32.dll" , 217) ; generic control panel icon
      Window%Window_Loop_Count% =%wid% ; store useful windows to new list
      WinGetTitle, title, ahk_id %wid%
      title :=  A_Space A_Space A_Space A_Space A_Space title ; indent listview title text to stand out
      WinGet, Exe_Name, ProcessName, ahk_id %wid%
      LV_Add("Icon" . IconNumber, Window_Loop_Count, A_Space A_Space title, Exe_Name)
      }
    }

  LV_ModifyCol(1, 22) ; resize listview column to show only icon, not number
  LV_ModifyCol(2, 400)
  LV_ModifyCol(3, 148)

  Listview_Rows := LV_GetCount()
  Listview_Height :=Listview_Rows * 21 + 24 ; height of rows + column headings
  Gui_Height := Listview_Height +10
  GuiControl, Move, ListView1, h%Listview_Height%
  Gui, Show, h%Gui_Height%
Return



;====================================================================



ListView_Event:
  If A_GuiEvent = Normal ; activate clicked window
    {
    Gosub, ListView_Destroy
    }
Return



ListView_Destroy:
  Critical
  Hotkey, *~LAlt Up, Off
  Hotkey, !Esc, Alt_Esc, Off
  Selected_Row := LV_GetNext(0, "F")
  LV_GetText(RowText, Selected_Row)  ; Get the row's first-column text.
  wid := Window%RowText%
  Gui, Submit
  IL_Destroy(ImageListID1) ; destroy gui, listview and associated icon imagelist.
  LV_Delete()
  GUI, Destroy
  WinActivate, ahk_id %wid%
  Display_List_Shown =0
Return



GuiClose:
  Gosub, Alt_Esc
Return
