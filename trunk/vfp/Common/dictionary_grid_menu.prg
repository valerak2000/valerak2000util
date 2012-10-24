PARAMETERS toform as Object, tnx as Integer, tny as Integer
	IF VARTYPE(m.tnx)='N' AND VARTYPE(m.tny)='N'
		MOUSE AT m.tny, m.tnx PIXELS
		INKEY(.05)
	ENDIF

	DEFINE POPUP shortcut SHORTCUT FROM MROW(), MCOL()
	DEFINE BAR 1 OF shortcut PROMPT "Создать(элемент)" ;
		SKIP FOR !m.toform.cntToolbars.CntNewFile.enabled ;
		PICTURE "..\bmp\16x16\data_add.bmp"
	DEFINE BAR 2 OF shortcut PROMPT "Создать(папка)" ;
		SKIP FOR !m.toform.cntToolbars.cntNewChild.enabled ;
		PICTURE "..\bmp\16x16\folder_add.bmp"
	DEFINE BAR 3 OF shortcut PROMPT "Редактировать" ;
		SKIP FOR !m.toform.cntToolbars.cntEdit.enabled ;
		PICTURE "..\bmp\16x16\data_edit.bmp"
	DEFINE BAR 4 OF shortcut PROMPT "Удалить" ;
		SKIP FOR !m.toform.cntToolbars.cntDelete.enabled ;
		PICTURE "..\bmp\16x16\data_delete.bmp"
	DEFINE BAR 5 OF shortcut PROMPT "\-"
	DEFINE BAR 6 OF shortcut PROMPT "Просмотр" ;
		SKIP FOR !m.toform.cntToolbars.cntView.enabled ;
		PICTURE "..\bmp\16x16\document_view.bmp"
	DEFINE BAR 7 OF shortcut PROMPT "Печать" ;
		SKIP FOR !m.toform.cntToolbars.cntPrint.enabled ;
		PICTURE "..\bmp\16x16\printer.bmp"
	DEFINE BAR 8 OF shortcut PROMPT "\-"
	DEFINE BAR 9 OF shortcut PROMPT "Потметить/Снять пометку"
	DEFINE BAR 10 OF shortcut PROMPT "Потметить все"
	DEFINE BAR 11 OF shortcut PROMPT "Снять пометку со всех"
	DEFINE BAR 12 OF shortcut PROMPT "Инвертировать пометку"
	DEFINE BAR 13 OF shortcut PROMPT "\-"
	DEFINE BAR 14 OF shortcut PROMPT "Обновить" ;
		SKIP FOR !m.toform.cntToolbars.cntRequery.enabled ;
		PICTURE "..\bmp\16x16\data_refresh.bmp"
	DEFINE BAR 15 OF shortcut PROMPT "Убрать меню"

	ON SELECTION BAR 1 OF shortcut m.toform.cntToolbars.CntNewFile.Click()
	ON SELECTION BAR 2 OF shortcut m.toform.cntToolbars.cntNewChild.Click()
	ON SELECTION BAR 3 OF shortcut m.toform.cntToolbars.cntEdit.Click()
	ON SELECTION BAR 4 OF shortcut m.toform.cntToolbars.cntDelete.Click()
	ON SELECTION BAR 6 OF shortcut m.toform.cntToolbars.cntView.Click()
	ON SELECTION BAR 7 OF shortcut m.toform.cntToolbars.cntPrint.Click()
	ON SELECTION BAR 9 OF shortcut KEYBOARD '{SPACEBAR}'
	ON SELECTION BAR 14 OF shortcut m.toform.cntToolbars.cntRequery.Click()

	ACTIVATE POPUP shortcut