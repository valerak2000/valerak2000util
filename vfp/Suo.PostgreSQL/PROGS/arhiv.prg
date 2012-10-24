!rar.EXE a -r .\arhiv\tempbase .\DATA\
DELETE FILE (".\arhiv\base"+DTOC(DATE(),1)+".rar")
RENAME .\arhiv\tempbase.rar TO (".\arhiv\base"+DTOC(DATE(),1)+".rar")