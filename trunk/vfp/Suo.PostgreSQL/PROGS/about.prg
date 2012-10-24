LOCAL lnElem, lcVer
LOCAL ARRAY laFile[1]
	lnElem=AGETFILEVERSION(laFile, "suo.exe")
	IF m.lnElem>0
		lcVer=laFile(4)
	ELSE
		lcVer='Not found EXE!'
	ENDIF
	*
	LOCAL loForm as Form
	loForm=NewObject("aboutbox","aboutbox","",;
					 m.goApp.Vars.cTaskCaption+CHR(169), m.lcVer, "All Rights Reserved", "Copyright"+CHR(169)+" 2004-2006 Козлитин В.А.", "..\bmp\infernus.gif")
	*
	IF VARTYPE(m.loForm)#"O"
		RETURN
	ENDIF
	*
	loForm.Applications_pageframe.Base_page1.lblUserName.Caption=""
	loForm.Applications_pageframe.Base_page1.lblUserCorp.Caption="GNU"
	m.loForm.Show()