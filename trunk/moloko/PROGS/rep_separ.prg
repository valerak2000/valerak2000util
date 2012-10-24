*отчет за декаду(сепарирование)
*
local filnam

setBase()
*
wait window nowai "Создание отчета...."
filnam=sys(3)
SET ENGINEBEHAVIOR 70
select pas.date as date,;
		kolinm as sepm, koljirinm as sepjirm,;
		kolpaht as sepsl, koljirpaht as sepjirsl,;
		kolob as sepob, jirob as sepjirob,;
		kolsm as seppot, koljirsm as sepjirpot;
from pas into table (filnam);
where between(date,flt.date1,flt.date2);
	  and;
	  id_pro='002   ';
order by 1
SET ENGINEBEHAVIOR 90
use (filnam) exclu alias rep_dek
*
select rep_dek
SUM ALL sepm,sepjirm,seppot,sepjirpot TO allm, alljirm,potm,potjir
planm=ROUND(allm*0.0037,0)
planjirm=ROUND(alljirm*0.0037,2)
delt=planm-potm
deltjir=planjirm-potjir
*
wait window nowai "Создание завершено"
GO TOP
DO FORM selprint
DO CASE
CASE prin_prev=1
	REPORT FORM separ NOCONSOLE PREVIEW 
CASE prin_prev=2
    REPORT FORM separ NOCONSOLE TO PRINTER PROMPT
ENDCASE
*удалить курсор
if used('rep_dek')
	use in rep_dek
endif
delete file sys(5)+sys(2003)+'\'+filnam+'.dbf'
close data
*