*����� �� ������(����� ������)
PARAMETERS idtar
*
*setBase()
*
STORE 0 TO m.plotnotob, rsmomob, koefm, rsmom, plotnot
*
select pro
set order to 1
seek '004'
select edizm
set order to 1
*
select sez
fou=.f.
IF seek(m.idtar)
	scan while id_ed=m.idtar
		if m.date1>=bmonth and m.date2<=emonth
			fou=.t.
			exit
		endif
	endscan
ENDIF
*
IF fou
	SELECT grpas
*		1				2	3		4	5		6			7		8			9		10		11	 12
	SUM kolm*plotnsv,kolm,koljirm,kolob,kolpaht,kolsuhob,koljirob,kolsuhpaht,koljirpaht,kolgot,rsmom,1 TO s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,rsmom,coup;
		FOR BETWEEN(grpas.date,m.date1,m.date2) and id_pro='004' and id_tara=m.idtar
	*
	m.rsmom=div(m.rsmom,coup)
	m.plotnot=ROUND(div(s1,s2),2)
	m.rjirm=s3*100/s2	&&d
	m.rsmom=(4.9*m.rjirm+m.plotnot)/4+0.5-m.rjirm
	m.rsmoob=div(s7,s4)*100
	m.rsmopa=0 &&div((s8+s9),s5)*100
	m.rsomosl=div((100-m.rsmoob),10.615)
	*
	ss1=s2*m.rsmom/100
	ss2=s4*m.rsomosl/100
*	ss3=s5*m.rsmopa
*	rsuhsm=div((ss1+ss2+ss3),(s2+s4+s5))
	m.rsuhsm=div((ss1+ss2+m.s3+m.s7)*100,(s2+s4))
	*
	m.nrsm=div(98.5*1000,m.rsuhsm*(1-0.01*0.79))
*	m.nrsm=div(96.8*1000,m.rsuhsm*(1-0.01*sez.koef5))
	*
	m.plallsm=m.nrsm*s10/1000
	m.faktallsm=(s2+s4)
	*
	m.plall1sm=m.nrsm
	m.faktall1sm=(s2+s4)*1000/s10
	*
	m.nrjirsm=425+425*0.5/100
	*
	m.plallj=m.nrjirsm*s10/1000
	m.faktallj=(s3+s7)
	*
	m.plall1j=m.nrjirsm
	m.faktall1j=(s3+s7)*1000/s10

	plall1sm1=0
	plall1j1=0
	plallsm1=0
	plallj1=0
	*
	SET RELATION TO id_tara INTO edizm
	GO TOP
	*
	DO FORM selprint
	*
	DO CASE
	CASE prin_prev=1
		REPORT FORM grsuhka NOCONSOLE PREVIEW for BETWEEN(grpas.date,m.date1,m.date2) AND id_pro='004' AND id_tara=m.idtar
	CASE prin_prev=2
	    REPORT FORM grsuhka NOCONSOLE TO PRINTER PROMPT for BETWEEN(grpas.date,m.date1,m.date2) AND id_pro='004' AND id_tara=m.idtar
	ENDCASE
ENDIF