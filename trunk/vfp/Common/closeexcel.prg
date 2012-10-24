#INCLUDE "..\lib.9\base_app.h"
LPARAMETERS toExcel, toBook, tcStoreToFolder, tcNameFile
LOCAL lobook, loexc, loTerm as Object
	loTerm = NEWOBJECT("Thermometer", "..\lib.9\base_gui", '',;
					   "Закрытие Excel...", 0, 0, '', .T.)
	m.loTerm.Show()

	IF VARTYPE(m.toBook) = 'O'
		IF !EMPTY(m.tcStoreToFolder)
			IF !DIRECTORY(ADDBS(m.tcStoreToFolder), 0)
			*создать папку с отчетами за текущую дату
				TRY
					MKDIR ADDBS(m.tcStoreToFolder)
				CATCH TO loExc
					MESSAGEBOX("Ошибка при сохранении книги Excel!" + CRLF + m.loExc.Message,;
							   0+48, _screen.Caption)
				ENDTRY
			ENDIF

			TRY
				*закрыть книгу с таким же названием
				FOR EACH lobook IN m.toExcel.workbooks
					IF UPPER(m.lobook.Name) == m.tcNameFile
						*закрыть с записью изменений в ней
						m.lobook.close(.T.)
					ENDIF
				ENDFOR
				*удалить старый файл
				DELETE FILE (ADDBS(m.tcStoreToFolder) + m.tcNameFile)
				 
			    m.tobook.SaveAs(ADDBS(m.tcStoreToFolder) + m.tcNameFile)
			    m.tobook.close
			CATCH TO loExc
				MESSAGEBOX("Ошибка при сохранении книги Excel!" + CRLF + m.loExc.Message, 0 + 48,;
						   _screen.Caption)
			FINALLY
			    toExcel.Visible = .T.
			ENDTRY
		ENDIF
	ELSE
	    toExcel.Visible = .T.
	ENDIF

	RELEASE m.loTerm