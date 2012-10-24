*список накладных
param typk
private nazv
	if !wexist('spis_nakl')
		typs=typk
		do form spis_nakl
	else
		activate window 'spis_nakl'
	endif
	*
return