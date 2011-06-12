unit StickAI;



interface

uses
sysutils,math,typestuff,D3DX9,ojjektumok;
const
WPsuruseg=1;
type
 TWaypoint = record
  hol:TD3DXVector3;
  hova:array [0..5] of word;
 end;

  TWaypointS = class (Tobject)
 private
  procedure AddWP(kitol,merre:word;hova:TD3DXVector3);
 public
  points:array of TWaypoint;
  ut:array of word;
  procedure generate(mibol:T3Dojjektum;bocsmegsem:boolean);
  function nearestWP(hol:TD3DXVector3):word;
  procedure FindPath(h1,h2:word);
 end;
 
 TAIplr = class (TObject)
 protected

 public
  fejh:TD3DXVector3;
  lo:single;
  vpos,opos,pos,cel,egyhely:TD3DXVector3;
  celmegvan:boolean;
  ehtim:word;
  becelzott:integer;
  ir,ir2,hir,hir2,cooldown:single;
  iranyithato,szfe,celmegs:boolean;
  state,fegyv:byte;
  Waypointok:array of TD3DXVector3;
  lovok:boolean;
  halal:single;
  fejcucc:byte;
  constructor Create(hol:TD3DXVector3;aFegyv:byte);
  procedure dosomething;
  procedure makeWPs(ojjektumarr:array of T3Dojjektum;ojjektumWP:array of Twaypoints);
  procedure lass(plr:TD3DXVector3;plrellen,lathatatlan:boolean;tobbi:array of TAIplr;ojjektumok:array of T3Dojjektum;advwove:Tadvwove);
  destructor Destroy;reintroduce;
 end;

 procedure decbotlevel;
 procedure incbotlevel;
 
var
 botlevel:single=1;
 invbotlevel:single=1;

implementation

constructor TAIplr.Create(hol:TD3DXVector3;aFegyv:byte);
begin
 inherited create;
 pos:=hol;
 vpos:=pos;
 egyhely:=pos;
 cel:=pos;
 celmegs:=false;
 celmegvan:=true;
 ehtim:=ehtim+1;
 fegyv:=afegyv;
 halal:=5;
 becelzott:=-1;
 fejcucc:=random(5);
end;

destructor TAIplr.Destroy;
begin
         //ide vmit.
 inherited
end;

{ LAW löwés:
meg:= arctan((v*v-sqrt(-g*g*x*x-v*v*(2*g*y-v*v)))/(g*x));
 px:=cos(meg)*SEB;
 py:=sin(meg)*seb;
}

procedure TAIplr.dosomething;
var
plrmerre:single;
vec:TD3DXVector3;
ds,dc:single;
cel2:TD3DXVector3;
i:integer;
gyrs:single;
x,y,v,g,a:single;
begin

 if halal>0 then
 begin
  //halal:=halal+0.01;
  exit;
 end;


 if lo>0 then
 lo:=lo-0.01
 else
 lo:=0;
 if celmegs then
 begin
  state:=0;
  lovok:=true;

  gyrs:=0.05*invbotlevel;
  if fegyv=FEGYV_MPG then gyrs:=0.03*invbotlevel;
  if (fegyv and FEGYV_LAW)=FEGYV_LAW then gyrs:=0.2*invbotlevel;

  if gyrs>1 then gyrs:=1;
  
  if ir>(hir+pi) then
   ir:=ir-gyrs*(ir-hir-2*pi)
  else
  if ir<(hir-pi) then
   ir:=ir-gyrs*(ir-hir+2*pi)
  else
   ir:=ir-gyrs*(ir-hir);
  ir2:=ir2-gyrs*(ir2-hir2);

  if cooldown<=0.01 then
  if fegyv=FEGYV_LAW then
  begin
   d3dxvec3subtract(vec,cel,pos);

   g:=GRAVITACIO/2; v:=0.7;
   x:=sqrt(sqr(vec.x)+sqr(vec.z)); y:=vec.y-1-random(2)*0.5;
   a:=-g*g*x*x-v*v*(2*g*y-v*v);

   if a>0 then
    ir2:=arctan((v*v-sqrt(a))/(g*x))
   else
   begin
    ir2:=pi/4;
    lovok:=false;
    celmegs:=false;
    cooldown:=2;
   end;


  end;

  exit;
 end;



 if (fegyv and 1)=0 then cooldown:=0.3
 else
 cooldown:=1;
 for i:=0 to min(high(waypointok),10) do
 if tavpointpointsq(Waypointok[high(waypointok)-i],pos)<sqr(0.5) then
 begin
  setlength(waypointok,high(waypointok)-i);
  break;
 end;

  state:=0;
 if length(Waypointok)=0 then cel2:=cel else cel2:=Waypointok[high(waypointok)];
 d3dxvec3subtract(vec,cel2,pos);
 if vec.x<>0 then
  plrmerre:=arctan2(vec.z,vec.x)
 else
  if vec.z>0 then
  plrmerre:=pi
  else
  plrmerre:=0;

 if szfe then
  plrmerre:=plrmerre-pi/2
 else
  plrmerre:=plrmerre;

 if ir>(plrmerre+pi) then
  ir:=ir*0.8+(plrmerre+2*pi)*0.2
 else
 if ir<(plrmerre-pi) then
  ir:=ir*0.8+(plrmerre-2*pi)*0.2
 else
  ir:=ir*0.8+plrmerre*0.2;

 if ir>pi then ir:=ir-2*pi;
 if ir<-pi then ir:=ir+2*pi;
 ds:=sin(ir)*0.06;
 dc:=cos(ir)*0.06;

 celmegvan:=celmegvan or (tavpointpointsq(pos,cel)<sqr(3));
 if iranyithato and (not celmegvan) then
 begin
  state:=5+MSTAT_CSIPO;
  if ehtim>100 then
  begin
   pos.y:=pos.y+0.11;
   vpos.y:=pos.y-0.09;

   pos.x:= pos.x-dc/5;
   pos.z:= pos.z-ds/5;

   vpos.x:=pos.x;
   vpos.z:=pos.z;

   ehtim:=0;
  end
  else
  begin
   pos.x:= pos.x+dc;
   pos.z:= pos.z+ds;
  end;
  //pos.y:=cel2.y;
 end
 else
 begin
  ds:=ds*0.02;
  dc:=dc*0.02;
  pos.x:= pos.x+dc;
  pos.z:= pos.z+ds;
 end;

 if tavpointpointsq(pos,egyhely)>sqr(0.3) then
 begin
  egyhely:=pos;
  ehtim:=0;
 end;
 inc(ehtim);

end;

procedure TAIplr.lass(plr:TD3DXVector3;plrellen,lathatatlan:boolean;tobbi:array of TAIplr;ojjektumok:array of T3Dojjektum;advwove:Tadvwove);
var
i,j,k,i2:integer;
v1,v2,v3:TD3DXVector3;
vec:TD3DXVector3;
cucc:single;
merrenez:TD3DXVector3;
rndszar:array of integer;
rnd,tmp:integer;
label
vege,tbc,mbc;
begin


 v1:=pos;
 v1.y:=v1.y+1.5;
 celmegs:=false;
 plrellen:=plrellen xor (fegyv>=128);
 merrenez:=D3DXVector3(cos(ir),0,sin(ir));
 // HA már céloz WALAKIT
 if becelzott>=0 then
 begin
  i:=becelzott;
  if (becelzott>high(tobbi)) and lathatatlan then goto tbc;
  if i<=high(tobbi) then
  v2:=tobbi[i].pos
  else
   v2:=plr;

   v2.y:=v2.y+1.5;

  // d3dxvec3subtract(v3,v2,v1);
  // if d3dxvec3dot(merrenez,v3)<0 then goto tbc;

  for k:=0 to high(ojjektumok) do
   for j:=0 to ojjektumok[k].hvszam-1 do
    if ojjektumok[k].raytestbol(v1,v2,j) then goto tbc;

  for j:=0 to 30 do
  begin
   d3dxvec3lerp(v3,v1,v2,j/30);
   if advwove(v3.x,v3.z)>v3.y then goto tbc;
  end;

   if fegyv=FEGYV_NOOB then if random(3)>0 then v2.y:=v2.y-1.4;
  // Ugyanaz, mint a másik résznél, oda kéne erre figyelni
  celmegs:=true;
  becelzott:=i;
  cel:=v2;
  cel.y:=cel.y-1.5;
  d3dxvec3subtract(vec,cel,pos);
  if vec.x<>0 then
   hir:=arctan2(vec.z,vec.x)
  else
  if vec.z>0 then
   hir:=pi
  else
   hir:=0;
  cucc:=sqrt(vec.x*vec.x+vec.z*vec.z);
  if cucc=0 then cucc:=1;
  hir2:=arctan2(vec.y,cucc);

  case fegyv of
   FEGYV_M4A1:hir:=hir+(random(100)-50)/(10000*botlevel);
   FEGYV_QUAD:hir:=hir+(random(100)-50)/(5000*botlevel);
   FEGYV_MPG:hir:=hir+(random(100)-50)/(15000*botlevel);
   FEGYV_LAW:hir:=hir+(random(100)-50)/(10000*botlevel);
   FEGYV_NOOB:hir:=hir+(random(100)-50)/(20000*botlevel);
  end;

  goto mbc;
  tbc:
  becelzott:=-1;
  mbc:
 end;

 // HA nem céloz senkit
 setlength(rndszar,length(tobbi)+1);
 for i:=0 to high(rndszar) do
  rndszar[i]:=i;

 for i:=0 to high(rndszar) do
 begin
  rnd:=random(length(rndszar));
  tmp:=rndszar[i];
  rndszar[i]:=(rndszar[rnd]);
  rndszar[rnd]:=tmp;
 end;

 for i2:=0 to min(high(tobbi)+1,4) do
 begin
  i:=rndszar[i2];
  if i<=high(tobbi) then
  begin
   if (tobbi[i].fegyv<128) xor (fegyv>=128) then continue;
   if (tobbi[i].halal>0) then continue;
   v2:=tobbi[i].pos;
  end
  else
  begin
   if (not plrellen) or lathatatlan then  continue;
   v2:=plr;
  end;
   v2.y:=v2.y+1.5;
   d3dxvec3subtract(v3,v2,v1);
   if d3dxvec3dot(merrenez,v3)<0 then goto vege;


  for k:=0 to high(ojjektumok) do
   for j:=0 to ojjektumok[k].hvszam-1 do
    if ojjektumok[k].raytestbol(v1,v2,j) then goto vege;

  for j:=0 to 30 do
  begin
   d3dxvec3lerp(v3,v1,v2,j/30);
   if advwove(v3.x,v3.z)>v3.y then goto vege;
  end;

  //Meglátási esély.... fontos lehet.
  d3dxvec3subtract(v3,v2,v1);
  // asszem 25 volt
   if 10*invbotlevel<random(round(d3dxvec3lengthsq(v3)/d3dxvec3dot(merrenez,v3))) then
    goto vege;


  celmegs:=true;
  becelzott:=i;
  cel:=v2;
  cel.y:=cel.y-1.5;
  d3dxvec3subtract(vec,cel,pos);
  if vec.x<>0 then
   hir:=arctan2(vec.z,vec.x)
  else
  if vec.z>0 then
   hir:=pi
  else
   hir:=0;
  cucc:=sqrt(vec.x*vec.x+vec.z*vec.z);
  if cucc=0 then cucc:=1;
  hir2:=arctan2(vec.y,cucc);

  case fegyv of
   FEGYV_M4A1:hir:=hir+(random(100)-50)/5000;
   FEGYV_QUAD:hir:=hir+(random(100)-50)/5000;
   FEGYV_MPG:hir:=hir+(random(100)-50)/5000;
  end;
  
  break;
  vege:
 end;

end;


procedure incbotlevel;
begin
 botlevel:=botlevel/1.5;
  //Biztos ami biztos
 if botlevel<0.1 then botlevel:=0.1;
 if botlevel>10 then botlevel:=10;
 invbotlevel:=1/botlevel;
end;

procedure decbotlevel;
begin
 botlevel:=botlevel*1.5;
  //Biztos ami biztos
 if botlevel<0.1 then botlevel:=0.1;
 if botlevel>10 then botlevel:=10;
 invbotlevel:=1/botlevel;
end;


procedure TAIplr.makeWPs(ojjektumarr:array of T3Dojjektum;ojjektumWP:array of Twaypoints);
var
i,j:integer;
hol1,hol2:integer;
tt,tav:single;
vec,vec2:TD3DXVector3;
oa:array of T3Dojjektum;
oWP:array of Twaypoints;
begin
 setlength(oa,length(ojjektumarr));
 setlength(oWP,length(ojjektumarr));
 for i:=0 to high(ojjektumarr) do
 begin
  oa[i]:=ojjektumarr[i];
  oWP[i]:=ojjektumWP[i];
 end;

 hol1:=-1;
 hol2:=0;
 tav:=1000000;
 for i:=0 to high(oa) do
  for j:=0 to oa[i].hvszam-1 do
  begin
   d3dxvec3add(vec,oa[i].vce,oa[i].holvannak[j]);
   tt:=tavpointpointsq(vec,pos);
   if tt<sqr(oa[i].rad+0.6) then
    if tt<tav then
    begin
     tav:=tt;
     hol1:=i;
     hol2:=j;
    end;
  end;

 if hol1=-1 then
  for i:=0 to high(oa) do
  for j:=0 to oa[i].hvszam-1 do
  begin
   d3dxvec3add(vec,oa[i].vce2,oa[i].holvannak[j]);
   tt:=sqrt(sqr(vec.x-cel.x)+sqr(vec.z-cel.z));
   if tt<sqr(oa[i].rad2+1) then
    if tt<tav then
    begin
     tav:=tt;
     hol1:=i;
     hol2:=j;
    end;
  end;

 if hol1=-1 then begin setlength(waypointok,0); exit; end;

 d3dxvec3subtract(vec,pos,oa[hol1].holvannak[hol2]);
 d3dxvec3subtract(vec2,cel,oa[hol1].holvannak[hol2]);
 vec.y:=vec.y+0.4;
 vec2.y:=vec2.y+0.4;
 oWP[hol1].FindPath(oWP[hol1].NearestWP(vec),oWP[hol1].NearestWP(vec2));
 setlength(Waypointok,length(oWP[hol1].ut));
 for i:=0 to high(oWP[hol1].ut) do
 begin
  d3dxvec3add(Waypointok[i],oWP[hol1].points[oWP[hol1].ut[i]].hol,oa[hol1].holvannak[hol2]);
  Waypointok[i].y:=Waypointok[i].y-0.4;
 end;
end;

/////////////////////////////
////////TWAYPOINTS///////////
/////////////////////////////

procedure Twaypoints.AddWP(kitol,merre:word;hova:TD3DXVector3);
var
i:integer;
begin
 for i:=0 to high(points) do
  if tavpointpointsq(points[i].hol,hova)<0.7*0.7*WPsuruseg*WPsuruseg then
  begin
   points[kitol].hova[merre]:=i;
   exit;
  end;
  setlength(points,length(points)+1);
  points[high(points)].hol:=hova;
  for i:=0 to 5 do
   points[high(points)].hova[i]:=high(word);
  points[kitol].hova[merre]:=high(points);
end;


procedure Twaypoints.generate(mibol:T3Dojjektum;bocsmegsem:boolean);
const
atellen:array [0..5] of byte =(3,4,5,0,1,2);
var
vec,pos,vpos,avpos,ap,kp:TD3DXVector3;
i,j,k,l:integer;
adst:single;
addtable:array [0..5] of TD3DXVector3;
ir:boolean;
tmp:single;
{remap:array of word;
hanyan:array of array [0..5] of word;
torl:array of boolean;   }
label nana;
begin
 for i:=0 to 5 do
 begin
  addtable[i].x:=sin(i*2*pi/6)*0.06;
  addtable[i].y:=-GRAVITACIO;
  addtable[i].z:=cos(i*2*pi/6)*0.06;
 end;

 vec:=D3DXVector3(mibol.vce2.x-mibol.rad2-1,0.4,mibol.vce2.z);
 AddWP(0,0,vec);
 i:=0;
 if bocsmegsem then goto nana;
 repeat
  for j:=0 to 5 do
  begin
   pos:=points[i].hol;
   vpos:=pos;
                             //futás
   ir:=true;

   l:=0;
   k:=ceil(WPsuruseg/0.06);
   repeat
    if ir then
    begin
     vpos:=pos;
     d3dxvec3add(pos,pos,addtable[j])
    end
    else
    begin
     avpos:=pos;
     pos.x:=pos.x*2-vpos.x;
     pos.y:=pos.y*2-vpos.y-GRAVITACIO;
     pos.z:=pos.z*2-vpos.z;
     vpos:=avpos;
    end;

    pos.y:=pos.y/2;

    if mibol.nincsrad then
      tmp:=(azadvwove(mibol.holvannak[0].x+pos.x,mibol.holvannak[0].z+pos.z)-mibol.holvannak[0].y)/2+0.4
    else
     tmp:=0.4;

    if pos.y<tmp then begin pos.y:=tmp; ir:=true; end else ir:=false;

    adst:=mibol.tavtest(pos,0.4,ap,-1,true);
    if adst<sqr(0.4) then
    begin

     //adst:=sqrt(adst);
     d3dxvec3subtract(kp,ap,pos);
     adst:=fastinvsqrt(adst);
     d3dxvec3scale(kp,kp,0.4*adst-1);
     ir:=ir or (kp.y<-0.001);
     d3dxvec3subtract(pos,pos,kp);
    end;
    pos.y:=pos.y*2;
    inc(l);
   until (l>k) and ir;

   if tavpointpointsq(pos,mibol.vce2)<sqr(mibol.rad2+WPSuruseg*2) then
   AddWP(i,j,d3dxvector3(pos.x,pos.y-0.4,pos.z));
  end;
  inc(i);
 until {(i>3000) or }(high(points)<i);
 nana:
 {setlength(remap,length(points));
 setlength(hanyan,length(points));
 for i:=0 to high(remap) do
 begin
  remap[i]:=i;
  for j:=0 to 5 do
  hanyan[i,j]:=0;
 end;

 for i:=0 to high(points) do
 for j:=0 to 5 do
 if points[i].hova[j]<high(word) then
  inc(hanyan[points[i].hova[j],atellen[j]]);
 setlength(torl,high(points));
 for i:=0 to high(points) do
 begin
  torl[i]:=false;
  if (hanyan[i,0]=1) and (hanyan[i,1]=1) and (hanyan[i,2]=1) and (hanyan[i,3]=1) and (hanyan[i,4]=1) and (hanyan[i,5]=1) then
  begin
   torl[i]:=true;
   for j:=0 to 5 do
   if points[i].hova[j]=high(word) then torl[i]:=false else
   if points[points[i].hova[j]].hova[atellen[j]]<>i then torl[i]:=false;
  end;
 end;
  setlength(hanyan,0);
 i:=0;
 repeat
  if torl[i] then
  begin
   for j:=0 to 5 do
    points[remap[points[i].hova[j]]].hova[atellen[j]]:=points[i].hova[atellen[j]];
   remap[high(points)]:=remap[i];
   points[i]:=points[high(points)];
   torl[i]:=torl[high(points)];
   setlength(points, high(points));
  end
  else
 inc(i);
 until (high(points)<i);

 for i:=0 to high(points) do
  for j:=0 to 5 do
  if points[i].hova[j]<high(word) then
   points[i].hova[j]:=remap[points[i].hova[j]];  }
end;

function Twaypoints.nearestWP(hol:TD3DXVector3):word;
var
i:integer;
tmost,t2:single;
begin
 result:=0;
 tmost:=sqr(2000);
 for i:=0 to high(points) do
 begin
  t2:=tavpointpointsq(hol,points[i].hol);
  if t2<tmost then
  begin
   result:=i;
   tmost:=t2;
   if t2<1 then break;
  end;
 end;
end;

procedure Twaypoints.FindPath(h1,h2:word);
var
i,j:integer;
honnan:array of word;
mik1,mik2,mik3:array of word;
bol1:boolean;
hv:word;
hsz:integer;
begin
 setlength(ut,0);
 setlength(honnan,length(points));
 for i:=0 to high(points) do
  honnan[i]:=high(word);
 honnan[h1]:=0;
 setlength(mik1,1);
 mik1[0]:=h1;
 bol1:=false;
 hsz:=0;
 repeat
  setlength(mik2,0);
  for i:=0 to high(mik1) do
  begin
   if mik1[i]=h2 then begin bol1:=true; break; end;
   for j:=0 to 5 do
   if points[mik1[i]].hova[j]<high(word) then
   if  honnan[points[mik1[i]].hova[j]]=high(word) then
   begin
    setlength(mik2,length(mik2)+1);
    mik2[high(mik2)]:=points[mik1[i]].hova[j];
    honnan[points[mik1[i]].hova[j]]:=mik1[i];
   end;
  end;
 mik3:=mik1;
 mik1:=mik2;   //pointer csere
 mik2:=mik3;
 inc(hsz);
 until  bol1 or (length(mik1)=0) or (hsz>1000);

 hsz:=0;
 if bol1 then
 begin
  hv:=h2;
  repeat
   setlength(ut,length(ut)+1);
   ut[high(ut)]:=hv;
   hv:=honnan[hv];
   inc(hsz);
  until (hv=h1) or (hv=high(worD))or (hsz>1000);
 end;
end;

end.

