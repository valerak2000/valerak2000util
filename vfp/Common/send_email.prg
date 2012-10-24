LPARAMETERS tcRecipients, tcSubject, tcMessage, tcAttachment
LOCAL loPop3 as Object, loIP as Object, lnErr as Integer
	lnErr = 1
	loPop3 = NEWOBJECT("wwPOP3", "wwPOP3.prg")
	
	IF NOT (VARTYPE(m.loPop3) = "O" AND !ISNULL(m.loPop3))
		m.goApp.showMsg(DATETIME() + ':' + "Ошибка инициализации POP3 клиента")
	ELSE
		loPop3.nTimeout = 15    && Seconds
		loPop3.nBufferSize = 1024
		
*!*			loPop3.cMailServer = m.goApp.oVars.oCurrentTask.oVars.csmtp_host &&"192.168.210.251"
*!*			loPop3.cUserName = m.goApp.oVars.oCurrentTask.oVars.cpop3_log &&"Sales_report@transasia.ru"
*!*			loPop3.cPassword = m.goApp.oVars.oCurrentTask.oVars.cpop3_pwd &&"123456"

*!*			IF !m.loPop3.Connect()
*!*			*возврат, если нет соединения
*!*				m.goApp.showMsg("Ошибка авторизации " + m.loPop3.cErrorMsg)
*!*				m.goApp.oFunction.writeLog("Ошибка авторизации " + m.loPop3.cErrorMsg)
*!*			ELSE 
			m.goApp.showMsg("отправка сообщения:" + m.tcRecipients)

			loIP = NEWOBJECT("wwIpStuff", "wwIpStuff.vcx")

			loIP.cMailServer = m.goApp.oVars.oCurrentTask.oVars.csmtp_host
			loIP.cSenderName = m.goApp.oVars.oCurrentTask.oVars.cpop3_log
			loIP.cSenderEmail = m.goApp.oVars.oCurrentTask.oVars.cpop3_log
			loIP.cRecipient = CHRTRAN(CHRTRAN(m.tcRecipients, ';', ','), ' ', '') &&
			loIP.cSubject = m.tcSubject &&
			loIP.cMessage = m.tcMessage &&
			loIP.cAttachment = m.tcAttachment
*!*				loIP.cContentType = 'text/plain;charset = "windows-1251"'

			IF !m.loIP.sendMail() 
				m.goApp.oFunction.writeLog("SEND_EMAIL:Error " + m.loIP.cErrorMsg + " Email " + m.loIP.cRecipient)
			ELSE
				lnErr = 0
			ENDIF
*!*			ENDIF
	ENDIF
RETURN m.lnErr

