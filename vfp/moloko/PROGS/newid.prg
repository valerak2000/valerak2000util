*новый системный код в таблице
param als
private nwid,osel,otag,orec,ofil
	osel=select()
	select (als)
	otag=sys(21)
	orec=iif(eof(),0,recno())
	ofil=filter()
	*
	set filter to
	set order to id
	go bottom
*	skip -1
	nwid=NVL(id,0)+1
	*
	set order to &otag
	set filter to &ofil
	if orec#0
		go orec
	else
		go bottom
	endif
	*
	select (osel)
return nwid