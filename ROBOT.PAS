Program ROBOT;

Uses Dos,Crt,TPMouse,ROBOTU;

Begin
   InitProgram;AllocAndLoad;InitRobots;
   Bo:=Mouse_Installed;DC;Mouse_Window(0,0,638,199);
   SelRob:=0;TCol:=63;DTCol:=-1;EndProg:=False;LastTip:=0;
   StartUp;
   Repeat
   MainMenu;
   If EndProg=False then
   Begin
      Bo:=False;MonX:=0;MonY:=0;Tim:=0;MCNum:=0;
      CentreRobot(1);
      Repeat
         Repeat
            ShowSurface;
            ShowRobots;
            ShowBar;
            ShowMouse;
            FreshScreen;
            If Left_Button_Pressed then LeftClick;
            If Right_Button_Pressed then RightClick;
            Inc(Tim);If Tim>3 then Tim:=0;
            ChangeTCol;If Tim=0 then ScrollMon;
            If (Bro=0) or (Ure=0) then Bo:=True;
         Until KeyPressed or Bo;
         If KeyPressed then
          Begin
             Ch:=ReadKey;
             Case Ch of
                #27:Bo:=True;
                'p':Begin
                       ComputerMove;
                       For J:=0 to MapY-1 Do
                        For I:=0 to MapX-1 Do mSig[I,J]:=0;
                       FillLSLA;For I:=1 to 200 Do FreshSight(I);
                    End;
                's':Begin
                       For I:=0 to 4 Do HLine(182,194+I,137,0,Screen);
                       WriteText(182,194,'SAVE/CHOOSE SLOT!',245,Screen);
                       Repeat Until KeyPressed;Ch:=ReadKey;
                       SaveGame('FastSav'+Ch);
                    End;
                'l':Begin
                       For I:=0 to 4 Do HLine(182,194+I,137,0,Screen);
                       WriteText(182,194,'LOAD/CHOOSE SLOT!',245,Screen);
                       Repeat Until KeyPressed;Ch:=ReadKey;
                       LoadGame('FastSav'+Ch);
                    End;
                'a':LoadGame('AutoSave');
                'n':Begin
                       If SelRob>0 then I:=SelRob else I:=0;
                       SelRob:=0;J:=I;
                       Repeat
                          Inc(I);If I>100 then I:=1;
                          If (rLS[I]+rLA[I]>0) and
                             (rHP[I]>0) and (rTyp[I]<NumOfTyp) then SelRob:=I;
                       Until (SelRob>0) or (I=J);
                       If SelRob>0 then CentreRobot(SelRob);
                    End;
                'm':ShowMap;
                't':Begin
                       Repeat
                          I:=Random(NOTip)+1;
                       Until I<>LastTip;
                       LastTip:=I;ShowTip(I);
                    End;
             End;
          End;
      Until Bo;
      If (Ure>0) and (Bro>0) then SaveGame('AutoSave');
      If Ure=0 then Victory;
      If Bro=0 then Defeat;
   End;
   Until EndProg;
   FinishProgram;
   WriteLn('Thanks for playing ROBOT...');
End.