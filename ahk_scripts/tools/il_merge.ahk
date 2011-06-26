 IL_Merge(il1, il2)
{
DllCall("LoadLibrary", "str", "Comctl32")

count1 := DllCall("Comctl32.dll\ImageList_GetImageCount", "uint", il1)
count2 := DllCall("Comctl32.dll\ImageList_GetImageCount", "uint", il2)
DllCall("Comctl32.dll\ImageList_SetImageCount", "uint", il1, "uint", count1 + count2)

Loop %count2%
   {
   hIcon := DllCall("Comctl32.dll\ImageList_GetIcon", "uint", il2, "int", A_Index - 1, "uint", 0)
   DllCall("Comctl32.dll\ImageList_ReplaceIcon", "uint", il1, "int", count1 + A_Index - 1, "uint", hIcon)
   }
 }
 
 
 ;;example
 
;  Gui, Add, ListView, w400 h600, icons
; Loop 2
;    {
;    ImageListID_%A_Index% := IL_Create()
;    i := A_Index
;    Loop 5
;       IL_Add(ImageListID_%i%, "shell32.dll", A_Index + 5 * i)
;    }
; IL_Merge(ImageListID_1, ImageListID_2)
; LV_SetImageList(ImageListID_1)

; Loop 10
;     LV_Add("Icon" . A_Index, A_Index)

; Gui Show
