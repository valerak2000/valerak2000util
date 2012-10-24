*** Basic send Email to an SMTP server with sockets
#INCLUDE wconnect.h

*************************************************************
DEFINE CLASS wwPOP3 AS Relation
*************************************************************
*: Author: Rick Strahl
*:         (c) West Wind Technologies, 2001
*:Contact: http://www.west-wind.com
*:Created: 09/03/2001
*************************************************************
*!*	#IF .T.
*!*	*:Help Documentation
*!*	*:Topic:
*!*	Class wwPOP3

*!*	*:Description:
*!*	*:Example:
*!*	*:Remarks:
*!*	*:SeeAlso:
*!*	*:ENDHELP
*!*	#ENDIF

*** Custom Properties
	oIP = .NULL.

	cMailServer = ""
	nPort = 110
	cUsername = ""
	cPassword = ""

	lLogSession = .F.

	nError = 0
	lError = .f.
	cErrorMsg = ""

	nTimeout = 10
	nBufferSize = 512

	nMessageCount = 0
	DIMENSION aMessages[1]

************************************************************************
* wwPOP3 :: Connect
****************************************
***  Function: Connects to the POP server and logs in
***            Sets the message count
***    Assume: user name and password are set
***      Pass:
***    Return:
************************************************************************
FUNCTION Connect
	THIS.oIP = NEWOBJECT("wwSocket", "..\lib\wwIPStuff")
	THIS.oIP.lStripNulls = .t.
	THIS.OIP.lLogSession = THIS.lLogSession
	THIS.oIP.nBufferSize = THIS.nBufferSize
	THIS.oIP.nTimeout = THIS.nTimeout

	loIP = THIS.oIP
	IF !loIP.Connect(THIS.cMailserver,THIS.nPort)
	   THIS.SetError(loIP.cErrorMsg)
	   RETURN .F.
	ENDIF

	*** Retrieve Hello Message
	lcResult = loIP.Receive()
	IF EMPTY(lcResult)
	   RETURN .F.
	ENDIF

	lcResult = loIP.SendReceive("USER " + THIS.cUsername +  CRLF)
	IF lcResult # "+"
	   THIS.SetError("Login failed: " + SUBSTR(lcResult,2))
	   RETURN .F.
	ENDIF

	lcResult = loIP.SendReceive("PASS " + THIS.cPassword + CRLF)
	IF lcResult # "+"
	   THIS.SetError("Login failed: " + SUBSTR(lcResult,2))
	   RETURN .F.
	ENDIF

	IF  "has " $ lcResult AND " message" $ lcResult
	   THIS.nMessageCount = VAL( EXTRACT(lcResult,"has "," message") )
	ELSE
	   *** Try again to get count with LIST command
	   lcResult = loIP.SendReceive("STAT" + CRLF)
	   
	   THIS.nMessageCount = VAL( EXTRACT(lcResult,"OK "," ") )
	ENDIF

	IF THIS.nMessageCount > 0
	   *** Pre-size the array
	   DIMENSION THIS.aMessages[THIS.nMessageCount]
	ENDIF

	RETURN .T.
ENDFUNC
*  wwPOP3 :: Connect

************************************************************************
* wwPop3 :: GetMessages
****************************************
***  Function: Retrieves all messages into an array of message
***            objects.
***    Assume:
***      Pass: @lamessages  -  Array to
***            llNoParseAttachments  -  Determines whether attachments
***                                     are parsed and Decoded
***    Return: Message Count
************************************************************************
FUNCTION GetMessages(llNoParseAttachments,llDeleteMessages)
LOCAL x, loMsg, lnMsgs

	lnMsgs = 0
	FOR m.x =1 TO THIS.nMessageCount
	  loMsg = THIS.GetMessage(m.x)
	  IF !ISNULL(loMsg) AND !llNoParseAttachments
	     THIS.ParseMultiPartMessage(loMsg)  
	  ENDIF
	  IF llDeleteMessages
	     THIS.DeleteMessage(m.x)
	  ENDIF
	ENDFOR

	RETURN THIS.nMessageCount
ENDFUNC
*  wwPop3 :: GetMessages


************************************************************************
* wwPop3 :: GetMessageById
****************************************
***  Function: Returns a message number from its message ID
***    Assume: 
***      Pass: Message Id: The string Message ID from the SMTP header
***    Return: message number or 0 on failure
************************************************************************
FUNCTION GetMessageNumberFromId(lcMsgId)
LOCAL x, lnMessage

	lnMessage = 0

	*** Run through message headers and try to find MsgID
	FOR m.x=1 TO this.nMessageCount
	   loMsg = THIS.GetMessageHeader(m.x)
	   IF loMsg.cMsgId == lcMsgId
	      lnMessage = m.x
	      EXIT
	   ENDIF
	ENDFOR

	RETURN lnMessage
ENDFUNC
*  wwPop3 :: GetMessageById


************************************************************************
* wwPOP3 :: GetMessage
****************************************
***  Function: Retrieves a message from the server by its message number (order)
***    Assume: message is returned and stored into the msg array
***      Pass: lnMessage   -   Message Id
***    Return: Message object or NULL
************************************************************************
FUNCTION GetMessage(lnMessage)
LOCAL lcResult, lcMessage, loMsg,x

	IF VARTYPE(lnMessage) = "C"
	   lnMessage = THIS.GetMessageNumberFromID(lnMessage)
	ENDIF

	*** Read the message Prefix  +OK x octets
	lcResult =  THIS.oIP.SendReceive("RETR " + TRANSFORM(lnMessage) + CRLF)
	IF lcResult # "+"
	   THIS.SetError(SUBSTR(lcResult,2))
	   RETURN .NULL.
	ENDIF   
	IF EMPTY(lcResult)
	   THIS.SetError("Timed out.",THIS.oIP.nError)
	   RETURN .NULL.
	ENDIF

	*** Now read the message until we get the server's . alone
	lcMessage = lcResult
	DO WHILE ATC(CRLF + "." + CHR(13),lcMessage) < 1 AND ATC(" ." + CHR(13),lcMessage) < 1
	   *** Can't search for CRLF + "." CRLF because 
	   *** some mail servers will send the . CRLF on their own
	   lcResult = THIS.oIp.WaitFor( "." + CHR(13))  

	   IF EMPTY(lcResult) AND THIS.oIP.nError # 0
	      THIS.SetError("Timed out getting messages")
	      RETURN .NULL. 
	   ENDIF
	   lcMessage = lcMessage + lcResult
	ENDDO

	*** Create and store the message
	loMsg = THIS.ParseMessageHeader(lcMessage)

	loMsg.nSize = LEN(loMsg.cBody)
	loMsg.cFullText = lcMessage

	THIS.aMessages[lnMessage] = loMsg

RETURN loMsg
*  wwPOP3 :: GetMessage

************************************************************************
* wwPOP3 :: GetMessageHeader
****************************************
***  Function: Retrieves a message from the server
***    Assume: message is returned and stored into the msg array
***      Pass: lnMessage   -   Message Id
***    Return: Message object or NULL
************************************************************************
FUNCTION GetMessageHeader(lnMessage)

	*** Read the message Prefix  +OK x octets
	lcResult =  THIS.oIP.SendReceive("TOP " + TRANSFORM(lnMessage) + " 1"  + CRLF)
	IF lcResult # "+"
	   THIS.SetError(SUBSTR(lcResult,2))
	   RETURN .NULL.
	ENDIF   
	IF EMPTY(lcResult)
	   THIS.SetError("Timed out",THIS.oIP.nError)
	   RETURN .NULL.
	ENDIF

	*** Now read the message until we get the server's . alone
	lcMessage = lcResult
	IF ATC(CRLF + "." ,lcMessage) < 1
	   lcResult = THIS.oIp.WaitFor(CRLF + "." + CRLF)
	   IF THIS.oIP.nError # 0
	      THIS.SetError("Timed out getting message " + TRANSFORM(lnMessage))
	      EXIT
	   ENDIF   
	   lcMessage = lcMessage + lcResult
	ENDIF

	lcResult =  THIS.oIP.SendReceive("LIST " + TRANSFORM(lnMessage) +  CRLF)
	lnSize = VAL( STRTRAN(lcResult,"+OK " + TRANSFORM(lnMessage) + " ","") )

	loMsg = THIS.ParseMessageHeader(lcMessage)
	loMsg.nSize = lnSize

	THIS.aMessages[lnMessage] = loMsg

RETURN loMsg
*  wwPOP3 :: GetMessageHeader

************************************************************************
* wwPop3 :: ParseMessageHeader
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION ParseMessageHeader(lcMessage)
LOCAL lnAt, loMsg, lnParens, lcFrom, lnBrackets

	*** Create and store the message
	loMsg = THIS.CreateMessageObject()
	loMsg.cBody = Extract(lcMessage,CRLF+CRLF,CRLF + "." +CRLF," ." + CRLF)

	*** Parse the From Name
	lcFrom = Extract(lcMessage,CRLF + "From: ",'>'+CRLF)+'>'
	lnBrackets = ATC("<",lcFrom)
	lnParens = ATC("(",lcFrom)
	DO CASE
	CASE  lnBrackets > 0
	   loMsg.cFromEmail = Extract(lcFrom,"<",">")
	   IF lnBrackets > 2
	     loMsg.cFromName = STRTRAN( LEFT(lcFrom,lnBrackets-1),'"',"" )
	   ELSE
	      loMsg.cFromName = loMsg.cFromEmail
	   ENDIF
	CASE lnParens > 0
	   loMsg.cFromName = Extract(lcFrom,"(",")")
	   IF lnParens > 2
	     loMsg.cFromEmail = ALLTRIM(STRTRAN( LEFT(lcFrom,lnParens-1),'"',"" ))
	   ELSE
	      loMsg.cFromEmail = ALLTRIM(lcFrom)
	   ENDIF
	 
	OTHERWISE 
	    loMsg.cFromName = STRTRAN(lcFrom,'"',"")
	    loMsg.cFromEmail = loMsg.cFromName
	ENDCASE

	IF EMPTY(loMsg.cFromName)
	   loMsg.cFromName = loMsg.cFromEmail
	ENDIF

	loMsg.cTo = ALLTRIM(Extract(lcMessage,"To:",CRLF))
	loMsg.cTo = CHRTRAN(loMsg.cTo,"<>()[]","")
	loMsg.cSubject = ALLTRIM(Extract(lcMessage,"Subject:",CRLF))
	loMsg.nSize = LEN(loMsg.cBody)
	loMsg.cContentType = ALLTRIM( EXTRACT(lcMessage,"Content-Type:",";",CRLF))
	loMsg.cGlobalContentType = loMsg.cContentType  
	loMsg.cMultipartBoundary = CHRTRAN(Extract(lcMessage,[boundary=],CRLF),["],[])
	loMsg.cEncoding = ALLTRIM(STRTRAN( EXTRACT(lcMessage,"Content-Transfer-Encoding:",CRLF),";",""))
	loMsg.cDate = Extract(lcMessage,"Date: ",CRLF)
	loMsg.dDate = MimeDateTime(loMsg.cDate)
	loMsg.cMsgId = ALLTRIM(EXTRACT(lcMessage,"Message-ID:",CRLF))
	   
	loMsg.cFullText = lcMessage

	RETURN loMSG 
ENDFUNC
*  wwPop3 :: ParseMessageHeader

************************************************************************
* wwPop3 :: ParseMultiPartMessage
****************************************
***  Function: Parses the cBody property of a message and creates
***            an array of attachments if 
***    Assume: Follows a call to GetMessage
***      Pass:
***    Return:
************************************************************************
FUNCTION ParseMultiPartMessage(loMsg)
LOCAL x, lnParts

	DIMENSION laParts[1]
	lnParts = APARSESTRING(@laParts,loMsg.cBody,loMsg.cMultipartBoundary)
	*lnParts = ALINES(laParts,loMsg.cBody,loMsg.cMultipartBoundary)
	IF lnParts = 0
	   *** No attachments
	   RETURN 
	ENDIF

	lnGotParts = 0
	FOR m.x = 1 TO lnParts
	   lcPart = laParts[m.x]
	   lcContentType = STRTRAN( Extract(lcPart,"Content-Type: ",CHR(13)),";","")
	   IF !EMPTY(lcContentType)
	      loAttachment = THIS.CreateAttachmentObject()
	      *** Strip off trailing "--" MIME chars
	      IF RIGHT(lcPart,2) = "--"
	         lcPart = SUBSTR(lcPart,1,LEN(lcPart)-2)
	      ENDIF
	      IF EMPTY(lcPart)
	         LOOP
	      ENDIF
	      
	      lnGotParts = lnGotParts + 1
	      
	      loAttachment.cContentType = STRTRAN( Extract(lcPart,"Content-Type: ",CHR(13)),";","")
	      loAttachment.cEncoding = LOWER(Extract(lcPart,"Content-Transfer-Encoding: ",CHR(13)))
	      loAttachment.cFileName = Extract(lcPart,[filename="],["])

	      loAttachment.cBody = Extract(lcPart,CRLF+CRLF,WWC_NULLSTRING,,.T.)
	      
	      IF loAttachment.cContentType = "multipart/alternative"
	         *** Boundary changes
	         lcAltBoundary = EXTRACT(lcPart,[boundary="],["])
	         DIMENSION laAltParts[1]
	         lnAltParts = APARSESTRING(@laAltParts,loAttachment.cBody,lcAltBoundary)
	         lnGotParts = lnGotParts - 1  && Start over

	         FOR y = 2 TO lnAltParts
	            loAttachment = THIS.CreateAttachmentObject()
	            
	            lcPart = laAltParts[y]
	            
	            *** Strip off trailing "--" MIME chars
	            IF RIGHT(lcPart,2) = "--"
	               lcPart = SUBSTR(lcPart,1,LEN(lcPart)-2)
	            ENDIF
	            
	            IF EMPTY(lcPart)
	               LOOP
	            ENDIF
	            
	            lnGotParts = lnGotParts + 1

	            loAttachment.cContentType = STRTRAN( Extract(lcPart,"Content-Type: ",CHR(13)),";","")
	            loAttachment.cEncoding = LOWER(Extract(lcPart,"Content-Transfer-Encoding: ",CHR(13)))
	            loAttachment.cFileName = Extract(lcPart,[filename="],["])

	            loAttachment.cBody = Extract(lcPart,CRLF+CRLF,WWC_NULLSTRING,,.T.)
	            THIS.DecodeMessagePart(loAttachment)
	            loAttachment.nSize = LEN(loAttachment.cBody)
	            IF lnGotParts > 1
	               DIMENSION loMsg.aAttachments[lnGotParts -1]
	               loMsg.aAttachments[lnGotParts-1] = loAttachment
	            ELSE
	               loMsg.cBody = loAttachment.cBody
	               loMsg.cContentType = loAttachment.cContentType
	            ENDIF
	         ENDFOR
	         LOOP
	      ENDIF
	      
	      THIS.DecodeMessagePart(loAttachment)
	      
	      loAttachment.nSize = LEN(loAttachment.cBody)
	      
	      IF lnGotParts > 1
	         DIMENSION loMsg.aAttachments[lnGotParts -1]
	         loMsg.aAttachments[lnGotParts-1] = loAttachment
	      ELSE
	         loMsg.cBody = loAttachment.cBody
	         loMsg.cContentType = loAttachment.cContentType
	      ENDIF
	   ENDIF
	ENDFOR

	loMsg.nAttachments = lnGotParts -1 
	IF loMsg.nAttachments < 0 
	   loMsg.nAttachments = 0
	ENDIF

	*** Fix up text message
	IF loMsg.nAttachments = 0 AND loMsg.cEncoding = "quoted-printable"
	   loMsg.cBody = STRTRAN(loMsg.cBody,"=20" )
	   loMsg.cBody = STRTRAN(loMsg.cBody,"=" + CHR(13) + CHR(10) )  && 75 char breaks
	   loMsg.cBody = STRTRAN(loMsg.cBody,"=" + CHR(13) )  && 75 char breaks
	   loMsg.cBody = STRTRAN(loMsg.cBody,"=3D","=")
	ENDIF
ENDFUNC
*  wwPop3 :: ParseMultiPartMessage

************************************************************************
* wwPOP3 :: DecodeMessagePart
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION DecodeMessagePart(loAttachment)
	DO CASE
	CASE loAttachment.cEncoding = "base64" 
      loAttachment.cbody = STRCONV(loAttachment.cBody,14)
	CASE loAttachment.cEncoding = "quoted-printable"
	   loAttachment.cBody = STRTRAN(loAttachment.cBody,"=20" )
	   loAttachment.cBody = STRTRAN(loAttachment.cBody,"=" + CHR(13) + CHR(10) )  && 75 char breaks
	   loAttachment.cBody = STRTRAN(loAttachment.cBody,"=" + CHR(13) )  && 75 char breaks
	   loAttachment.cBody = STRTRAN(loAttachment.cBody,"=3D","=")
	ENDCASE
ENDFUNC
*  wwPOP3 :: DecodeMessagePart


************************************************************************
* wwPOP3 :: DeleteMessage
****************************************
***  Function: Deletes a message by message number. Note this 
***            will change the order of messages and you'll have
***            reload the list to get new message number lists
***    Assume:
***      Pass: lnMessage   -   Message number
***    Return:
************************************************************************
FUNCTION DeleteMessage(lnMessage)
	IF EMPTY(lnMessage)
	   RETURN .F.
	ENDIF

	IF VARTYPE(lnMessage) = "C"
	   lnMessage = THIS.GetMessageNumberFromID(lnMessage)
	   IF lnMessage=0
	      THIS.SetError("Couldn't delete message. Invalid Message Id.")
	      RETURN .F.
	   ENDIF
	ENDIF

	lcResult = THIS.oIP.SendReceive("DELE " + TRANSFORM(lnMessage) +CRLF )

	IF lcResult # "+"
	   THIS.SetError(SUBSTR(lcResult,2))
	   RETURN .F.
	ENDIF   
ENDFUNC
*  wwPOP3 :: DeleteMessage

FUNCTION Quit
	IF !ISNULL(THIS.oIP)
	   THIS.oIP.SendReceive("QUIT" + CRLF)
	   THIS.oIp.Close()
	ENDIF
ENDFUNC

************************************************************************
* wwPOP3 :: CreateMessageObject
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION CreateMessageObject
	loMsg = CREATEOBJECT("Relation")
	loMsg.AddProperty("cSubject","")
	loMsg.AddProperty("cBody","")
	loMsg.AddProperty("cFromName","")
	loMsg.AddProperty("cFromEmail","")
	loMsg.AddProperty("cTo","")
	loMsg.AddProperty("nSize","")
	loMsg.AddProperty("cContentType","")
	loMsg.AddProperty("cGlobalContentType","")
	loMsg.AddProperty("cEncoding","")
	loMsg.AddProperty("cMultiPartBoundary","")
	loMsg.AddProperty("cFullText","")
	loMsg.AddProperty("cDate","")
	loMsg.AddProperty("dDate",{ : })
	loMsg.AddProperty("cMsgId","")
	loMsg.AddProperty("nAttachments",0)
	loMsg.AddProperty("aAttachments(1)","")

	RETURN loMsg
ENDFUNC
*  wwPOP3 :: CreateMessageObject

************************************************************************
* wwPop3 :: CreateAttachmentObject
****************************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION CreateAttachmentObject()
LOCAL loAttachment
	loAttachment = CREATEOBJECT("Relation")
	loAttachment.AddProperty("cFilename","")
	loAttachment.AddProperty("nSize",0)
	loAttachment.AddProperty("cBody","")
	loAttachment.AddProperty("cContentType","")
	loAttachment.AddProperty("cEncoding","")
	loAttachment.AddProperty("cAltBoundary","")

	RETURN loAttachment
ENDFUNC
*  wwPop3 :: CreateAttachmentObject

************************************************************************
* wwPOP3 :: SetError
****************************************
***  Function: Logs errors
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION SetError
LPARAMETERS lcError, lnError

	IF EMPTY(lnError)
	   lnError = 0
	ENDIF

	IF EMPTY(lcError)
	   THIS.lError = .F.
	   THIS.cErrorMsg = ""
	   THIS.nError = 0
	ELSE
	   THIS.lError = .T.
	   THIS.cErrorMsg = lcError
	   THIS.nError = lnError
	ENDIF      
*  wwPOP3 :: SetError

************************************************************************
* wwPop3 :: Destroy
****************************************
***  Function: Shuts down the POP3 session.
***    Return: 
************************************************************************
FUNCTION Destroy()
	THIS.Quit()
ENDFUNC
*  wwPop3 :: Destroy

PROTECTED FUNCTION nBufferSize_Assign(lnSize)
	IF !ISNULL(THIS.oIP)
	  THIS.oIP.nBufferSize = lnSize
	ENDIF
	THIS.nBufferSize = lnSize
	RETURN 

	PROTECTED FUNCTION nTimeout_Assign(lnTimeout)
	IF !ISNULL(THIS.oIP)
	  THIS.oIP.nTimeout = lnTimeout
	ENDIF
	THIS.nTimeout = lnTimeout
	RETURN 

FUNCTION INIT
	IF AT("wwUTILS", SET("Procedure"))=0
		SET PROCEDURE TO wwUTILS additive
	ENDIF
	IF AT("wwAPI", SET("Procedure"))=0
		SET PROCEDURE TO wwAPI additive
	ENDIF
ENDFUNC

ENDDEFINE