UNIT PMDialog;

{**************************************************************************
*                                                                         *
*                                                                         *
*                                                                         *
*          General Unit for Object-PM  (C) 1993,94 R. Nrnberger          *
*                                                                         *
*                                                                         *
***************************************************************************}


INTERFACE

USES PMObject;



TYPE TDialog=OBJECT
                   HwndDlg:Hwnd;
                   {*******Do not change this location -- its hard coded***}
                   FUNCTION DialogHandleEvent(Dlg:HWND;msg:LONGWORD;
                                        Para1,Para2:LONGWORD;VAR Handled:BOOLEAN):
                                        LONGWORD;
                   {*******************************************************}
                   CONSTRUCTOR Init(Parent,Owner:HWND;hmod:HModule;idDlg:LONGWORD;
                                    pCreateParams:Pointer);
                   DESTRUCTOR Done;
                   PROCEDURE ExecDialog;
                   PROCEDURE GetDlg(VAR Dlg:HWND);
             END;


VAR FileOpenDlgWildCards:STRING;
    FileOpenDlgTitle:String[40];
    FileOpenDlgOkName:String[40];
    FileSaveDlgWildCards:STRING;
    FileSaveDlgTitle:String[40];
    FileSaveDlgOkName:String[40];
    DialogVMT:POINTER;


FUNCTION FileOpenDialog(Win:HWND;Wildcards:String;VAR result:String):Boolean;
FUNCTION FileSaveDialog(Win:HWND;Wildcards:String;VAR result:String):Boolean;


IMPLEMENTATION

IMPORTS {Private}
       FUNCTION WinLoadDlg(pCreateParams:POINTER;idDld:LONGWORD;
                           hmod:HMODULE;DlgProc:POINTER;Owner:HWND;
                           Parent:HWND):LONGWORD:   PMWIN index 924;
       FUNCTION WinProcessDlg(hwndDlg:HWND):LONGWORD: PMWIN index 796;
       FUNCTION WinDefDlgProc(Para2,Para1:POINTER;msg:LONGWORD;hwnddlg:HWND):
                           LONGWORD:    PMWIn index 910;
       FUNCTION WinDestroyWindow(_hwnd:HWND):
                                    LONGWORD:              PMWIN index 728;
END;

PROCEDURE TDialog.GetDlg(VAR Dlg:HWND);
BEGIN
     Dlg:=hwnddlg;
END;


FUNCTION TDialog.DialogHandleEvent(Dlg:HWND;msg:LONGWORD;Para1,Para2:
                             LONGWORD;VAR Handled:BOOLEAN):LONGWORD;
VAR H:BOOLEAN;
    r:LONGWORD;
BEGIN
     r:=0;
     H:=FALSE;
     Handled:=H;
     DialogHandleEvent:=r;
END;


PROCEDURE StdDlgProc(para2,para1:POINTER;Msg,Win:LONGWORD);ASM;
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
        LEA EAX,[EBP-2]  ;Handled
        PUSH EAX
        MOV EDI,_DialogVMT
        PUSH EDI         ;VMT Pointer
        MOV EDI,[EDI+0]  ;get VMT pointer for AppHandleEvent
        db ffh,17h       ;CALL NEAR32 [EDI+0] --> in Methode springen
        MOV BL,[EBP-2]
        CMP BL,0
        JNE !hh
        ;not handled
        ;Default Dialog handler
        PUSHL $para2
        PUSHL $para1
        PUSHL $msg
        PUSHL $win
        MOV AL,4
        CALLDLL PMWin,910   ;WinDefDlgProc
        ADD ESP,16
!hh:
        LEAVE
        RETN32
     END;
END;

CONSTRUCTOR TDialog.Init(Parent,Owner:HWND;hmod:HModule;idDlg:LONGWORD;
                         PCreateParams:Pointer);
BEGIN
     DialogVMT:=SELF;
     hwnddlg:=WinLoadDlg(PCreateParams,idDlg,hmod,@StdDlgProc,Owner,Parent);
END;

DESTRUCTOR TDialog.Done;
BEGIN
END;

PROCEDURE TDialog.ExecDialog;
BEGIN
     WinProcessDlg(hwnddlg);
     WinDestroyWindow(hwnddlg);
END;


TYPE PFileDlg=^FileDlg;
     FileDlg=record
                   cbSize:LONGWORD;        { Size of FILEDLG structure.}
                   fl:LONGWORD;            { FDS_ flags. Alter behavior of dlg. }
                   ulUser:LONGWORD;        { User defined field. }
                   lReturn:LONGWORD;       { Result code from dialog dismissal. }
                   lSRC:LONGWORD;          { System return code. }
                   pszTitle:POINTER;       { String to display in title bar.}
                   pszOKButton:POINTER;    { String to display in OK button. }
                   pfnDlgProc:POINTER;     { Entry point to custom dialog proc. }
                   pszIType:POINTER;       { Pointer to string }
                   papszITypeList:POINTER;
                   pszIDrive:POINTER;
                   papszIDriveList:POINTER;
                   hMod:LONGWORD;   { Custom File Dialog template.       }
                   szFullFile:ARRAY[0..259] OF Char;
                   papszFQFilename:POINTER;
                   ulFQFCount:LONGWORD;  { Number of files selected }
                   usDlgId:WORD;         { Custom dialog id.}
                   x:WORD;               { X coordinate of the dialog  }
                   y:WORD;               { Y coordinate of the dialog  }
                   sEAType:WORD;         { Selected files EA Type. }
             END;

FUNCTION FileOpenDialog(Win:HWND;VAR result:String):Boolean;
VAR Dlg:FileDlg;
BEGIN
     fillchar(dlg,sizeof(FileDlg),0); {Clear Dialog structure}
     ASM
        LEA EDI,$dlg
        ADD EDI,20   ;to pszTitle
        MOV EAX,OFFSET(_FileOpenDlgTitle)
        INC EAX
        MOV [EDI+0],EAX

        LEA EDI,$dlg
        ADD EDI,24  ;to pszOKButton
        MOV EAX,OFFSET(_FileOpenDlgOkName)
        INC EAX
        MOV [EDI+0],EAX

        LEA EDI,$dlg
        ADD EDI,52  ;to szFullFile
        MOV ESI,OFFSET(_FileOpenDlgWildCards)
        MOV CL,[ESI+0]
        INC ESI
        MOVZX ECX,CL
        INC ECX
        CLD
        REP
        MOVSB
     END;
     dlg.cbSize:=sizeof(Filedlg);
     dlg.fl:=$901;  {FDS_OPEN_DIALOG | FDS_CENTER | FDS_ENABLEFILELB }
     ASM
        LEA EAX,$Dlg
        PUSH EAX
        PUSHL $Win
        PUSHL 1   ;Owner is HWND_DESKTOP
        MOV AL,3
        CALLDLL PMCTLS,4  ;WinFileDlg
        ADD ESP,12
     END;
     IF Dlg.lReturn=1 THEN {DID_OK}
     BEGIN
          asm
             MOV EDI,$result
             INC EDI
             LEA ESI,$dlg
             ADD ESI,52  ;to szFullFile
             MOV CX,0
!next:
             MOV AL,[ESI+0]
             CMP AL,0
             JE !ec
             MOV [EDI+0],AL
             INC EDI
             INC ESI
             INC CX
             JMP !next
!ec:
             MOV EDI,$result
             MOV [EDI+0],CL  ;set length
          end;
          FileOpenDialog:=TRUE;
     END
     ELSE
     BEGIN
          result:='';
          FileOpenDialog:=FALSE;
     END;
END;

FUNCTION FileSaveDialog(Win:HWND;VAR result:String):Boolean;
VAR Dlg:FileDlg;
    t:BYTE;
BEGIN
     fillchar(dlg,sizeof(FileDlg),0); {Clear Dialog structure}
     asm
        LEA EDI,$dlg
        ADD EDI,20   ;to pszTitle
        MOV EAX,OFFSET(_FileSaveDlgTitle)
        INC EAX
        MOV [EDI+0],EAX

        LEA EDI,$dlg
        ADD EDI,24  ;to pszOKButton
        mOV EAX,OFFSET(_FileSaveDlgOkName)
        INC EAX
        MOV [EDI+0],EAX

        LEA EDI,$dlg
        ADD EDI,52  ;to szFullFile
        MOV ESI,OFFSET(_FileSaveDlgWildCards)
        MOV CL,[ESI+0]
        INC ESI
        MOVZX ECX,CL
        INC ECX
        CLD
        REP
        MOVSB
     end;
     Dlg.cbSize:=sizeof(Filedlg);
     Dlg.fl:=$a01;  {FDS_SAVEAS_DIALOG | FDS_CENTER | FDS_ENABLEFILELB }
     asm
        LEA EAX,$Dlg
        PUSH EAX
        PUSHL $Win
        PUSHL 1   ;Owner is HWND_DESKTOP
        MOV AL,3
        CALLDLL PMCTLS,4  ;WinFileDlg
        ADD ESP,12
     end;
     IF Dlg.lReturn=1 THEN {DID_OK}
     BEGIN
          asm
             MOV EDI,$result
             INC EDI
             LEA ESI,$dlg
             ADD ESI,52  ;to szFullFile
             MOV CX,0
!next_1:
             MOV AL,[ESI+0]
             CMP AL,0
             JE !ec_1
             MOV [EDI+0],AL
             INC EDI
             INC ESI
             INC CX
             JMP !next_1
!ec_1:
             MOV EDI,$result
             MOV [EDI+0],CL  ;set length
          end;
          FileSaveDialog:=TRUE;
     END
     ELSE
     BEGIN
          result:='';
          FileSaveDialog:=FALSE;
     END;
     FOR t:=1 TO length(result) DO result[t]:=upcase(result[t]);
END;


BEGIN
     FileOpenDlgTitle:='Open a file';
     FileOpenDlgWildcards:='*.*';
     FileOpenDlgOkname:='Open';
     FileSaveDlgTitle:='Save file as';
     FileSaveDlgWildcards:='*.*';
     FileSaveDlgOkname:='Save';
END.