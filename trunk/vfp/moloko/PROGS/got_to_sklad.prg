*готовая продукция - движение на склад
PARAMETERS tnidtovar as Integer, tnidedz as Integer, tddatebeg as Date, tddateend as Date
LOCAL ldI as Date, lnJ as Integer, llfoulog as Logical, lnidrash as Integer, lnidprih as Integer, lnvesedz as Integer
LOCAL ARRAY laproview[1,6], lasumviewprih[1,2], lasumviewrash[1,2], laarcursgroup[1,6]
    WAIT WINDOW NOWAIT "Создание отчета..."
    *
	CREATE CURSOR print_rep (date d, koln n(10,3), kolnjir n(10,3), kolned n(10,3),;
							name_prih c(70), kol_prih n(10,3), koljir_prih n(10,3), koled_prih n(10,3),;
							name_rash c(70), kol_rash n(10,3), koljir_rash n(10,3), koled_rash n(10,3),;
							kolk n(10,3), kolkjir n(10,3), kolked n(10,3), flag n(1))
	INDEX ON DTOS(DATE)+TRANSFORM(FLAG,'9')+IIF(!EMPTY(NAME_PRIH),'0','9')+IIF(!EMPTY(NAME_RASH),'0','9') TAG dt
	*
	CREATE CURSOR print_reppr (date d, name_prih c(70), kol_prih n(10,3), koljir_prih n(10,3), koled_prih n(10,3))
	*
	DIMENSION lcproview[1,4], lcsumviewprih[1,2], lcsumviewrash[1,2]
	*
	SELECT DISTINCT 0, NVL(PRO.ID,0000000000), PADR(RTRIM(NVL(PRO.COMMENT,''))+'('+RTRIM(NVL(EDIZM.NAME,''))+") "+RTRIM(NVL(TYPEDOC.NAME,''))+' '+RTRIM(NVL(OR.NAME,'')),70), NVL(EDIZM.ID,0000000000), NVL(OR.ID,0000000000), NVL(TYPEDOC.ID,0000000000);
	FROM NAK RIGHT JOIN PAS ON NAK.ID_PAS=PAS.ID;
			  LEFT JOIN NAKC ON BINTOC(NAKC.ID_NAK)+BINTOC(NAKC.ID_TOVAR)+BINTOC(NAKC.ID_TARA)=BINTOC(NAK.ID)+BINTOC(m.tnidtovar)+BINTOC(m.tnidedz);
			  LEFT JOIN TYPEDOC ON NAK.TYPEDOC==TYPEDOC.ID;
			  LEFT JOIN OR ON NAK.ID_ORGAN=OR.ID;
			  LEFT JOIN PRO ON PAS.ID_PRO=PRO.ID;
			  LEFT JOIN EDIZM ON EDIZM.ID=NAKC.ID_TARA INTO ARRAY laproview;
	WHERE NAK.ID IN (SELECT ID_NAK FROM NAKC WHERE ID_TOVAR=m.tnidtovar AND ID_TARA=m.tnidedz) AND;
 		  BETWEEN(NAK.DATE,m.tddatebeg,m.tddateend);
	UNION ALL;
	SELECT DISTINCT 1, NVL(TYPEDOC.ID,0000000000), PADR(RTRIM(NVL(OR.NAME,''))+'('+RTRIM(NVL(EDIZM.NAME,''))+')',70), NVL(EDIZM.ID,0000000000), NVL(OR.ID,0000000000), NVL(TYPEDOC.ID,0000000000);
	FROM NAKC LEFT JOIN EDIZM ON NAKC.ID_TARA=EDIZM.ID;
				   RIGHT JOIN NAK ON NAK.ID=NAKC.ID_NAK AND BETWEEN(NAK.DATE,m.tddatebeg,m.tddateend) AND NAK.ID_PAS=0 AND NAK.ID_PARNAK=0;
				   LEFT JOIN TYPEDOC ON NAK.TYPEDOC=TYPEDOC.ID;
				   LEFT JOIN OR ON NAK.ID_ORGAN=OR.ID AND INLIST(OR.NAME,"Склад готовой продукции","Лаборатория");
    WHERE ID_TOVAR=m.tnidtovar AND ID_TARA=m.tnidedz
	*
	m.lnvesedz=1
	*
	IF SEEK("Расход хозяйствам","TYPEDOC","NAME")
		lnidrash=TYPEDOC.ID
	ENDIF
	*
	IF SEEK("Приход от производства","TYPEDOC","NAME")
		lnidprih=TYPEDOC.ID
	ENDIF
	*
	ldI=m.tddatebeg
	DO WHILE ldI<=m.tddateend
		STORE 0 TO m.koln, m.kolnjir, m.kolned, m.kolk, m.kolkjir, m.kolked
		*
		FOR lnJ=1 TO ALEN(laproview,1)
			STORE 0 TO lasumviewprih[1,1], lasumviewprih[1,2], lasumviewrash[1,1], lasumviewrash[1,2]
			*
			IF VARTYPE(laproview[m.lnJ,1])='N'
				DO CASE
				CASE laproview[m.lnJ,1]=0
					=SEEK(laproview[m.lnJ,6],"TYPEDOC","ID")
					*
					DO CASE
					CASE TYPEDOC.ID==m.lnidprih
						SELECT SUM(KOL), SUM(KOLJIR);
						FROM NAK LEFT JOIN NAKC ON BINTOC(ID_NAK)+BINTOC(ID_TOVAR)+BINTOC(ID_TARA)=BINTOC(nak.id)+BINTOC(m.tnidtovar)+BINTOC(m.tnidedz) INTO ARRAY lasumviewprih;
						WHERE ID_PAS IN (SELECT ID;
						 			  	 FROM PAS;
						 			  	 WHERE ID_PRO+DTOS(DATE)=laproview[m.lnJ,2]+DTOS(m.ldI) AND ID_TARA=m.tnidedz) AND;
						 	  TYPEDOC+DTOS(DATE)=laproview[m.lnJ,6]+DTOS(m.ldI) AND ID_ORGAN=laproview[m.lnJ,5]
					CASE TYPEDOC.ID==m.lnidrash
						SELECT SUM(KOL), SUM(KOLJIR);
						FROM NAK LEFT JOIN NAKC ON BINTOC(ID_NAK)+BINTOC(ID_TOVAR)+BINTOC(ID_TARA)=BINTOC(NAK.ID)+BINTOC(m.tnidtovar)+BINTOC(m.tnidedz) INTO ARRAY lasumviewrash;
						WHERE ID_PAS IN (SELECT ID;
						 			  	 FROM PAS;
						 			  	 WHERE ID_PRO+DTOS(DATE)=laproview[m.lnJ,2]+DTOS(m.ldI) AND ID_TARA=m.tnidedz) AND;
						 	  TYPEDOC+DTOS(DATE)=laproview[m.lnJ,6]+DTOS(m.ldI) AND ID_ORGAN=laproview[m.lnJ,5]
					ENDCASE
				CASE laproview[m.lnJ,1]=1 AND !ISNULL(laproview[m.lnJ,2])
					IF SEEK(laproview[m.lnJ,6],"TYPEDOC","ID") AND TYPEDOC.ID==m.lnidprih
						SELECT SUM(KOL), SUM(KOLJIR);
						FROM NAK LEFT JOIN NAKC ON BINTOC(ID_NAK)+BINTOC(ID_TOVAR)+BINTOC(ID_TARA)=BINTOC(NAK.ID)+BINTOC(m.tnidtovar)+BINTOC(m.tnidedz) INTO ARRAY lasumviewprih;
						WHERE TYPEDOC+DTOS(DATE)=laproview[m.lnJ,6]+DTOS(m.ldI) AND ID_ORGAN=laproview[m.lnJ,5]
					ELSE
						SELECT SUM(KOL), SUM(KOLJIR);
						FROM NAK LEFT JOIN NAKC ON BINTOC(ID_NAK)+BINTOC(ID_TOVAR)+BINTOC(ID_TARA)=BINTOC(NAK.ID)+BINTOC(m.tnidtovar)+BINTOC(m.tnidedz) INTO ARRAY lasumviewrash;
						WHERE TYPEDOC+DTOS(DATE)=laproview[m.lnJ,6]+DTOS(m.ldI) AND ID_ORGAN=laproview[m.lnJ,5]
					ENDIF
				ENDCASE
				*
				lasumviewprih[1,1]=NVL(lasumviewprih[1,1],0)
				lasumviewrash[1,1]=NVL(lasumviewrash[1,1],0)
				*
				IF lasumviewprih[1,1]#0
					lasumviewprih[1,2]=NVL(lasumviewprih[1,2],0)
					*
					INSERT INTO PRINT_REPPR (DATE, NAME_PRIH, KOL_PRIH, KOLJIR_PRIH, KOLED_PRIH);
									 VALUES (m.ldI, IIF(lasumviewprih[1,1]#0,laproview[m.lnJ,3],''), lasumviewprih[1,1], lasumviewprih(1,2), m.goApp.oFunction.div(lasumviewprih[1,1],m.lnvesedz))
				ENDIF
				*
				IF lasumviewrash[1,1]#0
					lasumviewrash[1,2]=NVL(lasumviewrash[1,2],0)
					*
					INSERT INTO PRINT_REP (DATE, NAME_RASH, KOL_RASH, KOLJIR_RASH, KOLED_RASH);
								   VALUES (m.ldI, IIF(lasumviewrash[1,1]#0,laproview[m.lnJ,3],''), lasumviewrash[1,1], lasumviewrash[1,2], m.goApp.oFunction.div(lasumviewrash[1,1],m.lnvesedz))
				ENDIF
			ENDIF
		ENDFOR
		*
		ldI=m.ldI+1
	ENDDO
	*
	LOCAL lncntrep as Number,lncntreppr as Number
	ldI=m.tddatebeg
	DO WHILE ldI<=m.tddateend
		SELECT PRINT_REP
		COUNT TO lncntrep FOR DATE=m.ldI
		SELECT print_reppr
		COUNT TO lncntreppr FOR DATE=m.ldI
		*
		DO CASE
		CASE m.lncntrep=0
		*добавляем записи из приходов
			INSERT INTO PRINT_REP (DATE, NAME_PRIH, KOL_PRIH, KOLJIR_PRIH, KOLED_PRIH);
				SELECT DATE, NAME_PRIH, KOL_PRIH, KOLJIR_PRIH, KOLED_PRIH;
				FROM PRINT_REPPR;
				WHERE DATE=m.ldI
		CASE m.lncntrep>=m.lncntreppr
		*сделать замену
			SELECT PRINT_REPPR
			LOCATE FOR DATE=m.ldI
			*
			SELECT PRINT_REP
			SCAN FOR DATE=m.ldI
				IF PRINT_REPPR.DATE#m.ldI OR EOF("PRINT_REPPR")
					EXIT
				ELSE
					REPLACE NAME_PRIH WITH PRINT_REPPR.NAME_PRIH, KOL_PRIH WITH PRINT_REPPR.KOL_PRIH, KOLJIR_PRIH WITH PRINT_REPPR.KOLJIR_PRIH, KOLED_PRIH WITH PRINT_REPPR.KOLED_PRIH IN PRINT_REP
					SKIP IN PRINT_REPPR
				ENDIF
			ENDSCAN
		CASE m.lncntrep<m.lncntreppr
		*сделать замену
			SELECT PRINT_REP
			LOCATE FOR DATE=m.ldI
			*
			SELECT PRINT_REPPR
			SCAN FOR DATE=m.ldI
				IF PRINT_REP.DATE#m.ldI OR EOF("PRINT_REP")						
					INSERT INTO PRINT_REP (DATE, NAME_PRIH, KOL_PRIH, KOLJIR_PRIH, KOLED_PRIH);
								   VALUES (PRINT_REPPR.DATE, PRINT_REPPR.NAME_PRIH, PRINT_REPPR.KOL_PRIH, PRINT_REPPR.KOLJIR_PRIH, PRINT_REPPR.KOLED_PRIH)
				ELSE
					REPLACE NAME_PRIH WITH PRINT_REPPR.NAME_PRIH, KOL_PRIH WITH PRINT_REPPR.KOL_PRIH, KOLJIR_PRIH WITH PRINT_REPPR.KOLJIR_PRIH, KOLED_PRIH WITH PRINT_REPPR.KOLED_PRIH IN PRINT_REP
				ENDIF
				*
				IF !EOF("PRINT_REP")
					SKIP IN PRINT_REP
				ENDIF
			ENDSCAN
		ENDCASE
		*
		ldI=m.ldI+1
	ENDDO
	*заполнить остатки
	IF SEEK(DTOS(m.tddatebeg)+BINTOC(m.tnidtovar)+BINTOC(m.tnidedz),"OST","DATETOVAR")
		lnkoln=OST.KOLN
		lnkolnjir=OST.KOLNJIR
		lnkolned=OST.KOLN
	ELSE
		STORE 0 TO lnkoln, lnkolnjir, lnkolned
	ENDIF
	*
	SELECT PRINT_REP
	SCAN
		REPLACE KOLN WITH m.lnkoln, KOLNJIR WITH m.lnkolnjir, KOLNED WITH m.goApp.oFunction.div(m.lnkoln,m.lnvesedz), KOLK WITH m.lnkoln+KOL_PRIH-KOL_RASH, KOLKJIR WITH m.lnkolnjir+KOLJIR_PRIH-KOLJIR_RASH, KOLKED WITH m.goApp.oFunction.div(KOLK,m.lnvesedz)
		lnkoln=PRINT_REP.KOLK
		lnkolnjir=PRINT_REP.KOLKJIR
	ENDSCAN
	*заполнить итоги по декадам
	lnJ=0
	ldI=m.tddatebeg
	ldOldD=m.tddatebeg
	DO WHILE ldI<=m.tddateend
	    lnJ=m.lnJ+1
	    IF m.lnJ>9
	    	DIMENSION laarcursgroup[1,1]
			laarcursgroup[1,1]=''
	    	*
			SELECT NAME_PRIH, SUM(KOL_PRIH), SUM(KOLJIR_PRIH), '', 0, 0;
			FROM PRINT_REP INTO ARRAY laarcursgroup;
			WHERE BETWEEN(DATE,m.ldOldD,m.ldI) AND !EMPTY(NAME_PRIH);
			GROUP BY NAME_PRIH;
			ORDER BY 1
			*
			SELECT NAME_RASH, SUM(KOL_RASH) AS KOLRH, SUM(KOLJIR_RASH) AS KOLJIRRH;
			FROM PRINT_REP INTO CURSOR CURSGROUP;
			WHERE BETWEEN(DATE,m.ldOldD,m.ldI) AND !EMPTY(NAME_RASH);
			GROUP BY NAME_RASH;
			ORDER BY 1
			*
			DIMENSION laarcursgroup[ALEN(laarcursgroup,1),6]
			IF EMPTY(laarcursgroup[1,1])
				laarcursgroup[1,2]=0
				laarcursgroup[1,3]=0
			ENDIF
			laarcursgroup[1,4]=''
			laarcursgroup[1,5]=0
			laarcursgroup[1,6]=0
			*
			LOCAL lnK as Number
			lnK=1
			SELECT CURSGROUP
			SCAN
				IF m.lnK>ALEN(laarcursgroup,1)
					DIMENSION laarcursgroup[m.lnK,6]
					laarcursgroup[m.lnK,1]=''
					laarcursgroup[m.lnK,2]=0
					laarcursgroup[m.lnK,3]=0
				ENDIF
				*
				laarcursgroup[m.lnK,4]=NAME_RASH
				laarcursgroup[m.lnK,5]=KOLRH
				laarcursgroup[m.lnK,6]=KOLJIRRH
				*
				lnK=m.lnK+1
			ENDSCAN
			*
			FOR lnK=1 TO ALEN(laarcursgroup,1)
				IF !(EMPTY(laarcursgroup[m.lnK,1]) AND EMPTY(laarcursgroup[m.lnK,4]))
					INSERT INTO PRINT_REP (DATE, NAME_PRIH, KOL_PRIH, KOLJIR_PRIH, KOLED_PRIH, NAME_RASH, KOL_RASH, KOLJIR_RASH, KOLED_RASH, FLAG);
								   VALUES (m.ldI, laarcursgroup[m.lnK,1], laarcursgroup[m.lnK,2], laarcursgroup[m.lnK,3], m.goApp.oFunction.div(laarcursgroup[m.lnK,2],m.lnvesedz), laarcursgroup[m.lnK,4], laarcursgroup[m.lnK,5], laarcursgroup[m.lnK,6], m.goApp.oFunction.div(laarcursgroup[m.lnK,5],m.lnvesedz), 1)
				ENDIF
			ENDFOR
			*
			RELEASE laarcursgroup
			*
	        m.lnJ=0
			ldOldD=m.ldI+1
	    ENDIF
	    *
		ldI=m.ldI+1
	ENDDO
	*
   	DIMENSION laarcursgroup[1,1]
	laarcursgroup[1,1]=''
	*
	SELECT NAME_PRIH, SUM(KOL_PRIH), SUM(KOLJIR_PRIH), '', 0, 0;
	FROM PRINT_REP INTO ARRAY laarcursgroup;
	WHERE BETWEEN(DATE,m.tddatebeg,m.tddateend) AND !EMPTY(NAME_PRIH) AND FLAG=0;
	GROUP BY NAME_PRIH;
	ORDER BY 1
	*
	SELECT NAME_RASH, SUM(KOL_RASH) as kolrh, SUM(KOLJIR_RASH) as koljirrh;
	FROM PRINT_REP INTO CURSOR cursgroup;
	WHERE BETWEEN(DATE,m.tddatebeg,m.tddateend) AND !EMPTY(NAME_RASH) AND FLAG=0;
	GROUP BY NAME_RASH;
	ORDER BY 1
	*
	DIMENSION laarcursgroup[ALEN(laarcursgroup,1),6]
	IF EMPTY(laarcursgroup[1,1])
		laarcursgroup[1,2]=0
		laarcursgroup[1,3]=0
	ENDIF
	laarcursgroup[1,4]=''
	laarcursgroup[1,5]=0
	laarcursgroup[1,6]=0
	*
	LOCAL lnK as Number
	lnK=1
	SELECT CURSGROUP
	SCAN
		IF m.lnK>ALEN(laarcursgroup,1)
			DIMENSION laarcursgroup[m.lnK,6]
			laarcursgroup[m.lnK,1]=''
			laarcursgroup[m.lnK,2]=0
			laarcursgroup[m.lnK,3]=0
		ENDIF
		*
		laarcursgroup[m.lnK,4]=NAME_RASH
		laarcursgroup[m.lnK,5]=KOLRH
		laarcursgroup[m.lnK,6]=KOLJIRRH
		*
		lnK=m.lnK+1
	ENDSCAN
	*
	FOR lnK=1 TO ALEN(laarcursgroup,1)
		INSERT INTO PRINT_REP (DATE, NAME_PRIH, KOL_PRIH, KOLJIR_PRIH, KOLED_PRIH, NAME_RASH, KOL_RASH, KOLJIR_RASH, KOLED_RASH, KOLK, KOLKJIR, KOLKED, FLAG);
					   VALUES (m.tddateend, laarcursgroup[m.lnK,1], laarcursgroup[m.lnK,2], laarcursgroup[m.lnK,3], m.goApp.oFunction.div(laarcursgroup[m.lnK,2],m.lnvesedz), laarcursgroup[m.lnK,4], laarcursgroup[m.lnK,5], laarcursgroup[m.lnK,6], m.goApp.oFunction.div(laarcursgroup[m.lnK,5],m.lnvesedz), m.lnkoln, m.lnkolnjir, m.goApp.oFunction.div(m.lnkoln,m.lnvesedz), 2)
	ENDFOR
	*
    WAIT CLEAR
    *
    =SEEK(m.tnidtovar,"TO","ID")
    *
*!*		oListener=CREATEOBJECT("ReportListener")
*!*		oListener.ListenerType=1 && Preview, or 0 for Print

*!*	*	m.goApp.goForm("selprint", 0, .NULL., .NULL., "..\REPORTS\GOT_TO_SKLAD", "PRINT_REP", "oListener")
	*
	USE IN CURSGROUP
*!*		USE IN PRINT_REP
	USE IN PRINT_REPPR