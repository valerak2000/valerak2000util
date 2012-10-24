*!*	PROCEDURE closeBase
*!*	PRIVATE maxals,i
	CLOSE DATABASES ALL
*!*		maxals=SELECT(1)
*!*		FOR i=maxals TO 1 STEP -1
*!*			IF !EMPTY(ALIAS(i))
*!*				USE IN ALIAS(i)
*!*			ENDIF 
*!*		ENDFOR 
RETURN