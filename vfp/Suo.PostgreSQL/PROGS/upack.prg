*!*	PROCEDURE upack
LOCAL llfouerr as Logical, lnI as Integer 
LOCAL ARRAY lamastable[1]
	m.goApp.Function.CloseAllWindows()
	llfouerr=.f.
	lnI=1
	*
	closeBase()
	TRY
		WAIT WINDOWS "Упаковка файлов" NOWAIT
		*
		SELECT 0
		USE m.goApp.cDBPath+m.goApp.cDBName EXCLUSIVE ALIAS "DSTR"
		SCAN FOR OBJECTTYPE="Table"
			lamastable[m.lnI]=ALLTRIM(DSTR.OBJECTNAME)+".DBF"
			lnI=m.lnI+1
			DIMENSION lamastable[m.lnI]
		ENDSCAN
		*
		USE IN DSTR
		FOR lnI=1 TO ALEN(lamastable,1)
			IF !EMPTY(lamastable[m.lnI])
				TRY
					USE (m.goApp.cDBPath+m.goApp.cDBName+lamastable[m.lnI]) EXCLUSIVE
					PACK
					USE
					*
					WAIT WINDOWS "Упаковка файла "+lamastable[m.lnI]+" завершена!" NOWAIT 
				CATCH
					llfouerr=.t.
					WAIT WINDOWS "Ошибка открытия файла "+lamastable[m.lnI]+'!' &&NOWAIT 
				ENDTRY
			ENDIF
		ENDFOR
	CATCH
		llfouerr=.t.
	ENDTRY 
	*
	IF !m.llfouerr
		WAIT WINDOWS "Упаковка файлов завершена!" &&NOWAIT
	ELSE
		WAIT WINDOWS "Ошибка открытия базы!" &&NOWAIT
	ENDIF
	*
	closeBase()
RETURN