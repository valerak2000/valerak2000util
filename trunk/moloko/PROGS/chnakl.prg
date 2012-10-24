*изменение позиции в накладой
PARAMETERS whatdo,idnak,idtov,idtar,idor,kol,koljir
*0-добавить, 1-удалить, 2-модифицировать
PRIVATE osel,orecnakc,otagnakc, otagnak,orecnak
    if empty(idnak)
        return
    endif

*   kol=round(m.kol,0)
*   koljir=round(m.koljir,2)

    osel=select()

    select nakc
    otagnakc=sys(21)
    orecnakc=iif(eof(),0,recno())
    set order to it

    select nak
    otagnak=sys(21)
    orecnak=iif(eof(),0,recno())
    set order to id

    IF seek(m.idnak, "NAK", "ID")
        SELECT NAKC

*!*	 IF INLIST(NAK.TYPEDOC, '0205')
*!*	 SUSPEND
*!*	 ENDIF
        DO CASE
        CASE INLIST(m.whatdo, 0, 2)
        *нова€ или правка
            IF m.whatdo=0
                INSERT INTO NAKC (ID_NAK, ID_TOVAR, ID_TARA);
                          VALUES (m.idnak, m.idtov, m.idtar)
            ENDIF

            IF SEEK(BINTOC(m.idnak)+BINTOC(m.idtov)+BINTOC(m.idtar), "NAKC", "IT")
                *остатки
                IF m.glpereschet
		            lndeltkol=-m.KOL
		            lndeltkoljir=-m.KOLJIR
                ELSE
		            lndeltkol=NAKC.KOL-m.KOL
		            lndeltkoljir=NAKC.KOLJIR-m.KOLJIR
                ENDIF

                IF !SEEK(DTOS(NAK.DATE)+BINTOC(m.idtov)+BINTOC(m.idtar), "OST", "DATETOVAR")
	                INSERT INTO OST (DATE, ID_TOVAR, ID_TARA, ID_ORGAN);
	                		 VALUES (NAK.DATE, m.idtov, m.idtar, nak.id_organ)
                ENDIF
                
		        DO CASE
		        CASE LEFT(NAK.TYPEDOC, 2)='01'
		        *приход
		        	UPDATE OST SET PRIH=PRIH-m.lndeltkol, PRIHJIR=PRIHJIR-m.lndeltkoljir,;
		        				   KOLK=KOLK-m.lndeltkol, KOLKJIR=KOLKJIR-m.lndeltkoljir;
		        	WHERE DTOS(OST.DATE)+BINTOC(OST.ID_TOVAR)+BINTOC(OST.ID_TARA)=DTOS(NAK.DATE)+BINTOC(m.idtov)+BINTOC(m.idtar)
		        CASE LEFT(NAK.TYPEDOC, 2)='02'
		        *расход
                	IF (!INLIST(NAKC.ID_TOVAR, 2) AND INLIST(NAK.TYPEDOC, '0203')) OR (INLIST(NAKC.ID_TOVAR, 1, 2) AND INLIST(NAK.TYPEDOC, '0205'))
                	ELSE
			        	UPDATE OST SET RASH=RASH-m.lndeltkol, RASHJIR=RASHJIR-m.lndeltkoljir,;
			        				   KOLK=KOLK+m.lndeltkol, KOLKJIR=KOLKJIR+m.lndeltkoljir;
			        	WHERE DTOS(OST.DATE)+BINTOC(OST.ID_TOVAR)+BINTOC(OST.ID_TARA)=DTOS(NAK.DATE)+BINTOC(m.idtov)+BINTOC(m.idtar)
		        	ENDIF
		        ENDCASE

                IF m.kol<>0 OR m.koljir<>0
	                REPLACE KOL WITH m.kol, KOLJIR WITH m.koljir IN NAKC
	            ELSE
	            	DELETE IN NAKC
	            ENDIF
                *формируем накл с потер€ми(расход на производство, реализаци€) дл€ обезжир.молока
                IF (INLIST(NAK.TYPEDOC, '0202', '0204') AND (NAKC.ID_TOVAR=2)) OR;
                	(NAK.TYPEDOC='0202' AND NAKC.ID_TOVAR=1)
                    local nid,nnomer,ddate,kkol,kkoljir,orec,otag,orec1,otag1,fou

                    ddate=NAK.DATE

                    SELECT NAK
                    SET ORDER TO ID_PARNAK

                    DO CASE
                    CASE NAKC.ID_TOVAR=1
	                    DO CASE 
	                    CASE NAK.TYPEDOC='0202'
	                    *–асход
	                    	IF NAK.DATE>={^2007-09-01}
		                    	STORE 0 TO kkol, kkoljir
	                    	ELSE
		                    	DO CASE
		                    	CASE NAK.ID_ORGAN=2
		                    	*хоз€йствам
			                        kkol=ROUND(NAKC.KOL*0.0013, 0)
			                        kkoljir=ROUND(NAKC.KOLJIR*0.0013, 2)
		                    	CASE INLIST(NAK.ID_ORGAN, 0, 1) AND NAK.DATE>{^2007-07-31}
		                    	*ц\м консервный
			                        kkol=ROUND(NAKC.KOL*0.0028, 0)
			                        kkoljir=ROUND(NAKC.KOLJIR*0.0028, 2)
			                    OTHERWISE
			                    	STORE 0 TO kkol, kkoljir
		                    	ENDCASE
		                    ENDIF
	                    ENDCASE 
                    CASE NAKC.ID_TOVAR=2
	                    DO CASE 
	                    CASE NAK.TYPEDOC='0202'
	                    *–асход хоз€йствам
	                    	IF NAK.DATE>={^2007-09-01}
		                    	STORE 0 TO kkol, kkoljir
	                    	ELSE
		                    	DO CASE
		                    	CASE INLIST(NAK.ID_ORGAN, 0, 1) AND NAK.DATE>{^2007-07-31}
		                    	*ц\м консервный
			                        kkol=ROUND(NAKC.KOL*0.0028, 0)
			                        kkoljir=ROUND(m.kkol*0.0005, 2)
			                    OTHERWISE
			                        kkol=round(NAKC.KOL*0.0058, 0)
			                        kkoljir=round(m.kkol*0.0005, 2)
			                    OTHERWISE
			                    	STORE 0 TO kkol, kkoljir
		                    	ENDCASE
		                    ENDIF
	                    CASE NAK.TYPEDOC='0204' OR NAK.ID_ORGAN=1
	                    *–асход цельномолочному
	                        kkol=round(NAKC.KOL*0.0052,0)
*!*		                        kkoljir=nakc.koljir
	                        kkoljir=round(m.kkol*0.0005,2)
	                    OTHERWISE
	                    	STORE 0 TO kkol, kkoljir
	                    ENDCASE
	                ENDCASE

                    IF SEEK(m.idnak, "NAK", "ID_PARNAK")
                        SELECT NAKC
                        fou=.f.

                        IF SEEK(BINTOC(NAK.ID)+BINTOC(m.idtov)+BINTOC(m.idtar), "NAKC", "IT")
			                IF m.glpereschet
					            lndeltkol=-m.KKOL
					            lndeltkoljir=-m.KKOLJIR
			                ELSE
					            lndeltkol=NAKC.KOL-m.KKOL
					            lndeltkoljir=NAKC.KOLJIR-m.KKOLJIR
			                ENDIF

			                REPLACE KOL WITH m.kkol, KOLJIR WITH m.kkoljir IN NAKC
                        else
				            lndeltkol=m.KKOL
				            lndeltkoljir=m.KKOLJIR

                            INSERT INTO NAKC (ID_NAK,ID_TOVAR,ID_TARA,KOL,KOLJIR) VALUES (NAK.ID,m.idtov,m.idtar,m.kkol,m.kkoljir) &&молоко обезж
                        endif
                    ELSE
                        nid=newid('nak')
                        nnomer=newnmnak('02')

                        INSERT INTO NAK (ID,NOMER, DATE, TYPEDOC, ID_PARNAK);
                                    VALUES (m.nid, m.nnomer, m.ddate, '0205', m.idnak)
                        INSERT INTO NAKC (ID_NAK, ID_TOVAR, ID_TARA, KOL, KOLJIR);
                                     VALUES (m.nid, m.idtov, m.idtar, m.kkol, m.kkoljir) &&молоко обезж

			            lndeltkol=m.kkol
			            lndeltkoljir=m.kkoljir
                    ENDIF

	                IF !SEEK(DTOS(NAK.DATE)+BINTOC(m.idtov)+BINTOC(m.idtar), "OST", "DATETOVAR")
		                INSERT INTO OST (DATE, ID_TOVAR, ID_TARA, ID_ORGAN) VALUES (NAK.DATE, m.idtov, m.idtar, nak.id_organ)
	                ENDIF

			        DO CASE
			        CASE LEFT(NAK.TYPEDOC, 2)='01'
			        *приход
			        	UPDATE OST SET PRIH=PRIH-m.lndeltkol, PRIHJIR=PRIHJIR-m.lndeltkoljir,;
			        				   KOLK=KOLK-m.lndeltkol, KOLKJIR=KOLKJIR-m.lndeltkoljir;
			        	WHERE DTOS(OST.DATE)+BINTOC(OST.ID_TOVAR)+BINTOC(OST.ID_TARA)=DTOS(NAK.DATE)+BINTOC(m.idtov)+BINTOC(m.idtar)
			        CASE LEFT(NAK.TYPEDOC, 2)='02'
			        *расход
			        	IF INLIST(NAKC.ID_TOVAR, 1, 2) AND INLIST(NAK.TYPEDOC, '0205')
			        	ELSE
				        	UPDATE OST SET RASH=RASH-m.lndeltkol, RASHJIR=RASHJIR-m.lndeltkoljir,;
				        				   KOLK=KOLK+m.lndeltkol, KOLKJIR=KOLKJIR+m.lndeltkoljir;
				        	WHERE DTOS(OST.DATE)+BINTOC(OST.ID_TOVAR)+BINTOC(OST.ID_TARA)=DTOS(NAK.DATE)+BINTOC(m.idtov)+BINTOC(m.idtar)
				        ENDIF
			        ENDCASE
                ENDIF
            ENDIF
        case m.whatdo=1
        *удаление
            if SEEK(BINTOC(m.idnak)+BINTOC(m.idtov)+BINTOC(m.idtar), "NAKC", "IT")
                *остатки
                if !SEEK(DTOS(NAK.DATE)+BINTOC(m.idtov)+BINTOC(m.idtar), "OST", "DATETOVAR")
	                INSERT INTO OST (DATE, ID_TOVAR, ID_TARA, ID_ORGAN);
	                		 VALUES (NAK.DATE, m.idtov, m.idtar, m.idor)
                endif

		        DO CASE
		        CASE LEFT(NAK.TYPEDOC, 2)='01'
		        *приход
		        	UPDATE OST SET PRIH=PRIH-NAKC.KOL, PRIHJIR=PRIHJIR-NAKC.KOLJIR,;
		        				   KOLK=KOLK-NAKC.KOL, KOLKJIR=KOLKJIR-NAKC.KOLJIR;
		        	WHERE DTOS(OST.DATE)+BINTOC(OST.ID_TOVAR)+BINTOC(OST.ID_TARA)=DTOS(NAK.DATE)+BINTOC(m.idtov)+BINTOC(m.idtar)
		        CASE LEFT(NAK.TYPEDOC, 2)='02'
		        *расход
		        	UPDATE OST SET RASH=RASH-NAKC.KOL, RASHJIR=RASHJIR-NAKC.KOLJIR,;
		        				   KOLK=KOLK+NAKC.KOL, KOLKJIR=KOLKJIR+NAKC.KOLJIR;
		        	WHERE DTOS(OST.DATE)+BINTOC(OST.ID_TOVAR)+BINTOC(OST.ID_TARA)=DTOS(NAK.DATE)+BINTOC(m.idtov)+BINTOC(m.idtar)
		        ENDCASE

                DELETE IN NAKC

                *удалить порожденные накладные с потер€ми(расход на производство, реализаци€) молоко обезж
                IF ((NAK.TYPEDOC='0202' OR NAK.TYPEDOC='0204') AND NAKC.ID_TOVAR=2) OR;
                	((NAK.TYPEDOC='0202') AND NAKC.ID_TOVAR=1)
                    IF SEEK(m.idnak, "NAK", "ID_PARNAK")
                        SELECT NAKC

				        SCAN FOR BINTOC(ID_NAK)+BINTOC(ID_TOVAR)+BINTOC(ID_TARA)=BINTOC(NAK.ID)
                            DO chnakl WITH 1, NAK.ID, NAKC.ID_TOVAR, NAKC.ID_TARA
                        ENDSCAN

                        DELETE IN NAK
                    ENDIF
                    
                    =SEEK(m.idnak, "NAK", "ID")
                    =SEEK(BINTOC(m.idnak)+BINTOC(m.idtov)+BINTOC(m.idtar), "NAKC", "IT")
                ENDIF
            ENDIF
        ENDCASE

		*расчитать остатки на начало и конец
		SET ORDER TO DATETOVAR IN OST
		GO BOTTOM IN OST

		IF !EOF("OST")
		    lddate=OST.DATE
		ELSE
		    lddate={^0001.01.01}
		ENDIF

	    ldI=NAK.DATE-1
	    
	    DO WHILE m.ldI<=m.lddate
	    	*перенести нач.остатки с предыдущего мес€ца
            IF DTOS(OST.DATE)+BINTOC(OST.ID_TOVAR)+BINTOC(OST.ID_TARA)=DTOS(m.ldI-1)+BINTOC(m.idtov)+BINTOC(m.idtar) OR;
               SEEK(DTOS(m.ldI-1)+BINTOC(m.idtov)+BINTOC(m.idtar), "OST", "DATETOVAR")
            	lnkoln=OST.KOLK
            	lnkolnjir=OST.KOLKJIR
            ELSE
            	lnkoln=0
            	lnkolnjir=0
            ENDIF

            IF !(DTOS(OST.DATE)+BINTOC(OST.ID_TOVAR)+BINTOC(OST.ID_TARA)=DTOS(m.ldI)+BINTOC(m.idtov)+BINTOC(m.idtar) OR;
               SEEK(DTOS(m.ldI)+BINTOC(m.idtov)+BINTOC(m.idtar), "OST", "DATETOVAR"))
                INSERT INTO OST (DATE, ID_TOVAR, ID_TARA) VALUES (m.ldI, m.idtov, m.idtar)
            ENDIF

			UPDATE OST SET KOLN=m.lnkoln, KOLNJIR=m.lnkolnjir,;
						   KOLK=KOLN+PRIH-RASH, KOLKJIR=KOLNJIR+PRIHJIR-RASHJIR;
			WHERE DTOS(DATE)+BINTOC(ID_TOVAR)+BINTOC(ID_TARA)=DTOS(m.ldI)+BINTOC(m.idtov)+BINTOC(m.idtar)

	        ldI=m.ldI+1
	    ENDDO
    ENDIF

    IF m.whatdo=1
        =SEEK(m.idnak, "NAK", "ID")
    ELSE
        IF m.orecnak<>0
            GO m.orecnak IN NAK
        ELSE
            GO BOTTOM IN NAK
        ENDIF
    ENDIF

    SET ORDER TO &otagnak IN NAK

    IF m.whatdo=1
    	=SEEK(BINTOC(m.idnak)+BINTOC(m.idtov)+BINTOC(m.idtar), "NAKC", "IT")
    ELSE 
        IF m.orecnakc<>0
            GO m.orecnakc IN NAKC
        ELSE
            GO BOTTOM IN NAKC
        ENDIF
    ENDIF

    SET ORDER TO &otagnakc IN NAKC

    SELECT (m.osel)
RETURN