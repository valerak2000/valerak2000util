*список сводных паспортов
PARAMETERS typ
	if !wexist('spis_grpas')
		m.typpro=m.typ
		do form grppassw
	else
		activate window 'spis_grpas'
	endif
return
