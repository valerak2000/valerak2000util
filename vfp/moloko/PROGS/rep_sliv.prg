*отчет за декаду(сливки)
PARAMETERS idtov,prnt
*
LOCAL filnam, ii, iii, rmas,rmasjir, rsuhm,rsuhmjir, rsliv,rslivjir, flttov, prihmasl,prihjirmas, rhozm, rhozmjir
*setBase()
*
WAIT WINDOW NOWAIT "Создание отчета"
filnam=SYS(3)
SET ENGINEBEHAVIOR 70
select ost.date as date, id_tovar, to.name as name, koln,kolnjir, prih,prihjir,;
		000000000.000 as prihmasl,000000000.000 as prihjirmas,;
        rash as rmas,rashjir as rmasjir,;
        000000000.000 as rsuhm,000000000.000 as rsuhmjir,;
        000000000.000 as rsliv,000000000.000 as rslivjir,;
        000000000.000 as rhozm,000000000.000 as rhozmjir,; && (23.01.07 Andrey)
        000000000.000 as rhozm_c,000000000.000 as rhozmjir_c,; && (04.02.07 Andrey)
        kolk,kolkjir, 00 as posx;
from ost,to into table (filnam);
where between(ost.date, m.goApp.oVars.oCurrentTask.oVars.dfltdatebegin, m.goApp.oVars.oCurrentTask.oVars.dfltdateend);
      and id_tovar=m.idtov;
      and to.id=id_tovar;
group by 1,2;
order by 1,3
SET ENGINEBEHAVIOR 90
USE (filnam) EXCLUSIVE ALIAS rep_dek
*
STORE 0 TO m.ii,m.iii,m.monthotch
*
SELECT rep_dek
SCAN
	IF MONTH(rep_dek.date)#m.monthotch
		STORE .f. to mdek10,mdek20,mdek30
		m.monthotch=MONTH(rep_dek.date)
	ENDIF
	*
    STORE 0 TO rmas,rmasjir, rsuhm,rsuhmjir, rsliv,rslivjir
    SELECT pas
    SET ORDER TO prodate
    DO CASE
    CASE rep_dek.id_tovar=4 
        SUM kolob,ROUND(kolob*jirob/100,2) TO rsliv,rslivjir;
        for id_pro+DTOS(date)='004   '+DTOS(rep_dek.date)
    ENDCASE
    *
    STORE 0 TO prihmasl,prihjirmas
    *посчитать приход сливок из маслоцеха
    SELECT or
    SET ORDER TO name
    =SEEK('Маслоцех')
    *
    SELECT nakc
    SET ORDER TO it
    *
    SELECT nak
    SET ORDER TO typorgan
    SEEK '01'+BINTOC(or.id)
    SCAN FOR LEFT(typedoc,2)='01' AND id_organ=or.id AND date=rep_dek.date
    	SELECT nakc
    	SUM kol,koljir TO s1,s2 FOR BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(4)
    	prihmasl=m.prihmasl+s1
    	prihjirmas=m.prihjirmas+s2
    	*
    	SELECT nak
    ENDSCAN 
    *
***Мое дополнение *********************&& (23.01.07 Andrey)
***хозяйства 
	STORE 0 TO m.rhozm, m.rhozmjir
    select nak
    set order to typedoc
    scan for typedoc+dtos(date)='0202'+dtos(rep_dek.date) AND id_organ=2 AND BETWEEN(nak.date,m.date1,m.date2)
	    select nakc
    	set order to it
	    scan for BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(4)
		    m.rhozm=m.rhozm+kol
		    m.rhozmjir=m.rhozmjir+koljir
	    endscan
    	select nak
    endscan

	STORE 0 TO m.rhozm_c, m.rhozmjir_c
    select nak
    set order to typedoc
    scan for typedoc='0202' AND id_organ=2 AND BETWEEN(nak.date,m.date1,m.date2)
	    select nakc
    	set order to it
	    scan for BINTOC(id_nak)+BINTOC(id_tovar)+BINTOC(id_tara)=BINTOC(nak.id)+BINTOC(4)
		    m.rhozm_c=m.rhozm_c+kol
		    m.rhozmjir_c=m.rhozmjir_c+koljir
	    endscan
    	select nak
    endscan
***************************************
	
    SELECT rep_dek
    REPLACE prih WITH prih-m.prihmasl,prihjir WITH prihjir-m.prihjirmas,; 
	    prihmasl WITH m.prihmasl, prihjirmas WITH m.prihjirmas,;
    	rsuhm WITH m.rsuhm, rsuhmjir WITH m.rsuhmjir,;
    	rmas WITH rmas-m.rsliv-m.rhozm, rmasjir WITH rmasjir-m.rslivjir-m.rhozmjir,;&& (23.01.07 Andrey)
        rsliv WITH m.rsliv, rslivjir WITH m.rslivjir,;
        rhozm with m.rhozm, rhozmjir with m.rhozmjir,;
        rhozm_c with m.rhozm_c, rhozmjir_c with m.rhozmjir_c && (04.02.07 Andrey)
        
    *
    m.ii=m.ii+1
    REPLACE posx WITH m.iii
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
ENDSCAN
*
WAIT WINDOW NOWAIT "Создание завершено"
DO FORM selprint
DO CASE
CASE prin_prev=1
    REPORT FORM slivki NOCONSOLE PREVIEW 
CASE prin_prev=2
    REPORT FORM slivki NOCONSOLE TO PRINTER PROMPT
ENDCASE
*удалить курсор
IF USED('rep_dek')
    USE IN rep_dek
ENDIF
*
DELETE FILE SYS(5)+SYS(2003)+'\'+filnam+'.dbf'