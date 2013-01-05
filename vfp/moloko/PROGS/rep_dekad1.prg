*отчет за декаду
PARAMETERS idtov,prnt
*
LOCAL filnam, ii, iii, prihhz,prihjirhz, prihhz1,prihjirhz1, prihsp,prihjirsp, prihzm,prihjirzm, rsuh,rsuhjir,;
      rsuhm,rsuhmjir, rhoz,rhozjir, rhoz1,rhozjir1, rpot,rpotjir, rsom,rsomjir, flttov
*setBase()
*
wait window nowai "—оздание отчета...."
filnam=sys(3)
SET ENGINEBEHAVIOR 70

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

SET ENGINEBEHAVIOR 90

use (filnam) exclu alias rep_dek
*
STORE 0 TO ii,iii
*
SELECT rep_dek
SCAN 
    STORE 0 TO prihhz,prihjirhz, prihhz1,prihjirhz1, prihsp,prihjirsp, prihzm,prihjirzm, rsuh,rsuhjir, rsuhm,rsuhmjir,;
                rhoz,rhozjir, rhoz1,rhozjir1, rpot, rpotjir, rsom,rsomjir
    SELECT pas
    SET ORDER TO prodate
    *
    DO CASE 
    CASE rep_dek.id_tovar=2
    *обрат
    **приход производство
        select nak
        set order to typedoc
        scan for typedoc+dtos(date)='0101'+dtos(rep_dek.date)
            select nakc
            set order to it
            scan for BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(2)
                prihsp=prihsp+kol
                prihjirsp=prihjirsp+koljir
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
                scan for BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(2)
                    prihhz=prihhz+kol
                    prihjirhz=prihjirhz+koljir
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
                scan for BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(2)
                    prihzm=prihzm+kol
                     prihjirzm=prihjirzm+koljir
                endscan
                select nak
            endif
        endscan
    **сушка
        select pas
        sum kolob,jirob to rsuh,rsuhjir;
        for id_pro+dtos(date)='001   '+dtos(rep_dek.date) and id_tara=1
    **мелка сушка
        sum kolob,jirob to rsuhm,rsuhmjir;
        for id_pro+dtos(date)='001   '+dtos(rep_dek.date) and id_tara=2
    **—ќћ
        sum kolob,jirob to rsom,rsomjir;
        for id_pro+dtos(date)='003   '+dtos(rep_dek.date) OR id_pro+dtos(date)='005   '+dtos(rep_dek.date)
    **расход хоз€йствам
        select nak
        set order to typedoc
        scan for typedoc+dtos(date)='0202'+dtos(rep_dek.date) AND id_organ<>1
            select nakc
            set order to it
            scan for BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(2)
                rhoz1=rhoz1+kol
                rhozjir1=rhozjir1+koljir
            endscan
            select nak
        endscan
    **расход цельномолочному
        SELECT nak
        SCAN FOR typedoc+dtos(date)='0204'+dtos(rep_dek.date) OR (typedoc+dtos(date)='0202'+dtos(rep_dek.date) AND id_organ=1)
            select nakc
            set order to it
            scan for BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(2)
                rhoz=rhoz+kol
                rhozjir=rhozjir+koljir
            ENDSCAN
            *
            SELECT nak
        ENDSCAN 
    **потери производство+реализаци€
        SELECT nak
        SCAN FOR typedoc+DTOS(date)='0203'+DTOS(rep_dek.date) OR;
                 typedoc+DTOS(date)='0205'+DTOS(rep_dek.date)
            SELECT nakc
            SET ORDER TO it
            SCAN FOR BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(2)
                rpot=rpot+kol
                rpotjir=rpotjir+koljir
            ENDSCAN 
            *
            SELECT nak
        ENDSCAN
    CASE rep_dek.id_tovar=8
    *сыворотка
    **приход хоз€йства
        SELECT nak
        SET ORDER TO typedoc
        SCAN FOR typedoc+DTOS(date)='0102'+DTOS(rep_dek.date)
            IF id_organ#1
                SELECT nakc
                SET ORDER TO it
                SCAN FOR BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(8)+BINTOC(0)
                    prihhz=prihhz+kol
                    prihjirhz=prihjirhz+koljir
                ENDSCAN
                * 
                SELECT nak
            ENDIF 
        ENDSCAN 
    **производство
    	m.datep=DTOS(rep_dek.date)
    	*
    	SELECT sum(kol), sum(koljir);
    	FROM nak, nakc INTO ARRAY gotpr;
    	WHERE typedoc+DTOS(date)='0201'+m.datep AND BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(8)
*!*	    	SELECT sum(kol), sum(koljir)
*!*	    	FROM nak, nakc INTO ARRAY gotpr
*!*	    	WHERE typedoc+DTOS(date)='0101'+m.datep AND
*!*	    		STR(id_nak,10)+STR(id_tovar,10)+STR(id_tara,10)=STR(nak.id,10)+STR(9,10)
    	*
    	IF TYPE('gotpr')#'U' AND !EMPTY(gotpr)
    		m.rsuh=gotpr(1,1)
    		m.rsuhjir=gotpr(1,2)
    		RELEASE gotpr
    	ELSE
    		STORE 0 TO m.rsuh,m.rsuhjir
    	ENDIF 
    CASE rep_dek.id_tovar=10
    *сыворотка
    **приход хоз€йства
        SELECT nak
        SET ORDER TO typedoc
        SCAN FOR typedoc+DTOS(date)='0102'+DTOS(rep_dek.date)
            IF id_organ#1
                SELECT nakc
                SET ORDER TO it
                SCAN FOR BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(10)+BINTOC(0)
                    prihhz=prihhz+kol
                    prihjirhz=prihjirhz+koljir
                ENDSCAN
                * 
                SELECT nak
            ENDIF 
        ENDSCAN 
    **производство
    	m.datep=DTOS(rep_dek.date)
    	*
    	SELECT sum(kol), sum(koljir);
    	FROM nak, nakc INTO ARRAY gotpr;
    	WHERE typedoc+DTOS(date)='0201'+m.datep AND BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(10)
    	*
    	IF TYPE('gotpr')#'U' AND !EMPTY(gotpr)
    		m.rsuh=gotpr(1,1)
    		m.rsuhjir=gotpr(1,2)
    		RELEASE gotpr
    	ELSE
    		STORE 0 TO m.rsuh,m.rsuhjir
    	ENDIF 
    ENDCASE
    *
    SELECT rep_dek
    REPLACE prihhz with NVL(m.prihhz,0), prihjirhz with NVL(m.prihjirhz,0),;
         prihzm with NVL(m.prihzm,0), prihjirzm with NVL(m.prihjirzm,0),;
         prihsp with NVL(m.prihsp,0), prihjirsp with NVL(m.prihjirsp,0),;
         rsuh with NVL(m.rsuh,0), rsuhjir with NVL(m.rsuhjir,0),;
         rsuhm with NVL(m.rsuhm,0), rsuhmjir with NVL(m.rsuhmjir,0),;
         rhoz with NVL(m.rhoz,0), rhozjir with NVL(m.rhozjir,0),;
         rhoz1 with NVL(m.rhoz1,0), rhozjir1 with NVL(m.rhozjir1,0),;
         rpot with NVL(m.rpot,0), rpotjir with NVL(m.rpotjir,0),;
         rsom with NVL(m.rsom,0), rsomjir with NVL(m.rsomjir,0)
    *
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
m.goApp.goForm("selprint", 0, .NULL., .NULL., ".\REPORTS\dekad1", "rep_dek")
*удалить курсор
if used('rep_dek')
    use in rep_dek
endif
delete file sys(5)+sys(2003)+'\'+filnam+'.dbf'