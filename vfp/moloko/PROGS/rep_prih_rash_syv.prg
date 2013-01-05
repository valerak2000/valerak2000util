LPARAMETERS tnidtovar as Integer, tddatebeg as Date, tddateend as Date
LOCAL ldI as Date, lnJ as Integer, lnidrash as Integer, lnidprih as Integer, lnI as Integer, llfou as Logical
LOCAL ARRAY laproview[1,4], lasumviewprih[1,2], lasumviewrash[1,2], larcursgroup[1,12]
    WAIT WINDOW NOWAIT "Создание отчета..."

    =SEEK(m.tnidtovar, "TO", "ID")
*!*	    IF SEEK(TOVAR.BASE_EDZ,"EDIZM","ID")
*!*		    baseedname=ALLTRIM(EDIZM.NAME)
*!*		ELSE
	    baseedname="Кг"
*!*		ENDIF

	CREATE CURSOR PRINT_REP (DATE D, KOLN N(13, 6), KOLNSUH N(13, 6),;
							NAME_PRIH C(70), KOL_PRIH N(13, 6), KOLSUH_PRIH N(13, 6),;
							NAME_RASH C(70), KOL_RASH N(13, 6), KOLSUH_RASH N(13, 6),;
							KOLK N(13, 6), KOLKSUH N(13, 6), SOOTN N(13, 6), EDNAME C(30), FLAG N(1))
	INDEX ON DTOS(DATE)+TRANSFORM(FLAG, '9')+IIF(!EMPTY(NAME_PRIH), '0', '9')+IIF(!EMPTY(NAME_RASH), '0', '9')+EDNAME TAG dt

	CREATE CURSOR PRINT_REPPR (DATE D, NAME_PRIH C(70), KOL_PRIH N(13, 6), KOLSUH_PRIH N(13, 6),;
							   KOLED_PRIH N(13, 6), SOOTN N(13, 6), EDNAME C(30))
	INDEX ON DTOS(DATE)+IIF(!EMPTY(NAME_PRIH), '0', '9')+EDNAME TAG dt

	DIMENSION laproview[1, 4], lasumviewprih[1, 2], lasumviewrash[1, 2]

	SELECT DISTINCT 0, NVL(PRO.ID, "000000"), PADR(RTRIM(NVL(PRO.COMMENT, ''))+CHR(13)+RTRIM(NVL(TYPEDOC.NAME, ''))+CHR(13)+RTRIM(NVL(OR.NAME, '')), 70), NVL(EDIZM.ID, 0000000000), NVL(OR.ID, 0000000000), NVL(TYPEDOC.ID, "000000"), NVL(EDIZM.NAME, SPACE(40)), 1;
	FROM NAK RIGHT JOIN PAS ON NAK.ID_PAS=PAS.ID;
			  LEFT JOIN NAKC ON BINTOC(NAKC.ID_NAK)+BINTOC(NAKC.ID_TOVAR)+BINTOC(NAKC.ID_TARA)=BINTOC(NAK.ID)+BINTOC(m.tnidtovar);
			  LEFT JOIN TYPEDOC ON NAK.TYPEDOC==TYPEDOC.ID;
			  LEFT JOIN OR ON NAK.ID_ORGAN=OR.ID;
			  LEFT JOIN PRO ON PAS.ID_PRO = PRO.ID;
			  LEFT JOIN EDIZM ON EDIZM.ID=NAKC.ID_TARA INTO ARRAY laproview;
	WHERE NAK.ID IN (SELECT ID_NAK FROM NAKC WHERE ID_TOVAR=m.tnidtovar) AND BETWEEN(NAK.DATE, m.tddatebeg, m.tddateend);
	UNION ALL;
	SELECT DISTINCT 1, NVL(TYPEDOC.ID, "000000"), PADR(RTRIM(NVL(TYPEDOC.NAME, ''))+CHR(13)+RTRIM(NVL(OR.NAME, '')), 70), NVL(EDIZM.ID,0000000000), NVL(OR.ID, 0000000000), NVL(TYPEDOC.ID, "000000"), NVL(EDIZM.NAME, SPACE(40)), 1;
	FROM NAKC LEFT JOIN EDIZM ON NAKC.ID_TARA=EDIZM.ID;
				   RIGHT JOIN NAK ON NAK.ID=NAKC.ID_NAK AND BETWEEN(NAK.DATE, m.tddatebeg, m.tddateend) AND NAK.ID_PAS=0;
				   LEFT JOIN TYPEDOC ON NAK.TYPEDOC==TYPEDOC.ID;
				   LEFT JOIN OR ON NAK.ID_ORGAN=OR.ID;
    WHERE NAKC.ID_TOVAR=m.tnidtovar

	IF SEEK("Расход", "TYPEDOC", "NAME")&& AND TYPEDOC.PID=0
		lnidrash=RTRIM(TYPEDOC.ID)
	ENDIF

	IF SEEK("Приход", "TYPEDOC", "NAME")&& AND TYPEDOC.PID=0
		lnidprih=RTRIM(TYPEDOC.ID)
	ENDIF

	ldI=m.tddatebeg

	DO WHILE ldI<=m.tddateend
		STORE 0 TO m.koln, m.kolnsuh, m.kolk, m.kolksuh

		FOR lnJ=1 TO ALEN(laproview, 1)
			STORE 0 TO lasumviewprih[1, 1], lasumviewprih[1, 2], lasumviewrash[1, 1], lasumviewrash[1, 2]

			IF VARTYPE(laproview[m.lnJ, 1])='N'
				DO CASE
				CASE laproview[m.lnJ, 1]=0
					IF SEEK(laproview[m.lnJ, 6], "TYPEDOC", "ID") AND TYPEDOC.ID=m.lnidprih
						SELECT SUM(KOL), SUM(KOLSUH);
						FROM NAK LEFT JOIN NAKC ON BINTOC(ID_NAK)+BINTOC(ID_TOVAR)+BINTOC(ID_TARA)=BINTOC(NAK.ID)+BINTOC(m.tnidtovar)+BINTOC(laproview[m.lnJ, 4]) INTO ARRAY lasumviewprih;
						WHERE ID_PAS IN (SELECT ID;
						 			  	 FROM PAS;
						 			  	 WHERE ID_PRO+DTOS(DATE)=laproview[m.lnJ, 2]+DTOS(m.ldI)) AND;
						 	  TYPEDOC+DTOS(DATE)=laproview[m.lnJ, 6]+DTOS(m.ldI) AND ID_ORGAN=laproview[m.lnJ, 5]
					ELSE
						SELECT SUM(KOL), SUM(KOLSUH);
						FROM NAK LEFT JOIN NAKC ON BINTOC(ID_NAK)+BINTOC(ID_TOVAR)+BINTOC(ID_TARA)=BINTOC(NAK.ID)+BINTOC(m.tnidtovar)+BINTOC(laproview[m.lnJ, 4]) INTO ARRAY lasumviewrash;
						WHERE ID_PAS IN (SELECT ID;
						 			  	 FROM PAS;
						 			  	 WHERE ID_PRO+DTOS(DATE)=laproview[m.lnJ, 2]+DTOS(m.ldI)) AND;
						 	  TYPEDOC+DTOS(DATE)=laproview[m.lnJ, 6]+DTOS(m.ldI) AND ID_ORGAN=laproview[m.lnJ, 5]
					ENDIF
				CASE laproview[m.lnJ, 1]=1 AND !ISNULL(laproview[m.lnJ, 2])
					IF SEEK(laproview[m.lnJ, 6], "TYPEDOC", "ID") AND TYPEDOC.ID=m.lnidprih
						SELECT SUM(KOL), SUM(KOLSUH);
						FROM NAK LEFT JOIN NAKC ON BINTOC(ID_NAK)+BINTOC(ID_TOVAR)+BINTOC(ID_TARA)=BINTOC(NAK.ID)+BINTOC(m.tnidtovar)+BINTOC(laproview[m.lnJ, 4]) INTO ARRAY lasumviewprih;
						WHERE TYPEDOC+DTOS(DATE)=laproview[m.lnJ, 6]+DTOS(m.ldI) AND ID_ORGAN=laproview[m.lnJ, 5]
					ELSE
						SELECT SUM(KOL), SUM(KOLSUH);
						FROM NAK LEFT JOIN NAKC ON BINTOC(ID_NAK)+BINTOC(ID_TOVAR)+BINTOC(ID_TARA)=BINTOC(NAK.ID)+BINTOC(m.tnidtovar)+BINTOC(laproview[m.lnJ, 4]) INTO ARRAY lasumviewrash;
						WHERE TYPEDOC+DTOS(DATE)=laproview[m.lnJ, 6]+DTOS(m.ldI) AND ID_ORGAN=laproview[m.lnJ, 5]
					ENDIF
				ENDCASE

				lasumviewprih[1, 1]=NVL(lasumviewprih[1, 1], 0)
				lasumviewrash[1, 1]=NVL(lasumviewrash[1, 1], 0)

				IF lasumviewprih[1, 1]<>0
					lasumviewprih[1, 2]=NVL(lasumviewprih[1, 2], 0)

					INSERT INTO PRINT_REPPR (DATE, NAME_PRIH, KOL_PRIH, KOLSUH_PRIH, SOOTN, EDNAME);
								     VALUES (m.ldI, IIF(lasumviewprih[1, 1]<>0, laproview[m.lnJ, 3], ''), lasumviewprih[1, 1], lasumviewprih[1, 2], laproview[m.lnJ, 8], laproview[m.lnJ, 7])
				ENDIF

				IF lasumviewrash[1, 1]<>0
					lasumviewrash[1, 2]=NVL(lasumviewrash[1, 2], 0)

					INSERT INTO PRINT_REP (DATE, NAME_RASH, KOL_RASH, KOLSUH_RASH, SOOTN, EDNAME);
								   VALUES (m.ldI, IIF(lasumviewrash[1, 1]<>0, laproview[m.lnJ, 3], ''), lasumviewrash[1, 1], lasumviewrash[1, 2], laproview[m.lnJ, 8], laproview[m.lnJ, 7])
				ENDIF
			ENDIF
		ENDFOR

		ldI=m.ldI+1
	ENDDO

	LOCAL lncntrep as Integer,lncntreppr as Integer
	ldI=m.tddatebeg

	DO WHILE ldI<=m.tddateend
		SELECT PRINT_REP
		COUNT TO lncntrep FOR DATE=m.ldI

		SELECT PRINT_REPPR
		COUNT TO lncntreppr FOR DATE=m.ldI

		DO CASE
		CASE m.lncntrep=0
		*добавляем записи из приходов
			INSERT INTO PRINT_REP (DATE, NAME_PRIH, KOL_PRIH, KOLSUH_PRIH, SOOTN, EDNAME);
						SELECT DATE, NAME_PRIH, KOL_PRIH, KOLSUH_PRIH, SOOTN, EDNAME;
						FROM PRINT_REPPR WHERE DATE=m.ldI
		CASE m.lncntrep>=m.lncntreppr
		*сделать замену
			SELECT PRINT_REPPR
			LOCATE FOR DATE=m.ldI

			SELECT PRINT_REP

			SCAN FOR DATE=m.ldI
				IF PRINT_REPPR.DATE<>m.ldI OR PRINT_REPPR.EDNAME<>PRINT_REP.EDNAME OR EOF("PRINT_REPPR")
					LOOP
				ELSE
					REPLACE NAME_PRIH WITH PRINT_REPPR.NAME_PRIH, KOL_PRIH WITH PRINT_REPPR.KOL_PRIH, KOLSUH_PRIH WITH PRINT_REPPR.KOLSUH_PRIH IN PRINT_REP

					DELETE IN PRINT_REPPR
					SKIP IN PRINT_REPPR
				ENDIF
			ENDSCAN
			*добавить приход с другими едизмами
			INSERT INTO PRINT_REP (DATE, NAME_PRIH, KOL_PRIH, KOLSUH_PRIH, SOOTN, EDNAME);
						SELECT DATE, NAME_PRIH, KOL_PRIH, KOLSUH_PRIH, SOOTN, EDNAME;
						FROM PRINT_REPPR WHERE DATE=m.ldI
		CASE m.lncntrep<m.lncntreppr
		*сделать замену+добавляем записи
			SELECT PRINT_REP
			LOCATE FOR DATE=m.ldI

			SELECT PRINT_REPPR

			SCAN FOR DATE=m.ldI
				IF PRINT_REP.DATE<>m.ldI OR PRINT_REP.EDNAME<>PRINT_REPPR.EDNAME OR EOF("PRINT_REP")						
					INSERT INTO PRINT_REP (DATE, NAME_PRIH, KOL_PRIH, KOLSUH_PRIH, SOOTN, EDNAME);
								   VALUES (PRINT_REPPR.DATE, PRINT_REPPR.NAME_PRIH, PRINT_REPPR.KOL_PRIH, PRINT_REPPR.KOLSUH_PRIH, PRINT_REPPR.SOOTN, PRINT_REPPR.EDNAME)
				ELSE
					REPLACE NAME_PRIH WITH PRINT_REPPR.NAME_PRIH, KOL_PRIH WITH PRINT_REPPR.KOL_PRIH, KOLSUH_PRIH WITH PRINT_REPPR.KOLSUH_PRIH IN PRINT_REP
				ENDIF

				IF !EOF("PRINT_REP")
					SKIP IN PRINT_REP
				ENDIF

				DELETE
			ENDSCAN
			*добавить приход с другими едизмами
			INSERT INTO PRINT_REP (DATE, NAME_PRIH, KOL_PRIH, KOLSUH_PRIH, SOOTN, EDNAME);
						SELECT DATE, NAME_PRIH, KOL_PRIH, KOLSUH_PRIH, SOOTN, EDNAME;
						FROM PRINT_REPPR WHERE DATE=m.ldI
		ENDCASE

		ldI=m.ldI+1
	ENDDO
	*заполнить остатки
	*найти дату до m.tddatebeg на которую есть остатки m.tddatebeg-1
	INSERT INTO PRINT_REP (DATE, NAME_PRIH, KOLK, KOLKSUH, SOOTN, EDNAME);
				SELECT m.tddatebeg-1, "Входящий остаток", SUM(a.KOLK) as koln, SUM(a.KOLKSUH) as kolsuh, 1, EDIZM.NAME;
				FROM OST a LEFT JOIN EDIZM ON EDIZM.ID=a.ID_TARA;
				WHERE BINTOC(a.ID_TOVAR)+BINTOC(a.ID_TARA)+DTOS(a.DATE)=BINTOC(m.tnidtovar) AND;
					  a.DATE IN (SELECT MAX(b.DATE);
					  		  	 FROM OST b;
					  		  	 WHERE b.ID_TOVAR=a.ID_TOVAR AND b.ID_TARA=a.ID_TARA AND b.DATE<=m.tddatebeg-1) AND;
					  (a.KOLK<>0 OR a.KOLKSUH<>0);
				GROUP BY 1, 2, 5, 6
*					  		  WHERE BINTOC(b.ID_TOVAR)+BINTOC(b.ID_TARA)+DTOS(b.DATE)=BINTOC(a.ID_TOVAR)+BINTOC(a.ID_TARA) AND b.DATE<=m.tddatebeg-1) AND;

	DIMENSION laostkoln[1, 3]

	SELECT EDNAME, 0, 0;
	FROM PRINT_REP INTO ARRAY laostkoln;
	GROUP BY EDNAME

	SELECT PRINT_REP

	SCAN &&FOR BETWEEN(DATE, m.tddatebeg, m.tddateend)
		FOR lnI=1 TO ALEN(laostkoln, 1)
			IF EDNAME==laostkoln[m.lnI, 1]
				IF DATE>=m.tddatebeg
					REPLACE KOLN WITH laostkoln[m.lnI, 2], KOLNSUH WITH laostkoln[m.lnI, 3],;
						    KOLK WITH laostkoln[m.lnI, 2]+KOL_PRIH-IIF(INLIST(m.tnidtovar, 1, 2) AND ATC("Расход потери при реализации", NAME_RASH)<>0, 0, KOL_RASH),;
						    KOLKSUH WITH laostkoln[m.lnI, 3]+KOLSUH_PRIH-IIF(INLIST(m.tnidtovar, 1, 2) AND ATC("Расход потери при реализации", NAME_RASH)<>0, 0, KOLSUH_RASH)
				ENDIF

				laostkoln[m.lnI, 2]=PRINT_REP.KOLK
				laostkoln[m.lnI, 3]=PRINT_REP.KOLKSUH
			ENDIF
		ENDFOR
	ENDSCAN
	*заполнить ИТОГИ ПО ДЕКАДАМ
	lnJ=0
	STORE m.tddatebeg TO ldI, ldOldD

	DO WHILE ldI<=m.tddateend
	    lnJ=m.lnJ+1

	    IF m.lnJ>9 OR m.ldI=m.tddateend
	    	DIMENSION larcursgroup[1, 1]
			larcursgroup[1, 1]=''

			SELECT NAME_PRIH, SUM(KOL_PRIH), SUM(KOLSUH_PRIH), MIN(SOOTN) as sootn, EDNAME, '', 0, 0, 0, '';
			FROM PRINT_REP INTO ARRAY larcursgroup;
			WHERE BETWEEN(DATE, m.ldOldD, m.ldI) AND !EMPTY(NAME_PRIH);
			GROUP BY NAME_PRIH, EDNAME;
			ORDER BY 1, 6

			SELECT NAME_RASH, MIN(SOOTN) as sootn, EDNAME, SUM(KOL_RASH) as kolrh, SUM(KOLSUH_RASH) as kolsuhrh;
			FROM PRINT_REP INTO CURSOR CURSGROUP;
			WHERE BETWEEN(DATE, m.ldOldD, m.ldI) AND !EMPTY(NAME_RASH);
			GROUP BY NAME_RASH, EDNAME;
			ORDER BY 1, 2

	    	DIMENSION laostkoln[1, 3]

			SELECT EDNAME, SUM(KOLK), SUM(KOLKSUH);
			FROM PRINT_REP INTO ARRAY laostkoln;
			WHERE BETWEEN(DATE, m.ldOldD, m.ldI);
			GROUP BY EDNAME

			IF EMPTY(laostkoln[1, 1])
				laostkoln[1, 1]=''
				laostkoln[1, 2]=0
				laostkoln[1, 3]=0
			ENDIF

			SELECT EDNAME, DATE, KOLK, KOLKSUH;
			FROM PRINT_REP INTO CURSOR OSTKOLN;
			WHERE BETWEEN(DATE, m.ldOldD, m.ldI);
			ORDER BY 2

			SELECT OSTKOLN

			SCAN
				FOR lnI=1 TO ALEN(laostkoln, 1)
					IF EDNAME==laostkoln[m.lnI, 1]
						laostkoln[m.lnI, 2]=KOLK
						laostkoln[m.lnI, 3]=KOLKSUH
					ENDIF
				ENDFOR
			ENDSCAN

			USE IN OSTKOLN

			DIMENSION larcursgroup[ALEN(larcursgroup, 1), 10]

			IF EMPTY(larcursgroup[1, 1])
				larcursgroup[1, 2]=0
				larcursgroup[1, 3]=0
				larcursgroup[1, 4]=0
				larcursgroup[1, 5]=''
			ENDIF

			larcursgroup[1, 6]=''
			larcursgroup[1, 7]=0
			larcursgroup[1, 8]=0
			larcursgroup[1, 9]=0
			larcursgroup[1, 10]=''

			LOCAL lnK as Integer
			lnK=1

			SELECT CURSGROUP

			SCAN
				llfou=.f.

				FOR lnK=1 TO ALEN(larcursgroup, 1)
					IF EMPTY(larcursgroup[m.lnK, 6]) AND EDNAME=larcursgroup[m.lnK, 5]
						llfou=.t.
						EXIT
					ENDIF
				ENDFOR

				IF !m.llfou
					lnK=ALEN(larcursgroup, 1)+1
					DIMENSION larcursgroup[m.lnK, 10]
					larcursgroup[m.lnK, 1]=''
					larcursgroup[m.lnK, 2]=0
					larcursgroup[m.lnK, 3]=0
					larcursgroup[m.lnK, 4]=0
					larcursgroup[m.lnK, 5]=''
				ENDIF

				larcursgroup[m.lnK, 6]=NAME_RASH
				larcursgroup[m.lnK, 7]=KOLRH
				larcursgroup[m.lnK, 8]=KOLSUHRH
				larcursgroup[m.lnK, 9]=SOOTN
				larcursgroup[m.lnK, 10]=EDNAME
			ENDSCAN

			FOR lnK=1 TO ALEN(larcursgroup, 1)
				IF !(EMPTY(larcursgroup[m.lnK, 1]) AND EMPTY(larcursgroup[m.lnK, 7]))
					STORE 0 TO lnkoln, lnkolnsuh

					FOR lnI=1 TO ALEN(laostkoln, 1)
						IF larcursgroup[m.lnK, 10]==laostkoln[m.lnI, 1]
							lnkoln=laostkoln[m.lnI, 2]
							lnkolnsuh=laostkoln[m.lnI, 3]
						ENDIF
					ENDFOR

					INSERT INTO PRINT_REP (DATE, NAME_PRIH, KOL_PRIH, KOLSUH_PRIH,;
										   NAME_RASH, KOL_RASH, KOLSUH_RASH, KOLK, KOLKSUH, SOOTN, EDNAME, FLAG);
								   VALUES (m.ldI, larcursgroup[m.lnK, 1], larcursgroup[m.lnK, 2], larcursgroup[m.lnK, 3],;
								   		   larcursgroup[m.lnK, 6], larcursgroup[m.lnK, 7], larcursgroup[m.lnK, 8], m.lnkoln, m.lnkolnsuh, larcursgroup[m.lnK, 9], larcursgroup[m.lnK, 10], 1)
				ENDIF
			ENDFOR

			RELEASE larcursgroup

	        lnJ=0
			ldOldD=m.ldI+1
	    ENDIF

		ldI=m.ldI+1
	ENDDO

   	DIMENSION larcursgroup[1, 1]
	larcursgroup[1, 1]=''

	SELECT NAME_PRIH, SUM(KOL_PRIH), SUM(KOLSUH_PRIH), MIN(SOOTN) as sootn, EDNAME, '', 0, 0, 0, '';
	FROM PRINT_REP INTO ARRAY larcursgroup;
	WHERE BETWEEN(DATE,m. tddatebeg, m.tddateend) AND !EMPTY(NAME_PRIH) AND FLAG=0;
	GROUP BY NAME_PRIH, EDNAME;
	ORDER BY 1, 6

	SELECT NAME_RASH, MIN(SOOTN) as sootn, EDNAME, SUM(KOL_RASH) AS KOLRH, SUM(KOLSUH_RASH) as kolsuhrh;
	FROM PRINT_REP INTO CURSOR CURSGROUP;
	WHERE BETWEEN(DATE, m.tddatebeg, m.tddateend) AND !EMPTY(NAME_RASH) AND FLAG=0;
	GROUP BY NAME_RASH, EDNAME;
	ORDER BY 1, 2

	DIMENSION laostkoln[1, 3]

	SELECT EDNAME, SUM(KOLK), SUM(KOLKSUH);
	FROM PRINT_REP INTO ARRAY laostkoln;
	WHERE BETWEEN(DATE, m.tddatebeg, m.tddateend) AND FLAG=0;
	GROUP BY EDNAME

	IF EMPTY(laostkoln[1, 1])
		laostkoln[1, 1]=''
		laostkoln[1, 2]=0
		laostkoln[1, 3]=0
	ENDIF

	SELECT PRINT_REP

	SCAN FOR FLAG=0
		FOR lnI=1 TO ALEN(laostkoln, 1)
			IF EDNAME==laostkoln[m.lnI, 1]
				laostkoln[m.lnI, 2]=KOLK
				laostkoln[m.lnI, 3]=KOLKSUH
			ENDIF
		ENDFOR
	ENDSCAN

	DIMENSION larcursgroup[ALEN(larcursgroup, 1),10]

	IF EMPTY(larcursgroup[1, 1])
		larcursgroup[1, 2]=0
		larcursgroup[1, 3]=0
		larcursgroup[1, 4]=0
		larcursgroup[1, 5]=''
	ENDIF

	larcursgroup[1, 6]=''
	larcursgroup[1, 7]=0
	larcursgroup[1, 8]=0
	larcursgroup[1, 9]=0
	larcursgroup[1, 10]=''

	LOCAL lnK as Integer
	lnK=1
	SELECT CURSGROUP

	SCAN
		llfou=.f.

		FOR lnK=1 TO ALEN(larcursgroup, 1)
			IF EMPTY(larcursgroup[m.lnK, 6]) AND EDNAME=larcursgroup[m.lnK, 5]
				llfou=.t.
				EXIT
			ENDIF
		ENDFOR

		IF !m.llfou
			lnK=ALEN(larcursgroup, 1)+1

			DIMENSION larcursgroup[m.lnK, 10]
			larcursgroup[m.lnK, 1]=''
			larcursgroup[m.lnK, 2]=0
			larcursgroup[m.lnK, 3]=0
			larcursgroup[m.lnK, 4]=0
			larcursgroup[m.lnK, 5]=''
		ENDIF

		larcursgroup[m.lnK, 6]=NAME_RASH
		larcursgroup[m.lnK, 7]=KOLRH
		larcursgroup[m.lnK, 8]=KOLSUHRH
		larcursgroup[m.lnK, 9]=SOOTN
		larcursgroup[m.lnK, 10]=EDNAME
	ENDSCAN

	FOR lnK=1 TO ALEN(larcursgroup, 1)
		STORE 0 TO lnkoln, lnkolnsuh

		FOR lnI=1 TO ALEN(laostkoln, 1)
			IF larcursgroup[m.lnK, 10]==laostkoln[m.lnI, 1]
				lnkoln=laostkoln[m.lnI, 2]
				lnkolnsuh=laostkoln[m.lnI, 3]
			ENDIF
		ENDFOR

		INSERT INTO PRINT_REP (DATE, NAME_PRIH, KOL_PRIH, KOLSUH_PRIH,;
							   NAME_RASH, KOL_RASH, KOLSUH_RASH, KOLK, KOLKSUH, SOOTN, EDNAME, FLAG);
					   VALUES (m.tddateend, larcursgroup[m.lnK, 1], larcursgroup[m.lnK, 2], larcursgroup[m.lnK, 3],;
					   		   larcursgroup[m.lnK, 6], larcursgroup[m.lnK, 7], larcursgroup[m.lnK, 8], m.lnkoln, m.lnkolnsuh, larcursgroup[m.lnK, 9], larcursgroup[m.lnK, 10], 2)
	ENDFOR
    *Total
    DIMENSION larcursgroup[1, 1]
	larcursgroup[1, 1]=''

	SELECT 'ОБЩИЙ ИТОГ' as NAME_PRIH, SUM(KOL_PRIH), SUM(KOLSUH_PRIH), MIN(SOOTN) as sootn, EDNAME, '', 0, 0, 0, '';
	FROM PRINT_REP INTO ARRAY larcursgroup;
	WHERE BETWEEN(DATE, m.tddatebeg, m.tddateend) AND !EMPTY(NAME_PRIH) AND FLAG=0;
	GROUP BY EDNAME;
	ORDER BY 1, 6

	SELECT 'ОБЩИЙ ИТОГ' as NAME_RASH, MIN(SOOTN) as sootn, EDNAME, SUM(KOL_RASH) AS KOLRH, SUM(KOLSUH_RASH) as kolsuhrh;
	FROM PRINT_REP INTO CURSOR CURSGROUP;
	WHERE BETWEEN(DATE, m.tddatebeg, m.tddateend) AND (!EMPTY(NAME_RASH) AND ATC("Расход потери при реализации", NAME_RASH)=0) AND FLAG=0;
	GROUP BY EDNAME;
	ORDER BY 1, 2

	DIMENSION laostkoln[1, 3]

	SELECT EDNAME, SUM(KOLK), SUM(KOLKSUH);
	FROM PRINT_REP INTO ARRAY laostkoln;
	WHERE BETWEEN(DATE, m.tddatebeg, m.tddateend) AND FLAG=0;
	GROUP BY EDNAME

	IF EMPTY(laostkoln[1, 1])
		laostkoln[1, 1]=''
		laostkoln[1, 2]=0
		laostkoln[1, 3]=0
	ENDIF

	SELECT PRINT_REP
	SCAN FOR FLAG=0
		FOR lnI=1 TO ALEN(laostkoln, 1)
			IF EDNAME==laostkoln[m.lnI, 1]
				laostkoln[m.lnI, 2]=KOLK
				laostkoln[m.lnI, 3]=KOLKSUH
			ENDIF
		ENDFOR
	ENDSCAN

	DIMENSION larcursgroup[ALEN(larcursgroup, 1), 10]

	IF EMPTY(larcursgroup[1, 1])
		larcursgroup[1, 2]=0
		larcursgroup[1, 3]=0
		larcursgroup[1, 4]=0
		larcursgroup[1, 5]=''
	ENDIF

	larcursgroup[1, 6]=''
	larcursgroup[1, 7]=0
	larcursgroup[1, 8]=0
	larcursgroup[1, 9]=0
	larcursgroup[1, 10]=''

	LOCAL lnK as Integer
	lnK=1

	SELECT CURSGROUP

	SCAN
		llfou=.f.

		FOR lnK=1 TO ALEN(larcursgroup, 1)
			IF EMPTY(larcursgroup[m.lnK, 6]) AND EDNAME=larcursgroup[m.lnK, 5]
				llfou=.t.
				EXIT
			ENDIF
		ENDFOR

		IF !m.llfou
			lnK=ALEN(larcursgroup, 1)+1

			DIMENSION larcursgroup[m.lnK, 10]
			larcursgroup[m.lnK, 1]=''
			larcursgroup[m.lnK, 2]=0
			larcursgroup[m.lnK, 3]=0
			larcursgroup[m.lnK, 4]=0
			larcursgroup[m.lnK, 5]=''
		ENDIF

		larcursgroup[m.lnK, 6]=NAME_RASH
		larcursgroup[m.lnK, 7]=KOLRH
		larcursgroup[m.lnK, 8]=KOLSUHRH
		larcursgroup[m.lnK, 9]=SOOTN
		larcursgroup[m.lnK, 10]=EDNAME
	ENDSCAN

	FOR lnK=1 TO ALEN(larcursgroup, 1)
		STORE 0 TO lnkoln, lnkolnsuh

		FOR lnI=1 TO ALEN(laostkoln, 1)
			IF larcursgroup[m.lnK, 10]==laostkoln[m.lnI, 1]
				lnkoln=laostkoln[m.lnI, 2]
				lnkolnsuh=laostkoln[m.lnI, 3]
			ENDIF
		ENDFOR

		INSERT INTO PRINT_REP (DATE, NAME_PRIH, KOL_PRIH, KOLSUH_PRIH,;
							   NAME_RASH, KOL_RASH, KOLSUH_RASH, KOLK, KOLKSUH, SOOTN, EDNAME, FLAG);
					   VALUES (m.tddateend, larcursgroup[m.lnK, 1], larcursgroup[m.lnK, 2], larcursgroup[m.lnK, 3],;
					   		   larcursgroup[m.lnK, 6], larcursgroup[m.lnK, 7], larcursgroup[m.lnK, 8], m.lnkoln, m.lnkolnsuh, larcursgroup[m.lnK, 9], larcursgroup[m.lnK, 10], 3)
	ENDFOR
	
	WAIT CLEAR

	IF USED("CURSGROUP")
		USE IN CURSGROUP
	ENDIF

	IF USED("PRINT_REPPR")
		USE IN PRINT_REPPR
	ENDIF