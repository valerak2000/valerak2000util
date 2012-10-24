PARAMETERS s1
PRIVATE otag
*
DO CASE 
CASE s1='BEGIN'
*!*		select to
*!*		if m.idtov#0
*!*			otag=sys(21)
*!*			set order to id
*!*			seek m.idtov
*!*			set order to &otag
*!*		endif
CASE s1='END'
ENDCASE