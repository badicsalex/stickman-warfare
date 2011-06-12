unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    L0: TLabel;
    L1: TLabel;
    L2: TLabel;
    L3: TLabel;
    L4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  Tpoi=record
   x,y,irany:single;
   meddig:word;
   szin:Tcolor;
  end;

  Tjatekos=record
   pos:Tpoi;
   el:boolean;
   typ,pont:byte;
   jobb,bal:integer;
  end;

  T2dvec=record x,y:single; end;
var
  Form1: TForm1;
  Hol:Tpoi;
  Bot:Tpoi;
  jas:array [0..4] of Tjatekos;
  myb:Tbitmap;
  csakbotok:boolean;
const vec2null:T2dvec=(x:0;y:0);
procedure ujrakezd;
procedure fulluj;
implementation

{$R *.DFM}
function vec2kul(v1,v2:T2dvec):T2dvec;
begin
 result.x:=v1.x-v2.x;
 result.y:=v1.y-v2.y;
end;

function vec2x(v1,v2,v3:T2dvec):single;
begin
 result:=(v1.x-v3.x)*(v2.y-v3.y)-(v1.y-v3.y)*(v2.x-v3.x);
end;

function vec2(x,y:single):T2dvec;
begin
 result.x:=x; result.y:=y;
end;

function vec2Xtra(v1,v2,v3,v4:T2dvec):boolean;
begin
 result:=(vec2x(v1,v2,v3)*vec2x(v1,v2,v4)<=0) and
         (vec2x(v3,v4,v1)*vec2x(v3,v4,v2)<=0);
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
 randomize;
 myb:=Tbitmap.create;
 myb.width:=500;
 myb.height:=350;
 fulluj;
 ujrakezd;
end;

procedure fulluj;
var
i:integer;
begin
 jas[0].typ:=1;
 jas[1].typ:=2;
 jas[2].typ:=2;
 jas[3].typ:=2;
 jas[4].typ:=2;
 jas[0].pos.szin:=clgreen;
 jas[1].pos.szin:=clmaroon;
 jas[2].pos.szin:=clblue;
 jas[3].pos.szin:=clpurple;
 jas[4].pos.szin:=clteal;
 with form1 do begin
 L0.Font.Color:=jas[0].pos.szin;L1.Font.Color:=jas[1].pos.szin;
 L2.Font.Color:=jas[2].pos.szin;L3.Font.Color:=jas[3].pos.szin;
 L4.Font.Color:=jas[4].pos.szin;
 end;
  for i:=0 to high(jas) do jas[i].pont:=0;

 jas[0].jobb:=VK_RIGHT;
 jas[0].bal:=VK_LEFT;
end;

procedure ujrakezd;
var
i:integer;
begin
 for i:=0 to high(jas) do
 begin
  jas[i].pos.x:=50+random(400);
  jas[i].pos.y:=50+random(250);
  jas[i].pos.irany:=pi*random(1000)/500;
  if jas[i].typ>0 then
   jas[i].el:=true
  else
   jas[i].el:=false;
 end;
 //jas[0].pos.irany:=pi/2+random(10)/100;
 //jas[1].pos.irany:=-pi/2+random(10)/100;
 myb.canvas.brush.color:=clwhite;
 myb.canvas.pen.color:=clblack;
 myb.canvas.rectangle(0,0,499,349);
 csakbotok:=false;
end;

function ajjaj(x,y:single):boolean;
begin
 result:=false;
 if (x<0) or (y<0) or (x>500) or (y>350) then result:=true
 else
  if myb.canvas.pixels[round(x),round(y)]<>clwhite then result:=true;
end;

function hujjuj(x,y,mx,my:single):single;
var
i:integer;
mob:boolean;
begin
 mob:=false;
 result:=0;
 for i:=1 to 100 do
 begin
  mob:=mob or ajjaj(x+(mx-x)*i/100,y+(my-y)*i/100);
  if mob then
  begin
   result:=1-i/100;
   break;
  end;
 end;
end;

procedure killja(mit:byte);
var
i:integer;
begin
 jas[mit].el:=false;
 for i:=0 to high(jas) do
 begin
  if jas[i].el then inc(jas[i].pont);
 end;
 form1.L0.Caption:=inttostr(jas[0].pont);
 form1.L1.Caption:=inttostr(jas[1].pont);
 form1.L2.Caption:=inttostr(jas[2].pont);
 form1.L3.Caption:=inttostr(jas[3].pont);
 form1.L4.Caption:=inttostr(jas[4].pont);
end;

procedure dohuman(ezaz:byte);
var
mx,my:integer;
mit:Tpoi;
jobb,bal:integer;
begin
 if not jas[ezaz].el then exit;
 mit:=jas[ezaz].pos;
 jobb:=jas[ezaz].jobb;
 bal:=jas[ezaz].bal;
 mit.x:=mit.x+sin(mit.irany)*2;
 mit.y:=mit.y+cos(mit.irany)*2;

 if getasynckeystate(bal )<>0 then mit.irany:=mit.irany+pi/40;
 if getasynckeystate(jobb)<>0 then mit.irany:=mit.irany-pi/40;

 mx:=round(mit.x+sin(mit.irany)*3);
 my:=round(mit.y+cos(mit.irany)*3);
 if random(200)=0 then mit.meddig:=3+random(3);
 if ajjaj(mx,my) then
 begin
  killja(ezaz);
 end;
 jas[ezaz].pos:=mit;
end;

function akad(j1,j2:byte):single;
var
adst:single;
p1,p2,p3,p4:T2dvec;
begin
 result:=0;
 p1.x:=jas[j1].pos.x;
 p1.y:=jas[j1].pos.y;
 p2.x:=jas[j2].pos.x;
 p2.y:=jas[j2].pos.y;
 adst:=sqrt(sqr(p1.x-p2.x)+sqr(p1.y-p2.y)*1.2);
 if adst>100 then exit;
 p3.x:=p1.x+sin(jas[j1].pos.irany);
 p3.y:=p1.y+cos(jas[j1].pos.irany);
 p4.x:=p2.x+sin(jas[j2].pos.irany);
 p4.y:=p2.y+cos(jas[j2].pos.irany);
 if vec2Xtra(p1,p2,p3,p4) then
 begin
  p1:=vec2kul(p1,p2);
  p2.x:=sin(jas[j1].pos.irany);
  p2.y:=cos(jas[j1].pos.irany);
  if vec2x(p1,p2,vec2null)>0 then
   result:=5/adst
  else
   result:=-5/adst;
 end;

end;

procedure dobot(melyik:byte);
var
i,mx,my:integer;
msz,mst,maxsz,max,dst,mx2,my2:single;
mit:Tpoi;
begin
 if not jas[melyik].el then exit;
 mit:=jas[melyik].pos;
 mit.x:=mit.x+sin(mit.irany)*2;
 mit.y:=mit.y+cos(mit.irany)*2;
 max:=10;
 for i:=-10 to 10 do
 begin
  msz:=pi*0.5*i/10;
  mst:=hujjuj(mit.x+sin(mit.irany)*3,mit.y+cos(mit.irany)*3,mit.x+sin(mit.irany+msz)*(100),mit.y+cos(mit.irany+msz)*(100));
  if mst<max then
  begin
   max:=mst;
   maxsz:=msz;
  end;
  if (mst=0) and (max>abs(msz/10)-1) then
  begin
   max:=abs(msz/10)-1;
   maxsz:=msz;
  end;
 end;
 maxsz:=maxsz-0.1*hujjuj(mit.x+sin(mit.irany)*3,mit.y+cos(mit.irany)*3,mit.x+sin(mit.irany+pi/2)*(20),mit.y+cos(mit.irany+pi/2)*(20));
 maxsz:=maxsz+0.1*hujjuj(mit.x+sin(mit.irany)*3,mit.y+cos(mit.irany)*3,mit.x+sin(mit.irany-pi/2)*(20),mit.y+cos(mit.irany-pi/2)*(20));
 mx2:=mit.x-500/2;
 my2:=mit.y-350/2;
 dst:=sqrt(sqr(mx2)+sqr(my2));
 maxsz:=maxsz+0.001*(sin(mit.irany)*my2/dst-cos(mit.irany)*mx2/dst);
 maxsz:=maxsz+0.001*(random(3)-1);
 maxsz:=maxsz-akad(melyik,1-melyik);
 if maxsz>0 then mit.irany:=mit.irany+pi/40;
 if maxsz<0 then mit.irany:=mit.irany-pi/40;

 mx:=round(mit.x+sin(mit.irany)*3);
 my:=round(mit.y+cos(mit.irany)*3);
 if random(200)=0 then mit.meddig:=3+random(3);
 if ajjaj(mx,my) then killja(melyik);
 jas[melyik].pos:=mit;
end;

procedure draw1(var mit:Tpoi);
var
mx,my:integer;
begin
 myb.canvas.brush.color:=mit.szin;
 myb.canvas.pen.color:=mit.szin;
 mx:=round(mit.x);
 my:=round(mit.y);
 if mit.meddig>0 then dec(mit.meddig) else
 myb.canvas.ellipse(mx-2,my-2,mx+2,my+2);
end;

procedure draw2(var mit:Tpoi);
var
mx,my:integer;
begin
 form1.canvas.brush.color:=mit.szin;
 form1.canvas.pen.color:=mit.szin;
 mx:=round(mit.x);
 my:=round(mit.y);
 form1.canvas.ellipse(mx-2,my-2,mx+2,my+2);
end;

procedure doit;
var
i:integer;
elnek:byte;
begin
 with form1 do begin
 if clientwidth<>500 then clientwidth:=500;
 if clientheight<>420 then clientheight:=420;

 for i:=0 to high(jas) do
 begin
  if jas[i].typ=1 then dohuman(i);
  if jas[i].typ=2 then dobot(i);
  if jas[i].typ>0 then draw1(jas[i].pos);
 end;
 canvas.draw(0,0,myb);
 elnek:=0;
 csakbotok:=true;
 for i:=0 to high(jas) do
 begin
  if jas[i].el then inc(elnek);
  if jas[i].el and (jas[i].typ=1) then csakbotok:=false;
  if jas[i].typ>0 then draw2(jas[i].pos);
 end;
 if elnek<2 then ujrakezd;
 end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
i,j:integer;
begin
if csakbotok then j:=10 else j:=1;
for i:=1 to j do
doit;
end;

end.
