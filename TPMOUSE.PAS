Unit TPMOUSE;

Interface

Uses Dos,Crt;

Var GraphC: Array[1..32] of Word;

Procedure Enable_software_cursor;
Procedure ES;
Procedure Enable_hardware_cursor(start,stop:integer);
Procedure Disable_cursor;
Procedure DC;
Procedure Read_mouse_position(var x,y:integer);
Function Mouse_installed:Boolean;
Function Mouse_x_position:integer;
Function Mouse_y_position:integer;
Function Left_button_pressed:Boolean;
Function Right_button_pressed:Boolean;
Function Middle_button_pressed:Boolean;
Procedure Set_mouse_position(x,y:integer);
Procedure Button_state(var b,x,y:integer);
Procedure Button_release_state(var b,x,y:integer);
Procedure Mouse_window(x1,y1,x2,y2:integer);
Procedure Mouse_move(var x,y:integer);
Procedure Enable_light_pen_emulation;
Procedure Disable_light_pen_emulation;
Procedure Mouse_sensitivity(x,y:integer);
Procedure Double_speed_mode(v:integer);
Procedure Disable_double_speed_mode;
Procedure InitGraphCursor(X,Y:Integer);
Procedure Define_Graphics_Cursor(Hot_Spot_X,Hot_Spot_Y:integer;
                                 Mask_Pointer:pointer);

Implementation

function Mouse_installed:Boolean;
     var register:registers;
   begin
      with register do
           begin
              ax:=0;
              intr($33,register);
              Mouse_installed:=(ax<>0);
           end;
   end;

procedure Enable_software_cursor;
     var register:registers;
   begin
      with register do
           begin
              ax:=1;
              intr($33,register);
              ax:=10;
              bx:=0;
              cx:=$ffff;
              dx:=$7700;
              intr($33,register);
           end;
   end;

procedure ES;
     var register:registers;
   begin
      with register do
           begin
              ax:=1;
              intr($33,register);
              ax:=10;
              bx:=0;
              cx:=$ffff;
              dx:=$7700;
              intr($33,register);
           end;
   end;

procedure Enable_hardware_cursor;
     var register:registers;
   begin
      with register do
           begin
              ax:=10;
              bx:=1;
              cx:=start;
              dx:=stop;
              intr($33,register);
              ax:=1;
              intr($33,register);
           end;
   end;

procedure Disable_cursor;
     var register:registers;
   begin
      register.ax:=2;
      intr($33,register);
   end;

procedure DC;
     var register:registers;
   begin
      register.ax:=2;
      intr($33,register);
   end;

procedure Read_mouse_position;
     var register:registers;
   begin
      with register do
           begin
              ax:=3;
              intr($33,register);
              x:=cx;
              y:=dx;
           end;
   end;

function Mouse_x_position;
     var register:registers;
   begin
      register.ax:=3;
      intr($33,register);
      Mouse_x_position:=register.cx;
   end;

function Mouse_y_position;
     var register:registers;
   begin
      register.ax:=3;
      intr($33,register);
      Mouse_y_position:=register.dx;
   end;

function Left_button_pressed;
     var register:registers;
   begin
      with register do
           begin
              ax:=3;
              intr($33,register);
              Left_button_pressed:=(bx mod 2 = 1);
           end;
   end;

function Right_button_pressed;
     var register:registers;
   begin
      with register do
           begin
              ax:=3;
              intr($33,register);
              Right_button_pressed:=((bx div 2) mod 2 = 1);
           end;
   end;

function Middle_button_pressed;
     var register:registers;
   begin
      with register do
           begin
              ax:=3;
              intr($33,register);
              Middle_button_pressed:=((bx div 4) mod 2 = 1);
           end;
   end;

procedure Set_mouse_position;
     var register:registers;
   begin
      with register do
           begin
              ax:=4;
              cx:=x;
              dx:=y;
              intr($33,register);
           end;
   end;

procedure Button_state;
     var register:registers;
   begin
      with register do
           begin
              if (b>=0) and (b<4)
                 then begin
                         ax:=5;
                         bx:=b;
                         intr($33,register);
                         b:=bx;
                         x:=cx;
                         y:=dx;
                      end
                 else begin
                         b:=0;
                         x:=0;
                         y:=0;
                      end;
           end;
   end;

procedure Button_release_state;
     var register:registers;
   begin
      with register do
           begin
              if (b>=0) and (b<4)
                 then begin
                         ax:=6;
                         bx:=b;
                         intr($33,register);
                         b:=bx;
                         x:=cx;
                         y:=dx;
                      end
                 else begin
                         b:=0;
                         x:=0;
                         y:=0;
                      end;
           end;
   end;

procedure Mouse_window;
     var register:registers;
         z:integer;
   begin
      with register do
           begin
              if x2<x1 then begin
                               z:=x1;
                               x1:=x2;
                               x2:=z;
                            end;
              if y2<y1 then begin
                               z:=y1;
                               y1:=y2;
                               y2:=z;
                            end;
              ax:=7;
              cx:=x1;
              dx:=x2;
              intr($33,register);
              ax:=8;
              cx:=y1;
              dx:=y2;
              intr($33,register);
           end;
   end;

procedure Mouse_move;
     var register:registers;
   begin
      with register do
           begin
              ax:=11;
              intr($33,register);
              x:=cx;
              y:=dx;
           end;
   end;

procedure Enable_light_pen_emulation;
     var register:registers;
   begin
      register.ax:=13;
      intr($33,register);
   end;

procedure Disable_light_pen_emulation;
     var register:registers;
   begin
      register.ax:=14;
      intr($33,register);
   end;

procedure Mouse_sensitivity;
     var register:registers;
   begin
      with register do
           begin
              ax:=15;
              cx:=x;
              dx:=y;
              intr($33,register);
           end;
   end;

procedure Double_speed_mode;
     var register:registers;
   begin
      register.ax:=19;
      register.dx:=v;
      intr($33,register);
   end;

procedure Disable_double_speed_mode;
     var register:registers;
   begin
      register.ax:=19;
      register.dx:=32767;
      intr($33,register);
   end;

Procedure InitGraphCursor;
     var register:registers;
   Begin
      With register Do
         Begin
         AX:=9;
         BX:=X;
         CX:=Y;
         ES:=Seg(GraphC[1]);
         DX:=Ofs(GraphC[1]);
         Intr($33,register);
      End;
   End;

Procedure Define_Graphics_Cursor(Hot_Spot_X, Hot_Spot_Y :integer;
                                  Mask_Pointer :pointer);
var regs: registers;
begin
     with regs do
     begin
          AX:=9;
          BX:=Hot_Spot_X;
          CX:=Hot_Spot_Y;
          DX:=ofs(Mask_Pointer^);
          ES:=seg(Mask_Pointer^);
          intr(51,regs);
     end;
end;




Begin
   if not Mouse_installed then halt(1);
   graphc[1]:=$0000;graphc[2]:=$0000;graphc[3]:=$3000;graphc[4]:=$3E00;
   graphc[5]:=$1E00;graphc[6]:=$1E00;graphc[7]:=$1F00;graphc[8]:=$0380;
   graphc[9]:=$01C0;graphc[10]:=$00E0;graphc[11]:=$0070;graphc[12]:=$0038;
   graphc[13]:=$001C;graphc[14]:=$000C;graphc[15]:=$0000;graphc[16]:=$0000;

   graphc[17]:=$3FFF;graphc[18]:=$07FF;graphc[19]:=$80FF;graphc[20]:=$800F;
   graphc[21]:=$80FF;graphc[22]:=$C07F;graphc[23]:=$C03F;graphc[24]:=$C01F;
   graphc[25]:=$E80F;graphc[26]:=$EC07;graphc[27]:=$EE03;graphc[28]:=$EF01;
   graphc[29]:=$FF80;graphc[30]:=$FFC0;graphc[31]:=$FFE1;graphc[32]:=$FFF3;
End.