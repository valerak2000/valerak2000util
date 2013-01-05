*отчет за декаду(сушка)
PARAMETERS tnidtar, tddatebeg as Date, tddateend as Date
*
*setBase()
*
SELECT pro
SET ORDER TO 1
SEEK '001'
SELECT edizm
SET ORDER TO 1
*
SELECT sez
fou=.F.
IF SEEK(m.tnidtar, "sez", "id_ed")
	SCAN WHILE id_ed=m.tnidtar
		IF m.tddatebeg>=bmonth AND m.tddateend<=emonth
			fou=.T.
			EXIT
		ENDIF
	ENDSCAN
ENDIF
*
IF m.fou
	=SEEK(m.tnidtar, "edizm", "ID")

	SELECT count(*) as cntpas, SUM(kjir) as kjir, SUM(kvlaga) as kvlaga;
	FROM pas INTO CURSOR curTmp;
	WHERE BETWEEN(DATE, m.tddatebeg, m.tddateend) AND id_pro='001' AND id_tara=m.tnidtar

	lnkjir = curTmp.kjir / curTmp.cntpas
	lnkvlaga = curTmp.kvlaga / curTmp.cntpas

	SELECT grpas
	*		1		2	   3		4	5		6			7		8			9		10		11	 12 13		14
	SUM kolm*plotnsv,kolm,koljirm,kolob,kolpaht,kolsuhob,koljirob,kolsuhpaht,koljirpaht,kolgot,rsmom,1,kolsuhm,kolob*plotnob;
	    TO s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,rsmom,coup,s13,s14;
		FOR BETWEEN(grpas.DATE, m.tddatebeg, m.tddateend) AND id_pro='001' AND id_tara=m.tnidtar
	
	m.rsmom=ROUND(m.goApp.oFunction.div(m.rsmom,m.coup),6)
	m.plotnot=ROUND(m.goApp.oFunction.div(m.s1,m.s2),2) &&d
	*
	rjirm=m.goApp.oFunction.div(m.s3*100,m.s2)	&&d
	*	rsmom=(4.9*m.rjirm+m.plotnot)/4+0.5 &&d
	*	rsmoob=div((s6+s7),s4)*100
	rsmoob=m.goApp.oFunction.div(m.s6,m.s4)*100
	*	rsmopa=div((s8+s9),s5)*100
	rsmopa=ROUND(m.goApp.oFunction.div(m.s8,m.s5)*100,6)
	*	m.rsomom=m.rsmom-m.rjirm
	*
	m.koefm=ABS(m.goApp.oFunction.div(4.9*m.rjirm+m.plotnot,4-m.rsmom))
	*
	m.plotnotob=ROUND(m.goApp.oFunction.div(m.s14,m.s4),2) &&d
	m.rsmomob=ROUND(ABS(m.goApp.oFunction.div(m.plotnotob,4+.05-m.rsmoob)),6)
	*
	m.ss1=m.s13
	*	ss1=s2*m.rsmom/100
	*	ss1=s2*m.rsomom/100
	*	ss2=s4*m.rsmoob/100
	ss2=m.s6
	*	ss3=s5*m.rsmopa/100
	ss3=m.s8
	rsuhsm=m.goApp.oFunction.div((m.ss1+m.ss2+m.ss3+m.s3+m.s7+m.s9)*100,m.s2+m.s4+m.s5)
	*
	*	m.nrsm=div(96.8*1000,m.rsuhsm*(1-0.01*sez.koef5))
	IF m.tddatebeg<{^2005-04-01} OR m.tddatebeg>={^2005-05-01}
		m.nrsm=m.goApp.oFunction.div(m.lnkvlaga*1000,m.rsuhsm*(1-0.01*sez.koef5))
		m.nrsm1=m.goApp.oFunction.div(m.lnkvlaga*1000,m.goApp.oFunction.div((m.s2*m.rsmom+m.s4*m.rsmoob+m.s5*m.rsmopa),;
												  m.s2+m.s4+m.s5)*(1-0.01*sez.koef5))
	ELSE
		m.nrsm=m.goApp.oFunction.div(96.8*1000,m.rsuhsm*(1-0.01*sez.koef5))
		m.nrsm1=m.goApp.oFunction.div(96.8*1000,div((m.s2*m.rsmom+m.s4*m.rsmoob+m.s5*m.rsmopa),m.s2+m.s4+m.s5)*(1-0.01*sez.koef5))
	ENDIF
*!*				m.nrjirsm = 255 + 255*sez.nrjir/100
	nrjirsm = m.lnkjir + m.lnkjir*sez.nrjir/100
	*
	m.plallsm=m.nrsm*m.s10/1000
	m.faktallsm=m.s2+m.s4+m.s5
	*
	m.plall1sm=m.nrsm
	*
	m.plallsm1=m.nrsm1*m.s10/1000
	m.plall1sm1=m.nrsm1
	*
	m.faktall1sm=m.goApp.oFunction.div((m.s2+m.s4+m.s5)*1000,m.s10)
	*
	*	m.nrjirsm=257+257*sez.nrjir/100
	*
	m.plallj=m.nrjirsm*m.s10/1000
	m.plallj1=m.nrjirsm*m.s10/1000
	m.faktallj=m.s3+m.s7+m.s9
	*
	m.plall1j=m.nrjirsm
	m.plall1j1=m.nrjirsm
	*
	m.faktall1j=m.goApp.oFunction.div((m.s3+m.s7+m.s9)*1000,m.s10)
	*
	SELECT grpas.*;
	FROM grpas INTO CURSOR PRINT_REP;
	WHERE BETWEEN(grpas.DATE,m.tddatebeg,m.tddateend) AND id_pro='001' AND id_tara=m.tnidtar

	oListener = CREATEOBJECT("ReportListener")
	oListener.ListenerType=1 && Preview, or 0 for Print 
	SELECT PRINT_REP
	GO TOP

	REPORT FORM "..\REPORTS\grsuhka" OBJECT oListener NOCONSOLE PREVIEW

	IF USED("PRINT_REP")
		USE IN PRINT_REP
	ENDIF
ENDIF