	SET ESCAPE ON
	CLEAR ALL
	SET PATH TO d:\work\upldrepl_winnew;d:\work\upldrepl_winnew\lib;d:\work\common;d:\work\lib;d:\work\lib.9;d:\work\lib.old;d:\work\magistr_common;d:\work\skl450n\prg
	SET CLASSLIB TO .\lib\mtoolbar, .\lib\selectvalues, .\lib\PolCld
	SET CLASSLIB TO select_values, base_gui, base_app, xml_ini, sfmenu, sfmenu_app ADDITIVE 
	SET PROCEDURE TO MAIN ADDITIVE
	SET MESSAGE TO
	SET BELL OFF
	CLEAR MACROS
	SET SYSMENU OFF

	PUBLIC chdate,date1,date2,chor,organ,chtyp,typedoc,chtov,tovar
	PUBLIC typs, typpro, basep, mas, masto, mased, masor, date1, date2, prin_prev, maspro
	PUBLIC 	glpereschet
	glpereschet = .f.

	DIMENSION mas(1), masto(1), mased(1), masor(1), maspro[1]
	STORE 0 TO mas(1), masto(1), mased(1), masor(1)
	STORE {  .  .    } TO date1,date2
	STORE '' TO maspro[1]
	prin_prev = 0
	basep = '.\dbf\'

	_SCREEN.ICON = 'moloko.ico'
	_SCREEN.CAPTION = 'Учет молока'
	_SCREEN.WINDOWSTATE = 2
	_SCREEN.BACKCOLOR = RGB(132,130,132)
	*_SCREEN.BackColor = RGB(255,255,255)
	_SCREEN.PICTURE = 'desktop.jpg'
	_SCREEN.SHOWTIPS = .T.

	**setBase()
	setEnvir()
	PRIVATE TOOLB
	TOOLB = CREATEOBJECT('mtoolbar')

	PUBLIC goApp

	goApp=CREATEOBJECT("custom")
	m.goApp.AddObject("oWinApi", "cstwinapi")
	m.goApp.AddObject("oFunction", "cstfunction")
	m.goApp.AddObject("oVars", "cstvars")
	m.goApp.oVars.cAppExeName = SYS(16, 0)
	*проверить - запущена ли еще одна копия?
	IF m.goApp.oWinApi.findWindow(_SCREEN.Caption) = 0
		SET ENGINEBEHAVIOR 80

		DO MAIN.mpr
		*застолбим тулбар
		TOOLB.MOVE(0,-1)
		TOOLB.SHOW()

		ACTIVATE MENU _MSYSMENU

		READ EVENTS
	ENDIF

	isexit()
CANCEL

PROCEDURE isexit
	CloseAllWindows()
	CLEAR ALL
	SET MESSAGE TO
	SET BELL ON
	POP KEY ALL
	RESTORE MACROS
	SET CLASSLIB TO
	
	SET SYSMENU TO DEFAULT
	
	IF _VFP.StartMode = 0
		CANCEL
	ELSE
		QUIT
	ENDIF

PROCEDURE setEnvir
	SET CENT ON
	SET DATE DMY
	SET EXCL OFF
	SET EXAC OFF
	SET TALK OFF
	SET SAFE OFF
	SET DELETE ON
	SET NEAR ON
	SET POINT TO '.'
	SET DECIMAL TO 6

PROCEDURE CloseAllWindows
LOCAL lnFmIdx
	FOR lnFmIdx = _SCREEN.FORMCOUNT TO 1 STEP -1
		TRY
			IF _SCREEN.FORMS(lnFmIdx).BASECLASS = "Form"
				_SCREEN.FORMS(lnFmIdx).RELEASE
			ENDIF
		CATCH
		ENDTRY
	ENDFOR

PROCEDURE setBase
	OPENTABLE(basep + 'tovar.dbf','to')
	OPENTABLE(basep + 'organ.dbf','or')
	OPENTABLE(basep + 'ostat.dbf','ost')
	OPENTABLE(basep + 'typedoc.dbf','typ')
	OPENTABLE(basep + 'nakl.dbf','nak')
	OPENTABLE(basep + 'nakl_cont.dbf','nakc')
	OPENTABLE(basep + 'production.dbf','pro')
	OPENTABLE(basep + 'passw.dbf','pas')
	OPENTABLE(basep + 'grppassw.dbf','grpas')
	OPENTABLE(basep + 'grpass_cont.dbf','grpasc')
	OPENTABLE(basep + 'koef.dbf','sp')
	OPENTABLE(basep + 'edizm.dbf','edizm')
	OPENTABLE(basep + 'sezon.dbf','sez')
	OPENTABLE(basep + 'filt.dbf','flt')
	date1 = flt.date1
	date2 = flt.date2
RETURN

PROCEDURE OPENTABLE
PARAMETERS tabls,ali, agains, excls
	SELECT 0

	IF m.excls
		IF m.agains
			USE (tabls) ALIAS (ali) EXCLUSIVE AGAIN
		ELSE
			USE (tabls) ALIAS (ali) EXCLUSIVE
		ENDIF
	ELSE
		IF m.agains
			USE (tabls) ALIAS (ali) AGAIN
		ELSE
			USE (tabls) ALIAS (ali)
		ENDIF
	ENDIF
	
	IF TAGCOUNT()>0
		SET ORDER TO 1
	ENDIF

PROCEDURE closeBase
PRIVATE maxals,i
	maxals = SELECT(1)
	FOR i = maxals TO 1 STEP -1
		IF !EMPTY(ALIAS(i))
			USE IN ALIAS(i)
		ENDIF
	ENDFOR
RETURN

PROCEDURE creIndx
	WAIT WINDOWS 'Построение индексных файлов' NOWAI
	CloseAllWindows()
	CLOSE DATA
	SET EXCLUSIVE ON
	DELE FILE .\DBF\*.CDX
	setBase()
	
	SELECT TO
	DELETE TAG ALL
	INDEX ON ID TAG ID
	INDEX ON NAME TAG NAME
	
	SELECT OR
	DELETE TAG ALL
	INDEX ON ID TAG ID
	INDEX ON NAME TAG NAME
	
	SELECT typ
	DELETE TAG ALL
	INDEX ON ID TAG ID
	INDEX ON NAME TAG NAME
	
	SELECT nak
	DELETE TAG ALL
	INDEX ON ID TAG ID
	INDEX ON DATE TAG DATE
	INDEX ON BINTOC(id_pas) + typedoc TAG id_pas
	INDEX ON LEFT(typedoc,2) + nomer TAG typnomer
	INDEX ON LEFT(typedoc,2) + DTOS(DATE) TAG typdate
	INDEX ON LEFT(typedoc,2) + BINTOC(id_organ) TAG typorgan
	INDEX ON typedoc + DTOS(DATE) TAG typedoc
	INDEX ON id_parnak TAG id_parnak
	
	SELECT nakc
	DELETE TAG ALL
	INDEX ON id_nak TAG id_nak
	INDEX ON BINTOC(id_nak) + BINTOC(id_tovar) + BINTOC(id_tara) TAG it
	
	SELECT ost
	DELETE TAG ALL
	INDEX ON DTOS(DATE) + BINTOC(id_tovar) + BINTOC(id_tara) TAG datetovar
	
	SELECT pro
	DELETE TAG ALL
	INDEX ON ID TAG ID
	
	SELECT grpas
	DELETE TAG ALL
	INDEX ON ID TAG ID
	INDEX ON nomer TAG nomer
	INDEX ON DTOS(DATE) TAG DATE
	INDEX ON DTOS(DATE) + nomer TAG datenom
	INDEX ON id_pro + STR(YEAR(DATE)*12 + MONTH(DATE),6) + nomer TAG nomdate
	
	SELECT grpasc
	DELETE TAG ALL
	INDEX ON id_grpas TAG id_grpas
	INDEX ON id_pas TAG id_pas
	
	SELECT pas
	DELETE TAG ALL
	INDEX ON ID TAG ID
	INDEX ON nomer TAG nomer
	INDEX ON id_pro + nomer TAG pronomer
	INDEX ON id_pro + DTOS(DATE) TAG prodate
	INDEX ON DTOS(DATE) TAG DATE
	
	SELECT edizm
	DELETE TAG ALL
	INDEX ON ID TAG ID
	INDEX ON NAME TAG NAME
	
	SELECT sp
	DELETE TAG ALL
	INDEX ON id_pro TAG id_pro
	
	SELECT sez
	DELETE TAG ALL
	INDEX ON id_ed TAG id_ed
	
	CLOSE DATA
	SET EXCLU OFF
*	setBase()
RETURN

PROCEDURE celost
RETURN
	*проверка корректности записей
	setEnvir()
	creIndx()
	
	WAIT WINDOWS 'Идет проверка целостности файлов базы данных...' NOWAI
	setBase()
	*спрaвочник товаров
	SELECT 0
	USE basep + 'tovar.dbf' AGAIN ORDER 1 ALIAS to1
	SELECT TO
	IF !SEEK(0)
		INSERT INTO TO (ID,NAME) VALUE(0,'Пустой')
	ENDIF
	SET RELATION TO ID INTO to1
	SCAN ALL
		IF RECNO('to')#RECNO('to1')
			DELETE
		ENDIF
		IF !DELETED()
			REPL NAME WITH LTRIM(NAME)
		ENDIF
	ENDSCAN
	SET RELATION TO
	USE IN to1
	
	*спрaвочник контрагентов
	SELECT 0
	USE basep + 'organ.dbf' AGAIN ORDER 1 ALIAS or1

	SELECT OR

	IF !SEEK(0)
		INSERT INTO OR (ID,NAME) VALUE(0,'Пустой')
	ENDIF

	SET RELATION TO ID INTO or1

	SCAN ALL
		IF RECNO('or')#RECNO('or1')
			DELETE
		ENDIF
		IF !DELETED()
			REPL NAME WITH LTRIM(NAME)
		ENDIF
	ENDSCAN

	SET RELATION TO
	USE IN or1
	
	SELECT 0
	USE basep + 'nakl.dbf' AGAIN ORDER 1 ALIAS nak1
	*упорядочивание номеров накладных
	SELECT nak
	SET RELATION TO ID INTO nak1, id_pas INTO pas ADDI
	SCAN ALL
		IF id_organ = 0
			REPL id_organ WITH 0
		ENDIF
		IF RECNO('nak')#RECNO('nak1') OR (id_pas#0 AND EOF('pas')) OR ID = 0
			DELETE
		ENDIF
		IF !DELETED()
			REPL nomer WITH STR(VAL(nomer),10)
		ENDIF
	ENDSCAN
	SET RELATION TO
	USE IN nak1
	*содержимое накладных
	SELECT nakc
	SET RELATION TO id_nak INTO nak, id_tovar INTO TO ADDI
	SET RELATION TO id_tara INTO edizm ADDI
	SCAN ALL
		IF id_tovar = 0
			REPL id_tovar WITH 0
		ENDIF
		IF id_tara = 0
			REPL id_tara WITH 0
		ENDIF
		IF EOF('nak')
			DELETE
		ENDIF
		IF !DELETED() AND EOF('to')
			REPL id_tovar WITH 0
		ENDIF
		IF !DELETED() AND EOF('edizm')
			REPL id_tara WITH 0
		ENDIF
	ENDSCAN
	SET RELATION TO
	*паспорта
	SELECT 0
	USE basep + 'passw.dbf' AGAIN ORDER 1 ALIAS pas1
	SELECT pas
	SET RELATION TO ID INTO pas1
	SCAN ALL
		IF id_organ = 0
			REPL id_organ WITH 0
		ENDIF
		IF id_tara = 0
			REPL id_tara WITH 0
		ENDIF
		IF RECNO('pas')#RECNO('pas1')
			DELETE
		ENDIF
		IF !DELETED() AND ID = 0
			DELETE
		ENDIF
		IF !DELETED()
			REPL nomer WITH STR(VAL(nomer),10)
		ENDIF
	ENDSCAN
	SET RELATION TO
	USE IN pas1
	*группир.паспорта
	SELECT 0
	USE basep + 'grppassw.dbf' AGAIN ORDER 1 ALIAS grpas1
	SELECT grpas
	SET RELATION TO ID INTO grpas1
	SCAN ALL
		IF id_tara = 0
			REPL id_tara WITH 0
		ENDIF
		IF RECNO('grpas')#RECNO('grpas1')
			DELETE
		ENDIF
		IF !DELETED() AND ID = 0
			DELETE
		ENDIF
		IF !DELETED()
			REPL nomer WITH STR(VAL(nomer),10)
		ENDIF
	ENDSCAN
	SET RELATION TO
	USE IN grpas1
	*содержимое группир.паспортов
	SELECT grpasc
	SET RELATION TO id_grpas INTO grpas, id_pas INTO pas ADDI
	SCAN ALL
		IF EOF('grpas') OR EOF('pas')
			DELETE
		ENDIF
	ENDSCAN
	SET RELATION TO
	*остатки
	SELECT 0
	USE basep + 'ostat.dbf' AGAIN ORDER 1 ALIAS ost1
	SELECT ost
	SET RELATION TO DTOS(DATE) + BINTOC(id_tovar) + BINTOC(id_tara) INTO ost1
	SCAN ALL
		IF id_tara = 0
			REPL id_tara WITH 0
		ENDIF
		IF RECNO('ost')#RECNO('ost1')
			DELETE
		ENDIF
	ENDSCAN
	SET RELATION TO
	USE IN ost1
	
	CLOSE DATA
	WAIT WINDOWS 'Проверка целостности файлов базы данных окончена!' NOWAI
RETURN

PROCEDURE upack
	WAIT WINDOWS 'Упаковка файлов' NOWAI
	CloseAllWindows()
	
	CLOSE DATA
	SET EXCLU ON
	DELE FILE .\DBF\*.CDX
	setBase()
	
	SELECT TO
	PACK
	
	SELECT OR
	PACK
	
	SELECT nak
	PACK
	
	SELECT nakc
	PACK
	
	SELECT ost
	PACK
	
	SELECT typ
	PACK
	
	SELECT pas
	PACK
	
	SELECT grpas
	PACK
	
	SELECT grpasc
	PACK
	
	SELECT sez
	PACK
	
	CLOSE DATA
	SET EXCLU OFF
	creIndx()
	WAIT WINDOWS 'Упаковка файлов завершена!' NOWAI
RETURN

PROCEDURE rashet_pas1
*расчет паспорта(сух.молоко)
PARAMETERS mid
PRIVATE koljirm,kolsuhm,suhm,kolob,jirob,suhob,plotnob,kolgot,kfgot,;
	kolsm,deltsm,koljirsm,deltjirsm,suhsm,kolsuhsm,nrsm,m.kolsuhpaht,;
	kol,koljir,ID, idtar, otag,orec,osel
	osel = SELECT()

	SELECT pas
	otag = SYS(21)
	orec = IIF(EOF(),0,RECNO())
	SET ORDER TO ID

	IF SEEK(m.mid) AND .NOT.EMPTY(id_pro)
	*сезонные коэффициенты
		SELECT SEZ
		fou = .F.

		IF SEEK(PAS.ID_TARA)
			SCAN WHILE ID_ED = PAS.ID_TARA
				IF PAS.DATE >= BMONTH AND PAS.DATE <= EMONTH
					fou = .T.
					EXIT
				ENDIF
			ENDSCAN
		ENDIF

		IF m.fou
			SELECT PAS
			*производство
			*лаб.анализы
			REPLACE LABAN WITH 0.2
			*кол жира в молоке
			jirInm = ROUND(div(pas.koljirinm*100,pas.kolinm),5)
			*%сухих в-в в молоке(СМОм)
			s11 = div((sp.koef1*m.jirInm + pas.plotnInm),sp.koef2) + pas.ksmom
			*%сухого обезжир молока(СОМОм)
			suhm = s11-m.jirInm
			*кол-во сухого обезжир молока(СОМОкг-м)
			kolsuhm = pas.kolinm*m.suhm/100
			*%сухой обезжир пахты(СОМОп)
			s21 = pas.suhpaht-div(pas.koljirpaht*100,pas.kolpaht) &&0.7
			*кол-во сухой обезжир пахты(СОМОкг-п)
			kolsuhpaht = ROUND(pas.kolpaht*m.s21/100,2)
			*%сухого обезжир молоко + пахта(СОМОмп)
			s31 = div((m.kolsuhm + m.kolsuhpaht)*100,(pas.kolinm + pas.kolpaht))
			*жир суммарный пошедший на переработку
			s4 = div((pas.koljirinm + pas.koljirpaht)*100,(pas.kolinm + pas.kolpaht))

			IF pas.obrat
				*%сухих в-в в обрате(СМОо)
				IF pas.DATE >= {^2003-06-01}
					s51 = ROUND(pas.plotnob/4 + .05 + pas.ksmoo,2)
				ELSE
					s51 = ROUND(pas.plotnob/4 + .05 + .59,2) &&
				ENDIF
				*%сухого обезжир обрата(СОМОо)
				suhob = m.s51 - .05
			ELSE
				*%сухого обезжир обрата(СОМОо)
				suhob = div(m.suhm*100,(100-m.jirInm))
				*%сухих в-в в обрате(СМОо)
				s51 = m.suhob + 0.05
				*плотность обрата
				plotnob = ROUND(m.s51*sp.koef6-sp.koef7,1)
			ENDIF
			*коэфф.учит.потери жира и СМО
			opr = 25.5 / 70.9
			kpot = div(1,(1 + m.opr)*div(1-0.01*sez.nrjir,1-0.01*sez.koef5)-m.opr)
			*масса компонентов для нормализации
			onorm = m.opr*m.kpot
			kolob = IIF(pas.inpobrat, pas.kolob, ROUND(div(m.s4-m.s31*m.onorm,m.suhob*m.onorm-0.05)*(pas.kolinm + pas.kolpaht),0))
			*жир обрата
			IF !pas.inpobrat
				jirob = ROUND(m.kolob*0.05/100,2)
			ELSE
				jirob = PAS.JIROB
			ENDIF
			*кол сух обезжир в-в в обрате(СОМОкг-о)
			kolsuhob = m.kolob*m.suhob/100
			**кол-во смеси
			kolsm = pas.kolinm + pas.kolpaht + m.kolob
			*жир смеси
			koljirsm = pas.koljirinm + pas.koljirpaht + m.jirob
			*%жир смеси
			rsjirsm = div(m.koljirsm*100,m.kolsm)
			*кол-во сухой обезжир смеси(СОМОкг-см)
			kolsuhsm = m.kolsuhm + m.kolsuhpaht + m.kolsuhob
			*%сух в-в в смеси(СОМсм)
			suhsm = div(m.kolsuhsm*100,m.kolsm)
			sm = div((m.koljirsm + m.kolsuhsm)*100,m.kolsm)
			*норма расхода смеси
			*расход нормы жира
*!*				IF pas.date<{^2005-04-01} OR pas.date> = {^2005-05-01}
*!*					nrsm = div(96.4*1000,m.sm*(1-0.01*sez.koef5))
*!*				ELSE
*!*					nrsm = div(96.8*1000,m.sm*(1-0.01*sez.koef5))
*!*				ENDIF
			nrsm = div(pas.kvlaga*1000,m.sm*(1-0.01*sez.koef5))

*!*				m.nrjirsm = 255 + 255*sez.nrjir/100
			nrjirsm = pas.kjir + pas.kjir*sez.nrjir/100
			*выход готовой продукц
			IF pas.kolgt
				kolgot = pas.kolgot
			ELSE
				kolgot = ROUND(ROUND(div(div(m.koljirsm*1000,m.nrjirsm),edizm.ves),0)*edizm.ves + pas.laban,1)
			ENDIF

			kfgot = ROUND(m.kolgot/1000,3)
			*фактич расход смеси
			kolsm = ROUND(div(m.kolsm,m.kolgot)*1000,3)
			*экономия/перерасход смеси
			deltsm = (m.kolsm-m.nrsm)*m.kfgot
			*фактич расход жира смеси
			koljirsm = ROUND(div(m.koljirsm,m.kolgot)*1000,3)
			*экономия/перерасход жира смеси
			deltjirsm = (m.koljirsm-m.nrjirsm)*m.kfgot
			*сохраняем изменения
			GATHER MEMV
			*добавить накладные
			SELECT nakc
			SET ORDER TO it
			SELECT nak
			SET ORDER TO id_pas
			
			SELECT pro

			SCAN FOR ID = RTRIM(pas.id_pro)
				IF id_tovar = 0
					LOOP
				ENDIF
				*накладная
				SELECT nak
				IF SEEK(BINTOC(pas.ID) + pro.typedoc, "NAK", "id_pas")
					id = ID
					REPLACE DATE WITH pas.DATE, id_organ WITH pas.id_organ IN NAK
				ELSE
					id = newid('nak')
					nomer = newnmnak(LEFT(pro.typedoc,2))

					INSERT INTO nak (ID,nomer,DATE,typedoc,id_pas, id_organ);
						VALU(m.id,m.nomer,pas.DATE,pro.typedoc,pas.ID, pas.id_organ)
				ENDIF
				*содержимое накладной
				m.idtar = 0
				DO CASE
				CASE pro.id_tovar = 1
				*молоко
					kol = pas.kolinm
					koljir = pas.koljirinm
					kolsuh = 0
				CASE pro.id_tovar = 3
				*пахта
					kol = pas.kolpaht
					koljir = pas.koljirpaht
					kolsuh = 0
				CASE pro.id_tovar = 2
				*обрат
					kol = pas.kolob
					koljir = pas.jirob
					kolsuh = 0
				CASE pro.id_tovar = 5
				*молоко сухое
					m.idtar = pas.id_tara
					kol = pas.kolgot
					koljir = 0
					kolsuh = 0
				ENDCASE
				
				SELECT nakc

				IF SEEK(BINTOC(m.id) + BINTOC(pro.id_tovar) + BINTOC(m.idtar), "NAKC", "IT")
					IF m.kol#0 OR m.koljir#0
						 = chnakl(2, m.id, pro.id_tovar, m.idtar, pas.id_organ, m.kol, m.koljir, m.kolsuh)
					ELSE
						 = chnakl(1, m.id, pro.id_tovar, m.idtar, pas.id_organ)
					ENDIF
				ELSE
					IF m.kol#0 OR m.koljir#0
						 = chnakl(0, m.id, pro.id_tovar, m.idtar, pas.id_organ, m.kol, m.koljir, m.kolsuh)
					ENDIF
				ENDIF
			ENDSCAN
		ENDIF
		
		SELECT pas
	ELSE
		MESSAGEB('Нет типа документа!',54,'Внимание')
	ENDIF

	IF m.orec#0
		GO m.orec
	ENDIF

	SET ORDER TO &otag

	SELECT (m.osel)
RETURN

PROCEDURE rashet_grpas1
*расчет группир-го паспорта(молоко)
PARAMETERS nom, tpro
PRIVATE koljirsm,kolsm,jirsm,kolsuhsm,suhsm,nrsm,kolgot,;
	deltsm,deltjirsm,kolm,koljirm,kolsuhm,kolpaht,;
	koljirpaht,kolsuhpaht,kolob,koljirob,kolsuhob,kolgots;
	otag,orec,orec1,osel &&,rela1,targ1,rela2,targ2
	osel = SELECT()
	
	SELECT grpasc
	orec1 = IIF(EOF(),0,RECNO())
	SELECT grpas
	otag = SYS(21)
	orec = IIF(EOF(),0,RECNO())
	SET ORDER TO nomer

	IF nomer#m.nom AND !SEEK(m.nom)
		IF orec#0
			GO orec
		ENDIF
		SET ORDER TO &otag
		RETURN
	ENDIF

	m.nom = ID
	fou = .F.
	*сезонные коэффициенты
	SELECT sez

	IF SEEK(grpas.id_tara)
		SCAN WHILE id_ed = grpas.id_tara
			IF grpas.DATE >= bmonth AND grpas.DATE <= emonth
				fou = .T.
				EXIT
			ENDIF
		ENDSCAN
	ENDIF
	
	IF m.fou
		SELECT grpas
		
		SET ENGINEBEHAVIOR 70

		SELECT SUM(kolinm) AS kolm,SUM(koljirinm) AS koljirm,SUM(kolsuhm) AS kolsuhm,;
			SUM(kolpaht) AS kolpaht,SUM(koljirpaht) AS koljirpaht,SUM(kolsuhpaht) AS kolsuhpaht,;
			SUM(kolob) AS kolob,SUM(jirob) AS koljirob,SUM(kolsuhob) AS kolsuhob,;
			SUM(kolgot) AS kolgot,SUM(laban) AS laban, SUM(kolinm*plotnInm)/SUM(kolinm) AS plotnsv,;
			(4.9*SUM(koljirinm)*100/SUM(kolinm) + ROUND(SUM(plotnInm)/SUM(1), 2))/4 + ksmom AS rsmom,;
			SUM(kolob*plotnob)/SUM(kolob) AS plotnob,;
			SUM(div(kvlaga*1000,div((koljirinm + koljirpaht + jirob + kolsuhm + kolsuhpaht + kolsuhob)*100,;
								kolinm + kolpaht + kolob)*(1-0.01*sez.koef5)))/SUM(1) as nrsm,;
			SUM(kjir + kjir*sez.nrjir/100)/SUM(1) as nrjirsm;
		FROM pas INTO CURSOR vrems;
		WHERE ID IN (SELECT id_pas FROM grpasc WHERE id_grpas  =  m.nom)

		SET ENGINEBEHAVIOR 90
		
*!*				(4.9*SUM(koljirinm)*100/SUM(kolinm) + ROUND(SUM(kolinm)*SUM(kolinm*plotnInm)/SUM(kolinm)/SUM(kolinm),2))/4 + ksmom AS rsmom,
		SCATTER MEMV
		USE

		nrjirsm = m.nrjirsm
		koljirsm = m.koljirm + m.koljirpaht + m.koljirob
		kolsm = m.kolm + m.kolpaht + m.kolob
		jirsm = ROUND(div(m.koljirsm*100,m.kolsm),5)
		kolsuhsm = m.kolsuhm + m.kolsuhpaht + m.kolsuhob
		suhsm = ROUND(div(m.kolsuhsm*100,m.kolsm),5)
		
*!*		*норма расхода смеси
*!*			m.sm = div((m.koljirsm + m.kolsuhsm)*100,m.kolsm)
*!*		*расход нормы жира
*!*			IF grpas.date<{^2005-04-01} OR grpas.date> = {^2005-05-01}
*!*				m.nrsm = div(96.4*1000,m.sm*(1-0.01*sez.koef5))
*!*			ELSE
*!*				m.nrsm = div(96.8*1000,m.sm*(1-0.01*sez.koef5))
*!*			ENDIF
*!*			
*!*			m.nrjirsm = 255 + 255*sez.nrjir/100
		*расчет нормы расхода смеси
		kfgot = ROUND(m.kolgot/1000,3)
		*фактич расход смеси
		kolsm = ROUND(div(m.kolsm,m.kolgot)*1000,3)
		*экономия/перерасход смеси
		deltsm = (m.kolsm-m.nrsm)*m.kfgot
		*фактич расход жира смеси
		koljirsm = ROUND(div(m.koljirsm,m.kolgot)*1000,3)
		*экономия/перерасход жира смеси
		deltjirsm = (m.koljirsm-m.nrjirsm)*m.kfgot
		
		SELECT grpas
		GATHER MEMV
	ELSE
		SELECT grpas
	ENDIF
	
	IF orec#0
		GO orec
	ENDIF
	SET ORDER TO &otag
	
	SELECT grpasc

	IF orec1#0
		GO orec1
	ENDIF
	
	SELECT (osel)
RETURN

PROCEDURE rashet_pas2
*расчет паспорта(сепар)
PARAMETERS mid
PRIVATE kolinm,jirInm,koljirinm,kolpaht,koljirpaht,kolob,jirob,suhob,plotnob,;
	kolsm,suhsm,koljirsm,kolsuhsm,nrsm,m.kolsuhpaht,;
	kol,koljir,ID,nrsmf,delt,kolgot, idtar,;
	otag,orec,osel
	osel = SELECT()

	SELECT pas
	otag = SYS(21)
	orec = IIF(EOF(),0,RECNO())
	SET ORDER TO ID

	IF SEEK(m.mid) AND !EMPTY(id_pro)
		SCATTER MEMV
		*производство
		*кол жира в молоке
		*учесть пахту
		m.jirInm = ROUND(div((m.koljirinm)*100,m.kolinm),2)
	
		m.kolsm = ROUND((m.kolinm)*sp.koef1/100,0)
		m.koljirsm = ROUND((m.koljirinm)*sp.koef1/100,2)
	*териотич кол-во обрата
		m.kolob = kolinm-m.kolsm-pas.kolpaht
		m.jirob = ROUND(m.kolob*0.0005,2)
	
		delt = (m.jirob + m.koljirpaht + m.koljirsm)-m.koljirinm
	
		m.koljirinm = m.koljirinm + m.delt
		m.kolinm = ROUND(div(m.koljirinm*100,m.jirInm),0)
	
		m.kolsm = ROUND(m.kolinm*sp.koef1/100,0)
		m.koljirsm = ROUND(m.koljirinm*sp.koef1/100,2)
	*факт кол-во обрата
		m.kolob = kolinm-m.kolsm-pas.kolpaht
		m.jirob = ROUND(m.kolob*0.0005,2)
	*пересчит жир молока
		m.koljirinm = ROUND(m.jirob + m.koljirpaht + m.koljirsm,2)
		m.kolinm = ROUND(m.koljirinm*100/m.jirInm,0) &&m.kolob + m.kolpaht + m.kolsm
	
		m.kolsm = ROUND(m.kolinm*sp.koef1/100,0)
		m.koljirsm = ROUND(m.koljirinm*sp.koef1/100,2)
	*факт кол-во обрата
		m.kolob = m.kolinm-m.kolsm-pas.kolpaht
		m.jirob = ROUND(m.kolob*0.0005,2)
	
		m.koljirinm = ROUND(m.jirob + m.koljirpaht + m.koljirsm,2)
	
		m.kolob = ROUND(m.kolob,0)
		m.kolgot = m.kolob
	*сохраняем изменения
		GATHER MEMV
	*добавить накладные
		SELECT nakc
		SET ORDER TO it
		SELECT nak
		SET ORDER TO id_pas
	
		SELECT pro
		SCAN FOR ID = RTRIM(pas.id_pro)
			IF id_tovar = 0
				LOOP
			ENDIF
	*накладная
			SELECT nak
			IF SEEK(BINTOC(pas.ID) + pro.typedoc, "NAK", "id_pas")
				m.id = ID
				REPLACE DATE WITH pas.DATE IN NAK
				IF nak.id_organ<>2 && если расход на контрагента "Хозяйства", то не исправляем (23.01.07 Andrey)
					REPLACE id_organ WITH pas.id_organ
				ENDIF
			ELSE
				m.id = newid('nak')
				m.nomer = newnmnak(LEFT(pro.typedoc,2))

				INSERT INTO nak (ID,nomer,DATE,typedoc,id_pas, id_organ);
					VALU(m.id,m.nomer,pas.DATE,pro.typedoc,pas.ID, pas.id_organ)
			ENDIF
	*содержимое накладной
			m.idtar = 0
			DO CASE
			CASE pro.id_tovar = 1
	*молоко
				kol = pas.kolinm
				koljir = pas.koljirinm
				kolsuh = 0
			CASE pro.id_tovar = 2
	*обрат
				kol = pas.kolob
				koljir = pas.jirob
				kolsuh = 0
			CASE pro.id_tovar = 4
	*сливки
				kol = pas.kolpaht
				koljir = pas.koljirpaht
				kolsuh = 0
			CASE pro.id_tovar = 3
	*пахта
				kol = 0
				koljir = 0
				kolsuh = 0
			ENDCASE

			SELECT nakc
			IF SEEK(BINTOC(m.id) + BINTOC(pro.id_tovar) + BINTOC(m.idtar), "NAKC", "IT")
				IF m.kol#0 OR m.koljir#0
					 = chnakl(2, m.id, pro.id_tovar, m.idtar, pas.id_organ, m.kol, m.koljir, m.kolsuh)
				ELSE
					 = chnakl(1, m.id, pro.id_tovar, m.idtar, pas.id_organ)
				ENDIF
			ELSE
				IF m.kol#0 OR m.koljir#0
					 = chnakl(0, m.id, pro.id_tovar, m.idtar, pas.id_organ, m.kol, m.koljir, m.kolsuh)
				ENDIF
			ENDIF
		ENDSCAN
	
		SELECT pas
	ELSE
		MESSAGEB('Нет типа документа!',54,'Внимание')
	ENDIF
	IF orec#0
		GO orec
	ENDIF
	
	SET ORDER TO &otag
	SELECT (osel)
RETURN

PROCEDURE rashet_grpas2
*расчет гр.паспорта(сепар)
PARAMETERS nom

PROCEDURE rashet_pas3
*расчет паспорта(обрат)
PARAMETERS mid
PRIVATE kolob,jirob,suhob,plotnob,kolgot,kfgot,;
	kolsm,suhsm,koljirsm,kolsuhsm,nrsm,m.kolsuhpaht,;
	kol,koljir,ID,nrsmf, idtar,;
	otag,orec,osel
	osel = SELECT()

	SELECT pas
	otag = SYS(21)
	orec = IIF(EOF(),0,RECNO())
	SET ORDER TO ID

	IF SEEK(m.mid) AND !EMPTY(id_pro)
	*производство
		*лабанализы
		REPL laban WITH 0.2
		kolob = pas.kolob
		plotnob = pas.plotnob
		*расчетный жир обрата
		jirob = pas.jirob &&ROUND(m.kolob*0.05/100,2)
		*%сух в-в в обрате
		suhob = ROUND(m.plotnob / 4 + pas.ksmoo, 3)
		*кол сух в-в в обрате
		kolsuhob = ROUND(m.kolob*m.suhob/100,3)
		*кол сух в-в в пахте
		kolsuhpaht = ROUND(pas.kolpaht*pas.suhpaht/100,3)
		*кол-во смеси
		kolsm = m.kolob + pas.kolpaht
		*жирокг смеси
		koljirsm = m.jirob + pas.koljirpaht
		*%жира смеси
		rsjirsm = div(m.koljirsm * 100, m.kolsm)  
		*кол сух в-в в смеси
		kolsuhsm = m.kolsuhob + m.kolsuhpaht
		*%сух в-в в смеси
		suhsm = div(m.kolsuhsm * 100, m.kolsm)
		sm = div((m.koljirsm + m.kolsuhsm) * 100, m.kolsm)
		*норма расхода смеси
		nrsm = ROUND(div(pas.kvlaga * 1000, m.sm * (1 - 0.01 * sp.koef2)), 3)
		*выход готовой продукц
		IF pas.kolgt
			kolgot = pas.kolgot
		ELSE
			kolgot = ROUND(div(div(m.kolsm*1000,m.nrsm),edizm.ves),0)*edizm.ves + pas.laban
		ENDIF

		kfgot = ROUND(m.kolgot / 1000, 3)
		*фактич.норма расхода смеси
		kolsm = ROUND(div(m.kolsm, m.kfgot), 3)
		deltsm = (m.kolsm - m.nrsm) * m.kolgot / 1000
		*сохраняем изменения
		GATHER MEMV
		*добавить накладные
		SELECT nakc
		SET ORDER TO it

		SELECT nak
		SET ORDER TO id_pas
	
		SELECT pro

		SCAN FOR ID = RTRIM(pas.id_pro)
			IF id_tovar = 0
				LOOP
			ENDIF
			*накладная
			SELECT nak

			IF SEEK(BINTOC(pas.ID) + pro.typedoc, "NAK", "id_pas")
				id = ID
				REPLACE DATE WITH pas.DATE, id_organ WITH pas.id_organ IN NAK
			ELSE
				id = newid('nak')
				nomer = newnmnak(LEFT(pro.typedoc,2))

				INSERT INTO nak (ID,nomer,DATE,typedoc,id_pas, id_organ);
					VALU(m.id,m.nomer,pas.DATE,pro.typedoc,pas.ID, pas.id_organ)
			ENDIF
			*содержимое накладной
			idtar = 0

			DO CASE
			CASE pro.id_tovar = 2 AND pro.typedoc = '0203'
			*обрат
				kol = ROUND(pas.kolob*0.0052,0)
				koljir = ROUND(m.kol*0.0005,2)
				kolsuh = 0
			CASE pro.id_tovar = 2
			*обрат
				kol = pas.kolob
				koljir = pas.jirob
				kolsuh = 0
			CASE pro.id_tovar = 3
			*пахта
				kol = pas.kolpaht
				koljir = pas.koljirpaht
				kolsuh = 0
			CASE pro.id_tovar = 6
			*обрат сухой
				m.idtar = pas.id_tara
				kol = pas.kolgot
				koljir = 0
				kolsuh = 0
			ENDCASE

			SELECT nakc

			IF SEEK(BINTOC(m.id) + BINTOC(pro.id_tovar) + BINTOC(m.idtar), "NAKC", "IT")
				IF m.kol#0 OR m.koljir#0
					 = chnakl(2, m.id, pro.id_tovar, m.idtar, pas.id_organ, m.kol, m.koljir, m.kolsuh)
				ELSE
					 = chnakl(1, m.id, pro.id_tovar, m.idtar, pas.id_organ)
				ENDIF
			ELSE
				IF m.kol#0 OR m.koljir#0
					 = chnakl(0, m.id, pro.id_tovar, m.idtar, pas.id_organ, m.kol, m.koljir, m.kolsuh)
				ENDIF
			ENDIF
		ENDSCAN
	
		SELECT pas
	ELSE
		MESSAGEB('Нет типа документа!',54,'Внимание')
	ENDIF
	IF orec#0
		GO orec
	ENDIF
	SET ORDER TO &otag
	SELECT (osel)
RETURN

PROCEDURE rashet_grpas3
*расчет группир-го паспорта(обрат)
PARAMETERS nom
PRIVATE koljirsm,kolsm,jirsm,kolsuhsm,suhsm,nrsm,kolgot,;
	deltsm,kolpaht,;
	koljirpaht,kolsuhpaht,kolob,koljirob,kolsuhob,kolgots,plotnob;
	otag,orec,orec1,osel
	osel = SELECT()
	
	SELECT grpasc
	orec1 = IIF(EOF(),0,RECNO())
	SELECT grpas
	otag = SYS(21)
	orec = IIF(EOF(),0,RECNO())
	SET ORDER TO nomer

	IF nomer#m.nom AND !SEEK(m.nom)
		IF orec#0
			GO orec
		ENDIF
		SET ORDER TO &otag
		RETURN
	ENDIF

	nom = ID
	SET ENGINEBEHAVIOR 70

	SELECT SUM(kolpaht) AS kolpaht, SUM(koljirpaht) AS koljirpaht, SUM(kolsuhpaht) AS kolsuhpaht,;
		SUM(kolob) AS kolob, SUM(jirob) AS koljirob, SUM(kolsuhob) AS kolsuhob,;
		SUM(kolgot) AS kolgot, SUM(laban) AS laban,;
		SUM(kolob * plotnob) / SUM(kolob) AS plotnob,;
		SUM(div(kvlaga * 1000, div((jirob + koljirpaht + kolsuhob + kolsuhpaht) * 100,;
							       (kolob + kolpaht));
							   * (1 - 0.01 * sp.koef2)));
		/ SUM(1) as nrsm;
	FROM pas INTO CURSOR vrems;
	WHERE ID IN (SELECT id_pas FROM grpasc WHERE id_grpas  =  m.nom)
	SET ENGINEBEHAVIOR 90

	SCATTER MEMV
	USE
	*кол-во смеси
	kolsm = m.kolob + m.kolpaht
	*жирокг смеси
	koljirsm = m.koljirob + m.koljirpaht
	jirsm = div(m.koljirsm*100,m.kolsm)
	kolsuhsm = m.kolsuhob + m.kolsuhpaht
	suhsm = div(m.kolsuhsm*100,m.kolsm)
	sm = div((m.koljirsm + m.kolsuhsm) * 100, m.kolsm)
	*расчет нормы расхода смеси
*!*		nrsm = ROUND(div(sp.koef1*1000,m.sm*(1-0.01*sp.koef2)),3)
	kfgot = ROUND(m.kolgot/1000,3)
	*фактич расход смеси
	kolsm = ROUND(div(m.kolsm,m.kfgot),3)
	*экономия/перерасход смеси
	deltsm = (m.kolsm-m.nrsm)*m.kolgot/1000
	
	SELECT grpas
	GATHER MEMV
	
	IF orec#0
		GO orec
	ENDIF
	SET ORDER TO &otag
	
	SELECT grpasc
	IF orec1#0
		GO orec1
	ENDIF
	
	SELECT (osel)
RETURN

PROCEDURE rashet_pas4
*расчет паспорта(сух.сливки)
PARAMETERS mid
PRIVATE koljirm,kolsuhm,suhm,kolob,jirob,suhob,plotnob,kolgot,kfgot,;
	kolsm,deltsm,koljirsm,deltjirsm,suhsm,kolsuhsm,nrsm,m.kolsuhpaht,;
	kol,koljir,ID, idtar, otag,orec,osel
	osel = SELECT()

	SELECT pas
	otag = SYS(21)
	orec = IIF(EOF(),0,RECNO())
	SET ORDER TO ID

	IF SEEK(m.mid) AND !EMPTY(id_pro)
	*сезонные коэффициенты
		SELECT sez
		fou = .F.

		IF SEEK(pas.id_tara)
			SCAN WHILE id_ed = pas.id_tara
				IF pas.DATE >= bmonth AND pas.DATE <= emonth
					fou = .T.
					EXIT
				ENDIF
			ENDSCAN
		ENDIF

		IF m.fou
			SELECT pas
	*производство
	*лаб.анализы
			REPLACE laban WITH 0.2
	*кол жира в молоке
			m.jirInm = ROUND(div(pas.koljirinm*100,pas.kolinm),5)
	*%сухих в-в в молоке(СМОм)
			m.s11 = div((sp.koef1*m.jirInm + pas.plotnInm),sp.koef2) + pas.ksmom
	*%сухого обезжир молока(СОМОм)
			m.suhm = s11-m.jirInm
	*кол-во сухого обезжир молока(СОМОкг-м)
			m.kolsuhm = pas.kolinm*m.suhm/100
	*коэфф.учит.потери жира и СМО
			m.opr = 42.5/55.5 &&81
			m.kpot = div(1,(1 + m.opr)*div(1-0.01*0.5,1-0.01*0.79)-m.opr)
	*масса компонентов для нормализации
			m.onorm = m.opr*m.kpot
	*%сухих обезжир сливок(СОМОсл)
			m.suhob = div(100-pas.jirob,10.615)
	*%сухих в-в в сливках(СМОсл)
			kolob = IIF(pas.inpobrat, pas.kolob, ROUND(div(m.suhm*m.onorm-m.jirInm,pas.jirob-m.suhob*m.onorm)*pas.kolinm,0))
	*жир сливок
			m.koljirob = ROUND(m.kolob*pas.jirob/100,2)
	*кол-во сухого обезжир сливок(СОМОкг-сл)
			m.kolsuhob = m.kolob*m.suhob/100
	**кол-во смеси
			m.kolsm = pas.kolinm + m.kolob
	*жир смеси
			m.koljirsm = pas.koljirinm + m.koljirob
	*%жир смеси
			m.rsjirsm = div(m.koljirsm*100,m.kolsm)
	*кол-во сухой обезжир смеси(СОМОкг-см)
			m.kolsuhsm = m.kolsuhm + m.kolsuhob
	*%сух в-в в смеси(СОМсм)
			m.suhsm = div(m.kolsuhsm*100,m.kolsm)
			m.sm = div((m.koljirsm + m.kolsuhsm)*100,m.kolsm)
	*норма расхода смеси
			m.nrsm = div(98*1000,m.sm*(1-0.01*0.79))
	*расход нормы жира
			m.nrjirsm = 425 + 425*0.5/100
	*выход готовой продукц
			IF pas.kolgt
				kolgot = ROUND(pas.kolgot,1)
			ELSE
				kolgot = ROUND(ROUND(ROUND(div(div(m.koljirsm*1000,m.nrjirsm),edizm.ves),0)*edizm.ves,0) + pas.laban,1)
			ENDIF
			m.kfgot = ROUND(m.kolgot/1000,3)
			*фактич расход смеси
			m.kolsm = ROUND(div(m.kolsm,m.kolgot)*1000,3)
			*экономия/перерасход смеси
			m.deltsm = (m.kolsm-m.nrsm)*m.kfgot
			*фактич расход жира смеси
			m.koljirsm = ROUND(div(m.koljirsm,m.kolgot)*1000,3)
			*экономия/перерасход жира смеси
			m.deltjirsm = (m.koljirsm-m.nrjirsm)*m.kfgot
			*сохраняем изменения
			GATHER MEMV
			*добавить накладные
			SELECT nakc
			SET ORDER TO it
			SELECT nak
			SET ORDER TO id_pas
	
			SELECT pro
			SCAN FOR ID = RTRIM(pas.id_pro)
				IF id_tovar = 0
					LOOP
				ENDIF
				*накладная
				SELECT nak
				IF SEEK(BINTOC(pas.ID) + pro.typedoc, "NAK", "id_pas")
					m.id = ID
					REPLACE DATE WITH pas.DATE, id_organ WITH pas.id_organ IN NAK
				ELSE
					m.id = newid('nak')
					m.nomer = newnmnak(LEFT(pro.typedoc,2))

					INSERT INTO nak (ID,nomer,DATE,typedoc,id_pas, id_organ);
						VALU(m.id,m.nomer,pas.DATE,pro.typedoc,pas.ID, pas.id_organ)
				ENDIF
				*содержимое накладной
				m.idtar = 0
				DO CASE
				CASE pro.id_tovar = 1
				*молоко
					kol = pas.kolinm
					koljir = pas.koljirinm
					kolsuh = 0
				CASE pro.id_tovar = 4
				*сливки
					kol = pas.kolob
					koljir = ROUND(pas.kolob*pas.jirob/100,2)
					kolsuh = 0
				CASE pro.id_tovar = 7
				*сухие сливки
					m.idtar = pas.id_tara
					kol = pas.kolgot
					koljir = 0
					kolsuh = 0
				ENDCASE

				SELECT nakc
				IF SEEK(BINTOC(m.id) + BINTOC(pro.id_tovar) + BINTOC(m.idtar), "NAKC", "IT")
					IF m.kol#0 OR m.koljir#0
						 = chnakl(2, m.id, pro.id_tovar, m.idtar, pas.id_organ, m.kol, m.koljir, m.kolsuh)
					ELSE
						 = chnakl(1, m.id, pro.id_tovar, m.idtar, pas.id_organ)
					ENDIF
				ELSE
					IF m.kol#0 OR m.koljir#0
						 = chnakl(0, m.id, pro.id_tovar, m.idtar, pas.id_organ, m.kol, m.koljir, m.kolsuh)
					ENDIF
				ENDIF
			ENDSCAN
		ENDIF
	ELSE
		MESSAGEB('Нет типа документа!',54,'Внимание')
	ENDIF
	
	SELECT pas
	IF orec#0
		GO orec
	ENDIF
	SET ORDER TO &otag
	SELECT (osel)
RETURN

PROCEDURE rashet_grpas4
*расчет группир-го паспорта(сух.сливки)
PARAMETERS nom,tpro
PRIVATE koljirsm,kolsm,jirsm,kolsuhsm,suhsm,nrsm,kolgot,;
	deltsm,deltjirsm,kolm,koljirm,kolsuhm,kolpaht,;
	koljirpaht,kolsuhpaht,kolob,koljirob,kolsuhob,kolgots;
	otag,orec,orec1,osel &&,rela1,targ1,rela2,targ2
	osel = SELECT()
	
	SELECT grpasc
	orec1 = IIF(EOF(),0,RECNO())
	SELECT grpas
	otag = SYS(21)
	orec = IIF(EOF(),0,RECNO())
	SET ORDER TO nomer
	IF nomer#m.nom AND !SEEK(m.nom)
		IF orec#0
			GO orec
		ENDIF
		SET ORDER TO &otag
		RETURN
	ENDIF
	m.nom = ID
	SELECT grpas
	
	SET ENGINEBEHAVIOR 70

	SELECT SUM(kolinm) AS kolm,SUM(koljirinm) AS koljirm,SUM(kolsuhm) AS kolsuhm,;
		SUM(kolpaht) AS kolpaht,SUM(koljirpaht) AS koljirpaht,SUM(kolsuhpaht) AS kolsuhpaht,;
		SUM(kolob) AS kolob,SUM(ROUND(kolob*jirob/100,2)) AS koljirob,SUM(kolsuhob) AS kolsuhob,;
		SUM(kolgot) AS kolgot,SUM(laban) AS laban, div(SUM(kolinm*plotnInm),SUM(kolinm)) AS plotnsv,;
		div(SUM(kolob*plotnob),SUM(kolob)) AS plotnob;
	FROM pas INTO CURSOR vrems;
	WHERE ID IN (SELECT id_pas FROM grpasc WHERE id_grpas = m.nom)

	SET ENGINEBEHAVIOR 90
	
	SCATTER MEMV
	USE
	m.koljirsm = m.koljirm + m.koljirpaht + m.koljirob
	m.kolsm = m.kolm + m.kolpaht + m.kolob
	m.jirsm = ROUND(div(m.koljirsm*100,m.kolsm),5)
	m.kolsuhsm = m.kolsuhm + m.kolsuhpaht + m.kolsuhob
	m.suhsm = ROUND(div(m.kolsuhsm*100,m.kolsm),5)
	m.jirob = ROUND(div(m.koljirob*100,m.kolob),2)
	
	*%сухих обезжир сливок(СОМОсл)
	*норма расхода смеси
	m.sm = div((m.koljirsm + m.kolsuhsm)*100,m.kolsm)
	m.nrsm = div(98*1000,m.sm*(1-0.01*0.79))
	*расход нормы жира
	m.nrjirsm = 425 + 425*0.5/100
	*расчет нормы расхода смеси
	m.kfgot = ROUND(m.kolgot/1000,3)
	*фактич расход смеси
	m.kolsm = ROUND(div(m.kolsm,m.kolgot)*1000,3)
	*экономия/перерасход смеси
	m.deltsm = (m.kolsm-m.nrsm)*m.kfgot
	*фактич расход жира смеси
	m.koljirsm = ROUND(div(m.koljirsm,m.kolgot)*1000,3)
	*экономия/перерасход жира смеси
	m.deltjirsm = (m.koljirsm-m.nrjirsm)*m.kfgot
	
	SELECT grpas
	GATHER MEMV
	
	IF orec#0
		GO orec
	ENDIF
	SET ORDER TO &otag
	
	SELECT grpasc
	IF orec1#0
		GO orec1
	ENDIF
	
	SELECT (osel)
RETURN

PROCEDURE rashet_pas6
*расчет паспорта(сыворотка)
PARAMETERS mid, tlnorm
PRIVATE kolob,jirob,suhob,plotnob,kolgot,kfgot,;
	kolsm,suhsm,koljirsm,kolsuhsm,nrsm,m.kolsuhpaht,;
	kol,koljir,ID,nrsmf, idtar,otag,orec,osel
	osel = SELECT()

	SELECT pas
	otag = SYS(21)
	orec = IIF(EOF(),0,RECNO())
	SET ORDER TO ID

	IF SEEK(m.mid) AND !EMPTY(id_pro)
		*производство
		*лабанализы
		REPLACE laban WITH 0.2
		*сухих в общей выработке
		kolsuhm = ROUND(div(pas.kolinm * PAS.SUHM, 100), 2)
		*норма расхода смеси
		nrsm = ROUND(div((100 - PAS.KVLAGA) * 1000, PAS.SUHM * (1 - 0.01 * PAS.SUHPAHT)), 3)
		nrsuh = ROUND(div(m.nrsm * PAS.SUHM, 100), 2)
*!*			IF m.tlnorm
*!*				nrsm = ROUND(div(96*1000,pas.suhm*(1-0.01*pas.suhpaht)),3)
*!*			ELSE
*!*				nrsm = ROUND(div(95*1000,PAS.SUHM*(1-0.01*PAS.SUHPAHT)),3)
*!*			ENDIF
		*выход готовой продукц
		IF pas.kolgt
			kolgot = pas.kolgot
		ELSE
			kolgot = ROUND(div(div(pas.kolinm * 1000, m.nrsm), edizm.ves), 0) * edizm.ves + pas.laban
		ENDIF

		kolsuhgot = ROUND(m.kolgot*(100-pas.kvlaga)/100,2)
		kfgot = ROUND(m.kolgot / 1000, 3)
		*фактич.норма расхода смеси
		kolsm = ROUND(div(pas.kolinm, m.kfgot), 3)
		kolsuhfakt = ROUND(div(m.kolsuhm, m.kfgot), 3)
		*deltsm = (div(pas.kolinm,(m.kolgot/1000)-m.nrsm))*m.kolgot/1000
		deltsm = (m.kolsm - m.nrsm) * m.kfgot
		deltjirsm = (m.kolsuhfakt - m.nrsuh) * m.kfgot
		*сохраняем изменения
		GATHER MEMV
		*добавить накладные
		SELECT nakc
		SET ORDER TO it

		SELECT nak
		SET ORDER TO id_pas
	
		SELECT pro

		SCAN FOR ID = RTRIM(pas.id_pro)
			IF id_tovar = 0
				LOOP
			ENDIF
			*накладная
			SELECT nak
			IF SEEK(BINTOC(pas.ID) + pro.typedoc, "NAK", "id_pas")
				id = ID
				REPLACE DATE WITH pas.DATE, id_organ WITH pas.id_organ IN NAK
			ELSE
				id = newid('nak')
				nomer = newnmnak(LEFT(pro.typedoc,2))

				INSERT INTO nak (ID,nomer,DATE,typedoc,id_pas, id_organ);
						 VALUES (m.id,m.nomer,pas.DATE,pro.typedoc,pas.ID, pas.id_organ)
			ENDIF
			*содержимое накладной
			idtar = 0
			
			DO CASE
			CASE INLIST(pro.id_tovar, 9, 10, 11, 12, 13, 20, 22, 23, 26, 28, 30, 31, 32) AND pro.typedoc = '0101'
			*сух сыворотка
				idtar = pas.id_tara
				kol = pas.kolgot
				koljir = 0
				kolsuh = 0
			CASE INLIST(pro.id_tovar, 8, 10, 15, 16, 17, 19, 21, 24, 25, 27, 29) AND pro.typedoc = '0201'
			*сыворотка
				kol = pas.kolinm
				koljir = 0
				kolsuh = m.kolsuhm
			ENDCASE

			SELECT nakc
			IF SEEK(BINTOC(m.id) + BINTOC(pro.id_tovar) + BINTOC(m.idtar), "NAKC", "IT")
				IF m.kol#0 OR m.koljir#0
					 = chnakl(2, m.id, pro.id_tovar, m.idtar, pas.id_organ, m.kol, m.koljir, m.kolsuh)
				ELSE
					 = chnakl(1, m.id, pro.id_tovar, m.idtar, pas.id_organ)
				ENDIF
			ELSE
				IF m.kol#0 OR m.koljir#0
					 = chnakl(0, m.id, pro.id_tovar, m.idtar, pas.id_organ, m.kol, m.koljir, m.kolsuh)
				ENDIF
			ENDIF
		ENDSCAN
		
		SELECT pas
	ELSE
		MESSAGEBOX('Нет типа документа!',54,'Внимание')
	ENDIF

	IF orec#0
		GO orec
	ENDIF
	SET ORDER TO &otag

	SELECT (osel)
RETURN

PROCEDURE rashet_grpas6
*расчет группир-го паспорта(сыв.демир.)
PARAMETERS tcnom, tnnorm
PRIVATE koljirsm,kolsm,jirsm,kolsuhsm,suhsm,nrsm,kolgot,deltsm,kolpaht,;
	koljirpaht,kolsuhpaht,kolob,koljirob,kolsuhob,kolgots,plotnob,kvlaga;
	otag,orec,orec1,osel

	osel = SELECT()

	SELECT grpasc
	orec1 = IIF(EOF(),0,RECNO())

	SELECT grpas
	otag = SYS(21)
	orec = IIF(EOF(),0,RECNO())
	SET ORDER TO nomer

	IF nomer#m.tcnom AND !SEEK(m.tcnom)
		IF orec#0
			GO orec
		ENDIF
		SET ORDER TO &otag
		RETURN
	ENDIF

	tcnom = ID

	SET ENGINEBEHAVIOR 70

	SELECT SUM(kolinm) AS kolm,SUM(koljirinm) AS koljirm,SUM(kolsuhm) AS kolsuhm,MAX(suhm) AS suhm,MAX(suhpaht) AS suhpaht,;
		SUM(kolob) AS kolob,SUM(jirob) AS koljirob,SUM(kolsuhob) AS kolsuhob, SUM(KVLAGA)/SUM(1) as kvlaga,;
		SUM(kolgot) AS kolgot,SUM(laban) AS laban,;
		div(SUM(kolob*plotnob),SUM(kolob)) AS plotnob;
	FROM pas INTO CURSOR vrems;
	WHERE ID IN (SELECT id_pas FROM grpasc WHERE id_grpas  =  m.tcnom)

	SET ENGINEBEHAVIOR 90

	SCATTER MEMV
	USE
	*кол-во смеси
	kolsm = m.kolob + m.kolm
	*жирокг смеси
	koljirsm = m.koljirob + m.kolm
	jirsm = div(m.koljirsm*100,m.kolsm)
	kolsuhsm = m.kolsuhob + m.kolsuhm
	suhsm = ROUND(div(m.kolsuhsm * 100, m.kolsm), 2)
	sm = div((m.koljirsm + m.kolsuhsm)*100,m.kolsm)
	*расчет нормы расхода смеси
	nrsm = ROUND(div((100-m.kvlaga)*1000,m.suhm*(1-0.01*m.suhpaht)),3)
	nrsuh = ROUND(div(m.nrsm * m.suhm, 100), 2)
*!*		IF m.tnnorm
*!*			nrsm = ROUND(div(96*1000,m.suhm*(1-0.01*m.suhpaht)),3)
*!*		ELSE
*!*			nrsm = ROUND(div(95*1000,m.suhm*(1-0.01*m.suhpaht)),3)
*!*		ENDIF

	kolsuhgot = ROUND(m.kolgot*(100-m.kvlaga)/100,2)
	kolsuhm = ROUND(div(m.kolm * m.suhm, 100), 2)
	kfgot = ROUND(m.kolgot/1000,3)
	*фактич расход смеси
	kolsm = ROUND(div(m.kolsm,m.kfgot),3)
	kolsuhfakt = ROUND(div(m.kolsuhm, m.kfgot), 3)
	*экономия/перерасход смеси
	*	m.deltsm = (div(m.kolsm,(m.kolgot/1000)-m.nrsm))*m.kolgot/1000
	deltsm = (m.kolsm - m.nrsm) * m.kfgot
	deltjirsm = (m.kolsuhfakt - m.nrsuh) * m.kfgot

	SELECT grpas
	GATHER MEMVAR

	IF orec#0
		GO orec
	ENDIF
	SET ORDER TO &otag

	SELECT grpasc

	IF orec1#0
		GO orec1
	ENDIF

	SELECT (osel)
RETURN

FUNCTION div
PARAMETERS d1,d2
	IF m.d2 = 0
		RETURN 0
	ELSE
		RETURN m.d1/m.d2
	ENDIF

FUNCTION transform_my
LPARAMETERS tnnum
LOCAL lcstr as String, lnpoint as Integer, lnpos as Integer
	lcstr = LTRIM(TRANSFORM(m.tnnum, "@Z"))
	
	lnpoint = RATC('.', m.lcstr)
	
	IF m.lnpoint>0
		lnpos = LENC(m.lcstr)

		DO WHILE m.lnpos >= m.lnpoint
			IF INLIST(SUBSTRC(m.lcstr, m.lnpos, 1), '0', '.', ' ')
				lcstr = LEFTC(m.lcstr, m.lnpos-1)
			ELSE
				EXIT
			ENDIF

			lnpos = m.lnpos-1
		ENDDO
	ENDIF
RETURN m.lcstr