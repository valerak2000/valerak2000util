*новый номер в таблице накладных в соответсвии с типом
param tpdoc
private nwnm,osel,otag,orec,ofil
    osel=select()
    select nak
    otag=sys(21)
    orec=iif(eof(),0,recno())
    ofil=filter()
    *
    set filter to
    select max(val(nomer)) as mnom from nak into cursor mnoms;
    where left(typedoc,2)+dtos(date)=m.tpdoc+left(dtos(flt.date2),6)
    nwnm=str(NVL(mnoms.mnom,0)+1,10)
    *
    use in mnoms
    select nak
    set filter to
    set order to &otag
    set filter to &ofil
    if orec#0
        go orec
    else
        go bottom
    endif
    *
    select (osel)
return nwnm