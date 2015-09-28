unit muksoka;

interface
uses typestuff,Direct3D9,D3DX9,windows,sysutils,math;

type

 Tgmbk= array [0..10] of TD3dvector;
 Tkapcsk = array [0..9,0..1] of byte;
const
 //amag4=0.38729833;
 amag4=0.4;
 amag3=0.28284271;
 vst=0.03;
 //vst=0.1;
 fejvst=0.1;
 alapgmbk:Tgmbk=((x:-0.05;y:0;z:0),(x:0.05;y:0;z:0),
                 (x:-0.05;y:0.4;z:0),(x:0.05;y:0.4;z:0),
                 (x:0;y:amag4+0.4;z:0),
                 (x:0;y:amag4+1;z:0),
                 (x:-0.1;y:amag4-amag3+1;z:0),(x:+0.1;y:amag4-amag3+1;z:0),
                 (x:-0.1;y:amag4-amag3+0.7;z:0),(x:+0.1;y:amag4-amag3+0.7;z:0),
                 (x:0;y:amag4+1.1;z:0));
 alapkapcsk:Tkapcsk=((0,2),(1,3),(2,4),(3,4),(4,5),(5,6),(5,7),(6,8),(7,9),(5,10));
type
 TMuksoka = class (TObject)
 protected
   g_pD3Ddevice:IDirect3ddevice9;
 public
  gmb:array [0..7*8-1] of TCustomvertex;
  kisgmb:array [0..4*5-1] of Tcustomvertex;
  kapcs:array [0..7*2-1] of TCustomvertex;
  bkez,jkez:TD3DVector;
  g_pmuksVB:IDirect3DVertexBuffer9;
  g_pmuksIB:IDirect3DIndexBuffer9;
  gmbind,kapcsind,kisgmbind:integer;
  betoltve:boolean;
  gmbk:Tgmbk;
  kapcsk:Tkapcsk;
  VBwh2,IBwh2:integer;
  bkl,jkl:TD3DXVector3;
  tex:IDirect3DTexture9;
  constructor Create(dev:Idirect3ddevice9);
  procedure Init;
  procedure Render(szin:cardinal;matworld:TD3DMatrix;cam:TD3DXVector3);
  procedure RenderDistortion(szin:cardinal;matworld,matproj,matview:TD3DMatrix;cam:TD3DXVector3);
  procedure Flush;
  procedure Stand(gun:boolean);
  procedure Walk(animstate:single;gun:boolean);
  procedure Runn(animstate:single;gun:boolean);
  procedure SideWalk(animstate:single;gun:boolean);
  procedure haromszog(x1,y1,x2,y2:single; out xh,yh:single; dst1,dst2:single);
  procedure haromszog3d(a1,a2:Td3dvector; out b:Td3dVector;norm:Td3dVector; dst1:single);
  destructor Destroy;reintroduce;
 end;

 
 Tfejcucchatar = record
  vertstart,vertszam:integer;
  indstart,indszam:integer;
  minv,maxv:TD3DXVector3;
 end;

 TFejcuccrenderer = class (Tobject)
 private
  data:array of TPosNormUV;
  normdata:array of TPosNormUV;
  inddata:array of word;
  hatarok:array of Tfejcucchatar;
  RenderToTex:ID3DXRenderToSurface;
  surf:IDirect3DSurface9;
  g_pd3ddevice:IDirect3DDevice9;
  hstex:IDirect3DTexture9;
  ibWH2,vbWH2:integer;
  procedure loadOBJ(mit:string);
 public
  tex:IDirect3DTexture9;
  g_pmuksVB:IDirect3DVertexBuffer9;
  g_pmuksIB:IDirect3DIndexBuffer9;
  constructor Create(dev:Idirect3ddevice9);
  procedure Init;
  procedure Render(mit:integer;matworld:TD3DMatrix;normalized:boolean;cam:TD3DXVector3);overload;
  procedure Render(mit:integer;pos:TD3DXVector3;irany:single;cam:TD3DXVector3); overload;
  procedure Updatetex(mire:integer;tech:boolean;forg:single);
  procedure Flush;
  destructor Destroy;reintroduce;
 end;
 procedure fenykardkezek(var ajk,abk:TD3DXVector3;animstate:single;state:byte; lo:single);
var
heavyLOD:boolean;
  gunszin,techszin:cardinal;
implementation

var
 gmbindexes,kisgmbindexes,kapcsindexes:array [1..1000] of word;
function da(mit:single):single;
begin
 if mit>0.5 then
  result:=(mit-0.5)*2
 else
  result:=mit*2;
end;

function corr(x,y:integer):integer;
begin
 result:=(x+y*2) mod y;
end;

constructor TMuksoka.Create(dev:Idirect3ddevice9);
var
i,j:integer;
ind:integer;
begin
 inherited Create;
 betoltve:=false;
 g_pD3Ddevice:=dev;
 gmbk:=alapgmbk;
 kapcsk:=alapkapcsk;
  addfiletochecksum('data\fehk.png');
  LTFF(g_pd3ddevice,'data\fehk.png',tex);


  if FAILED(g_pd3dDevice.CreateVertexBuffer(20000*sizeof(TCustomVertex),
                                            D3DUSAGE_WRITEONLY or D3DUSAGE_DYNAMIC, D3DFVF_CUSTOMVERTEX,
                                            D3DPOOL_DEFAULT, g_pmuksVB, nil))
  then Exit;
  if FAILED(g_pd3dDevice.CreateIndexBuffer(40000*2,
                                            D3DUSAGE_WRITEONLY or D3DUSAGE_DYNAMIC,D3DFMT_INDEX16,
                                            D3DPOOL_DEFAULT, g_pmuksIB, nil))

  then Exit;

  for i:=0 to 6 do
   for j:=0 to 7 do
    gmb[i*8+j]:=Customvertex(sin(i*pi/6)*sin((j+i/2)*pi/4),cos(i*pi/6),sin(i*pi/6)*cos((j+i/2)*pi/4),0,0,0,0,j/7,1-i/6,0,0);

  for i:=0 to 3 do
   for j:=0 to 4 do
    kisgmb[i*5+j]:=Customvertex(sin(i*pi/3)*sin((j+i/2)*pi/2),cos(i*pi/3),sin(i*pi/3)*cos((j+i/2)*pi/2),0,0,0,0,j/4,1-i/3,0,0);

  for i:=0 to 6 do
  begin
   kapcs[i*2]:=Customvertex(sin(i*2*pi/7),0,cos(i*2*pi/7),0,0,0,0,0,0,0,0);
   kapcs[i*2+1]:=Customvertex(sin(i*2*pi/7),1,cos(i*2*pi/7),0,0,0,0,0,0,0,0);
  end;

  ind:=0;
  for i:=0 to 3 do
   for j:=0 to 4 do
   begin
    kisgmbindexes[ind+1]:=corr(i,4)*5+corr(j,5);
    kisgmbindexes[ind+0]:=corr(i,4)*5+corr(j+1,5);
    kisgmbindexes[ind+2]:=corr(i+1,4)*5+corr(j,5);
    kisgmbindexes[ind+3]:=corr(i+1,4)*5+corr(j,5);
    kisgmbindexes[ind+4]:=corr(i+1,4)*5+corr(j+1,5);
    kisgmbindexes[ind+5]:=corr(i,4)*5+corr(j+1,5);
    inc(ind,6);
   end;
  kisgmbind:=ind;

  ind:=0;
  for i:=0 to 6 do
   for j:=0 to 7 do
   begin
    gmbindexes[ind+1]:=corr(i,7)*8+corr(j,8);
    gmbindexes[ind+0]:=corr(i,7)*8+corr(j+1,8);
    gmbindexes[ind+2]:=corr(i+1,7)*8+corr(j,8);
    gmbindexes[ind+3]:=corr(i+1,7)*8+corr(j,8);
    gmbindexes[ind+4]:=corr(i+1,7)*8+corr(j+1,8);
    gmbindexes[ind+5]:=corr(i,7)*8+corr(j+1,8);
    inc(ind,6);
   end;
  gmbind:=ind;

  ind:=0;
  for i:=0 to 6 do
   begin
    kapcsindexes[ind+0]:=corr(i,7)*2;
    kapcsindexes[ind+1]:=corr(i,7)*2+1;
    kapcsindexes[ind+2]:=corr(i+1,7)*2;
    kapcsindexes[ind+4]:=corr(i+1,7)*2;
    kapcsindexes[ind+3]:=corr(i+1,7)*2+1;
    kapcsindexes[ind+5]:=corr(i,7)*2+1;
    inc(ind,6);
   end;
  kapcsind:=ind;

  gmbk[9]:=jkez;
  gmbk[8]:=bkez;
  jkl:=D3DXVector3(0.3,-1,0);
  bkl:=D3DXVector3(-0.3,-1,0);
  d3dxvec3normalize(bkl,bkl);
  d3dxvec3normalize(jkl,jkl);


  betoltve:=true;
end;

procedure TMuksoka.haromszog(x1,y1,x2,y2:single; out xh,yh:single; dst1,dst2:single);
var
c,p,m,xi,yi:single;
begin
 c:=sqrt(sqr(x1-x2)+sqr(y1-y2));
 p:=(c+(dst1*dst1-dst2*dst2)/c)/2;
 if (dst1>p) then m:=sqrt(dst1*dst1-p*p) else m:=0; 
 xi:=(x2-x1)/c; yi:=(y2-y1)/c;
 xh:=x1+xi*p-yi*m;
 yh:=y1+yi*p+xi*m;
end;

procedure TMuksoka.haromszog3d(a1,a2:Td3dvector; out b:Td3dVector;norm:Td3dVector; dst1:single);
var
cx,cy,cz,cp:Td3dVector;
a21:Td3dxvector2;
begin
// fastvec3normalize(norm);
 cy:=norm;
 d3dxvec3subtract(cx,a1,a2);
 fastvec3normalize(cx);
 cp:=a2;
 
 d3dxVec3cross(cz,cx,norm);
 d3dxVec3cross(cy,cx,cz);
 d3dxvec3subtract(a1,a1,a2);
 a21.x:=d3dxvec3dot(a1,cx)/2;

 if a21.x>dst1 then
 a21.y:=0
 else
 a21.y:=sqrt(dst1*dst1-a21.x*a21.x);

 d3dxvec3scale(cx,cx,a21.x);
 d3dxvec3scale(cy,cy,a21.y);
 d3dxvec3add(cp,cp,cx);
 d3dxvec3subtract(cp,cp,cy);

 b:=cp;
end;

procedure TMuksoka.Stand(gun:boolean);
var i:integer;
begin
 gmbk:=alapgmbk;
 for i:=0 to high(gmbk) do
begin
 gmbk[i]:=alapgmbk[i];
 if gun then
  gmbk[i].y:=alapgmbk[i].y-0.5
 else
  gmbk[i].y:=alapgmbk[i].y;
end;
 //lábak
 gmbk[0].y:=0;
 gmbk[1].y:=0;

haromszog(gmbk[0].z,gmbk[0].y,gmbk[4].z,gmbk[4].y,gmbk[2].z,gmbk[2].y,0.405,0.405);
haromszog(gmbk[1].z,gmbk[1].y,gmbk[4].z,gmbk[4].y,gmbk[3].z,gmbk[3].y,0.405,0.405);
 //kezek
  gmbk[9]:=jkez;
  gmbk[8]:=bkez;
  haromszog3d(gmbk[9],gmbk[5],gmbk[7],jkl,0.3);
haromszog3d(gmbk[8],gmbk[5],gmbk[6],bkl,0.3);
end;

procedure Tmuksoka.Walk(animstate:single;gun:boolean);
var
i:integer;
begin
if not gun then animstate:=da(animstate);
for i:=0 to high(gmbk) do
begin
 gmbk[i]:=alapgmbk[i];
 if gun then
  gmbk[i].y:=alapgmbk[i].y+abs(sin(animstate*2*D3DX_PI))*0.05-0.5
 else
  gmbk[i].y:=alapgmbk[i].y+abs(sin(animstate*2*D3DX_PI))*0.05
end;

//labak
if gun then
begin
gmbk[0].y:=max(sin(animstate*2*D3DX_PI),0)/20;
gmbk[1].y:=max(sin(-animstate*2*D3DX_PI),0)/20;
gmbk[0].z:=(abs(animstate-0.5)-0.25)/2;
gmbk[1].z:=-gmbk[0].z;
end
else
begin
gmbk[0].y:=max(sin(animstate*2*D3DX_PI),0)/10;
gmbk[1].y:=max(sin(-animstate*2*D3DX_PI),0)/10;
gmbk[0].z:=(abs(animstate-0.5)-0.25);
gmbk[1].z:=-gmbk[0].z;
end;

haromszog(gmbk[0].z,gmbk[0].y,gmbk[4].z,gmbk[4].y,gmbk[2].z,gmbk[2].y,0.405,0.405);
haromszog(gmbk[1].z,gmbk[1].y,gmbk[4].z,gmbk[4].y,gmbk[3].z,gmbk[3].y,0.405,0.405);

//kezek
gmbk[9]:=jkez;
gmbk[8]:=bkez;
haromszog3d(gmbk[9],gmbk[5],gmbk[7],jkl,0.3);
haromszog3d(gmbk[8],gmbk[5],gmbk[6],bkl,0.3);
end;

procedure fenykardkezek(var ajk,abk:TD3DXVector3;animstate:single;state:byte; lo:single);
var
a1,a2:single;
begin

 if (state and mstat_csipo)>0 then
 begin
  if (state and MSTAT_MASK) =0 then
  begin
   ajk:=alapgmbk[9];
   ajk.y:=ajk.y+0.1;
   ajk.z:=ajk.z-0.1;
   abk:=alapgmbk[8];
   abk.y:=abk.y+0.1;
   abk.z:=abk.z-0.1;
  end
  else
  begin
   if (state and MSTAT_MASK) =MSTAT_FUT then
   begin
    a1:=(sin(da(animstate)*2*D3DX_PI)+1);
    a2:=(sin(da(animstate)*2*D3DX_PI+D3DX_PI)+1);
   end
   else
   begin
   a1:=0;
    a2:=0;
    end;
   ajk.y:=1.3-cos(a1)/5;
   ajk.z:=(-sin(a1))/2;
   ajk.x:=ajk.z/3;

   abk.y:=1.3-cos(a2)/5;
   abk.z:=(-sin(a2))/2;
   abk.x:=abk.z/3;
  end;
 end
 else
 begin
  if lo=1 then
   animstate:=0.0;

  abk.x:=sin(animstate*2*D3DX_PI)/4;
  abk.y:=-sin(animstate*4*D3DX_PI)/4+1.2;
  abk.z:=-cos(animstate*4*D3DX_PI)/6-1/6;

  ajk.x:=sin(animstate*2*D3DX_PI+0.2)/4.2;
  ajk.y:=-sin(animstate*4*D3DX_PI+0.2)/4.2+1.16;
  ajk.z:=-(cos(animstate*4*D3DX_PI+0.2)+1)/6.5;
 end;

end;


procedure Tmuksoka.Runn(animstate:single;gun:boolean);
var
i:integer;
an2:single;
begin
if gun then animstate:=da(animstate);
for i:=0 to high(gmbk) do
begin
 gmbk[i]:=alapgmbk[i];
 gmbk[i].y:=alapgmbk[i].y+abs(sin(animstate*2*D3DX_PI))*0.1-0.1;
end;

//labak
an2:=abs(animstate-0.5);

gmbk[0].y:=sin(animstate*2*D3DX_PI)/5+an2/1.2;
gmbk[0].z:=cos(animstate*2*D3DX_PI)/3;
gmbk[1].y:=sin((animstate*2+1)*D3DX_PI)/5+(0.5-an2)/1.2;
gmbk[1].z:=cos((animstate*2+1)*D3DX_PI)/3;
haromszog(gmbk[0].z,gmbk[0].y,gmbk[4].z,gmbk[4].y,gmbk[2].z,gmbk[2].y,0.405,0.405);
haromszog(gmbk[1].z,gmbk[1].y,gmbk[4].z,gmbk[4].y,gmbk[3].z,gmbk[3].y,0.405,0.405);

//kezek
gmbk[9]:=jkez;
gmbk[8]:=bkez;
haromszog3d(gmbk[9],gmbk[5],gmbk[7],jkl,0.3);
haromszog3d(gmbk[8],gmbk[5],gmbk[6],bkl,0.3);
end;

procedure Tmuksoka.SideWalk(animstate:single;gun:boolean);
var
i:integer;
begin
if not gun then animstate:=da(animstate);
for i:=0 to high(gmbk) do
begin
 gmbk[i]:=alapgmbk[i];
 if gun then
  gmbk[i].y:=alapgmbk[i].y+abs(sin(animstate*2*D3DX_PI))*0.05-0.5
 else
  gmbk[i].y:=alapgmbk[i].y+abs(sin(animstate*2*D3DX_PI))*0.05
end;

//labak
gmbk[0].y:=max(sin(animstate*2*D3DX_PI),0)/10;
gmbk[1].y:=max(sin(-animstate*2*D3DX_PI),0)/10;
gmbk[0].x:=(abs(animstate-0.5)-0.25);
gmbk[1].x:=-gmbk[0].x;
gmbk[1].z:=0.05;
gmbk[0].z:=-0.05;
haromszog(gmbk[0].x,gmbk[0].y,gmbk[4].x,gmbk[4].y,gmbk[2].z,gmbk[2].y,0.405,0.405);
haromszog(gmbk[1].x,gmbk[1].y,gmbk[4].x,gmbk[4].y,gmbk[3].z,gmbk[3].y,0.405,0.405);
gmbk[2].z:=-abs(gmbk[2].z);
gmbk[3].z:=-abs(gmbk[3].z);
//kezek
gmbk[9]:=jkez;
gmbk[8]:=bkez;
haromszog3d(gmbk[9],gmbk[5],gmbk[7],jkl,0.3);
haromszog3d(gmbk[8],gmbk[5],gmbk[6],bkl,0.3);
end;

procedure TMuksoka.Init;
begin

g_pd3dDevice.SetStreamSource(0, g_pmuksVB, 0, SizeOf(TCustomVertex));
g_pd3dDevice.SetIndices(g_pmuksIB);
g_pd3dDevice.SetFVF(D3DFVF_CUSTOMVERTEX);

g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG2);


end;

procedure TMuksoka.Render(szin:cardinal;matworld:TD3DMatrix;cam:TD3DXVector3);
var
i,j,k:integer;
xh,yh,zh:TD3DVector;
mat:TD3DMatrix;
pVertices: PCustomVertexArray;
pindices:PWordarray;
lockmode:cardinal;
 IBwh,VBwh:integer;
 LOD:integer;
 dst:single;
 transgmbk:Tgmbk;
 vu,vl:Td3dxvector3;
 vec:TCustomvertex;
 ind,ind2:integer;
 v1,v2a,vp:TD3DXVector3;
begin
{$R-}

Ibwh:=0;
VBwh:=0;
if IBwh2=0 then
lockmode:=D3DLOCK_DISCARD
else
lockmode:=D3DLOCK_NOOVERWRITE;

if FAILED(g_pmuksIB.Lock(IBwh2*2, gmbind*2*length(gmbk)+kapcsind*2*length(kapcsk), Pointer(pindices), lockmode))
  then Exit;
if FAILED(g_pmuksVB.Lock(VBwh2*sizeof(Tcustomvertex), (length(kisgmb)+length(kapcs))*sizeof(Tcustomvertex), Pointer(pVertices), lockmode))
  then Exit;


d3dxvec3transformcoordarray(pointer(addr(transgmbk[0])),sizeof(TD3DXVector3),pointer(addr(gmbk[0])),sizeof(TD3DXVector3),matworld,length(gmbk));

dst:=tavpointpointsq(transgmbk[10],cam);
if dst>sqr(20) then LOD:=10 else
if dst>sqr(7)  then LOD:=9 else
                    LOD:=-1;

if (LOD<10) and (not heavyLOD) then
begin
//SIMA POLIS MUKSÓKÁM
 for i:=0 to LOD do
 begin
   for k:=0 to high(kisgmb) do
   begin
    j:=k+VBwh;
     pVertices[j]:=kisgmb[k];
    pVertices[j].color:=szin;
    pVertices[j].u:=0.5;    pVertices[j].v:=0.5;
    if i=high(transgmbk) then
      d3dxvec3scale(pVertices[j].position,pVertices[j].position,fejvst)
    else
     d3dxvec3scale(pVertices[j].position,pVertices[j].position,vst);
   d3dxvec3add(pVertices[j].position,pVertices[j].position,transgmbk[i]);
   end;
   for j:=0 to kisgmbind-1 do
    pindices[j+IBwh]:=kisgmbindexes[j]+VBwh+VBwh2;
    VBwh:=VBwh+length(kisgmb);
   IBwh:=IBwh+kisgmbind;
 end;

 for i:=LOD+1 to high(transgmbk) do
 begin
   for k:=0 to high(gmb) do
   begin
    j:=k+VBwh;
    pVertices[j]:=gmb[k];
    pVertices[j].color:=szin;
    pVertices[j].u:=0.5;    pVertices[j].v:=0.5;
    if i=high(transgmbk) then
     d3dxvec3scale(pVertices[j].position,pVertices[j].position,fejvst)
    else
     d3dxvec3scale(pVertices[j].position,pVertices[j].position,vst);
    d3dxvec3add(pVertices[j].position,pVertices[j].position,transgmbk[i]);
   end;
   for j:=0 to gmbind-1 do
   pindices[j+IBwh]:=gmbindexes[j]+VBwh+VBwh2;
   VBwh:=VBwh+length(gmb);
   IBwh:=IBwh+gmbind;
end;


 for i:=0 to high(kapcsk) do
 begin

  d3dxvec3subtract(yh,transgmbk[kapcsk[i,0]],transgmbk[kapcsk[i,1]]);
  d3dxvec3cross(xh,yh,D3DXVector3(0,0,1));
  d3dxvec3cross(zh,yh,xh);
  fastvec3normalize(xh);
  fastvec3normalize(zh);
  mat._11:=xh.x*vst;mat._12:=xh.y*vst;mat._13:=xh.z*vst;mat._14:=0;
  mat._21:=yh.x;mat._22:=yh.y;mat._23:=yh.z;mat._24:=0;
  mat._31:=zh.x*vst;mat._32:=zh.y*vst;mat._33:=zh.z*vst;mat._34:=0;
  mat._41:=transgmbk[kapcsk[i,1]].x;mat._42:=transgmbk[kapcsk[i,1]].y;mat._43:=transgmbk[kapcsk[i,1]].z;mat._44:=1;
  for j:=0 to high(kapcs) do
  begin
   pVertices[j+VBwh]:=kapcs[j];
   pVertices[j+VBwh].u:=0.5;    pVertices[j+VBwh].v:=0.5;
   pVertices[j+VBwh].color:=szin;
  end;
  //d3dxmatrixmultiply(mat2,mat,matworld);
  d3dxvec3transformcoordarray(pointer(addr(pVertices^[VBwh].position)),sizeof(Tcustomvertex),pointer(addr(kapcs[0].position)),sizeof(Tcustomvertex),mat,length(kapcs));

  for j:=0 to kapcsind-1 do
   pindices[j+IBwh]:=kapcsindexes[j]+VBwh+VBwh2;
  VBwh:=VBwh+length(kapcs);
  IBwh:=IBwh+kapcsind;
end;
//SIMA POLIS MUKSÓ VÉGE
end
else
begin
//SPRITE MUKSÓ
 d3dxvec3scale(vu,upvec,vst*SQRT2);
 d3dxvec3scale(vL,lvec,vst*SQRT2);
 vec.u:=0;  vec.v:=0;
 vec.u2:=0.5;  vec.v2:=0.5;
 vec.color:=szin;
 for i:=0 to high(transgmbk)-1 do
 begin
  ind:=VBwh;
  VBwh:=VBwh+4;
  vec.u:=0;  vec.v:=0;
  d3dxvec3add(vec.position ,transgmbk[i],vu);
  pVertices[ind+0]:=vec;
  vec.v:=1;
  d3dxvec3add(vec.position,transgmbk[i],vl);
  pVertices[ind+1]:=vec;

  vec.u:=1;
  vec.v:=1;
  d3dxvec3subtract(vec.position,transgmbk[i],vu);
  pVertices[ind+2]:=vec;
  vec.u:=0;
  d3dxvec3subtract(vec.position,transgmbk[i],vl);
  pVertices[ind+3]:=vec;

  ind2:=IBwh;
  IBwh:=IBwh+6;
  pIndices[ind2+0]:=VBwh2+ind+0;
  pIndices[ind2+1]:=VBwh2+ind+2;
  pIndices[ind2+2]:=VBwh2+ind+1;
  pIndices[ind2+3]:=VBwh2+ind+0;
  pIndices[ind2+4]:=VBwh2+ind+3;
  pIndices[ind2+5]:=VBwh2+ind+2;
 end;
  d3dxvec3scale(vu,upvec,fejvst*SQRT2);
 d3dxvec3scale(vL,lvec,fejvst*SQRT2);
  ind:=VBwh;
  VBwh:=VBwh+4;
  vec.u:=0;  vec.v:=0;
  d3dxvec3add(vec.position ,transgmbk[high(transgmbk)],vu);
  pVertices[ind+0]:=vec;
  vec.v:=1;
  d3dxvec3add(vec.position,transgmbk[high(transgmbk)],vl);
  pVertices[ind+1]:=vec;

  vec.u:=1;
  vec.v:=1;
  d3dxvec3subtract(vec.position,transgmbk[high(transgmbk)],vu);
  pVertices[ind+2]:=vec;
  vec.u:=0;
  d3dxvec3subtract(vec.position,transgmbk[high(transgmbk)],vl);
  pVertices[ind+3]:=vec;

  ind2:=IBwh;
  IBwh:=IBwh+6;
  pIndices[ind2+0]:=VBwh2+ind+0;
  pIndices[ind2+1]:=VBwh2+ind+2;
  pIndices[ind2+2]:=VBwh2+ind+1;
  pIndices[ind2+3]:=VBwh2+ind+0;
  pIndices[ind2+4]:=VBwh2+ind+3;
  pIndices[ind2+5]:=VBwh2+ind+2;

  for i:=0 to high(kapcsk) do
  begin

    v1:=transgmbk[kapcsk[i,0]];
    v2a:=transgmbk[kapcsk[i,1]];

    d3dxvec3subtract(vu,campos,v1);

    d3dxvec3subtract(vl,v1,v2a);

    d3dxvec3cross(vp,vu,vl);
    dst:=d3dxvec3lengthsq(vp);
    if dst>0.0001 then
     d3dxvec3scale(vp,vp,vst*fastinvsqrt(dst));


    ind:=VBwh;
    VBwh:=VBwh+4;

    vec.u:=0;
    vec.v:=0.5;

    d3dxvec3add(vec.position,v1,vp);
    pVertices[ind+0]:=vec;

    d3dxvec3add(vec.position,v2a,vp);
    pVertices[ind+1]:=vec;
    vec.u:=1;

    d3dxvec3subtract(vec.position,v1,vp);
    pVertices[ind+2]:=vec;

    d3dxvec3subtract(vec.position,v2a,vp);
    pVertices[ind+3]:=vec;

    ind2:=IBwh;
    IBwh:=IBwh+6;
    pIndices[ind2+0]:=VBwh2+ind+0;
    pIndices[ind2+1]:=VBwh2+ind+1;
    pIndices[ind2+2]:=VBwh2+ind+2;
    pIndices[ind2+3]:=VBwh2+ind+1;
    pIndices[ind2+4]:=VBwh2+ind+3;
    pIndices[ind2+5]:=VBwh2+ind+2;
  end;

end;






g_pmuksIb.Unlock;
g_pmuksVB.Unlock;


IBwh2:=IBwh2+IBwh;

VBwh2:=VBwh2+VBwh;

if IBwh2>35000 then
 flush;

end;

procedure TMuksoka.RenderDistortion(szin:cardinal;matworld,matproj,matview:TD3DMatrix;cam:TD3DXVector3);
var
i,j,k:integer;
xh,yh,zh:TD3DVector;
mat:TD3DMatrix;
pVertices: PCustomVertexArray;
pindices:PWordarray;
lockmode:cardinal;
 IBwh,VBwh:integer;
 LOD:integer;
 dst:single;
 transgmbk:Tgmbk;
 UV1,UV2:array of TD3DXVector3;
begin
{$R-}

Ibwh:=0;
VBwh:=0;

setlength(UV1,1000);

if IBwh2=0 then
lockmode:=D3DLOCK_DISCARD
else
lockmode:=D3DLOCK_NOOVERWRITE;

if FAILED(g_pmuksIB.Lock(IBwh2*2, gmbind*2*length(gmbk)+kapcsind*2*length(kapcsk), Pointer(pindices), lockmode))
  then Exit;
if FAILED(g_pmuksVB.Lock(VBwh2*sizeof(Tcustomvertex), (length(kisgmb)+length(kapcs))*sizeof(Tcustomvertex), Pointer(pVertices), lockmode))
  then Exit;


d3dxvec3transformcoordarray(pointer(addr(transgmbk[0])),sizeof(TD3DXVector3),pointer(addr(gmbk[0])),sizeof(TD3DXVector3),matworld,length(gmbk));

dst:=tavpointpointsq(transgmbk[10],cam);
if dst>sqr(20) then LOD:=10 else
if dst>sqr(7)  then LOD:=9 else
                    LOD:=-1;
for i:=0 to LOD do
begin
  for k:=0 to high(kisgmb) do
  begin
   j:=k+VBwh;
   pVertices[j]:=kisgmb[k];
   pVertices[j].color:=szin;

   if i=high(transgmbk) then
    d3dxvec3scale(pVertices[j].position,pVertices[j].position,fejvst)
   else
    d3dxvec3scale(pVertices[j].position,pVertices[j].position,vst);
   d3dxvec3scale(UV1[j],pVertices[j].position,2);
   d3dxvec3add(pVertices[j].position,pVertices[j].position,transgmbk[i]);
   d3dxvec3add(UV1[j],UV1[j],transgmbk[i]);
  end;
  for j:=0 to kisgmbind-1 do
   pindices[j+IBwh]:=kisgmbindexes[j]+VBwh+VBwh2;
  VBwh:=VBwh+length(kisgmb);
  IBwh:=IBwh+kisgmbind;
end;

for i:=LOD+1 to high(transgmbk) do
begin
  for k:=0 to high(gmb) do
  begin
   j:=k+VBwh;
   pVertices[j]:=gmb[k];
   pVertices[j].color:=szin;
   if i=high(transgmbk) then
    d3dxvec3scale(pVertices[j].position,pVertices[j].position,fejvst)
   else
    d3dxvec3scale(pVertices[j].position,pVertices[j].position,vst);
    d3dxvec3scale(UV1[j],pVertices[j].position,2);
   d3dxvec3add(pVertices[j].position,pVertices[j].position,transgmbk[i]);
   d3dxvec3add(UV1[j],UV1[j],transgmbk[i]);
  end;
  for j:=0 to gmbind-1 do
   pindices[j+IBwh]:=gmbindexes[j]+VBwh+VBwh2;
  VBwh:=VBwh+length(gmb);
  IBwh:=IBwh+gmbind;
end;



for i:=0 to high(kapcsk) do
begin

  d3dxvec3subtract(yh,transgmbk[kapcsk[i,0]],transgmbk[kapcsk[i,1]]);
  d3dxvec3cross(xh,yh,D3DXVector3(0,0,1));
  d3dxvec3cross(zh,yh,xh);
  fastvec3normalize(xh);
  fastvec3normalize(zh);
  mat._11:=xh.x*vst;mat._12:=xh.y*vst;mat._13:=xh.z*vst;mat._14:=0;
  mat._21:=yh.x;mat._22:=yh.y;mat._23:=yh.z;mat._24:=0;
  mat._31:=zh.x*vst;mat._32:=zh.y*vst;mat._33:=zh.z*vst;mat._34:=0;
  mat._41:=transgmbk[kapcsk[i,1]].x;mat._42:=transgmbk[kapcsk[i,1]].y;mat._43:=transgmbk[kapcsk[i,1]].z;mat._44:=1;
  for j:=0 to high(kapcs) do
  begin
   pVertices[j+VBwh]:=kapcs[j];
   pVertices[j+VBwh].color:=szin;
  end;
  //d3dxmatrixmultiply(mat2,mat,matworld);
  d3dxvec3transformcoordarray(pointer(addr(pVertices^[VBwh].position)),sizeof(Tcustomvertex),pointer(addr(kapcs[0].position)),sizeof(Tcustomvertex),mat,length(kapcs));

  mat._11:=xh.x*vst*2;mat._12:=xh.y*vst*2;mat._13:=xh.z*vst*2;mat._14:=0;
  mat._31:=zh.x*vst*2;mat._32:=zh.y*vst*2;mat._33:=zh.z*vst*2;mat._34:=0;

  d3dxvec3transformcoordarray(pointer(addr(UV1[VBwh])),sizeof(TD3DXVector3),pointer(addr(kapcs[0].position)),sizeof(Tcustomvertex),mat,length(kapcs));


  for j:=0 to kapcsind-1 do
   pindices[j+IBwh]:=kapcsindexes[j]+VBwh+VBwh2;
  VBwh:=VBwh+length(kapcs);
  IBwh:=IBwh+kapcsind;
end;

d3dxmatrixmultiply(matproj,matview,matproj);

  setlength(UV2,VBwh);
 d3dxvec3transformcoordarray(pointer(addr(UV2[0])),sizeof(TD3DXVector3),pointer(addr(UV1[0])),sizeof(TD3DXVector3),matproj,VBwh);
  setlength(UV1,0);
for i:=0 to VBwh-1 do
begin
 pvertices[i].u:=(UV2[i].x+1)*0.5;
 pvertices[i].v:=(1-UV2[i].y)*0.5;
end;
 setlength(UV2,0);

g_pmuksIb.Unlock;
g_pmuksVB.Unlock;


IBwh2:=IBwh2+IBwh;
VBwh2:=VBwh2+VBwh;

if IBwh2>35000 then
 flush;

end;


procedure Tmuksoka.flush;
begin
 g_pd3dDevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST,0,0,VBwh2,0,IBwh2 div 3);
 VBwh2:=0;
 IBWh2:=0;
end;

destructor TMuksoka.Destroy;
begin
 if g_pd3ddevice<> nil then
 g_pD3Ddevice:=nil;
 inherited Destroy;
end;


constructor TFejcuccrenderer.Create(dev:Idirect3ddevice9);
var
 hib:HRESULT;
 i:integer;
begin
  g_pd3ddevice:=dev;

  if FAILED(g_pd3dDevice.CreateVertexBuffer(20000*sizeof(TPosNormUV),
                                            D3DUSAGE_WRITEONLY+D3DUSAGE_DYNAMIC, D3DFVF_PosNormUV,
                                            D3DPOOL_DEFAULT, g_pmuksVB, nil))
  then Exit;
  if FAILED(g_pd3dDevice.CreateIndexBuffer(20000*2,
                                            D3DUSAGE_WRITEONLY+D3DUSAGE_DYNAMIC,D3DFMT_INDEX16,
                                            D3DPOOL_DEFAULT, g_pmuksIB, nil))

  then Exit;


  for i:=0 to stuffjson.GetNum(['hats'])-1 do
  begin
   loadOBJ(stuffjson.GetString(['hats',i]));
  end;
   
  LTFF(g_pd3ddevice,'data\hs\hstex.bmp',hstex,TEXFLAG_FIXRES);
  addfiletochecksum('data\hs\hstex.bmp');
  writeln(logfile,'Loaded head items...');
  system.flush(logfile);


  // Create renders target texture
  hib := D3DXCreateTexture(g_pd3dDevice, round(vertScale*64),round(vertScale*64),0, D3DUSAGE_RENDERTARGET,D3DFMT_A8R8G8B8,D3DPOOL_DEFAULT, tex);
  if FAILED(hib) then
  begin
    hib := D3DXCreateTexture(g_pd3dDevice, round(vertScale*64),round(vertScale*64), 0, 0, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, tex);
    if FAILED(hib) then Exit;
  end;

  tex.GetSurfaceLevel(0, surf);

  // Create a ID3DXRenderToSurface to help render to a texture on cards
  // that don't support render targets
  D3DXCreateRenderToSurface(g_pd3dDevice, round(vertScale*64), round(vertScale*64),
              D3DFMT_A8R8G8B8, true, D3DFMT_D16, RenderToTex);
  writeln(logfile,'Loaded head item displayer...');
  system.flush(logfile);
end;

procedure TFejcuccrenderer.loadOBJ(mit:string);
var
tmpv:array of TD3DXVector3;
tmpvn:array of TD3DXVector3;
tmpuv:array of TD3DXVector2;
osszerakott:array of TPosNormUV;
osszerakottkeys:array of cardinal;
keymost:cardinal;
osszerakottind:array of word;
aminv,amaxv:TD3DXVector3;
fil:textfile;
str:string;
e0:Tarrayofstring;
ex:array [0..2] of Tarrayofstring;
i1,i2,i3:integer;
i,j:integer;
hol:integer;
pls:TD3DXVector3;
szor:TD3DXVector3;
begin
 DecimalSeparator:='.';
 aminv:=D3DXVector3(1000,1000,1000);
 amaxv:=D3DXVector3(-1000,-1000,-1000);

 addfiletochecksum('data\hs\'+mit+'.obj');
 assignfile(fil,'data\hs\'+mit+'.obj');

 reset(fil);
 if eof(fil) then
 begin
  writeln(logfile,'Could not load head item "'+mit+'"');
  system.flush(logfile);
  exit;
 end;

 repeat
  readln(fil,str);
  if str[1]='v' then
  begin
   case str[2] of
    ' ':begin
         str:=copy(str,3,100);
         explode(str,' ',e0);
         setlength(tmpv,length(tmpv)+1);
         tmpv[high(tmpv)]:=D3DXVector3(-strtofloat(e0[2])*fejvst,strtofloat(e0[1])*fejvst,-strtofloat(e0[0])*fejvst);

         d3dxvec3minimize(aminv,aminv,tmpv[high(tmpv)]);
         d3dxvec3maximize(amaxv,amaxv,tmpv[high(tmpv)]);
         setlength(e0,0);
        end;

    'n':begin
         str:=copy(str,4,100);
         explode(str,' ',e0);
         setlength(tmpvn,length(tmpvn)+1);
         tmpvn[high(tmpvn)]:=D3DXVector3(strtofloat(e0[0]),strtofloat(e0[1]),strtofloat(e0[2]));
         setlength(e0,0);
        end;
    't':begin
         str:=copy(str,4,100);
         explode(str,' ',e0);
         setlength(tmpuv,length(tmpuv)+1);
         tmpuv[high(tmpuv)]:=D3DXVector2(strtofloat(e0[0]),strtofloat(e0[1]));
         setlength(e0,0);
        end;
   end;
  end
  else
  if str[1]='f' then
  begin
   str:=copy(str,3,100);

   explode(str,' ',e0);

   explode(e0[0],'/',ex[0]);
   explode(e0[1],'/',ex[1]);
   explode(e0[2],'/',ex[2]);

   setlength(osszerakottind,length(osszerakottind)+3);
   for i:=0 to 2 do
   begin

    i1:=strtoint(ex[i][0]);
    i2:=strtoint(ex[i][1]);
    i3:=strtoint(ex[i][2]);
    keymost:=i1+1024*(i2+1024*i3);
    hol:=-1;
    for j:=0 to high(osszerakottkeys) do
     if osszerakottkeys[j]=keymost then begin hol:=j; break; end;
    if hol>=0 then
     osszerakottind[high(osszerakottind)-i]:=hol
    else
    begin
     setlength(osszerakottkeys,length(osszerakottkeys)+1);
     osszerakottkeys[high(osszerakottkeys)]:=keymost;
     setlength(osszerakott,length(osszerakottkeys));
     with osszerakott[high(osszerakott)] do
     begin
      position:=tmpv[i1-1];
      normal:=tmpvn[i3-1];
      u:=tmpuv[i2-1].x;
      v:=1-tmpuv[i2-1].y;
     end;
     osszerakottind[high(osszerakottind)-i]:=high(osszerakott);
    end;
   end;
  end;
 until eof(fil);
 closefile(fil);
 
 setlength(hatarok,length(hatarok)+1);
 with hatarok[high(hatarok)] do
 begin
  minv:=aminv;
  maxv:=amaxv;

  vertstart:=length(data);
  vertszam:=length(osszerakott);
  setlength(data,length(data)+vertszam);
  for i:=0 to high(osszerakott) do
   data[vertstart+i]:=osszerakott[i];


  indstart:=length(inddata);
  indszam:=length(osszerakottind);
  setlength(inddata,length(inddata)+indszam);
  for i:=0 to high(osszerakottind) do
   inddata[indstart+i]:=osszerakottind[i];

  d3dxvec3add(pls,minv,maxv);
  d3dxvec3scale(pls,pls,-0.5);
  d3dxvec3subtract(szor,maxv,minv);
  szor.x:=2/szor.x; szor.y:=2/szor.y; szor.z:=2/szor.z;
  setlength(normdata,length(data));
  for i:=0 to high(osszerakott) do
  begin
  with osszerakott[i] do
  begin
   d3dxvec3add(position,position,pls);
   position.x:=position.x*szor.x;
   position.y:=position.y*szor.y;
   position.z:=position.z*szor.z;
   normal.x:=normal.x*szor.x;
   normal.y:=normal.y*szor.y;
   normal.z:=normal.z*szor.z;
  end;
   normdata[vertstart+i]:=osszerakott[i];
  end;
 end;

 DecimalSeparator:=',';
 setlength(osszerakott,0);
 setlength(osszerakottind,0);
 setlength(osszerakottkeys,0);
 setlength(tmpv,0);
 setlength(tmpvn,0);
 setlength(tmpuv,0);

end;

procedure TFejcuccrenderer.Init;
begin
g_pd3dDevice.SetStreamSource(0, g_pmuksVB, 0, SizeOf(TPosNormUV));
g_pd3dDevice.SetIndices(g_pmuksIB);
g_pd3dDevice.SetFVF(D3DFVF_PosNormUV);
g_pd3dDevice.SetTexture(0,hstex);

g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_MODULATE);

end;


procedure TFejcuccrenderer.flush;
begin
  if (VBwh2>0) and ((IBwh2 div 3)>0) then
 g_pd3dDevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST,0,0,VBwh2,0,IBwh2 div 3);
 VBwh2:=0;
 IBWh2:=0;
end;

procedure TFejcuccrenderer.Render(mit:integer;matworld:TD3DMatrix;normalized:boolean;cam:TD3DXVector3);
var
pVertices: PPosNormUVArray;
pindices:PWordarray;
lockmode:cardinal;
i:integer;
begin
{$R-}

//if tavpointpointsq(D3DXvector3(matworld._41,matworld._42,matworld._43),cam)>sqr(50) then exit;

if IBwh2=0 then
 lockmode:=D3DLOCK_DISCARD
else
 lockmode:=D3DLOCK_NOOVERWRITE;

with hatarok[mit] do
begin
if FAILED(g_pmuksIB.Lock(IBwh2*2, indszam*2, Pointer(pindices), lockmode))
  then Exit;
if FAILED(g_pmuksVB.Lock(VBwh2*sizeof(TPosNormUV), vertszam*sizeof(TPosNormUV), Pointer(pVertices), lockmode))
  then Exit;


if normalized then
begin
  d3dxvec3transformcoordarray(@(pvertices[0].position),sizeof(TPosNormUV),@(normdata[0].position),sizeof(TPosNormUV),matworld,vertszam);
  d3dxvec3transformnormalarray(@(pvertices[0].normal ),sizeof(TPosNormUV),@(normdata[0].normal  ),sizeof(TPosNormUV),matworld,vertszam);
end
else
begin
 for i:=0 to vertszam-1 do
 begin
  d3dxvec3transformcoord(pvertices[i].position,data[vertstart+i].position,matworld);
  d3dxvec3transformnormal(pvertices[i].normal,data[vertstart+i].normal,matworld);
  pvertices[i].u:=data[vertstart+i].u;
  pvertices[i].v:=data[vertstart+i].v;
 end;
end;

for i:=0 to indszam-1 do
 pindices[i]:=VBwh2+inddata[indstart+i];

g_pmuksIb.Unlock;
g_pmuksVB.Unlock;


IBwh2:=IBwh2+indszam;

VBwh2:=VBwh2+vertszam;

end;

if IBwh2>35000 then
 flush;

end;

procedure TFejcuccrenderer.Render(mit:integer;pos:TD3DXVector3;irany:single;cam:TD3DXVector3);
var
amv:TD3DMatrix;
begin
 D3DXmatrixRotationY(amv,irany);
 amv._41:=pos.x;
 amv._42:=pos.y+1.5;
 amv._43:=pos.z;
 render(mit,amv,false,cam);
end;

procedure Tfejcuccrenderer.Updatetex(mire:integer;tech:boolean;forg:single);
type
Tszinesvertex = record
 position:TD3DXVector3;
 szin:cardinal;
end;
const
D3DFVF_SZINESVERTEX = (D3DFVF_XYZ or D3DFVF_DIFFUSE);
var
VP:TD3DViewport9;
matWorld,matView,matProj:TD3DMatrix;
fejverts:array [0..30] of Tszinesvertex;
veyept,vlookatpt,vupvec:TD3DXVector3;
i:integer;
 mtrl: TD3DMaterial9;
  vecDir: TD3DXVector3;
  light: TD3DLight9;
begin
 Vp.X:=0;
 VP.y:=0;
 vp.Width:=64;
 vp.Height:=64;
 vp.MinZ:=0;
 vp.MaxZ:=1;

 if not FAILED(Rendertotex.BeginScene(surf,nil)) then
 begin
  g_pd3dDevice.Clear(0, nil, D3DCLEAR_TARGET or D3DCLEAR_ZBUFFER,
                       0, 1.0, 0);
  // Set up a material. The material here just has the diffuse and ambient
  // colors set to white. Note that only one material can be used at a time.
  ZeroMemory(@mtrl, SizeOf(TD3DMaterial9));
  mtrl.Diffuse.r := 1.0; mtrl.Ambient.r := 1.0;
 // if (halal=0) or (halal>1.5) then
  begin
   mtrl.Diffuse.g := 1.0; mtrl.Ambient.g := 1.0;
   mtrl.Diffuse.b := 1.0; mtrl.Ambient.b := 1.0;
  end;
   mtrl.Diffuse.a := 1.0; mtrl.Ambient.a := 1.0;

  g_pd3dDevice.SetMaterial(mtrl);

  // Set up a white, directional light, with an oscillating direction.
  // Note that many lights may be active at a time (but each one slows down
  // the rendering of our scene). However, here we are just using one. Also,
  // we need to set the D3DRS_LIGHTING renderstate to enable lighting
  ZeroMemory(@light, SizeOf(TD3DLight9));
  light._Type      := D3DLIGHT_DIRECTIONAL;
  light.Diffuse.r  := 1.0;
  light.Diffuse.g  := 1.0;
  light.Diffuse.b  := 0.9;
  light.Diffuse.a := 1;
 // light.Ambient.r  := 0.1;
  //light.Ambient.g  := 1.0-halal;
  //light.Ambient.b  := 1.0-halal;
  //light.Ambient.a := 1;
  vecDir:= D3DXVector3(0,-1.0,-1);
  D3DXVec3Normalize(light.Direction, vecDir);
  light.Range := 1000.0;
  g_pd3dDevice.SetLight(0, light);
  g_pd3dDevice.LightEnable(0, True);
  
  g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iTrue);

  // Finally, turn on some ambient light.
  //if (halal=0) or (halal>1.5) then
  g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $FF606060);
  //else

  // For our world matrix, we will just leave it as the identity
  D3DXMatrixIdentity(matWorld);
  g_pd3dDevice.SetTransform(D3DTS_WORLD, matWorld);
  vEyePt:=    D3DXVector3(0,0,-1.2);
  vLookatPt:= D3DXVector3Zero;
  vUpVec:=    D3DXVector3(0,1,0);

  D3DXMatrixLookAtLH(matView, vEyePt, vLookatPt, vUpVec);

  g_pd3dDevice.SetTransform(D3DTS_VIEW, matView);

  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/16, 1, 0.01, 10.0);
  g_pd3dDevice.SetTransform(D3DTS_PROJECTION, matProj);

  g_pd3dDevice.SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR );
  g_pd3dDevice.SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR );
  g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_NONE);
  g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_CLAMP);
  g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_CLAMP);

  g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE,ifalse);
  g_pd3dDevice.SetRenderState(D3DRS_CULLMODE,D3DCULL_NONE);
  g_pd3dDevice.SetRenderState(D3DRS_LIGHTING,ifalse);

  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);

  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_DIFFUSE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_SELECTARG1);

  fejverts[0].position:=D3DXVector3zero;
  if tech then
    fejverts[0].szin:=techszin
   else
    fejverts[0].szin:=gunszin;
  for i:=1 to 30 do
  begin
   fejverts[i].position:=D3DXVector3(fejvst*sin(i*2*pi/29),fejvst*cos(i*2*pi/29),0);
   if tech then
    fejverts[i].szin:=techszin
   else
    fejverts[i].szin:=gunszin;
  end;

  g_pd3dDevice.SetRenderState(D3DRS_ZENABLE,itrue);
  g_pd3dDevice.SetRenderState(D3DRS_ZWRITEENABLE,itrue);
  g_pd3ddevice.SetFVF(D3DFVF_SZINESVERTEX);
  g_pd3dDevice.SetTexture(0,nil);
  g_pd3ddevice.drawprimitiveUP(D3DPT_TRIANGLEFAN,29,fejverts[0],sizeof(Tszinesvertex));

  g_pd3dDevice.SetTransform(D3DTS_WORLD, matWorld);
  vEyePt:=    D3DXVector3(sin(forg)*1.2,0,cos(forg)*1.2);
  vLookatPt:= D3DXVector3Zero;
  vUpVec:=    D3DXVector3(0,1,0);

  D3DXMatrixLookAtLH(matView, vEyePt, vLookatPt, vUpVec);
  g_pd3dDevice.SetTransform(D3DTS_VIEW, matView);
  g_pd3dDevice.SetRenderState(D3DRS_LIGHTING,itrue);

  init;

  render(mire,identmatr,false,d3dxvector3zero);
  flush;
  Rendertotex.EndScene(0);
 end;
end;


destructor TFejcuccrenderer.Destroy;
begin
 surf:=nil;
 tex:=nil;
 RenderToTex:=nil;
 setlength(data,0);
 setlength(inddata,0);
end;

end.
