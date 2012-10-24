*отчет за декаду(пахта)
param idtov,prnt
*
local filnam, ii,iii, rsuh,rsuhjir, rsuhm,rsuhmjir, rsom,rsomjir, flttov
*setBase()
*
wait window nowai "Создание отчета"
filnam=sys(3)

SET ENGINEBEHAVIOR 70
select ost.date as date, id_tovar, to.name as name, koln,kolnjir, prih,prihjir,;
        000000000.000 as rsuh,000000000.000 as rsuhjir,;
        000000000.000 as rsuhm,000000000.000 as rsuhmjir,;
        000000000.000 as rsom,000000000.000 as rsomjir,;
        kolk,kolkjir, 00 as posx;
from ost,to into table (filnam);
where between(ost.date,m.date1,m.date2);
      and id_tovar=m.idtov;
      and to.id=id_tovar;
group by 1,2;
order by 1,3
SET ENGINEBEHAVIOR 90

use (filnam) exclu alias rep_dek
*
STORE 0 TO m.ii,m.iii,m.monthotch
*
select rep_dek
scan
	IF MONTH(rep_dek.date)#m.monthotch
		STORE .f. to mdek10,mdek20,mdek30
		m.monthotch=MONTH(rep_dek.date)
	ENDIF
	*
    store 0 to rsuh,rsuhjir, rsuhm,rsuhmjir, rsom,rsomjir
    select pas
    set order to prodate
    *
    do case
    case rep_dek.id_tovar=3
    *молоко
    **сушка
        sum kolpaht,koljirpaht to rsuh,rsuhjir;
        for id_pro+dtos(date)='001   '+dtos(rep_dek.date) and id_tara=1
    **мелка сушка
        sum kolpaht,koljirpaht to rsuhm,rsuhmjir;
        for id_pro+dtos(date)='001   '+dtos(rep_dek.date) and id_tara=2
    *СОМ
    **сушка
        sum kolpaht,koljirpaht to rsom,rsomjir;
        for id_pro+dtos(date)='003   '+dtos(rep_dek.date) OR id_pro+dtos(date)='005   '+dtos(rep_dek.date)
    ENDCASE
    *
    select rep_dek
    repl rsuh with m.rsuh, rsuhjir with m.rsuhjir,;
        rsuhm with m.rsuhm, rsuhmjir with m.rsuhmjir,;
        rsom with m.rsom, rsomjir with m.rsomjir
    *
    ii=ii+1
    repl posx with m.iii
    *
    DO CASE
    CASE DAY(rep_dek.date)>=10 AND !mdek10
        m.iii=m.iii+1
        m.ii=0
        mdek10=.t.
    CASE DAY(rep_dek.date)>=20 AND !mdek20
        m.iii=m.iii+1
        m.ii=0
        mdek20=.t.
    CASE rep_dek.date=CTOD('01/'+STR(IIF(m.monthotch<12,m.monthotch+1,1))+STR(IIF(m.monthotch<12,YEAR(rep_dek.date),YEAR(rep_dek.date)+1))) AND !mdek30
        m.iii=m.iii+1
        m.ii=0
        mdek30=.t.
    ENDCASE
endscan
wait window nowai "Создание завершено"
DO FORM selprint
DO CASE
CASE prin_prev=1
    report form pahta nocon preview
CASE prin_prev=2
    report form pahta nocon to print PROMPT
ENDCASE 
*удалить курсор
if used('rep_dek')
    use in rep_dek
endif
delete file sys(5)+sys(2003)+'\'+filnam+'.dbf'
*