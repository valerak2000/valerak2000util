*отчет за декаду(сом)
*
setBase()
*
select pro
set order to 1
seek '007'
select edizm
set order to 1
*
select grpas
*
*!*	SUM kolinm,kolgot,round(div(95*1000,suhm*(1-0.01*suhpaht)),3) TO s4,s10,s11;
*!*		for between(pas.date,flt.date1,flt.date2) and id_pro='007'
SUM round(div(kolm,round(kolgot/1000,3)),3),kolgot,ROUND(div(95*1000,suhm*(1-0.01*suhpaht)),3) TO s4,s10,s11;
	for between(grpas.date,flt.date1,flt.date2) and id_pro='007'
*
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
	*
	GO TOP
	set rela to id_tara into edizm
	m.date1=flt.date1
	m.date2=flt.date2
	*
	DO FORM selprint
	*
	DO CASE
	CASE prin_prev=1
		REPORT FORM grsyvor NOCONSOLE PREVIEW for between(grpas.date,flt.date1,flt.date2) and id_pro='007'
	CASE prin_prev=2
	    REPORT FORM grsyvor NOCONSOLE TO PRINTER PROMPT for between(grpas.date,flt.date1,flt.date2) and id_pro='007'
	ENDCASE
CLOSE DATABASES
*