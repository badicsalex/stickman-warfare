unit fiz2;
interface

uses
   Direct3D9,D3DX9,typestuff,math,windows;

type

//  3/4-esek a kártyák jelenleg.

  Tnegypont = array [0..3] of TD3DXVector3;
{
 0--1
 |  |
 |  |
 2--3
}

 PCard = ^Tcard;
 Tcollision = packed record
  axe:byte;//0,1: normál;  2:oldal;  3:padló... TODO
  point1,point2:byte; //oldal vagy valóban pont
  ido:byte;
  masikkartya:pCard;
  coord1,coord2,coord1o,coord2o,ero:single;
 end;



  TCard = Record
   p,op,op2,cp,sp,ep:Tnegypont;   //Pontok, Old Pontok, Very old pontok, Collision hozzáadás, Súrlódás hozzáadás, Eredeti pos
   octp:TD3DXVector3;
   disabled,foldon:boolean;
   distimer,alljmeg:integer;
   colls:array of Tcollision;
   szam:integer;
   kovkartya:PCard;     //Lista...
  end;

  TfuraSATtype = record
   dotp:single;
   ssz:byte;
  end;

  procedure CardConstraintShape(card:Pcard);
  procedure CardConstraintFloor(card:Pcard);

  procedure CardVerlet(card:Pcard);

  procedure CardStep(card:Pcard);
//  procedure CardStepLight(card:Pcard);
  
  procedure CardVCard(card1:Pcard;card2:Pcard);

  procedure InitOcttree;
var
 firstcard,xcard:Pcard;
 octtree:Poctleaf ;
const
 CARD_GRAV=0.0015;
 rugalmassag=0.95;    //   préselés vs. stabilitás
 utkozesi=rugalmassag*0.4; //rugalmas vagy rugalmatlan ütközés
 surlodasi=1;         //súrlódási erõ szorzója... feltehetõen 1nek kell maradnia, sok vizet nem zavar
 egyutthato =0.20;     // tapadási együttható... mü null.
 egyutthato2 = egyutthato*0.95;    // surlódási együttható... mü.
 tompitas = 0.20;      // lengéscsillapítási szorzó
 mineromozdhoz = 0.005; //minimális erõ a tapadás megszûnéséhez
{$DEFINE valostapadasi}
implementation

procedure ConstraintTwoPoints(var p1,p2:TD3DXVector3;const dst:single);
var
tmp:TD3DXVector3;
tmplngt,dlngt:single;
begin
 d3dxvec3subtract(tmp,p2,p1);
 tmplngt:=d3dxvec3lengthsq(tmp)+dst*dst;
 if tmplngt<0.00001 then tmplngt:=1;
 dlngt:=(dst*dst)/(tmplngt)-0.5;
 d3dxvec3scale(tmp,tmp,dlngt);
 d3dxvec3subtract(p1,p1,tmp);
 d3dxvec3add     (p2,p2,tmp);

end;

procedure CardConstraintShape(card:Pcard);
const
wdt=3;
hgh=4;
atlo=5;
var
 i,j:integer;
 n,a,b:TD3DXVector3;
 tav:array [0..3] of single;
 ossz:single;
 tmpp:Tnegypont;
begin
 // 3/4-esek a kártyák jelenleg.
 {
 0--1
 |  |
 |  |
 2--3
}

 with card^ do
 begin
  tmpp:=p;
  //Egysík.
  d3dxvec3subtract(a,p[0],p[3]);
  d3dxvec3subtract(b,p[1],p[2]);
  d3dxvec3cross(n,a,b);
  fastvec3normalize(n);
  ossz:=0;
  for i:=0 to 3 do
  begin
   tav[i]:=d3dxvec3dot(n,p[i]);
   ossz:=ossz+tav[i];
  end;
  ossz:=ossz*0.25;
  for i:=0 to 3 do
  begin
   d3dxvec3scale(a,n,ossz-tav[i]);
   d3dxvec3add(p[i],p[i],a);
  end;

  //oldalak
  constraintTwoPoints(p[0],p[1],wdt);
  constraintTwoPoints(p[2],p[3],wdt);

  constraintTwoPoints(p[0],p[2],hgh);
  constraintTwoPoints(p[1],p[3],hgh);
  //átló
  constraintTwoPoints(p[0],p[3],atlo);
  constraintTwoPoints(p[1],p[2],atlo);

  for i:=0 to 3 do
  begin
   d3dxvec3subtract(tmpp[i],p[i],tmpp[i]);
   d3dxvec3scale(tmpp[i],tmpp[i],tompitas);
   d3dxvec3add(op[i],op[i],tmpp[i]);
  end;

 end;
end;

procedure addcoll(card1,card2:Pcard;aaxe,p1,p2:byte;c1,c2,aero:single);
var
i:integer;
begin
// if card1.disabled then exit;
 //if card2<>nil then if card2.disabled then exit;
 for i:=0 to high(card1.colls) do
 with card1.colls[i] do
  if (masikkartya=card2) and (aaxe=axe) and (p1=point1) and (p2=point2) then
  begin

   coord1:=c1;
   coord2:=c2;

   ido:=0; //0-nál van feldoolgozás
   exit;
  end;
 //ELSE

 setlength(card1.colls,length(card1.colls)+1);
 with card1.colls[high(card1.colls)] do
 begin
  coord1:=c1;
  coord2:=c2;
  coord1o:=coord1;
  coord2o:=coord2;
  ido:=1;  //ne dolgozza fel.

  masikkartya:=card2;
  axe:=aaxe;
  point1:=p1;
  point2:=p2;
  ero:=aero;
 end;

end;


procedure CardConstraintFloor(card:Pcard);
var
i:integer;
bol:boolean;
begin
 bol:=true;
 with card^ do
 begin
 for i:=0 to 3 do
  if p[i].y<=0 then
  begin
   addcoll(card,nil,3,i,0,p[i].x,p[i].z,-p[i].y);
   p[i].y:=0;//-p[i].y;
   //op[i].y:=0;
  end
  else
  bol:=false;
 if bol then
 begin
  card.disabled:=true;
  card.foldon:=true;
  for i:=0 to 3 do
   begin
    p[i].y:=0;
    op[i]:=p[i];
   end;
 end;
 end;
end;



procedure CardVerlet(card:Pcard);

var
tmp:Td3dxvector3;
i:integer;
begin
 with card^ do
 for i:=0 to 3 do
 begin
  tmp:=p[i];

  p[i].x:=2*p[i].x-op[i].x+cp[i].x*rugalmassag+sp[i].x*surlodasi;
  p[i].y:=2*p[i].y-op[i].y+cp[i].y*rugalmassag+sp[i].y*surlodasi-CARD_GRAV;
  p[i].z:=2*p[i].z-op[i].z+cp[i].z*rugalmassag+sp[i].z*surlodasi;

  //
  op2:=op;
  op[i]:=tmp;

  //  ütközési energiaelnyelés
  op[i].x:=op[i].x+cp[i].x*utkozesi;
  op[i].y:=op[i].y+cp[i].y*utkozesi;
  op[i].z:=op[i].z+cp[i].z*utkozesi;
  cp[i]:=D3DXVector3Zero;
  sp[i]:=D3DXVector3Zero;
 end;
end;

procedure CardVerletLight(card:Pcard);
var
tmp:Td3dxvector3;
i:integer;
begin
 with card^ do
 for i:=0 to 3 do
 begin
  p[i].x:=p[i].x+cp[i].x*rugalmassag+sp[i].x*surlodasi;
  p[i].y:=p[i].y+cp[i].y*rugalmassag+sp[i].y*surlodasi-CARD_GRAV;
  p[i].z:=p[i].z+cp[i].z*rugalmassag+sp[i].z*surlodasi;

  //  ütközési energiaelnyelés
  op[i].x:=op[i].x+cp[i].x*utkozesi;
  op[i].y:=op[i].y+cp[i].y*utkozesi;
  op[i].z:=op[i].z+cp[i].z*utkozesi;
  cp[i]:=D3DXVector3Zero;
  sp[i]:=D3DXVector3Zero;
 end;
end;


procedure CardHandleColls(card:Pcard);
var
i:integer;
elmozd,vec2:TD3DXVector3;
cardhossz,cardszel,el1,el2:TD3DXVector3;
card2:Pcard;
c1ep1,c2ep1,c1ep2,c2ep2:integer;
min1,max1,min2,max2:single;
tapad:boolean;
begin
 i:=0;
 while i<=high(card.colls) do
   if card.colls[i].ido>20 then
   begin
    card.colls[i]:=card.colls[high(card.colls)];
    setlength(card.colls,high(card.colls));
   end
   else
   with card.colls[i] do
   begin
    tapad:=true;
    if (ido=0) then
    begin

     //történt vmi...
    //OMGOMG so much feldolgozás
     case axe of
      0:begin // Card lapja vs. masikkartya pontja
         D3DXVec3subtract(cardhossz,card.p[2],card.p[0]);
         D3DXVec3subtract(cardszel ,card.p[1],card.p[0]);

         d3dxvec3scale(cardhossz,cardhossz,coord2o-coord2);
         d3dxvec3scale(cardszel,cardszel,coord1o-coord1);
         d3dxvec3add(elmozd,cardhossz,cardszel);

         if d3dxvec3lengthsq(elmozd)>sqr(egyutthato*ero) then
         begin
          fastvec3normalize(elmozd);
          d3dxvec3scale(elmozd,elmozd,egyutthato2*ero);
          if ero>mineromozdhoz then
          tapad:=false;
         end;

         d3dxvec3scale(elmozd,elmozd,0.5);

         min1:=coord1; max1:=1-coord1; min2:=coord2; max2:=1-coord2;
         d3dxvec3scale(vec2,elmozd,min1*min2);    //szel bal hossz fent
         d3dxvec3add(card.sp[0],card.sp[0],vec2);
         d3dxvec3scale(vec2,elmozd,max1*min2);    //szel jobb hossz fent
         d3dxvec3add(card.sp[1],card.sp[1],vec2);
         d3dxvec3scale(vec2,elmozd,min1*max2);    //szel bal hossz lent
         d3dxvec3add(card.sp[2],card.sp[2],vec2);
         d3dxvec3scale(vec2,elmozd,max1*max2);   //szel jobb hossz lent
         d3dxvec3add(card.sp[3],card.sp[3],vec2);
       end;
      1:begin // Card lapja vs. masikkartya pontja
         card2:=masikkartya;
         D3DXVec3subtract(cardhossz,card2.p[2],card2.p[0]);
         D3DXVec3subtract(cardszel ,card2.p[1],card2.p[0]);

         d3dxvec3scale(cardhossz,cardhossz,coord2o-coord2);
         d3dxvec3scale(cardszel,cardszel,coord1o-coord1);
         d3dxvec3add(elmozd,cardhossz,cardszel);

         if d3dxvec3lengthsq(elmozd)>sqr(egyutthato*ero) then
         begin
          fastvec3normalize(elmozd);
          d3dxvec3scale(elmozd,elmozd,egyutthato2*ero);
          if ero>mineromozdhoz then
          tapad:=false;
         end;


         d3dxvec3scale(elmozd,elmozd,-0.5);
         d3dxvec3add(card.sp[point1],card.sp[point1],elmozd);
       end;
      2:begin
         {lehetséges élek:
          0-1 <> 1-0     => 1
          0-2 <> 2-0     => 2
          1-3 <> 3-1     => 4
          2-3 <> 3-2     => 5
         }
         c1ep1:=0; c1ep2:=0;c2ep1:=0; c2ep2:=0;
         case point1 of
          1:begin c1ep1:=0; c1ep2:=1; end;
          2:begin c1ep1:=0; c1ep2:=2; end;
          4:begin c1ep1:=1; c1ep2:=3; end;
          5:begin c1ep1:=2; c1ep2:=3; end;

         end;
         case point2 of
          1:begin c2ep1:=0; c2ep2:=1; end;
          2:begin c2ep1:=0; c2ep2:=2; end;
          4:begin c2ep1:=1; c2ep2:=3; end;
          5:begin c2ep1:=2; c2ep2:=3; end;

         end;


         card2:=masikkartya;
         if (abs(coord1o-coord1)+abs(coord2o-coord2))<0.2 then
         if (c2ep2<>0) and (c1ep2<>0) then
         begin
          D3DXVec3subtract(el1, card.p[c1ep1], card.p[c1ep2]);
          D3DXVec3Scale(el1,el1,coord1o-coord1);
          D3DXVec3subtract(el2,card2.p[c2ep1],card2.p[c2ep2]);
          D3DXVec3Scale(el2,el2,coord2-coord2o);
          d3dxvec3add(elmozd,el1,el2);

          if d3dxvec3lengthsq(elmozd)>sqr(egyutthato*ero) then
         begin
          fastvec3normalize(elmozd);
          d3dxvec3scale(elmozd,elmozd,egyutthato2*ero);
          if ero>mineromozdhoz then
          tapad:=false;
         end;

          d3dxvec3scale(vec2,elmozd,(1-coord1)*0.5);
          d3dxvec3add(card.sp[c1ep1],card.sp[c1ep1],vec2);
          d3dxvec3scale(vec2,elmozd,(  coord1)*0.5);
          d3dxvec3add(card.sp[c1ep2],card.sp[c1ep2],vec2);
         end;
      end;

      3:begin // Padló vs. sajat pont
         elmozd:=D3DXVector3(coord1o-coord1,0,coord2o-coord2);
         if d3dxvec3lengthsq(elmozd)>sqr(egyutthato*ero*8) then
         begin
          fastvec3normalize(elmozd);
          d3dxvec3scale(elmozd,elmozd,egyutthato2*ero*8);
          if ero>mineromozdhoz then
          tapad:=false;
         end;
                               
         d3dxvec3scale(elmozd,elmozd,1);
         d3dxvec3add(card.sp[point1],card.sp[point1],elmozd);
       end;
     end;
    end;

  {$IFDEF valostapadasi}
   if not tapad then
    begin
     coord1o:=(coord1o+coord1)/2;
     coord2o:=(coord2o+coord2)/2;
    end;
    {$ENDIF}
    inc(ido);
    inc(i);
   end;
end;

procedure CardRecompOctTree(card:Pcard);
var
newoctp:TD3DXVector3;
begin
 newoctp:=vec3add4(card.p[0],card.p[1],card.p[2],card.p[3]);
 d3dxvec3scale(newoctp,newoctp,0.25);  
 if tavpointpointsq(card.octp,newoctp)>0.1 then
 begin
  octtreedel(octtree,card.octp,card);
  if not card.foldon then
  begin
  octtreeadd(octtree,newoctp  ,card);
  card.octp:=newoctp;
  end;
 end;
end;

procedure CardDoDisabling(card:Pcard);
var
tavsq:single;
i:integer;
vec1,vec2:TD3DXVector3;
begin
 with card^ do
 begin
  tavsq:=0;
  for i:=0 to 3 do
  begin
   d3dxvec3add(vec1,p[i],op[i]);
   d3dxvec3add(vec2,p[i],op2[i]);
   tavsq:=tavsq+tavpointpointsq(vec1,vec2);

  end;
  if length(colls)<3 then tavsq:=1;
  distimer:=distimer+3-round(min(tavsq*4000,100));
  if distimer<0 then distimer:=0; 
  if distimer>200 then
  begin
   disabled:=true;
   distimer:=200;
  end;
  
 end;
end;

procedure CardStep(card:Pcard);
begin

 cardDoDisabling(card);
 cardHandleColls(card);
 cardVerlet(card);
 cardRecompOctTree(card);
 cardConstraintShape(card);
 cardConstraintFloor(card);


end;

{procedure CardStepLight(card:Pcard);
begin
 //cardRecompOctTree(card);
 //cardHandleColls(card);
 cardVerletlight(card);
 cardConstraintShape(card);
 cardConstraintFloor(card);

end; }

procedure Pontarany(const p1,p2,p3,p4:TD3DXVector3;out c1,c2:single);
const
EPS=0.0001;
var
p13,p43,p21:TD3DXVector3;
d1343,d4321,d1321,d4343,d2121:single;
numer,denom:single;
begin
   d3dxvec3subtract(p13,p1,p3);
   d3dxvec3subtract(p43,p4,p3);
   d3dxvec3subtract(p21,p2,p1);
   d1343 := p13.x * p43.x + p13.y * p43.y + p13.z * p43.z;
   d4321 := p43.x * p21.x + p43.y * p21.y + p43.z * p21.z;
   d1321 := p13.x * p21.x + p13.y * p21.y + p13.z * p21.z;
   d4343 := p43.x * p43.x + p43.y * p43.y + p43.z * p43.z;
   d2121 := p21.x * p21.x + p21.y * p21.y + p21.z * p21.z;

   denom := d2121 * d4343 - d4321 * d4321;
   if (ABS(denom) < EPS) then
    begin
     c1:=0.5; c2:=0.5;
     exit;
    end;
   numer := d1343 * d4321 - d1321 * d4343;

   if (ABS(d4343) < EPS) then
    begin
     c1:=0.5; c2:=0.5;
     exit;
    end;
   c1 := numer / denom;
   if (c1<0) or (c1>1) then
   begin
     c1:=0.5; c2:=0.5;
     exit;
    end;
   c2 := (d1343 + d4321 * c1) / d4343;
   if (c2<0) or (c2>1) then
   begin
     c1:=0.5; c2:=0.5;
     exit;
    end;
end;


function Elmfunc0(const a:single):single;
begin
 result:=-2*a*a+3*a
end;

function Elmfunc1(const b:single):single;
begin
 result:=-2*b*b+b+1;
end;




procedure CardVCard(card1,card2:Pcard);
const
szorzok:array [0..5] of single = (1/12,1/12,1/3,1/3,1/4,1/4);
var
 i,j,k:integer;
 axes:array[0..5] of TD3DXVector3;
 card1Hossz,card2Hossz,card1Szel,card2Szel:TD3DXVector3;
 norm1,norm2,vec,vec2:TD3DXVector3;
 min1,min2,max1,max2:single;
 kul,kulmin:single;
 szor,hsz:single;
 lk:integer;
 coord1, coord2:single;
 ep,c1ep1,c2ep1,c1ep2,c2ep2:integer;
 em,tmp:single;
 sat1,sat2:array [0..5,0..3] of TfuraSATtype;
 tmpsat:TfuraSATtype;
 dtmr:integer;
begin


 D3DXVec3subtract(card1hossz,card1.p[2],card1.p[0]);
 D3DXVec3subtract(card2hossz,card2.p[2],card2.p[0]);

 D3DXVec3subtract(card1szel ,card1.p[1],card1.p[0]);
 D3DXVec3subtract(card2szel ,card2.p[1],card2.p[0]);

 D3DXVec3cross(norm1,card1szel,card1hossz);
 D3DXVec3cross(norm2,card2szel,card2hossz);

 D3DXVec3cross(vec,norm1,norm2);


{ d3dxvec3scale(axes[0],norm1,1/12);
 d3dxvec3scale(axes[1],norm2,1/12);

 D3DXVec3cross(axes[2],card1szel,card2szel);
 D3DXVec3cross(axes[3],card1szel,card2hossz);
 D3DXVec3cross(axes[4],card1hossz,card2szel);
 D3DXVec3cross(axes[5],card1hossz,card2hossz);   }
 axes[0]:=norm1;
 axes[1]:=norm2;
 axes[2]:=card1szel;
 axes[3]:=card2szel;
 axes[4]:=card1hossz;
 axes[5]:=card2hossz;

{
 d3dxvec3scale(axes[2],card1hossz,1/4);
 d3dxvec3scale(axes[3],card2hossz,1/4);
 d3dxvec3scale(axes[4],card1szel,1/3);
 d3dxvec3scale(axes[5],card2szel,1/3); }

 kulmin:=100000;
 lk:=0;
 szor:=0;
 for i:=0 to 5 do
 begin
  d3dxvec3scale(axes[i],axes[i],szorzok[i]);
  {if i>1 then
  begin
  hsz:=d3dxvec3lengthsq(axes[i]);
  d3dxvec3scale(axes[i],axes[i],1/hsz);
   end;}
  for j:=0 to 3 do
  begin
   sat1[i,j].dotp:=d3dxvec3dot(axes[i],card1.p[j]);
   sat1[i,j].ssz:=j;
   
   sat2[i,j].dotp:=d3dxvec3dot(axes[i],card2.p[j]);
   sat2[i,j].ssz:=j;
  end;

  for j:=0 to 2 do
   for k:=j+1 to 3 do
   if sat1[i,j].dotp>sat1[i,k].dotp then
   begin tmpsat:=sat1[i,j]; sat1[i,j]:=sat1[i,k]; sat1[i,k]:=tmpsat; end;

  for j:=0 to 2 do
   for k:=j+1 to 3 do
   if sat2[i,j].dotp>sat2[i,k].dotp then
   begin tmpsat:=sat2[i,j]; sat2[i,j]:=sat2[i,k]; sat2[i,k]:=tmpsat; end;



  //kul:=min(max1-min2,max2-min1);

  kul:=min(sat1[i,3].dotp-sat2[i,0].dotp,sat2[i,3].dotp-sat1[i,0].dotp);

  if kul<kulmin then
  begin
   kulmin:=kul;
   if kul<-0 then  break;
   lk:=i;
   if sat1[i,3].dotp-sat2[i,0].dotp<sat2[i,3].dotp-sat1[i,0].dotp then szor:=-1 else szor:=+1;
  end;
 end;

 if kulmin>=0 then
 begin
  card1.disabled:=false;
  card2.disabled:=false;

  if card1.distimer>card2.distimer then
   card1.distimer:=card2.distimer
  else
   card2.distimer:=card1.distimer;

  d3dxvec3scale(vec,axes[lk],kulmin*szor); //ne baszakodj ezzel

          

  
  case lk of
   0:begin

      if szor<0 then ep:=sat2[lk,0].ssz else ep:=sat2[lk,3].ssz;
      d3dxvec3subtract(vec2,card2.p[ep],card1.p[0]);
      d3dxvec3subtract(vec2,vec2,vec);
      coord1:=1-d3dxvec3dot(card1szel ,vec2)*(1/9);

      coord2:=1-d3dxvec3dot(card1hossz,vec2)*(1/16);

    //  coord1:=d3dxvec3dot(axes[0],vec2);

     // coord2:=d3dxvec3dot(card1hossz,card1szel);

      min1:=elmfunc0(coord1); //szel bal     //Újrafelhasználás powah
      max1:=elmfunc1(coord1); //szel jobb
      min2:=elmfunc0(coord2); //hossz fent     //Újrafelhasználás powah
      max2:=elmfunc1(coord2); //hossz lent

      min1:=coord1; max1:=1-coord1; min2:=coord2; max2:=1-coord2;
      d3dxvec3scale(vec2,vec,min1*min2*0.5);    //szel bal hossz fent
      d3dxvec3add(card1.cp[0],card1.cp[0],vec2);
      d3dxvec3scale(vec2,vec,max1*min2*0.5);    //szel jobb hossz fent
      d3dxvec3add(card1.cp[1],card1.cp[1],vec2);
      d3dxvec3scale(vec2,vec,min1*max2*0.5);    //szel bal hossz lent
      d3dxvec3add(card1.cp[2],card1.cp[2],vec2);
      d3dxvec3scale(vec2,vec,max1*max2*0.5);   //szel jobb hossz lent
      d3dxvec3add(card1.cp[3],card1.cp[3],vec2);

      addcoll(card1,card2,0,ep,0,coord1,coord2,kulmin);
     end;
   1:begin
      if szor<0 then ep:=sat1[lk,3].ssz else ep:=sat1[lk,0].ssz;

      d3dxvec3subtract(vec2,card1.p[ep],card2.p[0]);
      d3dxvec3subtract(vec2,vec2,vec);
      coord1:=1-d3dxvec3dot(card2szel ,vec2)*(1/9);

      coord2:=1-d3dxvec3dot(card2hossz,vec2)*(1/16);

      d3dxvec3scale(vec2,vec,0.5);
      d3dxvec3add(card1.cp[ep],card1.cp[ep],vec2);
      addcoll(card1,card2,1,ep,0,coord1,coord2,kulmin);
   end;

   2,3,4,5:begin
     if szor<0 then
     begin
      c1ep1:=sat1[lk,3].ssz;
      c1ep2:=sat1[lk,2].ssz;
      c2ep1:=sat2[lk,1].ssz;
      c2ep2:=sat2[lk,0].ssz;
     end
     else
     begin
      c1ep1:=sat1[lk,0].ssz;
      c1ep2:=sat1[lk,1].ssz;
      c2ep1:=sat2[lk,2].ssz;
      c2ep2:=sat2[lk,3].ssz;
     end;

      {
       0--1
       |  |
       |  |
       2--3
      }

      {lehetséges élek:
       0-1 <> 1-0     => 1
       0-2 <> 2-0     => 2
       1-3 <> 3-1     => 4
       2-3 <> 3-2     => 5
       }

      if c1ep1>c1ep2 then
      begin
       ep:=c1ep1;
       c1ep1:=c1ep2;
       c1ep2:=ep;
      end;

      if c2ep1>c2ep2 then
      begin
       ep:=c2ep1;
       c2ep1:=c2ep2;
       c2ep2:=ep;
      end;

      pontarany(card1.p[c1ep1],card1.p[c1ep2],card2.p[c2ep1],card2.p[c2ep2],coord1,coord2);
      
      d3dxvec3scale(vec2,vec,0.25*coord1);
      d3dxvec3add(card1.cp[c1ep2],card1.cp[c1ep2],vec2);
      d3dxvec3scale(vec2,vec,0.25*(1-coord1));
      d3dxvec3add(card1.cp[c1ep1],card1.cp[c1ep1],vec2);

      addcoll(card1,card2,2,c1ep1+c1ep2,c2ep1+c2ep2,coord1,coord2,kulmin);
     end;
  end;

  
 end;

end;

procedure InitOcttree;
var
cardmost:Pcard;
newoctp:TD3DXVector3;
begin

 new(octtree);
 zeromemory(octtree,sizeof(Toctleaf));
 //enyhén hasraütés
 octtree.AABB.min:=D3DXVector3(-500,-10,-500);
 octtree.AABB.max:=D3DXVector3(500,100,500);
 cardmost:=firstcard;
 while cardmost<>nil do
 begin
  newoctp:=vec3add4(cardmost.p[0],cardmost.p[1],cardmost.p[2],cardmost.p[3]);
  d3dxvec3scale(cardmost.octp,newoctp,0.25);
  octtreeadd(octtree,cardmost.octp,cardmost);
  cardmost:=cardmost.kovkartya;
 end;
end;

end.
