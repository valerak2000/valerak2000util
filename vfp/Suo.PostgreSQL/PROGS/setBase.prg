LPARAMETERS tctabls as String
LOCAL llfoks as Logical, lctabls as String, lcstrtabls as String, lcirun as String, lnipos as Integer, lciruna as String
	llfoks=.f.
	*
	TRY
		OPEN DATABASE (m.goApp.cDBPath+m.goApp.cDBName) SHARED
		*
		llfoks=.t.
		tctabls=IIF(VARTYPE(m.tctabls)='C',m.tctabls,"tovar:tovar,organ:organ,ostat:ostat,typedoc:typedoc,nakl:nakl,nakl_cont:nakl_cont,production:production,passw:passw,grpassw:grpassw,grpass_cont:grpass_cont"+;
													 ",edizm:edizm,tovedizm:tovedizm,sezon:sezon,describepole:describepole,softpole:softpole")
		*
		tcstrtabls=m.tctabls
		DO WHILE !EMPTY(m.tcstrtabls) AND m.llfoks
			lnipos=AT(',',m.tcstrtabls)
			IF m.lnipos=0
				tcirun=m.tcstrtabls
				tcstrtabls=''
			ELSE
				tcirun=LEFT(m.tcstrtabls,m.lnipos-1)
				tcstrtabls=SUBSTR(m.tcstrtabls,m.lnipos+1)
			ENDIF
			*
			lnipos=AT(':',m.tcirun)
			tciruna=SUBSTR(m.tcirun,m.lnipos+1)
			tcirun=LEFT(m.tcirun,m.lnipos-1)
			*
			IF !(!EMPTY(m.tcirun) AND openTableDB(m.goApp.cDBName+"!"+m.tcirun,m.tciruna))
		        MESSAGEBOX("Не удалось открыть файл "+m.goApp.cDBPath+m.goApp.cDBName+'!'+m.tcirun, 16, m.goApp.cTaskCaption)
				llfoks=.f.
			ENDIF
		ENDDO
	CATCH
        MESSAGEBOX("Ошибка открытия базы!", 16, m.goApp.cTaskCaption)
        CLOSE DATABASES ALL
	ENDTRY
    * 
    IF !m.llfoks
    	closeBase()
        MESSAGEBOX("Указанный путь "+m.goApp.cDBPath+m.goApp.cDBName+" не верен!", 16, m.goApp.cTaskCaption)
    ENDIF 
RETURN m.llfoks