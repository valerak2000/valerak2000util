#INCLUDE "..\lib.9\base_app.h"
*завернуть экспорт на ДЦ и реестр
LPARAMETERS tcFileZip, tcFiles, tc7zPath
	IF FILE(m.goApp.oVars.cAppCurPaths + "7z.exe")
		LOCAL loShell as Object
		*создание архива
#IF !_DEVELOP_MODE
		TRY
#ENDIF
			tcFileZip = FORCEEXT(m.tcFileZip, "ZIP")
			DELETE FILE (m.tcFileZip)

			loShell = CREATEOBJECT("WScript.Shell")
			loShell.Run('"' + m.goApp.oVars.cAppCurPaths + '7z.exe" a -tzip ' + m.tcFileZip + ' ';
						+ m.tcFiles, 0, .T.)
			RELEASE loShell
#IF !_DEVELOP_MODE
		CATCH TO loExc
			m.goApp.oFunction.showErrMsg(m.loExc)
		ENDTRY
#ENDIF
	ENDIF