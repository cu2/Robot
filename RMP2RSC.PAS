Program RMPtoRSCconverter;

Uses Dos,Crt;

Var I,J: Integer;
    S: String;
    B: Byte;
    F: File;
    FT: Text;
    MaxX,MaxY: Integer;
    MapNam,SceNam: String;
    Map: Array[1..100,1..100] of Char;

Begin
   MapNam:='SkullIsl';SceNam:='SkullI2';
   MaxX:=100;MaxY:=100;
   For J:=1 to 100 Do
    For I:=1 to 100 Do Map[I,J]:=' ';
   Assign(F,MapNam+'.RMP');
   Reset(F,1);
   For J:=1 to MaxY Do
    For I:=1 to MaxX Do
     Begin
        BlockRead(F,B,1);
        Case B of
           17..27:Map[I,J]:='H';
           28:Map[I,J]:='W';
           56..60:Map[I,J]:='W';
           81..85:Map[I,J]:='W';
           63..79:Map[I,J]:='X';
           30..47:Map[I,J]:='O';
           251:Map[I,J]:='I';
           216:Map[I,J]:='F';
{           :Map[I,J]:='';}
        End;
     End;
   Close(F);
   Assign(FT,SceNam+'.RSC');
   ReWrite(FT);
   WriteLn(FT,MaxX);WriteLn(FT,MaxY);
   For J:=1 to MaxY Do
    Begin
       For I:=1 to MaxX-1 Do Write(FT,Map[I,J]);
       WriteLn(FT,Map[MaxX,J]);
    End;
   Close(FT);
End.