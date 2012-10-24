#INCLUDE "..\lib.9\base_app.h"
LPARAMETERS toExcel, toBook, tcStoreToFolder, tcNameFile
LOCAL lobook, loexc, loTerm as Object
	loTerm = NEWOBJECT("Thermometer", "..\lib.9\base_gui", '',;
					   "�������� Excel...", 0, 0, '', .T.)
	m.loTerm.Show()

	IF VARTYPE(m.toBook) = 'O'
		IF !EMPTY(m.tcStoreToFolder)
			IF !DIRECTORY(ADDBS(m.tcStoreToFolder), 0)
			*������� ����� � �������� �� ������� ����
				TRY
					MKDIR ADDBS(m.tcStoreToFolder)
				CATCH TO loExc
					MESSAGEBOX("������ ��� ���������� ����� Excel!" + CRLF + m.loExc.Message,;
							   0+48, _screen.Caption)
				ENDTRY
			ENDIF

			TRY
				*������� ����� � ����� �� ���������
				FOR EACH lobook IN m.toExcel.workbooks
					IF UPPER(m.lobook.Name) == m.tcNameFile
						*������� � ������� ��������� � ���
						m.lobook.close(.T.)
					ENDIF
				ENDFOR
				*������� ������ ����
				DELETE FILE (ADDBS(m.tcStoreToFolder) + m.tcNameFile)
				 
			    m.tobook.SaveAs(ADDBS(m.tcStoreToFolder) + m.tcNameFile)
			    m.tobook.close
			CATCH TO loExc
				MESSAGEBOX("������ ��� ���������� ����� Excel!" + CRLF + m.loExc.Message, 0 + 48,;
						   _screen.Caption)
			FINALLY
			    toExcel.Visible = .T.
			ENDTRY
		ENDIF
	ELSE
	    toExcel.Visible = .T.
	ENDIF

	RELEASE m.loTerm