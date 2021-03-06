UNIT PMCrt;

{**************************************************************************
 *                 General Unit for Speed-386                             *
 *                                                                        *
 *                                                                        *
 * Copyright (C) 1993,94 R.N�rnberger, Franz-Mehring-Str.2 09112 Chemnitz *
 *                                                                        *
 *                                                                        *
 **************************************************************************}


INTERFACE

CONST
     { default color table indices }

      CLR_FALSE                =-5;
      CLR_TRUE                 =-4;
      CLR_ERROR                =-255;
      CLR_DEFAULT              =-3;
      CLR_WHITE                =-2;
      CLR_BLACK                =-1;
      CLR_BACKGROUND           = 0;
      CLR_BLUE                 = 1;
      CLR_RED                  = 2;
      CLR_PINK                 = 3;
      CLR_GREEN                = 4;
      CLR_CYAN                 = 5;
      CLR_YELLOW               = 6;
      CLR_NEUTRAL              = 7;
      CLR_DARKGRAY             = 8;
      CLR_DARKBLUE             = 9;
      CLR_DARKRED              = 10;
      CLR_DARKPINK             = 11;
      CLR_DARKGREEN            = 12;
      CLR_DARKCYAN             = 13;
      CLR_BROWN                = 14;
      CLR_PALEGRAY             = 15;


procedure Window(X1,Y1,X2,Y2: Byte);
function WhereX: Byte;
function WhereY: Byte;
procedure GetBounds(VAR x,y,x1,y1:Byte);
procedure ClrEol;
procedure TextColor(Color: Byte);
procedure TextBackground(Color: Byte);


IMPLEMENTATION


PROCEDURE ClrEol;
BEGIN
END;


PROCEDURE Window(x,y,x1,y1:byte);
BEGIN
END;

PROCEDURE TextColor(c:LONGWORD);
BEGIN
     ASM
        CALLN32 System._CreatePMCrtWindow
     END;
     TextCol:=c;
END;

PROCEDURE TextBackGround(c:LONGWORD);
BEGIN
     ASM
        CALLN32 System._CreatePMCrtWindow
     END;
     TextBackCol:=c;
END;

FUNCTION WhereX:BYTE;
BEGIN
     ASM
        CALLN32 System._CreatePMCrtWindow
     END;
     WhereX:=DrawLocX+1;
END;

FUNCTION WhereY:BYTE;
BEGIN
     ASM
        CALLN32 System._CreatePMCrtWindow
     END;
     WhereY:=DrawLocY+1;
END;

procedure GetBounds(VAR x,y,x1,y1:Byte);
BEGIN
END;

BEGIN
END.
                                                           