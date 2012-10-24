*!*	PROCEDURE openTable
PARAMETERS tabls,ali,tcClose, mexcl
PRIVATE lni, lnArr, llSucc, lcOnErr
    IF EMPTY(mexcl)
    	m.mexcl=.f.
    ENDIF
    *
    IF EMPTY(tcClose)
        tcClose = "OPEN"
    ENDIF 
    tcClose = UPPER(tcClose)
    *
    lcOnErr = ON("ERROR")
    ON ERROR llSucc = .F.
    llSucc = .T.
    *
    DO CASE 
    CASE tcClose = "CLOSE"
        SELECT (m.ali)
        USE
    CASE tcClose = "OPEN"
        IF FILE(m.tabls)
        	TRY
	            IF USED(m.ali)
	                SELECT (m.ali)
	                USE (m.tabls) ALIAS (m.ali)
	                CURSORSETPROP("buffering",1)
	            ELSE
	            	IF m.mexcl
		                USE (m.tabls) IN 0 AGAIN ALIAS (m.ali) excl
	            	ELSE
	                	USE (m.tabls) IN 0 AGAIN ALIAS (m.ali)
	            	ENDIF 
	            	*
	                SELECT (m.ali)
	                CURSORSETPROP("buffering",1)
	            ENDIF 
	            *
	            IF CPDBF()#866
	            	USE IN m.ali
			        zero(m.tabls, 866)
			        *
	            	IF m.mexcl
		                USE (m.tabls) IN 0 AGAIN ALIAS (m.ali) excl  
	            	ELSE
	                	USE (m.tabls) IN 0 AGAIN ALIAS (m.ali)
	            	ENDIF 
	                SELECT (m.ali)
	                cursorsetprop("buffering",1)
		            IF cpdbf()#866
		            	llSucc=.f.
	 	            ENDIF 
	            ENDIF 
	        CATCH
    	        llSucc=.f.
	            EXIT 
	    	ENDTRY
        ELSE
            llSucc=.f.
            EXIT 
        ENDIF 
    CASE tcClose = "CHECK"
        IF !FILE(m.tabls)
           llSucc = .F.
           EXIT 
        ENDIF 
    CASE tcClose = "HARDCLOSE"
        IF USED(m.ali)
           USE IN (m.ali)
        ENDIF 
    ENDCASE 
    *
    ON ERROR &lcOnErr
RETURN m.llSucc