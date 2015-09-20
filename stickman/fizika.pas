unit fizika;

interface
uses
  Direct3D9,
  D3DX9,
  typestuff,
  windows,
  muksoka;
const
 koteshossz:array [0..9] of single = (0.4,0.4,0.4,0.4,0.6,0.3,0.3,0.3,0.3,0.1);
 felshiftek:array [1..5] of integer = (0,35,85,130,180);
 leshiftek:array [1..5] of integer = (15,70,110,150,1000);
 fordulatok:array [1..5] of single = (0,3.8729,6.3245,8.9442,10.6189);
type

 TRongybaba = class (TObject)
 public
  ID:cardinal;
  disabled:boolean;
  ido:cardinal;
  gmbk,voltgmbk:Tgmbk;                                  //meglövési erõ      meglõtt gömb
  szin:cardinal;
  constructor create(mat:TD3DMatrix;Muks:TMuksoka;pos,vpos,gmbvec:TD3DXVector3;mlgmb:byte;azID,aszin:cardinal);
  procedure step(advwove:Tadvwove;nondis:boolean;bubi:boolean);
  procedure transfertomuks(muks:Tmuksoka);
 end;

 TTegla = class (Tobject)
 public
  ID:cardinal;
  disabled:boolean;
  ido:cardinal;
  pontok,vpontok,vp:T7pbox;
  {LENT  FENT
   0 2   4 6

   1 3   5 7 }
  axes:array [0..2] of TD3DXVector3; // hossz szél mag
  pos,vpos:TD3DXVector3;
  axehossz,axearany:array [0..2] of single;
  friction,zsele:single;                                    //0..1 minél több annál jobban csúszik
  vmi,vma:TD3DXVector3;
  procedure remakepontokfromaxes;
  procedure remakeaxesfrompontok;
  constructor create(axe1,axe2,axe3,apos,seb:TD3DXVector3;afriction,azsele:single);
  procedure step;
  procedure constraintoter(advwove:Tadvwove);
  procedure constraintoteg;
  function matrixfromaxes:TD3DMatrix;
  function SATtri(tri:Tacctri):boolean;
 // function SATray(v1,v2:TD3DXVector3):boolean;
 end;

 Tkerekarray = array [0..3] of TD3DXVector3;
 TAuto = class (TTegla)
 public
  kerekek,vkerekek,kerekorig:Tkerekarray;
  kerekhely:Tkerekarray;
  kerekbol:array [0..3] of boolean;
  kerekirany:integer;
  felf,felfero,felfdamp,kereknagy,kerekvst:single;
  maxseb,nyomatek:single;
  k1,k2,k3:single;
  kx1,kx2:array [0..31] of single;
  kerekiranyszorzo:single;
  elore,fek,jobb,bal,iranyitjak:boolean;
  kerekfor:single;
  atlagseb:TD3DXVector3;
  fordulatszam,porgetes:single;
  pillspd:single;
  shift:integer;
  agx:boolean;
  kerekfriction:single;
  lastsebgtc:Cardinal;
  sebcache:single;
  function getseb:single;
  function getmotionvec:TD3DXVector3;
  function kerektransformmatrix(mit:integer):TD3DMatrix;
  constructor create(axe1,axe2,axe3,apos,seb:TD3DXVector3;afriction,azsele:single;akerekhely:Tkerekarray;afelf,afelfero,afelfdamp,akereknagy,akerekvst,akerekfriction,amaxseb,anyomatek:single;aantigrav:boolean);
  procedure initkerekek;
  procedure usekerekek;
  procedure step;
  procedure iranyit(aelore,afek,ajobb,abal,airanyitjak:boolean);
 end;

var
 kim:integer;
 kic:array [0..12] of integer;
var
 hummkerekarr:Tkerekarray=((x:-1;y:-1;z:0.8),(x:-1;y:-1;z:-0.7),(x:1;y:-1;z:0.8),(x:1;y:-1;z:-0.7));
 agkerekarr:Tkerekarray=((x:-0.9;y:-1;z:1),(x:-0.9;y:-1;z:-0.9),(x:0.9;y:-1;z:1),(x:0.9;y:-1;z:-0.9));
implementation

procedure constraintvectav(var v1,v2:TD3DXVector3;const tav:single);
var
tmp:TD3DXVector3;
dlngt,tmplngt:single;
begin
  d3dxvec3subtract(tmp,v2,v1);
  tmplngt:=d3dxvec3lengthsq(tmp)+tav*tav;
  if tmplngt<0.00001 then tmplngt:=1;
  dlngt:=tav*tav/(tmplngt)-0.5;
  d3dxvec3scale(tmp,tmp,dlngt);
  d3dxvec3subtract(v1,v1,tmp);
  d3dxvec3add     (v2,v2,tmp);
end;


constructor TRongybaba.create(mat:TD3DMatrix;Muks:TMuksoka;pos,vpos,gmbvec:TD3DXVector3;mlgmb:byte;azID,aszin:cardinal);
var
sub:TD3DXVector3;
i:integer;
begin
 ID:=azID;
 d3dxvec3transformcoordarray(addr(gmbk[0]),sizeof(TD3DXVector3),addr(muks.gmbk[0]),sizeof(TD3DXVector3),mat,length(gmbk));
 d3dxvec3subtract(sub,vpos,pos);
 if d3dxvec3lengthsq(sub)>100 then sub:=d3dxvector3zero;
 for i:=0 to high(gmbk) do
 begin
  constraintvec(gmbk[i]);
  d3dxvec3add(voltgmbk[i],gmbk[i],sub);
  voltgmbk[i].y:=gmbk[i].y;
 end;
 constraintvec(gmbvec);
// if (mlgmb>=0) and ( mlgmb<=high(gmbk)) then
 d3dxvec3add(gmbk[mlgmb],gmbk[mlgmb],gmbvec);
 szin:=aszin;
 ido:=0;
 disabled:=false;
end;

procedure TRongybaba.step(advwove:Tadvwove;nondis:boolean;bubi:boolean);
var
i,j:integer;
tmp,pa,pb,norm:TD3DXVector3;
dlngt,lngt,tmplngt:single;
v24y,v13y:single;
bol:boolean;
begin
 ido:=ido+1;

 if disabled and (not nondis) then exit;

 for i:=0 to high(gmbk) do
 begin
  noNANINF(gmbk[i]);
  constraintvec(voltgmbk[i]);
  if (gmbk[i].x<-5000) or (gmbk[i].x>5000) then gmbk[i].x:=voltgmbk[i].x;
  if (gmbk[i].y<-5000) or (gmbk[i].y>5000) then gmbk[i].y:=voltgmbk[i].y;
  if (gmbk[i].z<-5000) or (gmbk[i].z>5000) then gmbk[i].z:=voltgmbk[i].z;

  tmp:=gmbk[i];
  //gmbk[i]:=gmbk[i]*2-voltgmbk[i];
  if ((gmbk[i].y<10) and not bubi) then begin
  //vízben
  gmbk[i].x:=gmbk[i].x +(gmbk[i].x-voltgmbk[i].x)*0.98;
  gmbk[i].y:=gmbk[i].y +(gmbk[i].y-voltgmbk[i].y)*0.98+GRAVITACIO/30;
  gmbk[i].z:=gmbk[i].z +(gmbk[i].z-voltgmbk[i].z)*0.98;
  end
  else
  begin
  gmbk[i].x:=gmbk[i].x*2-voltgmbk[i].x;
  gmbk[i].y:=gmbk[i].y*2-voltgmbk[i].y-GRAVITACIO/5;
  gmbk[i].z:=gmbk[i].z*2-voltgmbk[i].z;
  end;
  voltgmbk[i]:=tmp;
  if i=10 then
  dlngt:=advwove(gmbk[i].x,gmbk[i].z)+fejvst
  else
  dlngt:=advwove(gmbk[i].x,gmbk[i].z)+vst;
  if gmbk[i].y<dlngt then
  begin
   v24y:=advwove(gmbk[i].x,gmbk[i].z-1)- advwove(gmbk[i].x,gmbk[i].z+1);
   //v1-v3
   v13y:=advwove(gmbk[i].x-1,gmbk[i].z)-advwove(gmbk[i].x+1,gmbk[i].z);
   //Döbbenetes az egyszerûsítés
   norm.x:=v13y;
   norm.y:=2;
   norm.z:=v24y;
   lngt:=d3dxvec3lengthsq(norm);
   if lngt<0.00001 then lngt:=1;
   d3dxvec3scale(norm,norm,fastinvsqrt(lngt));
   if abs(norm.y)<0.0001 then norm.y:=1;
   d3dxvec3scale(norm,norm,(dlngt-gmbk[i].y)/norm.y);
   //gmbk[i].y:=dlngt;
   d3dxvec3add(gmbk[i],gmbk[i],norm);
   d3dxvec3lerp(voltgmbk[i],voltgmbk[i],gmbk[i],0.2);

  end;
 end;


 { sqrt approximation
 delta = x2-x1;
delta*=restlength*restlength/(delta*delta+restlength*restlength)-0.5;
x1 -= delta;
x2 += delta;}
 for i:=0 to high(alapkapcsk) do
 begin
 // gmbk[alapkapcsk[i,0]]
  d3dxvec3subtract(tmp,gmbk[alapkapcsk[i,1]],gmbk[alapkapcsk[i,0]]);
  tmplngt:=d3dxvec3lengthsq(tmp)+koteshossz[i]*koteshossz[i];
  if tmplngt<0.00001 then tmplngt:=1;
  dlngt:=(koteshossz[i]*koteshossz[i])/(tmplngt)-0.5;
  d3dxvec3scale(tmp,tmp,dlngt);
  d3dxvec3subtract(gmbk[alapkapcsk[i,0]],gmbk[alapkapcsk[i,0]],tmp);
  d3dxvec3add     (gmbk[alapkapcsk[i,1]],gmbk[alapkapcsk[i,1]],tmp);

  for j:=i+1 to high(alapkapcsk) do
   if (alapkapcsk[i,0]<>alapkapcsk[j,0]) and  (alapkapcsk[i,1]<>alapkapcsk[j,1]) and
      (alapkapcsk[i,1]<>alapkapcsk[j,0]) and  (alapkapcsk[i,0]<>alapkapcsk[j,1]) then
    if tavlinelinesq(gmbk[alapkapcsk[i,0]],gmbk[alapkapcsk[i,1]],gmbk[alapkapcsk[j,0]],gmbk[alapkapcsk[j,1]],
                     pa,pb,dlngt) then
     if dlngt<vst*vst then
     begin
      d3dxvec3subtract(tmp,pa,pb);
      if dlngt<0.00001 then dlngt:=1;
      dlngt:=sqrt(dlngt);
      dlngt:=(vst-dlngt)/dlngt;
      d3dxvec3scale(tmp,tmp,dlngt/2);
      d3dxvec3add     (gmbk[alapkapcsk[i,0]],gmbk[alapkapcsk[i,0]],tmp);
      d3dxvec3add     (gmbk[alapkapcsk[i,1]],gmbk[alapkapcsk[i,1]],tmp);
      d3dxvec3subtract(gmbk[alapkapcsk[j,0]],gmbk[alapkapcsk[j,0]],tmp);
      d3dxvec3subtract(gmbk[alapkapcsk[j,1]],gmbk[alapkapcsk[j,1]],tmp);
     end;
 end;

 for i:=0 to high(gmbk) do
 begin
  noNANINF(gmbk[i]);
  constraintvec(voltgmbk[i]);
  constraintvec(gmbk[i]);
 end;

 bol:=true;
 for i:=0 to high(gmbk) do
 begin
  if tavpointpointsq(voltgmbk[i],gmbk[i])<sqr(0.001) then  gmbk[i]:=voltgmbk[i]
  else bol:=false;
 end;
 disabled:=bol;
 
end;

procedure TRongybaba.transfertomuks(muks:Tmuksoka);
begin
 muks.gmbk:=gmbk;
end;



procedure Ttegla.remakepontokfromaxes;
var
fen,len,job,bal,elo,hat:TD3DXVector3;
i:integer;
begin
 fen:=axes[2];
 D3DXVec3scale(len,fen,-1);
 job:=axes[1];
 D3DXVec3scale(bal,job,-1);
 elo:=axes[0];
 D3DXVec3scale(hat,elo,-1);
 pontok[0]:=vec3add3(bal,len,elo);
 pontok[1]:=vec3add3(bal,len,hat);
 pontok[2]:=vec3add3(job,len,elo);
 pontok[3]:=vec3add3(job,len,hat);
 pontok[4]:=vec3add3(bal,fen,elo);
 pontok[5]:=vec3add3(bal,fen,hat);
 pontok[6]:=vec3add3(job,fen,elo);
 pontok[7]:=vec3add3(job,fen,hat);
 vmi:=d3DXVector3(2000,2000,2000);
 vma:=d3DXVector3(-2000,-2000,-2000);
 for i:=0 to 7 do
 begin
  d3dxvec3add(pontok[i],pontok[i],pos);
  d3dxvec3minimize(vmi,vmi,pontok[i]);
  d3dxvec3maximize(vma,vma,pontok[i]);
 end;

end;

  {LENT  FENT
   0 2   4 6

   1 3   5 7 }
procedure Ttegla.remakeaxesfrompontok;
var
a1,a2,a3,a:TD3DXVector3;
i:integer;
begin
 a:=d3dxvector3zero;
 for i:=0 to 7 do
  d3dxvec3add(a,a,pontok[i]);
 d3dxvec3scale(pos,a,1/8);
 a1:=vec3add4(pontok[0],pontok[2],pontok[4],pontok[6]);
 a2:=vec3add4(pontok[2],pontok[3],pontok[6],pontok[7]);
 a3:=vec3add4(pontok[4],pontok[6],pontok[5],pontok[7]);

 d3dxvec3scale(a1,a1,2);
 d3dxvec3subtract(a1,a1,a);

 d3dxvec3scale(a2,a2,2);
 d3dxvec3subtract(a2,a2,a);

 d3dxvec3scale(a3,a3,2);
 d3dxvec3subtract(a3,a3,a);

 constraintvectav(a1,a2,axearany[0]);
 constraintvectav(a2,a3,axearany[1]);
 constraintvectav(a3,a1,axearany[2]);

 fastvec3normalize(a1);
 d3dxvec3scale(axes[0],a1,axehossz[0]);
 fastvec3normalize(a2);
d3dxvec3scale(axes[1],a2,axehossz[1]);
 fastvec3normalize(a3);
d3dxvec3scale(axes[2],a3,axehossz[2]);
end;

procedure Ttegla.step;
var
i:integer;
begin
 if disabled then exit;
  vpos:=pos;
 vp:=pontok;
 for i:=0 to 7 do
 begin
 if (pontok[i].y<10) then
 begin
  pontok[i].x:=pontok[i].x+(pontok[i].x-vpontok[i].x)*0.95;
  pontok[i].y:=pontok[i].y+(pontok[i].y-vpontok[i].y)*0.95-GRAVITACIO*0.45;
  pontok[i].z:=pontok[i].z+(pontok[i].z-vpontok[i].z)*0.95;
 end
 else
 begin
  pontok[i].x:=pontok[i].x*2-vpontok[i].x;
  pontok[i].y:=pontok[i].y*2-vpontok[i].y-GRAVITACIO;
  pontok[i].z:=pontok[i].z*2-vpontok[i].z;
 end;
 end;
 vpontok:=vp;
end;


constructor Ttegla.create(axe1,axe2,axe3,apos,seb:TD3DXVector3;afriction,azsele:single);
var
i:integer;
begin
 inherited create;
 d3dxvec3scale(axes[0],axe1,-1);
 d3dxvec3scale(axes[1],axe2,-1);
 d3dxvec3scale(axes[2],axe3,-1);
 for i:=0 to 2 do
  axehossz[i]:=d3dxvec3length(axes[i]);

 axearany[0]:=tavpointpoint(axes[0],axes[1])*8;
 axearany[1]:=tavpointpoint(axes[1],axes[2])*8;
 axearany[2]:=tavpointpoint(axes[2],axes[0])*8;

 pos:=apos;
 
 remakepontokfromaxes;
 //remakeaxesfrompontok;

 for i:=0 to 7 do
  randomplus(pontok[i],i+random(20),0.01);
 remakeaxesfrompontok;
 remakepontokfromaxes;

 for i:=0 to 7 do
  d3dxvec3subtract(vpontok[i],pontok[i],seb);

 vpos:=pos;
 friction:=afriction;
 zsele:=azsele;
end;

procedure Ttegla.constraintoter(advwove:Tadvwove);
var
i:integer;
mi:single;
v24y,v13y,lngt:single;
norm:TD3DXVector3;
//resety:boolean;
begin
 //resety:=false;
 for i:=0 to 7 do
 begin
  mi:=advwove(pontok[i].x,pontok[i].z);
  if pontok[i].y<mi then
  begin
   v24y:=advwove(pontok[i].x,pontok[i].z-1)- advwove(pontok[i].x,pontok[i].z+1);
   //v1-v3
   v13y:=advwove(pontok[i].x-1,pontok[i].z)-advwove(pontok[i].x+1,pontok[i].z);
   //Döbbenetes az egyszerûsítés
   norm.x:=v13y;
   norm.y:=2;
   norm.z:=v24y;
   lngt:=d3dxvec3length(norm);
   if lngt<0.00001 then lngt:=1;
   d3dxvec3scale(norm,norm,1/(lngt));
   
   d3dxvec3scale(norm,norm,(mi-pontok[i].y)/norm.y);

   d3dxvec3add(pontok[i],pontok[i],norm);
   //pontok[i].y:=pontok[i].y+norm.y;
   d3dxvec3lerp(vpontok[i],vpontok[i],pontok[i],friction);
   //resety:=true;
  end;
 end;
 //if resety then
 //for i:=0 to 7 do
 // vpontok[i].y:=pontok[i].y;
end;

procedure Ttegla.constraintoteg;
begin
 if disabled then exit;
 remakeaxesfrompontok;
 remakepontokfromaxes;
end;

function Ttegla.matrixfromaxes:TD3DMatrix;
begin
 with result do
 begin
  _11:=axes[1].x;  _12:=axes[1].y;  _13:=axes[1].z;  _14:=0;
  _21:=axes[2].x;  _22:=axes[2].y;  _23:=axes[2].z;  _24:=0;
  _31:=axes[0].x;  _32:=axes[0].y;  _33:=axes[0].z;  _34:=0;
  _41:=pos.x;      _42:=pos.y;      _43:=pos.z;      _44:=1;
 end;
end;


function Ttegla.SATtri(tri:Tacctri):boolean;
var
tmp,tmp2:TD3DXVector3;
tmpbb:T7pboxbol;
mst:single;
min:single;
minv:TD3DXVector3;
i:integer;
bolbox:T7pboxbol;
oszt:integer;
const
olsc=1;
osztlookup:array [0..8] of single = (olsc,olsc,olsc/2,olsc/3,olsc/4,olsc/5,olsc/6,olsc/7,olsc/8);
begin
 kim:=0;
 result:=false;
 min:=1000;
 minv:=d3dxvector3zero;

 for i:=0 to 7 do
  tmpbb[i]:=true;

 tmp:=tri.n;
 mst:=doSAT(pontok,tmpbb,tri,tmp);
 if mst<min then
  if mst=0 then
  exit
 else
 begin
  minv:=tmp;
  min:=mst;
  bolbox:=tmpbb;
 end;


 for i:=0 to 2 do
 begin
  tmp:=axes[i];
  mst:=doSAT(pontok,tmpbb,tri,tmp);
  if mst<min then
   if mst<=0 then exit else
   begin min:=mst; bolbox:=tmpbb; minv:=tmp; end;

  d3dxvec3subtract(tmp2,tri.v1,tri.v2);
  d3dxvec3cross(tmp,tmp2,axes[i]);
  mst:=doSAT(pontok,tmpbb,tri,tmp);
  if mst<min then
   if mst=0 then exit else
  begin min:=mst; bolbox:=tmpbb; minv:=tmp; end;


  d3dxvec3subtract(tmp2,tri.v2,tri.v0);
  d3dxvec3cross(tmp,tmp2,axes[i]);
  mst:=doSAT(pontok,tmpbb,tri,tmp);
  if mst<min then
   if mst=0 then exit else
  begin min:=mst; bolbox:=tmpbb; minv:=tmp; end;


  d3dxvec3subtract(tmp2,tri.v0,tri.v1);
  d3dxvec3cross(tmp,tmp2,axes[i]);
  mst:=doSAT(pontok,tmpbb,tri,tmp);
  if mst<min then
   if mst=0 then exit else
  begin min:=mst; bolbox:=tmpbb; minv:=tmp; end;


 end;

 oszt:=0;
 for i:=0 to 7 do
  if bolbox[i] then
   inc(oszt);

 d3dxvec3scale(minv,minv,osztlookup[oszt]);

 for i:=0 to 7 do
  if bolbox[i] then
  begin
   d3dxvec3add(pontok[i],pontok[i],minv);
  end;

 for i:=0 to 7 do
  if bolbox[i] then
  begin
   d3dxvec3lerp(vpontok[i],vpontok[i],pontok[i],friction);
  end;
end;

{function SATray(v1,v2:TD3DXVector3):boolean;
var
tmp:TD3DXVector3;
tmpbb:T7pboxbol;
mst:single;
min:single;
minv:TD3DXVector3;
i:integer;
bolbox:T7pboxbol;
mennyivel:TD3DXVector3;
begin
 //tmp:=tri.n;
 //if 0=doSAT(pontok,tmpbb,tri,tmp) then exit;
end;
     }

//AUTÓ CLASS ITT

constructor Tauto.create(axe1,axe2,axe3,apos,seb:TD3DXVector3;afriction,azsele:single;akerekhely:Tkerekarray;afelf,afelfero,afelfdamp,akereknagy,akerekvst,akerekfriction,amaxseb,anyomatek:single;aantigrav:boolean);
var
i:integer;
tmp,tmp2:TD3DXVector3;
begin
 inherited create(axe1,axe2,axe3,apos,seb,afriction,azsele);
 agx:=aantigrav;
 for i:=0 to 3 do
  kerekhely[i]:=akerekhely[i];
 kerekirany:=0;
 felf:=afelf;
 felfero:=afelfero;
 felfdamp:=afelfdamp;
 kereknagy:=akereknagy;
 kerekvst:=akerekvst;
 kerekfriction:=akerekfriction;
 maxseb:=amaxseb;
 nyomatek:=anyomatek;
 k2:=-kerekvst/axehossz[1];
 k1:=kereknagy/axehossz[0];
 k3:=kereknagy/axehossz[2];
 kerekiranyszorzo:=0.6;
 fordulatszam := 0;
 porgetes :=0;
 shift := 1;
 for i:=0 to 31 do
 begin
  d3dxvec3lerp(tmp,axes[0],axes[1],i*kerekiranyszorzo/32);
  if d3dxvec3length(tmp)>0 then
   kx1[i]:=kereknagy/d3dxvec3length(tmp)
  else
   kx1[i]:=1;
  d3dxvec3cross(tmp2,tmp,axes[2]);
  if d3dxvec3length(tmp2)>0 then
   kx2[i]:=kerekvst/d3dxvec3length(tmp2)
  else
   kx2[i]:=1;
 end;
 initkerekek;
 kerekfor:=0;
end;

procedure Tauto.initkerekek;
var
tmp:TD3DXVector3;
i:integer;
begin
 vkerekek:=kerekek;
 d3dxvec3transformcoordarray(@(kerekorig[0]),sizeof(TD3DXVector3),@(kerekhely[0]),sizeof(TD3DXVector3),matrixfromaxes,4);

 if agx then
 tmp:=D3DXVector3(0,-felf*1.5,0)
 else
 d3dxvec3scale(tmp,axes[2],-felf);
 
 for i:=0 to 3 do
  d3dxvec3add(kerekek[i],kerekorig[i],tmp);
end;

procedure Tauto.usekerekek;
var
tmp,tmp2,a1,a2:TD3DXVector3;
i,j:integer;
elorescale,tt:single;
begin

 if agx then
  tmp:=D3DXVector3(0,-felf,0)
 else
  d3dxvec3scale(tmp,axes[2],-felf);
 elorescale:=(maxseb-tavpointpointsq(pos,vpos))*nyomatek/maxseb;

 for i:=0 to 3 do
 begin
  d3dxvec3subtract(tmp2,kerekek[i],vkerekek[i]);

  d3dxvec3add(atlagseb,atlagseb,tmp2);
  if kerekbol[i] then
  begin
   //d3dxvec3subtract(tmp2,kerekek[i],vkerekek[i]);
   a1:=axes[0];
   if (i=0) or (i=2) then
   begin
     if kerekirany>=0 then
     d3dxvec3lerp(a1,axes[0],axes[1],kerekirany*kerekiranyszorzo/32)
     else
     begin
      d3dxvec3scale(a1,axes[1],-1);
      d3dxvec3lerp(a1,axes[0],a1,-kerekirany*kerekiranyszorzo/32);
     end;
    d3dxvec3cross(a2,a1,axes[2]);
   end
   else
    a2:=axes[1];
   if d3dxvec3lengthsq(a2)<0.0001 then a2.y:=1;
   d3dxvec3scale(tmp2,a2,d3dxvec3dot(a2,tmp2)*(1-kerekfriction)/d3dxvec3lengthsq(a2));
   //wtf ennyi lenne a kerekes hozzáadós cucc?
   //ja lol ez a kerék tapadása
   d3dxvec3subtract(kerekek[i],kerekek[i],tmp2);
   if elore then
   begin
    if porgetes<1.0 then porgetes:= porgetes + 0.005;
    d3dxvec3scale(tmp2,a1,elorescale);
    if not agx then
    tmp2.y:=tmp2.y*2;
    d3dxvec3add(kerekek[i],kerekek[i],tmp2);
   end;
   if porgetes>0.501 then porgetes:= porgetes - 0.001;
   if not iranyitjak then
   begin
    kerekek[i].x:=kerekek[i].x+(vkerekek[i].x-kerekek[i].x)*0.5;
    kerekek[i].z:=kerekek[i].z+(vkerekek[i].z-kerekek[i].z)*0.5;
   end;

   if fek then
   if tavpointpointsq(kerekek[i],vkerekek[i])<0.1*0.1 then
   begin
    if porgetes>0.52 then porgetes:= porgetes - 0.01;
    d3dxvec3scale(tmp2,a1,-0.02);
    d3dxvec3add(kerekek[i],kerekek[i],tmp2);
   end
   else
   begin
    kerekek[i].x:=kerekek[i].x+(vkerekek[i].x-kerekek[i].x)*0.5;
    kerekek[i].z:=kerekek[i].z+(vkerekek[i].z-kerekek[i].z)*0.5;
   end;
  end;
  d3dxvec3subtract(tmp2,kerekek[i],kerekorig[i]);
  tt:=d3dxvec3dot(tmp2,tmp);
  if (tt<0) or (tt>d3dxvec3lengthsq(tmp)) then d3dxvec3add(kerekek[i],tmp,kerekorig[i]);
   pontok[i].x:= pontok[i].x+(tmp2.x-tmp.x)*felfero;
   pontok[i].y:= pontok[i].y+(tmp2.y-tmp.y)*felfero;
   pontok[i].z:= pontok[i].z+(tmp2.z-tmp.z)*felfero;
  vpontok[i].x:=vpontok[i].x+(tmp2.x-tmp.x)*felfdamp;
  vpontok[i].y:=vpontok[i].y+(tmp2.y-tmp.y)*felfdamp;
  vpontok[i].z:=vpontok[i].z+(tmp2.z-tmp.z)*felfdamp;


  pillspd:=tavpointpoint(pos,vpos);
  for j:=shift to 5 do
  if pillspd*360>felshiftek[j] then begin
    shift:=j;
    end;

  for j:=shift downto 1 do
  if pillspd*360<leshiftek[j] then begin
    shift:=j;
    end;
  fordulatszam:=(sqrt(pillspd*360)-fordulatok[shift]+1)*porgetes;//+porgetes;
 end;
end;

function Tauto.getseb:single;
begin
  if gettickcount=lastsebgtc then
    result:=sebcache
  else
  begin
    Result:=tavpointpoint(pos,vpos);
    sebcache:=Result;
  end;
end;

function Tauto.getmotionvec:TD3DXVector3;
begin
  Result:=D3DXVector3(pos.x - vpos.x,pos.y - vpos.y,pos.z - vpos.z);
end;

function Tauto.kerektransformmatrix(mit:integer):TD3DMatrix;
var
tmp,tmp2:TD3DXVector3;
a1,a2:TD3DXVector3;
rotmat:TD3DMatrix;
i:integer;
begin

 d3dxvec3scale(tmp,axes[2],-k3*0.85);
 if mit>1 then
  d3dxvec3scale(tmp2,axes[1],k1*0.5)
 else
  d3dxvec3scale(tmp2,axes[1],-k1*0.5);

 d3dxvec3add(tmp,tmp,tmp2);
 d3dxvec3subtract(tmp,kerekek[mit],tmp);
 //tmp:=kerekek[mit];
 if (mit=0) or (mit=2) then
 begin
  if kerekirany>=0 then
   d3dxvec3lerp(a1,axes[0],axes[1],kerekirany*kerekiranyszorzo/32)
  else
  begin
   d3dxvec3scale(a1,axes[1],-1);
   d3dxvec3lerp(a1,axes[0],a1,-kerekirany*kerekiranyszorzo/32);
  end;
  d3dxvec3cross(a2,a1,axes[2]);
  i:=abs(kerekirany);
  with result do
  begin
   _31:=a2.x*kx2[i];  _32:=a2.y*kx2[i];  _33:=a2.z*kx2[i];  _34:=0;
   _11:=a1.x*kx1[i];  _12:=a1.y*kx1[i];  _13:=a1.z*kx1[i];  _14:=0;
   _21:=axes[2].x*k3; _22:=axes[2].y*k3; _23:=axes[2].z*k3; _24:=0;
   _41:=tmp.x;        _42:=tmp.y;        _43:=tmp.z;        _44:=1;
  end;
 end
 else
 with result do
  begin
   _31:=axes[1].x*k2; _32:=axes[1].y*k2; _33:=axes[1].z*k2; _34:=0;
   _11:=axes[0].x*k1; _12:=axes[0].y*k1; _13:=axes[0].z*k1; _14:=0;
   _21:=axes[2].x*k3; _22:=axes[2].y*k3; _23:=axes[2].z*k3; _24:=0;
   _41:=tmp.x;        _42:=tmp.y;        _43:=tmp.z;        _44:=1;
  end;
  d3dxmatrixrotationZ(rotmat,-kerekfor/1.5);
  d3dxmatrixmultiply(result,rotmat,result);
 //d3dxmatrixtranslation(result,kerekek[mit].x,kerekek[mit].y,kerekek[mit].z);
end;

procedure Tauto.iranyit(aelore,afek,ajobb,abal,airanyitjak:boolean);
begin
 if disabled then exit;
 elore:=aelore;
 fek:=afek;
 jobb:=ajobb;
 bal:=abal;
 iranyitjak:=airanyitjak;
end;

procedure Tauto.step;
var
tmp:TD3DXVector3;
begin
 if disabled then exit;
 if jobb then
  if kerekirany<31 then
  inc(kerekirany);
 if bal then if kerekirany>-31 then dec(kerekirany);

 if not (jobb or bal) then
  if kerekirany>0 then dec(kerekirany)
  else
  if kerekirany<0 then inc(kerekirany);
  d3dxvec3subtract(tmp,pos,vpos);
 kerekfor:=kerekfor+d3dxvec3dot(axes[0],tmp);
  inherited;

end;
end.
