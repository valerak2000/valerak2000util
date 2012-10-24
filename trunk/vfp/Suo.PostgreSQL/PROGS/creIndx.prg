*!*	PROCEDURE creIndx
	m.goApp.Function.CloseAllWindows()
	*
	closeBase()
*!*		set exclusive on
*!*		dele file .\dbf\*.cdx
*!*		setBase()
	TRY
		WAIT windows "Построение индексных файлов" NOWAIT 
		OPEN DATABASEm.goApp.cDBPath+m.goApp.cDBName EXCLUSIVE VALIDATE 
		WAIT WINDOWS "Построение индексных файлов завершено!" NOWAIT 
	CATCH
		WAIT WINDOWS "Ошибка открытия базы!" NOWAIT 
	ENDTRY 
	*
*!*		select to
*!*		delete tag all
*!*		index on id tag id
*!*		index on name tag name
*!*		*
*!*		select or
*!*		delete tag all
*!*		index on id tag id
*!*		index on name tag name
*!*		*
*!*		select typ
*!*		delete tag all
*!*		index on id tag id
*!*		*
*!*		select nak
*!*		delete tag all
*!*		index on id tag id
*!*		index on date tag date
*!*		index on str(id_pas,10)+typedoc tag id_pas
*!*		index on left(typedoc,2)+nomer tag typnomer
*!*		index on left(typedoc,2)+dtos(date) tag typdate
*!*		index on left(typedoc,2)+str(id_organ,10) tag typorgan
*!*		index on typedoc+dtos(date) tag typedoc
*!*		index on id_parnak tag id_parnak
*!*		*
*!*		select nakc
*!*		delete tag all
*!*		index on id_nak tag id_nak
*!*		index on str(id_nak,10)+str(id_tovar,10)+str(id_tara,10) tag it
*!*		*
*!*		select ost
*!*		delete tag all
*!*		index on dtos(date)+str(id_tovar,10)+str(id_tara,10) tag datetovar
*!*		*
*!*		select pro
*!*		delete tag all
*!*		index on id tag id
*!*		*
*!*		select grpas
*!*		delete tag all
*!*		index on id tag id
*!*		index on nomer tag nomer
*!*		index on dtos(date) tag date
*!*		index on dtos(date)+nomer tag datenom
*!*		index on id_pro+str(year(date)*12+month(date),6)+nomer tag nomdate
*!*		*
*!*		select grpasc
*!*		delete tag all
*!*		index on id_grpas tag id_grpas
*!*		index on id_pas tag id_pas
*!*		*
*!*		select pas
*!*		delete tag all
*!*		index on id tag id
*!*		index on nomer tag nomer
*!*		index on id_pro+nomer tag pronomer
*!*		index on id_pro+dtos(date) tag prodate
*!*		index on dtos(date) tag date
*!*		*
*!*		select edizm
*!*		delete tag all
*!*		index on id tag id
*!*		index on name tag name
*!*		*
*!*		select sp
*!*		delete tag all
*!*		index on id_pro tag id_pro
*!*		*
*!*		select sez
*!*		delete tag all
*!*		index on id_ed tag id_ed
	closeBase()
*!*		set exclu off
RETURN