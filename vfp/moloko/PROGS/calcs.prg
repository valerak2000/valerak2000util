LPARAMETERS tlCalcOst
local koln,kolnjir,kolnsuh,prih,prihjir,prihsuh,rash,rashjir,rashsuh,kolk,kolkjir,kolksuh,month,id_tovar,id_tara,orec
	setEnvir()
	SetBase()

	IF !USED('typedoc')
		OPENTABLE(m.basep+'typedoc.dbf', 'typedoc', .t.)
	ENDIF
	*������ ���������
	glpereschet=.t.
	begdate=flt.date1
	enddate=flt.date2

	select edizm
	set order to id
	select sp
	set order to id_pro

    WAIT WINDOW "���� ������������� ��������..." NOWAIT
	*�������� ������ �� ��������
	UPDATE OST SET KOLN=0, KOLNJIR=0, KOLNSUH=0, PRIH=0, PRIHJIR=0, PRIHSUH=0, RASH=0, RASHJIR=0, RASHSUH=0, KOLK=0, KOLKJIR=0, KOLKSUH=0;
	WHERE BETWEEN(DATE, m.begdate, m.enddate)
	
	SELECT ID_TOVAR, ID_TARA, KOLK, KOLKJIR, KOLKSUH;
	FROM OST INTO CURSOR ost_beg;
	WHERE DATE=m.begdate-1
	
	SELECT OST_BEG

	SCAN 
		IF SEEK(DTOS(m.begdate)+BINTOC(OST_BEG.ID_TOVAR)+BINTOC(OST_BEG.ID_TARA), "OST", "DATETOVAR")
			UPDATE OST SET KOLN=OST_BEG.KOLK, KOLNJIR=OST_BEG.KOLKJIR, KOLNSUH=OST_BEG.KOLKSUH,;
						   KOLK=OST_BEG.KOLK, KOLKJIR=OST_BEG.KOLKJIR, KOLKSUH=OST_BEG.KOLKSUH;
			WHERE DTOS(DATE)+BINTOC(ID_TOVAR)+BINTOC(ID_TARA)=DTOS(m.begdate)+BINTOC(OST_BEG.ID_TOVAR)+BINTOC(OST_BEG.ID_TARA)
		ELSE
            INSERT INTO OST (DATE, ID_TOVAR, ID_TARA, KOLN, KOLNJIR, KOLNSUH, KOLK, KOLKJIR, KOLKSUH);
            		 VALUES (m.begdate, OST_BEG.ID_TOVAR, OST_BEG.ID_TARA,;
            		 		 OST_BEG.KOLK, OST_BEG.KOLKJIR, OST_BEG.KOLKSUH,;
            		 		 OST_BEG.KOLK, OST_BEG.KOLKJIR, OST_BEG.KOLKSUH)
		ENDIF

		ldI=m.begdate

	    DO WHILE m.ldI<=m.enddate
	    	*��������� ���.������� � ����������� ������
	        IF DTOS(OST.DATE)+BINTOC(OST.ID_TOVAR)+BINTOC(OST.ID_TARA)=DTOS(m.ldI-1)+BINTOC(OST_BEG.ID_TOVAR)+BINTOC(OST_BEG.ID_TARA) OR;
	           SEEK(DTOS(m.ldI-1)+BINTOC(OST_BEG.ID_TOVAR)+BINTOC(OST_BEG.ID_TARA), "OST", "DATETOVAR")
	        	lnkoln=OST.KOLK
	        	lnkolnjir=OST.KOLKJIR
	        	lnkolnsuh=OST.KOLKSUH
	        ELSE
	        	lnkoln=0
	        	lnkolnjir=0
	        	lnkolnsuh=0
	        ENDIF

	        IF !(DTOS(OST.DATE)+BINTOC(OST.ID_TOVAR)+BINTOC(OST.ID_TARA)=DTOS(m.ldI)+BINTOC(OST_BEG.ID_TOVAR)+BINTOC(OST_BEG.ID_TARA) OR;
	           SEEK(DTOS(m.ldI)+BINTOC(OST_BEG.ID_TOVAR)+BINTOC(OST_BEG.ID_TARA), "OST", "DATETOVAR"))
	            INSERT INTO OST (DATE, ID_TOVAR, ID_TARA);
	            		 VALUES (m.ldI, OST_BEG.ID_TOVAR, OST_BEG.ID_TARA)
	        ENDIF

			UPDATE OST SET KOLN=m.lnkoln, KOLNJIR=m.lnkolnjir, KOLNSUH=m.lnkolnsuh,;
						   KOLK=m.lnkoln, KOLKJIR=m.lnkolnjir, KOLKSUH=m.lnkolnsuh;
			WHERE DTOS(DATE)+BINTOC(ID_TOVAR)+BINTOC(ID_TARA)=DTOS(m.ldI)+BINTOC(OST_BEG.ID_TOVAR)+BINTOC(OST_BEG.ID_TARA)

	        ldI=m.ldI+1
	    ENDDO
	ENDSCAN

	USE IN OST_BEG

	IF !m.tlCalcOst
		SELECT PAS
		SET ORDER TO DATE
		SET RELA TO ID_PRO INTO SP, ID_TARA INTO EDIZM ADDI

		seek dtos(flt.date1)

		scan while date<=flt.date2
		    WAIT WINDOW "���� ���������� �������� �"+PAS.NOMER+" �� "+DTOC(PAS.DATE)+" "+PAS.ID_PRO NOWAIT

		    do case
		    case pas.id_pro='001'
		    *����� �������� ������
		        do rashet_pas1 with id
		    case pas.id_pro='002'
		    *�������������
		        do rashet_pas2 with id
		    case pas.id_pro='003'
		    *����� ����
		        do rashet_pas3 with id
			CASE pas.id_pro='004'
				DO rashet_pas4 WITH id
		    case pas.id_pro='005'
		    *����� ����
		        do rashet_pas3 with id
		    case pas.id_pro='006'
		    *���������
		        do rashet_pas6 with id
		    case pas.id_pro='007'
		    *��������� ���������
		        do rashet_pas6 with id
		    case pas.id_pro='008'
		    *���������
		        do rashet_pas6 with id, .t.
			case pas.id_pro='009'
			*��������� ��������� 90
			    do rashet_pas6 with id, .t.
			case pas.id_pro='010'
			*��������� ��������� 50
			    do rashet_pas6 with id, .t.
			case pas.id_pro='011'
			*��������� ��������� 20 �����
			    do rashet_pas6 with id, .t.
			case pas.id_pro='012'
			*��������� ��������� 20
			    do rashet_pas6 with id, .t.
			case pas.id_pro='013'
			*��������� �������� ��������� 20%
			    do rashet_pas6 with id, .t.
			case pas.id_pro='014'
			*��������� �������� ��� 50% ���� ���                                                                 
			    do rashet_pas6 with id, .t.
			case pas.id_pro='015'
			*��������� �������� ������������ ��� 70% ���
			    do rashet_pas6 with id, .t.
			case pas.id_pro='016'
			*��������� �������� ������������ ��� 90%
			    do rashet_pas6 with id, .t.
			case pas.id_pro='017'
			*��������� ��������� �����                                                             
			    do rashet_pas6 with id, .t.
		    ENDCASE
		endscan
	ENDIF

	*������ �������/������� �� ������ �� ���������
    SELECT NAK
    SET ORDER TO DATE
    SEEK m.begdate

    SCAN WHILE NAK.DATE<=m.enddate
   		IF m.tlCalcOst OR (!m.tlCalcOst AND NAK.ID_PAS=0 AND NAK.ID_PARNAK=0)
	        SELECT NAKC

	        SCAN FOR BINTOC(ID_NAK)+BINTOC(ID_TOVAR)+BINTOC(ID_TARA)=BINTOC(NAK.ID)
	            *���������� �������
*!*	IF NAK.DATE={^2007-07-01} and ID_TARA=5
*!*		SUSPEND
*!*	ENDIF
			    WAIT WINDOW "���� ���������� ��������� �"+NAK.NOMER+" �� "+DTOC(NAK.DATE) NOWAIT
			    
		        =chnakl(2, NAK.ID, NAKC.ID_TOVAR, NAKC.ID_TARA, NAK.ID_ORGAN, NAKC.KOL, NAKC.KOLJIR, NAKC.KOLSUH) &&���������� �������
	        ENDSCAN
    	ENDIF
    ENDSCAN

	glpereschet=.f.

	CLOSE DATABASES ALL
	
	WAIT CLEAR