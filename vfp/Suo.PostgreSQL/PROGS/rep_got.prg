*готовая продукция в упаковке
PARAMETERS idtovar, datebeg, dateend
LOCAL lcI, lcJ, foulog, lcproview, lcsumviewprih, lcsumviewrash, lcidrash, lcidprih, arcursgroup
    WAIT WINDOW NOWAIT "Создание отчета..."
    *
	CREATE CURSOR print_rep (date d, koln n(10,3), kolnjir n(10,3), kolned n(10,3),;
							name_prih c(70), kol_prih n(10,3), koljir_prih n(10,3), koled_prih n(10,3),;
							name_rash c(70), kol_rash n(10,3), koljir_rash n(10,3), koled_rash n(10,3),;
							kolk n(10,3), kolkjir n(10,3), flag n(1))
	INDEX ON DTOS(date)+STR(flag,1)+IIF(!EMPTY(name_prih),'0','9')+IIF(!EMPTY(name_rash),'0','9') TAG dt
	*
	CREATE CURSOR print_reppr (date d, name_prih c(70), kol_prih n(10,3), koljir_prih n(10,3), koled_prih n(10,3))
	*
	DIMENSION lcproview(1,4), lcsumviewprih(1,2), lcsumviewrash(1,2)
	*
	SELECT DISTINCT 0, production.id, PADR(RTRIM(production.name)+'('+RTRIM(edizm.name)+') '+RTRIM(typedoc.name)+' '+RTRIM(organ.name),70), edizm.id, organ.id, typedoc.id, edizm.ves;
	FROM nakl LEFT JOIN passw ON passw.id=nakl.id_pas;
			  LEFT JOIN typedoc ON typedoc.id=nakl.id_typedoc;
			  LEFT JOIN organ ON organ.id=nakl.id_organ;
			  LEFT JOIN production ON production.id=passw.id_pro;
			  LEFT JOIN edizm ON edizm.id=passw.id_edz INTO ARRAY lcproview;
	WHERE nakl.id IN (SELECT id_nak;
					  FROM nakl_cont;
					  WHERE id_tovar=m.idtovar) AND;
 		  BETWEEN(nakl.date,m.datebeg,m.dateend);
	UNION ALL;
	SELECT DISTINCT 1, typedoc.id, PADR(RTRIM(typedoc.name)+'('+RTRIM(edizm.name)+') '+RTRIM(organ.name),70), edizm.id, organ.id, typedoc.id, edizm.ves;
	FROM nakl_cont LEFT JOIN edizm ON edizm.id=nakl_cont.id_edz;
				   LEFT JOIN nakl ON nakl.id=nakl_cont.id_nak AND BETWEEN(nakl.date,m.datebeg,m.dateend) AND nakl.id_pas=0;
				   LEFT JOIN typedoc ON typedoc.id=nakl.id_typedoc;
				   LEFT JOIN organ ON organ.id=nakl.id_organ;
    WHERE id_tovar=m.idtovar
	*
	IF SEEK("Расход","typedoc","name") AND typedoc.pid=0
		lcidrash=typedoc.id
	ENDIF
	*
	IF SEEK("Приход","typedoc","name") AND typedoc.pid=0
		lcidprih=typedoc.id
	ENDIF
	*
	lcI=m.datebeg
	DO WHILE lcI<=m.dateend
		STORE 0 TO m.koln, m.kolnjir, m.kolk, m.kolkjir
		*
		FOR lcJ=1 TO ALEN(lcproview,1)
			STORE 0 TO lcsumviewprih(1,1), lcsumviewprih(1,2), lcsumviewrash(1,1), lcsumviewrash(1,2)
			*
			IF VARTYPE(lcproview(m.lcJ,1))='N'
				DO CASE
				CASE lcproview(m.lcJ,1)=0
					SELECT SUM(kol), SUM(koljir);
					FROM nakl_cont INTO ARRAY lcsumviewprih;
					WHERE id_nak IN (SELECT id;
						 			 FROM nakl;
					 			  	 WHERE id_pas IN (SELECT id;
					 			  	 				  FROM passw;
					 			  	 				  WHERE id_pro=lcproview(m.lcJ,2) AND date=m.lcI AND id_edz=lcproview(m.lcJ,4)) AND;
					 			  	 	   date=m.lcI AND id_typedoc=lcproview(m.lcJ,6) AND id_typedoc IN (SELECT id FROM typedoc WHERE PID=m.lcidprih) AND id_organ=lcproview(m.lcJ,5)) AND id_tovar=m.idtovar
					*
					SELECT SUM(kol), SUM(koljir);
					FROM nakl_cont INTO ARRAY lcsumviewrash;
					WHERE id_nak IN (SELECT id;
						 			 FROM nakl;
					 			  	 WHERE id_pas IN (SELECT id;
					 			  	 				  FROM passw;
					 			  	 				  WHERE id_pro=lcproview(m.lcJ,2) AND date=m.lcI AND id_edz=lcproview(m.lcJ,4)) AND;
					 			  	 	   date=m.lcI AND id_typedoc=lcproview(m.lcJ,6) AND id_typedoc IN (SELECT id FROM typedoc WHERE PID=m.lcidrash) AND id_organ=lcproview(m.lcJ,5)) AND id_tovar=m.idtovar
				CASE lcproview(m.lcJ,1)=1 AND !ISNULL(lcproview(m.lcJ,2))
					IF SEEK(lcproview(m.lcJ,2),"typedoc","ID") AND typedoc.pid=m.lcidprih
						SELECT SUM(kol), SUM(koljir);
						FROM nakl_cont INTO ARRAY lcsumviewprih;
						WHERE id_nak IN (SELECT id;
							 			 FROM nakl;
						 			  	 WHERE id_typedoc=lcproview(m.lcJ,2) AND date=m.lcI AND id_organ=lcproview(m.lcJ,5)) AND id_tovar=m.idtovar
					ELSE
						SELECT SUM(kol), SUM(koljir);
						FROM nakl_cont INTO ARRAY lcsumviewrash;
						WHERE id_nak IN (SELECT id;
							 			 FROM nakl;
						 			  	 WHERE id_typedoc=lcproview(m.lcJ,2) AND date=m.lcI AND id_organ=lcproview(m.lcJ,5)) AND id_tovar=m.idtovar
					ENDIF
				ENDCASE
				*
				lcsumviewprih(1,1)=NVL(lcsumviewprih(1,1),0)
				lcsumviewrash(1,1)=NVL(lcsumviewrash(1,1),0)
				*
				IF lcsumviewprih(1,1)#0
					lcsumviewprih(1,2)=NVL(lcsumviewprih(1,2),0)
					*
					INSERT INTO print_reppr (date, name_prih, kol_prih, koljir_prih, koled_prih);
								   VALUES (m.lcI, IIF(lcsumviewprih(1,1)#0,lcproview(m.lcJ,3),''), lcsumviewprih(1,1), lcsumviewprih(1,2), ROUND(div(lcsumviewprih(1,1),lcproview(m.lcJ,7)),0))
				ENDIF
				*
				IF lcsumviewrash(1,1)#0
					lcsumviewrash(1,2)=NVL(lcsumviewrash(1,2),0)
					*
					INSERT INTO print_rep (date, name_rash, kol_rash, koljir_rash, koled_rash);
								     VALUES (m.lcI, IIF(lcsumviewrash(1,1)#0,lcproview(m.lcJ,3),''), lcsumviewrash(1,1), lcsumviewrash(1,2), ROUND(div(lcsumviewrash(1,1),lcproview(m.lcJ,7)),0))
				ENDIF
			ENDIF
		ENDFOR
		*
		lcI=m.lcI+1
	ENDDO
	*
	LOCAL lccntrep,lccntreppr
	lcI=m.datebeg
	DO WHILE lcI<=m.dateend
		SELECT print_rep
		COUNT TO lccntrep FOR date=m.lcI
		SELECT print_reppr
		COUNT TO lccntreppr FOR date=m.lcI
		*
		DO CASE
		CASE lccntrep=0
		*добавляем записи из приходов
			INSERT INTO print_rep (date, name_prih, kol_prih, koljir_prih, koled_prih) SELECT date, name_prih, kol_prih, koljir_prih, koled_prih FROM print_reppr WHERE date=m.lcI
		CASE lccntrep>=lccntreppr
		*сделать замену
			SELECT print_reppr
			LOCATE FOR date=m.lcI
			*
			SELECT print_rep
			SCAN FOR date=m.lcI
				IF print_reppr.date#m.lcI OR EOF("print_reppr")
					EXIT
				ELSE
					REPLACE name_prih WITH print_reppr.name_prih, kol_prih WITH print_reppr.kol_prih, koljir_prih WITH print_reppr.koljir_prih, koled_prih WITH print_reppr.koled_prih IN print_rep
					SKIP IN print_reppr
				ENDIF
			ENDSCAN
		CASE lccntrep<lccntreppr
		*сделать замену
			SELECT print_rep
			LOCATE FOR date=m.lcI
			*
			SELECT print_reppr
			SCAN FOR date=m.lcI
				IF print_rep.date#m.lcI OR EOF("print_rep")						
					INSERT INTO print_rep (date, name_prih, kol_prih, koljir_prih, koled_prih);
								   VALUES (print_reppr.date, print_reppr.name_prih, print_reppr.kol_prih, print_reppr.koljir_prih, print_reppr.koled_prih)
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
		lcI=m.lcI+1
	ENDDO
	*заполнить остатки
	IF SEEK(DTOS(m.datebeg)+BINTOC(m.idtovar),"ostat","datetovar")
		lckoln=ostat.koln
		lckolnjir=ostat.kolnjir
		lckolned=ostat.koln
	ELSE
		STORE 0 TO lckoln, lckolnjir, lckolned
	ENDIF
	*
	SELECT print_rep
	SCAN
		REPLACE koln WITH m.lckoln, kolnjir WITH lckolnjir, kolned WITH m.lckolned, kolk WITH m.lckoln+kol_prih-kol_rash, kolkjir WITH m.lckolnjir+koljir_prih-koljir_rash, kolked WITH m.lckolned+koled_prih-koled_rash
		lckoln=print_rep.kolk
		lckolnjir=print_rep.kolkjir
		lckolned=print_rep.kolked
	ENDSCAN
	*заполнить итоги по декадам
	lcJ=0
	lcI=m.datebeg
	lcOldD=m.datebeg
	DO WHILE lcI<=m.dateend
	    lcJ=m.lcJ+1
	    IF m.lcJ>9
	    	DIMENSION arcursgroup(1,1)
			arcursgroup(1,1)=''
	    	*
			SELECT name_prih, SUM(kol_prih), SUM(koljir_prih), '', 0, 0;
			FROM print_rep INTO ARRAY arcursgroup;
			WHERE BETWEEN(date,m.lcOldD,m.lcI) AND !EMPTY(name_prih);
			GROUP BY name_prih;
			ORDER BY 1
			*
			SELECT name_rash, SUM(kol_rash) as kolrh, SUM(koljir_rash) as koljirrh;
			FROM print_rep INTO CURSOR cursgroup;
			WHERE BETWEEN(date,m.lcOldD,m.lcI) AND !EMPTY(name_rash);
			GROUP BY name_rash;
			ORDER BY 1
			*
			DIMENSION arcursgroup(ALEN(arcursgroup,1),6)
			IF EMPTY(arcursgroup(1,1))
				arcursgroup(1,2)=0
				arcursgroup(1,3)=0
			ENDIF
			arcursgroup(1,4)=''
			arcursgroup(1,5)=0
			arcursgroup(1,6)=0
			*
			LOCAL lcK
			lcK=1
			SELECT cursgroup
			SCAN
				IF m.lcK>ALEN(arcursgroup,1)
					DIMENSION arcursgroup(m.lcK,6)
					arcursgroup(m.lcK,1)=''
					arcursgroup(m.lcK,2)=0
					arcursgroup(m.lcK,3)=0
				ENDIF
				*
				arcursgroup(m.lcK,4)=name_rash
				arcursgroup(m.lcK,5)=kolrh
				arcursgroup(m.lcK,6)=koljirrh
				*
				lcK=m.lcK+1
			ENDSCAN
			*
			FOR lcK=1 TO ALEN(arcursgroup,1)
				IF !(EMPTY(arcursgroup(m.lcK,1)) AND EMPTY(arcursgroup(m.lcK,4)))
					INSERT INTO print_rep (date, name_prih, kol_prih, koljir_prih, name_rash, kol_rash, koljir_rash, flag);
								   VALUES (m.lcI, arcursgroup(m.lcK,1), arcursgroup(m.lcK,2), arcursgroup(m.lcK,3), arcursgroup(m.lcK,4), arcursgroup(m.lcK,5), arcursgroup(m.lcK,6), 1)
				ENDIF
			ENDFOR
			*
			RELEASE arcursgroup
			*
	        m.lcJ=0
			lcOldD=m.lcI+1
	    ENDIF
	    *
		lcI=m.lcI+1
	ENDDO
	*
   	DIMENSION arcursgroup(1,1)
	arcursgroup(1,1)=''
	*
	SELECT name_prih, SUM(kol_prih), SUM(koljir_prih), '', 0, 0;
	FROM print_rep INTO ARRAY arcursgroup;
	WHERE BETWEEN(date,m.datebeg,m.dateend) AND !EMPTY(name_prih) AND flag=0;
	GROUP BY name_prih;
	ORDER BY 1
	*
	SELECT name_rash, SUM(kol_rash) as kolrh, SUM(koljir_rash) as koljirrh;
	FROM print_rep INTO CURSOR cursgroup;
	WHERE BETWEEN(date,m.datebeg,m.dateend) AND !EMPTY(name_rash) AND flag=0;
	GROUP BY name_rash;
	ORDER BY 1
	*
	DIMENSION arcursgroup(ALEN(arcursgroup,1),6)
	IF EMPTY(arcursgroup(1,1))
		arcursgroup(1,2)=0
		arcursgroup(1,3)=0
	ENDIF
	arcursgroup(1,4)=''
	arcursgroup(1,5)=0
	arcursgroup(1,6)=0
	*
	LOCAL lcK
	lcK=1
	SELECT cursgroup
	SCAN
		IF m.lcK>ALEN(arcursgroup,1)
			DIMENSION arcursgroup(m.lcK,6)
			arcursgroup(m.lcK,1)=''
			arcursgroup(m.lcK,2)=0
			arcursgroup(m.lcK,3)=0
		ENDIF
		*
		arcursgroup(m.lcK,4)=name_rash
		arcursgroup(m.lcK,5)=kolrh
		arcursgroup(m.lcK,6)=koljirrh
		*
		lcK=m.lcK+1
	ENDSCAN
	*
	FOR lcK=1 TO ALEN(arcursgroup,1)
		INSERT INTO print_rep (date, name_prih, kol_prih, koljir_prih, name_rash, kol_rash, koljir_rash, kolk, kolkjir, flag);
					   VALUES (m.dateend, arcursgroup(m.lcK,1), arcursgroup(m.lcK,2), arcursgroup(m.lcK,3), arcursgroup(m.lcK,4), arcursgroup(m.lcK,5), arcursgroup(m.lcK,6), m.lckoln, m.lckolnjir, 2)
	ENDFOR
	*
    WAIT CLEAR
    *
	oListener=CREATEOBJECT("ReportListener")
	oListener.ListenerType=1 && Preview, or 0 for Print 
	SELECT print_rep
	REPORT FORM (m.curdirs+"\FRX\prih_rash") OBJECT oListener TO PRINTER PROMPT
	*
	USE IN cursgroup
	USE IN print_rep
	USE IN print_reppr