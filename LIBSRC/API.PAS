UNIT API;


{****************************************************************************
*                                                                           *
*                                                                           *
*                     Speed-386 Compiler fÅr OS/2 V 1.0                     *
*                                                                           *
*                      Basic API functions fÅr OS/2 2.1                     *
*                                                                           *
*                                                                           *
*  Dieses File enthÑlz die Deklaration von wichtigen OS/2 API's aus den     *
*  entsprechenden OS/2 DLL's.                                               *
*                                                                           *
*  Die Angaben sind nicht ÅberprÅft und kînnten Fehler enthalten !          *
*                                                                           *
*                                                                           *
****************************************************************************}

INTERFACE

{************************COMMON FUNCTIONS********************************}

{Common types}
TYPE PFNThread =POINTER;  {Pointer to a procedure}
     TID       =LONGWORD; {Thread information handle}
     PID       =LONGWORD; {Process information handle}

     PRESULTCODES=^RESULTCODES;
     RESULTCODES=RECORD
                       CodeTerminate:LONGWORD;
                       CodeResult:LONGWORD;
                 END;


{DosExit codes}
CONST
     EXIT_THREAD       =0;
     EXIT_PROCESS      =1;

{DosExit Action code values}
CONST
     DCWA_PROCESS      =0;
     DCWA_PROCESSTREE  =1;

{Wait option values}
CONST
     DCWW_WAIT         =0;
     DCWW_NOWAIT       =1;

{DosCreateThread values}
CONST
     CREATE_READY         =0;
     CREATE_SUSPENDED     =1;
     STACK_SPARSE         =0;
     STACK_COMMITTED      =2;

IMPORTS  {Import all functions with IBM _System calling convention}
   FUNCTION DosBeep(dur,freq:LONGWORD):LONGWORD:        'DOSCALLS' index 286;
   PROCEDURE DosExit(result,action:LONGWORD):           'DOSCALLS' index 234;
   FUNCTION DosCreateThread(cbStack:LONGWORD;
                            flag:LONGWORD;
                            param:LONGWORD;
                            pfn:PFNTHREAD;
                            VAR _Tid:TID):LONGWORD:     'DOSCALLS' index 311;
   FUNCTION DosResumeThread(_tid:TID):LONGWORD:         'DOSCALLS' index 237;
   FUNCTION DosSuspendThread(_tid:TID):LONGWORD:        'DOSCALLS' index 238;
   FUNCTION DosKillThread(_tid:TID):LONGWORD:           'DOSCALLS' index 111;
   FUNCTION DosWaitChild(_pid:PID;
                         VAR ppid:PID;
                         pres:PResultCodes;
                         Options:LONGWORD;
                         Action:LONGWORD):LONGWORD:     'DOSCALLS' index 280;
   FUNCTION DosWaitThread(Options:LONGWORD;
                          VAR _ptid:TID):LONGWORD:      'DOSCALLS' index 349;
   FUNCTION DosSleep(msec:LONGWORD):LONGWORD:           'DOSCALLS' index 229;
   FUNCTION DosEnterCritSec:LONGWORD:                   'DOSCALLS' index 232;
   FUNCTION DosExitCritSec:LONGWORD:                    'DOSCALLS' index 233;
   FUNCTION DosExecPgm(PName:PSZ;
                       pres:PResultCodes;
                       penv:PSZ;
                       PArg:PSZ;
                       ExeFlags:LONGWORD;
                       cbObjName:LONGINT;
                       pObjName:PSZ):LONGWORD:          'DOSCALLS' index 283;
   FUNCTION DosSetPriority(PorTid:LONGWORD;
                           delta:LONGINT;
                           class:LONGWORD;
                           Scope:LONGWORD):LONGWORD:    'DOSCALLS' index 236;
   FUNCTION DosKillProcess(_pid:PID;
                           Action:LONGWORD):LONGWORD:   'DOSCALLS' index 235;
END;


{************************MEMORY MANAGEMENT********************************}

{Access protection}
CONST
     PAG_READ         =$00000001;
     PAG_WRITE        =$00000002;
     PAG_EXECUTE      =$00000004;
     PAG_GUARD        =$00000008;
     PAG_DEFAULT      =$00000400;

{Commitment}
CONST
     PAG_COMMIT       =$00000010;
     PAG_DECOMMIT     =$00000020;

{Allocation attributes}

CONST
     OBJ_TILE         =$00000040;
     OBJ_PROTECTED    =$00000080;
     OBJ_GETTABLE     =$00000100;
     OBJ_GIVEABLE     =$00000200;

CONST
     fPERM            =$00000007;
     fSHARE           =$00000300;

{DosAllocMem flags}
CONST
     fALLOC           =$00000057;

{DosAllocSharedMem flags}

CONST
     fALLOCSHR        =$00000357;

{DosGetNamedSharedMem flags}

CONST
     fGETNMSHR        =$00000007;

{DosGetSharedMem flags}

CONST
     fGETSHR          =$00000007;

{DosGiveSharedMem flags}

CONST
     fGIVESHR         =$00000007;

{DosSetMem flags}

CONST
     fSET             =$00000437;

{Dos32SubSet flags}

CONST
     DOSSUB_INIT       =$0000001;
     DOSSUB_GROW       =$0000002;
     DOSSUB_SPARSE_OBJ =$0000004;
     DOSSUB_SERIALIZE  =$0000008;


{Allocation type (returned from DosQueryMem)}

CONST
     PAG_SHARED        =$00002000;
     PAG_FREE          =$00004000;
     PAG_BASE          =$00010000;


IMPORTS {All IMPORTS use IBM _System Calling Convention}

   FUNCTION DosAllocMem(flag:LONGWORD;
                        cb:LONGWORD;
                        VAR ppb:POINTER):LONGWORD:    'DOSCALLS' index 299;
   FUNCTION DosFreeMem(pb:POINTER):LONGWORD:          'DOSCALLS' index 304;
   FUNCTION DosSetMem(Flag:LONGWORD;
                      cb:LONGWORD;
                      pb:POINTER):LONGWORD:           'DOSCALLS' index 305;
   FUNCTION DosGiveSharedMem(flag:LONGWORD;
                             _pid:PID;
                             pb:POINTER):LONGWORD:    'DOSCALLS' index 303;
   FUNCTION DosGetSharedMem(Flag:LONGWORD;
                            pb:POINTER):LONGWORD:     'DOSCALLS' index 302;
   FUNCTION DosGetNamedSharedMem(Flag:LONGWORD;
                                 pszName:PSZ;
                                 VAR ppb:POINTER):
                                 LONGWORD:            'DOSCALLS' index 301;
   FUNCTION DosAllocSharedMem(Flag:LONGWORD;
                              cb:LONGWORD;
                              pszName:PSZ;
                              VAR ppb:POINTER):
                              LONGWORD:               'DOSCALLS' index 300;
   FUNCTION DosQueryMem(VAR pFlag:LONGWORD;
                        VAR pcb:LONGWORD;
                        pb:POINTER):LONGWORD:         'DOSCALLS' index 306;
   FUNCTION DosSubAllocMem(cb:LONGWORD;
                           VAR ppb:POINTER;
                           pbBase:POINTER):LONGWORD:  'DOSCALLS' index 345;
   FUNCTION DosSubFreeMem(cb:LONGWORD;
                          pb:POINTER;
                          pbBase:POINTER):LONGWORD:   'DOSCALLS' index 346;
   FUNCTION DosSubSetMem(cb:LONGWORD;
                         Flags:LONGWORD;
                         pbBase:POINTER):LONGWORD:    'DOSCALLS' index 344;
   FUNCTION DosSubUnsetMem(pbBase:POINTER):LONGWORD:  'DOSCALLS' index 347;
END;

{**********************MODULE MANAGEMENT**********************************}

CONST
    PT_16BIT=0;
    PT_32BIT=1;

IMPORTS {All IMPORTS use IBM _System Calling Convention}

   FUNCTION DosLoadModule(VAR phmod:HMODULE;
                          pszModName:PSZ;
                          cbname:LONGWORD;
                          pszName:PSZ):LONGWORD:     'DOSCALLS' index 318;

   FUNCTION  DosFreeModule(hmod:HMODULE):LONGWORD:   'DOSCALLS' index 322;

   FUNCTION DosQueryProcAddr(VAR ppfn:POINTER;
                             pszName:PSZ;
                             ordinal:LONGWORD;
                             hmod:HMODULE):LONGWORD: 'DOSCALLS' index 321;
   FUNCTION DosQueryModuleHandle(VAR phmod:HMODULE;
                                 pszmodName:PSZ):
                                 LONGWORD:           'DOSCALLS' index 319;
   FUNCTION DosQueryModuleName(pch:PSTRING;
                               cbname:LONGWORD;
                               hmod:HMODULE):
                               LONGWORD:             'DOSCALLS' index 320;
   FUNCTION DosQueryProcType(VAR pulproctype:LONGWORD;
                             pszname:PSZ;
                             ordinal:LONGWORD;
                             hmod:HMODULE):LONGWORD: 'DOSCALLS' index 586;
END;


IMPLEMENTATION

{We dont need to implement anything !}

BEGIN
END.