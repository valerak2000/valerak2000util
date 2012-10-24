DEFINE CLASS base_session AS Session
	Name = "base_session"
	DataSession = 2

	PROCEDURE Init
		m.goApp.setEnvironment(THIS.DataSessionId)
	ENDPROC
ENDDEFINE