Program AATtoPICConverter;

Uses Dos,Crt;

Var I,J,X,Y: Integer;
    F: File;
    P,P2: Pointer;

Begin
   GetMem(P,64000);
   Assign(F,'C:\AAT\AATemp2.PIC');
   Reset(F,800);
   GetMem(P2,800);
   BlockRead(F,P2^,1);
   FreeMem(P2,800);
   BlockRead(F,P^,80);
   Close(F);
   Assign(F,'TITLE.ROB');
   Rewrite(F,64000);
   BlockWrite(F,P^,1);
   Close(F);
   FreeMem(P,64000);
End.