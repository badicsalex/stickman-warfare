unit Snake;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls,registry, ImgList;

type
  Thol=array of integer;
  TForm1 = class(TForm)
    Pb: TPaintBox;
    Timer1: TTimer;
    kep: TImageList;
    egy: TImage;
    ket: TImage;
    ha: TImage;
    temp: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PbDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
procedure rajz(szin:Tcolor;x,y:cardinal;mit:boolean);
procedure megy(no:boolean);
procedure kirajz;
procedure tesz;
function vesz:boolean;
procedure meghal;
procedure dogep;
var
  Form1: TForm1;
  iranya,iri:byte;
  buf:Tbitmap;
  holx,holy,holkepe,holkepk:Thol;
  dx,dy,rekord:integer;
  Reg:Tregistry;
  megyben:boolean;
  gep:boolean;
implementation

{$R *.DFM}
procedure loading;
var
rec,recII:Trect;
xx,yy,a:byte;
fajl:string;
begin
 buf:=Tbitmap.create;
 buf.Width:=form1.Clientwidth;
 buf.height:=form1.Clientheight;
 //ez nem a rajz,de ide kell
 gep:=false;
 //ez már az
 rec.Left:=0;
 rec.Top:=0;
 rec.Right:=19;
 rec.Bottom:=19;
 recII.Left:=19;
 recII.Top:=19;
 recII.Right:=0;
 recII.Bottom:=0;
  with form1 do
  begin
  for a:=0 to 1 do
   begin
    case a of
     0:fajl:='fej.bmp';
     1:fajl:='farok.bmp';
    end;
    egy.Picture.bitmap.LoadFromFile(fajl);
    kep.AddMasked(egy.Picture.Bitmap,clwhite);
    for xx:=0 to 19 do
     for yy:=0 to 19 do
      ket.Canvas.Pixels[18-xx,yy]:=egy.Canvas.Pixels[yy,xx];
    kep.AddMasked(ket.Picture.Bitmap,clwhite);
    egy.Canvas.CopyRect(rec,egy.canvas,recII);
    ket.Canvas.CopyRect(rec,ket.canvas,recII);
    kep.AddMasked(egy.Picture.Bitmap,clwhite);
    kep.AddMasked(ket.Picture.Bitmap,clwhite);
   end;
   egy.Picture.bitmap.LoadFromFile('kanyar.bmp');
   ket.Picture.bitmap.LoadFromFile('egyenes.bmp');
   recII.Top:=0;
   recII.Bottom:=20;
   ha.Canvas.CopyRect(recII,egy.canvas,rec);
   for a:=1 to 4 do
    begin
     kep.AddMasked(egy.Picture.Bitmap,clwhite);
     kep.AddMasked(ket.Picture.Bitmap,clwhite);
     kep.AddMasked(ha.Picture.Bitmap,clwhite);
     temp.Canvas.CopyRect(rec,egy.canvas,rec);
     for xx:=0 to 19 do
      for yy:=0 to 19 do
       egy.Canvas.Pixels[18-xx,yy]:=temp.Canvas.Pixels[yy,xx];
     temp.Canvas.CopyRect(rec,ket.canvas,rec);
     for xx:=0 to 19 do
      for yy:=0 to 19 do
       ket.Canvas.Pixels[18-xx,yy]:=temp.Canvas.Pixels[yy,xx];
     temp.Canvas.CopyRect(rec,ha.canvas,rec);
     for xx:=0 to 19 do
      for yy:=0 to 19 do
       ha.Canvas.Pixels[18-xx,yy]:=temp.Canvas.Pixels[yy,xx];
    end;
   end;
end;
procedure rajz(szin:Tcolor;x,y:cardinal;mit:boolean);
var
rec:Trect;
begin
 with buf.canvas do
  begin
   if mit then
   begin
    rec.Left:=x;
    rec.Top:=y;
    rec.Right:=x+19;
    rec.Bottom:=y+19;
   end
   else
   begin
    rec.Left:=0;
    rec.Top:=0;
    rec.Right:=form1.Pb.Width;
    rec.Bottom:=form1.Pb.Height;
   end;
   brush.Color:=szin;
   pen.Color:=szin;
   fillrect(rec);
  end;
end;
procedure tesz;
var
a:integer;
jo:boolean;
begin
 repeat
  dx:=random(26);
  dy:=random(16);
  jo:=true;
  for a:=0 to high(holx) do
    if (holx[a]=dx) and (holy[a]=dy) then jo:=false;
  until jo;
end;
procedure TForm1.FormCreate(Sender: TObject);
var
a:byte;
eli:boolean;
begin
clientwidth:=500;
clientheight:=320;
megyben:=false;
eli:=(sender=nil);
if not eli then loading;
iranya:=1; {0 fel, 1 jobb, 2 le, 3 bal}
setlength(holx,5);
setlength(holy,5);
setlength(holkepk,5);
for a:=0 to 4 do
 begin
  holx[a]:=17-a;
  holy[a]:=8;
  holkepk[a]:=7+4*3+1;
 end;
holkepk[0]:=1;
holkepk[4]:=5;
randomize;
tesz;
rajz(clwhite,0,0,false);
if eli then exit;
Reg:=Tregistry.Create;
if not reg.OpenKey('software\Speedy software\PC Snake',false)
   then
   begin
    reg.openkey('software\Speedy software\PC Snake',true);
    rekord:=5;
    reg.Writeinteger('rekord',rekord);
   end;
rekord:=reg.ReadInteger('rekord');
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if (key=vk_escape) then halt;
 if  gep then  exit;
 case key of
  vk_up:iranya:=0;
  vk_right:iranya:=1;
  vk_down:iranya:=2;
  vk_left:iranya:=3;
 end;
 if (iri=((iranya+2) mod 4)) then iranya:=iri;
end;
procedure ize(x,y:shortint);
 begin
  holx[0]:=holx[0]+x;
  holy[0]:=holy[0]+y;
  if megyben then
  begin
   holkepk[0]:=iranya;
  end;
  if 0>holx[0] then holx[0]:=25;
  if holx[0]>25 then holx[0]:=0;
  if 0>holy[0] then holy[0]:=15;
  if holy[0]>15 then holy[0]:=0;
 end;
procedure megy(no:boolean);
var
a:shortint;
begin
 if no then
 begin
  setlength(holx,length(holx)+1);
  setlength(holy,length(holy)+1);
  setlength(holkepk,length(holkepk)+1);
 end;
 for a:=high(holx)-1 downto 0 do
  begin
   holx[a+1]:=holx[a];
   holy[a+1]:=holy[a];
   holkepk[a+1]:=holkepk[a];
  end;
 megyben:=true;
 case iranya of
  0:ize(0,-1);
  1:ize(1,0);
  2:ize(0,1);
  3:ize(-1,0);
 else
  beep;
 end;
 megyben:=false;
end;

procedure kirajz;
var
a,e,k,kk:shortint;
begin
 with buf.canvas do
 begin
  rajz(clwhite,0,0,false);
  rajz(clred,dx*19,dy*19,true);
  form1.kep.Draw(buf.canvas,holx[0]*19,holy[0]*19,holkepk[0]);
  for a:=1 to high(holx)-1 do
  begin
    e:=holkepk[a];
    k:=(2+holkepk[a-1]) mod 4;
    kk:=(k-e+3) mod 4;
    e:=8+(e*3+kk);
    form1.kep.Draw(buf.canvas,holx[a]*19,holy[a]*19,e);
  end;
  form1.kep.Draw(buf.canvas,holx[high(holkepk)]*19,holy[high(holkepk)]*19,holkepk[high(holkepk)-1]+4);
  form1.Caption:='PC Snake! Hossz:'+inttostr(length(holx))+'/Rekord:'+ inttostr(rekord);
 end;
 with form1 do canvas.CopyRect(rect(0,0,clientwidth,clientheight),buf.canvas,rect(0,0,clientwidth,clientheight));
end;

procedure meghal;
var       
b:cardinal;
jo:boolean;          
hx,hy:integer;
begin                  
 hx:=holx[0];
 hy:=holy[0];
 jo:=false;
 for b:=1 to high(holy) do
    if (holx[b]=hx) and (holy[b]=hy) then jo:=true;
 holx[0]:=hx;
 holy[0]:=hy;
 if jo then  form1.FormCreate(nil);
end;
procedure TForm1.Timer1Timer(Sender: TObject);
begin
if buf=nil then exit;
if gep then dogep;
if not (rekord>length(holx))then rekord:=length(holx);
meghal;
megy(vesz);
kirajz;
iri:=iranya;
end;

function vesz:boolean;
var
hx,hy:integer;
vsz:boolean;
begin
 hx:=holx[0];
 hy:=holy[0];
 case iranya of
  0:ize(0,-1);
  1:ize(1,0);
  2:ize(0,1);
  3:ize(-1,0);
 else
  beep;
 end;
 vsz:=(holy[0]=dy) and (holx[0]=dx);
 holx[0]:=hx;
 holy[0]:=hy;
 if vsz then tesz;
 vesz:=vsz;
end;
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 reg.Writeinteger('rekord',rekord);
 buf.free;
end;

procedure TForm1.PbDblClick(Sender: TObject);
begin
gep:=not gep;
if gep then timer1.Interval:=50 else timer1.interval:=150;
end;

function vanhelyen(x,y:integer):boolean;
var
jo:boolean;
a:integer;
begin
  jo:=true;
  x:=(x+26) mod 26;
  y:=(y+16) mod 16;
  for a:=0 to high(holx) do
    if (holx[a]=x) and (holy[a]=y) then jo:=false;
  result:=jo;
end;
function jobb (enhol:Tpoint):boolean;
var
yo:boolean;
begin
 yo:=vanhelyen(enhol.x+1,enhol.y);
 if yo then iranya:=1;
 result:=yo;
end;

function bal (enhol:Tpoint):boolean;
var
yo:boolean;
begin
 yo:=vanhelyen(enhol.x-1,enhol.y);
 if yo then iranya:=3;
 result:=yo;
end;

function fel (enhol:Tpoint):boolean;
var
yo:boolean;
begin
 yo:=vanhelyen(enhol.x,enhol.y-1);
 if yo then iranya:=0;
 result:=yo;
end;

function le (enhol:Tpoint):boolean;
var
yo:boolean;
begin
 yo:=vanhelyen(enhol.x,enhol.y+1);
 if yo then iranya:=2;
 result:=yo;
end;

procedure dogep;
var
enhol,kul:Tpoint;
merre,strat:byte;
begin
 // a strat a stratégia.
 //1. Semmi különös
 //2. Falon átmenés
 //3. Csak  föl és balra.
 //(nem hatékony, de kicsi a kockázat)
 strat:=2;
 enhol:=point(holx[0],holy[0]);
 case strat of
 1:kul:=point(enhol.x-dx,enhol.y-dy);
 2:kul:=point((enhol.x-dx+13) mod 26-13,(enhol.y-dy+8)mod 16-8);
 3:kul:=point((enhol.x-dx+26) mod 26,(enhol.y-dy+16)mod 16);
end;
 merre:=1;
 if (abs(kul.y)>abs(kul.x)) then merre:=0;
 if (-kul.y>kul.x) then merre:=merre+2;
 //Ez már TÖKÉLETES. Már csak a gabalyodás-
 //gátló kell... Vagy a 3. stratégia.
 case merre of
  0:if kul.x>0 then begin if not fel(enhol) then if not jobb(enhol) then if not bal(enhol) then le(enhol) end
               else begin if not fel(enhol) then if not bal(enhol) then if not jobb(enhol) then le(enhol) end;
  2:if kul.x>0 then begin if not le(enhol) then if not jobb(enhol) then if not bal(enhol) then fel(enhol) end
               else begin if not le(enhol) then if not bal(enhol) then if not jobb(enhol) then fel(enhol) end;
  3:if kul.y>0 then begin if not jobb(enhol) then if not fel(enhol) then if not le(enhol) then bal(enhol) end
               else begin if not jobb(enhol) then if not le(enhol) then if not fel(enhol) then bal(enhol) end;
  1:if kul.y>0 then begin if not bal(enhol) then if not fel(enhol) then if not le(enhol) then jobb(enhol) end
               else begin if not bal(enhol) then if not le(enhol) then if not fel(enhol) then jobb(enhol) end;
end;
end;
end.

