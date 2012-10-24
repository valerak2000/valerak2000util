LPARAMETERS tdDatem, tcTimem
RETURN INT((m.tdDatem - {^1980-01-01}) * 86400;
	   + VAL(LEFT(m.tcTimem, 2)) * 3600 + VAL(SUBSTR(m.tcTimem, 4, 2)) * 60 + VAL(RIGHT(m.tcTimem, 2)))