PARAMETERS whatdo,idtov,idtar,idor,kol,koljir
*!*	LOCAL osel
*!*	PRIVATE m.koln,m.kolnjir,m.kolk,m.kolkjir, masto1, mased1
    *
    if empty(m.idtov)
        m.idtov=0
    endif
    if empty(m.idtar)
        m.idtar=0
    endif
    if empty(m.idor)
        m.idor=0
    endif
    if empty(m.kol)
        m.kol=0
    endif
    if empty(m.koljir)
        m.koljir=0
    endif
    *
*!*	    *начальные остатки
*!*	    if seek(dtos(nak.date)+str(m.idtov,10)+str(m.idtar,10)+str(m.idor,10),'ost')
*!*	        m.koln=ost.kolk+iif(left(nak.typedoc,2)='01',-m.kol,m.kol)
*!*	        m.kolnjir=ost.kolkjir+iif(left(nak.typedoc,2)='01',-m.koljir,m.koljir)
*!*	        m.kolk=ost.kolk
*!*	        m.kolkjir=ost.kolkjir
*!*	    else
*!*	        m.koln=0
*!*	        m.kolnjir=0
*!*	        m.kolk=iif(left(nak.typedoc,2)='01',-m.kol,m.kol)
*!*	        m.kolkjir=iif(left(nak.typedoc,2)='01',-m.koljir,m.koljir)
*!*	    endif
*!*	    *
*!*	    osel=select()
*!*	    *
*!*	    STORE masto TO masto1
*!*	    STORE mased TO mased1
*!*	    masto(1)=m.idtov
*!*	    mased(1)=m.idtar
*!*	    *
*!*	    select nakc
*!*	    *
    do form nak_tovar WITH whatdo,idtov,idtar,idor,kol,koljir
*!*	    STORE mased1 TO mased
*!*	    STORE masto1 TO masto
*!*	    *
*!*	    select (osel)