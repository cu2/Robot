Program AATtoDATConverter;

Uses Dos,Crt;

Var I,J,X,Y: Integer;
    Ch: Char;
    Bo,Tr,Fa: Boolean;
    F: File;
    V: Array[1..64000] of Byte;
    One,Zero: Byte;

Begin
   Assign(F,'C:\AAT\AATemp2.PIC');
   Reset(F,800);
   BlockRead(F,V,1);
   BlockRead(F,V,80);
   Close(F);
{   Assign(F,'Robot.ROB');
   Rewrite(F,1);
   For J:=0 to 1 Do
    For I:=0 to 14 Do
     For Y:=1 to 16 Do
      For X:=1 to 16 Do
       Begin
          BlockWrite(F,V[Y*320+X+J*320*18+I*18+1],1);
       End;
   Close(F);}
{   Assign(F,'World.ROB');
   Rewrite(F,1);
   For Y:=0 to 89 Do
    For X:=0 to 179 Do
     Begin
        BlockWrite(F,V[(55+Y)*320+(70+X)+1],1);
     End;
   Close(F);}
{   Assign(F,'SkullIsl.RMP');
   Rewrite(F,1);
   For Y:=1 to 100 Do
    For X:=1 to 100 Do
     Begin
        BlockWrite(F,V[Trunc(Y*1.28)*320+Trunc(X*1.28)+1],1);
     End;
   Close(F);}
{   Assign(F,'Mouse.ROB');
   Rewrite(F,1);
   For J:=0 to 3 Do
    For I:=0 to 3 Do
     For Y:=0 to 15 Do
      For X:=0 to 15 Do
       Begin
          BlockWrite(F,V[Y*320+X+J*320*16+I*16+1],1);
       End;
   Close(F);}
{   Assign(F,'Surface.ROB');
   Rewrite(F,1);
   For J:=0 to 4 Do
    For I:=0 to 15 Do
     For Y:=0 to 19 Do
      For X:=0 to 19 Do
       Begin
          BlockWrite(F,V[Y*320+X+J*320*20+I*20+1],1);
       End;
   Close(F);}
   Assign(F,'Char.ROB');
   Rewrite(F,1);
   One:=1;Zero:=0;
   For J:=0 to 15 Do
    For I:=0 to 15 Do
     For Y:=0 to 4 Do
      For X:=0 to 4 Do
       Begin
          If V[Y*320+X+J*320*6+I*6+1]>0
           then BlockWrite(F,One,1)
           else BlockWrite(F,Zero,1);
       End;
   Close(F);
End.