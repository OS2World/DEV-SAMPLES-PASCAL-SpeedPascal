PROGRAM test;
{ $m 16384,0,0}

USES pmobject,pmDialog,pmeditor,pmdos;

RESOURCE Speed;

CONST
     CM_COMPOPT     =200;  {Compiler options}
     CM_MEMSIZES    =201;  {Memory sizes}
     CM_LINKOPT     =202;  {Linker options}
     CM_DIRECTORIES =203;  {Directories}
     CM_PREFERENCES =204;  {Environment/Preferences}
     CM_EDOPT       =205;  {Editor options}
     CM_FIND        =206;  {Find}
     CM_REPLACE     =207;  {Replace}
     CM_GOTO        =208;  {Goto}
     CM_PARAMETER   =209;  {Proghram parameter}
     CM_PRJ         =210;  {Project control}

TYPE TMyApp=OBJECT(TEditorApplication)
                 CONSTRUCTOR Init(AppMainID:LONGWORD);
                 DESTRUCTOR Done;
                 FUNCTION AppHandleEvent(Win:HWND;Msg:LONGWORD;
                                         para1,para2:POINTER;
                                         VAR Handled:BOOLEAN):LONGWORD:
                                         VIRTUAL;
                 PROCEDURE AppCreateNotify(AppWin:HWND):VIRTUAL;
            END;

VAR
    MyApp:TMyApp;

PROCEDURE About;
VAR Dlg:TDialog;
BEGIN
     Dlg.Init(1,AppWinFrameHandle,0,1004,NIL);
     Dlg.ExecDialog;
     Dlg.Done;
END;

PROCEDURE CompOptDialog;
VAR CompOptDlg:TDialog;
BEGIN
     CompOptDlg.Init(1,AppWinFrameHandle,0,1005,NIL);
     CompOptDlg.ExecDialog;
     CompOptDlg.Done;
END;

PROCEDURE EdOptDialog;
VAR EdOptDlg:TDialog;
BEGIN
     EdOptDlg.Init(1,AppWinFrameHandle,0,1010,NIL);
     EdOptDlg.ExecDialog;
     EdOptDlg.Done;
END;

PROCEDURE LinkOptDialog;
VAR LinkOptDlg:TDialog;
BEGIN
     LinkOptDlg.Init(1,AppWinFrameHandle,0,1007,NIL);
     LinkOptDlg.ExecDialog;
     LinkOptDlg.Done;
END;

PROCEDURE DirDialog;
VAR DirDlg:TDialog;
BEGIN
     DirDlg.Init(1,AppWinFrameHandle,0,1008,NIL);
     DirDlg.ExecDialog;
     DirDlg.Done;
END;

PROCEDURE ProjectDialog;
VAR PrjDlg:TDialog;
BEGIN
     PrjDlg.Init(1,AppWinFrameHandle,0,1015,NIL);
     PrjDlg.ExecDialog;
     PrjDlg.Done;
END;

PROCEDURE FindDialog;
VAR FindDlg:TDialog;
BEGIN
     FindDlg.Init(1,AppWinFrameHandle,0,1011,NIL);
     FindDlg.ExecDialog;
     FindDlg.Done;
END;

PROCEDURE ReplaceDialog;
VAR ReplDlg:TDialog;
BEGIN
     ReplDlg.Init(1,AppWinFrameHandle,0,1012,NIL);
     ReplDlg.ExecDialog;
     ReplDlg.Done;
END;

PROCEDURE GotoDialog;
VAR GotoDlg:TDialog;
BEGIN
     GotoDlg.Init(1,AppWinFrameHandle,0,1013,NIL);
     GotoDlg.ExecDialog;
     GotoDlg.Done;
END;


PROCEDURE PreferencesDialog;
VAR PrefDlg:TDialog;
BEGIN
     PrefDlg.Init(1,AppWinFrameHandle,0,1009,NIL);
     PrefDlg.ExecDialog;
     PrefDlg.Done;
END;

PROCEDURE ParameterDialog;
VAR ParaDlg:TDialog;
BEGIN
     ParaDlg.Init(1,AppWinFrameHandle,0,1014,NIL);
     ParaDlg.ExecDialog;
     ParaDlg.Done;
END;

PROCEDURE MemorySizes;
VAR MemSizesDlg:TDialog;
BEGIN
     MemSizesDlg.Init(1,AppWinFrameHandle,0,1006,NIL);
     MemSizesDlg.ExecDialog;
     memSizesDlg.Done;
END;

FUNCTION TMyApp.AppHandleEvent(Win:HWND;Msg:LONGWORD;
                               para1,para2:POINTER;
                               VAR Handled:BOOLEAN):LONGWORD;
VAR command:WORD;
    result:LONGWORD;
    H:Boolean;
    s:string;
BEGIN
     result:=Inherited.AppHandleEvent(Win,Msg,para1,para2,Handled);
     H:=TRUE;
     CASE Msg OF
          WM_COMMAND:
          BEGIN
               command:=PointerToWord(para1);
               CASE command OF
                  CM_ABOUT:About;
                  CM_NEW:OpenNewFile;
                  CM_OPEN:IF FileOpenDialog(AppWinHandle,s) THEN OpenFile(s);
                  CM_SAVEAS:SaveFileAs;
                  CM_SAVE:SaveFile;
                  CM_SAVEALL:SaveAllFiles;
                  CM_COMPOPT:CompOptDialog;
                  CM_MEMSIZES:MemorySizes;
                  CM_LINKOPT:LinkOptDialog;
                  CM_DIRECTORIES:DirDialog;
                  CM_PREFERENCES:PreferencesDialog;
                  CM_EDOPT:EdOptDialog;
                  CM_FIND:FindDialog;
                  CM_REPLACE:ReplaceDialog;
                  CM_GOTO:GotoDialog;
                  CM_PARAMETER:ParameterDialog;
                  CM_PRJ:ProjectDialog;
                  ELSE IF not Handled THEN H:=FALSE;
               END;
          END;
          ELSE IF not Handled THEN H:=FALSE;
      END; {case}
      AppHandleEvent:=result;
      Handled:=H;
END;

PROCEDURE TMyApp.AppCreateNotify(AppWin:HWND);
BEGIN
     MaximizeWindow(AppWin);
     About;
END;

CONSTRUCTOR TMyApp.Init(AppMainID:LONGWORD);
BEGIN
     Inherited.Init(AppMainID);
     StdExt:='.PAS';
     FileOpenDlgWildCards:='*.PAS';
     FilesaveDlgWildCards:='*.PAS';
     InsertMenuResource;  {Application has menus}
     InsertIconResource;  {Application has a program icon}
     InsertAccelResource; {Application has an accelerator table}
     InsertHelp('SPEED.HLP','Speed-386 Online Help');
END;

DESTRUCTOR TMyApp.Done;
BEGIN
END;

BEGIN
     MyApp.Init(1000);
     MyApp.Run('Speed-386 PASCAL V1.0 for OS/2 ',0,0);
     MyApp.Done;
END.