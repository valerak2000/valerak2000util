PARAMETERS nom,dat,pri
PRIVATE otag,orec,orec1,otag1, m.idgrp
    SELECT grpasc
    orec=IIF(EOF(),0,RECNO())
    SELECT grpas
    otag=SYS(21)
    orec1=IIF(EOF(),0,RECNO())
    SET ORDER TO datenom
    IF SEEK(m.dat+m.nom)
        m.idgrp=grpas.id
        SET ORDER TO id
        *сезонные коэффициенты
        fou=.f.
        SELECT sez
        IF SEEK(grpas.id_tara)
            SCAN WHILE id_ed=grpas.id_tara
                IF grpas.date>=bmonth AND grpas.date<=emonth
			        fou=.t.
                    EXIT 
                ENDIF 
            ENDSCAN 
        ENDIF 
        *
        IF fou
			IF EMPTY(m.pri)
				DO FORM selprint
			ELSE
				m.prin_prev=m.pri
			ENDIF
			*
	        SELECT grpasc
	        SET ORDER TO id_grpas
	        IF grpas.id_pro='004'
				DO CASE
				CASE m.prin_prev=1
    	            REPORT FORM grpasswsl PREVIEW NOCONSOLE FOR grpasc.id_grpas=m.idgrp
				CASE m.prin_prev=2
            	    REPORT FORM grpasswsl TO PRINTER PROMPT NOCONSOLE FOR grpasc.id_grpas=m.idgrp
	            ENDCASE
	        ELSE
				DO CASE
				CASE m.prin_prev=1
	           	    REPORT FORM grpassw PREVIEW NOCONSOLE FOR grpasc.id_grpas=m.idgrp
				CASE m.prin_prev=2
	                REPORT FORM grpassw TO PRINTER PROMPT NOCONSOLE FOR grpasc.id_grpas=m.idgrp
    	        ENDCASE
	        ENDIF
*!*	        	SELECT * FROM grpasc INTO TABLE spgrpasc WHERE grpasc.id_grpas=grpas.id &&AND pas.id=grpasc.id_pas
*!*	        	*
*!*		        SELECT spgrpasc
*!*				SET RELATION TO id_pas INTO pas
*!*		        IF RECCOUNT()#0
*!*		        	GO TOP
*!*	*!*					ON ERROR fant=.t.
*!*			        IF grpas.id_pro='004'
*!*						DO CASE
*!*						CASE prin_prev=1
*!*		    	            REPORT FORM grpasswsl PREVIEW NOCONSOLE && FOR grpasc.id_grpas=m.idgrp
*!*						CASE prin_prev=2
*!*		            	    REPORT FORM grpasswsl TO PRINTER PROMPT NOCONSOLE &&FOR id_grpas=m.idgrp
*!*			            ENDCASE
*!*			        ELSE
*!*						DO CASE
*!*						CASE prin_prev=1
*!*		            	    REPORT FORM grpassw PREVIEW NOCONSOLE &&FOR grpasc.id_grpas=m.idgrp
*!*						CASE prin_prev=2
*!*			                REPORT FORM grpassw TO PRINTER PROMPT NOCONSOLE &&FOR id_grpas=m.idgrp
*!*		    	        ENDCASE
*!*		        	ENDIF
*!*		        	*
*!*	*!*					ON ERROR
*!*		        ENDIF
*!*			    *
*!*				USE IN spgrpasc
	    ENDIF
    ENDIF
    *
    SELECT grpas
    SET ORDER TO &otag
    IF orec1#0
        GO orec1
    ENDIF
    *
    SELECT grpasc
    IF orec#0
        GO orec
    ENDIF
RETURN