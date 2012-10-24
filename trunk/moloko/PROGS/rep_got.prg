*готовая продукция в упаковке
PARAMETERS tcidprod, tddatebeg, tddateend
LOCAL ldI, lnJ, foulog, laproview, lasumviewprih, lasumviewrash, lcidrash, lcidprih, arcursgroup
    WAIT WINDOW NOWAIT "Создание отчета..."
    *
	CREATE CURSOR PRINT_REP (date d, koln n(13, 6), kolnjir n(13, 6), kolned n(13, 6),;
							name_prih c(70), kol_prih n(13, 6), koljir_prih n(13, 6), koled_prih n(13, 6),;
							name_rash c(70), kol_rash n(13, 6), koljir_rash n(13, 6), koled_rash n(13, 6),;
							kolk n(10, 3), kolkjir n(13, 6), kolked n(13, 6), sootn n(13, 6), edname c(30), flag n(1))
	INDEX ON DTOS(date)+STR(flag, 1)+IIF(!EMPTY(name_prih), '0', '9')+IIF(!EMPTY(name_rash), '0', '9') TAG dt
	*
	CREATE CURSOR PRINT_REPPR (date d, name_prih c(70), kol_prih n(13, 6), koljir_prih n(13, 6), koled_prih n(13, 6))
	*
	DIMENSION laproview[1, 4], lasumviewprih[1, 2], lasumviewrash[1, 2]
	*
	SELECT DISTINCT 0, production.id, PADR(RTRIM(to.name)+'('+RTRIM(edizm.name)+')'+CHR(10)+RTRIM(typedoc.name)+CHR(10)+RTRIM(or.name), 70), edizm.id, or.id, typedoc.id, 1 as ves, nakc.id_tovar;
	FROM production LEFT JOIN pas ON pas.id_pro==production.id AND BETWEEN(pas.date, m.tddatebeg, m.tddateend);
			  LEFT JOIN edizm ON edizm.id=pas.ID_TARA;
			  LEFT JOIN nak ON nak.id_pas=pas.id;
			  LEFT JOIN typedoc ON typedoc.id==nak.typedoc;
			  LEFT JOIN or ON or.id=nak.id_organ;
			  LEFT JOIN nakc ON nakc.id_nak=nak.id;
			  LEFT JOIN to ON to.id=nakc.id_tovar INTO ARRAY laproview;
	WHERE production.id==m.tcidprod
	*
    baseedname="Кг"
    *
	IF SEEK("Расход", "typedoc", "name") && AND typedoc.pid=0
		lcidrash=typedoc.id
	ENDIF
	*
	IF SEEK("Приход", "typedoc", "name") && AND typedoc.pid=0
		lcidprih=typedoc.id
	ENDIF
	*
	ldI=m.tddatebeg

	DO WHILE m.ldI<=m.tddateend
		STORE 0 TO m.koln, m.kolnjir, m.kolk, m.kolkjir
		*
		FOR lnJ=1 TO ALEN(laproview, 1)
			STORE 0 TO lasumviewprih[1, 1], lasumviewprih[1, 2], lasumviewrash[1, 1], lasumviewrash[1, 2]
			*
			IF VARTYPE(laproview[m.lnJ, 1])='N'
				SELECT SUM(kol), SUM(koljir);
				FROM nakc INTO ARRAY lasumviewprih;
				WHERE id_nak IN (SELECT id;
					 			 FROM nak;
				 			  	 WHERE id_pas IN (SELECT ID;
								 			  	  FROM PAS;
								 			  	  WHERE ID_PRO+DTOS(DATE)=laproview[m.lnJ, 2]+DTOS(m.ldI)) AND;
				 			  	 	   date=m.ldI AND typedoc==laproview[m.lnJ, 6] AND;
				 			  	 	   typedoc IN (SELECT RTRIM(id);
				 			  	 	   			   FROM typedoc;
				 			  	 	   			   WHERE ID==m.lcidprih) AND;
				 			  	 	   id_organ=laproview[m.lnJ, 5]) AND id_tovar=laproview[m.lnJ, 8]
				*
				SELECT SUM(kol), SUM(koljir);
				FROM nakc INTO ARRAY lasumviewrash;
				WHERE id_nak IN (SELECT id;
					 			 FROM nak;
				 			  	 WHERE id_pas IN (SELECT ID;
								 			  	  FROM PAS;
								 			  	  WHERE ID_PRO+DTOS(DATE)=laproview[m.lnJ, 2]+DTOS(m.ldI)) AND;
				 			  	 	   date=m.ldI AND typedoc==laproview[m.lnJ, 6] AND;
				 			  	 	   typedoc IN (SELECT RTRIM(id);
				 			  	 	   			   FROM typedoc;
				 			  	 	   			   WHERE ID==m.lcidrash) AND;
				 			  	 	   id_organ=laproview[m.lnJ, 5]) AND id_tovar=laproview[m.lnJ, 8]
				*
				lasumviewprih[1, 1]=NVL(lasumviewprih[1, 1], 0)
				lasumviewrash[1, 1]=NVL(lasumviewrash[1, 1], 0)
				*
				IF lasumviewprih[1, 1]<>0
					lasumviewprih[1, 2]=NVL(lasumviewprih[1, 2], 0)
					*
					INSERT INTO print_reppr (date, name_prih, kol_prih, koljir_prih, koled_prih);
								   VALUES (m.ldI, IIF(lasumviewprih[1, 1]<>0, laproview[m.lnJ, 3], ''), lasumviewprih[1, 1], lasumviewprih[1, 2], ROUND(div(lasumviewprih[1, 1],laproview[m.lnJ, 7]),0))
				ENDIF
				*
				IF lasumviewrash[1, 1]<>0
					lasumviewrash[1, 2]=NVL(lasumviewrash[1, 2], 0)
					*
					INSERT INTO print_rep (date, name_rash, kol_rash, koljir_rash, koled_rash, sootn);
								     VALUES (m.ldI, IIF(lasumviewrash[1, 1]<>0, laproview[m.lnJ, 3], ''), lasumviewrash[1, 1], lasumviewrash[1, 2], ROUND(div(lasumviewrash[1, 1],laproview[m.lnJ, 7]), 0), 1)
				ENDIF
			ENDIF
		ENDFOR
		*
		ldI=m.ldI+1
	ENDDO
	*
	LOCAL lncntrep, lncntreppr
	ldI=m.tddatebeg
	DO WHILE ldI<=m.tddateend
		SELECT print_rep
		COUNT TO lncntrep FOR date=m.ldI
		SELECT print_reppr
		COUNT TO lncntreppr FOR date=m.ldI
		*
		DO CASE
		CASE lncntrep=0
		*добавляем записи из приходов
			INSERT INTO print_rep (date, name_prih, kol_prih, koljir_prih, koled_prih) SELECT date, name_prih, kol_prih, koljir_prih, koled_prih FROM print_reppr WHERE date=m.ldI
		CASE lncntrep>=lncntreppr
		*сделать замену
			SELECT print_reppr
			LOCATE FOR date=m.ldI
			*
			SELECT print_rep
			SCAN FOR date=m.ldI
				IF print_reppr.date<>m.ldI OR EOF("print_reppr")
					EXIT
				ELSE
					REPLACE name_prih WITH print_reppr.name_prih, kol_prih WITH print_reppr.kol_prih, koljir_prih WITH print_reppr.koljir_prih, koled_prih WITH print_reppr.koled_prih IN print_rep
					SKIP IN print_reppr
				ENDIF
			ENDSCAN
		CASE lncntrep<lncntreppr
		*сделать замену
			SELECT print_rep
			LOCATE FOR date=m.ldI
			*
			SELECT print_reppr
			SCAN FOR date=m.ldI
				IF print_rep.date<>m.ldI OR EOF("print_rep")						
					INSERT INTO print_rep (date, name_prih, kol_prih, koljir_prih, koled_prih, sootn);
								   VALUES (print_reppr.date, print_reppr.name_prih, print_reppr.kol_prih, print_reppr.koljir_prih, print_reppr.koled_prih, 1)
				ELSE
					REPLACE name_prih WITH print_reppr.name_prih, kol_prih WITH print_reppr.kol_prih, koljir_prih WITH print_reppr.koljir_prih, koled_prih WITH print_reppr.koled_prih IN print_rep
				ENDIF
				*
				IF !EOF("print_rep")
					SKIP IN print_rep
				ENDIF
			ENDSCAN
		ENDCASE
		*
		ldI=m.ldI+1
	ENDDO
	*заполнить остатки
*!*		IF SEEK(DTOS(m.tddatebeg)+BINTOC(m.idtovar),"ost","datetovar")
*!*			lckoln=ost.koln
*!*			lckolnjir=ost.kolnjir
*!*			lckolned=ost.koln
*!*		ELSE
		STORE 0 TO lnkoln, lnkolnjir, lnkolned
*!*		ENDIF
	*
*!*		SELECT print_rep
*!*		SCAN
*!*			REPLACE koln WITH m.lckoln, kolnjir WITH lckolnjir, kolned WITH m.lckolned, kolk WITH m.lckoln+kol_prih-kol_rash, kolkjir WITH m.lckolnjir+koljir_prih-koljir_rash, kolked WITH m.lckolned+koled_prih-koled_rash
*!*			lckoln=print_rep.kolk
*!*			lckolnjir=print_rep.kolkjir
*!*			lckolned=print_rep.kolked
*!*		ENDSCAN
	*заполнить итоги по декадам
	lnJ=0
	ldI=m.tddatebeg
	ldOldD=m.tddatebeg
	DO WHILE ldI<=m.tddateend
	    lnJ=m.lnJ+1
	    IF m.lnJ>9
	    	DIMENSION arcursgroup[1, 1]
			arcursgroup[1, 1]=''
	    	*
			SELECT name_prih, SUM(kol_prih), SUM(koljir_prih), '', 0, 0;
			FROM print_rep INTO ARRAY arcursgroup;
			WHERE BETWEEN(date, m.ldOldD, m.ldI) AND !EMPTY(name_prih);
			GROUP BY name_prih;
			ORDER BY 1
			*
			SELECT name_rash, SUM(kol_rash) as kolrh, SUM(koljir_rash) as koljirrh;
			FROM print_rep INTO CURSOR cursgroup;
			WHERE BETWEEN(date, m.ldOldD, m.ldI) AND !EMPTY(name_rash);
			GROUP BY name_rash;
			ORDER BY 1
			*
			DIMENSION arcursgroup(ALEN(arcursgroup, 1), 6)
			IF EMPTY(arcursgroup[1, 1])
				arcursgroup[1, 2]=0
				arcursgroup[1, 3]=0
			ENDIF
			arcursgroup[1, 4]=''
			arcursgroup[1, 5]=0
			arcursgroup[1, 6]=0
			*
			LOCAL lnK
			lnK=1
			SELECT cursgroup
			SCAN
				IF m.lnK>ALEN(arcursgroup, 1)
					DIMENSION arcursgroup[m.lnK, 6]
					arcursgroup[m.lnK, 1]=''
					arcursgroup[m.lnK, 2]=0
					arcursgroup[m.lnK, 3]=0
				ENDIF
				*
				arcursgroup[m.lnK, 4]=name_rash
				arcursgroup[m.lnK, 5]=kolrh
				arcursgroup[m.lnK, 6]=koljirrh
				*
				lnK=m.lnK+1
			ENDSCAN
			*
			FOR lnK=1 TO ALEN(arcursgroup, 1)
				IF !(EMPTY(arcursgroup[m.lnK, 1]) AND EMPTY(arcursgroup[m.lnK, 4]))
					INSERT INTO print_rep (date, name_prih, kol_prih, koljir_prih, name_rash, kol_rash, koljir_rash, sootn, flag);
								   VALUES (m.ldI, arcursgroup[m.lnK, 1], arcursgroup[m.lnK, 2], arcursgroup[m.lnK, 3], arcursgroup[m.lnK, 4], arcursgroup[m.lnK, 5], arcursgroup[m.lnK, 6], 1, 1)
				ENDIF
			ENDFOR
			*
			RELEASE arcursgroup
			*
	        lnJ=0
			ldOldD=m.ldI+1
	    ENDIF
	    *
		ldI=m.ldI+1
	ENDDO
	*
   	DIMENSION arcursgroup[1, 1]
	arcursgroup[1, 1]=''
	*
	SELECT name_prih, SUM(kol_prih), SUM(koljir_prih), '', 0, 0;
	FROM print_rep INTO ARRAY arcursgroup;
	WHERE BETWEEN(date, m.tddatebeg, m.tddateend) AND !EMPTY(name_prih) AND flag=0;
	GROUP BY name_prih;
	ORDER BY 1
	*
	SELECT name_rash, SUM(kol_rash) as kolrh, SUM(koljir_rash) as koljirrh;
	FROM print_rep INTO CURSOR cursgroup;
	WHERE BETWEEN(date, m.tddatebeg, m.tddateend) AND !EMPTY(name_rash) AND flag=0;
	GROUP BY name_rash;
	ORDER BY 1
	*
	DIMENSION arcursgroup(ALEN(arcursgroup, 1), 6)
	IF EMPTY(arcursgroup[1, 1])
		arcursgroup[1, 2]=0
		arcursgroup[1, 3]=0
	ENDIF
	arcursgroup[1, 4]=''
	arcursgroup[1, 5]=0
	arcursgroup[1, 6]=0
	*
	LOCAL lnK
	lnK=1
	SELECT cursgroup
	SCAN
		IF m.lnK>ALEN(arcursgroup, 1)
			DIMENSION arcursgroup(m.lnK, 6)
			arcursgroup[m.lnK, 1]=''
			arcursgroup[m.lnK, 2]=0
			arcursgroup[m.lnK, 3]=0
		ENDIF
		*
		arcursgroup[m.lnK, 4]=name_rash
		arcursgroup[m.lnK, 5]=kolrh
		arcursgroup[m.lnK, 6]=koljirrh
		*
		lnK=m.lnK+1
	ENDSCAN
	*
	FOR lnK=1 TO ALEN(arcursgroup, 1)
		INSERT INTO print_rep (date, name_prih, kol_prih, koljir_prih, name_rash, kol_rash, koljir_rash, kolk, kolkjir, flag);
					   VALUES (m.tddateend, arcursgroup[m.lnK, 1], arcursgroup[m.lnK, 2], arcursgroup[m.lnK, 3], arcursgroup[m.lnK, 4], arcursgroup[m.lnK, 5], arcursgroup[m.lnK, 6], m.lnkoln, m.lnkolnjir, 2)
	ENDFOR
	*
    WAIT CLEAR
    *
    =SEEK(m.tcidprod, "PRODUCTION", "ID")

    date1=m.tddatebeg
    date2=m.tddateend
	oListener=CREATEOBJECT("ReportListener")
	oListener.ListenerType=1 && Preview, or 0 for Print 
	SELECT print_rep
	REPORT FORM (".\prih_rash_prod") OBJECT oListener TO PRINTER PROMPT
	*
	USE IN cursgroup
	USE IN print_rep
	USE IN print_reppr
    
    RELEASE m.oListener