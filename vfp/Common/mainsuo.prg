PARAMETERS tcUserName as String, tcUserPassword as String, tv3, tv4, tv5, tv6, tv7, tv8
#INCLUDE "..\LIB.9\BASE_APP.H"
#INCLUDE ".\INCLUDE\SUO.H"
#IFNDEF _MAGISTR_MODE
	#DEFINE _MAGISTR_MODE .F.
#ENDIF
#IFNDEF _PRINT_MODE
	#DEFINE _PRINT_MODE .F.
#ENDIF
	IF _VFP.StartMode = 0
		SET PATH TO .\PROGS, .\MENUS, .\FORMS, .\LIBS, ..\LIB.9, ..\LIB.9\CTL32, ..\COMMON,;
					.\INCLUDE, ..\BMP, ..\LIB, ..\LIB.OLD, ..\BMP.OLD,;
					c:\Program Files\Microsoft Visual FoxPro 9\Tools\cpzero
		#IF _MAGISTR_MODE
			SET PATH TO "..\Magistr_Common" ADDITIVE
		#ENDIF
		#IF _PRINT_MODE
			SET PATH TO "..\CodePlexWorkCopy\VFP9\Tools\XSource\ReportPreview" ADDITIVE
*!*				SET PATH TO "..\LIB.9\ReportSculptor" ADDITIVE
		#ENDIF
	ENDIF
*!*	#IF FILE(".\INCLUDE\" + APP_OBJ_NAME_QUOTED + ".H")
*!*		lcInc = ".\INCLUDE\" + APP_OBJ_NAME_QUOTED + ".H"

*!*		#INSERT (".\INCLUDE\" + APP_OBJ_NAME_QUOTED + ".H")
*!*	*!*		#INSERT (m.lcInc)
*!*	#ENDIF

	SET CLASSLIB TO base_gui, standart_dictionary_form, xml_ini, PolCld, base_idb, softpole, _gdiplus,;
					APP_OBJ_NAME, base_app, sftoolbar, sfmenu_app, ctl32, vfpx
#IF _PRINT_MODE
	*подключить report_listener
	SET CLASSLIB TO "..\CodePlexWorkCopy\VFP9\ffc\_ReportListener" ADDITIVE
	SET CLASSLIB TO "..\CodePlexWorkCopy\VFP9\Tools\XSource\ReportPreview\frxpreview" ADDITIVE
*!*		SET PROCEDURE TO "..\LIB.9\ReportSculptor\ReportSculptor\MYRS.PRG" ADDITIVE
*!*		SET CLASSLIB TO "..\LIB.9\ReportSculptor\ReportSculptor" ADDITIVE
*!*		*********************** RS / GDI+X Initialisation Sequence ********************************
*!*		LOCAL lcRSServerFolder, lcGdiPlusX
*!*		lcRSServerFolder = IIF(_VFP.StartMode = 0, "..\LIB.9\", JUSTPATH(SYS(16, 1))) + "\rsServer" &&supply proper path

*!*		DO (ADDBS(m.lcRSServerFolder) + "ReportSculptor.App")
*!*		***Now we also enable GdiPlusX application supplied in subfolder of rsServer.
*!*		***(system_lean.app can be kept elsewhere, but make sure version is 1.20 with EMF support!)
*!*		lcGdiPlusX = ADDBS(m._oRSGO.RS_Root) + "GdiPlusX\system_lean.app"
*!*		DO (m.lcGdiPlusX)
	*********************************************************************************************!*	
#ENDIF
#IF _MAGISTR_MODE
	SET CLASSLIB TO BASECLAS, CONTROLS, MODIFICATORS, IFACES ADDITIVE
#ENDIF

	IF _VFP.StartMode = 0
		SET MESSAGE TO 
		SET BELL OFF 
		*почему-то в другой датасессии не меняется
		SET ECHO OFF
	ELSE
		SET SYSMENU OFF
	ENDIF

	SET PROCEDURE TO MainSUO ADDITIVE

	PUBLIC goApp as base_app OF ..\lib.9\base_app
	LOCAL loExc as Exception
#IF !_DEVELOP_MODE
	TRY
#ENDIF
		ON SHUTDOWN DO isExit
		*Выполнить проверку обновления версии
		*Инициализация глобального объекта
*!*			goApp = NEWOBJECT(APP_OBJ_NAME_QUOTED, ".\libs\"+APP_OBJ_NAME_QUOTED+".PRG", '', APP_OBJ_NAME_QUOTED, APP_NAME_QUOTED)
		goApp = NEWOBJECT(APP_OBJ_NAME_QUOTED, ".\LIBS\" + APP_OBJ_NAME_QUOTED, '', APP_OBJ_NAME_QUOTED,;
						  APP_NAME_QUOTED)

#IF _PRINT_MODE
		goApp.oVars.lTaskBar = .F.
#ENDIF
		m.goApp.go(m.tcUserName, m.tcUserPassword, m.tv3, m.tv4, m.tv5, m.tv6, m.tv7, m.tv8)
#IF !_DEVELOP_MODE
	CATCH TO loExc
		MESSAGEBOX("Error: " + LTRIM(TRANSFORM(m.loExc.ErrorNo)) + CRLF;
				   + "Procedure: " + m.loExc.Procedure + CRLF;
				   + "LineNo: " + LTRIM(TRANSFORM(m.loExc.LineNo)) + " LineContent: " + m.loExc.LineContents + CRLF;
				   + "Message: " + m.loExc.Message + CRLF;
				   + "Details: " + m.loExc.Details + CRLF;
				   + SYS(2018), 48, "Load program")
	ENDTRY
#ENDIF
	ON SHUTDOWN

	DO ..\common\isExit
*!*gcAppName as String, gcTaskName as String,
*!*	llAppRan=.F.
*!*	IF VARTYPE(m.goApp)="O"
*!*		IF NOT m.goApp.Show()
*!*		  	IF TYPE("m.goApp.Name")="C"
*!*		    	MESSAGEBOX(APP_CANNOT_RUN_LOC, 16, m.goApp.oVars.cCaption)
*!*		    	m.goApp.Release()
*!*			ELSE
*!*				MESSAGEBOX(APP_CANNOT_RUN_LOC, 16)
*!*			ENDIF
*!*		ELSE
*!*			llAppRan=.T.
*!*		ENDIF
*!*
*!*		IF TYPE("m.goApp.oVars.lReadEvents")="L"
*!*	    	IF m.goApp.oVars.lReadEvents
*!*	         * the Release() method was not used
*!*	         * but we've somehow gotten out of READ EVENTS...
*!*	        	m.goApp.Release()
*!*	      	ENDIF
*!*		ELSE
*!*			RELEASE m.goApp
*!*		ENDIF
*!*	ELSE
*!*		MESSAGEBOX(APP_WRONG_SUPERCLASS_LOC, 16)
*!*		RELEASE m.goApp
*!*	ENDIF
*!*
*!*	IF TYPE("m.goApp")="O"
*!*	   * non-read events app
*!*		RETURN m.goApp
*!*	ELSE
*!*		RETURN llAppRan
*!*	ENDIF   
