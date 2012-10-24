*отчет за декаду
param idtov,prnt
*
local filnam, ii, iii, prihhz,prihjirhz, prihhz1,prihjirhz1, prihsp,prihjirsp, prihzm,prihjirzm, rsuh,rsuhjir,;
      rsuhm,rsuhmjir, rhoz,rhozjir, rhoz1,rhozjir1, rpot,rpotjir, rsom,rsomjir, flttov
*setBase()
*
wait window nowai "—оздание отчета...."
filnam=sys(3)
select ost.date as date, id_tovar, to.name as name, koln,kolnjir,;
        000000000.000 as prihhz, 000000000.000 as prihjirhz,;
        000000000.000 as prihhz1, 000000000.000 as prihjirhz1,;
        000000000.000 as prihsp, 000000000.000 as prihjirsp,;
        000000000.000 as prihzm, 000000000.000 as prihjirzm,;
        000000000.000 as rsuh, 000000000.000 as rsuhjir,;
        000000000.000 as rsuhm, 000000000.000 as rsuhmjir,;
        000000000.000 as rhoz, 000000000.000 as rhozjir,;
        000000000.000 as rhoz1, 000000000.000 as rhozjir1,;
        000000000.000 as rpot, 000000000.000 as rpotjir,;
        000000000.000 as rsom, 000000000.000 as rsomjir,;
        kolk,kolkjir, 00 as posx;
from ost,to into table (filnam);
where between(ost.date,m.date1,m.date2);
      and id_tovar=m.idtov;
      and to.id=id_tovar;
group by 1,2;
order by 1,3
use (filnam) exclu alias rep_dek
*
store 0 to ii,iii
select rep_dek
scan
    store 0 to prihhz,prihjirhz, prihhz1,prihjirhz1, prihsp,prihjirsp, prihzm,prihjirzm, rsuh,rsuhjir, rsuhm,rsuhmjir,;
                rhoz,rhozjir, rhoz1,rhozjir1, rpot, rpotjir, rsom,rsomjir
    select pas
    set order to prodate
    do case
    case rep_dek.id_tovar=2
    *обрат
    **приход производство
        select nak
        set order to typedoc
        scan for typedoc+dtos(date)='0101'+dtos(rep_dek.date)
            select nakc
            set order to it
            scan for str(id_nak,10)+str(id_tovar,10)+str(id_tara,10)=str(nak.id,10)+str(2,10)
                prihsp=prihsp+kol
                prihjirsp=prihjirsp+kol*0.0005
            endscan
            select nak
        endscan
    **приход хоз€йства
        select nak
        set order to typedoc
        scan for typedoc+dtos(date)='0102'+dtos(rep_dek.date)
            if id_organ#1
                select nakc
                set order to it
                scan for str(id_nak,10)+str(id_tovar,10)+str(id_tara,10)=str(nak.id,10)+str(2,10)
                    prihhz=prihhz+kol
                    prihjirhz=prihjirhz+kol*0.0005
                endscan
                select nak
            endif
        endscan
    **приход цельномолочный
        select nak
        set order to typedoc
        scan for typedoc+dtos(date)='0102'+dtos(rep_dek.date)
            if id_organ=1
                select nakc
                set order to it
                scan for str(id_nak,10)+str(id_tovar,10)+str(id_tara,10)=str(nak.id,10)+str(2,10)
                    prihzm=prihzm+kol
                     prihjirzm=prihjirzm+kol*0.0005
                endscan
                select nak
            endif
        endscan
    **сушка
        select pas
        sum kolob,kolob*0.0005 to rsuh,rsuhjir;
        	for id_pro+dtos(date)='001   '+dtos(rep_dek.date) and id_tara=1
    **мелка сушка
        sum kolob,kolob*0.0005 to rsuhm,rsuhmjir;
        	for id_pro+dtos(date)='001   '+dtos(rep_dek.date) and id_tara=2
    **—ќћ
        sum kolob,kolob*0.0005 to rsom,rsomjir;
        	for id_pro+dtos(date)='003   '+dtos(rep_dek.date)
    **расход хоз€йствам
        select nak
        set order to typedoc
        scan for typedoc+dtos(date)='0202'+dtos(rep_dek.date)
            select nakc
            set order to it
            scan for str(id_nak,10)+str(id_tovar,10)+str(id_tara,10)=str(nak.id,10)+str(2,10)
                rhoz1=rhoz1+kol
                rhozjir1=rhozjir1+kol*0.0005
            endscan
            select nak
        endscan
    **расход цельномолочному
        select nak
        scan for typedoc+dtos(date)='0204'+dtos(rep_dek.date)
            select nakc
            set order to it
            scan for str(id_nak,10)+str(id_tovar,10)+str(id_tara,10)=str(nak.id,10)+str(2,10)
                rhoz=rhoz+kol
                rhozjir=rhozjir+kol*0.0005
            endscan
            select nak
        endscan
    **потери производство+реализаци€
        select nak
        scan for typedoc+dtos(date)='0203'+dtos(rep_dek.date) or;
                 typedoc+dtos(date)='0205'+dtos(rep_dek.date)
            select nakc
            set order to it
            scan for str(id_nak,10)+str(id_tovar,10)+str(id_tara,10)=str(nak.id,10)+str(2,10)
                rpot=rpot+kol
                rpotjir=rpotjir+kol*0.0005
            endscan
            select nak
        endscan
    endcase
    select rep_dek
    repl prihhz with m.prihhz, prihjirhz with m.prihjirhz,;
         prihzm with m.prihzm, prihjirzm with m.prihjirzm,;
         prihsp with m.prihsp, prihjirsp with m.prihjirsp,;
         rsuh with m.rsuh, rsuhjir with m.rsuhjir,;
         rsuhm with m.rsuhm, rsuhmjir with m.rsuhmjir,;
         rhoz with m.rhoz, rhozjir with m.rhozjir,;
         rhoz1 with m.rhoz1, rhozjir1 with m.rhozjir1,;
         rpot with m.rpot, rpotjir with m.rpotjir,;
         rsom with m.rsom, rsomjir with m.rsomjir
    *
    ii=ii+1
    repl posx with m.iii
    if ii>9
        iii=m.iii+1
        ii=0
    endif
endscan
*
go top
m.koln1=koln
m.kolnjir1=kolnjir
scan
	m.prih=prihhz+prihhz1+prihsp+prihzm
	m.prihj=prihjirhz+prihjirhz1+prihjirsp+prihjirzm
	m.rash=rsuh+rsuhm+rhoz+rhoz1+rpot+rsom
	m.rashj=rsuhjir+rsuhmjir+rhozjir+rhozjir1+rpotjir+rsomjir
	*
	repl koln with m.koln1, kolnjir with m.kolnjir1,;
		kolk with koln+m.prih-m.rash,;
		kolkjir with kolnjir+m.prihj-m.rashj
	*
	m.koln1=kolk
	m.kolnjir1=kolkjir
endscan
*
wait window nowai "—оздание завершено"
*
if prnt
    report form dekad1 nocon to print
else
    report form dekad1 nocon preview
endif
*удалить курсор
if used('rep_dek')
    use in rep_dek
endif
delete file sys(5)+sys(2003)+'\'+filnam+'.dbf'