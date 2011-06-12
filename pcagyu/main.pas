unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,setting,mmsystem;

type
  Tgoly=record
   x,y,xseb,yseb:real;
   van:boolean;
  end;
  Tpix=record
   x,y,xseb,yseb:single;
   szin:Tcolor;
  end;
  TForm1 = class(TForm)
    Button1: TButton;
    graph: TPaintBox;
    Timer1: TTimer;
    Timer2: TTimer;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure graphMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure graphClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  procedure updt; //ez csak azért van itt
                  //mer' macerás lett volna
                  //áttenni
  procedure frm2cls; //ez má' fontos
var
  Form1: TForm1;
  ter,temp:Tbitmap;
  varp,varz:Tpoint;
  megvan1:boolean=true;
  megvan2,vv,pz,uk,mv:boolean;
  holsor2:array[0..400]of longint;
  pixek:array of Tpix;
  vx,vy,dd,szel,erop,eroz:integer;
  //A settings ezt settingeli:
  min,mode:integer;
  grav,szele,leg,dmb1,dmb2,vdst:integer;
  //Itt a vege
  irp:integer=90;
  irz:integer=-90;
  tavz:integer=23;
  tavp:integer=23;
  golyo:Tgoly;
implementation
{$R *.DFM}
function rndbrwn:Tcolor;
var
melyik:integer;
r,g:byte;
begin
melyik:=32+random(32);
r:=melyik*3;
g:=melyik*2;
result:=RGB(r,g,0);
end;
procedure TForm1.Button1Click(Sender: TObject);
var
i,hol,dst,meret1,meret2,r2:longint;
holsor:array[0..104,0..1]of longint;
label
eleje;
begin
randomize;
eleje:
golyo.van:=false;
setlength(pixek,0);
pz:=true;
dst:=52-vdst;
dd:=dst*16;
meret1:=9;
meret2:=25;
graph.Canvas.Rectangle(200,200,600,400);
hol:=random(50)+75;
for i:=0 to 104 do
begin
if not (((i>dst+2) and (dst+meret1+2>i)) or ((102-dst>i) and (i>102-dst-meret1))) then
if (random(20)>sqrt(hol)) or (dmb1>hol) then hol:=hol+dmb1 div 2 else hol:=hol-dmb1 div 2;
holsor[i,0]:=hol;
end;
dst:=dst+1;
graph.Canvas.pen.Color:=clred;
for i:=2 to 102 do
begin
holsor[i-2,1]:=(holsor[i-2,0]+holsor[i-1,0]+holsor[i,0]+holsor[i+1,0]+holsor[i+2,0]) div 5;
if (holsor[i-2,1]*3 div 2>197) or (2>holsor[i-2,1]*3 div 2) then goto eleje;
end;
graph.canvas.MoveTo(200,holsor[0,1]*3);
for i:=0 to 399 do
begin
if ((i>dst*4) and (dst*4+meret2+2>i)) or ((400-dst*4>i) and (i>400-dst*4-meret2-2)) then r2:=3 else r2:=random(dmb2);
holsor2[i]:=((holsor[i div 4,1]*(4-i mod 4))+(holsor[i div 4+1,1]*(i mod 4))) div 4+r2;
graph.canvas.lineto(i+200,holsor2[i]+200);
end;
holsor2[400]:=holsor[100,1];
graph.canvas.lineto(600,holsor2[400]+200);
if ter=nil then
begin
ter:=Tbitmap.Create;
ter.Width:=1600;
ter.Height:=800;
end;
megvan1:=false;
megvan2:=false;
end;
function minmax(a,b:longint;mnmx:boolean):integer;
begin
if (a>b) xor mnmx then result:=a else result:=b;
end;

procedure TForm1.graphMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
i,col:integer;
hov:Tpoint;
begin
if (not megvan2) and (not megvan1) then
begin
graph.Canvas.brush.Color:=claqua;
with graph.canvas.Font do
begin
 color:=clgreen;
 height:=-30;
 Name:='Arial black';
end;
with graph.Canvas do
TextOut(400-textwidth('LoAdInG')div 2,300-textheight('LoAdInG') div 2,'LoAdInG');
szel:=random(300)-150;
ter.Canvas.Pen.Color:=claqua;
ter.canvas.Brush.Color:=claqua;
ter.Canvas.Rectangle(0,0,1600,800);
if temp=nil then
begin
temp:=Tbitmap.Create;
temp.loadfromfile('var.bmp');
end;
ter.Canvas.Brush.Style:=bsclear;
ter.Canvas.BrushCopy(rect(dd+16,holsor2[10+dd div 4]*4-70,dd+116,holsor2[10+dd div 4]*4),temp,rect(0,0,100,70),claqua);
varp:=point(dd+116,holsor2[10+dd div 4]*4-70);
ter.Canvas.BrushCopy(rect(1500-32-dd,holsor2[380-dd div 4]*4-70,1600-32-dd,holsor2[380-dd div 4]*4),temp,rect(100,0,200,70),claqua);
varz:=point(1500-32-dd,holsor2[380-dd div 4]*4-70);
ter.Canvas.Brush.Style:=bssolid;
for col:=0 to 15 do
begin
ter.canvas.moveto(0,holsor2[0]*4+col);
ter.Canvas.pen.Color:=rgb(128,255-191*col div 15,0);
for i:=1 to 400 do
  ter.canvas.lineto(i*4,holsor2[i]*4+col);
ter.canvas.brush.color:=rgb(128,64,0);
ter.Canvas.FloodFill(800,600,claqua,fssurface);
for i:=0 to 3000 do
 begin
  repeat
  hov:=point(random(1600),random(1800));
  until hov.y>holsor2[hov.x div 4]*4+15;
  ter.canvas.pixels[hov.x,hov.y]:=rndbrwn;
 end;
end;
updt;
megvan2:=true;
end;
if not mv then button2click(button2);
vx:=x*4;
vy:=y*4;
end;

procedure TForm1.graphClick(Sender: TObject);
begin
if (golyo.van) or (length(pixek)>0) or uk then exit;
if pz then
begin
golyo.van:=true;
golyo.x:=varp.x;
golyo.y:=varp.y;
golyo.yseb:=0-cos(pi*irp/360)*tavp/2;
golyo.xseb:=sin(pi*irp/360)*tavp/2;
end
else
begin
golyo.van:=true;
golyo.x:=varz.x;
golyo.y:=varz.y;
golyo.yseb:=0-cos(pi*irz/360)*tavz/2;
golyo.xseb:=sin(pi*irz/360)*tavz/2;
end
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
//!!!!!!!!!Ezzel nagyon vigyázz!!!!!!!!!
//!!!!!!Stack overflow, meg ilyesmi!!!!!
//!!!!!!!!!Ide semmit ne tegyél!!!!!!!!!
end;
                        //igaz:vizszintes
function ellenor(hol:Tpoint;merre:boolean):boolean;
var
i:byte;
yo:boolean;
begin
if merre then
begin
hol.x:=hol.x-5;
yo:=true;
for i:=0 to 10 do
 yo:=yo and (ter.Canvas.Pixels[hol.x+i,hol.y+1]=claqua);
result:=not yo;
end
else
begin
hol.y:=hol.y-5;
yo:=true;
for i:=0 to 10 do
 yo:=yo and (ter.Canvas.Pixels[hol.x,hol.y+i]=claqua);
result:=not yo;
end;
end;

procedure boom2(honnan,hova:Tpoint;szam:integer);
var
kul,temp:tpoint;
dst,ax,ay:real;
i:integer;
begin
kul:=point(hova.x-honnan.x,hova.y-honnan.y);
dst:=sqrt(kul.x*kul.x+kul.y*kul.y);
if dst=0 then exit;
ax:=kul.x/dst;
ay:=kul.y/dst;
for i:=0 to round(dst) do
 begin
  temp:=point(round(i*ax+honnan.x),round(i*ay+honnan.y));
  if ter.Canvas.pixels[temp.x,temp.y-1]<>claqua then
  if 0>pixek[szam].yseb then
   begin
   pixek[szam].yseb:=-pixek[szam].yseb/1.5;
   pixek[szam].x:=-1;
   pixek[szam].y:=0;
   end
   else
   begin
   temp:=point(round((i-2)*ax+honnan.x),round((i-2)*ay+honnan.y));
    with ter.Canvas do
     begin
      pixels[temp.x,temp.y]:=pixek[szam].szin;
      pixek[szam]:=pixek[high(pixek)];
      setlength(pixek,high(pixek));
     end;
    exit;
   end;
 end;
end;

procedure szrep(hol:tpoint);
var
tmp:Tbitmap;
xi,yi:integer;
szam:integer;
begin
 tmp:=Tbitmap.create;
 tmp.width:=40;
 tmp.height:=40;
 tmp.Canvas.Brush.Color:=clblack;
 tmp.Canvas.Rectangle(0,0,40,40);
 tmp.canvas.Brush.color:=clwhite;
 tmp.canvas.Pen.Color:=clwhite;
 tmp.Canvas.Ellipse(0,0,40,40);
 bitblt(tmp.canvas.handle,0,0,40,40,ter.canvas.handle,hol.x,hol.y,SRCAND);
 setlength(pixek,400);
 szam:=0;
 for xi:=0 to 39 do
  for yi:=0 to 39 do
  if not((tmp.canvas.pixels[xi,yi]=clblack) or (tmp.canvas.pixels[xi,yi]=claqua)) then
   begin
    pixek[szam].x:=xi+hol.x;
    pixek[szam].y:=yi+hol.y-1;
    pixek[szam].xseb:=(random(100)-50)/7;
    pixek[szam].yseb:=-(random(150)+50)/15;
    pixek[szam].szin:=tmp.canvas.pixels[xi,yi];
    szam:=szam+1;
    if szam>high(pixek) then
    setlength(pixek,szam+128);
   end;
   setlength(pixek,szam+1);
end;

procedure rep;
var
i:integer;
begin
i:=0;
repeat
pixek[i].yseb:=(pixek[i].yseb+grav/20)/(1+leg/50);
pixek[i].xseb:=(pixek[i].xseb-szel/15)/(1+leg/50)+szel/15;
pixek[i].y:=pixek[i].y+pixek[i].yseb;
pixek[i].x:=pixek[i].x+pixek[i].xseb;
if (5>pixek[i].x) or (pixek[i].x>1595) then
begin
 pixek[i]:=pixek[high(pixek)];
 setlength(pixek,high(pixek));
end
else
boom2( point(round(pixek[i].x-pixek[i].xseb),round(pixek[i].y-pixek[i].yseb)),
       point(round(pixek[i].x),round(pixek[i].y)),i);
i:=i+1;
until i>high(pixek);
end;

procedure boom(honnan,hova:Tpoint);
var
kul,temp:tpoint;
dst,ax,ay:real;
i:integer;
oye:string;
begin
if (5>hova.y) or (5>honnan.y) then exit;
kul:=point(hova.x-honnan.x,hova.y-honnan.y);
dst:=sqrt(kul.x*kul.x+kul.y*kul.y);
ax:=kul.x/dst;
ay:=kul.y/dst;
for i:=0 to round(dst) do
 begin
  temp:=point(round(i*ax+honnan.x),round(i*ay+honnan.y));
  if ellenor(temp,true) or ellenor(temp,false) then
   begin
    temp:=point(round((i+7)*ax+honnan.x),round((i+7)*ay+honnan.y));
    with ter.Canvas do
     begin
      oye:=extractfiledir(application.exename)+'\exp3.wav';
      PlaySound(Pchar(oye),application.handle,SND_FILENAME+SND_ASYNC);
      //if oye='' then golyo.van:=false;
      szrep(point(temp.x-20,temp.y-20));
      pen.Color:=claqua;
      brush.color:=claqua;
      ellipse(temp.x-20,temp.y-20,temp.x+20,temp.y+20);
      golyo.van:=false;
     end;
    exit;
   end;
 end;
end;

procedure updt;
var
tmp:Tbitmap;
ix,iy:integer;
begin
tmp:=Tbitmap.create;
tmp.Width:=200;
tmp.Height:=70;
tmp.Canvas.CopyRect(rect(100,0,200,70),ter.Canvas,rect(1500-32-dd,holsor2[380-dd div 4]*4-70,1600-32-dd,holsor2[380-dd div 4]*4));
tmp.Canvas.CopyRect(rect(0,0,100,70),ter.canvas,rect(dd+16,holsor2[10+dd div 4]*4-70,dd+116,holsor2[10+dd div 4]*4));
erop:=0;
eroz:=0;
for ix:=0 to 100 do
 for iy:=0 to 70 do
  case mode of
   0:if tmp.Canvas.Pixels[ix,iy]<>claqua then erop:=erop+1;
   1:if tmp.Canvas.Pixels[ix,iy]=clred then erop:=erop+1;
   2:if tmp.Canvas.Pixels[ix,iy]=clyellow then erop:=erop+1;
  end;
for ix:=100 to 200 do
 for iy:=0 to 70 do
  case mode of
   0:if tmp.Canvas.Pixels[ix,iy]<>claqua then eroz:=eroz+1;
   1:if tmp.Canvas.Pixels[ix,iy]=clgreen then eroz:=eroz+1;
   2:if tmp.Canvas.Pixels[ix,iy]=clyellow then eroz:=eroz+1;
  end;
 if min>eroz then
 begin
  form1.graph.Canvas.brush.Color:=claqua;
  with form1.graph.canvas.Font do
  begin
   color:=clred;
   height:=-30;
   Name:='Arial black';
  end;
  with form1.graph.Canvas do
   TextOut(400-textwidth('Nyert a piros vár!')div 2,300-textheight('Nyert a piros vár!') div 2,'Nyert a piros vár!');
  megvan1:=true;
 end;
 if min>erop then
 begin
  form1.graph.Canvas.brush.Color:=claqua;
  with form1.graph.canvas.Font do
  begin
   color:=clgreen;
   height:=-30;
   Name:='Arial black';
  end;
  with form1.graph.Canvas do
   TextOut(400-textwidth('Nyert a zöld vár!')div 2,300-textheight('Nyert a zöld vár!') div 2,'Nyert a zöld vár!');
  megvan1:=true;
 end;
tmp.Destroy;
end;
procedure TForm1.Timer1Timer(Sender: TObject);
begin
if length(pixek)>0 then rep;
if golyo.van then
begin
if (golyo.x>1600) or (0>golyo.x) then
begin
golyo.van:=false;
exit;
end;
golyo.yseb:=(golyo.yseb+grav/10)/(1+leg/100);
golyo.xseb:=(golyo.xseb-szel/5)/(1+leg/100)+szel/5;
boom(point(round(golyo.x),round(golyo.y)),point(round(golyo.x+golyo.xseb),round(golyo.y+golyo.yseb)));
golyo.y:=golyo.y+golyo.yseb;
golyo.x:=golyo.x+golyo.xseb;
end;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
var
graph2:Tbitmap;
x,y,ax,ay,i:integer;
nyil:array [0..2] of Tpoint;
ize:Tpoint;
begin
if megvan1 then exit;
x:=vx div 4;
y:=vy div 4;
if (golyo.van) or (length(pixek)>0) then
begin
x:=round(golyo.x) div 2;
y:=round(golyo.y) div 2;
uk:=true;
end
else
if uk then
begin
pz:=not pz;
uk:=false;
if pz then
ize:=clienttoscreen(point(varp.x div 2,varp.y div 2))
else
ize:=clienttoscreen(point(varz.x div 2,varz.y div 2));
setcursorpos(ize.x,ize.y);
x:=ize.x;
y:=ize.y;
if random(10)=0 then szel:=0 else szel:=random(szele*20)-szele*10;
updt;
if megvan1 then exit;
end;
graph2:=Tbitmap.Create;
graph2.Width:=800;
graph2.Height:=600;
ax:=minmax(400,minmax(1200,x*2,true),false);
ay:=minmax(300,minmax(500,y*2,true),false);
if megvan2 then graph2.canvas.CopyRect(rect(0,0,800,600),ter.canvas,rect(ax-400,ay-300,ax+400,ay+300));
graph2.Canvas.pen.Color:=clsilver;
graph2.Canvas.brush.Color:=clgray;
if golyo.van then graph2.canvas.Ellipse(round(golyo.x)-5-ax+400,round(golyo.y)-5-ay+300,round(golyo.x)+5-ax+400,round(golyo.y)+5-ay+300);
if length(pixek)>0 then
for i:=0 to high(pixek) do
 if (pixek[i].x-ax+400>0) and (800>pixek[i].x-ax+400) and (pixek[i].y-ay+300>0) and (600>pixek[i].y-ay+300) then
  graph2.Canvas.Pixels[round(pixek[i].x-ax+400),round(pixek[i].y-ay+300)]:=pixek[i].szin;
graph2.Canvas.pen.Color:=clnavy;
if not ((golyo.van) or (length(pixek)>0)) then
begin
if pz then
begin
graph2.canvas.moveto(varp.x-ax+400,varp.y-ay+300);
graph2.canvas.lineto(varp.x-ax+400+round(sin(pi*irp/360)*tavp/1.5),
                     varp.y-ay+300+round(0-cos(pi*irp/360)*tavp/1.5));
end
else
begin
graph2.canvas.moveto(varz.x-ax+400,varz.y-ay+300);
graph2.canvas.lineto(varz.x-ax+400+round(sin(pi*irz/360)*tavz/1.5),
                     varz.y-ay+300+round(0-cos(pi*irz/360)*tavz/1.5));
end;
end;
with graph2.canvas do
begin
pen.Width:=3;
if szel>0 then pen.color:=clgreen else pen.color:=clred;
moveto(400,20);
lineto(400+szel,20);
pen.Width:=1;
if szel>=0 then
begin
brush.Color:=clgreen;
pen.Color:=clgreen;
nyil[0]:=point(410+szel,20);
nyil[1]:=point(400+szel,10);
nyil[2]:=point(400+szel,30);
polygon(nyil);
end;
if 0>=szel then
begin
brush.Color:=clred;
pen.Color:=clred;
nyil[0]:=point(390+szel,20);
nyil[1]:=point(400+szel,10);
nyil[2]:=point(400+szel,30);
polygon(nyil);
end;
brush.Color:=rgb(128,64,0);
font.size:=12;
font.Color:=claqua;
textout(varp.x-ax+350-textwidth(inttostr(eroz)) div 2,varp.y-ay+400,inttostr(erop));
textout(varz.x-ax+450-textwidth(inttostr(eroz)) div 2,varz.y-ay+400,inttostr(eroz));
end;
if megvan2 then graph.Canvas.Draw(0,0,graph2);
graph2.Destroy;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if key=VK_ESCAPE then form1.close;
if key=VK_F1 then application.HelpJump('PCAGYUABOUT');
if pz then
 case key of
  ord('E'):graphclick(Form1);
  ord('W'):irp:=(irp-1+720) mod 720;
  ord('S'):irp:=(irp+1+720) mod 720;
  ord('A'):tavp:=minmax(tavp-1,20,false);
  ord('D'):tavp:=minmax(tavp+1,120,true);
 end
else
 case key of
  ord('E'):graphclick(Form1);
  ord('W'):irz:=(irz+1+720) mod 720;
  ord('S'):irz:=(irz-1+720) mod 720;
  ord('D'):tavz:=minmax(tavz-1,20,false);
  ord('A'):tavz:=minmax(tavz+1,120,true);
 end
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
mv:=true;
form1.Enabled:=false;
application.CreateForm(Tform2,form2);
form2.Show;
end;

procedure frm2cls;
begin
min:=ali[1];
mode:=ali[2];
grav:=ali[3];
szele:=ali[4];
leg:=ali[5];
dmb1:=ali[6];
dmb2:=ali[7];
vdst:=ali[8];
form1.Enabled:=true;
end;

end.
