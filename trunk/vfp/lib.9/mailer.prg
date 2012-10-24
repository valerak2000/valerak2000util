*****************************************************************************
* Mailer.prg
* ����� �������� ����� ����� SMTP-������ � ���������� ����������� (���� ��� TLS)
* ������� ��� VFP 9 � �������������� ��������� ���� ������
*
* �����: ���������� ���������
* Email: cos@inbox.ru
*
* � ������ ��� ����������� ������ ������� �������� (MS WinSock control � SMTP)
* � ������ �������������� ���������:
* RFC-2821, RFC-2822, RFC-2046, RFC-1521, RFC-1522, RFC-2104, RFC-1869, RFC-2554,
* RFC-1321, RFC-2195
*
* ������ �������������:
*	oSMTP=NEWOBJECT("mailer","mailer.prg")
*
*	* ������������ ��������
*	oSMTP.RemoteHost="smtp.mail.ru"
*
*	* ������������ ��������
*	oSMTP.RemotePort=25
*
*	* �������������� ��������
*	oSMTP.SenderName="������ ���� ��������"
*
*	* ������������ ��������
*	oSMTP.MailFrom="user@company.org"
*
*	* ������������ ��������. ����� ������������ ��������� �������
*	* ���������� �������� ";"
*	oSMTP.MailTo="another_user@company.org"
*
*	* �������������� ��������. ����� ������������ ��������� �������
*	* ���������� �������� ";"
*	oSMTP.MailCC="cc_user@company.org"
*
*	* �������������� ��������. ����� ������������ ��������� �������
*	* ���������� �������� ";"
*	oSMTP.MailBCC="bcc_user@company.org"
*
*	* �������������� ��������
*	oSMTP.MailReplyTo="user@company.org"
*
*	* �������������� ��������
*	oSMTP.MailSubject="���� ������"
*
*	* �������������� ��������
*	oSMTP.MailText="���� ������"
*
*	* ���� SMTP-������ ������� �����������
*	oSMTP.SmtpLogin="UserLogin"
*	oSMTP.SmtpPwd="UserPassword"
*
*	* ���� ���������� �������� ������� ��������� ������
*	DIMENSION aFiles[2]
*	aFiles[1]="file1.ext"
*	aFiles[2]="file2.ext"
*
*	* ��� ����� �������� ������ � ������ �����
*	cAttach="file1.ext"
*
*	* ����� ��� �������� �������
*	lRetVal=oSMTP.SendMessage()
*
*	* ����� � ��������� ������� � ������� ������
*	lRetVal=oSMTP.SendMessage(,,,,,,@aFiles)
*
*	* ����� � ��������� ������ � ������ �����
*	lRetVal=oSMTP.SendMessage(,,,,,,cAttach)
*
*****************************************************************************

*us-ascii"/ "iso-8859-1"/ "iso-8859-2"/ "iso-8859-3"
*          / "iso-8859-4"/ "iso-8859-5"/ "iso-8859-6"/ "iso-8859-7"
*          / "iso-8859-8" / "iso-8859-9
          
#DEFINE CRLF		CHR(13)+CHR(10)

DEFINE CLASS Mailer AS HYPERLINK
	PROTECTED Caption,UseAuth,Use8bit,AuthType &&,WinSock
	HIDDEN AllowedHeaderChars,AllowedBodyChars
	PROTECTED ADDPROPERTY,SAVEASCLASS,RESETTODEFAULT,READMETHOD,WRITEMETHOD
	PROTECTED READEXPRESSION,WRITEEXPRESSION
	PROTECTED APPLICATION,COMMENT,TAG,GOBACK,GOFORWARD,NAVIGATETO
	
	* ��������� ��� ���-�����
	Caption="�����"
	
	* ��� ���-�����, � ������� ������������ ����������
	* �� SMTP-������ ������� � ��� ������
	LogFile="mailer.log"
	
	* ����������� ������� � ��������� ������
	AllowedHeaderChars=""
	* ����������� ������� � ���� ������
	AllowedBodyChars=""
	
	* ��������������� ��������� ����, ������������ � ��������� ������
	FormattedTimeZone=""
	
	* DNS ��� SMTP-�������
	RemoteDomainName=""
	* SMTP-������, �� ������� ��������� ������� ������ ������������
	RemoteHost=""
	* ���� SMTP-�������
	RemotePort=25
	
	* ��� �����������, ������� ����� ��������� � ������������ ������
	SenderName=""
	* ����������� ����� �����������
	MailFrom=""
	* ����������� ����� ����������. �������� �����
	* ��������� ��������� �������, ���������� �������� ";"
	MailTo=""
	* ����������� �����, ���� ����� ���������� ����� ������.
	* �������� ����� ��������� ��������� �������, ���������� �������� ";"
	MailCC=""
	* ����������� �����, ���� ����� ���������� ������� ����� ������.
	* �������� ����� ��������� ��������� �������, ���������� �������� ";"
	MailBCC=""
	* ����������� �����, �� ������� ����� ������� �����. ����
	* ��� �������� ������, ����� ����� ��������� �� MailFrom
	MailReplyTo=""
	* ���� ������
	MailSubject=""
	* ����� ������
	MailText=""
	
	* ����� �������� �������� ������ ��� �������� ����� ���������
	* ���������� ������������� ������������� ������
	MessageID=""
	
	* ��������� ������
	Priority=3
	
	* ������� ������ ����������� ������. ��� �������� �����������
	* ������ �����, ����� SMTP-������ ������� �����������
	SmtpLogin=""
	* ������. ��� �������� ����������� ������ �����,
	* ����� SMTP-������ ������� �����������
	SmtpPwd=""
	
	* ��������� ����������
	ResultStr=""
	* ��� ������ ����������
	ResultCode=0
	
	* �� ��������� 1 ������ (���� RFC-2821 4.5.3.2 Timeouts ����������� 5 �����)
	TimeToOut=1*60
	
	* ������������ �������� ����������� (��������: PLAIN, LOGIN, CRAM-MD5, DIGEST-MD5)
	AuthType="CRAM-MD5"
	UseAuth=.F.
	Use8bit=.F.
	
	WinSock=.NULL.
	
	Version="1.0 alfa 3"
	
	_memberdata=[<VFPData><memberdata name="caption" type="property" display="Caption"/>]+ ;
		[<memberdata name="logfile" type="property" display="LogFile"/>]+ ;
		[<memberdata name="allowedheaderchars" type="property" display="AllowedHeaderChars"/>]+ ;
		[<memberdata name="allowedbodychars" type="property" display="AllowedBodyChars"/>]+ ;
		[<memberdata name="formattedtimezone" type="property" display="FormattedTimeZone"/>]+ ;
		[<memberdata name="remotedomainname" type="property" display="RemoteDomainName"/>]+ ;
		[<memberdata name="remotehost" type="property" display="RemoteHost"/>]+ ;
		[<memberdata name="remoteport" type="property" display="RemotePort"/>]+ ;
		[<memberdata name="sendername" type="property" display="SenderName"/>]+ ;
		[<memberdata name="mailfrom" type="property" display="MailFrom"/>]+ ;
		[<memberdata name="mailto" type="property" display="MailTo"/>]+ ;
		[<memberdata name="mailcc" type="property" display="MailCC"/>]+ ;
		[<memberdata name="mailbcc" type="property" display="MailBCC"/>]+ ;
		[<memberdata name="mailreplyto" type="property" display="MailReplyTo"/>]+ ;
		[<memberdata name="mailsubject" type="property" display="MailSubject"/>]+ ;
		[<memberdata name="mailtext" type="property" display="MailText"/>]+ ;
		[<memberdata name="messageid" type="property" display="MessageID"/>]+ ;
		[<memberdata name="priority" type="property" display="Priority"/>]+ ;
		[<memberdata name="smtplogin" type="property" display="SmtpLogin"/>]+ ;
		[<memberdata name="smtppwd" type="property" display="SmtpPwd"/>]+ ;
		[<memberdata name="resultstr" type="property" display="ResultStr"/>]+ ;
		[<memberdata name="resultcode" type="property" display="ResultCode"/>]+ ;
		[<memberdata name="timetoout" type="property" display="TimeToOut"/>]+ ;
		[<memberdata name="authtype" type="property" display="AuthType"/>]+ ;
		[<memberdata name="useauth" type="property" display="UseAuth"/>]+ ;
		[<memberdata name="use8bit" type="property" display="Use8bit"/>]+ ;
		[<memberdata name="winsock" type="property" display="WinSock"/>]+ ;
		[<memberdata name="version" type="property" display="Version"/>]+ ;
		[<memberdata name="getformattedtimezone" type="method" display="GetFormattedTimeZone"/>]+ ;
		[<memberdata name="getformattedemaildate" type="method" display="GetFormattedEmailDate"/>]+ ;
		[<memberdata name="resolvehostname" type="method" display="ResolveHostName"/>]+ ;
		[<memberdata name="connect" type="method" display="Connect"/>]+ ;
		[<memberdata name="disconnect" type="method" display="DisConnect"/>]+ ;
		[<memberdata name="senddata" type="method" display="SendData"/>]+ ;
		[<memberdata name="authdigestmd5" type="method" display="AuthDigestMd5"/>]+ ;
		[<memberdata name="authcrammd5" type="method" display="AuthCramMd5"/>]+ ;
		[<memberdata name="authplain" type="method" display="AuthPlain"/>]+ ;
		[<memberdata name="authloginorplain" type="method" display="AuthLoginOrPlain"/>]+ ;
		[<memberdata name="authenticate" type="method" display="Authenticate"/>]+ ;
		[<memberdata name="tobase64" type="method" display="ToBase64"/>]+ ;
		[<memberdata name="quoteifneed" type="method" display="QuoteIfNeed"/>]+ ;
		[<memberdata name="strfolding" type="method" display="StrFolding"/>]+ ;
		[<memberdata name="sendrcptto" type="method" display="SendRcptTo"/>]+ ;
		[<memberdata name="sendattach" type="method" display="SendAttach"/>]+ ;
		[<memberdata name="sendmessage" type="method" display="SendMessage"/>]+ ;
		[<memberdata name="wait" type="method" display="Wait"/>]+ ;
		[<memberdata name="newid" type="method" display="NewID"/>]+ ;
		[<memberdata name="strtolong" type="method" display="StrToLong"/>]+ ;
		[<memberdata name="getsystemerrormsg" type="method" display="GetSystemErrorMsg"/>]+ ;
		[<memberdata name="writelog" type="method" display="WriteLog"/>]+ ;
		[</VFPData>]
	
	PROTECTED PROCEDURE INIT
	PARAMETERS toMailSock
		LOCAL cAscii,nI,oErr AS Exception
		
		WITH THIS
			oErr=.NULL.
			TRY
				.WinSock=m.toMailSock
*!*					.WinSock=CREATEOBJECT("MSWinsock.Winsock")
			CATCH TO oErr
			ENDTRY
			IF !ISNULL(oErr)
				MESSAGEBOX("������ �������� ������ "+oErr.Message,48,.Caption)
				RETURN .F.
			ENDIF
			
			.ResultStr=""
			.ResultCode=0
			
			.FormattedTimeZone=.GetFormattedTimeZone()
			
			* RFC-2822
			* �������� ������, ��������� �� ����������� ��� ��������� ASCII ��������
			* ������ ����������, �� ���������� � �������� ���� �������� ����� ����������
			cAscii=""
			FOR nI=33 TO 90
				cAscii=cAscii+CHR(nI)
			ENDFOR
			FOR nI=94 TO 126
				cAscii=cAscii+CHR(nI)
			ENDFOR
			
			* �������� �� ���������� ��������
			.AllowedHeaderChars=cAscii
			
			* �������� ������, ��������� �� ����������� ��� ������ ASCII ��������
			* ���� ������, ���� � ��� ��������� �������, �� ���������� � ��������
			* ���� �������� ����� ����������
			cAscii=""
			FOR nI=0 TO 127
				cAscii=cAscii+CHR(nI)
			ENDFOR
			
			* �������� �� ���������� ��������
			.AllowedBodyChars=cAscii
			
  			DECLARE INTEGER gethostbyname IN ws2_32.dll STRING
		ENDWITH
	ENDPROC
	
	PROTECTED PROCEDURE DESTROY
		WITH THIS
*!*				.DisConnect()
			.WinSock=.NULL.
		ENDWITH
	ENDPROC
	
	PROTECTED PROCEDURE LogFile_ASSIGN(tcFile AS String)
		IF VARTYPE(tcFile)="C"
			THIS.LogFile=ALLTRIM(tcFile)
		ENDIF
	ENDPROC
	
	PROTECTED PROCEDURE RemoteHost_ASSIGN(tcRemoteHost AS String)
		IF VARTYPE(tcRemoteHost)="C"
			THIS.RemoteHost=ALLTRIM(tcRemoteHost)
			
			IF !EMPTY(tcRemoteHost)
				* ������� �������� �������� ��� SMTP-�������
				THIS.RemoteDomainName=THIS.ResolveHostName()
			ELSE
				THIS.RemoteDomainName=""
			ENDIF
		ENDIF
	ENDPROC
	
	PROTECTED PROCEDURE RemotePort_ASSIGN(tnRemotePort AS Integer)
		IF VARTYPE(tnRemotePort)="N" AND tnRemotePort>0
			THIS.RemotePort=tnRemotePort
		ENDIF
	ENDPROC
	
	PROTECTED PROCEDURE SenderName_ASSIGN(tcSenderName AS String)
		IF VARTYPE(tcSenderName)="C"
			THIS.SenderName=ALLTRIM(tcSenderName)
		ENDIF
	ENDPROC
	
	PROTECTED PROCEDURE MailFrom_ASSIGN(tcMailFrom AS String)
		LOCAL nLines,nI,nPos
		LOCAL ARRAY aLn[1]
		
		WITH THIS
			IF VARTYPE(tcMailFrom)="C"
				.MailFrom=""
				
				IF !EMPTY(tcMailFrom)
					aLn[1]=""
					nLines=ALINES(aLn,tcMailFrom,BITOR(1,4),";")
					FOR nI=1 TO nLines
						IF !EMPTY(aLn[nI])
							nPos=AT("<",aLn[nI])
							IF nPos>0
								aLn[nI]=SUBSTR(aLn[nI],nPos+1)
							ENDIF
							
							nPos=AT(">",aLn[nI])
							IF nPos>0
								aLn[nI]=SUBSTR(aLn[nI],1,nPos-1)
							ENDIF
							
							* ��� ������ ����������� ��������� ������ ���� �����
							.MailFrom=ALLTRIM(aLn[nI])
							EXIT
						ENDIF
					ENDFOR
				ENDIF
			ENDIF
		ENDWITH
	ENDPROC
	
	PROTECTED PROCEDURE MailTo_ASSIGN(tcMailTo AS String)
		LOCAL nLines,nI,nPos
		LOCAL ARRAY aLn[1]
		
		WITH THIS
			IF VARTYPE(tcMailTo)="C"
				.MailTo=""
				
				IF !EMPTY(tcMailTo)
					aLn[1]=""
					nLines=ALINES(aLn,tcMailTo,BITOR(1,4),";")
					FOR nI=1 TO nLines
						IF !EMPTY(aLn[nI])
							nPos=AT("<",aLn[nI])
							IF nPos>0
								aLn[nI]=SUBSTR(aLn[nI],nPos+1)
							ENDIF
							
							nPos=AT(">",aLn[nI])
							IF nPos>0
								aLn[nI]=SUBSTR(aLn[nI],1,nPos-1)
							ENDIF
							
							.MailTo=.MailTo+IIF(EMPTY(.MailTo),"",";")+ALLTRIM(aLn[nI])
						ENDIF
					ENDFOR
				ENDIF
			ENDIF
		ENDWITH
	ENDPROC
	
	PROTECTED PROCEDURE MailCC_ASSIGN(tcMailCC AS String)
		LOCAL nLines,nI,nPos
		LOCAL ARRAY aLn[1]
		
		WITH THIS
			IF VARTYPE(tcMailCC)="C"
				.MailCC=""
				
				IF !EMPTY(tcMailCC)
					aLn[1]=""
					nLines=ALINES(aLn,tcMailCC,BITOR(1,4),";")
					FOR nI=1 TO nLines
						IF !EMPTY(aLn[nI])
							nPos=AT("<",aLn[nI])
							IF nPos>0
								aLn[nI]=SUBSTR(aLn[nI],nPos+1)
							ENDIF
							
							nPos=AT(">",aLn[nI])
							IF nPos>0
								aLn[nI]=SUBSTR(aLn[nI],1,nPos-1)
							ENDIF
							
							.MailCC=.MailCC+IIF(EMPTY(.MailCC),"",";")+ALLTRIM(aLn[nI])
						ENDIF
					ENDFOR
				ENDIF
			ENDIF
		ENDWITH
	ENDPROC
	
	PROTECTED PROCEDURE MailBCC_ASSIGN(tcMailBCC AS String)
		LOCAL nLines,nI,nPos
		LOCAL ARRAY aLn[1]
		
		WITH THIS
			IF VARTYPE(tcMailBCC)="C"
				.MailBCC=""
				
				IF !EMPTY(tcMailBCC)
					aLn[1]=""
					nLines=ALINES(aLn,tcMailBCC,BITOR(1,4),";")
					FOR nI=1 TO nLines
						IF !EMPTY(aLn[nI])
							nPos=AT("<",aLn[nI])
							IF nPos>0
								aLn[nI]=SUBSTR(aLn[nI],nPos+1)
							ENDIF
							
							nPos=AT(">",aLn[nI])
							IF nPos>0
								aLn[nI]=SUBSTR(aLn[nI],1,nPos-1)
							ENDIF
							
							.MailBCC=.MailBCC+IIF(EMPTY(.MailBCC),"",";")+ALLTRIM(aLn[nI])
						ENDIF
					ENDFOR
				ENDIF
			ENDIF
		ENDWITH
	ENDPROC
	
	PROTECTED PROCEDURE MailReplyTo_ASSIGN(tcMailReplyTo AS String)
		LOCAL nLines,nI,nPos
		LOCAL ARRAY aLn[1]
		
		WITH THIS
			IF VARTYPE(tcMailReplyTo)="C"
				.MailReplyTo=""
				
				IF !EMPTY(tcMailReplyTo)
					aLn[1]=""
					nLines=ALINES(aLn,tcMailReplyTo,BITOR(1,4),";")
					FOR nI=1 TO nLines
						IF !EMPTY(aLn[nI])
							nPos=AT("<",aLn[nI])
							IF nPos>0
								aLn[nI]=SUBSTR(aLn[nI],nPos+1)
							ENDIF
							
							nPos=AT(">",aLn[nI])
							IF nPos>0
								aLn[nI]=SUBSTR(aLn[nI],1,nPos-1)
							ENDIF
							
							* ��� ������ �������� ������ ��������� ������ ���� �����
							.MailReplyTo=ALLTRIM(aLn[nI])
							EXIT
						ENDIF
					ENDFOR
				ENDIF
			ENDIF
		ENDWITH
	ENDPROC
	
	PROTECTED PROCEDURE MailSubject_ASSIGN(tcSubject AS String)
		LOCAL nLines,nI
		LOCAL ARRAY aLn[1]
		
		WITH THIS
			IF VARTYPE(tcSubject)="C"
				.MailSubject=""
				
				IF !EMPTY(tcSubject)
					aLn[1]=""
					nLines=ALINES(aLn,tcSubject,BITOR(1,4),CRLF,CHR(13),CHR(10))
					
					FOR nI=1 TO nLines
						* ��� ���� ������ ��������� ������ ���� ������
						.MailSubject=ALLTRIM(aLn[nI])
						EXIT
					ENDFOR
				ENDIF
			ENDIF
		ENDWITH
	ENDPROC
	
	PROTECTED PROCEDURE MailText_ASSIGN(tcText AS String)
		LOCAL nLines,nI
		LOCAL ARRAY aLn[1]
		
		IF VARTYPE(tcText)="C"
			aLn[1]=""
			nLines=ALINES(aLn,tcText,2,CRLF,CHR(13),CHR(10))
			
			WITH THIS
				.MailText=""
				
				FOR nI=1 TO nLines
					.MailText=.MailText+aLn[nI]+CRLF
				ENDFOR
			ENDWITH
		ENDIF
	ENDPROC
	
	PROTECTED PROCEDURE Priority_ASSIGN(tnPriority AS Integer)
		IF VARTYPE(tnPriority)="N" AND BETWEEN(tnPriority,0,5)
			THIS.Priority=tnPriority
		ENDIF
	ENDPROC
	
	PROTECTED PROCEDURE SmtpLogin_ASSIGN(tcSmtpLogin AS String)
		IF VARTYPE(tcSmtpLogin)="C"
			THIS.SmtpLogin=ALLTRIM(tcSmtpLogin)
		ENDIF
	ENDPROC
	
	PROTECTED PROCEDURE SmtpPwd_ASSIGN(tcSmtpPwd AS String)
		IF VARTYPE(tcSmtpPwd)="C"
			THIS.SmtpPwd=RTRIM(tcSmtpPwd)
		ENDIF
	ENDPROC
	
	PROTECTED PROCEDURE TimeToOut_ASSIGN(tnTimeToOut AS Integer)
		IF VARTYPE(tnTimeToOut)="N" AND tnTimeToOut>=0
			THIS.TimeToOut=tnTimeToOut
		ENDIF
	ENDPROC
	
	PROTECTED PROCEDURE Version_ASSIGN(tcVersion AS String)
	ENDPROC
	
	FUNCTION GetFormattedTimeZone AS String
		LOCAL cZoneInfo,nZone,cVal
		
		DECLARE INTEGER GetTimeZoneInformation IN kernel32.dll AS WinAPI_GetTimeZoneInformation STRING @
		
		* ��������� TIME_ZONE_INFORMATION
		cZoneInfo=REPLICATE(CHR(0),172)
		
		nZone=WinAPI_GetTimeZoneInformation(@cZoneInfo)
		DO CASE
			* �� ��������� � ����������� ��������� ����
			CASE nZone=1
				* ������� ����� �������� ���������� �������� � ������ ������������
				nTZ=CTOBIN(SUBSTR(cZoneInfo,1,4),"4RS")+CTOBIN(SUBSTR(cZoneInfo,85,4),"4RS")
			
			* �� ��������� � ������� ��������� ����
			CASE nZone=2
				* ������� ����� �������� ���������� �������� � ������ ��������
				nTZ=CTOBIN(SUBSTR(cZoneInfo,1,4),"4RS")+CTOBIN(SUBSTR(cZoneInfo,169,4),"4RS")
			
			* �� ������ ���������� ��������� ���� ����������
			OTHERWISE
				nTZ=0
		ENDCASE
		
		IF nTZ>0
			cVal="-"
		ELSE
			cVal="+"
		ENDIF
		cVal=cVal+PADL(INT(ABS(nTZ)/60),2,"0")
		cVal=cVal+PADL(ABS(nTZ)-INT(ABS(nTZ)/60)*60,2,"0")
		
		RETURN cVal
	ENDFUNC
	
	FUNCTION GetFormattedEmailDate AS String
		LOCAL tTime,cRetVal,cDate,nHours,cZoneInfo,nZone,nTZ,nDiff
		LOCAL ARRAY aDays[7],aMonths[12]
		
		aDays[1]="Mon"
		aDays[2]="Tue"
		aDays[3]="Wed"
		aDays[4]="Thu"
		aDays[5]="Fri"
		aDays[6]="Sat"
		aDays[7]="Sun"
		
		aMonths[1]="Jan"
		aMonths[2]="Feb"
		aMonths[3]="Mar"
		aMonths[4]="Apr"
		aMonths[5]="May"
		aMonths[6]="Jun"
		aMonths[7]="Jul"
		aMonths[8]="Aug"
		aMonths[9]="Sep"
		aMonths[10]="Oct"
		aMonths[11]="Nov"
		aMonths[12]="Dec"
		
		cDate=SET("DATE")
		nHours=SET("HOURS")
		SET DATE GERMAN
		SET HOURS TO 24
		
		cRetVal=""
		
		tTime=DATETIME()
		
		* ������: Fri, 15 Sep 2006 01:20:20 +0400
		cRetVal=aDays[DOW(tTime,2)]+", "+PADL(DAY(tTime),2,"0")+" "+aMonths[MONTH(tTime)]
		cRetVal=cRetVal+" "+ALLTRIM(STR(YEAR(tTime)))+" "+TTOC(tTime,2)
		cRetVal=cRetVal+" "+THIS.FormattedTimeZone
		
		SET HOURS TO (nHours)
		SET DATE &cDate
		
		RETURN cRetVal
	ENDFUNC
	
	* ��������� ��������� ����� SMTP-�������
	PROTECTED FUNCTION ResolveHostName AS String
		LOCAL cRetVal,nPtr,cStruct
		
		cRetVal=""
		
		WITH THIS
			IF !EMPTY(.RemoteHost)
				* ������� ��������� �� ��������� HOSTENT
				nPtr=gethostbyname(.RemoteHost)
				IF nPtr!=0
					* �������� ���� ������ 16 ���� �� ���������
					* 16 ���� - ������ ��������� HOSTENT
					cStruct=SYS(2600,nPtr,16)
					
					* ������ ��������� � ���������� ���������, ���������
					* �� Fully Qualified Domain Name ������ SMTP-�������
					cRetVal=SYS(2600,CTOBIN(SUBSTR(cStruct,1,4),"4RS"),128)
					
					* ������� ������, �� ������ ������, ���� �������� 0
					cRetVal=SUBSTR(cRetVal,1,AT(CHR(0),cRetVal)-1)
				ENDIF
			ENDIF
		ENDWITH
		
		RETURN cRetVal
	ENDFUNC
	
	PROTECTED FUNCTION Connect AS Boolean
		LOCAL cMessage,cResult,lRetVal,lYield
		
		lRetVal=.T.
		
		WITH THIS.WinSock.WinSock.Object
			* ���� ���������� ����������, ������� ������� ���
			THIS.DisConnect(.T.)
			
			* ��������� ���������� ����, ���������, ��� �������� �����
			* �� ������� ��� ������������ � ������
			THIS.UseAuth=.F.
			
			* ��������� ���������� ����, ���������, ��� ������ ��
			* ������������ 8-�� ������ ���������
			THIS.Use8bit=.F.
			
			.RemoteHost=THIS.RemoteHost
			.RemotePort=THIS.RemotePort
			.LocalPort=0
			
			THIS.WriteLog("����������� � "+THIS.RemoteHost+", ���� "+ALLTRIM(STR(THIS.RemotePort)),">")
			
			lYield=_VFP.AutoYield
			_VFP.AutoYield=.F.
			
			IF !EMPTY(THIS.RemoteHost)
				* ��������� ����������
				.Connect()
				
				* �������� ����� ����� ������ ������� ����������
				THIS.Wait()
			ENDIF
			
			* ���� ������ ����������� � ������
			IF .State=7 AND !EMPTY(.RemoteHostIP)
				* ������� ��������� ���������� � SMTP ��������
				IF .BytesReceived>0
					cResult=SPACE(.BytesReceived+1)
					.GetData(@cResult,,LEN(cResult))
					
					THIS.WriteLog(cResult,"<")
				ENDIF
				
				cMessage="EHLO "+.LocalHostName+CRLF
				
				* �������� ������� � ������� ���������
				cResult=THIS.SendData(cMessage,.T.)
				
				IF !INLIST(THIS.ResultCode,220,250)
					* �� ������� EHLO ������ ������ ������, ��������� HELO
					cMessage="HELO "+.LocalHostName+CRLF
					
					* �������� ������� � ������� ���������
					cResult=THIS.SendData(cMessage,.T.)
					
					IF !INLIST(THIS.ResultCode,220,250)
						lRetVal=.F.
					ENDIF
				ENDIF
				
				IF lRetVal
					IF ATC("AUTH",cResult)>0
						* ������� ����������� ������������ ��������������
						THIS.UseAuth=.T.
						
						* ������ ������ ����� ���� ����������� ��������������
						* (��� ���������� ���������� ����� ����������� PLAIN)
*!*							IF ATC("DIGEST-MD5",cResult)>0
*!*								THIS.AuthType="DIGEST-MD5"
*!*							ELSE
							IF ATC("CRAM-MD5",cResult)>0
								THIS.AuthType="CRAM-MD5"
							ELSE
								IF ATC("LOGIN",cResult)>0
									THIS.AuthType="LOGIN"
								ELSE
									IF ATC("PLAIN",cResult)>0
										THIS.AuthType="PLAIN"
									ENDIF
								ENDIF
							ENDIF
*!*							ENDIF
					ENDIF
					IF ATC("8BITMIME",cResult)>0
						* ������ ������������ 8 ������ ���������
						THIS.Use8bit=.T.
					ENDIF
				ENDIF
			ELSE
				THIS.ResultCode=500
				THIS.ResultStr="500 ������ �����������"
				THIS.WriteLog(THIS.ResultStr,"<")
				lRetVal=.F.
			ENDIF
			
			_VFP.AutoYield=lYield
			
			* ����� ���������� ��������� ������� ������, �������� ������������
			DOEVENTS
		ENDWITH
		
		RETURN lRetVal
	ENDFUNC
	
	PROTECTED PROCEDURE DisConnect(tlWait AS Boolean)
		LOCAL cMessage,lYield
		
		WITH THIS.WinSock.WinSock.Object
			IF .State!=0 && Closed
				cMessage="QUIT"+CRLF
				
				lYield=_VFP.AutoYield
				_VFP.AutoYield=.F.
				
				THIS.SendData(cMessage,tlWait)
				
				.Close()
				
				IF tlWait
					THIS.Wait()
				ENDIF
				
				_VFP.AutoYield=lYield
				
				* ����� ���������� ��������� ������� ������, �������� ������������
				DOEVENTS
			ENDIF
			
			.RemoteHost=""
			.LocalPort=0
		ENDWITH
	ENDPROC
	
	PROTECTED FUNCTION SendData(tcSendMsg AS String,tlGetResult AS Boolean) AS String
		LOCAL cRetVal,nSec,lYield
		
		cRetVal=""
		
		IF VARTYPE(tcSendMsg)="C" AND !EMPTY(tcSendMsg) AND RIGHT(tcSendMsg,2)!=CRLF
			tcSendMsg=tcSendMsg+CRLF
		ENDIF
		
		WITH THIS.WinSock.WinSock.Object
			* ���� ��������� � ������
			IF .State=7 AND !EMPTY(.RemoteHostIP)
				THIS.WriteLog(tcSendMsg,">")
				
				lYield=_VFP.AutoYield
				_VFP.AutoYield=.F.
				
				.SendData(tcSendMsg)
				
				IF tlGetResult
					nSec=SECONDS()
					
					DO WHILE SECONDS()-nSec<=THIS.TimeToOut
						IF .State!=7
							cRetVal="500 ����������"+IIF(!EMPTY(THIS.RemoteHost)," � "+THIS.RemoteHost,"")+" ��������"
							THIS.WriteLog(cRetVal,"<")
							EXIT
						ENDIF
						
						IF .BytesReceived!=0
							cRetVal=SPACE(.BytesReceived+1)
							.GetData(@cRetVal,,LEN(cRetVal))
							
							cRetVal=RTRIM(cRetVal,0,CHR(13),CHR(10))
							
							THIS.WriteLog(cRetVal,"<")
							EXIT
						ENDIF
						
						=INKEY(.1)
					ENDDO
					
					THIS.ResultCode=INT(VAL(cRetVal))
					THIS.ResultStr=cRetVal
				ENDIF
				
				_VFP.AutoYield=lYield
				
				* ����� ���������� ��������� ������� ������, �������� ������������
				DOEVENTS
			ELSE
				IF tlGetResult
					cRetVal="500 ����������� ���������"+IIF(!EMPTY(THIS.RemoteHost)," � "+THIS.RemoteHost,"")
					THIS.WriteLog(cRetVal,"<")
					
					THIS.ResultCode=INT(VAL(cRetVal))
					THIS.ResultStr=cRetVal
				ENDIF
			ENDIF
		ENDWITH
		
		RETURN cRetVal
	ENDFUNC
	
	PROTECTED FUNCTION AuthDigestMd5 AS Boolean
		LOCAL lRetVal,oHash AS Cryptor OF mailer.prg
		LOCAL cResult,cMessage,nLines,nI,cStr,cValue
		LOCAL cRealm,cNonce,cQop,cStale,nMaxBuf,cCharSet,cAlg,cCipher
		LOCAL cCnonce,nNonceCnt,cDigestURI,cA1,cA2,cSS
		LOCAL cSelQop,cSelCipher,cSelRealm
		LOCAL ARRAY aLn[1]
		
		lRetVal=.T.
		
		* ���������� �������� �������� �� �����������
		nNonceCnt=0
		
		WITH THIS
			* ����� ��� ������������ � ������, ���������
			* ��� �������� DIGEST MD5
			oHash=CREATEOBJECT("Cryptor")
			
			cMessage="AUTH DIGEST-MD5"+CRLF
			
			* �������� ������� �� ����� � ������� ���������
			cResult=.SendData(cMessage,.T.)
			
			* ����� ������ �� ������� �� �����������
			IF .ResultCode!=334
				lRetVal=.F.
			ENDIF
			
			IF lRetVal
				* ���������� ���������� ��������� �� �������
				cResult=STRCONV(SUBSTR(cResult,5),14)
				
				*******************************************************
				* Digest-challenge
				*******************************************************
				* realm="������"
				* nonce="������"
				* qop="auth","auth-int","auth-conf","������"
				* stale="true"
				* maxbuf=�����
				* charset="utf-8"
				* algorithm="md5-sess"
				* cipher="3des","des","aes","rc4-40","rc4","rc4-56","������"
				* ������=������,"������"
				*******************************************************
				nLines=ALINES(aLn,cResult,BITOR(1,4),",")
				FOR nI=1 TO nLines
					IF AT("=",aLn[nI])>0
						cStr=SUBSTR(aLn[nI],1,AT("=",aLn[nI])-1)
						cValue=SUBSTR(aLn[nI],AT("=",aLn[nI])+1)
						
						DO CASE
							CASE UPPER(cStr)=="REALM"
								cRealm=cValue
							CASE UPPER(cStr)=="NONCE"
								cNonce=cValue
							CASE UPPER(cStr)=="QOP"
								cQop=cValue
							CASE UPPER(cStr)=="STALE"
								cStale=cValue
							CASE UPPER(cStr)=="MAXBUF"
								nMaxBuf=INT(VAL(cValue))
							CASE UPPER(cStr)=="CHARSET"
								cCharSet=cValue
							CASE UPPER(cStr)=="ALGORITHM"
								cAlg=cValue
							CASE UPPER(cStr)=="CIPHER"
								cCipher=cValue
						ENDCASE
					ENDIF
				ENDFOR
				
				* ���� ������������ ������ ������ �� ��������
				IF VARTYPE(nMaxBuf)!="N"
					* �������� ��-���������
					nMaxBuf=65536
				ENDIF
				
				*******************************************************
				* Digest-response
				*******************************************************
				* username="���_������������"
				* realm="����������_������_�_�������"
				* nonce="����������_������_�_�������"
				* cnonce="������"
				* nc=����� (8-�� ������� HEX)
				* qop="auth","auth-int","auth-conf","������"
				* digest-uri="���_�������/����"
				* response=����� (32-�� ������� HEX)
				* cipher="3des","des","aes","rc4-40","rc4","rc4-56","������"
				* authzid="������"
				*******************************************************
				cMessage="username="+CHR(0x22)+.SmtpLogin+CHR(0x22)
				
				cSelRealm=""
				
				* ���� � ������� ������� �������� "realm"
				IF VARTYPE(cRealm)="C" AND !EMPTY(cRealm)
					* ����� �� ������ ������� �������
					cStr=CHRTRAN(cRealm,CHR(0x22),"")
					
					* ���� ���� ��������� ����������
					IF AT(",",cStr)>0
						DIMENSION aLn[1]
						nLines=ALINES(aLn,cStr,BITOR(1,4),",")
						FOR nI=1 TO nLines
							IF UPPER(aLn[nI])==UPPER(.RemoteHost) OR UPPER(aLn[nI])==UPPER(.RemoteDomainName)
								* ���������� realm ������������� ������ SMTP-�������
								
								* ���� � ������, ���������� � �������, ��������
								* �������� realm �������� � ������� �������
								IF AT(CHR(0x22),cRealm)>0
									cMessage=cMessage+",realm="+CHR(0x22)+aLn[nI]+CHR(0x22)
								ELSE
									cMessage=cMessage+",realm="+aLn[nI]
								ENDIF
								
								* ��������� realm
								cSelRealm=aLn[nI]
								EXIT
							ENDIF
						ENDFOR
					ELSE
						IF UPPER(cStr)==UPPER(.RemoteHost) OR UPPER(cStr)==UPPER(.RemoteDomainName)
							IF AT(CHR(0x22),cRealm)>0
								cMessage=cMessage+",realm="+CHR(0x22)+cStr+CHR(0x22)
							ELSE
								cMessage=cMessage+",realm="+cStr
							ENDIF
							
							* ��������� realm
							cSelRealm=cStr
						ENDIF
					ENDIF
				
					* �� ������� realm, ������������� ������� ������ �� ������
					IF EMPTY(cSelRealm)
						cSelRealm=cRealm
						cMessage=cMessage+",realm="+cRealm
					ENDIF
				ENDIF
				
				* ���� � ������� ������� �������� "nonce"
				IF VARTYPE(cNonce)="C" AND !EMPTY(cNonce)
					cMessage=cMessage+",nonce="+cNonce
				ENDIF
				
				* �������� ���������� ������������ ��������
				* �� ����������� �� ������� �������
				nNonceCnt=nNonceCnt+1
				cMessage=cMessage+",nc="+SUBSTR(TRANSFORM(nNonceCnt,"@0"),3)
				
				* ���������� ������ �� ������� �������
				cCnonce=.NewID()
				cMessage=cMessage+",cnonce="+CHR(0x22)+cCnonce+CHR(0x22)
				
				* digest-uri - smtp/mail.server.ru/server.ru
				cDigestURI=CHR(0x22)+"smtp/"+.RemoteDomainName+IIF(UPPER(.RemoteHost)==UPPER(.RemoteDomainName),"","/"+.RemoteHost)+CHR(0x22)
				cMessage=cMessage+",digest-uri="+cDigestURI
				
				* response
				* HEX( KD ( HEX(H(A1)),
				*                  { unq(nonce-value), ":" nc-value, ":",
				*                    unq(cnonce-value), ":", qop-value, ":",
				*                    HEX(H(A2)) }))
				* A1 = { SS, ":", unq(nonce-value), ":", unq(cnonce-value) }
				* SS = H( { unq(username-value), ":",
				*              unq(realm-value), ":", password } )
				* A2 = { "AUTHENTICATE:", digest-uri-value }
				
				* �������� SS
				cSS=oHash.GetMd5Hash(.SmtpLogin+":"+cSelRealm+":"+.SmtpPwd,.T.)
				
				* �������� A1
				cA1=oHash.GetMd5Hash(cSS+":"+CHRTRAN(cNonce,CHR(0x22),"")+":"+cCnonce)
				
				* �������� A2
				cA2=oHash.GetMd5Hash("AUTHENTICATE:"+cDigestURI)
				
				* ���������� response
				cMessage=cMessage+",response="+oHash.GetMd5Hash(cA1+":"+ ;
					CHRTRAN(cNonce,CHR(0x22),"")+":"+ ;
					SUBSTR(TRANSFORM(nNonceCnt,"@0"),3)+":"+ ;
					cCnonce+":"+cSelQop+":"+cA2)
				
				* �������������� ��������� ��� ����� ������������ � ������
				IF VARTYPE(cCharSet)="C" AND !EMPTY(cCharSet)
					cMessage=cMessage+",charset="+cCharSet
				ENDIF
				
				cSelQop=""
				
				* ���� � ������� ������� �������� "qop"
				IF VARTYPE(cQop)="C" AND !EMPTY(cQop)
					* ����� �� ������ ������� �������
					cStr=CHRTRAN(cQop,CHR(0x22),"")
					
					* ���� ���� ��������� ����������
					IF AT(",",cStr)>0
						DIMENSION aLn[1]
						nLines=ALINES(aLn,cStr,BITOR(1,4),",")
						FOR nI=1 TO nLines
							IF UPPER(aLn[nI])=="AUTH"
								* ������ ������������ �������� ����������� "auth"
								cMessage=cMessage+",qop="+aLn[nI]
								
								* ��������� ������ �����������
								cSelQop=aLn[nI]
								EXIT
							ENDIF
						ENDFOR
					ELSE
						IF UPPER(cStr)=="AUTH"
							* ������ ������������ �������� ����������� "auth"
							cMessage=cMessage+",qop="+cStr
							
							* ��������� ������ �����������
							cSelQop=cStr
						ENDIF
					ENDIF
					
					* ���� "auth" �� �������������� � ��� ��������� ������������
					* ������ �����������, �� ���� ���� ��������� ��������� ��
					* ��������������
				ENDIF
				
				cSelCipher=""
				
				* cipher ������������ ������ � ������ ������ qop="auth-conf"
				IF VARTYPE(cCipher)="C" AND !EMPTY(cCipher) AND UPPER(cSelQop)=="AUTH-CONF"
					* ����� �� ����� ������� �������
					cStr=CHRTRAN(cCipher,CHR(0x22),"")
					
					* ���� ���� ��������� ����������
					IF AT(",",cStr)>0
						DIMENSION aLn[1]
						nLines=ALINES(aLn,cStr,BITOR(1,4),",")
						FOR nI=1 TO nLines
							IF UPPER(aLn[nI])=="RC4" OR UPPER(aLn[nI])=="3DES" OR UPPER(aLn[nI])=="AES"
								* ������ ������������ ���������� "rc4" ��� "3des" ��� "aes"
								
								* ���� � ������, ���������� � �������, ��������
								* �������� cipher �������� � ������� �������
								IF AT(CHR(0x22),cCipher)>0
									cMessage=cMessage+",cipher="+CHR(0x22)+aLn[nI]+CHR(0x22)
								ELSE
									cMessage=cMessage+",cipher="+aLn[nI]
								ENDIF
								
								* ��������� ������ ����������
								cSelCipher=aLn[nI]
								EXIT
							ENDIF
						ENDFOR
					ELSE
						IF UPPER(cStr)=="RC4" OR UPPER(cStr)=="3DES" OR UPPER(cStr)=="AES"
							* ������ ������������ ���������� "rc4" ��� "3des" ��� "aes"
							IF AT(CHR(0x22),cCipher)>0
								cMessage=cMessage+",cipher="+CHR(0x22)+cStr+CHR(0x22)
							ELSE
								cMessage=cMessage+",cipher="+cStr
							ENDIF
							
							* ��������� ������ ����������
							cSelCipher=cStr
						ENDIF
					ENDIF
				ENDIF
				
				* ������������� ���������� ������ ��� ������� � base64
				cMessage=STRCONV(cMessage,13)+CRLF
				
				* �������� ������� �� ������ � ������� ���������
				cResult=.SendData(cMessage,.T.)
				
				* ����� ������ �� ������� �� �����������
				IF .ResultCode!=334
					lRetVal=.F.
				ENDIF
			ENDIF
		ENDWITH
		
		RETURN lRetVal
	ENDFUNC
	
	PROTECTED FUNCTION AuthCramMd5 AS Boolean
		LOCAL lRetVal,oHash AS Cryptor OF mailer.prg,cResult,cMessage
		
		lRetVal=.T.
		
		WITH THIS
			* ����� ��� ������������ � ������, ���������
			* ��� �������� HMAC MD5
			oHash=CREATEOBJECT("Cryptor")
			
			cMessage="AUTH CRAM-MD5"+CRLF
			
			* �������� ������� �� ����� � ������� ���������
			cResult=.SendData(cMessage,.T.)
			
			* ����� ������ �� ������� �� �����������
			IF .ResultCode!=334
				lRetVal=.F.
			ENDIF
			
			IF lRetVal
				* ���������� ���������� ��������� �� �������
				cResult=STRCONV(SUBSTR(cResult,5),14)
				
				* ��������� ����� �������, ������������� HMAC MD5
				cMessage=STRCONV(.SmtpLogin+" "+oHash.GetHmacMd5(cResult,.SmtpPwd),13)+CRLF
				
				* �������� ��� ������������ � ������� ���������
				cResult=.SendData(cMessage,.T.)
				
				IF .ResultCode!=235
					* ����������� �� �������
					lRetVal=.F.
				ENDIF
			ENDIF
		ENDWITH
		
		RETURN lRetVal
	ENDFUNC
	
	PROTECTED FUNCTION AuthPlain AS Boolean
		LOCAL lRetVal,cResult,cMessage
		
		lRetVal=.T.
		
		WITH THIS
			* ����� ��� ������������ � ������ � ��������� base64
			* � ������� "login\0login\0password"
			cMessage="AUTH PLAIN "+STRCONV(.SmtpLogin+CHR(0)+.SmtpLogin+CHR(0)+.SmtpPwd,13)+CRLF
			
			* �������� ������� �� ����� � ������� ���������
			cResult=.SendData(cMessage,.T.)
			
			IF .ResultCode!=235
				* ����������� �� �������
				lRetVal=.F.
			ENDIF
		ENDWITH
		
		RETURN lRetVal
	ENDPROC
	
	PROTECTED FUNCTION AuthLoginOrPlain(tlPlain AS Boolean) AS Boolean
		LOCAL lRetVal,cResult,cMessage
		
		IF VARTYPE(tlPlain)!="L"
			tlPlain=.F.
		ENDIF
		
		lRetVal=.T.
		
		WITH THIS
			IF tlPlain
				* ����� ��� ������������ � ������ �������� �������
				cMessage="AUTH PLAIN"+CRLF
			ELSE
				* ����� ��� ������������ � ������ � ��������� base64
				cMessage="AUTH LOGIN"+CRLF
			ENDIF
			
			* �������� ������� �� ����� � ������� ���������
			cResult=.SendData(cMessage,.T.)
			
			* ����� ������ �� ������� �� ���� ����� ������������
			IF .ResultCode!=334
				lRetVal=.F.
			ENDIF
			
			IF lRetVal
				IF tlPlain
					* �������� ��� ������������ �������� �������
					cMessage=.SmtpLogin+CRLF
				ELSE
					* ������������� ��� ������������ � base64
					cMessage=STRCONV(.SmtpLogin,13)+CRLF
				ENDIF
				
				* �������� ��� ������������ � ������� ���������
				cResult=.SendData(cMessage,.T.)
				
				IF .ResultCode!=334
					lRetVal=.F.
				ENDIF
			ENDIF
			
			IF lRetVal
				IF tlPlain
					* �������� ������ �������� �������
					cMessage=.SmtpPwd+CRLF
				ELSE
					* ������������� ������ � base64
					cMessage=STRCONV(.SmtpPwd,13)+CRLF
				ENDIF
				
				* �������� ������ � ������� ���������
				cResult=.SendData(cMessage,.T.)
				
				IF .ResultCode!=235
					* ����������� �� �������
					lRetVal=.F.
				ENDIF
			ENDIF
		ENDWITH
		
		RETURN lRetVal
	ENDFUNC
	
	* ������� ����������� ������������
	PROTECTED FUNCTION Authenticate AS Boolean
		LOCAL lRetVal,lTried
		
		lRetVal=.T.
		
		WITH THIS
			IF .UseAuth AND !EMPTY(.SmtpLogin) AND !EMPTY(.SmtpPwd)
				* ��� ������� ����� ����� ������������ � ������ ��������������
				
				* ���������, ��� ������� ����������� �� ����
				lTried=.F.
				
*!*					* ����� ��� ����������� ��������������?
*!*					* ����� � ������� ����������� � ����� �� ����������
*!*					IF UPPER(.AuthType)=="DIGEST-MD5"
*!*						lRetVal=.AuthDigestMd5()
*!*						
*!*						* ���� ������� �����������
*!*						lTried=.T.
*!*					ENDIF
				
				* ����� ��� ����������� ��������������?
				* ����� � ������� ����������� � ����� �� ����������
				
				* ���� ��� �������� �������������� � �������� ���-�� �����
				* "����������� ������ �����������" ��� ������� �����������
				* ��� �� ���� � ����� ������ ����������� CRAM-MD5
*!*					IF (lTried AND !lRetVal AND .ResultCode=504) OR ;
*!*						(!lTried AND UPPER(.AuthType)=="CRAM-MD5")
				
				IF UPPER(.AuthType)=="CRAM-MD5"
					lRetVal=.AuthCramMd5()
					
					* ���� ������� �����������
					lTried=.T.
				ENDIF
				
				* ���� ��� �������� �������������� � �������� ���-�� �����
				* "����������� ������ �����������" ��� ������� �����������
				* ��� �� ���� � ����� ������ ����������� LOGIN
				IF (lTried AND !lRetVal AND .ResultCode=504) OR ;
					(!lTried AND UPPER(.AuthType)=="LOGIN")
					
					lRetVal=.AuthLoginOrPlain()
					
					* ���� ������� �����������
					lTried=.T.
				ENDIF
				
				* ���� ��� �������� �������������� � �������� ���-�� �����
				* "����������� ������ �����������" ��� ������� �����������
				* ��� �� ����
				IF (lTried AND !lRetVal AND .ResultCode=504) OR !lTried
					
					lRetVal=.AuthPlain()
					
					* ���� ������� �����������
					lTried=.T.
				ENDIF
			ENDIF
		ENDWITH
		
		RETURN lRetVal
	ENDFUNC
	
	* ������� ��������������� ������ ��� ��������� ��� ���� ������ � base64
	PROTECTED FUNCTION ToBase64(tcString AS String,tcWhatTo AS String) AS String
		LOCAL cRetVal,cStart,cEnd,cCharSet
		
		* �������� ������� ������������� ��������
		cRetVal=tcString
		
		cStart="=?"
		cEnd="?="
		cCharSet="windows-"+ALLTRIM(STR(CPCURRENT()))
		
		* ������ � ��������� ������ ���������� ������� ��-�������
		IF VARTYPE(tcWhatTo)="C" AND tcWhatTo="header"
			* ���� �������, ��������� �� ������������ ���������?
			IF !EMPTY(CHRTRAN(tcString,THIS.AllowedHeaderChars,""))
				* ����! ��������.
				cRetVal=cStart+cCharSet+"?B?"+STRCONV(tcString,13)+cEnd
			ENDIF
		ELSE
			* ���� ������ ���������� �� �����������, ���� ������ ������������
			* 8-�� ������ ���������.
			IF !THIS.Use8bit
				* ���� �������, ��������� �� ������������ ���������?
				IF !EMPTY(CHRTRAN(tcString,THIS.AllowedBodyChars,""))
					cRetVal=STRCONV(tcString,13)
				ENDIF
			ENDIF
		ENDIF
		
		RETURN cRetVal
	ENDFUNC
	
	* ������� ����������� �������� ��������� ������, ���������� ������ ��� ���������
	PROTECTED FUNCTION QuoteIfNeed(tcString AS String) AS String
		IF AT(" ",ALLTRIM(tcString))>0 OR AT(CHR(9),ALLTRIM(tcString))>0
			tcString=CHR(0x22)+tcString+CHR(0x22)
		ENDIF
		
		RETURN cString
	ENDFUNC
	
	FUNCTION StrFolding(tcString AS String) AS String
		* � ������� ��������� ������ ��� CRLF
		* �� ������ RFC-2822 2.2.3
		LOCAL cRetVal,nLines,nI,nLen,cStr
		LOCAL aLn[1]
		
		* �������� ������� ������������� ��������
		cRetVal=tcString
		
		* ������ ������� 78 ��������?
		IF LEN(tcString)>78
			* ��! ����� ��������� ��� ��� ����������� �����������
			
			* �������� ������ �� ������������, ������� � ������ �����������
			nLines=ALINES(aLn,tcString,BITOR(2,16)," ",CHR(9),";")
			
			* ���� ����� ����������� � ������?
			IF nLines>0
				cRetVal=""
				cStr=""
				
				FOR nI=1 TO nLines
					* ������� ����� ���� ������ �� ������� � ���������� �������
					* �� ����� ������ 78 �������� ���� 1 �����������, �� ���� 79
					IF LEN(cStr+aLn[nI])>79
						* ���� ���������� ��� �� � ������ ������� �������...
						IF nI>1
							* ... ������ � ��� ��� ���� � cStr ������, �������
							* �� ��������� ������ ����� � � ������� ����������
							* �������� CRLF � ������
							cRetVal=cRetVal+RTRIM(cStr,0," ",CHR(9))+CRLF &&+" "
							
							* ����� �������� ������� ������, ����� ������
							* ��������� ���� ������ �� ������� ��� ���
							nI=nI-1
							
							* � ������� cStr, ��� ��� ���������� ����� ������
							cStr=""
						ELSE
							* � ����� �������� ���������� ����� ������ ������������
							* 998 �������� � ���� ��� ��������� ��� ��������, �����
							* �������� � �������������
							IF LEN(aLn[nI])>998
								DO WHILE .T.
									IF LEN(aLn[nI])>998
										cStr=cStr+SUBSTR(aLn[nI],1,998)+CRLF
										aLn[nI]=SUBSTR(aLn[nI],999)
									ELSE
										cStr=cStr+aLn[nI]
										EXIT
									ENDIF
								ENDDO
							ELSE
								* ��������� ������ ������ ����� ����
								cStr=cStr+RTRIM(aLn[nI],0," ",CHR(9))+CRLF &&+" "
							ENDIF
						ENDIF
					ELSE
						* ��������� ������ �� ������� � ���� ����������
						cStr=cStr+aLn[nI]
					ENDIF
				ENDFOR
				
				* ����� ������������� ������
				cRetVal=cRetVal+cStr
			ENDIF
		ENDIF
		
		RETURN cRetVal
	ENDFUNC
	
	PROTECTED FUNCTION SendRcptTo(tcRcptList AS String) AS Boolean
		LOCAL lRetVal,nErrCnt,nLines,nI,cMessage,cResult
		LOCAL ARRAY aLn[1]
		
		lRetVal=.T.
		nErrCnt=0
		nLines=ALINES(aLn,tcRcptList,BITOR(1,4),";")
		FOR nI=1 TO nLines
			cMessage="RCPT TO:<"+aLn[nI]+">"+CRLF
			
			* �������� �� ������ ����� ����
			cResult=.SendData(cMessage,.T.)
			
			IF !INLIST(.ResultCode,250,251)
				nErrCnt=nErrCnt+1
			ENDIF
		ENDFOR
		
		* ���� ���������� ���������� ������ ��� ������� ���������
		* ������ ��������� ����� ���������� ���� �������, ������
		* �� ���� ����� �� ������ SMTP-��������, ������� ����� ������
		IF nErrCnt>=nLines
			lRetVal=.F.
		ENDIF
		
		RETURN lRetVal
	ENDFUNC
	
	* ������� ���������� ����� �� SMTP-������
	PROTECTED PROCEDURE SendAttach(tcAttach AS String)
		LOCAL cStrFile,cMessage,cName
		
		WITH THIS
			IF FILE(tcAttach)
				cName=CHR(0x22)+.ToBase64(JUSTFNAME(tcAttach),"header")+CHR(0x22)
				
				* �������� �������, ��� ��� �����
				DO CASE
					CASE UPPER(JUSTEXT(tcAttach))=="ZIP"
						cMessage="Content-Type: application/x-zip-compressed;"+CRLF+CHR(9)+"name="+cName+CRLF
					CASE UPPER(JUSTEXT(tcAttach))=="RAR"
						cMessage="Content-Type: application/x-rar-compressed;"+CRLF+CHR(9)+"name="+cName+CRLF
					OTHERWISE
						cMessage="Content-Type: application/octet-stream;"+CRLF+CHR(9)+"name="+cName+CRLF
				ENDCASE
				.SendData(cMessage)
				
				cMessage="Content-Disposition: attachment;"+CRLF+CHR(9)+"filename="+cName+CRLF
				.SendData(cMessage)
				
				cMessage="Content-Transfer-Encoding: base64"+CRLF
				.SendData(cMessage)
				
				* �������� ������ ������, ����� �������� ��������� �� ���� �����
				cMessage=CRLF
				.SendData(cMessage)
				
				* �������� ���������� ����� � ����������
				cStrFile=FILETOSTR(tcAttach)
				
				* ������������� ���������� ����� � base64
				cStrFile=STRCONV(cStrFile,13)
				
				* ����� ������ base64-����� �� ������������� ������ ������ 72 �������
				DO WHILE .T.
					IF LEN(cStrFile)>72
						* �������� 72 ������� �� ����������� ������
						cMessage=SUBSTR(cStrFile,1,72)+CRLF
						* ����������� ���������� ������ �� 72 �������
						cStrFile=SUBSTR(cStrFile,73)
						
						.SendData(cMessage)
					ELSE
						* ������� ����������� ������ ��� ������ 72 ��������,
						* ������� ���������� ��� � ������� �� �����
						cMessage=cStrFile+CRLF
						.SendData(cMessage)
						EXIT
					ENDIF
				ENDDO
				
				* �������� ������ ������, ����� �������� ���� ����� �� �����������
				cMessage=CRLF
				.SendData(cMessage)
			ENDIF
		ENDWITH
	ENDPROC
	
	FUNCTION SendMessage(tcRemoteHost AS String,tnRemotePort AS Integer,tcFrom AS String,tcTo AS String,tcSubject AS String,tcText AS String,tuAttach) AS Boolean
		LOCAL lRetVal,cMessage,cMessageID,cResult,cStr,nI,nLines,nErrCnt
		LOCAL lMultiPart,cBoundary,cBody,cText,lBodyInBase64,cOldCode,cOldStr
		LOCAL ARRAY aLn[1]
		
		WITH THIS
			IF NOT (VARTYPE(tcRemoteHost)="C" AND !EMPTY(tcRemoteHost))
				tcRemoteHost=.RemoteHost
			ELSE
				.RemoteHost=tcRemoteHost
			ENDIF
			IF NOT (VARTYPE(tnRemotePort)="N" AND !EMPTY(tnRemotePort))
				tnRemotePort=.RemotePort
			ELSE
				.RemotePort=tnRemotePort
			ENDIF
			IF NOT (VARTYPE(tcFrom)="C" AND !EMPTY(tcFrom))
				tcFrom=.MailFrom
			ELSE
				.MailFrom=tcFrom
			ENDIF
			IF NOT (VARTYPE(tcTo)="C" AND !EMPTY(tcTo))
				tcTo=.MailTo
			ELSE
				.MailTo=tcTo
			ENDIF
			IF NOT (VARTYPE(tcSubject)="C" AND !EMPTY(tcSubject))
				tcSubject=.MailSubject
			ELSE
				.MailSubject=tcSubject
			ENDIF
			IF NOT (VARTYPE(tcText)="C" AND !EMPTY(tcText))
				tcText=.MailText
			ELSE
				.MailText=tcText
			ENDIF
			
			.WriteLog(PADC("������ ������ "+TTOC(DATETIME()),78,"="),,.T.)
			
			lMultiPart=.F.
			cBoundary=""
			lBodyInBase64=.F.
			lRetVal=.T.
			
			* ���� ��������� � ������
			IF .Connect()
				* �������� ������������� ������
				cMessageID=.NewID()+"@"+.RemoteHost
				
				lRetVal=.Authenticate()
				
				IF lRetVal
					cMessage="MAIL FROM:<"+.MailFrom+">"+IIF(.Use8bit," BODY=8BITMIME","")+CRLF
					
					* �������� �� ������ ����� �� ����
					cResult=.SendData(cMessage,.T.)
					
					IF .ResultCode!=250
						lRetVal=.F.
					ENDIF
				ENDIF
				
				IF lRetVal AND !EMPTY(.MailTo)
					* �������� �� ������ ����� ����
					lRetVal=.SendRcptTo(.MailTo)
				ENDIF
				
				IF lRetVal AND !EMPTY(.MailCC)
					* �������� �� ������ ����� ����� ����
					lRetVal=.SendRcptTo(.MailCC)
				ENDIF
				
				IF lRetVal AND !EMPTY(.MailBCC)
					* �������� �� ������ ����� ������� ����� ����
					lRetVal=.SendRcptTo(.MailBCC)
				ENDIF
				
				IF lRetVal
					cMessage="DATA"+CRLF
					
					* �������� �� ������ ������� ������ ���� ������
					cResult=.SendData(cMessage,.T.)
					
					IF .ResultCode!=354
						lRetVal=.F.
					ENDIF
				ENDIF
				
				IF lRetVal
					* �������� ��������� ������
					cMessage="Date: "+.GetFormattedEmailDate()+CRLF
					.SendData(cMessage)
					
					* ��������� ��������� "From:"
					IF !EMPTY(.MailFrom)
						IF !EMPTY(.SenderName)
							* ���� ������ ��� �����������, ����� ��� �������������
							* ���������� ��� � base64, ���� � ����� ���� �������,
							* ��������� �� ����� �����������
							cMessage="From: "+.ToBase64(.SenderName,"header")+" <"+.MailFrom+">"+CRLF
						ELSE
							cMessage="From: <"+.MailFrom+">"+CRLF
						ENDIF
						.SendData(cMessage)
					ENDIF
					
					* ��������� ��������� "Reply-To:"
					IF !EMPTY(.MailReplyTo)
						cMessage="Reply-To: <"+.MailReplyTo+">"+CRLF
						.SendData(cMessage)
					ELSE
						IF !EMPTY(.MailFrom)
							IF !EMPTY(.SenderName)
								* ���� ������ ��� �����������, ����� ��� �������������
								* ���������� ��� � base64, ���� � ����� ���� �������,
								* ��������� �� ����� �����������
								cMessage="Reply-To: "+.ToBase64(.SenderName,"header")+" <"+.MailFrom+">"+CRLF
							ELSE
								cMessage="Reply-To: <"+.MailFrom+">"+CRLF
							ENDIF
							.SendData(cMessage)
						ENDIF
					ENDIF
					
					* ��������� ��������� "To:"
					IF !EMPTY(.MailTo)
						DIMENSION aLn[1]
						aLn[1]=""
						
						nLines=ALINES(aLn,.MailTo,BITOR(1,4),";")
						IF nLines>0
							cMessage="To: "
							FOR nI=1 TO nLines
								cMessage=cMessage+IIF(nI=1,"",","+CRLF+CHR(9))+"<"+aLn[nI]+">"
							ENDFOR
							cMessage=cMessage+CRLF
							.SendData(cMessage)
						ENDIF
					ENDIF
					
					* ��������� ��������� "Cc:"
					IF !EMPTY(.MailCC)
						DIMENSION aLn[1]
						aLn[1]=""
						
						nLines=ALINES(aLn,.MailCC,BITOR(1,4),";")
						IF nLines>0
							cMessage="Cc: "
							FOR nI=1 TO nLines
								cMessage=cMessage+IIF(nI=1,"",","+CRLF+CHR(9))+"<"+aLn[nI]+">"
							ENDFOR
							cMessage=cMessage+CRLF
							.SendData(cMessage)
						ENDIF
					ENDIF
					
					* ��������� ��������� "Bcc:" �� ����������, ��������
					* ���������� RFC-2822 3.6.3. Destination address fields
					
					* ��������� ��������� "Message-Id:"
					cMessage="Message-Id: <"+cMessageID+">"+CRLF
					.SendData(cMessage)
					
					* �������� "folding" ��� ������ ������
					cText=.StrFolding(.MailText)
					
					* �������� ���� ������ � ����������, ������� ���������
					* �������� � ����� ToBase64, � ���� ����� �������� �� ��
					* ���������� cBody �� ����� ����� cText, ������
					* Content-Transfer ��� ���� ������ ����� ����������
					* � base64, ������ 8bit, ������� �� �������������� ��������
					cBody=.ToBase64(cText)
					IF cBody!=cText
						* ���� ������ ������������ � ��������� base64
						lBodyInBase64=.T.
					ENDIF
					
					* ��������� ��������� "Subject:"
					cMessage="Subject: "+.ToBase64(.MailSubject,"header")+CRLF
					.SendData(cMessage)
					
					* MIME ���������
					cMessage="MIME-Version: 1.0"+CRLF
					.SendData(cMessage)
					
					* ��������� ��������� "Content-Type:"
					IF TYPE("tuAttach")="C" AND !EMPTY(tuAttach) AND FILE(ALLTRIM(tuAttach))
						* ������ ����� �����, ������ ������ ������� "multipart/mixed"
						lMultiPart=.T.
						
						cBoundary="NextPart_"+CHRTRAN(.NewID(),"-","_")
						cMessage="Content-Type: multipart/mixed;"+CRLF+CHR(9)+"boundary="+CHR(0x22)+cBoundary+CHR(0x22)+CRLF
					ELSE
						cMessage="Content-Type: text/plain;"+CRLF+CHR(9)+"charset=windows-"+ALLTRIM(STR(CPCURRENT()))+CRLF
						.SendData(cMessage)
						
						IF lBodyInBase64
							cMessage="Content-Transfer-Encoding: base64"+CRLF
						ELSE
							cMessage="Content-Transfer-Encoding: 8bit"+CRLF
						ENDIF
					ENDIF
					.SendData(cMessage)
					
					* ��������� ������
					cMessage="X-Priority: "+ALLTRIM(STR(.Priority))+CRLF
					.SendData(cMessage)
					
					* ������ �������� ���������
					cMessage="X-Mailer: KvazNET.SMTPClient "+.Version+CRLF
					.SendData(cMessage)
					
					* ������� ��������� ��������� ������: ������ ������
					cMessage=CRLF
					.SendData(cMessage)
					
					IF !EMPTY(cBody)
						* ���� ���� �����
						IF lMultiPart
							cMessage="This is a multi-part message in MIME format."+CRLF+CRLF
							.SendData(cMessage)
							
							* �������� ����������� multipart/mixed
							cMessage="--"+cBoundary+CRLF
							.SendData(cMessage)
							
							cMessage="Content-Type: text/plain;"+CRLF+CHR(9)+"charset=windows-"+ALLTRIM(STR(CPCURRENT()))+CRLF
							.SendData(cMessage)
							
							IF lBodyInBase64
								cMessage="Content-Transfer-Encoding: base64"+CRLF
							ELSE
								cMessage="Content-Transfer-Encoding: 8bit"+CRLF
							ENDIF
							.SendData(cMessage)
							
							* ������� multipart/mixed ��������� �� ���� ������
							cMessage=CRLF
							.SendData(cMessage)
						ENDIF
						
						* �������� ���� ������
						IF lBodyInBase64
							* ��� ���� ������ ������������ � base64, ������
							* ����� ������ base64-����� �� ������ ������ 72
							* �������
							DO WHILE .T.
								IF LEN(cBody)>72
									* �������� 72 ������� �� ���� ������
									cMessage=SUBSTR(cBody,1,72)+CRLF
									* ����������� ���� ������ �� 72 �������
									cBody=SUBSTR(cBody,73)
									
									.SendData(cMessage)
								ELSE
									* ������� ���� ������ ��� ������ 72 ��������,
									* ������� ���������� ��� � ������� �� �����
									cMessage=cBody+CRLF
									.SendData(cMessage)
									EXIT
								ENDIF
							ENDDO
						ELSE
							aLn[1]=""
							nLines=ALINES(aLn,cBody,2,CRLF,CHR(13),CHR(10))
							FOR nI=1 TO nLines
								* ���� ������ ������ ������ ���������� � �����,
								* ����� ������� ����� ��� ��� ���� �����
								* RFC-2821: 4.5.2 Transparency
								cMessage=IIF(SUBSTR(aLn[nI],1,1)=".",".","")+aLn[nI]+CRLF
								.SendData(cMessage)
							ENDFOR
						ENDIF
						
						* ���� ���� �����
						IF lMultiPart
							* ������� ���� ������ �� multipart/mixed ���������
							cMessage=CRLF
							.SendData(cMessage)
						ENDIF
					ENDIF
					
					* ���� ���� �����
					IF lMultiPart
						* ���� ������� ������ ��� ������ ��� �������� � ������ �������
						IF TYPE("tuAttach",1)="A"
							FOR nI=1 TO ALEN(tuAttach,1)
								IF VARTYPE(tuAttach[nI])="C" AND FILE(tuAttach[nI])
									* �������� ����������� multipart/mixed
									cMessage="--"+cBoundary+CRLF
									.SendData(cMessage)
									
									* �������� �����
									.SendAttach(tuAttach)
								ENDIF
							ENDFOR
						ELSE
							FOR nI=1 TO GETWORDCOUNT(ALLTRIM(tuAttach), ',')
								* �������� ����������� multipart/mixed
								cMessage="--"+cBoundary+CRLF
								.SendData(cMessage)
								
								* �������� �����
								.SendAttach(GETWORDNUM(ALLTRIM(tuAttach), m.nI, ','))
							ENDFOR
						ENDIF
						
						* �������� ����������� ����������� multipart/mixed
						cMessage="--"+cBoundary+"--"+CRLF
						.SendData(cMessage)
					ENDIF
					
					* ������� ��������� ���� ������
					cMessage="."+CRLF
					.SendData(cMessage,.T.)
					
					IF .ResultCode!=250
						lRetVal=.F.
					ENDIF
				ENDIF
				
				* ��� ���� ������ �������� ��� �������� ������ ������� �������� ����������
				IF !lRetVal
					* ���������� �������� �������� ����������,
					* ��� ���� �������� ��� � ��������� �� ������
					cOldCode=THIS.ResultCode
					cOldStr=THIS.ResultStr
					
					cMessage="RSET"+CRLF
					.SendData(cMessage,.T.)
					
					THIS.ResultCode=cOldCode
					THIS.ResultStr=cOldStr
				ELSE
					.MessageID=cMessageID
				ENDIF
			ELSE
				lRetVal=.F.
			ENDIF
			
			* ������� ����������
			.DisConnect()
			
			.WriteLog(PADC("����� ������ "+TTOC(DATETIME()),78,"="),,.T.)
			.WriteLog(CRLF,,.T.)
		ENDWITH
		
		RETURN lRetVal
	ENDFUNC
	
	PROTECTED PROCEDURE Wait
		LOCAL lYield,nSec
		
		* ������� ��������� ��������� ������
		nSec=SECONDS()
		
		WITH THIS
			IF .TimeToOut>0
				lYield=_VFP.AutoYield
				_VFP.AutoYield=.F.
				
				DO WHILE SECONDS()-nSec<=.TimeToOut
					IF .WinSock.WinSock.Object.State=9 && Error
						EXIT
					ENDIF
					IF .WinSock.WinSock.Object.BytesReceived!=0
						EXIT
					ENDIF
					=INKEY(.1)
				ENDDO
				
				_VFP.AutoYield=lYield
				
				* ����� ���������� ��������� ������� ������, �������� ������������
				DOEVENTS
			ENDIF
		ENDWITH
	ENDPROC

	PROTECTED FUNCTION NewID
		LOCAL pGuid,lRetVal,cData1,cData2,cData3,cData4,cData5,cDataAll,nGuidlen
		LOCAL nCode,cErrorMsg

		DECLARE INTEGER CoCreateGuid IN ole32.dll AS WinAPI_CoCreateGuid STRING @pGuid

		pGuid=REPLICATE(CHR(0),17)

		lRetVal=WinAPI_CoCreateGuid(@pGuid)

		WITH THIS
			IF lRetVal=0
				* Store the first eight characters of the GUID in data1
				cData1=RIGHT(TRANSFORM(.StrToLong(LEFT(pGuid,4)),"@0"),8)
				* Store the first group of four characters of the GUID in data2
				cData2=RIGHT(TRANSFORM(.StrToLong(SUBSTR(pGuid,5,2)),"@0"),4)
				* Store the second group of four characters of the GUID in data3
				cData3=RIGHT(TRANSFORM(.StrToLong(SUBSTR(pGuid,7,2)),"@0"),4)
				* Store the third group of four characters of the GUID in data4
				cData4=RIGHT(TRANSFORM(.StrToLong(SUBSTR(pGuid,9,1)),"@0"),2) + ;
					RIGHT(TRANSFORM(.StrToLong(SUBSTR(pGuid,10,1)),"@0"),2)

				* Initialize data5 to a null string
				cData5=""
				* Convert the final 12 characters of the GUID and store in data5
				FOR nGuidlen=1 TO 6
					cData5=cData5+RIGHT(TRANSFORM(.StrToLong(SUBSTR(pGuid,10+nGuidlen,1))),2)
				ENDFOR

				* Check the length of data5. If less than 12, the final 12-len(data5)
				* characters are '0'
				IF LEN(cData5)<12
					cData5=cData5+REPLICATE("0",12-LEN(cData5))
				ENDIF
				* Assemble the GUID into a string
				cDataAll=cData1+"-"+cData2+"-"+cData3+"-"+cData4+"-"+cData5
				RETURN cDataAll
			ELSE
				DECLARE INTEGER GetLastError IN win32api AS WinAPI_GetLastError
				
				nCode=WinAPI_GetLastError()
				cErrorMsg=.GetSystemErrorMsg(nCode)
				
				IF !EMPTY(cErrorMsg)
					MESSAGEBOX(cErrorMsg,16,.Caption)
				ELSE
					MESSAGEBOX("������ OLE",16,.Caption)
				ENDIF
				
				RETURN ""
			ENDIF
		ENDWITH
	ENDFUNC

	PROTECTED FUNCTION StrToLong(cLongstr AS String) AS Number
		LOCAL nI,nRetval

		nRetval=0

		FOR nI=0 TO 24 STEP 8
			nRetval=nRetval+(ASC(cLongstr)*(2^nI))
			cLongstr=RIGHT(cLongstr,LEN(cLongstr)-1)
		NEXT
		RETURN nRetval
	ENDFUNC

	PROTECTED FUNCTION GetSystemErrorMsg(tnErrorNo AS Integer) AS String
		LOCAL szMsgBuffer,lnSize,lnModule
		
		tnErrorNo=IIF(TYPE("tnErrorNo")="N",tnErrorNo,0)
		
		szMsgBuffer=SPACE(500)
		
		DECLARE INTEGER GetModuleHandle IN win32api AS WinAPI_GetModuleHandle STRING
		DECLARE INTEGER FormatMessage IN win32api AS WinAPI_FormatMessage INTEGER,INTEGER,INTEGER,INTEGER,STRING @,INTEGER,INTEGER
		
		lnModule=WinAPI_GetModuleHandle("advapi32.dll")
		IF lnModule!=0
			lnSize=WinAPI_FormatMessage(0x00000800,lnModule,tnErrorNo, ;
				0,@szMsgBuffer,LEN(szMsgBuffer),0)
		ELSE
		   lnSize=0
		ENDIF
		
		IF lnSize>2
		   szMsgBuffer=SUBSTR(szMsgBuffer,1,lnSize-2)
		ELSE
			lnSize=WinAPI_FormatMessage(0x00001000,0,tnErrorNo, ;
				0,@szMsgBuffer,LEN(szMsgBuffer),0)
			
			IF lnSize>2
				szMsgBuffer=SUBSTR(szMsgBuffer,1,lnSize-2)
			ELSE
				szMsgBuffer=""
			ENDIF
		ENDIF

		RETURN szMsgBuffer
	ENDFUNC
	
	PROCEDURE WriteLog(cString AS String,cWhere AS String,lNoPrefix AS Boolean)
		LOCAL nLines,nI,cStr,cTime
		LOCAL ARRAY aLn[1]
		
		IF !EMPTY(THIS.LogFile)
			IF VARTYPE(cString)="C"
				IF !lNoPrefix
					IF NOT (VARTYPE(cWhere)="C" AND INLIST(cWhere,">","<"))
						cWhere=">"
					ENDIF
					
					cTime=TIME()
					
					* ��� ������������ �� ������� ����� ������ ������ �� ���������
					IF cWhere="<"
						nLines=ALINES(aLn,cString,BITOR(1,4),CRLF,CHR(13),CHR(10))
					ELSE
						nLines=ALINES(aLn,cString,1,CRLF,CHR(13),CHR(10))
					ENDIF
					FOR nI=1 TO nLines
						cStr=cTime+": "+cWhere+" "+aLn[nI]
						STRTOFILE(cStr+CHR(13)+CHR(10),THIS.LogFile,.T.)
					ENDFOR
				ELSE
					STRTOFILE(cString+CHR(13)+CHR(10),THIS.LogFile,.T.)
				ENDIF
			ENDIF
		ENDIF
	ENDPROC
ENDDEFINE

#DEFINE PROV_RSA_FULL			1

#DEFINE CRYPT_NEWKEYSET			0x00000008
#DEFINE CRYPT_DELETEKEYSET		0x00000010

#DEFINE NTE_BAD_KEY_STATE		-2146893813 && 0x8009000B
#DEFINE NTE_NO_KEY				-2146893811 && 0x8009000D
#DEFINE NTE_EXISTS				-2146893809 && 0x8009000F
#DEFINE NTE_BAD_KEYSET			-2146893802 && 0x80090016

#DEFINE ALG_CLASS_SIGNATURE		BITLSHIFT(1,13)
#DEFINE ALG_CLASS_MSG_ENCRYPT	BITLSHIFT(2,13)
#DEFINE ALG_CLASS_DATA_ENCRYPT	BITLSHIFT(3,13)
#DEFINE ALG_CLASS_HASH  		BITLSHIFT(4,13)
#DEFINE ALG_CLASS_KEY_EXCHANGE	BITLSHIFT(5,13)

#DEFINE ALG_TYPE_ANY			0
#DEFINE ALG_TYPE_DSS			BITLSHIFT(1,9)
#DEFINE ALG_TYPE_RSA			BITLSHIFT(2,9)
#DEFINE ALG_TYPE_BLOCK			BITLSHIFT(3,9)
#DEFINE ALG_TYPE_STREAM			BITLSHIFT(4,9)
#DEFINE ALG_TYPE_DH				BITLSHIFT(5,9)
#DEFINE ALG_TYPE_SECURECHANNEL	BITLSHIFT(6,9)

#DEFINE ALG_SID_DES				1
#DEFINE ALG_SID_RC2				2
#DEFINE ALG_SID_MD5				3
#DEFINE ALG_SID_SHA				4
#DEFINE ALG_SID_SHA1			4

#DEFINE AT_KEYEXCHANGE			1
#DEFINE AT_SIGNATURE			2

#DEFINE CALG_RC2				(BITOR(ALG_CLASS_DATA_ENCRYPT,ALG_TYPE_BLOCK,ALG_SID_RC2))
#DEFINE CALG_MD5				(BITOR(ALG_CLASS_HASH,ALG_TYPE_ANY,ALG_SID_MD5))
#DEFINE CALG_SHA1				(BITOR(ALG_CLASS_HASH,ALG_TYPE_ANY,ALG_SID_SHA1))

#DEFINE HP_HASHVAL				0x0002

#DEFINE CRYPT_EXPORTABLE		1

#DEFINE SIMPLEBLOB				0x1

#DEFINE GENERIC_READ			0x80000000
#DEFINE FILE_SHARE_READ			0x00000001
#DEFINE FILE_SHARE_WRITE		0x00000002
#DEFINE OPEN_EXISTING			3
#DEFINE FILE_FLAG_SEQUENTIAL_SCAN	0x08000000

#DEFINE FORMAT_MESSAGE_FROM_SYSTEM	4096
#DEFINE FORMAT_MESSAGE_FROM_HMODULE	2048

#DEFINE ERROR_MORE_DATA				234

DEFINE CLASS Cryptor AS HYPERLINK
	PROTECTED ADDPROPERTY,SAVEASCLASS,RESETTODEFAULT,READMETHOD,WRITEMETHOD
	PROTECTED READEXPRESSION,WRITEEXPRESSION
	PROTECTED APPLICATION,COMMENT,TAG,GOBACK,GOFORWARD,NAVIGATETO
	HIDDEN nProvHandle,nSignKeyHandle,nExchKeyHandle,nHashHandle
	
	* �������� ������ ������� � ���� ����������
	cContainer="CryptoContainerName"
	
	* ����������������� ���������
	cProvider="Microsoft Base Cryptographic Provider v1.0"
	
	* ����� ����, ���������� ����� ���������� ��� ������
	PublicKey=""
	
	* ������, ������� ����� �������������� � ��������� ����������/������������
	Password=""
	
	* ���������� ��������
	nProvHandle=0
	nSignKeyHandle=0
	nExchKeyHandle=0
	nHashHandle=0
	
	_memberdata=[<VFPData><memberdata name="ccontainer" type="property" display="cContainer"/>]+ ;
		[<memberdata name="cprovider" type="property" display="cProvider"/>]+ ;
		[<memberdata name="publickey" type="property" display="PublicKey"/>]+ ;
		[<memberdata name="password" type="property" display="Password"/>]+ ;
		[<memberdata name="nprovhandle" type="property" display="nProvHandle"/>]+ ;
		[<memberdata name="nsignkeyhandle" type="property" display="nSignKeyHandle"/>]+ ;
		[<memberdata name="nexchkeyhandle" type="property" display="nExchKeyHandle"/>]+ ;
		[<memberdata name="nhashhandle" type="property" display="nHashHandle"/>]+ ;
		[<memberdata name="getsystemerrormessage" type="method" display="GetSystemErrorMessage"/>]+ ;
		[<memberdata name="getmd5hash" type="method" display="GetMd5Hash"/>]+ ;
		[<memberdata name="getfilemd5hash" type="method" display="GetFileMd5Hash"/>]+ ;
		[<memberdata name="getsha1hash" type="method" display="GetSha1Hash"/>]+ ;
		[<memberdata name="getfilesha1hash" type="method" display="GetFileSha1Hash"/>]+ ;
		[<memberdata name="gethmacmd5" type="method" display="GetHmacMd5"/>]+ ;
		[<memberdata name="createfilehash" type="method" display="CreateFileHash"/>]+ ;
		[<memberdata name="createhash" type="method" display="CreateHash"/>]+ ;
		[<memberdata name="encrypt" type="method" display="Encrypt"/>]+ ;
		[<memberdata name="decrypt" type="method" display="Decrypt"/>]+ ;
		[</VFPData>]
	
	PROTECTED PROCEDURE INIT
		LOCAL nProvHandle,nCryptKey,nCode,cErrorMsg
		
		DECLARE INTEGER CryptAcquireContextA IN advapi32.dll INTEGER @,STRING,STRING,INTEGER,INTEGER
		DECLARE INTEGER CryptReleaseContext IN advapi32.dll INTEGER,INTEGER
		DECLARE INTEGER CryptCreateHash IN advapi32.dll INTEGER,INTEGER,INTEGER,INTEGER,INTEGER @
		DECLARE INTEGER CryptHashData IN advapi32.dll INTEGER,STRING @,INTEGER,INTEGER
		DECLARE INTEGER CryptDestroyHash IN advapi32.dll INTEGER
		DECLARE INTEGER CryptGetHashParam IN advapi32.dll INTEGER,INTEGER,STRING @,INTEGER @,INTEGER
		DECLARE INTEGER CryptGenKey IN advapi32.dll INTEGER,INTEGER,INTEGER,INTEGER @
		DECLARE INTEGER CryptDeriveKey IN advapi32.dll INTEGER,INTEGER,INTEGER,INTEGER,INTEGER @
		DECLARE INTEGER CryptGetUserKey IN advapi32.dll INTEGER,INTEGER,INTEGER @
		DECLARE INTEGER CryptExportKey IN advapi32.dll INTEGER,INTEGER,INTEGER,INTEGER,STRING @,INTEGER @
		DECLARE INTEGER CryptImportKey IN advapi32.dll INTEGER,STRING @,INTEGER,INTEGER,INTEGER,INTEGER @
		DECLARE INTEGER CryptDestroyKey IN advapi32.dll INTEGER
		DECLARE INTEGER CryptEncrypt IN advapi32.dll INTEGER,INTEGER,INTEGER,INTEGER,STRING @,INTEGER @,INTEGER
		DECLARE INTEGER CryptDecrypt IN advapi32.dll INTEGER,INTEGER,INTEGER,INTEGER,STRING @,INTEGER @
		
		DECLARE INTEGER GetLastError IN kernel32.dll
		
		DECLARE INTEGER CreateFile IN kernel32.dll STRING,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER
		DECLARE INTEGER ReadFile IN kernel32.dll INTEGER,STRING @,INTEGER,INTEGER @,INTEGER
		DECLARE INTEGER CloseHandle IN kernel32.dll INTEGER
		
		WITH THIS
			nProvHandle=0
			
			IF CryptAcquireContextA(@nProvHandle,.cContainer,.cProvider,PROV_RSA_FULL,0)=0
				nCode=GetLastError()
				
				IF INLIST(nCode,NTE_BAD_KEYSET,NTE_NO_KEY,NTE_BAD_KEY_STATE)
					* ������ ��������� ��� �������� �� ��������� ��������
					IF CryptAcquireContextA(@nProvHandle,.cContainer,.cProvider,PROV_RSA_FULL,CRYPT_DELETEKEYSET)=0
						IF nCode=NTE_BAD_KEY_STATE
							MESSAGEBOX("���������� ������������ ��������� ����� ����� ������ ����������",16,"������")
							RETURN .F.
						ENDIF
					ENDIF
					
					* �������� ������� ��������� ������
					IF CryptAcquireContextA(@nProvHandle,.cContainer,.cProvider,PROV_RSA_FULL,CRYPT_NEWKEYSET)=0
						nCode=GetLastError()
						cErrorMsg=.GetSystemErrorMsg(nCode)
						IF EMPTY(cErrorMsg)
							MESSAGEBOX("������ �������� ������ ������ ����������.  ����������������� ������� �������� ����������.",16,"������")
						ELSE
							MESSAGEBOX(cErrorMsg,16,"������")
						ENDIF
						RETURN .F.
					ENDIF
				ELSE
					cErrorMsg=.GetSystemErrorMsg(nCode)
					IF EMPTY(cErrorMsg)
						MESSAGEBOX("������ �������� ������ ������ ����������.  ����������������� ������� �������� ����������.",16,"������")
					ELSE
						MESSAGEBOX(cErrorMsg,16,"������")
					ENDIF
					RETURN .F.
				ENDIF
			ENDIF
			
			* �������� ��������� �� ������������������ ����������
			.nProvHandle=nProvHandle
			
			nCryptKey=0
			
			* ������� ������� �������� ��������� �� ���� �������
			IF CryptGetUserKey(.nProvHandle,AT_SIGNATURE,@nCryptKey)=0
				nCode=GetLastError()
				cErrorMsg=.GetSystemErrorMsg(nCode)
				IF nCode=NTE_NO_KEY OR EMPTY(nCode)
					IF CryptGenKey(.nProvHandle,AT_SIGNATURE,0,@nCryptKey)=0
						IF EMPTY(cErrorMsg)
							MESSAGEBOX ("���������� ������� ������ ���� ������������.  ����������������� ������� �������� ����������.",16,"������")
						ELSE
							MESSAGEBOX(cErrorMsg,16,"������")
						ENDIF
						RETURN .F.
					ENDIF
				ELSE
					IF EMPTY(cErrorMsg)
						MESSAGEBOX ("��� ������� � ������� ����� ������������.  ����������������� ������� �������� ����������.",16,"������")
					ELSE
						MESSAGEBOX(cErrorMsg,16,"������")
					ENDIF
					RETURN .F.
				ENDIF
			ENDIF
			
			* �������� ��������� �� ���������� ���� �������
			.nSignKeyHandle=nCryptKey
			
			nCryptKey=0
			
			* ������� ������� �������� ��������� �� ���� ������
			IF CryptGetUserKey(.nProvHandle,AT_KEYEXCHANGE,@nCryptKey)=0
				nCode=GetLastError()
				cErrorMsg=.GetSystemErrorMsg(nCode)
				IF nCode=NTE_NO_KEY OR EMPTY(nCode)
					IF CryptGenKey(.nProvHandle,AT_KEYEXCHANGE,0,@nCryptKey)=0
						IF EMPTY(cErrorMsg)
							MESSAGEBOX ("���������� ������� ����� ���� ������������.  ����������������� ������� �������� ����������.",16,"������")
						ELSE
							MESSAGEBOX(cErrorMsg,16,"������")
						ENDIF
						RETURN .F.
					ENDIF
				ELSE
					IF EMPTY(cErrorMsg)
						MESSAGEBOX ("��� ������� � ������ ����� ������������.  ����������������� ������� �������� ����������.",16,"������")
					ELSE
						MESSAGEBOX(cErrorMsg,16,"������")
					ENDIF
					RETURN .F.
				ENDIF
			ENDIF
			
			* �������� ��������� �� ���������� ���� ������
			.nExchKeyHandle=nCryptKey
		ENDWITH
	ENDPROC
	
	PROTECTED PROCEDURE DESTROY
		WITH THIS
			IF .nHashHandle!=0
				CryptDestroyHash(.nHashHandle)
			ENDIF
			IF .nSignKeyHandle!=0
				CryptDestroyKey(.nSignKeyHandle)
			ENDIF
			IF .nExchKeyHandle!=0
				CryptDestroyKey(.nExchKeyHandle)
			ENDIF
			IF .nProvHandle!=0
				CryptReleaseContext(.nProvHandle,0)
			ENDIF
		ENDWITH
	ENDPROC
	
	PROTECTED FUNCTION GetSystemErrorMessage(tnErrorNo AS Integer) AS String
		LOCAL szMsgBuffer,lnSize,lnModule
		
		tnErrorNo=IIF(TYPE("tnErrorNo")="N",tnErrorNo,0)
		
		szMsgBuffer=SPACE(500)
		
		DECLARE INTEGER GetModuleHandle IN win32api AS WinAPI_GetModuleHandle STRING
		DECLARE INTEGER FormatMessage IN win32api AS WinAPI_FormatMessage INTEGER,INTEGER,INTEGER,INTEGER,STRING @,INTEGER,INTEGER
		
		lnModule=WinAPI_GetModuleHandle("advapi32.dll")
		IF lnModule!=0
			lnSize=WinAPI_FormatMessage(0x00000800,lnModule,tnErrorNo, ;
				0,@szMsgBuffer,LEN(szMsgBuffer),0)
		ELSE
		   lnSize=0
		ENDIF
		
		IF lnSize>2
		   szMsgBuffer=SUBSTR(szMsgBuffer,1,lnSize-2)
		ELSE
			lnSize=WinAPI_FormatMessage(0x00001000,0,tnErrorNo, ;
				0,@szMsgBuffer,LEN(szMsgBuffer),0)
			
			IF lnSize>2
				szMsgBuffer=SUBSTR(szMsgBuffer,1,lnSize-2)
			ELSE
				szMsgBuffer=""
			ENDIF
		ENDIF

		RETURN szMsgBuffer
	ENDFUNC
	
	FUNCTION GetMd5Hash(tcString AS String,tlRaw AS Boolean) AS String
		LOCAL cString
		
		IF VARTYPE(tlRaw)!="L"
			tlRaw=.F.
		ENDIF
		
		WITH THIS
			.nHashHandle=0
			cString=.CreateHash(tcString,CALG_MD5)
			IF VARTYPE(cString)!="C"
				* �� ����� ����������� ��������� ������, ����� ������ ������
				cString=""
			ENDIF
		ENDWITH
		
		IF tlRaw
			RETURN cString
		ELSE
			RETURN LOWER(STRCONV(cString,15))
		ENDIF
	ENDFUNC
	
	FUNCTION GetFileMd5Hash(tcFileName AS String,tlRaw AS Boolean) AS String
		LOCAL cString
		
		IF VARTYPE(tlRaw)!="L"
			tlRaw=.F.
		ENDIF
		
		WITH THIS
			cString=.CreateFileHash(tcFileName,CALG_MD5)
			IF VARTYPE(cString)!="C"
				* �� ����� ����������� ��������� ������, ����� ������ ������
				cString=""
			ENDIF
		ENDWITH
		
		IF tlRaw
			RETURN cString
		ELSE
			RETURN LOWER(STRCONV(cString,15))
		ENDIF
	ENDFUNC
	
	FUNCTION GetSha1Hash(tcString AS String,tlRaw AS Boolean) AS String
		LOCAL cString
		
		IF VARTYPE(tlRaw)!="L"
			tlRaw=.F.
		ENDIF
		
		WITH THIS
			.nHashHandle=0
			cString=.CreateHash(tcString,CALG_SHA1)
			IF VARTYPE(cString)!="C"
				* �� ����� ����������� ��������� ������, ����� ������ ������
				cString=""
			ENDIF
		ENDWITH
		
		IF tlRaw
			RETURN cString
		ELSE
			RETURN LOWER(STRCONV(cString,15))
		ENDIF
	ENDFUNC
	
	FUNCTION GetFileSha1Hash(tcFileName AS String,tlRaw AS Boolean) AS String
		LOCAL cString
		
		IF VARTYPE(tlRaw)!="L"
			tlRaw=.F.
		ENDIF
		
		WITH THIS
			cString=.CreateFileHash(tcFileName,CALG_SHA1)
			IF VARTYPE(cString)!="C"
				* �� ����� ����������� ��������� ������, ����� ������ ������
				cString=""
			ENDIF
		ENDWITH
		
		IF tlRaw
			RETURN cString
		ELSE
			RETURN LOWER(STRCONV(cString,15))
		ENDIF
	ENDFUNC
	
	FUNCTION GetHmacMd5(tcText AS String,tcKey AS String) AS String
		LOCAL cRetVal,cInBuf,cOutBuf,nI
		
		cRetVal=""
		
		WITH THIS
			IF LEN(tcKey)>64
				tcKey=.CreateHash(tcKey,CALG_MD5)
			ENDIF
			
			tcKey=PADR(tcKey,64,CHR(0))
			cInBuf=REPLICATE(CHR(0x36),64)
			cOutBuf=REPLICATE(CHR(0x5C),64)
			
			FOR nI=1 TO 64
				cInBuf=STUFF(cInBuf,nI,1,CHR(BITXOR(ASC(SUBSTR(cInBuf,nI,1)),ASC(SUBSTR(tcKey,nI,1)))))
				cOutBuf=STUFF(cOutBuf,nI,1,CHR(BITXOR(ASC(SUBSTR(cOutBuf,nI,1)),ASC(SUBSTR(tcKey,nI,1)))))
			ENDFOR
			
			* �������� ��� �� ������ � cInBuf
			.CreateHash(cInBuf,CALG_MD5,0)
			
			* �������� ��� �� ������ tcText, ��������� ���������� ��� � ������� ���������
			cRetVal=.CreateHash(tcText,CALG_MD5,2)
			IF VARTYPE(cRetVal)!="C"
				cRetVal=""
			ENDIF
			
			* �������� ��� �� ������ � cInBuf
			.CreateHash(cOutBuf,CALG_MD5,0)
			
			* �������� ��� �� ������ cRetVal, ��������� ���������� ��� � ������� ���������
			cRetVal=.CreateHash(cRetVal,CALG_MD5,2)
			IF VARTYPE(cRetVal)!="C"
				cRetVal=""
			ENDIF
		ENDWITH
		
		RETURN LOWER(STRCONV(cRetVal,15))
	ENDFUNC
	
	PROTECTED FUNCTION CreateFileHash(tcFileName AS String,tnAlg AS Integer) AS String
		LOCAL cString,nHand,nBufLen,nFileSize,lFirst
		LOCAL nRead
		LOCAL aFile[1]
		
		* ������� ���� ��� ������
		nHand=CreateFile(tcFileName,GENERIC_READ,BITOR(FILE_SHARE_READ,FILE_SHARE_WRITE), ;
			0,OPEN_EXISTING,FILE_FLAG_SEQUENTIAL_SCAN,0)
		IF nHand<0
			RETURN .NULL.
		ENDIF
		
		* ������� ������ �����
		IF ADIR(aFile,tcFileName,"AHRS",1)=0
			CloseHandle(nHand)
			RETURN .NULL.
		ENDIF
		nFileSize=INT(aFile[1,2])
		
		* ���������: ���������� ���� ��� ������ �� ����� � �����
		nBufLen=65536
		
		cString=.NULL.
		
		lFirst=.T.
		
		WITH THIS
			* ������� ���������� ��������� �� ������ ����
			.nHashHandle=0
			
			DO WHILE .T.
				* �������� ������� ����������� ����
				nRead=0
				
				* ����� ��� ������
				cString=REPLICATE(CHR(0),nBufLen)
				
				* ��������� �� ����� �������� ���������� ����
				IF ReadFile(nHand,@cString,nBufLen,@nRead,0)=0
					CloseHandle(nHand)
					
					* ������ ������, �������
					RETURN .NULL.
				ENDIF
				
				cString=LEFT(cString,nRead)
				
				* ���� ��� ������ ��������
				IF lFirst
					* ���� ������ ����� ������ ��� ����� ������������ ������
					IF nFileSize<nBufLen OR nFileSize=nRead
						* ������� ���
						cString=.CreateHash(cString,tnAlg)
						
						* ������� �� �����
						EXIT
					ELSE
						* ����� ������ ����� �� ����������� � ������������
						.CreateHash(cString,tnAlg,0)
					ENDIF
					
					lFirst=.F.
				ELSE
					* ���� ������ ������������ ������ ��������� ������
					* ��� ��������� �� ����� 0 ����, ������ ��������
					* ����� �����
					IF nRead<nBufLen OR nRead=0
						* �������� �����������
						cString=.CreateHash(cString,tnAlg,2)
						
						* ������� �� �����
						EXIT
					ELSE
						* ��������� �����������
						.CreateHash(cString,tnAlg,1)
					ENDIF
				ENDIF
			ENDDO
		ENDWITH
		
		CloseHandle(nHand)
		
		RETURN cString
	ENDFUNC
	
	PROTECTED FUNCTION CreateHash(tcString AS String,tnAlg AS Integer,tnAdditiveCall AS Integer) AS String
		******************************************************************
		* �������������� �������� ������ tnAdditiveCall:
		*   0 - �������� ���-������� �� ������ ��� �������� �������� ����
		*   1 - ������������� ��� ���������� ���� ��� ���������������
		*       ����������� ��� �������� �������� ����
		*   2 - ������������� ��� ���������� ���� ��� ���������������
		*       ����������� � ��������� �������� ���� � ������������ ����
		******************************************************************
		LOCAL nHHash,nBufSize,cHash,nSuccess
		
		nHHash=0
		nBufSize=0
		cHash=.NULL.
		
		IF VARTYPE(tnAdditiveCall)!="N"
			tnAdditiveCall=0
		ENDIF
		
		* ���� ���������� ������ ����, ������ ��� ����������� ������ ������
		* ������� ��������� ���� �� ������, ������� ��������� �� ������ ����
		* ������� �� �������� nHashHandle, ���� �������� tnAdditiveCall �����
		* �������� 1 ��� 2
		IF PCOUNT()>2 AND INLIST(tnAdditiveCall,1,2)
			nHHash=THIS.nHashHandle
		ELSE
			* ������� ���������� �������� �� �������� ������� ����
			THIS.nHashHandle=0
			
			nSuccess=CryptCreateHash(THIS.nProvHandle,tnAlg,0,0,@nHHash)
			IF nSuccess<=0
				* �� ������ ������� ���-������, ��������� .NULL.
				RETURN .NULL.
			ENDIF
			
			* �������� �� ���������� �������� ���������
			THIS.nHashHandle=nHHash
		ENDIF
		
		* ��������� ����������� ���������� ������
		nSuccess=CryptHashData(nHHash,@tcString,LEN(tcString),0)
		IF nSuccess<=0
			CryptDestroyHash(nHHash)
			
			* ������� ���������� ��������
			THIS.nHashHandle=0
			
			* ����������� ������� ������, ����� � �� .NULL.
			RETURN .NULL.
		ENDIF
		
		* ���� ��� �� ����������� ����� ��� ����� � ��������� �������� ����
		IF PCOUNT()=2 OR (PCOUNT()>2 AND tnAdditiveCall=2)
			CryptGetHashParam(nHHash,HP_HASHVAL,0,@nBufSize,0)
			
			cHash=SPACE(nBufSize)
			CryptGetHashParam(nHHash,HP_HASHVAL,@cHash,@nBufSize,0)
			
			IF nBufSize>0
				cHash=SUBSTR(cHash,1,nBufSize)
			ENDIF
		ENDIF
		
		* ���� ��� �� ����������� ����� ��� ����� � ��������� �������� ����
		IF PCOUNT()=2 OR (PCOUNT()>2 AND tnAdditiveCall=2)
			CryptDestroyHash(nHHash)
			
			* ������� ���������� ��������
			THIS.nHashHandle=0
		ENDIF
		
		RETURN cHash
	ENDFUNC
	
	FUNCTION Encrypt(tcString AS String,tcPassword AS String) AS String
		LOCAL nHkey,nHHash,nBlobLen,cKeyBlob,nBufLen,cCryptBuf,nCryptLen,nCode
		LOCAL cRetVal,nSuccess
		
		cRetVal=""
		
		WITH THIS
			IF NOT (VARTYPE(tcPassword)="C" AND !EMPTY(tcPassword))
				tcPassword=.Password
			ELSE
				.Password=tcPassword
			ENDIF
			
			nHkey=0
			nBlobLen=0
			
			* ��������� ���������� ��������� ���������� ������
			IF EMPTY(tcPassword)
				CryptGenKey(.nProvHandle,CALG_RC2,CRYPT_EXPORTABLE,@nHkey)
				CryptExportKey(nHkey,.nExchKeyHandle,SIMPLEBLOB,0,0,@nBlobLen)
				
				cKeyBlob=SPACE(nBlobLen)
				CryptExportKey(nHkey,.nExchKeyHandle,SIMPLEBLOB,0,@cKeyBlob,@nBlobLen)
				
				.PublicKey=SUBSTR(cKeyBlob,1,nBlobLen)
			ELSE
				* �������� ��� �� ������, �� ��������� ���-������
				.CreateHash(tcPassword,CALG_MD5,0)
				
				* ������� ��������� �� ������ ����� ����������
				CryptDeriveKey(.nProvHandle,CALG_RC2,.nHashHandle,0,@nHkey)
				
				* ��������� ���-������
				CryptDestroyHash(.nHashHandle)
				* � ������� ��� ���������� ���������
				.nHashHandle=0
				
				.PublicKey=""
			ENDIF
			
			* ��������� ������ ������ ��� ����������
			nBufLen=0
			nSuccess=CryptEncrypt(nHkey,0,1,0,0,@nBufLen,0)
			IF nSuccess<=0
				IF nHkey!=0
					CryptDestroyKey(nHkey)
				ENDIF
				
				RETURN ""
			ENDIF
			
			DO WHILE .T.
				nCryptLen=LEN(tcString)
				cCryptBuf=PADR(tcString,nBufLen,CHR(0))
				nBufLen=LEN(cCryptBuf)
				
				nSuccess=CryptEncrypt(nHkey,0,1,0,@cCryptBuf,@nCryptLen,@nBufLen)
				
				IF nSuccess<=0
					nCode=GetLastError()
					
					IF nCode=ERROR_MORE_DATA
						nBufLen=nCryptLen
						LOOP
					ENDIF
					
					IF nHkey!=0
						CryptDestroyKey(nHkey)
					ENDIF
					
					RETURN ""
				ENDIF
				
				EXIT
			ENDDO
			
			cRetVal=LEFT(cCryptBuf,nCryptLen)
			
			CryptDestroyKey(nHkey)
		ENDWITH
		
		RETURN cRetVal
	ENDFUNC
	
	FUNCTION Decrypt(tcString AS String,tcPassword AS String,tcPublicKey AS String) AS String
		LOCAL nHkey,nBufLen,cRetVal,nSuccess
		
		cRetVal=""
		
		WITH THIS
			IF NOT (VARTYPE(tcPassword)="C" AND !EMPTY(tcPassword))
				tcPassword=.Password
			ELSE
				.Password=tcPassword
			ENDIF
			IF NOT (VARTYPE(tcPublicKey)="C" AND !EMPTY(tcPublicKey))
				tcPublicKey=.PublicKey
			ELSE
				.PublicKey=tcPublicKey
			ENDIF
			
			nHkey=0
			
			IF EMPTY(tcPassword)
				nSuccess=CryptImportKey(.nProvHandle,tcPublicKey,LEN(tcPublicKey),0,0,@nHkey)
				IF nSuccess<=0
					RETURN ""
				ENDIF
			ELSE
				* �������� ��� �� ������, �� ��������� ���-������
				.CreateHash(tcPassword,CALG_MD5,0)
				
				* ������� ��������� �� ������ ����� ����������
				CryptDeriveKey(.nProvHandle,CALG_RC2,.nHashHandle,0,@nHkey)
				
				* ��������� ���-������
				CryptDestroyHash(.nHashHandle)
				* � ������� ��� ���������� ���������
				.nHashHandle=0
			ENDIF
			
			* ���������� ����� ��� ������������
			cRetVal=tcString
			
			* ��������� ������������ ���������� ������
			nBufLen=LEN(cRetVal)
			nSuccess=CryptDecrypt(nHkey,0,1,0,@cRetVal,@nBufLen)
			IF nSuccess<=0
				cRetVal=""
			ELSE
				cRetVal=LEFT(cRetVal,nBufLen)
			ENDIF
			
			CryptDestroyKey(nHkey)
		ENDWITH

		RETURN cRetVal
	ENDFUNC
ENDDEFINE
