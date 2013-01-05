*отчет за декаду(сепарирование)
local filnam

m.ddatebeg = m.goApp.oVars.oCurrentTask.oVars.dfltdatebegin
m.ddateend = m.goApp.oVars.oCurrentTask.oVars.dfltdateend
setBase()
*
wait window nowai "Создание отчета...."
SET ENGINEBEHAVIOR 70
select pas.date,;
		kolinm as sepm, koljirinm as sepjirm,;
		kolpaht as sepsl, koljirpaht as sepjirsl,;
		kolob as sepob, jirob as sepjirob,;
		kolsm as seppot, koljirsm as sepjirpot,;
		pro.comment as pro_comment, edizm.name as edname;
FROM PAS LEFT JOIN PRO ON PRO.ID = PAS.ID_PRO;
		 LEFT JOIN EDIZM ON EDIZM.ID = PAS.ID_TARA;
	INTO CURSOR PRINT_REP;
where between(date, m.ddatebeg, m.ddateend);
	  AND id_pro='002   ';
order by 1
SET ENGINEBEHAVIOR 90
*
SELECT PRINT_REP
SUM ALL sepm,sepjirm,seppot,sepjirpot TO allm, alljirm,potm,potjir
planm=ROUND(allm*0.0037,0)
planjirm=ROUND(alljirm*0.0037,2)
delt=planm-potm
deltjir=planjirm-potjir
*
wait window nowai "Создание завершено"
GO TOP
oListener = CREATEOBJECT("ReportListener")
oListener.ListenerType=1 && Preview, or 0 for Print 

REPORT FORM "..\REPORTS\separ" OBJECT oListener NOCONSOLE PREVIEW
*удалить курсор
if used('PRINT_REP')
	use in PRINT_REP
endif
*
CLOSE DATABASES