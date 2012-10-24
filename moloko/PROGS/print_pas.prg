PARAMETERS nom, pri
	*сезонные коэффициенты
    fou=.f.
    *
	SELECT sez
	IF SEEK(pas.id_tara, "sez", "ID_ED")
		SCAN WHILE id_ed=pas.id_tara
			IF BETWEEN(pas.date, bmonth, emonth)
		        fou=.t.
				EXIT 
			ENDIF 
		ENDSCAN 
	ENDIF 
	*
	IF m.fou
		IF EMPTY(m.pri)
			DO FORM selprint
		ELSE
			m.prin_prev=m.pri
		ENDIF
		*
		SELECT pas
		idrr=RECNO()
		IF pas.id_pro='004'
			DO CASE
			CASE prin_prev=1
				REPORT FORM passwsl PREVIEW NOCONSOLE FOR id=m.nom
			CASE prin_prev=2
				REPORT FORM passwsl TO PRINTER PROMPT NOCONSOLE FOR id=m.nom
			ENDCASE
		ELSE
			DO CASE
			CASE prin_prev=1
				REPORT FORM passw PREVIEW NOCONSOLE FOR id=m.nom
			CASE prin_prev=2
				REPORT FORM passw TO PRINTER PROMPT NOCONSOLE FOR id=m.nom
			ENDCASE
		ENDIF
		*
		SELECT pas
		GO m.idrr
	ENDIF
RETURN