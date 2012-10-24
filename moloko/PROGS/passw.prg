*список паспортов
param typ
	if !wexist('spis_pas')
		m.typpro=m.typ
		do form passw
	else
		activate window 'spis_pas'
	endif
	*
return
