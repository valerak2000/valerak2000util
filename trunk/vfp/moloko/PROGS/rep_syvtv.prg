*отчет за декаду(сом)
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
	  AND INLIST(id_pro, '007');
order by 1
SET ENGINEBEHAVIOR 90

SELECT PRINT_REP
SUM round(m.goApp.oFunction.div(kolm,round(kolgot/1000,3)),3),kolgot,ROUND(m.goApp.oFunction.div(95*1000,suhm*(1-0.01*suhpaht)),3);
	TO s4,s10,s11
*
sSuhpaht
sKolRec
skolsuhm
skolsuhgot
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
m.plallsm=m.s11*s10/1000
m.faktallsm=s4*s10/1000
*
m.plall1sm=m.s11
m.faktall1sm=s4
*
m.nrjirsm=0
*
m.plallj=0
m.faktallj=0
*
m.plall1j=0
m.faktall1j=0

GO TOP
oListener = CREATEOBJECT("ReportListener")
oListener.ListenerType=1 && Preview, or 0 for Print 

REPORT FORM "..\REPORTS\grsyvor" OBJECT oListener NOCONSOLE PREVIEW
*удалить курсор
IF USED('PRINT_REP')
	USE IN PRINT_REP
ENDIF

CLOSE DATABASES