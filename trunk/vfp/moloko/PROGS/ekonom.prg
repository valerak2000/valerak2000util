*отчет экономии жира(сух.мол/СОМ)
PARAMETERS idtov, idtar, tddatebeg as Date, tddateend as Date
*
LOCAL filnam, flttov, strs
	*
	wait window nowai "Создание отчета..."
	*
	strs=""
	*
	usl='grpas'
	do case
	case idtov=5
	*сух.молоко-001
		strs="AND id_pro='001   '"
	case idtov=6
	*СОМ-003
	    strs="AND (id_pro='003   ' or id_pro='005   ')"
	case idtov=7
	*Сух.сливки-004
	    strs="AND id_pro='004   '"
	case idtov=9
	*сыворотка-006
	    strs="AND id_pro='006   '"
	    usl='pas'
	endcase
	*
	SELECT to
	LOCATE FOR id=m.idtov
	*
	select date, sum(iif(deltsm<0,-deltsm,0.000)) as ekol, sum(iif(deltjirsm<0,-deltjirsm,0.000)) as ejir,;
		 sum(iif(deltsm>0,deltsm,0.000)) as pkol, sum(iif(deltjirsm>0,deltjirsm,0.000)) as pjir;
	from &usl into CURSOR PRINT_REP;
	where between(date, m.tddatebeg, m.tddateend) AND id_tara=m.idtar;
		 &strs;
	group BY date;
	order by 1
	*
	SUM ALL ekol,ejir,pkol,pjir TO s1,s2,s3,s4
	*
	oListener = CREATEOBJECT("ReportListener")
	oListener.ListenerType=1 && Preview, or 0 for Print 
	SELECT PRINT_REP
	GO TOP

	REPORT FORM "..\REPORTS\ekonom" OBJECT oListener NOCONSOLE PREVIEW

	IF USED("PRINT_REP")
		USE IN PRINT_REP
	ENDIF
