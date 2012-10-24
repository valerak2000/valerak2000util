*отчет экономии жира(сух.мол/СОМ)
PARAMETERS idtov,idtar,prnt
*
LOCAL filnam, flttov, strs
*
wait window nowai "Создание отчета..."
filnam=sys(3)
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
from &usl into table (filnam);
where between(date,m.date1,m.date2) AND id_tara=m.idtar;
	 &strs;
group BY date;
order by 1
*
use (filnam) exclu alias rep_dek
*
SUM ALL ekol,ejir,pkol,pjir TO s1,s2,s3,s4
*
GO TOP 
*
wait window nowai "Создание завершено..."
if prnt
    report form ekonom nocon to print
else
    report form ekonom nocon preview
endif
*удалить курсор
if used('rep_dek')
    use in rep_dek
endif
delete file sys(5)+sys(2003)+'\'+filnam+'.dbf'
