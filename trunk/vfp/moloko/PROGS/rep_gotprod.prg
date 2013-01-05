*отчет за декаду(готовая продукция)
LPARAMETERS tnidorgan as Integer, tddatebeg as Date, tddateend as Date 
LOCAL lcfilnam as String
    WAIT WINDOW NOWAIT "Создание отчета..."
	SET TALK ON

    SELECT PAS.ID_PRO, PRO.COMMENT AS NAME, SUM(KOLGOT) as kolgot, SUM(KOLGOT) as kolupack, .f. as group;
    FROM PAS LEFT JOIN EDIZM ON EDIZM.ID = PAS.ID_TARA;
    		 LEFT JOIN PRO ON PRO.ID == PAS.ID_PRO INTO CURSOR PRINT_REP READWRITE;
    WHERE BETWEEN(PAS.DATE, m.tddatebeg, m.tddateend);
    	  AND IIF(!EMPTY(m.tnidorgan), PAS.ID_ORGAN = m.tnidorgan, .T.);
    GROUP BY PAS.ID_PRO, PRO.COMMENT;
    ORDER BY 2

	SET TALK OFF

	LOCAL lnI, lnkolgot
	LOCAL ARRAY lapro[1]
	lnI=1
	
	SELECT PRO
	SCAN FOR !EMPTY(PARENT)
		ALINES(lapro, PARENT, 4, ' ')
		lnkolgot=0

		FOR lnI = 1 TO ALEN(lapro, 1)
			SELECT SUM(KOLGOT) as kolgot;
			FROM PAS LEFT JOIN EDIZM ON EDIZM.ID = PAS.ID_TARA INTO CURSOR SUM_PAS;
			WHERE ID_PRO == lapro[m.lnI] AND BETWEEN(PAS.DATE, m.tddatebeg, m.tddateend)
			
			IF _tally <> 0
				lnkolgot = m.lnkolgot + NVL(SUM_PAS.kolgot, 0)
			ENDIF
		ENDFOR
		
		INSERT INTO PRINT_REP (NAME, KOLGOT, KOLUPACK, GROUP);
					   VALUES (PRO.COMMENT, m.lnkolgot, m.lnkolgot, .t.)
	ENDSCAN
	
    WAIT WINDOW NOWAI "Создание завершено"
