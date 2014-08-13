UNIT PMEditor;

{************************************************************************
*                                                                       *
*                                                                       *
*          General Unit for Object-PM (C) 1993,94 R. NÅrnberger         *
*                                                                       *
*                                                                       *
*************************************************************************}

INTERFACE

USES PmObject,PmDos,PmDialog;

CONST
     MaxEditors=32;          {Maximal editors to process}
     InitialBuf=32768;       {starting buffer size for editing}
     EditorMaxLines:WORD=28; {maximal editor lines for standard text}

VAR
   CharWidth:LONGWORD;
   CharHeight:LONGWORD;
   SelectDrawColor,SelectBackColor:LONGINT;

TYPE
     PSliderData=^SliderData;
     SliderData=record
                      scrollbottom:LONGWORD; { Scroll lower border  }
                      scrolltop:LONGWORD;    { Scroll upper border  }
                      viewarea:LONGWORD;     { View area of window  }
                      intervall:WORD;        { Intervall of Slider  }
                      acvalue:LONGWORD;      { actual Slider value  }
                end;

     PTextBuf=^TTextBuf;
     TTextBuf=ARRAY[0..6553500] OF BYTE; {that should be enough ...}

     PEditor=^TEditor;  {Data structure for each editor}
     TEditor=RECORD
                   TextBuffer:PTextBuf; {Buffer to text}
                   ScreenBuffer:ARRAY[0..60] OF String[126];
                   TextLen:LONGWORD;    {Length of text +InitialBuf}
                   TextLow:LONGWORD;    {Actual low position in text}
                   TextHigh:LONGWORD;   {Actual high position in text}
                   HSlider,VSlider:SliderData;
                   CursorX,CursorY:LONGWORD; {Current cursor position}
                   InsertMode:BOOLEAN;
                   Title:String;
                   Untitled:BOOLEAN;
                   Modified:BOOLEAN;
                   TextLines:LONGWORD;
                   TextViewX,TextViewY:LONGWORD;
                   SelectLineStart,SelectColumnStart:WORD;
                   SelectLineEnd,SelectColumnEnd:WORD;
                   SelectAnchorLine,SelectAnchorColumn:WORD;
                   Win:HWND;  {Frame window handle}
             END;



TYPE TEditorApplication=OBJECT(TMDIApplication)
                   EditorCount:WORD;
                   UntitledCount:BYTE;
                   Editors:ARRAY[0..MaxEditors] OF PEditor;
                   CreateBackups:BOOLEAN;
                   StdExt:String;
                   CONSTRUCTOR Init(AppMainID:LONGWORD);
                   DESTRUCTOR Done;
                   FUNCTION MDIHandleEvent(Win:HWND;Msg:LONGWORD;para1,para2:POINTER;
                                           VAR Handled:BOOLEAN;
                                           Extra:POINTER):LONGWORD:virtual;
                   FUNCTION AppHandleEvent(Win:HWND;Msg:LONGWORD;
                                           para1,para2:POINTER;
                                           VAR Handled:BOOLEAN):
                                           LONGWORD:virtual;
                   PROCEDURE MDIRedraw(Win:HWND;_hps:HPS;Extra:POINTER):virtual;
                   PROCEDURE MDICreateNotify(Win:HWND;Extra:POINTER):virtual;
                   PROCEDURE OpenNewFile;
                   PROCEDURE OpenFile(name:STRING);
                   PROCEDURE SaveFile;
                   PROCEDURE SaveFileAs;
                   PROCEDURE SaveAllFiles;
                   PROCEDURE SaveEditor(e:PEditor);
                   PROCEDURE InitEditor(e:Peditor);
                   PROCEDURE CheckHScrollBar(Win:HWND;para1,para2,Extra:PEditor);
                   PROCEDURE CheckVScrollBar(Win:HWND;para1,para2,Extra:PEditor);
                   PROCEDURE MDIHandleCharEvent(Win:HWND;Extra:POINTER;
                                               ch:Char):virtual;
                   PROCEDURE MDIHandleScanEvent(Win:HWND;Extra:POINTER;
                                                scan:Word):virtual;
                   PROCEDURE SetCursor(Win:HWND;pp:PEditor);
                   PROCEDURE InvalidateEditorLine(Win:HWND;VAR s:string;
                                                  y:LONGWORD;Extra:PEditor);
                   FUNCTION CheckIfToScrollX(Win:HWND;Extra:PEditor):BOOLEAN;
                   PROCEDURE DestroyEditor(e:PEditor);
                   PROCEDURE InvalidateEditorWindow(Win:HWND;Extra:PEditor);
                   FUNCTION CalcMaxSliderPositions(VAR scrolldata:SliderData)
                                                   :WORD;
                   FUNCTION CalcSliderfromValue(wert:LONGWORD;scrolldata:
                                                SliderData):WORD;
                   FUNCTION CalcValuefromSlider(wert:WORD;scrolldata:
                                                SliderData):LONGWORD;
                   FUNCTION GetUpperLine(VAR s:string;Extra:PEditor):BOOLEAN;
                   FUNCTION GetLowerLine(VAR s:string;Extra:PEditor):BOOLEAN;
                   FUNCTION AppendUpperLine(VAR s:string;Extra:PEditor):BOOLEAN;
                   FUNCTION AppendLowerLine(VAR s:string;Extra:PEditor):BOOLEAN;
                   PROCEDURE LineDown(Win:HWND;Extra:PEditor);
                   PROCEDURE PageDown(Win:HWND;Extra:PEditor);
                   PROCEDURE LineUp(Win:HWND;Extra:PEditor);
                   PROCEDURE PageUp(Win:HWND;Extra:PEditor);
              END;


IMPLEMENTATION

IMPORTS {Private}
      FUNCTION WinSetWindowText(psztext:PSZ;
                                _hwnd:HWND):LONGWORD:   PMWIN index 877;
      FUNCTION WinQueryWindow(cmd:LONGWORD;
                                  _hwnd:HWND):LONGWORD:    PMWIN index 834;
      FUNCTION WinWindowFromID(id:LONGWORD;
                                   hwndParent:HWND):HWND:  PMWIN index 899;
      FUNCTION WinSendMsg(MPARAM2,MPARAM1:POINTER;
                              msg:LONGWORD;
                              _hwnd:HWND):POINTER:         PMWIN index 920;
      FUNCTION WinQueryWindowRect(VAR prclDest:RECTL;
                                      _hwnd:HWND ):
                                      LONGWORD:            PMWIN index 840;
      PROCEDURE WinReleasePS(_hps:HPS):                    PMWIN index 848;
      FUNCTION  WinGetPS(Win:HWND):HPS:                    PMWIN index 757;
      PROCEDURE WinShowCursor(Visible:LONGWORD;
                              Win:HWND):                   PMWIN index 880;
      PROCEDURE GpiSetBackMix(Mix:LONGWORD;_hps:HPS):      PMGPI index 505;
      FUNCTION GpiSetColor(lColor:LONGWORD;
                             _hps:HPS):LONGINT:            PMGPI index 517;
      FUNCTION GpiSetBackColor(lColor:LONGINT;
                               _hps:HPS):LONGWORD:       PMGPI index 504;
      FUNCTION GpiCharStringAt(VAR pchString;
                               lCount:LONGWORD;
                               VAR pptlPoint:POINTL;
                               _hps:HPS):LONGWORD:       PMGPI index 359;
END;

PROCEDURE TEditorApplication.SaveEditor(e:PEditor);
VAR f:file;
    d:dirstr;
    n:namestr;
    ex:extstr;
    s:String;
    Buf:LONGWORD;
    Len:LONGWORD;
    t:BYTE;
    sp:PString;
BEGIN
     IF e=NIL THEN exit;
     IF e^.Untitled THEN
     BEGIN
          GetDir(0,s);
          IF s[length(s)]='\' THEN dec(s[0]);
          s:=s+'\'+e^.Title;
          e^.Title:=s;
          e^.Untitled:=FALSE;
          sp:=s;
          WinSetWindowText(sp,e^.Win);
     END;
     IF CreateBackups THEN
     BEGIN
          s:=e^.Title;
          assign(f,s);
          fsplit(s,d,n,ex);
          IF d[length(d)]='\' THEN dec(d[0]);
          s:=d+'\'+n+'.BAK';
          Erase(s);  {Delete old .BAK file}
          Rename(f,s);
     END;
     s:=e^.Title;
     Assign(f,s);
     Rewrite(f,1);
     IF ioresult<>0 THEN
     BEGIN
          ErrorBox('Could not create file (Disk full ?)');
          exit;
     END;
     Buf:=LONGWORD(e^.TextBuffer);
     Len:=e^.TextLow-Buf;
     IF Len>0 THEN
     BEGIN
          BlockWrite(f,e^.TextBuffer^[0],Len);
          IF ioresult<>0 THEN
          BEGIN
              ErrorBox('Could not write file (Disk full ?)');
              Close(f);
              exit;
          END;
     END;

     FOR t:=0 TO EditorMaxLines DO
     BEGIN
          s:=e^.ScreenBuffer[t];
          while s[length(s)]=#32 do dec(s[0]);
          s:=s+#13+#10;
          BlockWrite(f,s[1],length(s));
          IF ioresult<>0 THEN
          BEGIN
              ErrorBox('Could not write file (Disk full ?)');
              Close(f);
              exit;
          END;
     END;

     Len:=Buf+e^.textlen;  {Maximal adress}
     Len:=Len-e^.TextHigh;
     IF Len>0 THEN
     BEGIN
          BlockWrite(f,e^.TextBuffer^[e^.TextHigh-Buf],len);
          IF ioresult<>0 THEN
          BEGIN
             ErrorBox('Could not write file (Disk full ?)');
             Close(f);
             exit;
          END;
     END;
     Close(f);
     IF ioresult<>0 THEN
     BEGIN
          ErrorBox('Could not write file (Disk full ?)');
          exit;
     END;
     e^.Modified:=FALSE;
END;

PROCEDURE TEditorApplication.SaveFile;  {Save upper editor file}
VAR e:PEditor;
    s:string;
    sp:PString;
    f:file;
BEGIN
     IF EditorCount=0 THEN exit;
     MDIGetTopWindow(e);
     IF e=NIL THEN exit;
     IF e^.Untitled THEN
     BEGIN
          IF FileSaveDialog(AppWinHandle,s) THEN
          BEGIN
               IF pos('.',s)=0 THEN s:=s+StdExt;
               assign(f,s);
               reset(f,1);
               IF ioresult=0 THEN  {file exists}
               BEGIN
                    Close(f);
                    IF not ConfirmBox('File exists. Overwrite ??') THEN exit;
               END;
               e^.Title:=s;
               e^.Untitled:=FALSE;
               sp:=s;
               WinSetWindowText(sp,e^.Win);
          END
          ELSE exit; {Canceled}
     END;
     SaveEditor(e);
END;

PROCEDURE TEditorApplication.SaveFileAs;  {Save upper editor file}
VAR e:PEditor;
    s:string;
    sp:PString;
    f:file;
BEGIN
     IF EditorCount=0 THEN exit;
     MDIGetTopWindow(e);
     IF e=NIL THEN exit;
     IF FileSaveDialog(AppWinHandle,s) THEN
     BEGIN
          IF pos('.',s)=0 THEN s:=s+StdExt;
          assign(f,s);
          reset(f,1);
          IF ioresult=0 THEN  {file exists}
          BEGIN
               Close(f);
               IF not ConfirmBox('File exists. Overwrite ??') THEN exit;
          END;
          e^.Title:=s;
          e^.Untitled:=FALSE;
          sp:=s;
          WinSetWindowText(sp,e^.Win);
     END
     ELSE exit; {Canceled}
     SaveEditor(e);
END;

PROCEDURE TEditorApplication.SaveAllFiles;
VAR t:BYTE;
BEGIN
     IF EditorCount=0 THEN exit;
     FOR t:=0 TO EditorCount-1 DO
       IF Editors[t]^.Modified THEN SaveEditor(Editors[t]);
END;


FUNCTION TEditorApplication.CalcMaxSliderPositions(VAR scrolldata:SliderData):WORD;
VAR as:WORD;
BEGIN
     as:=(scrolldata.scrolltop-scrolldata.scrollbottom)-scrolldata.viewarea;
     inc(as,2);
     scrolldata.intervall:=as;
     CalcMaxSliderPositions:=as;
END;

FUNCTION TEditorApplication.CalcSliderfromValue(wert:LONGWORD;scrolldata:SliderData):WORD;
VAR og:LONGWORD;
    rec:RECTL;
BEGIN
     og:=(scrolldata.scrolltop-scrolldata.viewarea)+1;
     IF wert<scrolldata.scrollbottom THEN wert:=scrolldata.scrollbottom;
     IF wert>og THEN wert:=og;
     CalcSliderfromValue:=(wert-scrolldata.scrollbottom)+1;
END;

FUNCTION TEditorApplication.CalcValuefromSlider(Wert:WORD;scrolldata:SliderData):
         LONGWORD;
VAR og:WORD;
BEGIN
     og:=(scrolldata.scrolltop-scrolldata.scrollbottom)-scrolldata.viewarea;
     inc(og,2);
     IF Wert<1 THEN Wert:=1;
     IF Wert>og THEN Wert:=og;
     CalcValuefromSlider:=(Wert+scrolldata.scrollbottom)-1;
END;


FUNCTION TEditorApplication.GetUpperLine(VAR s:string;Extra:PEditor):BOOLEAN;
VAR Adresse:LONGWORD;
    Buffer:POINTER;
    Max:LONGWORD;
    result:BOOLEAN;
Label l;
BEGIN
     Adresse:=Extra^.TextHigh;
     Max:=LONGWORD(Extra^.TextBuffer)+Extra^.TextLen;
     IF Adresse>=Max THEN
     BEGIN
          Extra^.TextHigh:=Max;
          s:='';
          result:=FALSE;
          goto l;
     END;
     Buffer:=Extra^.TextBuffer;
     ASM
        MOV CL,0
        MOV EDI,$s
        INC EDI
        MOV ESI,$Adresse
        INC ESI
!rep_lab:
        CMP ESI,$Max
        JAE !crlf
        MOV AL,[ESI+0]
        CMP AL,13
        JE !cr
        CMP AL,10
        JE !crlf

        INC CL
        INC ESI
        MOV [EDI+0],AL
        INC EDI
        CMP CL,127
        JAE !crlf
        JMP !rep_lab
!cr:
        INC ESI
        MOV AL,[ESI+0]
        CMP AL,10
        JNE !crlf
        INC ESI
!crlf:
        CLD
        MOV AL,0
        STOSB
        MOV EDI,$s
        MOV [EDI+0],CL   ;Set text len
        DEC ESI
        CMP ESI,$Max
        JBE !ok1
        MOV ESI,$Max
!ok1:
        MOV $Adresse,ESI
     END;
     Extra^.TextHigh:=Adresse;
     result:=TRUE;
l:
     IF length(s)>126 THEN s[0]:=#126;
     ASM
        MOV EDI,$s
        MOV AL,[EDI+0]
        CMP AL,126
        JE !eee
        ;Length to short --> fill up with space
        MOVZX EAX,AL
        MOVB [EDI+0],126
        ADD EDI,EAX
        INC EDI
        MOV ECX,126
        SUB ECX,EAX
        MOV AL,32
        CLD
        REP
        STOSB
        MOV AL,0
        STOSB
!eee:
     END;
     GetUpperLine:=result;
END;

FUNCTION TEditorApplication.GetLowerLine(VAR s:string;Extra:PEditor):BOOLEAN;
VAR Adresse:LONGWORD;
    Buffer:POINTER;
    Result:BOOLEAN;
Label l;
BEGIN
     Adresse:=Extra^.TextLow;
     Buffer:=Extra^.TextBuffer;
     IF Adresse<=LONGWORD(Buffer) THEN
     BEGIN
          Extra^.TextLow:=LONGWORD(Buffer);
          Result:=FALSE;
          s:='';
          goto l;
     END;
     ASM
         MOV CL,0
         MOV EDI,$s
         INC EDI
         MOV ESI,$Adresse
         SUB ESI,3
!rep_lab1:
         CMP ESI,$Buffer
         JB !cr1
         CMP CL,127
         JAE !cr1
         MOV AL,[ESI+0]
         CMP AL,10
         JE !cr1
         CMP AL,13
         JE !cr1
         DEC ESI
         INC CL
         JMP !rep_lab1
!cr1:
         INC ESI
         MOVZX ECX,CL
         PUSH ECX
         PUSH ESI
         CMP ECX,0
         JE !no_copy
         CLD
         REP
         MOVSB
!no_copy:
         CLD
         MOV AL,0
         STOSB
         POP ESI
         POP ECX
         MOV EDI,$s
         MOV [EDI+0],CL
         CMP ESI,$Buffer
         JAE !ok
         MOV ESI,$Buffer
!ok:
         MOV $Adresse,ESI
     END;
     Extra^.TextLow:=Adresse;
     Result:=TRUE;
l:
     IF length(s)>126 THEN s[0]:=#126;
     ASM
        MOV EDI,$s
        MOV AL,[EDI+0]
        CMP AL,126
        JE !eee1
        ;Length to short --> fill up with space
        MOVZX EAX,AL
        MOVB [EDI+0],126
        ADD EDI,EAX
        INC EDI
        MOV ECX,126
        SUB ECX,EAX
        MOV AL,32
        CLD
        REP
        STOSB
        MOV AL,0
        STOSB
!eee1:
     END;
     GetLowerLine:=Result;
END;

FUNCTION TEditorApplication.AppendUpperLine(VAR s:string;Extra:PEditor):BOOLEAN;
VAR Adresse:LONGWORD;
    Buffer:POINTER;
BEGIN
     WHILE s[length(s)]=#32 DO dec(s[0]);
     Adresse:=Extra^.TextHigh;
     Buffer:=Extra^.TextBuffer;
     ASM
         MOV EDI,$Adresse
         MOV AL,10
         STD
         STOSB
         MOV AL,13
         STOSB
         MOV ESI,$s
         MOV CL,[ESI+0]
         MOVZX ECX,CL
         ADD ESI,ECX
         CMP ECX,0
         JE !no_copy1
         STD
         REP
         MOVSB
!no_copy1:
         MOV $Adresse,EDI
     END;
     Extra^.TextHigh:=Adresse;
     AppendUpperLine:=TRUE;
END;

FUNCTION TEditorApplication.AppendLowerLine(VAR s:string;Extra:PEditor):BOOLEAN;
VAR Adresse:LONGWORD;
    Buffer:POINTER;
BEGIN
     WHILE s[length(s)]=#32 DO dec(s[0]);
     Adresse:=Extra^.TextLow;
     Buffer:=Extra^.TextBuffer;
     ASM
        MOV EDI,$Adresse
        MOV ESI,$s
        MOV CL,[ESI+0]
        MOVZX ECX,CL
        INC ESI
        CMP ECX,0
        JE !no_copy2
        CLD
        REP
        MOVSB
!no_copy2:
        MOV AL,13
        STOSB
        MOV AL,10
        STOSB
        MOV $Adresse,EDI
     END;
     Extra^.TextLow:=Adresse;
     AppendLowerLine:=TRUE;
END;

CONSTRUCTOR TEditorApplication.Init(AppMainID:LONGWORD);
VAR t:WORD;
BEGIN
     inherited.init(AppMainID);
     SelectBackColor:=15; {CLR_PALEGRAY}
     SelectDrawColor:=1; {CLR_BLUE}
     StdExt:='.TXT';
     EditorCount:=0;
     UntitledCount:=0;
     CharHeight:=16;
     CharWidth:=8;
     CreateBackups:=TRUE;
     FOR t:=0 TO MaxEditors DO Editors[t]:=NIL;
END;

DESTRUCTOR TEditorApplication.Done;
BEGIN
END;

PROCEDURE TEditorApplication.DestroyEditor(e:PEditor);
VAR t,t1:WORD;
label l;
BEGIN
     freemem(e^.TextBuffer,e^.TextLen);
     FOR t:=0 TO MaxEditors DO IF Editors[t]=e THEN goto l;
     errorbox('Could not free editor data !');
     exit;
l:
     FOR t1:=t TO MaxEditors DO Editors[t1]:=Editors[t1+1];
     dec(EditorCount);
     dispose(e);
END;

PROCEDURE TEditorApplication.InitEditor(e:Peditor);
VAR Adresse:LONGWORD;
    Max:LONGWORD;
BEGIN
     Editors[EditorCount]:=e;
     inc(EditorCount);
     e^.CursorX:=1;
     e^.CursorY:=1;
     e^.InsertMode:=FALSE;
     e^.Untitled:=FALSE;
     e^.Modified:=FALSE;
     e^.SelectLineStart:=65535;
     e^.SelectLineEnd:=65535;
     e^.SelectColumnStart:=65535;
     e^.SelectColumnEnd:=65535;
     Adresse:=e^.TextHigh;
     Max:=EditorMaxLines;
     ASM
        MOV ECX,$Max
        MOV EDI,$Adresse
        STD
!cploop:
        MOV AL,10
        STOSB
        MOV AL,13
        STOSB
        LOOP !cploop
        MOV $Adresse,EDI
     END;
     e^.TextHigh:=Adresse;
END;

PROCEDURE TEditorApplication.OpenNewFile;
VAR e:PEditor;
    t:WORD;
    s:string;
BEGIN
      IF EditorCount>=MaxEditors THEN
      BEGIN
           ErrorBox('Too much files opened');
           exit;
      END;
      new(e);
      getmem(e^.TextBuffer,InitialBuf); {reserve 32K initially}
      e^.Textlen:=InitialBuf;
      e^.TextLow:=LONGWORD(e^.TextBuffer);
      e^.TextHigh:=e^.TextLow+e^.textLen;  {Clear Editor}
      e^.TextLines:=EditorMaxLines;
      InitEditor(e);
      FOR t:=0 TO EditorMaxLines DO
      BEGIN
           e^.ScreenBuffer[t]:='';
           s:=e^.ScreenBuffer[t];
           ASM
              CLD
              LEA EDI,$s
              MOV AL,126
              STOSB
              MOV ECX,126
              MOV AL,32
              REP
              STOSB
           END;
           e^.ScreenBuffer[t]:=s;
      END;
      s:=Tostr(UntitledCount);
      inc(UntitledCount);
      IF length(s)=1 THEN s:='0'+s;
      e^.Title:='NONAME'+s+StdExt;
      e^.untitled:=TRUE;
      e^.Win:=MDICreateChild(e^.Title,e,FCF_VERTSCROLL or FCF_HORZSCROLL);
END;

PROCEDURE TEditorApplication.OpenFile(name:string);
VAR e:PEditor;
    t:WORD;
    f:file;
    size:LONGWORD;
    Adresse:LONGWORD;
    Zeilen:LONGWORD;
    BufAdresse:LONGWORD;
    BufLen:LONGWORD;
BEGIN
      IF EditorCount>=MaxEditors THEN
      BEGIN
           ErrorBox('Too much files opened');
           exit;
      END;
      assign(f,name);
      reset(f,1);
      if ioresult<>0 THEN
      BEGIN
           ErrorBox('Error reading:'+name);
           exit;
      END;
      size:=FileSize(f);
      new(e);
      getmem(e^.TextBuffer,size+InitialBuf); {reserve 32K initially}
      e^.Textlen:=InitialBuf+size;
      e^.TextLow:=LONGWORD(e^.TextBuffer);
      e^.TextHigh:=e^.TextLow+InitialBuf+size;  {Clear Editor}
      e^.TextLines:=EditorMaxLines;
      InitEditor(e);
      dec(e^.TextHigh,size+1);
      Adresse:=e^.TextHigh+1;
      ASM
         LEA EAX,$f
         PUSH EAX
         PUSHL $Adresse
         PUSHL $Size
         CALLN32 System._BlockRead
      END;
      IF ioresult<>0 THEN ErrorBox('Error reading:'+name)
      ELSE IF Size<>BlockReadResult THEN ErrorBox('Error reading:'+name);
      close(f);
      {Count Zeilnums}
      Zeilen:=0;
      BufAdresse:=e^.TextHigh+1;
      BufLen:=e^.TextLow+InitialBuf+size;
      ASM
         MOV ESI,$BufAdresse
         CLD
!cloop:
         CMP ESI,$BufLen
         JAE !zexit
         LODSB
         CMP AL,13
         JE !zfoundcr
         CMP AL,10
         JE !zFound
         JMP !cloop
!zfoundcr:
         LODSB
         CMP AL,10
         JE !zfound
         DEC ESI
!zfound:
         INCD $Zeilen
         JMP !cloop
!zexit:
      END;
      e^.TextLines:=Zeilen;
      FOR t:=0 TO EditorMaxLines DO GetUpperLine(e^.ScreenBuffer[t],e);
      e^.Title:=name;
      MDICreateChild(e^.Title,e,FCF_VERTSCROLL or FCF_HORZSCROLL); {Extra Byte is the editor}
END;


FUNCTION TEditorApplication.AppHandleEvent(Win:HWND;Msg:LONGWORD;
                                        para1,para2:POINTER;
                                        VAR Handled:BOOLEAN):LONGWORD;
VAR r:LONGWORD;
BEGIN
     r:=Inherited.AppHandleEvent(Win,Msg,para1,para2,Handled);
     AppHandleEvent:=r;
END;


PROCEDURE TEditorApplication.SetCursor(Win:HWND;pp:PEditor);
VAR cux,cuy:LONGWORD;
    rec:RECTL;
    s,s1:string;
    sp:Pstring;
    ScrollWin,FrameWin:HWND;
    w:WORD;
    p:POINTER;
    ww,ww1:WORD;
    t:LONGWORD;
    na:namestr;
    di:dirstr;
    ex:extstr;
BEGIN
     WinShowCursor(0,Win);
     WinQueryWindowRect(rec,Win);
     cux:=2+(pp^.CursorX-1)*CharWidth;
     cuy:=rec.yTop-(pp^.CursorY)*CharHeight;
     dec(cuy,2);
     ASM
        ;Set window cursor
        PUSHL 0      ;whole window
        PUSHL 8004h  ;CURSOR_SETPOS
        PUSHL 2      ;Cusizey
        PUSHL _CharWidth
        PUSHL $cuy
        PUSHL $cux
        PUSHL $Win
        MOV AL,7
        CALLDLL PMWIN,715  ;WinCreateCursor
        ADD ESP,28
    END;
    WinShowCursor(1,Win);
    s1:=pp^.Title;
    IF length(s1)>60 THEN
    BEGIN
         fsplit(s1,di,na,ex);
         s1:='...\'+na+ex;
    END;
    s:=s1+'   '+tostr(pp^.CursorY+pp^.VSlider.acvalue)+':'+
       tostr(pp^.CursorX+pp^.HSlider.acvalue);
    IF pp^.Modified THEN s:=s+' *';
    sp:=s;
    FrameWin:=WinQueryWindow(QW_PARENT,Win);
    WinSetWindowText(sp,FrameWin);
    ScrollWin:=WinWindowFromID(FID_HORZSCROLL,FrameWin);

    w:=CalcSliderfromValue(pp^.HSlider.acvalue,pp^.HSlider);
    p:=PointerFromShort(w);
    WinSendMsg(NIL,p,SBM_SETPOS,ScrollWin);
    ScrollWin:=WinWindowFromID(FID_VERTSCROLL,FrameWin);
    w:=CalcSliderfromValue(pp^.VSlider.acvalue,pp^.VSlider);
    p:=PointerFromShort(w);
    WinSendMsg(NIL,p,SBM_SETPOS,ScrollWin);
END;

PROCEDURE TEditorApplication.MDIRedraw(Win:HWND;_hps:HPS;Extra:POINTER);
VAR facename,s:string;
    rec:RECTL;
    pp:PEditor;
    Lines:LONGWORD;
    t:LongWord;
    pt:POINTL;
    ScrollX:LONGWORD;
    SelectLoLine,SelectHiLine:WORD;
    SelectLoColumn,SelectHiColumn:WORD;
    AcLine,AcColumn,help,TextViewX,Mul,Mul1:WORD;
Label l;
BEGIN
    WinShowCursor(0,Win);
    facename:='System VIO';
    CreateLogFont(_hps,facename,CharHeight,CharWidth); {default font}

    pp:=Extra;
    GpiSetBackMix(2,_hps); {BM_OverPaint}
    WinQueryWindowRect(rec,Win);
    Lines:=(rec.ytop-rec.ybottom) div CharHeight; {Lines to draw}
    pt.x:=2;
    pt.y:=rec.yTop-CharHeight;
    ScrollX:=pp^.HSlider.acvalue;

    SelectLoLine:=pp^.SelectLineStart;
    SelectHiLine:=pp^.SelectLineEnd;
    SelectLoColumn:=pp^.SelectColumnStart;
    SelectHiColumn:=pp^.SelectColumnEnd;
    AcLine:=pp^.VSlider.acvalue;
    AcColumn:=ScrollX+1;
    TextViewX:=pp^.TextViewX+1;

    IF SelectLoColumn<65535 THEN
    BEGIN
        IF SelectLoColumn>AcColumn THEN
        BEGIN
             Dec(SelectLoColumn,AcColumn);
             Mul:=CharWidth*SelectLoColumn;
        END
        ELSE SelectLoColumn:=0;
    END
    ELSE SelectLoColumn:=0;

    IF SelectHiColumn<65535 THEN
    BEGIN
        IF SelectHiColumn>AcColumn-1 THEN
        BEGIN
             Dec(SelectHiColumn,AcColumn-1);
             Mul1:=CharWidth*SelectHiColumn;
        END
        ELSE SelectHiColumn:=0;
    END
    ELSE SelectHiColumn:=0;

    GpiSetColor(TextDrawColor,_hps);
    GpiSetBackColor(TextBackColor,_hps);
    FOR t:=0 TO Lines-1 DO
    BEGIN
        help:=t+AcLine;
        IF ((help>=SelectLoLine)AND(Help<=SelectHiLine)) THEN
        BEGIN
             CASE Help OF
                SelectLoLine:
                BEGIN
                     IF SelectLoColumn>0 THEN
                     BEGIN
                          GpiCharStringAt(pp^.ScreenBuffer[t][AcColumn],
                                          SelectLoColumn,pt,_hps);
                          inc(pt.x,Mul);
                          GpiSetColor(SelectDrawColor,_hps);
                          GpiSetBackColor(SelectBackColor,_hps);
                          IF Help=SelectHiLine THEN
                          BEGIN
                               GpiCharStringAt(pp^.ScreenBuffer[t][AcColumn+
                                          SelectLoColumn],SelectHiColumn-
                                          SelectLoColumn,pt,_hps);
                               GpiSetColor(TextDrawColor,_hps);
                               GpiSetBackColor(TextBackColor,_hps);
                               inc(pt.x,mul1-mul);
                               GpiCharStringAt(pp^.ScreenBuffer[t][AcColumn+
                                          SelectLoColumn+
                                          (SelectHiColumn-SelectLoColumn)],
                                          TextViewX-SelectHiColumn,pt,_hps);
                               dec(pt.x,mul1-mul);
                          END
                          ELSE GpiCharStringAt(pp^.ScreenBuffer[t][AcColumn+
                                          SelectLoColumn],TextViewX-SelectLoColumn,
                                          pt,_hps);
                          dec(pt.x,Mul);
                     END
                     ELSE
                     BEGIN
l:
                          GpiSetColor(SelectDrawColor,_hps);
                          GpiSetBackColor(SelectBackColor,_hps);
                          GpiCharStringAt(pp^.ScreenBuffer[t][AcColumn],
                                          pp^.TextViewX+1,pt,_hps);
                     END;
                     GpiSetColor(TextDrawColor,_hps);
                     GpiSetBackColor(TextBackColor,_hps);
                END;
                SelectHiLine:
                BEGIN
                     IF SelectHiColumn>0 THEN
                     BEGIN
                          GpiSetColor(SelectDrawColor,_hps);
                          GpiSetBackColor(SelectBackColor,_hps);
                          GpiCharStringAt(pp^.ScreenBuffer[t][AcColumn],
                                          SelectHiColumn,pt,_hps);
                          inc(pt.x,Mul1);
                          GpiSetColor(TextDrawColor,_hps);
                          GpiSetBackColor(TextBackColor,_hps);
                          GpiCharStringAt(pp^.ScreenBuffer[t][AcColumn+
                                          SelectHiColumn],TextViewX-SelectHiColumn,
                                          pt,_hps);
                          dec(pt.x,Mul1);
                     END
                     ELSE goto l;
                END;
                ELSE
                BEGIN
                     GpiSetColor(SelectDrawColor,_hps);
                     GpiSetBackColor(SelectBackColor,_hps);
                     GpiCharStringAt(pp^.ScreenBuffer[t][AcColumn],
                                     pp^.TextViewX+1,pt,_hps);
                     GpiSetColor(TextDrawColor,_hps);
                     GpiSetBackColor(TextBackColor,_hps);
                END;
             END; {case}
        END
        ELSE GpiCharStringAt(pp^.ScreenBuffer[t][ScrollX+1],pp^.TextViewX+1,pt,_hps);
        dec(pt.y,CharHeight);
    END;
    WinShowCursor(1,Win);
    SetCursor(Win,pp);
END;

PROCEDURE TEditorApplication.CheckHScrollBar(Win:HWND;para1,para2,Extra:PEditor);
VAr w:Word;
    p,p1:POINTER;
    l:LONGWORD;
    ScrollWin,FrameWin:HWND;
    SliderID:LONGWORD;
    HSliderX:SliderData;
label lab;
BEGIN
     HSliderX:=Extra^.HSlider;

     l:=PointerToLong(para2);
     SliderID:=PointerToLong(para1);
     SliderID:=lo(SliderID);
     w:=hi(l);
     FrameWin:=WinQueryWindow(QW_PARENT,Win);
     ScrollWin:=WinWindowFromID(SliderID,FrameWin);
     CASE w OF
         SB_LINELEFT:
         BEGIN
              IF HSliderX.acvalue-1>HSliderX.scrollbottom THEN dec(HSliderX.acvalue)
              ELSE HSliderX.acvalue:=HSliderX.scrollbottom;
              goto lab;
         END;
         SB_LINERIGHT:
         BEGIN
              IF HSliderX.acvalue+1<HSliderX.scrolltop THEN inc(HSliderX.acvalue);
              {ELSE HSliderX.acvalue:=HSliderX.scrolltop;}
              goto lab;
         END;
         SB_PAGELEFT:
         BEGIN
              IF HSliderX.acvalue-HSliderX.viewarea>HSliderX.scrollbottom THEN
               dec(HSliderX.acvalue,HSliderX.viewarea)
              ELSE HSliderX.acvalue:=HSliderX.scrollbottom;
              goto lab;
         END;
         SB_PAGERIGHT:
         BEGIN
              IF HSliderX.acvalue+HSliderX.viewarea<HSliderX.scrolltop THEN
              inc(HSliderX.acvalue,HSliderX.viewarea)
              ELSE HSliderX.acvalue:=HSliderX.scrolltop;
lab:
              IF HSliderX.acValue+Extra^.CursorX>HSliderX.ScrollTop THEN
              BEGIN
                  Beep(1200,200);
                  HSliderX.acvalue:=HSliderX.ScrollTop-Extra^.CursorX;
              END;
              w:=HSliderX.acvalue; {CalcSliderfromValue(HSliderX.acvalue,HSliderX);}
              p:=PointerFromShort(w);
              WinSendMsg(NIL,p,SBM_SETPOS,ScrollWin);
         END;
         SB_SLIDERPOSITION:
         BEGIN
              w:=lo(l);
              HSliderX.acvalue:=CalcValuefromSlider(w,HSliderX);
              IF HSliderX.acValue+Extra^.CursorX>HSliderX.ScrollTop THEN
              BEGIN
                   Beep(1200,200);
                   HSliderX.acvalue:=HSliderX.ScrollTop-Extra^.CursorX;
                   w:=CalcSliderfromValue(HSliderX.acvalue,HSliderX);
                   p:=PointerFromShort(w);
                   WinSendMsg(NIL,p,SBM_SETPOS,ScrollWin);
              END;
         END;
         ELSE exit;
     END; {Case}
     Extra^.HSlider:=HSliderX;
END;


FUNCTION TEditorApplication.CheckIfToScrollX(Win:HWND;Extra:PEditor):BOOLEAN;
VAR ScrollX:LONGWORD;
    rec:RECTL;
BEGIN
     IF Extra^.CursorX>Extra^.TextViewX THEN
     BEGIN
          ScrollX:=Extra^.CursorX-Extra^.TextViewX;
          dec(Extra^.Cursorx,ScrollX);
          inc(Extra^.HSlider.acvalue,ScrollX);
          InvalidateEditorWindow(Win,Extra);
          CheckIfToScrollX:=TRUE;
     END
     ELSE CheckIfToScrollX:=FALSE;
END;


PROCEDURE TEditorApplication.MDIHandleCharEvent(Win:HWND;Extra:POINTER;ch:CHAR);
VAR s:string;
    x,y:LongWord;
    Extra1:PEditor;
label L;
BEGIN
     Extra1:=Extra;
     x:=Extra1^.CursorX+Extra1^.HSlider.acvalue;
     IF x>=Extra1^.HSlider.ScrollTop THEN
     BEGIN
l:
          beep(1200,200);
          exit;
     END;
     y:=Extra1^.CursorY-1;
     s:=Extra1^.ScreenBuffer[y];
     Extra1^.Modified:=TRUE;
     IF Extra1^.insertmode THEN s[x]:=ch
     ELSE
     BEGIN
          Insert(ch,s,x);
          IF Length(s)>126 THEN s[0]:=#126;
     END;
     inc(Extra1^.CursorX);
     Extra1^.ScreenBuffer[y]:=s;
     IF CheckIfToScrollX(Win,Extra1) THEN exit;
     InvalidateEditorLine(Win,s,y+1,Extra1);
END;

PROCEDURE TEditorApplication.PageUp(Win:HWND;Extra:PEditor);
VAR t,t1:WORD;
    TextView:WORD;
BEGIN
     IF Extra^.TextLow<=LONGWORD(Extra^.TextBuffer) THEN
     BEGIN
          Extra^.CursorY:=1;
          exit;
     END;
     IF Extra^.VSlider.acvalue=0 THEN
     BEGIN
          Extra^.CursorY:=1;
          exit;
     END;
     TextView:=Extra^.TextViewY-1;
     IF TextView>Extra^.VSlider.acvalue THEN
     BEGIN
          TextView:=Extra^.VSlider.acvalue;
          Extra^.CursorY:=1;
     END;
     FOR t:=EditorMaxLines DOWNTO (EditorMaxLines-TextView)+1 DO
        AppendUpperLine(Extra^.ScreenBuffer[t],Extra);
     t1:=EditorMaxLines-TextView;  {Lines to transmit}
     ASM
        MOVZXW ECX,$t1
        INC ECX
        SHL ECX,5         ;multiply with 128 and divide by 4

        MOV ESI,$Extra    ;Source buffer
        MOVZXW EAX,_EditormaxLines
        MOVZXW EBX,$TextView
        SUB EAX,EBX
        INC EAX
        SHL EAX,7         ;multiply with 128
        ADD ESI,EAX       ;Source

        MOV EDI,$Extra    ;Destination
        MOVZXW EAX,_EditorMaxLines
        INC EAX
        SHL EAX,7
        ADD EDI,EAX       ;Destination

        STD
        REP
        MOVSW             ;MOVSD
     END;
     FOR t:=TextView-1 DOWNTO 0 DO GetLowerLine(Extra^.ScreenBuffer[t],Extra);
     Dec(Extra^.VSlider.acvalue,TextView);
END;

PROCEDURE TEditorApplication.LineUp(Win:HWND;Extra:PEditor);
VAR t:WORD;
BEGIN
     IF Extra^.CursorY=1 THEN
     BEGIN
          IF Extra^.VSlider.acvalue=0 THEN exit;
          IF Extra^.TextLow<=LONGWORD(Extra^.TextBuffer) THEN
          BEGIN
               Extra^.VSlider.Acvalue:=0;
               exit;
          END;
          dec(Extra^.VSlider.acvalue);
          AppendUpperLine(Extra^.ScreenBuffer[EditorMaxLines],Extra);
          ASM
             MOVZXW ECX,_EditorMaxLines
             SHL ECX,5         ;multiply with 128 and divide by 4

             MOV ESI,$Extra    ;Source
             MOVZXW EAX,_EditorMaxLines
             INC EAX
             SHL EAX,7
             ADD ESI,EAX
             MOV EDI,ESI       ;Destination
             SUB ESI,128       ;Source

             STD
             REP
             MOVSW             ;MOVSD
          END;
          GetLowerLine(Extra^.ScreenBuffer[0],Extra);
     END
     ELSE dec(Extra^.CursorY);
END;

PROCEDURE TEditorApplication.LineDown(Win:HWND;Extra:PEditor);
VAR t:Word;
label l;
BEGIN
     IF Extra^.TextHigh>=LONGWORD(Extra^.TextBuffer)+Extra^.TextLen THEN
     BEGIN
          {No more lines in memory}
          FOR t:=Extra^.CursorY TO EditorMaxLines DO
            IF length(Extra^.ScreenBuffer[t])<>0 THEN goto l;
          exit;
     END;
l:
     inc(Extra ^.CursorY);
     IF Extra^.CursorY>Extra^.TextViewY THEN
     BEGIN
          Extra^.CursorY:=Extra^.TextViewY;
          inc(Extra^.VSlider.acvalue);
          AppendLowerLine(Extra^.ScreenBuffer[0],Extra);
          ASM
             MOVZXW ECX,_EditorMaxLines
             SHL ECX,5         ;multiply with 128 and divide by 4

             MOV EDI,$Extra    ;Destination
             ADD EDI,4
             MOV ESI,EDI       ;Source
             ADD ESI,128

             CLD
             REP
             MOVSW             ;MOVSD
          END;
          GetUpperLine(Extra^.ScreenBuffer[EditorMaxLines],Extra);
     END;
END;

PROCEDURE TEditorApplication.PageDown(Win:HWND;Extra:PEditor);
VAR
    Count:WORD;
    TextView:WORD;
    t,t1:WORD;
BEGIN
     IF Extra^.TextHigh>=LONGWORD(Extra^.TextBuffer)+Extra^.TextLen THEN exit;
     TextView:=Extra^.TextViewY-1;
     FOR t:=0 TO TextView-1 DO AppendLowerLine(Extra^.ScreenBuffer[t],Extra);
     t1:=(EditorMaxLines-TextView)+1;  {Lines to transmit}
     ASM
        MOVZXW ECX,$t1
        SHL ECX,5         ;multiply with 128 and divide by 4
        MOV ESI,$Extra    ;Source buffer
        ADD ESI,4
        MOVZXW EAX,$TextView
        SHL EAX,7         ;multiply with 128
        ADD ESI,EAX       ;onto ScreenBuffer[TextView]
        MOV EDI,$Extra
        ADD EDI,4         ;onto ScreenBuffer[0]
        CLD
        REP
        MOVSW             ;MOVSD
     END;
     FOR t:=t1 TO EditorMaxLines DO GetUpperLine(Extra^.ScreenBuffer[t],Extra);
     Inc(Extra^.VSlider.acvalue,TextView);
END;

PROCEDURE TEditorApplication.CheckVScrollBar(Win:HWND;para1,para2,Extra:PEditor);
VAr w:Word;
    p,p1:POINTER;
    l,r:LONGWORD;
    ScrollWin,FrameWin:HWND;
    SliderID:LONGWORD;
    t:WORD;
    t1:LONGWORD;
    acval:LONGWORD;
    aclineval:LONGWORD;
    acpageval:LONGWORD;
BEGIN
     l:=PointerToLong(para2);
     SliderID:=PointerToLong(para1);
     SliderID:=lo(SliderID);
     w:=hi(l);
     FrameWin:=WinQueryWindow(QW_PARENT,Win);
     ScrollWin:=WinWindowFromID(SliderID,FrameWin);
     CASE w OF
         SB_LINEUP:
         BEGIN
              Extra^.CursorY:=1;
              LineUp(Win,Extra);
              w:=CalcSliderfromValue(Extra^.VSlider.acvalue,Extra^.VSlider);
              p:=PointerFromShort(w);
              WinSendMsg(NIL,p,SBM_SETPOS,ScrollWin);
         END;
         SB_LINEDOWN:
         BEGIN
              Extra^.CursorY:=Extra^.TextViewY;
              LineDown(Win,Extra);
              w:=CalcSliderfromValue(Extra^.VSlider.acvalue,Extra^.VSlider);
              p:=PointerFromShort(w);
              WinSendMsg(NIL,p,SBM_SETPOS,ScrollWin);
         END;
         SB_PAGEUP:
         BEGIN
              PageUp(Win,Extra);
              w:=CalcSliderfromValue(Extra^.VSlider.acvalue,Extra^.VSlider);
              p:=PointerFromShort(w);
              WinSendMsg(NIL,p,SBM_SETPOS,ScrollWin);
         END;
         SB_PAGEDOWN:
         BEGIN
              PageDown(Win,Extra);
              w:=CalcSliderfromValue(Extra^.VSlider.acvalue,Extra^.VSlider);
              p:=PointerFromShort(w);
              WinSendMsg(NIL,p,SBM_SETPOS,ScrollWin);
         END;
         SB_SLIDERPOSITION:
         BEGIN
              w:=lo(l);
              acval:=CalcValuefromSlider(w,Extra^.VSlider);
              IF acval=Extra^.VSlider.acvalue THEN exit;
              IF acval>Extra^.VSlider.acvalue THEN
              BEGIN
                   r:=(acval-Extra^.VSlider.acvalue)+Extra^.TextViewY;
                   acpageval:=r div Extra^.TextViewY;
                   aclineval:=r mod Extra^.TextViewY;
                   FOR t1:=1 TO acpageval DO PageDown(Win,Extra);
                   FOR t1:=1 TO aclineval DO LineDown(Win,Extra);
              END
              ELSE
              BEGIN
                   r:=(Extra^.VSlider.acvalue-acval)+Extra^.TextViewY;
                   acpageval:=r div Extra^.TextViewY;
                   aclineval:=r mod Extra^.TextViewY;
                   FOR t1:=1 TO acpageval DO PageUp(Win,Extra);
                   FOR t1:=1 TO aclineval DO LineUp(Win,Extra);
              END;
         END;
     END; {Case}
END;

PROCEDURE TEditorApplication.MDICreateNotify(Win:HWND;Extra:POINTER);
VAR
    ww,ww1:Word;
    p:POINTER;
    p1:POINTER;
    FrameWin,ScrollWin:HWND;
    pp:PEditor;
    rec:RECTL;
    Lines:LONGWORD;
BEGIN
     inherited.MDICreateNotify(Win,Extra);
     pp:=Extra;

     WinQueryWindowrect(rec,Win);

     {init horizontal ScrollWindow}
     Lines:=(rec.XRight-rec.XLeft) div CharWidth;
     pp^.TextViewX:=Lines;
     FrameWin:=WinQueryWindow(QW_PARENT,Win);
     ScrollWin:=WinWindowFromID(FID_HORZSCROLL,FrameWin);
     pp^.HSlider.scrollbottom:=0;
     pp^.HSlider.scrolltop:=127;
     pp^.HSlider.viewarea:=Lines;
     {define Scroll intervall}
     ww1:=1;
     ww:=CalcMaxSliderPositions(pp^.HSlider);
     p:=PointerFrom2Short(ww,ww1);
     WinSendMsg(p,LongToPointer(1),SBM_SETSCROLLBAR,ScrollWin);
     pp^.HSlider.acvalue:=pp^.HSlider.scrollbottom;
     {Set slider size}
     ww1:=pp^.HSlider.viewarea;
     ww:=pp^.HSlider.scrolltop-pp^.HSlider.scrollbottom+1;
     p:=PointerFrom2Short(ww,ww1);
     WinSendmsg(NIL,p,SBM_SETTHUMBSIZE,ScrollWin);

     {init vertical ScrollWindow}
     ScrollWin:=WinWindowFromID(FID_VERTSCROLL,FrameWin);
     Lines:=(rec.yTop-rec.yBottom) div CharHeight;
     pp^.TextViewY:=Lines;
     pp^.VSlider.scrollbottom:=0;
     pp^.VSlider.scrolltop:=pp^.TextLines;
     pp^.VSlider.viewarea:=Lines;
     {define Scroll intervall}
     ww1:=1;
     ww:=CalcMaxSliderPositions(pp^.VSlider);
     p:=PointerFrom2Short(ww,ww1);
     WinSendMsg(p,LongToPointer(1),SBM_SETSCROLLBAR,ScrollWin);
     pp^.VSlider.acvalue:=pp^.VSlider.scrollbottom;
     {Set slider size}
     ww1:=pp^.VSlider.viewarea;
     ww:=pp^.VSlider.scrolltop-pp^.VSlider.scrollbottom+1;
     p:=PointerFrom2Short(ww,ww1);
     WinSendmsg(NIL,p,SBM_SETTHUMBSIZE,ScrollWin);
END;

PROCEDURE TEditorApplication.InvalidateEditorLine(Win:HWND;var s:string;
                                                  y:LONGWORD;Extra:PEditor);
VAR _hps:LONGWORD;
    rec:RECTL;
    pt:POINTL;
    facename:String;
    scrollX:LONGWORD;
BEGIN
     WinShowCursor(0,Win);
     _hps:=WinGetPS(Win);
     WinQueryWindowRect(rec,Win);
     facename:='System VIO';
     CreateLogFont(_hps,facename,CharHeight,CharWidth); {default font}
     pt.x:=2;
     pt.y:=rec.yTop-y*CharHeight;
     scrollX:=Extra^.HSlider.acvalue;
     GpiSetBackMix(2,_hps);  {BM_OverPaint}
     GpiSetColor(TextDrawColor,_hps);
     GpiSetBackColor(TextBackColor,_hps);
     GpiCharStringAt(s[Scrollx+1],Extra^.TextViewX+1,pt,_hps);
     WinReleasePS(_hps);
     WinShowCursor(1,Win);
     SetCursor(Win,Extra);
END;

PROCEDURE TEditorApplication.InvalidateEditorWindow(Win:HWND;Extra:PEditor);
VAR _hps:LONGWORD;
BEGIN
     _hps:=WinGetPS(Win);
     MDIRedraw(Win,_hps,Extra);
     WinReleasePs(_hps);
END;



PROCEDURE TEditorApplication.MDIHandleScanEvent(Win:HWND;Extra:POINTER;scan:Word);
VAR hsp:LONGWORD;
    r:LongWord;
    x,y:LONGWORD;
    s,s1:string;
    t,t1:WORD;
    ScrollWin,FrameWin:HWND;
    p:POINTER;
    ww,ww1:WORD;
    rc:RECTL;
    Extra1:PEditor;
BEGIN
     Extra1:=Extra;
     CASE Scan OF
         kbCtrlY:
         BEGIN
              Extra1^.Modified:=TRUE;
              FOR t:=Extra1^.CursorY-1 TO EditorMaxLines-1 DO
                Extra1^.ScreenBuffer[t]:=Extra1^.ScreenBuffer[t+1];
              IF GetUpperLine(Extra1^.ScreenBuffer[EditorMaxLines],Extra1)
               THEN Dec(Extra1^.TextLines);
              InvalidateEditorWindow(Win,Extra1);
         END;
         kbCDown:
         BEGIN
              IF Extra1^.CursorY=Extra1^.TextViewY THEN
              BEGIN
                   LineDown(Win,Extra1);
                   InvalidateEditorWindow(Win,Extra);
                   exit;
              END
              ELSE LineDown(Win,Extra1);
         END;
         kbCUp:
         BEGIN
              IF Extra1^.CursorY=1 THEN
              BEGIN
                   IF Extra1^.VSlider.acvalue=0 THEN exit;
                   LineUp(Win,Extra1);
                   InvalidateEditorWindow(Win,Extra1);
                   exit;
              END
              ELSE LineUp(Win,Extra1);
         END;
         kbCR:
         BEGIN
              IF Extra1^.InsertMode THEN
              BEGIN
                   Extra1^.CursorX:=1;
                   Extra1^.HSlider.acvalue:=0;
                   IF Extra1^.CursorY=Extra1^.TextViewY THEN
                   BEGIN
                        LineDown(Win,Extra1);
                        InvalidateEditorWindow(Win,Extra);
                        exit;
                   END
                   ELSE LineDown(Win,Extra1);
              END
              ELSE
              BEGIN
                   Extra1^.Modified:=TRUE;
                   s:=Extra1^.ScreenBuffer[Extra1^.CursorY-1];
                   x:=Extra1^.CursorX+Extra1^.HSlider.acvalue;
                   s1:=copy(s,1,x-1);
                   WHILE Length(s1)<126 DO s1:=s1+' ';
                   Extra1^.ScreenBuffer[Extra1^.CursorY-1]:=s1;
                   delete(s,1,x-1);
                   WHILE Length(s)<126 DO s:=s+' ';
                   inc(Extra1^.CursorY);
                   Extra1^.CursorX:=1;
                   Extra1^.HSlider.acvalue:=0;
                   inc(Extra1^.TextLines);

                   {init vertical ScrollWindow}
                   WinQueryWindowrect(rc,Win);
                   FrameWin:=WinQueryWindow(QW_PARENT,Win);
                   ScrollWin:=WinWindowFromID(FID_VERTSCROLL,FrameWin);
                   r:=(rc.yTop-rc.yBottom) div CharHeight;
                   Extra1^.TextViewY:=r;
                   Extra1^.VSlider.scrollbottom:=0;
                   Extra1^.VSlider.scrolltop:=Extra1^.TextLines;
                   Extra1^.VSlider.viewarea:=r;
                   {define Scroll intervall}
                   ww1:=1;
                   ww:=CalcMaxSliderPositions(Extra1^.VSlider);
                   p:=PointerFrom2Short(ww,ww1);
                   WinSendMsg(p,LongToPointer(1),SBM_SETSCROLLBAR,ScrollWin);
                   {Set slider size}
                   ww1:=Extra1^.VSlider.viewarea;
                   ww:=Extra1^.VSlider.scrolltop-Extra1^.VSlider.scrollbottom+1;
                   p:=PointerFrom2Short(ww,ww1);
                   WinSendmsg(NIL,p,SBM_SETTHUMBSIZE,ScrollWin);

                   AppendUpperLine(Extra1^.ScreenBuffer[EditorMaxLines],Extra1);
                   FOR t:=EditorMaxLines DOWNTO Extra1^.CursorY DO
                    Extra1^.ScreenBuffer[t]:=Extra1^.ScreenBuffer[t-1];
                   Extra1^.ScreenBuffer[Extra1^.CursorY-1]:=s;
                   Dec(Extra1^.CursorY);
                   LineDown(Win,Extra1);
                   InvalidateEditorWindow(Win,Extra);
              END;
         END;
         kbPageDown:
         BEGIN
              IF Extra1^.TextHigh>=LONGWORD(Extra1^.TextBuffer)+Extra1^.TextLen THEN exit;
              PageDown(Win,Extra1);
              InvalidateEditorWindow(Win,Extra1);
              exit;
         END;
         kbPageUp:
         BEGIN
              IF Extra1^.TextLow<=LONGWORD(Extra1^.TextBuffer) THEN exit;
              PageUp(Win,Extra1);
              InvalidateEditorWindow(Win,Extra1);
              exit;
         END;
         kbCRight:
         BEGIN
              x:=Extra1^.CursorX+Extra1^.HSlider.acvalue;
              IF x>=Extra1^.HSlider.ScrollTop THEN exit;
              inc(Extra1^.CursorX);
              IF CheckIfToScrollX(Win,Extra1) THEN exit;
         END;
         kbCLeft:
         BEGIN
              IF Extra1^.CursorX=1 THEN
              BEGIN
                   IF Extra1^.HSlider.acvalue=0 THEN exit;
                   dec(Extra1^.HSlider.acvalue);
                   InvalidateEditorWindow(Win,Extra1);
                   exit;
              END
              ELSE dec(Extra1^.CursorX);
         END;
         kbPos1:
         BEGIN
              Extra1^.CursorX:=1;
              r:=Extra1^.HSlider.acvalue;
              Extra1^.HSlider.acvalue:=0;
              if r<>0 THEN
              BEGIN
                   InvalidateEditorWindow(Win,Extra1);
                   exit;
              END;
         END;
         kbEnd:
         BEGIN
              x:=Extra1^.CursorY-1;
              s:=Extra1^.ScreenBuffer[x];
              while s[length(s)]=#32 do dec(s[0]);
              Extra1^.CursorX:=length(s)+1;
              Extra1^.HSlider.acvalue:=0;
              IF CheckIfToScrollX(Win,Extra1) THEN exit;
         END;
         kbDel:
         BEGIN
              Extra1^.Modified:=TRUE;
              y:=Extra1^.CursorY-1;
              s:=Extra1^.ScreenBuffer[y];
              x:=Extra1^.CursorX+Extra1^.HSlider.acvalue;
              t1:=0;
              for t:=length(s) downto x do if s[t]<>#32 then t1:=t;
              if t1<x then
              begin
                   while s[length(s)]=#32 do dec(s[0]);
                   s1:=Extra1^.ScreenBuffer[y+1];
                   while s1[length(s1)]=#32 do dec(s1[0]);
                   if length(s)+length(s1)>126 then s1[0]:=chr(126-length(s));
                   s:=s+s1;
                   while length(s)<126 do s:=s+' ';
                   Extra1^.ScreenBuffer[y]:=s;
                   FOR t:=y+1 TO EditorMaxLines-1 DO
                     Extra1^.ScreenBuffer[t]:=Extra1^.ScreenBuffer[t+1];
                   IF GetUpperLine(Extra1^.ScreenBuffer[EditorMaxLines],Extra1)
                    THEN Dec(Extra1^.TextLines);
                   InvalidateEditorWindow(Win,Extra1);
              end
              else
              begin
                   delete(s,x,1);
                   s:=s+' ';
                   Extra1^.ScreenBuffer[y]:=s;
                   InvalidateEditorLine(Win,s,y+1,Extra1);
              end;
              exit;
         END;
         kbBS:
         BEGIN
              Extra1^.Modified:=TRUE;
              y:=Extra1^.CursorY-1;
              x:=Extra1^.CursorX+Extra1^.HSlider.acvalue;
              s:=Extra1^.ScreenBuffer[y];
              IF length(s)>=x-1 THEN IF x<>1 THEN delete(s,x-1,1);
              Extra1^.ScreenBuffer[y]:=s;
              while s[length(s)]=#32 do dec(s[0]);
              IF Extra1^.CursorX=1 THEN
              BEGIN
                   IF Extra1^.HSlider.acvalue=0 THEN exit;
                   dec(Extra1^.HSlider.acvalue);
                   InvalidateEditorWindow(Win,Extra1);
                   exit;
              END
              ELSE
              BEGIN
                   dec(Extra1^.CursorX);
                   InvalidateEditorLine(Win,s,y+1,Extra1);
                   exit;
              END;
         END;
         kbInsert:
         BEGIN
              Extra1^.InsertMode:=not(Extra1^.InsertMode);
              IF Extra1^.InsertMode THEN r:=CharHeight
              ELSE r:=2;
              ASM
                  ;Destroy the cursor
                  PUSHL $Win
                  MOV AL,1
                  CALLDLL PMWIN,725  ;WinDestroyCursor
                  ADD ESP,4

                  ;Create the cursor
                  PUSHL 0  ;whole window
                  PUSHL 4  ;CURSOR_SOLID | CURSOR_FLASH
                  PUSHL $r ;Cursorheigth
                  PUSHL _CharWidth
                  PUSHL 40
                  PUSHL 40
                  PUSHL $Win
                  MOV AL,7
                  CALLDLL PMWIN,715  ;WinCreateCursor
                  ADD ESP,28
              END;
              WinShowCursor(1,Win);
         END;
         ELSE exit;
     END; {CASE}
     SetCursor(Win,Extra1);
END;


FUNCTION TEditorApplication.MDIHandleEvent(Win:HWND;Msg:LONGWORD;para1,
                      para2:POINTER;VAR Handled:BOOLEAN;
                      Extra:POINTER):LONGWORD;
VAR r:LONGWORD;
    rc:RECTL;
    H:BOOLEAN;
    w:WORD;
    ch:CHAR;
    b:Byte;
    pp:PEditor;
    FrameWin,ScrollWin:HWND;
    ww,ww1:WORD;
    p:POINTER;
    po:points;
    lx,ly,wx,wy:Integer;
Label l,ll,ll1;
BEGIN
     H:=TRUE;
     r:=0;
     CASE MSG OF
          WM_SIZE:
          BEGIN
               pp:=Extra;
               WinQueryWindowrect(rc,Win);

               {init horizontal ScrollWindow}
               r:=(rc.XRight-rc.XLeft) div CharWidth;
               pp^.TextViewX:=r;
               FrameWin:=WinQueryWindow(QW_PARENT,Win);
               ScrollWin:=WinWindowFromID(FID_HORZSCROLL,FrameWin);
               pp^.HSlider.scrollbottom:=0;
               pp^.HSlider.scrolltop:=127;
               pp^.HSlider.viewarea:=r;
               {define Scroll intervall}
               ww1:=1;
               ww:=CalcMaxSliderPositions(pp^.HSlider);
               p:=PointerFrom2Short(ww,ww1);
               WinSendMsg(p,LongToPointer(1),SBM_SETSCROLLBAR,ScrollWin);
               {Set slider size}
               ww1:=pp^.HSlider.viewarea;
               ww:=pp^.HSlider.scrolltop-pp^.HSlider.scrollbottom+1;
               p:=PointerFrom2Short(ww,ww1);
               WinSendmsg(NIL,p,SBM_SETTHUMBSIZE,ScrollWin);

               {init vertical ScrollWindow}
               ScrollWin:=WinWindowFromID(FID_VERTSCROLL,FrameWin);
               r:=(rc.yTop-rc.yBottom) div CharHeight;
               pp^.textViewY:=r;
               pp^.VSlider.scrollbottom:=0;
               pp^.VSlider.scrolltop:=pp^.TextLines;
               pp^.VSlider.viewarea:=r;
               {define Scroll intervall}
               ww1:=1;
               ww:=CalcMaxSliderPositions(pp^.VSlider);
               p:=PointerFrom2Short(ww,ww1);
               WinSendMsg(p,LongToPointer(1),SBM_SETSCROLLBAR,ScrollWin);
               {Set slider size}
               ww1:=pp^.VSlider.viewarea;
               ww:=pp^.VSlider.scrolltop-pp^.VSlider.scrollbottom+1;
               p:=PointerFrom2Short(ww,ww1);
               WinSendmsg(NIL,p,SBM_SETTHUMBSIZE,ScrollWin);

               IF not Handled THEN H:=FALSE;
          END;
          WM_DESTROY:
          BEGIN
               DestroyEditor(Extra);
               IF not Handled THEN H:=FALSE;
          END;
          WM_HSCROLL:CheckHScrollBar(Win,para1,para2,Extra);
          WM_VSCROLL:CheckVScrollBar(Win,para1,para2,Extra);
          WM_SETFOCUS:  {EingabeFocus neu setzen}
          BEGIN
               pp:=Extra;
               IF pp^.InsertMode THEN r:=CharHeight
               ELSE r:=2;
               ASM
                  MOV EAX,$Para2
                  CMP EAX,0
                  JE !dc      ;Window is loosing focus

                  ;Window becomes focus --> Create the cursor
                  PUSHL 0  ;whole window
                  PUSHL 4  ;CURSOR_SOLID | CURSOR_FLASH
                  PUSHL $r ;Cursorheigth
                  PUSHL _CharWidth
                  PUSHL 40
                  PUSHL 40
                  PUSHL $Win
                  MOV AL,7
                  CALLDLL PMWIN,715  ;WinCreateCursor
                  ADD ESP,28
               END;
               WinShowCursor(1,Win);
               SetCursor(Win,Extra);
               InvalidateWindow(Win);
               goto l;

               ASM
!dc:
                  ;Window is loosing focus --> Destroy the cursor
                  PUSHL $Win
                  MOV AL,1
                  CALLDLL PMWIN,725  ;WinDestroyCursor
                  ADD ESP,4
               END;
l:
          END;
          WM_BUTTON1Down,WM_BUTTON1Click:
          BEGIN
               po:=Points(Para1);
               lx:=po.x DIV CharWidth;
               ly:=po.y DIV CharHeight;
               WinQueryWindowrect(rc,Win);
               wx:=(rc.xright-rc.xleft) DIV CharWidth;
               wy:=(rc.ytop-rc.ybottom) DIV CharHeight;
               inc(lx);
               if lx>wx then lx:=wx;
               ly:=wy-ly;
               if ly<1 then ly:=1;
               pp:=Extra;
               pp^.SelectColumnStart:=65535;
               pp^.SelectLineStart:=65535;
               pp^.SelectColumnEnd:=65535;
               pp^.SelectLineEnd:=65535;
               IF lx=pp^.CursorX THEN IF ly=pp^.Cursory THEN goto ll;
               pp^.CursorX:=lx;
               pp^.CursorY:=ly;
               SetCursor(Win,pp);
               InvalidateEditorWindow(Win,pp)
ll:
               IF not Handled THEN H:=FALSE;
          END;
          WM_BUTTON2Click:MessageBox('Right mouse button clicked');
          WM_MOUSEDRAG1:
          BEGIN
               po:=Points(Para1);
               lx:=po.x DIV CharWidth;
               ly:=po.y DIV CharHeight;
               WinQueryWindowrect(rc,Win);
               wx:=(rc.xright-rc.xleft) DIV CharWidth;
               wy:=(rc.ytop-rc.ybottom) DIV CharHeight;
               inc(lx);
               if lx>wx then lx:=wx;
               ly:=wy-ly;
               if ly<1 then ly:=1;
               pp:=Extra;
               IF lx=pp^.CursorX THEN IF ly=pp^.Cursory THEN
                 IF ly<pp^.TextViewY-1 THEN IF ly>1 THEN goto ll1;
               pp^.CursorX:=lx;
               pp^.CursorY:=ly;
               SetCursor(Win,pp);

               ww:=pp^.HSlider.acvalue+pp^.CursorX-1;
               ww1:=pp^.vSlider.acvalue+pp^.CursorY-1;

               IF pp^.SelectLineStart=65535 THEN
               BEGIN
                    pp^.SelectLineStart:=ww1;
                    pp^.SelectAnchorLine:=ww1;
               END;

               IF ww1>=pp^.SelectAnchorLine THEN
               BEGIN
                    pp^.SelectLineEnd:=ww1;
                    pp^.SelectLineStart:=pp^.SelectAnchorLine;
               END;
               ELSE
               BEGIN
                    pp^.SelectLineStart:=ww1;
                    pp^.SelectLineEnd:=pp^.SelectAnchorLine;
               END;

               IF pp^.SelectColumnStart=65535 THEN
               BEGIN
                    pp^.SelectColumnStart:=ww;
                    pp^.SelectAnchorColumn:=ww;
               END;

               IF ww1=pp^.SelectLineStart THEN
               BEGIN
                    IF ww>=pp^.SelectAnchorColumn THEN
                    BEGIN
                        IF ww1=pp^.SelectLineEnd THEN pp^.SelectColumnEnd:=ww;
                        pp^.SelectColumnStart:=pp^.SelectAnchorColumn;
                    END;
                    ELSE
                    BEGIN
                        pp^.SelectColumnStart:=ww;
                        IF ww1=pp^.SelectLineEnd THEN pp^.SelectColumnEnd:=
                               pp^.SelectAnchorColumn;
                    END;
               END;

               IF ww1=pp^.SelectLineEnd THEN IF ww1<>pp^.SelectLineStart THEN
                   pp^.SelectColumnEnd:=ww;

               dec(ww1,pp^.VSlider.AcValue);

               IF ww1=pp^.TextViewY-1 THEN
               BEGIN
                    LineDown(Win,pp);
                    LastDragPos:=para1;
                    DragWindow:=Win;
                    Drag_Mode:=TRUE;
               END
               ELSE
               BEGIN
                    IF ww1=0 THEN
                    BEGIN
                         LineUp(Win,pp);
                         LastDragPos:=para1;
                         DragWindow:=Win;
                         Drag_Mode:=TRUE;
                    END
                    ELSE Drag_Mode:=FALSE;
               END;
               InvalidateEditorWindow(Win,pp);
ll1:
               IF not Handled THEN H:=FALSE;
          END;
          ELSE IF not Handled THEN H:=FALSE;
     END; {Case}
     Handled:=H;
     r:=Inherited.MDIHandleEvent(Win,Msg,para1,para2,Handled,Extra);
     MDIHandleEvent:=r;
END;

BEGIN
END.