Unit ROBOTU;

Interface

Uses Dos,Crt,TPMouse;

Const SegA000: Word=$A000;
      NumOfMCur=16;
      NumOfSur=64;
      NumOfTyp=15;

Var I,J,K,L,C: Integer;
    UI,UJ,UK: Integer;
    UB: Byte;
    W: Word;
    R: Real;
    S,S2: String;
    F: File;
    FT: Text;
    Tim,Tim2: Word;
    TCol,DTCol: Integer;
    B: Byte;
    Ch: Char;
    Bo,EndProg: Boolean;
    Pal: Array[0..767] of Byte;
    PreScreen,Screen: Pointer;
    MonX,MonY: Integer;
    X,Y,SelRob: Integer;
    X1,Y1,X2,Y2,DX,DY: Integer;
    Bro,Ure: Integer;
   {}
    TitlePic: Pointer;
    aMenuP,aScen,aGame,MenuPl: Integer;
   {Tips}
    NOTip,LastTip: Integer;
    Tip: Array[1..50] of String[50];
   {Computer}
    ComT,ComTV,ComTX,ComTY: Integer;
    MovT: Array[-1..1,-1..1] of Integer;
   {Scenario}
    ScenN: String[8];
    ScenTX,ScenTY: Integer;
    MisText: Array[1..20] of String;
    MisTitle: String;
   {Map}
    mSur,mRob,mSig,mSigC: Array[0..99,0..99] of Byte;
    MapX,MapY: Integer;
    gLS: Array[0..NumOfSur] of Byte;
    gNam: Array[0..NumOfSur] of String[30];
   {Shapes}
    sRobot,sGround,sMouse,sChar: Pointer;
   {Mouse}
    MoX,MoY: Integer;
    MCNum,HotX,HotY: Word;
   {Robots}
    rX,rY,rHP,rTyp,rLS,rLA,rTac: Array[1..200] of Byte;
   {Types}
    tDmg,tArm,tRng: Array[0..2*NumOfTyp-1] of Byte;
    tSig,tDrv,tNOA: Array[0..2*NumOfTyp-1] of Byte;
    tNam,tWep: Array[0..2*NumOfTyp-1] of String[15];

Procedure ChangeTCol;
Procedure PutMouseCursor2(MX,MY,MCNum,SX,SY:Word;WX,WY: Byte);
Procedure PutFieldTp(MX,MY,MCNum: word);
Procedure PutChar(PCX,PCY: Word;PCC,PCCol: Byte;PCP: Pointer);
Procedure WriteText(WTX,WTY: Word;WTS: String;WTC: Byte;WTP: Pointer);
Procedure PutPixel(PPX,PPY: Word;PPC: Byte);
Procedure HLine(HLX,HLY,HLL: Word;HLC: Byte;HLP: Pointer);
Procedure VLine(VLX,VLY,VLL: Word;VLC: Byte;VLP: Pointer);
Procedure PutImage(X,Y: Word;PIP: Pointer;N: Word);
Procedure PutField(X,Y,M: Word);
Procedure FreshSight(FSR: Integer);
Procedure FillLSLA;
Procedure InitProgram;
Procedure AllocAndLoad;
Procedure InitRobots;
Procedure InitScenario(ISS: String);
Procedure FinishProgram;
Procedure ShowSurface;
Procedure ShowRobots;
Procedure ShowBar;
Procedure ShowMouse;
Procedure ScrollMon;
Procedure FreshScreen;
Procedure CentreRobot(CRR: Integer);
Procedure KillRobot(KRR: Integer);
Procedure MoveRobot(MRR,MRX,MRY: Integer);
Procedure AttackRobot(ARR,ART: Integer);
Procedure ViewRobot(VRR: Integer);
Procedure LeftClick;
Procedure RightClick;
Procedure ComputerMove;
Procedure Victory;
Procedure Defeat;
Procedure StartUp;
Procedure SaveGame(SGN: String);
Procedure LoadGame(LGN: String);
Procedure ShowMap;
Procedure MainMenu;
Procedure ShowTip(STN: Integer);

Implementation

Procedure ChangeTCol;
   Begin
      TCol:=TCol+DTCol;
      If (TCol=0) or (TCol=63) then DTCol:=-DTCol;
      Pal[765]:=TCol;Pal[766]:=TCol;Pal[767]:=TCol;
      Asm
       push es
       mov  ax,1012h
       mov  bx,255
       mov  cx,1
       push ds
       pop  es
       lea  dx,pal
       add  dx,765
       int  10h
       pop  es
      End;
   End;

Procedure PutMouseCursor2(MX,MY,MCNum,SX,SY:Word;WX,WY: Byte); Assembler;
   Asm
    push DS
    push ES
    lES di,PreScreen
    mov ax,320
    mul MY
    add ax,MX
    add di,ax
    mov ax,320
    mul SY
    add ax,SX
    add di,ax
    mov ax,256
    mul MCNum
    lds si,sMouse
    add si,ax
    add si,SX
    mov ax,16
    mul SY
    add si,ax

    mov dl,WY
@Lines:
    mov dh,WX
@Pixels:
    lodsb
    and al,al
    jnz @Put
    mov al,ES:[di]
@Put:
    stosb
    dec dh
    jnz @Pixels
    add di,320
    mov al,WX
    xor ah,ah
    sub di,ax
    add si,16
    sub si,ax
    dec dl
    jnz @Lines
    pop ES
    pop DS
   End;

Procedure PutFieldTp(MX,MY,MCNum: word); Assembler;
   Asm
    push DS
    push ES
    lES di,PreScreen
    mov ax,320
    mul MY
    add ax,MX
    add di,ax
    mov ax,400
    mul MCNum
    lds si,sGround
    add si,ax

    mov dl,20
@Lines:
    mov dh,20
@Pixels:
    lodsb
    and al,al
    jnz @Put
    mov al,ES:[di]
@Put:
    stosb
    dec dh
    jnz @Pixels
    add di,300
    dec dl
    jnz @Lines
    pop ES
    pop DS
   End;

Procedure PutChar(PCX,PCY:Word;PCC,PCCol: Byte;PCP: Pointer); Assembler;
   Asm
    push DS
    push ES
    lES di,PCP
    mov ax,320
    mul PCY
    add ax,PCX
    add di,ax
    mov ax,25
    mul PCC
    lds si,sChar
    add si,ax

    mov dl,5
@Lines:
    mov dh,5
@Pixels:
    lodsb
    and al,al
    jnz @Put
    mov al,ES:[di]
    jmp @NP
@Put:
    mov al,PCCol
@NP:
    stosb
    dec dh
    jnz @Pixels
    add di,315
    dec dl
    jnz @Lines
    pop ES
    pop DS
   End;

Procedure WriteText(WTX,WTY: Word;WTS: String;WTC: Byte;WTP: Pointer);
   Begin
      If Length(WTS)>0 then
       For UI:=1 to Length(WTS) Do
        PutChar(WTX+(UI-1)*6,WTY,Ord(WTS[UI]),WTC,WTP);
   End;

Procedure PutPixel(PPX,PPY: Word;PPC: Byte); Assembler;
   Asm
    lES di,PreScreen
    mov ax,320
    mul PPY
    add ax,PPX
    add di,ax
    mov al,PPC
    mov ES:[di],al
   End;

Procedure HLine(HLX,HLY,HLL: Word;HLC: Byte;HLP: Pointer); Assembler;
   Asm
    lES di,HLP
    mov ax,320
    mul HLY
    add ax,HLX
    add di,ax
    mov cx,HLL
    cmp cx,0
    je @Ex
    mov al,HLC
    rep stosb
@Ex:
   End;

Procedure VLine(VLX,VLY,VLL: Word;VLC: Byte;VLP: Pointer); Assembler;
   Asm
    lES di,VLP
    mov ax,320
    mul VLY
    add ax,VLX
    add di,ax
    mov cx,VLL
    cmp cx,0
    je @Ex
    mov al,VLC
@Pix:
    stosb
    add di,319
    loop @Pix
@Ex:
   End;

Procedure PutImage(X,Y: Word;PIP: Pointer;N: Word); Assembler;
   Asm
    lES di,PreScreen
    mov ax,320
    mul Y
    add ax,X
    add di,ax

    mov ax,256
    mul N
    push DS
    lDS si,PIP
    add si,ax

    mov dl,16
@Sor:
    mov dh,16
@Pixel:
    lodsb
    and al,al
    jnz @Put
    inc di
    jmp @NP
@Put:
    stosb
@NP:
    dec dh
    jnz @Pixel
    add di,304
    dec dl
    jnz @Sor

    pop DS
   End;

Procedure PutField(X,Y,M: Word); Assembler;
   Asm
    push es
    push ds
    les di,PreScreen
    mov ax,320
    mul Y
    add ax,X
    add di,ax
    lds si,sGround
    mov ax,400
    mul M
    add si,ax
    mov ax,20
    @Line:
    mov cx,20
    rep movsb
    add di,300
    dec ax
    jnz @Line
    pop ds
    pop es
   End;

Procedure FreshSight(FSR: Integer);
   Begin
      If rHP[FSR]>0 then
       For UJ:=-tSig[rTyp[FSR]] to tSig[rTyp[FSR]] Do
        For UI:=-tSig[rTyp[FSR]] to tSig[rTyp[FSR]] Do
         If (UI+rX[FSR]>=0) and (UI+rX[FSR]<MapX) then
         If (UJ+rY[FSR]>=0) and (UJ+rY[FSR]<MapY) then
         If rTyp[FSR]<NumOfTyp
          then Begin If Sqrt(Sqr(UI)+Sqr(UJ))<=tSig[rTyp[FSR]] then mSig[UI+rX[FSR],UJ+rY[FSR]]:=1;End
          else Begin If Sqrt(Sqr(UI)+Sqr(UJ))<=tSig[rTyp[FSR]] then mSigC[UI+rX[FSR],UJ+rY[FSR]]:=1;End;

   End;

Procedure FillLSLA;
   Begin
      For I:=1 to 200 Do
       If rHP[I]>0 then
        Begin
           rLS[I]:=tDrv[rTyp[I]];
           rLA[I]:=tNOA[rTyp[I]];
        End;
   End;

Procedure InitProgram;
   Begin
      Asm
       mov   ax,0013h
       int   10h
      End;
      Screen:=Ptr(SegA000,0);
      GetMem(PreScreen,64000);
      Asm
       lES di,PreScreen
       mov ax,0
       mov cx,32000
       rep stosw
      End;
      Assign(F,'Palette.ROB');
      Reset(F,1);
      BlockRead(F,Pal,768);
      Close(F);
      Asm
       push es
       mov  ax,1012h
       xor  bx,bx
       mov  cx,256
       push ds
       pop  es
       lea  dx,pal
       int  10h
       pop  es
      End;
      For I:=0 to 10 Do gLS[I]:=1;
      For I:=11 to 13 Do gLS[I]:=2;
      For I:=14 to 15 Do gLS[I]:=4;
      For I:=33 to 34 Do gLS[I]:=3;
      gLS[35]:=6;
      For I:=36 to 37 Do gLS[I]:=6;
      For I:=38 to 41 Do gLS[I]:=100;
      For I:=42 to 45 Do gLS[I]:=3;
      For I:=46 to 63 Do gLS[I]:=4;
      For I:=0 to 10 Do gNam[I]:='ROAD';
      For I:=11 to 13 Do gNam[I]:='CLEAR';
      For I:=14 to 15 Do gNam[I]:='WOOD';
      For I:=33 to 34 Do gNam[I]:='HILLS';
      gNam[35]:='MOUNTAINS';
      For I:=36 to 37 Do gNam[I]:='WATER';
      For I:=38 to 39 Do gNam[I]:='DEEP WATER';
      For I:=40 to 41 Do gNam[I]:='ROCKS';
      gNam[42]:='SOLAR PS';
      gNam[43]:='NUCLEAR PS';
      gNam[44]:='FACTORIES';
      gNam[45]:='MINES';
      gNam[46]:='ROME';gNam[52]:='SAIGON';gNam[58]:='SAN FRANCISCO';
      gNam[47]:='LONDON';gNam[53]:='SYDNEY';gNam[59]:='LOS ANGELES';
      gNam[48]:='JERUSALEM';gNam[54]:='HONOLULU';gNam[60]:='SEATTLE';
      gNam[49]:='CAIRO';gNam[55]:='SEOUL';gNam[61]:='MEXICO CITY';
      gNam[50]:='BAGHDAD';gNam[56]:='CAPE TOWN';gNam[62]:='NEW ORLEANS';
      gNam[51]:='HAVANA';gNam[57]:='SANTIAGO';gNam[63]:='NEW YORK';
   End;

Procedure AllocAndLoad;
   Begin
      GetMem(sRobot,256*2*NumOfTyp);
      Assign(F,'Robot.ROB');
      Reset(F,1);
      BlockRead(F,sRobot^,256*2*NumOfTyp);
      Close(F);
      GetMem(sMouse,256*NumOfMCur);
      Assign(F,'Mouse.ROB');
      Reset(F,1);
      BlockRead(F,sMouse^,256*NumOfMCur);
      Close(F);
      GetMem(sGround,400*NumOfSur);
      Assign(F,'Surface.ROB');
      Reset(F,1);
      BlockRead(F,sGround^,400*NumOfSur);
      Close(F);
      GetMem(sChar,6400);
      Assign(F,'Char.ROB');
      Reset(F,1);
      BlockRead(F,sChar^,6400);
      Close(F);
      Assign(FT,'Tips.ROB');
      Reset(FT);
      I:=0;
      While not EOF(FT) Do
       Begin
          Inc(I);ReadLn(FT,Tip[I]);
       End;
      NOTip:=I;
      Close(FT);
   End;

Procedure InitRobots;
   Begin
      Assign(F,'UnitType.ROB');
      Reset(F,1);
      For J:=0 to 2*NumOfTyp-1 Do
       Begin
         {Name}
          For I:=1 to 15 Do
           Begin
              BlockRead(F,B,1);
              tNam[J][I]:=Chr(B);
           End;
          BlockRead(F,B,1);
          tNam[J][0]:=Chr(15);
         {Weapon}
          For I:=1 to 15 Do
           Begin
              BlockRead(F,B,1);
              tWep[J][I]:=Chr(B);
           End;
          BlockRead(F,B,1);
          tWep[J][0]:=Chr(15);
         {Others}
          BlockRead(F,B,1);tSig[J]:=B;
          BlockRead(F,B,1);tDrv[J]:=B*2;
          BlockRead(F,B,1);tRng[J]:=B;
          BlockRead(F,B,1);tDmg[J]:=B;
          BlockRead(F,B,1);tNOA[J]:=B;
          BlockRead(F,B,1);tArm[J]:=B;
          For I:=1 to 10 Do BlockRead(F,B,1);
       End;
      Close(F);
   End;

Procedure InitScenario(ISS: String);
   Begin
      MapX:=100;MapY:=100;
      For J:=0 to MapY-1 Do
       For I:=0 to MapX-1 Do mSig[I,J]:=0;
      For J:=0 to MapY-1 Do
       For I:=0 to MapX-1 Do mSigC[I,J]:=0;
      For J:=0 to MapY-1 Do
       For I:=0 to MapX-1 Do mSur[I,J]:=0;
      For J:=0 to MapY-1 Do
       For I:=0 to MapX-1 Do mRob[I,J]:=0;
      For I:=1 to 200 Do
       Begin
          rX[I]:=0;rY[I]:=0;
          rHP[I]:=0;rTyp[I]:=0;
          rLS[I]:=0;rLA[I]:=0;
          rTac[I]:=0;
       End;
      For I:=1 to 20 Do MisText[I]:='';
      Bro:=0;Ure:=0;
      Assign(FT,ISS+'.RSC');
     {$I-}
      Reset(FT);
     {$I+}
      If IOResult<>0 then
       Begin
          Assign(FT,'DefScen.RSC');
          Reset(FT);ScenN:='DefScen ';
       End;
     {Mission}
      ReadLn(FT,MisTitle);
      ReadLn(FT,S);Val(S,I,J);
      For J:=1 to I Do
       ReadLn(FT,MisText[J]);
     {Brotherhood units}
      ReadLn(FT,S);Val(S,Bro,J);
      For J:=1 to Bro Do
       Begin
          ReadLn(FT,S);
          rHP[J]:=100;rTac[J]:=0;
          S2:=Copy(S,1,2);Val(S2,rTyp[J],K);
          S2:=Copy(S,4,2);Val(S2,rX[J],K);
          S2:=Copy(S,7,2);Val(S2,rY[J],K);
          mRob[rX[J],rY[J]]:=J;
       End;
     {United Robots units}
      ReadLn(FT,S);Val(S,Ure,J);
      For J:=1 to Ure Do
       Begin
          ReadLn(FT,S);
          rHP[99+J]:=100;
          S2:=Copy(S,1,2);Val(S2,rTyp[99+J],K);
          S2:=Copy(S,4,2);Val(S2,rX[99+J],K);
          S2:=Copy(S,7,2);Val(S2,rY[99+J],K);
          Case S[10] of
             'b':rTac[99+J]:=0;
             's':rTac[99+J]:=1;
             'd':rTac[99+J]:=2;
             'm':rTac[99+J]:=3;
          End;
          mRob[rX[99+J],rY[99+J]]:=99+J;
       End;
     {Map}
      ReadLn(FT,S);Val(S,MapX,K);
      ReadLn(FT,S);Val(S,MapY,K);
      For J:=0 to MapY-1 Do
       Begin
          ReadLn(FT,S);
          For I:=0 to MapX-1 Do
           Case S[I+1] of
              '-':mSur[I,J]:=0;
              '|':mSur[I,J]:=1;
              '/':mSur[I,J]:=2;
              '\':mSur[I,J]:=3;
              '''':mSur[I,J]:=4;
              '`':mSur[I,J]:=5;
              '+':mSur[I,J]:=6;
              '^':mSur[I,J]:=7;
              'T':mSur[I,J]:=8;
              '{':mSur[I,J]:=9;
              '}':mSur[I,J]:=10;
              'X':mSur[I,J]:=11+Random(3);
              'W':mSur[I,J]:=14+Random(2);
              'H':mSur[I,J]:=33+Random(2);
              'M':mSur[I,J]:=35;
              'o':mSur[I,J]:=36+Random(2);
              'O':mSur[I,J]:=38+Random(2);
              'R':mSur[I,J]:=40+Random(2);
              'S':mSur[I,J]:=42;
              'N':mSur[I,J]:=43;
              'F':mSur[I,J]:=44;
              'I':mSur[I,J]:=45;
              'a'..'n':mSur[I,J]:=Ord(S[I+1])-51;
              'p'..'s':mSur[I,J]:=Ord(S[I+1])-52;
           End;
       End;
     {Scenario target}
      ReadLn(FT,S);
      S2:=Copy(S,1,2);Val(S2,ScenTX,K);
      S2:=Copy(S,3,2);Val(S2,ScenTY,K);
     {}
      Close(FT);
      FillLSLA;For I:=1 to 200 Do FreshSight(I);
     {Mission Brief}
      For J:=0 to MapY-1 Do
       For I:=0 to MapX-1 Do
        Begin
           Case mSur[I,J] of
              0..10:K:=95;
              11..13:K:=75;
              14..15:K:=10;
              33..34:K:=159;
              35:K:=63;
              36..37:K:=85;
              38..39:K:=53;
              40..41:K:=235;
              42:K:=101;
              43:K:=160;
              44:K:=31;
              45:K:=231;
              46..63:K:=245;
           End;
           If mSig[I,J]=0 then K:=228;
           If MapY>66 then
            Begin
               HLine(I*2+(320-MapX*2),J*2+(200-MapY*2),2,K,Screen);
               HLine(I*2+(320-MapX*2),J*2+1+(200-MapY*2),2,K,Screen);
            End else
            Begin
               HLine(I*3+(320-MapX*3),J*3+(200-MapY*3),3,K,Screen);
               HLine(I*3+(320-MapX*3),J*3+1+(200-MapY*3),3,K,Screen);
               HLine(I*3+(320-MapX*3),J*3+2+(200-MapY*3),3,K,Screen);
            End;
           If mRob[I,J]>0 then
            If rTyp[mRob[I,J]]<NumOfTyp then L:=96 else L:=116;
           If (mRob[I,J]>0) and (mSig[I,J]>0) then
            Begin
               If MapY>66
                then HLine(I*2+1+(320-MapX*2),J*2+1+(200-MapY*2),1,L,Screen)
                else HLine(I*3+1+(320-MapX*3),J*3+1+(200-MapY*3),1,L,Screen);
            End;
        End;
      WriteText(0,0,MisTitle,96,Screen);
      For I:=1 to 20 Do
       Begin
          WriteText(0,I*6,MisText[I],245,Screen);
       End;
      WriteText(0,190,'PRESS LEFT BUTTON TO CONTINUE...',245,Screen);
      Repeat
         ChangeTCol;
      Until Left_Button_Pressed;
   End;

Procedure FinishProgram;
   Begin
      FreeMem(sRobot,256*2*NumOfTyp);
      FreeMem(sMouse,256*NumOfMCur);
      FreeMem(sGround,400*NumOfSur);
      FreeMem(sChar,6400);
      FreeMem(PreScreen,64000);
      Asm
       mov   ax,0003h
       int   10h
      End;
   End;

Procedure ShowSurface;
   Begin
      For J:=0 to 8 Do
       For I:=0 to 15 Do
        Begin
           If mSig[I+MonX,J+MonY]=0 then
            PutField(I*20,J*20,32) else
            PutField(I*20,J*20,mSur[I+MonX,J+MonY]);
        End;
   End;

Procedure ShowRobots;
   Begin
      For J:=0 to 8 Do
       For I:=0 to 15 Do
        If mSig[I+MonX,J+MonY]>0 then
        Begin
           K:=mRob[I+MonX,J+MonY];
           If K>0 then
            Begin
               PutImage(I*20+2,J*20+2,sRobot,rTyp[K]);
               If K=SelRob then PutMouseCursor2(I*20+2,J*20+2,7,0,0,16,16);
               If (rLA[K]>0) and (rTyp[K]<NumOfTyp) then WriteText(I*20+4,J*20,'A',255,PreScreen);
               If (rLS[K]>0) and (rTyp[K]<NumOfTyp) then WriteText(I*20+10,J*20,'M',255,PreScreen);
            End;
        End;
   End;

Procedure ShowBar;
   Begin
      For I:=0 to 15 Do
       PutField(I*20,180,16+I);
     {Selected}
      If SelRob>0 then
       Begin
          If rTyp[SelRob]>=NumOfTyp then J:=116 else J:=96;
          WriteText(1,182,tNam[rTyp[SelRob]],J,PreScreen);
          Str(rHP[SelRob],S);WriteText(1,188,'STRENGTH:'+S,J,PreScreen);
          Str(rLS[SelRob],S);WriteText(1,194,'LS:'+S,J,PreScreen);
          Str(rLA[SelRob],S);WriteText(43,194,'LA:'+S,J,PreScreen);
       End;
     {UnderMouse}
      If MoY<180 then
      If mSig[MoX div 20+MonX,MoY div 20+MonY]>0 then
       Begin
          I:=mRob[MoX div 20+MonX,MoY div 20+MonY];
          If I>0 then
           Begin
              If rTyp[I]>=NumOfTyp then J:=116 else J:=96;
              WriteText(92,182,tNam[rTyp[I]],J,PreScreen);
              Str(rHP[I],S);WriteText(92,188,'STRENGTH:'+S,J,PreScreen);
              Str(rLS[I],S);WriteText(92,194,'LS:'+S,J,PreScreen);
              Str(rLA[I],S);WriteText(134,194,'LA:'+S,J,PreScreen);
           End;
       End;
     {Message}
      If MoY<180 then
       Begin
          Str(MoX div 20+MonX,S);Str(MoY div 20+MonY,S2);
          If mSig[MoX div 20+MonX,MoY div 20+MonY]>0 then
           WriteText(182,194,'['+S+','+S2+']'+gNam[mSur[MoX div 20+MonX,
                                  MoY div 20+MonY]],100,PreScreen) else
           WriteText(182,194,'['+S+','+S2+']'+'UNKNOWN AREA',100,PreScreen);
       End;
      If MCNum=12 then
       WriteText(182,194,'CENTRE SELECTED UNIT',245,PreScreen);
   End;

Procedure ShowMouse;
   Begin
      Read_Mouse_Position(MoX,MoY);MoX:=MoX shr 1;
      If ((MoX>0) and (MoX<319)) and
         ((MoY>0) and (MoY<180)) then
       Begin
          I:=mRob[MoX div 20+MonX,MoY div 20+MonY];
          If I=0
           then
            Begin
               If SelRob=0
                then Begin MCNum:=0;HotX:=0;HotY:=0;End
                else Begin
                        If (Abs((MoX div 20+MonX)-rX[SelRob])<=1) and
                           (Abs((MoY div 20+MonY)-rY[SelRob])<=1)
                         then Begin MCNum:=4;HotX:=6;HotY:=6;End
                         else Begin MCNum:=0;HotX:=0;HotY:=0;End;
                     End;
            End
           else If SelRob=I then MCNum:=3
                            else
                If rTyp[I]>=NumOfTyp
                 then
                  Begin
                     If SelRob=0
                      then Begin MCNum:=3;HotX:=6;HotY:=6;End
                      else Begin
                              If Trunc(Sqrt(Sqr((MoX div 20+MonX)-
                                           rX[SelRob])+
                                      Sqr((MoY div 20+MonY)-
                                           rY[SelRob])))<=tRng[rTyp[SelRob]]
                               then Begin MCNum:=5;HotX:=6;HotY:=6;End
                               else Begin MCNum:=3;HotX:=6;HotY:=6;End;
                           End;
                  End
                 else
                  Begin
                     If SelRob=0
                      then Begin MCNum:=2;HotX:=6;HotY:=6;End
                      else Begin
                              MCNum:=3;HotX:=6;HotY:=6;
                           End;
                  End;
          If mSig[MoX div 20+MonX,MoY div 20+MonY]=0
           then Begin MCNum:=0;HotX:=0;HotY:=0;End;
       End else
       Begin
          MCNum:=0;HotX:=0;HotY:=0;
          If MoX<91 then Begin MCNum:=12;HotX:=6;HotY:=6;End;
          If MoX=0 then Begin MCNum:=10;HotX:=0;HotY:=6;End;
          If MoX=319 then Begin MCNum:=11;HotX:=11;HotY:=6;End;
          If MoY=0 then Begin MCNum:=8;HotX:=6;HotY:=0;End;
          If MoY=199 then Begin MCNum:=9;HotX:=6;HotY:=11;End;
       End;
      X1:=0;Y1:=0;X2:=16;Y2:=16;
      If MoX-HotX>304 then X2:=320-(MoX-HotX);
      If MoY-HotY>184 then Y2:=200-(MoY-HotY);
      If MoX-HotX<0 then X1:=HotX-MoX;
      If MoY-HotY<0 then Y1:=HotY-MoY;
      PutMouseCursor2(MoX-HotX,MoY-HotY,MCNum,X1,Y1,Abs(X2-X1),Abs(Y2-Y1));
      If (MCNum=1) or (MCNum=5) then
       Begin
          J:=Trunc(tDmg[rTyp[SelRob]]/tArm[rTyp[I]]*rHP[SelRob]/100);
          If tDmg[rTyp[SelRob]]=0 then J:=rHP[I];
          If J>rHP[I] then J:=rHP[I];
          Str(J,S);
          If J=rHP[I]
           then WriteText(MoX-HotX,MoY+HotY,S,245,PreScreen)
           else WriteText(MoX-HotX,MoY+HotY,S,224,PreScreen);
       End;
   End;

Procedure ScrollMon;
   Begin
      Case MCNum of
         8:If MonY>0 then Dec(MonY);
         9:If MonY<(MapY-9) then Inc(MonY);
        10:If MonX>0 then Dec(MonX);
        11:If MonX<(MapX-16) then Inc(MonX);
      End;
   End;

Procedure FreshScreen; Assembler;
   Asm
    push DS
    les di,Screen
    lds si,PreScreen
    mov cx,32000
    rep movsw
    pop DS
   End;

Procedure CentreRobot(CRR: Integer);
   Begin
      If CRR>0 then
       Begin
          MonX:=rX[CRR]-7;
          If MonX<0 then MonX:=0;
          If MonX>(MapX-16) then MonX:=MapX-16;
          MonY:=rY[CRR]-4;
          If MonY<0 then MonY:=0;
          If MonY>(MapY-9) then MonY:=MapY-9;
       End;
      Delay(100);
   End;

Procedure KillRobot(KRR: Integer);
   Begin
      mRob[rX[KRR],rY[KRR]]:=0;
      rHP[KRR]:=0;
      If SelRob=KRR then SelRob:=0;
      If rTyp[KRR]<NumOfTyp then Dec(Bro) else Dec(Ure);
   End;

Function CanRMove(CRR,CRX,CRY: Integer): Boolean;
   Begin
      If rLS[CRR]>=(gLS[mSur[rX[CRR],rY[CRR]]]+gLS[mSur[CRX,CRY]]) div 2
       then CanRMove:=True else CanRMove:=False;
      If mRob[CRX,CRY]>0 then CanRMove:=False;
      If (CRX>MapX-1) or (CRX<0) then CanRMove:=False;
      If (CRY>MapY-1) or (CRY<0) then CanRMove:=False;
   End;

Procedure MoveRobot(MRR,MRX,MRY: Integer);
   Begin
      Dec(rLS[MRR],(gLS[mSur[rX[MRR],rY[MRR]]]+gLS[mSur[MRX,MRY]]) div 2);
      mRob[rX[MRR],rY[MRR]]:=0;
      mRob[MRX,MRY]:=MRR;
      rX[MRR]:=MRX;
      rY[MRR]:=MRY;
      FreshSight(MRR);Delay(150-MapX);
   End;

Procedure AttackRobot(ARR,ART: Integer);
   Begin
      If rLA[ARR]>0 then
       Begin
          UI:=Trunc(tDmg[rTyp[ARR]]/tArm[rTyp[ART]]*
                    rHP[ARR]/100*(0.9+Random(200)/1000));
          If tDmg[rTyp[ARR]]=0 then UI:=rHP[ART];
          If UI>=rHP[ART]
           then KillRobot(ART)
           else Dec(rHP[ART],UI);
          Dec(rLA[ARR]);
       End;
      Delay(100);
   End;

Procedure ViewRobot(VRR: Integer);
   Begin
      For I:=0 to 76 Do HLine(84,62+I,153,96,PreScreen);
      For I:=1 to 75 Do HLine(85,62+I,151,0,PreScreen);
      HLine(86,118,149,96,PreScreen);I:=rTyp[VRR];
      If I>=NumOfTyp then J:=116 else J:=96;
      WriteText(86,64,'UNIT TYPE:'+tNam[I],J,PreScreen);
      WriteText(86,70,'WEAPON:'+tWep[I],J,PreScreen);
      Str(tDmg[I],S);If tDmg[I]=0 then S:='DEATH!';
      WriteText(86,76,'DAMAGE:'+S,J,PreScreen);
      Str(tArm[I],S);WriteText(86,82,'ARMOUR:'+S,J,PreScreen);
      Str(tRng[I],S);WriteText(86,88,'RANGE:'+S,J,PreScreen);
      Str(tSig[I],S);WriteText(86,94,'SIGHT:'+S,J,PreScreen);
      Case tDrv[I] of
         0:S:='NONE';
         6:S:='FEET';
        20:S:='WHEELED';
        24:S:='TRACKED';
        30:S:='FF-FEET';
      End;
      WriteText(86,100,'DRIVE:'+S,J,PreScreen);
      Str(tDrv[I],S);WriteText(86,106,'SPEED:'+S,J,PreScreen);
      Str(tNOA[I],S);WriteText(86,112,'MAX ATTACKS:'+S,J,PreScreen);
      Str(rHP[VRR],S);WriteText(86,120,'STRENGTH:'+S,J,PreScreen);
      Str(rLS[VRR],S);WriteText(86,126,'LEFT STEPS:'+S,J,PreScreen);
      Str(rLA[VRR],S);WriteText(86,132,'LEFT ATAKS:'+S,J,PreScreen);
      FreshScreen;Delay(500);
      Repeat Until Left_Button_Pressed;
      Delay(150);
   End;

Procedure LeftClick;
   Begin
      If (MCNum=2) or (MCNum=6)
       then Begin
               SelRob:=mRob[MoX div 20+MonX,MoY div 20+MonY];
               Delay(200);
            End;
      If (MCNum=4) and (rTyp[SelRob]<NumOfTyp) and
         (CanRMove(SelRob,MoX div 20+MonX,MoY div 20+MonY)) then MoveRobot(SelRob,MoX div 20+MonX,MoY div 20+MonY);
      If MCNum=3 then ViewRobot(mRob[MoX div 20+MonX,MoY div 20+MonY]);
      If ((MCNum=1) or (MCNum=5)) and (rTyp[SelRob]<NumOfTyp) then AttackRobot(SelRob,mRob[MoX div 20+MonX,MoY div 20+MonY]);
      If MCNum=12 then CentreRobot(SelRob);
   End;

Procedure RightClick;
   Begin
      SelRob:=0;
   End;

Procedure ComputerMove;
   Begin
      For I:=0 to 4 Do HLine(182,194+I,137,0,Screen);
      WriteText(182,194,'WAIT',245,Screen);
      For I:=1 to 200 Do
       Begin
       If I mod 12=0 then WriteText(200+I*6 div 12,194,'.',245,Screen);
       If (rHP[I]>0) and (rTyp[I]>=NumOfTyp) then
        Begin
          {Choose Target}
           Case rTac[I] of
              0,2:Begin
                    {Choose best target...}
                     ComT:=0;ComTV:=0;
                     For J:=1 to 200 Do
                      If (rHP[J]>0) and (rTyp[J]<NumOfTyp) and
                         (mSigC[rX[J],rY[J]]>0) then
                       Begin
                          L:=Trunc(tDmg[rTyp[I]]/tArm[rTyp[J]]*rHP[I]/100);
                          If L>rHP[J] then L:=rHP[J];
                          If tDmg[rTyp[I]]=0 then L:=100;
                          K:=Trunc(L/10*(rHP[J]/100*tDmg[rTyp[J]]*tNOA[rTyp[J]]+tRng[rTyp[J]]));
                          If K>10000 then K:=10000;
                          If tDmg[rTyp[J]]=0 then K:=10000;
                          R:=Sqrt(Sqr(rX[I]-rX[J])+Sqr(rY[I]-rY[J]));
                          If K/R<1 then K:=Trunc(R+1);
                          If rTac[I]=0
                               {...in the world}
                           then K:=Trunc(K/R)
                               {...which can be dangerous}
                           else If R<=tRng[rTyp[J]] then K:=Trunc(K/R) else K:=0;
                          If K>ComTV then
                           Begin
                              ComT:=J;ComTV:=K;
                              ComTX:=rX[J];ComTY:=rY[J];
                           End;
                       End;
                  End;
                3:Begin
                    {Choose target place}
                     ComT:=0;ComTX:=ScenTX;ComTY:=ScenTY;
                  End;
            End;
          {Move Unit}
           If ComT>0 then K:=Trunc(Sqrt(Sqr(rX[I]-ComTX)+Sqr(rY[I]-ComTY)));
           Case rTac[I] of
              0,2:Begin
                    {Move towards target unit}
                     If ComT>0 then
                      For J:=1 to tDrv[rTyp[I]] Do
                       Begin
                          If K>tRng[rTyp[I]] then
                           Begin
                              DX:=rX[I]-ComTX;DY:=rY[I]-ComTY;
                              MovT[0,0]:=10;
                              MovT[-1,-1]:=10+(DX+DY) div 2;
                              MovT[0,-1]:=10+DY;
                              MovT[1,-1]:=10+(-DX+DY) div 2;
                              MovT[-1,0]:=10+DX;
                              MovT[1,0]:=10-DX;
                              MovT[-1,1]:=10+(DX-DY) div 2;
                              MovT[0,1]:=10-DY;
                              MovT[1,1]:=10+(-DX-DY) div 2;
                              For Y:=-1 to 1 Do
                               For X:=-1 to 1 Do
                                If CanRMove(I,rX[I]+X,rY[I]+Y)
                                 then MovT[X,Y]:=20*MovT[X,Y] div ((gLS[mSur[rX[I],rY[I]]]+gLS[mSur[rX[I]+X,rY[I]+Y]])*5)
                                 else MovT[X,Y]:=0;
                              L:=0;
                              For Y:=-1 to 1 Do
                               For X:=-1 to 1 Do
                                If MovT[X,Y]>L then
                                 Begin L:=MovT[X,Y];X2:=X;Y2:=Y;End;
                              If L>0 then MoveRobot(I,rX[I]+X2,rY[I]+Y2);
                           End;
                          K:=Trunc(Sqrt(Sqr(rX[I]-ComTX)+Sqr(rY[I]-ComTY)));
                       End;
                  End;
                3:Begin
                    {Move to target place}
                     For J:=1 to tDrv[rTyp[I]] Do
                      Begin
                         DX:=rX[I]-ComTX;DY:=rY[I]-ComTY;
                         MovT[0,0]:=10;
                         MovT[-1,-1]:=10+(DX+DY) div 2;
                         MovT[0,-1]:=10+DY;
                         MovT[1,-1]:=10+(-DX+DY) div 2;
                         MovT[-1,0]:=10+DX;
                         MovT[1,0]:=10-DX;
                         MovT[-1,1]:=10+(DX-DY) div 2;
                         MovT[0,1]:=10-DY;
                         MovT[1,1]:=10+(-DX-DY) div 2;
                         For Y:=-1 to 1 Do
                          For X:=-1 to 1 Do
                           If CanRMove(I,rX[I]+X,rY[I]+Y)
                            then MovT[X,Y]:=20*MovT[X,Y] div ((gLS[mSur[rX[I],rY[I]]]+gLS[mSur[rX[I]+X,rY[I]+Y]])*5)
                            else MovT[X,Y]:=0;
                         L:=0;
                         For Y:=-1 to 1 Do
                          For X:=-1 to 1 Do
                           If MovT[X,Y]>L then
                            Begin L:=MovT[X,Y];X2:=X;Y2:=Y;End;
                         If L>0 then MoveRobot(I,rX[I]+X2,rY[I]+Y2);
                      End;
                  End;
           End;
          {Attack Target}
           If (ComT>0) and (K<=tRng[rTyp[I]])
            then Begin
                   {Attack chosen target}
                    For J:=1 to tNOA[rTyp[I]] Do
                     If rHp[ComT]>0 then AttackRobot(I,ComT);
                 End
            else Begin
                   {Attack best target in range}
                    ComT:=0;ComTV:=0;
                    For J:=1 to 200 Do
                     If (rHP[J]>0) and (rTyp[J]<NumOfTyp) and
                        (mSigC[rX[J],rY[J]]>0) then
                      Begin
                         R:=Sqrt(Sqr(rX[I]-rX[J])+Sqr(rY[I]-rY[J]));
                         If R<=tRng[rTyp[I]] then
                          Begin
                             L:=Trunc(tDmg[rTyp[I]]/tArm[rTyp[J]]*rHP[I]/100);
                             If L>rHP[J] then L:=rHP[J];
                             If tDmg[rTyp[I]]=0 then L:=100;
                             K:=Trunc(L/10*(rHP[J]/100*tDmg[rTyp[J]]*tNOA[rTyp[J]]+tRng[rTyp[J]]));
                             If K>10000 then K:=10000;
                             If tDmg[rTyp[J]]=0 then K:=10000;
                             If K>ComTV then
                              Begin
                                 ComT:=J;ComTV:=K;
                                 ComTX:=rX[J];ComTY:=rY[J];
                              End;
                          End;
                      End;
                    If ComT>0 then
                     For J:=1 to tNOA[rTyp[I]] Do
                      If rHp[ComT]>0 then AttackRobot(I,ComT);
                 End;
        End;
       End;
      Delay(50);
   End;

Procedure Victory;
   Begin
      Asm
       les di,Screen
       mov cx,32000
       xor ax,ax
       rep stosw
      End;
      WriteText(92,98,'MISSION ACCOMPLISHED!!!',96,Screen);Delay(200);
      Repeat Until Left_Button_Pressed;
   End;

Procedure Defeat;
   Begin
      Asm
       les di,Screen
       mov cx,32000
       xor ax,ax
       rep stosw
      End;
      WriteText(110,98,'MISSION FAILED!!!',116,Screen);Delay(200);
      Repeat Until Left_Button_Pressed;
   End;

Procedure StartUp;
   Procedure WriteCenter(WCY: Integer;WCS: String;WCC: Byte);
      Begin
         WriteText(160-Length(WCS)*3,WCY,WCS,WCC,Screen);
      End;
   Begin
      Asm
       mov   ax,0013h
       int   10h
      End;
      Screen:=Ptr(SegA000,0);
      Assign(F,'TitlePal.ROB');
      Reset(F,1);
      BlockRead(F,Pal,768);
      Close(F);
      Asm
       push es
       mov  ax,1012h
       xor  bx,bx
       mov  cx,256
       push ds
       pop  es
       lea  dx,pal
       int  10h
       pop  es
      End;
      Assign(F,'Title.ROB');
      Reset(F,64000);
      BlockRead(F,Screen^,1);
      Close(F);
      Delay(100);WriteCenter(80,'N‚meth Andr s',180);
      Delay(100);WriteCenter(90,'proudly persents',180);
      Delay(100);WriteCenter(100,'a CUCU production',180);
      Delay(100);WriteCenter(110,'called',180);
      Delay(100);WriteCenter(120,'ROBOT',180);
      Delay(100);WriteText(0,190,'Copyright(c)1997 by N‚meth Andr s',172,Screen);
      Repeat Until KeyPressed;Ch:=ReadKey;
   End;

Procedure SaveGame(SGN: String);
   Begin
      For I:=0 to 4 Do HLine(182,194+I,137,0,Screen);
      WriteText(182,194,'SAVING...',245,Screen);
      Assign(F,SGN+'.RSV');
      ReWrite(F,1);
      For I:=1 to Length(ScenN) Do BlockWrite(F,ScenN[I],1);
      B:=32;For I:=1 to 8-Length(ScenN) Do BlockWrite(F,B,1);
      BlockWrite(F,Bro,1);BlockWrite(F,Ure,1);
      For J:=0 to MapY-1 Do
       For I:=0 to MapX-1 Do BlockWrite(F,mRob[I,J],1);
      For I:=1 to 200 Do
       Begin
          BlockWrite(F,rX[I],1);BlockWrite(F,rY[I],1);
          BlockWrite(F,rHP[I],1);BlockWrite(F,rTyp[I],1);
          BlockWrite(F,rLS[I],1);BlockWrite(F,rLA[I],1);
          BlockWrite(F,rTac[I],1);
       End;
      Close(F);
   End;

Procedure LoadGame(LGN: String);
   Begin
      For I:=0 to 4 Do HLine(182,194+I,137,0,Screen);
      WriteText(182,194,'LOADING...',245,Screen);
      Assign(F,LGN+'.RSV');
     {$I-}
      Reset(F,1);
     {$I+}
      If IOResult<>0 then
       Begin
          For I:=0 to 4 Do HLine(182,194+I,137,0,Screen);
          WriteText(182,194,'CAN''T LOAD GAME',245,Screen);
          Delay(500);
       End else
       Begin
          ScenN:='        ';
          For I:=1 to 8 Do BlockRead(F,ScenN[I],1);
          Asm
           les di,Screen
           mov cx,32000
           xor ax,ax
           rep stosw
          End;
          InitScenario(ScenN);
          BlockRead(F,Bro,1);BlockRead(F,Ure,1);
          For J:=0 to MapY-1 Do
           For I:=0 to MapX-1 Do BlockRead(F,mRob[I,J],1);
          For I:=1 to 200 Do
           Begin
              BlockRead(F,rX[I],1);BlockRead(F,rY[I],1);
              BlockRead(F,rHP[I],1);BlockRead(F,rTyp[I],1);
              BlockRead(F,rLS[I],1);BlockRead(F,rLA[I],1);
              BlockRead(F,rTac[I],1);
           End;
          Close(F);
          For J:=0 to MapY-1 Do
           For I:=0 to MapX-1 Do mSig[I,J]:=0;
          For I:=1 to 200 Do FreshSight(I);
          CentreRobot(1);
       End;
   End;

Procedure ShowMap;
   Begin
      For J:=0 to MapY-1 Do
       For I:=0 to MapX-1 Do
        Begin
           Case mSur[I,J] of
              0..10:K:=95;
              11..13:K:=75;
              14..15:K:=10;
              33..34:K:=159;
              35:K:=63;
              36..37:K:=85;
              38..39:K:=53;
              40..41:K:=235;
              42:K:=101;
              43:K:=160;
              44:K:=31;
              45:K:=231;
              46..63:K:=245;
           End;
           If mSig[I,J]=0 then K:=228;
           If MapY>66 then
            Begin
               HLine(I*2,J*2,2,K,Screen);
               HLine(I*2,J*2+1,2,K,Screen);
            End else
            Begin
               HLine(I*3,J*3,3,K,Screen);
               HLine(I*3,J*3+1,3,K,Screen);
               HLine(I*3,J*3+2,3,K,Screen);
            End;
           If mRob[I,J]>0 then
            If rTyp[mRob[I,J]]<NumOfTyp then L:=96 else L:=116;
           If (mRob[I,J]>0) and (mSig[I,J]>0) then
            Begin
               If MapY>66
                then HLine(I*2+1,J*2+1,1,L,Screen)
                else HLine(I*3+1,J*3+1,1,L,Screen);
            End;
        End;
      Repeat Until Left_Button_Pressed;
      Delay(200);
   End;

Procedure MainMenu;
   Procedure WriteCenter(WCY: Integer;WCS: String;WCC: Byte);
      Begin
         WriteText(160-Length(WCS)*3,WCY,WCS,WCC,PreScreen);
      End;
   Begin
      Assign(F,'TitlePal.ROB');
      Reset(F,1);
      BlockRead(F,Pal,768);
      Close(F);
      Asm
       push es
       mov  ax,1012h
       xor  bx,bx
       mov  cx,256
       push ds
       pop  es
       lea  dx,pal
       int  10h
       pop  es
      End;
      GetMem(TitlePic,64000);
      Assign(F,'Title.ROB');
      Reset(F,64000);
      BlockRead(F,TitlePic^,1);
      Close(F);
      Bo:=False;aMenuP:=1;aScen:=1;aGame:=1;MenuPl:=0;
      Repeat
         Asm
          push ds
          les di,PreScreen
          lds si,TitlePic
          mov cx,32000
          rep movsw
          pop ds
         End;
         Case MenuPl of
            0:Begin
                 If aMenuP=1 then C:=180 else C:=172;
                 WriteCenter(85,'START CAMPAIGN',C);
                 If aMenuP=2 then C:=180 else C:=172;
                 WriteCenter(91,'CUSTOM SCENARIO',C);
                 If aMenuP=3 then C:=180 else C:=172;
                 WriteCenter(97,'LOAD GAME',C);
                 If aMenuP=4 then C:=180 else C:=172;
                 WriteCenter(103,'SHOW CREDITS',C);
                 If aMenuP=5 then C:=180 else C:=172;
                 WriteCenter(109,'EXIT PROGRAM',C);
              End;
            1:Begin
              End;
         End;
         WriteText(0,190,'Copyright(c)1997 by N‚meth Andr s',172,PreScreen);
         FreshScreen;
         If KeyPressed then Ch:=ReadKey;
         If Ch=#13 then MenuPl:=aMenuP;
         If Ch=#0 then
          Begin
             Ch:=ReadKey;
             If Ch=#72 then
              If aMenuP>1 then Dec(aMenuP) else aMenuP:=5;
             If Ch=#80 then
              If aMenuP<5 then Inc(aMenuP) else aMenuP:=1;

          End;
         Case MenuPl of
            1:Begin
                 ScenN:='Scen1';
                 Asm
                  les di,Screen
                  mov cx,32000
                  xor ax,ax
                  rep stosw
                 End;
                 Assign(F,'Palette.ROB');
                 Reset(F,1);
                 BlockRead(F,Pal,768);
                 Close(F);
                 Asm
                  push es
                  mov  ax,1012h
                  xor  bx,bx
                  mov  cx,256
                  push ds
                  pop  es
                  lea  dx,pal
                  int  10h
                  pop  es
                 End;
                 InitScenario(ScenN);Bo:=True;
              End;
            2:Begin
                 WriteText(0,0,'ENTER SCENARIO NAME: ',180,Screen);
                 ReadLn(ScenN);
                 Asm
                  les di,Screen
                  mov cx,32000
                  xor ax,ax
                  rep stosw
                 End;
                 Assign(F,'Palette.ROB');
                 Reset(F,1);
                 BlockRead(F,Pal,768);
                 Close(F);
                 Asm
                  push es
                  mov  ax,1012h
                  xor  bx,bx
                  mov  cx,256
                  push ds
                  pop  es
                  lea  dx,pal
                  int  10h
                  pop  es
                 End;
                 InitScenario(ScenN);Bo:=True;
              End;
            3:Begin
                 WriteText(0,0,'CHOOSE SLOT!',180,Screen);
                 Ch:=ReadKey;
                 Asm
                  les di,Screen
                  mov cx,32000
                  xor ax,ax
                  rep stosw
                 End;
                 Assign(F,'Palette.ROB');
                 Reset(F,1);
                 BlockRead(F,Pal,768);
                 Close(F);
                 Asm
                  push es
                  mov  ax,1012h
                  xor  bx,bx
                  mov  cx,256
                  push ds
                  pop  es
                  lea  dx,pal
                  int  10h
                  pop  es
                 End;
                 LoadGame('FastSav'+Ch);Bo:=True;
              End;
            4:Begin
                 Asm
                  push ds
                  les di,PreScreen
                  lds si,TitlePic
                  mov cx,32000
                  rep movsw
                  pop ds
                 End;
                 Assign(FT,'Credits.ROB');
                 Reset(FT);
                 I:=0;
                 While not EOF(FT) Do
                  Begin
                     ReadLn(FT,S);Inc(I);
                     Case S[1] of
                        '.':Begin Delete(S,1,1);WriteCenter(I*6,S,172);End;
                        'x':Begin Delete(S,1,1);WriteCenter(I*6,S,180);End;
                     End;
                  End;
                 Close(FT);
                 WriteCenter(180,'PRESS ANY KEY...',180);
                 WriteText(0,190,'Copyright(c)1997 by N‚meth Andr s',172,PreScreen);
                 FreshScreen;MenuPl:=0;
                 Repeat Until KeyPressed;Ch:=ReadKey;
              End;
            5:Begin EndProg:=True;Bo:=True;End;
         End;
      Until Bo;
      FreeMem(TitlePic,64000);
   End;

Procedure ShowTip(STN: Integer);
   Begin
      For I:=1 to 7 Do HLine(1,I,318,0,Screen);
      WriteText(2,2,Tip[STN],245,Screen);
      Repeat Until Left_Button_Pressed;Delay(200);
   End;

Begin
End.