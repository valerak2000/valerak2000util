*отчет за декаду(сом)
*
setBase()
*
select pro
set order to 1
seek '003'
select edizm
set order to 1
*
select grpas
*
SUM kolob,kolpaht,kolsuhob,koljirob,kolsuhpaht,koljirpaht,kolgot,kolob*plotnob TO s4,s5,s6,s7,s8,s9,s10,s11;
	for between(grpas.date,flt.date1,flt.date2) and (id_pro='003' OR id_pro='005')
*
STORE 0 TO m.rjirm, m.plotnot, m.rsmom, m.plall1sm1, m.plall1j1, m.plallsm1, m.plallj1
*
rsmoob=((s6+s7)/s4)*100
rsmopa=((s8+s9)/s5)*100
*
ss2=s4*rsmoob
ss3=s5*rsmopa
rsuhsm=(ss2+ss3)/(s4+s5)
*
m.nrsm=div(95*1000,m.rsuhsm*0.966)
*
m.plallsm=m.nrsm*s10/1000
m.faktallsm=(s4+s5)
*
m.plall1sm=m.nrsm
m.faktall1sm=(s4+s5)*1000/s10
*
STORE 0 TO m.nrjirsm, m.plallj, m.faktallj, m.plall1j, m.faktall1j, m.koefm
*
m.plotnotob=ROUND(div(s11,s4),2) &&d
m.rsmomob=ABS(m.plotnotob/4+.05-m.rsmoob)
*
GO TOP
set rela to id_tara into edizm
m.date1=flt.date1
m.date2=flt.date2
*
DO FORM selprint
DO CASE
CASE prin_prev=1
	REPORT FORM grsuhka NOCONSOLE PREVIEW for between(grpas.date,flt.date1,flt.date2) and (id_pro='003' OR id_pro='005')
CASE prin_prev=2
    REPORT FORM grsuhka NOCONSOLE TO PRINTER PROMPT for between(grpas.date,flt.date1,flt.date2) and (id_pro='003' OR id_pro='005')
ENDCASE 
*
close data
*