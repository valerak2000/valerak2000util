openTable(basep+'nakl_cont.dbf','nakc')
openTable(basep+'ostat.dbf','ost')
select nakc
scan all
	if id_tovar=6
		repl id_tara with 1
	endif
endscan

select ost
scan all
	if id_tovar=6
		repl id_tara with 1
	endif
endscan
close data
return