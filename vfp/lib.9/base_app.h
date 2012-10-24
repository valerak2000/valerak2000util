*выключить обработчик ошибок
#DEFINE _DEVELOP_MODE .F.
*число попыток
#DEFINE _WAIT_CYCLE 30
*секунд обновления
#DEFINE _SECONDS_REFRESH 3

#DEFINE CRLF CHR(13) + CHR(10)
#DEFINE MSG_ALERT_EXIT "ВНИМАНИЕ! ПРОГРАММА ЗАВЕРШИТ РАБОТУ АВТОМАТИЧЕСКИ В"

#define GWL_WNDPROC         (-4)
#define WM_NULL					0x0000
#define WM_CREATE				0x0001
#define WM_DESTROY				0x0002
#define WM_MOVE					0x0003
#define WM_SIZE					0x0005
#define WM_ACTIVATE				0x0006
#define WM_SETFOCUS				0x0007
#define WM_KILLFOCUS			0x0008
#define WM_ENABLE				0x000A
#define WM_SETREDRAW			0x000B
#define WM_SETTEXT				0x000C
#define WM_GETTEXT				0x000D
#define WM_GETTEXTLENGTH		0x000E
#define WM_PAINT				0x000F
#define WM_CLOSE				0x0010
#define WM_QUERYENDSESSION		0x0011
#define WM_QUIT					0x0012
#define WM_QUERYOPEN			0x0013
#define WM_ERASEBKGND			0x0014
#define WM_SYSCOLORCHANGE		0x0015
#define WM_ENDSESSION			0x0016
#define WM_SHOWWINDOW			0x0018
#define WM_WININICHANGE			0x001A
#define WM_DEVMODECHANGE		0x001B
#define WM_ACTIVATEAPP			0x001C
#define WM_FONTCHANGE			0x001D
#define WM_TIMECHANGE			0x001E
#define WM_CANCELMODE			0x001F
#define WM_SETCURSOR			0x0020
#define WM_MOUSEACTIVATE		0x0021
#define WM_CHILDACTIVATE		0x0022
#define WM_QUEUESYNC			0x0023
#define WM_GETMINMAXINFO		0x0024
#define WM_PAINTICON			0x0026
#define WM_ICONERASEBKGND		0x0027
#define WM_NEXTDLGCTL			0x0028
#define WM_SPOOLERSTATUS		0x002A
#define WM_DRAWITEM				0x002B
#define WM_MEASUREITEM			0x002C
#define WM_DELETEITEM			0x002D
#define WM_VKEYTOITEM			0x002E
#define WM_CHARTOITEM			0x002F
#define WM_SETFONT				0x0030
#define WM_GETFONT				0x0031
#define WM_SETHOTKEY			0x0032
#define WM_GETHOTKEY			0x0033
#define WM_QUERYDRAGICON		0x0037
#define WM_COMPAREITEM			0x0039
#define WM_COMPACTING			0x0041
#define WM_WINDOWPOSCHANGING	0x0046
#define WM_WINDOWPOSCHANGED		0x0047
#define WM_POWER				0x0048
#define WM_COPYDATA				0x004A
#define WM_CANCELJOURNAL		0x004B
#define WM_NCCREATE				0x0081
#define WM_NCDESTROY			0x0082
#define WM_NCCALCSIZE			0x0083
#define WM_NCHITTEST			0x0084
#define WM_NCPAINT				0x0085
#define WM_NCACTIVATE			0x0086
#define WM_GETDLGCODE			0x0087
#define WM_NCMOUSEMOVE			0x00A0
#define WM_NCLBUTTONDOWN		0x00A1
#define WM_NCLBUTTONUP			0x00A2
#define WM_NCLBUTTONDBLCLK		0x00A3
#define WM_NCRBUTTONDOWN		0x00A4
#define WM_NCRBUTTONUP			0x00A5
#define WM_NCRBUTTONDBLCLK		0x00A6
#define WM_NCMBUTTONDOWN		0x00A7
#define WM_NCMBUTTONUP			0x00A8
#define WM_NCMBUTTONDBLCLK		0x00A9
#define WM_KEYFIRST				0x0100
#define WM_KEYDOWN				0x0100
#define WM_KEYUP				0x0101
#define WM_CHAR					0x0102
#define WM_DEADCHAR				0x0103
#define WM_SYSKEYDOWN			0x0104
#define WM_SYSKEYUP				0x0105
#define WM_SYSCHAR				0x0106
#define WM_SYSDEADCHAR			0x0107
#define WM_KEYLAST				0x0108
#define WM_INITDIALOG			0x0110
#define WM_COMMAND				0x0111
#define WM_SYSCOMMAND			0x0112
#define WM_TIMER				0x0113
#define WM_HSCROLL				0x0114
#define WM_VSCROLL				0x0115
#define WM_INITMENU				0x0116
#define WM_INITMENUPOPUP		0x0117
#define WM_MENUSELECT			0x011F
#define WM_MENUCHAR				0x0120
#define WM_ENTERIDLE			0x0121
#define WM_CTLCOLORMSGBOX		0x0132
#define WM_CTLCOLOREDIT			0x0133
#define WM_CTLCOLORLISTBOX		0x0134
#define WM_CTLCOLORBTN			0x0135
#define WM_CTLCOLORDLG			0x0136
#define WM_CTLCOLORSCROLLBAR	0x0137
#define WM_CTLCOLORSTATIC		0x0138
#define WM_MOUSEFIRST			0x0200
#define WM_MOUSEMOVE			0x0200
#define WM_LBUTTONDOWN			0x0201
#define WM_LBUTTONUP			0x0202
#define WM_LBUTTONDBLCLK		0x0203
#define WM_RBUTTONDOWN			0x0204
#define WM_RBUTTONUP			0x0205
#define WM_RBUTTONDBLCLK		0x0206
#define WM_MBUTTONDOWN			0x0207
#define WM_MBUTTONUP			0x0208
#define WM_MBUTTONDBLCLK		0x0209
#define WM_MOUSELAST			0x0209
#define WM_PARENTNOTIFY			0x0210
#define WM_ENTERMENULOOP		0x0211
#define WM_EXITMENULOOP			0x0212
#define WM_POWERBROADCAST		0x0218
#define WM_DEVICECHANGE			0x0219
#define WM_MDICREATE			0x0220
#define WM_MDIDESTROY			0x0221
#define WM_MDIACTIVATE			0x0222
#define WM_MDIRESTORE			0x0223
#define WM_MDINEXT				0x0224
#define WM_MDIMAXIMIZE			0x0225
#define WM_MDITILE				0x0226
#define WM_MDICASCADE			0x0227
#define WM_MDIICONARRANGE		0x0228
#define WM_MDIGETACTIVE			0x0229
#define WM_MDISETMENU			0x0230
#define WM_DROPFILES			0x0233
#define WM_MDIREFRESHMENU		0x0234
#define WM_CUT					0x0300
#define WM_COPY					0x0301
#define WM_PASTE				0x0302
#define WM_CLEAR				0x0303
#define WM_UNDO					0x0304
#define WM_RENDERFORMAT			0x0305
#define WM_RENDERALLFORMATS		0x0306
#define WM_DESTROYCLIPBOARD		0x0307
#define WM_DRAWCLIPBOARD		0x0308
#define WM_PAINTCLIPBOARD		0x0309
#define WM_VSCROLLCLIPBOARD		0x030A
#define WM_SIZECLIPBOARD		0x030B
#define WM_ASKCBFORMATNAME		0x030C
#define WM_CHANGECBCHAIN		0x030D
#define WM_HSCROLLCLIPBOARD		0x030E
#define WM_QUERYNEWPALETTE		0x030F
#define WM_PALETTEISCHANGING	0x0310
#define WM_PALETTECHANGED		0x0311
#define WM_HOTKEY				0x0312
#define WM_THEMECHANGED			0x031A
#define WM_PENWINFIRST			0x0380
#define WM_PENWINLAST			0x038F
#define WM_USER_SHNOTIFY        WM_USER+10
#define WA_INACTIVE				0
#define WA_ACTIVE				1
#define WA_CLICKACTIVE			2
#define WM_DEVICECHANGE         0x0219


* Device and Media Events
#define SHCNE_RENAMEITEM          0x00000001
#define SHCNE_CREATE              0x00000002
#define SHCNE_DELETE              0x00000004
#define SHCNE_MKDIR               0x00000008
#define SHCNE_RMDIR               0x00000010
#define SHCNE_MEDIAINSERTED       0x00000020
#define SHCNE_MEDIAREMOVED        0x00000040
#define SHCNE_DRIVEREMOVED        0x00000080
#define SHCNE_DRIVEADD            0x00000100
#define SHCNE_NETSHARE            0x00000200
#define SHCNE_NETUNSHARE          0x00000400
#define SHCNE_ATTRIBUTES          0x00000800
#define SHCNE_UPDATEDIR           0x00001000
#define SHCNE_UPDATEITEM          0x00002000
#define SHCNE_SERVERDISCONNECT    0x00004000
#define SHCNE_UPDATEIMAGE         0x00008000
#define SHCNE_DRIVEADDGUI         0x00010000
#define SHCNE_RENAMEFOLDER        0x00020000
#define SHCNE_FREESPACE           0x00040000
 
#define SHCNE_DISKEVENTS          0x0002381F
#define SHCNE_GLOBALEVENTS        0x0C0581E0 // Events that dont match pidls first
#define SHCNE_ALLEVENTS           0x7FFFFFFF
#define SHCNE_INTERRUPT           0x80000000 // The presence of this flag indicates

#define CSIDL_DESKTOP                   0x0000        &&// <desktop>
#define CSIDL_INTERNET                  0x0001        &&// Internet Explorer (icon on desktop)
#define CSIDL_PROGRAMS                  0x0002        &&// Start Menu\Programs
#define CSIDL_CONTROLS                  0x0003        &&// My Computer\Control Panel
#define CSIDL_PRINTERS                  0x0004        &&// My Computer\Printers
#define CSIDL_PERSONAL                  0x0005        &&// My Documents
#define CSIDL_FAVORITES                 0x0006        &&// <user name>\Favorites
#define CSIDL_STARTUP                   0x0007        &&// Start Menu\Programs\Startup
#define CSIDL_RECENT                    0x0008        &&// <user name>\Recent
#define CSIDL_SENDTO                    0x0009        &&// <user name>\SendTo
#define CSIDL_BITBUCKET                 0x000a        &&// <desktop>\Recycle Bin
#define CSIDL_STARTMENU                 0x000b        &&// <user name>\Start Menu
#define CSIDL_MYDOCUMENTS               0x000c        &&// logical "My Documents" desktop icon
#define CSIDL_MYMUSIC                   0x000d        &&// "My Music" folder
#define CSIDL_MYVIDEO                   0x000e        &&// "My Videos" folder

#define DBT_DEVNODES_CHANGED            0x0007
#define DBT_DEVICEARRIVAL               0x8000  &&// system detected a new device
#define DBT_DEVICEQUERYREMOVE           0x8001  &&// wants to remove, may fail
#define DBT_DEVICEQUERYREMOVEFAILED     0x8002  &&// removal aborted
#define DBT_DEVICEREMOVEPENDING         0x8003  &&// about to remove, still avail.
#define DBT_DEVICEREMOVECOMPLETE        0x8004  &&// device is gone
 
#define DBT_DEVTYP_OEM                  0x00000000  &&// oem-defined device type
#define DBT_DEVTYP_DEVNODE              0x00000001  &&// devnode number
#define DBT_DEVTYP_VOLUME               0x00000002  &&// logical volume
#define DBT_DEVTYP_PORT                 0x00000003  &&// serial, parallel
#define DBT_DEVTYP_NET                  0x00000004  &&// network resource 
 
* Power Events
#define PBT_APMQUERYSUSPEND             0x0000
#define PBT_APMQUERYSTANDBY             0x0001
#define PBT_APMQUERYSUSPENDFAILED       0x0002
#define PBT_APMQUERYSTANDBYFAILED       0x0003
#define PBT_APMSUSPEND                  0x0004
#define PBT_APMSTANDBY                  0x0005
#define PBT_APMRESUMECRITICAL           0x0006
#define PBT_APMRESUMESUSPEND            0x0007
#define PBT_APMRESUMESTANDBY            0x0008
#define PBTF_APMRESUMEFROMFAILURE       0x00000001
#define PBT_APMBATTERYLOW               0x0009
#define PBT_APMPOWERSTATUSCHANGE        0x000A
#define PBT_APMOEMEVENT                 0x000B
#define PBT_APMRESUMEAUTOMATIC          0x0012

#define HWND_TOP        (0)
#define HWND_BOTTOM     (1)
#define HWND_TOPMOST    (0xffffffff)
#define HWND_NOTOPMOST  (0xfffffffe)

#define WS_OVERLAPPED       0x00000000
#define WS_POPUP            0x80000000
#define WS_CHILD            0x40000000
#define WS_MINIMIZE         0x20000000
#define WS_VISIBLE          0x10000000
#define WS_DISABLED         0x08000000
#define WS_CLIPSIBLINGS     0x04000000
#define WS_CLIPCHILDREN     0x02000000
#define WS_MAXIMIZE         0x01000000
#define WS_CAPTION          0x00C00000    
#define WS_BORDER           0x00800000
#define WS_DLGFRAME         0x00400000
#define WS_VSCROLL          0x00200000
#define WS_HSCROLL          0x00100000
#define WS_SYSMENU          0x00080000
#define WS_THICKFRAME       0x00040000
#define WS_GROUP            0x00020000
#define WS_TABSTOP          0x00010000
#define WS_MINIMIZEBOX      0x00020000
#define WS_MAXIMIZEBOX      0x00010000
#define WS_TILED            WS_OVERLAPPED
#define WS_ICONIC           WS_MINIMIZE
#define WS_SIZEBOX          WS_THICKFRAME
#define WS_TILEDWINDOW      WS_OVERLAPPEDWINDOW
#define WS_EX_DLGMODALFRAME     0x00000001
#define WS_EX_NOPARENTNOTIFY    0x00000004
#define WS_EX_TOPMOST           0x00000008
#define WS_EX_ACCEPTFILES       0x00000010
#define WS_EX_TRANSPARENT       0x00000020
#define WS_EX_MDICHILD          0x00000040
#define WS_EX_TOOLWINDOW        0x00000080
#define WS_EX_WINDOWEDGE        0x00000100
#define WS_EX_CLIENTEDGE        0x00000200
#define WS_EX_CONTEXTHELP       0x00000400
#define WS_EX_RIGHT             0x00001000
#define WS_EX_LEFT              0x00000000
#define WS_EX_RTLREADING        0x00002000
#define WS_EX_LTRREADING        0x00000000
#define WS_EX_LEFTSCROLLBAR     0x00004000
#define WS_EX_RIGHTSCROLLBAR    0x00000000
#define WS_EX_CONTROLPARENT     0x00010000
#define WS_EX_STATICEDGE        0x00020000
#define WS_EX_APPWINDOW         0x00040000
#define WS_EX_OVERLAPPEDWINDOW  (WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE)
#define WS_EX_PALETTEWINDOW     (WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST)
#define WS_EX_LAYERED           0x00080000
#DEFINE SC_MOVE					0xF010	&& System Menu Command Values
#DEFINE HTCAPTION				0x0002	&& HitTest and Mouse Position Codes

#DEFINE BOOL       	LONG
#DEFINE HANDLE     	LONG
#DEFINE PSTR       	STRING @
#DEFINE PRECT      	STRING @
#DEFINE UINT        LONG
#DEFINE COLORREF    LONG
#DEFINE PATINVERT   0x005A0049

* ЦВЕТА
#DEFINE COLOR_WHITE							RGB(255, 255, 255)
#DEFINE COLOR_BLACK							RGB(000, 000, 000)
#DEFINE COLOR_GRAY							RGB(192, 192, 192)
#DEFINE COLOR_DARK_GRAY						RGB(128, 128, 128)
#DEFINE COLOR_RED							RGB(255, 000, 000)
#DEFINE COLOR_DARK_RED						RGB(128, 000, 000)
#DEFINE COLOR_YELLOW						RGB(255, 255, 000)
#DEFINE COLOR_DARK_YELLOW					RGB(128, 128, 000)
#DEFINE COLOR_GREEN							RGB(000, 255, 000)
#DEFINE COLOR_DARK_GREEN					RGB(000, 128, 000)
#DEFINE COLOR_CYAN							RGB(000, 255, 255)
#DEFINE COLOR_DARK_CYAN						RGB(000, 128, 128)
#DEFINE COLOR_BLUE							RGB(000, 000, 255)
#DEFINE COLOR_DARK_BLUE						RGB(000, 000, 128)
#DEFINE COLOR_MAGENTA						RGB(255, 000, 255)
#DEFINE COLOR_DARK_MAGENTA					RGB(128, 000, 128)

#DEFINE MB_SIMPLEBEEP					-1		&& -1 Simple beep. If the sound card is not available, the sound is generated using the speaker.
#DEFINE MB_OK                       0x0000000	&& 00 SystemDefault
#DEFINE MB_ICONHAND                 0x0000010	&& 16 SystemHand
#DEFINE MB_ICONQUESTION             0x0000020	&& 32 SystemQuestion
#DEFINE MB_ICONEXCLAMATION          0x0000030	&& 48 SystemExclamation
#DEFINE MB_ICONASTERISK             0x0000040	&& 64 SystemAsterisk

* SYSTEM METRICS ( СМ. SYSMETRIC() )

#DEFINE SM_CXVSCROLL					02 && Ширина вертикального скролбара, например кнопок спиннера
#DEFINE SM_CMOUSEBUTTONS				43 && Количество кнопок мышки или 0, если мышки нет.
#DEFINE SM_MOUSEWHEELPRESENT			75 && (WNT,W98,WME) TRUE or nonzero if a mouse with a wheel is installed; FALSE or zero otherwise
#DEFINE SM_CLEANBOOT					67 && 0 Normal boot / 1 Safe-mode / 2 Safe-mode with network support
#DEFINE SM_CXSIZE						30 && Width in pixels, of a button in a window's caption or title bar.
#DEFINE SM_CYSIZE						31 && Height in pixels, of a button in a window's caption or title bar.
#DEFINE SM_CXFRAME						32 && Ширина вертикальной границы окна
#DEFINE SM_CYFRAME						33 && Высота горизонтальной границы окна

* SYSTEM COLORS ( СМ. GETSYSCOLOR() )
#DEFINE COLOR_SCROLLBAR					00
#DEFINE COLOR_BACKGROUND				01
#DEFINE COLOR_ACTIVECAPTION				02
#DEFINE COLOR_INACTIVECAPTION			03
#DEFINE COLOR_MENU						04
#DEFINE COLOR_WINDOW					05
#DEFINE COLOR_WINDOWFRAME				06
#DEFINE COLOR_MENUTEXT					07
#DEFINE COLOR_WINDOWTEXT				08
#DEFINE COLOR_CAPTIONTEXT				09
#DEFINE COLOR_ACTIVEBORDER				10
#DEFINE COLOR_INACTIVEBORDER			11
#DEFINE COLOR_APPWORKSPACE				12	&& Background color of MDI applications
#DEFINE COLOR_HIGHLIGHT					13	&& Grid.HighlightBackColor
#DEFINE COLOR_HIGHLIGHTTEXT				14	&& Grid.HighlightForeColor
#DEFINE COLOR_BTNFACE					15
#DEFINE COLOR_BTNSHADOW					16
#DEFINE COLOR_GRAYTEXT					17
#DEFINE COLOR_BTNTEXT					18
#DEFINE COLOR_INACTIVECAPTIONTEXT		19
#DEFINE COLOR_BTNHIGHLIGHT				20
#DEFINE COLOR_3DDKSHADOW				21
#DEFINE COLOR_3DLIGHT					22
#DEFINE COLOR_INFOTEXT					23
#DEFINE COLOR_INFOBK					24
#DEFINE COLOR_HOTLIGHT					26
#DEFINE COLOR_GRADIENTACTIVECAPTION		27
#DEFINE COLOR_GRADIENTINACTIVECAPTION	28
#DEFINE COLOR_DESKTOP					COLOR_BACKGROUND
#DEFINE COLOR_3DFACE					COLOR_BTNFACE
#DEFINE COLOR_3DSHADOW					COLOR_BTNSHADOW
#DEFINE COLOR_3DHIGHLIGHT				COLOR_BTNHIGHLIGHT
#DEFINE COLOR_3DHILIGHT					COLOR_BTNHIGHLIGHT
#DEFINE COLOR_BTNHILIGHT				COLOR_BTNHIGHLIGHT

#DEFINE DRIVE_UNKNOWN					0
#DEFINE DRIVE_NO_ROOT_DIR				1
#DEFINE DRIVE_REMOVABLE					2
#DEFINE DRIVE_FIXED					3
#DEFINE DRIVE_REMOTE					4
#DEFINE DRIVE_CDROM					5
#DEFINE DRIVE_RAMDISK					6

#Define FILE_ADD_FILE                                                0x2 
#Define FILE_ADD_SUBDIRECTORY                                        0x4 
#Define FILE_ALL_ACCESS                                              0x1F01FF 
#Define FILE_APPEND_DATA                                             0x4 
#Define FILE_ATTRIBUTE_ARCHIVE                                       32 
#Define FILE_ATTRIBUTE_COMPRESSED                                    2048 
#Define FILE_ATTRIBUTE_DEVICE                                        64 
#Define FILE_ATTRIBUTE_DIRECTORY                                     16 
#Define FILE_ATTRIBUTE_ENCRYPTED                                     16384 
#Define FILE_ATTRIBUTE_HIDDEN                                        2 
#Define FILE_ATTRIBUTE_NORMAL                                        128 
#Define FILE_ATTRIBUTE_NOT_CONTENT_INDEXED                           8192 
#Define FILE_ATTRIBUTE_OFFLINE                                       4096 
#Define FILE_ATTRIBUTE_READONLY                                      1 
#Define FILE_ATTRIBUTE_REPARSE_POINT                                 1024 
#Define FILE_ATTRIBUTE_SPARSE_FILE                                   512 
#Define FILE_ATTRIBUTE_SYSTEM                                        4 
#Define FILE_ATTRIBUTE_TEMPORARY                                     256 
#Define FILE_ATTRIBUTE_VIRTUAL                                       131072 
#Define FILE_BEGIN                                                   0 
#Define FILE_CREATE_PIPE_INSTANCE                                    0x4 
#Define FILE_CURRENT                                                 1 
#Define FILE_DELETE_CHILD                                            0x40 
#Define FILE_END                                                     2 
#Define FILE_EXECUTE                                                 0x20 
#Define FILE_FLAG_BACKUP_SEMANTICS                                   0x2000000 
#Define FILE_FLAG_DELETE_ON_CLOSE                                    0x4000000 
#Define FILE_FLAG_NO_BUFFERING                                       0x20000000 
#Define FILE_FLAG_OPEN_NO_RECALL                                     0x100000 
#Define FILE_FLAG_OPEN_REPARSE_POINT                                 0x200000 
#Define FILE_FLAG_OVERLAPPED                                         0x40000000 
#Define FILE_FLAG_POSIX_SEMANTICS                                    0x1000000 
#Define FILE_FLAG_RANDOM_ACCESS                                      0x10000000 
#Define FILE_FLAG_SEQUENTIAL_SCAN                                    0x8000000 
#Define FILE_FLAG_WRITE_THROUGH                                      0x80000000 
#Define FILE_LIST_DIRECTORY                                          0x1 
#Define FILE_READ_ATTRIBUTES                                         0x80 
#Define FILE_READ_DATA                                               0x1 
#Define FILE_READ_EA                                                 0x8 
#Define FILE_SHARE_DELETE                                            0x4 
#Define FILE_SHARE_READ                                              0x1 
#Define FILE_SHARE_WRITE                                             0x2 
#Define FILE_TRAVERSE                                                0x20 
#Define FILE_WRITE_ATTRIBUTES                                        0x100 
#Define FILE_WRITE_DATA                                              0x2 
#Define FILE_WRITE_EA                                                0x10 
