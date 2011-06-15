(* Stickman Warfare Source Code              *
 * ----------------------------------------- *
 * All rights reserved                       *
 *                                           *
 * Almost everything in this file and the    *
 * units are written by me, Badics Alex.     *
 * Except: PerlinNoise (i got that from      *
 *                      a forum)             *
 *         D3D units   (www.clootie.ru)      *
 *                                           *)
{$R stickman.RES}
{$DEFINE force16bitindices} //ez hibás, pár helyen, ha nincs kipontozva, meg kell majd nézni
{.$DEFINE undebug}
{.$DEFINE speedhack}
{.$DEFINE repkedomod}
{.$DEFINE godmode}
{.$DEFINE noHUD}
{.$DEFINE palyszerk}
program Stickman;

uses
  AntiFreeze,
  D3DX9,
  Direct3D9,
  DinputE,
  DirectSound,
  Directinput,
  DSUtil,
  eventscripts,
  fegyverek,
  filectrl,
  fizika,
  foliage,
  Math,
  Messages,
  MMSystem,
  muksoka,
  multiplayer,
  myUI,
  newsoundunit,
  ojjektumok,
  ParticleSystem,
  PerlinNoise,
  sky,
  Sysutils,
  SyncObjs,
  Typestuff,
  Windows,
  Winsock2;

const
lvlmin=0;  //ENNEK ÍGY KÉNE MARADNIA
lvlmax=6;
lvlsiz=32;  //Ennek is :(
lvlsizp=lvlsiz+1;
farlvl=4;
fuszam=10;
//fuszin=$0079E433;
fuszin=$00FFFFFF;
koszin=$FFFFFFFE;
lvmi=lvlsiz div 4; //lvlsiz div 4
lvma=lvmi*3-1;


MAXszog=3.141592654/2-0.1;
pow2:array [-10..20] of single=(1/1024,1/512,1/256,1/128,1/64,1/32,1/16,1/8,1/4,1/2,1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576);
pow2i:array [0..15] of word=(1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768);

RB_MAX_IDO=6000;

DETAIL_VIZ=1;
DETAIL_POM=2;
DETAIL_MAX=2;

POSTPROC_DISTORTION=1;
POSTPROC_GREYSCALE=2;
POSTPROC_MOTIONBLUR=3;
POSTPROC_GLOW=4;
POSTPROC_MAX=4;

MP5_NAGYITAS = 3;
//-----------------------------------------------------------------------------
// Global variables
//-----------------------------------------------------------------------------
var


  g_pD3D: IDirect3D9 = nil; // Used to create the D3DDevice
  g_pd3dDevice: IDirect3DDevice9 = nil; // Our rendering device
  g_pVB:IDirect3DVertexBuffer9 = nil; // Buffer to hold vertices
  g_pdynVB:IDirect3DVertexBuffer9 = nil;
  g_pIB:IDirect3DIndexBuffer9 = nil;
  g_pIBlvl2:IDirect3DIndexBuffer9 = nil;
  homtex:IDirect3DTexture9 = nil;
   futex:IDirect3DTexture9 = nil;
  futexa:IDirect3DTexture9 = nil;
   kotex:IDirect3DTexture9 = nil;
  noisetex:IDirect3DTexture9 = nil;
  noise2tex:IDirect3DTexture9 = nil;
  viztex:IDirect3DTexture9 = nil;
  mt1:IDirect3DTexture9 = nil;
  mt2:IDirect3DTexture9 = nil;
  cartex:IDirect3DTexture9 = nil;
  antigravtex:IDirect3DTexture9 = nil;
  kerektex:IDirect3DTexture9 = nil;
  g_pautomesh:ID3DXMesh=nil;
  g_pantigravmesh:ID3DXMesh=nil;
  g_pkerekmesh:ID3DXMesh=nil;
  singtc,cosgtc,plsgtc:single; //hullámzás
  skytex:IDirect3DTexture9 = nil;
  skystrips: array [0..20] of array [0..31] of TSkyVertex;

  Testmesh:ID3DXMesh = nil;  //Test, mint TESZT (kis gömb a becsapódásnál)
  bokrok,fuvek:Tfoliage; //Növényzet
  ojjektumrenderer:T3DORenderer;
  fegyv:Tfegyv = nil;
  test:array [0..9] of single;
  VBwhere:integer;
  levels:array [lvlmin..lvlmax] of Tlvl;
  lvlind:array [lvlmin..farlvl,0..2,0..lvlsizp*lvlsizp*6] of Dword;
  lvlindszam:array [lvlmin..farlvl,0..2] of integer;
  lvlupd:array [lvlmin..lvlmax] of boolean;
  splatinds:array [0..2] of integer;
  alapind:array [0..lvlsizp*lvlsizp*6] of Dword;
  menu:T3dMenu = nil;

  matView, matProj: TD3DMatrix;
  cpy:Psingle; ///FRÖCCCS
  DIne:TdinputEasy = nil;
  noobtoltpos:TD3DXVector3;
  
  gazmsg:string;
  epulethezert:integer;
  
  botszam:integer;

  cpx:Psingle;  ///FRÖCCCS

  cmx,cmz:integer;
  szogx,szogy,mszogx,mszogy:single;
  ccpx,ccpy,ccpz,cocpx,cocpy,cocpz:single;
  ysb:single;
  volttim,kuldd,hanyszor:cardinal;
  eltim:single;
  framespersecond:single=1;
  cpz:Psingle;  ///FRÖCCCS
  hWindow: HWND;
  cpox:Psingle; ///FRÖCCCS
  toind,allind:integer;
  muks:Tmuksoka;
  rongybabak:array [0..50] of Trongybaba;
  halalhorg:integer;
  cpoy:Psingle; ///FRÖCCCS
  rbido:integer;
  rbszam:integer=-1;
  cpoz:Psingle; ///FRÖCCCS
  rbm:integer=0;
  mat_world,mfm:TD3DMatrix;
  mousesens:single;
  mouseacc:boolean;
  oopos:TD3DXVector3;
  wentthroughwall:boolean;
  posokvoltak:array [0..4] of TD3DXVector3;  //Ne MERD az MMO-n kíbvül használni mert megbaszlak!
  lastzone:string;
  zonaellen:integer;
  zonechanged:integer;

  errorospointer:PDWORD;
  ahovaajopointermutat:DWORD;
  anticheat1,anticheat2:integer;
  guardpage:pointer;


  mstat:byte;
  myfegyv:byte;
  csipo,rblv,gugg,spc,iranyithato,objir:boolean;
  lovok:single;
  cooldown:single;

  halal,playrocks,vizben:single;

  packszam:integer;
  hvolt:boolean;
  gobacktomenu:boolean;
  lostdevice:boolean;
  iswindowed:boolean;
  epuletmost:integer;
  chatmost:string;
  kitlottemle:string;
  latszonaKL:integer;
  suicidevolt:integer;
  
  HDRarr:array [0..7,0..7] of integer;
  HDRscanline:byte;
  HDRincit:single=8000;
  FelesHDRopt:boolean;
  FelesHDR:boolean;
  fegylit:integer;

  canbeadmin:boolean;
  invulntim:integer;
  nemlohet:boolean;

  mapbol:boolean;
  mapmode:single;
  kulsonezet:boolean=false;
  autoban:boolean=false;
  bunkerkozelben:boolean;
  melyikbunkerkozelben:integer;
  recovercar,vanishcar,kiszallas:integer;
  latszonazF,latszonazR:byte;
  volthi,voltspeeder,voltbasejump:boolean;


  tegla:Tauto;
  tobbiekautoi:array of Tauto;
  flipcount,voltflip:integer;
  flipbol:boolean;
  
  rays:array [0..7] of TD3DXVector3;

  felho:Tfelho;
  suntex:IDirect3DTexture9;
  villam:word;
  villambol:byte;
  fogc,fogstart,fogend:single;

  noobproj,lawproj,x72proj:array of Tnamedprojectile;
  lawmesh,noobmesh:ID3DXMesh;
  rezg:single;
  LAWkesleltetes:integer=-1;
  mp5ptl:single;
  x72gyrs:single;

  effecttexture,reflecttexture:IDirect3DTexture9;
  waterbumpmap: IDirect3DTexture9;
  enableeffects:boolean;
  opt_detail, opt_postproc:integer;
  opt_rain:boolean;
  explosionbubbles:array of TDBubble;
  explosionripples:array of TDRipple;
  g_pEffect:ID3DXEffect;

  fejcuccrenderer:TFejcuccrenderer;
  myfejcucc:integer;

  mfkmat:TD3DMatrix;

  frust:Tfrustum;

  teleports:array of TTeleport;
  
  opt_taunts:boolean;

  printscreensurf:IDirect3DSurface9;

  armcount:byte;
  robhely:TD3DXVector3;

  currevent:TStickmanevent;
  zeneintensity:integer;
//  re_gk:TD3DXVector3;
//  re_pos:TD3DXVector3;
//////////////////////////////////////////////////////////////////////////////////////////////////



function collerp(c1,c2:cardinal):cardinal;
var
c3:cardinal;
begin

 c3:=(((c1 and $000000FF)+(c2 and $000000FF)) div 2) and $000000FF;
 c3:=c3+(((c1 and $0000FF00)+(c2 and $0000FF00)) div 2) and $0000FF00;
 c3:=c3+(((c1 and $00FF0000)+(c2 and $00FF0000)) div 2) and $00FF0000;
 c3:=c3+((c1 and $FF000000) div 2+(c2 and $FF000000) div 2) and $FF000000;
 result:=c3;
end;

function VertInterpolate(av1,av2:Tcustomvertex):Tcustomvertex;
begin
with result do
begin
 d3dxvec3lerp(position,av1.position,av2.position,0.5);
 d3dxvec3lerp(normal,av1.normal,av2.normal,0.5);
 if (av1.color=fuszin) or (av2.color=fuszin) then
  color:=fuszin
 else
  color:=collerp(av1.color,av2.color);
 u:=(av1.u+av2.u)/2;
 v:=(av1.v+av2.v)/2;
 u2:=(av1.u2+av2.u2)/2;
 v2:=(av1.v2+av2.v2)/2;

end;
end;


function TRY3D(hwVP:boolean;hWnd: HWND):boolean;
var
 d3dpp: TD3DPresentParameters;
 hiba:HRESULT;
 aVP:cardinal;
begin
  if hwVP then aVP:=D3DCREATE_HARDWARE_VERTEXPROCESSING else
               aVP:=D3DCREATE_SOFTWARE_VERTEXPROCESSING;
  FillChar(d3dpp, SizeOf(d3dpp), 0);
  d3dpp.Windowed := true;

  d3dpp.BackBufferFormat := D3DFMT_UNKNOWN;
  d3dpp.BackBufferWidth:=SCwidth;
  d3dpp.BackBufferHeight:=SCheight;
  d3dpp.SwapEffect := D3DSWAPEFFECT_COPY;
  d3dpp.EnableAutoDepthStencil := True;
  d3dpp.PresentationInterval:= D3DPRESENT_INTERVAL_IMMEDIATE;

  if  not iswindowed then
  begin
   d3dpp.Windowed := false;
   d3dpp.SwapEffect := D3DSWAPEFFECT_FLIP;
   d3dpp.BackBufferFormat := D3DFMT_X8R8G8B8;
  end;

  d3dpp.AutoDepthStencilFormat := D3DFMT_D32 ;


  // Create the D3DDevice

  hiba:= g_pD3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, hWnd,
                               AVP,
                               @d3dpp, g_pd3dDevice);
  result:=not FAILED(hiba);
  if result then exit;
  d3dpp.AutoDepthStencilFormat := D3DFMT_D24X8 ;
  hiba:= g_pD3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, hWnd,
                               AVP,
                               @d3dpp, g_pd3dDevice);
  result:=not FAILED(hiba);
  if result then exit;
  d3dpp.AutoDepthStencilFormat := D3DFMT_D16 ;
  hiba:= g_pD3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, hWnd,
                               AVP,
                               @d3dpp, g_pd3dDevice);
  result:=not FAILED(hiba);
end;
//-----------------------------------------------------------------------------
// Name: InitD3D()
// Desc: Initializes Direct3D
//-----------------------------------------------------------------------------
function InitD3D(hWnd: HWND): HRESULT;
var
caps:TD3DCaps9;
begin
  Result:= E_FAIL;

  // Create the D3D object.
  g_pD3D := Direct3DCreate9(D3D_SDK_VERSION);
  if (g_pD3D = nil) then
  begin
   messagebox(hWindow,'D3DCreate error.',Pchar(lang[30]),MB_SETFOREGROUND);
   Exit;
  end;

  // Set up the structure used to create the D3DDevice. Since we are now
  // using more complex geometry, we will create a device with a zbuffer.
  if not TRY3d(true,hwnd) then
   if not TRY3D(false,hwnd) then
   begin
    messagebox(hWindow,'No available D3D9 devices.',Pchar(lang[30]),0);
    exit;
   end;

  // Turn on culling
  g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);

  //Developer stuff

 // g_pd3dDevice.SetRenderState(D3DRS_FILLMODE, D3DFILL_WIREFRAME);
  // Turn on the zbuffer
  g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iTrue);
  showcursor(false);

  g_pd3ddevice.GetDeviceCaps(caps);

  write(logfile,'Max indices:',inttohex(caps.MaxVertexIndex,0),'...');
  maxindices:=caps.MaxVertexIndex+1;
  if (caps.PixelShaderVersion<D3DPS_VERSION(2,0)) or (maxindices<=(high(word)+50))
     or commandlineoption('16bit') {$IFDEF force16bitindices} or true {$ENDIF} then
  begin
   use32bitIndices:=false;
   writeln(logfile,'Using 16 bit indices');
  end
  else
  begin
   use32bitIndices:=true;
   writeln(logfile,'Using 32 bit indices');
  end;

  Result:= S_OK;
end;

procedure csinaljfaszapointereket;
var
i:integer;
arr:array[1..6] of byte;
tmp,rnd1,rnd2:byte;
tcpx,tcpy,tcpz,tcpox,tcpoy,tcpoz:single;
begin
 for i:=1 to 6 do arr[i]:=i;
 for i:=1 to 20 do begin
  rnd1:=random(6)+1;rnd2:=random(6)+1;
  tmp:=arr[rnd1];arr[rnd1]:=arr[rnd2];arr[rnd2]:=tmp;
 end;
 tcpx :=0;tcpy :=0;tcpz :=0;
 tcpox:=0;tcpoy:=0;tcpoz:=0;
 if cpx<>nil then
 begin
  tcpx :=cpx^ ;tcpy :=cpy^ ;tcpz :=cpz^;
  tcpox:=cpox^;tcpoy:=cpoy^;tcpoz:=cpoz^;
  freemem(cpx );freemem(cpy );freemem(cpz );
  freemem(cpox);freemem(cpoy);freemem(cpoz);
 end;

 for i:=1 to 6 do
  case arr[i] of
   1:getmem(cpx,4);
   2:getmem(cpy,4);
   3:getmem(cpz,4);
   4:getmem(cpox,4);
   5:getmem(cpoy,4);
   6:getmem(cpoz,4);
  end;

  cpx^ :=tcpx ;cpy^ :=tcpy ;cpz^ :=tcpz ;
  cpox^:=tcpox;cpoy^:=tcpoy;cpoz^:=tcpoz;
end;

function tavPointPoint(Point1,point2:TD3DXvector3):single;
var
Vec:TD3DXVector3;
begin

    Vec.X := Point2.X - Point1.X;
    Vec.Y := Point2.Y - Point1.Y;
    Vec.Z := Point2.Z - Point1.Z;

    result:=sqrt( Vec.X * Vec.X + Vec.Y * Vec.Y + Vec.Z * Vec.Z );
end;

function tavPointLine(point,linestart,lineend:TD3DXVector3;out Intersection:TD3DXVector3; out Distance:single ):boolean;
var
LineMag,U:single;
begin

    LineMag := tavPointPoint( LineEnd, LineStart );
    if linemag<0.0001 then
    begin
     result:=false;
     exit;
    end;
    U := ( ( ( Point.X - LineStart.X ) * ( LineEnd.X - LineStart.X ) ) +
        ( ( Point.Y - LineStart.Y ) * ( LineEnd.Y - LineStart.Y ) ) +
        ( ( Point.Z - LineStart.Z ) * ( LineEnd.Z - LineStart.Z ) ) ) /
        ( LineMag * LineMag );

    if( (U < 0.0) or (U > 1.0) ) then
    begin
     result:=false;   // closest point does not fall within the line segment
     exit;
    end;
    Intersection.X := LineStart.X + U * ( LineEnd.X - LineStart.X );
    Intersection.Y := LineStart.Y + U * ( LineEnd.Y - LineStart.Y );
    Intersection.Z := LineStart.Z + U * ( LineEnd.Z - LineStart.Z );

    Distance := tavPointPoint( Point, Intersection );

    result:=true;
end;


function tavLineLine(p1,p2,p3,p4:TD3DXVector3;out pa,pb:TD3DXVector3;out Distance:single):boolean;
const
EPS=0.00001;
var
p13,p43,p21:TD3DXVector3;
d1343,d4321,d1321,d4343,d2121:single;
numer,denom:single;
mua,mub:single;
begin
   d3dxvec3subtract(p13,p1,p3);
   d3dxvec3subtract(p43,p4,p3);
   if ((ABS(p43.x)  < EPS) and (ABS(p43.y)  < EPS) and (ABS(p43.z)  < EPS)) then
    begin
     result:=false;
     exit;
    end;
   d3dxvec3subtract(p21,p2,p1);
   if ((ABS(p21.x)  < EPS) and (ABS(p21.y)  < EPS) and (ABS(p21.z)  < EPS)) then
    begin
     result:=false;
     exit;
    end;
   d1343 := p13.x * p43.x + p13.y * p43.y + p13.z * p43.z;
   d4321 := p43.x * p21.x + p43.y * p21.y + p43.z * p21.z;
   d1321 := p13.x * p21.x + p13.y * p21.y + p13.z * p21.z;
   d4343 := p43.x * p43.x + p43.y * p43.y + p43.z * p43.z;
   d2121 := p21.x * p21.x + p21.y * p21.y + p21.z * p21.z;

   denom := d2121 * d4343 - d4321 * d4321;
   if (ABS(denom) < EPS) then
    begin
     result:=false;
     exit;
    end;
   numer := d1343 * d4321 - d1321 * d4343;

   if (ABS(d4343) < EPS) then
    begin
     result:=false;
     exit;
    end;
   mua := numer / denom;
   mub := (d1343 + d4321 * (mua)) / d4343;
   if (mua<0) or (mua>1) or (mub<0) or (mub>1) then
   begin
    result:=false;
    exit;
   end;
   pa.x := p1.x + mua * p21.x;
   pa.y := p1.y + mua * p21.y;
   pa.z := p1.z + mua * p21.z;
   pb.x := p3.x + mub * p43.x;
   pb.y := p3.y + mub * p43.y;
   pb.z := p3.z + mub * p43.z;
   distance:=Tavpointpoint(pa,pb);
   result:=true;
end;
(* Régi
var
p21,p43,p31,crs:TD3DXVector3;
crsdst:single;
begin

d3dxvec3subtract(p31,p3,p1);
d3dxvec3subtract(p43,p4,p3);
d3dxvec3subtract(p21,p2,p1);
d3dxvec3cross(crs,p21,p43);
crsdst:=d3dxvec3length(crs);
distance:=abs(d3dxvec3dot(p31,crs)/(crsdst));
result:=true;
end;
*)


function rou(mit:single):integer;
begin
 result:=round(mit*100);
end;

function meglove(gmbk:Tgmbk;kapcsk:Tkapcsk;lin,ir:Td3DVector;fegyvvst:single):integer;
var
i,j:integer;
dst:single;
tmp,tmp2:TD3DXvector3;
 transgmbk:TGmbk;
begin

 D3DXVec3TransformCoordArray(@transgmbk[0],sizeof(gmbk[0]),@gmbk[0],sizeof(gmbk[0]),mat_World,11);
 dst:=10000;
 for i:=0 to 9 do
  if tavpointline(transgmbk[i],lin,ir,tmp,dst) then
   if dst<(vst+fegyvvst) then
   begin
    result:=i;
    exit;
   end;

 if tavpointline(transgmbk[10],lin,ir,tmp,dst) then
   if dst<(fejvst+fegyvvst) then
   begin
    result:=10;
    exit;
   end;

 for j:=0 to 9 do
 begin
  test[j]:=j/2;
  dst:=1000;
  if tavlineline(transgmbk[kapcsk[j,0]],transgmbk[kapcsk[j,1]],lin,ir,tmp,tmp2,dst) then
   if dst<(vst+fegyvvst) then
   begin
    result:=1;
    exit;
   end;
 end;
 result:=-1;
end;


{$IFNDEF palyszerk}

 {if not kelltav then begin tav:=hol.y; exit; end;
 tav2:=sqrt(tav2);//sqrt(tav2); //Optimizálni kéne.
 if tav2<rad2 then
  tav:=0
 else
 if tav2<(rad2+tav)*0.5 then
  tav:=sqr((tav2-rad2)/(tav-rad2))*2
 else
  tav:=1-sqr((tav-tav2)/(tav-rad2))*2;
        }
function vanottvalami(xx:single;var yy:single;zz:single):boolean;
const
szor=2;
var
i:integer;
tav:single;
begin
 result:=false;

 for i:=0 to high(posrads) do
 with posrads[i] do
 begin

  tav:=sqr(posx-xx)+sqr(posz-zz);
  if tav>sqr(raddn) then continue;

  if tav<sqr(radd) then
   tav:=0
  else
  begin
   tav:=sqrt(tav);
   if tav<(radd+raddn)*0.5 then
    tav:=sqr((tav-radd)/(raddn-radd))*2
   else
    tav:=1-sqr((raddn-tav)/(raddn-radd))*2;
  end;
  yy:=posy*(1-tav)+yy*tav;
  result:=true;
 end;
end;

{$ELSE}
function vanottvalami(xx:single;var yy:single;zz:single):boolean;
var
i,j:integer;
tav:single;
begin
 result:=false;
 for j:=0 to high(ojjektumnevek) do
 begin
 // if ojjektumarr[j]<>nil then
  for i:=0 to ojjektumarr[j].hvszam-1 do
  begin
   tav:=ojjektumarr[j].rad*1.5;
   if ojjektumarr[j].van(xx,zz,i,tav,true) then
   begin
     yy:=ojjektumarr[j].holvannak[i].y*(1-tav)+yy*tav;
     result:=true;
  end;
  end;
 end;
end;
{$ENDIF}

function safevanottvalami(xx:single;var yy:single;zz:single):boolean;
var
i,j:integer;
tav:single;
begin
 result:=false;
 for j:=0 to high(ojjektumnevek) do
 begin
  if ojjektumarr[j]<>nil then
  for i:=0 to ojjektumarr[j].hvszam-1 do
  begin
   tav:=ojjektumarr[j].rad*1.5;
   if ojjektumarr[j].van(xx,zz,i,tav,true) then
   begin
     //if yy<bunker.holvannak[i].y then
     //tav:=tav/30;
     yy:=ojjektumarr[j].holvannak[i].y*(1-tav)+yy*tav;
     result:=true;
    // exit;
  end;
  end;
 end;
end;

function vanottvalami2(xx:single;var yy:single;zz,scalfac:single):boolean;
var
i:integer;
tav:single;
begin
 result:=false;
 for i:=0 to ojjektumarr[0].hvszam-1 do
 begin
  tav:=scalfac;
  if ojjektumarr[0].van(xx,zz,i,tav,false) then
   begin
   yy:=tav;
   result:=true; exit; end;
 end;
end;

function advwove(xx,zz:single):single;
var
ay:single;
begin
 if (xx<-10000) or (xx>10000) or (zz<-10000) or (zz>10000) then
 begin
  result:=0;
  exit;
 end;
 ay:=wove(xx,zz);
 vanottvalami(xx,ay,zz);
 result:=ay;
end;

function safeadvwove(xx,zz:single):single;
var
ay:single;
begin
 if (xx<-10000) or (xx>10000) or (zz<-10000) or (zz>10000) then
 begin
  result:=0;
  exit;
 end;
 ay:=wove(xx,zz);
 safevanottvalami(xx,ay,zz);
 result:=ay;
end;


procedure yandnorm(var xx,yy,zz:single;var norm:Td3dvector;scalfac:single);
var
lngt:single;
v24y,v13y:single;
begin
 xx:=xx*scalfac;
 zz:=zz*scalfac;
 yy:=advwove(xx,zz);
 noNANInf(xx);noNANInf(yy);noNANInf(zz);
 if scalfac>10 then
  vanottvalami2(xx,yy,zz,scalfac);

 v24y:=advwove(xx,zz-(scalfac))- advwove(xx,zz+(scalfac));
 //v1-v3
 v13y:=advwove(xx-(scalfac),zz)-advwove(xx+(scalfac),zz);
 //Döbbenetes az egyszerûsítés
 norm.x:=v13y;
 norm.y:=2*scalfac;
 norm.z:=v24y;
 lngt:=d3dxvec3lengthsq(norm);
 if lngt<0.00001 then lngt:=1;
 d3dxvec3scale(norm,norm,fastinvsqrt(lngt));
end;

function palyvert(xx,yy,zz,scalfac:single;lvl:integer):TCustomVertex;
var
norm:Td3dVector;
szin:COLORREF;
i,j:integer;
ux,uz,u2x,u2z:single;
begin
 yandnorm(xx,yy,zz,norm,scalfac);
 //zz:=zz+(round(xx)mod 2)*scalfac/2;
 {szin:=RGB(round((1+perlin.noise(xx+1000,yy,zz))*100)+100,
           round((1+perlin.noise(xx,yy+1000,zz))*50)+180,
           round((1+perlin.noise(xx,yy,zz+1000))*100)+100);   }
 szin:=fuszin;
 if (norm.y)<0.83 then szin:=koszin;
 if yy<15 then szin:=RGB(200,200,250)+$FF000000;

 if yy<0 then yy:=0;
 if yy<10 then szin:=RGB(250-round(yy*4),100+round(yy*8),round(yy*20))+$FF000000;

 if  scalfac<pow2[farlvl] then
 for j:=0 to high(ojjektumnevek) do
  for i:=0 to ojjektumarr[j].hvszam-1 do
  if ojjektumarr[j].raytestbol(D3DXVector3(xx,yy,zz),D3DXVector3(xx-ojjektumarr[j].rad*2,yy+ojjektumarr[j].rad*2,zz),i) then
  begin
   norm:=D3DXVector3(sqrt(2),sqrt(2),0);
   break;
  end;


 ux:=xx/1+sin(zz/2)/2{+sin(zz/8){+perlin.complexnoise(1,xx+2000,zz,16,4,0.5)*3{+perlin.noise(xx/200,0.5,zz/200+100)*50};
 uz:=zz/1-cos(xx/2)/2{+cos(xx/8){+perlin.complexnoise(1,xx,zz+2000,16,4,0.5)*3{+perlin.noise(xx/200+100,0.5,zz/200)*50};

 u2x:=xx/16;
 u2z:=zz/16;
 if scalfac>=pow2[farlvl] then
 begin
  ux:=xx/2048+0.5;
  uz:=zz/2048+0.5;
  szin:=$FFFFFF;
 end;
 
 result:=CustomVertex(xx,yy,zz,norm.x,norm.y,norm.z,szin,ux,uz,u2x,u2z);
end;

procedure remakelvl(lvl:integer);
var
  x,y:integer;
  scalfac:single;
  xx,yy,zz:single;
begin
  scalfac:=pow2[lvl];
  for x:=0 to lvlsiz do
   for y:=0 to lvlsiz do
   begin
     xx:=x-lvlsiz div 2;
     zz:=y-lvlsiz div 2;
     yy:=0;
     xx:=xx+(cmx div pow2i[lvl-lvlmin]){+(y mod 2)/2};
     zz:=zz+(cmz div pow2i[lvl-lvlmin]);
      levels[lvl,x*lvlsizp+y]:=palyvert(xx,yy,zz,scalfac,lvl);
   end;
  lvlupd[lvl]:=true;
end;

procedure updatelvl(lvl:integer);

 procedure atmasol(var a:TCustomvertex;b:TCustomvertex;csakpost:boolean);
 begin
  a.position:=b.position;
  if csakpost then exit;
  a:=b;
 end;

var
  i:integer;
  x,y:integer;
  scalfac:single;
  xx,yy,zz:single;
  pvertices:PCustomvertexarray;
  lvlcucc,szam:cardinal;

begin

  if (lvl<lvlmax) then
  for i:=0 to lvlsiz div 2 do
  begin
   y:=i*2;
   x:=0;

   atmasol(levels[lvl,x*lvlsizp+y],levels[lvl+1,lvmi*lvlsizp+i+lvmi],(lvl=farlvl-1));
   //levels[lvl,x*lvlsizp+y]:=levels[lvl+1,lvmi*lvlsizp+i+lvmi];
    //uvdiv(levels[lvl,x*lvlsizp+y]);
   x:=lvlsiz;

   atmasol(levels[lvl,x*lvlsizp+y],levels[lvl+1,(lvma+1)*lvlsizp+i+lvmi],(lvl=farlvl-1));
   //levels[lvl,x*lvlsizp+y]:=levels[lvl+1,lvma*lvlsizp+i+lvmi];
   x:=i*2;
   y:=0;

   atmasol(levels[lvl,x*lvlsizp+y],levels[lvl+1,(lvmi+i)*lvlsizp+lvmi],(lvl=farlvl-1));
  // levels[lvl,x*lvlsizp+y]:=levels[lvl+1,(lvmi+i)*lvlsizp+lvmi];
   y:=lvlsiz;

   atmasol(levels[lvl,x*lvlsizp+y],levels[lvl+1,(lvmi+i)*lvlsizp+lvma+1],(lvl=farlvl-1));
  // levels[lvl,x*lvlsizp+y]:=levels[lvl+1,(lvmi+i)*lvlsizp+lvma];
  end;
  for i:=0 to (lvlsiz div 2)-1 do
  begin
   y:=i*2+1;
   x:=0;
   levels[lvl,x*lvlsizp+y]:=VertInterpolate(levels[lvl,x*lvlsizp+(y-1)],levels[lvl,x*lvlsizp+(y+1)]);
   //if lvl=farlvl-1 then uvdiv(levels[lvl,x*lvlsizp+y]);
   x:=lvlsiz;
   levels[lvl,x*lvlsizp+y]:=VertInterpolate(levels[lvl,x*lvlsizp+(y-1)],levels[lvl,x*lvlsizp+(y+1)]);
   //if lvl=farlvl-1 then uvdiv(levels[lvl,x*lvlsizp+y]);
   x:=i*2+1;
   y:=0;
   levels[lvl,x*lvlsizp+y]:=VertInterpolate(levels[lvl,(x-1)*lvlsizp+y],levels[lvl,(x+1)*lvlsizp+y]);
   //if lvl=farlvl-1 then uvdiv(levels[lvl,x*lvlsizp+y]);
   y:=lvlsiz;
   levels[lvl,x*lvlsizp+y]:=VertInterpolate(levels[lvl,(x-1)*lvlsizp+y],levels[lvl,(x+1)*lvlsizp+y]);
   //if lvl=farlvl-1 then uvdiv(levels[lvl,x*lvlsizp+y]);
  end;

  if lvl<=farlvl then
  begin
   lvlcucc:=lvlsizp*lvlsizp*(lvl-lvlmin);
   lvlindszam[lvl,0]:=0;
   lvlindszam[lvl,1]:=0;
   lvlindszam[lvl,2]:=0;
   if lvl=lvlmin then szam:=0 else szam:=toind;
   for i:=(szam div 3) to (allind div 3)-1  do
   begin
    if (levels[lvl,alapind[i*3+0]].color=fuszin) or
       (levels[lvl,alapind[i*3+1]].color=fuszin) or
       (levels[lvl,alapind[i*3+2]].color=fuszin) then
       begin  //füves a cucc
        lvlind[lvl,0,lvlindszam[lvl,0]+0]:=alapind[i*3+0]+lvlcucc;
        lvlind[lvl,0,lvlindszam[lvl,0]+1]:=alapind[i*3+1]+lvlcucc;
        lvlind[lvl,0,lvlindszam[lvl,0]+2]:=alapind[i*3+2]+lvlcucc;
        inc(lvlindszam[lvl,0],3);
       end;
    //else
    if (levels[lvl,alapind[i*3+0]].color=koszin) or
       (levels[lvl,alapind[i*3+1]].color=koszin) or
       (levels[lvl,alapind[i*3+2]].color=koszin) then
       begin  //vagy köves
        lvlind[lvl,1,lvlindszam[lvl,1]+0]:=alapind[i*3+0]+lvlcucc;
        lvlind[lvl,1,lvlindszam[lvl,1]+1]:=alapind[i*3+1]+lvlcucc;
        lvlind[lvl,1,lvlindszam[lvl,1]+2]:=alapind[i*3+2]+lvlcucc;
        inc(lvlindszam[lvl,1],3);
       end
    else
    if (levels[lvl,alapind[i*3+0]].color<>fuszin) or
       (levels[lvl,alapind[i*3+1]].color<>fuszin) or
       (levels[lvl,alapind[i*3+2]].color<>fuszin) then
       begin //vagy egyéb (homok, víz)
        lvlind[lvl,2,lvlindszam[lvl,2]+0]:=alapind[i*3+0]+lvlcucc;
        lvlind[lvl,2,lvlindszam[lvl,2]+1]:=alapind[i*3+1]+lvlcucc;
        lvlind[lvl,2,lvlindszam[lvl,2]+2]:=alapind[i*3+2]+lvlcucc;
        inc(lvlindszam[lvl,2],3);
       end;
   end;

  end;

  if FAILED(g_pVB.Lock(lvlsizp*lvlsizp*(lvl-lvlmin)*sizeof(Tcustomvertex), lvlsizp*lvlsizp*sizeof(Tcustomvertex), Pointer(pVertices), D3DLOCK_NOOVERWRITE))
  then Exit;
  {$R-}
  copymemory(pointer(pVertices),pointer(addr(levels[lvl,0])),lvlsizp*lvlsizp*sizeof(Tcustomvertex));
 // zeromemory(pointer(pVertices),lvlsizp*lvlsizp*sizeof(Tcustomvertex));
  g_pVB.Unlock;
  if lvl=4 then bokrok.update(@(levels[lvl,0]),advwove);
  if lvl=1 then fuvek.update(@(levels[lvl,0]),advwove);
 // if lvl=0 then fuvek2.update(@(levels[lvl]),advwove);
end;

procedure remakeindexbuffer;
var
pIndices:Pointer;
i,j,k,hol2:integer;
hol:Pword;
begin

 laststate:='Remakeindexbuffer 1';
  if FAILED(g_pIB.Lock(0, 0, pIndices, D3DLOCK_DISCARD))
  then Exit;
  {.$R+}
  hol:=pIndices;
  hol2:=0;

  for i:=0 to 2 do
  begin
   for j:=lvlmin to farlvl-1 do
   begin
    for k:=0 to lvlindszam[j,i]-1 do
    begin
     hol^:=(lvlind[j,i,k]);
     inc(hol);
     if use32bitindices then
      inc(hol);
     inc(hol2);
    end;
   end;
   splatinds[i]:=hol2;
  end;
  g_pIB.unlock;
  {$R-}
end;

procedure updateterrain;
var
volt:boolean;
i:integer;
begin    
 volt:=false;
 for i:=lvlmax downto lvlmin do
  if lvlupd[i] then
  begin
   updatelvl(i);
   volt:=true;
  end;
 if volt then remakeindexbuffer;
end;

procedure remaketerrain;
var
i:integer;
begin
 for i:=lvlmax downto lvlmin do
  remakelvl(i);
 updateterrain;
end;

procedure stepb;
var
i:integer;
x,y:integer;
now,now2:integer;
dorecalc:array [lvlmin..lvlmax] of boolean;

  scalfac:single;
  xx,yy,zz:single;
begin
 now:=cmz;
 now2:=cmz-1;
 for i:=lvlmin to lvlmax do
 begin
  dorecalc[i]:=now mod 2<>now2 mod 2;
  now:=now div 2; now2:=now2 div 2;
 end;
 dec(cmz);
 for i:=lvlmax downto lvlmin do
 if dorecalc[i] then
 begin
  scalfac:=pow2[i];


  for x:=0 to lvlsiz do
  begin
      y:=0;
      xx:=x-lvlsiz div 2;
      zz:=y-lvlsiz div 2;
      yy:=0;
      xx:=xx+(cmx div pow2i[i-lvlmin]);
      zz:=zz+(cmz div pow2i[i-lvlmin])+1;
      levels[i,x*lvlsizp+y]:=palyvert(xx,yy,zz,scalfac,i);
   end;

  for x:=0 to lvlsiz do
   for y:=lvlsiz downto 1 do
    levels[i,x*lvlsizp+y]:=levels[i,x*lvlsizp+y-1];

  if i=farlvl-1 then
  for x:=0 to lvlsiz do
  begin
      y:=0;
      xx:=x-lvlsiz div 2;
      zz:=y-lvlsiz div 2;
      yy:=0;
      xx:=xx+(cmx div pow2i[i-lvlmin]);
      zz:=zz+(cmz div pow2i[i-lvlmin])+0;
      levels[i,x*lvlsizp+y]:=palyvert(xx,yy,zz,scalfac,i);
   end;

  lvlupd[i]:=true;
 end;
end;


procedure stepf;
var
i:integer;
x,y:integer;
now,now2:integer;
dorecalc:array [lvlmin..lvlmax] of boolean;

  scalfac:single;
  xx,yy,zz:single;
begin
 now:=cmz;
 now2:=cmz+1;
 for i:=lvlmin to lvlmax do
 begin
  dorecalc[i]:=now mod 2<>now2 mod 2;
  now:=now div 2; now2:=now2 div 2;
 end;
 inc(cmz);
 for i:=lvlmax downto lvlmin do
 if dorecalc[i] then
 begin
  scalfac:=pow2[i];

  for x:=0 to lvlsiz do
  begin
      y:=lvlsiz;
      xx:=x-lvlsiz div 2;
      zz:=y-lvlsiz div 2;
      yy:=0;
      xx:=xx+(cmx div pow2i[i-lvlmin]);
      zz:=zz+(cmz div pow2i[i-lvlmin])-1;
      levels[i,x*lvlsizp+y]:=palyvert(xx,yy,zz,scalfac,i);
   end;

  for x:=0 to lvlsiz do
   for y:=0 to lvlsiz-1 do
     levels[i,x*lvlsizp+y]:=levels[i,x*lvlsizp+y+1];
  if i=farlvl-1 then
  for x:=0 to lvlsiz do
  begin
      y:=lvlsiz;
      xx:=x-lvlsiz div 2;
      zz:=y-lvlsiz div 2;
      yy:=0;
      xx:=xx+(cmx div pow2i[i-lvlmin]);
      zz:=zz+(cmz div pow2i[i-lvlmin])-0;
      levels[i,x*lvlsizp+y]:=palyvert(xx,yy,zz,scalfac,i);
   end;
  lvlupd[i]:=true;
 end;

end;


procedure stepr;
var
i:integer;
x,y:integer;
now,now2:integer;
dorecalc:array [lvlmin..lvlmax] of boolean;

  scalfac:single;
  xx,yy,zz:single;
begin
 now:=cmx;
 now2:=cmx+1;
 for i:=lvlmin to lvlmax do
 begin
  dorecalc[i]:=now mod 2<>now2 mod 2;
  now:=now div 2; now2:=now2 div 2;
 end;
 inc(cmx);
 for i:=lvlmax downto lvlmin do          
 if dorecalc[i] then
 begin
  scalfac:=pow2[i];

  for y:=0 to lvlsiz do
  begin
      x:=lvlsiz;
      xx:=x-lvlsiz div 2;
      zz:=y-lvlsiz div 2;
      yy:=0;
      xx:=xx+(cmx div pow2i[i-lvlmin])-1;
      zz:=zz+(cmz div pow2i[i-lvlmin]);

      levels[i,x*lvlsizp+y]:=palyvert(xx,yy,zz,scalfac,i);
   end;

  for x:=0 to lvlsiz-1 do
   for y:=0 to lvlsiz do
     levels[i,x*lvlsizp+y]:=levels[i,(x+1)*lvlsizp+y];

  if i=farlvl-1 then
  for y:=0 to lvlsiz do
  begin
      x:=lvlsiz;
      xx:=x-lvlsiz div 2;
      zz:=y-lvlsiz div 2;
      yy:=0;
      xx:=xx+(cmx div pow2i[i-lvlmin])-0;
      zz:=zz+(cmz div pow2i[i-lvlmin]);

      levels[i,x*lvlsizp+y]:=palyvert(xx,yy,zz,scalfac,i);
   end;

  lvlupd[i]:=true;
 end;

end;

procedure stepl;
var
i:integer;
x,y:integer;
now,now2:integer;
dorecalc:array [lvlmin..lvlmax] of boolean;

  scalfac:single;
  xx,yy,zz:single;
begin
 now:=cmx;
 now2:=cmx-1;
 for i:=lvlmin to lvlmax do
 begin
  dorecalc[i]:=now mod 2<>now2 mod 2;
  now:=now div 2; now2:=now2 div 2;
 end;
 dec(cmx);
 for i:=lvlmax downto lvlmin do          
 if dorecalc[i] then
 begin
  scalfac:=pow2[i];

  for y:=0 to lvlsiz do
  begin
      x:=0;
      xx:=x-lvlsiz div 2;
      zz:=y-lvlsiz div 2;
      yy:=0;
      xx:=xx+(cmx div pow2i[i-lvlmin])+1;
      zz:=zz+(cmz div pow2i[i-lvlmin]);

      levels[i,x*lvlsizp+y]:=palyvert(xx,yy,zz,scalfac,i);
   end;

  for x:=lvlsiz downto 1 do
   for y:=0 to lvlsiz do
     levels[i,x*lvlsizp+y]:=levels[i,(x-1)*lvlsizp+y];
     
  if i=farlvl-1 then
  for y:=0 to lvlsiz do
  begin
      x:=0;
      xx:=x-lvlsiz div 2;
      zz:=y-lvlsiz div 2;
      yy:=0;
      xx:=xx+(cmx div pow2i[i-lvlmin])+0;
      zz:=zz+(cmz div pow2i[i-lvlmin]);

      levels[i,x*lvlsizp+y]:=palyvert(xx,yy,zz,scalfac,i);
   end;

  lvlupd[i]:=true;
 end;
end;



procedure initsky;
const
skynagy=900;
var
mag1,mag2,szel1,szel2:extended;
i,j:integer;
szog:single;
begin
 for j:=0 to high(skystrips) do
 begin
  sincos((j/length(skystrips))*D3DX_PI,szel1,mag1);
  sincos(((j+1)/length(skystrips))*D3DX_PI,szel2,mag2);
  szel1:=szel1*skynagy;mag1:=mag1*skynagy-100;szel2:=szel2*skynagy;mag2:=mag2*skynagy-100;
  for i:=0 to high(skystrips[i]) div 2 do
  begin
   szog:=i*D3DX_PI*8/length(skystrips[i])+D3DX_PI/2;
   skystrips[j,i*2+0]:=SkyVertex(sin(szog)*szel1,mag1,cos(szog)*szel1,i*4/length(skystrips[i]), j*2   /(length(skystrips)));
   skystrips[j,i*2+1]:=SkyVertex(sin(szog)*szel2,mag2,cos(szog)*szel2,i*4/length(skystrips[i]),(j*2+2)/(length(skystrips)));
  end;
 end;
end;

procedure loadspecials(honnan:string);
var
fil:textfile;
str:string;
attr,val:string;
flt:Tarrayofstring;
categ:string;
begin
 assignfile(fil,honnan);
 reset(fil);
 repeat
  readln(fil,str);
  if str='' then continue;
  if str[1]='[' then
  begin
   if pos('[SPECIAL:',str)>0 then
    categ:=lowercase(copy(str,length('[SPECIAL:')+1,length(str)-length('[SPECIAL:')-1))
   else
    categ:='';
   if categ='teleport' then
   begin
    setlength(teleports,length(teleports)+1);
    with teleports[high(teleports)] do
    begin
      vfrom:=D3DXVector3Zero;
      vto:=D3DXVector3Zero;
      rad:=5;
      vis:=20;
    end;
   end;
  end
  else
  begin
   attr:=lowercase(copy(str,1,pos('=',str)-1));
   val :=copy(str,pos('=',str)+1,1000);

   if categ='teleport' then
    with teleports[high(teleports)] do
    begin
     if attr='radius' then
      rad:=strtofloat(val);
     if attr='visible' then
      vis:= strtofloat(val);

     if attr='from' then
     begin
      explode(val,' ',flt);
      if high(flt)<2 then
      begin
       writeln(logfile,'Bad position value in specials file at a [teleport]');
       continue;
      end;
      vfrom:=D3DXVector3(strtofloat(flt[0]),strtofloat(flt[1]),strtofloat(flt[2]));
     end;

     if attr='to' then
     begin
      explode(val,' ',flt);
      if high(flt)<2 then
      begin
       writeln(logfile,'Bad position value in specials file at a [teleport]');
       continue;
      end;
      vto:=D3DXVector3(strtofloat(flt[0]),strtofloat(flt[1]),strtofloat(flt[2]));
     end;
    end;
   end;
 until eof(fil);
 closefile(fil);
end;

function loadojjektumok:boolean;
var
i:byte;
ures:array of TD3DXVector3;
label
visszobj;
begin
  result:=false;
 setlength(ures,0);

 addfiletochecksum('data\map.ini');
 loadojjektumini('data\map.ini');

 setlength(ojjektumarr,length(ojjektumnevek));
 for i:=0 to high(ojjektumnevek) do
  begin
   menu.DrawLoadScreen((40*i) div length(ojjektumnevek));
   ojjektumarr[i]:=nil;
   ojjektumarr[i]:=T3dojjektum.Create('data\'+ojjektumnevek[i],g_pd3ddevice,ojjektumscalek[i].x,ojjektumscalek[i].y,ojjektumhv[i],ojjektumflags[i],false);
   if (ojjektumarr[i]=nil)  then
   begin
    writeln(logfile,'Brutal error loading object '''+ojjektumnevek[i]+'''');
    exit;
   end
   else
    if not  ojjektumarr[i].betoltve then
    begin
     writeln(logfile,'Error loading object '''+ojjektumnevek[i]+'''');
     exit;
    end
    else
     writeln(logfile,'Loaded object '''+ojjektumnevek[i]+'''');
  end;

  d3dxvec3add(dnsvec,ojjektumarr[panthepulet].holvannak[0],ojjektumarr[panthepulet].vce);
  dnsrad:=ojjektumarr[panthepulet].rad*1.4;

  result:=true;
  writeln(logfile,'Loaded objects');flush(logfile);
   menu.DrawLoadScreen(45);
  ojjektumrenderer:=T3DORenderer.Create(g_pd3ddevice);
 
  writeln(logfile,'Loaded objectrenderer');flush(logfile);

  //saveojjektumini('data\ojjektumok.ini');
end;

function loadfegyv:boolean;
var
gotolni:boolean;
label
visszfegyv;
begin
  result:=false;
  visszfegyv:
  gotolni:=false;
  try
   fegyv:=TFegyv.Create(g_pD3Ddevice);
  except
   on EAccessViolation do
   begin
    writeln(logfile,'Access Violation.');
    exit;
   end;
  end;
  if (fegyv=nil) then
  begin
   messagebox(0,'Weapon loading brutal error',Pchar(lang[30]),0);
   exit;
  end;
  if not fegyv.betoltve then gotolni:=true;
  if gotolni then begin
   writeln(logfile,'Failed to load weapon');flush(logfile);
   exit;
  end;
  result:=not gotolni;
  if not gotolni then begin writeln(logfile,'Loaded weapons');flush(logfile);end;
end;

function initmaptex:HRESULT;
const
l1c:TD3DXColor=(r  : 1.0;g  : 1.0; b  : 0.9 ;a : 1);
l2c:TD3DXColor=(r  : 0.15;g : 0.15;b  : 0.25;a : 1);
l3c:TD3DXColor=(r  : $20/255;g : $20/255;b  : $20/255;a : 1);
type
 array4ofbyte = array [0..3] of byte;
var
i,j,k,l:integer;
lr:TD3DLockedrect;
pbits:pointer;
cmap1:array [0..255,0..255] of array4ofbyte;
xx,yy,zz:single;
tmp:single;
n:TD3DXVector3;
fucol,hocol,kocol:TD3DXColor;
col,lght1,lght2,ossz,veg:TD3DXColor;
l1,l2:TD3DXVector3;
fil:file of array4ofbyte;
tmptex:IDIrect3DTexture9;
begin
 Result:= E_FAIL;
 tmptex:=nil;
 if Failed(g_pd3dDevice.CreateTexture( 256, 256, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, tmptex, nil)) then Exit;
 if Failed(g_pd3dDevice.CreateTexture( 256, 256, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, mt1, nil)) then Exit;
 if Failed(g_pd3dDevice.CreateTexture( 256, 256, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, mt2, nil)) then Exit;

 fucol:=D3DXColor(116/255,178/255,67/255,0);
 kocol:=D3DXColor(110/255,110/255,108/255,1);
 D3DXColormodulate(hocol,D3DXColor(239/255,239/255,239/255,0),
                         D3DXColor(250/255,200/255,200/255,0));
 hocol:= D3DXColor(250/255,200/255,200/255,0);
 if fileexists('data\cmap.raw') then
 begin
  assignfile(fil,'data\cmap.raw');
  reset(fil);
  blockread(fil,cmap1,256*256);
  closefile(fil)

 end
 else
 begin
 l1:= D3DXVector3(-1,1.0,0);
 D3DXVec3Normalize(l1, l1);
 l2:=l1; l2.x:=-l2.x;

 for i:=0 to 255 do
  for j:=0 to 255 do
  begin
   xx:=j-128;
   zz:=i-128;
   yandnorm(xx,yy,zz,n,8);

   for k:=0 to high(ojjektumarr) do
    for l:=0 to ojjektumarr[k].hvszam-1 do
     if ojjektumarr[k].raytestbol(D3DXVector3(xx,yy,zz),D3DXVector3(xx-ojjektumarr[k].rad*2,yy+ojjektumarr[k].rad*2,zz),l) then
     begin
      n:=D3DXVector3(sqrt(2),sqrt(2),0);
      break;
     end;
 //zz:=zz+(round(xx)mod 2)*scalfac/2;
 {szin:=RGB(round((1+perlin.noise(xx+1000,yy,zz))*100)+100,
           round((1+perlin.noise(xx,yy+1000,zz))*50)+180,
           round((1+perlin.noise(xx,yy,zz+1000))*100)+100);   }
   col:=fucol;
   if yy<0 then yy:=0;
   if yy<15 then col:=hocol;
   if (n.y)<0.83 then col:=kocol;
   if yy<10 then {D3DXColormodulate(col,D3DXColor(239/255,239/255,239/255,1),
                    D3DXColorfromDword(RGB(250-round(yy*4),100+round(yy*8),round(yy*20))+$FF000000));}
                    col:=D3DXColorfromDword(RGB(255-round(yy*4),100+round(yy*8)+35,round(yy*20)+25)+$FF000000);
   tmp:=D3DXVec3dot(n,l1);
   if tmp<0 then tmp:=0;
   D3DXColorscale(lght1,l1c,tmp);

   tmp:=D3DXVec3dot(n,l2);
   if tmp<0 then tmp:=0;
   D3DXColorscale(lght2,l2c,tmp);

   D3DXColoradD(ossz,lght1,lght2);
   D3DXColorAdd(ossz,ossz,l3c);
   D3DXColorModulate(veg,ossz,col);

   cmap1[i,j,0]:=min(round(veg.b*255),255);
   cmap1[i,j,1]:=min(round(veg.g*255),255);
   cmap1[i,j,2]:=min(round(veg.r*255),255);
   cmap1[i,j,3]:=min(round(col.a*255),255);
  end;

  assignfile(fil,'data\cmap.raw');
  rewrite(fil);
  blockwrite(fil,cmap1,256*256);
  closefile(fil);

 end;


 result:=tmptex.LockRect(0, lr, nil, 0);
 if Failed(result) then Exit;
 for i:= 0 to 255 do
  begin
    pBits := PDWORD(Integer(lr.pBits)+i*lr.Pitch);
    copymemory(pbits,addr(cmap1[i]),256*4);
  end;
 tmptex.UnlockRect(0);

 g_pd3ddevice.UpdateTexture(tmptex,mt1);

 // MT2/////////////////////////////////////////////////

 if fileexists('data\cmap2.raw') then
 begin
  assignfile(fil,'data\cmap2.raw');
  reset(fil);
  blockread(fil,cmap1,256*256);
  closefile(fil)

 end
 else
 begin
 for i:=0 to 255 do
  for j:=0 to 255 do
  begin
   xx:=j-128;
   zz:=i-128;
   yandnorm(xx,yy,zz,n,8);
   for k:=0 to high(ojjektumnevek) do
    for l:=0 to ojjektumarr[k].hvszam-1 do
     if ojjektumarr[k].raytestbol(D3DXVector3(xx,yy,zz),D3DXVector3(xx,yy+ojjektumarr[k].rad*2,zz),l) then
     begin
     // n:=ojjektumarr[k].raytest(D3DXVector3(xx,yy+ojjektumarr[k].rad*2,zz),D3DXVector3(xx,yy,zz),l);
     //  yy:=(n.y-yy)/3;
      cmap1[i,j,1]:=255;//round(yy*255);
      cmap1[i,j,0]:=255;//-$FF and round(yy*255);
      cmap1[i,j,2]:=255;
      cmap1[i,j,3]:=255;
      break;
     end;
   end;

  assignfile(fil,'data\cmap2.raw');
  rewrite(fil);
  blockwrite(fil,cmap1,256*256);
  closefile(fil);

 end;


 result:=tmptex.LockRect(0, lr, nil, 0);
 if Failed(result) then Exit;
 for i:= 0 to 255 do
  begin
    pBits := PDWORD(Integer(lr.pBits)+i*lr.Pitch);
    copymemory(pbits,addr(cmap1[i]),256*4);
  end;
 tmptex.UnlockRect(0);

 g_pd3ddevice.UpdateTexture(tmptex,mt2);


 tmptex:=nil;
 Result:= S_OK;
end;

procedure fillmp3filelist;
var
myrec:Tsearchrec;
hov:integer;
begin
 if findfirst('mp3\*.mp3',faAnyFile-fadirectory,myrec)=0 then
 repeat
  setlength(mp3filelist,length(mp3filelist)+1);
  mp3filelist[high(mp3filelist)]:='mp3\'+myrec.name;
 until not (findnext(myrec)=0);

 if findfirst('radio\*.m3u',faAnyFile-fadirectory,myrec)=0 then
 repeat
  case myrec.Name[2] of
   'm':hov:=0; //aMbient
   'c':hov:=1; //aCtion
   'a':hov:=2; //rAdio
  else
   hov:=0;
  end;
  setlength(mp3strms[hov],length(mp3strms[hov])+1);
  mp3strms[hov][high(mp3strms[hov])]:=readm3urecord('radio\'+myrec.name);
 until not (findnext(myrec)=0);

 if findfirst('radio\*.pls',faAnyFile-fadirectory,myrec)=0 then
 repeat
  case myrec.Name[2] of
   'm':hov:=0; //aMbient
   'c':hov:=1; //aCtion
   'a':hov:=2; //rAdio
  else
   hov:=0;
  end;
  setlength(mp3strms[hov],length(mp3strms[hov])+1);
  mp3strms[hov][high(mp3strms[hov])]:=readplsrecord('radio\'+myrec.name);
 until not (findnext(myrec)=0);

end;

procedure loadsounds;
begin
   menu.DrawLoadScreen(85);

  // Initialize DirectSound
 InitSound(hwindow);

  LoadSound('gunshot',true,false,true,3);
  LoadSound('walkground',true,true,true,1);
  LoadSound('rocks',true,true,true,1);
  LoadSound('walkwater',true,false,true,1);
  LoadSound('plasmashot2',true,false,true,2);
  LoadSound('m82shot',true,false,true,7);     //5
  LoadSound('4shot',true,false,true,4);
  LoadSound('antigrav',true,true,true,1);
  LoadSound('humm',true,true,true,1);
  LoadSound('death1',true,false,true,1);
  LoadSound('death2',true,false,true,1);      //10
  LoadSound('death3',true,false,true,1);
  LoadSound('rain',false,false,true,1);
  LoadSound('thd',false,false,true,1);
  LoadSound('whoosh',true,true,true,0.1);
  LoadSound('charge',true,true,true,2);       //15
  LoadSound('rocket',true,false,true,2);
  LoadSound('niceexp',true,true,true,6);
  LoadSound('noobshot',true,false,true,2);
  LoadSound('noobexp',true,false,true,7);
  LoadSound('rocketshot',true,false,true,2);  //20
  LoadSound('x72exp',true,true,true,1);
  LoadSound('mp5',true,false,true,2);
  LoadSound('x72shot',true,false,true,3);
  LoadSound('pajzs',true,false,true,1);
  LoadSound('teleport',true,false,true,1);    //25
  LoadSound('mechanic',true,false,true,1);
  LoadSound('lwhoosh',true,false,true,0.1);
  LoadSound('creak',true,true,true,20);
  LoadSound('lasertiu',true,true,true,20);
  LoadSound('lownoise',true,true,true,15);    //30
  LoadSound('biglas',true,true,true,10);
  LoadSound('uberexp',true,false,true,100);
  LoadSound('mechahuge',true,false,true,30);
  LoadSound('largeser',true,true,true,2);
                                              //35



  menu.DrawLoadScreen(87);

  fillMP3filelist;
 // zeneinit;

  LoadStrm('tch\begin');        //0  TECH
  LoadStrm('tch\end');                        
  LoadStrm('tch\targ_el');
  LoadStrm('tch\subj_ter');
  LoadStrm('tch\sens_rep_own');
  LoadStrm('tch\resist_is_fut'); //5
  LoadStrm('tch\recalc_en_num');
  LoadStrm('tch\impressive');
  LoadStrm('tch\excellent');
  LoadStrm('tch\error_666');
  LoadStrm('tch\crt_dmg_det');    //10
  LoadStrm('tch\cls_a_sht');
  LoadStrm('tch\killing_spree');  //12 killing spreek
  LoadStrm('tch\rampage');
  LoadStrm('tch\dominating');
  LoadStrm('tch\unstoppable');    //15
  LoadStrm('tch\godlike');
  LoadStrm('tch\wicked_sick');
  LoadStrm('gun\begin');          //18 GUN
  LoadStrm('gun\end');
  LoadStrm('gun\you_the_man');    //20
  LoadStrm('gun\thy_mst_lk');
  LoadStrm('gun\tht_ws_nst');
  LoadStrm('gun\tht_it_sldr');
  LoadStrm('gun\tht_a_kill');
  LoadStrm('gun\ownage');         //25
  LoadStrm('gun\one_down');
  LoadStrm('gun\nc_sht_man');
  LoadStrm('gun\keep_up');
  LoadStrm('gun\grt_shot');
  LoadStrm('gun\good_work');      //30
  LoadStrm('gun\good_work');
  LoadStrm('gun\killing_spree');  //32 killing spreek
  LoadStrm('gun\rampage');
  LoadStrm('gun\dominating');
  LoadStrm('gun\unstoppable');    //35
  LoadStrm('gun\godlike');
  LoadStrm('gun\wicked_sick');
  menu.DrawLoadScreen(90);
end;

procedure SetupMyMuksmatr;
var
  matWorld,matWorld2: TD3DMatrix;
  pos:TD3DVector;
begin
 muks.jkez:=fegyv.jkez(myfegyv,mstat);
 muks.bkez:=fegyv.bkez(myfegyv,mstat);

 case mstat and MSTAT_MASK of
  0:muks.stand((mstat and MSTAT_GUGGOL)>0);
  1:muks.Walk(animstat,(mstat and MSTAT_GUGGOL)>0);
  2:muks.Walk(1-animstat,(mstat and MSTAT_GUGGOL)>0);
  3:muks.SideWalk(animstat,(mstat and MSTAT_GUGGOL)>0);
  4:muks.SideWalk(1-animstat,(mstat and MSTAT_GUGGOL)>0);
  5:muks.Runn(animstat,true);
 end;

 pos:=d3dxvector3(ccpx,ccpy,ccpz);
 D3DXMatrixRotationY(matWorld2,szogx+d3dx_pi);
 D3DXMatrixTranslation(matWorld,pos.x,pos.y,pos.z);
 D3DXMatrixMultiply(matWorld,matWorld2,matWorld);
 mat_World:=matworld;
 //g_pd3dDevice.SetTransform(D3DTS_WORLD, matWorld);
end;

{procedure re_sound;
var
i:integer;
begin

 if ((hanyszor mod 16)=0) and (tavpointpoint(re_gk,campos)<200) then
 begin
  playsound(34,true,1338,true,re_gk);
  SetSoundProperties(34,1338,0,5000,true,re_gk);
 end;
end;}



{procedure re_effect;
var
tmp,vec1,tmp1,tmp2,vec2,t:TD3DXVector3;
rnd:integer;
i,j:integer;
val:boolean;
camtav:single;
love:integer;
szog,tav:single;
begin
if (currevent is TReactorEvent) then
begin
 if (currevent.phs=2) or (currevent.phs=3) then
  if currevent.phstim=1 then
  begin
   rezg:=10;
   d3dxvec3subtract(robhely,re_pos,d3dxvector3(cpx^,cpy^,cpz^));
   fastvec3normalize(robhely);
  end;

 if (currevent.phs=9) then
  if currevent.phstim=1 then
  begin
   rezg:=20;
   d3dxvec3subtract(robhely,re_pos,d3dxvector3(cpx^,cpy^,cpz^));
   fastvec3normalize(robhely);
  end;

 if (currevent.phs=10) then
  begin
   rezg:=currevent.phstim/20;
   d3dxvec3subtract(robhely,re_pos,d3dxvector3(cpx^,cpy^,cpz^));
   fastvec3normalize(robhely);
  end;

 if currevent.phs=11 then
   needsupdate:=true;
 gazmsg:='You have vanished into the nothingness. Please download 2.0 to reappear.';
 exit;
end;
  camtav:=tavpointpoint(campos,re_gk);


   //Particlesystem_Add_Villam(re_szikr[random(length(re_szikr))],vec1,2,0.4,5,0.5,$FFFFFFFF,50);

   //kék háttér a gömbnek
 particlesystem_add(simpleparticlecreate(re_gk,randomvec(gettickcount mod 100000,0.5),40,40,$10402010,0,1));

 // az örvény
 tmp:=re_gk;
 tmp.y:=tmp.y+200;
 for i:=0 to 2 do
 begin
  szog:=pi*random(10000)/5000;
  tav:=random(110);
  tmp1:=D3DXVector3(sin(szog)*tav,0,cos(szog)*tav);
  tmp2:=D3DXVector3(cos(szog)*0.3*150,0,-sin(szog)*0.3*150);
  d3dxvec3add(tmp1,tmp1,tmp);
  d3dxvec3subtract(tmp1,tmp1,tmp2);
  d3dxvec3scale(tmp2,tmp2,1/150);
  if tav>5 then
   particlesystem_add(simpleparticlecreate(tmp1,tmp2,(160-tav)/3,0,0,$FF000000+$010101*round(tav),150))
  else
   particlesystem_add(simpleparticlecreate(tmp1,tmp2,100,0,0,$80F08040,150))
 end;

 //a tripla csík cucc
 for i:=0 to 2 do
 begin
  vec1:=re_gk;
  for j:=0 to 20 do
  begin
   vec2:=vec1;
   tmp1:=randomvec(gettickcount/2000-j/20,j*5+5);
   tmp2:=randomvec(gettickcount/1000+i*100,30+j*2);
   d3dxvec3lerp(vec1,tmp1,tmp2,sqr((j-10)/10));
   vec1.y:=(re_gk.y-re_pos.y+vec1.y*1+j*10);
   d3dxvec3add(vec1,vec1,re_pos);
   if j>0 then
   particlesystem_Add(fenycsik2create(vec1,vec2,2+j/4,min($808080,$101010*(10-abs(10-j))),min($808080,$101010*(10-abs(10-j))),1));
  end;
 end;

 //a szívott csíkok
 if camtav<150 then
 for i:=0 to 2 do
 begin
  tmp1:=randomvec(random(100000)/100+i*13.4567,3);
  d3dxvec3scale(tmp2,tmp1,1.2);
  d3dxvec3scale(vec1,tmp2,-50);
  d3dxvec3add(vec1,vec1,re_gk);
  particlesystem_Add(fenycsikubercreate(vec1,vec1,tmp1,tmp2,0.2,0,0,$808080,50));
 end;

 // a felfelé menõ csíkok
 if (hanyszor and 3)=0 then
 begin
  tmp1:=randomvec(random(100000)/100+i*13.4567,25);
  d3dxvec3add(vec1,tmp1,re_gk);
  vec2:=vec1;
  vec2.y:=vec2.y+3;
  particlesystem_Add(fenycsikubercreate(vec1,vec2,D3dxvector3(0,2,0),d3dxvector3(0,2.4,0),0.5,0.5,$808080,0,80));
 end;

 //for i:=0 to 0 do
 begin
  tmp1:=randomvec(gettickcount*1.234+random(100),70);
  tmp1.y:=0;
  d3dxvec3add(tmp1,tmp1,re_pos);
  d3dxvec3subtract(vec1,re_gk,tmp1);
  d3dxvec3scale(vec1,vec1,1/1000);
  particlesystem_Add(expsebparticlecreate(tmp1,vec1,5,2,1.03,0,$A0204020,100));
 end;


 particlesystem_add(simpleparticlecreate(re_gk,randomvec(gettickcount mod 100000,0.5),25,20,$FF000000,0,1));

end;


procedure re_gomb;
var
light:TD3DLight9;
vecDir:TD3DXVector3;
mat1,mat2,mat3:TD3DMatrix;
begin
  if (currevent is TReactorEvent) then
  begin
   if currevent.phs>6 then exit;

   re_gk:=currevent.kivec;
  end;

  ZeroMemory(@light, SizeOf(TD3DLight9));
  light._Type      := D3DLIGHT_DIRECTIONAL;
  light.Diffuse.r  := -22;
  light.Diffuse.g  := -22;
  light.Diffuse.b  := -22;
  light.Diffuse.a  := 1;
  d3dxvec3subtract(vecDir,re_gk,campos);
  D3DXVec3Normalize(light.Direction, vecDir);
  light.Range := 1000.0;
  g_pd3dDevice.SetLight(0, light);
  g_pd3dDevice.LightEnable(0, true);
  g_pd3dDevice.LightEnable(1, false);
  g_pd3ddevice.setrenderstate(D3DRS_LIGHTING,itrue);
  g_pd3ddevice.SetRenderState(D3DRS_ALPHABLENDENABLE,iTrue);
  g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_ONE);
  g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,  D3DBLEND_ONE);
  g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE,iFalse);
  g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $0FFFFFF);

  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG2);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_SELECTARG2);
  g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
  g_pd3ddevice.setrenderstate(D3DRS_CULLMODE,D3DCULL_CCW);
  //g_pd3ddevice.setrenderstate(D3DRS_ZWRITEENABLE,itrue);

  d3dxmatrixtranslation(mat1,re_gk.x,re_gk.y,re_gk.z);
  d3dxmatrixscaling(mat2,18.5+sin(gettickcount/1000),18.5+sin(gettickcount/1200),18.5+sin(gettickcount/1300));
  d3dxmatrixmultiply(mat3,mat2,mat1);
  g_pd3ddevice.SetTransform(D3DTS_WORLD,mat3);

  noobmesh.DrawSubset(0);

end;



procedure re_initeffect;
var
i,j,hol:integer;
tav:single;
tmp:TD3DXVector3;
begin
 hol:=reactorepulet;
 re_pos:=ojjektumarr[hol].holvannak[0];
 d3dxvec3add(re_gk,D3DxVector3(0,17,0),re_pos);
end;     }


//-----------------------------------------------------------------------------
// Name: InitGeometry()
// Desc: Creates the scene geometry
//-----------------------------------------------------------------------------
function InitializeAll: HRESULT;
var
  pIndices:PWordArray;
  indmost:integer;
  x,y:integer;
  tempmesh:ID3DXMesh;
  tempd3dbuf:ID3DXBuffer;
  vmi:string;
  devicecaps: TD3DCaps9;
  backbuf:IDirect3Dsurface9;
  desc:TD3DSurfacedesc;
const
  Effect_offset:array [0..11] of TD3DXVector2 =
    ((x:-0.015;y:-0.015),(x:-0.01;y:-0.01),(x:-0.005;y:-0.005),(x: 0.015;y:-0.015),(x: 0.01;y:-0.01),(x: 0.005;y:-0.005),
     (x:-0.015;y: 0.015),(x:-0.01;y: 0.01),(x:-0.005;y: 0.005),(x: 0.015;y: 0.015),(x:-0.01;y: 0.01),(x: 0.005;y: 0.005));
  Effect_Szorzo:array [0..11] of single =(0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5);
label
visszobj,visszfegyv;
begin

   {$IFDEF AIparancsok}
   botlevel:=0.3;
   invbotlevel:=1/botlevel;
   {$ENDIF}
  Result:= E_FAIL;
  enableeffects:=true;
  laststate:='Initializing';

  g_pd3ddevice.GetDeviceCaps(devicecaps);

  g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iTrue);

  FAKE_HDR:=D3DTOP_MODULATE;
  muks:=Tmuksoka.create(g_pd3ddevice);
  if muks=nil then
  begin
   messagebox(0,'TMuks.create brutal error',Pchar(lang[30]),0);
   exit;
  end;
  if not muks.betoltve then
  begin
   messagebox(0,'TMuks.create error',Pchar(lang[30]),0);
   exit;
  end;
  writeln(logfile,'Loaded stickmen');flush(logfile);

  if not loadfegyv then exit;

  if not loadojjektumok then exit;
  tempmesh:=nil;

  loadspecials('data\map.ini');
    menu.DrawLoadScreen(50);

 { if FAILED(D3DXCreateSphere(g_pD3DDevice,0.2,10,20,tempmesh,nil)) then Exit;
  if tempmesh=nil then exit;if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_CUSTOMVERTEX,g_pd3ddevice,Testmesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;}
  if not LTFF(g_pd3dDevice, 'data\grass.jpg',futex) then exit;
  if not LTFF(g_pd3dDevice, 'data\gnoise.jpg',noise2tex) then exit;
  if not LTFF(g_pd3dDevice, 'data\rock.jpg',kotex) then exit;
  if not LTFF(g_pd3dDevice, 'data\rnoise.jpg',noisetex) then exit;
  if not LTFF(g_pd3dDevice, 'data\sand.jpg',homtex) then exit;
    menu.DrawLoadScreen(55);
  writeln(logfile,'Loaded ground textures');flush(logfile);
  if not LTFF(g_pd3dDevice, 'data\water.jpg', viztex) then exit;
  if not LTFF(g_pd3dDevice, 'data\water2.jpg', waterbumpmap) then exit;
  writeln(logfile,'Loaded water texture');flush(logfile);
  if not LTFF(g_pd3dDevice, 'data\sky1.png', skytex) then exit;
  if not LTFF(g_pd3dDevice, 'data\sun1.png', suntex) then exit;

  initsky;
  writeln(logfile,'Loaded Sky');flush(logfile);
    menu.DrawLoadScreen(60);
  if FAILED(D3DXLoadMeshFromX('data\hummer.x',0,g_pd3ddevice,nil,nil, nil,nil,tempmesh)) then Exit;
  if tempmesh=nil then exit;if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_TEX1,g_pd3ddevice,g_pautomesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;

  if FAILED(D3DXLoadMeshFromX('data\antigrav.x',0,g_pd3ddevice,nil,nil, nil,nil,tempmesh)) then Exit;
  if tempmesh=nil then exit;if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_TEX1,g_pd3ddevice,g_pantigravmesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;

  if FAILED(D3DXLoadMeshFromX('data\kerek.x',0,g_pd3ddevice,nil,nil, nil,nil,tempmesh)) then Exit;
  if tempmesh=nil then exit;if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_TEX1,g_pd3ddevice,g_pkerekmesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;
  normalizemesh(G_pkerekmesh);
  normalizemesh(g_pautomesh);
  normalizemesh(g_pantigravmesh);


  if FAILED(D3DXLoadMeshFromX('data\rocket003.x',0,g_pd3ddevice,nil,nil, nil,nil,tempmesh)) then Exit;
  if tempmesh=nil then exit;if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_XYZ or D3DFVF_NORMAL + D3DFVF_DIFFUSE ,g_pd3ddevice,lawmesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;

  if FAILED(D3DXLoadMeshFromX('data\gomb.x',0,g_pd3ddevice,nil,nil, nil,nil,tempmesh)) then Exit;
  if tempmesh=nil then exit;if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_XYZ or D3DFVF_NORMAL ,g_pd3ddevice,noobmesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;

  normalizemesh(lawmesh);
  normalizemesh(noobmesh);

 // D3DXcreatebox(g_pd3ddevice,2,2,2,testmesh,nil);

  tegla:=Tauto.create(d3dxvector3(1,0,0),d3dxvector3(0,1,0),d3dxvector3(0,0,1),d3dxvector3zero,d3dxvector3zero,0.9,0.99,hummkerekarr,1,0.2,0.3,false);
  tegla.disabled:=true;
  if not LTFF(g_pd3dDevice, 'data\hummer.jpg', cartex) then exit;
  if not LTFF(g_pd3dDevice, 'data\antigrav.jpg', antigravtex) then exit;
  if not LTFF(g_pd3dDevice, 'data\kerektex.jpg', kerektex) then exit;
  writeln(logfile,'Loaded vehicles');
                           
  result:=D3DXCreateTexture(g_pd3ddevice,SCWidth div 2,SCheight div 2,0,D3DUSAGE_RENDERTARGET,D3DFMT_A8R8G8B8,D3DPOOL_DEFAULT,effecttexture);
  if failed(result) then
  begin
   enableeffects:=false;
   writeln(logfile,'No Rendertarget textures');
  end
  else
   writeln(logfile,'Full screen texture intitialized');
                                                                                             
  result:=D3DXCreateTexture(g_pd3ddevice,SCWidth div 4,SCheight div 4,0,D3DUSAGE_RENDERTARGET,D3DFMT_A8R8G8B8,D3DPOOL_DEFAULT,reflecttexture);
  if failed(result) or (reflecttexture=nil) then
  begin
   enableeffects:=false;
   writeln(logfile,'Not using reflection');
  end
  else
   writeln(logfile,'Reflections initialized');

  g_pd3ddevice.GetBackBuffer(0,0,D3DBACKBUFFER_TYPE_MONO,backbuf);
  backbuf.GetDesc(desc);

  g_pd3ddevice.CreateOffscreenPlainSurface(desc.Width,desc.height,desc.Format,D3DPOOL_SYSTEMMEM,printscreensurf,nil);

    addfiletoChecksum('data/effects.fx');
  if  devicecaps.PixelShaderVersion>=D3DPS_VERSION(2,0) then
  begin

   result:=D3DXCreateEffectFromFile(g_pd3dDevice, 'data/effects.fx', nil, nil, 0, nil, g_pEffect, @tempd3dbuf);
   if Failed(result)
   then
   begin
    vmi:=string(Pchar(tempd3dbuf.GetBufferPointer));
    writeln(logfile,'Not using shaders ('+vmi+')');
   end
   else
   begin
    g_pEffect.SetValue('g_Offset', @Effect_offset, sizeof(Effect_offset));
    writeln(logfile,'Shaders initialized');
   end;
  end
  else
    writeln(logfile,'No shader 2.0 on device');

  Result:= E_FAIL;

  ParticleSystem_Init(g_pd3ddevice);
  // Create the buffers.
 { if legyenfu then
   if FAILED(g_pd3dDevice.CreateVertexBuffer((lvlsizp*lvlsizp*(4)+100)*SizeOf(TCustomVertex),
                                            D3DUSAGE_WRITEONLY+D3DUSAGE_DYNAMIC, D3DFVF_CUSTOMVERTEX,
                                            D3DPOOL_DEFAULT, g_pdynVB, nil))
  then Exit; }

    menu.DrawLoadScreen(70);

  if FAILED(g_pd3dDevice.CreateVertexBuffer((lvlsizp*lvlsizp*(lvlmax-lvlmin+1)+8*200)*SizeOf(TCustomVertex),
                                            D3DUSAGE_WRITEONLY, D3DFVF_CUSTOMVERTEX,
                                            D3DPOOL_MANAGED, g_pVB, nil))
  then Exit;
//  g_pd3ddevice.EvictManagedResources;
  //use32bitindices:=false;
  if use32bitindices then
  begin
   if FAILED(g_pd3dDevice.CreateIndexBuffer((lvlsiz*lvlsiz*6*(farlvl-lvlmin+3)+5000)*SizeOf(dword),
                                             D3DUSAGE_WRITEONLY and D3DUSAGE_DYNAMIC,D3DFMT_INDEX32,
                                             D3DPOOL_DEFAULT , g_pIB, nil))
   then Exit;

   if FAILED(g_pd3dDevice.CreateIndexBuffer((lvlsiz*lvlsiz*6*(lvlmax-farlvl+1)+5000)*SizeOf(dword),
                                             D3DUSAGE_WRITEONLY,D3DFMT_INDEX32,
                                             D3DPOOL_DEFAULT , g_pIBlvl2, nil))
   then Exit;
  end
  else
  begin
   if FAILED(g_pd3dDevice.CreateIndexBuffer((lvlsiz*lvlsiz*6*(farlvl-lvlmin+3)+5000)*SizeOf(word),
                                             D3DUSAGE_WRITEONLY and D3DUSAGE_DYNAMIC,D3DFMT_INDEX16,
                                             D3DPOOL_DEFAULT , g_pIB, nil))
   then Exit;

   if FAILED(g_pd3dDevice.CreateIndexBuffer((lvlsiz*lvlsiz*6*(lvlmax-farlvl+1)+5000)*SizeOf(word),
                                             D3DUSAGE_WRITEONLY,D3DFMT_INDEX16,
                                             D3DPOOL_DEFAULT , g_pIBlvl2, nil))
   then Exit;
  end;

  

   indmost:=0;

   for x:=lvmi to lvma do
    for y:=lvmi to lvma do
    begin
     alapind[indmost+1]:=x*lvlsizp+y;
     alapind[indmost+0]:=(x+1)*lvlsizp+y;
     alapind[indmost+2]:=x*lvlsizp+(y+1);
     alapind[indmost+4]:=x*lvlsizp+(y+1);
     alapind[indmost+3]:=(x+1)*lvlsizp+y;
     alapind[indmost+5]:=(x+1)*lvlsizp+(y+1);
     indmost:=indmost+6;
    end;

     toind:=indmost;

   for x:=0 to lvlsiz-1 do
    for y:=0 to lvlsiz-1 do
    if ((x<lvmi) or (x>lvma))or ((y<lvmi) or (y>lvma)) then
    begin
     alapind[indmost+1]:=x*lvlsizp+y;
     alapind[indmost+0]:=(x+1)*lvlsizp+y;
     alapind[indmost+2]:=x*lvlsizp+(y+1);
     alapind[indmost+4]:=x*lvlsizp+(y+1);
     alapind[indmost+3]:=(x+1)*lvlsizp+y;
     alapind[indmost+5]:=(x+1)*lvlsizp+(y+1);
     indmost:=indmost+6;
    end;

    allind:=indmost;

  if FAILED(g_pIBlvl2.Lock( 0, 0, Pointer(pIndices), D3DLOCK_DISCARD))
  then Exit;

  indmost:=0;
  for x:=farlvl to lvlmax do
  begin
    for y:=0 to allind-1 do
    begin
     if (x<>farlvl) and (y<toind) then continue;
     pIndices[indmost]:=alapind[y];
     inc(indmost);
     if use32bitindices then
     begin
      pIndices[indmost]:=0;
      inc(indmost);
     end;
    end;
    for y:=0 to allind-1 do
    inc(alapind[y],lvlsizp*lvlsizp);
  end;


  g_pIBlvl2.unlock;


   for y:=0 to allind-1 do
    dec(alapind[y],lvlsizp*lvlsizp*(lvlmax-farlvl+1));


   menu.DrawLoadScreen(75);
   initmaptex;
   menu.DrawLoadScreen(80);
  writeln(logfile,'Initialized buffers');flush(logfile);
  addfiletochecksum('data/bush256.png');
  bokrok:=TFoliage.create(G_pd3ddevice,'bush256.png',1,1.2,-0.1);
  fuvek:=TFoliage.create(G_pd3ddevice,'mg3.png',0.2,-0.3,0.25);
 // fuvek2:=TFoliage.create( G_pd3ddevice,'mg3.png',0.1,-0.2,0.18);
  if not bokrok.betoltve then exit;
  if not fuvek.betoltve then exit;
  //if not fuvek2.betoltve then exit;
  writeln(logfile,'Loaded foliage');flush(logfile);

  felho:=Tfelho.create(g_pd3ddevice);
  writeln(logfile,'Initialized sky');flush(logfile);

  fejcuccrenderer:=Tfejcuccrenderer.Create(g_pd3ddevice);


  cpx^:=10-random(20)+0.5;
  cpz^:=10-random(20)+0.5;

  cpox^:=cpx^;cpoy^:=cpy^;cpoz^:=cpz^;


  cpy^:=advwove(cpx^,cpz^);

  writeln(logfile,'Initilazing geometry succesful');flush(logfile);



  writeln(logfile,'Loading sounds');flush(logfile);
  loadsounds;    //  menu.DrawLoadScreen(85);-tõl 95-ig

  writeln(logfile,'Initializing succeful');flush(logfile);

//  re_initeffect;
  Result:= S_OK;
end;

procedure CleanIBVB;
var
  pVertices: PCustomVertexArray;
begin
 g_pVB.Lock( 0, 0, Pointer(pVertices), D3DLOCK_DISCARD);
 g_pVB.unlock;
 VBwhere:=0;
end;


procedure drawlvl(toplvl:boolean);
begin
// exit;
 if toplvl then
  g_pd3dDevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST,lvlsizp*lvlsizp*farlvl,0,lvlsizp*lvlsizp*(lvlmax-farlvl+1),0,((allind-toind)*(lvlmax-farlvl+1)+toind) div 3)
 else
  g_pd3dDevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST,lvlsizp*lvlsizp*farlvl,0,lvlsizp*lvlsizp*(lvlmax-farlvl+1),toind,((allind-toind)*(lvlmax-farlvl+1)) div 3)
end;

procedure drawsplat(mettol,meddig:integer);
begin
// exit;
mettol:=mettol;
meddig:=meddig;
g_pd3dDevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST,0,0,lvlsizp*lvlsizp*(farlvl-lvlmin+1),mettol,(meddig-mettol) div 3)
end;


//-----------------------------------------------------------------------------
// Name: Cleanup()
// Desc: Releases all previously initialized objects
//-----------------------------------------------------------------------------
procedure Cleanup;
begin
 laststate:='Cleanup';
  showcursor(true);

  if (futex <> nil) then
    futex:= nil;

  if (g_pVB <> nil) then
    g_pVB:= nil;

  if (g_pd3dDevice <> nil) then
    g_pd3dDevice:= nil;

  if (g_pD3D <> nil) then
    g_pD3D:= nil;
end;





procedure Setupidentmatr;
//var
  //matWorld: TD3DMatrix;
begin
  // For our world matrix, we will just leave it as the identity
  D3DXMatrixIdentity(mat_World);

  g_pd3dDevice.SetTransform(D3DTS_WORLD, identmatr);
end;

procedure SetupMuksmatr(mi:integer);
var
  matWorld,matWorld2: TD3DMatrix;
  pos:TD3DVector;
begin

  if mi>=0 then
  begin
   if ppl[mi].net.vtim>0 then
    pos:=ppl[mi].pos.megjpos
   else
    pos:=ppl[mi].pos.pos;
   //pos:=pplpos[mi].pos;
   D3DXMatrixRotationY(matWorld2,ppl[mi].pos.irany+d3dx_pi);
  end
  else
    MessageBox(0,'Benthagyott AI kód','Hiba',0);
   D3DXMatrixTranslation(matWorld,pos.x,pos.y,pos.z);
   D3DXMatrixMultiply(matWorld,matWorld2,matWorld);
   mat_World:=matworld;
  // g_pd3dDevice.SetTransform(D3DTS_WORLD, matWorld);
end;


procedure SetupFegyvmatr(mi:integer;iscsip:boolean);
var
  matWorld,matWorld2: TD3DMatrix;
  pos:TD3DVector;
begin

  if mi>=0 then
  begin
   //pos:=pplpos[mi].pos;
   if ppl[mi].net.vtim>0 then
        pos:=ppl[mi].pos.megjpos
   else
    pos:=ppl[mi].pos.pos;
   if (ppl[mi].pos.state and MSTAT_GUGGOL)>0 then
    pos.y:=pos.y-0.5;
   D3DXMatrixRotationY(matWorld2,ppl[mi].pos.irany+d3dx_pi);

   if (ppl[mi].pls.fegyv=FEGYV_M82A1) and iscsip then
    D3DXMatrixTranslation(matWorld,-0.05,-0.05,0.15)
   else
   if (ppl[mi].pls.fegyv=FEGYV_LAW)then
    D3DXMatrixTranslation(matWorld,0.05,0,0)
   else
   if (ppl[mi].pls.fegyv=FEGYV_QUAD) and (not iscsip) then
    D3DXMatrixTranslation(matWorld,-0.00,-0.1,-0.03)
   else
    D3DXMatrixTranslation(matWorld,-0.05,0,0);

  end else
    MessageBox(0,'Benttthagyott AI kód','Faszom',0);

  D3DXMatrixMultiply(matWorld2,matWorld,matWorld2);
 // pos.x:=pos.x+0.05;
  if iscsip then
    D3DXMatrixTranslation(matWorld,pos.x,pos.y+1.2,pos.z)
  else
   D3DXMatrixTranslation(matWorld,pos.x,pos.y+1.5,pos.z);
   D3DXMatrixMultiply(matWorld,matWorld2,matWorld);

   g_pd3dDevice.SetTransform(D3DTS_WORLD, matWorld);

end;


procedure SetupMyFegyvmatr;
var
  matWorld, mat, mat2: TD3DMatrix;
  acpx,acpy,acpz:single;
begin

  acpy:=ccpy;
  acpx:=ccpx;
  acpz:=ccpz;

  if csipo then
  begin
   acpx:=ccpx+(ccpx-cpx^)*0.5;
   acpy:=ccpy+(ccpy-cpy^)*0.5;
   acpz:=ccpz+(ccpz-cpz^)*0.5;
  end;


  if ((mstat and MSTAT_MASK)<>0) then
   if ((mstat and MSTAT_MASK)=MSTAT_FUT) then
    acpy:=acpy+sin(animstat*4*D3DX_PI)/40
   else
    if csipo then
    acpy:=acpy+sin(animstat*2*D3DX_PI)/80;


  if gugg then
   D3DXMatrixTranslation(matWorld,acpx, acpy+1,acpz)
  else
   D3DXMatrixTranslation(matWorld,acpx, acpy+1.5,acpz);


  D3DXMatrixRotationY(mat,mszogx+d3dx_pi);

  D3DXMatrixRotationX(mat2,mszogy);
  D3DXMatrixMultiply(mat,mat2,mat);
  if csipo then
   D3DXMatrixTranslation(mat2,-0.1,-0.1,0.0)
  else
   D3DXMatrixTranslation(mat2,0,0,0.05);
  if (myfegyv=FEGYV_MP5A3) and (not csipo) then mat2._43:=mat2._43+0.05;

  D3DXMatrixMultiply(mat,mat2,mat);

 // D3DXMatrixscaling(mat2,1.2,1.2,1.2);
  //D3DXMatrixMultiply(mat,mat2,mat);

  D3DXMatrixMultiply(matworld,mat,matworld);
  if halal>0 then d3dxmatrixidentity(matWorld);
  mfm:=matworld;
  g_pd3dDevice.SetTransform(D3DTS_WORLD, matWorld);


end;

procedure undebug_memory1;
var
virt:pdword;
begin
{$IFDEF undebug}
  virt:=nil;
 try
  virt:=virtualalloc(nil,4,MEM_COMMIT+MEM_RESERVE,PAGE_READWRITE+PAGE_GUARD);
  {guard page-es memóriadebug tesztelése}
  virt^:=$13370000; {Kiakad, kivéve ha fut a CE}
  cpy^:=10000000;
 except
 end;
  virtualfree(virt,0,MEM_RELEASE);
{$ENDIF}
end;

//-----------------------------------------------------------------------------
// Name: SetupLights()
// Desc: Sets up the lights and materials for the scene.
//-----------------------------------------------------------------------------
procedure SetupLights;
var
  mtrl: TD3DMaterial9;
  vecDir: TD3DXVector3;
  light: TD3DLight9;
begin
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
  vecDir:= D3DXVector3(1,-1.0,0);
  D3DXVec3Normalize(light.Direction, vecDir);
  light.Range := 1000.0;
  g_pd3dDevice.SetLight(0, light);
  g_pd3dDevice.LightEnable(0, true);
  light.Direction.x:=-light.direction.x;
  light.Diffuse.r  := 0.15;
  light.Diffuse.g  := 0.15;
  light.Diffuse.b  := 0.25;
  light.Diffuse.a := 1;
  g_pd3dDevice.SetLight(1, light);
  g_pd3dDevice.LightEnable(1, true);   //}

  undebug_memory1;
  g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iTrue);
  // Finally, turn on some ambient light.
  //if (halal=0) or (halal>1.5) then
  g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $FF202020);
end;


procedure SetupFegyvlights(lit:integer);
 var
  vecDir: TD3DXVector3;
  light: TD3DLight9;
  v:single;
begin
  v:=lit/10;
  ZeroMemory(@light, SizeOf(TD3DLight9));
  light._Type      := D3DLIGHT_DIRECTIONAL;
  light.Diffuse.r  := lerp(0.15,1.0,v);
  light.Diffuse.g  := lerp(0.15,1.0,v);
  light.Diffuse.b  := lerp(0.25,0.9,v);
  light.Diffuse.a := 1;
  vecDir:= D3DXVector3(1,-1.0,0);
  D3DXVec3Normalize(light.Direction, vecDir);
  light.Range := 1000.0;
  g_pd3dDevice.SetLight(0, light);
  g_pd3dDevice.LightEnable(0, true);
end;
         

procedure addrongybaba(apos,vpos,gmbvec:TD3DXVector3;fegyv,mlgmb:byte;ID:cardinal;kimiatt:integer);
var
szin:cardinal;
mv2:TD3DMatrix;
begin
// apos.y:=apos.y+0.5;

 if ID=0 then
 begin
  multisc.Killed(kimiatt);
  multip2p.Killed(apos,vpos,szogx,mstat,animstat,mlgmb,gmbvec,kimiatt);
 end;
 
 if rbszam>=20 then exit;
 inc(rbszam);

 mv2:=mat_world;
 mv2._42:=mv2._42+0.1;
 //rongybabak[rbszam]:=nil;
 if fegyv>127 then szin:=$FF000040 else szin:=$FF000000;
  rongybabak[rbszam]:=TRongybaba.Create(mat_world,muks,apos,vpos,gmbvec,mlgmb,ID,szin);

 playsound(9+halalhorg,false,timegettime+random(10000),true,rongybabak[rbszam].gmbk[10]);
 halalhorg:=(halalhorg+1) mod 3;
end;

function getrongybababyID(ID:cardinal):integer;
var
i:integer;
ido2:cardinal;
begin
 result:=-1;
 ido2:=100000;
 for i:=0 to rbszam do
  if rongybabak[i].ID=ID then
  if rongybabak[i].ido<ido2 then
  begin
   ido2:=rongybabak[i].ido;
   result:=i;
  end;
end;

procedure delrongybaba(mit:integer);
var
i:integer;
mlk,tmp:single;
nezvec,camvec,tvec:TD3DXVector3;
trb:Trongybaba;
begin
 if rbszam=-1 then exit;
 if (mit<-1) or (mit>rbszam) then exit;
{ begin
  mido:=0;
  mit:=-1;
  for i:=0 to rbszam do
   if mido<rongybabak[i].ido then
   begin
    mit:=i;
    mido:=rongybabak[i].ido;
   end;
  if mit<0 then exit;
 end; }

 if mit=-1 then
 begin
  camvec:=D3DXVector3(cpx^,cpy^,cpz^);
  nezvec:=D3DXVector3(sin(szogx)*cos(szogy),sin(szogy),cos(szogx)*cos(szogy));

  d3dxvec3subtract(tvec,camvec,rongybabak[0].gmbk[0]);
  //mlk:=d3dxvec3length(tvec){/d3dxvec3dot(nezvec,tvec)};
//  if mlk<0 then mlk:=-mlk*5;
  mlk:=0;
  mlk:=mlk+rongybabak[0].ido*200;
  //if rongybabak[0].disabled and (rongybabak[0].ido>300) then mlk:=mlk+10000;

  for i:=1 to rbszam do
  begin
   d3dxvec3subtract(tvec,camvec,rongybabak[i].gmbk[0]);
   //tmp:= d3dxvec3length(tvec){/d3dxvec3dot(nezvec,tvec)};
   //if tmp<0 then tmp:=-tmp*5;
   tmp:=0;
   tmp:=tmp+rongybabak[i].ido*200;
   //if rongybabak[i].disabled and (rongybabak[i].ido>300) then tmp:=tmp+10000;
   if tmp>mlk then
   begin
    trb:=rongybabak[i];
    rongybabak[i]:=rongybabak[0];
    rongybabak[0]:=trb;
    mlk:=tmp;
   end;
  end;
  mit:=0;
 end;

 rongybabak[mit].Destroy;
 rongybabak[mit]:=nil;
 for i:=mit to rbszam do
  rongybabak[i]:=rongybabak[i+1];
 dec(rbszam);
end;


function raytestlvl(v1,v2:TD3DXVector3;hany:integer;var v3:TD3DXVector3):boolean;
var
k:integer;
v4:TD3DXVector3;
begin
 v4:=v1;
 for k:=0 to hany do
  begin
   v3:=v4;
   d3dxvec3lerp(v4,v1,v2,k/(hany+1));
   try
   if advwove(v4.x,v4.z)>v4.y then
   begin
    result:=true;exit;
    v3:=v4;
   end;
   except
    v3:=v2; result:=false; exit;
   end;
  end;
 result:=false;
end;


procedure lojjegyet;
var
tmp:TD3DXVector3;
hollo,v2,v1:TD3DXVector3;
j,k:integer;
{$IFDEF palyszerk}
torl:integer;
{$ENDIF}
begin
//   if invulntim>0 then exit;


   //hollo:=D3DXVector3(0,3,0); ///BVÁÁÁÁÁÁ

    hollo:=D3DXVector3(0,-0.10,0);
    if myfegyv=FEGYV_QUAD then hollo.y:=0;

    v1:=D3DXvector3zero;

     D3DXVec3add(v2   ,hollo,D3DxVector3(0,0,-300));

    D3DXVec3add(hollo,hollo,D3DxVector3(0,0,-0.7));



   d3dxvec3transformcoord(hollo,hollo,mfm);
   d3dxvec3transformcoord(v2,v2,mfm);
   d3dxvec3transformcoord(v1,v1,mfm);
   d3dxvec3subtract(tmp,v2,hollo);
   d3dxvec3scale(tmp,tmp,1/3000);



  for k:=0 to high(ojjektumnevek) do
   for j:=0 to ojjektumarr[k].hvszam-1 do
   begin
    if ojjektumarr[k].raytestbol(v1,hollo,j) then exit;
   end;

  if intlinesphere(hollo,v2,DNSVec,DNSrad*0.9,v1) then
  begin
   v2:=v1;

  end;

  {$IFDEF palyszerk}
  torl:=-1;
  {$ENDIF}
  for k:=0 to high(ojjektumnevek) do
  begin
  {$IFDEF palyszerk}
   torl:=-1;
   {$ENDIF}
   for j:=0 to ojjektumarr[k].hvszam-1 do
   begin
    tmp:=v2;
    v2:=ojjektumarr[k].raytest(hollo,v2,j);
    {$IFDEF palyszerk}
   if tavpointpointsq(tmp,v2)>0.1 then
     torl:=j;
     {$ENDIF}
   end;


  {$IFDEF palyszerk}
  if torl>=0 then
  begin
   ojjektumarr[k].minuszegy(torl);
   saveojjektumini('ujjektumok.ini');
  end;
  {$ENDIF}
  end;

  if raytestlvl(hollo,v2,500,tmp) then
  begin
   v2:=tmp;
   {$IFDEF palyszerk}
   if epuletmost<0 then
   begin
   // bunker.pluszegy(v2);
   // bunker.savehv('data\bunker4.pos');
   end
   else
   begin
    ojjektumarr[epuletmost].pluszegy(v2);
    saveojjektumini('ujjektumok.ini');
   end;
   {$ENDIF}
  end;

  {$IFDEF palyszerk}
   remaketerrain;
  {$ENDIF}

  {$IFDEF palyszerk}
   ojjektumrenderer.Destroy;
   ojjektumrenderer:=T3DORenderer.Create(G_pd3ddevice);
  {$ENDIF}


  {$IFDEF AIparancsok}
  if aimode>1 then
  begin
   setlength(AIplrs,length(AIplrs)+1);
   AIplrs[high(AIplrs)]:=TAIplr.Create(v2,random(2));
   if random(20)=0 then AIplrs[high(AIplrs)].fegyv:=2;
   if aimode=3 then
   inc(AIplrs[high(AIplrs)].fegyv,128);
   if AIplrs[high(AIplrs)].fegyv=FEGYV_X72 then AIplrs[high(AIplrs)].fegyv:=FEGYV_MPG;

   AIplrs[high(AIplrs)].halal:=0;
   if random(2)>0 then
    inc(AIplrs[high(AIplrs)].state,MSTAT_CSIPO);
  // if random(2)>0 then inc(AIplrs[high(AIplrs)].state,MSTAT_GUGGOL);
   AIplrs[high(AIplrs)].fegyv:=FEGYV_QUAD;
  // AIplrs[high(AIplrs)].fejcucc:=5;


   setlength(Aitaroltpos,length(AIplrs));
   AItaroltpos[high(AIplrs)]:=v2;
  end;
  {$ENDIF}
  
  multip2p.Loves(hollo,v2,myfegyv);
end;

procedure lojjranged;
var
k,j:integer;
hollo,v2,v1:TD3DXVector3;
begin
//  if invulntim>0 then exit;
  
  setupmyfegyvmatr;
  if myfegyv=FEGYV_NOOB then
   hollo:=D3DXVector3(0,-0.2,-0.5)
  else
  if myfegyv=FEGYV_X72 then
   hollo:=D3DXVector3((random(100)-50)/200,-0.2,-0.4)
  else          
   hollo:=D3DXVector3(0,-0.05,-0.7);

   v2:=hollo;

   if myfegyv=FEGYV_LAW then
    D3DXVec3add(hollo,hollo,D3DxVector3(0,0.0,-0.04))
   else
   if myfegyv=FEGYV_X72 then
    D3DXVec3add(hollo,hollo,D3DxVector3(0,0,-1.2))
   else
    D3DXVec3add(hollo,hollo,D3DxVector3(0,0.0,-0.04));


   d3dxvec3transformcoord(hollo,hollo,mfm);
   d3dxvec3transformcoord(v2,v2,mfm);
   d3dxvec3transformcoord(v1,d3dxvector3zero,mfm);
   for k:=0 to high(ojjektumnevek) do
   for j:=0 to ojjektumarr[k].hvszam-1 do
   begin
    if ojjektumarr[k].raytestbol(v1,hollo,j) then exit;
   end;

  {$IFDEF Armageddon}
  hollo:=D3DXVector3(cpx^,cpy^+100,cpz^);
  randomplus(hollo,animstat*200,200);
  v2:=D3DXVector3(random(100)-50,random(100)-200,random(100)-50);
  fastvec3normalize(v2);
  d3dxvec3scale(v2,v2,0.1);
  d3dxvec3subtract(v2,hollo,v2);
  {$ENDIF}

  multip2p.Loves(hollo,v2,myfegyv);
  inc(zeneintensity,3000);
end;


function NtQueryInformationProcess(hProcess: THandle;ProcessInformationClass: Integer;Var ProcessInformation;ProcessInformationLength: Integer;ReturnLength: PInteger): Integer; stdcall;external 'ntdll.dll';
procedure undebug_debugobject;
var
 status,hdebugobject:dword;
begin
{$IFDEF undebug}
 hDebugObject:=0;
 Status := NtQueryInformationProcess($ffffffff, 7,hDebugObject, 4, nil);
 if (Status = 0) then
 if(hDebugObject<>0) then {windows féle debug handler}
  setlength(ppl,0);
{$ENDIF}
end;


procedure iranyit;
var
ds,dc:single;
tmp:TD3DXVector3;
px,py,ph:single;
fut:boolean;
label
atugor;
begin

   if iswindowed then
   dine.Update(point(400,400))
  else
   dine.update(point(400,400));

  iranyithato:= iranyithato and (mapmode=0);

  if ((dine.mouss.rgbButtons[0] and $80)=$80) then chatmost:='';
  if length(chatmost)>0 then zeromemory(addr(dine.keys),sizeof(dine.keys));


  //Új irányítás kód
  ds:=sin(szogx);
  dc:=cos(szogx);
  px:=0; py:=0;


  gugg:=dine.keyd(DIK_LCONTROL) and (halal=0) and iranyithato;
  if (myfegyv=FEGYV_QUAD) and (not csipo) then iranyithato:=false;
  fut:= dine.keyd(DIK_W) and (not dine.keyd(DIK_LSHIFT)) and (vizben<0.5) and iranyithato and csipo and (not gugg) and (halal=0);

  mstat:=MSTAT_ALL;
  if dine.keyd(DIK_D) and not dine.keyd(DIK_A) then begin px:=px+dc*0.02; py:=py-ds*0.02; mstat:=MSTAT_BALRA end;
  if dine.keyd(DIK_A) and not dine.keyd(DIK_D) then begin px:=px-dc*0.02; py:=py+ds*0.02; mstat:=MSTAT_JOBBRA end;
  if dine.keyd(DIK_S) and not dine.keyd(DIK_W) then begin px:=px-ds*0.02; py:=py-dc*0.02; mstat:=MSTAT_HATRA end;
  if dine.keyd(DIK_W) then
   if fut then begin px:=px+ds*0.06; py:=py+dc*0.06; mstat:=MSTAT_FUT end
          else begin px:=px+ds*0.02; py:=py+dc*0.02; mstat:=MSTAT_ELORE end;
  ph:=sqrt(sqr(px)+sqr(py));

  if ph>0 then
   if fut then begin px:=px*0.06/ph; py:=py*0.06/ph; end
          else begin px:=px*0.02/ph; py:=py*0.02/ph; end;
  if gugg then begin px:=px/3; py:=py/3; mstat:=mstat+MSTAT_GUGGOL; end;
  {$IFDEF speedhack}
      px:=px*4; py:=py*4;
      {$ENDIF}
  if csipo then mstat:=mstat+MSTAT_CSIPO;
  if (halal>0) then mstat:=0;

  {$IFDEF repkedomod}
  mstat:=0;
  {$ENDIF}

  if not iranyithato then
    begin
     px:=px*0.02;
     py:=py*0.02;
      mstat:=0;
     undebug_debugobject;
    end;
  cpx^:=cpx^+px;
  cpz^:=cpz^+py;
  {$IFNDEF repkedomod}
  if (iranyithato) and (length(chatmost)=0) and (halal=0) then
  begin
   if dine.keyd2(DIK_SPACE) and not gugg then
    begin
      cpox^:=cpox^+0.3*(cpx^-cpox^);
      cpoz^:=cpoz^+0.3*(cpz^-cpoz^);
      cpy^:=cpy^+0.11;
      cpoy^:=cpy^-0.09;
      {$IFDEF speedhack}
      cpoy^:=cpy^-0.7;
      {$ENDIF}
    end;
  end;

  {$ELSE}
   if dine.keyd(DIK_SPACE)then
    begin
      cpy^:=cpy^+0.31;
    end;
    gugg:=false;
   if dine.keyd(DIK_LCONTROL)then
    begin
      cpy^:=cpy^-0.31;
    end;
  {$ENDIF}
  if (length(chatmost)=0) and autoban then
  begin
    tegla.iranyit(dine.keyd(DIK_W),dine.keyd(DIK_S),dine.keyd(DIK_D),dine.keyd(DIK_A),true);
    if (tegla.axes[2].y<0) and dine.keyd(DIK_R) then
     recovercar:=1;
  end
   else
    tegla.iranyit(false,false,false,false,false);

  if iranyithato then
   if dine.keyd(DIK_W) or dine.keyd(DIK_SPACE) or dine.keyd(DIK_S) or
      dine.keyd(DIK_A) or dine.keyd(DIK_D) then
       multisc.killscamping:=multisc.kills;

  if dine.keyd(DIK_F) and (not autoban) {$IFNDEF speedhack} and (bunkerkozelben){$ENDIF}and (halal=0)  and (length(chatmost)=0) then
  begin
   tegla.destroy; autoban:=true;
   cpox^:=cpx^; cpoz^:=cpz^; cpoy^:=cpy^;
   {$IFNDEF speedhack}
   d3dxvec3add(tmp,ojjektumarr[0].holvannak[melyikbunkerkozelben],d3dxvector3(0,4,-8));
   tmp.y:=advwove(tmp.x,tmp.z)+2;
   {$ELSE}
   d3dxvec3add(tmp,d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(0,4,0));
   {$ENDIF}

   if myfegyv<128 then
    tegla:=Tauto.create(d3dxvector3(2.3,0,0),d3dxvector3(0,0,-1.3),d3dxvector3(0,-0.7,0),tmp,d3dxvector3zero,0.2,0.5,hummkerekarr,0.7,0.5,0.2,false)
   else
    tegla:=Tauto.create(d3dxvector3(1.8,0,0),d3dxvector3(0,0,-1.5),d3dxvector3(0,-0.9,0),tmp,d3dxvector3zero,0.2,0.99,agkerekarr,0.7,0.5,0.2,true);
   
  end;

  if  dine.keyd(DIK_F) and (not autoban) and (tavpointpointsq(tegla.pos,d3dxvector3(cpx^,cpy^,cpz^))<5*5) and (halal=0) then
  autoban:=true;
  

  if dine.keyd(DIK_ESCAPE) then
  begin
   gobacktomenu:=true;
  end;


  while cpz^>((cmz+1)*pow2[lvlmin]) do
   stepf;
  while cpz^<((cmz)*pow2[lvlmin]) do
   stepb;
  while cpx^>((cmx+1)*pow2[lvlmin]) do
   stepr;
  while cpx^<((cmx)*pow2[lvlmin]) do
   stepl;

  if not autoban then
  begin
   if (myfegyv=FEGYV_QUAD) and csipo then
    if (dine.mouss.rgbButtons[0] and $80)=$80 then
       dine.mouss.rgbButtons[1]:=dine.mouss.rgbButtons[1] or $80;

   if (myfegyv=FEGYV_QUAD) and (not csipo) then
     if dine.keyd(DIK_W) or dine.keyd(DIK_A) or dine.keyd(DIK_S) or dine.keyd(DIK_D) or dine.keyd(DIK_SPACE) then
       dine.mouss.rgbButtons[1]:=dine.mouss.rgbButtons[1] or $80;
  end;
  
  if (((dine.mouss.rgbButtons[1] and $80)=$80) or dine.keyd(DIK_Q)) and rblv  then
  begin
   csipo:=not csipo;
   if myfegyv=FEGYV_QUAD then cooldown:=1;
   if csipo then
   begin
    mszogx:=szogx-pi/10;
    mszogy:=szogy+pi/10;
   end
   else
   begin
    mszogx:=szogx+pi/30;
    mszogy:=szogy-pi/30;
   end;
  end;
  rblv:=((dine.mouss.rgbButtons[1] and $80)=0) and (not dine.keyd(DIK_Q));

  if dine.keyprsd(DIK_Q) then
  begin
   inc(epuletmost);
    if epuletmost>high(ojjektumnevek) then epuletmost:=-1;
  end;

  if dine.keyprsd(DIK_E) then
  begin
   dec(epuletmost);
   if epuletmost<-1 then epuletmost:=high(ojjektumnevek);
  end;

  if autoban then
    csipo:=true;

  if autoban and (dine.MousMovScrl>0) then
   begin
    mp3strmpvalts:=true;
    if mp3strmp[mp3strmp2]<high(mp3strms[mp3strmp2]) then
     inc(mp3strmp[mp3strmp2])
    else
     mp3strmp[mp3strmp2]:=0;
   end;

   if autoban and (dine.MousMovScrl<0) then
   begin
    mp3strmpvalts:=true;
    if mp3strmp[mp3strmp2]>0 then
     dec(mp3strmp[mp3strmp2])
    else
     mp3strmp[mp3strmp2]:=high(mp3strms[mp3strmp2]);
   end;

  if not (currevent is TReactorEvent) then
  if myfegyv=FEGYV_NOOB then
  begin

   if ((dine.mouss.rgbButtons[0] and $80)=$80) and (cooldown<0) and (halal=0) and (mapmode=0)then
   begin

    if autoban then
    begin
     if kiszallas=0 then

     kiszallas:=1;
     lovok:=0;

     goto atugor;
    end;

    if nemlohet then
    begin
     lovok:=0;
     kitlottemle:='';
     latszonaKL:=200;
     goto atugor;
    end;
    {$IFNDEF Armageddon}

    lovok:=lovok+0.01;
    if lovok>=0.99 then
    begin
     lojjranged;
     cooldown:=1.5;
     szogX:=szogx+(100-random(200))/4000;
     szogY:=szogy+(100-random(200))/400;
     inc(zeneintensity,round(4000));
    end;
    {$ELSE}
     lojjranged;
     cooldown:=0.2;
    {$ENDIF}
   end
   else
   lovok:=0;
  end
  else
  begin
   if (((dine.mouss.rgbButtons[0] and $80)=$80)) and (cooldown<0) and (halal=0) and (mapmode=0)then
   if not((myfegyv=FEGYV_QUAD)and csipo) or autoban then
   begin
    if autoban then
    begin
     if kiszallas=0 then

     kiszallas:=1;
     goto atugor;
    end;

    if nemlohet then
    begin
     kitlottemle:=lang[64];
     latszonaKL:=200;
     goto atugor;
    end;
    //fegyv.addproj(FEGYV_M4A1,hollo,v2,M4_Golyoido);
    if myfegyv<>FEGYV_LAW then
     if myfegyv=FEGYV_X72 then
      lojjranged
     else
      lojjegyet;

    if myfegyv=FEGYV_MP5A3 then mp5ptl:=mp5ptl+1;
    if myfegyv=FEGYV_X72 then x72gyrs:=x72gyrs+1/8;

    case myfegyv of
     FEGYV_M4A1:begin lovok:=0.5; cooldown:=1/8; end;
     FEGYV_M82A1:begin lovok:=1; cooldown:=1/1.5;  end;
     FEGYV_MPG:begin lovok:=0; cooldown:=1/1.5; end;
     FEGYV_quad:begin lovok:=1; cooldown:=1/8; end;
     {$IFNDEF Armageddon}
     FEGYV_LAW:begin
                LAWkesleltetes:=75;
                rezg:=2;
                lovok:=0.5;
                cooldown:=3;
                playsound(26,false,1,true,D3DXVector3(campos.x+cos(szogx),campos.y,campos.z-sin(szogx)));
                setsoundproperties(26,1,1,1,true,D3DXVector3(campos.x+cos(szogx),campos.y,campos.z-sin(szogx)));
               end;
     {$ELSE}
     FEGYV_LAW:begin LAWkesleltetes:=5;lovok:=0.5; cooldown:=0.2; end;
     {$ENDIF}
     FEGYV_X72:begin lovok:=1; cooldown:=max(x72gyrs-0.5,1/6) end;
     FEGYV_Mp5a3:begin lovok:=0.5; cooldown:=1/8; end;
    end;

    if myfegyv<>FEGYV_LAW then
    inc(zeneintensity,round(3000*cooldown));

    if myfegyv=FEGYV_QUAD then
    begin
      szogX:=szogx+(100-random(200))/40000;
      szogY:=szogy+(100-random(200))/40000;
      mszogX:=mszogx+(100-random(200))/20000;
      mszogY:=mszogy+(100-random(200))/20000;
    end;
    {$IFNDEF Armageddon}
    if myfegyv<>FEGYV_LAW then
    begin
     if myfegyv=FEGYV_M82A1 then
     if csipo then
      begin
       szogX:=szogx+(100-random(200))/500;
       szogY:=szogy+(100-random(200))/500;

       end
      else
      begin
       mszogX:=mszogx+(100-random(200))/200;
        mszogY:=mszogy+(100-random(200))/200;
       //szogX:=szogx+(100-random(200))/5000;
      // szogY:=szogy+(100-random(200))/5000;
      end;

     if myfegyv=FEGYV_MP5A3 then
     if csipo then
      begin
       szogX:=szogx+(100-random(200))/5000;
       szogY:=szogy+(100-random(200))/5000;
       mszogX:=mszogx+(100-random(200))/2000;
       mszogY:=mszogy+(100-random(200))/2000;
       end
      else
      begin
       mszogX:=mszogx+(100-random(200))*mp5ptl*mp5ptl/50000;
       mszogY:=mszogy+(100-random(200))*mp5ptl*mp5ptl/50000;
       szogX:=szogx+(100-random(200))*mp5ptl*mp5ptl/100000;
       szogY:=szogy+(100-random(200))*mp5ptl*mp5ptl/100000;
      end;

     if myfegyv=FEGYV_M4A1 then
      if csipo then
      begin
       szogX:=szogx+(100-random(200))/5000;
       szogY:=szogy+(100-random(200))/5000;
      end
      else
       if gugg then
       begin
        szogX:=szogx+(100-random(200))/20000;
        szogY:=szogy+(100-random(200))/20000;
       end
       else
       begin
        szogX:=szogx+(100-random(200))/7000;
        szogY:=szogy+(100-random(200))/7000;
       end;


      if myfegyv=FEGYV_X72 then
      if csipo then
      begin
       MszogX:=Mszogx+(100-random(200))/500;
       MszogY:=mszogy+(100-random(200))/500;

       end
       else
       begin
       szogX:=szogx+(100-random(200))/5000;
        szogY:=szogy+(100-random(200))/5000;
       //szogX:=szogx+(100-random(200))/5000;
      // szogY:=szogy+(100-random(200))/5000;
      end;
     

     end;

     {$ENDIF}
   end;
  end;

  dec(LAWkesleltetes);
  if Not ((halal=0) and (not nemlohet)) or (LAWkesleltetes<0) or autoban then LAWkesleltetes:=-1;
  if LAWkesleltetes=0 then
  begin
   lojjranged;
   szogX:=szogx+(100-random(200))/500;
   szogY:=szogy+(100-random(200))/500-0.2;
  end;

  atugor:
  dine.MouseSensitivity:=mousesens;
  dine.MouseAcceleration:=mouseacc;
  if (not csipo) and (halal=0) then
  begin
    if myfegyv=FEGYV_M82A1 then
    begin
     szogx:=szogx+dine.MousMovX/3000;
     szogy:=szogy-dine.MousMovy/3000;
    end
    else
    begin
     szogx:=szogx+dine.MousMovX/1000;
     szogy:=szogy-dine.MousMovy/1000;
    end
  end
  else
  begin
   szogx:=szogx+dine.MousMovX/200;
   szogy:=szogy-dine.MousMovy/200;
  end;
  if szogy>maxszog then szogy:=maxszog;
  if szogy<(-maxszog) then szogy:=-maxszog;
 
  if (halal>0) then
   if szogy>0 then szogy:=0;
  if szogx>D3DX_PI then szogx:=szogx-2*D3DX_PI;
  if szogx<-D3DX_PI then szogx:=szogx+2*D3DX_PI;


end;


procedure dokerektests;
var
i,j,l:integer;
ide:TD3DXVector3;

begin
 with tegla do
 begin
  if disabled then exit;
  initkerekek;


  for i:=0 to 3 do
  begin
   NONANINF(kerekek[i]);
   rays[i*2]:=kerekorig[i];
   rays[i*2+1]:=kerekek[i];
  end;



  for i:=0 to 3 do
  begin
   ide:=kerekek[i];
   if raytestlvl(kerekorig[i],kerekek[i],20,ide) then
   begin
    kerekbol[i]:=true;
    kerekek[i]:=ide;
    flipcount:=0;
   end
   else
     kerekbol[i]:=false;
  end;



   for l:=0 to high(ojjektumnevek) do
   for j:=0 to ojjektumarr[l].hvszam-1 do
   if tavpointpointsq(pos,ojjektumarr[l].holvannak[j])<sqr(ojjektumarr[l].rad+10) then
    for i:=0 to 3 do
    begin
     ide:=ojjektumarr[l].raytest(kerekorig[i],kerekek[i],j);
     if tavpointpointsq(ide,kerekek[i])>0.001 then
     begin
      kerekbol[i]:=true;
      kerekek[i]:=ide;
      flipcount:=0;
     end;

    end;
  for i:=0 to 3 do
   NONANINF(kerekek[i]);
  usekerekek;
 end;
end;


function felrobbanva(gmbk:Tgmbk;kapcsk:Tkapcsk;hol,honnan:Td3DVector;siz1,siz2:single):integer;
var
i,j,l:integer;
talalat:array [0..9] of boolean;
vec:TD3DXVector3;
begin
 result:=-1;

 if hol.y>200 then
 begin
  if tavpointpointsq(hol,honnan)>sqr(siz1+1) then exit;
 end
 else
 begin
  if tavpointpointsq(hol,honnan)>sqr(siz2+1) then exit;
 end;

 D3DXVec3TransformCoordArray(@gmbk[0],sizeof(gmbk[0]),@gmbk[0],sizeof(gmbk[0]),mat_World,11);

 for i:=0 to 9 do talalat[i]:=true;


   for l:=0 to high(ojjektumnevek) do
   for j:=0 to ojjektumarr[l].hvszam-1 do
   begin
    D3dxvec3add(vec,ojjektumarr[l].holvannak[j],ojjektumarr[l].vce);
    if tavpointpointsq(honnan,vec)<sqr(ojjektumarr[l].rad+siz2) then
     for i:=0 to 9 do
      if ojjektumarr[l].raytestbol(gmbk[i],hol,j) then talalat[i]:=false;
    end;

 for i:=0 to 9 do
  if talalat[i] then result:=i;

end;


{function handlepajzsok(p1,p2:TD3DXVector3;mennyitvesz:integer):boolean;
const
r=1;
var
dp,sc,ep:TD3DXVector3;
a,b,c,cp,bb4ac,a2:single;
i,j,k:integer;
mu1,mu2:single;
ap,eap:TD3DXVector3;
begin

  result:=false;
  constraintvec(p1);
  constraintvec(p2);
   dp.x := p2.x - p1.x;
   dp.y := p2.y - p1.y;
   dp.z := p2.z - p1.z;
   a := dp.x * dp.x + dp.y * dp.y + dp.z * dp.z;
   a2:=0.5/a;
   cp := p1.x * p1.x + p1.y * p1.y + p1.z * p1.z;
   cp := cp - r * r;



   for i:=0 to pplhgh do
   begin
    if pplpls[i].fegyv<>FEGYV_FLAMETHROWER then continue;
    if pplpos[i].pos.y>200 then continue;
    if tavpointpointsq(pplpos[i].pos,campos)>sqr(100) then continue;
    if pplpls[i].vtim<=1 then pplpls[i].vtim:=10000;
    sc:=pplpls[i].megjpos;
    sc.y:=sc.y+0.8;
    c := sc.x * sc.x + sc.y * sc.y + sc.z * sc.z;
    c := c+cp-2 * (sc.x * p1.x + sc.y * p1.y + sc.z * p1.z);
    b := 2 * (dp.x * (p1.x - sc.x) + dp.y * (p1.y - sc.y) + dp.z * (p1.z - sc.z));

    bb4ac := b * b - 4 * a * c;
    if ((ABS(a) < 0.001) or  (bb4ac < 0)) then
     continue;

    bb4ac:=sqrt(bb4ac);

    //mu1 := (-b + bb4ac) * a;
    mu2 := (-b - bb4ac) * a2;
    if mu2>0 then
     d3dxvec3lerp(ep,p1,p2,mu2)
    else continue;

    for k:=0 to 3 do
    begin
     ap:=ep;
     for j:=0 to 5 do
     begin
      eap:=ap;

      randomplus(ap,animstat+j+k*100,1);
      d3dxvec3subtract(ap,ap,sc);
      fastvec3normalize(ap);
      d3dxvec3add(ap,ap,sc);

      Particlesystem_add(fenycsikcreate(eap,ap,0.03,$FFFFFF00,100-j*10));
     end;
    end;

     setlength(explosionbubbles,length(explosionbubbles)+1);
     with explosionbubbles[high(explosionbubbles)] do
     begin
      pos:=sc;
      meret:=0.8; meretpls:=0.01;
      erosseg:=1; erossegpls:=-1/20;
      meretplsszor:=0.95;
      tim:=20;
     end;
   end;
    if (myfegyv<>FEGYV_FLAMETHROWER) or (halal>0) then exit;

    sc.x:=cpx^;
    sc.z:=cpz^;
    sc.y:=cpy^+0.8;
    c := sc.x * sc.x + sc.y * sc.y + sc.z * sc.z;
    c := c+cp-2 * (sc.x * p1.x + sc.y * p1.y + sc.z * p1.z);
    b := 2 * (dp.x * (p1.x - sc.x) + dp.y * (p1.y - sc.y) + dp.z * (p1.z - sc.z));

    bb4ac := b * b - 4 * a * c;
    if ((ABS(a) < 0.001) or  (bb4ac < 0)) then
     exit;

    bb4ac:=sqrt(bb4ac);
    //mu1 := (-b + bb4ac) * a;
    mu2 := (-b - bb4ac) * a2;
    if mu2>0 then
     d3dxvec3lerp(ep,p1,p2,mu2)
    else exit;



    playsound(24,false,timegettime+random(10000),true,ep) ;
    for k:=0 to 3 do
    begin
     ap:=ep;
     for j:=0 to 5 do
     begin
      eap:=ap;

      randomplus(ap,animstat+j+k*100,1);
      d3dxvec3subtract(ap,ap,sc);
      fastvec3normalize(ap);
     // d3dxvec3scale(ap,ap,1);
      d3dxvec3add(ap,ap,sc);

      Particlesystem_add(fenycsikcreate(eap,ap,0.03,$FFFFFF00,100-j*10));
     end;
    end;

   if  (energy>mennyitvesz) then
    energy:=energy-mennyitvesz
   else
    energy:=0;
end;}



procedure handlerobbanas(hol:TD3DXVector3;kilotte:integer;lovesfegyv:byte;x72eletkor:single);
var
love:integer;
tmp:TD3DXVector3;
begin

  SetupMyMuksmatr;
  love:=-1;

  if (kilotte=-1) or ((lovesfegyv xor myfegyv)>=128) then
  case lovesfegyv of
   FEGYV_LAW :love:=felrobbanva(muks.gmbk,muks.kapcsk,hol,D3DXVector3(cpx^,cpy^,cpz^),3,4);
   FEGYV_NOOB:love:=felrobbanva(muks.gmbk,muks.kapcsk,hol,D3DXVector3(cpx^,cpy^,cpz^),3,5);
   FEGYV_X72:love:=felrobbanva(muks.gmbk,muks.kapcsk,hol,D3DXVector3(cpx^,cpy^,cpz^),x72eletkor/200+0.5,x72eletkor/200+0.5);
  end;                                                                   

  {$IFNDEF godmode}
  if invulntim=0 then
  if love>=0 then
  if halal=0 then
  begin

   halal:=1;
  // setupmymuksmatr;
   d3dxvec3subtract(tmp,D3DXVector3(cpx^,cpy^+1,cpz^),hol);

   fastvec3normalize(tmp);

   constraintvec(tmp);

   suicidevolt:=800;
   addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),tmp,myfegyv,love,0,kilotte);
  end;
  {$ENDIF}

end;

procedure explosionripple(hol:TD3DXVector3;nagy:boolean);
var
 t:TD3DXVector3;
 k,j:integer;
 ap,eap:TD3DXVector3;
 r2:single;
begin
  if not nagy then
   if tavpointpointsq(hol,campos)>sqr(50) then exit;
  setlength(explosionripples,length(explosionripples)+1);
   with explosionripples[high(explosionripples)] do
   begin
    pos:=hol;
    d3dxvec3subtract(t,hol,DNSvec);
    d3dxvec3cross(vsz,t,D3DXVector3(0,1,0));
    d3dxvec3cross(hsz,t,vsz);
    fastvec3normalize(vsz);
    fastvec3normalize(hsz);
    meret:=0;
    if nagy then
    meretpls:=0.5
    else
    meretpls:=0.1;

    if nagy then
     erosseg:=5
    else
     erosseg:=2;


    meretplsszor:=0.95;
    if nagy then
     tim:=100
    else
     tim:=40;
    erossegpls:=-erosseg/tim;
   end;

   r2:=tavpointpoint(hol,DNSVec);
  if nagy then
  for k:=0 to 3 do
    begin
     ap:=hol;
     for j:=0 to 10 do
     begin
      eap:=ap;

      randomplus(ap,animstat+j+k*100,10);
      d3dxvec3subtract(ap,ap,DNSVec);
      d3dxvec3scale(ap,ap,fastinvsqrt(d3dxvec3lengthsq(ap))*r2);
      d3dxvec3add(ap,ap,DNSvec);

      Particlesystem_add(fenycsik3create(eap,ap,0.5,$FFFFFF00,j*10+50,50));
     end;
    end
  else
  for k:=0 to 3 do
    begin
     ap:=hol;
     for j:=0 to 5 do
     begin
      eap:=ap;

      randomplus(ap,animstat+j+k*100,2);
      d3dxvec3subtract(ap,ap,DNSVec);
      d3dxvec3scale(ap,ap,fastinvsqrt(d3dxvec3lengthsq(ap))*r2);
      d3dxvec3add(ap,ap,DNSvec);

      Particlesystem_add(fenycsik3create(eap,ap,0.03,$FFFFFF00,j*10+20,20));
     end;
    end;
end;

procedure undebug_peb;
asm
 MOV eax,FS:[$30]
 ADD eax,2
 MOV EAX,[EAX]
 AND EAX,$ff
 XOR EAX,123
 jz @josag
 MOV EAX,1000000
 MOV mapmode,EAX
 //büntetés

 @josag:
end;

procedure undebug_registers;
var
 cont:Tcontext;
begin
{$IFDEF undebug}
 zeromemory(@cont,sizeof(cont));
 cont.ContextFlags:=CONTEXT_DEBUG_REGISTERS;
 getthreadcontext(getcurrentthread,cont);
 if (cont.Dr7<>0) then
    cpx^:=100000;
 {$ENDIF}
end;

procedure DoLAWRobbanas(mi:integer;rippl:boolean);
var
 t:TD3DXVector3;
 i:integer;
 alngt:single;
 avec:TD3DXVector3;
 col:cardinal;
begin
 for i:=0 to 100 do
 begin
  t:=lawproj[mi].v3;
  randomplus(t,animstat+i,15);
  Particlesystem_add(Bulletcreate(lawproj[mi].v3,t,10,10,0.03,$00A0A050,0));
 end;

 for i:=0 to 100 do
 begin
  t:=lawproj[mi].v3;
  randomplus(t,animstat*10+i,7);
  Particlesystem_add(SimpleparticleCreate(t,randomvec(animstat*10+i,0.05),2,0,$0000FFFF,$010000FF,random(20)+20));
 end;
 for i:=0 to 200 do
 begin
  t:=randomvec(animstat*2+i*3,0.5);
  col:=round((-t.x+t.y)*300+120);
  Particlesystem_add(ExpsebparticleCreate(lawproj[mi].v3,t,random(100)/200+1.0,1.0,0.95,$FF000000+$10101*col {(random(50))},$00000000,random(100)+100));
 end;

 alngt:=tavpointpointsq(d3dxvector3(cpx^,cpy^,cpz^),lawproj[mi].v3);
 if alngt<sqr(15) then
 begin
  rezg:=15-sqrt(alngt);
  d3dxvec3subtract(robhely,lawproj[mi].v3,d3dxvector3(cpx^,cpy^,cpz^));
  fastvec3normalize(robhely);

  if myfegyv>=128 then
   inc(zeneintensity,10000);
 end;
  d3dxvec3lerp(avec,lawproj[mi].v3,d3dxvector3(cpx^,cpy^,cpz^),0);
 playsound(17,false,timegettime+random(10000),true,avec);

  if rippl then
   explosionripple(lawproj[mi].v3,true)
  else
  if alngt>sqr(15) then
  begin
   setlength(explosionbubbles,length(explosionbubbles)+1);
   with explosionbubbles[high(explosionbubbles)] do
   begin
    pos:=lawproj[mi].v3;
    meret:=0; meretpls:=0.5;
    erosseg:=2; erossegpls:=-2/50;
    meretplsszor:=0.95;
    tim:=50;
   end;
  end;

 handlerobbanas(lawproj[mi].v3,lawproj[mi].kilotte,FEGYV_LAW,0);
 undebug_registers;
 lawproj[mi]:=lawproj[high(lawproj)];
 setlength(lawproj,high(lawproj));
end;

procedure DoNoobRobbanas(mi:integer;rippl:boolean);
var
 t:TD3DXVector3;
 i,j:integer;
 alngt:single;
 avec:TD3DXVector3;
begin

 for j:=0 to 3 do
  for i:=0 to 50 do
  begin
   t:=randomvec(animstat*2+i/30+j,i/70);
   Particlesystem_add(ExpsebparticleCreate(noobproj[mi].v3,t,0.5,0.5,0.95,$502060FF,$00000000,i+100));
  end;

 for i:=0 to 500 do
 begin
  t:=randomvec(animstat*2+i*3,1);
  fastvec3normalize(t);
  Particlesystem_add(ExpsebparticleCreate(noobproj[mi].v3,t,1.0,1.0,0.8,$502060FF,$00000000,random(50)+20));
 end;

 alngt:=tavpointpointsq(d3dxvector3(cpx^,cpy^,cpz^),noobproj[mi].v3);
 if alngt<sqr(15) then
 begin
  rezg:=15-sqrt(alngt);
  d3dxvec3subtract(robhely,noobproj[mi].v3,d3dxvector3(cpx^,cpy^,cpz^));
    fastvec3normalize(robhely);
  if myfegyv<128 then
   inc(zeneintensity,10000);
 end;
 d3dxvec3lerp(avec,noobproj[mi].v3,d3dxvector3(cpx^,cpy^,cpz^),0);
 playsound(19,false,timegettime+random(10000),true,avec);

 if rippl then
   explosionripple(noobproj[mi].v3,true)
  else
 if alngt>sqr(15) then
 begin
  setlength(explosionbubbles,length(explosionbubbles)+1);
 with explosionbubbles[high(explosionbubbles)] do
 begin
  pos:=noobproj[mi].v3;
  meret:=0; meretpls:=0.5;
  erosseg:=2; erossegpls:=-2/50;
  meretplsszor:=0.95;
  tim:=50;
 end;
 end;
  handlerobbanas(noobproj[mi].v3,noobproj[mi].kilotte,FEGYV_NOOB,0);

 noobproj[mi]:=noobproj[high(noobproj)];
 setlength(noobproj,high(noobproj));
end;

procedure DoX72Robbanas(mi:integer;rippl:boolean);
var
 t:TD3DXVector3;
 i:integer;
 alngt:single;
 avec:TD3DXVector3;
begin

 for i:=0 to 100 do
 begin
  t:=randomvec(animstat*2+i*3,1);
  fastvec3normalize(t);
  d3dxvec3scale(t,t,(x72proj[mi].eletkor/200+1)*0.3);
  Particlesystem_add(ExpsebparticleCreate(x72proj[mi].v3,t,1.0,0,0.75,$FFFFFFFF,$00FF0000,random(50)+20));
 end;

 alngt:=tavpointpointsq(d3dxvector3(cpx^,cpy^,cpz^),x72proj[mi].v3);
 if alngt<sqr(5) then
 begin
  rezg:=5-sqrt(alngt);
  d3dxvec3subtract(robhely,x72proj[mi].v3,d3dxvector3(cpx^,cpy^,cpz^));
  fastvec3normalize(robhely);
  if myfegyv<128 then
   inc(zeneintensity,10000);
 end;
 d3dxvec3lerp(avec,x72proj[mi].v3,d3dxvector3(cpx^,cpy^,cpz^),0);
 playsound(21,false,timegettime+random(10000),true,avec);

 if rippl then
   explosionripple(x72proj[mi].v3,true)
  else
 if alngt>sqr(10) then
 begin
 {setlength(explosionbubbles,length(explosionbubbles)+1);
 with explosionbubbles[high(explosionbubbles)] do
 begin
  pos:=x72proj[mi].v3;
  meret:=0; meretpls:=0.2;
  erosseg:=2; erossegpls:=-2/50;
  meretplsszor:=0.95;
  tim:=50;
 end;}
 end;
  handlerobbanas(x72proj[mi].v3,x72proj[mi].kilotte,FEGYV_X72,x72proj[mi].eletkor);

 x72proj[mi]:=x72proj[high(x72proj)];
 setlength(x72proj,high(x72proj));
end;

procedure DoCollisionTests;
var
 i,j,k,l,m:integer;
 adst,mdst:single;
 cp,ap,kp:TD3DXVector3;
 rbb:array of TAABB;
 tmpbb:TAABB;
 tmpvec:TD3DXVector3;
 miket:TKDData;
 tris:Tacctriarr;
 p2:TD3DXVector3;
 vec1,vec2,vec3,vec4:TD3DXVector3;
 voltc:boolean;
 tulnagylokes:boolean;
label
lawskip,noobskip,x72skip;
begin

 vec2:=D3DXVector3(cpox^,cpoy^+0.8,cpoz^);
 laststate:='Docollisiontests 1';
 cp:=D3DXVector3(cpx^,cpy^*0.5+0.4,cpz^);

 bunkerkozelben:=false;

 tulnagylokes:=false;
 for j:=0 to high(ojjektumnevek) do
 for i:=0 to ojjektumarr[j].hvszam-1 do
 begin
  adst:=ojjektumarr[j].tavtest(cp,0.4,ap,i,true);
  if adst>sqr(0.4) then continue;
  if (j=0) then
  begin
   bunkerkozelben:=true;
   melyikbunkerkozelben:=i;
  end;
  epulethezert:=10;
  adst:=sqrt(adst);

  if 0.4-adst>0.05 then
   tulnagylokes:=true;
  d3dxvec3subtract(kp,ap,cp);
  d3dxvec3scale(kp,kp,1/adst);
  iranyithato:=iranyithato or (kp.y<-0.5);
  d3dxvec3scale(kp,kp,(0.4-adst));
  kp.x:=kp.x*0.5;
  kp.z:=kp.z*0.5;
  d3dxvec3subtract(cp,cp,kp);
 end;
 if tulnagylokes then iranyithato:=false;

 cpx^:=cp.x;cpy^:=cp.y*2-0.8;cpz^:=cp.z;

 laststate:='Docollisiontests 2';
//VONAL TESZT  ÉS ZÓNATESZT
 vec1:=D3DXVector3(cpx^,cpy^+0.8,cpz^);
 if not autoban then
 for l:=0 to high(ojjektumnevek) do
  for j:=0 to ojjektumarr[l].hvszam-1 do
   begin
   D3DXVec3add(vec4,ojjektumarr[l].holvannak[j],ojjektumarr[l].vce);
     if tavpointpointsq(vec1,vec4)<sqr(ojjektumarr[l].rad+1) then
      if ojjektumarr[l].raytestbol(vec1,vec2,j) then
       wentthroughwall:=true;
   end
 else
 for l:=0 to high(ojjektumnevek) do
  for j:=0 to ojjektumarr[l].hvszam-1 do
   begin
   D3DXVec3add(vec4,ojjektumarr[l].holvannak[j],ojjektumarr[l].vce);
     if tavpointpointsq(vec1,vec4)<sqr(ojjektumarr[l].rad+1) then
      if ojjektumarr[l].raytestbol(tegla.pos,tegla.vpos,j) then
       wentthroughwall:=true;
   end;

//RONGYBABAK
  setlength(rbb,length(rongybabak));
  for j:=0 to rbszam do
  begin
   rbb[j].min:=d3dxvector3( 10000, 10000, 10000);
   rbb[j].max:=d3dxvector3(-10000,-10000,-10000);
   with rongybabak[j] do
   for k:=0 to high(gmbk) do
   begin
    d3dxvec3minimize(rbb[j].min,rbb[j].min,gmbk[k]);
    d3dxvec3maximize(rbb[j].max,rbb[j].max,gmbk[k]);
   end;
   d3dxvec3subtract(rbb[j].min,rbb[j].min,d3dxvector3(fejvst,fejvst,fejvst));
   d3dxvec3add     (rbb[j].max,rbb[j].max,d3dxvector3(fejvst,fejvst,fejvst));
  end;

laststate:='Docollisiontests(false) 2';
{ inc(rbm);
 if rbm>rbszam then rbm:=0;
 if rbszam>=0 then }
 for l:=0 to high(ojjektumnevek) do
 for i:=0 to ojjektumarr[l].hvszam-1 do
 begin
 d3dxvec3add(p2,ojjektumarr[l].holvannak[i],ojjektumarr[l].vce);
 for j:=0 to rbszam do
  with rongybabak[j] do
  if tavpointpointsq(gmbk[4],p2)<sqr(ojjektumarr[l].rad+3) then
  begin
   if disabled then continue;

   //TraverseKDTreee
   d3dxvec3subtract(tmpbb.min,rbb[j].min,ojjektumarr[l].holvannak[i]);
   d3dxvec3subtract(tmpbb.max,rbb[j].max,ojjektumarr[l].holvannak[i]);
   ojjektumarr[l].NeedKD;
   traverseKDTree(tmpbb,miket,ojjektumarr[l].KDData,ojjektumarr[l].KDTree);
   ojjektumarr[l].makecurrent(miket);
   //gömbök
   for k:=0 to high(gmbk) do
   begin
    if k=10 then mdst:=fejvst else mdst:=vst;
    adst:=ojjektumarr[l].tavtestfromcurrent(gmbk[k],mdst,ap,i);
    if adst>mdst*mdst then
     continue;
    if adst<0.00001 then adst:=0.1;
    adst:=sqrt(adst);
    d3dxvec3subtract(kp,ap,gmbk[k]);
    d3dxvec3scale(kp,kp,(mdst-adst)/adst);
    d3dxvec3subtract(gmbk[k],gmbk[k],kp);
    d3dxvec3lerp(voltgmbk[k],voltgmbk[k],gmbk[k],0.2);
   end;

   //vonalak
   for k:=0 to high(alapkapcsk) do
    begin
     if not ojjektumarr[l].raytestbolfromcurrent(gmbk[alapkapcsk[k,0]],gmbk[alapkapcsk[k,1]],i) then continue;

     if not ojjektumarr[l].raytestbolfromcurrent(gmbk[alapkapcsk[k,0]],voltgmbk[alapkapcsk[k,1]],i) then
     begin
      gmbk[alapkapcsk[k,1]]:=voltgmbk[alapkapcsk[k,1]];
      continue
     end;

     if not ojjektumarr[l].raytestbolfromcurrent(voltgmbk[alapkapcsk[k,0]],gmbk[alapkapcsk[k,1]],i) then
     begin
      gmbk[alapkapcsk[k,0]]:=voltgmbk[alapkapcsk[k,0]];
      continue
     end;

     gmbk[alapkapcsk[k,0]]:=voltgmbk[alapkapcsk[k,0]];
     gmbk[alapkapcsk[k,1]]:=voltgmbk[alapkapcsk[k,1]];
    end;
  end;
 end;

laststate:='Docollisiontests(false) 4';


 // AUTÓK AUTÓK AUTÓK AUTÓK AUTÓK AUTÓK AUTÓK AUTÓK AUTÓK
 // AUTÓK AUTÓK AUTÓK AUTÓK AUTÓK AUTÓK AUTÓK AUTÓK AUTÓK
 // AUTÓK AUTÓK AUTÓK AUTÓK AUTÓK AUTÓK AUTÓK AUTÓK AUTÓK

 for l:=0 to high(ojjektumnevek) do
 for i:=0 to ojjektumarr[l].hvszam-1 do
 begin
  with tegla do
  begin
   if disabled then continue;
   d3dxvec3add(tmpvec,ojjektumarr[l].holvannak[i],ojjektumarr[l].vce);
   if tavpointpointsq(tmpvec,pos)>sqr(ojjektumarr[l].rad+10) then continue;
   d3dxvec3subtract(tmpbb.min,vmi,ojjektumarr[l].holvannak[i]);
   d3dxvec3subtract(tmpbb.max,vma,ojjektumarr[l].holvannak[i]);

   ojjektumarr[l].needKD;
   traverseKDTree(tmpbb,miket,ojjektumarr[l].KDData,ojjektumarr[l].KDTree);
   ojjektumarr[l].getacctris(tris,miket,ojjektumarr[l].holvannak[i]);
   for k:=0 to high(tris) do
    tegla.SATtri(tris[k]);
  end;
 end;

 
 dokerektests;

laststate:='Docollisiontests 6';
////////////////////////////////////////////////////////////////
////////////////////////PROJECTILES/////////////////////////////
////////////////////////////////////////////////////////////////

//LAW

 

 i:=0;

 while i<=high(lawproj) do
 with lawproj[i] do
  if colltim>=4 then
  begin
  laststate:='Docollisiontests 6a';
   if advwove(v1.x,v1.z)>v1.y then
    begin
      DoLAWRobbanas(i,false);
      goto lawskip;
     end;
    laststate:='Docollisiontests 6b';
   if tavpointpointsq(v1,DNSvec)<sqr(DNSrad) then
   begin
    if tavpointpointsq(v1,DNSvec)<sqr(DNSrad-5) then
    begin
     lawproj[i]:=lawproj[high(lawproj)];
     setlength(lawproj,high(lawproj));
    end
    else
     DoLAWRobbanas(i,true);
    goto lawskip;
   end;

   laststate:='Docollisiontests 6c';

   for l:=0 to high(ojjektumnevek) do
   for j:=0 to ojjektumarr[l].hvszam-1 do
   begin
      if ojjektumarr[l].raytestbol(v1,v3,j) then
       begin
        DoLAWRobbanas(i,false);
        goto lawskip;
       end;
   end;

   v3:=v1;
   colltim:=0;
   inc(i);

   lawskip:
  end
  else
   inc(i);

   i:=0;

  laststate:='Docollisiontests 7';
//NOOB

 while i<=high(noobproj) do
 with noobproj[i] do
  if (colltim>=3) or (eletkor>150) then
  begin

   if  (advwove(v1.x,v1.z)>v1.y) or (abs(v1.x)>1500) or (abs(v1.y)>1500) or (abs(v1.z)>1500) then
    begin
      DonoobRobbanas(i,false);
      goto noobskip;
     end;
   if tavpointpointsq(v1,DNSvec)<sqr(DNSrad) then
   begin
    if tavpointpointsq(v1,DNSvec)<sqr(DNSrad-5) then
    begin
     noobproj[i]:=noobproj[high(noobproj)];
     setlength(noobproj,length(noobproj)-1);
    end
    else
    DoNoobRobbanas(i,true);
    goto noobskip;
   end;

   for l:=0 to high(ojjektumnevek) do
   for j:=0 to ojjektumarr[l].hvszam-1 do
   begin
      if ojjektumarr[l].raytestbol(v1,v3,j) then
       begin
        DonoobRobbanas(i,false);
        goto noobskip;
       end;
   end;

   

   if eletkor>300 then
       begin
        DonoobRobbanas(i,false);
        goto noobskip;
       end;

   v3:=v1;
   colltim:=0;
   inc(i);

   noobskip:
  end
  else
   inc(i);


   laststate:='Docollisiontests 8';
 //X72

 i:=0;

 while i<=high(x72proj) do
 with x72proj[i] do
  if colltim>=3 then
  begin
   Particlesystem_add(fenycsikcreate(v1,v3,0.07,$FF4010,100));
   if advwove(v1.x,v1.z)>v1.y then
    begin
      Dox72Robbanas(i,false);
      goto x72skip;
     end;

   if tavpointpointsq(v1,DNSvec)<sqr(DNSrad) then
   begin
    if tavpointpointsq(v1,DNSvec)<sqr(DNSrad-5) then
    begin
     x72proj[i]:=x72proj[high(x72proj)];
     setlength(x72proj,length(x72proj)-1);
    end
    else
    DoX72Robbanas(i,true);
    goto x72skip;
   end;


   for l:=0 to high(ojjektumnevek) do
   for j:=0 to ojjektumarr[l].hvszam-1 do
   begin
      if ojjektumarr[l].raytestbol(v1,v3,j) then
       begin
        Dox72Robbanas(i,false);
        goto x72skip;
       end;
  end;

    
   v3:=v1;
   colltim:=0;
   inc(i);

   x72skip:
  end
  else
   inc(i);

end;

procedure addesocsepp(tav:integer);
const
mag=4;
var
v1,v2,s,s2,s3,tmpv:TD3DXVector3;
pls1,pls2:single;
j,k:integer;
tmp:single;
begin
 pls1:=(random(tav*1000)-500*tav)/10000;
 pls2:=(random(tav*1000)-500*tav)/10000;

 v1:=D3DXVector3(campos.x+pls1,campos.y-mag,campos.z+pls2);

 s3:=D3DXVector3(cpox^-cpx^,0 {cpoy^-cpy^},cpoz^-cpz^);
  s:=s3;s.y:=s.y-0.5;
 d3dxvec3scale(s3,s3,-50);
 d3dxvec3add(v1,v1,s3);



 d3dxvec3scale(s,s,-100);

 s2:=s;
 fastvec3normalize(s2);
 d3dxvec3scale(s2,s2,mag*20);
// d3dxvec3add(v1,v1,s2);

 d3dxvec3add(v2,v1,s2);
 //v2:=v1;
 tmp:=v1.y;
 v1.y:=max(advwove(v1.x,v1.z),v1.y);
 if v1.y<10 then v1.y:=10;
  for k:=0 to high(ojjektumnevek) do
  begin
   for j:=0 to ojjektumarr[k].hvszam-1 do
   begin
    d3dxvec3add(tmpv,ojjektumarr[k].holvannak[j],ojjektumarr[k].vce);
    if tavpointpointsq(campos,tmpv)<sqr(ojjektumarr[k].rad+20) then
    v1:=ojjektumarr[k].raytest(v2,v1,j);
   end;
  end;  // }


 d3dxvec3scale(s2,s2,0.1);
 d3dxvec3add(v2,v1,s2);
 Particlesystem_add(Esocseppcreate(v2,v1,0.2,2,$C0A0A0C0,round(1+(abs(pls1)+abs(pls2))/10)));
 if v1.y<>tmp then
 Particlesystem_add(Simpleparticlecreate(v1,D3DXVector3zero,0.03,0,$C0C0A0A0,0,20));
end;




procedure AddLAW(av1,av2:TD3DXvector3;akl:integer);
begin
 setlength(lawproj, length(lawproj)+1);
 with lawproj[high(lawproj)] do
 begin
  v1:=av1;
  v2:=av2;
  v3:=v2;
  name:=XORHash2x12byte(v1,v2);
  kilotte:=akl;
  eletkor:=0;
 end;
end;


procedure AddNOOB(av1,av2:TD3DXvector3;akl:integer);
begin
 setlength(noobproj, length(noobproj)+1);
 with noobproj[high(noobproj)] do
 begin
  v1:=av1;
  v2:=av2;
  v3:=v2;
  name:=XORHash2x12byte(v1,v2);
  kilotte:=akl;
  eletkor:=0;
 end;
end;



procedure AddX72(av1,av2:TD3DXvector3;akl:integer);
begin
 setlength(X72proj, length(X72proj)+1);
 with X72proj[high(X72proj)] do
 begin
  v1:=av1;
  v2:=av2;

  name:=XORHash2x12byte(v1,v2);
 // name:=((name shl 16) and $FFFF0000) + ((name shr 16) and $FFFF);
  d3dxvec3lerp(v2,v2,v1,0.6);
  v3:=v2;
  kilotte:=akl;
  eletkor:=0;
 end;
end;

 procedure handleHDR;
var
tmpmat:TD3DMatrix;
tmpvec,tmpvec2:array [0..7] of TD3DVector;
i,j,k,a,tmpint:integer;
vec0,vec1,vecX:TD3DVector;
tmp:integer;
mennyit:single;
bol:boolean;
begin

 d3dxmatrixinverse(tmpmat,nil,matView);
 d3dxvec3transformcoord(vec0,d3dxvector3(0,0,0.01),tmpmat);
 noNANINF(vec0);
 constraintvec(vec0);
 vec1:=vec0; vec1.y:=vec1.y+100;

 mennyit:=3;
 nemlohet:=false;

 d3dxvec3add(vecx,ojjektumarr[panthepulet].holvannak[0],ojjektumarr[panthepulet].vce);
 if (sqr(vecx.x-cpx^)+sqr(vecx.z-cpz^))<sqr(ojjektumarr[panthepulet].rad*1.35) then
  nemlohet:=true;

 for i:=0 to 1 do
 if FelesHDR then
  tmpvec[i]:=D3DXVector3((i-1.5)*1*mennyit,(HDRscanline-3.5)*0.75*mennyit,10*mennyit)
 else
  tmpvec[i]:=D3DXVector3((i+0.5)*1*mennyit,(HDRscanline-3.5)*0.75*mennyit,10*mennyit);
 d3dxvec3transformcoordarray(pointer(@tmpvec2),sizeof(TD3DVector),pointer(@tmpvec),sizeof(TD3DVector),tmpmat,2);


 for a:=0 to 1 do
 begin
  if felesHDR then i:=a else i:=a+2;



  HDRarr[i,HDRScanline]:=128;
  for k:=0 to high(ojjektumnevek) do
   for j:=0 to ojjektumarr[k].hvszam-1 do
   begin
   constraintvec(vec0);
   constraintvec(tmpvec2[a]);
    tmpint:=ojjektumarr[k].raytestlght(vec0,tmpvec2[a],j);
    if tmpint>0 then
     HDRarr[i,HDRScanline]:=tmpint;

   end;
  d3dxvec3lerp(vec1,vec0,tmpvec2[a],0.5);
  //Particlesystem_add(simpleparticlecreate(tmpvec2[a],d3dxvector3zero,0.2,0.2,HDRarr[i,HDRScanline]*2,HDRarr[i,HDRScanline],10))
 end;



 if felesHDR then
 if HDRscanline>=7 then
 begin
  felesHDR:=true;
  tmp:=0;
  for i:=0 to 3 do
   for j:=0 to 7 do
    tmp:=tmp+HDRarr[i,j];
  HDRincit:=(HDRincit*2+tmp)/3;
  {$IFDEF depthcomplexity}         
  HDRincit:=5000;
  {$ENDIF}
  if HDRincit>2000 then FAKE_HDR:=D3DTOP_MODULATE else
  if HDRincit>1000 then FAKE_HDR:=D3DTOP_MODULATE2X else
                        FAKE_HDR:=D3DTOP_MODULATE4X;
  HDRscanline:=0;
 end
 else
  inc(HDRscanline);
 felesHDR:=not felesHDR;

 if (hanyszor and 3)=0 then
 begin
  bol:=false;
  d3dxvec3transformcoord(vec0,d3dxvector3zero,mfm);
  constraintvec(vec0);
  vec1:=vec0;
  vec1.x:=vec1.x-50;
  vec1.y:=vec1.y+50;
  for k:=0 to high(ojjektumnevek) do
   for j:=0 to ojjektumarr[k].hvszam-1 do
    bol:=bol or ojjektumarr[k].raytestbol(vec0,vec1,j);
  if bol then
  begin
   if fegylit>0 then dec(fegylit);
  end
  else
   if fegylit<10 then inc(fegylit);

 end;
end;

procedure pantheoneffect;
var
vec1,vec2,vec3:TD3DXVector3;
rnd:single;
   szin:cardinal;
begin

 d3dxvec3add(vec1,ojjektumarr[panthepulet].holvannak[0],ojjektumarr[panthepulet].vce);
 //if (hanyszor  and 15)=0 then
 if (sqr(vec1.x-campos.x)+sqr(vec1.z-campos.z))<sqr(ojjektumarr[panthepulet].rad*1.35+20) then
 begin
  vec2:=campos;
  randomplus(vec2,hanyszor+10.5,30);
  if (sqr(vec1.x-vec2.x)+sqr(vec1.z-vec2.z))<sqr(ojjektumarr[panthepulet].rad*1.35) then
  begin
   vec2.y:=advwove(vec2.x,vec2.z);
   szin:=(random(80)+40)+(random(80)+40) shl 8 +(random(80)+40) shl 16;
   Particlesystem_add(Simpleparticlecreate(vec2,D3DXVector3(0,0.005,0),0.05,0,szin,$0,100));
  end;
 end;

  vec1:=ojjektumarr[panthepulet].holvannak[0];
 if tavpointpointsq(vec1,campos)>sqr(ojjektumarr[panthepulet].rad*1.5) then exit;
 if tavpointpointsq(vec1,campos)<sqr(15) then HDRincit:=1000;
 d3dxvec3subtract(vec3,vec1,campos);
 vec3.y:=0;
 fastvec3normalize(vec3);
 rnd:=-(random(2000)*0.001-0.001);
 vec1:=D3DXVector3(vec1.x+vec3.x*rnd,vec1.y+vec3.y*rnd,vec1.z+vec3.z*rnd);
 vec2:=vec1;
 vec2.y:=vec2.y+34;
 Particlesystem_add(fenycsik2create(vec1,vec2,1.8,$00151515,$0,20));
 if random(20)=0 then
 begin
  vec1:=ojjektumarr[panthepulet].holvannak[0];
  randomplus(vec1,hanyszor+0.5,5);
  vec2:=vec1;
  vec2.y:=vec2.y+34;
  Particlesystem_add(bulletcreate(vec1,vec2,0.05,50,0.03,$FFFFFFFF,0));
 end;

end;

procedure handleZones;
const
radpls=10;
var
i,j,k:integer;
vec1,vec2:TD3DXVector3;
zonaban,zch:boolean;
mt:single;
lk:single;
begin
 if zonechanged>0 then dec(zonechanged);
 zonaban:=false;
 zch:=false;
 vec1:=D3DXVector3(cpx^,cpy^+0.8,cpz^);
 lk:=100000000000;
 for i:=1 to high(ojjektumnevek) do
  for j:=0 to ojjektumarr[i].hvszam-1 do
   begin
     D3DXVec3add(vec2,ojjektumarr[i].holvannak[j],ojjektumarr[i].vce);
     mt:=tavpointpointsq(vec1,vec2);
     if mt<sqr(ojjektumarr[i].rad+radpls) then
     if mt<lk then
     begin
       zonaban:=true;
       lk:=mt;
       if lastzone<>ojjektumzone[i] then
       begin
        lastzone:=ojjektumzone[i];
        zch:=true;
       end;
     end;
   end;

 if (lastzone<>'') and (not zonaban) then
 begin
  lastzone:='';
  zonechanged:=0;
  zonaellen:=0;
 end;

 if zch or ((hanyszor and 15)=0) then
 begin
  zonaellen:=0;
  if zch then
  zonechanged:=400;
  for k:=0 to high(ppl) do
   if (ppl[k].pls.fegyv xor myfegyv)>127 then
   begin
    vec1:=ppl[k].pos.megjpos;
    for i:=1 to high(ojjektumnevek) do
    if ojjektumzone[i]=lastzone then
     for j:=0 to ojjektumarr[i].hvszam-1 do
     begin
      D3DXVec3add(vec2,ojjektumarr[i].holvannak[j],ojjektumarr[i].vce);
      if tavpointpointsq(vec1,vec2)<sqr(ojjektumarr[i].rad+radpls) then
       inc(zonaellen);
     end;
   end;
 end;
end;


procedure addbadge(mit:shortstring);
begin
 if (checksum=datachecksum) or canbeadmin then
   //!TODO
 ;
end;

procedure handleteleports;
var
i,k:integer;
atav:single;
v1,v2:TD3DXVector3;
rnd:single;
begin

 for k:=0 to high(teleports) do
  with teleports[k] do
  begin
   if autoban then
    atav:=tavpointpointsq(vfrom,tegla.pos)
   else
    atav:=tavpointpointsq(vfrom,d3dxvector3(cpx^,cpy^,cpz^));


   if atav<sqr(vis) then
   begin

    if (hanyszor and 1)=1 then
    begin
     v1.x:=vfrom.x+sin(hanyszor/8)*(rad+0.4);
     v1.y:=vfrom.y;
     v1.z:=vfrom.z+cos(hanyszor/8)*(rad+0.4);
     Particlesystem_add(simpleparticleCreate(v1,D3DXVector3(0,0.03,0),0.3,0.5,$00FF4020,$00000000,random(50)+100));
    end;

    if random(40)=0 then
    begin
     v1:=vfrom;
     v1.y:=v1.y+2-random(200)/200;
     Particlesystem_add(fenykorcreate(v1,D3DXVector3(0,0.03,0),d3dxvector3(1,0,0),d3dxvector3(0,0,1),rad,rad,0.5,$00FF8040,$00000000,100));
     Particlesystem_add(fenykorcreate(v1,D3DXVector3(0,-0.02,0),d3dxvector3(1,0,0),d3dxvector3(0,0,1),rad,rad,0.5,$00FF8040,$00000000,100));

    end;

    if (hanyszor and 3)=0 then
    begin
     d3dxvec3subtract(v1,vfrom,campos);
     v1.y:=0;
     fastvec3normalize(v1);
     rnd:=-(random(2000)*0.001-0.001)*rad*0.5;
     v1:=D3DXVector3(vfrom.x+v1.x*rnd,vfrom.y+v1.y*rnd,vfrom.z+v1.z*rnd);
     v2:=v1;
     v2.y:=v1.y+4;
     Particlesystem_add(fenycsik2create(v1,v2,rad*1.2,$00604020,$0,20));
    end;
   end;

   if atav<sqr(rad) then
   begin
    cpx^:=vto.x;cpy^:=vto.y;cpz^:=vto.z;
    cpox^:=cpx^;cpoy^:=cpy^;cpoz^:=cpz^;

    if tavpointpointsq(vfrom,vto)>sqr(100) then
    begin
     cmz:=round(cpz^/pow2[lvlmin]);
     cmx:=round(cpx^/pow2[lvlmin]);
     remaketerrain;
    end;

    if autoban then
    begin
     for i:=0 to high(tegla.vpontok) do
      d3dxvec3subtract(tegla.vpontok[i],tegla.vpontok[i],tegla.pontok[i]);
     tegla.pos:=vto;
     tegla.pos.y:=vto.y+5;

     tegla.remakepontokfromaxes;

     for i:=0 to high(tegla.vpontok) do
      d3dxvec3add(tegla.vpontok[i],tegla.vpontok[i],tegla.pontok[i]);

    end;

    invulntim:=300;
    playsound(25,false,timegettime+random(10000),true,D3DXVector3(cpx^,cpy^+1.5,cpz^));
    for i:=0 to 200 do
    begin
     v1:=randomvec(animstat*2+i*3,1);
     fastvec3normalize(v1);
     Particlesystem_add(ExpsebparticleCreate(D3DXVector3(cpx^,cpy^+1.5,cpz^),v1,1.0,1.0,0.8,$00FF2010,$00000000,random(50)+20));
    end;
   end;

   {
 invulntim:=300;
 v1:=D3DXVector3(BGarr[BGben].holvannak[0].x+random(20)-10,BGarr[BGben].holvannak[0].y+0,BGarr[BGben].holvannak[0].z+random(20)-10);
 v2:=v1; v2.y:=v2.y+100;
 v3:=BGarr[BGben].raytest(v2,v1,0);
 cpx^:=v3.x;cpy^:=v3.y;cpz^:=v3.z;
 cpox^:=cpx^;cpoy^:=cpy^;cpoz^:=cpz^;

 playsound(25,false,timegettime+random(10000),true,D3DXVector3(cpx^,cpy^+1.5,cpz^));
 for i:=0 to 200 do
 begin
  tmp:=randomvec(animstat*2+i*3,1);
  fastvec3normalize(tmp);
  Particlesystem_add(ExpsebparticleCreate(D3DXVector3(cpx^,cpy^+1.5,cpz^),tmp,1.0,1.0,0.8,$00FF2010,$00000000,random(50)+20));
 end;
        }
  end;

end;

{procedure re_playerstuff;
var
tmp:single;
vec1:TD3DXVector3;
i:integer;
begin
if (currevent is TReactorEvent) then exit;

for i:=0 to high(lawproj) do
 with lawproj[i] do
 begin
  if eletkor<65 then continue;
  tmp:=tavpointpoint(v1,re_gk);
  if tmp<100 then
   if tmp<2 then
    v1.y:=0
   else
   begin
    d3dxvec3subtract(vec1,v1,re_gk);
    d3dxvec3scale(vec1,vec1,-0.3/(tmp*tmp));
    d3dxvec3add(v1,v1,vec1);
   end;
 end;

 for i:=0 to high(noobproj) do
 with noobproj[i] do
 begin
  tmp:=tavpointpoint(v1,re_gk);
  if tmp<100 then
   if tmp<2 then
    v1.y:=0
   else
   begin
    d3dxvec3subtract(vec1,v1,re_gk);
    d3dxvec3scale(vec1,vec1,-0.002*eletkor/(tmp*tmp));
    d3dxvec3add(v1,v1,vec1);
   end;
 end;

 for i:=0 to high(x72proj) do
 with x72proj[i] do
 begin
  tmp:=tavpointpoint(v1,re_gk);
  if tmp<100 then
   if tmp<2 then
    v1.y:=0
   else
   begin
    d3dxvec3subtract(vec1,v1,re_gk);
    d3dxvec3scale(vec1,vec1,-0.3/(tmp*tmp));
    d3dxvec3add(v1,v1,vec1);
   end;
 end;

 tmp:=tavpointpoint(tegla.pos,re_gk);
 if tmp<100 then
 begin
  d3dxvec3subtract(vec1,tegla.pos,re_gk);
  d3dxvec3scale(vec1,vec1,-0.3/(tmp*tmp));

  for i:=0 to high(tegla.pontok) do
   d3dxvec3add(tegla.pontok[i],tegla.pontok[i],vec1);
 end;

 tmp:=tavpointpoint(D3DXVector3(cpx^,cpy^+1,cpz^),re_gk);
 if tmp<100 then
 begin
  d3dxvec3subtract(vec1,d3dxvector3(cpox^,cpoy^,cpoz^),re_gk);
  d3dxvec3scale(vec1,vec1,-0.1/(tmp*tmp));
  cpx^:=cpx^+vec1.x;
  cpy^:=cpy^+vec1.y*40;
  cpoy^:=cpoy^+vec1.y*39;
  cpz^:=cpz^+vec1.z;
 end;

if halal=0 then
  if tmp<15 then
   begin
    halal:=1;
    autoban:=false;
    MMO.chatelj('==>'+MMO.mynev2+' has been disintegrated.');
    addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(0.00,-0.1,0),myfegyv,10,0);
   end;
end;    }


procedure handlefizik;
var
i,j:integer;
ox,oy,oz,amag,tx,tz:single;
norm,hova,opos,tmp,tmps:TD3DXVector3;
korlat:integer;
rbid:integer;
h1,h2,h3:integer;
bol:boolean;
rnd:integer;
cnt:integer;
mxh:integer;
mx,tmp2:single;
v1,v2,v3:TD3DXVector3;
az:Tspeexdecoder;
gtc:cardinal;
aauto:Tauto;
begin

 gtc:=gettickcount;
 korlat:=0;
 repeat

  oopos:=D3DXVector3(cpox^,cpoy^,cpoz^);
  wentthroughwall:=false;
  
  laststate:='Doing Real Physics';
  inc(hanyszor);

   //Saját fizika


  ox:=cpx^;oy:=cpy^;oz:=cpz^;
  try
  amag:=advwove(cpx^,cpz^);
  except
  amag:=0;
  end;
  yandnorm(cpx^,amag,cpz^,norm,1);
  {$IFDEF repkedomod}
  cpoy^:=cpy^;
  {$ELSE}
  cpy^:=cpy^*2-cpoy^-GRAVITACIO;
  {$ENDIF}
  if (cpy^-0.03)<amag then
  begin
   if not volthi then
    if (halal=0) and (not autoban) then
    if cpy^>79.4 then
    begin
     volthi:=true; addbadge('HI');
    end;
   if (epulethezert=0) or (cpy^<amag) then
   begin
   cpy^:=amag;
   oy:=amag;
   end;
   {$IFNDEF repkedomod}
   if norm.y<0.83 then
   begin
    cpx^:=cpx^+norm.x*0.001;
    cpz^:=cpz^+norm.z*0.001;
   end;
  {$ENDIF}
  end;

  if not (((cpy^-0.1)<amag) and (norm.y>0.83)) then
  begin
   if ((cpy^-0.1)<amag) and (myfegyv=FEGYV_QUAD)  then csipo:=true;
   iranyithato:=false;
  end
  else
   iranyithato:=true;

  {$IFDEF repkedomod}
   iranyithato:=true;
  {$ENDIF}
  if (not iranyithato) and ((cpy^-0.05)<amag) then
   playrocks:=1
  else
   playrocks:=playrocks-eltim/2;
 // if playrocks>1 then playrocks:=1;
  if playrocks<0 then playrocks:=0;
  
   laststate:='Doing Real Physics 2';
  //Egyéb plr cucc
  ;
  if (cpy^<10) and ((mstat and MSTAT_MASK)>0) then
   vizben:=vizben+eltim
  else
   vizben:=vizben-eltim;
 // if playrocks>1 then playrocks:=1;
  if vizben<0 then vizben:=0;
  if vizben>1 then vizben:=1;
  if autoban then
  begin
   if (cpy^<9.5) then
   begin
    halal:=1;
    autoban:=false;
    //!TODO submarine
    addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),d3dxvector3(0.00,-0.1,0),myfegyv,10,0,-1);
   end;
  end
  else
  if ((cpy^<9) and gugg) or ((cpy^<8.5) and (not gugg)) then
  if halal=0 then
  begin
   halal:=1;
   //couldn't swim
   addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),d3dxvector3(0.00,0.0,0),myfegyv,10,0,-1);
  end;

  if recovercar>0 then
  begin
   inc(recovercar);
   flipcount:=0;
   if tegla.axes[2].y>0 then
    recovercar:=0;
  end;

  if recovercar>300 then
  begin
   flipbol:=false;
   d3dxvec3scale(tegla.axes[2],tegla.axes[2],-1);
   d3dxvec3scale(tegla.axes[1],tegla.axes[1],-1);
   tegla.pos.y:=tegla.pos.y+1;
   tegla.remakepontokfromaxes;
   tegla.vpontok:=tegla.pontok;
   recovercar:=0;
  end;
  tegla.step;
  tegla.constraintoter(advwove);
  tegla.constraintoteg;

  for i:=-1 to min(high(tobbiekautoi),high(ppl)) do
  begin
   if i<0 then
   begin
    tmp2:=myfegyv;
    aauto:=tegla;
   end
   else
   begin
    aauto:=tobbiekautoi[i];
    tmp2:=ppl[i].pls.fegyv;
   end;

  if (not aauto.disabled) and (tavpointpointsq(campos,aauto.pos)<sqr(100)) then
  if tmp2<128 then
  begin
   tmp:=aauto.kerekek[hanyszor mod 4];
   if tavpointpointsq(aauto.pos,aauto.vpos)>sqr(0.05) then
   if tmp.y-0.3<advwove(tmp.x,tmp.z) then
   begin
    tmps:=randomvec(animstat*100+hanyszor,0.1);
    tmps.x:=    tmps.x +(aauto.pos.x-aauto.vpos.x)*0.8;
    tmps.y:=abs(tmps.y)+(aauto.pos.y-aauto.vpos.y)*0.8;
    tmps.z:=    tmps.z +(aauto.pos.z-aauto.vpos.z)*0.8;
    if tmp.y>10 then
     if tmp.y<15 then
      Particlesystem_add(SimpleparticleCreate(tmp,randomvec(animstat*100+hanyszor,0.1),0.5,2,$FFB2B9DC,$0,100))
     else
      Particlesystem_add(SimpleparticleCreate(tmp,randomvec(animstat*100+hanyszor,0.1),0.5,2,$FF2D7755,$0,100))

   end;
  end
  else
  begin           //mod 4
   if (hanyszor and 3)=0 then
   begin
    if (hanyszor and 7)=0 then
     d3dxvec3lerp(tmp,aauto.kerekorig[0],aauto.kerekorig[1],0.1+0.8*random(1000)/1000)
    else
     d3dxvec3lerp(tmp,aauto.kerekorig[2],aauto.kerekorig[3],0.1+0.8*random(1000)/1000);

     tmp :=aauto.kerekorig[0]; randomplus(tmp ,gtc  ,1);
     tmps:=aauto.kerekorig[1]; randomplus(tmps,gtc+5,1);
     Particlesystem_add(fenycsikcreate(tmp,tmps,0.3,$0401005,100));
     tmp :=aauto.kerekorig[2]; randomplus(tmp ,gtc  ,1);
     tmps:=aauto.kerekorig[3]; randomplus(tmps,gtc+5,1);
     Particlesystem_add(fenycsikcreate(tmp,tmps,0.3,$0401005,100));
    //Particlesystem_add(fenykorCreate(tmp,d3dxvector3(0,-0.02,0),
    //                                    d3dxvector3(1,0,0),d3dxvector3(0,0,1),0.3,0.3,0.3,$00FF7000,0,30));
   end;
  end;
  end;

    docollisiontests;

   //PLR fizikája
  if not iranyithato then
  begin
   cpx^:=cpx^*2-cpox^;
   cpz^:=cpz^*2-cpoz^;
  end;
  cpox^:=ox;cpoy^:=oy;cpoz^:=oz;
  if halal>0 then
  begin cpx^:=cpox^; cpy^:=cpoy^; cpz^:=cpoz^; end;
 
  laststate:='Iranyit';
  iranyit;
  laststate:='Fizik: WTW';
  if wentthroughwall then
  if not autoban then
  begin
   cpx^:=oopos.x;
   cpy^:=oopos.y;
   cpz^:=oopos.z;

   cpox^:=oopos.x;
   cpoy^:=oopos.y;
   cpoz^:=oopos.z;
  end
  else
  begin
   tegla.pos:=tegla.vpos;
   tegla.remakepontokfromaxes;
  end;
  laststate:='Doing BG stuff';
  {if (cpy^-cpoy^)>0.6 then cpoy^:=cpy^;}

  handleteleports;

  laststate:='Ragdoll physics';
  inc(rbido);
  if rbszam>-1 then
  rbido:=rbido mod (rbszam+1);
  for i:=0 to rbszam do
   rongybabak[i].step(advwove,i=rbido);
  i:=0;
  while i<=rbszam do
  begin
   if rongybabak[i].ido >RB_MAX_IDO then
    delrongybaba(i)
   else
    inc(i);
  end;
  cooldown:=cooldown-0.01;
  if hanyszor*10<(timegettime-100) then
  begin
   hanyszor:=(timegettime div 10) +1;
   //if not hvolt then delrongybaba(-1);
  end;
  laststate:='After Ragdoll Physics';
  inc(korlat);

  for i:=0 to high(ppl) do
  begin
  if ppl[i].net.mtim<300 then
   inc(ppl[i].net.mtim);
  if ppl[i].net.amtim<200 then
   inc(ppl[i].net.amtim);
  end;

 if halal>0 then
 begin
  rbid:=getrongybababyID(0);
  if rbid>=0 then
  begin
     
   cpx^:=(cpx^*19+rongybabak[rbid].gmbk[5].x)/20; //ingadozik minta kvantum XD
   cpy^:=(cpy^*19+rongybabak[rbid].gmbk[5].y)/20; //ki kell egynlíteni
   cpz^:=(cpz^*19+rongybabak[rbid].gmbk[5].z)/20;
   cpox^:=(cpox^*19+cpx^)/20; //damp
   cpoy^:=(cpoy^*19+cpy^)/20;
   cpoz^:=(cpoz^*19+cpz^)/20;
  end;
  if halal<=1.1 then begin
   cpox^:=cpx^;cpoy^:=cpy^;cpoz^:=cpz^; end;
 end;


 noNANinf(cpx^); noNANinf(cpy^); noNANinf(cpz^);
 noNANinf(cpox^); noNANinf(cpoy^); noNANinf(cpoz^);

   laststate:='Auto egyeb';

 if autoban then
 begin
  cpx^:=tegla.pos.x;
  cpy^:=tegla.pos.y;
  cpz^:=tegla.pos.z;
  kulsonezet:=true;
  vanishcar:=0;
 end
 else
 begin
  kulsonezet:=false;
  if vanishcar>0 then
  inc(vanishcar);
 end;

  if halal>0 then
  begin
   autoban:=false;
   kulsonezet:=false;
  end;
 if vanishcar>1500 then
 begin
  vanishcar:=0;
  tegla.pos:=d3dxvector3zero;
  tegla.vpos:=d3dxvector3zero;
  tegla.disabled:=true;
 end;

 if kiszallas>0 then inc(kiszallas);
 if kiszallas>=200 then
 begin
  if tavpointpointsq(tegla.pos,tegla.vpos)> sqr(0.1) then
  begin
    halal:=1;
    setupmymuksmatr;
    //!TODO tried to exit
    addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3((cpox^+cpx^)/2,cpy^-0.5,(cpoz^+cpz^)/2),d3dxvector3(-sin(szogx)*0.3,-0.1,-cos(szogx)*0.3),myfegyv,0,0,-1);
  end;
  cooldown:=3;
  autoban:=false;
  kulsonezet:=false;
  kiszallas:=0;
  vanishcar:=1;
 end;
 if mszogx>(szogx+pi) then
  mszogx:=mszogx*0.8+(szogx+2*pi)*0.2
 else
 if mszogx<(szogx-pi) then
  mszogx:=mszogx*0.8+(szogx-2*pi)*0.2
 else
  mszogx:=mszogx*0.8+szogx*0.2;

 mszogy:=mszogy*0.8+szogy*0.2;
 if ((mstat and MSTAT_MASK)<5) and ((mstat and MSTAT_MASK)<>0) then
 if csipo then
  mszogy:=mszogy+sin(animstat*2*D3DX_PI)/200
 else
  mszogy:=mszogy+sin(animstat*2*D3DX_PI)/400;
 if ((mstat and MSTAT_MASK)=5) then
 begin              //animstat kiteljsített formában
  mszogx:=mszogx+sin(animstat*2*D3DX_PI)/50;
  mszogy:=mszogy+sin(animstat*4*D3DX_PI)/200;
 end;
 //mszogy:=mszogy+(cpoy^-cpy^)/20;

 ox:=ccpx; oy:=ccpy; oz:=ccpz;

 ccpx:=ccpx*2-cocpx;
 ccpy:=ccpy*2-cocpy;
 ccpz:=ccpz*2-cocpz;
 cocpx:=ox; cocpy:=oy; cocpz:=oz;

 tmp2:=max(0,power(0.3,sqr(cpx^-ccpx)+sqr(cpy^-ccpy)+sqr(cpz^-ccpz))-0.1);
 //tmp2:=0.9;
 ccpx:=ccpx*tmp2+cpx^*(1-tmp2);
 ccpy:=ccpy*tmp2+cpy^*(1-tmp2);
 ccpz:=ccpz*tmp2+cpz^*(1-tmp2);
                              
 //cocpx:=(ox*5+ccpx)/6; cocpy:=(oy*5+ccpy)/6; cocpz:=(oz*5+ccpz)/6;

 cocpx:=ccpx+(cocpx-ccpx)*0.5+(cpox^-cpx^)*0.3;
 cocpy:=ccpy+(cocpy-ccpy)*0.5+(cpoy^-cpy^)*0.6;
 cocpz:=ccpz+(cocpz-ccpz)*0.5+(cpoz^-cpz^)*0.3;

// ccpx:=cpx^;ccpy:=cpy^;ccpz:=cpz^;


 laststate:='Weather';
 felho.update;

 d3dxvec3subtract(tmp,tegla.vpos,tegla.pos);
 if opt_rain then
 if not (autoban and (d3dxvec3lengthsq(tmp)>sqr(0.2))) then
 for i:=round(felho.coverage) to 5 do
  for j:=0 to 5 do
    addesocsepp((i+2)*(10-round(felho.coverage))*2);
 ParticleSystem_Update;

 if myfegyv<128 then
  if not voltspeeder then
   if (autoban and (d3dxvec3lengthsq(tmp)>sqr(0.56))) then
   begin
    addbadge('HS');
    voltspeeder:=true;
   end;

// if opt_ then
 if felho.coverage<2 then
 begin
  if villam=200 then felho.villamolj;
  if villam=0 then
  begin

   villambol:=100;
   villam:=1000+random(2000);
  end
  else
   dec(villam);
  if villambol>0 then dec(villambol);
 end
 else
 begin
  villam:=1000;
  villambol:=0;
 end;

 if (myfegyv=FEGYV_NOOB) and (lovok>0) then
 begin
  norm:=D3DXVector3(random(10000)-5000,random(10000)-5000,random(10000)-5000);
  fastvec3normalize(norm);
  tmp:=noobtoltpos;
  tmp:=D3DXVector3(tmp.x+norm.x*0.3,tmp.y+norm.y*0.3,tmp.z+norm.z*0.3);
 // d3dxvec3scale(norm,-0.01);
  Particlesystem_add(bulletcreate(tmp,noobtoltpos,0.01,20,0.004,$50FF6020,0));
  Particlesystem_add(bulletcreate(tmp,noobtoltpos,0.01,20,0.001,$FFFFFFFF,0));
 end;



   laststate:='Projectiles';
 for i:=0 to high(noobproj) do
 with noobproj[i] do
 begin
  inc(colltim);
    inc(eletkor);
  tmp:=v1;
     //gyorsuló

  v1.x:=(v1.x-v2.x)*1.02+v1.x;
  v1.y:=(v1.y-v2.y)*1.02+v1.y;
  v1.z:=(v1.z-v2.z)*1.02+v1.z;

  v2:=tmp;

  d3dxvec3subtract(tmp,v1,v2);
  d3dxvec3scale(tmp,tmp,0.5);
  randomplus(tmp,animstat*5+i*2,0.01);
  Particlesystem_add(Simpleparticlecreate(v1,
                                         // D3DXVector3Zero,
                                          tmp,
                                          0.5,0,$0000010*(random(70)+150),$00000000,100));
 end;

 


 for i:=0 to high(lawproj) do
 with lawproj[i] do
 begin
  inc(eletkor);
  inc(colltim);
  tmp:=v1;
  if eletkor>65 then
  begin
   v1.x:=(v1.x-v2.x)*1.00+v1.x;
   v1.y:=(v1.y-v2.y)*1.00+v1.y-GRAVITACIO/2;
   v1.z:=(v1.z-v2.z)*1.00+v1.z;
  end
  else
  begin
   v1.x:=(v1.x-v2.x)*1.04+v1.x;
   v1.y:=(v1.y-v2.y)*1.04+v1.y;
   v1.z:=(v1.z-v2.z)*1.04+v1.z;
  end;

  v2:=tmp;
  if (hanyszor and 1)=1 then
  begin
   Particlesystem_add(Simpleparticlecreate(v2,
                                           D3DXVector3Zero,
                                          // D3DXVector3((random(100)-50)/10000,(random(100)-50)/10000,(random(100)-50)/10000),
                                           0.5,0,$1000000*(random(50)+70)+$010101*random(70),$00000000,200));
   d3dxvec3subtract(tmp,v1,v2);
   d3dxvec3scale(tmp,tmp,0.5);
   Particlesystem_add(Simpleparticlecreate(v2,
                                          // D3DXVector3Zero,
                                           tmp,
                                           0.5,0,$0001010*(random(70)+150),$00000000,60));
  end;
 end;

 for i:=0 to high(x72proj) do
 with x72proj[i] do
 begin
  inc(eletkor);
  inc(colltim);
  tmp:=v1;
  v1.x:=2.00*v1.x-v2.x;
  v1.y:=2.00*v1.y-v2.y-(max(0,eletkor-400))/5000-GRAVITACIO/2;
  v1.z:=2.00*v1.z-v2.z;
  randomplus2(v1,eletkor/100+name and $FFFF,0.003);
  v2:=tmp;
  d3dxvec3subtract(tmp,v1,v2);
  d3dxvec3scale(tmp,tmp,0.8);
  Particlesystem_add(Simpleparticlecreate(v2,
                                         // D3DXVector3Zero,
                                          tmp,
                                          0.3,0,$00202020,$00200000,30));
 end;

 i:=0;
 while i<=high(explosionbubbles) do
 if explosionbubbles[i].tim<=0 then
 begin
  explosionbubbles[i]:=explosionbubbles[high(explosionbubbles)];
  setlength(explosionbubbles,high(explosionbubbles));
 end
 else
 with explosionbubbles[i] do
  begin
   dec(tim);
   meret:=meret+meretpls;
   meretpls:=meretpls*meretplsszor;
   erosseg:=erosseg+erossegpls;
   inc(i);
  end;

 i:=0;
 while i<=high(explosionripples) do
 if explosionripples[i].tim<=0 then
 begin
  explosionripples[i]:=explosionripples[high(explosionripples)];
  setlength(explosionripples,high(explosionripples));
 end
 else
 with explosionripples[i] do
  begin
   dec(tim);
   meret:=meret+meretpls;
   meretpls:=meretpls*meretplsszor;
   erosseg:=erosseg+erossegpls;
   inc(i);
  end;


 if rezg>0 then rezg:=rezg-0.1 else
 begin
  rezg:=0;
  robhely:=D3DXvector3zero;
 end;

  for i:=0 to high(ppl) do
   if ppl[i].pls.lottram>0 then dec(ppl[i].pls.lottram);

 if invulntim>0 then dec(invulntim);
 if latszonaKL>0 then dec(latszonaKL);

/// UNTIL


{ for i:=0 to min(high(ppl),high(AIplrs)) do
 begin
  pplpos[i].pos:=AIplrs[i].pos;
  pplpls[i].vpos:=AIplrs[i].pos;
  pplpls[i].fegyv:=AIplrs[i].fegyv;
  pplpos[i].state:=AIplrs[i].state;
  pplpls[i].afejcucc:=AIplrs[i].fejcucc;
   pplpls[i].vpos.x:= pplpos[i].pos.x+5;
   pplpos[i].pos.x:= pplpos[i].pos.x+5;
 end; }

 gtc:=timegettime;
  for i:=0 to high(ppl) do
   if ppl[i].pls.utsocht<>'' then
    if ppl[i].pls.chttim<length(ppl[i].pls.utsocht)*15 then inc(ppl[i].pls.chttim) else ppl[i].pls.utsocht:='';

  if suicidevolt>0 then dec(suicidevolt);

  inc(armcount);

  if armcount>=10 then
  begin
   v1:=d3dxvector3(cpx^+random(150)-75,cpy^+200,cpz^+random(150)-75);
   v2:=v1;
   v2.y:=v2.y+0.1;
   randomplus(v2,gtc,0.03);
   //AddNOOB(v1,v2,255);
   armcount:=0;
  end;

    laststate:='Calculating megjpos';
  for i:=0 to high(ppl) do
   with ppl[i].net do
   with ppl[i].pos do
   if vtim<>0 then
    if ppl[i].net.connected then
    begin
     v1:=D3DXVector3( pos.x+ seb.x*mtim, pos.y+ seb.y*mtim, pos.z+ seb.z*mtim);
     v2:=D3DXVector3(vpos.x+vseb.x*mtim,vpos.y+vseb.y*mtim,vpos.z+vseb.z*mtim);
     D3DXVec3lerp(megjpos,v2,v1,min(mtim/vtim,1));
    end
    else
     megjpos:=D3DXVector3Zero;

  if epulethezert>0 then dec(epulethezert) else epulethezert:=0;
   laststate:='HandleHDR';
      handleHDR;
  laststate:='physics UNTIL';

     pantheoneffect;


  sky_voros:=false;
  if currevent<>nil then
  begin
   currevent.Step;
   if currevent.vege then
   begin
    currevent.Destroy;
    currevent:=nil;
   end;
   if currevent is TSpaceshipevent then
   with currevent do
   begin
    if phs=5 then
    begin
     if phstim<500 then
     if (phstim mod 20)=0 then
      //!TODO spaceship event nooblövések
    end;

   { if (phs=7) or (phs=8) then
    begin
     setlength(explosionbubbles,length(explosionbubbles)+1);
     with explosionbubbles[high(explosionbubbles)] do
     begin
      pos:=DNSVec;
      randomplus(pos,timegettime,5);
      meret:=50; meretpls:=-0.3;
      erosseg:=random(700); erossegpls:=-1/50;
      meretplsszor:=1;
      tim:=5;
     end;

    end;  }
   end;
  end;
  for i:=high(posokvoltak)-1 downto 0  do
    posokvoltak[i+1]:=posokvoltak[i];
  posokvoltak[0]:=D3DXVector3(cpx^,cpy^,cpz^);

  mapbol:=mapbol xor dine.keyd2(DIK_M);
  if mapbol then
  begin
   if mapmode<1 then mapmode:=mapmode*1.1+0.0005 else mapmode:=1;
  end
  else
   if mapmode>0 then mapmode:=mapmode*0.9-0.001 else mapmode:=0;

  if abs(mapmode-0.5)<0.5 then
  begin

   rezg:=min(2,(0.5-abs(mapmode-0.5))*20);
   if mapbol then
    robhely:=D3DXVector3(0.01, 3,0.01)
   else
    robhely:=D3DXVector3(0.01,-3,0.01);
  end;

  szogx:=szogx+(D3DX_PI/2-szogx)*mapmode;
  //if mapmode=1 then szogx:=D3DX_PI/2;

  if halal>0 then mapbol:=false;

  handlezones;


  //0  TECH //12 killing spreek   //18 GUN //32 killing spreek
  //Haláli rádiók :P

  if opt_taunts then
   begin
   if myfegyv>127 then
   begin

    case multisc.kills-multisc.killswithoutdeath of
      3:i:=12+0;
      6:i:=12+1;
      9:i:=12+2;
     12:i:=12+3;
     15:i:=12+4;
     30:i:=12+5;
    else
     i:=2+random(10);
    end;

    PlayStrm(0,123,-300,true);
    PlayStrm(i,123,-300);
    PlayStrm(1,123,-300);
   end
   else
   begin
    case multisc.kills-multisc.killswithoutdeath of
      3:i:=32+0;
      6:i:=32+1;
      9:i:=32+2;
     12:i:=32+3;
     15:i:=32+4;
     30:i:=32+5;
    else
     i:=20+random(11);
    end;

    PlayStrm(18+0,123,-400,true);
    PlayStrm(   i,123,-400);
    PlayStrm(18+1,123,-400);
   end;

  end;

  if mp5ptl>0 then
   if mp5ptl>10 then mp5ptl:=3
    else
     mp5ptl:=mp5ptl-0.05
   else
   mp5ptl:=0;

  if x72gyrs>0 then
   x72gyrs:=x72gyrs-0.002
  else
   x72gyrs:=0;

  if myfegyv<128 then
  begin
   if flipbol then
   begin
    if tegla.axes[2].y>0.2 then
    begin
     flipbol:=false;
     inc(flipcount);
     if voltflip<flipcount then
     case flipcount of
      1:Addbadge('F1');
      2:Addbadge('F2');
      3:Addbadge('F3');
      4:Addbadge('F4');
     end;
     voltflip:=flipcount;
    end;
   end
   else
    if tegla.axes[2].y<-0.2 then
     flipbol:=true;
  end;

  if autoban then
  begin
   if zeneintensity>0 then
    dec(zeneintensity,3)
   else
    zeneintensity:=0;
    if mp3strmp2<>2 then
    begin
     mp3strmp2:=2;
     mp3strmp[mp3strmp2]:=random(high(mp3strms[mp3strmp2])+1);
     mp3strmpvalts:=true;
    end;
  end
  else
  begin
   if zeneintensity>0 then dec(zeneintensity,3)
   else
   begin
    zeneintensity:=0;
    if mp3strmp2<>0 then
    begin
     mp3strmp2:=0;
     mp3strmpvalts:=true;
    end;
   end;

   if zeneintensity>5000 then
    if mp3strmp2<>1 then
    begin
     mp3strmp2:=1;
     mp3strmpvalts:=true;
    end;

   if mp3strmp2=2 then
    begin
     if zeneintensity>2500 then
      mp3strmp2:=1
     else
      mp3strmp2:=0;
     mp3strmpvalts:=true;
    end;
  end;

  if zeneintensity>10000 then zeneintensity:=10000;

  if (hanyszor mod 50)=0 then updateterrain;
 // sleep(10);

  ojjektumRenderer.RefreshImposters(D3DXVector3(cpx^,cpy^,cpz^));

 

 until (hanyszor*10>timegettime) or (korlat>20);
//////////

 if rbszam>4 then delrongybaba(-1);
 hvolt:=false;
 i:=hanyszor*10-timegettime;

 if i>0 then sleep(i)
 else
  hanyszor:=timegettime div 10;

 anticheat2:=round(time*86400000)-timegettime;

 if abs(anticheat1-anticheat2)>5000 then
 begin
   Postmessage(hwindow,WM_DESTROY,0,0);
 end;

 csinaljfaszapointereket;
end;

procedure handlefizikVEGE;
begin
 // üres, csak könyvjelzõ;
end;


procedure handlefizikLite;
var
korlat:integer;
i,j:integer;
begin
korlat:=0;
 repeat
   laststate:='Weather';
  felho.update;

 if opt_rain then
 for i:=round(felho.coverage) to 5 do
  for j:=0 to 5 do
    addesocsepp((i+2)*(10-round(felho.coverage))*2);


 ParticleSystem_Update;

 //if (opt_detail>=DETAIL_RAIN) then
 if felho.coverage<2 then
 begin
  if villam=200 then felho.villamolj;
  if villam=0 then
  begin

   villambol:=100;
   villam:=1000+random(2000);
  end
  else
   dec(villam);
  if villambol>0 then dec(villambol);
 end
 else
 begin
  villam:=1000;
  villambol:=0;
 end;
 laststate:='HandleHDR lite';
  handleHDR;
  pantheoneffect;
  //re_effect;
 ccpx:=cpx^; ccpy:=cpy^; ccpz:=cpz^;

  inc(korlat);
  inc(hanyszor);

   ojjektumRenderer.RefreshImposters(D3DXVector3(cpx^,cpy^,cpz^));

 until (hanyszor*10>timegettime) or (korlat>4);
 if (korlat>4) then hanyszor:=timegettime div 10;
end;


procedure quadeffect;
const
 a1:TD3DXVector3=(x: 0.022;y: 0.022;z:-0.62);
 a2:TD3DXVector3=(x: 0.020;y:-0.022;z:-0.62);
 a3:TD3DXVector3=(x:-0.020;y:-0.022;z:-0.62);
 a4:TD3DXVector3=(x:-0.022;y: 0.022;z:-0.62);
 n1:TD3DXVector3=(x:-0.01;y: 0.01;z:0);
 n2:TD3DXVector3=(x: 0.01;y: 0.01;z:0);
var
 tmp,tmp2,v1,v2:TD3dvector;
 i:integer;
 rnd:single;
begin


 if (myfegyv=FEGYV_QUAD) then
 if not csipo then
 if cooldown<random(100)/100 then
    begin

     //ZÕD
     rnd:=0;
     for i:=0 to 9 do
     begin
      D3DXVec3lerp(tmp,a1,a3,i/10);
      d3dxvec3scale(tmp2,n1,rnd);
      d3dxvec3add(tmp,tmp,tmp2);
      d3dxvec3transformcoord(v1,tmp,mfm);
      nonaninf(v1);

      rnd:=random(100)/100-0.5;
      if i=9 then rnd:=0;
      
      D3DXVec3lerp(tmp,a1,a3,i/10+0.1);
      d3dxvec3scale(tmp2,n1,rnd);
      d3dxvec3add(tmp,tmp,tmp2);
      d3dxvec3transformcoord(v2,tmp,mfm);
      nonaninf(v2);
      particlesystem_Add(fenycsikcreate(v1,v2,0.005,$20103010,1));
     end;

     rnd:=0;
     for i:=0 to 9 do
     begin
      D3DXVec3lerp(tmp,a2,a4,i/10);
      d3dxvec3scale(tmp2,n2,rnd);
      d3dxvec3add(tmp,tmp,tmp2);
      d3dxvec3transformcoord(v1,tmp,mfm);
      nonaninf(v1);

      rnd:=random(100)/100-0.5;
      if i=9 then rnd:=0;

      D3DXVec3lerp(tmp,a2,a4,i/10+0.1);
      d3dxvec3scale(tmp2,n2,rnd);
      d3dxvec3add(tmp,tmp,tmp2);
      d3dxvec3transformcoord(v2,tmp,mfm);
      nonaninf(v2);
      particlesystem_Add(fenycsikcreate(v1,v2,0.005,$20103010,1));
     end;

     //FEHÉR

     rnd:=0;
     for i:=0 to 9 do
     begin
      D3DXVec3lerp(tmp,a1,a3,i/10);
      d3dxvec3scale(tmp2,n1,rnd);
      d3dxvec3add(tmp,tmp,tmp2);
      d3dxvec3transformcoord(v1,tmp,mfm);
      nonaninf(v1);

      rnd:=(random(100)-50)/300;
      if i=9 then rnd:=0;

      D3DXVec3lerp(tmp,a1,a3,i/10+0.1);
      d3dxvec3scale(tmp2,n1,rnd);
      d3dxvec3add(tmp,tmp,tmp2);
      d3dxvec3transformcoord(v2,tmp,mfm);
      nonaninf(v2);
      particlesystem_Add(fenycsikcreate(v1,v2,0.001,$FFFFFF,1));
     end;

     rnd:=0;
     for i:=0 to 9 do
     begin
      D3DXVec3lerp(tmp,a2,a4,i/10);
      d3dxvec3scale(tmp2,n2,rnd);
      d3dxvec3add(tmp,tmp,tmp2);
      d3dxvec3transformcoord(v1,tmp,mfm);
      nonaninf(v1);

      rnd:=(random(100)-50)/300;
      if i=9 then rnd:=0;

      D3DXVec3lerp(tmp,a2,a4,i/10+0.1);
      d3dxvec3scale(tmp2,n2,rnd);
      d3dxvec3add(tmp,tmp,tmp2);
      d3dxvec3transformcoord(v2,tmp,mfm);
      nonaninf(v2);
      particlesystem_Add(fenycsikcreate(v1,v2,0.001,$FFFFFF,1));
     end;
    end;
end;

procedure handleMMO;
begin

{  if (halal=0) and (not autoban) then
  begin
   MMO.mypos.pos:=posokvoltak[0]; //D3DXVector3(cpx^,cpy^,cpz^);
   MMO.myopos   :=D3DXVector3(cpox^,cpoy^,cpoz^);
   d3dxvec3lerp(MMO.myopos,posokvoltak[0],posokvoltak[high(posokvoltak)],1/high(posokvoltak));
   if length(chats[0])=0 then
   MMO.mypos.state:=mstat
   else
    MMO.mypos.state:=0;
  end
  else
  begin
   MMO.mypos.pos:=D3DXVector3(cpox^,-50,cpoz^);
   MMO.myopos   :=D3DXVector3(cpox^,-50,cpoz^);
   MMO.mypos.state:=0;
  end;

  MMO.mypos.irany:=szogx;
  MMO.mypos.irany2:=szogy;
  MMO.getdatafromcar(tegla.pos,tegla.vpos,tegla.axes,autoban,tegla.disabled);
  if kuldd+1000<timegettime then
   kuldd:=timegettime;

  MMO.mynez1:=campos;
  d3dxvec3add(MMO.mynez2,campos,D3DXVector3(sin(szogx)*cos(szogy)*200,sin(szogy)*200,cos(szogx)*cos(szogy)*200));
 }
  //!TODO update
  //!TODO kick
  //!TODO weather
  //!TODO medal
  //!TODO kill
end;

procedure handleMMOcars;
var
i:integer;
pos1,pos2:TD3DXvector3;
begin
 while high(ppl)>high(tobbiekautoi) do
 begin
  setlength(tobbiekautoi,length(tobbiekautoi)+1);
  tobbiekautoi[high(tobbiekautoi)]:=Tauto.create(d3dxvector3(2.3,0,0),d3dxvector3(0,0,-1.3),d3dxvector3(0,-0.7,0),d3dxvector3zero,d3dxvector3zero,0.2,0.99,hummkerekarr,0.5,0.5,0.2,false);
 end; 
 for i:=0 to high(ppl) do
 with tobbiekautoi[i] do
 begin

  if ppl[i].net.avtim=0 then ppl[i].net.avtim:=10;
  disabled:=ppl[i].auto.pos.y<2;

  if disabled then continue;
  d3dxvec3lerp(axes[0],ppl[i].auto.vaxes[0],ppl[i].auto.axes[0],min(ppl[i].net.amtim*10/ppl[i].net.avtim,1));
  d3dxvec3lerp(axes[1],ppl[i].auto.vaxes[1],ppl[i].auto.axes[1],min(ppl[i].net.amtim*10/ppl[i].net.avtim,1));
  d3dxvec3lerp(axes[2],ppl[i].auto.vaxes[2],ppl[i].auto.axes[2],min(ppl[i].net.amtim*10/ppl[i].net.avtim,1));

  d3dxvec3lerp(pos1,ppl[i].auto.opos ,ppl[i].auto.pos ,1+ppl[i].net.amtim/10);
  d3dxvec3lerp(pos2,ppl[i].auto.oposx,ppl[i].auto.posx,1+(ppl[i].net.amtim+ppl[i].net.amtim2)/10);
  vpos:=pos;
  d3dxvec3lerp(pos,pos2,pos1,max((ppl[i].net.amtim)/500,1));
  agx:=ppl[i].pls.fegyv>127;
  initkerekek;
 end;
end;

procedure undebug_memory2;
var
virt:pdword;
begin
{$IFDEF undebug}
  {windows féle debug kiiktatása}
 virt:=nil;
 try
  virt:=virtualalloc(nil,4,MEM_COMMIT+MEM_RESERVE,PAGE_NOACCESS);
  {noacces-es memóriadebug tesztelése}
  virt^:=$13370000;
  cpy^:=10000000;
 except
 end;
  virtualfree(virt,0,MEM_RELEASE);
 {$ENDIF}
end;


procedure handleSounds;
var
i,j,k:integer;
id:cardinal;
abuft:byte;
hol,tmp:TD3DXVector3;
tt:single;
sorrend:array [0..2] of shortint;
sortav:array [0..2] of single;
begin
 laststate:='HandleDS';
 hol:=campos;
 if gugg then hol.y:=hol.y-0.5;
  PlaceListener(hol,szogx,szogy);



 if ((mstat and  MSTAT_MASK)>0) and (halal=0) then
 begin
  playsound(1,false,25,true,D3DXvector3(cpx^,cpy^,cpz^)) ;
  if (mstat and MSTAT_MASK)=(MSTAT_FUT) then setSoundProperties(1,25,0,40000,true,D3DXVector3Zero)
  else
  if (mstat and MSTAT_GUGGOL)>0 then SetSoundProperties(1,25,-2000,16000,true,D3DXVector3Zero)
  else
  SetSoundProperties(1,25,-1000,0,true,D3DXVector3Zero)
 end
 else
 stopsound(1,25);

 if myfegyv=FEGYV_NOOB then
  if lovok>0 then
  begin
   playsound(15,false,25,true,D3DXvector3(cpx^,cpy^,cpz^)) ;
   SetSoundProperties(15,25,0,round(100000*lovok),true,D3DXVector3Zero);
  end
  else
   stopSound(15,25);

 //Legközelebbi 3

 for i:=0 to high(sorrend) do
 begin
  sorrend[i]:=-1;
  sortav[i]:=100000;
 end;

 for i:=0 to high(ppl) do
 begin
  tt:=tavpointpointsq(ppl[i].pos.pos,hol);
  if (ppl[i].pos.state and  MSTAT_MASK)=0 then tt:=tt+1000000;
  for j:=0 to high(sorrend) do
  begin
   if tt<sortav[j] then
   begin
    for k:=high(sorrend) downto j+1 do
    begin
     sortav[k]:=sortav[k-1];
     sorrend[k]:=sorrend[k-1];
    end;
    sortav[j]:=tt;
    sorrend[j]:=i;
    break;
   end;
  end;
 end;


 for i:=0 to high(sorrend) do
 if sorrend[i]>=0 then
 begin
  id:=i;
  if (ppl[sorrend[i]].pos.state and  MSTAT_MASK)>0 then
  begin
   //id:=ppl[i].sin_addr.S_addr xor ppl[i].sin_port shl 15;
   playsound(1,false,id,true,ppl[sorrend[i]].pos.pos);
   if (ppl[sorrend[i]].pos.state and MSTAT_MASK)=(MSTAT_FUT) then SetSoundProperties(1,id,0,40000,true,D3DXVector3Zero)
   else
    if (ppl[sorrend[i]].pos.state and MSTAT_GUGGOL)>0 then SetSoundProperties(1,id,-2000,16000,true,D3DXVector3Zero)
    else
     SetSoundProperties(1,id,-1000,0,true,D3DXVector3Zero)
  end
  else
   stopSound(1,id);
 end
 else
   stopSound(1,i);

 //AI
  for i:=0 to high(sorrend) do
 begin
  sorrend[i]:=-1;
  sortav[i]:=100000;
 end;


 //Rakéták

 for i:=0 to 2 do
 begin
  sorrend[i]:=-1;
  sortav[i]:=100000;
 end;

 //Legközelebbi 3
 for i:=0 to high(lawproj) do
 begin
  tt:=tavpointpointsq(lawproj[i].v1,hol);
  for j:=0 to 2 do
  begin
   if tt<sortav[j] then
   begin
    for k:=high(sorrend) downto j+1 do
    begin
     sortav[k]:=sortav[k-1];
     sorrend[k]:=sorrend[k-1];
    end;
    sortav[j]:=tt;
    sorrend[j]:=i;
    break;
   end;
  end;
 end;
 
 for i:=0 to 2 do
 if sorrend[i]>=0 then
 begin
  //d3dxvec3lerp(tmp,hol,lawproj[sorrend[i]].v1,0.3);
  playsound(16,false,i,false,lawproj[sorrend[i]].v1);
  d3dxvec3subtract(tmp,lawproj[sorrend[i]].v2,lawproj[sorrend[i]].v1);
  d3dxvec3scale(tmp,tmp,-100);
  setsoundvelocity(16,i,tmp);
  undebug_memory2;
 end
  else
   StopSound(16,i);

 //Noobgolyók

 for i:=0 to 2 do
 begin
  sorrend[i]:=-1;
  sortav[i]:=100000;
 end;

 //Legközelebbi 6
 for i:=0 to high(noobproj) do
 begin
  tt:=tavpointpointsq(noobproj[i].v1,hol);
  for j:=0 to 2 do
  begin
   if tt<sortav[j] then
   begin
    for k:=high(sorrend) downto j+1 do
    begin
     sortav[k]:=sortav[k-1];
     sorrend[k]:=sorrend[k-1];
    end;
    sortav[j]:=tt;
    sorrend[j]:=i;
    break;
   end;
  end;
 end;

 for i:=0 to 2 do
 if sorrend[i]>=0 then
 begin
  //d3dxvec3lerp(tmp,hol,noobproj[sorrend[i]].v1,0.3);
  playsound(15,false,i,false,noobproj[sorrend[i]].v1);
  setsoundproperties(15,i,0,40000,false,d3dxvector3zero);
  d3dxvec3subtract(tmp,noobproj[sorrend[i]].v2,noobproj[sorrend[i]].v1);
  d3dxvec3scale(tmp,tmp,-100);
  setsoundvelocity(15,i,tmp);
 end
  else
   StopSound(15,i);


 //Humi
 //Legközelebbi 3
 for i:=0 to 2 do
 begin
  sorrend[i]:=-1;
  sortav[i]:=100000;
 end;

 for i:=0 to min(high(tobbiekautoi),high(ppl)) do
 begin
  if tobbiekautoi[i].agx then continue;
  if tobbiekautoi[i].disabled  then continue;
  tt:=tavpointpointsq(tobbiekautoi[i].pos,hol);
  for j:=0 to 2 do
  begin
   if tt<sortav[j] then
   begin
    for k:=2 downto j+1 do
    begin
     sortav[k]:=sortav[k-1];
     sorrend[k]:=sorrend[k-1];
    end;
    sortav[j]:=tt;
    sorrend[j]:=i;
    break;
   end;
  end;
 end;

 for i:=0 to 2 do
 begin
  if sorrend[i]>=0 then
  begin
   playsound(8,false,i,false,tobbiekautoi[sorrend[i]].pos);
    SetSoundProperties(8,i,0,round((0.3+min(tavpointpoint(tobbiekautoi[sorrend[i]].pos,tobbiekautoi[sorrend[i]].vpos),0.25))*50000),true,D3DXVector3Zero);
  end
   else
    StopSound(8,i);
 end;

 //Antigrav
  for i:=0 to 2 do
 begin
  sorrend[i]:=-1;
  sortav[i]:=100000;
 end;

 for i:=0 to min(high(tobbiekautoi),high(ppl)) do
 begin
  if not tobbiekautoi[i].agx then continue;
    if tobbiekautoi[i].disabled  then continue;
  tt:=tavpointpointsq(tobbiekautoi[i].pos,hol);
  for j:=0 to 2 do
  begin
   if tt<sortav[j] then
   begin
    for k:=2 downto j+1 do
    begin
     sortav[k]:=sortav[k-1];
     sorrend[k]:=sorrend[k-1];
    end;
    sortav[j]:=tt;
    sorrend[j]:=i;
    break;
   end;
  end;
 end;

 for i:=0 to 2 do
 begin
  if sorrend[i]>=0 then
  begin
   playsound(7,false,i,false,tobbiekautoi[sorrend[i]].pos);
    SetSoundProperties(7,i,0,round((0.3+min(tavpointpoint(tobbiekautoi[sorrend[i]].pos,tobbiekautoi[sorrend[i]].vpos),0.25))*50000),true,D3DXVector3Zero);
  end
   else
    StopSound(7,i);
 end;

 //Player mozgás

 if (playrocks>0) and (halal=0) then
 begin
  playsound(2,false,25,true,D3DXvector3(cpx^,cpy^,cpz^));
  SetSoundProperties(2,25,round(-2000*(1-playrocks)),round(playrocks*22000),true,D3DXVector3Zero)
 end
 else
   StopSound(2,25);
 if (vizben>0) and (halal=0) then
 begin
  playsound(3,false,25,true,D3DXvector3(cpx^,cpy^,cpz^));
  SetSoundProperties(3,25,round(-2000*(1.7-vizben)),round(20000+vizben*2000),true,D3DXVector3Zero)
 end
 else
   StopSound(3,25);

 if myfegyv<128 then abuft:=8 else abuft:=7;

 if not tegla.disabled then
 begin
  playsound(abuft,true,125,true,tegla.pos);
  SetSoundProperties(abuft,125,0,round((0.3+min(tavpointpoint(tegla.pos,tegla.vpos),0.25))*50000),true,D3DXVector3Zero);
 end
 else
  StopSound(abuft,125);

 StopSound(15-abuft,125);

 if felho.coverage<=5 then
 begin
  playsound(12,true,125,true,D3DXVector3Zero);
  SetSoundProperties(12,125,round(-1200-felho.coverage*400),0,true,D3DXVector3Zero);
 end
 else
  StopSound(12,125);

 if villambol>50 then
  playsound(13,false,12,true,D3DXVector3Zero);

 //re_sound;

  laststate:='CommitDeferredSoundstuff';
  CommitDeferredSoundStuff;
  laststate:='HandleDS vége';
end;


procedure setupmyfegyvprojmat;
begin
{ if (not csipo) and (myfegyv=FEGYV_MP5A3) and (halal=0) then
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/4, 4/3, 0.1, 2000.0)
 else  }
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/3, 4/3, 0.05, 2000.0);
  g_pd3dDevice.SetTransform(D3DTS_PROJECTION, matProj);
end;

procedure setupprojmat;
begin
 if (not csipo) and (myfegyv=FEGYV_MP5A3) and (halal=0) then
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/MP5_NAGYITAS, 4/3, 0.05, 1100.0)
 else
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/3, 4/3, 0.05, 1100.0);
 g_pd3dDevice.SetTransform(D3DTS_PROJECTION, matProj);
end;

procedure SetupMatrices(nvm:boolean);
var
  matWorld,mat: TD3DMatrix;
  vEyePt, vLookatPt, vUpVec2,v2: TD3DVector;
  rbid:integer;
  i,j:integer;
  acpx,acpy,acpz:single;
//  i:integer;
begin
  acpx:=ccpx;
  acpy:=ccpy;
  acpz:=ccpz;

  // For our world matrix, we will just leave it as the identity
  D3DXMatrixIdentity(matWorld);

  g_pd3dDevice.SetTransform(D3DTS_WORLD, matWorld);
  // Set up our view matrix. A view matrix can be defined given an eye point,
  // a point to lookat, and a direction for which way is up. Here, we set the
  // eye five units back along the z-axis and up three units, look at the
  // origin, and define "up" to be in the y-direction.
  vEyePt:=    D3DXVector3(acpx+halal, acpy+1.5+halal/3,acpz+halal);
  if kulsonezet then
   vEyePt:=    D3DXVector3(acpx-sin(szogx)*cos(szogy)*15, acpy+1.5-sin(szogy)*15,acpz-cos(szogx)*cos(szogy)*15);

  vLookatPt:= D3DXVector3(acpx+sin(szogx)*cos(szogy), acpy+1.5+sin(szogy),cos(szogx)*cos(szogy)+acpz);
  if halal>0 then
  begin
   rbid:=getrongybababyID(0);
   if rbid>=0 then
   begin
   { vlookatpt:=rongybabak[rbid].gmbk[10];
    d3dxvec3add(veyept,rongybabak[rbid].gmbk[10],d3dxvector3(halal,halal/2,halal)); }
    vlookatpt:=d3dxvector3(acpx,acpy,acpz);
    d3dxvec3add(veyept,vlookatpt,
                D3DXVector3(-sin(szogx)*cos(szogy)*halal, -sin(szogy)*halal,-cos(szogx)*cos(szogy)*halal));

   end else
   begin
    vlookatPt:=D3DXVector3(acpx,acpy+1.5,acpz);
    d3dxvec3add(veyept,vlookatpt,
                D3DXVector3(-sin(szogx)*cos(szogy)*halal, -sin(szogy)*halal,-cos(szogx)*cos(szogy)*halal));
   end;
  end else
  if gugg and (halal=0) then
  begin
   vEyePt.y:=vEyePt.y-0.5;
   vLookatPt.y:=vLookatPt.y-0.5;
  end;

  if (halal>0) or kulsonezet then
  begin
   vlookatpt.y:=vlookatpt.y+0.1;
   constraintvec(vlookatpt);
   constraintvec(veyept);
   veyept.y:=veyept.y-0.2;
   if raytestlvl(vlookatpt,veyept,10,v2) then veyept:=v2;

   if tavpointpointsq(vlookatpt,veyept)>sqr(0.1) then
   begin

    for j:=0 to high(ojjektumnevek) do
     for i:=0 to ojjektumarr[j].hvszam-1 do
      veyept:=ojjektumarr[j].raytest(vlookatpt,veyept,i);
      
    d3dxvec3lerp(veyept,veyept,vlookatpt,0.3);
   end
   else
   begin
    vlookatpt:=D3DXVector3zero;

   end;
      veyept.y:=veyept.y+0.2;
  end;

  vUpVec2:=    D3DXVector3(0.0, 1.0, 0.0);

  if rezg>0 then
  randomplus(veyept,animstat*100,rezg/100);

  if mapmode>0 then
  begin
   d3dxvec3lerp(vEyept,vEyePt,D3DXVector3(acpx,500,acpz),mapmode);
   d3dxvec3lerp(vLookatpt,vLookatPt,D3DXVector3(acpx,497,acpz),mapmode);
   d3dxvec3lerp(vUpVec2,vUpVec2,D3DXVector3(sin(szogx),0,cos(szogx)),mapmode);
  end;

    D3DXMatrixLookAtLH(matView, vEyePt, vLookatPt, vUpVec2);

  if nvm then begin
   matView._41:=0;   matView._42:=0;   matView._43:=0;
   end;

  g_pd3dDevice.SetTransform(D3DTS_VIEW, matView);

  if not nvm then
  begin
    d3dxmatrixinverse(mat,nil,matView);

  d3dxvec3transformcoord(campos,d3dxvector3(0,0,0.01),mat);
  D3DXVec3normalize(upvec,D3DXVector3(mat._11,mat._12,mat._13));
  D3DXVec3normalize(lvec,D3DXVector3(mat._21,mat._22,mat._23));
  end;

  // For the projection matrix, we set up a perspective transform (which
  // transforms geometry from 3D view space to 2D viewport space, with
  // a perspective divide making objects smaller in the distance). To build
  // a perpsective transform, we need the field of view (1/4 pi is common),
  // the aspect ratio, and the near and far clipping planes (which define at
  // what distances geometry should be no longer be rendered).

  if (not csipo) and (myfegyv=FEGYV_M82A1) and (halal=0) then
  begin
   D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/16, 4/3, 0.1, 1100.0);
   frust:=frustum(matview,0.1,1100,D3DX_PI/16, 4/3);
  end
  else
  if (not csipo) and (myfegyv=FEGYV_MP5A3) and (halal=0) then
  begin
   D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/MP5_NAGYITAS, 4/3, 0.05, 1100.0);
   frust:=frustum(matview,0.1,1100,D3DX_PI/MP5_NAGYITAS, 4/3);
  end
  else
  begin
   D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/3, 4/3, 0.05, 1100.0);
   frust:=frustum(matview,0.1,1100,D3DX_PI/3, 4/3);
  end;

  g_pd3dDevice.SetTransform(D3DTS_PROJECTION, matProj);

  g_pd3dDevice.SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR );
  g_pd3dDevice.SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR );
  g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
  g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_WRAP);
  g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_WRAP);
  g_pd3dDevice.SetSamplerState(1, D3DSAMP_MINFILTER, D3DTEXF_LINEAR );
  g_pd3dDevice.SetSamplerState(1, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR );
  g_pd3dDevice.SetSamplerState(1, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR );
  g_pd3dDevice.SetSamplerState(1, D3DSAMP_ADDRESSU,  D3DTADDRESS_WRAP);
  g_pd3dDevice.SetSamplerState(1, D3DSAMP_ADDRESSV,  D3DTADDRESS_WRAP);
  g_pd3dDevice.SetSamplerState(2, D3DSAMP_MINFILTER, D3DTEXF_LINEAR );
  g_pd3dDevice.SetSamplerState(2, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR );
  g_pd3dDevice.SetSamplerState(2, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR );
  g_pd3dDevice.SetSamplerState(2, D3DSAMP_ADDRESSU,  D3DTADDRESS_WRAP);
  g_pd3dDevice.SetSamplerState(2, D3DSAMP_ADDRESSV,  D3DTADDRESS_WRAP);
end;

procedure rendersky;
var
i:integer;
begin
 g_pd3dDevice.SetRenderState(D3DRS_LIGHTING,ifalse);
  fogc:=felho.coverage/13;
  if fogc>1 then fogc:=1;
 g_pd3dDevice.SetRenderState(D3DRS_FOGCOLOR,
                               colorlerp($FF909090,$FFFFF2C5,fogc));

  g_pd3dDevice.SetRenderState(D3DRS_RANGEFOGENABLE,itrue);
  g_pd3dDevice.SetRenderState(D3DRS_FOGVERTEXMODE,D3DFOG_LINEAR);

 fogstart:=800;fogend:=900;

  g_pd3dDevice.SetRenderState(D3DRS_FOGSTART,singletodword(FogStart));
  g_pd3dDevice.SetRenderState(D3DRS_FOGEND,singletodword(FogEnd));

 g_pd3dDevice.SetRenderState(D3DRS_ZFUNC, D3DCMP_ALWAYS);
 g_pd3dDevice.SetRenderState(D3DRS_ZWRITEENABLE, iTrue);
 g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);
  g_pd3dDevice.SetRenderState(D3DRS_ALPHATESTENABLE, iFalse);

 //if (halal=0) or (halal>2.5) then
 g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
 g_pd3dDevice.SetFVF(D3DFVF_SKYVERTEX);

 g_pd3dDevice.SetTexture(0,skytex);
 //g_pd3dDevice.SetTexture(0,felho.tex1);

 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   FAKE_HDR);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP,   D3DTOP_DISABLE);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
 g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_NONE);
  g_pd3dDevice.SetRenderState(D3DRS_FOGENABLE,ifalse);
  g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_CLAMP);
  g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_CLAMP);
 for i:=0 to high(skystrips) do
  g_pd3ddevice.drawprimitiveUP(D3DPT_TRIANGLESTRIP,high(skystrips[i]) div 2+1,skystrips[i][0],sizeof(TSkyvertex));
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_WRAP);
  g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_WRAP);


 
  felho.render(cpy^>100);
 // felho.render(false);
 g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
 g_pd3dDevice.SetRenderState(D3DRS_ZFUNC, D3DCMP_LESSEQUAL);
  g_pd3dDevice.SetRenderState(D3DRS_ZWRITEENABLE, iTrue);
  g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iTrue);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_MODULATE);
   // And some fog

  g_pd3dDevice.SetRenderState(D3DRS_FOGENABLE,itrue);
  fogstart:=20;fogend:=lerp(600,900,fogc);


 if mapmode>0 then
 begin
  fogend:=fogend+mapmode*1000;
 end;

  g_pd3dDevice.SetRenderState(D3DRS_FOGSTART,singletodword(FogStart));
  g_pd3dDevice.SetRenderState(D3DRS_FOGEND,singletodword(FogEnd));


end;





procedure Handlelovesek;
var
i,love:integer;
aloves:Tloves;
tmp:TD3DXVector3;
dst:single;
atc:cardinal;
gtc:cardinal;
snd:byte;
begin
 SetupMyMuksmatr;
 gtc:=timegettime;
 for i:=0 to high(lovesek) do
 begin
  aloves:=lovesek[i];
  constraintvec(aloves.pos);
  constraintvec(aloves.v2);
  {for j:=0 to bunker.hvszam-1 do
   aloves.v2:=bunker.raytest(aloves.pos,aloves.v2,j);
  for k:=0 to high(ojjektumnevek) do
   for j:=0 to ojjektumarr[k].hvszam-1 do
   aloves.v2:=ojjektumarr[k].raytest(aloves.pos,aloves.v2,j);
  if raytestlvl(aloves.pos,aloves.v2,500,tmp) then aloves.v2:=tmp; }
 { d3dxvec3subtract(tmp,aloves.v2,aloves.pos);
  fastvec3normalize(tmp);
  Particlesystem_add(Gunmuzzcreate(aloves.pos,tmp,3));
  }

  case aloves.fegyv of                                                         //////
   FEGYV_M4A1,FEGYV_M82A1,FEGYV_MP5A3:Particlesystem_add(Bulletcreate(aloves.pos,aloves.v2,3,5,0.01,$00A0A050,1));
   FEGYV_MPG:particle_special_mpg(aloves.pos,aloves.v2);
   FEGYV_QUAD:particle_special_quad(aloves.pos,aloves.v2);
   FEGYV_LAW:AddLAW(aloves.pos,aloves.v2,aloves.kilotte);
   FEGYV_NOOB:AddNOOB(aloves.pos,aloves.v2,aloves.kilotte);
   FEGYV_X72:AddX72(aloves.pos,aloves.v2,aloves.kilotte);
   //Particlesystem_add(MPGcreate(aloves.pos,aloves.v2,1.5,$0000A0FF));
  end;


  case aloves.fegyv of
   FEGYV_MPG:playsound(4,false,gtc,true,aloves.pos);
   FEGYV_M82A1:playsound(5,false,gtc,true,aloves.pos);
   FEGYV_M4A1:playsound(0,false,gtc,true,aloves.pos);
   FEGYV_QUAD:playsound(6,false,gtc,true,aloves.pos);
   FEGYV_NOOB:playsound(18,false,gtc,true,aloves.pos);
   FEGYV_LAW:playsound(20,false,gtc,true,aloves.pos);
   FEGYV_X72:playsound(23,false,gtc,true,aloves.pos);
   FEGYV_MP5A3:playsound(22,false,gtc,true,aloves.pos);
   else
    playsound(0,false,gtc,true,aloves.pos);
  end;
                                             
  if ((aloves.fegyv=FEGYV_M4A1) or (aloves.fegyv=FEGYV_M82A1)
   or (aloves.fegyv=FEGYV_QUAD) or (aloves.fegyv=FEGYV_MPG))
     and ((myfegyv xor aloves.fegyv)>=128) then
  begin
   //vEyePt:= D3DXVector3(cpx^, cpy^+1.5,cpz^);
   atc:=timegettime+random(2000);
   //if gugg then veyept.y:=veyept.y-0.5;
   if tavpointlinesq(campos,aloves.pos,aloves.v2,tmp,dst) then
   if dst<25 then
   begin
    if aloves.fegyv>127 then snd:=27 else snd:=14;
    playsound(snd,false,atc,true,tmp);
    SetSoundProperties(snd,atc,1,15000+random(10000),true,tmp);
    if (aloves.fegyv xor myfegyv)>=128 then
    inc(zeneintensity,300);
    rezg:=max(rezg,(25-dst)/20);
   end;
  end;

  dst:=tavpointpointsq(campos,aloves.pos);
  if (aloves.fegyv xor myfegyv)>=128 then
   if dst<sqr(50) then
    inc(zeneintensity,sqr(50)-round(dst));

  love:=-1;

   // !!!!!!!!!!!!!!!!!!!!!
  if (aloves.fegyv>=128) xor (myfegyv<128) then love:=-1 else
  case aloves.fegyv of
   FEGYV_M4A1,FEGYV_M82A1:love:=meglove(muks.gmbk,muks.kapcsk,aloves.pos,aloves.v2,vst);
   FEGYV_MPG: love:=meglove(muks.gmbk,muks.kapcsk,aloves.pos,aloves.v2,0.15);
   FEGYV_QUAD: love:=meglove(muks.gmbk,muks.kapcsk,aloves.pos,aloves.v2,0.15);
   FEGYV_MP5A3: love:=meglove(muks.gmbk,muks.kapcsk,aloves.pos,aloves.v2,0.02);
  end;

  {if  ((aloves.fegyv=FEGYV_QUAD) or (aloves.fegyv=FEGYV_MPG)) then
  begin
   if aloves.fegyv=FEGYV_QUAD then
    handlepajzsok(aloves.pos,aloves.v2,1000)
   else
    handlepajzsok(aloves.pos,aloves.v2,3000);
   if (energy>0) and (myfegyv=FEGYV_FLAMETHROWER) then love:=-1;
  end;   }

  if (aloves.fegyv<>FEGYV_LAW) and (aloves.fegyv<>FEGYV_NOOB) and (aloves.fegyv<>FEGYV_X72) then
  if tavpointpointsq(aloves.v2,DNSvec)<sqr(DNSrad*0.95) then
   explosionripple(aloves.v2,false);

  {$IFNDEF aikovetes}
  {$IFNDEF godmode}
  {$IFNDEF aiparancsok}
  if invulntim=0 then
  if love>=0 then
   if halal=0 then
   begin

   halal:=1;
  // setupmymuksmatr;
   d3dxvec3subtract(tmp,aloves.v2,aloves.pos);
   if (aloves.fegyv=FEGYV_M82A1) or (aloves.fegyv=FEGYV_QUAD) then
    d3dxvec3scale(tmp,tmp,0.6/d3dxvec3length(tmp))
   else
    d3dxvec3scale(tmp,tmp,0.3/d3dxvec3length(tmp));

   constraintvec(tmp);
   addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),tmp,myfegyv,love,0,aloves.kilotte);
  end;
  {$ENDIF}
    {$ENDIF}
   {$ENDIF}
 end;
 
 setlength(lovesek,0);
end;

procedure handledoglodesek;
var
  matWorld,matWorld2: TD3DMatrix;
//  pos:TD3DVector;
  i:integer;
begin
 for i:=0 to high(hullak) do
 with hullak[i] do
 begin
  D3DXMatrixRotationY(matWorld2,irany+d3dx_pi);
  D3DXMatrixTranslation(matWorld,apos.x,apos.y,apos.z);
  D3DXMatrixMultiply(matWorld,matWorld2,matWorld);
  mat_world:=matworld;

  muks.jkez:=fegyv.jkez(fegyver,state);
  muks.bkez:=fegyv.bkez(fegyver,state);

     case state and MSTAT_MASK of
      0:muks.stand((state and MSTAT_GUGGOL)>0);
      1:muks.Walk(animstate,(state and MSTAT_GUGGOL)>0);
      2:muks.Walk(1-animstate,(state and MSTAT_GUGGOL)>0);
      3:muks.SideWalk(animstate,(state and MSTAT_GUGGOL)>0);
      4:muks.SideWalk(1-animstate,(state and MSTAT_GUGGOL)>0);
      5:muks.Runn(animstate,true);
     end;
  addrongybaba(apos,vpos,gmbvec,fegyver,mlgmb,random(20000)+1,-1);
 end;
 setlength(hullak,0);
end;


procedure respawn;
type
 Tpszam = record
  pont:single;
  index:integer;
 end;
var
x,i,j:integer;
rnd:byte;
pontszam:array [0..100] of Tpszam;
tmp:Tpszam;
tmp2:single;
begin
 lastzone:='';
 multisc.killscamping:=multisc.kills;


 zonechanged:=0;
 invulntim:=300;
 autoban:=false;
 vanishcar:=1500;
 kulsonezet:=false;
 mapmode:=0;
 mapbol:=false;
 halal:=0;
 multisc.killswithoutdeath :=multisc.kills;
{ rbid:=getrongybababyID(0);
 if rbid>=0 then
  delrongybaba(rbid);}

 { x:=pplhgh+2;
 cpx^:=10*x-random(20*x);
 cpz^:=10*x-random(20*x);
 cpy^:=advwove(cpx^,cpz^);  }


 for i:=0 to ojjektumarr[0].hvszam-1 do
 begin
  pontszam[i].index:=i;
  pontszam[i].pont:=random(50);
  for j:=0 to high(ppl) do
  begin
   constraintvec(ppl[j].pos.pos);
   if ppl[j].pos.pos.y>5 then
   begin
    tmp2:=100-tavpointpoint(ojjektumarr[0].holvannak[i],ppl[j].pos.pos);
    if tmp2<0 then tmp2:=0;
    if (ppl[j].pls.fegyv xor myfegyv)>128 then
     pontszam[i].pont:=pontszam[i].pont+tmp2
    else
     pontszam[i].pont:=pontszam[i].pont-tmp2;

   end;
  end;
 end;

 for i:=0 to ojjektumarr[0].hvszam-2 do
  for j:=i+1 to ojjektumarr[0].hvszam-1 do
  if pontszam[i].pont<pontszam[j].pont then
  begin
   tmp:=pontszam[i];
   pontszam[i]:=pontszam[j];
   pontszam[j]:=tmp;
  end;

 rnd:=pontszam[1].index;
 with ojjektumarr[0] do
 begin
 cpx^:=holvannak[rnd].x+rad*(random(10000)/5000-1)/4;
 cpy^:=holvannak[rnd].y+rad+2;
 cpz^:=holvannak[rnd].z+rad*(random(10000)/5000-1)/4;
  end;
 NoNANINF(cpx^); NoNANINF(cpy^); NoNANINF(cpz^);

 szogx:=0;
 szogy:=0;
 cpox^:=cpx^;cpoy^:=cpy^;cpoz^:=cpz^;

 cmz:=round(cpz^/pow2[lvlmin]);
 cmx:=round(cpx^/pow2[lvlmin]);

 for x:=lvlmax downto lvlmin do
 begin
   laststate:='respawn: upatelvl'+inttostr(x);
   remakelvl(x);
   if timegettime>(kuldd+50) then
   begin
    //!TODO MMO.Update(0,0,0,0,0,0...)
    kuldd:=timegettime;
   end;
 end;
 updateterrain;

 Dine.Update(point(400,400));
 Dine.Update(point(400,400));

 hanyszor:=(timegettime div 10) +1;
 hvolt:=true;

 csipo:=true;
end;

function vizvertex(xp,zp:single):TCustomvertex;
begin
 result:=CustomVertex(cpx^+xp*1500,10.1+singtc/10,cpz^+zp*1500,0,1,0,$7F7F7F7F,(cpx^+xp*1500)/3+singtc,(cpz^+zp*1500)/3+cosgtc+plsgtc,(cpx^+xp*1500)/6-singtc/3+plsgtc/3,(cpz^+zp*1500)/6-cosgtc/3);
end;

procedure renderviz;
var
viz:array [0..9] of TCustomVertex;
tmplw:longword;
matViewProj,matKorr,matkorr2:TD3DMatrix;
begin
 g_pd3dDevice.SetRenderState(D3DRS_FOGENABLE,itrue);
 if not( (G_peffect<>nil) and (opt_detail>=DETAIL_VIZ) )then
     g_pd3ddevice.SetRenderState(D3DRS_ZWRITEENABLE,itrue);
 if ((cpy^<40) or (opt_detail>=DETAIL_VIZ)) and (mapmode=0) then
 begin
 singtc:=sin((volttim mod 15000)*D3DX_PI*2/15000);
 cosgtc:=cos((volttim mod 15000)*D3DX_PI*2/15000);
 plsgtc:=(volttim mod 20000)/20000;
 end;
 viz[0]:=vizvertex(0,0);
 //viz[0].position.y:=10.1;
 viz[1]:=vizvertex(1,0);
 viz[2]:=vizvertex(1,1);
 viz[3]:=vizvertex(0,1);
 viz[4]:=vizvertex(-1,1);
 viz[5]:=vizvertex(-1,0);
 viz[6]:=vizvertex(-1,-1);
 viz[7]:=vizvertex(0,-1);
 viz[8]:=vizvertex(1,-1);
 viz[9]:=vizvertex(1,0);
 //{
 g_pd3dDevice.SetTexture(0,viztex);
 g_pd3dDevice.SetTexture(1,viztex);

 g_pd3dDevice.SetSamplerState(1, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR );
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_SELECTARG1);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, FAKE_HDR);

 g_pd3ddevice.drawprimitiveUP(D3DPT_TRIANGLEFAN,8,viz,sizeof(TCustomvertex));
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
      //}
      //{

 if (G_peffect<>nil) and (opt_detail>=DETAIL_VIZ) then
    begin
      g_peffect.SetTechnique('WaterReflection');
     matkorr:=D3DXMatrix(0.5,   0,  0,0,
                         0  ,-0.5,  0,0,
                         0  ,   0,  1,0,
                         0.5, 0.5,  0,1);

     d3dxmatrixmultiply(matViewproj,matView,matProj);
     d3dxmatrixmultiply(matkorr2,matProj,matKorr);

     g_pEffect.SetMatrix('g_mWorldViewProjection', matViewproj);
     g_pEffect.SetMatrix('g_mWorldView', matView);
     g_pEffect.SetMatrix('g_mProjectionKorr', matKorr2);
     g_pEffect.SetTexture('g_MeshTexture', reflecttexture);
     g_pEffect.SetTexture('g_Wavemap', waterbumpmap);
     
     g_peffect._Begin(@tmplw,0);
     g_peffect.BeginPass(0);
     g_pd3ddevice.SetRenderState(D3DRS_ZWRITEENABLE,itrue);
     //g_pd3ddevice.SetRenderState(D3DRS_ALPHABLENDENABLE,iFalse);
     g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
     g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,  D3DBLEND_INVSRCALPHA);
     g_pd3ddevice.SetRenderState(D3DRS_LIGHTING,ifalse);
     g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE,iFalse);
      g_pd3ddevice.drawprimitiveUP(D3DPT_TRIANGLEFAN,8,viz,sizeof(TCustomvertex));
     g_peffect.Endpass;
     g_peffect._end;
    end;  // }
 g_pd3ddevice.SetRenderState(D3DRS_ALPHABLENDENABLE,itrue);
 g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE,itrue);
 g_pd3ddevice.SetRenderState(D3DRS_ZWRITEENABLE,ifalse);
end;


procedure initHUD;
begin
 menu.g_pSprite._Begin(D3DXSPRITE_ALPHABLEND+D3DXSPRITE_SORT_TEXTURE);
end;

procedure ShowDepthComplexity;
var
v:array [1..4] of TD3DXVector3;
begin
  v[2] := D3DXVector3( 0.1, 0.1,0.2);
  v[3] := D3DXVector3( -0.1,-0.1,0.2);
  v[1] := D3DXVector3( -0.1, 0.1,0.2);
  v[4] := D3DXVector3( 0.1,-0.1,0.2);
  // Turn off the buffer, and enable alpha blending
 g_pd3dDevice.SetRenderState(D3DRS_ZENABLE,          iFalse);

 g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
 g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_ONE);
 g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);

  // Set up the stencil states
 g_pd3dDevice.SetRenderState(D3DRS_STENCILZFAIL, D3DSTENCILOP_KEEP);
 g_pd3dDevice.SetRenderState(D3DRS_STENCILFAIL,  D3DSTENCILOP_KEEP);
 g_pd3dDevice.SetRenderState(D3DRS_STENCILPASS,  D3DSTENCILOP_KEEP);
 g_pd3dDevice.SetRenderState(D3DRS_STENCILFUNC,  D3DCMP_NOTEQUAL);
 g_pd3dDevice.SetRenderState(D3DRS_STENCILREF,   0);
 g_pd3dDevice.SetRenderState(D3DRS_CULLMODE,   D3DCULL_NONE);
  // Set the background to black
 //g_pd3dDevice.Clear(0, nil, D3DCLEAR_TARGET, $00000000, 1.0, 0);

  // Set render states for drawing a rectangle that covers the viewport.
  // The color of the rectangle will be passed in D3DRS_TEXTUREFACTOR
 g_pd3dDevice.SetFVF(D3DFVF_XYZ);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TFACTOR);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG1);

  // Draw a red rectangle wherever the 1st stencil bit is set
  g_pd3dDevice.SetRenderState(D3DRS_STENCILMASK, $01);
  g_pd3dDevice.SetRenderState(D3DRS_TEXTUREFACTOR, $ff202020);
 g_pd3dDevice.DrawPrimitiveUP(D3DPT_TRIANGLESTRIP, 2, v,sizeof(TD3DXVector3));


  // Draw a green rectangle wherever the 2nd stencil bit is set
  g_pd3dDevice.SetRenderState(D3DRS_STENCILMASK, $02);
  g_pd3dDevice.SetRenderState(D3DRS_TEXTUREFACTOR, $ff404040);
g_pd3dDevice.DrawPrimitiveUP(D3DPT_TRIANGLESTRIP, 2, v,sizeof(TD3DXVector3));


  // Draw a blue rectangle wherever the 3rd stencil bit is set
  g_pd3dDevice.SetRenderState(D3DRS_STENCILMASK, $04);
  g_pd3dDevice.SetRenderState(D3DRS_TEXTUREFACTOR, $ff808080);
 g_pd3dDevice.DrawPrimitiveUP(D3DPT_TRIANGLESTRIP, 2, v,sizeof(TD3DXVector3));

  // Restore states
 g_pd3dDevice.SetRenderState(D3DRS_ZENABLE,          iTrue);
 g_pd3dDevice.SetRenderState(D3DRS_STENCILENABLE,    iFalse);
 g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);
  g_pd3dDevice.SetRenderState(D3DRS_CULLMODE,   D3DCULL_CCW);
end;

function fegyvernev(mi:byte):string;
begin
case mi of
  FEGYV_M4A1:result:='<M4>';
  FEGYV_M82A1:result:='<M82>';
  FEGYV_LAW:result:='<LAW>';
  FEGYV_MPG:result:='<MPG>';
  FEGYV_QUAD:result:='<QUAD>';
  FEGYV_NOOB:result:='<NOOB>';
  FEGYV_X72:result:='<X72>';
  FEGYV_MP5A3:result:='<MP5>';
else
result:='<WTF>';
end;

end;

var
glob_dmh:single;

procedure Drawmessage(mit:string;szin:dword);
begin
  menu.drawtext(mit,0.1,glob_dmh,0.9,glob_dmh+0.1,1,szin);
  glob_dmh:=glob_dmh+0.05;
end;

procedure drawHUD;
const
avp:TD3DViewport9=(X:0;Y:0;width:0;Height:0;minZ:0;maxZ:1);
terkeptav=1.732050*1024*0.1;
var
viPo:TD3DViewport9;
i,j,gunsz,techsz:integer;
ar:array of string;
ac:array of string;
ap:array of TD3DXVector3;
ap2:array of TD3DXVector3;
aa:array of single;
vec,tmp,camvec:TD3DXvector3;
bol:boolean;
wo:TD3DMatrix;
txt:string;
mit:string;
sunhol:TD3DXVector3;
mv2:TD3DMatrix;
meret:single;
k1,k2:single;
aszin:cardinal;
cghash:cardinal;
bszvolt:cardinal;
arect:Trect;
killtmutat:boolean;
rendezve:array of integer;
rtmp:integer;
glph:array of Tglyph;
terkep1:TD3DXVector2;
terszog,tertav:single;
kisTAB:integer;
menuszor:single;
const
menuplus=0.2;

label
nosun;
begin

 glob_dmh:=0.2;
 vipo:=avp;
 vipo.Width:=SCwidth;
 vipo.Height:=SCheight;
 if (myfegyv=FEGYV_M82A1) and (not csipo) and (halal=0) then
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/16, 4/3, 0.1, 1000.0)
 else
  if (not csipo) and (myfegyv=FEGYV_MP5A3) and (halal=0) then
   D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/MP5_NAGYITAS, 4/3, 0.1, 1100.0)
 else
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/3, 4/3, 0.1, 1000.0);
  try
  if gugg then
   camvec:=d3dxvector3(cpx^,cpy^+1.0,cpz^)
  else
   camvec:=d3dxvector3(cpx^,cpy^+1.5,cpz^);

  noNANINF(camvec);
  vec:=D3DXVector3(camvec.x-700,camvec.y+595,camvec.z);

  bol:=true;
  if not raytestlvl(vec,camvec,10,tmp) then
  begin
   bol:=false;
   for i:=0 to high(ojjektumnevek) do
    for j:=0 to ojjektumarr[i].hvszam-1 do
     bol:=bol or ojjektumarr[i].raytestbol(vec,camvec,j);
  end;

  d3dxmatrixidentity(wo);
  if bol then goto nosun;


   d3dxvec3project(sunhol,vec,viPo,matProj,matview,wo);
   if noNANINF(sunhol) then goto nosun;
   if not( (sunhol.x>-20) and (sunhol.y>-20) and (sunhol.x<SCWidth+20) and (sunhol.y<SCHeight+20) and (sunhol.z<1) )then goto nosun;

    k1:=20;k2:=20;
    if sunhol.x<0 then k1:=sunhol.x+20;
    if sunhol.y<0 then k2:=sunhol.y+20;
    if sunhol.x>SCwidth then k1:=SCwidth+20-sunhol.x;
    if sunhol.y>SCheight then k2:=SCheight+20-sunhol.y;

    meret:=min(k1,k2)/40;
    with felho do
    meret:=lerp((colormap[(131+floor(hol*255)) and 255,118,3]/255)*16+1,
                (colormap[(131+ceil (hol*255)) and 255,118,3]/255)*16+1,hol*255-floor(hol*255))*meret;
    d3dxmatrixscaling(mv2,meret,meret,1);
    menu.g_pSprite.SetTransform(mv2);
    sunhol.z:=0;
    sunhol.x:=sunhol.x/meret;
    sunhol.y:=sunhol.y/meret;
    sunhol.x:=sunhol.x-32;
    sunhol.y:=sunhol.y-32;

    if currevent=nil then
    menu.g_pSprite.Draw(suntex,nil,nil,@sunhol,$FFFFFFFF);

  nosun:
  //d3dxmatrixidentity(mv2);
  menu.g_pSprite.SetTransform(identmatr);

 {$IFDEF noHUD}exit;{$ENDIF}
 {$IFNDEF AIparancsok}

 if currevent is TReactorEvent then
 begin
  if currevent.phs=10 then
  begin
   menu.DrawRect(0,0,1,1,$01000000*max(0,min(currevent.phstim*3-1500,255)));
   menu.g_psprite.Flush;
   exit;
  end;
  if currevent.phs=11 then
  begin
   menu.DrawRect(0,0,1,1,$FF000000);
   menu.g_psprite.Flush;
   menu.g_psprite.SetTransform(identmatr);
   aszin:=$FF000000+$010000*max(0,min(255,currevent.phstim-100));
   menu.DrawText('Stickman Warfare 2.0:',0.0,0.2,1,0.3,2,aszin);
   menu.DrawText('The Awakening',0.0,0.3,1,0.4,2,aszin);
   menu.DrawText('Available for download',0.0,0.5,1,0.6,2,aszin);
   exit;
  end;

 end;
 setlength(ar,length(ppl));
 setlength(ap,length(ppl));
 setlength(ap2,length(ppl));
 setlength(aa,length(ppl));
 setlength(ac,length(ppl));

 for i:=0 to high(ppl) do
 begin
  ar[i]:='';
  ac[i]:='';
     if (ppl[i].pos.pos.y<0.1) then
   if (ppl[i].auto.pos.y<0.1) then
   begin
    if ppl[i].pos.pos.y=0 then continue;
    ap[i]:=D3DXVector3(1,1,2);
    ap2[i]:=ap[i];
    continue;
   end
   else
    vec:=tobbiekautoi[i].pos
   else
  vec:=ppl[i].pos.megjpos;
  if abs(ppl[i].pos.pos.y-cpy^)>150  then
  begin
    if ppl[i].pos.megjpos.y<10 then continue;
    ap[i]:=D3DXVector3(1,1,2);
    ap2[i]:=ap[i];
    continue;
   end;
    bol:=true;
  if (vec.y<10) then
  begin
   bol:=false;
   vec:=D3DXVector3(0,100,0);
  end;

  if (ppl[i].pos.state and MSTAT_GUGGOL)>0 then
   vec.y:=vec.y+1.2
  else
   vec.y:=vec.y+1.7;
  vec.y:=vec.y+0.4;

  d3dxvec3transformcoord(sunhol,vec,matView);

  bol:=bol and (sunhol.z>1) and (sunhol.z<200);
  bol:=bol and (tavpointpointsq(camvec,vec)<sqr(200)) and (not raytestlvl(camvec,vec,5,tmp));
  bol:=bol or (mapmode>0);
  if not bol then
   vec:=D3DXVector3(0,100,0);

  if not((ppl[i].pls.fegyv>=128)  xor (myfegyv>=128)) then
   if ppl[i].pls.chttim<length(ppl[i].pls.utsocht)*15 then
      ac[i]:=ppl[i].pls.utsocht
    else
      ar[i]:= ppl[i].pls.nev;


  if bol then
  d3dxvec3project(ap[i],vec,viPo,matProj,matView,wo);
  ap2[i]:=ap[i];
  noNANinf(ap[i]);
  bol:=bol and (ap[i].z>0) and (ap[i].z<1);
  NoNANINF(vec);
  if bol then
  ap2[i].y:=ap2[i].y-30;
  noNANinf(ap2[i]);
  aa[i]:=max(0,1-tavpointpoint(ppl[i].pos.pos,camvec)/200);
  if (mapmode>0) then aa[i]:=1;
 end;


 if length(ar)>0 then
  menu.DrawTextsInGame(ar,ap,ap2,aa,false);
 //menu.drawrect(0.0,0.0,0.2,0.25,$A0000000);

 setlength(glph,2);
 glph[0].melyik:=1;
 glph[0].x:=726;
 glph[0].y:=75;

 glph[1].melyik:=0;
 glph[1].x:=726+cos(-szogx)*70;
 glph[1].y:=75+sin(-szogx)*70;

 for i:=0 to high(ppl) do
  if (ppl[i].pls.fegyv xor myfegyv)<128 then
  if (ppl[i].pos.megjpos.y>10) then
  if  ((sqr(ppl[i].pos.pos.x-cpx^)+sqr(ppl[i].pos.pos.z-cpz^))<sqr(terkeptav)) or (mapmode=1) then
  begin
   terkep1.x:=ppl[i].pos.pos.x-cpx^;
   terkep1.y:=ppl[i].pos.pos.z-cpz^;
   //terkep1.x:=0.00;
   //terkep1.y:=terkeptav/2;
   if terkep1.x<>0 then
    terszog:=arctan2(terkep1.y,terkep1.x)
   else
    if terkep1.y>0 then terszog:=D3DX_PI/2 else terszog:=-D3DX_PI/2;
   tertav:=sqrt((sqr(ppl[i].pos.pos.x-cpx^)+sqr(ppl[i].pos.pos.z-cpz^)))/terkeptav;
   terszog:=-terszog;
   setlength(glph,length(glph)+1);
   glph[high(glph)].melyik:=2;
   glph[high(glph)].x:=726+cos(terszog-szogx)*tertav*70;
   glph[high(glph)].y:=75+sin(terszog-szogx)*tertav*70;
   if mapmode=1 then
   begin
   glph[high(glph)].melyik:=2;
   glph[high(glph)].x:=400-1.15*(ppl[i].pos.megjpos.z-cpz^);
   glph[high(glph)].y:=300-1.15*(ppl[i].pos.megjpos.x-cpx^);
   end;
  end;


 menu.g_pSprite.SetTransform(identmatr);

 menu.DrawGlyphsInGame(glph);

 txt:=lang[33]+servername+':';
 if multisc.playersonserver<=0 then txt:=txt+lang[34]
 else
 txt:=txt+inttostr(multisc.playersonserver);

 techsz:=0;gunsz:=0;
 for i:=0 to high(ppl) do
 begin
  if ppl[i].net.connected then
  if ppl[i].pls.fegyv>=128 then inc(techsz) else inc(gunsz)
 end;

 txt:=txt+' - '+lang[37]+': '+inttostr(gunsz)+' / '+inttostr(techsz);

 txt:=txt+' - '+lang[38]+':'+inttostr(length(ppl)+1-gunsz-techsz);
 menu.DrawText(txt,0,0,0.4,0.05,0,$FF000000+betuszin);

 txt:=formatdatetime('hh:nn',time);
 menu.DrawText(txt,0.9,0.25,1,0.27,0,$FF000000+betuszin);

 txt:=lastzone;
 menu.DrawText(txt,0.88,0.27,1,0.29,0,$FF000000+betuszin);

  case zonaellen of
   0:txt:=lang[39];
   1:txt:=lang[40];
  else
     txt:=inttostr(zonaellen)+lang[41];
  end;
 menu.DrawText(txt,0.88,0.29,1,0.31,0,$FF000000+betuszin);


 if multisc.kills>0 then
  if multisc.kills>1 then
   txt:=inttostr(multisc.kills)+lang[42]
  else
   txt:=lang[43]
 else
  txt:='';
 menu.DrawText(txt,0.9,0.33,1,0.35,0,$FF000000+betuszin);

 if multisc.kills-multisc.killswithoutdeath>1 then
  txt:=inttostr(multisc.kills-multisc.killswithoutdeath)+lang[44]
 else
  txt:='';
 menu.DrawText(txt,0.87,0.35,1,0.37,0,$FF000000+betuszin);

 case multisc.kills-multisc.killswithoutdeath of
   0, 1, 2:txt:='';
   3, 4, 5:txt:='Killing Spree!';
   6, 7, 8:txt:='Rampage!';
   9,10,11:txt:='Dominating!';
  12,13,14:txt:='Unstoppable!';
  15..29  :txt:='Godlike';
  else           txt:='WICKED SICK';
 end;
 menu.DrawText(txt,0.89,0.37,1,0.39,0,$FF000000+betuszin);

 {$ENDIF}
 aszin:=$FF;


 if length(chatmost)>0 then
  menu.DrawText('Chat:'+chatmost ,0,0.03,0.4,0.3,0,$FF000000+aszin);

 for i:=1 to 8 do
 begin
  //!TODO szines csodacset

  if (aszin<>0) and (pos(':',multisc.chats[i])>0) then
  begin
   if aszin=$FF0000 then
    cghash:=(((13)*16+12)*16+14)*16+15   {szin}+29*65536
   else
    cghash:=StringHash(copy(multisc.chats[i],1,pos(':',multisc.chats[i])));

   menu.DrawChatGlyph(cghash,0.005,0.06+(i-1)*0.02,$1F*(9-i));
   menu.DrawText(multisc.chats[i],0.015,0.05+(i-1)*0.02,0.4,0.2+(i-1)*0.02,0,$1F000000*(9-i)+aszin);
  end
  else
   menu.DrawText(multisc.chats[i],0.000,0.05+(i-1)*0.02,0.4,0.2+(i-1)*0.02,0,$1F000000*(9-i)+aszin);
 end;

 {$IFDEF palyszerk}
 mit:='DELETE';
 if epuletmost>=0 then mit:=ojjektumnevek[epuletmost];
 menu.DrawText(mit,0.3,0.3,0.7,0.7,2,$FF000000);
 {$ENDIF}

 //menu.drawtext(inttostr(round(botlevel*100)),0.3,0.9,0.9,1,1,$FF000000+betuszin);

 if autoban then
 begin
  d3dxvec3subtract(tmp,tegla.vpos,tegla.pos);
  menu.drawtext(mp3stationname,0,0.85,0.4,0.9,1,$FF000000+betuszin);
  menu.drawtext(inttostr(round(d3dxvec3length(tmp)*360))+'Km/h',0,0.9,0.4,1,2,$FF000000+betuszin);
  if tegla.axes[2].y<0 then
  begin
   if latszonazR>1 then dec(latszonazR) else
   if latszonazR=0 then
    latszonazR:=255;
   Drawmessage(lang[45],latszonazR*$01000000+betuszin);
  end
  else
   latszonazR:=0;

  if kiszallas>0 then
  begin
   Drawmessage(lang[46],$FF000000+betuszin);
   if tavpointpointsq(tegla.pos,tegla.vpos)> sqr(0.1) then
    Drawmessage(lang[47],$FFFF0000);
  end
 end;
 if recovercar>0 then
 begin
   Drawmessage(lang[48]+inttostr(3-recovercar div 100)+lang[49],$FF000000+betuszin)
 end
 else
 begin
  if vanishcar>0 then
  begin
   drawmessage(inttostr(15-vanishcar div 100)+lang[50],(128-(vanishcar*17) div 300)*$1000000+betuszin);
  end;
 end;

  if zonechanged>0 then
 begin
  case zonaellen of
   0:txt:=lang[39];
   1:txt:=lang[40];
  else
     txt:=inttostr(zonaellen)+lang[41];
  end;
  drawmessage(lang[51]+lastzone+',',min(zonechanged,255) shl 24+betuszin);
  drawmessage(txt,min(zonechanged,255) shl 24+betuszin);
 end;

 if bunkerkozelben and (halal=0) then
 begin
  if latszonazF>2 then dec(latszonazF,2);
   drawmessage(lang[52],latszonazF*$1000000+betuszin)
 end
 else
  if (not autoban) and (tavpointpointsq(tegla.pos,d3dxvector3(cpx^,cpy^,cpz^))<5*5) and (halal=0) then
  begin
    if latszonazF>2 then dec(latszonazF,2);
   drawmessage(lang[53],latszonazF*$1000000+betuszin)

  end
 else
  if latszonazF<240 then inc(latszonazF,5) else latszonazF:=255;

 if invulntim>0 then
  drawmessage(lang[54]+inttostr(invulntim div 100+1),$A0000000+betuszin);
 if latszonaKL>0 then
  drawmessage(kitlottemle,$1000000*latszonaKL+$FF0000);

  // menu.g_pSprite.Draw(ojjektumrenderer.imposters,nil,nil,nil,$80FFFFFF);
// menu.drawtext(inttostr(length(zenebuffer)),0.2,0.8,0.8,0.9,2,$70000000+betuszin);
 //menu.drawtext(inttostr(zeneintensity),0.2,0.9,0.8,1,2,$70000000+betuszin);
 // menu.drawtext(inttostr(flipcount),0.2,0.9,0.8,1,2,$70000000+betuszin);
  //menu.drawtext(inttostr(length(particles))+'/'+inttostr(particlehgh),0.2,0.9,0.8,1,false,$70000000+betuszin);
  //menu.drawtext(inttostr(fegylit),0.2,0.9,0.8,1,2,$70000000+betuszin);
 // menu.drawtext(inttostr(uploadcurrenthasznos),0.2,0.8,0.8,0.9,2,$70000000+betuszin);
 // menu.drawtext(inttostr(bufplayingcount)+'/'+inttostr(length(bufplaying)),0.2,0.9,0.8,1,2,$70000000+betuszin);
 // menu.drawtext(inttostr(playsoundcount)+':'+inttostr(stopsoundcount)+'>'+inttostr(specialcreatecount),0.2,0.8,0.8,0.9,2,$70000000+betuszin);
  playsoundcount:=0; stopsoundcount:=0; specialcreatecount:=0;
  // menu.drawtext(inttostr(g_pd3ddevice.GetAvailableTextureMem div (1024*1024)),0.2,0.8,0.8,0.9,2,$70000000+betuszin);

// for i:=0 to 12 do
 // menu.drawtext(inttostr(kic[i]),0.3,0.1+i/20,0.5,0.2+i/20,true,$FFFF0000);
 {$IFDEF hudcoord}
 menu.drawtext(floattostr(cpx^) ,0.1,0.5,0.55,1,0,$FFFF00FF);
  menu.drawtext(floattostr(cpy^) ,0.1,0.55,0.6,1,0,$FFFF00FF);
  menu.drawtext(floattostr(cpz^) ,0.1,0.6,0.65,1,0,$FFFF00FF);
  menu.drawtext(floattostr(szogx),0.1,0.65,0.7,1,0,$FFFF00FF);
  menu.drawtext(floattostr(szogy),0.1,0.7,0.75,1,0,$FFFF00FF);
 {$ENDIF}
 //menu.drawtext(floattostr(
   //                  sqrt(sqr(cpx^-cpox^)+sqr(cpy^-cpoy^)+sqr(cpz^-cpoz^))
     //                ),0.2,0.9,0.8,1,2,$70000000+betuszin);

 { for i:=0 to 10 do
   menu.drawtext(inttostr(i)+':'+inttostr(microprofile[i]),0.3,0.1+i/20,0.5,0.2+i/20,0,$FFFF0000); }

 //Ezt a végére, mert matrix-flush-baszakodás van benne

 for i:=0 to high(ac) do
  if (ap[i].y-ap2[i].y)<1 then ac[i]:='';

 if length(ar)>0 then
  menu.DrawChatsInGame(ac,ap,aa);



 //Ez is flush-baszakodós
 if dine.keyd(DIK_TAB) then
 begin

  menu.DrawRect(0.1,0.1,0.9,0.9,$A0000000);
  menu.DrawRect(0.1,0.1,0.9,0.2,$A0000000);
  menu.g_psprite.Flush;
  menu.g_psprite.SetTransform(identmatr);
  menu.DrawText('GUN',0.15,0.11,0.5,0.2,2,$FFFF6000);
  menu.DrawText('TECH',0.50,0.11,0.85,0.2,2,$FF00A0FF);
//                       div 2048
  killtmutat:=((timegettime shr 11) and 1)=1 ;




  if (gunsz>13) or (techsz>13) then
  begin
   kisTAB:=0;
   menuszor:=0.02;
  end
  else
  begin
   kisTAB:=1;
   menuszor:=0.05;
  end;
  
  techsz:=0;gunsz:=0;
 
  setlength(rendezve,length(ppl));
  for i:=0 to high(rendezve) do
   rendezve[i]:=i;

  for i:=0 to high(rendezve) do
   for j:=i+1 to high(rendezve) do
   if ppl[rendezve[i]].pls.kills<ppl[rendezve[j]].pls.kills then
   begin
    rtmp:=rendezve[i];
    rendezve[i]:=rendezve[j];
    rendezve[j]:=rtmp;
   end;

  for i:=0 to high(rendezve) do
   if ppl[rendezve[i]].pls.fegyv>=128 then
   begin
    //!TODO mutasson a tab lista
    if ((length(ppl[rendezve[i]].pls.nev)>1) and (ppl[rendezve[i]].net.connected)) then
    begin

     if killtmutat then
      menu.DrawText(ppl[rendezve[i]].pls.nev+' '+inttostr(ppl[rendezve[i]].pls.kills)  ,0.5,menuplus+techsz*menuszor,0.85,menuplus+0.1+techsz*menuszor,kisTAB,$FF00A0FF)
     else
      menu.DrawText(ppl[rendezve[i]].pls.nev+' '+fegyvernev(ppl[rendezve[i]].pls.fegyv),0.5,menuplus+techsz*menuszor,0.85,menuplus+0.1+techsz*menuszor,kisTAB,$FF00A0FF);
      inc(techsz);
    end;
   end
   else
   begin
    if ((length(ppl[rendezve[i]].pls.nev)>1) and (ppl[rendezve[i]].net.connected))  then
    begin

     if killtmutat then
      menu.DrawText(ppl[rendezve[i]].pls.nev+' '+inttostr(ppl[rendezve[i]].pls.kills)  ,0.11,menuplus+ gunsz*menuszor,0.5,menuplus+0.1+ gunsz*menuszor,kisTAB,$FFFF6000)
     else
      menu.DrawText(ppl[rendezve[i]].pls.nev+' '+fegyvernev(ppl[rendezve[i]].pls.fegyv),0.11,menuplus+ gunsz*menuszor,0.5,menuplus+0.1+ gunsz*menuszor,kisTAB,$FFFF6000) ;
     inc(gunsz);
    end;
   end;
 end;

 except
  exit;
 end;
end;

procedure drawminimap;
const
szhx=0.1;szhy=0.5;
var
  vEyePt, vLookatPt, vUpVec: TD3DVector;
  mat:TD3DMatrix;
  i:integer;
  mapfan:array [0..50] of TSkyVertex;
begin

 {$IFDEF noHUD}exit;{$ENDIF}
 {$IFDEF AIparancsok}exit;{$ENDIF}
  g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);
 setupmyfegyvprojmat;
 
 g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_CLAMP);
 g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_CLAMP);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG1);
  vEyePt:=    D3DXVector3(0, 0,0);
  vUpVec:=    D3DXVector3(0,1,0);
  vlookatpt:= D3DXVector3(0,0, 1);
  D3DXMatrixLookAtLH(mat, vEyePt, vLookatPt, vUpVec);

  g_pd3dDevice.SetTransform(D3DTS_VIEW, mat);
  g_pd3dDevice.SetFVF(D3DFVF_SKYVERTEX);
  g_pd3ddevice.SetTexture(0,mt2);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_DISABLE);
  //g_pd3ddevice.settransform(D3DTS_TEXTURE0,identmatr);
  mapfan[0]:=SkyVertex(0.09,0.062,0.1435,cpx^/(2*1024)+0.5+0.29,cpz^/(2*1024)+0.5);
  for i:=0 to 49 do
   mapfan[i+1]:=SkyVertex(sin(i*D3DX_PI*2/49)*0.02+0.09,cos(i*D3DX_PI*2/49)*0.02+0.062,0.1435,(sin(i*D3DX_PI*2/49+szogx)*0.1+cpx^/(2*1024)+0.5)+0.29,(cos(i*D3DX_PI*2/49+szogx)*0.1+cpz^/(2*1024)+0.5));
 { vp.X:=0;
  vp.y:=0;
  vp.width:=800;
  vp.height:=600;
  vp.minz:=0;
  vp.maxz:=0;
  D3Dxvec3project(mapfan[1].position,mapfan[0].position,vp,matproj,mat,identmatr);   }

  g_pd3ddevice.DrawPrimitiveUP(D3DPT_TRIANGLEFAN,49,mapfan,sizeof(TSkyVertex));

 { mapfan[0]:=SkyVertex(0.09,0.062,0.2,0,0);
  mapfan[1]:=SkyVertex(0+0.09,1/500+0.062,0.2,0,0);
  mapfan[20]:=SkyVertex(0+0.09,1/500+0.062,0.2,0,0);
  for i:=1 to 18 do
   mapfan[i+1]:=SkyVertex(sin(i*D3DX_PI/9)/1000+0.09,cos(i*D3DX_PI/9)/1000+0.062,0.2,0,0);  

  g_pd3ddevice.DrawPrimitiveUP(D3DPT_TRIANGLEFAN,18,mapfan,sizeof(TSkyVertex)); }
   g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_WRAP);
 g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_WRAP);

 {$IFDEF depthcomplexity}
  ShowDepthComplexity;
 {$ENDIF}
end;

procedure closeHUD;
begin
 menu.g_pSprite._End;

end;



procedure DCRS;  //depth complexity renderstates
begin
   // Clear the stencil buffer
  g_pd3dDevice.Clear(0, nil, D3DCLEAR_STENCIL, $0, 1.0, 0);

  // Turn stenciling
  g_pd3dDevice.SetRenderState(D3DRS_STENCILENABLE,   iTrue);
  g_pd3dDevice.SetRenderState(D3DRS_STENCILFUNC,     D3DCMP_ALWAYS);
  g_pd3dDevice.SetRenderState(D3DRS_STENCILREF,      0);
  g_pd3dDevice.SetRenderState(D3DRS_STENCILMASK,     $00000000);
  g_pd3dDevice.SetRenderState(D3DRS_STENCILWRITEMASK,$ffffffff);

  // Increment the stencil buffer for each pixel drawn
  g_pd3dDevice.SetRenderState(D3DRS_STENCILZFAIL, D3DSTENCILOP_INCRSAT);
  g_pd3dDevice.SetRenderState(D3DRS_STENCILFAIL,  D3DSTENCILOP_KEEP);
  g_pd3dDevice.SetRenderState(D3DRS_STENCILPASS,  D3DSTENCILOP_INCRSAT);
end;


procedure Setuplawmat(mit:integer);
var
 v1,v2,v3,vp:TD3DXVector3;
 mat:TD3DMatrix;
begin
 vp:=lawproj[mit].v2;
 d3dxvec3subtract(v1,lawproj[mit].v1,lawproj[mit].v2);
 v2.y:=0;
 v2.z:=-v1.x;
 v2.x:=v1.z;
 d3dxvec3cross(v3,v1,v2);
 fastvec3normalize(v1);
 fastvec3normalize(v2);
 fastvec3normalize(v3);
 d3dxvec3scale(v1,v1,0.5);
 d3dxvec3scale(v2,v2,0.1);
 d3dxvec3scale(v3,v3,0.1);
 mat._11:=v1.x; mat._12:=v1.y; mat._13:=v1.z; mat._14:=0;
 mat._21:=v2.x; mat._22:=v2.y; mat._23:=v2.z; mat._24:=0;
 mat._31:=v3.x; mat._32:=v3.y; mat._33:=v3.z; mat._34:=0;
 mat._41:=vp.x; mat._42:=vp.y; mat._43:=vp.z; mat._44:=1;

 g_pd3ddevice.SetTransform(D3DTS_WORLD,mat);
end;

procedure SetupNoobmat(mit:integer);
var
 v1,v2,v3,vp:TD3DXVector3;
 mat:TD3DMatrix;
begin
 vp:=noobproj[mit].v2;
 d3dxvec3subtract(v1,noobproj[mit].v1,noobproj[mit].v2);
 v2.y:=0;
 v2.z:=-v1.x;
 v2.x:=v1.z;
 d3dxvec3cross(v3,v1,v2);
 fastvec3normalize(v1);
 fastvec3normalize(v2);
 fastvec3normalize(v3);
 d3dxvec3scale(v1,v1,0.2);
 d3dxvec3scale(v2,v2,0.1);
 d3dxvec3scale(v3,v3,0.1);
 mat._11:=v1.x; mat._12:=v1.y; mat._13:=v1.z; mat._14:=0;
 mat._21:=v2.x; mat._22:=v2.y; mat._23:=v2.z; mat._24:=0;
 mat._31:=v3.x; mat._32:=v3.y; mat._33:=v3.z; mat._34:=0;
 mat._41:=vp.x; mat._42:=vp.y; mat._43:=vp.z; mat._44:=1;

 g_pd3ddevice.SetTransform(D3DTS_WORLD,mat);
end;

procedure setupNoobToltMat;
var
  matWorld, matView2, matProj: TD3DMatrix;
begin
  if gugg then
   D3DXMatrixTranslation(matWorld,ccpx, ccpy+1,ccpz)
  else
   D3DXMatrixTranslation(matWorld,ccpx, ccpy+1.5,ccpz);
  D3DXMatrixRotationY(matView2,mszogx+d3dx_pi);

  D3DXMatrixRotationX(matproj,mszogy);
  D3DXMatrixMultiply(matView2,matProj,matView2);
  if csipo then
   D3DXMatrixTranslation(matproj,-0.1,-0.2,-0.4)
  else
   D3DXMatrixTranslation(matproj,0,-0.2,-0.4);

  D3DXMatrixMultiply(matView2,matProj,matView2);
  D3DXMatrixScaling(matproj,lovok/20,lovok/20,lovok/20);
  D3DXMatrixMultiply(matView2,matProj,matView2);
  D3DXMatrixMultiply(matworld,matView2,matworld);

  if halal>0 then d3dxmatrixidentity(matWorld);

  D3DXVec3TransformCoord(noobtoltpos,d3dxvector3zero,matworld);
  mfm:=matworld;
  g_pd3dDevice.SetTransform(D3DTS_WORLD, matWorld);


end;

procedure renderAutok(enyem:boolean);
var
i,j:integer;
sautok,antigravok:array of Tauto;
begin
      if cpy^>150 then exit;
     g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
     g_pd3dDevice.SetTransform(D3DTS_WORLD, tegla.matrixfromaxes);

     if enyem then
     if not tegla.disabled then 
     if myfegyv<128 then
     begin
      g_pd3ddevice.SetTexture(0,cartex);
      g_pautomesh.DrawSubset(0);
     end
     else
     begin
      g_pd3ddevice.SetTexture(0,antigravtex);
      g_pantigravmesh.DrawSubset(0);
     end;


     if not enyem then
     for i:=0 to high(ppl) do
     begin
      if high(tobbiekautoi)<i then continue;
      if tobbiekautoi[i]=nil then continue;
      if tobbiekautoi[i].disabled then continue;
      if not tobbiekautoi[i].agx then
      begin
       setlength(sautok,length(sautok)+1);
       sautok[high(sautok)]:=tobbiekautoi[i];
      end
      else
      begin
       setlength(antigravok,length(antigravok)+1);
       antigravok[high(antigravok)]:=tobbiekautoi[i];
      end
     end;

     g_pd3ddevice.SetTexture(0,cartex);
     for i:=0 to high(sautok) do
     begin
      g_pd3dDevice.SetTransform(D3DTS_WORLD, sautok[i].matrixfromaxes);
      g_pautomesh.DrawSubset(0);
     end;

     g_pd3ddevice.SetTexture(0,antigravtex);
     for i:=0 to high(antigravok) do
     begin
      g_pd3dDevice.SetTransform(D3DTS_WORLD, antigravok[i].matrixfromaxes);
      g_pantigravmesh.DrawSubset(0);
     end;

     g_pd3ddevice.SetTexture(0,kerektex);

     if enyem then
     if myfegyv<128 then
     if not tegla.disabled then
     for i:=0 to 3 do
     begin
      g_pd3dDevice.SetTransform(D3DTS_WORLD, tegla.kerektransformmatrix(i));
      g_pkerekmesh.DrawSubset(0);
     end;

     if not enyem then
     for j:=0 to high(sautok) do
     if sautok[j].disabled then continue else
     begin
      sautok[j].initkerekek;
      for i:=0 to 3 do
      begin
       g_pd3dDevice.SetTransform(D3DTS_WORLD, sautok[j].kerektransformmatrix(i));
       g_pkerekmesh.DrawSubset(0);
      end;
     end;
  g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);

end;



procedure rendermuks(i:integer;pos:TD3DXVector3;astate,afegyv:byte);
begin

 SetupMuksmatr(i);
 muks.jkez:=fegyv.jkez(afegyv,astate);
 muks.bkez:=fegyv.bkez(afegyv,astate);

 case astate and MSTAT_MASK of
  0:muks.stand((astate and MSTAT_GUGGOL)>0);
  1:muks.Walk(animstat,(astate and MSTAT_GUGGOL)>0);
  2:muks.Walk(1-animstat,(astate and MSTAT_GUGGOL)>0);
  3:muks.SideWalk(animstat,(astate and MSTAT_GUGGOL)>0);
  4:muks.SideWalk(1-animstat,(astate and MSTAT_GUGGOL)>0);
  5:muks.Runn(animstat,true);
 end;

 ppl[i].pls.fejh:=muks.gmbk[10];

 if afegyv>127 then
  muks.Render($FF000040,mat_world,D3DXVector3(cpx^,cpy^,cpz^))
 else
  muks.Render($FF000000,mat_world,D3DXVector3(cpx^,cpy^,cpz^));
end;

procedure rendermykez;
var
vj,vb,nj,nb,tj,tb,jk2,bk2:TD3DXVector3;
mrp,mfm2:TD3DMatrix;
i:integer;
begin
 setupmymuksmatr;
 setupmyfegyvmatr;
 setupidentmatr;
 d3dxmatrixrotationy(mrp,szogx);

 jk2:=D3DXVector3(0.5,-1,-0.5);
 bk2:=D3DXVector3(-0.5,-1,-0.5);
 d3dxvec3normalize(bk2,bk2);
 d3dxvec3normalize(jk2,jk2);

 with muks do
 begin
  d3dxmatrixinverse(mfm2,nil,matview);
  tj:=fegyv.jkez(myfegyv,0);
  tj:=D3DXVector3(tj.x+0.05,tj.y-1.5,tj.z-0.1);
  tb:=fegyv.bkez(myfegyv,0);
  tb:=D3DXVector3(tb.x+0.05,tb.y-1.5,tb.z-0.1);
  if myfegyv=FEGYV_LAW then begin tj.x:=tj.x-0.1; tb.x:=tb.x-0.1; end;
  d3dxvec3transformcoord(vj,tj,mfm);
  d3dxvec3transformcoord(vb,tb,mfm);
  d3dxvec3transformnormal(nj,jk2,mrp);
  d3dxvec3transformnormal(nb,bk2,mrp);

  D3DXVec3transformcoord(tj,D3DXVector3(-0.2,-0.2,-0.2),mfm2);
  for i:=0 to high(muks.gmbk) do
   gmbk[i]:=tj;
  gmbk[5]:=tj;//D3DXVector3(campos.x,campos.y-0.3,campos.z);
  gmbk[9]:=vb;
  gmbk[8]:=vj;
  haromszog3d(gmbk[9],gmbk[5],gmbk[7],nj,0.5);
  haromszog3d(gmbk[8],gmbk[5],gmbk[6],nb,0.5);
 end;
 if myfegyv<128 then
  muks.Render($FF000000,identmatr,campos)
 else
  muks.Render($FF000040,identmatr,campos)
end;

procedure DrawDistortionEffects;
var
mat,mat2:TD3DMatrix;
i:integer;
begin
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_COUNT3+D3DTTFF_PROJECTED);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXCOORDINDEX, D3DTSS_TCI_CAMERASPACEPOSITION);
 g_pd3dDevice.SetTexture(0,effecttexture);
 for i:=0 to high(explosionbubbles) do
 with explosionbubbles[i] do
 begin
  d3dxmatrixtranslation(mat,pos.x,pos.y,pos.z);
  d3dxmatrixscaling(mat2,meret,meret,meret);
  d3dxmatrixmultiply(mat,mat2,mat);
  g_pd3dDevice.SetTransform(D3DTS_World, mat);

  mat:=identmatr;
  mat._11:=0.5;
  mat._22:=-0.5;
  mat._41:=0.5;
  mat._42:=0.5;

  d3dxmatrixscaling(mat2,1,1,1+erosseg/sqr(meret));
  d3dxmatrixmultiply(mat,matproj,mat);
  d3dxmatrixmultiply(mat,mat2,mat);

  g_pd3dDevice.SetTransform(D3DTS_TEXTURE0, mat);

  noobmesh.DrawSubset(0);
 end;

 for i:=0 to high(explosionripples) do
 with explosionripples[i] do
 begin
  d3dxmatrixtranslation(mat,pos.x,pos.y,pos.z);

  mat2:=d3dxmatrix(vsz.x*meret,vsz.y*meret,vsz.z*meret,0,
                   hsz.x*meret,hsz.y*meret,hsz.z*meret,0,
                             0,          0,          0,0,
                             0,          0,          0,1);

  //d3dxmatrixscaling(mat2,meret,meret,meret);
  d3dxmatrixmultiply(mat,mat2,mat);
  g_pd3dDevice.SetTransform(D3DTS_World, mat);

  mat:=identmatr;
  mat._11:=0.5;
  mat._22:=-0.5;
  mat._41:=0.5;
  mat._42:=0.5;

  d3dxmatrixscaling(mat2,1,1,1+erosseg/sqr(meret));
  d3dxmatrixmultiply(mat,matproj,mat);
  d3dxmatrixmultiply(mat,mat2,mat);

  g_pd3dDevice.SetTransform(D3DTS_TEXTURE0, mat);

  noobmesh.DrawSubset(0);
 end;

end;


procedure drawHUDdistortion;
var
  mati: TD3DMatrix;
  sokszr:array [0..99] of Tskyvertex;
  i:integer;
  v1,v2,v3:TD3DXVector3;
begin

  v1:=    D3DXVector3(0, 0,0);
  v2:=    D3DXVector3(0,1,0);
  v3:=   D3DXVector3(0,0, 1);
  D3DXMatrixLookAtLH(mati, v1, v3, v2);

  g_pd3ddevice.SetTransform(D3DTS_View,mati);
  g_pd3ddevice.SetTransform(D3DTS_world,identmatr);
  g_pd3ddevice.SetTransform(D3DTS_texture0,identmatr);

  g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXCOORDINDEX, D3DTSS_TCI_PASSTHRU);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS,D3DTTFF_DISABLE);

  if (myfegyv=FEGYV_NOOB) and (lovok>0) and (not csipo) then
 begin
  g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iTrue);
  g_pd3dDevice.SetRenderState(D3DRS_ZWRITEENABLE, iFalse);
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/4, 4/3, 0.1, 1000.0);
  g_pd3ddevice.SetTransform(D3DTS_PROJECTION,matproj);
  for i:=0 to 49 do
  begin

   sokszr[i*2].position:=
    D3DXVector3(
    0,
    -0.2,
    0.5);

   sokszr[i*2].u:= sin((i+0.5)*D3DX_PI*2/49)*lovok*0.5+0.5;
   sokszr[i*2].v:=-cos((i+0.5)*D3DX_PI*2/49)*lovok*0.5+1;


   sokszr[i*2+1].position:=
    D3DXVector3(
    sin(i*D3DX_PI*2/49)*0.38*0.5,
    cos(i*D3DX_PI*2/49)*0.38*0.5-0.4*0.5,
    0.5);

   sokszr[i*2+1].u:= sokszr[i*2+1].position.x*1.8+0.5;
   sokszr[i*2+1].v:=-sokszr[i*2+1].position.y*1.8/0.75+0.5;
  end;
  g_pd3ddevice.SetFVF(D3DFVF_SKYVERTEX);
  g_pd3ddevice.DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,98,sokszr,sizeof(TSkyVertex));
 end;                             

 if ((myfegyv=FEGYV_M82A1) and (not csipo)) and (halal=0) then
 begin
  g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iFalse);
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/4, 4/3, 0.1, 1000.0);
  g_pd3ddevice.SetTransform(D3DTS_PROJECTION,matproj);
  for i:=0 to 49 do
  begin
   sokszr[i*2].position:=
    D3DXVector3(
    sin(i*D3DX_PI*2/49)*0.38*0.5,
    cos(i*D3DX_PI*2/49)*0.38*0.5,
    0.5);

   sokszr[i*2].u:= sokszr[i*2].position.x*2.41*0.75+0.5;
   sokszr[i*2].v:=-sokszr[i*2].position.y*2.41+0.5;

   sokszr[i*2+1].position:=
    D3DXVector3(
    sin(i*D3DX_PI*2/49)*0.68*0.5,
    cos(i*D3DX_PI*2/49)*0.68*0.5,
    0.3);

   sokszr[i*2+1].u:= sokszr[i*2+1].position.x*2.41*0.75+0.5;
   sokszr[i*2+1].v:=-sokszr[i*2+1].position.y*2.41+0.5;//}
  end;
  g_pd3ddevice.SetFVF(D3DFVF_SKYVERTEX);

  g_pd3ddevice.DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,98,sokszr,sizeof(TSkyVertex));
 end;

end;

procedure drawdistortionppl;
var
pos:TD3DXVector3;
begin
  exit;

  {mat:=identmatr;
  mat._11:=0.5;
  mat._22:=-0.5;
  mat._41:=0.5;
  mat._42:=0.5;

  d3dxmatrixscaling(mat2,1,1,0.7);
  d3dxmatrixmultiply(mat,matproj,mat);
  d3dxmatrixmultiply(mat,mat2,mat);   }

  g_pd3dDevice.SetTransform(D3DTS_TEXTURE0, identmatr);

    mat_world:=identmatr;
    muks.init;

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG1);
    setupidentmatr;
    pos:=D3DXVector3(cpx^,cpy^,cpz^);


   { for i:=0 to rbszam do
    begin
     //g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, rongybabak[i].szin);
     rongybabak[i].transfertomuks(muks);
     muks.RenderDistortion( rongybabak[i].szin,identmatr,matproj,matview,pos);
    end;      }
    muks.Flush;


end;

procedure DrawFullscreenRect;
var
  mati: TD3DMatrix;
  sokszr:array [0..3] of Tskyvertex;
  v1,v2,v3:TD3DXVector3;
  elmproj:TD3DMatrix;
begin

  v1:=    D3DXVector3(0, 0,0);
  v2:=    D3DXVector3(0,1,0);
  v3:=   D3DXVector3(0,0, 1);
  D3DXMatrixLookAtLH(mati, v1, v3, v2);

  g_pd3ddevice.SetTransform(D3DTS_View,mati);
  g_pd3ddevice.SetTransform(D3DTS_world,identmatr);
  g_pd3ddevice.SetTransform(D3DTS_texture0,identmatr);
  D3DXMatrixPerspectiveFovLH(elmProj, D3DX_PI/2, 4/3, 0.99, 1000.0);
  D3DXMatrixOrthoLH(elmProj,2,2,0.99, 1000.0);
  g_pd3ddevice.SetTransform(D3DTS_PROJECTION,elmproj);

  sokszr[0].position:=D3DXVector3(-1,-1,1);
  sokszr[0].u:=0+1/1600;  sokszr[0].v:=1+1/1200;
  sokszr[1].position:=D3DXVector3(-1,1,1);
  sokszr[1].u:=0+1/1600;  sokszr[1].v:=0+1/1200;
  sokszr[2].position:=D3DXVector3( 1,-1,1);
  sokszr[2].u:=1+1/1600;  sokszr[2].v:=1+1/1200;
  sokszr[3].position:=D3DXVector3( 1,1,1);
  sokszr[3].u:=1+1/1600;  sokszr[3].v:=0+1/1200;
  g_pd3ddevice.SetFVF(D3DFVF_SKYVERTEX);
  g_pd3ddevice.DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,2,sokszr,sizeof(TSkyVertex));
  g_pd3ddevice.SetTransform(D3DTS_View,matView);
  g_pd3ddevice.SetTransform(D3DTS_PROJECTION,matproj);
end;


{procedure drawmysaber;
var
tv1,tv2:TD3DXVector3;
  matWorld, mat, mat2: TD3DMatrix;
  v1,v2,v3:TD3DXVector3;
begin

  if gugg then
   D3DXMatrixTranslation(matWorld,cpx^, cpy^+1.0,cpz^)
  else
   D3DXMatrixTranslation(matWorld,cpx^, cpy^+1.5,cpz^);
  D3DXMatrixRotationY(mat,mszogx+d3dx_pi);
  D3DXMatrixRotationX(mat2,mszogy);
  D3DXMatrixMultiply(mat,mat2,mat);
  if gugg then
   D3DXMatrixTranslation(mat2,0, -0.8,0)
  else
   D3DXMatrixTranslation(mat2,0, -1.3,0);
  D3DXMatrixMultiply(mat,mat2,mat);
  D3DXMatrixMultiply(matworld,mat,matworld);
  if halal>0 then d3dxmatrixidentity(matWorld);
  mfm:=matworld;
  
if autoban then exit;


 fenykardkezek(muks.jkez,muks.bkez,animstat,mstat,lovok);

 if ((mstat and MSTAT_CSIPO)=0)then
 begin
  d3dxvec3transformcoord(tv1,muks.bkez,mfm);
  d3dxvec3transformcoord(tv2,muks.jkez,mfm);
  d3dxvec3subtract(tv2,tv1,tv2);
  fastvec3normalize(tv2);
  v2:=tv2;
  d3dxvec3cross(v1,v2,D3DXVector3(1,0,0));
  d3dxvec3cross(v3,v1,v2);
  d3dxvec3add(tv2,tv2,tv1);
  d3dxvec3lerp(tv1,tv1,tv2,0.07);
  particlesystem_add(FenycsikCreate(tv1,tv2,0.03,$1010FF,20));
  particlesystem_add(FenycsikCreate(tv1,tv2,0.01,$FFFFFFFF,20));
  
  d3dxvec3scale(v2,v2,0.15);
  d3dxvec3scale(v1,v1,0.02*fastinvsqrt(d3dxvec3lengthsq(v1)));
  d3dxvec3scale(v3,v3,0.02*fastinvsqrt(d3dxvec3lengthsq(v3)));

  mfkmat._11:=v1.x;  mfkmat._12:=v1.y;  mfkmat._13:=v1.z;   mfkmat._14:=0;
  mfkmat._21:=v2.x;  mfkmat._22:=v2.y;  mfkmat._23:=v2.z;   mfkmat._24:=0;
  mfkmat._31:=v3.x;  mfkmat._32:=v3.y;  mfkmat._33:=v3.z;   mfkmat._34:=0;
  mfkmat._41:=tv1.x-v2.x*1;  mfkmat._42:=tv1.y-v2.y*1;  mfkmat._43:=tv1.z-v2.z*1;   mfkmat._44:=1;
 end;

 case mstat and MSTAT_MASK of
  0:muks.stand((mstat and MSTAT_GUGGOL)>0);
  1:muks.Walk(animstat,(mstat and MSTAT_GUGGOL)>0);
  2:muks.Walk(1-animstat,(mstat and MSTAT_GUGGOL)>0);
  3:muks.SideWalk(animstat,(mstat and MSTAT_GUGGOL)>0);
  4:muks.SideWalk(1-animstat,(mstat and MSTAT_GUGGOL)>0);
  5:muks.Runn(animstat,true);
 end;

 muks.Render($FF000040,mfm,D3DXVector3(cpx^,cpy^,cpz^));
end;    }

procedure dopplvisibility;
var
 i:integer;
begin
 for i:=0 to high(ppl) do
 if (ppl[i].pos.pos.y<3) or (not ppl[i].net.connected) then
  ppl[i].pls.visible:=false
 else
  ppl[i].pls.visible:=spherevsfrustum(D3DXVector3(ppl[i].pos.pos.x,ppl[i].pos.pos.y+0.8,ppl[i].pos.pos.z),1,frust);

end;


procedure renderReflectionTex;
var
backbuffer,efftexsurf:IDirect3DSurface9;
reflectmat:TD3DMatrix;
aplane:TD3DXplane;
xmat:TD3DMatrix;
begin
 if reflecttexture=nil then
 begin
  enableeffects:=false;
  exit;
 end;
 // Clear the zbuffer
 g_pd3dDevice.Clear(0, nil, D3DCLEAR_ZBUFFER,
                        D3DCOLOR_XRGB(0,150,255), 1.0, 0);

 g_pd3ddevice.GetBackBuffer(0,0,D3DBACKBUFFER_TYPE_MONO,backbuffer);
 reflecttexture.GetSurfaceLevel(0,efftexsurf);

  if FAILED(g_pd3ddevice.SetRenderTarget(0,efftexsurf)) then
  begin
   exit;
  end;

  reflectmat:=Identmatr;
  reflectmat._22:=-1;

  D3DXPlaneFrompointnormal(aplane,D3DXVector3(0,10.05+singtc/10,0),D3DXVector3(0,1,0));
  if SUCCEEDED(g_pd3dDevice.BeginScene) then
  begin
   laststate:='Rendering Reflections';
    g_pd3ddevice.SetClipPlane(0,@aplane);
    g_pd3ddevice.setrenderstate( D3DRS_CLIPPLANEENABLE,1);


    // Setup the world, view, and projection matrices
    SetupMatrices(true);

    g_pd3ddevice.MultiplyTransform(D3DTS_VIEW,reflectmat);


     //Render background

     RenderSky;

    SetupLights;
    SetupMatrices(false);
      reflectmat._42:=(10.1+singtc/10)*2;
    g_pd3ddevice.MultiplyTransform(D3DTS_VIEW,reflectmat);

    g_pd3ddevice.GetTransform(D3DTS_VIEW,xmat);
    frust:=frustum(xmat,0.1,1100,D3DX_PI/3, 4/3);
    
    renderautok(true);

    setupidentmatr;
    // Render the vertex buffer contents
    g_pd3dDevice.SetStreamSource(0, g_pVB, 0, SizeOf(TCustomVertex));
    g_pd3dDevice.SetFVF(D3DFVF_CUSTOMVERTEX);
    g_pd3dDevice.SetIndices(g_pIB);

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,  D3DTOP_MODULATE );
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP,FAKE_HDR   );

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG2, D3DTA_CURRENT);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);

    g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
    g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,D3DBLEND_INVSRCALPHA );
    g_pd3ddevice.SetRenderState(D3DRS_BLENDOP,D3DBLENDOP_ADD);

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG2);
    g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CW);


    if not (cpy^>150)then
    begin
    g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $FF202020);
    g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);

    g_pd3dDevice.SetTexture(0,futex);
    g_pd3dDevice.SetTexture(1,noise2tex);
    DrawSplat(0,splatinds[0]);

    g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
    g_pd3dDevice.SetTexture(0,homtex);
    DrawSplat(splatinds[1],splatinds[2]);

    g_pd3dDevice.SetTexture(0,kotex);
    g_pd3dDevice.SetTexture(1,noisetex);
    DrawSplat(splatinds[0],splatinds[1]);
     end;

    g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iFalse);

    g_pd3dDevice.SetRenderState(D3DRS_TEXTUREFACTOR,$FF0000FF);

    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_NONE );

    g_pd3dDevice.SetIndices(g_pIBlvl2);
    g_pd3dDevice.SetTexture(1,noise2tex);
    g_pd3dDevice.SetTexture(0,mt1);


    g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_CLAMP);
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_CLAMP);
     g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);
     DrawLvl((cpy^>150));
     g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);
     g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
     g_pd3dDevice.SetTexture(1,noisetex);
     DrawLvl((cpy^>150));
      g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);

      g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_WRAP);
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_WRAP);
    g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iFalse);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);


    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   FAKE_HDR);
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP,   D3DTOP_DISABLE);
    g_pd3dDevice.SetSamplerState(1, D3DSAMP_MIPFILTER, D3DTEXF_NONE );
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR );
    g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $FFFFFFFF);

    initojjektumok(g_pd3ddevice,FAKE_HDR);
             g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CW);
    g_pd3dDevice.SetRenderState(D3DRS_TEXTUREFACTOR,$FF5050FF);
    //Shaderek nélkül.

    g_pd3ddevice.SetTransform(D3DTS_TEXTURE1,identmatr);
    g_pd3ddevice.SetTransform(D3DTS_TEXTURE0,identmatr);
    ojjektumrenderer.Draw(frust,nil,matview,matproj,fogstart,fogend,true);
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP,   D3DTOP_DISABLE);

    g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
    g_pd3ddevice.setrenderstate( D3DRS_CLIPPLANEENABLE,0);
    g_pd3dDevice.EndScene;
  end;

  if FAILED(g_pd3ddevice.SetRenderTarget(0,backbuffer)) then
  begin
   exit;
  end;

end;


procedure Mechanics;
var
 i:integer;
begin


  laststate:='Basic handling stuff';

  if volttim=0 then volttim:=timegettime;
  if hanyszor=0 then hanyszor:=timegettime div 10;
  if (timegettime-volttim)>1 then
  begin
   framespersecond:=1000/(timegettime-volttim);
   eltim:=(timegettime-volttim)/1000;
   volttim:=timegettime;
  end;
  
  animstat:=(timegettime mod 1000)/1000;

  laststate:='MMO stuff';
  handleMMO;
  handlemmocars;
  //dummypos.pos.z:=dummypos.pos.z+2*eltim;
  //dummypos.pos.y:=advwove(dummypos.pos.x,dummypos.pos.z);

  case myfegyv of
   FEGYV_M4A1,FEGYV_M82A1,FEGYV_MP5A3:lovok:=lovok-eltim*10;
   FEGYV_X72:lovok:=lovok-eltim*7;
   FEGYV_MPG:lovok:=lovok+eltim*2;
   FEGYV_QUAD:lovok:=lovok+eltim*2;
  end;

  if lovok<0 then lovok:=0;
  if lovok>1 then lovok:=1;
  for i:=0 to high(ppl) do
  begin
   case ppl[i].pls.fegyv of
    FEGYV_M4A1,FEGYV_M82A1,FEGYV_X72,FEGYV_MP5A3:ppl[i].pls.lo:=ppl[i].pls.lo-eltim*10;
    FEGYV_MPG:ppl[i].pls.lo:=ppl[i].pls.lo+eltim*2;
    FEGYV_QUAD:ppl[i].pls.lo:=ppl[i].pls.lo+eltim*2;
   end;

   if ppl[i].pls.lo<0 then ppl[i].pls.lo:=0;
   if ppl[i].pls.lo>1 then ppl[i].pls.lo:=1;
  end;

  if halal>0 then halal:=halal+eltim; //nem volt /2
  if halal>6 then respawn;              //6 volt
  laststate:='Handlelovesek';
  Handlelovesek;
  laststate:='Handledoglodesek';
  Handledoglodesek;
  laststate:='HandleDS';
  handleSounds;
  laststate:='Physics';
  handlefizik;
end;

procedure undebug_magic1;
asm
 push offset @tovabb
 mov eax,offset Mechanics-$ABF3ABF3
 add eax,$ABF3ABF3
 push eax
 ret
 @tovabb:
end;

 
procedure undebug_checksum;
var
 addr:dword;
 meminfo:MEMORY_BASIC_INFORMATION;
 checksum:dword;
begin
 {$IFDEF undebug}
 checksum:=0;
 addr:=$401000; {entry point elvileg}
 VirtualQuery(Pointer(addr),meminfo,sizeof(meminfo));
 if (meminfo.AllocationProtect and $F0)=0 then
  exit;
 for addr:=$401000 to $400FFF+meminfo.RegionSize do
  if (addr and 3)=0 then
   checksum:=(checksum*1234567) xor (Pdword(addr)^);
 addr:=$400020;
 checksum:=checksum+(Pdword(addr)^);
 if checksum=0 then
  exit;
 // Ezért überbünti jár. Viszlát stack.
 asm
  MOV ECX,-1
  MOV EDI,ESP         //REP STOSD
  MOV EAX,offset undebug_magic1+11+$12345678
  SUB EAX,$12345678
  JMP EAX
 end;
 {$ENDIF}
end;


procedure RenderScene;
const
magicfuertek:array [0..4] of byte = (0,13,45,119,181);
var
 i:integer;
 pos:TD3DVector;
begin
  if latszonaKL>0 then
   if (checksum<>datachecksum) and (not canbeadmin) then
    Postmessage(hwindow,WM_DESTROY,0,0);

   laststate:='Rendering reflections';


   //hát, ez elõre kell. pont.
  if (opt_detail>=DETAIL_VIZ) then
   Renderreflectiontex;

   laststate:='Rendering';
  // Clear the zbuffer
   g_pd3dDevice.Clear(0, nil, D3DCLEAR_ZBUFFER,
                        D3DCOLOR_XRGB(0,150,255), 1.0, 0);
  // Begin the scene
  if SUCCEEDED(g_pd3dDevice.BeginScene) then
  begin
     //heatvision:=(myfegyv=FEGYV_FLAMETHROWER) and (not csipo) and (halal=0);
     laststate:='Rendering Terrain';
    // Setup the world, view, and projection matrices
    SetupMatrices(true);

     //Render background

    RenderSky;


    // Setup the lights and materials
    SetupLights;
    SetupMatrices(false);
    //BUNKER
    {$IFDEF depthcomplexity}
      DCRS;
    {$ENDIF}
        g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
    g_pd3dDevice.SetRenderState(D3DRS_ZFUNC, D3DCMP_LESSEQUAL);

    //if not (enableeffects and enableeffectso and (not heatvision)) then
     renderautok(true);
    renderautok(false);

    if currevent<>nil then currevent.RenderModels;
    
    setupidentmatr;
    // Render the vertex buffer contents
    g_pd3dDevice.SetStreamSource(0, g_pVB, 0, SizeOf(TCustomVertex));
    g_pd3dDevice.SetFVF(D3DFVF_CUSTOMVERTEX);
    g_pd3dDevice.SetIndices(g_pIB);

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,  D3DTOP_MODULATE );
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP,FAKE_HDR   );

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG2, D3DTA_CURRENT);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);

    g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
    g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,D3DBLEND_INVSRCALPHA );
    g_pd3ddevice.SetRenderState(D3DRS_BLENDOP,D3DBLENDOP_ADD);

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);

    if not (cpy^>150)then
    begin
    g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $FF202020);
    g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);

    g_pd3dDevice.SetTexture(0,futex);
    g_pd3dDevice.SetTexture(1,noise2tex);

     DrawSplat(0,splatinds[0]);


    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG2);

    g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
    g_pd3dDevice.SetTexture(0,homtex);
    DrawSplat(splatinds[1],splatinds[2]);

    g_pd3dDevice.SetTexture(0,kotex);
    g_pd3dDevice.SetTexture(1,noisetex);
    DrawSplat(splatinds[0],splatinds[1]);
    end;

    g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iFalse);

    g_pd3dDevice.SetRenderState(D3DRS_TEXTUREFACTOR,$FF0000FF);
    
  //  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   fake_HDR);
   // g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE  );
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_NONE );

    g_pd3dDevice.SetIndices(g_pIBlvl2);
    g_pd3dDevice.SetTexture(1,noise2tex);
    g_pd3dDevice.SetTexture(0,mt1);


    g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_CLAMP);
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_CLAMP);
     g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);
     DrawLvl((cpy^>150));
     g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);
     g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
     g_pd3dDevice.SetRenderState(D3DRS_ALPHATESTENABLE, iTrue);
      g_pd3ddevice.SetRenderState(D3DRS_ALPHAREF, $5);
     g_pd3dDevice.SetTexture(1,noisetex);
     DrawLvl((cpy^>150));
      g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);
      g_pd3dDevice.SetRenderState(D3DRS_ALPHATESTENABLE, iFalse);

      g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_WRAP);
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_WRAP);
    g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iFalse);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);


    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   FAKE_HDR);
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP,   D3DTOP_DISABLE);
    g_pd3dDevice.SetSamplerState(1, D3DSAMP_MIPFILTER, D3DTEXF_NONE );
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR );
    g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $FFFFFFFF);

    laststate:='Rendering Stickman and ragdolls';

    muks.init;
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP,   D3DTOP_SELECTARG1);
 g_pd3ddevice.SetRenderState(D3DRS_ALPHAREF, $80);
 g_pd3ddevice.SetRenderState(D3DRS_ALPHATESTENABLE, iTRUE);
 g_pd3ddevice.SetRenderState(D3DRS_ALPHAFUNC,  D3DCMP_GREATEREQUAL );
    g_pd3dDevice.SetTexture(0,muks.tex);

    D3DXMatrixIdentity(mat_world);
    setupidentmatr;


    if (menu.lap=-1) then //MENÜBÕL nem kéne...
    begin
    if (halal=0) and (not autoban) and (not kulsonezet) and (mapmode=0) then
     if (csipo) or (myfegyv<>FEGYV_M82A1) then
    rendermykez;

    pos:=D3DXVector3(cpx^,cpy^,cpz^);
    for i:=0 to rbszam do
    if abs(rongybabak[i].gmbk[10].y-cpy^)<100 then
    begin
     //g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, rongybabak[i].szin);
     rongybabak[i].transfertomuks(muks);
     muks.Render( rongybabak[i].szin,mat_world,pos);


    end;

    if random(100)=0 then
     Undebug_checksum;

    dopplvisibility;

    for i:=0 to high(ppl) do
    if ppl[i].pls.visible then
     if tavpointpointsq(ppl[i].pos.pos,campos)<sqr(300) then
     begin
      Rendermuks(i,ppl[i].pos.pos,ppl[i].pos.state,ppl[i].pls.fegyv);
     end;

    muks.Flush;

     g_pd3ddevice.SetRenderState(D3DRS_ALPHATESTENABLE, iFALSE);
     g_pd3ddevice.SetRenderState(D3DRS_ALPHAFUNC,  D3DCMP_ALWAYS );
     g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP,   D3DTOP_SELECTARG2);
      g_pd3ddevice.Settexture(0,mt1);
    //MUKSÓKÁK VÉGE

     g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iTrue);
     g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $FF606060);

    laststate:='Rendering head stuff';
    setupidentmatr;

    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_POINT);
    fejcuccrenderer.init;
    for i:=0 to high(ppl) do
    if ppl[i].pls.visible then
    if tavpointpointsq(campos,ppl[i].pos.pos)<sqr(50) then
    begin
     setupmuksmatr(i);
     mat_world._41:=mat_world._41+ppl[i].pls.fejh.x;
     mat_world._42:=mat_world._42+ppl[i].pls.fejh.y;
     mat_world._43:=mat_world._43+ppl[i].pls.fejh.z;
     fejcuccrenderer.Render(ppl[i].pls.fejcucc,mat_world,false,D3DXVector3(cpx^,cpy^,cpz^));
    end;
    fejcuccrenderer.Flush;

    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);

    g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $FF202020);

    end;  //Menübõl nemkéne vége

    laststate:='Rendering bunker and stuff';

    initojjektumok(g_pd3ddevice,FAKE_HDR);
    g_pd3dDevice.SetRenderState(D3DRS_TEXTUREFACTOR,$FF5050FF);
    g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);

    if opt_detail<DETAIL_POM then
     ojjektumrenderer.Draw(frust,nil,matview,matproj,fogstart,fogend,(myfegyv<>FEGYV_M82A1) or csipo)
    else
      ojjektumrenderer.Draw(frust,g_peffect,matview,matproj,fogstart,fogend,(myfegyv<>FEGYV_M82A1) or  csipo);
    
    uninitojjektumok(g_pd3ddevice);
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG1, D3DTA_TEXTURE);

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE);

    //developer
    //g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG1);
    g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);

    if (menu.lap=-1) then //MENÜBÕL nem kéne...
    begin
    {$IFDEF AIparancsok}
    if aimode>0 then
    {$ENDIF}
    begin



    setupmyfegyvmatr;
    setupfegyvlights(fegylit);
    if not kulsonezet then
    if (not csipo) and (myfegyv=FEGYV_M82A1) then fegyv.drawscope(FEGYV_M82A1 {myfegyv}) else
    if myfegyv<>FEGYV_NOOB then
     begin
      setupmyfegyvprojmat;
      fegyv.drawfegyv(myfegyv);
      setupprojmat;
     end
    else
     if not (enableeffects and (opt_postproc>0)) then
     begin
      setupmyfegyvprojmat;
      fegyv.drawfegyv(myfegyv);
      setupprojmat;
     end;
    end;

    setupfegyvlights(10);

    quadeffect;

    for i:=0 to high(ppl) do
    if ppl[i].pls.visible then
     if tavpointpointsq(ppl[i].pos.pos,campos)<sqr(150) then
    begin
     pos:=ppl[i].pos.pos;
   //  if (abs(pos.x-MMO.mypos.pos.x)+abs(pos.z-MMO.mypos.pos.z))<0.5 then continue;
     SetupFegyvmatr(i,0<(ppl[i].pos.state and MSTAT_CSIPO));
     fegyv.drawfegyv(ppl[i].pls.fegyv);
    end;

    pos:=D3DXVector3(cpx^,cpy^,cpz^);

    laststate:='Rendering projectiles';

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP , D3DTOP_SELECTARG1 );
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TFACTOR);
    g_pd3dDevice.SetRenderState(D3DRS_TEXTUREFACTOR,$FF505050);
    g_pd3dDevice.SetTexture(0,nil);
    for i:=0 to high(lawproj) do
    begin
     setuplawmat(i);
     lawmesh.DrawSubset(0);
    end;


    g_pd3dDevice.SetRenderState(D3DRS_TEXTUREFACTOR,$FFFF5050);
    for i:=0 to high(noobproj) do
    begin
     setupnoobmat(i);
     noobmesh.DrawSubset(0);
    end;



    if (myfegyv=FEGYV_NOOB) and (lovok>0) then
    begin
      setupnoobtoltmat;
      setupmyfegyvprojmat;
      noobmesh.DrawSubset(0);
      setupprojmat;
    end;
    end;
    
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);

    laststate:='Rendering bushes';
    setupidentmatr;
    bokrok.init;
    bokrok.render;
    fuvek.render;
   // fuvek2.render;
    g_pd3ddevice.SetRenderState(D3DRS_ALPHATESTENABLE, ifalse);
   // g_pd3ddevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
    laststate:='Rendering Alpha stuff';
    //Alfás cuccos


    fegyv.preparealpha;


    setupidentmatr;

    // setupidentmatr;
 { g_pd3dDevice.SetFVF(D3DFVF_XYZ);

    //initfu;
    if legyenfu then
    begin
    for i:=0 to fuszam do
     drawfu(i);

    end;
    uninitfu;}
    g_pd3dDevice.SetFVF(D3DFVF_CUSTOMVERTEX);
    renderviz;


    g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_ONE);
    g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,  D3DBLEND_ONE);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_MODULATE);

    laststate:='Rendering Alpha stuff (fegyv)';
    if (menu.lap=-1) then //MENÜBÕL nem kéne...
    begin

    if not ((myfegyv=FEGYV_M82A1) and (not csipo)) then
      setupmyfegyvprojmat;
    setupmyfegyvmatr;
    fegyv.drawfegyeffekt(myfegyv,lovok);
    if not ((myfegyv=FEGYV_M82A1) and (not csipo)) then
     setupprojmat;

    for i:=0 to high(ppl) do
    if ppl[i].pls.visible then
    begin
     pos:=ppl[i].pos.pos;
     SetupFegyvmatr(i,0<(ppl[i].pos.state and MSTAT_CSIPO));
     fegyv.drawfegyeffekt(ppl[i].pls.fegyv,ppl[i].pls.lo);
    end;

    end;

    laststate:='Rendering Alpha stuff (ff)';
    fegyv.FlushFegyeffekt;

    fegyv.unpreparealpha;

    laststate:='Rendering Particle System';

    Particlesystem_render(matView);

   // re_gomb;

    setupidentmatr;

    if (menu.lap=-1) then //MENÜBÕL nem kéne...
    if not (enableeffects and (opt_postproc>0)) then
    begin
     if halal=0 then
     g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iFalse);
     drawminimap;
     g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iTrue);
     laststate:='Rendering HUD';
     initHUD;
     drawHUD;
     closeHUD;
    end;
    g_pd3dDevice.EndScene;
  end;

  errorospointer^:=random(100);
end;



procedure RenderPostProcess;
var
 backbuffer,efftexsurf:IDirect3DSurface9;
 tmplw:Longword;
 fajlnev:string;
 tmpvec:TD3DXVector3;
begin
  laststate:='Effects rendering';
 
  if enableeffects and (opt_postproc>0) then
  begin
   backbuffer:=nil;
   efftexsurf:=nil;

   g_pd3ddevice.GetBackBuffer(0,0,D3DBACKBUFFER_TYPE_MONO,backbuffer);
   effecttexture.GetSurfaceLevel(0,efftexsurf);
   if failed(g_pd3ddevice.StretchRect(backbuffer,nil,efftexsurf,nil,D3DTEXF_LINEAR)) then enableeffects:=false;

   backbuffer:=nil;
   efftexsurf:=nil;

   if SUCCEEDED(g_pd3dDevice.BeginScene) then
   begin
    SetupLights;
    SetupMatrices(false);

    if (menu.lap=-1) then //MENÜBÕL nem kéne...
    if (G_peffect<>nil) and (opt_postproc>=POSTPROC_GREYSCALE) then
     if halal<>0 then
     begin
      g_peffect.SetTechnique('FullScreenGreyscale');

      g_pEffect.SetTexture('g_MeshTexture', effecttexture);
      g_pEffect.SetFloat('BlendFactor',min(halal/4,1));


      g_peffect._Begin(@tmplw,0);
      g_peffect.BeginPass(0);
      g_pd3ddevice.SetRenderState(D3DRS_ZWRITEENABLE,ifalse);
      g_pd3ddevice.SetRenderState(D3DRS_ALPHABLENDENABLE,iTrue);
      g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA );
      g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,  D3DBLEND_INVSRCALPHA );
      g_pd3ddevice.SetRenderState(D3DRS_LIGHTING,ifalse);
      g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE,ifalse);
      g_pd3ddevice.SetRenderState(D3DRS_CULLMODE,D3DCULL_NONE);
      g_pd3ddevice.SetRenderState(D3DRS_ZENABLE,ifalse);
      DrawFullscreenrect;
      g_peffect.Endpass;
      g_peffect._end;

     end;


    if (G_peffect<>nil) and (opt_postproc>=POSTPROC_GLOW) then
    if halal=0 then
     begin

      g_peffect.SetTechnique('FullScreenGlow');

      g_pEffect.SetTexture('g_MeshTexture', effecttexture);

      g_peffect._Begin(@tmplw,0);
      g_peffect.BeginPass(0);
      g_pd3ddevice.SetRenderState(D3DRS_ZWRITEENABLE,ifalse);
      g_pd3ddevice.SetRenderState(D3DRS_ALPHABLENDENABLE,iTrue);
      g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_ONE);
      g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,  D3DBLEND_ONE);
      g_pd3ddevice.SetRenderState(D3DRS_LIGHTING,ifalse);
      g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE,ifalse);
      g_pd3ddevice.SetRenderState(D3DRS_CULLMODE,D3DCULL_NONE);
      g_pd3ddevice.SetRenderState(D3DRS_ZENABLE,ifalse);
      DrawFullscreenrect;
      g_peffect.Endpass;
      g_peffect._end;
     end;

     if (menu.lap=-1) then //MENÜBÕL nem kéne...
    if (G_peffect<>nil) and (opt_postproc>=POSTPROC_MOTIONBLUR) then
     if autoban or ((rezg>0) and (robhely.y<>0) and (robhely.x<>0)) then
     if halal=0 then
     begin
      g_peffect.SetTechnique('MotionBlur');

      g_pEffect.SetTexture('g_MeshTexture', effecttexture);

      tmpvec:=D3DXVector3(cpx^-cpox^,cpy^-cpoy^,cpz^-cpoz^);
      if not autoban then
       d3dxvec3scale(tmpvec,robhely,rezg/10);
      D3DXVec3Transformnormal(tmpvec,tmpvec,matView);
       G_pEffect.SetVector('g_vMotionVec',D3DXVector4(tmpvec.x,-tmpvec.y*1.5,-tmpvec.z*2,0));

      g_peffect._Begin(@tmplw,0);
      g_peffect.BeginPass(0);
      g_pd3ddevice.SetRenderState(D3DRS_ZWRITEENABLE,ifalse);
      g_pd3ddevice.SetRenderState(D3DRS_ALPHABLENDENABLE,iFalse);
      g_pd3ddevice.SetRenderState(D3DRS_LIGHTING,ifalse);
      g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE,ifalse);
      g_pd3ddevice.SetRenderState(D3DRS_CULLMODE,D3DCULL_NONE);
      g_pd3ddevice.SetRenderState(D3DRS_ZENABLE,ifalse);
      DrawFullscreenrect;
      g_peffect.Endpass;
      g_peffect._end;

     end;







    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,  D3DTOP_SELECTARG1 );
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP,D3DTOP_DISABLE   );

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);

    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR );
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR );
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_NONE);
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_WRAP);
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_WRAP);

    g_pd3ddevice.SetRenderState(D3DRS_ALPHABLENDENABLE,ifalse);
    g_pd3ddevice.SetRenderState(D3DRS_LIGHTING,ifalse);
    g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE,ifalse);
    g_pd3ddevice.SetRenderState(D3DRS_CULLMODE,D3DCULL_NONE);
    g_pd3ddevice.SetRenderState(D3DRS_ZENABLE,itrue);
    g_pd3ddevice.SetRenderState(D3DRS_ZWRITEENABLE,itrue);
    g_pd3ddevice.SetTexture(0,effecttexture);

    if halal=0 then
    drawdistortioneffects;

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXCOORDINDEX, D3DTSS_TCI_PASSTHRU);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS,D3DTTFF_DISABLE);
    g_pd3dDevice.SetTransform(D3DTS_TEXTURE0, identmatr);

    //drawdistortionppl;

    setupmatrices(false);

    g_pd3ddevice.SetRenderState(D3DRS_ALPHABLENDENABLE,ifalse);
    g_pd3ddevice.SetRenderState(D3DRS_LIGHTING,itrue);
    g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE,itrue);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,  D3DTOP_MODULATE );

     if (menu.lap=-1) then //MENÜBÕL nem kéne...
    renderautok(true);

    g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);

    setupidentmatr;

     if (menu.lap=-1) then //MENÜBÕL nem kéne...
    begin
    setupmyfegyvprojmat;
    if (myfegyv=FEGYV_NOOB) and (not autoban) and (halal=0) then
    begin

     g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE);
     g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);

     g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iTrue);
     g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $FF202020);
     setupmyfegyvmatr;

      fegyv.drawfegyv(myfegyv);

    end;

    //g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR );
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR );
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_NONE);

     g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iFalse);
    g_pd3dDevice.SetTexture(0,effecttexture);
    drawHUDdistortion;



    if halal=0 then
     g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iFalse);
    drawminimap;
     g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iTrue);
     laststate:='Rendering HUD';
     initHUD;
     drawHUD;
     closeHUD;
    end;
    g_pd3dDevice.EndScene;
   end;

  end;

  if (GetAsyncKeyState(VK_SNAPSHOT)<>0) then
  if (enableeffects) and (effecttexture<>nil) then
  begin
   backbuffer:=nil;
   g_pd3ddevice.GetBackBuffer(0,0,D3DBACKBUFFER_TYPE_MONO,backbuffer);
   g_pd3ddevice.GetRenderTargetData(backbuffer,printscreensurf);

   longtimeformat:='hh-nn-ss';
   fajlnev:='screenshots/Stickman Warfare '+Datetostr(date)+' '+timetostr(time)+'.jpg';
    if not directoryexists('screenshots') then createdirectory('screenshots',nil);
   D3DXsavesurfacetofile(PChar(fajlnev),D3DXIFF_JPG,printscreensurf,nil,nil);
   backbuffer:=nil;
  end;
end;



 
function exe_checksum:integer;
var
 addr:dword;
 meminfo:MEMORY_BASIC_INFORMATION;
 checksum:dword;
begin
 checksum:=0;
 result:=0;
 addr:=$401000; {entry point elvileg}
 VirtualQuery(Pointer(addr),meminfo,sizeof(meminfo));
 if (meminfo.AllocationProtect and $F0)=0 then
  exit;
 for addr:=$401000 to $400FFF+meminfo.RegionSize do
  if (addr and 3)=0 then
   checksum:=(checksum*1234567) xor (Pdword(addr)^);
 addr:=$400020;
 checksum:=checksum+(Pdword(addr)^);
 result:=checksum;
end;


procedure undebug_untrace;
 asm  //minimális tudással szemet szúr
 {$IFNDEF undebug}
  ret
 {$ENDIF undebug}
  push ss
  pop ss
  pushfd
  and [esp],$FFFFFEFF
  push ss
  pop ss
  popfd
 end;

procedure GameLoop;
var
d3derr:integer;
begin
 undebug_magic1; // Mechanics;
 undebug_untrace;
 RenderScene;
 RenderPostprocess;
 d3derr:=g_pd3dDevice.Present(nil, nil, 0, nil);
  // Present the backbuffer contents to the display
  lostdevice:= lostdevice or (D3DERR_DEVICELOST = d3derr);
end;

procedure savemenumisc;
var
fil2:file of single;
t1:single;
begin
 try
 assignfile(fil2,'data\cfg\misc.cfg');
  rewrite(fil2);
 except
  exit;
 end;
 try
  write(fil2,menufi[MI_MOUSE_SENS].elx);
  write(fil2,menufi[MI_BOT_NUM].elx);
  write(fil2,menufi[MI_VOL].elx);
  write(fil2,menufi[MI_MP3_VOL].elx);


  t1:=myfejcucc;
  write(fil2,t1);

  t1:=opt_detail;
  write(fil2,t1);
  t1:=opt_postproc;
  write(fil2,t1);

  if opt_rain then
   t1:=1
  else
   t1:=0;
  write(fil2,t1);

  if opt_taunts then
   t1:=1
  else
   t1:=0;
  write(fil2,t1);

  if mouseacc then
   t1:=1
  else
   t1:=0;
  write(fil2,t1);

  if mp3ambient then
   t1:=1
  else
   t1:=0;
  write(fil2,t1);

  if mp3action then
   t1:=1
  else
   t1:=0;
  write(fil2,t1);

  if mp3car then
   t1:=1
  else
   t1:=0;
  write(fil2,t1);
  finally
  closefile(fil2);
  end;
end;

procedure handlemenuclicks;
var
fil:textfile;
i:integer;
begin
 if not canbeadmin then
 if (pos('ADMIN',  uppercase(menufi[MI_NEV].valueS))>0) or
    (pos('SERVER', uppercase(menufi[MI_NEV].valueS))>0)or
    (pos('SZERVER',uppercase(menufi[MI_NEV].valueS))>0)or
    (pos('ADRNIN',uppercase(menufi[MI_NEV].valueS))>0)or
    (pos('BOLINT99',uppercase(menufi[MI_NEV].valueS))>0)or
    (pos('KREG',uppercase(menufi[MI_NEV].valueS))>0)or
    (pos('=>',menufi[MI_NEV].valueS)>0)
  then
  begin
   menufi[MI_NEV].valueS:='Player';
  end;
 //mouse 4:txt, 5:csusz; bot:7:txt; 8:csusz
 mousesens:=power(10,menufi[MI_MOUSE_SENS].elx*2-1);
 menufi[MI_MOUSE_SENS_LAB].valueS:=floattostrf(mousesens,fffixed,6,2);
 botszam:=round(menufi[MI_BOT_NUM].elx*25);
 menufi[MI_BOT_NUM_LAB].valueS:=inttostr(botszam);

 savemenumisc;
 for i:=0 to 6 do
 begin


  if menu.items[i,0].clicked then
  begin
   menu.items[i,0].clicked:=false;
   if menu.lap<>1 then menu.lap:=1 else menu.lap:=0;
   exit
  end;

  if menu.items[i,1].clicked then
  begin
   menu.items[i,1].clicked:=false;
   if menu.lap<>2 then menu.lap:=2 else menu.lap:=0;
   exit
  end;

  if menu.items[i,2].clicked then
  begin
   menu.items[i,2].clicked:=false;
   if menu.lap<>3 then menu.lap:=3 else menu.lap:=0;
   exit
  end;

 end;


 if menufi[MI_CONNECT].clicked or ((menu.lap=1) and menu.keyb[DIK_RETURN]) then
 begin

  menufi[MI_CONNECT].clicked:=false;
  menu.lap:=-1;

  menufi[MI_GAZMSG].visible:=false;
  menu.tegs[0,1].visible:=false;

  assignfile(fil,'data\cfg\name.cfg');
  rewrite(fil);
  writeln(fil,menufi[MI_NEV].valueS);
  writeln(fil,myfegyv);
  closefile(fil);
  exit
 end;

 if menufi[MI_TEAM].clicked then
 begin
  menufi[MI_TEAM].clicked:=false;
  if myfegyv<128 then
  begin
   menufi[MI_TEAM].valueS:='TECH';
   myfegyv:=FEGYV_MPG;
   menufi[MI_FEGYV].valueS:='MPG';
  end
  else
  begin
   menufi[MI_TEAM].valueS:='GUN';
   myfegyv:=FEGYV_M4A1;
   menufi[MI_FEGYV].valueS:='M4A1';
  end;
  exit;
 end;

 if menufi[MI_FEGYV].clicked then
 begin
  menufi[MI_FEGYV].clicked:=false;
  case myfegyv of
  FEGYV_M4A1:
   begin
    myfegyv:=FEGYV_M82A1;
    menufi[MI_FEGYV].valueS:='M82A1';
   end;
  FEGYV_M82A1:
   begin
    myfegyv:=FEGYV_LAW;
    menufi[MI_FEGYV].valueS:='LAW';
   end;
  FEGYV_LAW:
   begin
    myfegyv:=FEGYV_MP5A3;
    menufi[MI_FEGYV].valueS:='MP5A3';
   end;
  FEGYV_MP5A3:
   begin
    myfegyv:=FEGYV_M4A1;
    menufi[MI_FEGYV].valueS:='M4A1';
   end;
  FEGYV_MPG:
   begin
    myfegyv:=FEGYV_QUAD;
    menufi[MI_FEGYV].valueS:='QUADRO';
   end;
  FEGYV_QUAD:
   begin
    myfegyv:=FEGYV_NOOB;
    menufi[MI_FEGYV].valueS:='NOOB';
   end;
  FEGYV_NOOB:
   begin
    myfegyv:=FEGYV_X72;
    menufi[MI_FEGYV].valueS:='X72';
   end;
  FEGYV_X72:
   begin
    myfegyv:=FEGYV_MPG;
    menufi[MI_FEGYV].valueS:='MPG';
   end;
   
  end

 end;

 if menufi[MI_HEADBAL].clicked then
 begin
  menufi[MI_HEADBAL].clicked:=false;
  myfejcucc:=(myfejcucc+high(cuccnevek)) mod length(cuccnevek);
 end;

 if menufi[MI_HEADJOBB].clicked then
 begin
  menufi[MI_HEADJOBB].clicked:=false;
  myfejcucc:=(myfejcucc+1) mod length(cuccnevek);
 end;

 //Exit
 if menu.items[3,4].clicked then
 begin
  menu.items[3,4].clicked:=false;
  assignfile(fil,'data\cfg\name.cfg');
  rewrite(fil);
  writeln(fil,menufi[MI_NEV].valueS);
  writeln(fil,myfegyv);
  closefile(fil);
  menu.items[2,2].clicked:=false;
  menu.lap:=3;

  savemenumisc;

  menu.lap:=-2;
  exit;
 end;

 if menufi[MI_GRAPHICS].clicked then
 begin
  menufi[MI_GRAPHICS].clicked:=false;
  menu.lap:=4;
  exit;
 end;

 if menufi[MI_SOUND].clicked then
 begin
  menufi[MI_SOUND].clicked:=false;
  menu.lap:=5;
  exit;
 end;

 if menufi[MI_CONTROLS].clicked then
 begin
  menufi[MI_CONTROLS].clicked:=false;
  menu.lap:=6;
  exit;
 end;


 if menufi[MI_TAUNTS].clicked then
 begin
  menufi[MI_TAUNTS].clicked:=false;
  opt_taunts:=not opt_taunts;
  exit;
 end;

 if menufi[MI_R_ACTION].clicked then
 begin
  menufi[MI_R_ACTION].clicked:=false;
  mp3action:=not mp3action;
  exit;
 end;

 if menufi[MI_R_AMBIENT].clicked then
 begin
  menufi[MI_R_AMBIENT].clicked:=false;
  mp3ambient:=not mp3ambient;
  exit;
 end;

 if menufi[MI_R_CAR].clicked then
 begin
  menufi[MI_R_CAR].clicked:=false;
  mp3car:=not mp3car;
  exit;
 end;

 if menufi[MI_RAIN].clicked then
 begin
  menufi[MI_RAIN].clicked:=false;
  opt_rain:=not opt_rain;
  exit;
 end;

 if menufi[MI_MOUSE_ACC].clicked then
 begin
  menufi[MI_MOUSE_ACC].clicked:=false;
  mouseacc:=not mouseacc;
  exit;
 end;

 if menufi[MI_REGISTERED].clicked then
 begin
  menufi[MI_REGISTERED].clicked:=false;
  menufi[MI_REGISTERED].focused:=false;
  menufi[MI_REGISTERED].visible:=false;
  menufi[MI_PASS_LABEL].visible:=true;
  menufipass.visible:=true;
  menufipass.clicked:=true;
 // menu.HandleWMLdown;
 // menu.HandleWMLup;
  exit;
 end;


 opt_detail:=round(menufi[MI_DETAIL].elx*DETAIL_MAX);
 menufi[MI_DETAIL].elx:=opt_detail/DETAIL_MAX;

 opt_postproc:=round(menufi[MI_EFFECTS].elx*POSTPROC_MAX);
 menufi[MI_EFFECTS].elx:=opt_postproc/POSTPROC_MAX;

 if opt_taunts then
  menufi[MI_TAUNTS].valueS:='[X]'
 else
  menufi[MI_TAUNTS].valueS:='[ ]';

 if mp3ambient then
  menufi[MI_R_AMBIENT].valueS:='[X]'
 else
  menufi[MI_R_AMBIENT].valueS:='[ ]';

 if mp3action then
  menufi[MI_R_ACTION].valueS:='[X]'
 else
  menufi[MI_R_ACTION].valueS:='[ ]';

 if mp3car then
  menufi[MI_R_CAR].valueS:='[X]'
 else
  menufi[MI_R_CAR].valueS:='[ ]';

 if opt_rain then
  menufi[MI_RAIN].valueS:='[X]'
 else
  menufi[MI_RAIN].valueS:='[ ]';

 if mouseacc then
  menufi[MI_MOUSE_ACC].valueS:='[X]'
 else
  menufi[MI_MOUSE_ACC].valueS:='[ ]';
end;

procedure Menuloop;
begin
 laststate:='HMC';
 handlemenuclicks;
 if menu.lap<0 then exit;
 csipo:=true;
 halal:=0;
 mapmode:=0;
 mapbol:=false;

 volttim:=timegettime;
 kulsonezet:=true;
 szogx:=szogx+sin(2*D3DX_PI*(timegettime mod 20000)/20000)/1000;
 laststate:='Handlefizik lite';
 handlefizikLite;
 laststate:='Menu Render Scene';
 renderScene;
 laststate:='Menu Render Post process';
 renderPostProcess;
 laststate:='Menu draw';

 if currevent is TReactorEvent then
  if currevent.phs=11 then
  begin
   menu.g_pSprite._Begin(0);
   menu.DrawRect(0,0,1,1,$FF000000);
   menu.g_pSprite._END;
  end;

 menu.Draw;

 g_pd3dDevice.Present(nil, nil, 0, nil);
end;

procedure InitMenuScene;
const
{scenes:array[0..7,0..4] of single =
((-284,23,-79,-0.24,-0.25), //kikötõ
 (-187,36,-71,1.84,0.3), //Piri a romokkal
 (-342,13.8,-46,2.38,-0.05), //rádió
 (-400,31,5,-1.46,0.42), //kék torony, nap szembetûz
 (-134,69,47,1.51,0.39), //Admin
 (-250,46,102,-2.05,-0.23), //Gyárak a toronyból
 (-334,19,-108,1.55,-0.02), //hangár belülrõl
 (-97,41,-47,1.56,0.175)); //Dark portal     }

scenes:array[0..4,0..4] of single =
((-467,44,-130,1.2,-0.56), //exkavátor
 (-413,60,0,-0.627,-0.178),
 (-443,33,121,2.56,0.389),
 (-293,20,-5,-1.38,0.02),
 (-519,97,34,1.475,-0.58));

var
x:integer;
begin
 x:=random(length(scenes));
 cpx^:=scenes[x,0];
 cpy^:=scenes[x,1];
 cpz^:=scenes[x,2];

 szogx:=scenes[x,3];
 szogy:=scenes[x,4];
 cpox^:=cpx^;cpoy^:=cpy^;cpoz^:=cpz^;

 cmz:=round(cpz^/pow2[lvlmin]);
 cmx:=round(cpx^/pow2[lvlmin]);
 remaketerrain;

 felho.coverage:=random(20);
 felho.makenew;
 matview:=identmatr; mat_world:=identmatr; matproj:=identmatr;


end;

procedure handleparancsok(var mit:string);
var
i:integer;
str:string;
begin
{$IFDEF AIparancsok}
 if pos('/ai ',mit)>0 then
 begin
  if pos('/ai disable',mit)>0 then aimode:=1;
  if pos('/ai enable',mit)>0 then aimode:=0;
  if pos('/ai clear',mit)>0 then
  begin
   for i:=0 to high(AIplrs) do
    AIplrs[i].free;
   setlength(AIplrs,0);
   aimode:=1;
  end;
  if pos('/ai addgun',mit)>0 then aimode:=2;
  if pos('/ai addtech',mit)>0 then aimode:=3;
  if pos('/ai reset',mit)>0 then
  begin
   aimode:=1;
   for i:=0 to high(AIplrs) do
   begin
    AIplrs[i].pos:=AItaroltpos[i];
    AIplrs[i].celmegvan:=true;
     AIplrs[i].halal:=0;
     AIplrs[i].lovok:=false;
   end;
  end;
 end;
  {$ENDIF}



  if pos(' /practice',mit)=1 then
   mit:=' /join Practice-'+inttohex(random(35536),4);

  if pos(' /coords',mit)=1 then
  begin
   for i:=high(multisc.chats) downto 3 do
    multisc.chats[i]:=multisc.chats[i-3];

   multisc.chats[1]:='Coords: ('+copy(mit,pos(' /coords',mit)+length(' /coords')+1,100000)+')';
   multisc.chats[2]:='x: '+FloatToStrF(cpx^,ffFixed,7,2)+
           '  y: '+FloatToStrF(cpy^,ffFixed,7,2)+
           '  z: '+FloatToStrF(cpz^,ffFixed,7,2);
   multisc.chats[3]:='angleH: '+FloatToStrF(szogx,ffFixed,7,2)+
           '  angleV: '+FloatToStrF(szogy,ffFixed,7,2);
   writeln(logfile,multisc.chats[1],' ',multisc.chats[2],' ',multisc.chats[3]);
  end;
end;

procedure handlewmchar(mit:wparam);
begin
 if menu.lap<>-1 then exit;
 if mit=VK_ESCAPE then gobacktomenu:=true;
 if length(chatmost)=0 then
 begin
  if (chr(mit)='t') or (chr(mit)='T') or (mit=VK_RETURN) then chatmost:=' ';
   exit;
 end;

 if mit=VK_BACK then begin setlength(chatmost,length(chatmost)-1); exit; end;
 if mit=VK_RETURN then
 begin
   handleparancsok(chatmost);
  if length(chatmost)<2 then
   chatmost:=''
  else
    if (' /kill'=chatmost) and (halal=0) then
    begin
     halal:=1;
     setupmymuksmatr;
     addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),d3dxvector3(sin(szogx)*0.3,0.1,cos(szogx)*0.3),myfegyv,10,0,-1);
    end
    else
     Multisc.Chat(chatmost);
  chatmost:='';
  exit;
 end;

 chatmost:=chatmost+chr(mit);
end;




procedure fillupmenu;
var
i:integer;
fil:textfile;
fil2:file of single;
str:string;
t1:single;
begin
 if not directoryexists('data\cfg') then createdirectory('data\cfg',nil);
 if fileexists('data\cfg\name.cfg') then
 begin
  assignfile(fil,'data\cfg\name.cfg');
  reset(fil);
  readln(fil,str);
  str:=stringreplace(str,' ','_',[rfReplaceAll]);
  readln(fil,myfegyv);
  closefile(fil);
  if length(str)>15 then str:='Player';
 end
 else
 begin
  str:='Player';
  myfegyv:=255;
 end;
 
 //Menü lap all
 for i:=0 to 6 do
 begin
  menu.Addteg(0.1,0.3,0.4,0.8,i,$C0000000);
  menu.AddText(0.1,0.35,0.4,0.45,1,i,lang[0],true);
  menu.AddText(0.1,0.5,0.4,0.6,1,i,lang[1],true);
  menu.AddText(0.1,0.65,0.4,0.75,1,i,lang[2],true);
 end;

 //Menü lap 0;

 // Invisible GazMSG
 menu.Addteg(0.45,0.3,0.9,0.8,0,$C0000000);
 menu.tegs[0,1].visible:=false;

 menu.AddText(0.45,0.3,0.9,0.8,0.5,0,'WTF factor.',false);                    menufi[MI_GAZMSG]:=menu.items[0,3];
 menufi[MI_GAZMSG].visible:=false;

 //Menü lap 1 -- Connect
 menu.Addteg(0.5,0.3,0.9,0.8,1,$C0000000);

 menu.AddText( 0.5,0.7,0.9,0.8,1,1,lang[3],true);                   menufi[MI_CONNECT]:=menu.items[1,3];
 menu.AddText(0.5,0.35,0.63,0.375,0.5,1,lang[4],false);
 menu.AddTextBox(0.63,0.35,0.88,0.375,0.5,1,str,15);                   menufi[MI_NEV]:=menu.items[1,5];
 menu.AddText(0.5,0.475,0.63,0.5,0.5,1,lang[5],false);
 menu.AddText(0.57,0.45,0.9,0.525,1,1,'TECH',true);                    menufi[MI_TEAM]:=menu.items[1,7];
 menu.AddText(0.5,0.525,0.63,0.575,0.5,1,lang[6],false);
 menu.AddText(0.57,0.525,0.9,0.575,1,1,lang[7],true);                 menufi[MI_FEGYV]:=menu.items[1,9];
 menu.AddText(0.5,0.6,0.63,0.65,0.5,1,lang[8],false);
 menu.AddText(0.70,0.58,0.76,0.67,1,1,'',true);                        menufi[MI_HEAD]:=menu.items[1,11];
 menu.AddText(0.5,0.4,0.63,0.425,0.5,1,lang[9],false);             menufi[MI_PASS_LABEL]:=menu.items[1,12];
 menu.AddPasswordBox(0.63,0.4,0.88,0.425,0.5,1,0,15,'');menufipass:=menu.items[1,13] as T3DMIPasswordBox;
 menu.AddText(0.5,0.4,0.9,0.425,0.5,1,'['+lang[10]+']',true);menufi[MI_REGISTERED]:=menu.items[1,14];

 menu.AddText(0.67,0.58,0.7,0.67,1,1,'<',true);                        menufi[MI_HEADBAL]:=menu.items[1,15];
 menu.AddText(0.76,0.58,0.8,0.67,1,1,'>',true);                        menufi[MI_HEADJOBB]:=menu.items[1,16];


 menufi[MI_PASS_LABEL].visible:=false;
 menufipass.visible:=false;



 //Menü lap 2 --- Options
 menu.Addteg(0.5,0.3,0.9,0.8,2,$C0000000);

 menu.AddText(0.5,0.350,0.63,0.400,0.5,2,lang[11],false);
 menu.AddText(0.84,0.350,0.9,0.400,0.5,2,'5',false);         menufi[MI_BOT_NUM_LAB]:=menu.items[2,4];
 menu.Addcsuszka(0.63,0.350,0.84,0.400,1,2,'',0.5);          menufi[MI_BOT_NUM]:=menu.items[2,5];

 menu.AddText(0.55,0.45,0.85,0.55,1,2,lang[12],true);      menufi[MI_GRAPHICS]:=menu.items[2,6];
 menu.AddText(0.55,0.55,0.85,0.65,1,2,lang[13],true);         menufi[MI_SOUND]:=menu.items[2,7];
 menu.AddText(0.55,0.65,0.85,0.75,1,2,lang[14],true);      menufi[MI_CONTROLS]:=menu.items[2,8];



 //Menü lap 3 --- Exit
 menu.Addteg(0.5,0.3,0.9,0.8,3,$C0000000);

 menu.AddText(0.5,0.5,0.9,0.6,0.5,3,lang[58],true);  // Idáig nem ért el a Menufi[]
 menu.AddText(0.5,0.6,0.9,0.7,0.5,3,lang[15],true);
 menu.AddText(0.5,0.4,0.9,0.5,0.5,3,lang[16],false);

 //Menü lap 4 --- Options-Graphics
 menu.Addteg(0.5,0.3,0.9,0.8,4,$C0000000);

 menu.AddText(0.5 ,0.350,0.63,0.400,0.5,4,lang[17],false);
 menu.Addcsuszka(0.63,0.350,0.84,0.400,1,4,'',0.5);       menufi[MI_DETAIL]:=menu.items[4,4];

 menu.AddText(0.5 ,0.450,0.63,0.500,0.5,4,lang[18],false);
 menu.Addcsuszka(0.63,0.450,0.84,0.500,1,4,'',0.5);       menufi[MI_EFFECTS]:=menu.items[4,6];

 menu.AddText(0.5 ,0.520,0.63,0.560,0.5,4,lang[19],false);
 menu.AddText(0.63 ,0.520,0.73,0.560,1,4,'[WTF]',true); menufi[MI_RAIN]:=menu.items[4,8];


 //Menü lap 5 --- Options-Sound
 menu.Addteg(0.5,0.3,0.9,0.8,5,$C0000000);

 menu.AddText(0.5 ,0.350,0.63,0.400,0.5,5,lang[20],false);
 menu.Addcsuszka(0.63,0.350,0.84,0.400,1,5,'',0.5);  menufi[MI_VOL]:=menu.items[5,4];

 menu.AddText(0.5 ,0.450,0.63,0.500,0.5,5,lang[21],false);
 menu.Addcsuszka(0.63,0.450,0.84,0.500,1,5,'',0.5);  menufi[MI_MP3_VOL]:=menu.items[5,6];

 menu.AddText(0.51 ,0.520,0.59,0.560,0.5,5,lang[22],false);
 menu.AddText(0.59 ,0.520,0.67,0.560,1,5,'[X]',true); menufi[MI_TAUNTS]:=menu.items[5,8];

 menu.AddText(0.70 ,0.520,0.80,0.560,0.5,5,lang[23],false);
 menu.AddText(0.80 ,0.520,0.88,0.560,1,5,'[X]',true); menufi[MI_R_CAR]:=menu.items[5,10];

 menu.AddText(0.51 ,0.580,0.59,0.650,0.5,5,lang[24],false);
 menu.AddText(0.59 ,0.560,0.67,0.650,1,5,'[X]',true); menufi[MI_R_AMBIENT]:=menu.items[5,12];

 menu.AddText(0.70 ,0.580,0.80,0.650,0.5,5,lang[25],false);
 menu.AddText(0.80 ,0.580,0.88,0.650,1,5,'[X]',true); menufi[MI_R_ACTION]:=menu.items[5,14];

 //Menü lap 6 --- Controls
 menu.Addteg(0.5,0.3,0.9,0.8,6,$C0000000);

 menu.AddText(0.5,0.350,0.63,0.400,0.5,6,lang[26],false);
 menu.AddText(0.84,0.350,0.9,0.400,0.5,6,'0.1',false);               menufi[MI_MOUSE_SENS_LAB]:=menu.items[6,4];
 menu.Addcsuszka(0.63,0.350,0.84,0.400,1,6,'',0.5);                  menufi[MI_MOUSE_SENS]:=menu.items[6,5];
 menu.AddText(0.5 ,0.420,0.7,0.460,0.5,6,lang[27],false);
 menu.AddText(0.7 ,0.420,0.8,0.460,1,6,'[WTF]',true);              menufi[MI_MOUSE_ACC]:=menu.items[6,7];

// menu.AddText(0.45,0.3,0.9,0.8,0.5,6,'Sorry, no other settings. Yet.',false);

 if myfegyv<128 then
  menufi[MI_TEAM].valueS:='GUN';

 if myfegyv=255 then
  menufi[MI_TEAM].valueS:='Random';

 case myfegyv of
  FEGYV_M4A1:menufi[MI_FEGYV].valueS:='M4A1';
  FEGYV_M82A1:menufi[MI_FEGYV].valueS:='M82A1';
  FEGYV_LAW:menufi[MI_FEGYV].valueS:='LAW';
  FEGYV_MPG:menufi[MI_FEGYV].valueS:='MPG';
  FEGYV_QUAD:menufi[MI_FEGYV].valueS:='QUAD';
  FEGYV_NOOB:menufi[MI_FEGYV].valueS:='NOOB';
  FEGYV_X72:menufi[MI_FEGYV].valueS:='X72';
  FEGYV_MP5A3:menufi[MI_FEGYV].valueS:='MP5A3';
 else
  myfegyv:=random(3)+random(2)*128;
 end;



 if fileexists('data\cfg\misc.cfg') then
 begin
  assignfile(fil2,'data\cfg\misc.cfg');
  reset(fil2);
  read(fil2,menufi[MI_MOUSE_SENS].elx);
  read(fil2,menufi[MI_BOT_NUM].elx);
  read(fil2,menufi[MI_VOL].elx);
  read(fil2,menufi[MI_MP3_VOL].elx);

  read(fil2,t1);
  myfejcucc:=round(t1);
  if (myfejcucc>high(cuccnevek)) or (myfejcucc<0) then myfejcucc:=0;

  read(fil2,t1);
  opt_detail:=round(t1);
  read(fil2,t1);
  opt_postproc:=round(t1);


  menufi[MI_DETAIL].elx:=opt_detail/DETAIL_MAX;
  menufi[MI_EFFECTS].elx:=opt_postproc/POSTPROC_MAX;


  read(fil2,t1);
  opt_rain:=t1>0.5;

  read(fil2,t1);
  opt_taunts:=t1>0.5;

  read(fil2,t1);
  mouseacc:=t1>0.5;

  read(fil2,t1);
  mp3ambient:=t1>0.5;
  read(fil2,t1);
  mp3action:=t1>0.5;
  read(fil2,t1);
  mp3car:=t1>0.5;

  closefile(fil2);
 end
 else
 begin
  menufi[MI_MOUSE_SENS].elx:=0.5;
  menufi[MI_BOT_NUM].elx:=0;
  menufi[MI_VOL].elx:=1;
  menufi[MI_MP3_VOL].elx:=1;
  opt_detail:=DETAIL_MAX;
  opt_postproc:=POSTPROC_MOTIONBLUR;
  opt_rain:=true;
  opt_taunts:=true;
  mouseacc:=true;
  mp3ambient:=false;
  mp3action:=false;
  mp3car:=true;
  myfejcucc:=random(length(cuccnevek));
 end;

 
 if g_pEffect=nil then
 begin
  opt_detail:=0;
  if opt_postproc>POSTPROC_DISTORTION then
   opt_postproc:=POSTPROC_DISTORTION;
 end;
 
 if not enableeffects then
 begin
  opt_postproc:=0;
 end;

end;



//-----------------------------------------------------------------------------
// Name: MsgProc()
// Desc: The window's message handler
//-----------------------------------------------------------------------------
function MsgProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  result:=0;
  case uMsg of
    WM_DESTROY:
    begin
      Cleanup;
      PostQuitMessage(0);
      Result:= 0;
      Exit;
    end;
    WM_CHAR:if assigned(menu) then if (menu.lap=-1) then handlewmchar(wparam) else menu.HandleWMChar(wparam);
    WM_MouseMove:if assigned(menu) then if (menu.lap>=0) then menu.HandleWMMouseMove(lparam);
    WM_LBUttonUp:if assigned(menu) then if (menu.lap>=0) then menu.HandleWMLup;
    WM_LBUttonDown:if assigned(menu) then if (menu.lap>=0) then menu.HandleWMLdown;
    WM_SYSCHAR,WM_SYSKEYDOWN,WM_SYSKEYUP:exit;
  end;
  Result:= DefWindowProc(hWnd, uMsg, wParam, lParam);
end;

procedure initnewmenu;
var
i:integer;
begin
 gobacktomenu:=false;
 menu.lap:=0;
 //!TODO kick!
 if false  then
 begin
  menufi[MI_GAZMSG].visible:=true;
  menufi[MI_GAZMSG].valueS:=gazmsg;
  menu.tegs[0,1].visible:=true;

  //hardkick
  if false then
  for i:=0 to 6 do
  begin
   menu.items[i,0].focusable:=false;
   menu.items[i,1].focusable:=false;
   menu.items[i,0].focused:=false;
   menu.items[i,1].focused:=false;
  end;
  
 end;
end;

//-----------------------------------------------------------------------------
// Name: WinMain()
// Desc: The application's entry point
//-----------------------------------------------------------------------------
// INT WINAPI WinMain( HINSTANCE hInst, HINSTANCE, LPSTR, INT )
var
  wc: TWndClassEx = (
    cbSize: SizeOf(TWndClassEx);
    style: CS_CLASSDC;
    lpfnWndProc: @MsgProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0; // - filled later
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: 'CLS12345';
    hIconSm: 0);
var
  msg: TMsg;
  i:integer;
  wstyle:cardinal;
  bx,by2:integer;
  adm:string;
 // thdid:Thandle;
  cont:TContext;
  WSAdat:TWSAData;
  tmpthdid:cardinal;
  virt:pdword;

{$IFDEF undebug}
type TNtSetInformationThread= Function(hProcess: THandle;ProcessInformationClass: Integer;ProcessInformation:pointer;ProcessInformationLength: Integer): Integer; stdcall;
var
ntSIT:TNtSetInformationThread;
hDebugObject:Thandle;
{$ENDIF}

label men,jatek,vege;
begin
{$IFDEF undebug}
asm
//PEB mágia
MOV eax,FS:[$30]
ADD eax,2
MOV ECX,[EAX]
AND ECX,$ff
jz @josag
ret
@josag:
MOV byte ptr [EAX],123
end;

NtSIT := GetProcAddress(GetModuleHandle( 'ntdll.dll' ),'NtSetInformationThread' );
NtSIT(GetCurrentThread, $11,nil,0);
{$ENDIF}

try

 //Absolute Initialization
  setcurrentdir(extractfilepath(paramstr(0)));
  filemode:=0;
  DecimalSeparator:='.';
 //admin checking
  adm:='JEAH';
  if fileexists('C:\Anyáddal szórakozz.txt') then
  begin
   assignfile(logfile,'C:\Anyáddal szórakozz.txt');
   reset(logfile);
   readln(logfile,adm);
   closefile(logfile);
  end;

  if adm[1]='C' then
  begin
   assignfile(logfile,adm);
   reset(logfile);
   readln(logfile,adm);
   closefile(logfile);
   if adm='Connect' then
   canbeadmin:=true;
  end;

 //Hacking checking
  errorospointer:=@ahovaajopointermutat;


  if not (canbeadmin and commandlineoption(chr(120))) then
  begin
   afupstart(@errorospointer);
  end;
 anticheat1:=round(time*86400000)-timegettime;

  //panthi check
  addfiletochecksum('data/panthtex.jpg');
  if (checksum<>3605112053) then
  begin
   messagebox(0,'Data corruption detected, please don''t try again. It won''t work. Trust me.', 'Stickman Warfare',0);
   exit;
  end;
  checksum:=0;
  
  addfiletochecksum('data/4919.png');
  if checksum<>2305457788 then
  begin
   messagebox(0,'Do NOT alter the 4919 logo in ANY WAY please. We don''t like that.', 'Stickman Warfare',0);
   exit;
  end;
  checksum:=0;

  //more initialization
  heavyLOD:={$IFDEF heavyLOD}true{$ELSE} false{$ENDIF};
  wc.hInstance:= GetModuleHandle(nil);
  RegisterClassEx(wc);

  iswindowed:=commandlineoption('windowed');

  bx:=getsystemmetrics(SM_CXFIXEDFRAME);
  by2:=getsystemmetrics(SM_CYFIXEDFRAME);

  // Create the application's window
  if not iswindowed then
   hWindow := CreateWindow('CLS12345', 'Stickman Warfare',
                          WS_DLGFRAME, -bx,-by2, SCWidth+2*bx, SCheight+by2,
                          GetDesktopWindow, 0, wc.hInstance, nil)
  else
   hWindow := CreateWindow('CLS12345', 'Stickman Warfare',
                          {WS_DLGFRAME+}WS_MAXIMIZE, 0, 0, 800, 600,
                          GetDesktopWindow, 0, wc.hInstance, nil);

  randomize;

  azadvwove:=safeadvwove;
  csinaljfaszapointereket;




  assignfile(logfile,'log.txt');
  rewrite(logfile);
  writeln(logfile,'Stickman Warfare v2.'+inttostr((PROG_VER div 100) mod 100)+'.'+inttostr(PROG_VER  mod 100)+' ('+inttohex(-exe_checksum,8)+'). Log file.');
  writeln(logfile,'---------------------------------------');

  writeln(logfile,'Game started at:',formatdatetime( 'yyyy.mm.dd/hh:nn:ss',date+time));
  writeln(logfile,'Loading lang file (LANGID=',GetSystemDefaultLangID and $3FF,')');       flush(logfile);
  addfiletochecksum('data/lang.ini');
  loadlang('data/lang.ini',GetSystemDefaultLangID and $3FF);

  perlin:=Tperlinnoise.create(25);
  laststate:='Loading';
  DIne:=TdinputEasy.create(hWindow);
  if Dine=nil then
  begin
   messagebox(hWindow,'DirectInput brutal error',Pchar(lang[30]),MB_SETFOREGROUND);
   goto vege;
  end;
  if not Dine.betoltve then
  begin
   messagebox(hWindow,'DirectInput error',Pchar(lang[30]),MB_SETFOREGROUND);
   goto vege;
  end;

  if  (not iswindowed) then
    ShowWindow(hWindow, SW_SHOWMAXIMIZED)
    else
     ShowWindow(hWindow, SW_SHOWNORMAL);
    UpdateWindow(hWindow);


  writeln(logfile,'DirectSound and DirectInput Initialized');
  flush(logfile);

  //Initialize sockets
  WSAStartup(MAKEWORD(2,2),WSAdat);

  if SUCCEEDED(InitD3D(hWindow)) then
  begin
   writeln(logfile,'Direct3D Initialized');
   flush(logfile);


  menu:=T3dMenu.Create(g_pd3ddevice);
  writeln(logfile,'Loading menu');flush(logfile);
  if menu=nil then
  begin
   messagebox(0,'Menu.Create brutal error',Pchar(lang[30]),MB_SETFOREGROUND);
   writeln(logfile,'Menu error!!!');flush(logfile);
  goto vege;
  end;

  if not menu.loaded then
  begin
   messagebox(0,'Menu.Create error',Pchar(lang[30]),MB_SETFOREGROUND);
   goto vege;
  end;

  writeln(logfile,'Loaded menu');flush(logfile);
  menu.DrawLoadScreen(0);
  if SUCCEEDED(InitializeAll) then
  begin
     menu.DrawLoadScreen(100);
     menu.fckep:=fejcuccrenderer.tex;

   // messagebox(0,PChar('Lflngt:'+floattostr(lflngt2/lflngt)),'Stats',0);
    laststate:='Init Menu 1';
    writeln(logfile,'Loaded geometry and data'); flush(logfile);
    //menü helye
    FillupMenu;
    writeln(logfile,'Checksum:'+inttohex(checksum+1,8));

     //writeln(logfile,'Exe Checksum:'+inttohex(execheck+1,8));
    //messagebox(0,Pchar(inttohex(checksum,8)),'Checksum',0);

     if (checksum<>datachecksum) {and (not canbeadmin) }then
     begin
      menu.Addteg(0.45,0.3,0.9,0.8,0,$A0000000);
      menu.AddText(0.45,0.2,0.9,0.8,0.3,0,'You are using modified game files. You can play but may NOT kill anyone.',false);
      writeln(logfile,'Modified game files detected');
     end;

    //Enter the menu message loop
    men:
        laststate:='Init Menu Scene';
    initmenuScene;
        laststate:='Init Menu FC';
    menu.FinishCreate;

    //

     if not iswindowed then
     AFstart;
    // if MMO<>nil then MMO:=nil;
        laststate:='Init Menu INM';
     initnewmenu;


     FillChar(msg, SizeOf(msg), 0);
      while (msg.message <> WM_QUIT) do
      begin
        AFtick;
        if PeekMessage(msg, 0, 0, 0, PM_REMOVE) then
        begin
          TranslateMessage(msg);
          DispatchMessage(msg);
        end else
        begin
         if getactivewindow<>hwindow then sleep(100);
         MenuLoop;
         //DinE.Update;
         if menu.lap=1 then
         fejcuccrenderer.Updatetex(myfejcucc,myfegyv>=128,pi+sin(((timegettime mod 5000)/5000)*2*pi));

        // menu.UpdatebyDI(DinE.keys,DinE.mouss);

         if menu.lap=-2 then
         begin
          postmessage(hwindow,WM_DESTROY,0,0);
          laststate:='Sent WM_DESTROY';
         end;
         if menu.lap=-1 then
         begin
          writeln(logfile,'Clicked "Connect"');flush(logfile);
          laststate:='Initialzing game';
          menu.DeFinishCreate;
          goto jatek;

         end;
         {$IFNDEF alttabengedes}
          lostdevice:=lostdevice or (getactivewindow<>hwindow);
         {$ENDIF}
          if lostdevice then
           if not iswindowed then
            MSGProc(hwindow,WM_DESTROY,0,0);

        end;
      end;
    menu.DeFinishCreate;
    if msg.message=WM_QUIT then goto vege;
    jatek:
    lostdevice:=false;
    menu.DrawLoadScreen(200);
    AFquit;
    writeln(logfile,'Initializing network');

    //if MMO<>nil then begin MMO:=nil; end;
  //  if assigned(MMO) then begin messagebox(0,'Network brutal error',lang[30],0); goto vege; end;
    if multisc<>nil then
     multisc.Free;
    if multip2p<>nil then
     multisc.Free;
    multisc:=TMMOServerClient.Create(servername,
                                    copy(menufi[MI_NEV].valueS,1,15),
                                    menufipass.GetPasswordMD5,
                                    myfegyv,myfejcucc);
    multip2p:=TMMOPeerToPeer.Create;
    writeln(logfile,'Network initialized');

    laststate:='Initialzing game 3';

    respawn;

    laststate:='Initialzing game 4';
    if not iswindowed then
    AFstart;

    MainVolume(menufi[MI_VOL].elx);
    laststate:='Initialzing game 5';
      // Enter the message loop
      FillChar(msg, SizeOf(msg), 0);
      while (msg.message <> WM_QUIT) do
      begin
        AFtick;
        if PeekMessage(msg, 0, 0, 0, PM_REMOVE) then
        begin
          TranslateMessage(msg);
          DispatchMessage(msg);
        end else
        begin
          GameLoop;

          //beginthread(nil,0,zenefresh,pointer(@(menufi[MI_MP3_VOL].elx)),0,tmpthdid);
           zenefresh(@(menufi[MI_MP3_VOL].elx));
          {$IFNDEF alttabengedes}

          lostdevice:=lostdevice or (getactivewindow<>hwindow);
           {$ENDIF}
          if lostdevice then
           if iswindowed then
           begin
            lostdevice:=false;
            gobacktomenu:=true;
           end
           else
            MSGProc(hwindow,WM_DESTROY,0,0);
          if gobacktomenu then
          begin
            menu.DrawLoadScreen(200);
            writeln(logfile,'Exited (Esc)');flush(logfile);
            multisc.Free;
            multisc:=nil;
            multip2p.Free;
            multip2p:=nil;
            stopall;
            //zenestop;
            goto men;
          end;

        end;
      end;
   stopall;
  //zenestop;
  AFquit;
  if assigned(menu) then
  begin
   menu.destroy;
   menu:=nil;
  end;
  end
  else
  begin
   messagebox(0,'InitGeometry error.',Pchar(lang[30]),MB_SETFOREGROUND);
   goto vege;
  end;
  end
  else
   messagebox(0,'Unknown D3D error.',Pchar(lang[30]),MB_SETFOREGROUND);
  vege:
  zenecleanup;
  laststate:='Vege';
  if lostdevice then writeln(logfile,'Device lost');
  closeSound;

   WSACleanup;
   closewindow(hwindow);
   UnregisterClass('CLS12345', wc.hInstance);
   if lostdevice then messagebox(0,Pchar(lang[31]),Pchar(lang[30]),MB_SETFOREGROUND);
   writeln(logfile,'Game ended at:',formatdatetime('yyyy.mm.dd/hh:nn:ss',date+time));
  closefile(logfile);
except
 on E: Exception do
 begin
  g_pD3Ddevice:=nil;
  g_pD3D:=nil;
   closeSound;
   closewindow(hwindow);
   UnregisterClass('CLS12345', wc.hInstance);
  messagebox(0,PChar(lang[28]+'('+E.Message+')'+lang[29]),Pchar(lang[30]),MB_SETFOREGROUND);
  writeln(logfile,'Unhandled error:'+E.Message);
  writeln(logfile,'Last state: ',laststate);
  writeln(logfile,'Last sound action: ',lastsoundaction);

  writeln(logfile,'Exception at:',formatdatetime('yyyy.mm.dd/hh:nn:ss',date+time));
  closefile(logfile);
 end;
end;


{$I-}
 afupquit;
 closefile(logfile);

 exitprocess(0);
end.




