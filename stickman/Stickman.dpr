(* Stickman Warfare Source Code              *
 * ----------------------------------------- *
 * All rights reserved                       *
 *                                           *
 * Almost everything in this file and the    *
 * units are written by Badics Alex          *
 *                           and Háda Ádám.  *
 *                                           *
 * Except: PerlinNoise (i got that from      *
 *                      a forum)             *
 *         D3D units   (www.clootie.ru)      *
 *                                           *)
{$R stickman.RES}
{$DEFINE force16bitindices} //ez hibás, pár helyen, ha nincs kipontozva, meg kell majd nézni
{.$DEFINE undebug}
{.$DEFINE panthihogomb}
{.$DEFINE nochecksumcheck}
{.$DEFINE speedhack}
{.$DEFINE repkedomod}
{.$DEFINE godmode}
{.$DEFINE admingun}
{.$DEFINE palyszerk}
{.$DEFINE ajandekok}
{.$DEFINE alttabengedes}
{.$DEFINE matieditor}
{.$DEFINE profiler}

program Stickman;

uses
  AntiFreeze,
  D3DX9,
  Direct3D9,
  DinputE,
  DirectSound,
  Directinput,
  eventscripts,
  fegyverek,
  filectrl,
  fizika,
  foliage ,
  //generated,
  Math,
  Messages,
  MMSystem,
  muksoka,
  multiplayer,
  myUI,
  newsoundunit,
  ojjektumok,
  props,
  ParticleSystem,
  PerlinNoise,
  qjson,
  sky,
  Sysutils,
  SyncObjs,
  ShellApi,
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
fuszin=$00FFFFFF;
koszin=$FFFFFFFE;
lvmi=lvlsiz div 4; //lvlsiz div 4
lvma=lvmi*3-1;


MAXszog=3.141592654/2-0.1;
pow2:array [-10..20] of single=(1/1024,1/512,1/256,1/128,1/64,1/32,1/16,1/8,1/4,1/2,1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576);
pow2i:array [0..15] of word=(1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768);

RB_MAX_IDO=6000;

DETAIL_POM=1;
DETAIL_LIGHT=2;
DETAIL_MAX=2;

POSTPROC_DISTORTION=1;
POSTPROC_GREYSCALE=2;
POSTPROC_GLOW=3;
POSTPROC_MAX=3;

WATER_MAX=3;

PARTICLE_MAX=3;

PSYS_SIMPLE=1;
PSYS_GRAVITY=2;
PSYS_COOLING=3;
PSYS_LIGHTNING=4;
PSYS_FIRE=5;
PSYS_LIGHT=6;

//itten balaszoljunk
BALANCE_LAW_RAD=5;
BALANCE_NOOB_RAD=5.5;
BALANCE_X72_RAD=0.47; //minimum
BALANCE_H31_RAD=1.0;


//-----------------------------------------------------------------------------
// Global variables
//-----------------------------------------------------------------------------
var
  // REMOVE

{$IFDEF matieditor}

 
  debugstr:string = ' ';
  debugstr2:string = ' ';
  me_id:integer;
  me_mat:integer;
  me_tid:integer;
  me_spec:single;
  me_hard:single;



{$ENDIF}

  g_pD3D: IDirect3D9 = nil; // Used to create the D3DDevice
  g_pd3dDevice: IDirect3DDevice9 = nil; // Our rendering device
  g_pVB:IDirect3DVertexBuffer9 = nil; // Buffer to hold vertices
  g_pdynVB:IDirect3DVertexBuffer9 = nil;
  g_pIB:IDirect3DIndexBuffer9 = nil;
  g_pIBlvl2:IDirect3DIndexBuffer9 = nil;

  desc:TD3DSurfacedesc;
  
  homtex:IDirect3DTexture9 = nil;
  hoszin:cardinal;
  nhszin:cardinal;
  vizszin:cardinal;
  ambientszin:cardinal;
  futex:IDirect3DTexture9 = nil;
  futexa:IDirect3DTexture9 = nil;
  kotex:IDirect3DTexture9 = nil;
  noisetex:IDirect3DTexture9 = nil;
  hnoise:IDirect3DTexture9 = nil;
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

  {$IFDEF panthihogomb}
  hogombmesh:ID3DXMesh = nil;
  {$ENDIF}
  bokrok,fuvek:Tfoliage; //Növényzet
  ojjektumrenderer:T3DORenderer;
  propsystem:TPropsystem;
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
  nohud:boolean=false;
  nofegyv:boolean=false;

  safemode:boolean=false;
  disablekill:boolean;

  portalbaugras:boolean=false;

//  war_1v1:boolean=false;
//  war_kb:boolean=false;
//  war_atlantis:boolean=false;

//  matView, matProj: TD3DMatrix;

  DIne:TdinputEasy = nil;
  noobtoltpos:TD3DXVector3;

  kickmsg:string;
  hardkick:boolean;

  portalpos,piramispos:TD3DXVector3;
  portalstarted:boolean = false;

  menuopacity :single= 0;




  cmx,cmz:integer;
  szogx,szogy,mszogx,mszogy:single;
  ccpx,ccpy,ccpz,cocpx,cocpy,cocpz:single;
  ysb:single;
  volttim,kuldd,hanyszor:cardinal;
  eltim:single;
  framespersecond:single=1;

  hWindow: HWND;
  wndpos:Tpoint=(x:0;y:0);
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
  zonabarat:integer;
  zonechanged:integer;

  errorospointer:PDWORD;
  ahovaajopointermutat:DWORD;
  anticheat1,anticheat2:integer;
  guardpage:pointer;

  walkmaterial:byte;

  tabgorg:integer=0;

  coordsniper:boolean=false;

  mstat:byte;
//  myfegyv:byte;
  csipo,rblv,gugg,spc,iranyithato,objir:boolean;
  tulnagylokes:boolean;
  lovok:single;
  cooldown:single;
  kiszall_cooldown:single;

  halal,playrocks,vizben:single;

  packszam:integer;
  hvolt:boolean;
  gobacktomenu:boolean;
  lostdevice:boolean;
  iswindowed:boolean;
  windowrect:Trect;
  misteryNumber:longint;
  noborder:boolean;
  epuletmost:integer;
  chatmost:string;
  pleasenoexit:boolean;
  kitlottemle:string;
  meghaltam:boolean=false;
  latszonaKL:integer;
  suicidevolt:integer;
  tauntvolt:boolean;
  labelvolt:boolean;

  labelactive:boolean;
  labeltext:string;

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
  autobaszallhat:boolean;
  autobaszallhatpos:TD3DXVector3;
  recovercar,vanishcar,kiszallas:integer;
  latszonazF,latszonazR:word;
  volthi,voltspeeder,voltbasejump:boolean;


  tegla:Tauto;
  gunautoeffekt,techautoeffekt:boolean;
  tobbiekautoi:array of Tauto;
  flipcount,voltflip:integer;
  flipbol:boolean;
  
  rays:array [0..7] of TD3DXVector3;

  felho:Tfelho;
  suntex:IDirect3DTexture9;
  villam:word;
  villambol:byte;
//  fogc,fogstart,fogend,lightIntensity:single;

  noobproj,lawproj,x72proj,h31_gproj,h31_tproj:array of Tnamedprojectile;
  lawmesh,noobmesh:ID3DXMesh;
  rezg:single;
  hatralok:single;                                                                                                       
  LAWkesleltetes:integer=-1;
  mp5ptl:single;
  x72gyrs:single;

  effecttexture,reflecttexture:IDirect3DTexture9;
  waterbumpmap: IDirect3DTexture9;
  enableeffects:boolean;
  

  opt_detail,opt_postproc,opt_water,opt_particle:integer;
  pre_opt_water:integer;
  opt_motionblur:boolean;
  opt_rain:boolean;
  
  opt_imposters:boolean;
  png_screenshot:boolean;
  opt_radar,opt_nochat,opt_zonename,opt_tips:boolean;
  explosionbubbles:array of TDBubble;
  explosionripples:array of TDRipple;
//  g_pEffect:ID3DXEffect;

  fejcuccrenderer:TFejcuccrenderer;
  myfejcucc:integer;

  mfkmat:TD3DMatrix;

//  frust:Tfrustum;

  vegeffekt:integer;

  teleports:array of TTeleport;
  particlesSyses:array of TParticleSys;
  labels:array of TLabel;
  
  opt_taunts:boolean;



  printscreensurf:IDirect3DSurface9;
  downsamplesurf:IDirect3DSurface9;

  armcount:byte;
  robhely:TD3DXVector3;

  currevent:TStickmanevent;
  portalevent:TStickmanevent;
  zeneintensity:integer;

  grass_dust,sand_dust,color_mud,color_rainy,color_sunny,radius_rainy,radius_sunny:longword;

  nemviz:boolean;

{$IFDEF profiler}
  profile_start:TLargeInteger;
  profile_stop:TLargeInteger;
  profile_frequency:TLargeInteger;
  profile_mecha:TLargeInteger;
  profile_render:TLargeInteger;
{$ENDIF}
  //////////////////////////// M E D A L _ V A R I A B L E S //////////////////////
  
  {$IFDEF repkedomod}
  repszorzo:Single=0.5;
  repules:boolean=true;
  {$ENDIF}
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
 if (av1.color=hoszin) or (av2.color=hoszin) or (av2.color=nhszin) or (av1.color=nhszin) then
  color:=hoszin
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

  if g_pD3D.CheckDeviceMultiSampleType( D3DADAPTER_DEFAULT,
                                        D3DDEVTYPE_HAL,
                                        D3DFMT_X8R8G8B8,
                                        iswindowed,
                                        _D3DMULTISAMPLE_TYPE(multisampling),
                                        nil) = D3D_OK then
  begin
  d3dpp.MultiSampleType := _D3DMULTISAMPLE_TYPE(multisampling);
  d3dpp.SwapEffect := D3DSWAPEFFECT_DISCARD;
  end;


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
function InitD3D(reset:boolean;hWnd: HWND): HRESULT;
var
caps:TD3DCaps9;
card:D3DADAPTER_IDENTIFIER9;
cardname:string;
i:integer;
 d3dpp: TD3DPresentParameters;
begin
  Result:= E_FAIL;

  if reset then
  begin

   mt1._Release;
mt2   ._Release;
effecttexture   ._Release;
reflecttexture            ._Release;
g_pIB                               ._Release;
g_pIBlvl2                                     ._Release;
  g_pd3dDevice.Reset(d3dpp);
  end;

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


  g_pD3D.GetAdapterIdentifier(D3DADAPTER_DEFAULT ,0,card);

  for i:=0 to 512 do
     if card.Description[i]=char(0) then break;

  SetString(cardname, card.Description, i);

  writeln(logfile,'Using video card: ',cardname);
  writeln(logfile,'Available memory: ',inttostr(trunc(g_pd3dDevice.GetAvailableTextureMem()/1024/1024)),' MB');
  writeln(logfile,'Resolution: ' + IntToStr(SCwidth) + 'x' + IntToStr(SCheight));
  writeln(logfile,'Multisampling: ' + IntToStr(multisampling));

  gpukey:= (card.DeviceIdentifier.D1) + (card.DeviceIdentifier.D2) + (card.DeviceIdentifier.D3);
  for i:=low(card.DeviceIdentifier.D4) to high(card.DeviceIdentifier.D4) do
  gpukey:= gpukey + (card.DeviceIdentifier.D4[i]);

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
    result:=kapcsk[j,0];
    exit;
   end;
 end;
 result:=-1;
end;


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

procedure yandnorm(var xx,yy,zz:single;var norm:Td3dvector;scalfac:single);
var
lngt:single;
v24y,v13y:single;
begin
 xx:=xx*scalfac;
 zz:=zz*scalfac;
 yy:=advwove(xx,zz);
 noNANInf(xx);noNANInf(yy);noNANInf(zz);
 //if scalfac>10 then
  //vanottvalami(scalfac,yy,zz);

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

procedure yandnormbokor(var xx,yy,zz:single;var norm:Td3dvector;scalfac:single);
var
lngt:single;
k,l:integer;
begin
 yy:=wove(xx,zz);
 vanottvalami(xx,yy,zz);

 lngt:=d3dxvec3lengthsq(norm);
 if lngt<0.00001 then lngt:=1;
 d3dxvec3scale(norm,norm,fastinvsqrt(lngt));

  //  for k:=0 to high(ojjektumarr) do
  //  for l:=0 to ojjektumarr[k].hvszam-1 do
  //   if ojjektumarr[k].raytestbol(D3DXVector3(xx,yy+1,zz),D3DXVector3(xx,yy,zz),l,COLLISION_SOLID) then
  //   begin
  //    norm.y:=-2;
  //    break;
  //   end;
    if opt_detail > 0 then
    for k:=0 to high(ojjektumarr) do
    for l:=0 to ojjektumarr[k].hvszam-1 do
     if tavpointpoint(ojjektumarr[k].holvannak[l],D3DXVector3(xx,yy,zz))<ojjektumarr[k].rad then
     begin
      norm.y:=-2;
      break;
     end;
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

 szin:=fuszin;
 if (norm.y)<0.83 then szin:=koszin;
 if yy<15 then szin:=hoszin+$FF000000;

 if yy<10.5 then szin:=nhszin+$FF000000;


 //if yy<0 then yy:=0;
 if yy<10 then szin:=colorlerp(vizszin,nhszin,abs(yy)/15)+$FF000000;
 if yy<0 then szin:=vizszin+$FF000000;


 {$IFDEF panthihogomb}
 if tavpointpointsq(DNSVec,D3DXVector3(xx,yy,zz))<DNSrad*DNSRad then
   szin:=$FFFFFEFF;
 {$ENDIF}

 for i:=0 to length(bubbles)-1 do
  with bubbles[i] do
 begin
  if tavpointpointsq(D3DXVector3(posx,posy,posz),D3DXVector3(xx,yy,zz))<rad*rad then
   szin:=colorlerp(vizszin,hoszin,0.6)+$FF000000;
  end;


 if  scalfac<pow2[farlvl] then
 for j:=0 to high(ojjektumnevek) do
  for i:=0 to ojjektumarr[j].hvszam-1 do
  if ojjektumarr[j].raytestbol(D3DXVector3(xx,yy,zz),D3DXVector3(xx-ojjektumarr[j].rad*2,yy+ojjektumarr[j].rad*2,zz),i,COLLISION_SHADOW) then
  begin
   norm:=D3DXVector3(0.8,0.8,0);
   break;
  end;


 ux:=xx/1+sin(zz/2)/2+sin(zz/8)+perlin.complexnoise(1,xx+2000,zz,16,4,0.5)*3{+perlin.noise(xx/200,0.5,zz/200+100)*50};
 uz:=zz/1-cos(xx/2)/2+cos(xx/8)+perlin.complexnoise(1,xx,zz+2000,16,4,0.5)*3{+perlin.noise(xx/200+100,0.5,zz/200)*50};

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
  if lvl=4 then bokrok.update(@(levels[lvl,0]),yandnormbokor);
  if lvl=1 then fuvek.update(@(levels[lvl,0]),yandnormbokor);
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

procedure loadspecials;
var
i,n:integer;
tmp:String;
begin
 n:=stuffjson.GetNum(['teleports']);
 setlength(teleports,n);
 for i:=0 to n-1 do
  with teleports[i] do
  begin
   with vfrom do
   begin
    x:=stuffjson.GetFloat(['teleports',i,'from','x']);
    y:=stuffjson.GetFloat(['teleports',i,'from','y']);
    z:=stuffjson.GetFloat(['teleports',i,'from','z']);
   end;

   with vto do
   begin
    x:=stuffjson.GetFloat(['teleports',i,'to','x']);
    y:=stuffjson.GetFloat(['teleports',i,'to','y']);
    z:=stuffjson.GetFloat(['teleports',i,'to','z']);
   end;

   rad:=stuffjson.GetFloat(['teleports',i,'radius']);
   vis:=stuffjson.GetFloat(['teleports',i,'visible_range']);
   tip:=stuffjson.GetInt(['teleports',i,'type']);
  end;

 n:=stuffjson.GetNum(['labels']);
 setlength(labels,n);
 for i:=0 to n-1 do
  with labels[i] do
  begin
   with pos do
   begin
    x:=stuffjson.GetFloat(['labels',i,'x']);
    y:=stuffjson.GetFloat(['labels',i,'y']);
    z:=stuffjson.GetFloat(['labels',i,'z']);
   end;

   rad:=stuffjson.GetFloat(['labels',i,'radius']);
   text:=stuffjson.GetString(['labels',i,'text']);
  end;

 n:=stuffjson.GetNum(['particle_systems']);
 setlength(particlesSyses,n);
 for i:=0 to n-1 do
  with particlesSyses[i] do
  begin
   with from do
   begin
    x:=stuffjson.GetFloat(['particle_systems',i,'from','x']);
    y:=stuffjson.GetFloat(['particle_systems',i,'from','y']);
    z:=stuffjson.GetFloat(['particle_systems',i,'from','z']);
   end;

   with spd do
   begin
    x:=stuffjson.GetFloat(['particle_systems',i,'speed','x']);
    y:=stuffjson.GetFloat(['particle_systems',i,'speed','y']);
    z:=stuffjson.GetFloat(['particle_systems',i,'speed','z']);
   end;

   spdrnd:=stuffjson.GetFloat(['particle_systems',i,'random_speed']);
   rnd:=stuffjson.GetFloat(['particle_systems',i,'random_tangent']);
   szorzo:=stuffjson.GetFloat(['particle_systems',i,'factor']);
   scolor:=stuffjson.GetInt(['particle_systems',i,'start_color']);
   ecolor:=stuffjson.GetInt(['particle_systems',i,'end_color']);
   rcolor:=stuffjson.GetInt(['particle_systems',i,'rnd_color']);
   vis:=stuffjson.GetFloat(['particle_systems',i,'visible_range']);
   ssize:=stuffjson.GetFloat(['particle_systems',i,'start_size']);
   esize:=stuffjson.GetFloat(['particle_systems',i,'end_size']);
   amount:=stuffjson.GetInt(['particle_systems',i,'amount']);
   rndlt:=stuffjson.GetInt(['particle_systems',i,'random_lifetime']);
   period:=stuffjson.GetInt(['particle_systems',i,'period']);
   lifetime:=stuffjson.GetInt(['particle_systems',i,'lifetime']);
   tmp:= stuffjson.GetString(['particle_systems',i,'type']);

   tipus:=PSYS_SIMPLE;
   if tmp='gravity' then tipus:=PSYS_GRAVITY;
   if tmp='cooling' then tipus:=PSYS_COOLING;
   if tmp='electric' then tipus:=PSYS_LIGHTNING;
   if tmp='fire' then tipus:=PSYS_FIRE;
   if tmp='light' then tipus:=PSYS_LIGHT;

   tmp:= stuffjson.GetString(['particle_systems',i,'texture']);

   texture:=1;
   if tmp='fire' then texture:=3;
   if tmp='csepp' then texture:=2;
   if tmp='smoke' then texture:=4;
   if tmp='light' then texture:=5;

  end;


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

 loadojjektumokfromjson;

 setlength(ojjektumarr,length(ojjektumnevek));
 for i:=0 to high(ojjektumnevek) do
  begin
   laststate:= 'Loading object '''+ojjektumnevek[i]+'''';
   menu.DrawLoadScreen((40*i) div length(ojjektumnevek));
   ojjektumarr[i]:=nil;
   ojjektumarr[i]:=T3dojjektum.Create('data/objects/'+ojjektumnevek[i],g_pd3ddevice,ojjektumscalek[i].x,ojjektumscalek[i].y,ojjektumhv[i],ojjektumflags[i]);
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


  //list of ojjecttextures
  //writeln(logfile,'SM0 texture list: ');

  //for i:=0 to length(ojjektumTextures)-1 do
  //begin
  //  writeln(logfile,ojjektumTextures[i].name);
  //end;


  d3dxvec3add(dnsvec,ojjektumarr[panthepulet].holvannak[0],ojjektumarr[panthepulet].vce);
  portalpos:=ojjektumarr[portalepulet].holvannak[0];
  piramispos:=ojjektumarr[piramis].holvannak[0];
  dnsrad:=ojjektumarr[panthepulet].rad*1.4;

  result:=true;
  writeln(logfile,'Loaded objects');flush(logfile);
  laststate:= 'Loading objectrenderer ';
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
type
 array4ofbyte = array [0..3] of byte;
var
i,j,k,l:integer;
l1c,l2c,l3c:TD3DXColor;
lr:TD3DLockedrect;
pbits:pointer;
xx,yy,zz:single;
tmp:single;
n:TD3DXVector3;
fucol,hocol,nhcol,wacol,kocol:TD3DXColor;
cmap1:array of array4ofbyte;
tmprow:array [0..1023] of array4ofbyte;
col,lght1,lght2,ossz,veg:TD3DXColor;
l1,l2:TD3DXVector3;
tmptex:IDIrect3DTexture9;
begin

 setlength(cmap1,1024*1024);

 Result:= E_FAIL;
 tmptex:=nil;
 if Failed(g_pd3dDevice.CreateTexture( 1024, 1024, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, tmptex , nil)) then Exit;
 if Failed(g_pd3dDevice.CreateTexture( 1024, 1024, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, mt1, nil)) then Exit;
 if Failed(g_pd3dDevice.CreateTexture( 1024, 1024, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, mt2, nil)) then Exit;

 ;
 fucol:=D3DXColorFromDWord(stuffjson.GetInt(['color_grass']));
 fucol.a:=1;   //0
 kocol:=D3DXColorFromDWord(stuffjson.GetInt(['color_rock']));
 kocol.a:=1;   //1
 hocol:=D3DXColorFromDWord(stuffjson.GetInt(['color_sand']));
 hocol.a:=1;   //0
 nhcol:=D3DXColorFromDWord(stuffjson.GetInt(['color_wet_sand']));
 nhcol.a:=1;   //0
 wacol:=D3DXColorFromDWord(stuffjson.GetInt(['color_water']));
 wacol.a:=1;   //1




 l1c:=D3DXColorFromDWORD(stuffjson.GetInt(['light','color_sun']));
 l2c:=D3DXColorFromDWORD(stuffjson.GetInt(['light','color_shadow']));
 l3c:=D3DXColorFromDWORD(stuffjson.GetInt(['light','color_ambient']));

 //D3DXColor(116/255,178/255,67/255,0);
// kocol:=D3DXColor(110/255,110/255,108/255,1);
// hocol:= D3DXColor(250/255,200/255,200/255,0);
 if fileexists('data\cmap.png') then
 begin
  LTFF(g_pd3dDevice, 'data\cmap.png', mt1);
 end
 else
 begin

  laststate:= 'Generating minimaps ';
   menu.DrawLoadScreen(75);

 l1:= D3DXVector3(-1,1.0,0);
 D3DXVec3Normalize(l1, l1);
 l2:=l1; l2.x:=-l2.x;

 for i:=0 to 1023 do
  for j:=0 to 1023 do
  begin
   xx:=(j-512);
   zz:=(i-512);
   yandnorm(xx,yy,zz,n,2);

   for k:=0 to high(ojjektumarr) do
    for l:=0 to ojjektumarr[k].hvszam-1 do
     if ojjektumarr[k].raytestbol(D3DXVector3(xx,yy,zz),D3DXVector3(xx-ojjektumarr[k].rad*2,yy+ojjektumarr[k].rad*2,zz),l,COLLISION_SHADOW) then
     begin
      n:=D3DXVector3(sqrt(2),min(n.y,sqrt(2)),0);
      break;
     end;
 //zz:=zz+(round(xx)mod 2)*scalfac/2;
   col:=fucol;
   if yy<0 then yy:=0;
   if yy<15 then col:=hocol;
   if (n.y)<0.83 then
   begin
    D3DXColorScale(col,kocol,random(10)/100+0.9);
   end;
   if yy<10.5 then col:=nhcol;
   if yy<10 then D3DXColorLerp(col,wacol,nhcol,yy/15);
   tmp:=D3DXVec3dot(n,l1);
   if tmp<0 then tmp:=0;
   D3DXColorscale(lght1,l1c,tmp);

   tmp:=D3DXVec3dot(n,l2);
   if tmp<0 then tmp:=0;
   D3DXColorscale(lght2,l2c,tmp);

   D3DXColoradD(ossz,lght1,lght2);
   D3DXColorAdd(ossz,ossz,l3c);
   D3DXColorModulate(veg,ossz,col);

   cmap1[j*1024+i,0]:=min(round(veg.b*255),255);
   cmap1[j*1024+i,1]:=min(round(veg.g*255),255);
   cmap1[j*1024+i,2]:=min(round(veg.r*255),255);
   cmap1[j*1024+i,3]:=min(round(col.a*255),255);
  end;


 result:=tmptex.LockRect(0, lr, nil, 0);
 if Failed(result) then Exit;
 for i:= 0 to 1023 do
  begin
    pBits := PDWORD(Integer(lr.pBits)+i*lr.Pitch);
    for j:=0 to 1023 do
      tmprow[j] := cmap1[j*1024+i];
    copymemory(pbits,addr(tmprow),1024*4);
  end;
 tmptex.UnlockRect(0);

 if not fileexists('data\cmap.png') then
 begin
   D3DXSaveTextureToFile( PChar('data\cmap.png'),D3DXIFF_PNG,tmptex,nil);
 end;

 g_pd3ddevice.UpdateTexture(tmptex,mt1);

 end;



 // MT2/////////////////////////////////////////////////

 if fileexists('data\cmap2.png') then
 begin
  LTFF(g_pd3dDevice, 'data\cmap2.png', mt2);

 end
 else
 begin

    menu.DrawLoadScreen(78);

 for i:=0 to 1023 do
  for j:=0 to 1023 do
  begin
   xx:=j-512;
   zz:=i-512;
   yandnorm(xx,yy,zz,n,2);
   for k:=0 to high(ojjektumnevek) do
    for l:=0 to ojjektumarr[k].hvszam-1 do
     if ojjektumarr[k].raytestbol(D3DXVector3(xx,yy,zz),D3DXVector3(xx,yy+ojjektumarr[k].rad*2,zz),l,COLLISION_SOLID) then
     begin
     // n:=ojjektumarr[k].raytest(D3DXVector3(xx,yy+ojjektumarr[k].rad*2,zz),D3DXVector3(xx,yy,zz),l);
     //  yy:=(n.y-yy)/3;
      cmap1[j*1024+i,1]:=255;//round(yy*255);
      cmap1[j*1024+i,0]:=255;//-$FF and round(yy*255);
      cmap1[j*1024+i,2]:=255;
      cmap1[j*1024+i,3]:=255;
      break;
     end;
   end;




 result:=tmptex.LockRect(0, lr, nil, 0);
 if Failed(result) then Exit;
 for i:= 0 to 1023 do
  begin
    pBits := PDWORD(Integer(lr.pBits)+i*lr.Pitch);
    for j:=0 to 1023 do
      tmprow[j] := cmap1[j*1024+i];
    copymemory(pbits,addr(tmprow),1024*4);
  end;
 tmptex.UnlockRect(0);

 if not fileexists('data\cmap2.png') then
 begin
   D3DXSaveTextureToFile( PChar('data\cmap2.png'),D3DXIFF_PNG,tmptex,nil);
 end;

 g_pd3ddevice.UpdateTexture(tmptex,mt2);
  end;

 tmptex:=nil;
 Result:= S_OK;
end;

procedure fillmp3filelist;
var
myrec:Tsearchrec;
hov:integer;
radio:string;
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
  radio:=readm3urecord('radio\'+myrec.name);
  if  radio<>'' then
  begin
  setlength(mp3strms[hov],length(mp3strms[hov])+1);
  mp3strms[hov][high(mp3strms[hov])]:=radio
  end;
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
  LoadSound('hummer',true,true,true,10);
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
  LoadSound('knock',true,true,true,20);        //35
  LoadSound('openedportal',true,true,true,10);
  LoadSound('walkmetal',true,true,true,1);
  LoadSound('walkwood',true,true,true,1);
  LoadSound('magic1',true,false,true,3);
  LoadSound('magic2',true,true,true,1);  //40

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
  else muks.stand((mstat and MSTAT_GUGGOL)>0);
 end;

 pos:=d3dxvector3(ccpx,ccpy,ccpz);
 D3DXMatrixRotationY(matWorld2,szogx+d3dx_pi);
 D3DXMatrixTranslation(matWorld,pos.x,pos.y,pos.z);
 D3DXMatrixMultiply(matWorld,matWorld2,matWorld);
 mat_World:=matworld;
 //g_pd3dDevice.SetTransform(D3DTS_WORLD, matWorld);
end;

procedure bubbleeffect;
var
vec1,vec2:TD3DXVector3;
i:integer;
tempmesh:ID3DXMesh;
oo:HRESULT;
begin
  for i:=0 to length(bubbles)-1 do
  with bubbles[i] do
  begin
    tempmesh:= nil;
    vec1:=d3dxvector3(posx,posy,posz);
    vec2:=vec1;
    vec2.y:=vec2.y+34;
    oo := D3DXCreateSphere(g_pD3DDevice,1,30,20,tempmesh,nil);
  if (oo<>D3D_OK) then Exit;
  if tempmesh=nil then exit;
  if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_XYZ or D3DFVF_NORMAL,g_pd3ddevice,gomb)) then exit;
  if tempmesh<>nil then tempmesh:=nil;
  normalizemesh(gomb);
  end;
end;

function fegyvernev(mi:byte):string;
begin
case mi of
  FEGYV_M4A1:result:='M4';
  FEGYV_M82A1:result:='M82';
  FEGYV_LAW:result:='LAW';
  FEGYV_MPG:result:='MPG';
  FEGYV_QUAD:result:='QUAD';
  FEGYV_NOOB:result:='NOOB';
  FEGYV_X72:result:='X72';
  FEGYV_MP5A3:result:='MP5';

  FEGYV_H31_G:result:='H31';
  FEGYV_H31_T:result:='H31';
else
result:='WTF';
end;

end;

//-----------------------------------------------------------------------------
// Name: InitGeometry()
// Desc: Creates the scene geometry
//-----------------------------------------------------------------------------
function InitializeAll: HRESULT;
var
  pIndices:PWordArray;
  indmost:integer;
  i,j,x,y:integer;
  tempmesh:ID3DXMesh;
  tempd3dbuf:ID3DXBuffer;
  vmi:string;
  devicecaps: TD3DCaps9;
  backbuf:IDirect3Dsurface9;
  sky_ambient:integer;
  cloud_speed:single;
  cloud_color:longword;
  mati:TMaterial;
const
  Effect_offset:array [0..11] of TD3DXVector2 =
    ((x:-0.015;y:-0.015),(x:-0.01;y:-0.01),(x:-0.005;y:-0.005),(x: 0.015;y:-0.015),(x: 0.01;y:-0.01),(x: 0.005;y:-0.005),
     (x:-0.015;y: 0.015),(x:-0.01;y: 0.01),(x:-0.005;y: 0.005),(x: 0.015;y: 0.015),(x:-0.01;y: 0.01),(x: 0.005;y: 0.005));
  Effect_Szorzo:array [0..11] of single =(0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5);
label
visszobj,visszfegyv;
begin

  Result:= E_FAIL;
  enableeffects:=true;
  laststate:='Initializing';

  hoszin:=stuffjson.GetInt(['color_sand']) and $FFFFFF;
  nhszin:=stuffjson.GetInt(['color_wet_sand']) and $FFFFFF;
  vizszin:=stuffjson.GetInt(['color_water']) and $FFFFFF;
  ambientszin:=cardinal(stuffjson.GetInt(['light','color_ambient']));
  gunautoeffekt:=stuffjson.GetBool(['vehicle','gun','effect']);
  techautoeffekt:=stuffjson.GetBool(['vehicle','tech','effect']);

  gunszin:=stuffjson.GetInt(['color_gun']);
  techszin:=stuffjson.GetInt(['color_tech']);

  for i := 1 to 4 do
  begin
  setlength(weapons,i+1);
    for j := 1 to 8 do
    begin
    setlength(weapons[i].col,j+1);
    weapons[i].col[j]:=stuffjson.GetInt(['weapon',fegyvernev(i+127),'color',IntToStr(j)]);
    end;
  end;
  i:=4; //WTF?
  inc(i);
  setlength(weapons,length(weapons)+2);
  setlength(weapons[i].col,2);
  weapons[i].col[0]:=stuffjson.GetInt(['weapon','WATER','1']); //vízbe lövünk
  weapons[i].col[2]:=stuffjson.GetInt(['weapon','WATER','2']);
  inc(i);
  setlength(weapons[i].col,1);
  weapons[i].col[0]:=stuffjson.GetInt(['weapon','DUST']);



  grass_dust:=stuffjson.GetInt(['color_grass_dust']);
  sand_dust:=stuffjson.GetInt(['color_sand_dust']);
  color_mud:=stuffjson.GetInt(['color_mud']);
  color_rainy:=stuffjson.GetInt(['fog','color_rainy']);
  color_sunny:=stuffjson.GetInt(['fog','color_sunny']);
  radius_rainy:=stuffjson.GetInt(['fog','radius_rainy']);
  radius_sunny:=stuffjson.GetInt(['fog','radius_sunny']);

  if grass_dust=0 then grass_dust:=$FF55772D;
  if sand_dust=0 then sand_dust:=$FFDCB9B2;
  if color_mud=0 then color_mud:=$FF514024;
  if color_rainy=0 then color_rainy:=$FF909090;
  if color_sunny=0 then color_sunny:=$FFC8EBFA;
  if radius_rainy=0 then color_rainy:=600;
  if radius_sunny=0 then color_sunny:=900;

  setlength(posrads,stuffjson.GetNum(['terrain_modifiers']));
  for i:=0 to stuffjson.GetNum(['terrain_modifiers'])-1 do
  with posrads[i] do
  begin
   posx:=stuffjson.GetFloat(['terrain_modifiers',i,'x']);
   posy:=stuffjson.GetFloat(['terrain_modifiers',i,'y']);
   posz:=stuffjson.GetFloat(['terrain_modifiers',i,'z']);
   radd:=stuffjson.GetFloat(['terrain_modifiers',i,'radius']);
   raddn:=radd+stuffjson.GetFloat(['terrain_modifiers',i,'offset']);

   if (raddn<=radd) then raddn := 1.5* radd;
  end;

  setlength(bubbles,stuffjson.GetNum(['bubbles']));
  for i:=0 to stuffjson.GetNum(['bubbles'])-1 do
  with bubbles[i] do
  begin
   posx:=stuffjson.GetFloat(['bubbles',i,'x']);
   posy:=stuffjson.GetFloat(['bubbles',i,'y']);
   posz:=stuffjson.GetFloat(['bubbles',i,'z']);
   rad:=stuffjson.GetFloat(['bubbles',i,'radius']);
   if (rad<=3) then rad := 3;
  end;

  for i:=0 to 3 do
  begin
   hummkerekarr[i].x:=stuffjson.GetFloat(['vehicle','gun','wheels','position',i,'x']);
   hummkerekarr[i].y:=stuffjson.GetFloat(['vehicle','gun','wheels','position',i,'y']);
   hummkerekarr[i].z:=stuffjson.GetFloat(['vehicle','gun','wheels','position',i,'z']);
  end;

  for i:=0 to 3 do
  begin
   agkerekarr[i].x:=stuffjson.GetFloat(['vehicle','tech','wheels','position',i,'x']);
   agkerekarr[i].y:=stuffjson.GetFloat(['vehicle','tech','wheels','position',i,'y']);
   agkerekarr[i].z:=stuffjson.GetFloat(['vehicle','tech','wheels','position',i,'z']);
  end;
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

  //props
  laststate:='Loading the props';

  propsystem := TPropsystem.Create(g_pd3ddevice);

  for i:=0 to stuffjson.GetNum(['props'])-1 do
  begin
   propsystem.addPrototype(
      stuffjson.GetKey(['props'],i),
      stuffjson.GetString(['props',i,'model'])
   );

   for j:=0 to stuffjson.GetNum(['props',i,'materials'])-1 do
   begin
    mati.diffusename := '';
    mati.normalname := '';
    mati.specIntensity := stuffjson.GetFloat(['props',i,'materials',j,'specIntensity']);
    mati.specHardness := stuffjson.GetFloat(['props',i,'materials',j,'specHardness']);
    mati.emission := stuffjson.GetFloat(['props',i,'materials',j,'emission']);

    vmi := stuffjson.GetString(['props',i,'materials',j,'diffuse']);
    if (vmi<>'') then mati.diffusename := vmi
    else
    begin
      messagebox(0,
      Pchar('Prop '+stuffjson.GetKey(['props'],i)+' must have diffuse texture on material #'+inttostr(j)),
      'error',0);
      exit;
    end;

    vmi := stuffjson.GetString(['props',i,'materials',j,'normal']);
    if (vmi<>'') then mati.normalname := vmi;

    propsystem.addMaterial(stuffjson.GetKey(['props'],i),mati);
   end;

   for j:=0 to stuffjson.GetNum(['props',i,'collisions'])-1 do
    propsystem.addColl(stuffjson.GetKey(['props'],i),
                       stuffjson.GetString(['props',i,'collisions',j,'type']),
                       stuffjson.GetFloat(['props',i,'collisions',j,'xmin']),
                       stuffjson.GetFloat(['props',i,'collisions',j,'xmax']),
                       stuffjson.GetFloat(['props',i,'collisions',j,'ymin']),
                       stuffjson.GetFloat(['props',i,'collisions',j,'ymax']),
                       stuffjson.GetFloat(['props',i,'collisions',j,'zmin']),
                       stuffjson.GetFloat(['props',i,'collisions',j,'zmax']));

   for j:=0 to stuffjson.GetNum(['props',i,'position'])-1 do
      propsystem.addObject(
        stuffjson.GetKey(['props'],i),
        D3DXvector3(stuffjson.GetFloat(['props',i,'position',j,'x']),
                    stuffjson.GetFloat(['props',i,'position',j,'y']),
                    stuffjson.GetFloat(['props',i,'position',j,'z'])),
                    stuffjson.GetFloat(['props',i,'position',j,'rot']),
                    stuffjson.GetFloat(['props',i,'position',j,'scale']),
                    stuffjson.GetFloat(['props',i,'position',j,'light'])
                    );
  end;


  laststate:='Loading the island';
  loadspecials;
    menu.DrawLoadScreen(50);
  {$IFDEF panthihogomb}
  if FAILED(D3DXCreateSphere(g_pD3DDevice,1,30,20,tempmesh,nil)) then Exit;
  if tempmesh=nil then exit;
  if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_XYZ or D3DFVF_NORMAL,g_pd3ddevice,hogombmesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;
  normalizemesh(hogombmesh);
  {$ENDIF}

  bubbleeffect;

  if not LTFF(g_pd3dDevice, 'data\textures\grass.jpg',futex) then exit;
  if not LTFF(g_pd3dDevice, 'data\textures\gnoise.jpg',noise2tex) then exit;
  if not LTFF(g_pd3dDevice, 'data\textures\hnoise.jpg',hnoise) then exit;
  if not LTFF(g_pd3dDevice, 'data\textures\rock_01.jpg',kotex) then exit;
  if not LTFF(g_pd3dDevice, 'data\textures\rnoise.jpg',noisetex) then exit;
  if not LTFF(g_pd3dDevice, 'data\textures\sand.jpg',homtex) then exit;
    menu.DrawLoadScreen(55);
  writeln(logfile,'Loaded ground textures');flush(logfile);
  if not LTFF(g_pd3dDevice, 'data\textures\water.jpg', viztex) then exit;
  if not LTFF(g_pd3dDevice, 'data\textures\water2.jpg', waterbumpmap) then exit;
  writeln(logfile,'Loaded water texture');flush(logfile);
  if not LTFF(g_pd3dDevice, 'data\textures\sky1.png', skytex) then exit;
  if not LTFF(g_pd3dDevice, 'data\gui\sun1.png', suntex) then exit;

  initsky;
  writeln(logfile,'Loaded Sky');flush(logfile);
    menu.DrawLoadScreen(60);
  if FAILED(D3DXLoadMeshFromX('data\models\hummer.x',0,g_pd3ddevice,nil,nil, nil,nil,tempmesh)) then Exit;
  if tempmesh=nil then exit;if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_TEX1,g_pd3ddevice,g_pautomesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;

  if FAILED(D3DXLoadMeshFromX('data\models\antigrav.x',0,g_pd3ddevice,nil,nil, nil,nil,tempmesh)) then Exit;
  if tempmesh=nil then exit;if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_TEX1,g_pd3ddevice,g_pantigravmesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;

  if FAILED(D3DXLoadMeshFromX('data\models\kerek.x',0,g_pd3ddevice,nil,nil, nil,nil,tempmesh)) then Exit;
  if tempmesh=nil then exit;if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_TEX1,g_pd3ddevice,g_pkerekmesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;
  normalizemesh(G_pkerekmesh);
  normalizemesh(g_pautomesh);
  normalizemesh(g_pantigravmesh);

  if FAILED(D3DXLoadMeshFromX('data\models\rocket003.x',0,g_pd3ddevice,nil,nil, nil,nil,tempmesh)) then Exit;
  if tempmesh=nil then exit;if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_XYZ or D3DFVF_NORMAL + D3DFVF_DIFFUSE ,g_pd3ddevice,lawmesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;

  if FAILED(D3DXLoadMeshFromX('data\models\gomb.x',0,g_pd3ddevice,nil,nil, nil,nil,tempmesh)) then Exit;
  if tempmesh=nil then exit;if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_XYZ or D3DFVF_NORMAL ,g_pd3ddevice,noobmesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;

  normalizemesh(lawmesh);
  normalizemesh(noobmesh);

  tegla:=Tauto.create(d3dxvector3(1,0,0),d3dxvector3(0,1,0),d3dxvector3(0,0,1),d3dxvector3zero,d3dxvector3zero,0.9,0.99,hummkerekarr,1,0.1,0.03,0.2,0.3,0.2,0,0,false);
  tegla.disabled:=true;
  if not LTFF(g_pd3dDevice, 'data\textures\hummer.jpg', cartex) then exit;
  if not LTFF(g_pd3dDevice, 'data\textures\antigrav.jpg', antigravtex) then exit;
  if not LTFF(g_pd3dDevice, 'data\textures\kerektex.jpg', kerektex) then exit;
  writeln(logfile,'Loaded vehicles');

  result:=D3DXCreateTexture(g_pd3ddevice,SCWidth,SCheight,0,D3DUSAGE_RENDERTARGET,D3DFMT_A8R8G8B8,D3DPOOL_DEFAULT,effecttexture);


  //result:=D3DXCreateTexture(g_pd3ddevice,SCWidth div 2,SCheight div 2,0,D3DUSAGE_RENDERTARGET,D3DFMT_A8R8G8B8,D3DPOOL_DEFAULT,effecttexture);
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
  g_pd3ddevice.CreateRenderTarget(SCwidth,SCheight,D3DFMT_X8R8G8B8,D3DMULTISAMPLE_NONE,0,false,downsamplesurf,nil);



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

  menu.lowermenutext:=stuffjson.GetString(['lower_menu_text']);
 if menu.lowermenutext='' then
    menu.lowermenutext:='Music: Unreal Superhero III Symphonic version by Jaakko Takalo';
 
  writeln(logfile,'Initialized buffers');flush(logfile);
  addfiletochecksum('data/textures/bush256.png');
  bokrok:=TFoliage.create(G_pd3ddevice,'textures/bush256.png',1,1.2,-0.1);
  fuvek:=TFoliage.create(G_pd3ddevice,'textures/mg3.png',0.34,-0.32,0.34);
  //fuvek2:=TFoliage.create( G_pd3ddevice,'mg3.png',0.1,-0.2,0.18);
  if not bokrok.betoltve then exit;
  if not fuvek.betoltve then exit;
  //if not fuvek2.betoltve then exit;
  writeln(logfile,'Loaded foliage');flush(logfile);

  cloud_color:=stuffjson.GetInt(['cloud','color']);
  sky_ambient:=stuffjson.GetInt(['cloud','ambient']);
  cloud_speed:=stuffjson.GetFloat(['cloud','speed']);
  
  if sky_ambient=0 then sky_ambient:=100;
  if cloud_color=0 then cloud_color:=$FFFFFF;
  if cloud_speed=0 then cloud_speed:=0.00003;

  felho:=Tfelho.create(g_pd3ddevice,sky_ambient,cloud_speed,cloud_color);
  laststate:='Loading hats';
  writeln(logfile,'Initialized sky');flush(logfile);

  fejcuccrenderer:=Tfejcuccrenderer.Create(g_pd3ddevice);


  cpx^:=10-random(20)+0.5;
  cpz^:=10-random(20)+0.5;

  cpox^:=cpx^;cpoy^:=cpy^;cpoz^:=cpz^;


  cpy^:=advwove(cpx^,cpz^);

  writeln(logfile,'Initilazing geometry succesful');flush(logfile);


  laststate:='Loading sounds';
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
  acpx,acpy,acpz,magic:single;
begin
        {
  if repules then
  szogx:=szogx+0.2*eltim;{}

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
   D3DXMatrixTranslation(mat2,-0.1,-0.1,0.0+hatralok)
  else
   D3DXMatrixTranslation(mat2,0,0,0.05+hatralok*0.5);

  mat2._41:=mat2._41-sin(mszogx-szogx)*0.3;
  mat2._42:=mat2._42-sin(mszogy-szogy)*0.3;
  if (myfegyv=FEGYV_MP5A3) and (not csipo) then mat2._43:=mat2._43+0.05;
  if (myfegyv=FEGYV_M4A1) and (not csipo) then mat2._43:=mat2._43+0.06;

  if (myfegyv=FEGYV_H31_T) or (myfegyv=FEGYV_H31_G) then
  begin
  magic:=1-lovok;
  mat2._41:=mat2._41-0.298*magic;
  mat2._42:=mat2._42-0.32*magic-0.05*(sin(magic*d3dx_pi));
  mat2._43:=mat2._43+0.06*magic;
  end;

  if (kiszall_cooldown>0.02) then
  begin
    mat2._42:=mat2._42-kiszall_cooldown;
    mat2._43:=mat2._43+kiszall_cooldown;
  end;

  D3DXMatrixMultiply(mat,mat2,mat);
  
  if (myfegyv=FEGYV_H31_T) or (myfegyv=FEGYV_H31_G) then
  begin
  D3DXMatrixRotationY(mat2,-0.5*magic);
  D3DXMatrixMultiply(mat,mat2,mat);
  D3DXMatrixRotationX(mat2,0.5*magic);
  D3DXMatrixMultiply(mat,mat2,mat);
  end;
 // D3DXMatrixscaling(mat2,1.2,1.2,1.2);
  //D3DXMatrixMultiply(mat,mat2,mat);

  D3DXMatrixMultiply(matworld,mat,matworld);
  if halal>0 then d3dxmatrixidentity(matWorld);
  mfm:=matworld;
  g_pd3dDevice.SetTransform(D3DTS_WORLD, matWorld);


end;

procedure undebug_memory1;
{$IFDEF undebug}
var
virt:pdword;
{$ENDIF}
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
//  begin
   mtrl.Diffuse.g := 1.0; mtrl.Ambient.g := 1.0;
   mtrl.Diffuse.b := 1.0; mtrl.Ambient.b := 1.0;
//  end;
   mtrl.Diffuse.a := 1.0; mtrl.Ambient.a := 1.0;

  mtrl.Specular.r:=1.0;
  mtrl.Specular.g:=1.0;
  mtrl.Specular.b:=1.0;
  g_pd3dDevice.SetMaterial(mtrl);

  // Set up a white, directional light, with an oscillating direction.
  // Note that many lights may be active at a time (but each one slows down
  // the rendering of our scene). However, here we are just using one. Also,
  // we need to set the D3DRS_LIGHTING renderstate to enable lighting


  ZeroMemory(@light, SizeOf(TD3DLight9));
  light._Type      := D3DLIGHT_DIRECTIONAL;
  light.Diffuse:=D3DXColorFromDWORD(stuffjson.GetInt(['light','color_sun']));
  light.Diffuse.a := 1;

  light.Specular.r:=1.0;
  light.Specular.g:=1.0;
  light.Specular.b:=1.0;

  vecDir:= D3DXVector3(1,-1.0,0);
  D3DXVec3Normalize(light.Direction, vecDir);
  light.Range := 1000.0;
  g_pd3dDevice.SetLight(0, light);
  g_pd3dDevice.LightEnable(0, true);
  light.Direction.x:=-light.direction.x;
  light.Diffuse:=D3DXColorFromDWORD(stuffjson.GetInt(['light','color_shadow']));
  light.Diffuse.a := 1;
  g_pd3dDevice.SetLight(1, light);
  g_pd3dDevice.LightEnable(1, true);   //}

  undebug_memory1;
  g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iTrue);
  // Finally, turn on some ambient light.
  //if (halal=0) or (halal>1.5) then
  g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, ambientszin);
end;


procedure SetupFegyvlights(lit:integer);
 var
  vecDir: TD3DXVector3;
  light: TD3DLight9;
  v:single;
begin
  v:=lit/5;
  ZeroMemory(@light, SizeOf(TD3DLight9));
  light._Type      := D3DLIGHT_DIRECTIONAL;
  D3DXColorLerp(light.Diffuse,
                D3DXColorFromDWORD(stuffjson.GetInt(['light','color_shadow'])),
                D3DXColorFromDWORD(stuffjson.GetInt(['light','color_sun'])),v);
  light.Diffuse.a := 1;

  vecDir:= D3DXVector3(1,-1.0,0);
  D3DXVec3Normalize(light.Direction, vecDir);
  light.Range := 1000.0;
  g_pd3dDevice.SetLight(0, light);
  g_pd3dDevice.LightEnable(0, true);
end;



procedure respawn;
type
  TBunker = record
    index:integer;
    tav:single;
  end;
var
  x,p,b,i,j,ojjind:integer;
  tmp2:single;
  tmppos:TD3DXVector3;
  tmptav:single;
  legjobbpos:TD3DXVector3;
  Bunker:Tbunker;
  tmpBunker:Tbunker;
  bunkerek:array of TBunker;
begin
  lastzone:='';
  multisc.killscamping:=multisc.kills;
  multisc.killswithoutdeath:=multisc.kills;

  zonechanged:=0;
  invulntim:=300;
  autoban:=false;
  vanishcar:=1500;
  kulsonezet:=false;
  mapmode:=0;
  mapbol:=false;
  halal:=0;

  if multisc.state1v1 then
  begin
    invulntim:=500;
    autoban:=false;
    cpx^:=portalpos.x-2;    cpy^:=portalpos.y+1;    cpz^:=portalpos.z;
    szogx:=1.57075;
  end
  else
  if multisc.warevent then
  begin
    autoban:=false;
    invulntim:=multisc.warevent_invul*100;
    if multisc.warevent_dm then
    teleport_to_coords(multisc.warevent_spawns[random(length(multisc.warevent_spawns))])
    else
    begin
      if myfegyv < 128 then
      teleport_to_coords(multisc.warevent_gunspawns[random(length(multisc.warevent_gunspawns))])
      else
      teleport_to_coords(multisc.warevent_techspawns[random(length(multisc.warevent_techspawns))]);
    end;
  end
  else
  begin
    for i:=0 to high(ojjektumarr) do
    if ((ojjektumflags[i] and OF_SPAWNGUN)>0)  and (myfegyv<128) or
    ((ojjektumflags[i] and OF_SPAWNTECH)>0) and (myfegyv>=128) then
    ojjind:=i;
    for b:=0 to ojjektumarr[ojjind].hvszam-1 do
    begin
      tmppos:=ojjektumarr[ojjind].holvannak[b];
      tmptav:=0;
      for p:=0 to high(ppl) do
      begin
        if (ppl[p].pls.fegyv xor myfegyv)>=128 then
        tmptav:=tmptav+sqrt(tavpointpoint(tmppos,ppl[p].pos.pos));
      end;

      Bunker.index:=b;
      Bunker.tav:=tmptav;
      SetLength(bunkerek, Length(bunkerek)+1);
      bunkerek[High(bunkerek)]:=Bunker;
    end;


    for i:=0 to High(bunkerek) do
    for j:=0 to i do
    begin
      if bunkerek[i].tav<bunkerek[j].tav then
      begin
        tmpBunker:=bunkerek[i];
        bunkerek[i]:=bunkerek[j];
        bunkerek[j]:=tmpBunker;
      end;
    end;

    i:=random(trunc(min(length(bunkerek), 4 + length(ppl)/5)));
    legjobbpos:=ojjektumarr[ojjind].holvannak[bunkerek[i].index];


    tmp2:=stuffjson.GetFloat(['spawn_radius']);
    cpx^:=legjobbpos.x+tmp2*(random(10000)/5000-1)/2;
    cpy^:=legjobbpos.y+stuffjson.GetFloat(['spawn_height']);
    cpox^:=100;
    cpz^:=legjobbpos.z+tmp2*(random(10000)/5000-1)/2;

    NoNANINF(cpx^); NoNANINF(cpy^); NoNANINF(cpz^);
  end;

  if not (multisc.state1v1) then
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
      kuldd:=timegettime;
    end;
  end;
  updateterrain;

  Dine.Update(point(400,400));
  Dine.Update(point(400,400));

  hanyszor:=(timegettime div 10) +1;
  hvolt:=true;

  csipo:=true;

  meghaltam:= false;
end;



procedure addrongybaba(apos,vpos,gmbvec:TD3DXVector3;fegyv,mlgmb:byte;ID:cardinal;kimiatt:integer;h31:boolean=false);
var
szin:cardinal;
mv2:TD3DMatrix;
begin
// apos.y:=apos.y+0.5;

 if ID=0 then
 begin
  if not h31 then
  multisc.Killed(kimiatt);
  multip2p.Killed(apos,vpos,szogx,mstat,animstat,mlgmb,gmbvec,kimiatt);
 end;

 if rbszam>=20 then exit;
 inc(rbszam);

 mv2:=mat_world;
 mv2._42:=mv2._42+0.1;
 //rongybabak[rbszam]:=nil;
 if fegyv>127 then szin:=techszin else szin:=gunszin;
  rongybabak[rbszam]:=TRongybaba.Create(mat_world,muks,apos,vpos,gmbvec,mlgmb,ID,szin);

 playsound(9+halalhorg,false,integer(timegettime)+random(10000),true,rongybabak[rbszam].gmbk[10]);
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


procedure lojjegyet(aimbot:single=-1.0; aimbot_pontatlan:single=1.0);
var
tmp:TD3DXVector3;
hollo,v2,v1:TD3DXVector3;
dst:single;
i,j,k:integer;
{$IFDEF palyszerk}
torl:integer;
{$ENDIF}
begin
//   if invulntim>0 then exit;


   //hollo:=D3DXVector3(0,3,0); ///BVÁÁÁÁÁÁ

    hollo:=D3DXVector3(0,-0.10,0);
    if myfegyv=FEGYV_QUAD then
     hollo.y:=0
  {  else
    if myfegyv=FEGYV_X72 then
     hollo:=D3DXVector3((random(100)-50)/200,-0.2,0.3)};

    v1:=D3DXvector3zero;

    D3DXVec3add(v2   ,hollo,D3DxVector3(0,0,-300));
    D3DXVec3add(hollo,hollo,D3DxVector3(0,0,-0.7));



   d3dxvec3transformcoord(hollo,hollo,mfm);
   d3dxvec3transformcoord(v2,v2,mfm);
   d3dxvec3transformcoord(v1,v1,mfm);
   d3dxvec3subtract(tmp,v2,hollo);
   d3dxvec3scale(tmp,tmp,1/3000);



//  for k:=0 to high(ojjektumnevek) do
//   for j:=0 to ojjektumarr[k].hvszam-1 do
//   begin
//    if ojjektumarr[k].raytestbol(v1,hollo,j,COLLISION_BULLET) then exit;
//   end;

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
    v2:=ojjektumarr[k].raytest(hollo,v2,j,COLLISION_BULLET);
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

  if aimbot>0 then
  for i:=0 to high(ppl) do
   if (ppl[i].pls.fegyv xor myfegyv)>127 then
   begin
    if (tavpointlinesq(ppl[i].pos.pos,hollo,v2,tmp,dst)) then
     if dst<aimbot then
     begin
      D3DXVec3Scale(tmp,ppl[i].pos.seb,sqrt(tavpointpoint(hollo, ppl[i].pos.pos))*20+30);
//      tmp.y:=0;
      D3DXVec3Add(v2,ppl[i].pos.pos,D3DXVector3(0.0,1.0,0.0));
      D3DXVec3Add(v2,v2,tmp);
//      randomplus2(v2,GetTickCount,aimbot_pontatlan);
     end;
   end;

  if myfegyv=FEGYV_X72 then
  begin
   D3DXVec3Subtract(tmp,v2,hollo);
   FastVec3Normalize(tmp);
   D3DXVec3Add(v2,v2,tmp);
  end;

  multip2p.Loves(hollo,v2);
  setlength(multip2p.lovesek,length(multip2p.lovesek)+1);
  multip2p.lovesek[high(multip2p.lovesek)].pos:=hollo;
  multip2p.lovesek[high(multip2p.lovesek)].v2:=v2;
  multip2p.lovesek[high(multip2p.lovesek)].kilotte:=-1;
  multip2p.lovesek[high(multip2p.lovesek)].fegyv:=myfegyv;
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
   hollo:=D3DXVector3(0,-0.05,-0.7);

   v2:=hollo;

   if myfegyv=FEGYV_LAW then
    D3DXVec3add(hollo,hollo,D3DxVector3(0,0.0,-0.04))
   else
    D3DXVec3add(hollo,hollo,D3DxVector3(0,0.0,-0.04));


   d3dxvec3transformcoord(hollo,hollo,mfm);
   d3dxvec3transformcoord(v2,v2,mfm);
   d3dxvec3transformcoord(v1,d3dxvector3zero,mfm);
   for k:=0 to high(ojjektumnevek) do
   for j:=0 to ojjektumarr[k].hvszam-1 do
   begin
    if ojjektumarr[k].raytestbol(v1,hollo,j,COLLISION_BULLET) then exit;
   end;

  {$IFDEF Armageddon}
  hollo:=D3DXVector3(cpx^,cpy^+100,cpz^);
  randomplus(hollo,animstat*200,200);
  v2:=D3DXVector3(random(100)-50,random(100)-200,random(100)-50);
  fastvec3normalize(v2);
  d3dxvec3scale(v2,v2,0.1);
  d3dxvec3subtract(v2,hollo,v2);
  {$ENDIF}

  if (myfegyv=FEGYV_H31_T) or (myfegyv=FEGYV_H31_G) then
  d3dxvec3add(v2,v2,randomvec(random(1000),0.04*(x72gyrs-1/8)));

  multip2p.Loves(hollo,v2);
  setlength(multip2p.lovesek,length(multip2p.lovesek)+1);
  multip2p.lovesek[high(multip2p.lovesek)].pos:=hollo;
  multip2p.lovesek[high(multip2p.lovesek)].v2:=v2;
  multip2p.lovesek[high(multip2p.lovesek)].kilotte:=-1;
  multip2p.lovesek[high(multip2p.lovesek)].fegyv:=myfegyv;
  inc(zeneintensity,3000);
end;


function NtQueryInformationProcess(hProcess: THandle;ProcessInformationClass: Integer;Var ProcessInformation;ProcessInformationLength: Integer;ReturnLength: PInteger): Integer; stdcall;external 'ntdll.dll';
procedure undebug_debugobject;
{$IFDEF undebug}
var
 status,hdebugobject:dword;
{$ENDIF}
begin
{$IFDEF undebug}
 hDebugObject:=0;
 Status := NtQueryInformationProcess($ffffffff, 7,hDebugObject, 4, nil);
 if (Status = 0) then
 if(hDebugObject<>0) then {windows féle debug handler}
  setlength(ppl,0);
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

      Particlesystem_add(fenycsik3create(eap,ap,0.5,$FF00FFFF,j*10+50,50));
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

      Particlesystem_add(fenycsik3create(eap,ap,0.03,$FF00FFFF,j*10+20,20));
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

procedure Drawmessage(mit:string;szin:dword);
begin
  menu.drawtext(mit,0.1,hudMessagePosY,0.9,hudMessagePosY+0.1,1,szin);
  hudMessagePosY:=hudMessagePosY+hudMessageOffsetY;
end;

procedure showHudInfo(s:string;f:word;col:longword);
begin
hudInfo:=s;
hudInfoFade:=f;
hudInfoColor:=col;
end;


procedure addHudMessage(input:string;col:longword);
var
  i:byte;
begin
  for i:=high(hudMessages) downto low(hudMessages)+1 do
    hudMessages[i]:=hudMessages[i-1];

  hudMessages[i]:=THUDMessage.create(input,col);
end;

procedure stepHudMessages;
var
  i:byte;
begin
  if hudInfoFade<>0 then
    hudInfoFade:=hudInfoFade-1;
  for i:=low(hudMessages) to high(hudMessages) do
  begin
  if hudMessages[i].fade<>0 then
    hudMessages[i].fade:=hudMessages[i].fade-1;
  end;
end;



procedure iranyit;
var
ds,dc:single;
tmp:TD3DXVector3;
px,py,ph:single;
fut:boolean;
i:integer;
label
atugor;
begin

  if unfocused then exit; //LMFAO
  
  if iswindowed then
   dine.Update(point(SCWidth div 2+wndpos.x,SCHeight div 2+wndpos.y))
  else
   dine.update(point(SCWidth div 2,SCHeight div 2));

  if dine.keyd(DIK_LMENU) and dine.keyd2(DIK_RETURN) and not noborder and iswindowed then
  begin
    noborder:=true;
    misteryNumber:=GetWindowLong( hWindow, GWL_STYLE );
    SetWindowLong( hWindow,GWL_STYLE,GetWindowLong( hWindow, GWL_STYLE )and not WS_CAPTION);
    MoveWindow(hWindow,0, 0, GetSystemMetrics(SM_CXSCREEN),GetSystemMetrics(SM_CYSCREEN), false);
  end
  else if dine.keyd(DIK_LMENU) and dine.keyd2(DIK_RETURN) and noborder and iswindowed then
  begin
    noborder:=false;
    SetWindowLong( hWindow,GWL_STYLE,misteryNumber);//ezt valaki más kitalálja
    MoveWindow(hWindow, 0, 0, windowrect.Right-windowrect.Left, windowrect.Bottom-windowrect.Top, false);
  end;

  iranyithato:= iranyithato and (mapmode=0) and (portalevent<>nil) and not (portalevent.vege);


  if ((dine.mouss.rgbButtons[0] and $80)=$80) then chatmost:='';
  if length(chatmost)>0 then zeromemory(addr(dine.keys),sizeof(dine.keys));

  //atlantis
  nemviz:=false;


  for i:=0 to length(bubbles)-1 do
  with bubbles[i] do
  begin
    if tavpointpointsq(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(posx,posy,posz))<rad*rad then
      nemviz:=true;
  end;

  

  //Új irányítás kód
  ds:=sin(szogx);
  dc:=cos(szogx);
  px:=0; py:=0;
                                           // TODO
  gugg:=dine.keyd(DIK_LCONTROL) and (halal=0) and iranyithato;
  if (myfegyv=FEGYV_QUAD) and (not csipo) then iranyithato:=false;
  fut:= dine.keyd(DIK_W) and (not dine.keyd(DIK_LSHIFT)) and ((vizben<0.5) or nemviz) and iranyithato and csipo and (not gugg) and (halal=0);

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
  if repules then begin
  mstat:=0;
  px:=px*repszorzo; py:=py*repszorzo;
  end;
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
  if repules then begin
  cpox^:=cpox^+0.1*(cpx^-cpox^);//tehetetlenséd
  cpoy^:=cpoy^+0.1*(cpy^-cpoy^);
  cpoz^:=cpoz^+0.1*(cpz^-cpoz^);
   if dine.keyd(DIK_SPACE)then
    begin
      cpoy^:=cpoy^-0.03*repszorzo;
    end;
    gugg:=false;
   if dine.keyd(DIK_LCONTROL)then
    begin
      cpoy^:=cpoy^+0.03*repszorzo;
    end;
   end
  else
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
  {$ENDIF}

  if (length(chatmost)=0) and autoban then
  begin
    tegla.iranyit(dine.keyd(DIK_W),dine.keyd(DIK_S),dine.keyd(DIK_D),dine.keyd(DIK_A),true);
    if (tegla.axes[2].y<0) and dine.keyd(DIK_F) and (recovercar=0) then//beta
     recovercar:=1;
  end
   else
    tegla.iranyit(false,false,false,false,false);

  if iranyithato then
   if dine.keyd(DIK_W) or dine.keyd(DIK_SPACE) or dine.keyd(DIK_S) or
      dine.keyd(DIK_A) or dine.keyd(DIK_D) then
       multisc.killscamping:=multisc.kills;

  if dine.keyd(DIK_F) and (not autoban) {$IFNDEF speedhack} and (autobaszallhat){$ENDIF}and (halal=0) and (length(chatmost)=0) then
  begin
   tegla.free; autoban:=true;
   cpox^:=cpx^; cpoz^:=cpz^; cpoy^:=cpy^;
   {$IFNDEF speedhack}
   tmp:=autobaszallhatpos;
   tmp.y:=advwove(tmp.x,tmp.z)+2;
   {$ELSE}
   d3dxvec3add(tmp,d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(0,4,0));
   {$ENDIF}

   if myfegyv<128 then
    tegla:=Tauto.create(d3dxvector3(stuffjson.GetFloat(['vehicle','gun','scale','x']),0,0),
                        d3dxvector3(0,0,-stuffjson.GetFloat(['vehicle','gun','scale','z'])),
                        d3dxvector3(0,-stuffjson.GetFloat(['vehicle','gun','scale','y']),0),
                        tmp,
                        d3dxvector3zero,
                        stuffjson.GetFloat(['vehicle','gun','friction']),
                        0.5,
                        hummkerekarr,
                        stuffjson.GetFloat(['vehicle','gun','suspension','length']),
                        stuffjson.GetFloat(['vehicle','gun','suspension','strength']),
                        stuffjson.GetFloat(['vehicle','gun','suspension','absorb']),
                        stuffjson.GetFloat(['vehicle','gun','wheels','radius']),
                        stuffjson.GetFloat(['vehicle','gun','wheels','width']),
                        stuffjson.GetFloat(['vehicle','gun','wheels','friction']),
                        stuffjson.GetFloat(['vehicle','gun','max_speed']),
                        stuffjson.GetFloat(['vehicle','gun','torque']),
                        false)
   else
    tegla:=Tauto.create(d3dxvector3(stuffjson.GetFloat(['vehicle','tech','scale','x']),0,0),
                        d3dxvector3(0,0,-stuffjson.GetFloat(['vehicle','tech','scale','z'])),
                        d3dxvector3(0,-stuffjson.GetFloat(['vehicle','tech','scale','y']),0),
                        tmp,
                        d3dxvector3zero,
                        stuffjson.GetFloat(['vehicle','tech','friction']),
                        0.5,
                        agkerekarr,
                        stuffjson.GetFloat(['vehicle','tech','suspension','length']),
                        stuffjson.GetFloat(['vehicle','tech','suspension','strength']),
                        stuffjson.GetFloat(['vehicle','tech','suspension','absorb']),
                        stuffjson.GetFloat(['vehicle','tech','wheels','radius']),
                        stuffjson.GetFloat(['vehicle','tech','wheels','width']),
                        stuffjson.GetFloat(['vehicle','tech','wheels','friction']),
                        stuffjson.GetFloat(['vehicle','tech','max_speed']),
                        stuffjson.GetFloat(['vehicle','tech','torque']),
                        true);

  end;

  if  dine.keyd(DIK_F) and (not autoban) and (tavpointpointsq(tegla.pos,d3dxvector3(cpx^,cpy^,cpz^))<5*5) and (halal=0) then
  autoban:=true;


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
	
   {$IFDEF repkedomod}
   if repules then begin
  if (dine.MousMovScrl<0) then
  repszorzo:=repszorzo*0.9;
  if (dine.MousMovScrl>0) then
  repszorzo:=repszorzo*(1/0.9);
  end;
  {$ENDIF}	
	
  if not dine.keyd(DIK_TAB) then
  begin
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
  end
  else
  begin
  if (dine.MousMovScrl>0) then dec(tabgorg);
  if (dine.MousMovScrl<0) then inc(tabgorg);
  if tabgorg<0 then tabgorg:=0;
  end;

  if not (currevent is TReactorEvent) then
  if (myfegyv=FEGYV_H31_T) or (myfegyv=FEGYV_H31_G) then  //h31
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
        goto atugor;
      end;
      lovok:=lovok+eltim*4;
      if lovok>=0.99 then
      begin
        if x72gyrs<1 then
          x72gyrs:=x72gyrs+1/8; //kell
        lojjranged;
        cooldown:=1/3;
        hatralok:=0;
      end;
    end
    else
    begin
      if lovok>0 then
        lovok:=lovok-eltim*6;
      if lovok<0 then
        lovok:=0;
    end;
    lightIntensity:=lovok;
  end
  else //h31
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
        goto atugor;
      end;
      lovok:=lovok+0.01;
      if lovok>=0.99 then
      begin
        lojjranged;
        cooldown:=1.5;
        hatralok:=0.15;
        szogX:=szogx+(100-random(200))/4000;
        szogY:=szogy+(100-random(200))/400;
        inc(zeneintensity,round(4000));
      end;
    end
    else
    lovok:=0;
  end
  else
  begin
    if (((dine.mouss.rgbButtons[0] and $80)=$80)) and (cooldown<0) and (halal=0) and (mapmode=0)then
    if not((myfegyv=FEGYV_QUAD)and csipo) or autoban then
    begin
      labelactive:=false;

      if autoban then
      begin
        if kiszallas=0 then

        kiszallas:=1;
        goto atugor;
      end;

      if nemlohet then
      begin
        kiszall_cooldown:=-1;
        showHudInfo(lang[64],200,$FF0000);
        goto atugor;
      end
      else

      kiszall_cooldown:=0;
      //fegyv.addproj(FEGYV_M4A1,hollo,v2,M4_Golyoido);

      if (myfegyv=FEGYV_H31_T) or (myfegyv=FEGYV_H31_G) then
      begin
        lojjranged;
      end
      else
      begin
        if myfegyv<>FEGYV_LAW then
        if myfegyv=FEGYV_X72 then
        lojjegyet(5.0)
        else
        lojjegyet;
      end;


      if myfegyv=FEGYV_MP5A3 then mp5ptl:=mp5ptl+1;
      if myfegyv=FEGYV_X72 then x72gyrs:=x72gyrs+1/8;

      if (myfegyv=FEGYV_QUAD)then
      lightIntensity := lightIntensity + (1.5-lightIntensity)/4;

      if (myfegyv=FEGYV_M82A1) or (myfegyv=FEGYV_MPG) or (myfegyv=FEGYV_X72) then
      lightIntensity := 0.6;

      if (myfegyv=FEGYV_MP5A3) or (myfegyv=FEGYV_M4A1) then
      lightIntensity := 0.17;



      case myfegyv of
        FEGYV_M4A1: begin lovok:=holindul(FEGYV_M4A1); cooldown:=1/7.44; hatralok:=0.05; end;
        FEGYV_M82A1:
        begin
          lovok:=holindul(FEGYV_M82A1);
          cooldown:=1;
          hatralok:=0.15;
          if multip2p.medal_prof_active=1 then multip2p.medal_prof_count:=0;
          multip2p.medal_prof_active:=1;
        end;
       {$IFDEF admingun}
        FEGYV_MPG: begin lovok:=holindul(FEGYV_MPG); cooldown:=1/6; hatralok:=0.01; end;
       {$ELSE}
        FEGYV_MPG: begin lovok:=holindul(FEGYV_MPG); cooldown:=1/1.5; hatralok:=0.10; end;
       {$ENDIF}
        FEGYV_quad: begin lovok:=holindul(FEGYV_quad); cooldown:=1/7.93; hatralok:=0.04; end;
        FEGYV_LAW:
        begin
          LAWkesleltetes:=75;
          rezg:=2;
          lovok:=0.5;
          cooldown:=3;
          playsound(26,false,1,true,D3DXVector3(campos.x+cos(szogx),campos.y,campos.z-sin(szogx)));
          setsoundproperties(26,1,1,1,true,D3DXVector3(campos.x+cos(szogx),campos.y,campos.z-sin(szogx)));
        end;
        FEGYV_X72: begin lovok:=holindul(FEGYV_X72); cooldown:=max(x72gyrs-0.6,1/6.25); hatralok:=0.1; end;
        FEGYV_Mp5a3: begin lovok:=holindul(FEGYV_Mp5a3); cooldown:=1/8.32; hatralok:=0.05; end;
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
          szogX:=szogx+(100-random(200))/10000;
          szogY:=szogy+(100-random(200))/10000;
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
          MszogX:=Mszogx+(100-random(200))/1000;
          MszogY:=mszogy+(100-random(200))/1000;
        end
        else
        begin
          szogX:=szogx+(100-random(200))/10000;
          szogY:=szogy+(100-random(200))/10000;
         //szogX:=szogx+(100-random(200))/5000;
         //szogY:=szogy+(100-random(200))/5000;
        end;

      end;

       {$ENDIF}
    end;
  end;


  if (myfegyv=FEGYV_M82A1) and not csipo then begin
   szogX:=szogX + sin((volttim mod 3200)*D3DX_PI*2/3200)/20000;
   szogY:=szogY + cos((volttim mod 2500)*D3DX_PI*2/2500)/20000;
  end;

  dec(LAWkesleltetes);
  if Not ((halal=0) and (not nemlohet)) or (LAWkesleltetes<0) or autoban then LAWkesleltetes:=-1;
  if LAWkesleltetes=0 then
  begin
   lojjranged;
     {$IFDEF admingun} hatralok:=0.0;
     {$ELSE}
     hatralok:=0.3;
     {$ENDIF}

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
 
//  if (halal>0) then
//   if szogy>0 then szogy:=0;
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
     ide:=ojjektumarr[l].raytest(kerekorig[i],kerekek[i],j,COLLISION_SOLID);
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


function felrobbanva(gmbk:Tgmbk;kapcsk:Tkapcsk;hol,honnan:Td3DVector;siz:single):integer;
var
i,j,l:integer;
talalat:array [0..9] of boolean;
vec:TD3DXVector3;
begin
 result:=-1;

 if tavpointpointsq(hol,honnan)>sqr(siz+2) then exit;

 D3DXVec3TransformCoordArray(@gmbk[0],sizeof(gmbk[0]),@gmbk[0],sizeof(gmbk[0]),mat_World,11);

 for i:=0 to 9 do
  talalat[i]:=tavpointpointsq(hol,gmbk[i])<sqr(siz);


   for l:=0 to high(ojjektumnevek) do
   for j:=0 to ojjektumarr[l].hvszam-1 do
   begin
    D3dxvec3add(vec,ojjektumarr[l].holvannak[j],ojjektumarr[l].vce);
    if tavpointpointsq(honnan,vec)<sqr(ojjektumarr[l].rad+siz) then
     for i:=0 to 9 do
      if ojjektumarr[l].raytestbol(gmbk[i],hol,j,COLLISION_BULLET) then talalat[i]:=false;
    end;

 for i:=0 to 9 do
  if talalat[i] then
  begin
   result:=i;
   break;
  end;

end;


procedure handlerobbanas(hol:TD3DXVector3;kilotte:integer;lovesfegyv:byte;x72eletkor:single);
var
love:integer;
tmp:TD3DXVector3;
begin

  SetupMyMuksmatr;
  love:=-1;

  if (kilotte=-1) or ((lovesfegyv xor myfegyv)>=128) then
  case lovesfegyv of
   FEGYV_LAW:love:=felrobbanva(muks.gmbk,muks.kapcsk,hol,D3DXVector3(cpx^,cpy^,cpz^),BALANCE_LAW_RAD); //balance
   FEGYV_NOOB:love:=felrobbanva(muks.gmbk,muks.kapcsk,hol,D3DXVector3(cpx^,cpy^,cpz^),BALANCE_NOOB_RAD);
   FEGYV_X72:love:=felrobbanva(muks.gmbk,muks.kapcsk,hol,D3DXVector3(cpx^,cpy^,cpz^),x72eletkor/100+BALANCE_X72_RAD);        // x72eletkor/300+0.3

   FEGYV_H31_G:love:=felrobbanva(muks.gmbk,muks.kapcsk,hol,D3DXVector3(cpx^,cpy^,cpz^),x72eletkor/100+BALANCE_H31_RAD);
   FEGYV_H31_T:love:=felrobbanva(muks.gmbk,muks.kapcsk,hol,D3DXVector3(cpx^,cpy^,cpz^),x72eletkor/100+BALANCE_H31_RAD);
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
   if (lovesfegyv=FEGYV_H31_G) or (lovesfegyv=FEGYV_H31_T) then
   addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),tmp,myfegyv,love,0,kilotte,true)
   else
   addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),tmp,myfegyv,love,0,kilotte);
  end;
  {$ENDIF}

end;



procedure undebug_registers;
{$IFDEF undebug}
var
 cont:Tcontext;
{$ENDIF}
begin
{$IFDEF undebug}
 zeromemory(@cont,sizeof(cont));
 cont.ContextFlags:=CONTEXT_DEBUG_REGISTERS;
 getthreadcontext(getcurrentthread,cont);
 if (cont.Dr7<>0) then
    cpx^:=100000;
{$ENDIF}
end;

procedure DoLAWRobbanas(mi:integer;rippl,dirt:boolean);
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
  Particlesystem_add(Bulletcreate(lawproj[mi].v3,t,10,10,0.03,$00A0A050,0,true));
 end;

 for i:=0 to 100 do
 begin
  t:=lawproj[mi].v3;
  randomplus(t,animstat*10+i,7.35);
  Particlesystem_add(SimpleparticleCreate(t,randomvec(animstat*10+i,0.05),2,0,$00FFFF00,$01FF0000,random(20)+20));
 end;
 for i:=0 to 200 do
 begin
  t:=randomvec(animstat*2+i*3,0.525);
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
 playsound(17,false,integer(timegettime)+random(10000),true,avec);

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
  
   if opt_particle>0 then
  if dirt then
   begin
    col := $FF884400;
    if lawproj[mi].v3.y<=15 then col := $FFFFF6B5;
   for i:=0 to 40*opt_particle do
    begin
    t:=randomvec(animstat*2+i*3,0.42);
    Particlesystem_add(Gravityparticlecreate(lawproj[mi].v3,t,random(10)/90+0.1,0.1,0.163,col,$00000000,random(100)+330));

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
   t:=randomvec(animstat*2+i/30+j,i/66);
   Particlesystem_add(ExpsebparticleCreate(noobproj[mi].v3,t,0.5,0.5,0.95,weapons[3].col[1],$00000000,i+100));
  end;

 for i:=0 to 500 do
 begin
  t:=randomvec(animstat*2+i*3,1);
  fastvec3normalize(t);
  Particlesystem_add(ExpsebparticleCreate(noobproj[mi].v3,t,1.0,1.0,0.83,weapons[3].col[1],$00000000,random(50)+20));
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
 playsound(19,false,integer(timegettime)+random(10000),true,avec);

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
 t,t2:TD3DXVector3;
 i:integer;
 alngt,rad:single;
 avec:TD3DXVector3;
begin
  rad:=(x72proj[mi].eletkor/300+BALANCE_X72_RAD);

 Particlesystem_add(SimpleparticleCreate(x72proj[mi].v3,D3DXVector3Zero,rad*1.1,rad*0.8,weapons[4].col[1],$00000000,50));

 for i:=0 to 50 do
 begin
  t:=randomvec(animstat*2+i*3,1);
  fastvec3normalize(t);
  d3dxvec3scale(t,t,rad);
  D3dxvec3add(t,t,x72proj[mi].v3);
  Particlesystem_add(SimpleparticleCreate(t,D3DXVector3Zero,0.2,0,weapons[4].col[2],weapons[4].col[3],random(50)+20));
 end;

 for i:=0 to 20 do
 begin
  t:=randomvec(animstat*2+i*3,1);
  fastvec3normalize(t);
  d3dxvec3scale(t,t,rad*0.3);
  d3dxvec3scale(t2,t,0.25);
  D3dxvec3add(t,t,x72proj[mi].v3);
  particlesystem_Add(FenycsikuberCreate(x72proj[mi].v3,t,D3DXVector3Zero,t2,0.1,0,weapons[4].col[4],weapons[4].col[3],random(10)+10));
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
 playsound(21,false,integer(timegettime)+random(10000),true,avec);

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

procedure DoH31_TRobbanas(mi:integer;rippl:boolean);
var
 t,t2,v1:TD3DXVector3;
 i,j:integer;
 alngt,rad:single;
 avec:TD3DXVector3;
begin
 rad:=(h31_tproj[mi].eletkor/300+BALANCE_H31_RAD);

 Particlesystem_add(SimpleparticleCreate(h31_tproj[mi].v3,D3DXVector3Zero,rad*1.1,rad*0.8,$42DD6C,$00000000,100));

 for i:=0 to 25 do
 begin
  t:=randomvec(animstat*2+i*3,1);
  fastvec3normalize(t);
  d3dxvec3scale(t,t,rad*0.7);
  t.y:=0;
  D3dxvec3add(t,t,h31_tproj[mi].v3);
  Particlesystem_add(Gravityparticlecreate(t,d3dxvector3(0,(random(20)+20)/500,0),(random(2)+1)/10,0,0.12,$FFFFFFFF,$001A572A,random(50)+30));
 end;

 for i:=0 to 25 do
 begin
  t:=randomvec(animstat*2+i*3,1);
  fastvec3normalize(t);
  d3dxvec3scale(t,t,rad*0.7);
  t.y:=0;
  D3dxvec3add(t,t,h31_tproj[mi].v3);
  Particlesystem_add(expsebparticlecreate(t,randomvec(animstat*2+i*3,0.1),(random(2)+1)/10,0,0.9,$FFFFFFFF,$001A572A,random(50)+30));
 end;


 for i:=0 to 5 do
 begin
     v1.y:=h31_tproj[mi].v3.y;
     v1.x:=h31_tproj[mi].v3.x+sin(hanyszor)*(rad-((random(1000)/1000))*rad);
     v1.z:=h31_tproj[mi].v3.z+cos(hanyszor)*(rad-((random(1000)/1000))*rad);
     Particlesystem_add(simpleparticleCreate(v1,D3DXVector3(0,0.04*rad*0.5,0),0.2*rad*1.5,0.2*rad*1.5,$00D41C,$00000000,random(70)+30));
     v1.x:=h31_tproj[mi].v3.x+sin(hanyszor)*(rad-((random(1000)/1000))*rad);
     v1.z:=h31_tproj[mi].v3.z+cos(hanyszor)*(rad-((random(1000)/1000))*rad);
     Particlesystem_add(simpleparticleCreate(v1,D3DXVector3(0,0.03*rad*0.5,0),0.3*rad*1.5,0.2*rad*1.5,$00D41C,$00000000,random(70)+30));
     v1.x:=h31_tproj[mi].v3.x+sin(hanyszor)*(rad-((random(1000)/1000))*rad);
     v1.z:=h31_tproj[mi].v3.z+cos(hanyszor)*(rad-((random(1000)/1000))*rad);
     Particlesystem_add(simpleparticleCreate(v1,D3DXVector3(0,random(10)/1000*rad*1.5,0),0.5*rad*1.5,0.2*rad*1.5,$00D41C,$00000000,random(70)+30));
 end;

 alngt:=tavpointpointsq(d3dxvector3(cpx^,cpy^,cpz^),h31_tproj[mi].v3);
 if alngt<sqr(5) then
 begin
  rezg:=5-sqrt(alngt);
  d3dxvec3subtract(robhely,h31_tproj[mi].v3,d3dxvector3(cpx^,cpy^,cpz^));
  fastvec3normalize(robhely);
  if myfegyv<128 then
   inc(zeneintensity,10000);
 end;
 d3dxvec3lerp(avec,h31_tproj[mi].v3,d3dxvector3(cpx^,cpy^,cpz^),0);
 playsound(40,false,integer(timegettime)+random(10000),true,avec);

 if rippl then
   explosionripple(h31_tproj[mi].v3,true);

  handlerobbanas(h31_tproj[mi].v3,h31_tproj[mi].kilotte,FEGYV_H31_T,h31_tproj[mi].eletkor);

 h31_tproj[mi]:=h31_tproj[high(h31_tproj)];
 setlength(h31_tproj,high(h31_tproj));
end;

procedure DoH31_GRobbanas(mi:integer;rippl:boolean);
var
 t,t2,v1:TD3DXVector3;
 i,j:integer;
 alngt,rad:single;
 avec:TD3DXVector3;
begin
 rad:=(h31_gproj[mi].eletkor/300+BALANCE_H31_RAD);

 Particlesystem_add(SimpleparticleCreate(h31_gproj[mi].v3,D3DXVector3Zero,rad*1.1,rad*0.8,$42DD6C,$00000000,100));

 for i:=0 to 25 do
 begin
  t:=randomvec(animstat*2+i*3,1);
  fastvec3normalize(t);
  d3dxvec3scale(t,t,rad*0.7);
  t.y:=0;
  D3dxvec3add(t,t,h31_gproj[mi].v3);
  Particlesystem_add(Gravityparticlecreate(t,d3dxvector3(0,(random(20)+20)/500,0),(random(2)+1)/10,0,0.12,$FFFFFFFF,$001A572A,random(50)+30));
 end;

 for i:=0 to 25 do
 begin
  t:=randomvec(animstat*2+i*3,1);
  fastvec3normalize(t);
  d3dxvec3scale(t,t,rad*0.7);
  t.y:=0;
  D3dxvec3add(t,t,h31_gproj[mi].v3);
  Particlesystem_add(expsebparticlecreate(t,randomvec(animstat*2+i*3,0.1),(random(2)+1)/10,0,0.9,$FFFFFFFF,$001A572A,random(50)+30));
 end;


 for i:=0 to 5 do
 begin
     v1.y:=h31_gproj[mi].v3.y;
     v1.x:=h31_gproj[mi].v3.x+sin(hanyszor)*(rad-((random(1000)/1000))*rad);
     v1.z:=h31_gproj[mi].v3.z+cos(hanyszor)*(rad-((random(1000)/1000))*rad);
     Particlesystem_add(simpleparticleCreate(v1,D3DXVector3(0,0.04*rad*0.5,0),0.2*rad*1.5,0.2*rad*1.5,$00D41C,$00000000,random(70)+30));
     v1.x:=h31_gproj[mi].v3.x+sin(hanyszor)*(rad-((random(1000)/1000))*rad);
     v1.z:=h31_gproj[mi].v3.z+cos(hanyszor)*(rad-((random(1000)/1000))*rad);
     Particlesystem_add(simpleparticleCreate(v1,D3DXVector3(0,0.03*rad*0.5,0),0.3*rad*1.5,0.2*rad*1.5,$00D41C,$00000000,random(70)+30));
     v1.x:=h31_gproj[mi].v3.x+sin(hanyszor)*(rad-((random(1000)/1000))*rad);
     v1.z:=h31_gproj[mi].v3.z+cos(hanyszor)*(rad-((random(1000)/1000))*rad);
     Particlesystem_add(simpleparticleCreate(v1,D3DXVector3(0,random(10)/1000*rad*1.5,0),0.5*rad*1.5,0.2*rad*1.5,$00D41C,$00000000,random(70)+30));
 end;

 alngt:=tavpointpointsq(d3dxvector3(cpx^,cpy^,cpz^),h31_gproj[mi].v3);
 if alngt<sqr(5) then
 begin
  rezg:=5-sqrt(alngt);
  d3dxvec3subtract(robhely,h31_gproj[mi].v3,d3dxvector3(cpx^,cpy^,cpz^));
  fastvec3normalize(robhely);
  if myfegyv<128 then
   inc(zeneintensity,10000);
 end;
 d3dxvec3lerp(avec,h31_gproj[mi].v3,d3dxvector3(cpx^,cpy^,cpz^),0);
 playsound(40,false,integer(timegettime)+random(10000),true,avec);

 if rippl then
   explosionripple(h31_gproj[mi].v3,true);

  handlerobbanas(h31_gproj[mi].v3,h31_gproj[mi].kilotte,FEGYV_H31_G,h31_gproj[mi].eletkor);

 h31_gproj[mi]:=h31_gproj[high(h31_gproj)];
 setlength(h31_gproj,high(h31_gproj));
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
 iri:boolean;
label
lawskip,noobskip,x72skip,h31_gskip,h31_tskip;
begin

 vec2:=D3DXVector3(cpox^,cpoy^+0.8,cpoz^);
 laststate:='Docollisiontests 1';
 cp:=D3DXVector3(cpx^,cpy^*0.5+0.4,cpz^);

 autobaszallhat:=false;

 tulnagylokes:=false;
 for j:=0 to high(ojjektumnevek) do
 for i:=0 to ojjektumarr[j].hvszam-1 do
 begin
  adst:=ojjektumarr[j].tavtestmat(cp,0.4,ap,i,true,COLLISION_SOLID,walkmaterial);
  if adst>sqr(0.4) then continue;
  if (((ojjektumflags[j] and OF_VEHICLEGUN) >0) and (myfegyv< 128) or
     ((ojjektumflags[j] and OF_VEHICLETECH)>0) and (myfegyv>=128) ) and
     (cpy^>0) then
  begin
   autobaszallhat:=true;
   d3dxvec3add(autobaszallhatpos,ojjektumarr[j].holvannak[i],d3dxvector3(0,ojjektumarr[j].rad2*0.5+2,-ojjektumarr[j].rad2-2));
  end;
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

// cpox^:=cpox^+0.5*(cp.x-cpx^);
 cpoy^:=cpoy^+0.7*(cp.y*2-0.8-cpy^);
// cpoz^:=cpoz^+0.5*(cp.z-cpz^);

 cpx^:=cp.x;cpy^:=cp.y*2-0.8;cpz^:=cp.z;

 cp:=D3DXVector3(cpx^,cpy^,cpz^);


// PROP ÜTKÖZÉS
{ ideiglenesen kivéve
  for i:=0 to length(propsystem.objects)-1 do
 begin
  iri := propsystem.collision(cp,0.4,cp,i);
  iranyithato := iranyithato or iri;
 end;              {}

 laststate:='Docollisiontests 2';
//VONAL TESZT  ÉS ZÓNATESZT
 vec1:=D3DXVector3(cpx^,cpy^+1,cpz^);
 if not autoban then
 for l:=0 to high(ojjektumnevek) do
  for j:=0 to ojjektumarr[l].hvszam-1 do
   begin
   D3DXVec3add(vec4,ojjektumarr[l].holvannak[j],ojjektumarr[l].vce);
     if tavpointpointsq(vec1,vec4)<sqr(ojjektumarr[l].rad+1) then
      if ojjektumarr[l].raytestbol(vec1,vec2,j,COLLISION_SOLID) then
       wentthroughwall:=true;
   end
 else
 for l:=0 to high(ojjektumnevek) do
  for j:=0 to ojjektumarr[l].hvszam-1 do
   begin
   D3DXVec3add(vec4,ojjektumarr[l].holvannak[j],ojjektumarr[l].vce);
     if tavpointpointsq(vec1,vec4)<sqr(ojjektumarr[l].rad+1) then
      if ojjektumarr[l].raytestbol(tegla.pos,tegla.vpos,j,COLLISION_SOLID) then
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
   traverseKDTree(tmpbb,miket,ojjektumarr[l].KDData,ojjektumarr[l].KDTree,COLLISION_SOLID);
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
   traverseKDTree(tmpbb,miket,ojjektumarr[l].KDData,ojjektumarr[l].KDTree,COLLISION_SOLID);
   ojjektumarr[l].getacctris(tris,miket,ojjektumarr[l].holvannak[i],COLLISION_SOLID);
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
//  if colltim>=4 then
  if colltim>=1 then
  begin
  laststate:='Docollisiontests 6a';     //föld
   if advwove(v1.x,v1.z)>v1.y then
    begin
      DoLAWRobbanas(i,false,true);
      goto lawskip;
     end;
    laststate:='Docollisiontests 6b';     // panthi
   if tavpointpointsq(v1,DNSvec)<sqr(DNSrad) then
   begin
    if tavpointpointsq(v1,DNSvec)<sqr(DNSrad-5) then
    begin
     lawproj[i]:=lawproj[high(lawproj)];
     setlength(lawproj,high(lawproj));
    end
    else
     DoLAWRobbanas(i,true,false);
    goto lawskip;
   end;

   laststate:='Docollisiontests 6c';    // épület

   for l:=0 to high(ojjektumnevek) do
   for j:=0 to ojjektumarr[l].hvszam-1 do
   begin
      if ojjektumarr[l].raytestbol(v1,v3,j,COLLISION_BULLET) then
       begin
        DoLAWRobbanas(i,false,false);
        goto lawskip;
       end;
   end;

   for j:=0 to high(ppl) do
   if (j<>kilotte) then
   if tavPointLinesq0(v1,ppl[j].pos.megjpos,d3dxvector3(ppl[j].pos.megjpos.x,ppl[j].pos.megjpos.y + 1.5,ppl[j].pos.megjpos.z), adst) and (adst<(0.04*(1+eletkor/20))) then
   begin
    DoLAWRobbanas(i,false,false);
    goto lawskip;
   end;

   if (kilotte<>-1) then
   if tavPointLinesq0(v1,d3dxvector3(cpx^, cpy^, cpz^),d3dxvector3(cpx^, cpy^ + 1.5, cpz^), adst) and (adst<(0.04*(1+eletkor/20))) then
   begin
    DoLAWRobbanas(i,false,false);
    goto lawskip;
   end;

   v3:=v1;
   colltim:=0;
   inc(i);

   lawskip:
  end
  else
   inc(i);

   i:=0;

  laststate:='Docollisiontests 7';   //Bugos?
//NOOB

 while i<=high(noobproj) do
 with noobproj[i] do
//  if (colltim>=3) or (eletkor>150) then
  if (colltim>=1) then
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
      if ojjektumarr[l].raytestbol(v1,v3,j,COLLISION_BULLET) then
       begin
        DonoobRobbanas(i,false);
        goto noobskip;
       end;
   end;



   for j:=0 to high(ppl) do
   if (j<>kilotte) then
   if tavPointLinesq0(v1,ppl[j].pos.megjpos,d3dxvector3(ppl[j].pos.megjpos.x,ppl[j].pos.megjpos.y + 1.5,ppl[j].pos.megjpos.z), adst) and (adst<(0.04*(1+eletkor/20))) then
   begin
    DonoobRobbanas(i,false);
    goto noobskip;
   end;

   if (kilotte<>-1) then
   if tavPointLinesq0(v1,d3dxvector3(cpx^, cpy^, cpz^),d3dxvector3(cpx^, cpy^ + 1.5, cpz^), adst) and (adst<(0.04*(1+eletkor/20))) then
   begin
    DonoobRobbanas(i,false);
    goto noobskip;
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
//  if (colltim>=3) then
  if (colltim>=1) then
  begin
   Particlesystem_add(fenycsikcreate(v1,v3,0.07,weapons[4].col[5],100));
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
      if ojjektumarr[l].raytestbol(v1,v3,j,COLLISION_BULLET) then
       begin
        Dox72Robbanas(i,false);
        goto x72skip;
       end;
   end;



   if tavpointpointsq(v1,cel)<sqr((eletkor/300+BALANCE_X72_RAD)*0.66) then
   begin
    DoX72Robbanas(i,false);
    goto x72skip;
   end;

   for j:=0 to high(ppl) do
   if (j<>kilotte) then
   if tavPointLinesq0(v1,ppl[j].pos.megjpos,d3dxvector3(ppl[j].pos.megjpos.x,ppl[j].pos.megjpos.y + 1.5,ppl[j].pos.megjpos.z), adst) and (adst<(0.04*(1+eletkor/20))) then
   begin
    Dox72Robbanas(i,false);
    goto x72skip;
   end;
   
   if (kilotte<>-1) then
   if tavPointLinesq0(v1,d3dxvector3(cpx^, cpy^, cpz^),d3dxvector3(cpx^, cpy^ + 1.5, cpz^), adst) and (adst<(0.04*(1+eletkor/20))) then
   begin
    Dox72Robbanas(i,false);
    goto x72skip;
   end;

   if eletkor>300 then //vagy ez vagy a cél check kell, amúgy bugos
   begin
    Dox72Robbanas(i,false);
    goto x72skip;
   end; 

   v3:=v1;
   colltim:=0;
   inc(i);

   x72skip:
  end
  else
   inc(i);

   laststate:='Docollisiontests 9';

 i:=0;

 while i<=high(h31_gproj) do
 with h31_gproj[i] do
  if (colltim>=1) then
  begin
   if advwove(v1.x,v1.z)>v1.y then
    begin
      DoH31_GRobbanas(i,false);
      goto h31_gskip;
     end;

   if tavpointpointsq(v1,DNSvec)<sqr(DNSrad) then
   begin
    if tavpointpointsq(v1,DNSvec)<sqr(DNSrad-5) then
    begin
     h31_gproj[i]:=h31_gproj[high(h31_gproj)];
     setlength(h31_gproj,length(h31_gproj)-1);
    end
    else
    DoH31_GRobbanas(i,true);
    goto h31_gskip;
   end;


   for l:=0 to high(ojjektumnevek) do
   for j:=0 to ojjektumarr[l].hvszam-1 do
   begin
      if ojjektumarr[l].raytestbol(v1,v3,j,COLLISION_BULLET) then
       begin
        DoH31_GRobbanas(i,false);
        goto h31_gskip;
       end;
  end;


   for j:=0 to high(ppl) do
   if (j<>kilotte) then
   if tavPointLinesq0(v1,ppl[j].pos.megjpos,d3dxvector3(ppl[j].pos.megjpos.x,ppl[j].pos.megjpos.y + 1.5,ppl[j].pos.megjpos.z), adst) and (adst<(0.04*(1+eletkor/20))) then
   begin
    DoH31_GRobbanas(i,false);
    goto h31_gskip;
   end;

   if (kilotte<>-1) then
   if tavPointLinesq0(v1,d3dxvector3(cpx^, cpy^, cpz^),d3dxvector3(cpx^, cpy^ + 1.5, cpz^), adst) and (adst<(0.04*(1+eletkor/20))) then
   begin
    DoH31_GRobbanas(i,false);
    goto h31_gskip;
   end;

   if eletkor>300 then
   begin
    DoH31_GRobbanas(i,false);
    goto h31_gskip;
   end;

   v3:=v1;
   colltim:=0;
   inc(i);

   h31_gskip:
  end
  else
   inc(i);

   laststate:='Docollisiontests 10';


 i:=0;

 while i<=high(h31_tproj) do
 with h31_tproj[i] do
  if (colltim>=1) then
  begin
   if advwove(v1.x,v1.z)>v1.y then
    begin
      DoH31_TRobbanas(i,false);
      goto h31_tskip;
     end;

   if tavpointpointsq(v1,DNSvec)<sqr(DNSrad) then
   begin
    if tavpointpointsq(v1,DNSvec)<sqr(DNSrad-5) then
    begin
     h31_tproj[i]:=h31_tproj[high(h31_tproj)];
     setlength(h31_tproj,length(h31_tproj)-1);
    end
    else
    DoH31_TRobbanas(i,true);
    goto h31_tskip;
   end;


   for l:=0 to high(ojjektumnevek) do
   for j:=0 to ojjektumarr[l].hvszam-1 do
   begin
      if ojjektumarr[l].raytestbol(v1,v3,j,COLLISION_BULLET) then
       begin
        DoH31_TRobbanas(i,false);
        goto h31_tskip;
       end;
  end;


   for j:=0 to high(ppl) do
   if (j<>kilotte) then
   if tavPointLinesq0(v1,ppl[j].pos.megjpos,d3dxvector3(ppl[j].pos.megjpos.x,ppl[j].pos.megjpos.y + 1.5,ppl[j].pos.megjpos.z), adst) and (adst<(0.04*(1+eletkor/20))) then
   begin
    DoH31_TRobbanas(i,false);
    goto h31_tskip;
   end;

   if (kilotte<>-1) then
   if tavPointLinesq0(v1,d3dxvector3(cpx^, cpy^, cpz^),d3dxvector3(cpx^, cpy^ + 1.5, cpz^), adst) and (adst<(0.04*(1+eletkor/20))) then
   begin
    DoH31_TRobbanas(i,false);
    goto h31_tskip;
   end;

   if eletkor>300 then
   begin
    DoH31_TRobbanas(i,false);
    goto h31_tskip;
   end;

   v3:=v1;
   colltim:=0;
   inc(i);

   h31_tskip:
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
    v1:=ojjektumarr[k].raytest(v2,v1,j,COLLISION_SOLID);
   end;
  end;  // }


 d3dxvec3scale(s2,s2,0.1);
 d3dxvec3add(v2,v1,s2);
 Particlesystem_add(Esocseppcreate(v2,v1,0.2,2,$C0C0A0A0,round(1+(abs(pls1)+abs(pls2))/10)));
 if v1.y<>tmp then
 Particlesystem_add(Simpleparticlecreate(v1,D3DXVector3zero,0.03,0,$C0C0A0A0,0,20));
end;

{$IFDEF panthihogomb}
procedure addhopehely(tav:integer);
var
v,v1,v2,s,s2,tmpv:TD3DXVector3;
pls1,pls2:single;
j,k:integer;
begin
 pls1:=(random(tav*1000)-500*tav)/1000;
 pls2:=(random(tav*1000)-500*tav)/1000;

 v:=D3DXVector3(campos.x+pls1,campos.y,campos.z+pls2);

 pls1:=(random(1000)-500)/1000;
 pls2:=(random(1000)-500)/1000;
 s:=D3DXVector3(pls1,-2,pls2);
 fastvec3normalize(s);

 D3DXVec3Scale(s2,s, 02.0);
 d3dxvec3add(v1,v,s2);
 D3DXVec3Scale(s2,s,-100.0);
 d3dxvec3add(v2,v,s2);

 for k:=0 to high(ojjektumnevek) do
 begin
  for j:=0 to ojjektumarr[k].hvszam-1 do
  begin
   d3dxvec3add(tmpv,ojjektumarr[k].holvannak[j],ojjektumarr[k].vce);
   if tavpointpointsq(campos,tmpv)<sqr(ojjektumarr[k].rad+20) then
    v1:=ojjektumarr[k].raytest(v2,v1,j,COLLISION_SOLID);
  end;
 end;

 D3DXVec3Scale(s,s,0.03);
 D3DXVec3Scale(s2,s,300);
 D3DXVec3Subtract(v2,v1,s2);
 Particlesystem_add(Simpleparticlecreate(v2,s,0.03,0.03,$80FFFFFF,$80FFFFFF,500));
end;
{$ENDIF}

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
var
tmp1,tmp2:TD3DXVector3;
szog,l:single;
begin
 setlength(X72proj, length(X72proj)+1);
 with X72proj[high(X72proj)] do
 begin
  v1:=av1;
  cel:=av2;
  d3dxvec3Subtract(v2,av2,av1);


  name:=XORHash2x12byte(av1,av2);
  name:=(name+1)*(name+2)*(name-1)*(name-2)*134775813;
  D3DXVec3Cross(tmp1,v2,D3DXVector3(0,1,0));
  D3DXVec3Cross(tmp2,v2,tmp1);

  FastVec3Normalize(tmp1);
  FastVec3Normalize(tmp2);

  szog:=((name and $FFFF)/$10000)*D3DX_PI;

  d3dxvec3scale(tmp1,tmp1,cos(szog));
  d3dxvec3scale(tmp2,tmp2,-sin(szog));
  l:=d3dxvec3length(v2);
  if l>0.000001 then
    d3dxvec3scale(v2,v2,1/l);
  d3dxvec3add(v2,v2,tmp1);
  d3dxvec3add(v2,v2,tmp2);
  d3dxvec3scale(v2,v2,0.005*l);

  d3dxvec3subtract(v2,v1,v2);

  v3:=v2;
  kilotte:=akl;
  eletkor:=0;
 end;
end;

procedure AddH31_G(av1,av2:TD3DXvector3;akl:integer);
var
tmp1,tmp2:TD3DXVector3;
szog,l:single;
begin
 setlength(h31_gproj, length(h31_gproj)+1);
 with h31_gproj[high(h31_gproj)] do
 begin
  v1:=av1;
  v2:=av2;
  v3:=v2;
  name:=XORHash2x12byte(v1,v2);
  kilotte:=akl;
  eletkor:=0;
 end;
end;

procedure AddH31_T(av1,av2:TD3DXvector3;akl:integer);
var
tmp1,tmp2:TD3DXVector3;
szog,l:single;
begin
 setlength(h31_tproj, length(h31_tproj)+1);
 with h31_tproj[high(h31_tproj)] do
 begin
  v1:=av1;
  v2:=av2;
  v3:=v2;
  name:=XORHash2x12byte(v1,v2);
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
 if (sqr(vecx.x-cpx^)+sqr(vecx.z-cpz^))<sqr(ojjektumarr[panthepulet].rad*1.4) then
  nemlohet:=true;

 vecx:=ojjektumarr[portalepulet].holvannak[0];
 if (cpx^>vecx.x-13) and (cpx^<vecx.x+9) and
    (cpz^>vecx.z-9) and (cpz^<vecx.z+8) and
    (cpy^>vecx.y-1) and (cpy^<vecx.y+4) then  nemlohet:=true;

  if disablekill then  nemlohet:=true;

 if (nemlohet) and (kiszall_cooldown<1) then kiszall_cooldown:=kiszall_cooldown+0.01;

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
    tmpint:=ojjektumarr[k].raytestlght(vec0,tmpvec2[a],j,COLLISION_SHADOW);
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
  HDRincit:=(HDRincit*5+tmp)/6;
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
    bol:=bol or ojjektumarr[k].raytestbol(vec0,vec1,j,COLLISION_SHADOW);
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
vec1,vec2,vec3:  TD3DXVector3;
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
  Particlesystem_add(bulletcreate(vec1,vec2,0.05,50,0.03,$FFFFFFFF,0,false));
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
ujzone:string;
begin
 if zonechanged>0 then dec(zonechanged);
 zonaban:=false;
 zch:=false;
 vec1:=D3DXVector3(cpx^,cpy^+0.8,cpz^);
 lk:=100000000000;
 for i:=1 to high(ojjektumnevek) do
 if ojjektumzone[i]<>'' then
  for j:=0 to ojjektumarr[i].hvszam-1 do
   begin
     D3DXVec3add(vec2,ojjektumarr[i].holvannak[j],ojjektumarr[i].vce);
     mt:=tavpointpointsq(vec1,vec2);
     if mt<sqr(ojjektumarr[i].rad+radpls) then

     if mt<lk then
     begin
       zonaban:=true;
       lk:=mt;
       ujzone:=ojjektumzone[i];
     end;
   end;

 if lastzone<>ujzone then
 begin
  lastzone:=ujzone;
  zch:=true;
 end;

 if (lastzone<>'') and (not zonaban) then
 begin
  lastzone:='';
  zonechanged:=0;
  zonaellen:=0;
  zonabarat:=0;
  zch:=false;
 end;

 if zch or ((hanyszor and 15)=0) then
 begin
  zonaellen:=0;
  zonabarat:=0;
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
     for k:=0 to high(ppl) do
   if ((ppl[k].pls.fegyv and myfegyv)>127) or ((ppl[k].pls.fegyv and myfegyv)<127) then
   begin
    vec1:=ppl[k].pos.megjpos;
    for i:=1 to high(ojjektumnevek) do
    if ojjektumzone[i]=lastzone then
     for j:=0 to ojjektumarr[i].hvszam-1 do
     begin
      D3DXVec3add(vec2,ojjektumarr[i].holvannak[j],ojjektumarr[i].vce);
      if tavpointpointsq(vec1,vec2)<sqr(ojjektumarr[i].rad+radpls) then
       inc(zonabarat);
     end;
   end;

 end;
end;


procedure handleparticlesystems;
var
n,a,b,lt,modifier:integer;
atav,vis2:single;
tmp:TD3DXVector3;
begin


n := high(particlesSyses);
if opt_particle > 0 then
for a:=0 to n do
with particlesSyses[a] do
begin
  if autoban then
    atav:=tavpointpointsq(from,tegla.pos)
  else
    atav:=tavpointpointsq(from,d3dxvector3(cpx^,cpy^,cpz^));
  if (atav<sqr(vis*opt_particle)) and ((hanyszor and period)=period) then
  begin
      //jöhet a rajzolás
      if opt_particle=1 then
      modifier:=round(random(5)/5)-1;
      if opt_particle=2 then
      modifier:=random(1);
      if opt_particle=PARTICLE_MAX then
      modifier:=1;

      lt := lifetime + random(rndlt);
      case tipus of                                                                                             //todo random color
      PSYS_SIMPLE:for b:=0 to modifier*amount do
      begin
      D3DXVec3Scale(tmp,spd,lerp(1.0,spdrnd,random(10)/10));
      D3DXVec3Add(tmp,tmp,d3dxvector3(-rnd/2+random(20)*rnd/20,-rnd/2+random(20)*rnd/20,-rnd/2+random(20)*rnd/20));
      Particlesystem_add(Simpleparticlecreate(from,tmp,ssize,esize,scolor+rcolor*random(10),ecolor,lt,texture));
      end;
      PSYS_GRAVITY:for b:=0 to modifier*amount do
      begin
      D3DXVec3Scale(tmp,spd,lerp(1.0,spdrnd,random(10)/10));
      D3DXVec3Add(tmp,tmp,d3dxvector3(-rnd/2+random(20)*rnd/20,-rnd/2+random(20)*rnd/20,-rnd/2+random(20)*rnd/20));
      Particlesystem_add(Gravityparticlecreate(from,tmp,ssize,esize,szorzo,scolor+rcolor*random(10),ecolor,lt,texture));
      end;
      PSYS_COOLING:for b:=0 to modifier*amount do
      begin
      D3DXVec3Scale(tmp,spd,lerp(1.0,spdrnd,random(10)/10));
      D3DXVec3Add(tmp,tmp,d3dxvector3(-rnd/2+random(20)*rnd/20,-rnd/2+random(20)*rnd/20,-rnd/2+random(20)*rnd/20));
      Particlesystem_add(Coolingparticlecreate(from,tmp,ssize,esize,szorzo,scolor+rcolor*random(10),ecolor,lt,texture));
      end;
      PSYS_LIGHTNING:Particlesystem_Add_Villam(from,tmp,ssize,szorzo,amount,esize,scolor+rcolor*random(10),lifetime);
      end;
  end;

end;


end;


procedure handlelabels;
var
i:integer;
atav:single;
begin

 if labelactive then Exit;
 labelvolt:=false;
 
 for i:=0 to high(labels) do
  with labels[i] do
  begin
   atav:=tavpointpointsq(pos,d3dxvector3(cpx^,cpy^,cpz^));

   if (atav<sqr(rad)) then
   begin
     labelvolt:=true;
     labeltext:=text;
   end;
  end;
end;


procedure drawLabel;
begin
 menu.Addteg(0.1,0.1,0.9,0.9,8);
 menu.DrawKerekitett(menu.tegs[8,1]);
 menu.g_psprite.Flush;
 menu.DrawMultilineText(labeltext,0.1,0.1,0.9,0.9,1,$FFFFFFFF);
end;

procedure handleteleports;
var
i,k:integer;
atav:single;
v1,v2:TD3DXVector3;
rnd:single;
vis2:single;
begin

 for k:=0 to high(teleports) do
  with teleports[k] do
  begin
   if autoban then
    atav:=tavpointpointsq(vfrom,tegla.pos)
   else
    atav:=tavpointpointsq(vfrom,d3dxvector3(cpx^,cpy^,cpz^));

   vis2 := vis;
   if opt_particle>0 then vis2 := vis * 3;
   if atav<sqr(vis2) then
   begin
    if tip=0 then
    if (hanyszor and 1)=1 then
    begin
     v1.x:=vfrom.x+sin(hanyszor/8)*(rad+0.4);
     v1.y:=vfrom.y;
     v1.z:=vfrom.z+cos(hanyszor/8)*(rad+0.4);
     Particlesystem_add(simpleparticleCreate(v1,D3DXVector3(0,0.03,0),0.3,0.5,$002040FF,$00000000,random(50)+100));
    end;

    if tip=2 then
    if (hanyszor and 1)=1 then
    begin
     v1.x:=vfrom.x+(Random(200)-100)/100*(rad);
     v1.y:=vfrom.y;
     v1.z:=vfrom.z+(Random(200)-100)/100*(rad);
     Particlesystem_add(simpleparticleCreate(v1,D3DXVector3(0,0.03,0),0.11,0.13,$00FF6611,$00000000,random(50)+100));
    end;

    if tip=1 then
    if (hanyszor and 1)=1 then
    begin
     v1.x:=vfrom.x+(Random(200)-100)/100*(rad);
     v1.y:=vfrom.y;
     v1.z:=vfrom.z+(Random(200)-100)/100*(rad);
     Particlesystem_add(simpleparticleCreate(v1,D3DXVector3(0,0.03,0),0.11,0.13,$002222FF,$00000000,random(50)+100));
    end;

    if tip=3 then
    if (hanyszor and 5)=5 then
    begin
      v1.x:=vfrom.x+(Random(200)-100)/100*(rad);
     v1.y:=vfrom.y;
     v1.z:=vfrom.z+(Random(200)-100)/100*(rad);
    Particlesystem_add(CoolingparticleCreate(v1,D3DXVector3(random(10)*0.01-0.05,0.03,random(10)*0.01-0.05),1.5,8.5+random(15)*0.1,random(60)*0.001+0.12,$FFAAAAAA+random(32)*$010101,$00000000,random(230)+900));
    end;

    if tip=0 then
    if random(40)=0 then
    begin
     v1:=vfrom;
     v1.y:=v1.y+2-random(200)/200;
     Particlesystem_add(fenykorcreate(v1,D3DXVector3(0,0.03,0),d3dxvector3(1,0,0),d3dxvector3(0,0,1),rad,rad,0.5,$004080FF,$00000000,100));
     Particlesystem_add(fenykorcreate(v1,D3DXVector3(0,-0.02,0),d3dxvector3(1,0,0),d3dxvector3(0,0,1),rad,rad,0.5,$004080FF,$00000000,100));

    end;


    if ((hanyszor and 3)=0) and (tip=0) then
    begin
     d3dxvec3subtract(v1,vfrom,campos);
     v1.y:=0;
     fastvec3normalize(v1);
     rnd:=-(random(2000)*0.001-0.001)*rad*0.5;
     v1:=D3DXVector3(vfrom.x+v1.x*rnd,vfrom.y+v1.y*rnd,vfrom.z+v1.z*rnd);
     v2:=v1;
     v2.y:=v1.y+4;
     Particlesystem_add(fenycsik2create(v1,v2,rad*1.2,$00204060,$0,20));
    end;


   if ((hanyszor and 3)=0) and (tip=2) then
    begin
     d3dxvec3subtract(v1,vfrom,campos);
     v1.y:=0;
     fastvec3normalize(v1);
     rnd:=-(random(2000)*0.001-0.001)*rad*0.5;
     v1:=D3DXVector3(vfrom.x+v1.x*rnd,vfrom.y+v1.y*rnd,vfrom.z+v1.z*rnd);
     v2:=v1;
     v2.y:=v1.y+4;
     Particlesystem_add(fenycsik2create(v1,v2,rad*1.2,$00803300,$0,20));
    end;

   if ((hanyszor and 3)=0) and (tip=1) then
    begin
     d3dxvec3subtract(v1,vfrom,campos);
     v1.y:=0;
     fastvec3normalize(v1);
     rnd:=-(random(2000)*0.001-0.001)*rad*0.5;
     v1:=D3DXVector3(vfrom.x+v1.x*rnd,vfrom.y+v1.y*rnd,vfrom.z+v1.z*rnd);
     v2:=v1;
     v2.y:=v1.y+4;
     Particlesystem_add(fenycsik2create(v1,v2,rad*1.2,$002222FF,$0,20));
    end;

   end;

   if portalevent<>nil then
   if portalevent.phstim>3350 then
   if (tip=3) and (atav<sqr(rad)) then begin
    portalevent.vege:=true;
    PlaySound(38,false,666,false,D3DXVector3(0,0,0));
    exit;
    end;


   if (atav<sqr(rad)) and ((tip=0) or ((tip=1) and (myfegyv>=128)) or ((tip=2) and (myfegyv<128)))then
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
    playsound(25,false,integer(timegettime)+random(10000),true,D3DXVector3(cpx^,cpy^+1.5,cpz^));
    for i:=0 to 200 do
    begin
     v1:=randomvec(animstat*2+i*3,1);
     fastvec3normalize(v1);
     Particlesystem_add(ExpsebparticleCreate(D3DXVector3(cpx^,cpy^+1.5,cpz^),v1,1.0,1.0,0.8,$001020FF,$00000000,random(50)+20));
    end;
   end;
  end;

end;


procedure handlefizik;
var
i,j,k:integer;
ox,oy,oz,amag,tx,tz:single;
norm,hova,opos,tmp,tmps:TD3DXVector3;
korlat:integer;
rbid:integer;
h1,h2,h3:integer;
bol:boolean;
eses,nagyeses:boolean;
rnd:integer;
cnt:integer;
mxh:integer;
mx,tmp2:single;
col:cardinal;
v1,v2,v3,vecx,ppos:TD3DXVector3;

gtc:cardinal;
aauto:Tauto;
tuleli:boolean;
begin

 gtc:=gettickcount;
 korlat:=0;
 repeat
  inc(hanyszor);
 // if playrocks>1 then playrocks:=1;
  if vizben<0 then vizben:=0;
  if vizben>1 then vizben:=1;
  if autoban then
  begin
   if (cpy^<9.5) and (halal=0) then
   begin
   tuleli:=false;
    for i:=0 to length(bubbles)-1 do
    with bubbles[i] do
    begin
    if tavpointpointsq(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(posx,posy,posz))<rad*rad then
    tuleli:=true;
    end;
   if (not tuleli) then
    begin
    halal:=1;
    autoban:=false;
    addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),d3dxvector3(0.00,-0.1,0),myfegyv,10,0,-1);
    end;
   end;
  end
  else
  if ((cpy^<9) and gugg) or ((cpy^<8.5) and (not gugg)) then
  if halal=0 then
  begin
  tuleli:=false;
   for i:=0 to length(bubbles)-1 do
    with bubbles[i] do
    begin
    if tavpointpointsq(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(posx,posy,posz))<rad*rad then
    tuleli:=true;
    end;
   if (not tuleli) then begin
   halal:=1;
   //couldn't swim
   addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),d3dxvector3(0.00,0.0,0),myfegyv,10,0,-1);
   end;
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

  if opt_particle > 1 then
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
    if (tmp.y>9) and gunautoeffekt then
     if tmp.y<15 then
      if tmp.y<11 then
        Particlesystem_add(SimpleparticleCreate(tmp,randomvec(animstat*100+hanyszor,0.2),0.5,2,$FFEEEEFF,$0,100))
      else
        Particlesystem_add(SimpleparticleCreate(tmp,randomvec(animstat*100+hanyszor,0.1),0.5,2,sand_dust,$0,100))
     else
     {$IFDEF panthihogomb}
     if tavpointpointsq(DNSVec,tmp)<DNSrad*DNSRad then
      Particlesystem_add(SimpleparticleCreate(tmp,randomvec(animstat*100+hanyszor,0.1),0.5,2,$FFFFFFFF,$0,100))
     else
     {$ENDIF}
      Particlesystem_add(SimpleparticleCreate(tmp,randomvec(animstat*100+hanyszor,0.1),0.5,2,grass_dust,$0,100))

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

    if techautoeffekt then
    begin
     tmp :=aauto.kerekorig[0]; randomplus(tmp ,gtc  ,1);
     tmps:=aauto.kerekorig[1]; randomplus(tmps,gtc+5,1);
     Particlesystem_add(fenycsikcreate(tmp,tmps,0.3,$00051040,100));
     tmp :=aauto.kerekorig[2]; randomplus(tmp ,gtc  ,1);
     tmps:=aauto.kerekorig[3]; randomplus(tmps,gtc+5,1);

     Particlesystem_add(fenycsikcreate(tmp,tmps,0.3,$00051040,100));
    end;
   end;
  end;
  end;

  oopos:=D3DXVector3(cpox^,cpoy^,cpoz^);
  wentthroughwall:=false;

  laststate:='Doing Real Physics';


   //Saját fizika

  iranyithato:=false;
  docollisiontests;

  ox:=cpx^;oy:=cpy^;oz:=cpz^;
  try
  amag:=advwove(cpx^,cpz^);
  except
  amag:=0;
  end;
  eses:= cpy^-0.07>amag;
  nagyeses:= cpy^-0.2>amag;
  yandnorm(cpx^,amag,cpz^,norm,1);
  {$IFDEF repkedomod}
  if repules then  cpy^:=cpy^*2-cpoy^
    else cpy^:=cpy^*2-cpoy^-GRAVITACIO;
  {$ELSE}
  cpy^:=cpy^*2-cpoy^-GRAVITACIO;
  {$ENDIF}
  if (cpy^-0.03)<amag then
  begin
   if not volthi then
    if (halal=0) and (not autoban) then
    if cpy^>79.4 then
    begin
     volthi:=true; multisc.Medal('H','I');
    end;

    if not iranyithato or (cpy^<amag) then
    begin
     cpy^:=amag;
     oy:=amag;

     walkmaterial := MAT_DEFAULT;

     if nagyeses then rezg := 3;
     if eses and (opt_particle>0) then
      begin
        ppos :=  D3DXVector3(cpx^,cpy^,cpz^);
        if (multisc.weather>5) and (ppos.y<15) and (ppos.y>10.35) then //parton + nincs esõ
        begin
          col := sand_dust;
          for i:=0 to 20*opt_particle do
          begin
            tmp:=randomvec(animstat*2+i*3,0.12);
            Particlesystem_add(GravityparticleCreate(ppos,tmp,random(10)/60+0.03,0.1,0.08,col,0,random(100)+170));
          end;
        end
        else if (multisc.weather<=5) and (ppos.y>=15) then //földön + esõ
        begin
          col := color_mud;
          for i:=0 to 20*opt_particle do
          begin
            tmp:=randomvec(animstat*2+i*3,0.12);
            Particlesystem_add(GravityparticleCreate(ppos,tmp,random(5)/60+0.02,0.05,0.18,col,0,random(100)+170));
          end;
        end
        else if (ppos.y<(10.1+singtc/10)) then //vízben
        begin
          col := weapons[5].col[0]; //logic
          for i:=0 to 30*opt_particle do
          begin
            tmp:=randomvec(animstat*2+i*3,0.12);
            Particlesystem_add(GravityparticleCreate(ppos,tmp,random(8)/60+0.02,0.05,0.1,col,0,random(100)+170));
          end;
        end;
      end;


    end;
   {$IFNDEF repkedomod}
   if norm.y<0.83 then
   begin
    cpx^:=cpx^+norm.x*0.001;
    cpz^:=cpz^+norm.z*0.001;
   end;
  {$ELSE}
   if not repules and (norm.y<0.83) then
   begin
    cpx^:=cpx^+norm.x*0.001;
    cpz^:=cpz^+norm.z*0.001;
   end;

  {$ENDIF}
  end;

  if not (((cpy^-0.1)<amag) and (norm.y>0.83)) then
  begin
   if ((cpy^-0.1)<amag) then
   begin
    if (myfegyv=FEGYV_QUAD) then
     csipo:=true;
    playrocks:=1
   end;
  end
  else
   iranyithato:=true;
  if tulnagylokes then iranyithato:=false;
   //PLR fizikája
  {$IFNDEF repkedomod}
  if not iranyithato then
  begin
   cpx^:=cpx^*2-cpox^;
   cpz^:=cpz^*2-cpoz^;
  end;
  {$ELSE}
  if repules or not iranyithato then
  begin
   cpx^:=cpx^*2-cpox^;
   cpz^:=cpz^*2-cpoz^;
  end;
  {$ENDIF}
  cpox^:=ox;cpoy^:=oy;cpoz^:=oz;
  if halal>0 then
  begin cpx^:=cpox^; cpy^:=cpoy^; cpz^:=cpoz^; end;

  {$IFDEF repkedomod}
  if repules then iranyithato:=true;
  {$ENDIF}
  playrocks:=playrocks-0.01;
 // if playrocks>1 then playrocks:=1;
  if playrocks<0 then playrocks:=0;

   laststate:='Doing Real Physics 2';
  //Egyéb plr cucc

  if (cpy^<10) and ((mstat and MSTAT_MASK)>0) then
   vizben:=vizben+0.01
  else
   vizben:=vizben-0.01;

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
  handleparticlesystems;
  handlelabels;

  if multisc.state1v1 and multisc.atrak then         // atrakas 1v1 uzemmodba
  begin
    autoban:=false;
    multisc.atrak:=false;
    remaketerrain;
    cpx^:=portalpos.x;    cpy^:=portalpos.y+1;    cpz^:=portalpos.z;
    cpox^:=cpx^;cpoy^:=cpy^;cpoz^:=cpz^;
  end;

  laststate:='Ragdoll physics';
  inc(rbido);
  if rbszam>-1 then
  rbido:=rbido mod (rbszam+1);
  for i:=0 to rbszam do begin
{
    bubi:=false;
//    if (rongybabak[i].gmbk[0].y<10)  then
      for j:=0 to length(bubbles) do
        with bubbles[j] do
          if false then
            bubi:=true;
                       }
    rongybabak[i].step(advwove,i=rbido, false);
  end;
  i:=0;
  while i<=rbszam do
  begin
   if rongybabak[i].ido >RB_MAX_IDO then
    delrongybaba(i)
   else
    inc(i);
  end;

  cooldown:=cooldown-0.01;

  if (kiszall_cooldown>0) and (not nemlohet) then
  kiszall_cooldown:=kiszall_cooldown-0.01;

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
  if ppl[i].net.amtim<500 then
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
    addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3((cpox^+cpx^)/2,cpy^-0.5,(cpoz^+cpz^)/2),d3dxvector3(-sin(szogx)*0.3,-0.1,-cos(szogx)*0.3),myfegyv,0,0,-1);
  end;
  cooldown:=3;
  kiszall_cooldown:=3;
  autoban:=false;
  kulsonezet:=false;
  kiszallas:=0;
  vanishcar:=1;
  cpy^:=cpy^-1;
  cpoy^:=cpy^;
 end;
 if mszogx>(szogx+pi) then
  mszogx:=mszogx*0.8+(szogx+2*pi)*0.2
 else
 if mszogx<(szogx-pi) then
  mszogx:=mszogx*0.8+(szogx-2*pi)*0.2
 else
  mszogx:=mszogx*0.8+szogx*0.2;

 mszogy:=mszogy*0.8+szogy*0.2;

 if mszogx>D3DX_PI then mszogx:=mszogx-2*D3DX_PI;
 if mszogx<-D3DX_PI then mszogx:=mszogx+2*D3DX_PI;

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

  {$IFDEF panthihogomb}
 if tavpointpointsq(DNSVec,campos)<DNSRad*DNSRad then
 begin
   for j:=0 to 1 do
    addhopehely(30);
 end
 else
 begin
 if felho.coverage<=5 then
 begin
  d3dxvec3subtract(tmp,tegla.vpos,tegla.pos);
  if opt_rain then
  if not (autoban and (d3dxvec3lengthsq(tmp)>sqr(0.2))) then
  for i:=round(felho.coverage) to 5 do
   for j:=0 to 2*opt_particle do
     addesocsepp((i+2)*(10-round(felho.coverage))*2);
 end;
 end;
 {$ELSE}
 if felho.coverage<=5 then
 begin
  d3dxvec3subtract(tmp,tegla.vpos,tegla.pos);
  if opt_rain then
  if not (autoban and (d3dxvec3lengthsq(tmp)>sqr(0.2))) then
  for i:=round(felho.coverage) to 5 do
   for j:=0 to 2*opt_particle do
     addesocsepp((i+2)*(10-round(felho.coverage))*2);
 end;
 {$ENDIF}

 ParticleSystem_Update;

 if myfegyv<128 then
  if not voltspeeder then
   if (autoban and (d3dxvec3lengthsq(tmp)>sqr(0.56))) then
   begin
    multisc.Medal('H','S');
    voltspeeder:=true;
   end;

  if multip2p.medal_prof_count=3 then
        begin
        multisc.Medal('P','S');
        multip2p.medal_prof_count:=0;
        end;

  if multip2p.medal_spd_kills=2 then
      multisc.Medal('M','U');

  if multip2p.medal_spd_kills=4 then
      multisc.Medal('U','L');


  // nézzük a beérkezett medálokat
  if (multisc.medallist[0] <> '') and (menu.medalanimstart=0) then
  begin
    LTFF(g_pd3dDevice, 'data\medal\'+multisc.medallist[0]+'.png',menu.medaltex);
    menu.medalanimstart := GetTickCount;

    multisc.medallist[0]:= multisc.medallist[1];
    multisc.medallist[1]:= multisc.medallist[2];
    multisc.medallist[2]:= '';

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
  lightIntensity := lovok*1.5;
  fastvec3normalize(norm);
  tmp:=noobtoltpos;
  tmp:=D3DXVector3(tmp.x+norm.x*0.3,tmp.y+norm.y*0.3,tmp.z+norm.z*0.3);
 // d3dxvec3scale(norm,-0.01);
  Particlesystem_add(bulletcreate(tmp,noobtoltpos,0.01,20,0.004,weapons[3].col[1],0,false));
  Particlesystem_add(bulletcreate(tmp,noobtoltpos,0.01,20,0.001,weapons[3].col[2],0,false));
 end;



   laststate:='Projectiles';
 for i:=0 to high(noobproj) do
 with noobproj[i] do
 begin
  inc(colltim);
  inc(eletkor);
  tmp:=v1;
     //gyorsuló

  v1.x:=(v1.x-v2.x)*1.0215+v1.x;
  v1.y:=(v1.y-v2.y)*1.0215+v1.y;
  v1.z:=(v1.z-v2.z)*1.0215+v1.z;

  v2:=tmp;

  d3dxvec3subtract(tmp,v1,v2);
  d3dxvec3scale(tmp,tmp,0.5);
  randomplus(tmp,animstat*5+i*2,0.01);
  Particlesystem_add(Fenycsiknoobcreate(v1,v2,randomvec(eletkor/3,0.02),randomvec((eletkor-1)/3,0.02),0.03+0.07*eletkor/100,0.03+0.07*eletkor/100,weapons[3].col[1],0,100));
  if opt_particle > 0 then
    Particlesystem_add(ExpsebparticleCreate(v1,(randomvec(random(50),0.1)),0.2,0.15,0.9,weapons[3].col[1],0,30));
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
                                           0.5,0,$010100*(random(70)+150),$00000000,60));
  end;
 end;

 for i:=0 to high(x72proj) do
 with x72proj[i] do
 begin
  inc(eletkor);
  inc(colltim);
  tmp:=v1;
  v1.x:=(v1.x-v2.x)*0.95+v1.x;
  v1.y:=(v1.y-v2.y)*0.95+v1.y;
  v1.z:=(v1.z-v2.z)*0.95+v1.z;
  v2:=tmp;

  d3dxvec3subtract(tmp,cel,v1);
  d3dxvec3scale(tmp,tmp,0.0002*eletkor*fastinvsqrt(d3dxvec3lengthsq(tmp)));
  d3dxvec3add(v1,v1,tmp);

  if colltim=1 then
  begin
   d3dxvec3subtract(tmp,v1,v2);
   d3dxvec3scale(tmp,tmp,0.8);
   Particlesystem_add(Simpleparticlecreate(v2,
                                          // D3DXVector3Zero,
                                           tmp,
                                           0.3,0,weapons[4].col[6],weapons[4].col[7],30))
  end;
 end;


 for i:=0 to high(h31_gproj) do
 with h31_gproj[i] do
 begin
  inc(eletkor);
  inc(colltim);
  tmp:=v1;

  if eletkor<80 then
  begin
   v1.x:=(v1.x-v2.x)*1.05+v1.x;
   v1.y:=(v1.y-v2.y)*1.05+v1.y;
   v1.z:=(v1.z-v2.z)*1.05+v1.z;
  end
  else
  begin
   v1.x:=(v1.x-v2.x)*1+v1.x;
   v1.y:=(v1.y-v2.y)*1+v1.y;
   v1.z:=(v1.z-v2.z)*1+v1.z;
  end;

  v2:=tmp;
  Particlesystem_add(ExpSebparticlecreate (v1,randomvec(random(100),0.02),0.03,0,0.95,0,$42DD6C,random(100)+50));
  Particlesystem_add(Fenycsiknoobcreate(v1,v2,randomvec(eletkor/3,0.008),randomvec((eletkor-1)/3,0.008),0.01+0.02*eletkor/100,0.01+0.02*eletkor/100,$00D41C,0,20));
 end;



 for i:=0 to high(h31_tproj) do
 with h31_tproj[i] do
 begin
  inc(eletkor);
  inc(colltim);
  tmp:=v1;

  if eletkor<80 then
  begin
   v1.x:=(v1.x-v2.x)*1.05+v1.x;
   v1.y:=(v1.y-v2.y)*1.05+v1.y;
   v1.z:=(v1.z-v2.z)*1.05+v1.z;
  end
  else
  begin
   v1.x:=(v1.x-v2.x)*1+v1.x;
   v1.y:=(v1.y-v2.y)*1+v1.y;
   v1.z:=(v1.z-v2.z)*1+v1.z;
  end;

  v2:=tmp;
  Particlesystem_add(ExpSebparticlecreate (v1,randomvec(random(100),0.02),0.03,0,0.95,0,$42DD6C,random(100)+50));
  Particlesystem_add(Fenycsiknoobcreate(v1,v2,randomvec(eletkor/3,0.008),randomvec((eletkor-1)/3,0.008),0.01+0.02*eletkor/100,0.01+0.02*eletkor/100,$00D41C,0,20));
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

 if hatralok>0 then
  hatralok:=hatralok-0.005
 else
  hatralok:=0;

  for i:=0 to high(ppl) do
   if ppl[i].pls.lottram>0 then dec(ppl[i].pls.lottram);

 if invulntim<>0 then
 begin
   dec(invulntim);
   if invulntim=0 then
     showHudInfo('',0,0);
 end;
// if latszonaKL>0 then dec(latszonaKL);

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
//     v1:=pos;
     v1:=D3DXVector3( pos.x+ seb.x*mtim, pos.y+ seb.y*mtim, pos.z+ seb.z*mtim);
     v2:=D3DXVector3(vpos.x+vseb.x*mtim,vpos.y+vseb.y*mtim,vpos.z+vseb.z*mtim);
     D3DXVec3lerp(megjpos,v2,v1,min(mtim/vtim,1));
    end
    else
     megjpos:=D3DXVector3Zero;

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
      AddNOOB(kivec,d3dxvector3(kivec.x-0.2,kivec.y+(random(200)-100)*0.01*0.02,kivec.z+(random(200)-100)*0.01*0.05),-1);
    end;
   end;
  end;

  if portalevent<> nil then
  portalevent.Step;

  for i:=high(posokvoltak)-1 downto 0  do
    posokvoltak[i+1]:=posokvoltak[i];
  posokvoltak[0]:=D3DXVector3(cpx^,cpy^,cpz^);

    mapbol:=mapbol xor dine.keyd2(DIK_M);
  if mapbol then
  begin
   if mapmode<1 then mapmode:=mapmode*1.1+0.0005 else mapmode:=1;
   csipo:=true;
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

  if opt_taunts and tauntvolt then
   begin
   if myfegyv>127 then
   begin

    case multisc.kills-multisc.killswithoutdeath of
      2:i:=12+0;
      5:i:=12+1;
      8:i:=12+2;
     11:i:=12+3;
     14:i:=12+4;
     29:i:=12+5;
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
      2:i:=32+0;
      5:i:=32+1;
      8:i:=32+2;
     11:i:=32+3;
     14:i:=32+4;
     29:i:=32+5;
    else
     i:=20+random(11);
    end;

    PlayStrm(18+0,123,-400,true);
    PlayStrm(   i,123,-400);
    PlayStrm(18+1,123,-400);
   end;
   tauntvolt:=false;
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
      1:multisc.Medal('F','1');
      2:multisc.Medal('F','2');
      3:multisc.Medal('F','3');
      4:multisc.Medal('F','4');
     end;
     voltflip:=flipcount;
    end;
   end
   else
    if tegla.axes[2].y<-0.2 then
     flipbol:=true;
  end;
  if (multisc.state1v1) then zeneintensity:=10000;
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

  //if opt_imposters then
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
  for j:=0 to 2*opt_particle do
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

   //if opt_imposters then
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
 if not nofegyv then
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
const
 killcnt:array [1..9] of integer =(10,30,90,250,750,2000,5000,10000,30000);
var
 i:integer;
begin
  multisc.Update(round(cpx^),round(cpy^));
  if halal>0 then
   multip2p.Update(0,0,0,0,0,0,0,0,0,campos,false,not tegla.disabled,tegla.pos,tegla.vpos,tegla.axes,tegla.fordulatszam) //a tegla.pos minek?
  else
   multip2p.Update(cpx^,cpy^,cpz^,cpox^,cpoy^,cpoz^,szogx,szogy,mstat,campos,autoban,not tegla.disabled,tegla.pos,tegla.vpos,tegla.axes,tegla.fordulatszam);

  if multisc.kicked<>'' then
  begin
   gobacktomenu:=true;
   kickmsg:=multisc.kicked;
   hardkick:=multisc.kickedhard;
  end;

  if multisc.weather<>felho.coverage then
  begin
   felho.coverage:=multisc.weather;
   felho.makenew;
  end;

 case multisc.kills-multisc.killswithoutdeath of
   3:multisc.Medal('W','1');
   6:multisc.Medal('W','2');
   9:multisc.Medal('W','3');
  12:multisc.Medal('W','4');
  15:multisc.Medal('W','5');
  30:multisc.Medal('W','6');
 end;

 case multisc.kills-multisc.killscamping of
   3:multisc.Medal('C','1');
   6:multisc.Medal('C','2');
   9:multisc.Medal('C','3');
  15:multisc.Medal('C','4');
 end;

 for i:=1 to 9 do
  if multisc.kills>=killcnt[i] then
   multisc.Medal('K',inttostr(i)[1]);

 if multisc.doevent<>'' then
 begin
  if multisc.doevent='spaceship' then
  begin
   if currevent<>nil then
    if not (currevent is TSpaceshipEvent) then
    begin
     currevent.Free;
     currevent:=nil;
    end;

   if currevent=nil then
    currevent:=TSpaceshipEvent.Create(g_pd3ddevice,true,'data\event\');
  end;

  //if portalevent<>nil then
  // portalevent.Phase(multisc.doeventphase);

  if multisc.doevent='portal' then
  portalevent.phs:=1;

  if multisc.doevent='disablekill' then
  disablekill := true;

  if multisc.doevent='enablekill' then
  disablekill := false;



  multisc.doevent:='';
 end;
end;

procedure handleMMOcars;
var
i:integer;
pos1,pos2:TD3DXvector3;
begin
 while high(ppl)>high(tobbiekautoi) do
 begin
  setlength(tobbiekautoi,length(tobbiekautoi)+1);
  tobbiekautoi[high(tobbiekautoi)]:=Tauto.create(
                        d3dxvector3(stuffjson.GetFloat(['vehicle','gun','scale','x']),0,0),
                        d3dxvector3(0,0,-stuffjson.GetFloat(['vehicle','gun','scale','z'])),
                        d3dxvector3(0,-stuffjson.GetFloat(['vehicle','gun','scale','y']),0),
                        d3dxvector3zero,
                        d3dxvector3zero,
                        stuffjson.GetFloat(['vehicle','gun','friction']),
                        0.5,
                        hummkerekarr,
                        stuffjson.GetFloat(['vehicle','gun','suspension','length']),
                        stuffjson.GetFloat(['vehicle','gun','suspension','strength']),
                        stuffjson.GetFloat(['vehicle','gun','suspension','absorb']),
                        stuffjson.GetFloat(['vehicle','gun','wheels','radius']),
                        stuffjson.GetFloat(['vehicle','gun','wheels','width']),
                        stuffjson.GetFloat(['vehicle','gun','wheels','friction']),
                        0,0,
                        false);
 end; 
 for i:=0 to high(ppl) do
 with tobbiekautoi[i] do
 begin

  if ppl[i].net.avtim=0 then ppl[i].net.avtim:=10;
  disabled:=not ppl[i].auto.enabled;

  if disabled then continue;
  d3dxvec3lerp(axes[0],ppl[i].auto.vaxes[0],ppl[i].auto.axes[0],min(ppl[i].net.amtim/ppl[i].net.avtim,1));
  d3dxvec3lerp(axes[1],ppl[i].auto.vaxes[1],ppl[i].auto.axes[1],min(ppl[i].net.amtim/ppl[i].net.avtim,1));
  d3dxvec3lerp(axes[2],ppl[i].auto.vaxes[2],ppl[i].auto.axes[2],min(ppl[i].net.amtim/ppl[i].net.avtim,1));

  fordulatszam:=ppl[i].auto.fordszam;

  d3dxvec3scale(pos1,ppl[i].auto.seb,ppl[i].net.amtim);
  d3dxvec3add(pos1,pos1,ppl[i].auto.pos);
  d3dxvec3scale(pos2,ppl[i].auto.vseb,(ppl[i].net.amtim+ppl[i].net.vamtim));
  d3dxvec3add(pos2,pos2,ppl[i].auto.vpos);

  d3dxvec3lerp(pos,pos2,pos1,min((ppl[i].net.amtim)/ppl[i].net.avtim,1));
  d3dxvec3subtract(vpos,pos,ppl[i].auto.seb);
  
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
sndnum:integer;
id:cardinal;
abuft:byte;
hol,tmp:TD3DXVector3;
tt,spd:single;
sorrend:array [0..2] of shortint;
sortav:array [0..2] of single;
begin
 laststate:='HandleDS';
 hol:=campos;
 if gugg then hol.y:=hol.y-0.5;
  PlaceListener(hol,szogx,szogy);

 if ((mstat and  MSTAT_MASK)>0) and (halal=0) then
 begin

  sndnum := 1;
  if walkmaterial = MAT_METAL then sndnum := 37;
  if walkmaterial = MAT_WOOD then sndnum := 38;

  playsound(sndnum,false,25,true,D3DXvector3(cpx^,cpy^,cpz^)) ;

  if (mstat and MSTAT_MASK)=(MSTAT_FUT) then setSoundProperties(sndnum,25,0,1.81,true,D3DXVector3Zero)//beta
  else
  if (mstat and MSTAT_GUGGOL)>0 then SetSoundProperties(sndnum,25,-2000,0.73,true,D3DXVector3Zero)
  else
  SetSoundProperties(sndnum,25,-1000,1,true,D3DXVector3Zero)
 end
 else
 begin
 stopsound(1,25);
 stopsound(37,25);
 stopsound(38,25);
 end;

 if myfegyv=FEGYV_NOOB then
  if lovok>0 then
  begin
   playsound(15,false,25,true,D3DXvector3(cpx^,cpy^,cpz^)) ;
   SetSoundProperties(15,25,0,4.535*lovok,true,D3DXVector3Zero);
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
   if (ppl[sorrend[i]].pos.state and MSTAT_MASK)=(MSTAT_FUT) then SetSoundProperties(1,id,0,1.81,true,D3DXVector3Zero)
   else
    if (ppl[sorrend[i]].pos.state and MSTAT_GUGGOL)>0 then SetSoundProperties(1,id,-2000,0.73,true,D3DXVector3Zero)
    else
     SetSoundProperties(1,id,-1000,1,true,D3DXVector3Zero)
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
  setsoundproperties(15,i,0,1.81,false,d3dxvector3zero);
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
  if (sorrend[i]>=0) and not gobacktomenu then
  begin
   playsound(8,false,i,false,tobbiekautoi[sorrend[i]].pos);
   spd:=tavpointpoint(tobbiekautoi[sorrend[i]].pos,tobbiekautoi[sorrend[i]].vpos);
    SetSoundProperties(8,i,1,(tobbiekautoi[i].fordulatszam*0.22+0.5)*0.68,true,D3DXVector3Zero);
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
  if (sorrend[i]>=0) and not gobacktomenu then
  begin
   playsound(7,false,i,false,tobbiekautoi[sorrend[i]].pos);
    SetSoundProperties(7,i,0,(0.3+min(tavpointpoint(tobbiekautoi[sorrend[i]].pos,tobbiekautoi[sorrend[i]].vpos),0.25))*1.36,true,D3DXVector3Zero);
  end
   else
    StopSound(7,i);
 end;

 //Player mozgás

 if (playrocks>0) and (halal=0) then
 begin
  playsound(2,false,25,true,D3DXvector3(cpx^,cpy^,cpz^));
  SetSoundProperties(2,25,round(-2000*(1-playrocks)),playrocks,true,D3DXVector3Zero)
 end
 else
   StopSound(2,25);

 if ((vizben>0) and (not nemviz)) and (halal=0)  then
 begin
  playsound(3,false,25,true,D3DXvector3(cpx^,cpy^,cpz^));
  SetSoundProperties(3,25,round(-2000*(1.7-vizben)),1+(vizben/10),true,D3DXVector3Zero)
 end
 else
   StopSound(3,25);

 if myfegyv<128 then abuft:=8 else abuft:=7;

 if not tegla.disabled then
 begin
  playsound(abuft,true,125,true,tegla.pos);
  SetSoundProperties(abuft,125,round(tegla.pillspd),(tegla.fordulatszam*0.22+0.5)*0.68,true,D3DXVector3Zero);
  //round((0.3+min(tavpointpoint(tegla.pos,tegla.vpos),0.25))*50000)
 end
 else
  StopSound(abuft,125);

 StopSound(15-abuft,125);

 {$IFDEF panthihogomb}
 if felho.coverage<2 then
 {$ELSE}
 if felho.coverage<=5 then
 {$ENDIF}
 begin
  playsound(12,true,125,true,D3DXVector3Zero);
  SetSoundProperties(12,125,round(-1200-felho.coverage*400),1,true,D3DXVector3Zero);
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
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/3, ASPECT_RATIO, 0.05, 2000.0);
  g_pd3dDevice.SetTransform(D3DTS_PROJECTION, matProj);
end;

procedure setupprojmat;
begin
 D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/3, ASPECT_RATIO, 0.05, 1100.0);
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
      veyept:=ojjektumarr[j].raytest(vlookatpt,veyept,i,COLLISION_SOLID);
      
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
   D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/16, ASPECT_RATIO, 0.1, 1100.0);
   frust:=frustum(matview,0.1,1100,D3DX_PI/16, ASPECT_RATIO);
  end
  else
  begin
   D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/3, ASPECT_RATIO, 0.05, 1100.0);
   frust:=frustum(matview,0.1,1100,D3DX_PI/3, ASPECT_RATIO);
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
 if (cpy^>8) then
 g_pd3dDevice.SetRenderState(D3DRS_FOGCOLOR,
               colorlerp(color_rainy,color_sunny,fogc))
               else
 g_pd3dDevice.SetRenderState(D3DRS_FOGCOLOR, $FF4ca3ff) ;

  g_pd3dDevice.SetRenderState(D3DRS_RANGEFOGENABLE,itrue);
  g_pd3dDevice.SetRenderState(D3DRS_FOGVERTEXMODE,D3DFOG_LINEAR);

 fogstart:=0;
 fogend:=900;

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



  if cpy^>-50 then felho.render(cpy^>50);
 // felho.render(false);
 g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
 g_pd3dDevice.SetRenderState(D3DRS_ZFUNC, D3DCMP_LESSEQUAL);
  g_pd3dDevice.SetRenderState(D3DRS_ZWRITEENABLE, iTrue);
  g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iTrue);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_MODULATE);
   // And some fog

  g_pd3dDevice.SetRenderState(D3DRS_FOGENABLE,itrue);
  fogstart:=0;
  fogend:=lerp(radius_rainy,radius_sunny,fogc);
  if (cpy^<8.95+singtc/10) then fogend:=90;

 if mapmode>0 then
 begin
  fogend:=fogend+mapmode*1000;
 end;

  g_pd3dDevice.SetRenderState(D3DRS_FOGSTART,singletodword(FogStart));
  g_pd3dDevice.SetRenderState(D3DRS_FOGEND,singletodword(FogEnd));


end;


function sikmetsz(honnan,hova:TD3DXVector3;magassag:single):TD3DXVector3;
var
arany:single;
begin
if (min(honnan.y,hova.y)>magassag) or ((max(honnan.y,hova.y)<magassag) or (honnan.y = hova.y)) then
result:=d3dxvector3(0,0,0)
else
begin
arany:=abs(magassag-honnan.y);
arany:=arany/abs(honnan.y-hova.y);
result:= d3dxvector3(arany*(hova.x)+(1-arany)*honnan.x,magassag,arany*(hova.z)+(1-arany)*honnan.z);
end;
end;



procedure Handlelovesek;
var
i,j,love:integer;
aloves:Tloves;
tmp,tmp2:TD3DXVector3;
dst:single;
atc:cardinal;
gtc:cardinal;
snd:byte;
fsettings:TFormatSettings;
begin
 SetupMyMuksmatr;
 gtc:=timegettime;
 for i:=0 to high(multip2p.lovesek) do
 begin
  aloves:=multip2p.lovesek[i];
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
   FEGYV_M4A1,FEGYV_M82A1,FEGYV_MP5A3: begin
   Particlesystem_add(Bulletcreate(aloves.pos,aloves.v2,3,20,0.01,$00A0A050,1,false));
     tmp := sikmetsz(aloves.pos,aloves.v2,10);
  if tmp.y<>0 then
  begin
  for j:=0 to 6*opt_particle do
    ParticleSystem_Add(Gravityparticlecreate(tmp,d3dxvector3(-0.0167+random(10)/300,0.06+random(10)/270,-0.0167+random(10)/300),0.3,0.05,0.09,weapons[5].col[0],weapons[5].col[1],100));
  end;

  if (opt_particle>=1) then
  begin
  d3dxvec3subtract(tmp2,aloves.pos,aloves.v2);
  D3DXVec3Normalize(tmp2,tmp2);
  D3DXVec3Scale(tmp2,tmp2,0.10);
  ParticleSystem_Add(Coolingparticlecreate(aloves.v2,tmp2,0.03,0.24,0.05,weapons[6].col[0]+random(32)*$010101,$00000000,20));
  end;

  end;
   FEGYV_MPG:begin
   particle_special_mpg(aloves.pos,aloves.v2);
   ParticleSystem_Add(Simpleparticlecreate(aloves.v2,d3dxvector3(0,0,0),0.14,0.01,weapons[1].col[1],$00000000,125));
   end;
   FEGYV_QUAD:begin
   particle_special_quad(aloves.pos,aloves.v2);
   ParticleSystem_Add(Simpleparticlecreate(aloves.v2,d3dxvector3(0,0,0),0.14,0,weapons[2].col[6],weapons[2].col[6],125));
   end;
   FEGYV_LAW:AddLAW(aloves.pos,aloves.v2,aloves.kilotte);
   FEGYV_NOOB:AddNOOB(aloves.pos,aloves.v2,aloves.kilotte);
   FEGYV_X72:AddX72(aloves.pos,aloves.v2,aloves.kilotte);

   FEGYV_H31_T:AddH31_T(aloves.pos,aloves.v2,aloves.kilotte);
   FEGYV_H31_G:AddH31_G(aloves.pos,aloves.v2,aloves.kilotte);

   //Particlesystem_add(MPGcreate(aloves.pos,aloves.v2,1.5,$0000A0FF));
  end;

  if coordsniper then
  begin
  for j:=high(multisc.chats) downto 3 do
   multisc.chats[j]:=multisc.chats[j-3];
   GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT,fsettings);
   fsettings.DecimalSeparator:='.';
   multisc.chats[0].uzenet:='Coords: (' + IntToStr(random(1000)) + ')';
   multisc.chats[1].uzenet:='x: '+FloatToStrF(aloves.v2.x,ffFixed,7,2,fsettings)+
           '  y: '+FloatToStrF(aloves.v2.y,ffFixed,7,2,fsettings)+
           '  z: '+FloatToStrF(aloves.v2.z,ffFixed,7,2,fsettings);
   multisc.chats[2].uzenet:='angleH: '+FloatToStrF(szogx,ffFixed,7,2,fsettings)+
           '  angleV: '+FloatToStrF(szogy,ffFixed,7,2,fsettings);
           
   multisc.chats[0].glyph:=0;
   multisc.chats[1].glyph:=0;
   multisc.chats[2].glyph:=0;
   writeln(logfile,multisc.chats[0].uzenet,' ',multisc.chats[1].uzenet,' ',multisc.chats[2].uzenet);
   coordsniper :=false;
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

   FEGYV_H31_T:playsound(39,false,gtc,true,aloves.pos);
   FEGYV_H31_G:playsound(39,false,gtc,true,aloves.pos);
   else
    playsound(0,false,gtc,true,aloves.pos);
  end;
                                             
  if ((aloves.fegyv=FEGYV_M4A1) or (aloves.fegyv=FEGYV_M82A1)
   or (aloves.fegyv=FEGYV_QUAD) or (aloves.fegyv=FEGYV_MPG))
     and ((myfegyv xor aloves.fegyv)>=128) then
  begin
   //vEyePt:= D3DXVector3(cpx^, cpy^+1.5,cpz^);
   atc:=integer(timegettime)+random(2000);
   //if gugg then veyept.y:=veyept.y-0.5;
   if tavpointlinesq(campos,aloves.pos,aloves.v2,tmp,dst) then
   if dst<25 then
   begin
    if aloves.fegyv>127 then snd:=27 else snd:=14;
    playsound(snd,false,atc,true,tmp);
    SetSoundProperties(snd,atc,1,0.34+(random(22)/100),true,tmp);
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

   //balance
  if (aloves.fegyv>=128) xor (myfegyv<128) then love:=-1 else
  case aloves.fegyv of
   FEGYV_M4A1:love:=meglove(muks.gmbk,muks.kapcsk,aloves.pos,aloves.v2,0.033);
   FEGYV_M82A1:love:=meglove(muks.gmbk,muks.kapcsk,aloves.pos,aloves.v2,0.065);
   FEGYV_MPG: love:=meglove(muks.gmbk,muks.kapcsk,aloves.pos,aloves.v2,0.15);
   FEGYV_QUAD: love:=meglove(muks.gmbk,muks.kapcsk,aloves.pos,aloves.v2,0.16);
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

  if (aloves.fegyv<>FEGYV_LAW) and (aloves.fegyv<>FEGYV_NOOB) and (aloves.fegyv<>FEGYV_X72)
  and (aloves.fegyv<>FEGYV_H31_T) and (aloves.fegyv<>FEGYV_H31_G) then
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
   if (aloves.fegyv=FEGYV_H31_T) or (aloves.fegyv=FEGYV_H31_G) then
   addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),tmp,myfegyv,love,0,aloves.kilotte,true)
   else
   addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),tmp,myfegyv,love,0,aloves.kilotte);
   addHudMessage(lang[65]+' '+ppl[aloves.kilotte].pls.nev,betuszin);
   meghaltam:= true;
  end;
  {$ENDIF}
    {$ENDIF}
   {$ENDIF}
 end;
 
 setlength(multip2p.lovesek,0);
end;

procedure handledoglodesek;
var
  matWorld,matWorld2: TD3DMatrix;
//  pos:TD3DVector;
  i:integer;
begin
 for i:=0 to high(multip2p.hullak) do
 with multip2p.hullak[i] do
 begin
  if enlottemle then
  begin
   tauntvolt:=true;
   addHudMessage(lang[59]+ppl[index].pls.nev+lang[60],$FF0000);
   hudMessages[low(hudMessages)].fade:=200;
   if multisc.state1v1 then halal:=1;
  end;

  D3DXMatrixRotationY(matWorld2,irany+d3dx_pi);
  D3DXMatrixTranslation(matWorld,apos.x,apos.y,apos.z);
  D3DXMatrixMultiply(matWorld,matWorld2,matWorld);
  mat_world:=matworld;

  muks.jkez:=fegyv.jkez(ppl[index].pls.fegyv,state);
  muks.bkez:=fegyv.bkez(ppl[index].pls.fegyv,state);

     case state and MSTAT_MASK of
      0:muks.stand((state and MSTAT_GUGGOL)>0);
      1:muks.Walk(animstate,(state and MSTAT_GUGGOL)>0);
      2:muks.Walk(1-animstate,(state and MSTAT_GUGGOL)>0);
      3:muks.SideWalk(animstate,(state and MSTAT_GUGGOL)>0);
      4:muks.SideWalk(1-animstate,(state and MSTAT_GUGGOL)>0);
      5:muks.Runn(animstate,true);
     end;
  addrongybaba(apos,vpos,gmbvec,ppl[index].pls.fegyv,mlgmb,random(20000)+1,-1);
 end;
 setlength(multip2p.hullak,0);
end;


function vizvertex(xp,zp:single):TCustomvertex;
begin
 result:=CustomVertex(cpx^+xp*1500,10.1+singtc/10,cpz^+zp*1500,0,1,0,$7F7F7F7F,(cpx^+xp*1500)/3+singtc,(cpz^+zp*1500)/3+cosgtc+plsgtc,(cpx^+xp*1500)/6-singtc/3+plsgtc/3,(cpz^+zp*1500)/6-cosgtc/3);
end;

function ujvizvertex(xp,zp:single):TCustomvertex;
begin
 result:=CustomVertex(cpx^+xp*1500,10.1+singtc/10,cpz^+zp*1500,0,1,0,$7F7F7F7F,(cpx^+xp*1500)/3,(cpz^+zp*1500)/3,(cpx^+xp*1500)/6,(cpz^+zp*1500)/6);
end;

procedure renderviz;
var
viz:array [0..9] of TCustomVertex;
tmplw:longword;
matViewProj,matKorr,matkorr2:TD3DMatrix;
begin
 g_pd3dDevice.SetRenderState(D3DRS_FOGENABLE,itrue);
 if not( (G_peffect<>nil) and (opt_water>0) )then
     g_pd3ddevice.SetRenderState(D3DRS_ZWRITEENABLE,itrue);
 if ((cpy^<40) or (opt_water>0)) and (mapmode=0) then
 begin
 singtc:=sin((volttim mod 15000)*D3DX_PI*2/15000);
 cosgtc:=cos((volttim mod 15000)*D3DX_PI*2/15000);
 plsgtc:=(volttim mod 20000)/20000;
 end;


    viz[0]:=vizvertex(0,0);
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


      //}
      //{

 if (G_peffect<>nil) and (opt_water>0) and (cpy^>8.5) then
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


    end
    else
    begin
      g_pd3ddevice.drawprimitiveUP(D3DPT_TRIANGLEFAN,8,viz,sizeof(TCustomvertex));
    end;


         
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
 g_pd3ddevice.SetRenderState(D3DRS_ALPHABLENDENABLE,itrue);
 g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE,itrue);
 g_pd3ddevice.SetRenderState(D3DRS_ZWRITEENABLE,ifalse);
end;

procedure Setupbubbmat(mit:integer);
var
 vp:TD3DXVector3;
 mat,matRot:TD3DMatrix;
begin
 vp.x:=-bubbles[mit].posx;
 vp.y:=-bubbles[mit].posy;
 vp.z:=-bubbles[mit].posz;
 D3DXMatrixTranslation(matRot,vp.x,vp.y,vp.z);
 D3DXMatrixMultiply(mat, mat, matRot);

 g_pd3ddevice.SetTransform(D3DTS_WORLD,mat);
end;

procedure renderBubbles;
var
i:integer;
begin
 g_pd3dDevice.SetRenderState(D3DRS_FOGENABLE,itrue);

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP , D3DTOP_SELECTARG1 );
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_DIFFUSE);
    g_pd3dDevice.SetTexture(0,nil);
    g_pd3dDevice.SetRenderState(D3DRS_FOGENABLE , iFalse);
    g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iTrue);
    g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $303030);


 for i:=0 to high(bubbles) do
 with bubbles[i] do  begin
    mat_world:=identmatr;
    mat_world._11:=bubbles[i].rad;
    mat_world._22:=bubbles[i].rad;
    mat_world._33:=bubbles[i].rad;
    mat_world._41:=bubbles[i].posx;
    mat_world._42:=bubbles[i].posy;
    mat_world._43:=bubbles[i].posz;
    g_pd3dDevice.SetTransform(D3DTS_WORLD, mat_World);
  gomb.DrawSubset(0);
 end;
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



{$IFDEF matieditor}

procedure matieditor;
var
closestojj,i,j:integer;
mindist,dist:single;
me_tex:TOjjektumTexture;
begin
 mindist := 100;
 for i:=0 to high(ojjektumarr) do
    for j:=0 to ojjektumarr[i].hvszam do
      begin
      dist := tavPointPoint(D3DXVector3(cpx^,cpy^,cpz^),ojjektumarr[i].holvannak[j]);
      if dist<mindist then
        begin
        mindist := dist;
        me_id := i;
        debugstr := ojjektumarr[i].filenev;
        end;
      end;



end;

{$ENDIF}




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
mag:single;
bol:boolean;
wo:TD3DMatrix;
txt,temp:string;
mit:string;
sunhol:TD3DXVector3;
mv2:TD3DMatrix;
meret:single;
k1,k2:single;
aszin:cardinal;
cghash:cardinal;
bszvolt:cardinal;
szcol:cardinal;
arect:Trect;
killtmutat:boolean;
rendezve:array of integer;
rtmp:integer;
glph:array of Tglyph;
isTyping:array of boolean;
terkep1:TD3DXVector2;
terszog,tertav:single;
kisTAB:integer;
menuszor:single;
chatszam:integer;
tabsort,tabsorg:integer;
cursor:string;
const
menuplus=0.2;

label
nosun;
begin
 hudMessagePosY:=0.2;
 vipo:=avp;
 vipo.Width:=SCwidth;
 vipo.Height:=SCheight;
 if (myfegyv=FEGYV_M82A1) and (not csipo) and (halal=0) then
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/16, ASPECT_RATIO, 0.1, 1000.0)
 else
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/3, ASPECT_RATIO, 0.1, 1000.0);
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
     bol:=bol or ojjektumarr[i].raytestbol(vec,camvec,J,COLLISION_SHADOW);
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
    if cpy^<100 then meret:=0.1;
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
    if (cpy^>0) then
    menu.g_pSprite.Draw(suntex,nil,nil,@sunhol,$FFFFFFFF)
    else
    menu.g_pSprite.Draw(suntex,nil,nil,@sunhol,$FFDDEEFF);

  nosun:
  //d3dxmatrixidentity(mv2);
  menu.g_pSprite.SetTransform(identmatr);

  if (portalevent<>nil) and (portalevent.vege) then begin
  vegeffekt := vegeffekt+1;
  menu.DrawRect(0.0,0.0,1.0,1.0,$01000000*cardinal(min(vegeffekt,255))+$00FFFFFF);
  end;

  if vegeffekt>256 then begin
  menu.g_psprite.Flush;
  menu.g_psprite.SetTransform(identmatr);
  menu.DrawText('Stickman Atlantis: Egy elveszett város  Letölthetõ a honlapról!',
                      0.1,0.4,0.9,0.8,1,$02000000*cardinal(min(vegeffekt-256,127))+$000066FF);
  nohud:=true;
  end;

  if vegeffekt>750 then begin
     gobacktomenu:=true;
    kickmsg:='Stickman Atlantis: Egy elveszett város  Letölthetõ a honlapról!';
    hardkick:=true;
  end;




  aszin:=$FF;

 if length(chatmost)>0 then
 begin
 if GetTickCount mod 1000 >500 then cursor:='_' else cursor:='';
  if Copy(chatmost,1,4)=' /c ' then
   menu.DrawSzinesChat(lang[36]+':'+Copy(chatmost,5,Length(chatmost))+cursor ,0,0.03,0.4,0.3,$FF00FF00)
  else
  if Copy(chatmost,1,4)=' /r ' then
   menu.DrawSzinesChat(lang[38]+':'+Copy(chatmost,5,Length(chatmost))+cursor ,0,0.03,0.4,0.3,$FFFF00FF)
  else
  if (Copy(chatmost,1,4)=' /w ') and (pos(' ',Copy(chatmost,5,Length(chatmost)))>0) then
  begin
   rtmp:=pos(' ',Copy(chatmost,5,Length(chatmost)));
   menu.DrawSzinesChat(lang[37]+'('+Copy(chatmost,5,rtmp-1)+'):'+Copy(chatmost,rtmp+4,Length(chatmost))+cursor ,0,0.03,0.4,0.3,$FFFF00FF)
  end
  else
   menu.DrawSzinesChat('Chat:'+chatmost+cursor ,0,0.03,0.4,0.3,$FF000000+aszin);
 end;



 if (length(chatmost)<=0) then
 begin
 if not nohud then
  for i:=0 to 7 do
  begin
    if (multisc.chats[i].glyph<>0) then begin
     //cghash:=(((13)*16+12)*16+14)*16+15   {szin}+29*65536
     menu.DrawChatGlyph(multisc.chats[i].glyph,0.005,0.06+(i)*0.022,$1F*cardinal(8-i));
     menu.DrawSzinesChat(multisc.chats[i].uzenet,0.015,0.05+(i)*0.022,0.4,0.2+(i)*0.02,$1F000000*cardinal(8-i)+aszin);
      end
   else
     menu.DrawSzinesChat(multisc.chats[i].uzenet,0.015,0.05+(i)*0.022,0.4,0.2+(i)*0.02,$1F000000*cardinal(8-i)+aszin);
  end;
 end
 else
 begin
  for i:=0 to 23 do
 begin
  if (multisc.chats[i].glyph<>0) then begin
   menu.DrawChatGlyph(multisc.chats[i].glyph,0.005,0.06+(i)*0.022,$FF);
   menu.DrawSzinesChat(multisc.chats[i].uzenet,0.015,0.05+(i)*0.022,0.4,0.2+(i)*0.02,$FF000000+aszin);
     end
  else
   menu.DrawSzinesChat(multisc.chats[i].uzenet,0.015,0.05+(i)*0.022,0.4,0.2+(i)*0.02,$FF000000+aszin);
 end;
 end;


  if nohud then
  exit;

 setlength(ar,length(ppl));
 setlength(ap,length(ppl));
 setlength(ap2,length(ppl));
 setlength(aa,length(ppl));
 setlength(ac,length(ppl));
 setlength(isTyping,length(ppl));


 // emberek fej feletti nevei
 // és chatbubi

 for i:=0 to high(ppl) do
 begin
  ar[i]:='';
  ac[i]:='';
  if (ppl[i].pos.pos.y<0.1) or ppl[i].pls.autoban then
   if (not ppl[i].auto.enabled) then
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
    //if ppl[i].pos.megjpos.y<10 then continue;
    ap[i]:=D3DXVector3(1,1,2);
    ap2[i]:=ap[i];
    continue;
   end;
    bol:=true;
 { if (vec.y<10) then
  begin
   bol:=false;
   vec:=D3DXVector3(0,100,0);
  end;
 }
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

  isTyping[i]:= (tavpointpointsq(ppl[i].pos.pos,camvec)<sqr(25)) and (ppl[i].pos.state=MSTAT_CHAT);


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
  menu.DrawTextsInGame(ar,ap,ap2,aa,false,isTyping);
 //menu.drawrect(0.0,0.0,0.2,0.25,$A0000000);

 setlength(glph,2);
 glph[0].melyik:=1;
 glph[0].x:=(SCwidth-(SCwidth/10.91)-(4/3)*31+(ASPECT_RATIO)*31);
 glph[0].y:=(SCheight/8);

 glph[1].melyik:=0;
 glph[1].x:=(SCwidth-(SCwidth/10.91))+cos(-szogx)*(SCheight/8.57)*(4/3)/(ASPECT_RATIO)-(4/3)*31+(ASPECT_RATIO)*31;
 glph[1].y:=(SCheight/8)+sin(-szogx)*(SCheight/8.57);


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
   glph[high(glph)].x:=(SCwidth-(SCwidth/10.91))+cos(terszog-szogx)*tertav*(SCheight/8.57)*(4/3)/(ASPECT_RATIO)-(4/3)*31+(ASPECT_RATIO)*31;
   glph[high(glph)].y:=(SCheight/8)+sin(terszog-szogx)*tertav*(SCheight/8.57);
   if mapmode=1 then
   begin
   glph[high(glph)].melyik:=2;
   glph[high(glph)].x:=(SCwidth/2)-1.15*(ppl[i].pos.megjpos.z-cpz^)*(4/3)/(ASPECT_RATIO)-(4/3)*31+(ASPECT_RATIO)*31;
   glph[high(glph)].y:=(SCheight/2)-1.15*(ppl[i].pos.megjpos.x-cpx^);
   
  end;
 end;

 //solving redtext

 if multisc.redtext<>'' then
 begin
  addHudMessage(multisc.redtext,$FF0000);
  hudMessages[low(hudMessages)].fade:=500;
  multisc.redtext := '';
 end;


 menu.g_pSprite.SetTransform(identmatr);
 if opt_radar then
 menu.DrawGlyphsInGame(glph);

 if menu.medalanimstart>0 then menu.DrawMedal;

 txt:=#17#32+lang[33]+servername+':';
 if multisc.playersonserver<=0 then txt:=txt+lang[34]
 else
 txt:=txt+inttostr(multisc.playersonserver);

 techsz:=0;gunsz:=0;
 for i:=0 to high(ppl) do
 begin
  if ppl[i].net.connected then
  if ppl[i].pls.fegyv>=128 then inc(techsz) else inc(gunsz)
 end;

 if myfegyv>=128 then inc(techsz) else inc(gunsz);

 txt:=txt+' : '#17#236+inttostr(gunsz)+#17#32' / '#17#75+inttostr(techsz)+#17#32;

 txt:=txt+' / '#17#128+inttostr(length(ppl)-gunsz-techsz)+#17#32;
 menu.DrawSzinesChat(txt,0,0,0.4,0.05,$FF000000+betuszin);
 mag:=0.23;
 if not opt_radar then mag:=0;
 txt:=formatdatetime('hh:nn',time);
  menu.DrawSzinesChat(txt,0.9-(4/3)*0.02+(ASPECT_RATIO)*0.02,mag+0.025,1,0.27,$FF000000+betuszin);

 txt:=lastzone;
 menu.DrawSzinesChat(txt,0.86,mag+0.05,1,0.29,$FF000000+betuszin);

 //txt:=FloatToStr(szogx);
 //menu.DrawSzinesChat(txt,0.66,mag+0.05,1,0.29,$FF000000+betuszin);

 //txt:=FloatToStr(szogy);
 //menu.DrawSzinesChat(txt,0.3,mag+0.05,1,0.29,$FF000000+betuszin);

 txt:=#17#128+inttostr(zonaellen)+#17#32+' / '+inttostr(zonabarat);   //ellenségek és barátok száma
 menu.DrawSzinesChat(txt,0.9,mag+0.075,1,0.31,$FF000000+betuszin);



 if multisc.kills>0 then
  if multisc.kills>1 then
   txt:=inttostr(multisc.kills)+lang[42]
  else
   txt:=lang[43]
 else
  txt:='';
  menu.DrawSzinesChat(txt,0.9,0.33,1,0.35,$FF000000+betuszin);


 if multisc.kills-multisc.killswithoutdeath>1 then
  txt:=inttostr(multisc.kills-multisc.killswithoutdeath)+lang[44]
 else
  txt:='';
  menu.DrawSzinesChat(txt,0.86,0.35,1,39,$FF000000+betuszin);


 case multisc.kills-multisc.killswithoutdeath of
   0, 1, 2:txt:='';
   3, 4, 5:txt:='Killing Spree!';
   6, 7, 8:txt:='Rampage!';
   9,10,11:txt:='Dominating!';
  12,13,14:txt:='Unstoppable!';
  15..29  :txt:='Godlike';
  30..10000:txt:='WICKED SICK';
 end;
  menu.DrawSzinesChat(txt,0.89,0.37,1,0.39,$FF000000+betuszin);




 {$IFDEF palyszerk}
 mit:='DELETE';
 if epuletmost>=0 then mit:=ojjektumnevek[epuletmost];
 menu.DrawText(mit,0.3,0.3,0.7,0.7,2,$FF000000);
 {$ENDIF}

 //menu.drawtext(inttostr(round(botlevel*100)),0.3,0.9,0.9,1,1,$FF000000+betuszin);



  for i:=high(hudMessages) downto low(hudMessages) do
  begin
  if (hudMessages[i].value<>'') and (hudMessages[i].fade<>0) then
//    menu.drawtext(hudMessages[i].value,0.1,hudMessagePosY-(i+min(hudInfoFade,1))*hudMessageOffsetY,0.9,hudMessagePosY-(i+min(hudInfoFade,1))*hudMessageOffsetY+0.1,1,$1000000*min(hudMessages[i].fade,255)+hudMessages[i].color);
    drawmessage(hudMessages[i].value,$1000000*min(hudMessages[i].fade,255)+hudMessages[i].color);
  end;

  if hudInfoFade<>0 then
    drawmessage(hudInfo,$1000000*min(hudInfoFade,255)+hudInfoColor);

  if labelvolt and not labelactive and opt_tips then
    showHudInfo(lang[80],255,betuszin);

  stepHudMessages;


 if autoban then
 begin
  d3dxvec3subtract(tmp,tegla.vpos,tegla.pos);
  menu.drawtext(mp3stationname,0,0.85,0.4,0.9,1,$FF000000+betuszin);   //d3dxvec3length(tmp)*360)
  menu.drawtext(inttostr(round(tegla.pillspd*360))+'Km/h ',0,0.9,0.4,1,2,$FF000000+betuszin);
  // +inttostr(tegla.shift) + ': ' + inttostr(round(tegla.fordulatszam*1000))
  // sebesség, fordulatszám
  if tegla.axes[2].y<0 then
  begin
   if latszonazR>1 then dec(latszonazR) else
   if latszonazR=0 then
    latszonazR:=255;
    if opt_tips then
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

  if (zonechanged>0) and opt_zonename and (lastzone<>'') then
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

 if autobaszallhat and (halal=0) then
 begin
  if latszonazF>2 then dec(latszonazF,2);
//   drawmessage(lang[52],min(255,latszonazF)*$1000000+betuszin)
  if opt_tips then
   showHudInfo(lang[52],min(255,latszonazF),betuszin)
 end
 else
  if (not autoban) and (tavpointpointsq(tegla.pos,d3dxvector3(cpx^,cpy^,cpz^))<5*5) and (halal=0) then
  begin
    if latszonazF>2 then dec(latszonazF,2);
   if opt_tips then
   drawmessage(lang[53],min(255,latszonazF)*$1000000+betuszin)

  end
 else
  if latszonazF<240 then inc(latszonazF,5) else latszonazF:=500;

 if invulntim>0 then
  drawmessage(lang[54]+inttostr(invulntim div 100+1),$A0000000+betuszin);
//  showHudInfo(lang[54]+inttostr(invulntim div 100+1),500,$A0000000+betuszin);
 
{ if latszonaKL>0 then
 begin
 if meghaltam then
  drawmessage(kitlottemle,$1000000*min(latszonaKL,255)+$0000FF)
  else
  drawmessage(kitlottemle,$1000000*min(latszonaKL,255)+$FF0000);


 end;}
 
 {$IFDEF matieditor}
  if me_mat<0 then me_mat:=0;
  if me_mat>ojjektumarr[me_id].texszam-1 then me_mat:= ojjektumarr[me_id].texszam -1;

  me_tid := ojjektumarr[me_id].textures[me_mat];
  debugstr2 := ojjektumTextures[me_tid].name + ' i:' + FloatToStr(ojjektumTextures[me_tid].specIntensity) + ' h:' + FloatToStr(ojjektumTextures[me_tid].specHardness);

  menu.drawtext(debugstr,0.2,0.8,1,1,1,$FFFFFFFF);
  menu.drawtext(debugstr2,0.2,0.9,1,1,1,$FFFFFFFF);
  menu.drawtext(IntToStr(trunc(multisc.weather)),0.2,0.85,1,1,1,$FFFFFFFF);
 {$ENDIF}
 //  menu.g_pSprite.Draw(inttostr(sizeof(TD3DXAttributeRange)),nil,nil,nil,$80FFFFFF);


 //menu.drawtext(debugstr,0.2,0.8,1,1,2,$80FFFFFF);
 // if multip2p.laststatus then
 //   menu.drawtext('TRUE',0.9,0.8,1,2,2,$80FFFFFF)
 // else  menu.drawtext('FALSE',0.9,0.8,1,2,2,$80FFFFFF);
 // if multip2p.voltfalse then menu.drawtext('VOLT!',0.6,0.8,1,2,2,$80FFFFFF);
 //if (currevent <> nil) then menu.drawtext(inttostr(currevent.phs),0.7,0.9,1,1,2,$70000000+betuszin);
  //menu.drawtext( floattostr(kiszall_cooldown),0.2,0.9,0.8,1,2,$70000000+betuszin);
  //menu.drawtext(inttostr(length(particles))+'/'+inttostr(particlehgh),0.2,0.9,0.8,1,false,$70000000+betuszin);
  //if not nofegyv then menu.drawtext('nofegyv',0.2,0.9,0.8,1,2,$70000000+betuszin);
 // menu.drawtext(inttostr(bufplayingcount)+'/'+inttostr(length(bufplaying)),0.2,0.9,0.8,1,2,$70000000+betuszin);
 // menu.drawtext(inttostr(playsoundcount)+':'+inttostr(stopsoundcount)+'>'+inttostr(specialcreatecount),0.2,0.8,0.8,0.9,2,$70000000+betuszin);
  playsoundcount:=0; stopsoundcount:=0; specialcreatecount:=0;
{$IFDEF profiler}
  menu.drawtext('M:'+inttostr(profile_mecha)+' R:'+inttostr(profile_render),0.2,0.8,0.8,0.9,2,$70000000+betuszin);
{$ENDIF}

// for i:=0 to 12 do
 // menu.drawtext(inttostr(kic[i]),0.3,0.1+i/20,0.5,0.2+i/20,true,$FFFF0000);

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

  //menu.DrawRect(0.1,0.1,0.9,0.9,$A0000000);
  menu.DrawRect(0.1,0.1,0.9,0.2,$A0000000);
  menu.DrawRect(0.1,0.1,0.9,0.9,$A0000000);
  menu.Addteg(0.1,0.1,0.9,0.9,8);
  menu.DrawKerekitett(menu.tegs[8,1]);
  menu.g_psprite.Flush;
  menu.g_psprite.SetTransform(identmatr);
  menu.DrawText('GUN',0.15,0.125,0.5,0.2,2,$FFFF6000);
  menu.DrawText('TECH',0.50,0.125,0.85,0.2,2,$FF00A0FF);
//                       div 2048
  killtmutat:=((timegettime shr 11) and 1)=1 ;




   kisTAB:=0;
   menuszor:=0.022;

  if (tabgorg>techsz-33) and (tabgorg>gunsz-33) then tabgorg:=tabgorg-1;
  tabsort:=tabgorg;
  tabsorg:=tabgorg;

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
    if (length(ppl[rendezve[i]].pls.nev)>0) and (ppl[rendezve[i]].net.connected or (ppl[rendezve[i]].net.UID=0)) then
    begin
    if (tabsort<=0) and (techsz<33) then
      begin
      szcol:= $FF00A0FF;
      if (ppl[rendezve[i]].net.UID=0) then  szcol:= $FFFFFFFF;
      if (ppl[rendezve[i]].pls.nev = multisc.kihivas) then  szcol:= $FFFF0000;
      menu.DrawText(ppl[rendezve[i]].pls.clan ,0.5,menuplus+techsz*menuszor,0.85,menuplus+0.1+techsz*menuszor,kisTAB,$FF00FF00);
      menu.DrawText(ppl[rendezve[i]].pls.nev ,0.6,menuplus+techsz*menuszor,0.85,menuplus+0.1+techsz*menuszor,kisTAB,szcol);
      menu.DrawText(fegyvernev(ppl[rendezve[i]].pls.fegyv),0.78,menuplus+techsz*menuszor,0.85,menuplus+0.1+techsz*menuszor,kisTAB,$FF00A0FF);
      menu.DrawText(inttostr(ppl[rendezve[i]].pls.kills),0.85,menuplus+techsz*menuszor,0.85,menuplus+0.1+techsz*menuszor,kisTAB,$FF00A0FF);
      inc(techsz);
      end;
      tabsort:=tabsort-1;

    end;
   end
   else
   begin
    if (length(ppl[rendezve[i]].pls.nev)>0) and (ppl[rendezve[i]].net.connected or (ppl[rendezve[i]].net.UID=0))  then
    begin
    if (tabsorg<=0) and (gunsz<33) then
      begin
      szcol:= $FFFF6000;
      if (ppl[rendezve[i]].net.UID=0) then  szcol:= $FFFFFFFF;
      if (ppl[rendezve[i]].pls.nev = multisc.kihivas) then  szcol:= $FFFF0000;
      menu.DrawText(ppl[rendezve[i]].pls.clan ,0.11,menuplus+gunsz*menuszor,0.5,menuplus+0.1+gunsz*menuszor,kisTAB,$FF00FF00);
      menu.DrawText(ppl[rendezve[i]].pls.nev ,0.21,menuplus+gunsz*menuszor,0.85,menuplus+0.1+gunsz*menuszor,kisTAB,szcol);
      menu.DrawText(fegyvernev(ppl[rendezve[i]].pls.fegyv),0.39,menuplus+gunsz*menuszor,0.5,menuplus+0.1+gunsz*menuszor,kisTAB,$FFFF6000);
      menu.DrawText(inttostr(ppl[rendezve[i]].pls.kills),0.46,menuplus+gunsz*menuszor,0.5,menuplus+0.1+gunsz*menuszor,kisTAB,$FFFF6000);
      inc(gunsz);
      end;
      tabsorg:=tabsorg-1;

    end;
   end;
   if (gunsz>=33) or (techsz>=33) then
    menu.DrawText(lang[69],0.45,menuplus+34*menuszor,0.84,menuplus+0.1+34*menuszor,kisTAB,$FFFFFFFF);
 end
 else
 if multisc.kihivszam>0 then //multisc.kihivas <> nil
 begin
 // 1v1 kihívós menü
 dec(multisc.kihivszam);
 menu.DrawRect(0.70,0.92,0.98,0.985,$A0000000);
  menu.g_psprite.Flush;
  menu.g_psprite.SetTransform(identmatr);
 menu.DrawText(multisc.kihivas+lang[71]+inttostr(multisc.limit)+lang[73],0.71,0.93,1,1,0,$FFFFFFFF);
 menu.DrawText(lang[72],0.71,0.95,1,1,0,$DDDDDDDD);
 end
 else
 if labelactive then drawLabel;
 except
  exit;
 end;
end;


procedure drawminimap;
type
  TMinimapVertex = record
    position:TD3DVector;
    color:Dword;
    u,v:single;
  end;
function MinimapVertex(px,py,pz,au,av:single;acolor:dword):TMinimapVertex;
begin
  with result do
  begin
    position:=D3DXVector3(px,py,pz);
    u:=au;
    v:=av;
    color:=acolor;
  end;

end;
const
  szhx=0.1;szhy=0.5;
var
  vEyePt, vLookatPt, vUpVec: TD3DVector;
  mat:TD3DMatrix;
  i:integer;
  mapvert:array [0..100] of TMinimapVertex;
  mapind:array[0..149*3] of word;
begin

  if nohud then
  exit;
  //g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/3, 4/3, 0.05, 2000.0);
  g_pd3dDevice.SetTransform(D3DTS_PROJECTION, matProj);

  g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_CLAMP);
  g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_CLAMP);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_MODULATE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP,   D3DTOP_SELECTARG2);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);

  g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
  g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
  g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,  D3DBLEND_INVSRCALPHA);
  vEyePt:=    D3DXVector3(0, 0,0);
  vUpVec:=    D3DXVector3(0,1,0);
  vlookatpt:= D3DXVector3(0,0, 1);
  D3DXMatrixLookAtLH(mat, vEyePt, vLookatPt, vUpVec);

  g_pd3dDevice.SetTransform(D3DTS_VIEW, mat);
  g_pd3dDevice.SetFVF(D3DFVF_XYZ or D3DFVF_TEX1 or D3DFVF_DIFFUSE);
  g_pd3ddevice.SetTexture(0,mt2);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_DISABLE);
  //g_pd3ddevice.settransform(D3DTS_TEXTURE0,identmatr);
  mapvert[0]:=MinimapVertex(0.09-((4/3)*0.007)+((ASPECT_RATIO)*0.007),0.062,0.1435,cpx^/(2*1024)+0.5,cpz^/(2*1024)+0.5,$FFFFFFFF);
  for i:=0 to 49 do
  begin
    mapvert[i+1]:= MinimapVertex(sin(i*D3DX_PI*2/50)*(4/3)/(ASPECT_RATIO)*0.019+0.09-((4/3)*0.007)+((ASPECT_RATIO)*0.007),cos(i*D3DX_PI*2/50)*0.019+0.062,0.1435,(sin(i*D3DX_PI*2/50+szogx)*0.1+cpx^/(2*1024)+0.5),(cos(i*D3DX_PI*2/50+szogx)*0.1+cpz^/(2*1024)+0.5),$aaffffff);
    mapind[i*3+0]:=0;
    mapind[i*3+1]:=1+i;
    mapind[i*3+2]:=1+(i+1) mod 50;
  end;

  for i:=0 to 49 do
  begin
    mapvert[i+51]:=MinimapVertex(sin(i*D3DX_PI*2/50)*(4/3)/(ASPECT_RATIO)*0.020+0.09-((4/3)*0.007)+((ASPECT_RATIO)*0.007),cos(i*D3DX_PI*2/50)*0.020+0.062,0.1435,(sin(i*D3DX_PI*2/50+szogx)*0.1+cpx^/(2*1024)+0.5),(cos(i*D3DX_PI*2/50+szogx)*0.1+cpz^/(2*1024)+0.5),$55000000);
    mapind[(i+50 )*3+0]:=1+i;
    mapind[(i+50 )*3+1]:=1+i+50;
    mapind[(i+50 )*3+2]:=1+(i+1) mod 50;

    mapind[(i+100)*3+0]:=1+(i+1) mod 50 + 50;
    mapind[(i+100)*3+1]:=1+(i+1) mod 50;
    mapind[(i+100)*3+2]:=1+i+50;
  end;

  g_pd3ddevice.DrawIndexedPrimitiveUP(D3DPT_TRIANGLELIST,0,101,150,mapind[0],D3DFMT_INDEX16,mapvert[0],sizeof(TMinimapVertex));

  g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_WRAP);
  g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_WRAP);

end;

procedure closeHUD;
begin
  menu.g_pSprite._End;
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

    laststate:='RenderAutok';
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



procedure rendermuks(i:integer;astate,afegyv:byte);
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
  muks.Render(techszin,mat_world,D3DXVector3(cpx^,cpy^,cpz^))
 else
  muks.Render(gunszin,mat_world,D3DXVector3(cpx^,cpy^,cpz^));
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
  if myfegyv=FEGYV_M4A1 then begin tj.y:=tj.y+0.03; tb.y:=tb.y+0.03; end;
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
  muks.Render(gunszin,identmatr,campos)
 else
  muks.Render(techszin,identmatr,campos)
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
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/4, ASPECT_RATIO, 0.1, 1000.0);
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
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/4, ASPECT_RATIO, 0.1, 1000.0);
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
 pos:TD3DXVector3;
begin
 for i:=0 to high(ppl) do
 begin
  if ppl[i].net.vtim>0 then
   pos:=ppl[i].pos.megjpos
  else
   pos:=ppl[i].pos.pos;

  ppl[i].pls.visible:=spherevsfrustum(D3DXVector3(pos.x,pos.y+0.8,pos.z),1,frust);
 end;
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
    frust:=frustum(xmat,0.1,1100,D3DX_PI/3, ASPECT_RATIO);
    
    renderautok(true);


    laststate:='Rendering terrain';

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
    g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, ambientszin);
    g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);

    g_pd3dDevice.SetTexture(0,futex);
    g_pd3dDevice.SetTexture(1,noise2tex);
    DrawSplat(0,splatinds[0]);

    g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
    g_pd3dDevice.SetTexture(0,homtex);
    g_pd3dDevice.SetTexture(1,hnoise);
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
    ojjektumrenderer.Draw(opt_detail,nil,false,felho);
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
    FEGYV_M4A1,FEGYV_M82A1,FEGYV_X72,
    FEGYV_MP5A3:ppl[i].pls.lo:=ppl[i].pls.lo-eltim*10;
    FEGYV_MPG:ppl[i].pls.lo:=ppl[i].pls.lo+eltim*2;
    FEGYV_QUAD:ppl[i].pls.lo:=ppl[i].pls.lo+eltim*2;
   end;

   if ppl[i].pls.lo<0 then ppl[i].pls.lo:=0;
   if ppl[i].pls.lo>1 then ppl[i].pls.lo:=1;
  end;

  if halal>0 then
  halal:=halal+eltim; //nem volt /2
  if multisc.warevent then
  begin
    if halal>multisc.warevent_respawn then respawn;  
  end
  else
  begin
    if halal>6 then respawn;
  end;



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
 tmplw:longword;
begin
   laststate:='Rendering reflections';

   if (myfegyv = FEGYV_MPG) then
     (if lightIntensity > 0 then lightIntensity := max(0,lightIntensity - 0.03))
   else if (myfegyv = FEGYV_QUAD) then
     (if lightIntensity > 0 then lightIntensity := max(0,lightIntensity - 0.01))
   else
     (if lightIntensity > 0 then lightIntensity := max(0,lightIntensity - 0.04));

   //hát, ez elõre kell. pont.
  if (opt_water>0) then
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

    if currevent<>nil then
     currevent.RenderModels;

    if portalevent<>nil then
     portalevent.RenderModels;

    setupidentmatr;
    // Render the vertex buffer contents
    g_pd3dDevice.SetStreamSource(0, g_pVB, 0, SizeOf(TCustomVertex));
    g_pd3dDevice.SetFVF(D3DFVF_CUSTOMVERTEX);
    g_pd3dDevice.SetIndices(g_pIB);

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,  D3DTOP_MODULATE );
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP,FAKE_HDR   );

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(2, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(2, D3DTSS_COLORARG2, D3DTA_CURRENT);
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
    g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, ambientszin);
    g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);

    g_pd3dDevice.SetTexture(0,futex);
    g_pd3dDevice.SetTexture(1,noise2tex);

     DrawSplat(0,splatinds[0]);


    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG2);

    g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
    g_pd3dDevice.SetTexture(0,homtex);
    g_pd3dDevice.SetTexture(1,hnoise);
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
     //DrawLvl((cpy^>150));
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



        // a bubblékat is ki kéne raj-zolni


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
     if not nofegyv then
      rendermykez;

    pos:=D3DXVector3(cpx^,cpy^,cpz^);
    for i:=0 to rbszam do
    if abs(rongybabak[i].gmbk[10].y-cpy^)<100 then
    begin
     //g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, rongybabak[i].szin);
     rongybabak[i].transfertomuks(muks);
     muks.Render(rongybabak[i].szin,mat_world,pos);


    end;

    if random(100)=0 then
     Undebug_checksum;

    dopplvisibility;

    for i:=0 to high(ppl) do
    begin
    if ppl[i].pls.autoban then ppl[i].pls.visible:=false;
    if ppl[i].pls.visible then
     if tavpointpointsq(ppl[i].pos.pos,campos)<sqr(500) then
     begin
      Rendermuks(i,ppl[i].pos.state,ppl[i].pls.fegyv);
     end;
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
    if tavpointpointsq(campos,ppl[i].pos.pos)<sqr(50+20*opt_detail) then
    begin
     setupmuksmatr(i);
     mat_world._41:=mat_world._41+ppl[i].pls.fejh.x;
     mat_world._42:=mat_world._42+ppl[i].pls.fejh.y;
     mat_world._43:=mat_world._43+ppl[i].pls.fejh.z;
     fejcuccrenderer.Render(ppl[i].pls.fejcucc,mat_world,false,D3DXVector3(cpx^,cpy^,cpz^));
    end;
    fejcuccrenderer.Flush;

    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);

    g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, ambientszin);

    end;  //Menübõl nemkéne vége

    laststate:='Rendering bunker and stuff';

    initojjektumok(g_pd3ddevice,FAKE_HDR);
    g_pd3dDevice.SetRenderState(D3DRS_TEXTUREFACTOR,$FF5050FF);
    g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);

     if (opt_detail>0) and (g_pEffect<>nil) then
        g_pEffect.SetTexture('g_MeshTexture', effecttexture);

    if opt_detail>0 then
    begin
      ojjektumrenderer.Draw(opt_detail,g_peffect,((myfegyv<>FEGYV_M82A1) or csipo) and not mapbol, felho);
      propsystem.RenderModels(g_peffect);
    end
    else
    ojjektumrenderer.Draw(opt_detail,nil,((myfegyv<>FEGYV_M82A1) or csipo) and not mapbol, felho);



    uninitojjektumok(g_pd3ddevice);
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG1, D3DTA_TEXTURE);

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE);





    //developer
    //g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG1);
    g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);

    if (menu.lap=-1) then //MENÜBÕL nem kéne...
    begin




    setupmyfegyvmatr;
    setupfegyvlights(fegylit);
    if not kulsonezet then
    if (not csipo) and (myfegyv=FEGYV_M82A1) then fegyv.drawscope(FEGYV_M82A1 {myfegyv}) else
    if myfegyv<>FEGYV_NOOB then
     begin
      setupmyfegyvprojmat;
      if not nofegyv then
       fegyv.drawfegyv(myfegyv);
      setupprojmat;
     end
    else
     if not (enableeffects and (opt_postproc>0)) then
     begin
      setupmyfegyvprojmat;
      if not nofegyv then
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

    renderBubbles;
    
    {$IFDEF panthihogomb}

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP , D3DTOP_SELECTARG1 );
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_DIFFUSE);
    g_pd3dDevice.SetTexture(0,nil);
    g_pd3dDevice.SetRenderState(D3DRS_FOGENABLE , iFalse);
    g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iTrue);
    g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $101010);
    mat_world:=identmatr;
    mat_world._11:=DNSRad;
    mat_world._22:=DNSRad;
    mat_world._33:=DNSRad;
    mat_world._41:=DNSVec.x;
    mat_world._42:=DNSVec.y;
    mat_world._43:=DNSVec.z;
    g_pd3dDevice.SetTransform(D3DTS_WORLD, mat_World);
    hogombmesh.DrawSubset(0);
    {$ENDIF}



    g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $FFFFFFFF);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
    setupidentmatr();
    g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iFalse);


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
      fegyv.drawfegyeffekt(ppl[i].pls.fegyv,ppl[i].pls.lo);//bug
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
     if (opt_radar) then begin
     g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iFalse);
     drawminimap;
     g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iTrue);
     end;
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
// res:HRESULT;
 rect:Prect;
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
      g_pd3ddevice.SetRenderState(D3DRS_ALPHABLENDENABLE,iFalse);
      //g_pd3ddevice.SetRenderState(D3DRS_ALPHABLENDENABLE,iTrue);
      //g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_ONE);
      //g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,  D3DBLEND_ONE);
      g_pd3ddevice.SetRenderState(D3DRS_LIGHTING,ifalse);
      g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE,ifalse);
      g_pd3ddevice.SetRenderState(D3DRS_CULLMODE,D3DCULL_NONE);
      g_pd3ddevice.SetRenderState(D3DRS_ZENABLE,ifalse);
      DrawFullscreenrect;
      g_peffect.Endpass;
      g_peffect._end;
     end;


     if (menu.lap=-1) then //MENÜBÕL nem kéne...
    if (G_peffect<>nil) and (opt_motionblur) then
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
    if (myfegyv=FEGYV_NOOB) and not nofegyv and (not autoban) and (halal=0) then
    begin

     g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE);
     g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);

     g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iTrue);
     g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, ambientszin);
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



     if (opt_radar) then begin
     g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iFalse);
     drawminimap;
     g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iTrue);
     end;
     laststate:='Rendering HUD';
     initHUD;
     drawHUD;
     closeHUD;
    end;
    g_pd3dDevice.EndScene;
   end;

  end;

  if (GetAsyncKeyState(VK_SNAPSHOT)<>0) then
    begin

   backbuffer:=nil;
   g_pd3ddevice.GetBackBuffer(0,0,D3DBACKBUFFER_TYPE_MONO,backbuffer);

   if multisampling>0 then
   begin
     rect := AllocMem(SizeOf(TRect));
     rect.Left := 0;
     rect.Top := 0;
     rect.Right := SCwidth;
     rect.Bottom := SCheight;
     g_pd3dDevice.StretchRect(backbuffer,rect,downsamplesurf,rect,D3DTEXF_POINT);
     g_pd3ddevice.GetRenderTargetData(downsamplesurf,printscreensurf);
   end
   else
   g_pd3ddevice.GetRenderTargetData(backbuffer,printscreensurf);



   longdateformat:='yyyy.mm.dd.';
   longtimeformat:='hh-nn-ss';
   shortdateformat:='yyyy.mm.dd.';
   shorttimeformat:='hh-nn-ss';

   if not directoryexists('screenshots') then createdirectory('screenshots',nil);

   if png_screenshot then
   begin
    fajlnev:='screenshots/Stickman Warfare '+Datetostr(date)+' '+timetostr(time)+'.png';
    D3DXsavesurfacetofile(PChar(fajlnev),D3DXIFF_PNG,printscreensurf,nil,nil);
   end
   else
   begin
    fajlnev:='screenshots/Stickman Warfare '+Datetostr(date)+' '+timetostr(time)+'.jpg';
    D3DXsavesurfacetofile(PChar(fajlnev),D3DXIFF_JPG,printscreensurf,nil,nil);
   end;

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
{$IFDEF profiler}
 QueryPerformanceCounter(profile_start);
{$ENDIF}

 undebug_magic1; // Mechanics;
 undebug_untrace;

{$IFDEF profiler}
 QueryPerformanceCounter(profile_stop);
 profile_mecha := (MSecsPerSec*(profile_stop-profile_start)) div profile_frequency;
 QueryPerformanceCounter(profile_start);
{$ENDIF}

 RenderScene;
 RenderPostprocess;

{$IFDEF profiler}
 QueryPerformanceCounter(profile_stop);
 profile_render := (MSecsPerSec*(profile_stop-profile_start)) div profile_frequency;
{$ENDIF}

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
  write(fil2,menufi[MI_VOL].elx);
  write(fil2,menufi[MI_MP3_VOL].elx);


  t1:=myfejcucc;
  write(fil2,t1);

  t1:=opt_detail;
  write(fil2,t1);
  t1:=opt_postproc;
  write(fil2,t1);
  t1:=opt_water;
  write(fil2,t1);
  t1:=opt_particle;
  write(fil2,t1);

  if opt_rain then
   t1:=1
  else
   t1:=0;
  write(fil2,t1);

  if opt_motionblur then
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

  if png_screenshot then
   t1:=1
  else
   t1:=0;
  write(fil2,t1);

  if opt_radar then
   t1:=1
  else
   t1:=0;
  write(fil2,t1);

  if opt_nochat then
   t1:=1
  else
   t1:=0;
  write(fil2,t1);

  if opt_zonename then
   t1:=1
  else
   t1:=0;
  write(fil2,t1);

  if opt_tips then
   t1:=1
  else
   t1:=0;
  write(fil2,t1);

  if savepw then
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

 savemenumisc;
 for i:=0 to 7 do
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
  if not portalstarted then   begin
  portalevent:=TPortalEvent.Create(g_pd3ddevice,true,'data\event\');
  portalevent.phstim:=3351;
  portalevent.phs:=3;

  if portalevent.error > 0 then
      portalevent := nil;
  end;
  
  menufi[MI_GAZMSG].visible:=false;
  menu.tegs[0,1].visible:=false;

  assignfile(fil,'data\cfg\name.cfg');
  rewrite(fil);
  writeln(fil,menufi[MI_NEV].valueS);
  writeln(fil,myfegyv);
  if (lasthash='-') then
    lasthash:=menufipass.GetPasswordMD5;
  if savepw and (menufipass.valueS<>'') then
    writeln(fil,encodehash(lasthash))
  else
    writeln(fil,'-');
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
  if isHalloween then
   begin
    myfegyv:=FEGYV_H31_G;
    menufi[MI_FEGYV].valueS:=fegyvernev(FEGYV_H31_G);
   end
   else
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
  if isHalloween then
   begin
    myfegyv:=FEGYV_H31_T;
    menufi[MI_FEGYV].valueS:=fegyvernev(FEGYV_H31_T);
   end
   else
   begin
    myfegyv:=FEGYV_MPG;
    menufi[MI_FEGYV].valueS:='MPG';
   end;

  FEGYV_H31_T:
   begin
    myfegyv:=FEGYV_MPG;
    menufi[MI_FEGYV].valueS:='MPG';
   end;

  FEGYV_H31_G:
   begin
    myfegyv:=FEGYV_M4A1;
    menufi[MI_FEGYV].valueS:='M4A1';
   end;
   
  end

 end;

 if menufi[MI_HEADBAL].clicked then
 begin
  menufi[MI_HEADBAL].clicked:=false;
  myfejcucc:=(myfejcucc+stuffjson.GetNum(['hats'])-1) mod stuffjson.GetNum(['hats']);
 end;

 if menufi[MI_HEADJOBB].clicked then
 begin
  menufi[MI_HEADJOBB].clicked:=false;
  myfejcucc:=(myfejcucc+1) mod stuffjson.GetNum(['hats']);
 end;

 //Exit
 if menu.items[3,4].clicked then
 begin
  menu.items[3,4].clicked:=false;
  assignfile(fil,'data\cfg\name.cfg');
  rewrite(fil);
  writeln(fil,menufi[MI_NEV].valueS);
  writeln(fil,myfegyv);
  if (lasthash='-') then
    lasthash:=menufipass.GetPasswordMD5;
  if savepw and (menufipass.valueS<>'') then
    writeln(fil,encodehash(lasthash))
  else
    writeln(fil,'-');
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

  if menufi[MI_INTERFACE].clicked then
 begin
  menufi[MI_INTERFACE].clicked:=false;
  menu.lap:=7;
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

 if menufi[MI_MOTIONBLUR].clicked then
 begin
  menufi[MI_MOTIONBLUR].clicked:=false;
  opt_motionblur:=not opt_motionblur;
  exit;
 end;


 {
 if menufi[MI_IMPOSTER].clicked then
 begin
  menufi[MI_IMPOSTER].clicked:=false;
  opt_imposters:=not opt_imposters;
 end;
 }
 if menufi[MI_SCREENSHOT].clicked then
 begin
  menufi[MI_SCREENSHOT].clicked:=false;
  png_screenshot:=not png_screenshot;
  exit;
 end;



 if menufi[MI_RADAR].clicked then
 begin
  menufi[MI_RADAR].clicked:=false;
  opt_radar:=not opt_radar;
  exit;
 end;

 if menufi[MI_CHAT].clicked then
 begin
  menufi[MI_CHAT].clicked:=false;
  opt_nochat:=not opt_nochat;
  exit;
 end;

 if menufi[MI_ZONES].clicked then
 begin
  menufi[MI_ZONES].clicked:=false;
  opt_zonename:=not opt_zonename;
  exit;
 end;

 if menufi[MI_TIPS].clicked then
 begin
  menufi[MI_TIPS].clicked:=false;
  opt_tips:=not opt_tips;
  exit;
 end;

 if menufi[MI_SAVEPW].clicked then
 begin
  menufi[MI_SAVEPW].clicked:=false;
  savepw:=not savepw;
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

 opt_water:=round(menufi[MI_WATER].elx*WATER_MAX);
 menufi[MI_WATER].elx:=opt_water/WATER_MAX;

 if pre_opt_water<>opt_water then
 begin
  case opt_water of
  1: D3DXCreateTexture(g_pd3ddevice,SCWidth div 4,SCheight div 4,0,D3DUSAGE_RENDERTARGET,D3DFMT_A8R8G8B8,D3DPOOL_DEFAULT,reflecttexture);
  2: D3DXCreateTexture(g_pd3ddevice,SCWidth div 2,SCheight div 2,0,D3DUSAGE_RENDERTARGET,D3DFMT_A8R8G8B8,D3DPOOL_DEFAULT,reflecttexture);
  3: D3DXCreateTexture(g_pd3ddevice,SCWidth,SCheight,0,D3DUSAGE_RENDERTARGET,D3DFMT_A8R8G8B8,D3DPOOL_DEFAULT,reflecttexture);
  end;
  pre_opt_water:=opt_water;
 end;

 opt_particle:=round(menufi[MI_PARTICLE].elx*PARTICLE_MAX);
 menufi[MI_PARTICLE].elx:=opt_particle/PARTICLE_MAX;


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

 if opt_motionblur then
  menufi[MI_MOTIONBLUR].valueS:='[X]'
 else
  menufi[MI_MOTIONBLUR].valueS:='[ ]';

 if opt_radar then
  menufi[MI_RADAR].valueS:='[X]'
 else
  menufi[MI_RADAR].valueS:='[ ]';

 if opt_nochat then
  menufi[MI_CHAT].valueS:='[X]'
 else
  menufi[MI_CHAT].valueS:='[ ]';

 if opt_zonename then
  menufi[MI_ZONES].valueS:='[X]'
 else
  menufi[MI_ZONES].valueS:='[ ]';

 if opt_tips then
  menufi[MI_TIPS].valueS:='[X]'
 else
  menufi[MI_TIPS].valueS:='[ ]';

 if savepw then
  menufi[MI_SAVEPW].valueS:='[X]'
 else
  menufi[MI_SAVEPW].valueS:='[ ]';


 {if opt_imposters then
  menufi[MI_IMPOSTER].valueS:='[X]'
 else
  menufi[MI_IMPOSTER].valueS:='[ ]';
  }
 if png_screenshot then
  menufi[MI_SCREENSHOT].valueS:='PNG'
 else
  menufi[MI_SCREENSHOT].valueS:='JPG';



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
 szogx:=mszogx+sin(2*D3DX_PI*(timegettime mod 20000)/20000)/5;
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




 menu.Draw(menuopacity);
 if menuopacity<0.98 then menuopacity := menuopacity + 0.02;

 g_pd3dDevice.Present(nil, nil, 0, nil);
end;

procedure InitMenuScene;
var
x:integer;
begin
 x:=random(stuffjson.GetNum(['menubackgrounds']));
 cpx^:=stuffjson.GetFloat(['menubackgrounds',x,'x']);
 cpy^:=stuffjson.GetFloat(['menubackgrounds',x,'y']);
 cpz^:=stuffjson.GetFloat(['menubackgrounds',x,'z']);

 szogx:=stuffjson.GetFloat(['menubackgrounds',x,'angleH']);
 szogy:=stuffjson.GetFloat(['menubackgrounds',x,'angleV']);
 mszogx:=szogx;
 mszogy:=szogy;

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
fsettings:TFormatSettings;
begin

  if pos(' /practice',mit)=1 then
   mit:=' /join Practice-'+inttohex(random(35536),4);

  if pos(' /nohud',mit)=1 then
   nohud:=not nohud;

  if pos(' /activate portalevent code:12.11.16',mit)=1 then
   portalevent.phs:=1;

  if pos(' /nofegyv',mit)=1 then
   nofegyv:=not nofegyv;

  if pos(' /sniper',mit)=1 then
   coordsniper:=true;

  if pos(' /coords',mit)=1 then
  begin
   for i:=high(multisc.chats) downto 3 do
    multisc.chats[i]:=multisc.chats[i-3];
   GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT,fsettings);
   fsettings.DecimalSeparator:='.';
   multisc.chats[0].uzenet:='Coords: ('+copy(mit,pos(' /coords',mit)+length(' /coords')+1,100000)+')';
   multisc.chats[1].uzenet:='x: '+FloatToStrF(cpx^,ffFixed,7,2,fsettings)+
           '  y: '+FloatToStrF(cpy^,ffFixed,7,2,fsettings)+
           '  z: '+FloatToStrF(cpz^,ffFixed,7,2,fsettings);
   multisc.chats[2].uzenet:='angleH: '+FloatToStrF(szogx,ffFixed,7,2,fsettings)+
           '  angleV: '+FloatToStrF(szogy,ffFixed,7,2,fsettings);
   multisc.chats[0].glyph:=0;
   multisc.chats[1].glyph:=0;
   multisc.chats[2].glyph:=0;
   writeln(logfile,multisc.chats[0].uzenet,' ',multisc.chats[1].uzenet,' ',multisc.chats[2].uzenet);
  end;
end;

     {WAT
procedure pickup;
var
i:integer;
vec,view:TD3DXVector3;
mat: TD3DMatrix;

begin

  view.x := cos(szogy);
  view.y := sin(szogy);

  view.z := cos(szogx)*view.x; // +z *sin ,de Z = 0
  view.x := sin(szogx)*view.x; // -Z *cos , de Z még mindig 0

  D3DXVec3Normalize(view,view);


  for i:=0 to length(propsystem.objects)-1 do
  begin
    if tavPointPointsq(propsystem.objects[i].pos,campos) < 7 then // 1 méter minimum
    begin
      //összekötõ vector
      D3DXVec3Subtract(vec,propsystem.objects[i].pos,campos);
      D3DXVec3Normalize(vec,vec) ;
      //skaláris
      if (D3DXVec3Dot(vec,view)>0.9) then
        messagebox(0,'pickup',';)',0);

    end;
  end;

end;   {}


procedure findPlayerForChat(start:integer;command:string);
var
i,n,k:integer;
key:string;
db:string;

begin
 n:=high(ppl);

 key:=Copy(chatmost,start,Length(chatmost)-start+1);

 for i:=0 to n do
  begin
   if (Copy(LowerCase(ppl[i].pls.nev),1,Length(key))=LowerCase(key)) then
     begin
//     inc(j);
     k:=i;
     db:= db + Copy(ppl[i].pls.nev,1,Length(key)) + ' ';
     end;
  end;

  if k>0 then chatmost:=command + ppl[k].pls.nev + ' ';
  //if j=1 then debugstr:='kinek:('+inttostr(k)+') '+ppl[k].pls.nev
  //else
//  debugstr:='key:' + key + ' -> ' + ppl[k].pls.nev;


end;

procedure handlewmchar(mit:wparam);
begin



 if menu.lap<>-1 then exit;

 if length(chatmost)=0 then
 begin
  if (chr(mit)='t') or (chr(mit)='T') or (mit=VK_RETURN) then
  begin
   chatmost:=' ';
   mstat:=MSTAT_FUT;
  end;





  if (chr(mit)='r') or (chr(mit)='R') then chatmost:=' /r ';
  if (chr(mit)='c') or (chr(mit)='C') then chatmost:=' /c ';
  {$IFDEF repkedomod}
  if (chr(mit)='p') or (chr(mit)='P') then repules := not repules;
  if (chr(mit)='n') then addHudMessage('asd',$FF0000);;
  if (chr(mit)='x') then multisc.weather:=multisc.weather+1;
  if (chr(mit)='v') then multisc.weather:=0;
  if (chr(mit)='r') then coordsniper:=true;
  {$ENDIF}
  {$IFDEF matieditor}
  if (chr(mit)='+') then me_mat := me_mat + 1;
  if (chr(mit)='-') then me_mat := me_mat - 1;
  if (chr(mit)='8') then ojjektumTextures[me_tid].specHardness := ojjektumTextures[me_tid].specHardness + 0.1;
  if (chr(mit)='2') then ojjektumTextures[me_tid].specHardness := ojjektumTextures[me_tid].specHardness - 0.1;
  if (chr(mit)='6') then ojjektumTextures[me_tid].specIntensity := ojjektumTextures[me_tid].specIntensity + 0.1;
  if (chr(mit)='4') then ojjektumTextures[me_tid].specIntensity := ojjektumTextures[me_tid].specIntensity - 0.1;
  if (chr(mit)='5') then   matieditor;
  {$ENDIF}
  if (chr(mit)='/') then chatmost:=' /';
  if (mit=VK_ESCAPE) and (not labelactive) then gobacktomenu:=true;
  if (mit=VK_ESCAPE) and labelactive then labelactive:=false;
  if ((chr(mit)='f') or (chr(mit)='F')) and not labelactive and labelvolt then
  begin
   labelactive:=true;
   latszonaKL := 0;
   exit;
  end;
  if ((chr(mit)='f') or (chr(mit)='F')) and labelactive then labelactive:=false;

  //debug stuff
//  if ((chr(mit)='i') or (chr(mit)='I')) then glowdisable := not glowdisable; 


   exit;
 end;




 if mit=VK_BACK then begin

  setlength(chatmost,length(chatmost)-1);
  if chatmost=' ' then mstat:=MSTAT_ALL;
  exit;

   end;
 //if mit=VK_ESCAPE then begin
 // if length(chatmost)=0 then gobacktomenu:=true
 // else chatmost:='';
 // end;

  if mit=VK_ESCAPE then begin chatmost:='';  mstat:=MSTAT_ALL; Exit; end;

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
    if (' /realm'=Copy(chatmost,1,7)) and (halal=0) then
    begin
     halal:=1;
     setupmymuksmatr;
     addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),d3dxvector3(sin(szogx)*0.3,0.1,cos(szogx)*0.3),myfegyv,10,0,-1);
     Multisc.Chat(chatmost);
     mstat:=MSTAT_ALL;

    end
  else
    if (' /norealm'=Copy(chatmost,1,9)) and (halal=0) then
    begin
     halal:=1;
     setupmymuksmatr;
     addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),d3dxvector3(sin(szogx)*0.3,0.1,cos(szogx)*0.3),myfegyv,10,0,-1);
     Multisc.Chat(chatmost);
     mstat:=MSTAT_ALL;

    end
  else
 {   if (' /kbwar'=chatmost) and (halal=0) and (multisc.sock.error<>0) then
    begin
     war_kb:=false;
     halal:=1;
     setupmymuksmatr;
     addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),d3dxvector3(sin(szogx)*0.3,0.1,cos(szogx)*0.3),myfegyv,10,0,-1);
     mstat:=MSTAT_ALL;
    end
  else
 {   if (' /1v1war'=chatmost) and (halal=0) then
    begin        
     war_1v1:=not war_1v1;
     halal:=1;
     setupmymuksmatr;
     addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),d3dxvector3(sin(szogx)*0.3,0.1,cos(szogx)*0.3),myfegyv,10,0,-1);
     mstat:=MSTAT_ALL;
    end
  else
 {   if (' /atlantiswar'=chatmost) and (halal=0) then
    begin
     war_atlantis:=not war_atlantis;
     halal:=1;
     setupmymuksmatr;
     addrongybaba(d3dxvector3(cpx^,cpy^,cpz^),d3dxvector3(cpox^,cpoy^,cpoz^),d3dxvector3(sin(szogx)*0.3,0.1,cos(szogx)*0.3),myfegyv,10,0,-1);
     mstat:=MSTAT_ALL;
    end
  else  }
  begin
    Multisc.Chat(chatmost);
    mstat:=MSTAT_ALL;
  end;
  
  chatmost:='';
  exit;
 end;

 if mit<>VK_TAB then
 chatmost:=chatmost+chr(mit);

 if (mit=VK_TAB) and (Length(chatmost)>4) and (Copy(chatmost,1,4)=' /w ') then findPlayerForChat(5,' /w ');
 if (mit=VK_TAB) and (Length(chatmost)>7) and (Copy(chatmost,1,7)=' /kick ') then findPlayerForChat(8,' /kick ');
 if (mit=VK_TAB) and (Length(chatmost)>6) and (Copy(chatmost,1,6)=' /1v1 ') then findPlayerForChat(7,' /1v1 ');
 if (mit=VK_TAB) and (Length(chatmost)>6) and (Copy(chatmost,1,6)=' /ban ') then findPlayerForChat(7,' /ban ');
end;





procedure fillupmenu;
var
i:integer;
fil:textfile;
fil2:file of single;
str,password:string;
t1:single;
balstart,jobbveg,balveg,jobbstart,korr,bigtext,fent,sor:single;
begin
 if not directoryexists('data\cfg') then createdirectory('data\cfg',nil);
 if fileexists('data\cfg\name.cfg') then
 begin
  assignfile(fil,'data\cfg\name.cfg');
  reset(fil);
  readln(fil,str);
  str:=stringreplace(str,' ','_',[rfReplaceAll]);
  readln(fil,myfegyv);
  password:='';
  lasthash:='';
  readln(fil, lasthash);

  closefile(fil);
  if length(str)>15 then str:='Player';
 end
 else
 begin
  str:='Player';
  myfegyv:=255;
 end;

 balstart := 0.4-(0.8*(SCheight*0.5))/SCwidth;
 balveg   := 0.4;
 jobbstart:= 0.5;
 jobbveg  := 0.5+(1.067*(SCheight*0.5))/SCwidth;
 korr := (SCheight*1.333)/SCwidth;

 bigtext := 0.8;

 //Menü lap all
 for i:=0 to 7 do
 begin
  menu.Addteg(balstart,0.3,balveg,0.8,i);
  menu.AddText(balstart,0.35,balveg,0.45,bigtext,i,lang[0],true);
  menu.AddText(balstart,0.5,balveg,0.6,bigtext,i,lang[1],true);
  menu.AddText(balstart,0.65,balveg,0.75,bigtext,i,lang[2],true);
 end;

 //Menü lap 0;

 // Invisible GazMSG
 menu.Addteg(jobbstart,0.3,jobbveg,0.8,0);
 menu.tegs[0,1].visible:=false;

 menu.AddText(jobbstart,0.3,jobbveg,0.8,0.5,0,'WTF factor.',false);           menufi[MI_GAZMSG]:=menu.items[0,3];
 menufi[MI_GAZMSG].visible:=false;

 //Menü lap 1 -- Connect
 menu.Addteg(jobbstart,0.3,jobbveg,0.8,1);

 menu.AddText(      jobbstart,  0.7,  jobbveg,0.8,1,1,lang[3],true);                   menufi[MI_CONNECT]:=menu.items[1,3];
 menu.AddText(      jobbstart,  0.35, jobbstart+korr*0.13,0.375,0.5,1,lang[4],false);
 menu.AddTextBox(jobbstart+korr*0.13,0.344,jobbveg-korr*0.05,0.389,0.5,1,str,15);                   menufi[MI_NEV]:=menu.items[1,5];
 menu.AddText(jobbstart,0.475,jobbstart+korr*0.13,0.5,0.5,1,lang[5],false);
 menu.AddText(jobbstart+korr*0.13,0.45,jobbveg-korr*0.05,0.525,1,1,'TECH',true);                    menufi[MI_TEAM]:=menu.items[1,7];
 menu.AddText(jobbstart,0.525,jobbstart+korr*0.13,0.575,0.5,1,lang[6],false);
 menu.AddText(jobbstart+korr*0.13,0.525,jobbveg-korr*0.05,0.575,1,1,lang[7],true);                 menufi[MI_FEGYV]:=menu.items[1,9];
 menu.AddText(jobbstart,0.6,0.63,0.65,0.5,1,lang[8],false);
 menu.AddText(0.70,0.58,0.76,0.67,1,1,'',true);                        menufi[MI_HEAD]:=menu.items[1,11];
 menu.AddText(jobbstart,0.4,jobbstart+korr*0.13,0.425,0.5,1,lang[9],false);             menufi[MI_PASS_LABEL]:=menu.items[1,12];
 menu.AddPasswordBox(jobbstart+korr*0.13,0.394,jobbveg-korr*0.05,0.439,0.5,1,0,18,'');     menufipass:=menu.items[1,13] as T3DMIPasswordBox;
 menu.AddText(jobbstart+korr*0.05,0.4,jobbveg-korr*0.05,0.435,0.5,1,'['+lang[10]+']',true);menufi[MI_REGISTERED]:=menu.items[1,14];

 menu.AddText(jobbstart+0.13*korr,0.58,jobbstart+0.18*korr,0.67,1,1,'<',true);                        menufi[MI_HEADBAL]:=menu.items[1,15];
 menu.AddText(jobbstart+0.3*korr,0.58,jobbstart+0.35*korr,0.67,1,1,'>',true);                        menufi[MI_HEADJOBB]:=menu.items[1,16];


 menufi[MI_PASS_LABEL].visible:=false;
 menufipass.visible:=false;



 //Menü lap 2 --- Options
 menu.Addteg(jobbstart,0.3,jobbveg,0.8,2);

 menu.AddText(jobbstart,0.35,jobbveg,0.45,1,2,lang[12],true);      menufi[MI_GRAPHICS]:=menu.items[2,3];
 menu.AddText(jobbstart,0.45,jobbveg,0.55,1,2,lang[13],true);         menufi[MI_SOUND]:=menu.items[2,4];
 menu.AddText(jobbstart,0.55,jobbveg,0.65,1,2,lang[14],true);      menufi[MI_CONTROLS]:=menu.items[2,5];
 menu.AddText(jobbstart,0.65,jobbveg,0.75,1,2,lang[11],true);      menufi[MI_INTERFACE]:=menu.items[2,6];

 //Menü lap 3 --- Exit
 menu.Addteg(jobbstart,0.3,jobbveg,0.8,3);

 menu.AddText(jobbstart,0.5,jobbveg,0.6,0.5,3,lang[58],true);  // Idáig nem ért el a Menufi[]
 menu.AddText(jobbstart,0.6,jobbveg,0.7,0.5,3,lang[15],true);
 menu.AddText(jobbstart,0.4,jobbveg,0.5,0.5,3,lang[16],false);

 //Menü lap 4 --- Options-Graphics
 sor:=0.034;
 fent:=0.3;
 menu.Addteg(jobbstart,0.3,jobbveg,0.8,4);

 menu.AddText(jobbstart ,fent+sor*1,jobbstart+0.13*korr,fent+sor*2,0.5,4,lang[17],false);
 menu.Addcsuszka(jobbstart+0.13*korr,fent+sor*1,jobbveg-0.03*korr,fent+sor*2,1,4,'',0.5);       menufi[MI_DETAIL]:=menu.items[4,4];

 menu.AddText(jobbstart ,fent+sor*3,jobbstart+0.13*korr,fent+sor*4,0.5,4,lang[18],false);
 menu.Addcsuszka(jobbstart+0.13*korr,fent+sor*3,jobbveg-0.03*korr,fent+sor*4,1,4,'',0.5);       menufi[MI_EFFECTS]:=menu.items[4,6];

 menu.AddText(jobbstart ,fent+sor*5,jobbstart+0.13*korr,fent+sor*6,0.5,4,lang[77],false);
 menu.Addcsuszka(jobbstart+0.13*korr,fent+sor*5,jobbveg-0.03*korr,fent+sor*6,1,4,'',0.5);       menufi[MI_WATER]:=menu.items[4,8];

 menu.AddText(jobbstart ,fent+sor*7,jobbstart+0.13*korr,fent+sor*8,0.5,4,lang[78],false);
 menu.Addcsuszka(jobbstart+0.13*korr,fent+sor*7,jobbveg-0.03*korr,fent+sor*8,1,4,'',0.5);       menufi[MI_PARTICLE]:=menu.items[4,10];

 menu.AddText(jobbstart+korr*0.05,fent+sor*9,jobbstart+korr*0.2,fent+sor*10,0.5,4,lang[19],false);
 menu.AddText(jobbstart+korr*0.2 ,fent+sor*9,jobbstart+korr*0.3,fent+sor*10,1,4,'[X]',true); menufi[MI_RAIN]:=menu.items[4,12];

 menu.AddText(jobbstart+korr*0.05,fent+sor*11,jobbstart+korr*0.2,fent+sor*12,0.5,4,lang[79],false);
 menu.AddText(jobbstart+korr*0.2 ,fent+sor*11,jobbstart+korr*0.3,fent+sor*12,1,4,'[X]',true); menufi[MI_MOTIONBLUR]:=menu.items[4,14];

 menu.AddText(jobbstart+korr*0.05,fent+sor*13,jobbstart+korr*0.2,fent+sor*14,0.5,4,lang[74],false);
 menu.AddText(jobbstart+korr*0.2 ,fent+sor*13,jobbstart+korr*0.3,fent+sor*14,0.5,4,'[X]',true); menufi[MI_SCREENSHOT]:=menu.items[4,16];

 //menu.AddText(0.51 ,0.64,0.69,0.68,0.5,4,lang[75],false);
 //menu.AddText(0.69 ,0.64,0.77,0.68,0.5,4,'[X]',true); menufi[MI_IMPOSTER]:=menu.items[4,14];

 //Menü lap 5 --- Options-Sound
 menu.Addteg(jobbstart,0.3,jobbveg,0.8,5);

 menu.AddText(jobbstart ,0.350,jobbstart+0.13*korr,0.400,0.5,5,lang[20],false);
 menu.Addcsuszka(jobbstart+0.13*korr,0.350,jobbveg-0.03*korr,0.400,1,5,'',0.5);  menufi[MI_VOL]:=menu.items[5,4];

 menu.AddText(jobbstart ,0.450,jobbstart+0.13*korr,0.500,0.5,5,lang[21],false);
 menu.Addcsuszka(jobbstart+0.13*korr,0.450,jobbveg-0.03*korr,0.500,1,5,'',0.5);  menufi[MI_MP3_VOL]:=menu.items[5,6];

 menu.AddText(jobbstart ,0.520,jobbstart+0.15*korr,0.560,0.5,5,lang[22],false);
 menu.AddText(jobbstart+0.15*korr ,0.520,jobbstart+0.2*korr,0.560,1,5,'[X]',true); menufi[MI_TAUNTS]:=menu.items[5,8];

 menu.AddText(jobbstart+korr*0.2 ,0.520,jobbstart+0.35*korr,0.560,0.5,5,lang[23],false);
 menu.AddText(jobbstart+0.35*korr ,0.520,jobbstart+0.4*korr,0.560,1,5,'[X]',true); menufi[MI_R_CAR]:=menu.items[5,10];

 menu.AddText(jobbstart ,0.580,jobbstart+0.15*korr,0.650,0.5,5,lang[24],false);
 menu.AddText(jobbstart+0.15*korr ,0.560,jobbstart+0.2*korr,0.650,1,5,'[X]',true); menufi[MI_R_AMBIENT]:=menu.items[5,12];

 menu.AddText(jobbstart+korr*0.2 ,0.580,jobbstart+0.35*korr,0.650,0.5,5,lang[25],false);
 menu.AddText(jobbstart+0.35*korr ,0.580,jobbstart+0.4*korr,0.650,1,5,'[X]',true); menufi[MI_R_ACTION]:=menu.items[5,14];

 //Menü lap 6 --- Controls
 menu.Addteg(jobbstart,0.3,jobbveg,0.8,6);

 menu.AddText(jobbstart,0.350,jobbstart+korr*0.3,0.400,0.5,6,lang[26],false);
 menu.AddText(jobbveg-korr*0.2,0.350,jobbveg,0.400,0.5,6,'0.1',false);               menufi[MI_MOUSE_SENS_LAB]:=menu.items[6,4];
 menu.Addcsuszka(jobbstart+korr*0.05,0.420,jobbveg-korr*0.05,0.470,1,6,'',0.5);                  menufi[MI_MOUSE_SENS]:=menu.items[6,5];
 menu.AddText(jobbstart ,0.50,jobbstart+0.3*korr,0.560,0.5,6,lang[27],false);
 menu.AddText(jobbstart+0.3*korr ,0.50,jobbveg-0.03*korr,0.560,1,6,'[WTF]',true);              menufi[MI_MOUSE_ACC]:=menu.items[6,7];

 //Menü lap 7 --- Interface
 menu.Addteg(jobbstart,0.3,jobbveg,0.8,7);

 menu.AddText(jobbstart ,fent+sor*3,jobbstart+0.3*korr,fent+sor*4,0.5,7,lang[66],false);
 menu.AddText(jobbstart+0.3*korr ,fent+sor*3,jobbveg-0.03*korr,fent+sor*4,1,7,'[X]',true); menufi[MI_RADAR]:=menu.items[7,4];

 menu.AddText(jobbstart ,fent+sor*5,jobbstart+0.3*korr,fent+sor*6,0.5,7,lang[67],false);
 menu.AddText(jobbstart+0.3*korr ,fent+sor*5,jobbveg-0.03*korr,fent+sor*6,1,7,'[X]',true); menufi[MI_CHAT]:=menu.items[7,6];

 menu.AddText(jobbstart ,fent+sor*7,jobbstart+0.3*korr,fent+sor*8,0.5,7,lang[68],false);
 menu.AddText(jobbstart+0.3*korr ,fent+sor*7,jobbveg-0.03*korr,fent+sor*8,1,7,'[X]',true); menufi[MI_ZONES]:=menu.items[7,8];

 menu.AddText(jobbstart ,fent+sor*9,jobbstart+0.3*korr,fent+sor*10,0.5,7,lang[81],false);
 menu.AddText(jobbstart+0.3*korr ,fent+sor*9,jobbveg-0.03*korr,fent+sor*10,1,7,'[X]',true); menufi[MI_TIPS]:=menu.items[7,10];

 menu.AddText(jobbstart ,fent+sor*11,jobbstart+0.3*korr,fent+sor*12,0.5,7,lang[76],false);
 menu.AddText(jobbstart+0.3*korr ,fent+sor*11,jobbveg-0.03*korr,fent+sor*12,1,7,'[X]',true); menufi[MI_SAVEPW]:=menu.items[7,12];

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

  FEGYV_H31_T:menufi[MI_FEGYV].valueS:=fegyvernev(FEGYV_H31_T);
  FEGYV_H31_G:menufi[MI_FEGYV].valueS:=fegyvernev(FEGYV_H31_G);
 else
  myfegyv:=random(3)+random(2)*128;
 end;



 if fileexists('data\cfg\misc.cfg') then
 begin
  assignfile(fil2,'data\cfg\misc.cfg');
  reset(fil2);
  read(fil2,menufi[MI_MOUSE_SENS].elx);
  read(fil2,menufi[MI_VOL].elx);
  read(fil2,menufi[MI_MP3_VOL].elx);

  read(fil2,t1);
  
  myfejcucc:=round(t1);
  if (myfejcucc>stuffjson.GetNum(['hats'])-1) or (myfejcucc<0) then myfejcucc:=0;

  read(fil2,t1);
  opt_detail:=round(t1);
  read(fil2,t1);
  opt_postproc:=round(t1);
  read(fil2,t1);
  opt_water:=round(t1);
  read(fil2,t1);
  opt_particle:=round(t1);
  
  menufi[MI_DETAIL].elx:=opt_detail/DETAIL_MAX;
  menufi[MI_EFFECTS].elx:=opt_postproc/POSTPROC_MAX;
  menufi[MI_WATER].elx:=opt_water/WATER_MAX;
  menufi[MI_PARTICLE].elx:=opt_particle/PARTICLE_MAX;


  read(fil2,t1);
  opt_rain:=t1>0.5;

  read(fil2,t1);
  opt_motionblur:=t1>0.5;

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


  read(fil2,t1);
  png_screenshot:=t1>0.5;

  read(fil2,t1);
  opt_radar:=t1>0.5;

  read(fil2,t1);
  opt_nochat:=t1>0.5;

  read(fil2,t1);
  opt_zonename:=t1>0.5;

  read(fil2,t1);
  opt_tips:=t1>0.5;

  read(fil2,t1);
  savepw:=t1>0.5;
  if savepw then
  begin
    menufi[MI_REGISTERED].clicked:=true;
    lasthash:=decodehash(lasthash);
  end;


  closefile(fil2);
 end
 else
 begin
  menufi[MI_MOUSE_SENS].elx:=0.5;
  menufi[MI_VOL].elx:=0.5;
  menufi[MI_MP3_VOL].elx:=0.5;
  opt_detail:=DETAIL_MAX;
  opt_postproc:=POSTPROC_GREYSCALE;
  opt_water:=2;
  opt_particle:=2;
  opt_rain:=true;
  opt_motionblur:=false;
  png_screenshot:=false;
  opt_taunts:=true;
  opt_radar:=true;
  opt_nochat:=false;
  opt_zonename:=false;
  opt_tips:=true;
  savepw:=false;
  mouseacc:=true;
  mp3ambient:=false;
  mp3action:=false;
  mp3car:=true;
  myfejcucc:=random(stuffjson.GetNum(['hats']));
 end;

  //TODO remove

 //opt_imposters := false;

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
    WM_MOVE:begin wndpos.x:=LOWORD(lParam);wndpos.y:=HIWORD(lParam); end;
  end;
  Result:= DefWindowProc(hWnd, uMsg, wParam, lParam);
end;

procedure initnewmenu;
var
i:integer;
begin
 gobacktomenu:=false;
 menu.lap:=0;
 if kickmsg<>'' then
 begin
  menufi[MI_GAZMSG].visible:=true;
  menufi[MI_GAZMSG].valueS:=kickmsg;
  menu.tegs[0,1].visible:=true;
  kickmsg:='';
  //hardkick
  if hardkick then
  for i:=0 to 6 do
  begin
   menu.items[i,0].focusable:=false;
   menu.items[i,1].focusable:=false;
   menu.items[i,0].focused:=false;
   menu.items[i,1].focused:=false;
  end;
  
 end;
end;

procedure loadVideoIni;
var
  fil:TextFile;
  line,l2:string;
begin

  SCwidth := GetSystemMetrics(SM_CXSCREEN);
  SCheight := GetSystemMetrics(SM_CYSCREEN);
  texture_res:= 1;
  isnormals := true;
  iswindowed := false;
  ASPECT_RATIO:=SCwidth/SCheight;


  if FileExists('data/video.ini') then
  begin
    assignfile(fil,'data/video.ini');
    reset(fil);

    while not eof(fil) do
    begin
      ReadLn(fil,line);
      l2 := copy(line,1,pos('=',line)-1);

      if (l2 = 'width') then SCwidth := strtoint(copy(line,pos('=',line)+1,length(line)));
      if (l2 = 'height') then SCheight := strtoint(copy(line,pos('=',line)+1,length(line)));

      ASPECT_RATIO:=SCwidth/SCheight;

      if (l2 = 'multisampling') then multisampling := strtoint(copy(line,pos('=',line)+1,length(line)));
      if (l2 = 'windowed') then iswindowed := strtoint(copy(line,pos('=',line)+1,length(line)))=1;
      if (l2 = 'normals') then isnormals := strtoint(copy(line,pos('=',line)+1,length(line)))=1;
      if (l2 = 'langid') then nyelv := strtoint(copy(line,pos('=',line)+1,length(line))) and $3FF;
      if (l2 = 'texture_res') then texture_res := strtoint(copy(line,pos('=',line)+1,length(line)));

    end;
    closefile(fil);
  end;
  pixelX:= 1/SCwidth;
  pixelY:= 1/SCheight;
  ASPECT_RATIO:=SCwidth/SCheight;
  vertScale:= SCheight/600;
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
  bx,by:integer;
  adm:string;
 // thdid:Thandle;
  cont:TContext;
  WSAdat:TWSAData;
  tmpthdid:cardinal;
  virt:pdword;
  hostfile:Textfile;
{$IFDEF undebug}
type TNtSetInformationThread= Function(hProcess: THandle;ProcessInformationClass: Integer;ProcessInformation:pointer;ProcessInformationLength: Integer): Integer; stdcall;
var
  ntSIT:TNtSetInformationThread;
  hDebugObject:Thandle;
{$ENDIF}

label men,jatek,vege;
begin //                 BEGIIIN
{$IFDEF undebug}
  asm
//PEB mágia
    MOV eax,FS:[$30]
    ADD eax,2
    MOV ECX,[EAX]
    AND ECX,$ff
    jz @josag
    ret
    @josag: //
    MOV byte ptr [EAX],123
  end;

  NtSIT := GetProcAddress(GetModuleHandle( 'ntdll.dll' ),'NtSetInformationThread' );
  NtSIT(GetCurrentThread, $11,nil,0);
{$ENDIF}

  try

  //trolled
   longdateformat:='yyyymmdd';
   shortdateformat:='yyyymmdd'; //H31
   if (StrToInt(DateToStr(Date)) < 20141108) and (StrToInt(DateToStr(Date)) > 20141030) then
     isHalloween:=true;


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


  addfiletochecksum('data/gui/4919.png');
  if checksum<>524770836 then
  begin
    messagebox(0,'Do NOT alter the 4919 logo in ANY WAY please. We don''t like that.', 'Stickman Warfare',0);
    exit;
  end;
  checksum:=0;

  //more initialization
  heavyLOD:={$IFDEF heavyLOD}true{$ELSE} false{$ENDIF};
  wc.hInstance:= GetModuleHandle(nil);
  RegisterClassEx(wc);

  nyelv:=GetSystemDefaultLangID and $3FF;

  loadVideoIni;

  iswindowed:=iswindowed or commandlineoption('windowed');
  safemode:=commandlineoption('safemode');

  // Create the application's window
  if not iswindowed then
  begin
   bx:=getsystemmetrics(SM_CXFIXEDFRAME);
   by:=getsystemmetrics(SM_CYFIXEDFRAME);
   hWindow := CreateWindow('CLS12345', 'Stickman Warfare ',
                          WS_DLGFRAME, -bx,-by, SCWidth+2*bx, SCheight+by,
                          GetDesktopWindow, 0, wc.hInstance, nil)

  end
  else
  begin
   windowrect.Left:=0;
   windowrect.Top:=0;
   windowrect.Right:=SCWidth;
   windowrect.Bottom:=SCHeight;
   AdjustWindowRect(windowrect,WS_BORDER or WS_CAPTION,false);
   if not safemode  then
   hWindow := CreateWindow('CLS12345', 'Stickman Warfare',
                          WS_BORDER or WS_CAPTION, 0, 0,
                          windowrect.Right-windowrect.Left, windowrect.Bottom-windowrect.Top,
                          GetDesktopWindow, 0, wc.hInstance, nil)
  else
   hWindow := CreateWindow('CLS12345', 'Stickman Warfare (safe mode)',
                          WS_BORDER or WS_CAPTION, 0, 0,
                          windowrect.Right-windowrect.Left, windowrect.Bottom-windowrect.Top,
                          GetDesktopWindow, 0, wc.hInstance, nil);
  end;


  randomize;

  azadvwove:=advwove;
  csinaljfaszapointereket;




  assignfile(logfile,'log.txt');
  rewrite(logfile);
  writeln(logfile,'Stickman Warfare v2.'+inttostr((PROG_VER div 1000) mod 100)+'.'+inttostr((PROG_VER div 10) mod 100)+' ('+inttohex(-exe_checksum,8)+'). Log file.');
  writeln(logfile,'---------------------------------------');

  writeln(logfile,'Game started at:',formatdatetime( 'yyyy.mm.dd/hh:nn:ss',date+time));

  writeln(logfile,'Loading lang file (LANGID=',nyelv,')');       flush(logfile);
  addfiletochecksum('data/lang.ini');
  loadlang('data/lang.ini',nyelv);
  assignfile(hostfile,'data/server.cfg');
  reset(hostfile);
  readln(hostfile,servername);
  closefile(hostfile);
  writeln(logfile,'Server url: ',servername);flush(logfile);
  writeln(logfile,'Loading stuff.json');flush(logfile);
  laststate:='Loading stuff.json';

  addfiletochecksum('data/stuff.json');
  stuffjson:=TQJSON.CreateFromFile('data/stuff.json');

  perlin:=Tperlinnoise.create(stuffjson.GetInt(['random_seed']));
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

  ShowWindow(hWindow, SW_SHOWNORMAL);
  UpdateWindow(hWindow);


  writeln(logfile,'DirectSound and DirectInput Initialized');
  flush(logfile);

  //Initialize sockets
  WSAStartup(MAKEWORD(2,2),WSAdat);

  if SUCCEEDED(InitD3D(false,hWindow)) then
  begin
    writeln(logfile,'Direct3D Initialized');
    flush(logfile);


    menu:=T3dMenu.Create(g_pd3ddevice,safemode);
    if not LTFF(g_pd3dDevice, 'data/gui/chat.png',menu.chatbubble) then exit;
    addfiletoChecksum('data/gui/chat.png');
    writeln(logfile,'Loading menu');flush(logfile);
    laststate:='Loading menu';
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
    setlength(atlantiscoords,16);
    atlantiscoords[0]:=d3dxvector3(-795.21, -111.37, 703.21);
    atlantiscoords[1]:=d3dxvector3(-835.11, -115.76, 762.33);
    atlantiscoords[2]:=d3dxvector3(-824.49, -111.37, 782.27);
    atlantiscoords[3]:=d3dxvector3(-792.15, -111.18, 805.62);
    atlantiscoords[4]:=d3dxvector3(-776.17, -111.18, 801.73);
    atlantiscoords[5]:=d3dxvector3(-767.17, -111.18, 792.13);
    atlantiscoords[6]:=d3dxvector3(-758.12, -111.18, 782.84);
    atlantiscoords[7]:=d3dxvector3(-772.43, -114.78, 741.00);
    atlantiscoords[8]:=d3dxvector3(-803.80, -108.56, 741.15);
    atlantiscoords[9]:=d3dxvector3(-745.64, -101.47, 722.33);
    atlantiscoords[10]:=d3dxvector3(-728.29, -95.62, 729.60);
    atlantiscoords[11]:=d3dxvector3(-750.79, -85.66, 739.64);
    atlantiscoords[12]:=d3dxvector3(-772.92, -87.89, 786.63);
    atlantiscoords[13]:=d3dxvector3(-784.89, -110.33, 723.60);
    atlantiscoords[14]:=d3dxvector3(-798.48, -112.25, 766.31);
    atlantiscoords[15]:=d3dxvector3(-747.10, -111.48, 726.41);

    betuszin:=stuffjson.GetInt(['color_font']);
    color_menu_normal:=stuffjson.GetInt(['color_menu_normal']);
    color_menu_select:=stuffjson.GetInt(['color_menu_select']);
    color_menu_info:=stuffjson.GetInt(['color_menu_info']);
    if betuszin=0 then betuszin:=$0000B0;
    if color_menu_normal=0 then color_menu_normal:=$FFF45E1B;
    if color_menu_select=0 then color_menu_select:=$FFFFC070;
    if color_menu_info=0 then color_menu_info:=$FF000000;

    for i:=low(hudMessages) to high(hudMessages) do
      hudMessages[i]:=THUDMessage.create('',0); //init

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
      writeln(logfile,'Checksum:'+inttohex(checksum,8));
    {$IFDEF nochecksumcheck}
      checksum:=datachecksum;
    {$ENDIF}
     //writeln(logfile,'Exe Checksum:'+inttohex(execheck+1,8));
    //messagebox(0,Pchar(inttohex(checksum,8)),'Checksum',0);

      if (checksum<>datachecksum) {and (not canbeadmin) }then
      begin
        menufi[MI_GAZMSG].valueS:='Mod #'+inttohex(checksum,8)+#13#10#13#10+stuffjson.GetString(['modname']);
        menufi[MI_GAZMSG].visible:=true;
        menu.tegs[0,1].visible:=true;
        writeln(logfile,'Mod detected.');
      end;

    //Enter the menu message loop
      men:
      mp3menu:='data\menu_music.mp3';
      laststate:='Init Menu Scene';
      initmenuScene;
      laststate:='Init Menu FC';
      menu.FinishCreate;

      pleasenoexit:=false;
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
        end
        else
        begin
          if getactivewindow<>hwindow then sleep(10);
          MenuLoop;
          if menufi[MI_MP3_VOL].elx > 0.05 then
          zenefresh((menufi[MI_MP3_VOL].elx))
          else
          zenecleanup();
          CommitDeferredSoundStuff;
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
        end;
      end;
      menu.DeFinishCreate;
      if msg.message=WM_QUIT then goto vege;
      jatek:
      zenecleanup;
      mp3menu:='';
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

      multisc:=TMMOServerClient.Create(servername,25252+random(1024),
      copy(menufi[MI_NEV].valueS,1,15),
      lasthash,
      myfegyv,myfejcucc);

      multisc.weather:=felho.coverage; //ehh, ennyit a csodálatos OOP-rol.
      multip2p:=TMMOPeerToPeer.Create(multisc.myport,myfegyv);
      writeln(logfile,'Network initialized');


      laststate:='Initialzing game 3';

      respawn;

      laststate:='Initialzing game 4';
      if not iswindowed then
      AFstart;

      multisc.opt_nochat:=opt_nochat;

      {$IFDEF profiler}
      QueryPerformanceFrequency(profile_frequency);
      {$ENDIF}

      SetMainVolume(menufi[MI_VOL].elx);
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
        end
        else
        begin
          GameLoop;

          //beginthread(nil,0,zenefresh,pointer(@(menufi[MI_MP3_VOL].elx)),0,tmpthdid);
          if menufi[MI_MP3_VOL].elx > 0.05 then
          zenefresh((menufi[MI_MP3_VOL].elx))
          else
          zenecleanup();
          lostdevice:=lostdevice or (getactivewindow<>hwindow);
          if lostdevice then
          begin
           if iswindowed then
           begin
             lostdevice:=false;
             unfocused:=true;
           end
           else
           begin
             MSGProc(hwindow,WM_DESTROY,0,0);
           end;
          end
          else
          begin
            if unfocused then
              begin
                unfocused:=false;
//                dine:=TdinputEasy.create(hWindow);
                dine.Update(point(0,0));
               end;
          end;
          if gobacktomenu then
          begin
            menu.DrawLoadScreen(200);
            //war_kb:= false;
            //war_1v1:= false;
            //war_atlantis:= false;
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
      messagebox(0,PAnsiChar('InitGeometry error. '+laststate),Pchar(lang[30]),MB_SETFOREGROUND  or MB_ICONERROR);
      goto vege;
    end;
  end
  else
  messagebox(0,PAnsiChar('Unknown D3D error. '+laststate),Pchar(lang[30]),MB_SETFOREGROUND  or MB_ICONERROR);
  vege:
  zenecleanup;
  laststate:='Vege';
  if lostdevice then writeln(logfile,'Device lost');
  closeSound;

  WSACleanup;
  closewindow(hwindow);
  UnregisterClass('CLS12345', wc.hInstance);
  if not iswindowed and lostdevice then messagebox(0,Pchar(lang[31]),Pchar(lang[30]),MB_SETFOREGROUND or MB_ICONWARNING);
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
    messagebox(0,PChar(lang[28]+AnsiString(#13#10)+E.Message+AnsiString(#13#10)+'Aktuális esemény:'+laststate+AnsiString(#13#10)+lang[29]),Pchar(lang[30]),MB_SETFOREGROUND or MB_ICONERROR);
    writeln(logfile,'Unhandled error @'+inttohex(Integer(ExceptAddr),8)+':'+E.Message);
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

