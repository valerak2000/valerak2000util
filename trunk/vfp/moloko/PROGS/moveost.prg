select 1
use .\dbf\nakl
set order to id

select 2
use .\dbf\nakl_cont
set rela to id_nak into nakl
go top
scan
	if nakl.id_pas#0
		delete
	endif
endscan
close data