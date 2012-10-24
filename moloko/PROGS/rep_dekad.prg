*отчет за декаду
PARAMETERS idtov,prnt
*
LOCAL filnam, ii, iii, rsep,rsepjir, rsuh,rsuhjir, rsuhm,rsuhmjir, rhoz,rhozjir, rpot,rpotjir, flttov, rhozm, rhozmjir
*
wait window nowai "—оздание отчета"
filnam=sys(3)

SET ENGINEBEHAVIOR 70

select ost.date as date, id_tovar, to.name as name, koln,kolnjir, prih,prihjir,;
        000000000.000 as rsep,000000000.000 as rsepjir, 000000000.000 as rsuh,;
        000000000.000 as rsuhjir, 000000000.000 as rsuhm,000000000.000 as rsuhmjir,;
        000000000.000 as rhoz,000000000.000 as rhozjir,;
        000000000.000 as rpot,000000000.000 as rpotjir,;
        000000000.000 as rhozm,000000000.000 as rhozmjir,;
        kolk,kolkjir, 00 as posx;
from ost,to into table (filnam);
where between(ost.date,m.date1,m.date2);
      and id_tovar=idtov;
      and to.id=id_tovar;
group by 1,2;
order by 1,3

SET ENGINEBEHAVIOR 90
*
use (filnam) exclu alias rep_dek
*
store 0 to ii,iii
select rep_dek
scan
    store 0 to rsep,rsepjir, rsuh,rsuhjir, rsuhm,rsuhmjir, rhoz,rhozjir, rpot, rpotjir, rhozm, rhozmjir
    select pas
    set order to prodate
    *
    do case
    case rep_dek.id_tovar=1
    *молоко
    **сушка
        sum kolinm,koljirinm to rsuh,rsuhjir;
        for id_pro+dtos(date)='001   '+dtos(rep_dek.date) and id_tara=1
    **мелка сушка
        sum kolinm,koljirinm to rsuhm,rsuhmjir;
        for id_pro+dtos(date)='001   '+dtos(rep_dek.date) and id_tara=2
    **сепарирование
        sum kolinm,koljirinm to rsep,rsepjir;
        for id_pro+dtos(date)='002   '+dtos(rep_dek.date)
    **цельномолочный
        select nak
        set order to typedoc
        scan FOR typedoc+dtos(date)='0204'+dtos(rep_dek.date) OR (typedoc+dtos(date)='0202'+dtos(rep_dek.date) AND id_organ=1)
            select nakc
            set order to it
            scan for BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(1)
                rhoz=rhoz+kol
                rhozjir=rhozjir+koljir
            endscan
            select nak
        endscan
    **хоз€йства
        select nak
        set order to typedoc
        scan for typedoc+dtos(date)='0202'+dtos(rep_dek.date) AND id_organ<>1
            select nakc
            set order to it
            scan for BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(1)
                rhozm=rhozm+kol
                rhozmjir=rhozmjir+koljir
            endscan
            select nak
        endscan
    **потери
        select nak
        set order to typedoc
        scan for typedoc='0205' and date=rep_dek.date
            select nakc
            set order to it
            scan for BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(1)
                rpot=rpot+kol
                rpotjir=rpotjir+koljir
            endscan
            select nak
        endscan
    case rep_dek.id_tovar=2
    *обрат
    **сушка
        sum kolob,jirob to rsuh,rsuhjir;
        for id_pro+dtos(date)='001   '+dtos(rep_dek.date) and id_tara=1
    **мелка сушка
        sum kolob,jirob to rsuhm,rsuhmjir;
        for id_pro+dtos(date)='001   '+dtos(rep_dek.date) and id_tara=2
    **сепарирование
        sum kolob,jirob to rsep,rsepjir;
        for id_pro+dtos(date)='002   '+dtos(rep_dek.date)
    **потери
        select nak
        set order to typedoc
        scan for (typedoc='0203' or typedoc='0205') and date=rep_dek.date
            select nakc
            set order to it
            scan for BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(2)
                rpot=rpot+kol
                rpotjir=rpotjir+koljir
            endscan
            select nak
        endscan
    ENDCASE
    *
    select rep_dek
    REPLACE rsep with NVL(m.rsep,0), rsepjir with NVL(m.rsepjir,0), rsuh with NVL(m.rsuh,0),;
    	rsuhjir with NVL(m.rsuhjir,0), rsuhm with NVL(m.rsuhm,0), rsuhmjir with NVL(m.rsuhmjir,0),;
    	rhoz with NVL(m.rhoz,0), rhozjir with NVL(m.rhozjir,0), rpot with NVL(m.rpot,0),;
    	rpotjir with NVL(m.rpotjir,0), rhozm with NVL(m.rhozm,0), rhozmjir with NVL(m.rhozmjir,0)

    ii=ii+1

    REPLACE posx WITH m.iii

    IF ii>9
        iii=m.iii+1
        ii=0
    ENDIF
ENDSCAN
*
WAIT WINDOW NOWAIT "—оздание завершено"
*
DO FORM selprint
DO CASE
CASE prin_prev=1
    REPORT FORM dekad NOCONSOLE PREVIEW
CASE prin_prev=2
    REPORT FORM dekad NOCONSOLE TO PRINTER PROMPT
ENDCASE
*удалить курсор
IF USED('rep_dek')
    USE IN rep_dek
ENDIF 
DELETE FILE SYS(5)+SYS(2003)+'\'+filnam+'.dbf'
*delete file sys(2004)+filnam+'.cdx'