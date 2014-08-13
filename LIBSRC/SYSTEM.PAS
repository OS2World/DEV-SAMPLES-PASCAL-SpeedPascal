{$%} {Forces the compiler to accept SYSTEM as a unit}
UNIT SYSTEM;

{**************************************************************************
*                                                                         *
*                                                                         *
*                                                                         *
*         Main SYSTEM application routines and basic OS/2 APIs            *
*                                                                         *
*                                                                         *
*                                                                         *
*                                                                         *
***************************************************************************}


INTERFACE

CONST
     MAXINT       =32767;
     MININT       =-32768;
     MAXLONGINT  =$7FFFFFFF;
     MINLONGINT  =$80000001;

TYPE
     PCHAR=PSTRING;      {Pointer to Zero terminated string}

     HWND=LONGWORD;
     HPS=LONGWORD;
     HMODULE=LONGWORD;
     PSZ=PString;   {Pointer to zero terminated string}

     PPOINTL=^POINTL;
     POINTL=RECORD
                  x:LONGINT;
                  y:LONGINT;
            END;

     PRECTL=^RECTL;
     RECTL=RECORD
                xLeft:LONGINT;
                yBottom:LONGINT;
                xRight:LONGINT;
                yTop:LONGINT;
           END;

     PQMSG=^QMSG;
     QMSG=RECORD
              _hwnd:HWND;
              msg:LONGWORD;
              mp1:POINTER;
              mp2:POINTER;
              time:LONGWORD;
              ptl:POINTL;
              reserved:LONGWORD;
          END;

     PSWP=^SWP;
     SWP=RECORD
               fl:LONGWORD;
               cy:LONGWORD;
               cx:LONGWORD;
               y:LONGWORD;
               x:LONGWORD;
               hwndInsertBehind:HWND;
               _hwnd:HWND;
               ulReserved1:LONGWORD;
               ulReserved2:LONGWORD;
         END;

    PSWPBUF=^TSWPBUF;
    TSWPBUF=ARRAY[0..20] OF SWP;


    PLONGBUF=^TLONGBUF;
    TLONGBUF=ARRAY[0..65530] OF LONGWORD;

    PScreenBuf=^ScreenBuf;
    ScreenBuf=array[0..30] of string;

    PAnose=record
                 bFamilyType:BYTE;
                 bSerifStyle:BYTE;
                 bWeight:BYTE;
                 bProportion:BYTE;
                 bContrast:BYTE;
                 bStrokeVariation:BYTE;
                 bArmStyle:BYTE;
                 bLetterform:BYTE;
                 bMidline:BYTE;
                 bXHeight:BYTE;
                 fbPassedISO:BYTE;
                 fbFailedISO:BYTE;
           end;

    PFontMetrics=^FontMetrics;
    FontMetrics=record
                        szFamilyname:ARRAY[0..31] OF CHAR;
                        szFacename:ARRAY[0..31] OF CHAR;
                        idRegistry:WORD;
                        usCodePage:WORD;
                        lEmHeight:LONGWORD;
                        lXHeight:LONGWORD;
                        lMaxAscender:LONGWORD;
                        lMaxDescender:LONGWORD;
                        lLowerCaseAscent:LONGWORD;
                        lLowerCaseDescent:LONGWORD;
                        lInternalLeading:LONGWORD;
                        lExternalLeading:LONGWORD;
                        lAveCharWidth:LONGWORD;
                        lMaxCharInc:LONGWORD;
                        lEmInc:LONGWORD;
                        lMaxBaselineExt:LONGWORD;
                        sCharSlope:INTEGER;
                        sInlineDir:INTEGER;
                        sCharRot:INTEGER;
                        usWeightClass:INTEGER;
                        usWidthClass:INTEGER;
                        sXDeviceRes:INTEGER;
                        sYDeviceRes:INTEGER;
                        sFirstChar:INTEGER;
                        sLastChar:INTEGER;
                        sDefaultChar:INTEGER;
                        sBreakChar:INTEGER;
                        sNominalPointSize:INTEGER;
                        sMinimumPointSize:INTEGER;
                        sMaximumPointSize:INTEGER;
                        fsType:INTEGER;
                        fsDefn:INTEGER;
                        fsSelection:INTEGER;
                        fsCapabilities:INTEGER;
                        lSubscriptXSize:LONGWORD;
                        lSubscriptYSize:LONGWORD;
                        lSubscriptXOffset:LONGWORD;
                        lSubscriptYOffset:LONGWORD;
                        lSuperscriptXSize:LONGWORD;
                        lSuperscriptYSize:LONGWORD;
                        lSuperscriptXOffset:LONGWORD;
                        lSuperscriptYOffset:LONGWORD;
                        lUnderscoreSize:LONGWORD;
                        lUnderscorePosition:LONGWORD;
                        lStrikeoutSize:LONGWORD;
                        lStrikeoutPosition:LONGWORD;
                        sKerningPairs:INTEGER;
                        sFamilyClass:INTEGER;
                        lMatch:LONGWORD;
                        FamilyNameAtom:LONGWORD;
                        FaceNameAtom:LONGWORD;
                        _panose:PANOSE;
                END;

    TYPE PFATTRS=^FATTRS;
    FATTRS=record
               usRecordLength:WORD;
               fsSelection:WORD;
               lMatch:LONGWORD;
               szFacename:array[0..31] of char;
               idRegistry:WORD;
               usCodePage:WORD;
               lMaxBaselineExt:LONGWORD;
               lAveCharWidth:LONGWORD;
               fsType:WORD;
               fsFontUse:WORD;
           end;

VAR PMScrBuf:PScreenBuf;

CONST
     { Standard Window Messages }
     WM_NULL                  =$0000;
     WM_CREATE                =$0001;
     WM_DESTROY               =$0002;
     WM_ENABLE                =$0004;
     WM_SHOW                  =$0005;
     WM_MOVE                  =$0006;
     WM_SIZE                  =$0007;
     WM_ADJUSTWINDOWPOS       =$0008;
     WM_CALCVALIDRECTS        =$0009;
     WM_SETWINDOWPARAMS       =$000a;
     WM_QUERYWINDOWPARAMS     =$000b;
     WM_HITTEST               =$000c;
     WM_ACTIVATE              =$000d;
     WM_SETFOCUS              =$000f;
     WM_SETSELECTION          =$0010;
     WM_PPAINT                =$0011;
     WM_PSETFOCUS             =$0012;
     WM_PSYSCOLORCHANGE       =$0013;
     WM_PSIZE                 =$0014;
     WM_PACTIVATE             =$0015;
     WM_PCONTROL              =$0016;
     WM_COMMAND               =$0020;
     WM_SYSCOMMAND            =$0021;
     WM_HELP                  =$0022;
     WM_PAINT                 =$0023;
     WM_TIMER                 =$0024;
     WM_SEM1                  =$0025;
     WM_SEM2                  =$0026;
     WM_SEM3                  =$0027;
     WM_SEM4                  =$0028;
     WM_CLOSE                 =$0029;
     WM_QUIT                  =$002a;
     WM_SYSCOLORCHANGE        =$002b;
     WM_SYSVALUECHANGED       =$002d;
     WM_APPTERMINATENOTIFY    =$002e;
     WM_PRESPARAMCHANGED      =$002f;

     { Control notification messages }
     WM_CONTROL               =$0030;
     WM_VSCROLL               =$0031;
     WM_HSCROLL               =$0032;
     WM_INITMENU              =$0033;
     WM_MENUSELECT            =$0034;
     WM_MENUEND               =$0035;
     WM_DRAWITEM              =$0036;
     WM_MEASUREITEM           =$0037;
     WM_CONTROLPOINTER        =$0038;
     WM_QUERYDLGCODE          =$003a;
     WM_INITDLG               =$003b;
     WM_SUBSTITUTESTRING      =$003c;
     WM_MATCHMNEMONIC         =$003d;
     WM_SAVEAPPLICATION       =$003e;

     { Frame window related messages }

     WM_FLASHWINDOW           =$0040;
     WM_FORMATFRAME           =$0041;
     WM_UPDATEFRAME           =$0042;
     WM_FOCUSCHANGE           =$0043;

     WM_SETBORDERSIZE         =$0044;
     WM_TRACKFRAME            =$0045;
     WM_MINMAXFRAME           =$0046;
     WM_SETICON               =$0047;
     WM_QUERYICON             =$0048;
     WM_SETACCELTABLE         =$0049;
     WM_QUERYACCELTABLE       =$004a;
     WM_TRANSLATEACCEL        =$004b;
     WM_QUERYTRACKINFO        =$004c;
     WM_QUERYBORDERSIZE       =$004d;
     WM_NEXTMENU              =$004e;
     WM_ERASEBACKGROUND       =$004f;
     WM_QUERYFRAMEINFO        =$0050;
     WM_QUERYFOCUSCHAIN       =$0051;
     WM_OWNERPOSCHANGE        =$0052;
     WM_CALCFRAMERECT         =$0053;
     WM_WINDOWPOSCHANGED      =$0055;
     WM_ADJUSTFRAMEPOS        =$0056;
     WM_QUERYFRAMECTLCOUNT    =$0059;
     WM_QUERYHELPINFO         =$005B;
     WM_SETHELPINFO           =$005C;
     WM_ERROR                 =$005D;
     WM_REALIZEPALETTE        =$005E;

     { Key/Character input messages }
     WM_CHAR                  =$007a;
     WM_VIOCHAR               =$007b;

     { Mouse input messages }
     WM_MOUSEFIRST            =$0070;
     WM_MOUSELAST             =$0079;
     WM_BUTTONCLICKFIRST      =$0071;
     WM_BUTTONCLICKLAST       =$0079;
     WM_MOUSEMOVE             =$0070;
     WM_BUTTON1DOWN           =$0071;
     WM_BUTTON1UP             =$0072;
     WM_BUTTON1DBLCLK         =$0073;
     WM_BUTTON2DOWN           =$0074;
     WM_BUTTON2UP             =$0075;
     WM_BUTTON2DBLCLK         =$0076;
     WM_BUTTON3DOWN           =$0077;
     WM_BUTTON3UP             =$0078;
     WM_BUTTON3DBLCLK         =$0079;
     WM_MOUSEMAP              =$007D;
     WM_EXTMOUSEFIRST         =$0410;
     WM_EXTMOUSELAST          =$0419;
     WM_CHORD                 =$0410;
     WM_BUTTON1MOTIONSTART    =$0411;
     WM_BUTTON1MOTIONEND      =$0412;
     WM_BUTTON1CLICK          =$0413;
     WM_BUTTON2MOTIONSTART    =$0414;
     WM_BUTTON2MOTIONEND      =$0415;
     WM_BUTTON2CLICK          =$0416;
     WM_BUTTON3MOTIONSTART    =$0417;
     WM_BUTTON3MOTIONEND      =$0418;
     WM_BUTTON3CLICK          =$0419;
     WM_MOUSETRANSLATEFIRST   =$0420;
     WM_MOUSETRANSLATELAST    =$0428;
     WM_BEGINDRAG             =$0420;
     WM_ENDDRAG               =$0421;
     WM_SINGLESELECT          =$0422;
     WM_OPEN                  =$0423;
     WM_CONTEXTMENU           =$0424;
     WM_CONTEXTHELP           =$0425;
     WM_TEXTEDIT              =$0426;
     WM_BEGINSELECT           =$0427;
     WM_ENDSELECT             =$0428;
     WM_PENFIRST              =$04C0;
     WM_PENLAST               =$04FF;
     WM_MMPMFIRST             =$0500;
     WM_MMPMLAST              =$05FF;

VAR CheckBreak:BOOLEAN;        {Enables/Disables Ctrl-Break checks}
    ExitCode:WORD;             {The exitcode from main process}
    ErrorAddr:LONGWORD;        {32 Bit linear error adress}
    ExitProc:POINTER;          {Exit procedures chain}
    IORESULT:LONGWORD;         {In/Out result}
    SEEKMODE:LongWord;         {Mode for file seek operations}
    FILEMODE:LongWord;         {Mode for file open operations}
    HeapOrg:Pointer;           {Bottom of heap}
    HeapEnd:Pointer;           {End of heap}
    HeapPtr:Pointer;           {Actual heap position}
    HeapSize:LONGWORD;         {Size of heap}
    PMCrtWindow:LONGWORD;      {CRT Window for text output}
    PMCrtFrameHandle:LONGWORD; {Frame handle for CRT Window}
    PMCrtTitle:STRING;         {Title for CRT Window}
    DrawLocX,DrawLocY:LONGWORD;{Actual drawing position}
    Apphandle:LONGWORD;        {Main application PM anchor handle}
    AppQueueHandle:LONGWORD;   {Main application queue handle}
    AlternateExit:BOOLEAN;     {Set if PMObject is active for WM_QUIT Message}
    MaxLines:LONGWORD;         {Maximal count of crt lines}
    TextCol,TextBackCol:LONGWORD;  {Current colors for text output}
    CrtKeyCount:Byte;
    KeyBuffer:array[0..33] of char;
    CursorVisible:LONGWORD;    {indicates that cursor is visible/invisible}
    MaxDrawStarty,MaxDrawLeny:LONGWORD;
    ArgStart:POINTER; {Pointer to program arguments}
    BlockReadResult:LONGWORD;
    BlockWriteResult:LONGWORD;
    DllModule:LONGWORD;  {When the module is a DLL Init Module at main BEGIN}
    DllTerminating:LONGWORD; {When the module is a DLL Terminating flag at main BEGIN}
    DllInitTermResult:LONGWORD; {indicates success of DLL init/term}
    ModuleCount:BYTE; {If it is a DLL modules currently using this DLL}

CONST
    {Keyboard scancodes}
    kbCLeft       =99;
    kbCRight      =100;
    kbCUp         =97;
    kbCDown       =102;
    kbDel         =105;
    kbInsert      =104;
    kbEnd         =101;
    kbPos1        =96;
    kbPageDown    =103;
    kbPageUp      =98;
    kbBS          =8;
    kbCR          =13;
    kbF1          =59;
    kbF2          =60;
    kbF3          =61;
    kbF4          =62;
    kbF5          =63;
    kbF6          =64;
    kbF7          =65;
    kbF8          =66;
    kbF9          =67;
    kbF10         =68;
    kbESC         =1;
    kbCtrl        =29;

    kbCtrlA       =286;
    kbCtrlB       =304;
    kbCtrlC       =302;
    kbCtrlD       =288;
    kbCtrlE       =274;
    kbCtrlF       =289;
    kbCtrlG       =290;
    kbCtrlH       =291;
    kbCtrlI       =279;
    kbCtrlJ       =292;
    kbCtrlK       =293;
    kbCtrlL       =294;
    kbCtrlM       =306;
    kbCtrlN       =305;
    kbCtrlO       =280;
    kbCtrlP       =281;
    kbCtrlQ       =272;
    kbCtrlR       =275;
    kbCtrlS       =287;
    kbCtrlT       =276;
    kbCtrlU       =278;
    kbCtrlV       =303;
    kbCtrlW       =273;
    kbCtrlX       =301;
    kbCtrlY       =300;
    kbCtrlZ       =277;
    kbCtrlF1      =315;
    kbCtrlF2      =316;
    kbCtrlF3      =317;
    kbCtrlF4      =318;
    kbCtrlF5      =319;
    kbCtrlF6      =320;
    kbCtrlF7      =321;
    kbCtrlF8      =322;
    kbCtrlF9      =323;
    kbCtrlF10     =324;



FUNCTION  MAXAVAIL:LongWord;
FUNCTION  MEMAVAIL:LongWord;
PROCEDURE GETMEM(var p:Pointer;size:LongWord);
PROCEDURE FREEMEM(var p:pointer;size:LongWord);
PROCEDURE NewSystemHeap;  {free the whole (!) heap and generate new heap}

PROCEDURE BYTEMOVE(var source;var dest;size:LongWord);
PROCEDURE MOVE(var source;var dest;size:LongWord);
PROCEDURE FILLCHAR(var dest;size:LongWord;value:byte);

FUNCTION POS(item:string;source:string):Byte;
FUNCTION COPY(source:string;start,ende:Byte):String;
PROCEDURE SUBSTR(VAR source:string;start,ende:Byte);
PROCEDURE Str(l:LongInt;var s:string);
PROCEDURE Val(s:string;var l:longint;var result:Byte);
FUNCTION ToStr(l:longint):string;
FUNCTION  UPCASE(item:char):Char;
PROCEDURE Insert(Source:String;VAR s:string;Ind:Byte);
PROCEDURE Delete(Var s:string;Ind:byte;len:byte);
PROCEDURE CopyStrPChar(s:String;VAR p:PCHAR);
PROCEDURE CopyPCharStr(p:PChar;VAR s:STRING);
PROCEDURE Beep(Freq,duration:LONGWORD);

PROCEDURE Seek(var f:file;n:LongWord);
FUNCTION FilePos(var f:file):LongWord;
FUNCTION FileSize(var f:file):LongWord;
PROCEDURE Reset(var f:file;recsize:LongWord);
PROCEDURE Rewrite(var f:file;recsize:LongWord);
PROCEDURE BlockWrite(VAR f:file;var Buf;Count:LongWord);
PROCEDURE BlockRead(VAR f:file;var Buf;Count:LongWord);
PROCEDURE Rename(VAR f:file;Newname:String);
PROCEDURE CLOSE(VAR f:file);
PROCEDURE ASSIGN(VAR f:file;s:String);
FUNCTION Eof(VAR f:FILE):Boolean;
PROCEDURE Erase(name:STRING);
PROCEDURE CHDIR(path:string);
PROCEDURE GETDIR(drive:byte;var path:string);
PROCEDURE RMDIR(dir:string);
PROCEDURE MKDIR(dir:string);

PROCEDURE ClrScr;
FUNCTION KeyPressed: Boolean;
FUNCTION ReadKey: Char;
PROCEDURE CreateLogFont(_HPS:LONGWORD;VAR facename:STRING;hei,len:LONGWORD);
PROCEDURE GOTOXY(x,y:LONGWORD);

FUNCTION  PARAMSTR(item:Byte):string;
FUNCTION  PARAMCOUNT:Byte;
PROCEDURE PutMemPtr(p:Pointer;Offset:LONGWORD;Value:BYTE);
FUNCTION GetMemPtr(p:Pointer;Offset:LONGWORD):BYTE;
PROCEDURE Halt(code:BYTE);
PROCEDURE RunError(Code:BYTE);


PROCEDURE MainDispatchLoop;

FUNCTION LongToPointer(l:LONGWORD):POINTER;
FUNCTION PointerToLong(p:POINTER):LONGWORD;

IMPLEMENTATION

PROCEDURE NewSystemHeap;  {delete old system heap and create new one}
BEGIN
    {Free old system heap and generate new}
    ASM
       ;Free old system heap
       PUSHL _HeapOrg
       MOV AL,1
       CALLDLL DosCalls,347   ;DosSubUnsetMem
       ADD ESP,4
       PUSHL _HeapOrg
       MOV AL,1
       CALLDLL DosCalls,304   ;DosFreeMem
       ADD ESP,4

       ;generate new system heap
       MOV EAX,8192    ;Allocate 8MB private memory
       MOV EBX,1024
       MUL EBX
       MOV _HeapSize,EAX
       PUSHL 3         ;Flags PAG_READ|PAG_WRITE
       PUSH EAX        ;Length of memory
       PUSHL OFFSET(_Heaporg)
       MOV AL,3             ;3 Parameters
       CALLDLL DosCalls,299 ;DosAllocMem
       ADD ESP,12            ;Clear Stack

       ;Prepare the memory block for suballocation
       PUSHL _HeapSize      ;Size of Heap
       PUSHL 5              ;Flags DOSSUB_INIT|DOSSUB_SPARSE_OBJ
       PUSHL _Heaporg
       MOV AL,3
       CALLDLL DosCalls,344 ;DosSubSetMem
       ADD ESP,12            ;Clear Stack

       ;Set the system pointers
       MOV EAX,_HeapOrg
       MOV _HeapPtr,EAX
       ADD EAX,_HeapSize
       MOV _HeapEnd,EAX
    END;
END;

FUNCTION LongToPointer(l:LONGWORD):POINTER;ASM;
BEGIN
     ASM
        MOV EBX,ESP
        MOV EAX,[EBX+4]
        RETN32 4
     END;
END;

FUNCTION PointerToLong(p:POINTER):LONGWORD;ASM;
BEGIN
     ASM
        MOV EBX,ESP
        MOV EAX,[EBX+4]
        RETN32 4
     END;
END;


PROCEDURE PutMemPtr(p:Pointer;Offset:LONGWORD;Value:BYTE);
BEGIN
     ASM
        MOV EDI,$p
        ADD EDI,$Offset
        MOV AL,$Value
        MOV [EDI+0],AL
     END;
END;

FUNCTION GetMemPtr(p:Pointer;Offset:LONGWORD):BYTE;ASM;
BEGIN
     ASM
        PUSH EBP
        MOV EBP,ESP
        MOV EDI,$p
        ADD EDI,$Offset
        MOV AL,[EDI+0]
        LEAVE
        RETN32 8
     END;
END;




ASSEMBLER

!ParaInfo PROC NEAR32  ;(AL=Function - 1 count of parameters to CL
                       ;               2 Pointer to parameter CL to ESI
                       ;Input:argument start in ESI
         MOV BX,0      ;we start with parameter 0
         CMP AL,2      ;get parameter name ?
         JNE !no_name
         PUSH ESI
         CMP CL,0      ;parameter 0 required ?
         JE !no_args   ;Thats cool (or it sucks)
         POP ESI
!no_name:
         ;Overread the EXE file name
         CLD
         PUSH AX
!rrloop:
         LODSB
         CMP AL,0
         JNE !rrloop
         POP AX

         CMP AL,2   ;get parameter name ?
         JE !get_argname
         MOV CL,255 ;impossible parameter
!get_argname:
         XOR CH,CH
         MOV BX,1      ;now finally we start with parameter 1

         LODSB
         ;check whether the first character is a separator
         CMP AL,' '
         JE !aagain
         CMP AL,0   ;is this already the end -->Urrgh !
         JNE !al2
         PUSHL 0    ;The (nonexistent) parameters -->Throw it away guy !
         MOV BL,0   ;No parameters
         JMP !no_args
!al2:
         DEC ESI    ;restore old position
!aagain:
         PUSH ESI   ;save last adress
         CMP CL,BL  ;is the parameter reached ??
         JE !no_args
!readloop:
         LODSB
         CMP AL,0
         JE !no_args1  ;No more arguments detected
         ;check all separators possible
         CMP AL,' '
         JE !separator
         ;No separator --> normal character
         JMP !readloop
!separator:
         ;Check whether more separators follow
         LODSB
         CMP AL,' '
         JE !one_more
         CMP AL,0      ;A zero parameter is stupid
         JNE !no_more
         POP EAX       ;Clear stack
         PUSHL 0       ;The (nonexistent) parameter -->Throw it away guy !
         JMP !no_args
!one_more:
         JMP !separator
!no_more:
         DEC ESI
         INC BX        ;Increment parameter count
         POP EAX       ;clear stack
         JMP !aagain
!no_args1:
         ;Argument index was invalid
         POP ESI   ;Clear Stack
         PUSHL 0   ;Pointer to parameter is NIL
!no_args:
         MOV CL,BL     ;Parameter count
         POP ESI       ;Adress of last parameter
         RETN32
!ParaInfo ENDP

END;

FUNCTION  PARAMSTR(item:Byte):string;ASM;
BEGIN
     ASM
         MOV EBX,ESP
         MOV CL,[EBX+4]               ;index to CL
         MOV AL,2                     ;Get Parameter name
         MOV ESI,_ArgStart
         CALLN32 !ParaInfo
         MOVB !TempString,0          ;Result string is empty
         CMP ESI,0                    ;Parameter invalid ?
         JE _Lpe                      ;--> It sucks !

         MOV EDI,OFFSET(!TempString)
         XOR AL,AL    ;Stringlen to 0
         STOSB
         MOV CL,0     ;Len is 0
         CLD
__lp1:
         LODSB
         ;Check all separators
         CMP AL,' '
         JE __Lps
         CMP AL,0    ;Last parameter
         JE __Lps
         INC CL
         ;No separator --> save
         STOSB
         JMP __lp1
__Lps:
         MOV !TempString,CL    ;set Stringlen
         MOV Al,0               ;termionate string with zero
         STOSB
_lpe:
         RETN32 2
    END;
END;



FUNCTION  PARAMCOUNT:Byte;ASM;
BEGIN
     ASM
           MOV AL,1  ;get parametercount
           MOV ESI,_ArgStart
           CALLN32 !ParaInfo
           MOV AL,CL
           XOR AH,AH
           RETN32
     END;
END;



PROCEDURE Beep(Freq,duration:LONGWORD);
BEGIN
     ASM
         PUSHL $duration
         PUSHL $freq
         MOV AL,2
         CALLDLL DOSCALLS,286  ;DosBeep
         ADD ESP,8
     END;
END;



PROCEDURE MainDispatchLoop;
VAR _qmsg:QMSG;
BEGIN
     ASM
!ndis:
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

PROCEDURE CopyStrPChar(s:String;VAR p:PCHAR);ASM;
BEGIN
     ASM
        MOV EBX,ESP
        MOV ESI,[EBX+8]  ;Source
        MOV EDI,[EBX+4] ;Dest
        MOV CL,[ESI+0]
        INC ESI
        MOVZX ECX,CL
        CMP CX,0
        JE !scpc
        CLD
        REP
        MOVSB
!scpc:
        MOVB [EDI+0],0

        RETN32 8
     END;
END;

PROCEDURE CopyPCharStr(p:PChar;VAR s:String);ASM;
BEGIN
     ASM
        MOV EBX,ESP

        MOV ESI,[EBX+8]  ;Source
        MOV EDI,[EBX+4] ;Dest
        PUSH EDI
        INC EDI
        MOV CL,0
        CLD
!aclo:
        LODSB
        CMP AL,0
        JE !scpc_1
        STOSB
        INC CL
        JMP !aclo
!scpc_1:
        POP EDI
        MOV [EDI+0],CL

        RETN32 8
     END;
END;

ASSEMBLER

!Concat PROC NEAR32
        MOV EBX,ESP
        MOV EDI,[EBX+8]    ;s
        MOV ESI,[EBX+4]    ;s1
        MOVZXB ECX,[EDI+0] ;length of s
        CLD
        LODSB
        ADD [EDI+0],AL
        JNC !!ll1
        MOVB [EDI+0],255
        MOV AL,CL
        NOT AL
!!ll1:
        ADD EDI,ECX
        INC EDI
        MOV CL,AL
        REP
        MOVSB
        MOV AL,0      ;Abschluá PChar
        STOSB
        RETN32 4
!Concat ENDP

END; {Assembler}

PROCEDURE Halt(code:BYTE);ASM;
BEGIN
     ASM
        MOV EBX,ESP
        MOV AL,[EBX+4]
        XOR AH,AH
        MOV _ExitCode,AX
        CMPD _PMCrtWindow,0   ;is a CrtWindow created ?
        JE !qt                ;No !
        CALLN32 _MainDispatchLoop ;Wait until CRT terminates
!qt:
        MOV AX,_ExitCode  ;ExitCode holen
        XOR AH,AH
        CMP AL,0   ;Fehler aufgetreten ?
        JE noexerr

        PUSH AX      ;Save Return code

        MOV EDI,OFFSET(!ErrorMsg)
        ADD EDI,24   ;Focus after error
        XOR AH,AH
        MOV BX,10
        XOR CX,CX
Lw46:
        XOR DX,DX
        DIV BX
        ADD DL,'0'
        MOV [EDI+0],DL
        INC EDI
        INC CX
        OR AX,AX
        JNE Lw46

        PUSHL OFFSET(!TempRet);
        PUSHL 41                 ;length of text
        PUSHL OFFSET(!ErrorMsg)
        PUSHL 1                  ;to Standard output
        MOV AL,4                 ;4 Parameters
        CALLDLL DosCalls,282     ;DosWrite
        ADD ESP,16               ;Parameters from stack
        POP AX     ;Get Return Code
noexerr:
        PUSH AX

        MOV EAX,_PMCrtWindow
        CMP EAX,0
        JE !nodel

        PUSHL _PMCrtWindow
        MOV AL,1
        CALLDLL PMWIN,728   ;WinDestroyWindow
        ADD ESP,4
!nodel:
        ;Free system heap
        PUSHL _HeapOrg
        MOV AL,1
        CALLDLL DosCalls,347   ;DosSubUnsetMem
        ADD ESP,4
        PUSHL _HeapOrg
        MOV AL,1
        CALLDLL DosCalls,304   ;DosFreeMem
        ADD ESP,4

        PUSHL _AppQueueHandle
        MOV AL,1
        CALLDLL PMWIN,726   ;WinDestroyMsgQueue
        ADD ESP,4
        PUSHL _AppHandle
        MOV AL,1
        CALLDLL PMWIN,888   ;WinTerminate
        ADD ESP,4

        POP AX
        MOVZX EAX,AX
        PUSHL 1               ;Exit the whole process
        PUSH EAX              ;Return Code
        MOV AL,2
        CALLDLL DosCalls,234  ;DosExit
        ADD ESP,8
        RETN32
    END; {asm}
END;

PROCEDURE RunError(Code:BYTE);ASM;
BEGIN
     ASM
        MOV EBX,ESP
        MOV AL,[EBX+4]
        POP ECX         ;Adress of CALLN32 _Runerror
        POP ECX         ;Error Adress
        MOV _ErrorAddr,ECX
        XOR AH,AH
        MOV _ExitCode,AX
exloop:
        PUSHL OFFSET(@raddr) ;Return adress for ExitProc
        PUSHL _ExitProc    ;ExitProc on Stack
        RETN32             ;jump into ExitProc
@raddr
        JMP exloop  ;until termination
     END; {asm}
END;

ASSEMBLER

!PCharCopy PROC NEAR32
         MOV EBX,ESP
         MOV ESI,[EBX+8]
         MOV EDI,[EBX+4]
         CLD
!re:
         LODSB
         STOSB
         CMP AL,0
         JNE !re
         CLD
         RETN32 8
!PCharCopy ENDP

END;

PROCEDURE GetAPIMem(VAR p:POINTER;size:LONGWORD);
BEGIN
     ASM
        PUSHL 19        ;Flags PAG_READ|PAG_WRITE|PAG_COMMIT
        PUSHL $size     ;Length of memory
        PUSHL $p
        MOV AL,3             ;3 Parameters
        CALLDLL DosCalls,299 ;DosAllocMem
        ADD ESP,12            ;Clear Stack
        CMP EAX,0
        JE !eok
        MOV AX,214
        CALLN32 _Runerror      ;Illegal pointer operation
!eok:
     END;
END;

PROCEDURE FreeAPIMem(VAR p:POINTER;size:LONGWORD);
BEGIN
     ASM
        MOV ESI,$p
        PUSHL [ESI+0]
        MOV AL,1
        CALLDLL DosCalls,304   ;DosFreeMem
        ADD ESP,4
        CMP EAX,0
        JE !eok_1
        MOV AX,214
        CALLN32 _Runerror      ;Illegal pointer operation
!eok_1:
     END;
END;


PROCEDURE GETMEM(var p:Pointer;size:LongWord);
BEGIN
     ASM
        MOV EAX,[EBP+8]       ;Size
        ADD EAX,7
        AND AL,F8h            ;Align on 8 byte boundary
        PUSH EAX
        PUSHL [EBP+12]
        PUSHL _HeapOrg
        MOV AL,3
        CALLDLL DosCalls,345   ;DosSubAllocMem
        ADD ESP,12             ;Clear Stack
        CMP EAX,0
        JE !wg
        MOV AX,214
        CALLN32 _Runerror      ;Illegal pointer operation
!wg:
        MOV ESI,[EBP+12]
        MOV EAX,[ESI+0]        ;Adresse
        ADD EAX,[EBP+8]
        CMP EAX,_HeapPtr
        JB !eg
        MOV _HeapPtr,EAX
!eg:
     END;
END;

PROCEDURE FREEMEM(var p:pointer;size:LongWord);
BEGIN
     ASM
         mov esi,[EBP+12]      ;Addr
         mov esi,[esi+0]

         MOV EAX,[EBP+8]       ;Size
         ADD EAX,7
         AND AL,F8h            ;Align on 8 byte boundary
         PUSH EAX
         MOV ESI,[EBP+12]
         MOV EAX,[ESI+0]
         MOVD [ESI+0],0       ;Invalidate pointer
         MOV EBX,EAX
         ADD EBX,[EBP+8]
         CMP EBX,_HeapPtr
         JB !nf
         MOV _HeapPtr,EAX
!nf:
         PUSH EAX              ;Adress of block
         PUSHL _HeapOrg
         MOV AL,3
         CALLDLL DosCalls,346  ;DosSubFreeMem
         ADD ESP,12
         CMP EAX,0
         JE !ef
         MOV AX,214           ;Illegal pointer operation
         CALLN32 _RunError
!ef:
     END;
END;

FUNCTION  MAXAVAIL:LongWord;ASM;
BEGIN
     ASM
        MOV EAX,_HeapEnd
        SUB EAX,_HeapPtr
        RETN32
     END;
END;


FUNCTION  MEMAVAIL:LongWord;ASM;
BEGIN
     ASM
        MOV EAX,_HeapEnd
        SUB EAX,_HeapPtr
        RETN32
     END;
END;

PROCEDURE BYTEMOVE(var source;var dest;size:LongWord);ASM;
BEGIN
     ASM
         MOV EBX,ESP
         MOV ESI,[EBX+12]
         MOV EDI,[EBX+8]
         MOV ECX,[EBX+4]
         CLD
         CMP ESI,EDI
         JAE !Mo1
         ADD ESI,ECX
         ADD EDI,ECX
         DEC ESI
         DEC EDI
         STD
!Mo1:
         REP
         MOVSB
         CLD
         RETN32 12
    END;
END;


PROCEDURE MOVE(var source;var dest;size:LongWord);ASM;
BEGIN
     ASM
        MOV EBX,ESP
        MOV ESI,[EBX+12]
        MOV EDI,[EBX+8]
        MOV ECX,[EBX+4]
        CLD
        CMP ESI,EDI
        JB !Mo2
        CMP ECX,0
        JE __L12_1
        TEST ECX,1
        JE __L11_1         ;schon gerade Anzahl
        MOVSB
        JMP !Mo2_1
!Mo2:
        ADD ESI,ECX
        ADD EDI,ECX
        DEC ESI
        DEC EDI
        STD
        CMP ECX,0
        JE __L12_1
        TEST ECX,1
        JNE __L__11_1         ;schon gerade Anzahl ??
        DEC EDI               ;ja !!
        DEC ESI
        JMP __L11_1
__L__11_1:
        MOVSB
        DEC ESI
        DEC EDI
!Mo2_1:
        DEC ECX            ;count auf gerade Anzahl
        CMP ECX,0
        JE __L12_1
__L11_1:
        SHR ECX,1         ;da wortweises šbertragen
        REP
        db 66h            ;no double word
        MOVSW
__L12_1:
        RETN32 12
     END;
END;


PROCEDURE FILLCHAR(var dest;size:LongWord;value:byte);ASM;
BEGIN
    ASM
        CLD
        MOV EBX,ESP
        MOV EDI,[EBX+10]   ;Destination pointer
        MOV ECX,[EBX+6]    ;count
        CMP ECX,0          ;count=0 ??
        JE __L12
        MOV AL,[EBX+4]     ;value
        MOV AH,AL

        CMP ECX,0
        JE __L12
        TEST ECX,1
        JE __L11           ;schon gerade Anzahl
        STOSB
        DEC ECX            ;count auf gerade Anzahl
        CMP ECX,0
        JE __L12
__L11:
        SHR ECX,1         ;da wortweises šbertragen
        REP
        db 66h            ;no double word
        STOSW
__L12:
        RETN32 10
     END;
END;



ASSEMBLER

;***************************************************
;String Support routines
;***************************************************

!StrCopy PROC NEAR32
                CLD
                MOV EBX,ESP
                MOV ESI,[EBX+10]     ;Source String
                MOV EDI,[EBX+6]     ;Destination String
                MOV CL,[EBX+4]       ;Maximum length
                MOVZX ECX,CL
                LODSB
                CMP AL,CL
                JBE _L1
                MOV AL,CL
_L1:
                STOSB
                MOV CL,AL
                MOVZX ECX,CL
                CMP ECX,0
                JE _eee1

                TEST ECX,1
                JE __L11_2         ;schon gerade Anzahl
                MOVSB
                DEC ECX            ;count auf gerade Anzahl
                CMP ECX,0
                JE _eee1
__L11_2:
                SHR ECX,1         ;da wortweises šbertragen
                REP
                db 66h            ;no double word
                MOVSW
_eee1:
                MOV AL,0          ;Abschluá PChar
                STOSB
                RETN32 10
!StrCopy ENDP


!StrCopyTemp PROC NEAR32
                CLD
                MOV EBX,ESP
                PUSHA
                MOV ESI,[EBX+4]          ;Source String
                MOV EDI,OFFSET(!TempString) ;Destination String
                LODSB                       ;Length of source string
                STOSB                       ;save
                MOV CL,AL                   ;set counter
                MOVZX ECX,CL

                CMP ECX,0
                JE __L12_3
                TEST ECX,1
                JE __L11_3         ;schon gerade Anzahl
                MOVSB
                DEC ECX            ;count auf gerade Anzahl
                CMP ECX,0
                JE __L12_3
__L11_3:
                SHR ECX,1         ;da wortweises šbertragen
                REP
                db 66h            ;no double word
                MOVSW
__L12_3:
                MOV EDI,OFFSET(!TempString)
                MOV AL,[EDI+0]
                XOR AH,AH
                MOVZX EAX,AX
                ADD EDI,EAX
                MOVB [EDI+1],0  ;Abschluá PChar
                POPA
                RETN32 4
!StrCopyTemp ENDP

!AddString PROC NEAR32
        MOV EBX,ESP
        MOV EDI,OFFSET(!TempString3)
        MOV ESI,[EBX+4]    ;s1
        MOVZXB ECX,[EDI+0] ;length of s
        CLD
        LODSB
        ADD [EDI+0],AL
        JNC !!lll1
        MOVB [EDI+0],255
        MOV AL,CL
        NOT AL
!!lll1:
        ADD EDI,ECX
        INC EDI
        MOV CL,AL
        REP
        MOVSB
        MOV AL,0      ;Abschluá PChar
        STOSB
        RETN32 4
!AddString ENDP

!CopyString PROC NEAR32
        CLD
	SUB	EDX,EBX
	CMP	EAX,EBX
	JB	LA1
        MOV	EAX,EBX
LA1:
        STOSB
	MOV	ECX,EAX
	ADD	EBX,ESI
        CMP     ECX,0
        JE __L12_4

        TEST ECX,1
        JE __L11_4         ;schon gerade Anzahl
        MOVSB
        DEC ECX            ;count auf gerade Anzahl
        CMP ECX,0
        JE __L12_4
__L11_4:
        SHR ECX,1         ;da wortweises šbertragen
        REP
        db 66h            ;no double word
        MOVSW
__L12_4:
	MOV	ESI,EBX
	RETN32
!CopyString ENDP

END;

FUNCTION  UPCASE(item:char):Char;ASM;
BEGIN
     ASM
         MOV EBX,ESP
         MOV AL,[EBX+4]
         CMP AL,61h
         JB L32
         CMP AL,7ah
         JA L32
         SUB AL,20h
L32:
         RETN32 2
      END;
END;

FUNCTION COPY(source:string;start,ende:Byte):String;ASM;
BEGIN
     ASM
        PUSH EBP
        MOV EBP,ESP

        MOV ESI,[EBP+12]             ;Source string
        MOV EDI,OFFSET(!TempString)  ;Destination string

        MOVZXB AX,[ESI+0]            ;Length of source
        MOVZXB ECX,$Start            ;Index
        OR ECX,ECX
        JG !_Lab1
        MOV ECX,1
!_Lab1:
        ADD ESI,ECX
        SUB AX,CX
        JB !_Lab3
        INC AX
        MOVZXB CX,$Ende             ;Count
        OR CX,CX
        JGE !_Lab2
        XOR CX,CX
!_Lab2:
        CMP AX,CX
        JBE !_Lab4
        MOV AX,CX
        JMP !_Lab4
!_Lab3:
        XOR AX,AX
!_Lab4:
        STOSB
        MOVZX ECX,AX
        CMP ECX,0
        JE !_Lab5
        REP
        MOVSB
!_Lab5:
        MOV EDI,[EBP+12]
        MOVZXB EAX,[EDI+0]
        ADD EDI,EAX
        MOVB [EDI+1],0  ;Abschluá PChar

        LEAVE
        RETN32 8
     END;
END;

PROCEDURE SUBSTR(VAR source:string;start,ende:Byte);ASM;
BEGIN
      ASM
        PUSH EBP
        MOV EBP,ESP

        MOV ESI,[EBP+12]             ;Source string
        MOV EDI,ESI                  ;Destination string

        MOVZXB AX,[ESI+0]            ;Length of source
        MOVZXB ECX,$Start            ;Index
        OR ECX,ECX
        JG !_Lab1_1
        MOV ECX,1
!_Lab1_1:
        ADD ESI,ECX
        SUB AX,CX
        JB !_Lab3_1
        INC AX
        MOVZXB CX,$Ende             ;Count
        OR CX,CX
        JGE !_Lab2_1
        XOR CX,CX
!_Lab2_1:
        CMP AX,CX
        JBE !_Lab4_1
        MOV AX,CX
        JMP !_Lab4_1
!_Lab3_1:
        XOR AX,AX
!_Lab4_1:
        STOSB
        MOVZX ECX,AX
        CMP ECX,0
        JE !_Lab5_1
        REP
        MOVSB
!_Lab5_1:
        MOV EDI,[EBP+12]
        MOVZXB EAX,[EDI+0]
        ADD EDI,EAX
        MOVB [EDI+1],0  ;Abschluá PChar
        LEAVE
        RETN32 8
     END;
END;


PROCEDURE Str(l:LongInt;var s:string);ASM;
BEGIN
     ASM
        MOV EBX,ESP
        MOV EAX,[EBX+8]
        MOV EDI,[EBX+4]
        PUSH EDI
        POP ESI
        MOVB [EDI+0],0
        MOV EBX,10
        XOR ECX,ECX
        CMP EAX,0
        JNL Lw46_1
        NEG EAX
        MOVB [EDI+0],1
        INC EDI
        MOVB [EDI+0],'-'
Lw46_1:
        XOR EDX,EDX
        DIV EBX
        PUSH DX
        INC CX
        OR EAX,EAX
        JNE Lw46_1
Lw47:
        POP AX
        ADD AL,'0'
        INCB [ESI+0]
        INC EDI
        MOV [EDI+0],AL
        LOOP Lw47

        MOV EBX,ESP
        MOV EDI,[EBX+4]
        MOV AL,[EDI+0]
        MOVZX EAX,AL
        ADD EDI,EAX
        MOVB [EDI+1],0  ;Abschluá PChar
        RETN32 8
     END;
END;

PROCEDURE Val(s:string;var l:longint;var result:Byte);ASM;
BEGIN
     ASM
        PUSH EBP
        MOV EBP,ESP
        SUB ESP,10
        MOV EDI,[EBP+16]   ;s
        MOV CL,[EDI+0]     ;L„nge
        MOVZX ECX,CL
        MOVB [EBP-6],0

        MOVD [EBP-10],10   ;Base
        MOV AL,[EDI+1]
        ADD EDI,ECX
        CMP AL,'$'         ;Hexadecimal ??
        JNE !nohex
        MOVD [EBP-10],16   ;Base
        DEC ECX
!nohex:
        CMP AL,'-'
        JNE !q2
        DEC ECX
        MOVB [EBP-6],1
!q2:
        MOV EBX,1
        MOVW EAX,0
        MOV [EBP-4],EAX
!q1:
        MOV AL,[EDI+0]
        DEC EDI
        CMP AL,48
        JB !qerr
        CMP AL,57
        JNA !noqerr

        CMP AL,102
        JA !qerr
        CMP AL,65
        JB !qerr
        CMP AL,70
        JBE !hexnum
        CMP AL,97
        JB !qerr
        SUB AL,32    ;To upper
!hexnum:
        SUB AL,7
!noqerr:
        SUB AL,48
        MOVZX EAX,AL
        MUL EBX
        MOV EDX,[EBP-4]
        ADD EDX,EAX
        MOV [EBP-4],EDX
        MOV EAX,EBX
        MOV EBX,[EBP-10]  ;Base
        MUL EBX
        MOV EBX,EAX
        LOOP !q1
!qerr:
        MOV EDI,[EBP+8]     ;result
        MOV [EDI+0],CL
        MOV EAX,[EBP-4]
        CMPB [EBP-6],1
        JNE !q3
        NEG EAX
!q3:
        MOV EDI,[EBP+12]    ;l
        MOV [EDI+0],EAX
        LEAVE
        RETN32 12
     END;
END;

FUNCTION ToStr(l:longint):string;ASM;
BEGIN
     ASM
        MOV EBX,ESP
        PUSHL [EBX+4]
        PUSHL OFFSET(!TempString)
        CALLN32 _Str
        RETN32 4
     END;
END;

ASSEMBLER

!StringCmp PROC NEAR32
              MOV EBX,ESP
              CLD
              MOV ESI,[EBX+8]
              MOV EDI,[EBX+4]
              LODSB
              MOV AH,[EDI+0]
              INC EDI
              MOV CL,AL
              CMP CL,AH
              JBE _nl1
              MOV CL,AH
_nl1:
              OR CL,CL
              JE _nl2
              MOVZX ECX,CL
              CLD
              REP
              CMPSB
              JNE _nl3
_nl2:
              CMP AL,AH
_nl3:
              RETN32 8
!StringCmp ENDP

!PStringCmp PROC NEAR32
              MOV EBX,ESP
              CLD
              MOV ESI,[EBX+8]  ;2.String
              MOV EDI,[EBX+4]
              PUSH EDI
              PUSH ESI
              MOV AL,0
!syy:
              CMPB [ESI+0],0
              JE !sxx
              INC AL
              INC ESI
              JMP !syy
!sxx:
              MOV AH,0
!syy1:
              CMPB [EDI+0],0
              JE !sxx1
              INC AH
              INC EDI
              JMP !syy1
!sxx1:
              POP ESI
              POP EDI
              MOV CL,AL
              CMP CL,AH
              JBE _nl1_1
              MOV CL,AH
_nl1_1:
              OR CL,CL
              JE _nl2_1
              MOVZX ECX,CL
              CLD
              REP
              CMPSB
              JNE _nl3_1
_nl2_1:
              CMP AL,AH
_nl3_1:
              RETN32 8
!PStringCmp ENDP

END;

FUNCTION POS(item:string;source:string):Byte;ASM;
BEGIN
     ASM
         PUSH EBP
         MOV EBP,ESP
         MOV ESI,[EBP+12]   ;item
         CLD
         LODSB
         OR AL,AL
         JE !lab2
         MOVZXB EAX,AL
         MOV EDX,EAX
         MOV EDI,[EBP+8]    ;source
         MOVZXB ECX,[EDI+0]
         SUB ECX,EDX
         JB !lab2
         INC ECX
         INC EDI
!lab1:
         LODSB
         REPNE
         SCASB
         JNE !lab2
         MOV EAX,EDI
         MOV EBX,ECX
         MOV ECX,EDX
         DEC ECX
         REPE
         CMPSB
         JE !lab3
         MOV EDI,EAX
         MOV ECX,EBX
         MOV ESI,[EBP+12]   ;item
         INC ESI
         JMP !lab1
!Lab2:
         XOR EAX,EAX
         JMP !Lab4
!lab3:
         DEC EAX
         SUB EAX,[EBP+8]    ;source
!Lab4:
         LEAVE
         RETN32 8
     END;
END;

PROCEDURE Insert(Source:String;VAR s:string;Ind:Byte);
var OldLen:Byte;
    SourceLen:Byte;
Begin
     asm
        CMPB [EBP+8],0
        JE !exx2
        LEA EDI,!TempString
        MOV ESI,[EBP+10]
        INC EDI
        MOV CL,[ESI+0]
        XOR CH,CH
        MOV [EBP-2],CL   ;OldLen
        MOV CL,[EBP+8]   ;ab dieser Position
        CMP CL,[EBP-2]
        JNA !no
        MOV CL,[EBP-2]
        MOV [EBP+8],CL
        INC CL
!no:
        INC ESI
        CMP CL,0
        JE !nc1
        DEC CL
        MOVZX ECX,CL
        CLD
        REP
        MOVSB             ;var s in TempString kopieren
!nc1:
        PUSH ESI          ;alte Position merken
        MOV ESI,[EBP+14]  ;Source
        MOV CL,[Esi+0]
        XOR CH,CH
        MOV [EBP-4],CL    ;SourceLen
        iNC ESI
        CMP CL,0
        JE !nc2
        MOVZX ECX,CL
        CLD
        REP
        MOVSB
!nc2:
        POP ESI         ;alte Position holen
        MOV CL,[EBP-2]  ;Oldlen
        MOV AL,[EBP+8]  ;Index
        DEC AL
        SUB CL,AL
        CMP CL,0
        JE !nc3
        MOVZX ECX,CL
        REP
        MOVSB
!nc3:
        MOV AL,[EBP-2]  ;Oldlen
        ADD AL,[EBP-4]

        MOV !TempString,AL  ;L„nge setzen
        MOV EDI,[EBP+10]
        LEA ESI,!TempString
        MOV CL,AL
        INC CL
        MOVZX ECX,CL
        CLD
        REP
        MOVSB
        MOV EDI,[EBP+10]
        XOR CH,CH
        MOV CL,AL
        MOVZX ECX,CL
        ADD EDI,ECX
        MOVB [EDI+1],0  ;Abschluá PChar
!exx2:
    end;
End;

PROCEDURE Delete(Var s:string;Ind:byte;len:byte);
var newlen:Byte;
BEGIN
     ASM
        MOV EDI,$s        ;var s
        MOV AL,[EDI+0]    ;Length of the string
        MOV CL,$Ind       ;Index in the string
        CMP CL,AL
        JA !exx3
        CMP CL,0
        JE !exx1

        MOVZX ECX,CL      ;Index in the string
        ADD EDI,ECX       ;add the index
        MOV ESI,$s        ;var s
        ADD ESI,ECX       ;add the index
        MOV CL,$len       ;len
        ADD CL,$ind       ;index
        CMP CL,AL         ;greater than maximal length ??
        JNA !cp
        ;len=maximal length-Index
        MOV CL,$Len       ;len
        MOV BL,AL         ;maximal length to bl
        SUB BL,CL
        MOV $Len,CL       ;set len anew
!cp:
        MOV CL,$Len       ;len
        MOVZX ECX,CL
        ADD ESI,ECX       ;add len
        ADD CL,$Ind       ;Index
        DEC CL
        SUB AL,CL
        MOV CL,AL         ;to transmit
        CMP CL,0
        JE !exx1          ;zero bytes

        MOVZX ECX,CL
        CLD
        REP
        MOVSB
!exx1:
        MOV EDI,$s        ;var s
        MOV AL,[EDI+0]    ;current len
        SUB AL,$Len       ;len
        MOV [EDI+0],AL    ;L„nge neu setzen
        MOVZX EAX,AL
        ADD EDI,EAX
        MOVB [EDI+1],0 ;PChar Abschluá
!exx3:
     end;
END;

{*************************************************************************
*                                                                        *
*                                                                        *
*             Procedures and functions for file handling                 *
*                                                                        *
*                                                                        *
**************************************************************************}

PROCEDURE CHDIR(path:string);ASM;
BEGIN
     ASM
        MOV EBX,ESP
        MOV EAX,[EBX+4]
        INC EAX
        PUSH EAX
        MOV AL,1
        CALLDLL DosCalls,255  ;DosSetCurrentDir
        ADD ESP,4
        MOV _IoResult,EAX
        RETN32
     END;
END;

PROCEDURE GETDIR(drive:byte;var path:string);ASM;
BEGIN
     ASM
        PUSH EBP
        MOV EBP,ESP
        SUB ESP,8

        MOV AL,$drive
        CMP AL,0      ;actual drive required ??
        JA !nad

        LEA EAX,[EBP-4]    ;DriveMap
        PUSH EAX
        LEA EAX,[EBP-8]    ;Current drive
        PUSH EAX
        MOV AL,2
        CALLDLL DosCalls,275 ;DosQueryCurrentDisk
        ADD ESP,8

        MOV _IoResult,EAX
        CMPD _IoResult,0
        JNE !egd
        MOV AL,[EBP-8]
!nad:
        MOV EDI,[EBP+8]    ;Path
        INC EDI
        CLD
        ADD AL,64
        STOSB
        MOV AL,':'
        STOSB
        MOV AL,'\'
        STOSB

        MOVD [EBP-4],250   ;max length of dir
        LEA EAX,[EBP-4]
        PUSH EAX
        MOV EAX,[EBP+8]    ;Path
        ADD EAX,4          ;dispatch drive letter and :\
        PUSH EAX
        MOV AL,[EBP+12]    ;Drive number
        MOVZX EAX,AL
        PUSH EAX
        MOV AL,3
        CALLDLL DosCalls,274     ;DosQueryCurrentDir
        ADD ESP,12
        MOV _IoResult,EAX

        CMPD _IoResult,0
        JNE !egd

        MOV CL,255
        MOV ESI,[EBP+8]
        INC ESI
        CLD
!lgd:
        INC CL
        LODSB
        CMP AL,0
        JNE !lgd

        MOV ESI,[EBP+8]
        MOV [ESI+0],CL   ;set string length
!egd:
        LEAVE
        RETN32 6
     END;
END;

PROCEDURE RMDIR(dir:string);ASM;
BEGIN
     ASM
        MOV EBX,ESP
        MOV EAX,[EBX+4]
        INC EAX
        PUSH EAX
        MOV AL,1
        CALLDLL DosCalls,226    ;DosDeleteDir
        ADD ESP,4
        MOV _IoResult,EAX
        RETN32 4
     END;
END;

PROCEDURE MKDIR(dir:string);ASM;
BEGIN
     ASM
        MOV EBX,ESP
        PUSHL 0         ;No extended attributes
        MOV EAX,[EBX+4]
        INC EAX
        PUSH EAX
        MOV AL,2
        CALLDLL DosCalls,270  ;DosCreateDir
        ADD ESP,8
        MOV _IoResult,EAX
        RETN32 4
     END;
END;

PROCEDURE Erase(name:STRING);ASM;
BEGIN
     ASM
         MOV EBX,ESP
         MOV EAX,[EBX+4]
         INC EAX
         PUSH EAX
         MOV AL,1
         CALLDLL DosCalls,259   ;DosDelete
         ADD ESP,4
         MOV _IoResult,EAX
         RETN32
     END;
END;

PROCEDURE Seek(var f:file;n:LongWord);ASM;
BEGIN
     ASM
         PUSH EBP
         MOV EBP,ESP
         SUB ESP,4
         LEA EAX,[EBP-4]
         PUSH EAX
         PUSHL _SeekMode   ;from where to Seek
         PUSHL [EBP+8]     ;Bytes to move
         MOV EDI,[EBP+12]  ;var f
         PUSHL [EDI+0]     ;Handle
         MOV AL,4
         CALLDLL DosCalls,256 ;DosSetFilePtr
         ADD ESP,16
         MOV _IoResult,EAX
         LEAVE
         RETN32 8
      END;
END;

FUNCTION FilePos(var f:file):LongWord;ASM;
BEGIN
     ASM
         PUSH EBP
         MOV EBP,ESP
         SUB ESP,4
         LEA EAX,[EBP-4]
         PUSH EAX
         PUSHL 1                ;from current position
         PUSHL 0
         MOV EDI,[EBP+8]        ;var f
         PUSHL [EDI+0]     ;Handle
         MOV AL,4
         CALLDLL DosCalls,256 ;DosSetFilePtr
         ADD ESP,16
         MOV _IoResult,EAX
         MOV EAX,[EBP-4]   ;result
         LEAVE
         RETN32 4
      END;
END;


FUNCTION FileSize(var f:file):LongWord;ASM;
BEGIN
     ASM
         PUSH EBP
         MOV EBP,ESP
         SUB ESP,8
         MOV EDI,[EBP+8]  ;Var f
         PUSH EDI
         CALLN32 _FilePos
         PUSH EAX
         CMPD,_ioresult,0
         JNE L_19_1   ;Error occured

         LEA EAX,[EBP-8]
         PUSH EAX
         PUSHL 2                ;_End of file
         PUSHL 0
         MOV EDI,[EBP+8]        ;var f
         PUSHL [EDI+0]          ;Handle
         MOV AL,4
         CALLDLL DosCalls,256   ;DosSetFilePtr
         ADD ESP,16
         CMPD _IoResult,0
         JNE L_19_1   ;Error occured

         POP EBX   ;alte Fileposition
         LEA EAX,[EBP-4]
         PUSH EAX
         PUSHL 0                ;Start of file
         PUSH EBX
         MOV EDI,[EBP+8]        ;var f
         PUSHL [EDI+0]     ;Handle
         MOV AL,4
         CALLDLL DosCalls,256 ;DosSetFilePtr
         ADD ESP,16
         MOV _IoResult,EAX
L_19_1:
         MOV EAX,[EBP-8]
         LEAVE
         RETN32 4
      END;
END;



PROCEDURE Reset(var f:file;recsize:LongWord);ASM;
BEGIN
      ASM
         PUSH EBP
         MOV EBP,ESP
         SUB ESP,4         ;Action Taken
         MOV EDI,[EBP+12]  ;Var f
         MOV EAX,[EBP+8]   ;Recsize
         MOV [EDI+4],EAX
         PUSHL [EDI+88]    ;extended Attributes
         PUSHL _FileMode
         PUSHL 1           ;Open If file exists
         PUSHL 0           ;No attributes required
         PUSHL 0
         LEA EAX,[EBP-4]
         PUSH EAX
         LEA EAX,[EDI+0]   ;Handle
         PUSH EAX
         LEA EAX,[EDI+8]   ;Filename
         PUSH EAX
         MOV AL,8
         CALLDLL DosCalls,273  ;DosOpen
         ADD ESP,32
         MOV _IoResult,EAX
         CMPD _IoResult,0
         JNE !ers
         MOV ESI,[EBP+12]
         MOV EAX,_FileMode
         MOV [EDI+92],EAX  ;Patch file mode
!ers:
         LEAVE
         RETN32 8
      END;
END;

PROCEDURE Rewrite(var f:file;recsize:Longword);ASM;
BEGIN
     ASM
         PUSH EBP
         MOV EBP,ESP
         SUB ESP,4         ;Action Taken
         MOV EDI,[EBP+12]  ;Var f
         MOV EAX,[EBP+8]   ;Recsize
         MOV [EDI+4],EAX
         PUSHL [EDI+88]    ;extended Attributes
         PUSHL _FileMode
         PUSHL  18         ;Create if not exist,replace if exist
         PUSHL 20h         ;ARCHIVE
         PUSHL 0
         LEA EAX,[EBP-4]
         PUSH EAX
         LEA EAX,[EDI+0]   ;Handle
         PUSH EAX
         LEA EAX,[EDI+8]   ;Filename
         PUSH EAX
         MOV AL,8
         CALLDLL DosCalls,273  ;DosOpen
         ADD ESP,32
         MOV _IoResult,EAX
         CMPD _IoResult,0
         JNE !ers_1
         MOV ESI,[EBP+12]
         MOV EAX,_FileMode
         MOV [EDI+92],EAX  ;Patch file mode
!ers_1:
         LEAVE
         RETN32 8
      END;
END;

PROCEDURE BlockWrite(VAR f:file;var Buf;Count:LongWord);ASM;
BEGIN
     ASM
         PUSH EBP
         MOV EBP,ESP
         CMPD [EBP+8],0  ;Bufferlen
         JE !ebw
         MOV EDI,[EBP+16]  ;VAR f
         PUSHL OFFSET(_BlockWriteResult)    ;result
         MOV EAX,[EBP+8]  ;BufferLen
         MOV EBX,[EDI+4]   ;RecSize
         MUL EBX
         PUSH EAX
         PUSHL [EBP+12]    ;Buffer
         PUSHL [EDI+0]     ;Handle
         MOV AL,4
         CALLDLL DosCalls,282 ;DosWrite
         ADD ESP,16
         MOV _IoResult,EAX
!ebw:
         LEAVE
         RETN32 12
     END;
END;

PROCEDURE BlockRead(VAR f:file;var Buf;Count:LongWord);ASM;
BEGIN
     ASM
         PUSH EBP
         MOV EBP,ESP
         CMPD [EBP+8],0  ;Bufferlen
         JE !ebr
         MOV EDI,[EBP+16]  ;VAR f
         PUSHL OFFSET(_BlockreadResult)  ;result
         MOV EAX,[EBP+8]  ;BufferLen
         MOV EBX,[EDI+4]   ;RecSize
         MUL EBX
         PUSH EAX
         PUSHL [EBP+12] ;Buffer
         PUSHL [EDI+0]  ;Handle
         MOV AL,4
         CALLDLL DosCalls,281 ;DosRead
         ADD ESP,16
         MOV _IoResult,EAX
!ebr:
         LEAVE
         RETN32 12
     END;
END;

PROCEDURE Rename(VAR f:file;NewName:String);
BEGIN
     ASM
        LEA EAX,$NewName
        INC EAX
        PUSH EAX
        MOV ESI,$f
        LEA EAX,[ESI+8]   ;old filename
        PUSH EAX
        MOV AL,2
        CALLDLL DosCalls,271  ;DosMove
        ADD ESP,8
        MOV _Ioresult,EAX
     END;
END;

PROCEDURE CLOSE(VAR f:file);ASM;
BEGIN
     ASM
        PUSH EBP
        MOV EBP,ESP
        MOV EDI,[EBP+8]
        CMPD [EDI+0],0  ;Get file Handle
        JNE !nce
        MOVD _IoResult,6 ;Invalid Handle
        JMP !edc
!nce:
        PUSHL [EDI+0]  ;Handle
        MOV AL,1
        CALLDLL DosCalls,257  ;DosClose
        ADD ESP,4
        CMPD _IoResult,0
        JNE !edc
        MOV EDI,[EBP+8]
        MOVD [EDI+92],0  ;Mark file as closed
!edc:
        LEAVE
        RETN32 4
      END;
END;


PROCEDURE ASSIGN(VAR f:file;s:String);ASM;
BEGIN
     ASM
       PUSH EBP
       MOV EBP,ESP
       MOV EDI,[EBP+12]  ;File variable
       MOV AL,0
       MOV ECX,100       ;Length of file structure
       REP
       STOSB
       MOV EDI,[EBP+12]  ;File variable

       MOV ESI,[EBP+8]   ;String
       MOV CL,[ESI+0]    ;Length
       INC ESI
       CMP CL,79
       JBE L_1
L_2:
       MOV CL,79
       JMP L_3
L_1:
       CMP CL,0
       JE L_2__1    ;Skip empty file name
L_3:
       MOVZX ECX,CL
       ADD EDI,8    ;Set on filename
       CLD
       REP
       MOVSB
L_2__1:
       LEAVE
       RETN32 8
   END;
END;

ASSEMBLER

!TextRead PROC NEAR32  ;[EBP+12]-->FileVar  Result to !TempString
                       ;[EBP+8]-->BufferString
          PUSH EBP
          MOV EBP,ESP
          SUB ESP,4    ;for old file position
          PUSHA        ;PUSHAD

          PUSHL [EBP+12]    ;FileVar
          CALLN32 _Filepos
          MOV EBX,_IoResult
          CMP EBX,0
          JNE !end_read

          MOV [EBP-4],EAX   ;Save file position

          PUSHL [EBP+12]    ;Filevar
          MOV EDX,[EBP+8]   ;Buffer
          INC EDX
          PUSH EDX
          PUSHL 255         ;Length
          CALLN32 _BlockRead
          CMPD _IoResult,0
          JNE L_14x

          MOV EAX,_BlockReadresult    ;Result
          MOV ESI,[EBP+8]
          MOV [ESI+0],AL   ;Bytes read
          JMP L_16x
L_14x:
L_12x:
          MOV ESI,[EBP+8]
          MOVB [ESI+0],0   ;No records transmitted
L_16x:
          MOV EAX,_IoResult
          CMPW EAX,0
          JNE !end_read
          XOR CX,CX
          MOV ESI,[EBP+8]
          CLD
          LODSB
          CMP AL,0
          JE !end_read
          XOR AH,AH
          MOV DX,AX     ;old len
!lox1:
          LODSB
          INC CX
          CMP AL,13
          JE !end_lox
          CMP AL,10
          JE !end_lox
          CMP CX,DX       ;greater then bytes read ?
          JAE !end_read
          CMP CX,255
          JB !lox1
          JMP !end_read   ;NO CR found
!end_lox:
          MOV AX,CX
          DEC AX
          PUSH EDI
          MOV EDI,[EBP+8]
          MOV [EDI+0],AL  ;Set new length
          CMPB [EDI+1],13
          jne !ner
          MOVB [EDI+0],0
!ner:
          POP EDI
          LODSB
          CMP AL,10
          JNE !no_i
          INC CX
!no_i:
          MOV AX,CX
          MOVZX EAX,AL
          MOV EBX,[EBP-4]       ;old file-position
          ADD EBX,EAX
          MOV EAX,[EBP+12]       ;FileVar
          PUSH EAX
          PUSH EBX
          CALLN32 _Seek
!end_read:
          POPA                  ;POPAD
          LEAVE
          RETN32 4               ;Do not remove parameters !!!
!TextRead ENDP

!TextWrite PROC NEAR32  ;[BP+12]-->FileVar [BP+8] String to write
          PUSH EBP
          MOV EBP,ESP

          MOV EDI,[EBP+12]  ;Filevar
          PUSH EDI
          MOV EDI,[EBP+8]   ;String
          MOV CL,[EDI+0]
          MOVZX ECX,CL
          INC EDI
          PUSH EDI
          PUSH ECX          ;Length
          CALLN32 _BlockWrite
          CMPD _IoResult,0
          JNE !no_1

          MOV EDI,[EBP+12]   ;Filevar
          PUSH EDI
          MOV EDX,OFFSET(@creoln)
          PUSH EDX
          PUSHL 2            ;length
          CALLN32 _BlockWrite
!no_1:
          LEAVE
          RETN32 4    ;Do not remove FileVar parameter !!!
@creoln db 13,10
!TextWrite ENDP

END;

FUNCTION Eof(var f:file):Boolean;ASM;
BEGIN
     ASM
        PUSH EBP
        MOV EBP,ESP

        MOV EDI,[EBP+8] ;var f
        CMPD [EDI+0],0  ;FileHandle
        JE L_21

        PUSHL [EBP+8]  ;var f
        CALLN32 _Filepos
        PUSH EAX       ;Save current position

        PUSHL [EBP+8]  ;var f
        CALLN32 _FileSize

        POP EBX        ;Get current position
        CMP EBX,EAX
        JB L_22
        MOV AL,1       ;its EOF
        LEAVE
        RETN32 4
L_22:
        XOR AL,AL      ;its not EOF
        LEAVE
        RETN32 4
L_21:
        MOVD _IoResult,6  ;Invalid handle
        XOR EAX,EAX
        JMP L_22
      END;
END;




{*************************************************************************
*                                                                        *
*                                                                        *
*          Procedures and functions for outputting text in a PM Screen   *
*                                                                        *
**************************************************************************}

PROCEDURE CreateLogFont(_HPS:LONGWORD;VAR facename:STRING;hei,len:LONGWORD);
VAR fa:FATTRS;
BEGIN
     move(facename[1],fa.szFaceName,length(facename)+1);
     fa.usRecordLength:=sizeof(FATTRS);
     fa.fsSelection:=0;
     fa.lMatch:=1;
     fa.idRegistry:=0;
     fa.usCodePage:=0; {default}
     fa.lMaxbaseLineExt:=hei;
     fa.lAveCharWidth:=len;
     fa.fsType:=0;
     fa.fsFontUse:=0;
     ASM
        LEA EAX,$fa
        PUSH EAX
        PUSHL 1   ;Font ID
        PUSHL 0
        PUSHL $_hps
        MOV AL,4
        CALLDLL PMGPI,368    ;GpiCreateLogFont
        ADD ESP,16

        PUSHL 1   ;Font ID
        PUSHL $_hps
        MOV AL,2
        CALLDLL PMGPI,513   ;GpiSetCharSet
        ADD ESP,8
     END;
END;

PROCEDURE InvalidatePMCrtWindow;
VAR rc:RECTL;
BEGIN
     ASM
        LEA EAX,$rc
        PUSH EAX
        PUSHL _PMCrtWindow
        MOV AL,2
        CALLDLL PMWIN,840  ;WinQueryWindowRect
        ADD ESP,8

        PUSHL 0
        LEA EAX,$rc
        PUSH EAX
        PUSHL _PMCrtWindow
        MOV AL,3
        CALLDLL PMWIN,765   ;WinInvalidateRect
        ADD ESP,12
     END;
END;


PROCEDURE PMCrtScrollDown;
BEGIN
     ASM
        MOV EDI,_PMScrBuf
        MOV ESI,EDI
        ADD ESI,256
        MOV ECX,1920   ;30 Lines a 256 chars=7680 (DIV 4 --> MOVSD)
        CLD
        REP
        MOVSW          ;MOVSD
     END;
     Dec(DrawLocY);
     PmScrBuf^[DrawLocY]:='';
     {prepare whole window for repaint}
     MaxDrawStarty:=0;
     MaxDrawLeny:=MaxLines;
END;

PROCEDURE PMCrtRedraw(_hps:HPS);
VAR pt:pointl;
    rec:RECTL;
    Adresse:LONGWORD;
    t:Word;
    Metrics:FontMetrics;
    YAddFont:LONGWORD;
    Size:LONGWORD;
    cusizex,cusizey,cux,cuy:LONGWORD;
    facename:string;
BEGIN
     Size:=sizeof(FontMetrics);
     facename:='System VIO';
     CreateLogFont(_hps,facename,16,8);
     ASM
        LEA EAX,$Metrics
        PUSH EAX
        PUSHL $Size
        PUSHL $_hps
        MOV AL,3
        CALLDLL PMGPI,453  ;QueryFontMetrics
        ADD ESP,12

        LEA EAX,$rec
        PUSH EAX
        PUSHL _PMCrtWindow
        MOV AL,2
        CALLDLL PMWIN,840  ;WinQueryWindowRect
        ADD ESP,8
     END;
     YAddFont:=Metrics.lMaxAscender+Metrics.lMaxDescender;
     cusizex:=Metrics.lAveCharWidth;
     cusizey:=2;
     cux:=2+DrawLocx*cusizex;
     cuy:=rec.yTop-(DrawLocy+1)*YAddFont;
     ASM
        ;Set window cursor
        PUSHL 0      ;whole window
        PUSHL 8004h  ;CURSOR_SETPOS
        PUSHL $cusizey
        PUSHL $cusizex
        PUSHL $cuy
        PUSHL $cux
        PUSHL _PMCrtWindow
        MOV AL,7
        CALLDLL PMWIN,715  ;WinCreateCursor
        ADD ESP,28

        PUSHL _CursorVisible
        PUSHL _PMCrtWindow
        MOV AL,2
        CALLDLL PMWIN,880     ;WinShowCursor
        ADD ESP,8

        PUSHL _TextCol        ;TextColor
        PUSHL $_hps
        MOV AL,2
        CALLDLL PMGPI,517    ;GpiSetColor
        ADD ESP,8

        PUSHL _TextBackCol   ;Text BackGround
        PUSHL $_hps
        MOV AL,2
        CALLDLL PMGPI,504    ;GpiSetBackColor
        ADD ESP,8

        PUSHL 2      ;BM_OVERPAINT
        PUSHL $_hps
        MOV AL,2
        CALLDLL PMGPI,505    ;GpiSetBackMix
        ADD ESP,8

        MOV EAX,_MaxDrawStarty
        MOV EBX,256
        MUL EBX
        MOV EBX,_PmScrBuf
        ADD EAX,EBX
        MOV $Adresse,EAX
    END;

    pt.x:=2;
    pt.y:=rec.yTop-(MaxDrawStarty+1)*yAddFont;
    t:=0;
    IF MaxDrawLeny<>MaxLines THEN
    BEGIN
         rec.yTop:=pt.y;
         rec.yBottom:=rec.yTop-(MaxDrawLeny+1)*yAddFont;
         IF MaxDrawLeny=0 THEN rec.xleft:=rec.xleft+DrawLocX*cusizex; {1 Zeile}
    END;
    ASM
       PUSHL _TextBackCol
       LEA EAX,$rec
       PUSH EAX
       PUSHL $_hps
       MOV AL,3
       CALLDLL PMWIN,743  ;WinFillRect
       ADD ESP,12
    END;
    WHILE pt.y>=rec.yBottom DO
    BEGIN
         ASM
            MOV ESI,$Adresse
            MOV AL,[ESI+0]
            CMP AL,0
            JE !no_draw
            INC ESI
            PUSH ESI
            MOVZX EAX,AL
            PUSH EAX

            LEA EAX,$pt
            PUSH EAX
            PUSHL $_hps
            MOV AL,4
            CALLDLL PMGPI,359   ;GpiCharStringAt
            ADD ESP,16
!no_draw:
         END;
         Inc(Adresse,256);
         dec(pt.y,yAddFont);
         inc(t);
         IF t>MaxDrawLeny THEN exit;
    END;
END;

FUNCTION PMCrtHandleEvent(Win:LONGWORD;Msg:LONGWORD;para1,para2:POINTER;
                          VAR Handled:BOOLEAN):LONGWORD;
VAR
    H:Boolean;
    _hps:LONGWORD;
    r:LONGWORD;
    command:WORD;
    rc:RECTL;
BEGIN
      r:=0;
      H:=TRUE;
      CASE Msg OF
          WM_QUIT:
          BEGIN
               IF PMCrtWindow<>0 THEN
               BEGIN {Destroy Crt Window}
                    ASM
                       PUSHL 5 ;QW_PARENT
                       PUSHL $Win
                       MOV AL,2
                       CALLDLL PMWIN,834  ;WinQueryWindow
                       ADD ESP,8
                       PUSH EAX
                       MOV AL,1
                       CALLDLL PMWIN,728  ;WinDestroyWindow
                       ADD ESP,4
                    END;
                    PMCrtWindow:=0;
               END;
               IF not Handled THEN H:=FALSE;
          END;
          WM_SETFOCUS:  {EingabeFocus neu setzen}
          BEGIN
               ASM
                  MOV EAX,[EBP+12]  ;para2
                  CMP EAX,0
                  JE !dc      ;Window is loosing focus

                  ;Window becomes focus --> Create the cursor
                  PUSHL 0  ;whole window
                  PUSHL 4  ;CURSOR_SOLID | CURSOR_FLASH
                  PUSHL 2
                  PUSHL 8
                  PUSHL 40
                  PUSHL 40
                  PUSHL _PMCrtWindow
                  MOV AL,7
                  CALLDLL PMWIN,715  ;WinCreateCursor
                  ADD ESP,28

                  PUSHL 1            ;Show the cursor
                  PUSHL _PMCrtWindow
                  MOV AL,2
                  CALLDLL PMWIN,880  ;WinShowCursor
                  ADD ESP,4

                  CALLN32 _InvalidatePMCrtWindow

                  JMP !ccde
!dc:
                  ;Window is loosing focus --> Destroy the cursor
                  PUSHL _PMCrtWindow
                  MOV AL,1
                  CALLDLL PMWIN,725  ;WinDestroyCursor
                  ADD ESP,4
!ccde:
               END;
          END;
          WM_CHAR:
          BEGIN
              if CrtKeyCount < 33 then
              begin
                   ASM
                      MOV AX,[EBP+16]    ;para1
                      AND AX,41h         ;KC_Char valid and KC_KEYUP
                      CMP AX,1
                      JNE !no_char
                      MOV AX,[EBP+12] ;para2
                      LEA EDI,_KeyBuffer
                      MOV BL,_CrtKeyCount
                      MOVZX EBX,BL
                      ADD EDI,EBX
                      INCB _CrtKeyCount
                      MOV [EDI+0],AL
!no_char:
                   END;
              end;
          END;
          WM_CLOSE:
          BEGIN
               PmCrtWindow:=0;
               IF not AlternateExit THEN {send WM_QUIT}
               BEGIN
                    ASM
                       PUSHL 0
                       PUSHL 0
                       PUSHL 2ah  ;WM_QUIT
                       PUSHL $win
                       MOV AL,4
                       CALLDLL PMWIN,919  ;WinPostMsg
                       ADD ESP,16
                    END;
               END
               ELSE {only destroy window}
               BEGIN
                    ASM
                       PUSHL 5 ;QW_PARENT
                       PUSHL $Win
                       MOV AL,2
                       CALLDLL PMWIN,834  ;WinQueryWindow
                       ADD ESP,8
                       PUSH EAX
                       MOV AL,1
                       CALLDLL PMWIN,728  ;WinDestroyWindow
                       ADD ESP,4
                    END;
               END;
          END;
          WM_PAINT:
          BEGIN
               MaxDrawStarty:=0;
               MaxDrawLeny:=MaxLines;
               ASM
                  LEA EAX,$rc
                  PUSH EAX
                  PUSHL 0
                  PUSHL $Win
                  MOV AL,3
                  CALLDLL PMWIN,703  ;WinbeginPaint
                  ADD ESP,12
                  MOV $_hps,EAX
               END;
               PMCrtRedraw(_hps);
               ASM
                  PUSHL $_hps
                  MOV AL,1
                  CALLDLL PMWIN,738  ;WinendPaint
                  ADD ESP,4
               END;
          END;
          WM_ERASEBACKGROUND:r:=1;
          ELSE IF not Handled THEN H:=FALSE;
      END;
      Handled:=H;
      PMCrtHandleEvent:=r;
END;

FUNCTION PMCrtHandler(para2,para1:POINTER;Msg,Win:LONGWORD):LONGWORD;ASM;
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
        CALLN32 _PMCrtHandleEvent
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

PROCEDURE DrawPMCrtWindow;
BEGIN
     ASM
         PUSHL _PMCrtWindow
         MOV AL,1
         CALLDLL PMWIN,757   ;WinGetPS
         ADD ESP,4

         PUSH EAX            ;For WinReleasePS

         PUSH EAX
         CALLN32 _PMCrtRedraw

         MOV AL,1
         CALLDLL PMWIN,848   ;WinReleasePS
         ADD ESP,4
     END;
END;


PROCEDURE CreatePMCrtWindow; {Generate a window}
VAR fr:LONGWORD;
    t:Byte;
BEGIN
     IF PMCrtWindow=0 THEN
     BEGIN
         MaxLines:=29;
         TextCol:=7;     {CLR_NEUTRAL}
         TextBackCol:=0; {CLR_BACKGROUND}
         New(PMScrBuf);
         {prepare whole window for repaint}
         MaxDrawStarty:=0;
         MaxDrawLeny:=MaxLines;
         ASM
            MOV ECX,_MaxLines
            MOV AL,0
!cloop:
            MOV EDI,_PMScrBuf
            MOV [EDI+0],AL
            ADD EDI,256
            LOOP !cloop
         END;
         DrawLocX:=0;
         DrawLocY:=0;
         ASM
            PUSHL 0
            PUSHL 4  ;CS_SizeRedraw
            MOV EAX,*_PMCrtHandler
            PUSH EAX
            PUSHL OFFSET(@CrtWinName)
            PUSHL _AppHandle
            MOV AL,5
            CALLDLL PMWIN,926  ;WinregisterClass
            ADD ESP,20

            PUSHL OFFSET(_PmCrtWindow)
            PUSHL 0
            PUSHL 0
            PUSHL 0
            MOV EAX,OFFSET(_PMCrtTitle)
            INC EAX
            PUSH EAX
            PUSHL OFFSET(@CrtWinName)
            MOVD $fr,0c3bh
            LEA EAX,$fr
            PUSH EAX
            PUSHL 0
            PUSHL 1  ;HWND_DESKTOP
            MOV AL,9
            CALLDLL PMWIN,908   ;WinCreateStdWindow
            ADD ESP,36
            MOV _PMCrtFrameHandle,EAX

            PUSHL 8bh
            PUSHL 350
            PUSHL 500
            PUSHL 100
            PUSHL 50
            PUSHL 3   ;HWND_TOP
            PUSHL _PMCrtFrameHandle
            MOV AL,7
            CALLDLL PMWIN,875   ;WinsetWindowPos
            ADD ESP,28
            LEAVE
            RETN32
@CrtWinName db 'PMCRTWIN',0
       END;
     END;
END;



PROCEDURE GOTOXY(x,y:LONGWORD);
BEGIN
     CreatePMCrtWindow;
     IF x>0 THEN dec(x);
     IF y>0 THEN dec(y);
     IF x>250 THEN x:=250;
     IF y>MaxLines-1 THEN y:=MaxLines-1;
     DrawLocX:=x;
     DrawLocY:=y;
     MaxDrawStarty:=DrawLocy;
     MaxDrawLeny:=0;
     DrawPMCrtWindow;
END;

PROCEDURE HideCursor;
BEGIN
     CreatePMCrtWindow;
     Cursorvisible:=0;
     MaxDrawStarty:=DrawLocy;
     MaxDrawLeny:=0;
     DrawPMCrtWindow;
END;

PROCEDURE ShowCursor;
BEGIN
     CreatePMCrtWindow;
     Cursorvisible:=1;
     MaxDrawStarty:=DrawLocy;
     MaxDrawLeny:=0;
     DrawPMCrtWindow;
END;

PROCEDURE ClrScr;
BEGIN
     CreatePMCrtWindow;
     DrawLocx:=0;
     DrawLocY:=0;
     ASM
        MOV ECX,_MaxLines
        MOV AL,0
!cloop_1:
        MOV EDI,_PMScrBuf
        MOV [EDI+0],AL
        ADD EDI,256
        LOOP !cloop_1
     END;
     {prepare whole window for repaint}
     MaxDrawStarty:=0;
     MaxDrawLeny:=MaxLines;
     DrawPMCrtWindow;
END;

ASSEMBLER

!CharOut PROC NEAR32  ;Char in AL
             PUSH AX  ;Save char
             CALLN32 _CreatePMCrtWindow
             MOV EDI,_PMScrBuf
             MOV EAX,_DrawLocY
             SHL EAX,8  ;*256
             ADD EDI,EAX

             MOV EBX,_DrawLocX
             CMP EBX,255
             JAE !exco    ;Skip
!next_c:
             MOV AL,[EDI+0]
             MOVZX EAX,AL
             CMP EAX,255
             JAE !exco    ;Skip
             CMP EAX,EBX        ;until positions ok
             JA !go
             MOV ESI,EDI
             ADD ESI,EAX
             INC ESI
             MOVB [ESI+0],32    ;Fill with space
             INCB [EDI+0]
             JMP !next_c
!go:
             CMP EAX,EBX
             JA !ninc
             INCB [EDI+0]
!ninc:
             POP AX             ;Get char
             INC EBX
             ADD EDI,EBX
             MOV [EDI+0],AL
             INCD _DrawLocX
!exco:
             RETN32
!CharOut ENDP


!WriteWord PROC NEAR32       ;(AX:word)           gibt 16 bit Zahl in AX aus
          MOV BX,10
          XOR ECX,ECX
L1:       XOR DX,DX
          DIV BX
          PUSH DX
          INC ECX
          OR AX,AX
          JNE L1
L2:       POP AX
          ADD AL,'0'
          PUSH ECX
          CALLN32 !CharOut
          POP ECX
          LOOP L2
          RETN32     ;keine Parameter
!WriteWord ENDP

!WriteInt PROC NEAR32       ;(AX:word) gibt 16 bit Zahl in AX aus mit Vorzeichen
          CMP AX,0
          JNS !novorz
          PUSH AX
          MOV AL,'-'
          CALLN32 !CharOut
          POP AX
          NEG AX
!novorz:
          CALLN32 !WriteWord
          RETN32     ;keine Parameter
!WriteInt ENDP


!WriteLongWord PROC NEAR32       ;(EAX:word)    gibt 32 bit Zahl in EAX aus
             MOV EBX,10
             MOV BX,10
             XOR ECX,ECX
L46:         XOR EDX,EDX
             DIV EBX
             PUSH DX
             INC ECX
             OR EAX,EAX
             JNE L46
L47:         POP AX
             ADD AL,'0'
             PUSH ECX
             CALLN32 !CharOut
             POP ECX
             LOOP L47
             RETN32   ;keine Parameter
!WriteLongWord ENDP

!WriteLongInt PROC NEAR32       ;(EAX:word)    gibt 32 bit Zahl in EAX aus
             CMP EAX,0
             JNS !novorz1
             PUSH EAX
             MOV AL,'-'
             CALLN32 !CharOut
             POP EAX
             NEG EAX
!novorz1:
             CALLN32 !WriteLongWord
             RETN32     ;keine Parameter
!WriteLongInt ENDP

!WriteEnd PROC NEAR32
                  MOV EAX,_DrawLocY
                  MOV _MaxDrawStarty,EAX
                  MOVD _MaxDrawLeny,0  ;draw 1 line
                  CALLN32 _DrawPMCrtWindow
                  RETN32
!WriteEnd ENDP



!WritelnEnd PROC NEAR32
                  CALLN32 _CreatePMCrtWindow;
                  MOV EAX,_DrawLocY
                  MOV _MaxDrawStarty,EAX
                  MOVD _MaxDrawLeny,0  ;draw 1 line
                  INC EAX
                  MOV _DrawLocY,EAX
                  CMP EAX,_MaxLines
                  JB !ns
                  ;Scroll the current window
                  CALLN32 _PMCrtScrollDown
!ns:
                  MOVD _DrawLocX,0
                  CALLN32 _DrawPMCrtWindow
                  RETN32
!WritelnEnd ENDP


!Writeln PROC NEAR32
            CALLN32 !WritelnEnd
            RETN32
!Writeln ENDP


!WriteStr PROC NEAR32        ;put out string
         PUSH EBP
         MOV EBP,ESP
         CALLN32 _CreatePMCrtWindow

         MOV EDI,_PMScrBuf
         MOV EAX,_DrawLocY
         SHL EAX,8  ;*256
         ADD EDI,EAX

         MOV EBX,_DrawLocX  ;is this the start of a line ?
         CMP EBX,0
         JNE !move          ;No --> special action required

         MOV ESI,[EBP+8]   ;TextString
         MOV AL,[ESI+0]
         MOVZX EAX,AL
         ADD _DrawLocX,EAX
         PUSH ESI
         PUSH EDI
         PUSH 255
         CALLN32 !StrCopy
         LEAVE
         RETN32 4
!move:
!next_c_1:
         MOV AL,[EDI+0]
         MOVZX EAX,AL
         CMP EAX,255
         JAE !exco_1    ;Skip
         CMP EAX,EBX        ;until positions ok
         JA !go_1
         MOV ESI,EDI
         ADD ESI,EAX
         INC ESI
         MOVB [ESI+0],32    ;Fill with space
         INCB [EDI+0]
         JMP !next_c_1
!go_1:
         MOV ESI,[EBP+8]    ;TextString
         MOV AL,[ESI+0]
         INC ESI
         MOVZX EAX,AL
         MOV BL,[EDI+0]
         MOVZX EBX,BL

         MOV ECX,EAX
         ADD ECX,EBX
         CMP ECX,255
         JB !aok
         ;Limit exceeeded --> Cut String
         MOV EAX,255
         SUB EAX,EBX
!aok:
         CMP EAX,0
         JE !exco_1        ;No bytes to transmit
         PUSH EAX
         MOV AL,[EDI+0]
         MOVZX EAX,AL
         MOV ECX,_DrawLocX
         SUB EAX,ECX
         POP EAX
         ADD ECX,EAX
         ADD [EDI+0],CL     ;increment textlen
         MOV EBX,_DrawLocX
         ADD _DrawLocX,EAX
         ADD EDI,EBX        ;set to location
         INC EDI

         MOV ECX,EAX
         CLD
         REP
         MOVSB
!exco_1:
         LEAVE
         RETN32 4
!WriteStr ENDP

END;



{*************************************************************************
*                                                                        *
*                                                                        *
*           SYSTEM initialization procedures                             *
*                                                                        *
*                                                                        *
**************************************************************************}


ASSEMBLER

!SystemEnd PROC NEAR32
           XOR AH,AH
           MOV _ExitCode,AX
exloop1:
           PUSHL OFFSET(@raddr1)  ;Returnadress for ExitProc
           PUSHL _ExitProc    ;ExitProc on Stack
           RETN32             ;jump into ExitProc
@raddr1
           JMP exloop1        ;until termination
!SystemEnd ENDP

!Halt1 PROC NEAR32
      MOV AX,_ExitCode
      PUSH AX
      CALLN32 _Halt
!Halt1 ENDP

!SystemInit PROC NEAR32
           ;allocate main memory (uncommitted) for suballocation
           ;via Getmem and Freemem
           MOV EAX,8192    ;Allocate 8MB private memory
           MOV EBX,1024
           MUL EBX
           MOV _HeapSize,EAX
           PUSHL 3         ;Flags PAG_READ|PAG_WRITE
           PUSH EAX        ;Length of memory
           PUSHL OFFSET(_Heaporg)
           MOV AL,3             ;3 Parameters
           CALLDLL DosCalls,299 ;DosAllocMem
           ADD ESP,12            ;Clear Stack
           CMP EAX,0
           JNE !ei

           ;Prepare the memory block for suballocation
           PUSHL _HeapSize      ;Size of Heap
           PUSHL 5              ;Flags DOSSUB_INIT|DOSSUB_SPARSE_OBJ
           PUSHL _Heaporg
           MOV AL,3
           CALLDLL DosCalls,344 ;DosSubSetMem
           ADD ESP,12            ;Clear Stack
           CMP EAX,0
           JNE !ei

           MOV EAX,_HeapOrg
           MOV _HeapPtr,EAX
           ADD EAX,_HeapSize
           MOV _HeapEnd,EAX
           MOV EAX,*!Halt1       ;Standard exit procedure
           MOV _ExitProc,EAX
           ;Create Application anchor handle
           PUSHL 0
           MOV AL,1
           CALLDLL PMWIN,763   ;WinInitialize
           ADD ESP,4
           MOV _AppHandle,EAX
           ;Create Application Message queue
           PUSHL 0
           PUSHL _AppHandle
           MOV AL,2
           CALLDLL PMWIN,716   ;WinCreateMsgQueue
           ADD ESP,8
           MOV _AppQueueHandle,EAX

           PUSH 0
           CALLN32 _ParamStr   ;Get name of program

           PUSHL OFFSET(!TempString)
           PUSHL OFFSET(_PMCRTTITLE)
           PUSH 255
           CALLN32 !StrCopy
           MOVD _TextBackCol,-2
           MOVD _SeekMode,0   ;FILE_BEGIN
           MOVD _FileMode,42h ;fmInOut
           MOVB _CrtKeyCount,0
           MOVD _CursorVisible,1  ;Cursor is visible
           RETN32
!ei:
           ;Error during initialization
           MOV AX,216
           CALLN32 _RunError
!SystemInit ENDP

!VmtCall PROC NEAR32  ;(object:Pointer;) numProc in AX
        PUSH EBP
        MOV EBP,ESP
        MOV EDI,[EBP+8]
        CMP EDI,0
        JNE !obj_init
!obj_error:
        ;Object not initialized or VMT damaged
        MOV AX,210
        CALLN32 _Runerror
!obj_init
        MOV EBX [EDI+0]
        CMP EBX,0
        JE !obj_error
        MOV EDI,[EDI+0]  ;get VMT pointer
        DEC AX
        SHL AX,2         ;VmtNummer*2
        MOVZX EAX,AX
        ADD EDI,EAX      ;add NumProc
        LEAVE
        db ffh,27h       ;JMP NEAR32 [EDI+0] --> in Methode springen
        RETN32
!VmtCall ENDP

END;


{*************************************************************************
*                                                                        *
*                                                                        *
*             KeyBoard Procedures and functions                          *
*                                                                        *
*                                                                        *
**************************************************************************}

FUNCTION KeyPressed: Boolean;
VAR _qmsg:QMSG;
    MsgIdent:LONGWORD;
begin
  CreatePMCrtWindow;
  ASM
!next_mess:
      CMPB _CrtKeyCount,0
      JA !exm

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
      JNE !exm_1
      MOVD _PMCrtWindow,0
      MOV AX,0
      CALLN32 !SystemEnd  ;WM_QUIT message detected
!exm_1:
      LEA EAX,$_qmsg
      PUSH EAX
      PUSHL _AppHandle
      MOV AL,2
      CALLDLL PMWIN,912  ;WinDispatchMsg
      ADD ESP,8
!exm:
  END;
  IF CrtKeyCount>0 THEN KeyPressed:=TRUE
  ELSE KeyPressed:=FALSE;
END;

FUNCTION ReadKey:Char;
var t:byte;
begin
    CreatePMCrtWindow;
    REPEAT UNTIL KeyPressed;
    ReadKey:=KeyBuffer[0];
    Dec(CrtKeyCount);
    FOR t:=0 to CrtKeyCount do KeyBuffer[t]:=Keybuffer[t+1];
    ASM
       ;Function result
       MOV AL,[EBP-2]
    END;
end;

ASSEMBLER

!ReadStr PROC NEAR32  ;read string from comsole [EBP+8] is output
                   PUSH EBP
                   MOV EBP,ESP
                   SUB ESP,2
                   CALLN32 _CreatePMCrtWindow
                   PUSHA         ;PUSHAD
                   MOV EDI,[EBP+8]
                   INC EDI       ;on first character
                   MOV ECX,0     ;Length is currently zero
_nez:
                   PUSHA
                   CALLN32 _ReadKey   ;read a character
                   CMP AL,0dh          ;is it a CR
                   JE !zcr             ;yes !
                   MOV [EBP-2],AL      ;save
                   CMP AL,8            ;is it a BS
                   JNE __!nbs

                   POPA
                   MOV EAX,[EBP+8]
                   CMP ECX,0
                   JE _nez             ;Backspace cannot be first char
                   DEC EDI
                   PUSHA
                   DECD _DrawLocX
                   MOV AL,32
                   CALLN32 !CharOut
                   DECD _DrawLocX
                   CALLN32 !WriteEnd
                   POPA
                   DEC ECX
                   JMP _nez
__!nbs:
                   CALLN32 !CharOut    ;and put out
                   CALLN32 !WriteEnd
_nv10:
                   POPA
                   MOV AL,[EBP-2]      ;get char
                   MOV [EDI+0],AL      ;and save
                   INC EDI
                   INC ECX             ;save length
                   CMP ECX,254         ;already 255 chars ?
                   JB _nez             ;no-->next char
                   PUSHA

!zcr:
                   POPA
                   MOV ESI,[EBP+8]
                   MOV [ESI+0],CL      ;save length
                   CALLN32 !WriteEnd
                   POPA
                   LEAVE
                   RETN32
!ReadStr ENDP

!ReadLongWord PROC NEAR32   ;(var value:word)   read word from console
         PUSH EBP
         MOV EBP,ESP
         SUB ESP,4
         CALLN32 _CreatePMCrtWindow
         PUSHL OFFSET(!TempString)
         CALLN32 !ReadStr   ;to !TempString
         MOV ESI,OFFSET(!TempString)
         MOVD [EBP-4],0     ;Word to 0
         MOV EBX,1           ;value to multiply
         MOV CL,[ESI+0]     ;get length
         MOVZX ECX,CL
         CMP CL,0           ;no input ??
         JE l4
         ADD ESI,ECX        ;onto first char
L3:
         MOV AL,[ESI+0]     ;get char
         DEC ESI
         SUB AL,48
         MOVZX EAX,AL
         MUL EBX
         ADD [EBP-4],EAX
         MOV EAX,EBX
         MOV EBX,10
         MUL EBX
         MOV EBX,EAX          ;Multiplikator
         LOOP L3
L4:
         MOV EAX,[EBP-4]
         LEAVE
         RETN32             ;no parameters
!ReadLongWord ENDP

END; {ASSEMBLER}


BEGIN
END.

ASSEMBLER
!TempChar db 0     ;Uses for !CharOut
!TempWord dw 0,0   ;Used temporary
!TempRet  dw 0,0   ;Used for Output via DosWrite as return value
!TempCR   db 13,10 ;Used by !WritelnEnd
!ErrorMsg db 'Speed-386 Runtime error     at:XXXXXXXX',13,10 ;Error Message
!TempString   db 0,ds 255,0   ; for temporary string operations
!TempString1  db 0,ds 255,0   ; for temporary string operations
!TempString2  db 0,ds 255,0   ;  ''   ''            ''
!TempString3  db 0,ds 255,0   ;  ''   ''            ''
END; {ASSEMBLER}