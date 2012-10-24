*Dictionary Header
***********************************************
* Определение класса хидера
DEFINE CLASS standart_dictionary_grdhdr AS Header
	Alignment = 2
	ToolTipText = ""
	FontBold = .T.
	FontName = "Ms Sans Serif"
	FontSize = 8
	WordWrap = .T.
	Caption = ""
*!*		Name = "Header1"
	cNthgPicture = ""
	cAscPicture = "..\bmp\16x16\sort_ascending.bmp"
	cDescPicture = "..\bmp\16x16\sort_descending.bmp"
	cNthgBackColor = RGB(182, 202, 234)
	cAscBackColor = RGB(182, 202, 234)
	cDescBackColor = RGB(182, 202, 234)
	cSorting = "NOTHING"
	nBackColor = .NULL.
	nForeColor = .NULL.
	* Сохраняем цвет хидера и цвет текста хидера
	PROCEDURE Init
		THIS.cNthgBackColor = THIS.BackColor
		THIS.nBackColor = THIS.BackColor
		THIS.nForeColor = THIS.ForeColor
	ENDPROC

	PROCEDURE MouseDown
	LPARAMETERS tnButton, tnShift, tnXCoord, tnYCoord
	LOCAL lnWhere_Out as Integer, lnRelRow_Out as Integer, lnRelCol_Out as Integer, lnView_Out as Integer
		IF m.tnButton = 1
			THIS.PARENT.PARENT.GridHitTest(m.tnXCoord, m.tnYCoord, @m.lnWhere_Out, @m.lnRelRow_Out,;
										   @m.lnRelCol_Out, @m.lnView_Out)
			THISFORM.shapegrid.nActRow = IIF(THIS.PARENT.PARENT.RELATIVEROW = 0,;
											 1,;
											 THIS.PARENT.PARENT.RELATIVEROW)
			THISFORM.shapegrid.nActCol = m.lnRelCol_Out
		ENDIF
	ENDPROC 

	PROCEDURE Click
	LOCAL lnLId as Integer, lnOldRecno as Integer
		WITH THIS.PARENT.PARENT
			DO CASE
			CASE THISFORM.shapegrid.nActRow = 1 AND THISFORM.shapegrid.nActCol = 1
			CASE THISFORM.shapegrid.nActRow > 0 AND THISFORM.shapegrid.nActCol > 0
				.ActivateCell(THISFORM.shapegrid.nActRow, THISFORM.shapegrid.nActCol)
				.SetFocus()

				IF !(.LeftColumn = 1 AND THISFORM.shapegrid.nActCol = 1)
					LOCAL loC as Column, lcAscDesc as String
					lcAscDesc = ''

					IF m.goApp.oFunction.GetWordCount(THISFORM.cSQLOrder, ',') = 1;
					   AND THISFORM.shapegrid.nActCol = VAL(ALLTRIM(THISFORM.cSQLOrder))
						DO CASE
						CASE UPPER(m.goApp.oFunction.getWordNum(THISFORM.cSQLOrder, 2)) = "ASC"
							lcAscDesc = " DESC"
						CASE UPPER(m.goApp.oFunction.getWordNum(THISFORM.cSQLOrder, 2)) = "DESC"
							lcAscDesc = ''
						ENDCASE
					ELSE
						lcAscDesc = " ASC"
					ENDIF

					THISFORM.cSQLOrder = IIF(!EMPTY(m.lcAscDesc),;
											 LTRIM(TRANSFORM(.LeftColumn + THISFORM.shapegrid.nActCol - 1 ));
											 + m.lcAscDesc,;
											 THISFORM.cbackupSQLOrder)

					THISFORM.LockScreen = .T.

					SELECT (THISFORM.cSQLCursorName)
					lnLId = LID
					lnOldRecno = IIF(BOF() OR EOF(), 0, RECNO())

					THISFORM.SQLRequery()

					THISFORM.GrdDict.GrdPnl.ActivateCell(1, THISFORM.GrdDict.nOldColumn)

					LOCATE FOR ID = m.lnLId

					IF !FOUND()
						IF BETWEEN(m.lnOldRecno, 1, RECCOUNT())
							GO m.lnOldRecno
						ELSE
							GO BOTTOM
						ENDIF
					ENDIF

					THISFORM.GrdDict.Refresh()

					IF THISFORM.lEnableTree
						THISFORM.BuildTree()
					ENDIF

					THISFORM.LockScreen = .F.

					FOR EACH loC IN .Columns
						WITH loC.standart_dictionary_grdhdr1
							IF loC.ColumnOrder = THIS.PARENT.PARENT.LeftColumn;
												 + THISFORM.shapegrid.nActCol - 1
								DO CASE
								CASE m.lcAscDesc = " ASC"
									.BackColor = .cAscBackColor
									.Picture = .cAscPicture
								CASE m.lcAscDesc = " DESC"
									.BackColor = .cDescBackColor
									.Picture = .cDescPicture
								OTHERWISE
									.BackColor = .cNthgBackColor
									.Picture = .cNthgPicture
								ENDCASE
							ELSE
								.BackColor = .cNthgBackColor
								.Picture = .cNthgPicture
							ENDIF
						ENDWITH
					ENDFOR
				ENDIF
			OTHERWISE
				THISFORM.shapegrid.nActRow = 0
				THISFORM.shapegrid.nActCol = 0
			ENDCASE
		ENDWITH
	ENDPROC

*!*	  * Делаем всплывающее меню по правому клику.
*!*	  PROCEDURE RightClick
*!*	    LOCAL lnBar, lnClick, lnI, lnK, lcTHISName
*!*	    DEFINE POPUP MyRightClick SHORTCUT FROM MROW(),MCOL()
*!*	      DEFINE BAR 1 OF MyRightClick PROMPT "По возрастанию" ;
*!*	        PICTURE "bmp\hedtopPopUp.bmp"
*!*	      DEFINE BAR 2 OF MyRightClick PROMPT "По убыванию" ;
*!*	        PICTURE "bmp\hedbottomPopUp.bmp"
*!*	      DEFINE BAR 3 OF MyRightClick PROMPT "Убрать сортировку" ;
*!*	        PICTURE "bmp\nohed.bmp"
*!*	      DEFINE BAR 4 OF MyRightClick PROMPT "\-"
*!*	      DEFINE BAR 5 OF MyRightClick PROMPT "Зафиксировать столбец" ;
*!*	        PICTURE "bmp\Loced.bmp"
*!*	      DEFINE BAR 6 OF MyRightClick PROMPT "Убрать фиксацию" ;
*!*	        PICTURE "bmp\NoLoced.bmp"
*!*	    ****************************
*!*	      DEFINE BAR 7 OF MyRightClick PROMPT "\-"
*!*	      DEFINE BAR 8 OF MyRightClick PROMPT "Столбцы"
*!*	      ON BAR 8 OF MyRightClick ACTIVATE POPUP MyColumns
*!*	      DEFINE POPUP MyColumns SHORTCUT RELATIVE
*!*	      FOR lnI = 1 TO THIS.Parent.Parent.ColumnCount
*!*	        FOR lnK = 1 TO THIS.Parent.Parent.Columns(lnI).ControlCount
*!*	          IF THIS.Parent.Parent.Columns(lnI).Controls(lnK).BaseClass =  = "Header"
*!*	            lcTHISName = THIS.Parent.Parent.Columns(lnI).Controls(lnK).Name
*!*	            EXIT
*!*	           endIF
*!*	        endFOR
*!*	        DEFINE BAR (lnI+8) OF MyColumns ;
*!*	          PROMPT (THIS.Parent.Parent.Columns(lnI).&lcTHISName..Caption)
*!*	        IF THIS.Parent.Parent.Columns(lnI).Visible
*!*	          SET MARK OF BAR (lnI+8) OF MyColumns TO .T.
*!*	        ELSE
*!*	          SET MARK OF BAR (lnI+8) OF MyColumns TO .F.
*!*	        endIF
*!*	      endFOR
*!*	    ****************************
*!*	      ON SELECTION POPUP MyRightClick DEACTIVATE POPUP
*!*	      ON SELECTION POPUP MyColumns DEACTIVATE POPUP
*!*	    *******************************
*!*	    ACTIVATE POPUP MyRightClick
*!*	    lnBar = BAR()
*!*	    DO CASE
*!*	      CASE lnBar = 0
*!*	      CASE lnBar = 1
*!*	        THIS.cAscending = "ASCENDING"
*!*	        THIS.lTopBottom = .F.
*!*	        THIS.Click()
*!*	      CASE lnBar = 2
*!*	        THIS.cAscending = "DESCENDING"
*!*	        THIS.lTopBottom = .T.
*!*	        THIS.Click()
*!*	      CASE lnBar = 3
*!*	        THIS.cAscending = "NOSORT"
*!*	        THIS.lTopBottom = .F.
*!*	        THIS.Click()
*!*	      CASE lnBar = 5
*!*	        THIS.Parent.Parent.LockColumns = THIS.Parent.ColumnOrder
*!*	      CASE lnBar = 6
*!*	        THIS.Parent.Parent.LockColumns = 0
*!*	      CASE lnBar>8
*!*	        lnBar = lnBar-8
*!*	        lnK = 0
*!*	        FOR lnI = 1 TO THIS.Parent.Parent.ColumnCount
*!*	          IF THIS.Parent.Parent.Columns(lnI).Visible
*!*	            lnK = lnK+1
*!*	          endIF
*!*	        endFOR
*!*	        IF lnK = 1
*!*	          IF NOT THIS.Parent.Parent.Columns(lnBar).Visible
*!*	            THIS.Parent.Parent.Columns(lnBar).Visible = .T.
*!*	          ELSE
*!*	            WAIT WINDOW "Нельзя скрыть последний столбец"
*!*	          endIF
*!*	        ELSE
*!*	          IF THIS.Parent.Parent.Columns(lnBar).Visible
*!*	            THIS.Parent.Parent.Columns(lnBar).Visible = .F.
*!*	          ELSE
*!*	            THIS.Parent.Parent.Columns(lnBar).Visible = .T.
*!*	          endIF
*!*	        endIF
*!*	      OTHERWISE
*!*	        WAIT WINDOW "Опачки! Чето тут не то!!!"
*!*	    endCASE
*!*	    RELEASE POPUPS MyColumns
*!*	    RELEASE POPUPS MyRightClick
*!*	  ENDPROC
ENDDEFINE