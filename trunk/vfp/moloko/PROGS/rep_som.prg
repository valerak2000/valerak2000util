*отчет за декаду(сом)
setBase()
*
m.ddatebeg = m.goApp.oVars.oCurrentTask.oVars.dfltdatebegin
m.ddateend = m.goApp.oVars.oCurrentTask.oVars.dfltdateend
*
SET ENGINEBEHAVIOR 70
select GRPAS.*,;
		pro.comment as pro_comment, edizm.name as ed_name;
FROM GRPAS LEFT JOIN PRO ON PRO.ID = GRPAS.ID_PRO;
		   LEFT JOIN EDIZM ON EDIZM.ID = GRPAS.ID_TARA;
	INTO CURSOR PRINT_REP;
where between(date, m.ddatebeg, m.ddateend);
	  AND INLIST(id_pro, '003', '005');
order by 1
SET ENGINEBEHAVIOR 90

SELECT PRINT_REP
SUM kolob,kolpaht,kolsuhob,koljirob,kolsuhpaht,koljirpaht,kolgot,kolob*plotnob;
	TO s4,s5,s6,s7,s8,s9,s10,s11

STORE 0 TO m.rjirm, m.plotnot, m.rsmom, m.plall1sm1, m.plall1j1, m.plallsm1, m.plallj1

rsmoob=((s6+s7)/s4)*100
rsmopa=((s8+s9)/s5)*100
*
ss2=s4*rsmoob
ss3=s5*rsmopa
rsuhsm=(ss2+ss3)/(s4+s5)
*
m.nrsm=m.goApp.oFunction.div(95*1000,m.rsuhsm*0.966)
*
m.plallsm=m.nrsm*s10/1000
m.faktallsm=(s4+s5)
*
m.plall1sm=m.nrsm
m.faktall1sm=(s4+s5)*1000/s10
*
STORE 0 TO m.nrjirsm, m.plallj, m.faktallj, m.plall1j, m.faktall1j, m.koefm
*
m.plotnotob=ROUND(m.goApp.oFunction.div(s11,s4),2) &&d
m.rsmomob=ABS(m.plotnotob/4+.05-m.rsmoob)
*
GO TOP
oListener = CREATEOBJECT("ReportListener")
oListener.ListenerType=1 && Preview, or 0 for Print 

REPORT FORM "..\REPORTS\grsuhka" OBJECT oListener NOCONSOLE PREVIEW
*удалить курсор
IF USED('PRINT_REP')
	USE IN PRINT_REP
ENDIF

CLOSE DATABASES

