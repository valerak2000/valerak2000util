LPARAMETERS tnx as Integer, tny as Integer
	IF VARTYPE(m.tnx) = 'N' AND VARTYPE(m.tny) = 'N'
		MOUSE AT m.tny, m.tnx PIXELS
		INKEY(.05)
	ENDIF

	DEFINE POPUP shortcut SHORTCUT RELATIVE FROM MROW(), MCOL()

	DEFINE BAR _med_undo OF shortcut PROMPT "Отменить" ;
		KEY CTRL+R, "Ctrl+R" ;
		PICTURE "..\bmp\16x16\undo.bmp" ;
		MESSAGE "Отменить последнее действие"

	DEFINE BAR _med_redo OF shortcut PROMPT "Повторить" ;
		KEY CTRL+Z, "Ctrl+Z" ;
		PICTURE "..\bmp\16x16\redo.bmp" ;
		MESSAGE "Повторить последнее действие"

	DEFINE BAR 3 OF shortcut PROMPT "\-"

	DEFINE BAR _med_cut OF shortcut PROMPT "Вырезать" ;
		KEY CTRL+X, "Ctrl+X" ;
		PICTURE "..\bmp\16x16\cut.bmp" ;
		MESSAGE "Сохранить в буфер обмена и удалить"

	DEFINE BAR _med_copy OF shortcut PROMPT "Копировать" ;
		KEY CTRL+C, "Ctrl+C" ;
		PICTURE "..\bmp\16x16\copy.bmp" ;
		MESSAGE "Сохранить в буфер обмена"

	DEFINE BAR _med_paste OF shortcut PROMPT "Вставить" ;
		KEY CTRL+V, "Ctrl+V" ;
		PICTURE "..\bmp\16x16\paste.bmp" ;
		MESSAGE "Вставить из буфера обмена"

	DEFINE BAR 7 OF shortcut PROMPT "\-"

	DEFINE BAR _med_clear OF shortcut PROMPT "Очистить" ;
		PICTRES _med_clear ;
		MESSAGE "Очистить выделенное и не помещать его в буфкр обмена"

	DEFINE BAR _med_slcta OF shortcut PROMPT "Выделить всё" ;
		KEY CTRL+A, "Ctrl+A" ;
		PICTRES _med_slcta ;
		MESSAGE "Пометить весь текст"

	ACTIVATE POPUP shortcut