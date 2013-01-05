*отчет за декаду(сыворотка)
LPARAMETERS tcpro
*
m.ddatebeg = m.goApp.oVars.oCurrentTask.oVars.dfltdatebegin
m.ddateend = m.goApp.oVars.oCurrentTask.oVars.dfltdateend
setBase()
*
SET ENGINEBEHAVIOR 70
select GRPAS.*,;
		pro.comment as pro_comment, edizm.name as ed_name;
FROM GRPAS LEFT JOIN PRO ON PRO.ID = GRPAS.ID_PRO;
		   LEFT JOIN EDIZM ON EDIZM.ID = GRPAS.ID_TARA;
	INTO CURSOR PRINT_REP;
where between(date, m.ddatebeg, m.ddateend);
	  AND id_pro = m.tcpro;
order by 1
SET ENGINEBEHAVIOR 90

SELECT PRINT_REP
SUM round(m.goApp.oFunction.div(kolm,round(kolgot/1000,3)),3), kolgot, ROUND(m.goApp.oFunction.div(96*1000,suhm*(1-0.01*suhpaht)),3), kolm, suhm, suhpaht, 1,;
	ROUND(kolgot*suhm/100,2), kvlaga, kolsuhm, kolsuhgot;
	TO s4, sKolgot, s11, sKolm, sSuhm, sSuhPaht, sKolRec, sKolsuh, sKvlaga, sKolsuhm, sKolsuhgot

rjirm=0
plotnot=0
rsmom=0
*
rsmoob=0 &&((s6+s7)/s4)*100
rsmopa=0 &&((s8+s9)/s5)*100
*
*ss2=s4*rsmoob
*ss3=s5*rsmopa
rsuhsm=0 &&(ss2+ss3)/(s4+s5)
*
s11 = ROUND(m.goApp.oFunction.div(96 * 1000, m.goApp.oFunction.div(m.sSuhm, m.sKolRec) * (1 - 0.01 * m.goApp.oFunction.div(m.sSuhpaht, m.sKolRec))), 3)

plallsm = ROUND(m.s11 * ROUND(m.sKolgot / 1000, 3), 0)
*!*		plallsm=m.s11*sKolgot/1000
faktallsm = m.sKolm
*!*	faktallsm=s4*sKolgot/1000
*
plall1sm=m.s11
faktall1sm = round(m.goApp.oFunction.div(m.sKolm, round(m.sKolgot / 1000, 3)), 3) &&div(m.s4, m.sKolRec)
*
nrjirsm=0
*
plallj=0
faktallj=0
*
plall1j=0
faktall1j=0

planpot = round(m.sKolsuhgot * m.goApp.oFunction.div(m.sSuhpaht, m.sKolRec) / 100, 2)
faktpot = m.sKolsuhm - m.sKolsuhgot
*
GO TOP
oListener = CREATEOBJECT("ReportListener")
oListener.ListenerType=1 && Preview, or 0 for Print 

REPORT FORM "..\REPORTS\grsyvor_" OBJECT oListener NOCONSOLE PREVIEW
*удалить курсор
IF USED('PRINT_REP')
	USE IN PRINT_REP
ENDIF

CLOSE DATABASES
