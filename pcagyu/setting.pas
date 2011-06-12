unit setting;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls;
type
  TForm2 = class(TForm)
    porig: TRadioButton;
    zaszlo: TRadioButton;
    kapu: TRadioButton;
    min: TEdit;
    Bevel1: TBevel;
    gravity: TTrackBar;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    szelero: TTrackBar;
    legellen: TTrackBar;
    domborzat: TTrackBar;
    erdes: TTrackBar;
    aaa: TStaticText;
    vartav: TTrackBar;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    Bevel2: TBevel;
    Button1: TButton;
    Button2: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure porigClick(Sender: TObject);
    procedure zaszloClick(Sender: TObject);
    procedure kapuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  ali:array[1..8] of integer;
implementation

{$R *.DFM}
uses main;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
ali[1]:=strtoint(min.text);
if porig.checked then ali[2]:=0;
if zaszlo.Checked then ali[2]:=1;
if kapu.Checked then ali[2]:=2;
ali[3]:=gravity.Position;
ali[4]:=szelero.Position;
ali[5]:=legellen.Position;
ali[6]:=domborzat.Position;
ali[7]:=erdes.Position;
ali[8]:=vartav.Position;
frm2cls;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
form2.Close;
end;

procedure TForm2.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=VK_ESCAPE then form1.Close;
end;
                           
procedure TForm2.porigClick(Sender: TObject);
begin
if porig.Checked then min.Text:='4000';
end;

procedure TForm2.zaszloClick(Sender: TObject);
begin
if zaszlo.Checked then min.Text:='470';
end;

procedure TForm2.kapuClick(Sender: TObject);
begin
if kapu.Checked then min.Text:='180';
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
if ali[1]=0 then exit;
min.text:=inttostr(ali[1]);
case ali[2] of
 0:porig.checked:=true;
 1:zaszlo.checked:=true;
 2:kapu.checked:=true;
end;
gravity.Position:=ali[3];
szelero.Position:=ali[4];
legellen.Position:=ali[5];
domborzat.Position:=ali[6];
erdes.Position:=ali[7];
vartav.Position:=ali[8];
end;

procedure TForm2.Button2Click(Sender: TObject);
var
hmm:word;
ss:Tshiftstate;
begin
hmm:=VK_F1;
form1.FormKeyDown(form1,hmm,ss);
end;

end.
