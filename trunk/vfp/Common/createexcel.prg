LPARAMETERS tlVisible
LOCAL loExcel as Object, loTerm as Object
	loTerm = NEWOBJECT("Thermometer", "..\lib.9\base_gui", '',;
					   "Создание книги в Excel...", 0, 0, '', .T.)
	m.loTerm.Show()

    TRY
	    loExcel = GETOBJECT(, "Excel.Application")
	    loExcel.Visible = m.tlVisible
	CATCH
		loExcel = .NULL.
	ENDTRY

    IF ISNULL(m.loExcel)
	    TRY
    	    loExcel = CREATEOBJECT("Excel.Application")
		    loExcel.Visible = m.tlVisible
		CATCH
			loExcel = .NULL.
		ENDTRY
    ENDIF

	RELEASE m.loTerm
RETURN m.loExcel