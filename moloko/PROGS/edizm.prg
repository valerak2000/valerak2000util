openTable(basep+'edizm.dbf','edizm')
openTable(basep+'sezon.dbf','sez')
select edizm
set relation to id into sez
set skip to sez
browse field id,name,ves,sez.bmonth,sez.emonth,sez.nrjir :h='Норма потерь жира',sez.koef5  :h='Норма потерь сухих веществ'
close data
