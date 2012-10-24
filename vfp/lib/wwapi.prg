#INCLUDE WCONNECT.H

#DEFINE MAX_INI_BUFFERSIZE  		512
#DEFINE MAX_INI_ENUM_BUFFERSIZE 	8196

*************************************************************
DEFINE CLASS wwAPI AS Custom
*************************************************************
***    Author: Rick Strahl
***            (c) West Wind Technologies, 1997
***   Contact: (541) 386-2087  / rstrahl@west-wind.com
***  Function: Encapsulates several Windows API functions
*************************************************************

*** Custom Properties
nLastError=0

FUNCTION Init
************************************************************************
* wwAPI :: Init
*********************************
***  Function: DECLARES commonly used DECLAREs so they're not redefined
***            on each call to the methods.
************************************************************************

DECLARE INTEGER GetPrivateProfileString ;
   IN WIN32API ;
   STRING cSection,;
   STRING cEntry,;
   STRING cDefault,;
   STRING @cRetVal,;
   INTEGER nSize,;
   STRING cFileName

DECLARE INTEGER GetCurrentThread ;
   IN WIN32API 
   
DECLARE INTEGER GetThreadPriority ;
   IN WIN32API ;
   INTEGER tnThreadHandle

DECLARE INTEGER SetThreadPriority ;
   IN WIN32API ;
   INTEGER tnThreadHandle,;
   INTEGER tnPriority

*** Open Registry Key
DECLARE INTEGER RegOpenKey ;
        IN Win32API ;
        INTEGER nHKey,;
        STRING cSubKey,;
        INTEGER @nHandle

*** Create a new Key
DECLARE Integer RegCreateKey ;
        IN Win32API ;
        INTEGER nHKey,;
        STRING cSubKey,;
        INTEGER @nHandle

*** Close an open Key
DECLARE Integer RegCloseKey ;
        IN Win32API ;
        INTEGER nHKey
  
ENDFUNC
* Init

FUNCTION MessageBeep
************************************************************************
* wwAPI :: MessageBeep
**********************
***  Function: MessageBeep API call runs system sounds
***      Pass: lnSound   -   Uses FoxPro.h MB_ICONxxxxx values
***    Return: nothing
************************************************************************
LPARAMETERS lnSound
DECLARE INTEGER MessageBeep ;
   IN WIN32API AS MsgBeep ;
   INTEGER nSound
=MsgBeep(lnSound)
ENDFUNC
* MessageBeep

FUNCTION ReadRegistryString
************************************************************************
* wwAPI :: ReadRegistryString
*********************************
***  Function: Reads a string value from the registry.
***      Pass: tnHKEY    -  HKEY value (in CGIServ.h)
***            tcSubkey  -  The Registry subkey value
***            tcEntry   -  The actual Key to retrieve
***            tlInteger -  Optional - Return an DWORD value
***    Return: Registry String or .NULL. on not found
************************************************************************
LPARAMETERS tnHKey, tcSubkey, tcEntry, tlInteger
LOCAL lnRegHandle, lnResult, lnSize, lcDataBuffer, tnType

tnHKey=IIF(vartype(tnHKey)="N",tnHKey,HKEY_LOCAL_MACHINE)

lnRegHandle=0

*** Open the registry key
lnResult=RegOpenKey(tnHKey,tcSubKey,@lnRegHandle)
IF lnResult#ERROR_SUCCESS
   *** Not Found
   RETURN .NULL.
ENDIF   

*** Return buffer to receive value
IF !tlInteger
*** Need to define here specifically for Return Type
*** for lpdData parameter or VFP will choke.
*** Here it's STRING.
DECLARE INTEGER RegQueryValueEx ;
        IN Win32API ;
        INTEGER nHKey,;
        STRING lpszValueName,;
        INTEGER dwReserved,;
        INTEGER @lpdwType,;
        STRING @lpbData,;
        INTEGER @lpcbData
        
	lcDataBuffer=space(MAX_INI_BUFFERSIZE)
	lnSize=LEN(lcDataBuffer)
	lnType=REG_DWORD

	lnResult=RegQueryValueEx(lnRegHandle,tcEntry,0,@lnType,;
                         @lcDataBuffer,@lnSize)
ELSE
*** Need to define here specifically for Return Type
*** for lpdData parameter or VFP will choke. 
*** Here's it's an INTEGER
DECLARE INTEGER RegQueryValueEx ;
        IN Win32API AS RegQueryInt;
        INTEGER nHKey,;
        STRING lpszValueName,;
        INTEGER dwReserved,;
        Integer @lpdwType,;
        INTEGER @lpbData,;
        INTEGER @lpcbData

	lcDataBuffer=0
	lnSize=4
	lnType=REG_DWORD
	lnResult=RegQueryInt(lnRegHandle,tcEntry,0,@lnType,;
	                         @lcDataBuffer,@lnSize)
	IF lnResult = ERROR_SUCCESS
	   RETURN lcDataBuffer
	ELSE
       RETURN -1
	ENDIF
ENDIF
=RegCloseKey(lnRegHandle)

IF lnResult#ERROR_SUCCESS 
   *** Not Found
   RETURN .NULL.
ENDIF   

IF lnSize<2
   RETURN ""
ENDIF
   
*** Return string and strip out NULLs
RETURN SUBSTR(lcDataBuffer,1,lnSize-1)
ENDFUNC
* ReadRegistryString

************************************************************************
* Registry :: WriteRegistryString
*********************************
***  Function: Writes a string value to the registry.
***            If the value doesn't exist it's created. If the key
***            doesn't exist it is also created, but this will only
***            succeed if it's the last key on the hive.
***      Pass: tnHKEY    -  HKEY value (in WCONNECT.h)
***            tcSubkey  -  The Registry subkey value
***            tcEntry   -  The actual Key to write to
***            tcValue   -  Value to write or .NULL. to delete key
***            tlCreate  -  Create if it doesn't exist
***    Assume: Use with extreme caution!!! Blowing your registry can
***            hose your system!
***    Return: .T. or .NULL. on error
************************************************************************
FUNCTION WriteRegistryString
LPARAMETERS tnHKey, tcSubkey, tcEntry, tcValue,tlCreate
LOCAL lnRegHandle, lnResult, lnSize, lcDataBuffer, tnType

tnHKey=IIF(type("tnHKey")="N",tnHKey,HKEY_LOCAL_MACHINE)

lnRegHandle=0

lnResult=RegOpenKey(tnHKey,tcSubKey,@lnRegHandle)
IF lnResult#ERROR_SUCCESS
   IF !tlCreate
      RETURN .F.
   ELSE
      lnResult=RegCreateKey(tnHKey,tcSubKey,@lnRegHandle)
      IF lnResult#ERROR_SUCCESS
         RETURN .F.
      ENDIF  
   ENDIF
ENDIF   

*** Need to define here specifically for Return Type!
*** Here lpbData is STRING.
DECLARE INTEGER RegSetValueEx ;
        IN Win32API ;
        INTEGER nHKey,;
        STRING lpszEntry,;
        INTEGER dwReserved,;
        INTEGER fdwType,;
        STRING lpbData,;
        INTEGER cbData

*** Check for .NULL. which means delete key
IF !ISNULL(tcValue)
  *** Nope - write new value
  lnSize=LEN(tcValue)
  if lnSize=0
     tcValue=CHR(0)
  ENDIF

  lnResult=RegSetValueEx(lnRegHandle,tcEntry,0,REG_SZ,;
                         tcValue,lnSize)
ELSE
  *** Delete a value from a key
  DECLARE INTEGER RegDeleteValue ;
          IN Win32API ;
          INTEGER nHKEY,;
          STRING cEntry

  *** DELETE THE KEY
  lnResult=RegDeleteValue(lnRegHandle,tcEntry)
ENDIF                         

=RegCloseKey(lnRegHandle)
                        
IF lnResult#ERROR_SUCCESS
   RETURN .F.
ENDIF   

RETURN .T.
ENDPROC
* WriteRegistryString

FUNCTION EnumKey
************************************************************************
* wwAPI :: EnumRegistryKey
*********************************
***  Function: Returns a registry key name based on an index
***            Allows enumeration of keys in a FOR loop. If key
***            is empty end of list is reached.
***      Pass: tnHKey    -   HKEY_ root key
***            tcSubkey  -   Subkey string
***            tnIndex   -   Index of key name to get (0 based)
***    Return: "" on error - Key name otherwise
************************************************************************
LPARAMETERS tnHKey, tcSubKey, tnIndex 
LOCAL lcSubKey, lcReturn, lnResult, lcDataBuffer

lnRegHandle=0

*** Open the registry key
lnResult=RegOpenKey(tnHKey,tcSubKey,@lnRegHandle)
IF lnResult#ERROR_SUCCESS
   *** Not Found
   RETURN .NULL.
ENDIF   

DECLARE Integer RegEnumKey ;
  IN WIN32API ;
  INTEGER nHKey, ;
  INTEGER nIndex, ;
  STRING @cSubkey, ;  
  INTEGER nSize

lcDataBuffer=SPACE(MAX_INI_BUFFERSIZE)
lnSize=MAX_INI_BUFFERSIZE
lnResult=RegENumKey(lnRegHandle, tnIndex, @lcDataBuffer, lnSize)

=RegCloseKey(lnRegHandle)

IF lnResult#ERROR_SUCCESS 
   *** Not Found
   RETURN .NULL.
ENDIF   

RETURN TRIM(CHRTRAN(lcDataBuffer,CHR(0),""))
ENDFUNC
* EnumRegistryKey


FUNCTION GetProfileString
************************************************************************
* wwAPI :: GetProfileString
***************************
***  Modified: 09/26/95
***  Function: Read Profile String information from a given
***            text file using Windows INI formatting conventions
***      Pass: pcFileName   -    Name of INI file
***            pcSection    -    [Section] in the INI file ("Drivers")
***            pcEntry      -    Entry to retrieve ("Wave")
***                              If this value is a null string
***                              all values for the section are
***                              retrieved seperated by CHR(13)s
***    Return: Value(s) or .NULL. if not found
************************************************************************
LPARAMETERS pcFileName,pcSection,pcEntry, pnBufferSize
LOCAL lcIniValue, lnResult

*pcFileName=IIF(TYPE("pcFileName")="C",pcFileName,"")
*pcSection=IIF(TYPE("pcSection")="C",pcSection,"")

*** Default to 0, which means all entries!
*pcEntry=IIF(TYPE("pcEntry")="C",pcEntry,0)

*** Initialize buffer for result
lcIniValue=SPACE(IIF( type("pnBufferSize")="N",pnBufferSize,MAX_INI_BUFFERSIZE) )

lnResult=GetPrivateProfileString(pcSection,pcEntry,"*None*",;
   @lcIniValue,LEN(lcIniValue),pcFileName)

*** Strip out Nulls
IF TYPE("pcEntry")="N" AND pcEntry=0
   *** 0 was passed to get all entry labels
   *** Seperate all of the values with a Carriage Return
   lcIniValue=TRIM(CHRTRAN(lcIniValue,CHR(0),CHR(13)) )
ELSE
   *** Individual Entry
   lcIniValue=SUBSTR(lcIniValue,1,lnResult)
ENDIF

*** On error the result contains "*None"
IF lcIniValue="*None*"
   lcIniValue=.NULL.
ENDIF

RETURN lcIniValue
ENDFUNC
* GetProfileString

************************************************************************
* wwAPI :: GetProfileSections
*********************************
***  Function: Retrieves all sections of an INI File
***      Pass: @laSections   -   Empty array to receive sections
***            lcIniFile     -   Name of the INI file
***            lnBufSize     -   Size of result buffer (optional)
***    Return: Count of Sections  
************************************************************************
FUNCTION aProfileSections
LPARAMETERS laSections, lcIniFile
LOCAL lnBufsize, lcBuffer, lnSize, lnResult, lnCount

lnBufsize=IIF(EMPTY(lnBufsize),16484,lnBufsize)

DECLARE INTEGER GetPrivateProfileSectionNames ;
   IN WIN32API ;
   STRING @lpzReturnBuffer,;
   INTEGER nSize,;
   STRING lpFileName
   
lcBuffer = SPACE(lnBufSize)
lnSize = lEN(lcBuffer)   
lnResult = GetPrivateProfileSectionNames(@lcBuffer,lnSize,lcIniFile)
IF lnResult < 3
   RETURN 0
ENDIF

lnCount = aParseString(@laSections,TRIM(lcBuffer),CHR(0))
lnCount = lnCount - 2
IF lnCount > 0
  DIMENSION laSections[lnCount]
ENDIF

RETURN lnCount
ENDFUNC
* wwAPI :: aProfileSections

************************************************************************
* wwAPI :: WriteProfileString
*********************************
***  Function: Writes a value back to an INI file
***      Pass: pcFileName    -   Name of the file to write to
***            pcSection     -   Profile Section
***            pcKey         -   The key to write to
***            pcValue       -   The value to write
***    Return: .T. or .F.
************************************************************************
FUNCTION WriteProfileString
LPARAMETERS pcFileName,pcSection,pcEntry,pcValue

   DECLARE INTEGER WritePrivateProfileString ;
      IN WIN32API ;
      STRING cSection,STRING cEntry,STRING cEntry,;
      STRING cFileName

   lnRetVal=WritePrivateProfileString(pcSection,pcEntry,pcValue,pcFileName)

   if lnRetval=1
      RETURN .t.
   endif
   
   RETURN .f.
ENDFUNC
* WriteProfileString

FUNCTION GetTempPath
************************************************************************
* wwAPI :: GetTempPath
***********************
***  Function: Returns the OS temporary files path
***    Return: Temp file path with trailing "\"
************************************************************************
LOCAL lcPath, lnResult

*** API Definition:
*** ---------------
*** DWORD GetTempPath(cchBuffer, lpszTempPath)
***
*** DWORD cchBuffer;	/* size, in characters, of the buffer	*/
*** LPTSTR lpszTempPath;	/* address of buffer for temp. path name	*/
DECLARE INTEGER GetTempPath ;
   IN WIN32API AS GetTPath ;
   INTEGER nBufSize, ;
   STRING @cPathName

lcPath=SPACE(256)
lnSize=LEN(lcPath)

lnResult=GetTPath(lnSize,@lcPath)

IF lnResult=0
   lcPath=""
ELSE
   lcPath=SUBSTR(lcPath,1,lnResult)
ENDIF

RETURN lcPath
ENDFUNC
* eop GetTempPath

FUNCTION GetEXEFile
************************************************************************
* wwAPI :: GetEXEFileName
*********************************
***  Function: Returns the Module name of the EXE file that started
***            the current application. Unlike Application.Filename
***            this function correctly returns the name of the EXE file
***            for Automation servers too!
***    Return: Filename or ""  (VFP.EXE is returned in Dev Version)
************************************************************************
DECLARE integer GetModuleFileName ;
   IN WIN32API ;
   integer hinst,;
   string @lpszFilename,;
   integer @cbFileName
   
lcFilename=space(256)
lnBytes=255   

=GetModuleFileName(0,@lcFileName,@lnBytes)

lnBytes=AT(CHR(0),lcFileName)
IF lnBytes > 1
  lcFileName=SUBSTR(lcFileName,1,lnBytes-1)
ELSE
  lcFileName=""
ENDIF       

RETURN lcFileName
ENDFUNC
* GetEXEFileName


************************************************************************
* WinApi :: ShellExecute
*********************************
***    Author: Rick Strahl, West Wind Technologies
***            http://www.west-wind.com/ 
***  Function: Opens a file in the application that it's
***            associated with.
***      Pass: lcFileName  -  Name of the file to open
***            lcWorkDir   -  Working directory
***            lcOperation -  
***    Return: 2  - Bad Association (invalid URL)
***            31 - No application association
***            29 - Failure to load application
***            30 - Application is busy 
***
***            Values over 32 indicate success
***            and return an instance handle for
***            the application started (the browser) 
************************************************************************
***         FUNCTION ShellExecute
***         LPARAMETERS lcFileName, lcWorkDir, lcOperation
***         
***         lcWorkDir=IIF(type("lcWorkDir")="C",lcWorkDir,"")
***         lcOperation=IIF(type("lcOperation")="C",lcOperation,"Open")
***         
***         DECLARE INTEGER ShellExecute ;
***             IN SHELL32.DLL ;
***             INTEGER nWinHandle,;
***             STRING cOperation,;   
***             STRING cFileName,;
***             STRING cParameters,;
***             STRING cDirectory,;
***             INTEGER nShowWindow
***            
***         RETURN ShellExecute(0,lcOperation,lcFilename,"",lcWorkDir,1)
***         ENDFUNC
***         * ShellExecute

************************************************************************
* wwAPI :: CopyFile
*********************************
***  Function: Copies File. Faster than Fox Copy and handles
***            errors internally.
***      Pass: tcSource -  Source File
***            tcTarget -  Target File
***            tnFlag   -  0* override, 1 don't
***    Return: .T. or .F.
************************************************************************
FUNCTION CopyFile
LPARAMETERS lcSource, lcTarget,nFlag
LOCAL lnRetVal 

*** Copy File and overwrite
nFlag=IIF(type("nFlag")="N",nFlag,0)

DECLARE INTEGER CopyFile ;
   IN WIN32API ;
   STRING @cSource,;
   STRING @cTarget,;
   INTEGER nFlag

lnRetVal=CopyFile(@lcSource,@lcTarget,nFlag)

RETURN IIF(lnRetVal=0,.F.,.T.)
ENDPROC
* CopyFile

FUNCTION GetUserName


DECLARE INTEGER GetUserName ;
     IN WIN32API ;
     STRING@ cComputerName,;
     INTEGER@ nSize

lcComputer=SPACE(80)
lnSize=80

=GetUserName(@lcComputer,@lnSize)
IF lnSize < 2
   RETURN ""
ENDIF   

RETURN SUBSTR(lcComputer,1,lnSize-1)

FUNCTION GetComputerName
************************************************************************
* wwAPI :: GetComputerName
*********************************
***  Function: Returns the name of the current machine
***    Return: Name of the computer
************************************************************************

DECLARE INTEGER GetComputerName ;
     IN WIN32API ;
     STRING@ cComputerName,;
     INTEGER@ nSize

lcComputer=SPACE(80)
lnSize=80

=GetComputername(@lcComputer,@lnSize)
IF lnSize < 2
   RETURN ""
ENDIF   

RETURN SUBSTR(lcComputer,1,lnSize)
ENDFUNC
* GetComputerName


FUNCTION LogonUser
************************************************************************
* wwAPI :: LogonUser
*********************************
***  Function: Check whether a username and password is valid
***    Assume: Account checking must have admin rights
***      Pass: Username, Password and optionally a server
***    Return: .T. or .F.
************************************************************************
LPARAMETERS lcUsername, lcPassword, lcServer

IF EMPTY(lcUsername)
   RETURN .F.
ENDIF
IF EMPTY(lcPassword)
   lcPassword = ""
ENDIF
IF EMPTY(lcServer)
   lcServer = "."
ENDIF         

#define LOGON32_LOGON_INTERACTIVE   2
#define LOGON32_LOGON_NETWORK       3
#define LOGON32_LOGON_BATCH         4
#define LOGON32_LOGON_SERVICE       5

#define LOGON32_PROVIDER_DEFAULT    0

DECLARE INTEGER LogonUser in WIN32API ;
       String lcUser,;
       String lcServer,;
       String lcPassword,;
       INTEGER dwLogonType,;
       Integer dwProvider,;
       Integer @dwToken
       
lnToken = 0
lnResult = LogonUser(lcUsername,lcServer,lcPassword,;
                     LOGON32_LOGON_NETWORK,LOGON32_PROVIDER_DEFAULT,@lnToken) 

DECLARE INTEGER CloseHandle IN WIN32API INTEGER
CloseHandle(lnToken)

RETURN IIF(lnResult=1,.T.,.F.)
ENDFUNC
* wwAPI :: LogonUser

FUNCTION GetSystemDir
************************************************************************
* wwAPI :: GetSystemDir
*********************************
***  Function: Returns the Windows System directory path
***      Pass: llWindowsDir - Optional: Retrieve the Windows dir
***    Return: Windows System directory or "" if failed
************************************************************************
LPARAMETER llWindowsDir
LOCAL lcPath, lnSize

lcPath=SPACE(256)

IF !llWindowsDir
	DECLARE INTEGER GetSystemDirectory ;
	   IN Win32API ;
	   STRING  @pszSysPath,;
	   INTEGER cchSysPath
	lnsize=GetSystemDirectory(@lcPath,256) 
ELSE
	DECLARE INTEGER GetWindowsDirectory ;
	   IN Win32API ;
	   STRING  @pszSysPath,;
	   INTEGER cchSysPath
	lnsize=GetWindowsDirectory(@lcPath,256) 
ENDIF 

if lnSize > 0
   RETURN SUBSTR(lcPath,1,lnSize) + "\"
ENDIF
   
RETURN ""
ENDFUNC
* GetSystemDir
   

FUNCTION GetCurrentThread
************************************************************************
* wwAPI :: GetCurrentThread
*********************************
***  Function: Returns handle to the current Process/Thread
***    Return: Process Handle or 0
************************************************************************
RETURN GetCurrentThread()
ENDFUNC
* GetProcess

************************************************************************
* wwAPI :: GetThreadPriority
*********************************
***  Function: Gets the current Priority setting of the thread.
***            Use to save and reset priority when bumping it up.
***      Pass: tnThreadHandle
************************************************************************
FUNCTION GetThreadPriority
LPARAMETER tnThreadHandle
RETURN GetThreadPriority(tnThreadHandle)
ENDFUNC
* GetThreadPriority

FUNCTION SetThreadPriority
************************************************************************
* wwAPI :: SetThreadPriority
*********************************
***  Function: Sets a thread process priority. Can dramatically
***            increase performance of a task.
***      Pass: tnThreadHandle
***            tnPriority         0 - Normal
***                               1 - Above Normal
***                               2 - Highest Priority
***                              15 - Time Critical
***                              31 - Real Time (doesn't work w/ Win95)
************************************************************************
LPARAMETER tnThreadHandle,tnPriority
RETURN SetThreadPriority(tnThreadHandle,tnPriority)
ENDFUNC
* GetThreadPriority


FUNCTION PlayWave
************************************************************************
* wwapi :: PlayWave
*******************
***     Class: WinAPI
***  Function: Plays the Wave File or WIN.INI
***            [Sounds] Entry specified in the
***            parameter. If the .WAV file or
***            System Sound can't be found,
***            SystemDefault beep is played
***    Assume: Runs only under Windows
***            uses MMSYSTEM.DLL  (Win 3.1)
***                 WINMM.DLL  (32 bit Win)
***      Pass: pcWaveFile - Full path of Wave file
***                         or System Sound Entry
***            pnPlayType - 1 - sound plays in background (default)
***                         0 - sound plays - app waits
***                         2 - No default sound if file doesn't exist
***                         4 - Kill currently playing sound 
***                         8 - Continous  
***                         Values can be added together for combinations
***  Examples:
***    do PlayWav with "SystemQuestion"
***    do PlayWav with "C:\Windows\System\Ding.wav"
***    if PlayWav("SystemAsterisk")
***
***    Return: .t. if Wave was played .f. otherwise
*************************************************************************
LPARAMETER pcWaveFile,pnPlayType
LOCAL lhPlaySnd,llRetVal

pnPlayType=IIF(TYPE("pnPlayType")="N",pnPlayType,1)

llRetVal=.f.

DECLARE INTEGER PlaySound ;
   IN WINMM.dll  ;
   STRING cWave, INTEGER nModule, INTEGER nType

IF PlaySound(pcWaveFile,0,pnPlayType)=1
   llRetVal=.t.
ENDIF

RETURN llRetVal
ENDFUNC
*EOF PLAYWAV


FUNCTION CreateGUID
************************************************************************
* wwapi::CreateGUID
********************
***    Author: Rick Strahl, West Wind Technologies
***            http://www.west-wind.com/
***  Modified: 01/26/98
***  Function: Creates a globally unique identifier using Win32
***            COM services. The vlaue is guaranteed to be unique
***    Format: {9F47F480-9641-11D1-A3D0-00600889F23B}
***    Return: GUID as a string or "" if the function failed 
*************************************************************************
LOCAL lcStruc_GUID, lcGUID, lnSize

DECLARE INTEGER CoCreateGuid ;
  IN Ole32.dll ;
  STRING @lcGUIDStruc
  
DECLARE INTEGER StringFromGUID2 ;
  IN Ole32.dll ;
  STRING cGUIDStruc, ;
  STRING @cGUID, ;
  LONG nSize
  
*** Simulate GUID strcuture with a string
lcStruc_GUID = REPLICATE(" ",16) 
lcGUID = REPLICATE(" ",80)
lnSize = LEN(lcGUID) / 2
IF CoCreateGuid(@lcStruc_GUID) # 0
   RETURN ""
ENDIF

*** Now convert the structure to the GUID string
IF StringFromGUID2(lcStruc_GUID,@lcGuid,lnSize) = 0
  RETURN ""
ENDIF

*** String is UniCode so we must convert to ANSI
RETURN  StrConv(LEFT(lcGUID,76),6)
* Eof CreateGUID

FUNCTION Sleep(lnMilliSecs)
************************************************************************
* wwAPI :: Sleep
*********************************
***  Function: Puts the computer into idle state. More efficient and
***            no keyboard interface than Inkey()
***      Pass: tnMilliseconds
***    Return: nothing
************************************************************************

lnMillisecs=IIF(type("lnMillisecs")="N",lnMillisecs,0)

DECLARE Sleep ;
  IN WIN32API ;
  INTEGER nMillisecs
 	
=Sleep(lnMilliSecs) 	
ENDFUNC
* Sleep

************************************************************************
* wwAPI :: GetLastError
*********************************
***  Function:
***    Assume:
***      Pass:
***    Return:
************************************************************************
FUNCTION GetLastError
DECLARE INTEGER GetLastError IN Win32API 
RETURN GetLastError()
ENDFUNC
* wwAPI :: GetLastError

************************************************************************
* wwAPI :: GetSystemErrorMsg
*********************************
***  Function: Returns the Message text for a Win32API error code.
***      Pass: lnErrorNo  -  WIN32 Error Code
***    Return: Error Message or "" if not found
************************************************************************
FUNCTION GetSystemErrorMsg
LPARAMETERS lnErrorNo,lcDLL
LOCAL szMsgBuffer,lnSize

szMsgBuffer=SPACE(500)

DECLARE INTEGER FormatMessage ;
     IN WIN32API ;
     INTEGER dwFlags ,;
     STRING lpvSource,;
     INTEGER dwMsgId,;
     INTEGER dwLangId,;
     STRING @lpBuffer,;
     INTEGER nSize,;
     INTEGER  Arguments

lnSize=FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM,0,lnErrorNo,;
                     0,@szMsgBuffer,LEN(szMsgBuffer),0)

IF LEN(szMsgBUffer) > 1
  szMsgBuffer=SUBSTR(szMsgBuffer,1, lnSize-1 )
ELSE
  szMsgBuffer=""  
ENDIF
    		   
RETURN szMsgBuffer


#IF .F.    &&!DEBUGMODE
************************************************************************
* wwAPI :: Error
*********************************
***  Function: Sets an Error number of the error occurred
************************************************************************
FUNCTION Error
LPARAMETERS nError, cMethod, nLine
THIS.nLastError=nError
ENDFUNC
* Error
#ENDIF

ENDDEFINE
*EOC wwAPI


************************************************************************
FUNCTION GetTimeZone
*********************************
***  Function: Returns the TimeZone offset from GMT including
***            daylight savings. Result is returned in minutes.
************************************************************************

DECLARE integer GetTimeZoneInformation IN Win32API ;
   STRING @ TimeZoneStruct
   
lcTZ = SPACE(256)

lnDayLightSavings = GetTimeZoneInformation(@lcTZ)

lnOffset = CTOBIN(SUBSTR(lcTZ,1,4), '4RS')

*** Subtract an hour if daylight savings is active
IF lnDaylightSavings = 2
   lnOffset = lnOffset - 60
ENDIF

RETURN lnOffSet


**** Binary Numeric conversion routines!
*** Converts DWORD string to binary unsigned integer
FUNCTION CharToBin(tcWord)
  LOCAL i, lnWord

  lnWord = 0
  FOR i = 1 TO LEN(tcWord)
    lnWord = lnWord + (ASC(SUBSTR(tcWord, i, 1)) * (2 ^ (8 * (i - 1))))
  ENDFOR

RETURN lnWord
