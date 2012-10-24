DEFINE CLASS sfmenu_app AS sfmenu OF SFMenu.vcx
	Name = "sfmenu_app"

	PROCEDURE addpad
		lparameters tcClass,  tcLibrary,  tcName
		local loPad, ;
			lnCount, ;
			loOtherPad
		NODEFAULT

		with This

		* Add a pad of the desired class and name to the menu.

			if '\' + upper(tcLibrary) $ upper(set('CLASSLIB'))
				loPad = createobject(tcClass, tcName)
			else
				loPad = newobject(tcClass, tcLibrary, '', tcName)
			endif '\' + upper(tcLibrary) $ upper(set('CLASSLIB'))
		*!*		loPad = Container::CreateObject(m.tcName, m.tcClass)

			loPad.oParent = This
			.AddProperty(tcName, loPad)

		* Add the pad to the collection.

			.Add(loPad, tcName)
			lnCount = .Count
			do case

		* If this is the second item in the menu, tell the first item to display BEFORE
		* this item and this item to display AFTER that item.

				case lnCount = 2
					loOtherPad = .Item(1)
					loOtherPad.cPadPosition = 'before ' + tcName
					loPad.cPadPosition = 'after ' + loOtherPad.Name

		* If there are more than 2 items in the menu, this item will be displayed AFTER
		* the previous one.

				case lnCount > 2
					loOtherPad = .Item(lnCount - 1)
					loPad.cPadPosition = 'after ' + loOtherPad.Name
			endcase
		endwith
		return loPad
	ENDPROC

	PROCEDURE definemenu
		This.AddPad('SFEditPad', 'SFMenu_app.prg', 'EditPad')
		This.AddPad('SFFacePad', 'SFMenu_app.prg', 'FacePad')
		This.AddPad('SFReportsPad', 'SFMenu_app.prg', 'ReportsPad')
		This.AddPad('SFServicePad', 'SFMenu_app.prg', 'ServicePad')
		This.AddPad('SFTuningPad', 'SFMenu_app.prg', '_mn_settings')
		This.AddPad('SFHelpPad', 'SFMenu_app.prg', '_mn_help')
		This.AddPad('SFWindowsPad', 'SFMenu_app.prg', '_mn_window')
		This.AddPad('SFExitPad', 'SFMenu_app.prg', 'ExitPad')
	ENDPROC
ENDDEFINE

DEFINE CLASS sfmrubar AS sfmrubar OF SFMenu.vcx
	cmrubarlibrary = "SFMenu_app.prg"
	Name = "sfmrubar"
ENDDEFINE

DEFINE CLASS sfpad AS sfpad OF SFMenu.vcx
	cmrubarlibrary = "SFMenu_app.prg"
	Name = "sfpad"
ENDDEFINE

DEFINE CLASS sfeditpad AS sfeditpad OF SFMenu.vcx
	cmrubarlibrary = "SFMenu_app.prg"
	ccaption = "\<Правка"
	ckey = "ALT+G"
	Name = "sfeditpad"

	PROCEDURE addbars
		NODEFAULT

		WITH THIS
			.AddBar('SFBar', 'SFMenu_app.prg', 'EditUndo')
			WITH .EditUndo
				.cCaption       = 'Отменить'
				.cKey           = 'CTRL+Z'
				.cKeyText       = 'Ctrl+Z'
				.cStatusBarText = 'Отменить последнее действие'
				.cSystemBar     = '_med_undo'
				.cPictureFile   = '..\bmp\16x16\undo.bmp'
			ENDWITH

			.AddBar('SFBar', 'SFMenu_app.prg', 'EditRedo')
			WITH .EditRedo
				.cCaption       = 'Повторить'
				.cKey           = 'CTRL+R'
				.cKeyText       = 'Ctrl+R'
				.cStatusBarText = 'Повторить последнее действие'
				.cSystemBar     = '_med_redo'
				.cPictureFile   = '..\bmp\16x16\redo.bmp'
			ENDWITH

			.AddSeparatorBar()

			.AddBar('SFBar', 'SFMenu_app.prg', 'EditCut')
			WITH .EditCut
				.cCaption       = 'Вырезать'
				.cKey           = 'CTRL+X'
				.cKeyText       = 'Ctrl+X'
				.cStatusBarText = "Сохранить в буфер обмена и удалить"
				.cSystemBar     = '_med_cut'
				.cPictureFile   = '..\bmp\16x16\cut.bmp'
			ENDWITH

			.AddBar('SFBar', 'SFMenu_app.prg', 'EditCopy')
			WITH .EditCopy
				.cCaption       = 'Копировать'
				.cKey           = 'CTRL+C'
				.cKeyText       = 'Ctrl+C'
				.cStatusBarText = "Сохранить в буфер обмена"
				.cSystemBar     = '_med_copy'
				.cPictureFile   = '..\bmp\16x16\copy.bmp'
			ENDWITH

			.AddBar('SFBar', 'SFMenu_app.prg', 'EditPaste')
			WITH .EditPaste
				.cCaption       = 'Вставить'
				.cKey           = 'CTRL+V'
				.cKeyText       = 'Ctrl+V'
				.cStatusBarText = "Вставить из буфера обмена"
				.cSystemBar     = '_med_paste'
				.cPictureFile   = '..\bmp\16x16\paste.bmp'
			ENDWITH

			.AddBar('SFBar', 'SFMenu_app.prg', 'EditClear')
			WITH .EditClear
				.cCaption       = 'Очистить'
				.cStatusBarText = "Очистить выделенное и не помещать его в буфер обмена"
				.cSystemBar     = '_med_clear'
				.cSkipFor       = 'empty(wontop())'
			ENDWITH

			.AddBar('SFBar', 'SFMenu_app.prg', 'EditSelectAll')
			WITH .EditSelectAll
				.cCaption       = 'Выделить всё'
				.cKey           = 'CTRL+A'
				.cKeyText       = 'Ctrl+A'
				.cStatusBarText = "Пометить весь текст"
				.cSystemBar     = '_med_slcta'
			ENDWITH

			.AddSeparatorBar()

			.AddBar('SFBar', 'SFMenu_app.prg', 'Find')
			WITH .Find
				.cCaption       = 'Найти...'
				.cKey           = 'CTRL+F'
				.cKeyText       = 'Ctrl+F'
				.cStatusBarText = "Найти текст"
				.cPictureFile   = '..\bmp\16x16\find.bmp'
				.cOnClickCommand = 'm.goApp.OnMenuEvents("Find")'
			ENDWITH

			.AddBar('SFBar', 'SFMenu_app.prg', 'FindAndReplace')
			WITH .FindAndReplace
				.cCaption       = 'Заменить...'
				.cKey           = 'CTRL+L'
				.cKeyText       = 'Ctrl+L'
				.cStatusBarText = "Найти и заменить текcт"
				.cPictureFile   = '..\bmp\16x16\replace.bmp'
				.cOnClickCommand = 'm.goApp.OnMenuEvents("Replace")'
			ENDWITH
		ENDWITH
	ENDPROC
ENDDEFINE

DEFINE CLASS sfhelptopicsbar AS sfhelptopicsbar OF SFMenu.vcx
	cmrubarlibrary = "SFMenu_app.prg"
	ccaption = "По\<мощь"
	Name = "sfhelptopicsbar"
ENDDEFINE

DEFINE CLASS sfexitpad AS sfpad OF SFMenu.vcx
	ccaption = "Вы\<ход"
	Name = "sfexitpad"

	PROCEDURE addbars
		WITH THIS
			.AddBar("SFBar", "SFMenu_app.prg", "ExitBar")
			WITH .ExitBar
				.cCaption        = "Вы\<ход"
				.cKey            = "ALT+X"
				.cKeyText        = "ALT+X"
				.cStatusBarText  = ''
				.cPictureFile    = ''
				.cOnClickCommand = "m.goApp.Vars.oMenu.Release()"+CHR(13)+"CLEAR EVENTS"
			ENDWITH
		ENDWITH
	ENDPROC
ENDDEFINE

DEFINE CLASS sffacepad AS sfpad OF SFMenu.vcx
	ccaption = "\<Вид"
	ckey = "ALT+D"
	Name = "sffacepad"

	PROCEDURE addbars
		THIS.AddBar('SFBar', 'SFMenu_app.prg', 'ToolBarPad')

		WITH THIS.ToolBarPad
			.cCaption       = '\<Панели инструментов'
			.cKey           = 'ALT+G'
			.cStatusBarText = ''

			IF m.goApp.Vars.lToolBar
				.AddBar('SFBar', 'SFMenu_app.prg', 'EditBar')
				WITH .EditBar
					.cCaption        = '\<Правка'
					.cKey            = 'CTRL+G'
					.cKeyText        = 'Ctrl+G'
					.cStatusBarText  = ''
					.cPictureFile    = ''
					.cOnClickCommand = 'm.goApp.OnMenuEvents("TBEdit")'
				ENDWITH

				.AddBar('SFBar', 'SFMenu_app.prg', 'ToolBar')
				WITH .ToolBar
					.cCaption        = '\<Инструменты'
					.cKey            = 'ALT+B'
					.cKeyText        = 'ALT+B'
					.cStatusBarText  = ''
					.cPictureFile    = ''
					.cOnClickCommand = 'm.goApp.OnMenuEvents("TBTools")'
				ENDWITH

				.AddBar('SFBar', 'SFMenu_app.prg', 'ServiceBar')
				WITH .ServiceBar
					.cCaption        = '\<Сервис'
					.cKey            = 'ALT+T'
					.cKeyText        = 'ALT+T'
					.cStatusBarText  = ''
					.cPictureFile    = ''
					.cOnClickCommand = 'm.goApp.OnMenuEvents("TBService")'
				ENDWITH

				.AddBar('SFBar', 'SFMenu_app.prg', 'BaseTuningBar')
				WITH .BaseTuningBar
					.cCaption        = '\<Настройки'
					.cKey            = 'ALT+Y'
					.cKeyText        = 'ALT+Y'
					.cStatusBarText  = ''
					.cPictureFile    = ''
					.cOnClickCommand = 'm.goApp.OnMenuEvents("TBBaseTuning")'
				ENDWITH

				.AddBar('SFBar', 'SFMenu_app.prg', 'ActivityBar')
				WITH .ActivityBar
					.cCaption        = '\<Активность соединения'
					.cKey            = 'CTRL+F'
					.cKeyText        = 'Ctrl+F'
					.cStatusBarText  = ''
					.cPictureFile    = ''
					.cOnClickCommand = 'm.goApp.OnMenuEvents("TBActivity")'
				ENDWITH
			ENDIF

			IF m.goApp.Vars.lTaskBar
				.AddBar('SFBar', 'SFMenu_app.prg', 'TaskBar')
				WITH .TaskBar
					.cCaption        = '\<Окна'
					.cKey            = 'ALT+J'
					.cKeyText        = 'ALT+J'
					.cStatusBarText  = ''
					.cPictureFile    = ''
					.cOnClickCommand = 'm.goApp.OnMenuEvents("TBTaskBar")'
				ENDWITH
			ENDIF
		ENDWITH
	ENDPROC
ENDDEFINE

DEFINE CLASS sfhelppad AS sfpad OF SFMenu.vcx
	ccaption = "По\<мощь"
	ckey = "ALT+V"
	Name = "sfhelppad"

	PROCEDURE addbars
		WITH THIS
			.AddSeparatorBar()

			.AddBar('SFBar', 'SFMenu_app.prg', 'AboutBar')
			WITH .AboutBar
				.cCaption       = 'О программе'
				.cKey           = ''
				.cKeyText       = ''
				.cStatusBarText = ""
				.cPictureFile   = '..\bmp\information.ico'
				.cOnClickCommand = 'DO about'
			ENDWITH
		ENDWITH
	ENDPROC
ENDDEFINE

DEFINE CLASS sfreportspad AS sfpad OF SFMenu.vcx
	ccaption = "О\<тчеты"
	ckey = "ALT+N"
	Name = "sfreportspad"
ENDDEFINE

DEFINE CLASS sfservicepad AS sfpad OF SFMenu.vcx
	ccaption = "С\<ервис"
	ckey = "ALT+T"
	Name = "sfservicepad"

	PROCEDURE addbars
		WITH THIS
			.AddSeparatorBar()

			.AddBar('SFBar', 'SFMenu_app.prg', 'CalendarBar')
			WITH .CalendarBar
				.cCaption       = 'Календарь'
				.cKey           = ''
				.cKeyText       = ''
				.cStatusBarText = ""
				.cPictureFile   = '..\bmp\16x16\calendar.bmp'
				.cOnClickCommand = 'm.goApp.OnMenuEvents("Calendar")'
			ENDWITH

			.AddBar('SFBar', 'SFMenu_app.prg', 'ClockBar')
			WITH .ClockBar
				.cCaption       = 'Часы'
				.cKey           = ''
				.cKeyText       = ''
				.cStatusBarText = ""
				.cPictureFile   = '..\bmp\clock.ico'
				.cOnClickCommand = 'm.goApp.OnMenuEvents("Clock")'
			ENDWITH
		ENDWITH
	ENDPROC
ENDDEFINE

DEFINE CLASS sftuningpad AS sfpad OF SFMenu.vcx
	ccaption = "\<Настройки"
	ckey = "ALT+Y"
	Name = "sftuningpad"
ENDDEFINE

DEFINE CLASS sfwindowspad AS sfpad OF SFMenu.vcx
	ccaption = "\<Окна"
	ckey = "ALT+J"
	Name = "sfwindows"

	PROCEDURE addbars
		WITH THIS
			.AddBar('SFBar', 'SFMenu_app.prg', 'CascadeBar')
			WITH .CascadeBar
				.cCaption        = 'Упорядочить каскадно'
				.cKey            = ''
				.cKeyText        = ''
				.cStatusBarText  = ''
				.cPictureFile    = ''
				.cSystemBar     = '_MWI_CASCADE'
			ENDWITH

			.AddBar('SFBar', 'SFMenu_app.prg', 'ArranBar')
			WITH .ArranBar
				.cCaption        = 'Упорядочить без перекрытия'
				.cKey            = ''
				.cKeyText        = ''
				.cStatusBarText  = ''
				.cPictureFile    = ''
				.cSystemBar     = '_MWI_ARRAN'
			ENDWITH

			.AddSeparatorBar()

			.AddBar('SFBar', 'SFMenu_app.prg', 'HideaBar')
			WITH .HideaBar
				.cCaption        = 'Спрятать все'
				.cKey            = ''
				.cKeyText        = ''
				.cStatusBarText  = "Hides all windows"
				.cPictureFile    = ''
				.cSystemBar     = '_mwi_hidea'
			ENDWITH

			.AddBar('SFBar', 'SFMenu_app.prg', 'HideBar')
			WITH .HideBar
				.cCaption        = 'Спрятать'
				.cKey            = ''
				.cKeyText        = ''
				.cStatusBarText  = "Hides the active window"
				.cPictureFile    = ''
				.cSystemBar     = '_mwi_hide'
			ENDWITH

			.AddBar('SFBar', 'SFMenu_app.prg', 'ShowaBar')
			WITH .ShowaBar
				.cCaption        = 'Показать все'
				.cKey            = ''
				.cKeyText        = ''
				.cStatusBarText  = "Shows all hidden windows"
				.cPictureFile    = ''
				.cSystemBar     = '_mwi_showa'
			ENDWITH

			.AddSeparatorBar()

			.AddBar('SFBar', 'SFMenu_app.prg', 'ClallBar')
			WITH .ClallBar
				.cCaption        = 'Закрыть все'
				.cKey            = ''
				.cKeyText        = ''
				.cStatusBarText  = "Closes all windows"
				.cPictureFile    = ''
				.cSystemBar     = '_mfi_clall'
			ENDWITH

			.AddBar('SFBar', 'SFMenu_app.prg', 'ClallBar')
			WITH .ClallBar
				.cCaption        = '\<Закрыть'
				.cKey            = ''
				.cKeyText        = ''
				.cStatusBarText  = "Closes the current file"
				.cPictureFile    = ''
				.cSystemBar     = '_mfi_close'
			ENDWITH

			.AddSeparatorBar()

			.AddBar('SFBar', 'SFMenu_app.prg', 'RotatBar')
			WITH .RotatBar
				.cCaption        = 'Следующее'
				.cKey            = ''
				.cKeyText        = ''
				.cStatusBarText  = ""
				.cPictureFile    = ''
				.cSystemBar     = '_MWI_ROTAT'
			ENDWITH
		ENDWITH
	ENDPROC
ENDDEFINE

DEFINE CLASS sfseparatorbar AS sfseparatorbar OF SFMenu.vcx
	cmrubarlibrary = "SFMenu_app.prg"
	Name = "sfseparatorbar"
ENDDEFINE
