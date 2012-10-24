*отчет за декаду(готовая продукция)
LOCAL lcfilnam as String
    WAIT WINDOW NOWAIT "Создание отчета..."
    *
    lcfilnam=SYS(3)
	SET TALK ON
	*
    SELECT PAS.ID_PRO, PRODUCTION.COMMENT AS NAME, SUM(KOLGOT) as kolgot, SUM(KOLGOT) as kolupack, .f. as group;
    FROM PAS LEFT JOIN EDIZM ON EDIZM.ID=PAS.ID_TARA;
    		 LEFT JOIN PRODUCTION ON PRODUCTION.ID==PAS.ID_PRO INTO TABLE (m.lcfilnam);
    WHERE BETWEEN(PAS.DATE,m.gdrepdatebeg,m.gdrepdateend);
    GROUP BY PAS.ID_PRO, PRODUCTION.COMMENT;
    ORDER BY 2
    *
	SET TALK OFF
    *
    USE (m.lcfilnam) EXCLU ALIAS REP_DEK

	LOCAL lnI, lnkolgot
	LOCAL ARRAY lapro[1]
	lnI=1
	
	SELECT PRODUCTION
	SCAN FOR !EMPTY(PARENT)
		ALINES(lapro, PARENT, 4, ' ')
		lnkolgot=0

		FOR lnI=1 TO ALEN(lapro, 1)
			SELECT SUM(KOLGOT) as kolgot;
			FROM PAS LEFT JOIN EDIZM ON EDIZM.ID=PAS.ID_TARA INTO CURSOR SUM_PAS;
			WHERE ID_PRO==lapro[m.lnI] AND BETWEEN(PAS.DATE,m.gdrepdatebeg,m.gdrepdateend)
			
			IF _tally<>0
				lnkolgot=m.lnkolgot+NVL(SUM_PAS.kolgot, 0)
			ENDIF
		ENDFOR
		
		INSERT INTO REP_DEK (NAME, KOLGOT, KOLUPACK, GROUP) VALUES (PRODUCTION.COMMENT, m.lnkolgot, m.lnkolgot, .t.)
	ENDSCAN
	
    WAIT WINDOW NOWAI "Создание завершено"
    SELECT REP_DEK
    GO TOP
    *
	oListener=CREATEOBJECT("ReportListener")
	oListener.ListenerType=1 && Preview, or 0 for Print 
	*
	REPORT FORM (".\GOTPRODUCTION") OBJECT oListener TO PRINTER PROMPT
    *удалить курсор
    IF USED("REP_DEK")
        USE IN REP_DEK
    ENDIF
    DELETE FILE SYS(5)+SYS(2003)+'\'+m.lcfilnam+".DBF"
    
    RELEASE m.oListener