PARAMETERS s1
	IF s1='BEGIN'
		SELECT ID, COMMENT FROM PRODUCTION INTO CURSOR SEL_PRO;
		WHERE ID_TOVAR=0;
		ORDER BY 2
	ELSE
		USE IN SEL_PRO
	ENDIF
