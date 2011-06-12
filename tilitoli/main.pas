unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    TT: TStringGrid;
    Button1: TButton;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure TTSelectCell(Sender: TObject; Acol, Arow: Integer;
      var CanSelect: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
procedure swap(xa,ya,xb,yb:byte);
var
  Form1: TForm1;
  ures:Tpoint;
  mennyi:byte;
implementation

{$R *.DFM}
procedure swap(xa,ya,xb,yb:byte);
var
tmp:string;
begin
with form1.TT do
begin
 tmp:=cells[xa,ya];
 cells[xa,ya]:=cells[xb,yb];
 cells[xb,yb]:=tmp
end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
x:shortint;
ali:boolean;
begin
ures:=point(0,0);
for x:=1 to 16 do
 tt.Cells[x mod 4,x div 4]:=inttostr(x);
if sender=form1 then button1click(button1) else
ttselectcell(TT,0,0,ali);
end;

procedure TForm1.TTSelectCell(Sender: TObject; Acol, Arow: Integer;
  var CanSelect: Boolean);
var
i:byte;
heymama:boolean;
begin
if (ures.x=Acol) xor (ures.y=Arow) then
begin
if ures.x=Acol then
begin
if ures.y>Arow then
for i:=ures.y-1 downto Arow do
swap(ures.x,i+1,ures.x,i)
  else
for i:=ures.y+1 to Arow do
swap(ures.x,i-1,ures.x,i)
end
 else
if ures.x>Acol then
for i:=ures.x-1 downto Acol do
swap(i+1,ures.y,i,ures.y)
  else
for i:=ures.x+1 to Acol do
swap(i-1,ures.y,i,ures.y);
ures:=point(Acol,Arow);
end;
heymama:=not timer1.Enabled;
for i:=1 to 16 do
 heymama:=heymama and (TT.Cells[i mod 4,i div 4]=inttostr(i));
if heymama then
if IDYES=messagebox(handle,'Sikerült kirakni! Új játék?','Jihhá!',MB_YESNO+MB_ICONQUESTION+MB_APPLMODAL+MB_SETFOREGROUND+MB_TOPMOST) then
button1click(button1)
else
form1.Close;
canselect:=true;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
timer1.Enabled:=true;
button1.Enabled:=false;
mennyi:=0;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
if mennyi>100 then
begin
 timer1.Enabled:=false;
 button1.Enabled:=true;
end;
mennyi:=mennyi+1;
tt.Col:=random(4);
tt.row:=random(4);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (key=ord('M')) and (ssCtrl in shift) then
 formcreate(nil)
end;

end.
