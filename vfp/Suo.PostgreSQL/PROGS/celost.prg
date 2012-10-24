*!*	PROCEDURE celost
*проверка корректности записей
	RETURN &&временно
	*
	SetEnvironment()
	creIndx()
	*
	WAIT WINDOWS "Идет проверка целостности файлов базы данных..." NOWAIT
	IF setBase()
		*спрaвочник товаров
		SELECT 0
		USE DATASTORE!tovar AGAIN ORDER 1 ALIAS to1
		SELECT TOVAR
*!*			IF !SEEK(1)
*!*			    INSERT INTO TO (ID,NAME) VALUE(1,'Пустой')
*!*			ENDIF
		SET RELATION TO ID INTO to1
		SCAN ALL
		    IF RECNO('tovar')#RECNO('to1')
		        DELETE
		    ENDIF
		    IF !DELETED()
		        REPL NAME WITH LTRIM(NAME)
		    ENDIF
		ENDSCAN
		SET RELATION TO
		USE IN TO1
		*
		*спрaвочник контрагентов
		SELECT 0
		USE DATASTORE!ORGAN AGAIN ORDER 1 ALIAS OR1
		SELECT organ
*!*			IF !SEEK(1)
*!*			    INSERT INTO organ (ID,NAME) VALUE(1,'Пустой')
*!*			ENDIF
		SET RELATION TO ID INTO or1
		SCAN ALL
		    IF RECNO("ORGAN")#RECNO('OR1')
		        DELETE
		    ENDIF
		    IF !DELETED()
		        REPL NAME WITH LTRIM(NAME)
		    ENDIF
		ENDSCAN
		SET RELATION TO
		USE IN or1
		*
		SELECT 0
		USE DATASTORE!NAKL AGAIN ORDER 1 ALIAS NAK1
		*упорядочивание номеров накладных
		SELECT nakl
		SET RELATION TO ID INTO NAK1, id_pas INTO PASSW ADDI
		SCAN ALL
		    IF id_organ=0
		        REPL id_organ WITH 1
		    ENDIF
		    IF RECNO('NAKL')#RECNO('NAK1') OR (id_pas#0 AND EOF('PASSW')) OR ID=0
		        DELETE
		    ENDIF
		    IF !DELETED()
		        REPL nomer WITH TRANSFORM(VAL(nomer),"9999999999")
		    ENDIF
		ENDSCAN
		SET RELATION TO
		USE IN nak1
		*содержимое накладных
		SELECT nakl_cont
		SET RELATION TO id_nak INTO nakl, id_tovar INTO tovar ADDI
		SET RELATION TO ID_EDZ INTO edizm ADDI
		SCAN ALL
		    IF id_tovar=0
		        REPL id_tovar WITH 1
		    ENDIF
		    IF ID_EDZ=0
		        REPL ID_EDZ WITH 1
		    ENDIF
		    IF EOF('nakl')
		        DELETE
		    ENDIF
		    IF !DELETED() AND EOF('tovar')
		        REPL id_tovar WITH 1
		    ENDIF
		    IF !DELETED() AND EOF('edizm')
		        REPL ID_EDZ WITH 1
		    ENDIF
		ENDSCAN
		SET RELATION TO
		*паспорта
		SELECT 0
		USE DATASTORE!PASSW AGAIN ORDER 1 ALIAS pas1
		SELECT passw
		SET RELATION TO ID INTO pas1
		SCAN ALL
		    IF id_organ=0
		        REPL id_organ WITH 1
		    ENDIF
		    IF ID_EDZ=0
		        REPL ID_EDZ WITH 1
		    ENDIF
		    IF RECNO('passw')#RECNO('pas1')
		        DELETE
		    ENDIF
*!*			    IF !DELETED() AND ID=1
*!*			        DELETE
*!*			    ENDIF
		    IF !DELETED()
		        REPL nomer WITH TRANSFORM(VAL(nomer),"9999999999")
		    ENDIF
		ENDSCAN
		SET RELATION TO
		USE IN pas1
		*группир.паспорта
		SELECT 0
		USE DATASTORE!grpassw AGAIN ORDER 1 ALIAS grpas1
		SELECT grpassw
		SET RELATION TO ID INTO grpas1
		SCAN ALL
		    IF ID_EDZ=0
		        REPL ID_EDZ WITH 1
		    ENDIF
		    IF RECNO('grpassw')#RECNO('grpas1')
		        DELETE
		    ENDIF
*!*			    IF !DELETED() AND ID=0
*!*			        DELETE
*!*			    ENDIF
		    IF !DELETED()
		        REPL nomer WITH TRANSFORM(VAL(nomer),"9999999999")
		    ENDIF
		ENDSCAN
		SET RELATION TO
		USE IN grpas1
		*остатки
		SELECT 0
		USE DATASTORE!OSTAT AGAIN ORDER 1 ALIAS ost1
		SELECT OSTAT
		SET RELATION TO DTOS(DATE)+TRANSFORM(ID_TOVAR,"9999999999") INTO ost1
		SCAN ALL
		    IF RECNO('OSTAT')#RECNO('ost1')
		        DELETE
		    ENDIF
		ENDSCAN
		SET RELATION TO
		USE IN ost1
		*
		WAIT WINDOWS 'Проверка целостности файлов базы данных окончена!' NOWAIT
	ENDIF
	*
	CLOSE DATABASES ALL
RETURN