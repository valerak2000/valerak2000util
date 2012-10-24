PARAMETERS tabls,ali,tcClose, mexcl, tnCodePage
PRIVATE lni, lnArr, llSucc, lcOnErr
    IF EMPTY(m.mexcl)
    	mexcl = .f.
    ENDIF
     
    IF EMPTY(m.tcClose)
        tcClose = "OPEN"
    ENDIF 

    tcClose = UPPER(m.tcClose)

    IF EMPTY(m.tnCodePage)
        tnCodePage = 866
    ENDIF 
     
    lcOnErr = ON("ERRO")
    ON ERROR llSucc = .F.
    llSucc = .T.
     
    DO CASE 
    CASE tcClose = "CLOSE"
        SELECT (m.ali)
        USE
    CASE tcClose = "OPEN"
        IF FILE(m.tabls)
            IF USED(m.ali)
                SELECT (m.ali)

                USE (m.tabls) ALIAS (m.ali)

                CURSORSETPROP("buffering", 1)
            ELSE
            	IF m.mexcl
	                USE (m.tabls) IN 0 AGAIN ALIAS (m.ali) excl
            	ELSE
                	USE (m.tabls) IN 0 AGAIN ALIAS (m.ali)
            	ENDIF 
            	 
                SELECT (m.ali)
                CURSORSETPROP("buffering", 1)
            ENDIF 
             
            IF CPDBF() <> m.tnCodePage
            	USE IN m.ali

		        zero(m.tabls, m.tnCodePage)
		         
            	IF m.mexcl
	                USE (m.tabls) IN 0 AGAIN ALIAS (m.ali) excl  
            	ELSE
                	USE (m.tabls) IN 0 AGAIN ALIAS (m.ali)
            	ENDIF 

                SELECT (m.ali)
                cursorsetprop("buffering", 1)

	            IF cpdbf() <> m.tnCodePage
			        DO gene1 WITH "Неверная кодировка файла " + m.tabls + '!' + CRLF;
			        			  + "Обратитесь к администратору базы!", -1, -1
	            	 
	            	llSucc=.f.
 	            ENDIF 
            ENDIF 
        ELSE 
            llSucc=.f.
        ENDIF 
    CASE tcClose = "CHECK"
        IF !FILE(m.tabls)
           llSucc = .F.
        ENDIF 
    CASE tcClose = "HARDCLOSE"
        IF USED(m.ali)
           USE IN (m.ali)
        ENDIF 
    ENDCASE 
     
    ON ERROR &lcOnErr
RETURN m.llSucc