LOCAL lcFileZip, lcFiles 
	lcFileZip = ".\arhiv\moloko"+ TTOC(DATETIME(), 1) + ".zip"

	IF mkZip(m.lcFileZip, m.goApp.oVars.oCurrentTask.oVars.cDBPath + "*.*")
		m.goApp.showMsg("��������� ��������� �������! ���� - " + m.lcFileZip)
	ENDIF
