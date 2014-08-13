UNIT PMObject;

{**************************************************************************
*                                                                         *
*                                                                         *
*                                                                         *
*                Main Object definitions for Object-PM                    *
*                                                                         *
*                                                                         *
*                                                                         *
*                                                                         *
***************************************************************************}


INTERFACE

CONST {Common command constants}
     CM_TILE       =100;
     CM_CASCADE    =101;
     CM_CLOSE      =102;
     CM_CLOSEALL   =103;
     CM_NEXT       =104;
     CM_OPEN       =105;
     CM_SAVEAS     =106;
     CM_NEW        =107;
     CM_SAVE       =108;
     CM_SAVEALL    =109;
     CM_ABOUT      =110;

     CM_HELPONHELP =30000;
     CM_EXTENDEDHELP=30001;
     CM_KEYSHELP   =30002;
     CM_HELPINDEX  =30003;

{Self defined messages}
     WM_MOUSEDRAG1              =$1000;



VAR AppWinName:STRING[40];
    AppChildName:STRING[40];
    MainAppVMT:POINTER;
    AppWinFrameHandle:LONGWORD;    {Handle to main Window}
    AppWinHandle:LONGWORD;         {Client Window handle}

    TextDrawColor:LONGWORD;     {Current text draw color}
    TextBackColor:LONGWORD;     {Current text back color}
    AppBackColor:LONGWORD;      {ApplicationBackColor}
    ClientBackColor:LONGWORD;   {ClientBackColor}
    MouseButton1Down,Drag_Mode:BOOLEAN;
    DragWindow:HWND;
    LastDragPos:POINTER;

    HelpFileName:String;
    HelpTitle:STRING;

TYPE
    TApplication=OBJECT
                      MainID:LONGWORD;
                      MenuResource:BOOLEAN;       {TRUE for Menu resource}
                      IconResource:BOOLEAN;       {TRUE for Iconi resource}
                      AccelResource:BOOLEAN;      {TRUE for Accel resource}
                      HelpResource:BOOLEAN;       {TRUE for online help}
                      HelpWindow:HWND;
                      WinX,WinY,WinCX,WinCY:LONGWORD; {Win location}
                      {MDI variables}
                      ChildCount:LONGWORD;
                      MinimizedCount:LONGWORD;
                      ActiveChild:HWND;           {Current child active}
                      {*****************************************************}
                      {Do not change this location because its hard coded}
                      FUNCTION AppHandleEvent(Win:HWND;Msg:LONGWORD;
                                              para1,para2:POINTER;
                                              VAR Handled:BOOLEAN):LONGWORD;
                      {**************************************************}
                      {**************************************************}
                      {Do not change this location because its hard coded}
                      FUNCTION MDIHandleEvent(Win:HWND;Msg:LONGWORD;
                                              para1,para2:POINTER;
                                              VAR Handled:BOOLEAN;
                                              Extra:POINTER):LONGWORD;
                      {**************************************************}
                      CONSTRUCTOR Init(AppMainID:LONGWORD);
                      DESTRUCTOR Done;
                      PROCEDURE Run(title:String;flags,frame:LONGWORD);
                      PROCEDURE AppCreateNotify(AppWin:HWND);
                      PROCEDURE InsertMenuResource;
                      PROCEDURE InsertAccelResource;
                      PROCEDURE InsertIconResource;
                      PROCEDURE InsertHelp(Filename,WindowTitle:String);
                      PROCEDURE SetWindowLoc(x,y,cx,cy:LONGWORD);
                      PROCEDURE Redraw(Win:HWND;_hps:HPS);
                      {Window Sizing and positioning}
                      PROCEDURE PrintString(_hps:HPS;x,y:LONGWORD;s:string);
                      PROCEDURE CascadeWindows(Win:HWND);
                      PROCEDURE TileWindows(Win:HWND);
                      PROCEDURE CloseAllWindows(Win:HWND);
                      PROCEDURE NextWindow;
                      PROCEDURE GetMaxWindow(VAR _swp:SWP);
                      PROCEDURE MDIRedraw(Win:HWND;_hps:HPS;Extra:POINTER);
                      PROCEDURE MDIPaintNotify(Win:HWND;_hps:HPS;Extra:POINTER);
                      PROCEDURE CenterWindow(Win:HWND);
                      PROCEDURE InvalidateWindow(Win:HWND);
                      PROCEDURE HandleCharEvent(Win:HWND;ch:Char);
                      PROCEDURE HandleScanEvent(Win:HWND;scan:Word);
                      PROCEDURE MDIHandleCharEvent(Win:HWND;Extra:POINTER;
                                                   ch:Char);
                      PROCEDURE MDIHandleScanEvent(Win:HWND;Extra:POINTER;
                                                   scan:Word);
                 END;

    TMDIApplication=OBJECT(TApplication)
                          CONSTRUCTOR Init(AppMainID:LONGWORD);
                          DESTRUCTOR Done;
                          FUNCTION MDICreateChild(Title:String;
                                                  Extra:POINTER;
                                                  fcfFlags:LONGWORD):HWND;
                          PROCEDURE MDICreateNotify(Win:HWND;Extra:POINTER);
                          FUNCTION MDIGetTopWindow(VAR Extra:POINTER):HWND;
                          FUNCTION MDIGetExtraPointer(Win:HWND):POINTER;
                    END;

     POINTS=Record
                   x,y:Integer;
            End;

{Common procedures and functions}

FUNCTION PointerToWord(p:POINTER):WORD;
FUNCTION PointerFrom2Short(s1,s2:Word):POINTER;
FUNCTION PointerFromShort(s:Word):POINTER;
PROCEDURE MessageBox(msg:String);
PROCEDURE ErrorBox(err:String);
FUNCTION ConfirmBox(msg:String):BOOLEAN;
PROCEDURE MaximizeWindow(Win:HWND);
PROCEDURE MinimizeWindow(Win:HWND);
PROCEDURE HideWindow(Win:HWND);
PROCEDURE ShowWindow(Win:HWND);
PROCEDURE DisableWindow(Win:HWND);
PROCEDURE EnableWindow(Win:HWND);
PROCEDURE RestoreWindow(Win:HWND);
FUNCTION IsWindowMaximized(Win:HWND):BOOLEAN;
FUNCTION IsWindowMinimized(Win:HWND):BOOLEAN;
PROCEDURE DrawStringXY(_hps:HPS;VAR pt:POINTL;VAR s:string;start,Len:LONGWORD;
                       Color,BackColor:LONGWORD);


CONST {public}

     {IPF message base}
     HM_MSG_BASE              =$0220;
     {Messages applications can send to the IPF}
     HM_DISPLAY_HELP          =HM_MSG_BASE+$0002;
     HM_EXT_HELP              =HM_MSG_BASE+$0003;
     HM_GENERAL_HELP          =HM_EXT_HELP;
     HM_SET_HELP_WINDOW_TITLE =HM_MSG_BASE+$0007;
     HM_SET_SHOW_PANEL_ID     =HM_MSG_BASE+$0008;
     HM_REPLACE_HELP_FOR_HELP =HM_MSG_BASE+$0009;
     HM_REPLACE_USING_HELP    =HM_REPLACE_HELP_FOR_HELP;
     HM_HELP_INDEX            =HM_MSG_BASE+$000a;
     HM_HELP_CONTENTS         =HM_MSG_BASE+$000b;
     HM_KEYS_HELP             =HM_MSG_BASE+$000c;
     HM_SET_HELP_LIBRARY_NAME =HM_MSG_BASE+$000d;
     HM_ERROR                 =HM_MSG_BASE+$000e;
     HM_HELPSUBITEM_NOT_FOUND =HM_MSG_BASE+$000f;
     HM_QUERY_KEYS_HELP       =HM_MSG_BASE+$0010;
     HM_TUTORIAL              =HM_MSG_BASE+$0011;
     HM_EXT_HELP_UNDEFINED    =HM_MSG_BASE+$0012;
     HM_GENERAL_HELP_UNDEFINED=HM_EXT_HELP_UNDEFINED;


     { Frame window styles }
     FCF_TITLEBAR       =$00000001;
     FCF_SYSMENU        =$00000002;
     FCF_MENU           =$00000004;
     FCF_SIZEBORDER     =$00000008;
     FCF_MINBUTTON      =$00000010;
     FCF_MAXBUTTON      =$00000020;
     FCF_MINMAX         =$00000030;
     FCF_VERTSCROLL     =$00000040;
     FCF_HORZSCROLL     =$00000080;
     FCF_DLGBORDER      =$00000100;
     FCF_BORDER         =$00000200;
     FCF_SHELLPOSITION  =$00000400;
     FCF_TASKLIST       =$00000800;
     FCF_NOBYTEALIGN    =$00001000;
     FCF_NOMOVEWITHOWNER=$00002000;
     FCF_ICON           =$00004000;
     FCF_ACCELTABLE     =$00008000;
     FCF_SYSMODAL       =$00010000;
     FCF_SCREENALIGN    =$00020000;
     FCF_MOUSEALIGN     =$00040000;
     FCF_HIDEBUTTON     =$01000000;
     FCF_HIDEMAX        =$01000020;
     FCF_DBE_APPSTAT    =$80000000;
     FCF_AUTOICON       =$40000000;

     { FCF_TITLEBAR | FCF_SYSMENU | FCF_MENU | FCF_SIZEBORDER | FCF_MINMAX |
       FCF_ICON | FCF_ACCELTABLE | FCF_SHELLPOSITION | FCF_TASKLIST }
     FCF_STANDARD       =$0000CC3F;
     {FCF_TITLEBAR | FCF_SYSMENU | FCF_ICON | FCF_SIZEBORDER | FCF_MINMAX
      | FCF_MENU | FCF_SHELLPOSITION | FCF_TASKLIST}
     FCF_SPEED          =$00004C3F;
     {FCF_TITLEBAR | FCF_SYSMENU  | FCF_MINMAX | FCF_SIZEBORDER
      | FCF_TASKLIST | FCF_SHELLPOSITION}
     FCF_SIMPLE         =$00000c3b;
     {FCF_TITLEBAR | FCF_SYSMENU | FCF_MINMAX | FCF_SIZEBORDER |
      FCF_NOBYTEALIGN}
     FCF_SPEEDCHILD     =$0000103B;

     { WinQueryWindow() codes }

      QW_NEXT         =0;
      QW_PREV         =1;
      QW_TOP          =2;
      QW_BOTTOM       =3;
      QW_OWNER        =4;
      QW_PARENT       =5;
      QW_NEXTTOP      =6;
      QW_PREVTOP      =7;
      QW_FRAMEOWNER   =8;

      { Frame control IDs    }

      FID_SYSMENU                =$8002;
      FID_TITLEBAR               =$8003;
      FID_MINMAX                 =$8004;
      FID_MENU                   =$8005;
      FID_VERTSCROLL             =$8006;
      FID_HORZSCROLL             =$8007;
      FID_CLIENT                 =$8008;
      FID_DBE_APPSTAT            =$8010;
      FID_DBE_KBDSTAT            =$8011;
      FID_DBE_PECIC              =$8012;
      FID_DBE_KKPOPUP            =$8013;

      { Scroll Bar Commands }

      SB_LINEUP                  =1;
      SB_LINEDOWN                =2;
      SB_LINELEFT                =1;
      SB_LINERIGHT               =2;
      SB_PAGEUP                  =3;
      SB_PAGEDOWN                =4;
      SB_PAGELEFT                =3;
      SB_PAGERIGHT               =4;
      SB_SLIDERTRACK             =5;
      SB_SLIDERPOSITION          =6;
      SB_ENDSCROLL               =7;

      { Scroll Bar messages }

      SBM_SETSCROLLBAR           =$01a0;
      SBM_SETPOS                 =$01a1;
      SBM_QUERYPOS               =$01a2;
      SBM_QUERYRANGE             =$01a3;
      SBM_SETTHUMBSIZE           =$01a6;




IMPLEMENTATION

TYPE
    THelpInit=RECORD
                    cb:LONGWORD;
                    ulReturnCode:LONGWORD;
                    pszTutorialName:POINTER;
                    phtHelptable:LONGWORD;
                    hmodHelptableModule:HMODULE;
                    hmodAccelActionBarModule:HMODULE;
                    idAcceltable:LONGWORD;
                    idActionBar:LONGWORD;
                    pszHelpWindowTitle:POINTER;
                    fShowPanelID:LONGWORD;
                    pszHelpLibraryName:POINTER;
             END;

IMPORTS {Private} {USE OS/2 API calling convention}
          FUNCTION WinEnableWindow(fEnable:LONGWORD;
                                   _hwnd:HWND):LONGWORD:  PMWIN index 735;
          FUNCTION WinBeginPaint(VAR prclPaint:RECTL;
                                 _hps:HPS;_hwnd:HWND):
                                 LONGWORD:                PMWIN index 703;
          FUNCTION WinEndPaint(_hps:HPS):LONGWORD:        PMWIN index 738;
          FUNCTION WinRegisterClass(cbWindowData:LONGWORD;
                                    flStyle:LONGWORD;
                                    pfnWndProc:POINTER;
                                    pszClassName:PSZ;
                                    _hab:LONGWORD):
                                    LONGWORD:             PMWIN index 926;
          FUNCTION WinCreateStdWindow(VAR phwndClient:HWND;
                                      idResources:LONGWORD;
                                      hmod:HMODULE;
                                      styleClient:LONGWORD;
                                      pszTitle:PSZ;
                                      pszClientClass:PSZ;
                                      VAR pflCreateFlags:LONGWORD;
                                      flStyle:LONGWORD;
                                      hwndParent:HWND):
                                      LONGWORD:            PMWIN index 908;
          FUNCTION WinDestroyWindow(_hwnd:HWND):
                                    LONGWORD:              PMWIN index 728;
          FUNCTION WinSetWindowPos(fl:LONGWORD;
                                   cy,cx,y,x:LONGWORD;
                                   hwndInsertBehind:HWND;
                                   _hwnd:HWND):LONGWORD:   PMWIN index 875;
          FUNCTION WinPostMsg(mp2,mp1:POINTER;
                              msg:LONGWORD;
                              _hwnd:HWND):LONGWORD:        PMWIN index 919;
          FUNCTION WinMessageBox(flStyle:LONGWORD;
                                 idWindow:LONGWORD;
                                 pszCaption:PSZ;
                                 pszText:PSZ;
                                 hwndOwner:HWND;
                                 hwndParent:HWND):LONGWORD:PMWIN index 789;
          FUNCTION WinSetOwner(hwndNewOwner,_hwnd:HWND):
                               LONGWORD:                   PMWIN index 864;
          FUNCTION WinQueryWindowRect(VAR prclDest:RECTL;
                                      _hwnd:HWND ):
                                      LONGWORD:            PMWIN index 840;
          FUNCTION WinFillRect(lColor:LONGWORD;
                               VAR prcl:RECTL;
                               _hps:HPS):LONGWORD:         PMWIN index 743;
          FUNCTION WinQuerySysValue(iSysValue:LONGWORD;
                                    hwndDesktop:HWND):
                                    LONGWORD:              PMWIN index 829;
          FUNCTION WinQueryWindow(cmd:LONGWORD;
                                  _hwnd:HWND):LONGWORD:    PMWIN index 834;
          FUNCTION WinQueryWindowULong(_index:LONGWORD;
                                       _hwnd:HWND):
                                       LONGWORD:           PMWIN index 843;
          FUNCTION WinQueryWindowUShort(_index:LONGWORD;
                                        _hwnd:HWND):WORD:  PMWIN index 844;
          FUNCTION WinSendMsg(MPARAM2,MPARAM1:POINTER;
                              msg:LONGWORD;
                              _hwnd:HWND):POINTER:         PMWIN index 920;
          FUNCTION WinQueryWindowPos(_swp:SWP;
                                     _hwnd:HWND):LONGWORD: PMWIN index 837;
          FUNCTION WinSetMultWindowPos(cswp:LONGWORD;
                                       VAR pswp:SWP;
                                       _hab:LONGWORD):
                                       LONGWORD:           PMWIN index 863;
          FUNCTION WinBeginEnumWindows(_hwnd:HWND):
                                       LONGWORD:           PMWIN index 702;
          FUNCTION WinGetNextWindow(_henum:LONGWORD):HWND: PMWIN index 756;
          FUNCTION WinEndEnumWindows(_henum:LONGWORD):
                                     LONGWORD:             PMWIN index 737;
          FUNCTION WinSetWindowUShort(us:LONGINT;
                                      _index:LONGWORD;
                                      _hwnd:HWND):LONGWORD:PMWIN index 879;
          FUNCTION WinSetWindowULong(ul:LONGWORD;
                                     _index:LONGWORD;
                                     _hwnd:HWND):LONGWORD: PMWIN index 878;
          FUNCTION WinWindowFromID(id:LONGWORD;
                                   hwndParent:HWND):HWND:  PMWIN index 899;
          FUNCTION WinSetWindowText(psztext:PSZ;
                                    _hwnd:HWND):LONGWORD:  PMWIN index 877;
          FUNCTION WinCreateHelpInstance(VAR HInit:THelpInit;
                                         hab:LONGWORD):
                                         LONGWORD:         HELPMGR index 51;
          FUNCTION WinDestroyHelpInstance(hwndHelp:HWND):
                                          LONGWORD:        HELPMGR index 52;
          FUNCTION WinAssociateHelpInstance(Frame,Help:HWND):
                                           LONGWORD:       HELPMGR index 54;
END;

IMPORTS {Private}  {USE OS/2 API calling convention}
        FUNCTION GpiSetColor(lColor:LONGWORD;
                             _hps:HPS):LONGINT:            PMGPI index 517;
        FUNCTION GpiSetBackColor(lColor:LONGINT;
                                 _hps:HPS):LONGWORD:       PMGPI index 504;
        FUNCTION GpiSetBackMix(lMixMode:LONGINT;
                               _hps:HPS):LONGWORD:         PMGPI index 505;
        FUNCTION GpiCharStringAt(VAR pchString;
                                 lCount:LONGWORD;
                                 VAR pptlPoint:POINTL;
                                 _hps:HPS):LONGWORD:       PMGPI index 359;

END;

CONST {Private}
     HWND_DESKTOP       = 1;
     HWND_OBJECT        = 2;
     HWND_TOP           = 3;
     HWND_BOTTOM        = 4;
     HWND_THREADCAPTURE = 5;

     { Standard Window Styles }

     WS_VISIBLE         =$80000000;
     WS_DISABLED        =$40000000;
     WS_CLIPCHILDREN    =$20000000;
     WS_CLIPSIBLINGS    =$10000000;
     WS_PARENTCLIP      =$08000000;
     WS_SAVEBITS        =$04000000;
     WS_SYNCPAINT       =$02000000;
     WS_MINIMIZED       =$01000000;
     WS_MAXIMIZED       =$00800000;
     WS_ANIMATE         =$00400000;

     {***********************************************************************
      * Reserve a range of messages for help manager.  This range includes  *
      * public messages, defined below, and private ones, which need to be  *
      * reserved here to prevent clashing with application messages         *
      ***********************************************************************}

      WM_HELPBASE              =$0F00;
      WM_HELPTOP               =$0FFF;

      {User defined commands start here}
      WM_USER                  =$1000;


      { WinSetWindowPos() flags }

      SWP_SIZE                 =$0001;
      SWP_MOVE                 =$0002;
      SWP_ZORDER               =$0004;
      SWP_SHOW                 =$0008;
      SWP_HIDE                 =$0010;
      SWP_NOREDRAW             =$0020;
      SWP_NOADJUST             =$0040;
      SWP_ACTIVATE             =$0080;
      SWP_DEACTIVATE           =$0100;
      SWP_EXTSTATECHANGE       =$0200;
      SWP_MINIMIZE             =$0400;
      SWP_MAXIMIZE             =$0800;
      SWP_RESTORE              =$1000;
      SWP_FOCUSACTIVATE        =$2000;
      SWP_FOCUSDEACTIVATE      =$4000;
      SWP_NOAUTOCLOSE          =$8000;

      {SWP_SIZE | SWP_MOVE | SWP_ACTIVATE | SWP_SHOW }
      SWP_SPEED                =$008B;
      {SWP_SIZE | SWP_MOVE | SWP_SHOW }
      SWP_ACT                  =$000B;

      { Class styles }

      CS_MOVENOTIFY            =$00000001;
      CS_SIZEREDRAW            =$00000004;
      CS_HITTEST               =$00000008;
      CS_PUBLIC                =$00000010;
      CS_FRAME                 =$00000020;
      CS_CLIPCHILDREN          =$20000000;
      CS_CLIPSIBLINGS          =$10000000;
      CS_PARENTCLIP            =$08000000;
      CS_SAVEBITS              =$04000000;
      CS_SYNCPAINT             =$02000000;

      { background mixes }

      BM_ERROR                 =-1;
      BM_DEFAULT               = 0;
      BM_OR                    = 1;
      BM_OVERPAINT             = 2;
      BM_LEAVEALONE            = 5;
      BM_XOR                   = 4;
      BM_AND                   = 6;
      BM_SUBTRACT              = 7;
      BM_MASKSRCNOT            = 8;
      BM_ZERO                  = 9;
      BM_NOTMERGESRC           = 10;
      BM_NOTXORSRC             = 11;
      BM_INVERT                = 12;
      BM_MERGESRCNOT           = 13;
      BM_NOTCOPYSRC            = 14;
      BM_MERGENOTSRC           = 15;
      BM_NOTMASKSRC            = 16;
      BM_ONE                   = 17;
      BM_SRCTRANSPARENT        = 18;
      BM_DESTTRANSPARENT       = 19;

      {Message box types }

      MB_OK                    =$0000;
      MB_OKCANCEL              =$0001;
      MB_RETRYCANCEL           =$0002;
      MB_ABORTRETRYIGNORE      =$0003;
      MB_YESNO                 =$0004;
      MB_YESNOCANCEL           =$0005;
      MB_CANCEL                =$0006;
      MB_ENTER                 =$0007;
      MB_ENTERCANCEL           =$0008;

      MB_NOICON                =$0000;
      MB_CUANOTIFICATION       =$0000;
      MB_ICONQUESTION          =$0010;
      MB_ICONEXCLAMATION       =$0020;
      MB_CUAWARNING            =$0020;
      MB_ICONASTERISK          =$0030;
      MB_ICONHAND              =$0040;
      MB_CUACRITICAL           =$0040;
      MB_QUERY                 =$0010;
      MB_WARNING               =$0020;
      MB_INFORMATION           =$0030;
      MB_CRITICAL              =$0040;
      MB_ERROR                 =$0040;

      MB_DEFBUTTON1            =$0000;
      MB_DEFBUTTON2            =$0100;
      MB_DEFBUTTON3            =$0200;

      MB_APPLMODAL             =$0000;
      MB_SYSTEMMODAL           =$1000;
      MB_HELP                  =$2000;
      MB_MOVEABLE              =$4000;

      { Message box return codes }

      MBID_OK                  =1;
      MBID_CANCEL              =2;
      MBID_ABORT               =3;
      MBID_RETRY               =4;
      MBID_IGNORE              =5;
      MBID_YES                 =6;
      MBID_NO                  =7;
      MBID_HELP                =8;
      MBID_ENTER               =9;
      MBID_ERROR               =$ffff;

      SV_SWAPBUTTON            =0;
      SV_DBLCLKTIME            =1;
      SV_CXDBLCLK              =2;
      SV_CYDBLCLK              =3;
      SV_CXSIZEBORDER          =4;
      SV_CYSIZEBORDER          =5;
      SV_ALARM                 =6;
      SV_RESERVEDFIRST1        =7;
      SV_RESERVEDLAST1         =8;
      SV_CURSORRATE            =9;
      SV_FIRSTSCROLLRATE       =10;
      SV_SCROLLRATE            =11;
      SV_NUMBEREDLISTS         =12;
      SV_WARNINGFREQ           =13;
      SV_NOTEFREQ              =14;
      SV_ERRORFREQ             =15;
      SV_WARNINGDURATION       =16;
      SV_NOTEDURATION          =17;
      SV_ERRORDURATION         =18;
      SV_RESERVEDFIRST         =19;
      SV_RESERVEDLAST          =19;
      SV_CXSCREEN              =20;
      SV_CYSCREEN              =21;
      SV_CXVSCROLL             =22;
      SV_CYHSCROLL             =23;
      SV_CYVSCROLLARROW        =24;
      SV_CXHSCROLLARROW        =25;
      SV_CXBORDER              =26;
      SV_CYBORDER              =27;
      SV_CXDLGFRAME            =28;
      SV_CYDLGFRAME            =29;
      SV_CYTITLEBAR            =30;
      SV_CYVSLIDER             =31;
      SV_CXHSLIDER             =32;
      SV_CXMINMAXBUTTON        =33;
      SV_CYMINMAXBUTTON        =34;
      SV_CYMENU                =35;
      SV_CXFULLSCREEN          =36;
      SV_CYFULLSCREEN          =37;
      SV_CXICON                =38;
      SV_CYICON                =39;
      SV_CXPOINTER             =40;
      SV_CYPOINTER             =41;
      SV_DEBUG                 =42;
      SV_CMOUSEBUTTONS         =43;
      SV_CPOINTERBUTTONS       =43;
      SV_POINTERLEVEL          =44;
      SV_CURSORLEVEL           =45;
      SV_TRACKRECTLEVEL        =46;
      SV_CTIMERS               =47;
      SV_MOUSEPRESENT          =48;
      SV_CXBYTEALIGN           =49;
      SV_CXALIGN               =49;
      SV_CYBYTEALIGN           =50;
      SV_CYALIGN               =50;
      SV_NOTRESERVED           =56;
      SV_EXTRAKEYBEEP          =57;
      SV_SETLIGHTS             =58;
      SV_INSERTMODE            =59;
      SV_MENUROLLDOWNDELAY     =64;
      SV_MENUROLLUPDELAY       =65;
      SV_ALTMNEMONIC           =66;
      SV_TASKLISTMOUSEACCESS   =67;
      SV_CXICONTEXTWIDTH       =68;
      SV_CICONTEXTLINES        =69;
      SV_CHORDTIME             =70;
      SV_CXCHORD               =71;
      SV_CYCHORD               =72;
      SV_CXMOTIONSTART         =73;
      SV_CYMOTIONSTART         =74;
      SV_BEGINDRAG             =75;
      SV_ENDDRAG               =76;
      SV_SINGLESELECT          =77;
      SV_OPEN                  =78;
      SV_CONTEXTMENU           =79;
      SV_CONTEXTHELP           =80;
      SV_TEXTEDIT              =81;
      SV_BEGINSELECT           =82;
      SV_ENDSELECT             =83;
      SV_BEGINDRAGKB           =84;
      SV_ENDDRAGKB             =85;
      SV_SELECTKB              =86;
      SV_OPENKB                =87;
      SV_CONTEXTMENUKB         =88;
      SV_CONTEXTHELPKB         =89;
      SV_TEXTEDITKB            =90;
      SV_BEGINSELECTKB         =91;
      SV_ENDSELECTKB           =92;
      SV_ANIMATION             =93;
      SV_ANIMATIONSPEED        =94;
      SV_MONOICONS             =95;
      SV_KBDALTERED            =96;
      SV_PRINTSCREEN           =97;
      SV_CSYSVALUES            =98;



      { Standard WinQueryWindowUShort/ULong() indices }

      QWS_USER                   =0;
      QWS_ID                     =-1;
      QWS_MIN                    =-1;
      QWL_USER                   =0;
      QWL_STYLE                  =-2;
      QWP_PFNWP                  =-3;
      QWL_HMQ                    =-4;
      QWL_RESERVED               =-5;
      QWL_PENDATA                =-7;
      QWL_MIN                    =-7;

      { WC_FRAME WinQueryWindowUShort/ULong() indices }

      QWL_HHEAP                  =$0004;
      QWL_HWNDFOCUSSAVE          =$0018;
      QWL_DEFBUTTON              =$0040;
      QWL_PSSCBLK                =$0048;
      QWL_PFEPBLK                =$004c;
      QWL_PSTATBLK               =$0050;

      QWS_FLAGS                  =$0008;
      QWS_RESULT                 =$000a;
      QWS_XRESTORE               =$000c;
      QWS_YRESTORE               =$000e;
      QWS_CXRESTORE              =$0010;
      QWS_CYRESTORE              =$0012;
      QWS_XMINIMIZE              =$0014;
      QWS_YMINIMIZE              =$0016;


{**************************************************************************
*                                                                         *
*                                                                         *
*                Common procedures and functions                          *
*                                                                         *
*                                                                         *
***************************************************************************}


PROCEDURE DrawStringXY(_hps:HPS;VAR pt:POINTL;VAR s:string;start,Len:LONGWORD;
                       Color,BackColor:LONGWORD);
BEGIN
     GpiSetColor(Color,_hps);
     GpiSetBackColor(BackColor,_hps);
     GpiCharStringAt(s[Start],Len,pt,_hps);
END;


PROCEDURE MaximizeWindow(Win:HWND);
BEGIN
     WinSetWindowPos(SWP_MAXIMIZE OR SWP_ACTIVATE OR SWP_SHOW,0,0,0,0,
                     HWND_TOP,Win);
END;

PROCEDURE MinimizeWindow(Win:HWND);
BEGIN
     WinSetWindowPos(SWP_MINIMIZE OR SWP_ACTIVATE OR SWP_SHOW,0,0,0,0,
                     HWND_TOP,Win);
END;


FUNCTION IsWindowMaximized(Win:HWND):BOOLEAN;
VAR r:LONGWORD;
BEGIN
     IF Win=0 THEN
     BEGIN
          IsWindowMaximized:=FALSE;
          exit;
     END;
     IF WinQueryWindowUShort(QWS_ID,Win)=FID_CLIENT THEN
      Win:=WinQueryWindow(QW_PARENT,Win);
     r:=WinQueryWindowULong(QWL_STYLE,Win) and WS_MAXIMIZED;
     IF r<>0 THEN IsWindowMaximized:=TRUE
     ELSE IsWindowMaximized:=FALSE;
END;

FUNCTION IsWindowMinimized(Win:HWND):BOOLEAN;
VAR r:LONGWORD;
BEGIN
     IF Win=0 THEN
     BEGIN
          IsWindowMinimized:=FALSE;
          exit;
     END;
     IF WinQueryWindowUShort(QWS_ID,Win)=FID_CLIENT THEN
      Win:=WinQueryWindow(QW_PARENT,Win);
     r:=WinQueryWindowULong(QWL_STYLE,Win) and WS_MINIMIZED;
     IF r<>0 THEN IsWindowMinimized:=TRUE
     ELSE IsWindowMinimized:=FALSE;
END;

PROCEDURE HideWindow(Win:HWND);
BEGIN
     WinSetWindowPos(SWP_HIDE,0,0,0,0,0,Win);
END;

PROCEDURE ShowWindow(Win:HWND);
BEGIN
     WinSetWindowPos(SWP_SHOW,0,0,0,0,0,Win);
END;

PROCEDURE DisableWindow(Win:HWND);
BEGIN
     WinEnableWindow(0,Win);
END;


PROCEDURE EnableWindow(Win:HWND);
BEGIN
     WinEnableWindow(1,Win);
END;

PROCEDURE RestoreWindow(Win:HWND);
BEGIN
     WinSetWindowPos(SWP_RESTORE,0,0,0,0,0,Win);
END;

FUNCTION ConfirmBox(msg:String):BOOLEAN;
VAR s:PString;
    result:LONGWORD;
BEGIN
     s:='Confirm action';
     result:=WinMessageBox(MB_YESNO or MB_MOVEABLE or MB_Query,0,s,msg,
                           AppWinFrameHandle,HWND_Desktop);
     ConfirmBox:=result=MBID_YES;
END;


PROCEDURE MessageBox(msg:String);
VAR s:PString;
BEGIN
     s:='Message';
     WinMessageBox(MB_OK or MB_MOVEABLE or MB_Query,0,s,msg,AppWinFrameHandle,
                   HWND_Desktop);
END;

PROCEDURE ErrorBox(err:String);
VAR s:PString;
BEGIN
     s:='Error';
     WinMessageBox(MB_OK or MB_MOVEABLE or MB_Query,0,s,err,AppWinFrameHandle,
                   HWND_Desktop);
END;


FUNCTION PointerToWord(p:POINTER):WORD;ASM;
BEGIN
     ASM
        MOV EBX,ESP
        MOV EAX,[EBX+4]
        RETN32 4
     END;
END;

FUNCTION PointerFrom2Short(s1,s2:Word):POINTER;ASM;
BEGIN
     ASM
        MOV EBX,ESP
        MOV EAX,[EBX+4]
        RETN32 4
     END;
END;

FUNCTION PointerFromShort(s:Word):POINTER;ASM;
BEGIN
     ASM
        MOV EBX,ESP
        MOV AX,[EBX+4]
        MOVZX EAX,AX
        RETN32 2
     END;
END;

{**************************************************************************
*                                                                         *
*                                                                         *
*                Object Implementation TAPPLICATION                       *
*                                                                         *
*                                                                         *
***************************************************************************}

PROCEDURE MessageHandler(para2,para1:POINTER;Msg,Win:LONGWORD);ASM;
BEGIN
     ASM
        PUSH EBP
        MOV EBP,ESP
        SUB ESP,2
        MOVW [EBP-2],0   ;Not Handled

        PUSHL $Win
        PUSHL $Msg
        PUSHL $para1
        PUSHL $para2
        LEA EAX,[EBP-2]
        PUSH EAX
        MOV EDI,_MainAppVMT
        PUSH EDI         ;VMT Pointer
        MOV EDI,[EDI+0]  ;get VMT pointer for AppHandleEvent
        db ffh,17h       ;CALL NEAR32 [EDI+0] --> in Methode springen
        MOV BL,[EBP-2]
        CMP BL,0
        JNE !hh
        ;not handled
        ;Default Window handler
        PUSHL $para2
        PUSHL $para1
        PUSHL $msg
        PUSHL $win
        MOV AL,4
        CALLDLL PMWin,911   ;WinDefWindowProc
        ADD ESP,16
!hh:
        LEAVE
        RETN32
     END;
END;


PROCEDURE TApplication.InvalidateWindow(Win:HWND);
VAR rc:RECTL;
BEGIN
     ASM
        LEA EAX,$rc
        PUSH EAX
        PUSHL $Win
        MOV AL,2
        CALLDLL PMWIN,840  ;WinQueryWindowRect
        ADD ESP,8

        PUSHL 0
        LEA EAX,$rc
        PUSH EAX
        PUSHL $Win
        MOV AL,3
        CALLDLL PMWIN,765   ;WinInvalidateRect
        ADD ESP,12
     END;
END;


CONSTRUCTOR TApplication.Init(AppmainID:LONGWORD);
{Initializes application}
VAR t:WORD;
BEGIN
     MainID:=AppMainID;
     AlternateExit:=TRUE; {Set alternate WM_QUIT Handler}
     MenuResource:=FALSE;
     IconResource:=FALSE;
     AccelResource:=FALSE;
     HelpResource:=FALSE;

     AppBackColor:=8; {CLR_DARKGRAY}

     TextDrawColor:=6; {CLR_YELLOW}
     TextBackColor:=9; {CLR_DARKBLUE}

     ClientBackColor:=9; {CLR_DARKBLUE}
     ChildCount:=0;
     ActiveChild:=0;
     MinimizedCount:=0;

     WinX:=50;
     WinY:=100;
     WinCX:=550;
     WinCY:=320;
     MainAppVMT:=SELF;
     {Create Application Window class}
     WinRegisterClass(0,CS_SizeRedraw,@MessageHandler,AppWinName,AppHandle);
END;

DESTRUCTOR TApplication.Done;
BEGIN
END;



PROCEDURE TApplication.InsertHelp(Filename,WindowTitle:String);
BEGIN
     HelpResource:=TRUE;
     HelpFileName:=FileName;
     HelpTitle:=Windowtitle;
END;


PROCEDURE TApplication.AppCreateNotify(AppWin:HWND);
BEGIN
     WinSetWindowPos(SWP_SPEED,WinCY,WinCX,WinY,WinX,HWND_TOP,AppWinFrameHandle);
END;

PROCEDURE MainMessageLoop;
VAR _qmsg:QMSG;
BEGIN
     ASM
!ndis:
        PUSHL 0    ;PM_NOREMOVE
        PUSHL 0
        PUSHL 0
        PUSHL 0
        LEA EAX,$_qmsg
        PUSH EAX
        PUSHL _AppHandle
        MOV AL,6
        CALLDLL PMWIN,918  ;WinPeekMsg
        ADD ESP,24
        CMP EAX,0         ;Message in the queue ??
        JNE !mes_here

        ;There was no message in the queue
        CMPB _Drag_Mode,0
        JE !mes_here       ;Wait for next message

        ;Create a WM_MouseDRAG Message at last Message Position
        PUSHL 0
        PUSHL _LastDragPos
        PUSHL 1000h   ;WM_MOUSEDRAG1
        PUSHL _DragWindow
        MOV AL,4
        CALLDLL PMWIN,920       ;WinSendMsg
        ADD ESP,16

        JMP !ndis
!mes_here:
        PUSHL 0
        PUSHL 0
        PUSHL 0
        LEA EAX,$_qmsg
        PUSH EAX
        PUSHL _AppHandle
        MOV AL,5
        CALLDLL PMWIN,915  ;WinGetMsg
        ADD ESP,20
        CMP EAX,0
        JE !exdis

        LEA ESI,$_qmsg
        MOV EAX,[ESI+4]     ;qmsg.msg
        CMP EAX,72h         ;WM_Button1Up
        JE !naus
        CMP EAX,0412h       ;WM_Button1MotionEnd
        JNE !naus_1
!naus:
        MOVB _MouseButton1Down,0
        MOVB _Drag_Mode,0
!naus_1:
        LEA EAX,$_qmsg
        PUSH EAX
        PUSHL _AppHandle
        MOV AL,2
        CALLDLL PMWIN,912  ;WinDispatchMsg
        ADD ESP,8
        JMP !ndis
!exdis:
     END;
END;



PROCEDURE TApplication.Run(Title:String;flags,frame:LongWord);
{Starts execution of Application.
 Title is the Title of the Main Application window.
 If flags is not zero then flags will be the window style.
 If frame is not zero then frame will be the frame flags.}
VAR f:LONGWORD;
    fr:LONGWORD; {Frame flags}
    HelpInit:THelpInit;
    p:POINTER;
BEGIN
     IF frame<>0 THEN fr:=frame
     ELSE fr:=FCF_Simple;
     IF flags<>0 THEN f:=Flags
     ELSE f:=0;
     IF MenuResource THEN fr:=fr OR FCF_MENU;
     IF IconResource THEN fr:=fr OR FCF_ICON;
     IF AccelResource THEN fr:=fr OR FCF_ACCELTABLE;
     AppWinFrameHandle:=WinCreateStdWindow(AppWinHandle,MainID,0,0,
                                        Title,AppWinName,fr,
                                        f,HWND_DESKTOP);

     HelpWindow:=0;
     IF HelpResource THEN
     BEGIN
          p:=@helptitle;
          inc(p);
          HelpInit.pszHelpWindowTitle:=p;
          p:=@HelpFileName;
          inc(p);
          HelpInit.pszHelpLibraryName:=p;
          HelpInit.cb:=sizeof(THelpInit);
          HelpInit.ulReturnCode:=0;
          HelpInit.pszTutorialname:=NIL;
          HelpInit.phtHelptable:=$FFFF0000 OR MainID;
          HelpInit.hmodHelptableModule:=0;
          HelpInit.hmodAccelActionBarModule:=0;
          HelpInit.idAcceltable:=0;
          HelpInit.idActionBar:=0;
          HelpInit.fShowPanelID:=1;
          HelpWindow:=WinCreateHelpInstance(HelpInit,Apphandle);
          IF HelpWindow<>0 THEN WinAssociateHelpInstance(AppWinFrameHandle,
                                                         HelpWindow)
          ELSE ErrorBox('Application failed to initialize help');
     END;                                        
     AppCreateNotify(AppWinFrameHandle);

     MainMessageLoop;
     WinDestroyWindow(AppWinFrameHandle);
     IF HelpWindow<>0 THEN WinDestroyHelpInstance(HelpWindow);
END;

PROCEDURE TApplication.PrintString(_hps:HPS;x,y:LONGWORD;s:string);
VAR
    pt:POINTL;
    ps:PString;
BEGIN
     pt.x:=x;
     pt.y:=y;
     GpiSetColor(TextDrawColor,_hps);
     GpiSetBackColor(TextBackColor,_hps);
     GpiSetBackMix(BM_OVERPAINT,_hps);
     ps:=s;
     GpiCharStringAt(ps,length(s),pt,_hps);
END;

PROCEDURE TApplication.Redraw(Win:HWND;_hps:HPS);
VAR rc:RECTL;
BEGIN
     WinQueryWindowRect(rc,Win);
     WinFillRect(AppBackColor,rc,_hps);
END;

PROCEDURE TApplication.SetWindowLoc(x,y,cx,cy:LONGWORD);
BEGIN
     WinX:=x;
     WinY:=y;
     WinCX:=cx;
     WinCY:=cy;
END;

PROCEDURE TApplication.InsertMenuResource;
BEGIN
     MenuResource:=TRUE;
END;

PROCEDURE TApplication.InsertIconResource;
BEGIN
     IconResource:=TRUE;
END;

PROCEDURE TApplication.InsertAccelResource;
BEGIN
     AccelResource:=TRUE;
END;

PROCEDURE TApplication.GetMaxWindow(VAR _swp:SWP);
VAR rec:RECTL;
    XDiv,YDiv,UWin:LONGWORD;
BEGIN
     XDiv:=WinQuerySysValue(SV_CXSIZEBORDER,HWND_DESKTOP);
     XDiv:=XDiv+WinQuerySysValue(SV_CXMINMAXBUTTON,HWND_DESKTOP) DIV 2;

     YDiv:=WinQuerySysValue(SV_CYSIZEBORDER,HWND_DESKTOP);
     YDiv:=YDiv+WinQuerySysValue(SV_CYMINMAXBUTTON,HWND_DESKTOP);
     WinQueryWindowRect(rec,AppWinHandle);
     _swp.cx:=rec.XRight-rec.XLeft;
     _swp.cy:=rec.yTop-rec.yBottom;
     _swp.x:=rec.xRight-_swp.cx;
     _swp.y:=rec.yTop-_swp.cy;
END;



PROCEDURE TApplication.TileWindows(Win:HWND);
VAR
    Buf:PSWPBUF;
    Square,Rows,Columns,ExtraCols,Width,Height:LONGWORD;
    rec:RECTL;
    Child:HWND;
    _hEnum:LONGWORD;
    CurRow,CurCol:LONGWORD;
    ChildCnt:LONGWORD;
    t:LONGWORD;
LABEL l;
BEGIN
     Square:=2;
     ChildCnt:=ChildCount-MinimizedCount;
     IF ChildCnt=0 THEN
     BEGIN
          MessageBox('No Windows to tile !');
          exit;
     END;
     WHILE Square*2<=ChildCnt DO inc(Square);
     IF ChildCnt=3 THEN Square:=3;

     Columns:=Square-1;
     Rows:=ChildCnt DIV Columns;
     ExtraCols:=ChildCnt MOD Columns;

     WinQueryWindowRect(rec,Win);
     IF rec.xRight>0 THEN IF rec.yBottom<rec.yTop THEN
     BEGIN
          _hEnum:=WinBeginEnumWindows(Win);
          Child:=WinGetNextWindow(_hEnum);
          IF Child<>0 THEN
          BEGIN
               GetMem(Buf,sizeof(TSWPBUF)*ChildCount);
               ChildCnt:=0;
               Height:=(rec.yTop-rec.yBottom) div Rows;

               FOR CurRow:=0 TO Rows-1 DO
               BEGIN
                    IF Rows-CurRow<=ExtraCols THEN inc(Columns);
                    FOR CurCol:=0 TO Columns-1 DO
                    BEGIN
                         Width:=rec.xRight div Columns;

                         {Skip minimized Windows}
l:
                         IF ((IsWindowMinimized(Child))OR
                         (WinQueryWindowUShort(QWS_ID,Child)=0)) THEN
                         BEGIN
                              Child:=WinGetNextWindow(_hEnum);
                              If Child<>0 THEN goto l;
                         END;

                         IF Child<>0 THEN
                         BEGIN
                              IF IsWindowMaximized(Child) THEN
                               Buf^[ChildCnt].fl:=SWP_SPEED OR SWP_RESTORE
                              ELSE Buf^[ChildCnt].fl:=SWP_SPEED;
                              buf^[ChildCnt].x:=Width*CurCol;
                              buf^[ChildCnt].y:=rec.yTop-(Height*(CurRow+1));
                              buf^[ChildCnt].cx:=Width;
                              buf^[ChildCnt].cy:=Height;
                              buf^[ChildCnt]._hwnd:=Child;
                              inc(ChildCnt);

                              Child:=WinGetNextWindow(_hEnum);
                         END;
                    END;
                    IF Rows-CurRow<=ExtraCols THEN
                    BEGIN
                         dec(Columns);
                         dec(ExtraCols);
                    END;
               END;

               WinEndEnumWindows(_HEnum);
               WinSetMultWindowPos(ChildCnt,Buf^[0],AppHandle);
               FreeMem(Buf,sizeof(TSWPBUF)*ChildCount);
          END;

     END;
END;

PROCEDURE TApplication.CascadeWindows(Win:HWND);
VAR Next:HWND;
    Count:LONGWORD;
    Buf:PLONGBUF;
    t:LONGWORD;
    _swp:SWP;
    XDiv,YDiv:LONGWORD;
    Frame:HWND;
BEGIN
     If ChildCount-MinimizedCount=0 THEN
     begin
          MessageBox('No Windows to cascade !');
          exit; {No childs exist}
     end;
     XDiv:=WinQuerySysValue(SV_CXSIZEBORDER,HWND_DESKTOP);
     XDiv:=XDiv+WinQuerySysValue(SV_CXMINMAXBUTTON,HWND_DESKTOP) DIV 2;

     YDiv:=WinQuerySysValue(SV_CYSIZEBORDER,HWND_DESKTOP);
     YDiv:=YDiv+WinQuerySysValue(SV_CYMINMAXBUTTON,HWND_DESKTOP);
     Next:=WinQueryWindow(QW_BOTTOM,Win);
     if Next=0 THEN
     begin
          MessageBox('No Windows to cascade !');
          exit; {No childs exist}
     end;
     Count:=0;
     GetMem(Buf,4*ChildCount);
     WHILE Next<>0 DO
     BEGIN
          IF ((not IsWindowMinimized(Next))AND
             (WinQueryWindowUShort(QWS_ID,Next)<>0))
          THEN
          BEGIN
               Buf^[Count]:=Next;
               Inc(Count);
          END;
          Next:=WinQueryWindow(QW_PREV,Next);
     END;
     GetMaxWindow(_swp);
     FOR t:=0 TO Count-1 DO
     BEGIN
          WinSetWindowPos(SWP_SPEED,_swp.cy,_swp.cx,_swp.y,_swp.x,0,
                          Buf^[t]);
          inc(_swp.x,XDiv);
          dec(_swp.cx,XDiv);
          dec(_swp.cy,YDiv);
     END;
     FreeMem(Buf,4*ChildCount);
END;

PROCEDURE TApplication.NextWindow;
VAR Next:HWND;
    AcFrame:HWND;
    f:LONGWORD;
BEGIN
     Next:=WinQueryWindow(QW_PARENT,ActiveChild);
     AcFrame:=Next;
     Next:=WinQueryWindow(QW_NEXT,Next);
     WHILE ((Next<>0)AND(WinQueryWindowUShort(QWS_ID,Next)=0)) DO
       Next:=WinQueryWindow(QW_NEXT,Next);
     IF Next<>0 THEN
     BEGIN
           WinSetWindowPos(SWP_ZORDER or SWP_ACTIVATE,0,0,0,0,HWND_TOP,
                           Next);
           IF IsWindowMaximized(AcFrame) THEN f:=SWP_RESTORE OR SWP_ZORDER
           ELSE f:=SWP_ZORDER;
           WinSetWindowPos(f,0,0,0,0,HWND_BOTTOM,AcFrame);
     END;
END;

PROCEDURE TApplication.CloseAllWindows(Win:HWND);
VAR Child:HWND;
    _hEnum:LONGWORD;
BEGIN
     _hEnum:=WinBeginEnumWindows(Win);
     Child:=WinGetNextWindow(_HEnum);
     WHILE Child<>0 DO
     BEGIN
           WinDestroyWindow(Child);
           Child:=WinGetNextWindow(_HEnum);
     END;
     WinEndEnumWindows(_HEnum);
END;

PROCEDURE TApplication.HandleCharEvent(Win:HWND;ch:Char);
BEGIN
END;

PROCEDURE TApplication.HandleScanEvent(Win:HWND;scan:Word);
BEGIN
END;

PROCEDURE TApplication.MDIHandleCharEvent(Win:HWND;Extra:POINTER;ch:Char);
BEGIN
END;

PROCEDURE TApplication.MDIHandleScanEvent(Win:HWND;Extra:POINTER;scan:Word);
BEGIN
END;

FUNCTION TApplication.AppHandleEvent(Win:HWND;Msg:LONGWORD;
                                     para1,para2:POINTER;
                                     VAR Handled:BOOLEAN):LONGWORD;
VAR
    H:Boolean;
    _hps:HPS;
    r:LONGWORD;
    command:WORD;
    rc:RECTL;
    w,w1:Word;
    b:WORD;
    ch:char;
label l,l1;
BEGIN
      r:=0;
      H:=TRUE;
      CASE Msg OF
          HM_QUERY_KEYS_HELP:r:=CM_KEYSHELP;
          HM_ERROR:ErrorBox('Help manager error!');
          HM_HELPSUBITEM_NOT_FOUND:ErrorBox('Helpsubitem not found!');
          HM_EXT_HELP_UNDEFINED:ErrorBox('Extended help undefined!');
          HM_GENERAL_HELP_UNDEFINED:ErrorBox('General help undefined!');
          WM_CHAR:
          BEGIN
               r:=LONGINT(para1);
               w:=lo(r);
               IF w AND $41=1 THEN {KC_CHAR valid and KC_KEYUP}
               BEGIN
                    r:=LONGINT(para2);
                    w1:=lo(r);
                    b:=lo(w1);
                    if b<32 THEN goto l;
                    IF w and $10=$10 THEN goto l; {KC_CTRL valid}
                    ch:=chr(b);
                    HandleCharEvent(Win,ch);
                    goto l1;
               END
               ELSE
               BEGIN
                    IF w AND $44=4 THEN {KC_CHAR valid and KC_KEYUP}
                    BEGIN
                         w1:=hi(r);
                         b:=hi(w1);
l:
                         IF w and $10=$10 THEN inc(b,256); {KC_CTRL valid}
                         HandleScanEvent(Win,b);
                         goto l1;
                    END;
               END;
          END;
          WM_COMMAND:
          BEGIN
               command:=PointerToWord(para1);
               CASE command OF
                   CM_HELPONHELP:IF HelpWindow<>0 THEN
                             WinSendMsg(NIL,NIL,HM_DISPLAY_HELP,HelpWindow);
                   CM_EXTENDEDHELP:IF HelpWindow<>0 THEN
                             WinSendMsg(NIL,NIL,HM_EXT_HELP,HelpWindow);
                   CM_KEYSHELP:IF HelpWindow<>0 THEN
                             WinSendMsg(NIL,NIL,HM_KEYS_HELP,HelpWindow);
                   CM_HELPINDEX:IF HelpWindow<>0 THEN
                             WinSendMsg(NIL,NIL,HM_HELP_INDEX,HelpWindow);
               END; {case}
               IF ChildCount>0 THEN
               BEGIN
                    CASE command OF
                      CM_CLOSE:WinSendMsg(NIL,NIL,WM_CLOSE,ActiveChild);
                      CM_CASCADE:CascadeWindows(Win);
                      CM_TILE:TileWindows(Win);
                      CM_CLOSEALL:CloseAllWindows(Win);
                      CM_Next:NextWindow;
                    ELSE IF not Handled THEN H:=FALSE;
                    END; {case}
               END
               ELSE IF not Handled THEN H:=FALSE;
          END;
          WM_CLOSE:
          BEGIN
               WinPostMsg(NIL,NIL,WM_QUIT,Win);
          END;
          WM_PAINT:
          BEGIN
               _hps:=WinBeginPaint(rc,0,Win);
               Redraw(Win,_hps);
               WinEndPaint(_hps);
          END;
          WM_BUTTON1UP:
          BEGIN
               MouseButton1Down:=FALSE;
               Drag_Mode:=FALSE;
               IF not Handled THEN H:=FALSE;
          END;
          ELSE IF not Handled THEN H:=FALSE;
      END;
l1:
      Handled:=H;
      AppHandleEvent:=r;
END;

PROCEDURE TApplication.MDIRedraw(Win:HWND;_hps:HPS;Extra:POINTER);
BEGIN
END;

PROCEDURE TApplication.MDIPaintNotify(Win:HWND;_hps:HPS;Extra:POINTER);
VAR rc:RECTL;
BEGIN
     WinQueryWindowRect(rc,Win);
     WinFillRect(ClientBackColor,rc,_hps);
     MDIRedraw(Win,_hps,Extra);
END;


FUNCTION TApplication.MDIHandleEvent(Win:HWND;Msg:LONGWORD;para1,para2:POINTER;
                                     VAR Handled:BOOLEAN;Extra:POINTER):LONGWORD;
VAR
    H:Boolean;
    _hps:HPS;
    r:LONGWORD;
    command:WORD;
    rc:RECTL;
    _pswp:PSWP;
    Frame:HWND;
    w,w1:Word;
    b:WORD;
    ch:char;
label l,l1;
BEGIN
      r:=0;
      H:=TRUE;
      CASE Msg OF
          WM_CHAR:
          BEGIN
               r:=LONGINT(para1);
               w:=lo(r);
               IF w AND $41=1 THEN {KC_CHAR valid and KC_KEYUP}
               BEGIN
                    r:=LONGINT(para2);
                    w1:=lo(r);
                    b:=lo(w1);
                    if b<32 THEN goto l;
                    IF w and $10=$10 THEN goto l; {KC_CTRL valid}
                    ch:=chr(b);
                    MDIHandleCharEvent(Win,Extra,ch);
                    goto l1;
               END
               ELSE
               BEGIN
                    IF w AND $44=4 THEN {KC_CHAR valid and KC_KEYUP}
                    BEGIN
                         w1:=hi(r);
                         b:=hi(w1);
l:
                         IF w and $10=$10 THEN inc(b,256); {KC_CTRL valid}
                         MDIHandleScanEvent(Win,Extra,b);
                         goto l1;
                    END;
               END;
          END;
          WM_MINMAXFRAME:
          BEGIN
               {Minimize the window ??}
               _pswp:=para1;
               IF _pswp^.fl AND SWP_MINIMIZE<>0 THEN INC(MinimizedCount)
               ELSE
               BEGIN
                    Frame:=WinQueryWindow(QW_PARENT,Win);
                    IF IsWindowMinimized(Win) THEN
                    BEGIN
                         DEC(MinimizedCount);
                         WinSetWindowUShort(-1,QWS_XMINIMIZE,Frame);
                         WinSetWindowUShort(-1,QWS_YMINIMIZE,Frame);
                    END;
               END;
          END;
          WM_CREATE:
          BEGIN
               inc(ChildCount);
          END;
          WM_ACTIVATE:
          BEGIN
               ActiveChild:=Win;
          END;
          WM_CLOSE:
          BEGIN
               WinDestroyWindow(WinQueryWindow(QW_PARENT,Win));
          END;
          WM_DESTROY:
          BEGIN
               IF IsWindowMinimized(Win) THEN dec(MinimizedCount);
               dec(ChildCount);
          END;
          WM_BUTTON1DOWN:
          BEGIN
               Drag_Mode:=FALSE;
               MouseButton1Down:=TRUE;
               IF not Handled THEN H:=FALSE;
          END;
          WM_BUTTON1UP:
          BEGIN
               MouseButton1Down:=FALSE;
               Drag_Mode:=FALSE;
               IF not Handled THEN H:=FALSE;
          END;
          WM_MOUSEMOVE:
          BEGIN
               IF MouseButton1Down THEN WinSendMsg(NIL,para1,WM_MOUSEDRAG1,Win);
               IF not Handled THEN H:=FALSE;
          END;
          WM_PAINT:
          BEGIN
               _hps:=WinBeginPaint(rc,0,Win);
               MDIPaintNotify(Win,_hps,Extra);
               WinEndPaint(_hps);
          END;
          ELSE IF not Handled THEN H:=FALSE;
      END;
l1:
      Handled:=H;
      MDIHandleEvent:=r;
END;


PROCEDURE TApplication.CenterWindow(Win:HWND);
VAR ScrWidth,ScrHeight:LONGWORD;
    rec:RECTL;
BEGIN
     ScrWidth:=WinQuerySysValue(SV_CXSCREEN,HWND_DESKTOP);
     ScrHeight:=WinQuerySysValue(SV_CYSCREEN,HWND_DESKTOP);
     WinQueryWindowRect(rec,Win);
     WinSetWindowPos(SWP_MOVE OR SWP_ACTIVATE,0,0,(ScrHeight-rec.yTop) DIV 2,
                     (ScrWidth-rec.xRight) DIV 2,HWND_TOP,Win);
END;


{**************************************************************************
*                                                                         *
*                                                                         *
*                Object Implementation TMDIAPPLICATION                    *
*                                                                         *
*                                                                         *
***************************************************************************}

PROCEDURE MDIMessageHandler(para2,para1:POINTER;Msg,Win:LONGWORD);ASM;
BEGIN
     ASM
        PUSH EBP
        MOV EBP,ESP
        SUB ESP,2
        MOVW [EBP-2],0   ;Not Handled

        PUSHL $Win
        PUSHL $Msg
        PUSHL $para1
        PUSHL $para2
        LEA EAX,[EBP-2]
        PUSH EAX
        PUSHL 0
        PUSHL $Win
        MOV AL,2
        CALLDLL PMWIN,843   ;QueryWindowUlong
        ADD ESP,8
        PUSH EAX
        MOV EDI,_MainAppVMT
        PUSH EDI         ;VMT Pointer
        MOV EDI,[EDI+0]  ;get VMT pointer for MDIHandleEvent
        ADD EDI,4
        db ffh,17h       ;CALL NEAR32 [EDI+0] --> in Methode springen
        MOV BL,[EBP-2]
        CMP BL,0
        JNE !hh_1
        ;not handled
        ;Default Window handler
        PUSHL $para2
        PUSHL $para1
        PUSHL $msg
        PUSHL $win
        MOV AL,4
        CALLDLL PMWin,911   ;WinDefWindowProc
        ADD ESP,16
!hh_1:
        LEAVE
        RETN32
     END;
END;

CONSTRUCTOR TMDIApplication.Init(AppMainID:LONGWORD);
BEGIN
     Inherited.Init(AppMainID);
     {Create MDI Window class}
     WinRegisterClass(4,CS_SizeRedraw,@MDIMessageHandler,AppChildName,AppHandle);
END;

DESTRUCTOR TMDIApplication.Done;
BEGIN
END;


FUNCTION TMDIApplication.MDICreateChild(Title:String;Extra:POINTER;
                                         fcfFlags:LONGWORD):HWND;
VAR HWndChild,ChildFrame:HWND;
    fr:LONGWORD;
    _Swp:SWP;
    LastWin:HWND;
BEGIN
     IF ChildCount>=20 THEN
     BEGIN
          ErrorBox('Too much child windows');
          exit;
     END;
     fr:=FCF_SPEEDCHILD or FCF_ICON or fcfFlags;
     LastWin:=ActiveChild;
     ChildFrame:=WinCreateStdWindow(hwndChild,1001,0,0,Title,AppChildName,
                                        fr,0,AppWinHandle);
     IF ActiveChild<>0 THEN IF IsWindowMaximized(ActiveChild) THEN
      RestoreWindow(WinQueryWindow(QW_PARENT,ActiveChild));
     WinSetOwner(ChildFrame,hwndChild);
     GetMaxWindow(_swp);
     WinSetWindowULong(LONGWORD(Extra),0,hwndChild);
     WinSetWindowPos(SWP_SPEED,_swp.cy,_swp.cx,_swp.y,_swp.x,0,ChildFrame);
     MDICreateNotify(hwndchild,Extra);
     MDICreateChild:=ChildFrame;
END;

PROCEDURE TMDIApplication.MDICreateNotify(Win:HWND;Extra:POINTER);
BEGIN
END;

FUNCTION TMDIApplication.MDIGetExtraPointer(Win:HWND):POINTER;
VAr Result:POINTER;
BEGIN
    ASM
       PUSHL 0
       PUSHL $Win
       MOV AL,2
       CALLDLL PMWIN,843   ;WinQueryWindowUlong
       ADD ESP,8
       MOV $Result,EAX
    END;
    MDIGetExtraPointer:=result;
END;

FUNCTION TMDIApplication.MDIGetTopWindow(VAR Extra:POINTER):HWND;
VAR Win:HWND;
BEGIN
     Win:=ActiveChild;
     IF Win<>0 THEN Extra:=MDIGetExtraPointer(Win)
     ELSE Extra:=NIL;
     MDIGetTopWindow:=Win;
END;

BEGIN
      AppWinName:='SERVER';
      AppChildName:='MDICHILD';
END.

