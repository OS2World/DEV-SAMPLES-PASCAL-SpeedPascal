UNIT PMDos;

{**************************************************************************
 *                 General Unit for Speed-386                             *
 *                                                                        *
 *                                                                        *
 * Copyright (C) 1993,94 R.NÅrnberger, Franz-Mehring-Str.2 09112 Chemnitz *
 *                                                                        *
 *                                                                        *
 **************************************************************************}


interface


const

{ Flags bit masks }

  FCarry     = 1;
  FParity    = 4;
  FAuxiliary = 16;
  FZero      = 64;
  FSign      = 128;
  FOverflow  = 2048;

{ File mode numbers }

  fmClosed = 0;
  fmInput  = $40;   {Read only}
  fmOutput = $41;   {Write only}
  fmInOut  = $42;   {allow both read and write access}

{ File attribute constants }

  ReadOnly  = 1;
  Hidden    = 2;
  SysFile   = 4;
  VolumeID  = 8;
  Directory = 16;
  Archive   = 32;
  AnyFile   = 63;

type
      CmdStr  = string;        { Command line string }
      PathStr = string[79];    { File pathname string }
      DirStr  = string[128];   { Drive and directory string }
      NameStr = string[8];     { File name string }
      ExtStr  = string[4];     { File extension string }


      Registers =
         record
           case of
             0: (EAX,EBX,ECX,EDX,EBP,ESI,EDI,DS_ES,EFlags:LongWord);
             1: (AX,X_AX,BX,X_BX,CX,X_CX,DX,X_DX,BP,X_BP,SI,X_SI,
                 DI,X_DI,DS,ES,Flags,X_FLAGS: Word);
             2: (AL,AH,X_AL,X_AH,BL,BH,X_BL,X_BH,CL,CH,X_CL,X_CH,
                 DL,DH,X_DL,X_DH: Byte);
           end;


      FileRec = record
                      Handle   : LongWord;
                      RecSize  : LongWord;
                      Name     : array[0..79] of Char;
                      Private1 : POINTER;  {extended attributes}
                      Mode     : LONGWORD; {Current file mode}
                      Reserved : POINTER;  {for further extensions}
                end;


      TextRec = record
                      Handle    : LongWord;
                      RecSize  : LongWord; {not used yet}
                      Name      : array[0..79] of Char;
                      Private1 : POINTER;  {extended attributes}
                      Mode     : LONGWORD; {Current file mode}
                      Reserved : POINTER;  {for further extensions}
                end;

{ Search record used by FindFirst and FindNext }

  TSearchRec = record
                     oNextEntryOffset:LONGWORD;
                     fdateCreation:WORD;
                     ftimeCreation:WORD;
                     fdateLastAccess:WORD;
                     ftimeLastAccess:WORD;
                     fdateLastWrite:WORD;
                     ftimeLastWrite:WORD;
                     cbFile:LONGWORD;
                     cbFileAlloc:LONGWORD;
                     attrFile:LONGWORD;
                     cchName:BYTE;
                     achName:ARRAY[0..255] OF BYTE;
                     {private}
                     HDir:LONGINT;
               end;

  _PDATETIME=^_DATETIME;
  _DATETIME=RECORD
                  hours:BYTE;
                  minutes:BYTE;
                  seconds:BYTE;
                  hundredths:BYTE;
                  day:BYTE;
                  month:BYTE;
                  year:WORD;
                  timezone:INTEGER;
                  weekday:BYTE;
           END;

  _PFSALLOCATE=^_FSALLOCATE;
  _FSALLOCATE=RECORD
                    idFileSystem:LONGWORD;
                    cSectorUnit:LONGWORD;
                    cUnit:LONGWORD;
                    cUnitAvail:LONGWORD;
                    cbSector:WORD;
               END;

  _PFILESTATUS3=^_FILESTATUS3;
  _FILESTATUS3=RECORD
                    fdateCreation:WORD;
                    ftimeCreation:WORD;
                    fdateLastAccess:WORD;
                    ftimeLastAccess:WORD;
                    fdateLastWrite:WORD;
                    ftimeLastWrite:WORD;
                    cbFile:LONGWORD;
                    cbFileAlloc:LONGWORD;
                    attrFile:LONGWORD;
                END;

  {Type for GetEnvStr}
  PEnvString=^TEnvString;
  TEnvString=array[0..65500] of Char; {terminated with 0-character}

  ExecResultCode=record
                     codeTerminate:LONGWORD;
                     codeResult:LONGWORD;
                 end;

VAR DosError:LongWord;   {DOS unit error status}

FUNCTION  DosVersion:Word;
PROCEDURE GetDate(var Year,Month,Day,DayOfWeek: Word);
PROCEDURE SetDate(Year,Month,Day,DayOfWeek: Word);
PROCEDURE GetTime(var Hour,Minute,Second,Sec100: Word);
PROCEDURE SetTime(Hour,Minute,Second,Sec100: Word);
PROCEDURE GetVerify(var Verify: Boolean);
PROCEDURE SetVerify(Verify: Boolean);
FUNCTION  EnvStr(Env:String): PEnvString;
FUNCTION  DiskFree(Drive: Byte): LongWord;
FUNCTION  DiskSize(Drive: Byte): LongWord;
PROCEDURE GetFAttr(var F; var Attr: LongWord);
PROCEDURE SetFAttr(var F; Attr: LongWord);
PROCEDURE GetFTime(var F; var year,month,day,hours,minutes,twosecs:Word);
PROCEDURE SetFTime(var F; year,month,day,hours,minutes,twosecs:Word);
PROCEDURE Exec(Path: PathStr; CmdLine: CmdStr;VAR ExecPID:LONGWORD);
PROCEDURE FindFirst(Path: PathStr; Attr: LongWord; var F: TSearchRec);
PROCEDURE FindNext(var F: TSearchRec);
FUNCTION  PackTime(hour,minute,twosec:Word):Word;
FUNCTION  PackDate(year,month,day:Word):Word;
PROCEDURE UnPackTime(pack:Word;var hour,minute,twosec:Word);
PROCEDURE UnPackDate(pack:Word;var year,month,day:Word);
FUNCTION FSearch(Path: PathStr; DirList: String): PathStr;
{FUNCTION FExpand(Path: PathStr): PathStr;}
PROCEDURE FSplit(Path: PathStr; var Dir: DirStr;
                 var Name: NameStr; var Ext: ExtStr);


IMPLEMENTATION

PROCEDURE FSplit(Path: PathStr; var Dir: DirStr;
                 var Name: NameStr; var Ext: ExtStr);
BEGIN
     ASM
        LEA ESI,$Path
        MOV AL,[ESI+0]
        INC ESI
        XOR EDX,EDX
        XOR EBX,EBX
        MOV DL,AL
        XOR DH,DH
        MOV BX,DX
        PUSH ESI
        POP  EDI
        ADD  EDI,EBX
        DEC  EDI
        OR   EBX,EBX  ;String length 0 ?
        JE   !L_2
!L_1:
        CMPB [EDI+0],'\'
        JE   !L_2
        CMPB [EDI+0],':'
        JE   !L_2
        DEC  EDI
        DEC  EBX
        JNE  !L_1   ;until string begin
!L_2:
        MOV  EAX,67
        MOV EDI,$Dir
        CALLN32 System.!CopyString

        XOR EBX,EBX
        PUSH ESI
        POP EDI
        JMP !L_4
!L_3:
        CMPB [EDI+0],46
        JE !L_5
        INC EBX
        INC EDI
!L_4:
        CMP EBX,EDX
        JNE !L_3
!L_5:
        MOV EAX,8
        MOV EDI,$Name
        CALLN32 System.!CopyString

        MOV EAX,4
        PUSH EDX
        POP EBX
        MOV EDI,$Ext
        CALLN32 System.!CopyString
    END;
END;

FUNCTION FSearch(Path: PathStr; DirList: String): PathStr;
var r:PATHSTR;
BEGIN
     ASM
        PUSHL 79  ;result buf len
        LEA EAX,$r
        INC EAX
        PUSH EAX
        LEA EAX,$Path
        INC EAX
        PUSh EAX
        LEA EAX,$DirList
        INC EAX
        PUSH EAX
        PUSHL 0   ;Flags
        MOV AL,5
        CALLDLL DosCalls,228    ;DosSearchPath
        ADD ESP,20
        MOV _DosError,EAX
    END;
    IF DosError=0 THEN
    BEGIN
         ASM
            LEA ESI,$r
            INC ESI
            MOV CL,255
            CLD
!nef:
            INC CL
            LODSB
            CMP AL,0
            JNE !nef

            LEA EDI,$r
            MOV [EDI+0],CL  ;Set string len
        END;
    END
    ELSE r:='';
    FSearch:=r;
END;

FUNCTION PackTime(hour,minute,twosec:Word):Word;
VAR time:Word;
BEGIN
     ASM
        MOV BL,$Hour
        SHL BL,3    ;multiply with 8
        MOV AL,$minute
        SHR AL,3    ;divide by 8
        ADD AL,BL
        SHL AX,8    ;Shift
        MOV $time,AX

        MOV BL,$minute
        AND BL,7
        SHL BL,5    ;multiply with 2 and shift
        ADD BL,$TwoSec
        MOV $time,BL
     END;
     PackTime:=Time;
END;

FUNCTION Packdate(year,month,day:Word):Word;
VAR Date:Word;
BEGIN
     ASM
        MOV AL,$month
        MOV BL,0
        CMP AL,7
        JNA !mo1
        MOV BL,1
        SUB AL,8
!mo1:
        MOV CX,$year
        SUB CX,1980
        SHL CX,1    ;multiply with 2
        MOVZX BX,BL
        ADD CX,BX
        SHL CX,8    ;Shift
        MOV $Date,CX

        SHL AL,5    ;multiply month with 2 and shift
        ADD AL,$Day
        MOV $Date,AL
     END;
     PackDate:=Date;
END;

PROCEDURE UnPackTime(pack:Word;var hour,minute,twosec:Word);
VAR h,min,sec:WORD;
BEGIN
    ASM
       MOV DX,$pack

       MOV AL,DH    ;Hour/Minute
       AND AL,248   ;Mask Hour
       SHR AL,3     ;divide by 8
       MOVZX AX,AL
       MOV $h,AX

       MOV AL,DH    ;Hour/Minute
       AND AL,7     ;Mask Minute
       SHL AL,3     ;multiply with 8
       MOV BL,AL

       MOV AL,DL    ;Minute/sec
       AND AL,224   ;Mask minute
       SHR AL,5     ;divide by 2 and shift
       ADD AL,BL
       MOVZX AX,AL
       MOV $min,AX

       MOV AL,DL    ;Minute/sec
       AND AL,31    ;Mask twoseconds
       MOVZX AX,AL
       MOV $sec,AX
     END;
     Hour:=h;
     minute:=min;
     twosec:=sec;
END;

PROCEDURE UnPackDate(pack:Word;var year,month,day:Word);
VAR y,m,d:Word;
BEGIN
     ASM
        MOV DX,$pack

        MOV AL,DH    ;Year/Month
        AND AL,254   ;Clear Bit 1
        SHR AL,1     ;Divide by 2
        MOVZX AX,AL
        ADD AX,1980
        MOV $y,AX    ;Year
        MOV BL,0
        MOV AL,DH    ;Year/Month
        AND AL,1     ;Mask HSB month
        CMP AL,1
        JNE !ml7
        MOV BL,8
!ml7:
        MOV AL,DL    ;month/Day
        AND AL,224   ;mask month (upper 3 bits)
        SHR AL,5     ;divide by 2 and shift
        ADD AL,BL
        MOVZX AX,AL
        MOV $m,AX    ;Month

        MOV AL,DL    ;Month/day
        AND AL,31    ;Mask day
        MOVZX AX,AL
        MOV $d,AX    ;day
     END;
     year:=y;
     month:=m;
     day:=d;
END;

PROCEDURE FindFirst(Path: PathStr; Attr: LongWord; var F: TSearchRec);
VAR hDir:LONGINT;
    count,size:LONGWORD;
BEGIN
     hDir:=-1;  {HDIR_CREATE}
     count:=1;
     size:=sizeof(TSearchRec);
     ASM
        PUSHL 1  ;FIL_STANDARD
        LEA EAX,$count
        PUSH EAX
        PUSHL $size
        PUSHL $f
        PUSHL $Attr
        LEA EAX,$hDir
        PUSH EAX
        LEA EAX,$Path
        INC EAX
        PUSH EAX
        MOV AL,7
        CALLDLL DosCalls,264   ;DosFindFirst
        ADD ESP,28
        MOV _DosError,EAX
     END;
     f.HDir:=HDir;
     IF ((DosError<>0)or(Count=0)) THEN
     BEGIN
          ASM
             PUSHL $HDir
             MOV AL,1
             CALLDLL DosCalls,263  ;DosFindClose
             ADD ESP,4
          END;
     END;
END;

PROCEDURE FindNext(var F: TSearchRec);
VAR HDir:LONGINT;
    Count,size:LONGWORD;
BEGIN
     Count:=1;
     size:=sizeof(TSearchRec);
     HDir:=f.HDir;
     ASM
        LEA EAX,$Count
        PUSH EAX
        PUSHL $size
        PUSHL $F
        PUSHL $HDir
        MOV AL,4
        CALLDLL DosCalls,265     ;DosFindNext
        ADD ESP,16
        MOV _DosError,EAX
     END;
     IF ((DosError<>0)or(Count=0)) THEN
     BEGIN
          ASM
             PUSHL $HDir
             MOV AL,1
             CALLDLL DosCalls,263  ;DosFindClose
             ADD ESP,4
          END;
     END;
END;

PROCEDURE Exec(Path: PathStr; CmdLine: CmdStr;VAR ExecPID:LONGWORD);
VAR rc:ExecResultCode;
    error:string[128];
BEGIN
     ASM
        LEA EAX,$Path
        INC EAX
        PUSH EAX
        LEA EAX,$rc
        PUSH EAX
        PUSHL 0
        LEA EAX,$CmdLine
        INC EAX
        ;PUSH EAX
        PUSHL 0
        PUSHL 1     ;EXEC_ASYNC
        PUSHL 127
        LEA EAX,$error
        INC EAX
        PUSH EAX
        MOV AL,7
        CALLDLL DosCalls,283    ;DosExecPgm
        ADD ESP,28
     END;
     ExecPID:=rc.codeTerminate;
     Doserror:=rc.CodeResult;
END;


PROCEDURE GetFAttr(var F; var Attr: LongWord);
VAR s:_FILESTATUS3;
    size:LONGWORD;
BEGIN
     size:=sizeof(_FILESTATUS3);
     ASM
        PUSHL $size
        LEA EAX,$s
        PUSH EAX
        PUSHL 1   ;File Information level 1 FIL_STANDARD
        MOV EDI,$f
        MOV EAX,[EDI+0]  ;Handle of file
        PUSH EAX
        MOV AL,4
        CALLDLL DosCalls,279    ;DosQueryFileInfo
        ADD ESP,16
        MOV _DosError,EAX
     END;
     IF DosError=0 THEN
     BEGIN
          Attr:=s.attrFile;
     END
     ELSE Attr:=0; {invalid}

END;

PROCEDURE SetFAttr(var F; Attr: LongWord);
VAR s:_FILESTATUS3;
    size:LONGWORD;
BEGIN
     size:=sizeof(_FILESTATUS3);
     ASM
        PUSHL $size
        LEA EAX,$s
        PUSH EAX
        PUSHL 1   ;File Information level 1 FIL_STANDARD
        MOV EDI,$f
        MOV EAX,[EDI+0]  ;Handle of file
        PUSH EAX
        MOV AL,4
        CALLDLL DosCalls,279    ;DosQueryFileInfo
        ADD ESP,16
        MOV _DosError,EAX
     END;
     IF DosError=0 THEN
     BEGIN
          s.attrFile:=Attr;
          ASM
             PUSHL $size
             LEA EAX,$s
             PUSH EAX
             PUSHL 1   ;File Information level 1 FIL_STANDARD
             MOV EDI,$f
             MOV EAX,[EDI+0]  ;Handle of file
             PUSH EAX
             MOV AL,4
             CALLDLL DosCalls,218    ;DosSetFileInfo
             ADD ESP,16
             MOV _DosError,EAX
          END;
     END;
END;


PROCEDURE GetFTime(var F; var year,month,day,Hours,Minutes,TwoSecs:WORD);
VAR s:_FILESTATUS3;
    size:LONGWORD;
    y,m,d,h,min,sec:Word;
    date,time:WORD;
BEGIN
     size:=sizeof(_FILESTATUS3);
     ASM
        PUSHL $size
        LEA EAX,$s
        PUSH EAX
        PUSHL 1   ;File Information level 1 FIL_STANDARD
        MOV EDI,$f
        MOV EAX,[EDI+0]  ;Handle of file
        PUSH EAX
        MOV AL,4
        CALLDLL DosCalls,279    ;DosQueryFileInfo
        ADD ESP,16
        MOV _DosError,EAX
     END;
     IF DosError=0 THEN
     BEGIN
          date:=s.fdateLastWrite;
          time:=s.ftimelastwrite;
          ASM
             PUSHL $date
             PUSHL $year
             PUSHL $month
             PUSHL $day
             CALLN32 _UnPackDate

             PUSHL $time
             PUSHL $hours
             PUSHL $minutes
             PUSHL $TwoSecs
             CALLN32 _UnPackTime
          END;
     END
     ELSE
     BEGIN
          day:=0;
          month:=0;
          year:=0;
          Hours:=0;
          Minutes:=0;
          TwoSecs:=0;
     END;
END;


PROCEDURE SetFTime(var F; year,month,day,Hours,Minutes,TwoSecs:Word);
VAR s:_FILESTATUS3;
    size:LONGWORD;
    time,date:Word;
label l;
BEGIN
     IF ((Month>12)or(Month=0)) THEN
     BEGIN
l:
          DosError:=1;
          exit;
     END;
     IF ((Day>32)or(day=0)) THEN goto l;
     IF Hours>24 THEN goto l;
     IF Minutes>60 THEN goto l;
     IF TwoSecs>30 THEN goto l;
     size:=sizeof(_FILESTATUS3);
     ASM
        PUSHL $size
        LEA EAX,$s
        PUSH EAX
        PUSHL 1   ;File Information level 1 FIL_STANDARD
        MOV EDI,$f
        MOV EAX,[EDI+0]  ;Handle of file
        PUSH EAX
        MOV AL,4
        CALLDLL DosCalls,279    ;DosQueryFileInfo
        ADD ESP,16
        MOV _DosError,EAX
     END;
     IF DosError=0 THEN
     BEGIN
          ASM
             PUSHL $year
             PUSHL $month
             PUSHL $day
             CALLN32 _PackDate
             MOV $Date,AX

             PUSHL $Hours
             PUSHL $Minutes
             PUSHL $twosecs
             CALLN32 _PackTime
             MOV $Time,AX
          END;
          s.fdatelastwrite:=date;
          s.ftimeLastWrite:=time;
          ASM
             PUSHL $size
             LEA EAX,$s
             PUSH EAX
             PUSHL 1   ;File Information level 1 FIL_STANDARD
             MOV EDI,$f
             MOV EAX,[EDI+0]  ;Handle of file
             PUSH EAX
             MOV AL,4
             CALLDLL DosCalls,218    ;DosSetFileInfo
             ADD ESP,16
             MOV _DosError,EAX
          END;
     END;
END;

FUNCTION DiskFree(Drive: Byte): LongWord;
VAR a:_FSALLOCATE;
    s,d:LONGWORD;
    sec:LONGWORD;
BEGIN
     s:=sizeof(_FSALLOCATE);
     d:=Drive;
     ASM
        PUSHL $s
        LEA EAX,$a
        PUSH EAX
        PUSHL 1    ;FSIL_ALLOC -->Query allocation status
        PUSHL $d
        MOV AL,4
        CALLDLL DosCalls,278 ;DosQueryFSInfo
        ADD ESP,16
        MOV _DosError,EAX
     END;
     IF DosError=0 THEN
     BEGIN
          s:=a.cSectorUnit*a.cUnitAvail*a.cbSector;
     END
     ELSE s:=0;
     DiskFree:=s;
END;

FUNCTION DiskSize(Drive: Byte): LongWord;
VAR a:_FSALLOCATE;
    s,d:LONGWORD;
BEGIN
     s:=sizeof(_FSALLOCATE);
     d:=Drive;
     ASM
        PUSHL $s
        LEA EAX,$a
        PUSH EAX
        PUSHL 1    ;FSIL_ALLOC -->Query allocation status
        PUSHL $d
        MOV AL,4
        CALLDLL DosCalls,278 ;DosQueryFSInfo
        ADD ESP,16
        MOV _DosError,EAX
     END;
     IF DosError=0 THEN
     BEGIN
          s:=a.cSectorUnit*a.cUnit*a.cbSector;
     END
     ELSE s:=0;
     DiskSize:=s;
END;

FUNCTION EnvStr(Env:String): PEnvString;
VAR
   e:POINTER;
BEGIN
     ASM
        LEA EAX,$e
        PUSH EAX
        LEA EAX,$Env
        INC EAX
        PUSH EAX
        MOV AL,2
        CALLDLL DosCalls,227    ;DosScanEnv
        ADD ESP,8
        MOV ECX,0
        MOV _DosError,EAX
        CMP EAX,0
        JNE !scloope             ;EnvVar not found
        MOV ECX,$e
!scloope:
        MOV $e,ECX  ;Set string length
     END;
     EnvStr:=e;
END;

PROCEDURE GetVerify(var Verify: Boolean);ASM;
BEGIN
     ASM
        PUSH EBP
        MOV EBP,ESP
        SUB ESP,4   ;Return value
        LEA EAX,[EBP-4]
        PUSH EAX
        MOV AL,1
        CALLDLL DosCalls,225    ;DosQueryverify
        ADD ESP,4
        MOV AL,[EBP-4]
        MOV EDI,$Verify
        MOV [EDI+0],AL
        LEAVE
        RETN32
     END;
END;

PROCEDURE SetVerify(Verify: Boolean);ASM;
BEGIN
     ASM
        PUSH EBP
        MOV EBP,ESP
        MOV AL,$verify
        MOVZX EAX,AL
        PUSH EAX
        MOV AL,1
        CALLDLL DosCalls,210   ;DosSetVerify
        ADD ESP,4
        LEAVE
        RETN32
     END;
END;

FUNCTION DosVersion:Word;ASM;
BEGIN
     ASM
        PUSH EBP
        MOV EBP,ESP
        SUB ESP,8               ;for result values
        PUSHL 4                 ;size of buffer
        LEA EAX,[EBP-8]
        PUSH EAX                ;Buffer
        PUSHL 11                ;last:QSV_VERSION_MAJOR
        PUSHL 11                ;first:QSV_VERSION_MAJOR
        MOV AL,4
        CALLDLL DosCalls,348    ;DosQuerySysInfo
        ADD ESP,16
        PUSHL 4                 ;size of buffer
        LEA EAX,[EBP-4]
        PUSH EAX                ;Buffer
        PUSHL 12                ;last:QSV_VERSION_MINOR
        PUSHL 12                ;first:QSV_VERSION_MINOR
        MOV AL,4
        CALLDLL DosCalls,348    ;DosQuerySysInfo
        ADD ESP,16
        MOV AL,[EBP-8]          ;Major version number
        MOV AH,[EBP-4]          ;Minor version number
        LEAVE
        RETN32
     END;
END;

PROCEDURE GetDate(var Year,Month,Day,DayOfWeek: Word);
VAR d:_DateTime;
BEGIN
     ASM
        LEA EAX,$d
        PUSH EAX
        MOV AL,1
        CALLDLL DosCalls,230  ;DosGetDateTime
        ADD ESP,4
     END;
     Year:=d.year;
     Month:=d.month;
     Day:=d.Day;
     DayofWeek:=d.Weekday;
END;

PROCEDURE SetDate(Year,Month,Day,DayOfWeek: Word);
VAR d:_DateTime;
BEGIN
     ASM
        LEA EAX,$d
        PUSH EAX
        MOV AL,1
        CALLDLL DosCalls,230  ;DosGetDateTime
        ADD ESP,4
     END;
     d.year:=Year;
     d.month:=Month;
     d.day:=day;
     d.Weekday:=DayOfWeek;
     ASM
        LEA EAX,$d
        PUSH EAX
        MOV AL,1
        CALLDLL DosCalls,292 ;DosSetDateTime
        ADD ESP,4
     END;
END;

PROCEDURE GetTime(var Hour,Minute,Second,Sec100: Word);
VAR d:_DateTime;
BEGIN
     ASM
        LEA EAX,$d
        PUSH EAX
        MOV AL,1
        CALLDLL DosCalls,230  ;DosGetDateTime
        ADD ESP,4
     END;
     Hour:=d.hours;
     Minute:=d.minutes;
     Second:=d.Seconds;
     Sec100:=d.Hundredths;
END;

PROCEDURE SetTime(Hour,Minute,Second,Sec100: Word);ASM;
VAR d:_DateTime;
BEGIN
     ASM
        LEA EAX,$d
        PUSH EAX
        MOV AL,1
        CALLDLL DosCalls,230  ;DosGetDateTime
        ADD ESP,4
     END;
     d.Hours:=Hour;
     d.Minutes:=Minute;
     d.Seconds:=Second;
     d.Hundredths:=Sec100;
     ASM
        LEA EAX,$d
        PUSH EAX
        MOV AL,1
        CALLDLL DosCalls,292 ;DosSetDateTime
        ADD ESP,4
     END;
END;

BEGIN
END.
                 