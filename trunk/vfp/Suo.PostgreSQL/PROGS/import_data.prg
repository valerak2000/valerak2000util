goApp.GoForm("FORMS\EXPIMP", 0, .NULL., .NULL.)

PROCEDURE exp_data
*экспорт - накладных, паспортов, гр.паспортов
LPARAMETERS datebeg as Date, dateend as Date, datadir as String
LOCAL fph as Number, lcstrexp as String
	IF FILE(goApp.cfltpathexpimp+"EXPORT_PASSW.XML")
		DELETE FILE goApp.cfltpathexpimp+"EXPORT_PASSW.XML"
	ENDIF
	IF FILE(goApp.cfltpathexpimp+"EXPORT_GRPASSW.XML")
		DELETE FILE goApp.cfltpathexpimp+"EXPORT_GRPASSW.XML"
	ENDIF
	IF FILE(goApp.cfltpathexpimp+"EXPORT_NAKL.XML")
		DELETE FILE goApp.cfltpathexpimp+"EXPORT_NAKL.XML"
	ENDIF
	*
	IF !FILE(m.datadir+"\DBF\PASSW.DBF")
        MESSAGEBOX("В каталоге отсутствует база данных!", 16, _SCREEN.Caption)
		RETURN
	ENDIF
	*экспорт паспортов
	SELECT DATE as DATE_PASSW, NOMER as NOMER_PASSW, ORGAN.NAME as ORGAN_NAME, EDIZM.NAME as EDIZM_NAME, PRODUCTION.COMMENT as PRODUCTION_NAME,;
			LABAN, KOLINM as KOLM, JIRINM as JIRM, KOLJIRINM as KOLJIRM, PLOTNINM as PLOTNM, KOLSUHM, SUHM,;
			KOLPAHT, KOLJIRPAHT, SUHPAHT, KOLSUHPAHT,;
			JIRINSM, RSJIRSM, NRSM, KOLSM, DELTSM, KOLJIRSM, DELTJIRSM,;
			SUHSM, KOLSUHSM, KOLOB, JIROB, SUHOB, KOLSUHOB,	PLOTNOB, KOLGOT,;
			OBRAT, KOLGT, KSMOM, KSMOO,;
			IIF(PASSW.ID_PRO="002",KOLPAHT,IIF(PASSW.ID_PRO="004",KOLOB,000000000000000000000000.000000000000)) as KOLSL, IIF(PASSW.ID_PRO="002",KOLJIRPAHT,IIF(PASSW.ID_PRO="004",ROUND(KOLOB*JIROB/100,2),000000000000000000000000.000000000000)) as KOLJIRSL, IIF(PASSW.ID_PRO="002",KOLSM,000000000000000000000000.000000000000) as KOLPOT,;
			IIF(PASSW.ID_PRO="004",KOLINM,IIF(PASSW.ID_PRO="006" OR PASSW.ID_PRO="007",KOLINM,000000000000000000000000.000000000000)) as KOLSYV, IIF(PASSW.ID_PRO="004",SUHPAHT,IIF(PASSW.ID_PRO="006" OR PASSW.ID_PRO="007",SUHPAHT,000000000000000000000000.000000000000)) as NORMSUH,;
			IIF(PASSW.ID_PRO="004",JIROB,000000000000000000000000.000000000000) as JIRSL, IIF(PASSW.ID_PRO="004",KOLSUHOB,000000000000000000000000.000000000000) as KOLSUHSL, IIF(PASSW.ID_PRO="004",SUHOB,000000000000000000000000.000000000000) as SUHSL;
	FROM (m.datadir+"\DBF\PASSW") LEFT JOIN (m.datadir+"\DBF\ORGAN") ON PASSW.ID_ORGAN=ORGAN.ID;
			   LEFT JOIN (m.datadir+"\DBF\EDIZM") ON PASSW.ID_TARA=EDIZM.ID;
			   LEFT JOIN (m.datadir+"\DBF\PRODUCTION") ON PASSW.ID_PRO=PRODUCTION.ID INTO CURSOR TMPPASSW;
	WHERE !DELETED() AND BETWEEN(PASSW.DATE,m.datebeg,m.dateend);
	ORDER BY 5,1,2
	*
	CURSORTOXML("TMPPASSW", goApp.cfltpathexpimp+"EXPORT_PASSW.XML", 2, 16+512, 0, "1")
	USE IN TMPPASSW
	*экспорт гр.паспортов
	SELECT GRPPASSW.DATE as DATE_GRPASSW, GRPPASSW.NOMER as NOMER_GRPASSW, PRODUCTION.COMMENT as PRODUCTION_NAME, EDIZM.NAME as EDIZM_NAME, PASSW.NOMER as NOMER_PASSW, PASSW.DATE as DATE_PASSW;
	FROM (m.datadir+"\DBF\GRPPASSW") LEFT JOIN (m.datadir+"\DBF\PRODUCTION") ON ALLTRIM(GRPPASSW.ID_PRO)==ALLTRIM(PRODUCTION.ID);
				  LEFT JOIN (m.datadir+"\DBF\EDIZM") ON EDIZM.ID=GRPPASSW.ID_TARA;
				  LEFT JOIN (m.datadir+"\DBF\GRPASS_CONT") ON GRPPASSW.ID=GRPASS_CONT.ID_GRPAS;
			      LEFT JOIN (m.datadir+"\DBF\PASSW") ON GRPASS_CONT.ID_PAS=PASSW.ID INTO CURSOR TMPGRPASSW;
	WHERE !DELETED() AND BETWEEN(GRPPASSW.DATE,m.datebeg,m.dateend);
	ORDER BY 3,1,2
	*
	CURSORTOXML("TMPGRPASSW", goApp.cfltpathexpimp+"EXPORT_GRPASSW.XML", 2, 16+512, 0, "1")
	USE IN TMPGRPASSW
	*экспорт накладных(без порожденных документов)
	SELECT NOMER as NOMER_NAKL, date as DATE_NAKL, ORGAN.NAME as ORGAN_NAME, TYPEDOC.NAME as TYPEDOC_NAME, NVL(TOVAR.NAME,SPACE(100)) as TOVAR_NAME, NVL(EDIZM.NAME,SPACE(40)) as EDIZM_NAME, NVL(KOL,00000000.000000) as kol, NVL(KOLJIR,00000000.000000) as koljir;
	FROM (m.datadir+"\DBF\nakl") LEFT JOIN (m.datadir+"\DBF\ORGAN") ON NAKL.ID_ORGAN=ORGAN.ID;
			  LEFT JOIN (m.datadir+"\DBF\TYPEDOC") ON ALLTRIM(NAKL.TYPEDOC)==ALLTRIM(TYPEDOC.ID);
			  LEFT JOIN (m.datadir+"\DBF\NAKL_CONT") ON NAKL_CONT.ID_NAK=NAKL.ID;
			  LEFT JOIN (m.datadir+"\DBF\TOVAR") ON TOVAR.ID=NAKL_CONT.ID_TOVAR;
			  LEFT JOIN (m.datadir+"\DBF\EDIZM") ON EDIZM.ID=NAKL_CONT.ID_TARA INTO CURSOR TMPNAKL;
	WHERE !DELETED() AND BETWEEN(NAKL.DATE,m.datebeg,m.dateend) AND NAKL.ID_PAS=0 AND NAKL.ID_PARNAK=0;
	ORDER BY 4,1,2
	*
	CURSORTOXML("TMPNAKL", goApp.cfltpathexpimp+"EXPORT_NAKL.XML", 2, 16+512, 0, "1")
	USE IN TMPNAKL
	*
	CLOSE DATABASES ALL

PROCEDURE imp_data
*импорт - накладных, паспортов, гр.паспортов
LOCAL lnI as Integer, lnJ as Integer, lbfou as Logical
	SetEnvironment()
	*
	IF setBase()
		*импорт накладных(без порожденных документов)
		IF FILE(goApp.cfltpathexpimp+"EXPORT_NAKL.XML") AND XMLTOCURSOR(goApp.cfltpathexpimp+"EXPORT_NAKL.XML","TMPNAKL",512)>0 AND USED("TMPNAKL")
			LOCAL ARRAY lanakl[1,6], lanakl_cont[1,5]
			lanakl[1,1]=CTOD('')
			lanakl[1,2]=''
			lanakl[1,3]=0
			lanakl[1,4]=0
			*
			STORE 0 TO lanakl_cont[1,1],lanakl_cont[1,2],lanakl_cont[1,3],lanakl_cont[1,4],lanakl_cont[1,5]
			*
			SELECT TMPNAKL
			INDEX ON DTOS(DATE_NAKL)+NOMER_NAKL+TYPEDOC_NAME+ORGAN_NAME TAG IdNakl
			*
			SCAN
				*
				IF !EMPTY(TMPNAKL.DATE_NAKL) AND !EMPTY(TMPNAKL.NOMER_NAKL) AND !EMPTY(TMPNAKL.TYPEDOC_NAME) AND !EMPTY(TMPNAKL.ORGAN_NAME) AND (TMPNAKL.KOL#0 OR TMPNAKL.KOLJIR#0)
				*документ можно идентифицировать
					IF SEEK(TMPNAKL.TYPEDOC_NAME,"TYPEDOC","NAME") AND SEEK(TMPNAKL.ORGAN_NAME,"ORGAN","NAME") AND SEEK(TMPNAKL.TOVAR_NAME,"TOVAR","NAME") AND SEEK(TMPNAKL.EDIZM_NAME,"EDIZM","NAME")
						lbfou=.f.
						FOR lnI=1 TO ALEN(lanakl,1)
							IF lanakl[m.lnI,1]=TMPNAKL.DATE_NAKL AND lanakl[m.lnI,2]==ALLTRIM(TMPNAKL.NOMER_NAKL) AND lanakl[m.lnI,3]=TYPEDOC.ID AND lanakl[m.lnI,4]=ORGAN.ID
								lbfou=.t.
								EXIT
							ENDIF
						ENDFOR
						*
						IF !m.lbfou
							IF !EMPTY(lanakl[1,1])
								lnI=ALEN(lanakl,1)+1
								DIMENSION lanakl[m.lnI,6]
							ELSE
								lnI=1
							ENDIF
							*
							lanakl[m.lnI,1]=TMPNAKL.DATE_NAKL
							lanakl[m.lnI,2]=ALLTRIM(TMPNAKL.NOMER_NAKL)
							lanakl[m.lnI,3]=TYPEDOC.ID
							lanakl[m.lnI,4]=ORGAN.ID
							lanakl[m.lnI,5]=TMPNAKL.TYPEDOC_NAME
							lanakl[m.lnI,6]=.f.
						ENDIF
						*
						lbfou=.f.
						FOR lnJ=1 TO ALEN(lanakl_cont,1)
							IF lanakl_cont[m.lnJ,1]=m.lnI AND lanakl_cont[m.lnJ,2]=TOVAR.ID AND lanakl_cont[m.lnJ,3]=EDIZM.ID
								lbfou=.t.
								EXIT
							ENDIF
						ENDFOR
						*
						IF !m.lbfou
							IF lanakl_cont[1,1]#0
								lnJ=ALEN(lanakl_cont,1)+1
								DIMENSION lanakl_cont[m.lnJ,5]
							ELSE
								lnJ=1
							ENDIF
							*
							lanakl_cont[m.lnJ,1]=m.lnI
							lanakl_cont[m.lnJ,2]=TOVAR.ID
							lanakl_cont[m.lnJ,3]=EDIZM.ID
							lanakl_cont[m.lnJ,4]=TMPNAKL.KOL
							lanakl_cont[m.lnJ,5]=TMPNAKL.KOLJIR
						ENDIF
					ENDIF
				ENDIF
			ENDSCAN
			*
			USE IN TMPNAKL
			*сделать изменения в базе
	    	=show_termom("Импорт накладных",0,ALEN(lanakl,1),0)
	    	*
			FOR lnI=1 TO ALEN(lanakl,1)
				IF EMPTY(lanakl[m.lnI,1])
					LOOP
				ENDIF
			    =show_termom('',1,ALEN(lanakl,1),m.lnI,'',lanakl[m.lnI,2]+" от "+DTOC(lanakl[m.lnI,1])+' '+lanakl[m.lnI,5])
			    *
				SELECT NAKL
				SET ORDER TO typdate
				SEEK BINTOC(lanakl[m.lnI,3])+DTOS(lanakl[m.lnI,1])
				SCAN REST WHILE BINTOC(ID_TYPEDOC)+DTOS(DATE)=BINTOC(lanakl[m.lnI,3])+DTOS(lanakl[m.lnI,1])
					IF ALLTRIM(NOMER)==lanakl[m.lnI,2] AND ID_PARNAK=0
						IF ID_ORGAN#lanakl[m.lnI,4]
							REPLACE ID_ORGAN WITH lanakl[m.lnI,4]
						ENDIF
						lanakl[m.lnI,6]=.t.
						*удаляем прежний состав накладной
						SELECT nakl_cont
						SCAN FOR BINTOC(ID_NAK)+BINTOC(ID_TOVAR)+BINTOC(ID_EDZ)=BINTOC(NAKL.ID)
							=chnakl(1,NAKL.ID,NAKL_CONT.ID_TOVAR,NAKL_CONT.ID_EDZ)
						ENDSCAN
						*
						EXIT
					ENDIF
				ENDSCAN
				*
				IF !lanakl[m.lnI,6]
				*создать новый документ
					LOCAL laARSORTID[1] as Integer
					LOCAL lnnewSORTID as Integer
					*
					SELECT MAX(SORTID) FROM NAKL INTO ARRAY laARSORTID WHERE BINTOC(PID)=BINTOC(0)
					lnnewSORTID=NVL(laARSORTID[1],0)+1
					*
					INSERT INTO NAKL (ISFOLDER, PID, SORTID, DATE, NOMER, ID_TYPEDOC, ID_ORGAN) VALUES (2, 0, m.lnnewSORTID, lanakl[m.lnI,1], PADL(lanakl[m.lnI,2],10), lanakl[m.lnI,3], lanakl[m.lnI,4])
				ENDIF
				*создаем новый состав накладной
				FOR lnJ=1 TO ALEN(lanakl_cont,1)
					IF lanakl_cont[m.lnJ,1]=m.lnI
						=chnakl(0,NAKL.ID,lanakl_cont[m.lnJ,2],lanakl_cont[m.lnJ,3],lanakl_cont[m.lnJ,4],lanakl_cont[m.lnJ,5])
					ENDIF
				ENDFOR
			ENDFOR
			*
	    	=show_termom('',2,0,0)
		ENDIF
		*импорт паспортов
		IF FILE(goApp.cfltpathexpimp+"EXPORT_PASSW.XML") AND XMLTOCURSOR(goApp.cfltpathexpimp+"EXPORT_PASSW.XML","TMPPASSW",512)>0 AND USED("TMPPASSW")
			LOCAL losoftprodobj as Object, losoftpasswobj as Object, lcprocname as String
			*
			losoftprodobj=CREATEOBJECT("softpole.softpole")
			losoftprodobj.listsoftpole("PRODUCTION")
			*
			losoftpasswobj=CREATEOBJECT("softpole.softpole")
			losoftpasswobj.listsoftpole("PASSW")
			*
			SELECT TMPPASSW
	    	=show_termom("Импорт паспортов",0,RECCOUNT(),0)
			SCAN
				IF !EMPTY(TMPPASSW.DATE_PASSW) AND !EMPTY(TMPPASSW.NOMER_PASSW) AND !EMPTY(TMPPASSW.PRODUCTION_NAME) AND !EMPTY(TMPPASSW.EDIZM_NAME)
				*документ можно идентифицировать
					IF SEEK(TMPPASSW.PRODUCTION_NAME,"PRODUCTION","NAME") AND SEEK(TMPPASSW.ORGAN_NAME,"ORGAN","NAME") AND SEEK(TMPPASSW.EDIZM_NAME,"EDIZM","NAME")
					    =show_termom('',1,RECCOUNT(),RECNO(),'',TMPPASSW.NOMER_PASSW+" от "+DTOC(TMPPASSW.DATE_PASSW)+' '+PRODUCTION.NAME)
					    *
						lcprocname=losoftprodobj.getvaluesname("PROCEDURE",PRODUCTION.ID)
						*
						lbfou=.f.
						*
						SELECT PASSW
						SET ORDER TO prodate
						SEEK BINTOC(PRODUCTION.ID)+DTOS(TMPPASSW.DATE_PASSW)
						SCAN REST WHILE BINTOC(id_pro)+DTOS(DATE)=BINTOC(PRODUCTION.ID)+DTOS(TMPPASSW.DATE_PASSW)
							IF ALLTRIM(NOMER)==ALLTRIM(TMPPASSW.NOMER_PASSW)
								IF ID_ORGAN#ORGAN.ID
									REPLACE ID_ORGAN WITH ORGAN.ID
								ENDIF
								IF ID_EDZ#EDIZM.ID
									REPLACE ID_EDZ WITH EDIZM.ID
								ENDIF
								lbfou=.t.
								*
								EXIT
							ENDIF
						ENDSCAN
						*
						IF !m.lbfou
						*создать новый документ
						    WAIT WINDOW "Идет создание паспорта №"+TMPPASSW.NOMER_PASSW+" от "+DTOC(TMPPASSW.DATE_PASSW)+CHR(13)+PRODUCTION.NAME NOWAIT
						    *
							LOCAL laARSORTID[1] as Integer
							LOCAL lnnewSORTID as Integer
							*
							SELECT MAX(SORTID) FROM PASSW INTO ARRAY laARSORTID WHERE BINTOC(PID)=BINTOC(0)
							lnnewSORTID=NVL(laARSORTID[1],0)+1
							*
							INSERT INTO PASSW (ISFOLDER, PID, SORTID, DATE, NOMER, ID_PRO, ID_ORGAN, ID_EDZ) VALUES (2, 0, m.lnnewSORTID, TMPPASSW.DATE_PASSW, PADL(ALLTRIM(TMPPASSW.NOMER_PASSW),10), PRODUCTION.ID, ORGAN.ID, EDIZM.ID)
						ENDIF
						*изменить документ
						FOR lnI=1 TO ALEN(losoftpasswobj.softpole,1)
							FOR lnJ=1 TO FCOUNT("TMPPASSW")
								IF FIELD(m.lnJ,"TMPPASSW",0)==losoftpasswobj.softpole[m.lnI,2]
									losoftpasswobj.setvaluesname(losoftpasswobj.softpole[m.lnI,2], PASSW.ID, EVALUATE("TMPPASSW."+FIELD(m.lnJ,"TMPPASSW",0)), .F.)
								ENDIF
							ENDFOR
						ENDFOR
						*
					    WAIT WINDOW "Идет перерасчет паспорта №"+PASSW.NOMER+" от "+DTOC(PASSW.DATE)+CHR(13)+PRODUCTION.NAME NOWAIT
						DO (goApp.cAppCurPaths+m.lcprocname) WITH PASSW.ID, m.losoftpasswobj, "CALC"
					ENDIF
				ENDIF
			ENDSCAN
	    	=show_termom('',2,0,0)
			*
			USE IN TMPPASSW
			RELEASE losoftpasswobj
			RELEASE losoftprodobj
		ENDIF
		*импорт гр.паспортов
		IF FILE(goApp.cfltpathexpimp+"EXPORT_GRPASSW.XML") AND XMLTOCURSOR(goApp.cfltpathexpimp+"EXPORT_GRPASSW.XML","TMPGRPASSW",512)>0 AND USED("TMPGRPASSW")
			LOCAL losoftprodobj as Object, losoftgrpasswobj as Object, lcprocname as String
			LOCAL ARRAY lagrpassw[1,6], lagrpassw_cont[1,2]
			lagrpassw[1,1]=CTOD('')
			lagrpassw[1,2]=''
			lagrpassw[1,3]=0
			lagrpassw[1,4]=0
			*
			STORE 0 TO lagrpassw_cont[1,1],lagrpassw_cont[1,2]
			*
			losoftprodobj=CREATEOBJECT("softpole.softpole")
			losoftprodobj.listsoftpole("PRODUCTION")
			*
			losoftgrpasswobj=CREATEOBJECT("softpole.softpole")
			losoftgrpasswobj.listsoftpole("GRPASSW")
			*
			SELECT TMPGRPASSW
			SCAN
				IF !EMPTY(TMPGRPASSW.DATE_GRPASSW) AND !EMPTY(TMPGRPASSW.NOMER_GRPASSW) AND !EMPTY(TMPGRPASSW.PRODUCTION_NAME) AND !EMPTY(TMPGRPASSW.EDIZM_NAME)
				*документ можно идентифицировать
					IF SEEK(TMPGRPASSW.PRODUCTION_NAME,"PRODUCTION","NAME") AND SEEK(TMPGRPASSW.EDIZM_NAME,"EDIZM","NAME")
						lbfou=.f.
						FOR lnI=1 TO ALEN(lagrpassw,1)
							IF lagrpassw[m.lnI,1]=TMPGRPASSW.DATE_GRPASSW AND lagrpassw[m.lnI,2]==ALLTRIM(TMPGRPASSW.NOMER_GRPASSW) AND lagrpassw[m.lnI,3]=PRODUCTION.ID AND lagrpassw[m.lnI,4]=EDIZM.ID
								lbfou=.t.
								EXIT
							ENDIF
						ENDFOR
						*
						IF !m.lbfou
							IF !EMPTY(lagrpassw[1,1])
								lnI=ALEN(lagrpassw,1)+1
								DIMENSION lagrpassw[m.lnI,6]
							ELSE
								lnI=1
							ENDIF
							*
							lagrpassw[m.lnI,1]=TMPGRPASSW.DATE_GRPASSW
							lagrpassw[m.lnI,2]=ALLTRIM(TMPGRPASSW.NOMER_GRPASSW)
							lagrpassw[m.lnI,3]=PRODUCTION.ID
							lagrpassw[m.lnI,4]=EDIZM.ID
							lagrpassw[m.lnI,5]=TMPGRPASSW.PRODUCTION_NAME
							lagrpassw[m.lnI,6]=.f.
						ENDIF
						*найти паспорт
						lbfou=.f.
						SELECT PASSW
						SET ORDER TO prodate
						SEEK BINTOC(PRODUCTION.ID)+DTOS(TMPGRPASSW.DATE_PASSW)
						SCAN REST WHILE BINTOC(id_pro)+DTOS(DATE)=BINTOC(PRODUCTION.ID)+DTOS(TMPGRPASSW.DATE_PASSW)
							IF ALLTRIM(NOMER)==ALLTRIM(TMPGRPASSW.NOMER_PASSW) AND ID_EDZ=EDIZM.ID
								lbfou=.t.
								EXIT
							ENDIF
						ENDSCAN
						*
						IF m.lbfou
							lbfou=.f.
							FOR lnJ=1 TO ALEN(lagrpassw_cont,1)
								IF lagrpassw_cont[m.lnJ,1]=m.lnI AND lagrpassw_cont[m.lnJ,2]=PASSW.ID
									lbfou=.t.
									EXIT
								ENDIF
							ENDFOR
							*
							IF !m.lbfou
								IF lagrpassw_cont[1,1]#0
									lnJ=ALEN(lagrpassw_cont,1)+1
									DIMENSION lagrpassw_cont[m.lnJ,2]
								ELSE
									lnJ=1
								ENDIF
								*
								lagrpassw_cont[m.lnJ,1]=m.lnI
								lagrpassw_cont[m.lnJ,2]=PASSW.ID
							ENDIF
						ENDIF
					ENDIF
				ENDIF
			ENDSCAN
			*
			USE IN TMPGRPASSW
			*
			FOR lnI=1 TO ALEN(lagrpassw,1)
				IF EMPTY(lagrpassw[m.lnI,1])
					LOOP
				ENDIF
				lcprocname=losoftprodobj.getvaluesname("PROCEDURE",lagrpassw[m.lnI,3])+"GR"
				*
				lbfou=.f.
				*
				SELECT GRPASSW
				SET ORDER TO prodate
				SEEK BINTOC(lagrpassw[m.lnI,3])+DTOS(lagrpassw[m.lnI,1])
				SCAN REST WHILE BINTOC(id_pro)+DTOS(DATE)=BINTOC(lagrpassw[m.lnI,3])+DTOS(lagrpassw[m.lnI,1])
					IF ALLTRIM(NOMER)==lagrpassw[m.lnI,2]
						IF ID_EDZ#lagrpassw[m.lnI,4]
							REPLACE ID_EDZ WITH lagrpassw[m.lnI,4]
						ENDIF
						lbfou=.t.
						*
						EXIT
					ENDIF
				ENDSCAN
				*
				IF !m.lbfou
				*создать новый документ
				    WAIT WINDOW "Идет создание гр.паспорта №"+lagrpassw[m.lnI,2]+" от "+DTOC(lagrpassw[m.lnI,1])+CHR(13)+lagrpassw[m.lnI,5] NOWAIT
				    *
					LOCAL laARSORTID[1] as Integer
					LOCAL lnnewSORTID as Integer
					*
					SELECT MAX(SORTID) FROM GRPASSW INTO ARRAY laARSORTID WHERE BINTOC(PID)=BINTOC(0)
					lnnewSORTID=NVL(laARSORTID[1],0)+1
					*
					INSERT INTO GRPASSW (ISFOLDER, PID, SORTID, DATE, NOMER, ID_PRO, ID_EDZ) VALUES (2, 0, m.lnnewSORTID, lagrpassw[m.lnI,1], PADL(lagrpassw[m.lnI,2],10), lagrpassw[m.lnI,3], lagrpassw[m.lnI,4])
				ENDIF
				*изменить документ
				*1.удаляем прежний состав
				DELETE FROM GRPASS_CONT WHERE ID_GRPAS=GRPASSW.ID
				*2.создаем новый состав
				FOR lnJ=1 TO ALEN(lagrpassw_cont,1)
					IF lagrpassw_cont[m.lnJ,1]=m.lnI
						INSERT INTO GRPASS_CONT (ID_GRPAS,ID_PAS) VALUES (GRPASSW.ID,lagrpassw_cont[m.lnJ,2])
					ENDIF
				ENDFOR
				*
			    WAIT WINDOW "Идет перерасчет гр.паспорта №"+GRPASSW.NOMER+" от "+DTOC(GRPASSW.DATE)+CHR(13)+lagrpassw[m.lnI,5] NOWAIT
				DO (goApp.cAppCurPaths+m.lcprocname) WITH GRPASSW.ID, m.losoftgrpasswobj, "CALC"
			ENDFOR
			*
			RELEASE losoftgrpasswobj
			RELEASE losoftprodobj
		ENDIF
	ENDIF
	*
	WAIT CLEAR
	CLOSE DATABASES ALL
RETURN

*!*	FUNCTION rstr
*!*	LPARAMETERS tnnum as Number
*!*	LOCAL lcNewStr as String
*!*		lcNewStr=ALLTRIM(STR(m.tnnum,24,12))
*!*		DO WHILE RIGHT(m.lcNewStr,1)=='0'
*!*			lcNewStr=LEFT(m.lcNewStr,LEN(m.lcNewStr)-1)
*!*			IF RIGHT(m.lcNewStr,1)=='.'
*!*				lcNewStr=LEFT(m.lcNewStr,LEN(m.lcNewStr)-1)
*!*				EXIT
*!*			ENDIF
*!*		ENDDO
*!*	RETURN m.lcNewStr
*!*	FUNCTION getparamfromstring
*!*	PARAMETERS tstring as String, tfieldname as String
*!*	LOCAL lnposbeg as Integer, lnposend as Integer
*!*		lnpos=ATC(m.tfieldname,m.tstring)+LENC(m.tfieldname)+1
*!*		lnposend=ATC(';',SUBSTRC(m.tstring,m.lnpos))-1
*!*	RETURN ALLTRIM(SUBSTRC(m.tstring,m.lnpos,m.lnposend))