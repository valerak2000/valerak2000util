#include "DataExplorer.h"
#include "foxpro.h"
LOCAL oMenuList
LOCAL oContextMenu
LOCAL i
LOCAL oMenuItem
LOCAL oException
LOCAL oDataExplorerEngine
PRIVATE oForm

oDataExplorerEngine = NEWOBJECT("DataExplorerEngine", "DataExplorerEngine.prg")


oMenuList = oDataExplorerEngine.GetAddIns(DEFTYPE_QUERYADDIN)
oContextMenu = NEWOBJECT("ContextMenu", "foxmenu.prg")

oContextMenu.AddMenu("Cu\<t", _med_cut)
oContextMenu.AddMenu("\<Copy", _med_copy)
oContextMenu.AddMenu("\<Paste", _med_paste)
IF oMenuList.Count > 0
	oContextMenu.AddMenu("\-")
ENDIF


FOR i = 1 TO oMenuList.Count
	oMenuItem = oContextMenu.AddMenu(oMenuList.Item(i).Caption, "oForm.RunQueryAddIn([" + oMenuList.Item(i).UniqueID + "])")
ENDFOR

oForm = THISFORM
TRY
	oContextMenu.Show()
CATCH TO oException
	MESSAGEBOX(SHOWERROR_ADDIN_LOC + CHR(10) + CHR(10) + oException.Message, MB_ICONEXCLAMATION)
ENDTRY
