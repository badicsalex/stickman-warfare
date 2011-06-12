program DXB;

uses
  Windows,
  Registry,
  sysutils,
  Messages,
  MMSystem,
  Direct3D9,
  //D3DFont,
  //graphics,
  DSUtil,
  DirectSound,
  D3DX9;

//-----------------------------------------------------------------------------
// Global variables
//-----------------------------------------------------------------------------
const
szel=10;
mag=20;
maxbon=23;
nullmat:d3dmaterial9=();
//strs:array [0..6] of string=(' !"#$%&X()*+,-./0123456789:;<=>?',
//                             '@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_',
//                             '`abcdefghijklmnopqrstuvwxyz{|}~',
//                             '€‚ƒ„…†‡ˆ‰Š‹ŒŽ‘’“”•–—˜™š›œžŸ',
//                             ' ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿',
//                             'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞß',
//                             'àáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ');
type
  PCustomVertex = ^TCustomVertex;
  TCustomVertex = packed record
    position:Td3dvector;     // The untransformed, 3D position for the vertex
    color: DWORD;         // The vertex color
    tu,tv:single; // Texture ccord
  end;

  Tfiz = record
    x,y:single;
    xs,ys:single;
  end;

  Tponti = record
   pos,seb:d3dvector;
   color:cardinal;
  end;

  Txtra = record
   pos,seb,xtra:D3dvector;
   typ:byte;
   arg:single;
  end;
const
 X_BALL=0;
 X_TIMROB=1;
 X_ROCKET=2;
 X_GHOSTBALL=3;
type
  Tkoc = record
    x,y,z,vy:single;
    r,g,b:single;
    extra:byte; //0 sima;1:Láthatalan;2,3,4:Vas;5:Nemlehet;6:Majdnemlehet;7:Robbanós;
    robban:boolean;
    tl:single;
    no:boolean;
  end;

  Tpaddle = record
   fog,mfog:boolean;
   at,ford,tuz:boolean;
   fx,meret,ball:single;
  end;
  PCustomVertexArray = ^TCustomVertexArray;
  TCustomVertexArray = array [0..100] of TCustomVertex;
const
nullkoc:Tkoc=();
D3DFVF_CUSTOMVERTEX = D3DFVF_XYZ or D3DFVF_DIFFUSE or D3DFVF_TEX1;
var
  Xtras:array of Txtra;
  g_pD3D: IDirect3D9 = nil; // Used to create the D3DDevice
  g_pd3dDevice: IDirect3DDevice9 = nil; // Our rendering device
  mtak,mgoly,mkoc,mbon,mszel,mplan,mhat:Id3dxmesh;
  kockak:array of Tkoc;
  bontex:array [1..maxbon] of IDirect3dtexture9;
  textex:array [1..4] of IDirect3dtexture9;
  pontik:array [1..500] of Tponti;
  sztex,ftex,htex:Idirect3dTexture9;
  szVB,pontVB:Idirect3dVertexBuffer9;
  hwindow:Thandle;
  golyo,abon:Tfiz;
  szelmat:Td3dmatrix;
  bontyp:byte;
  bonus:Tpaddle;
  inittime,score,highs:cardinal;
  //Kfont:Cd3dfont;
  ex,ey,cx,cy,czoom:single;
  vti:cardinal;
  az:shortint;
  frh:longint;
  szg,cam,dm:boolean;
  szim,lives,level,hponti:word;
  bvolt:byte;
  bscale,elt:single;
const
 BUFS=13;
 texpos:array [1..4] of TD3DXVector2=((x:-20.8;y:20),(x:-20.8;y:16),(x:13.8;y:20),(x:13.8;y:16));
 bnam:array [0..BUFS] of string=
    ('gfal','boing','oldal','humm','ding',
     'rob0','rob1','rob2','torik','ping',
     'gover','pici','byeball','piung');
 B_gfal=0;
 B_boing=1;
 B_oldal=2;
 B_humm=3;
 B_ding=4;
 B_rob=5;
 B_torik=8;
 B_ping=9;
 B_gover=10;
 B_pici=11;
 B_byeball=12;
 B_PEOW=13;
var
  DS:IDirectsound;
  DSBuf1:IDirectSoundBuffer;
  DSBuf:array [0..BUFS] of IDirectSoundBuffer;
function CCW(x1,y1,x2,y2:single):single;
var
az:single;
begin
 az:=y1*x2-y2*x1;
 if az>0 then result:=1;
 if az=0 then result:=0;
 if 0>az then result:=-1;
end;

function ccw2(xa,ya,x1,y1,x2,y2:single):single;
begin
 result:=ccw(x1-xa,y1-ya,x2-xa,y2-ya);
end;

function intersect(x11,y11,x12,y12,x21,y21,x22,y22:single):boolean;
begin
 result:=(0>=ccw2(x11,y11,x21,y21,x22,y22)*ccw2(x12,y12,x21,y21,x22,y22)) and
         (0>=ccw2(x21,y21,x11,y11,x12,y12)*ccw2(x22,y22,x11,y11,x12,y12));
end;
//0 le; 1 bal; 2 fel; 3 jobb
function intgoly(x,y:single;g1,g2:Tfiz;ir:byte):boolean;
begin
case ir of
 0:result:=intersect(x-(bonus.ball+0.5),y-(bonus.ball+0.5),x+(bonus.ball+0.5),y-(bonus.ball+0.5),g1.x,g1.y,g2.x,g2.y);
 1:result:=intersect(x+(bonus.ball+0.5),y-(bonus.ball+0.5),x+(bonus.ball+0.5),y+(bonus.ball+0.5),g1.x,g1.y,g2.x,g2.y);
 2:result:=intersect(x-(bonus.ball+0.5),y+(bonus.ball+0.5),x+(bonus.ball+0.5),y+(bonus.ball+0.5),g1.x,g1.y,g2.x,g2.y);
 3:result:=intersect(x-(bonus.ball+0.5),y-(bonus.ball+0.5),x-(bonus.ball+0.5),y+(bonus.ball+0.5),g1.x,g1.y,g2.x,g2.y);
end;
end;


function mytiz(hany:byte):cardinal;
var
i:byte;
the:cardinal;
begin
 the:=1;
 for i:=1 to hany do
  the:=the*10;
 result:=the;
end;
//-----------------------------------------------------------------------------
// Name: InitD3D()
// Desc: Initializes Direct3D
//-----------------------------------------------------------------------------
function InitD3D(hWnd: HWND): HRESULT;
var
  d3dpp: TD3DPresentParameters;
begin
  Result:= E_FAIL;
  randomize;
  // Create the D3D object.
  g_pD3D := Direct3DCreate9(D3D_SDK_VERSION);
  if (g_pD3D = nil) then
  begin
   messagebox(0,'Hiba a D3D-vel','Hiba!',0);
   exit;
  end;

  FillChar(d3dpp, SizeOf(d3dpp), 0);
  d3dpp.Windowed := true;
  d3dpp.BackBufferWidth:=800;
  d3dpp.BackBufferHeight:=600;
  d3dpp.SwapEffect := D3DSWAPEFFECT_DISCARD;
  d3dpp.BackBufferFormat := D3DFMT_UNKNOWN;
  d3dpp.EnableAutoDepthStencil := True;
  d3dpp.AutoDepthStencilFormat := D3DFMT_D16;

  // Create the D3DDevice
  Result:= g_pD3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, hWnd,
                               D3DCREATE_hardWARE_VERTEXPROCESSING,
                               @d3dpp, g_pd3dDevice);
  if FAILED(Result) then
  begin
    Result:=g_pD3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, hWnd,
                               D3DCREATE_SoftWARE_VERTEXPROCESSING,
                               @d3dpp, g_pd3dDevice);
    if FAILED(Result) then
     begin
      Result:=g_pD3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_REF , hWnd,
                               D3DCREATE_SoftWARE_VERTEXPROCESSING,
                               @d3dpp, g_pd3dDevice);
      if FAILED(Result) then
      begin
       Result:=E_FAIL;
       messagebox(0,'Hiba a D3D eszközzel','Hiba!',0);
       exit;
      end;
     end;
  end;

  // Turn off culling, so we see the front and back of the triangle
  g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);

  // Turn on D3D lighting, since we aren't providing our own vertex colors
  g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, itrue);

  // Turn on the zbuffer
  g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iTrue);

  Result:= S_OK;
end;

function Loadbuf(var buf:IDirectsoundbuffer;fs:string):Hresult;
var
dsc:_DSbufferdesc;
mfile:Cwavefile;
pwfx:Pwaveformatex;
pDSLockedBuffer: Pointer;
dwDSLockedBufferSize: DWORD;
dwWavDataRead: DWORD;
begin
 Result:= E_FAIL;
 mFile:=Cwavefile.Create;
 mfile.Open(Pchar(fs),pwfx,WAVEFILE_READ);
 zeromemory(@dsc,sizeof(dsc));
 dsc.dwSize:=sizeof(dsc);
 dsc.dwFlags:=DSBCAPS_CTRLFREQUENCY or DSBCAPS_CTRLPAN or DSBCAPS_CTRLVOLUME;;
 dsc.dwBufferBytes:=mfile.m_dwSize;
 dsc.lpwfxFormat:=mfile.m_pwfx;
 if failed(DS.CreateSoundBuffer(dsc,Buf,nil))then exit;

 Buf.Lock(0, mfile.m_dwSize,
                      @pDSLockedBuffer, @dwDSLockedBufferSize, nil, nil, 0);
 mfile.ResetFile;
 mfile.Read(pDSLockedBuffer,
                             dwDSLockedBufferSize,
                             @dwWavDataRead);
 Buf.Unlock(pDSLockedBuffer, dwDSLockedBufferSize, nil, 0);
 mfile.Destroy;
 Result:= S_OK;
end;

function InitDS:Hresult;
var
veg,i:integer;
mio:Hmmio;
adesc:_DSbufferdesc;
hib:HRESULT;
begin
 if failed(directsoundcreate(nil,DS,nil)) then exit;
 if failed(DS.SetCooperativeLevel(hwindow,DSSCL_PRIORITY)) then exit;
 zeromemory(@adesc,sizeof(adesc));
 adesc.dwSize:=sizeof(adesc);
 adesc.dwFlags:=DSBCAPS_PRIMARYBUFFER;
 hib:=DS.CreateSoundBuffer(adesc,DSBuf1,nil);
 if failed(hib)then exit;
 for i:=0 to BUFS do
 Loadbuf(DSBuf[i],'snd\'+bnam[i]+'.3db');
 Result:=S_OK
end;

procedure playb(mi:integer);
var
hib:Hresult;
begin
 if DSbuf[mi]<>nil then
 begin
  Dsbuf[mi].Restore;
  hib:=DSbuf[mi].Setfrequency(00);
  if 4>=mi then
  begin
   if 0.1>bonus.ball then DsBuf[mi].SetFrequency(50000);
   if bonus.ball>0.1 then DsBuf[mi].SetFrequency(25000);
   if 0.01>abs(bonus.ball-0.1) then DsBuf[mi].SetFrequency(0);
  end;
  DSbuf[mi+hib-hib].stop;
  DSbuf[mi].Play(0,0,0);
 end;
end;

procedure initfiz;
begin
 setlength(Xtras,1);
 Xtras[0].pos.x:=0;
 Xtras[0].pos.y:=-0.05-0.3-0.01;
 Xtras[0].seb.x:=0.04;
 Xtras[0].seb.y:=-0.08;
 Xtras[0].seb.z:=1;
 bvolt:=1;
 szim:=0;
 bscale:=0;
 cx:=0;
 cy:=D3DX_PI/3;
 czoom:=1.5;
 az:=1;
 bontyp:=0;
 zeromemory(@bonus,sizeof(bonus));
 bonus.meret:=1;
 bonus.ball:=0.10;
 Xtras[0].arg:=1;
 Xtras[0].pos.z:=0.5;
end;

procedure loadpaly(mit:string);
var
fili:file of Tkoc;
i,j,lngt:integer;
tekoc:Tkoc;
begin
 assignfile(fili,'trk\'+mit+'.dxb');
 reset(fili);
 lngt:=0;
 setlength(kockak,0);
 repeat
  read(fili,tekoc);
  lngt:=lngt+1;
  if lngt>length(kockak) then
   setlength(kockak,length(kockak)+1024);
  kockak[lngt-1]:=tekoc;
 until (tekoc.z=nullkoc.z);
 setlength(kockak,lngt-1);
 write(fili,nullkoc);
 closefile(fili);
end;

procedure initpaly(nxt:boolean); 
const
RGBlist:array[2..7,1..3] of single=
        ((0.2,0.2,0.2),
         (0.2,0.2,0.2),
         (0.2,0.2,0.2),
         (1,1,0),
         (1,1,1),
         (1,1,0));
var
x,y,z:integer;
akoc:Tkoc;
maxvy:single;
anim:byte;
begin
 frh:=10;
 if nxt then
  if fileexists('trk\'+inttostr(level+1)+'.dxb') then level:=level+1 else level:=1;
 loadpaly(inttostr(level));
 maxvy:=0;
 anim:=random(6);
 //anim:=5;
 for x:=0 to high(kockak) do
 begin
 case anim of
    0:kockak[x].vy:=2+(kockak[x].x-kockak[x].z)/4;
    1:kockak[x].vy:=-kockak[x].z/2;
    2:kockak[x].vy:=random(20)/4;
    3:kockak[x].vy:=4-abs(kockak[x].x)/2;
    4:kockak[x].vy:=2+sin(kockak[x].x*D3DX_PI/4);
    5:kockak[x].vy:=kockak[x].y*2;
   end;
 if kockak[x].vy>maxvy then maxvy:=kockak[x].vy;
 end;
 inittime:=timegettime+round(500*maxvy);
 exit;
 setlength(kockak,9*15);
 for y:=6 to 14 do
  for x:=-7 to 7 do
  begin
   akoc.x:=random(15)-7;
   akoc.y:=y;
   case anim of
    0:akoc.vy:=(x-y)/4;
    1:akoc.vy:=y/2;
    2:akoc.vy:=random(20)/4;
    3:akoc.vy:=4-abs(x)/2;
    4:akoc.vy:=2+sin(x*D3DX_PI/4);
   end;
   if akoc.vy>maxvy then maxvy:=akoc.vy;
   akoc.z:=-random(9)-6;
   if random(2)=0 then
   akoc.extra:=0+random(8)
   else
   akoc.extra:=0;
   if akoc.extra=0 then
   begin
    akoc.r:=random(256)/256;
    akoc.g:=random(256)/256;
    akoc.b:=random(256)/256;
   end
   else
   begin
    akoc.r:=RGBlist[akoc.extra,1];
    akoc.g:=RGBlist[akoc.extra,2];
    akoc.b:=RGBlist[akoc.extra,3];
   end;

   akoc.tl:=0;
   akoc.robban:=false;
   akoc.no:=false;
   kockak[(y-6)*15+(x+7)]:=akoc;
  end;
 inittime:=timegettime+round(500*maxvy);
end;

function loadtext:hresult;
label
exity;
var
i:integer;
begin
 result:=E_FAIL;
 if failed(D3DXcreatetexturefromfile(g_pd3ddevice,pchar('tex\tuz.3db'),ftex)) then exit;
 if failed(D3DXcreatetexturefromfile(g_pd3ddevice,pchar('tex\hatter.3db'),htex)) then exit;
 for i:=low(bontex) to high(bontex) do
  if failed(D3DXcreatetexturefromfile(g_pd3ddevice,pchar('tex\'+inttostr(i)+'.3db'),bontex[i])) then goto exity;
 for i:=1 to 4 do
   if failed(D3DXcreatetexturefromfile(g_pd3ddevice,pchar('tex\T'+inttostr(i)+'.3db'),textex[i])) then goto exity;
 result:=S_OK;
 exity:
end;

function initfont:Hresult;
var
pvertices:PCustomvertexarray;
i:integer;
begin
 result:=E_fail;
 if FAILED(g_pd3dDevice.CreateVertexBuffer(12*2*SizeOf(TCustomVertex),
                                            0, D3DFVF_CUSTOMVERTEX,
                                            D3DPOOL_DEFAULT, szVB, nil))
 then Exit;

 result:=D3DXcreatetexturefromfile(g_pd3ddevice,pchar('tex\hatter.3db'),htex);
 if failed(result) then exit;
 if failed(D3DXcreatetexturefromfile(g_pd3ddevice,pchar('tex\szam.3db'),sztex)) then exit;


 if FAILED(szVB.Lock(0, 0, Pointer(pVertices), 0))
  then Exit;

  for i:= 0 to 10 do
  begin
    pVertices[2*i+0].position := D3DXVector3(i,1.0, 0);
    pvertices[2*i+0].tu:=i/10;
    pvertices[2*i+0].tv:=0;
    pvertices[2*i+0].color:=0;
    pVertices[2*i+1].position := D3DXVector3(i, -1.0, 0);
    pvertices[2*i+1].tu:=i/10;
    pvertices[2*i+1].tv:=1;
    pvertices[2*i+1].color:=0;
  end;
  pVertices[2*11+0].position := D3DXVector3(0,1.0, 0);
  pvertices[2*11+0].tu:=0;
  pvertices[2*11+0].tv:=0;
  pvertices[2*11+0].color:=0;
  pVertices[2*11+1].position := D3DXVector3(0, -1.0, 0);
  pvertices[2*11+1].tu:=0;
  pvertices[2*11+1].tv:=1;
  pvertices[2*11+1].color:=0;
  szVB.Unlock;

 result:=S_OK;
end;

procedure dokill(hang:boolean);
begin
 if hang then playb(B_GOVER);
 if lives>0 then
 begin
  lives:=lives-1;
  initfiz;
 end
 else
 begin
  score:=0;
  lives:=3;
  level:=1;
  initpaly(false);
  initfiz;
 end;
end;


procedure pontmak(x,y,z,xs,ys,zs:single;coll:cardinal);
begin
 hponti:=hponti+1;
 if hponti>high(pontik) then hponti:=high(pontik);
 with pontik[hponti] do
 begin
  pos.x:=x;
  pos.y:=y;
  pos.z:=z;
  seb.x:=xs;
  seb.y:=ys;
  seb.z:=zs;
  color:=coll;
 end;
end;

procedure pontdel(ind:word);
begin
 pontik[ind]:=pontik[hponti];
 hponti:=hponti-1;
end;

procedure pontdo(ind:word;ido:single);
begin
 with pontik[ind] do
 begin
  seb.y:=seb.y-ido/5000;
  D3dxvec3add(pos,pos,seb);
 end;
end;

procedure pontwrit;
var
pvertices:PCustomvertexarray;
i:integer;
the:D3dvector;
begin
 if FAILED(pontVB.Lock(0, 0, Pointer(pVertices), 0))
  then Exit;

  for i:= 0 to hponti-1 do
  begin
    d3dxvec3scale(the,pontik[i+1].seb,2);
    D3dxvec3add(pVertices[2*i+0].position,pontik[i+1].pos,the);
    pvertices[2*i+0].tu:=0;
    pvertices[2*i+0].tv:=0;
    pvertices[2*i+0].color:=pontik[i+1].color;
    D3dxvec3subtract(pVertices[2*i+1].position,pontik[i+1].pos,the);
    pvertices[2*i+1].tu:=0;
    pvertices[2*i+1].tv:=0;
    pvertices[2*i+1].color:=pontik[i+1].color;;
  end;
  pontVB.Unlock;
end;

procedure pontall(ido:single);
var
i:integer;
begin
 i:=1;
 while hponti>=i do
 begin
  pontdo(i,ido);
  if -0.25>pontik[i].pos.y then pontdel(i) else
  inc(i);
 end;
 pontwrit;
end;

//-----------------------------------------------------------------------------
// Name: InitGeometry()
// Desc: Creates the scene geometry
//-----------------------------------------------------------------------------
function InitGeometry: HRESULT;
var
mtmesh:id3dxmesh;
tmat:Td3dmatrix;
begin
  Result:= E_FAIL;
  zeromemory(@nullmat,sizeof(nullmat));
  // Lövõke
  if FAILED(D3DXLoadMeshFromX('msh\taktak.x', D3DXMESH_SYSTEMMEM,
                                g_pd3dDevice, nil,
                                nil, nil, nil,
                                mtmesh)) then exit;
  Result:= mtmesh.CloneMeshFVF(mtmesh.GetOptions,
                                      mtmesh.GetFVF or D3DFVF_NORMAL,
                                      g_pd3dDevice, mtak);
  if FAILED(Result) then Exit;
  mtmesh:=nil;
  D3DXComputeNormals(mtak, nil);

  //golyó
  if FAILED(D3DXLoadMeshFromX('msh\goly.x', D3DXMESH_SYSTEMMEM,
                                g_pd3dDevice, nil,
                                nil, nil, nil,
                                mtmesh)) then exit;
  Result:= mtmesh.CloneMeshFVF(mtmesh.GetOptions,
                                      mtmesh.GetFVF or D3DFVF_NORMAL,
                                      g_pd3dDevice, mgoly);
  if FAILED(Result) then Exit;
  mtmesh:=nil;
  D3DXComputeNormals(mgoly, nil);
  //kocka
  if FAILED(D3DXLoadMeshFromX('msh\koci.x', D3DXMESH_MANAGED,
                                g_pd3dDevice, nil,
                                nil, nil, nil,
                                mtmesh)) then exit;
  Result:= mtmesh.CloneMeshFVF(mtmesh.GetOptions,
                                      mtmesh.GetFVF or D3DFVF_NORMAL,
                                      g_pd3dDevice, mkoc);
  if FAILED(Result) then Exit;
  mtmesh:=nil;
  D3DXComputeNormals(mkoc, nil);

   //Bónusz
  if FAILED(D3DXLoadMeshFromX('msh\gmb.x', D3DXMESH_MANAGED,
                                g_pd3dDevice, nil,
                                nil, nil, nil,
                                mtmesh)) then exit;
  Result:= mtmesh.CloneMeshFVF(mtmesh.GetOptions,
                                      mtmesh.GetFVF or D3DFVF_NORMAL,
                                      g_pd3dDevice, mbon);
  if FAILED(Result) then Exit;
  mtmesh:=nil;
  D3DXComputeNormals(mbon, nil);

  //Szél
  if FAILED(D3DXLoadMeshFromX('msh\szel.x', D3DXMESH_SYSTEMMEM,
                                g_pd3dDevice, nil,
                                nil, nil, nil,
                                mtmesh)) then exit;
  Result:= mtmesh.CloneMeshFVF(mtmesh.GetOptions,
                                      mtmesh.GetFVF or D3DFVF_NORMAL,
                                      g_pd3dDevice, mszel);
  if FAILED(Result) then Exit;
  mtmesh:=nil;
  D3DXComputeNormals(mszel, nil);


  if FAILED(g_pd3dDevice.CreateVertexBuffer(length(pontik)*2*SizeOf(TCustomVertex),
                                            0, D3DFVF_CUSTOMVERTEX,
                                            D3DPOOL_DEFAULT, pontVB, nil))
  then Exit;


  //D3DXCreatepolygon(g_pd3ddevice,1,4,mplan,nil);
  D3dxmatrixscaling(szelmat,szel*2,2.05,mag);
  d3dxmatrixtranslation(tmat,0,0.75,-mag/2);
  d3dxmatrixmultiply(szelmat,szelmat,tmat);
  D3DXMatrixRotationY(tmat,D3DX_PI*1.5);
  d3dxmatrixmultiply(szelmat,tmat,szelmat);
  if failed(loadtext) then exit;
  Result:= S_OK;
  lives:=0;
  dokill(false);
  initfont;
  //kfont:=Cd3DFont.Create('Arial',10);
  //if failed(kfont.InitDeviceObjects(g_pd3ddevice)) then exit;
  //kfont.RestoreDeviceObjects;
end;

procedure doclck;
var
i:integer;
begin
 for i:=0 to high(Xtras) do
  if (Xtras[i].typ=X_BALL) and (Xtras[i].arg=1) then
  Xtras[i].arg:=0;


end;

procedure corrbill;
begin
 ey:=0;
 if szg then ex:=golyo.x+az*0.5;
 if szg and (random(100)=0) then doclck;
 if szg then cx:=cx+0.01*az;
 if szg then cy:=cy+(sin(timegettime/1000))/200;
 if ex>szel-bonus.meret then ex:=szel-bonus.meret;
 if -(szel-bonus.meret)>ex then ex:=-(szel-bonus.meret);
end;

procedure rob(ax,ay,az:single);
var
i:integer;
begin
 for i:=0 to high(kockak) do
 with kockak[i] do
 begin
  if (1.1>(abs(x-ax)))and (0.6>(abs(y-ay))) and (1.1>(abs(z-az))) then
   no:=true;
   robban:=true;
 end;
 playb(B_rob+random(3));
end;

function ellenorpaly:boolean;
var
bol:boolean;
i:integer;
begin
 bol:=true;
 for i:=0 to high(kockak) do
 begin
  bol:=bol and (kockak[i].extra=5);
  kockak[i].vy:=0;
 end;
 result:=bol
end;

procedure mXtra(typ:byte;xx,yy,zz,xs,ys,zs,arg:single);
var
xt:TXtra;
begin
 setlength(Xtras,length(Xtras)+1);
 xt.pos.y:=yy;
 xt.pos.z:=zz;
 xt.pos.x:=xx;
 xt.seb.y:=ys;
 xt.seb.z:=zs;
 xt.seb.x:=xs;
 xt.arg:=arg;
 xt.typ:=typ;
 Xtras[high(Xtras)]:=xt;
end;

procedure deXtra(ind:word);
var
i:integer;
begin
 Xtras[ind]:=Xtras[high(Xtras)];
 setlength(Xtras,high(Xtras));
end;

procedure dopaly(ido:single);
var
i,j:integer;
bol:boolean;
begin
 i:=0;
 while high(kockak)>=i do
 begin
 if 10>=inittime then kockak[i].vy:=0;
  if kockak[i].no then
  begin
  kockak[i].vy:=0;
  kockak[i].tl:=kockak[i].tl+ido;
  score:=score+round(ido*10);
  if kockak[i].tl>100 then
   begin
    szim:=szim+1;
    if dm then szim:=100;
    if (bontyp=0) and (szim>10) then
    begin
     bontyp:=random(maxbon)+1;
     abon.x:=kockak[i].x;
     abon.y:=kockak[i].z;
     abon.xs:=(random(1000)/500-1)/6;
     abon.ys:=(random(1000)/500-1)/3;
     szim:=0;
    end;
    if kockak[i].extra=7 then rob(kockak[i].x,kockak[i].y,kockak[i].z);
    for j:=i to high(kockak)-1 do
    kockak[j]:=kockak[j+1];
    setlength(kockak,high(kockak));
   end
   else
    i:=i+1;
  end
  else
   i:=i+1;
 end;
 for i:=0 to high(kockak) do
 if kockak[i].y>0 then
 begin
  bol:=false;
  kockak[i].vy:=0;
  for j:=high(kockak) downto i+1 do
   begin
    bol:=(0.5>abs(kockak[j].x-kockak[i].x));
    bol:=bol and (0.01>=kockak[j].y);
    bol:=bol and (0.5>abs(kockak[j].z-kockak[i].z));
    if bol then break;
   end;
  if not bol then kockak[i].y:=kockak[i].y-0.002*ido
 end;
 if ellenorpaly then
 begin
  initfiz;initpaly(true);
 end;
end;
procedure palypurc(var goly,vgoly:Tfiz;ido:single);
var
i,j:integer;
akoc:Tkoc;
begin
 for i:=0 to high(kockak) do
 begin
  if (0.35>kockak[i].y) and (not kockak[i].no) and
     (kockak[i].x+(bonus.ball+0.5)>=goly.x) and (kockak[i].x-(bonus.ball+0.5)<=golyo.x)  and
     (kockak[i].z+(bonus.ball+0.5)>=goly.y) and (kockak[i].z-(bonus.ball+0.5)<=golyo.y) then
   begin
    if not bonus.at then
    begin
    if intgoly(kockak[i].x,kockak[i].z,goly,vgoly,0) and (goly.ys>0) then goly.ys:=-goly.ys;//le
    if intgoly(kockak[i].x,kockak[i].z,goly,vgoly,2) and (0>goly.ys) then goly.ys:=-goly.ys;//fel
    if intgoly(kockak[i].x,kockak[i].z,goly,vgoly,1) and (0>goly.xs) then goly.xs:=-goly.xs;//bal
    if intgoly(kockak[i].x,kockak[i].z,goly,vgoly,3) and (goly.xs>0) then goly.xs:=-goly.xs;//jobb
    end else playb(B_PING);
    kockak[i].robban:=false;
    if (kockak[i].extra>0) and (7>kockak[i].extra) then
    for j:=0 to 10 do
     pontmak(golyo.x,0,golyo.y,random(10)/100-0.05,random(10)/100,0.05-random(10)/100,random($FF)*$010101);

    if not bonus.at then
     if not bonus.tuz then
    case kockak[i].extra of
     0:begin kockak[i].no:=true;playb(B_PING); end;
     1:begin kockak[i].extra:=0; playb(B_TORIK); end;
     2:begin kockak[i].extra:=0;playb(B_DING);  end;
     3:begin kockak[i].extra:=2; playb(B_DING); end;
     4:begin kockak[i].extra:=3; playb(B_DING); end;
     5:begin ; playb(B_GFAL); end;
     6:begin kockak[i].extra:=5; playb(B_DING); end;
     7:begin kockak[i].no:=true;
        kockak[i].robban:=true;
     end;
     end
      else
       rob(kockak[i].x,kockak[i].y,kockak[i].z)
     else
      if not bonus.tuz then
       kockak[i].no:=true
      else
      rob(kockak[i].x,kockak[i].y,kockak[i].z);
     golyo.x:=vgoly.x;
     golyo.y:=vgoly.y;
   end;
 end;
end;

procedure dogoly(ido:single;var goly:TXtra);
label
exity;
var
vgoly:Tfiz;
i:integer;
begin
 golyo.x:=goly.pos.x;
 golyo.y:=goly.pos.y;
 golyo.xs:=goly.seb.x;
 golyo.ys:=goly.seb.y;
 if 3>goly.seb.z then goly.seb.z:=goly.seb.z+ido/20000;
 vgoly:=golyo;
 golyo.x:=golyo.x+golyo.xs*goly.seb.z*ido/15;
 golyo.y:=golyo.y+golyo.ys*goly.seb.z*ido/15;
 if goly.arg=1 then
 begin
  golyo.x:=ex+goly.pos.z;
  golyo.y:=-bonus.ball-0.3-0.01;
  goto exity;
 end;
 if golyo.x>(szel-bonus.ball) then
 begin
  golyo.x:=szel-bonus.ball;
  golyo.xs:=-golyo.xs;
  az:=-az;
  playb(B_OLDAL);
 end;
 if -(szel-bonus.ball)>golyo.x then
 begin
  golyo.x:=-szel+bonus.ball;
  golyo.xs:=-golyo.xs;
  az:=-az;
  playb(B_OLDAL);
 end;

 if -(mag-bonus.ball)>golyo.y then
 begin
  golyo.y:=-mag+bonus.ball;
  golyo.ys:=-golyo.ys;
  playb(B_OLDAL);
 end;
 if (golyo.y>-bonus.ball-0.3) and (golyo.x>ex-bonus.meret) and (ex+bonus.meret>golyo.x) then
 begin
  if bonus.mfog then
   playb(B_humm)
  else
  if goly.seb.z>2.5 then
   playb(B_PEOW)
  else
     playb(B_BOING);
  golyo.y:=-bonus.ball-0.3-0.01;
  golyo.xs:=(golyo.x-ex)/(bonus.meret*1.2);
  golyo.ys:=-sqrt(1-golyo.xs*golyo.xs);
  golyo.xs:=golyo.xs/10;
  golyo.ys:=golyo.ys/10;
  if bonus.mfog then
  begin
   goly.arg:=1;
   goly.pos.z:=golyo.x-ex;
  end
  else
  if goly.seb.z>2.5 then
  begin
   for i:=0 to 10 do
    pontmak(golyo.x,0,golyo.y,random(10)/100,random(10)/100,-random(10)/100,$00FF0000+random($FF)*$0100);
  end;
 end;
 if golyo.y>0.1 then
 begin
  playb(B_Byeball);
  goly.arg:=-1;
 end;
 palypurc(golyo,vgoly,ido);
 elt:=elt+ido;
 if (bonus.tuz) and (elt>50) then
 begin
  elt:=0;
  pontmak(golyo.x,0,golyo.y,golyo.xs/2+golyo.ys/2*(random(100)-50)/100,0.05,golyo.ys/2+golyo.xs/2*(random(100)-50)/100,$00FF0000+random($FF)*$0100);
 end;
 exity:
 goly.pos.x:=golyo.x;
 goly.pos.y:=golyo.y;
 goly.seb.x:=golyo.xs;
 goly.seb.y:=golyo.ys;
end;

procedure doRob(var myx:Txtra;ido:single);
begin
 myx.arg:=myx.arg-ido;
 if 0>myx.arg then rob(myx.pos.x,myx.pos.y,myx.pos.z);
end;

function doXtra(ind:word;ido:single):boolean;
var
xt:Txtra;
begin
 result:=false;
 xt:=Xtras[ind];
 case xt.typ of
  X_BALL:dogoly(ido,xt);
  X_TIMROB:dorob(xt,ido);
 end;
 if 0>xt.arg then begin deXtra(ind);exit end;
 result:=true;
 Xtras[ind]:=xt;
end;

procedure DoallXtra(ido:single);
var
i:integer;
begin
 i:=0;
 if high(Xtras)>=0 then
 repeat
  if doXtra(i,ido) then i:=i+1;
 until i>high(Xtras);
 if 0>high(Xtras) then dokill (true);
end;

procedure dupball;
var
i:integer;
begin
 for i:=0 to high(Xtras) do
  if Xtras[i].typ=0 then mXtra(0,Xtras[i].pos.x,Xtras[i].pos.y,Xtras[i].pos.z,-Xtras[i].seb.x,-Xtras[i].seb.y,Xtras[i].seb.z,Xtras[i].arg);
end;

procedure Xball;
var
i:integer;
begin
 for i:=-4 to +4 do
  mXtra(0,0,0,bonus.meret*i/4,0,1,3,1);
end;

procedure allseb(seb:single);
var
i:integer;
begin
 for i:=0 to high(Xtras) do
  if Xtras[i].typ=0 then Xtras[i].seb.z:=seb;
end;


procedure Eball;
var
i,j,hig:integer;
si,co,ang:single;
begin
 hig:=high(Xtras);
 for j:=0 to 7 do
 begin
  ang:=j*D3DX_PI/4+D3DX_PI/8;
  si:=sin(ang)/10;
  co:=cos(ang)/10;
  for i:=0 to hig do
   if Xtras[i].typ=0 then mXtra(0,Xtras[i].pos.x,Xtras[i].pos.y,Xtras[i].pos.z,si,co,2,Xtras[i].arg);
 end;
end;

procedure suprob(brut:boolean);
var
i:integer;
begin
 for i:=0 to high(kockak) do
 if (kockak[i].extra=7) or brut then
 begin
  kockak[i].no:=true;
  kockak[i].robban:=true;
 end;
end;

procedure zrob;
var
i:integer;
begin
 for i:=0 to high(kockak) do
 if 0.1>kockak[i].y then
 begin
  kockak[i].no:=true;
  kockak[i].robban:=false;
 end;
end;

procedure zap;
var
i:integer;
begin
 for i:=0 to high(kockak) do
 if not (kockak[i].extra=7) then
 begin
  kockak[i].extra:=0;
 end;
end;

procedure robmax;
var
i,j:integer;
begin
 for i:=0 to high(kockak) do
 if (kockak[i].extra=7) then
 begin
  for j:=0 to high(kockak) do
  if (1.1>(abs(kockak[i].x-kockak[j].x)))and (1.1>(abs(kockak[i].y-kockak[j].y))) and (1.1>(abs(kockak[i].z-kockak[j].z))) then
   begin
    kockak[j].extra:=8;
   end;
 end;
 for i:=0 to high(kockak) do
  if (kockak[i].extra=8) then
  kockak[i].extra:=7;
end;

procedure eltimrob;
var
i,az:integer;
begin
 for i:=0 to 5 do
 begin
  az:=random(length(kockak));
  mXtra(X_TIMROB,kockak[i].x,kockak[az].y,kockak[az].z,0,0,0,random(i*400));
 end;
end;

procedure pluszkoc;
var
i,j,az:integer;
bol:boolean;
heh:single;
begin
 setlength(kockak,length(kockak)+50);
 //{
 for i:=high(kockak)-50 downto 0 do
 begin
  kockak[i+50]:=kockak[i];
 end;
 //}
 for i:=1 to 50 do
  begin
   az:=i-1;
   //az:=high(kockak)-50+i;
   kockak[az].extra:=0;
   kockak[az].vy:=0;
   kockak[az].r:=random(3)/2;
   kockak[az].g:=random(3)/2;
   kockak[az].b:=random(3)/2;
   kockak[az].tl:=0;
   heh:=0;
   repeat
    heh:=heh+0.5;
    kockak[az].x:=szel-2-random(szel*2-2)+0.5;
    kockak[az].y:=heh;
    kockak[az].z:=-5.5-random(mag-6);
    bol:=false;
    for j:=0 to az-1 do
     bol:=bol or ((0.1>abs(kockak[az].x-kockak[j].x)) and
                  ((kockak[az].y-0.6)<kockak[j].y) and
                  (0.1>abs(kockak[az].z-kockak[j].z)));
   until not bol;
  end;
end;
procedure dobon(ido:single);
begin
 abon.ys:=abon.ys+ido/3000;
 abon.x:=abon.x+abon.xs*ido/30;
 abon.y:=abon.y+abon.ys*ido/30;
 if abon.x>(szel-0.05) then
 begin
  abon.x:=szel-0.1;
  abon.xs:=-abon.xs;
  az:=-az;
 end;

 if -(szel-0.25)>abon.x then
 begin
  abon.x:=-szel+0.25;
  abon.xs:=-abon.xs;
  az:=-az;
 end;

 if -(mag-0.25)>abon.y then
 begin
  abon.y:=-mag+0.25;
  abon.ys:=-abon.ys;
 end;
 //if dm then bonus.tuz:=true;
 if (abon.y>-0.25-0.3) and (abon.x>ex-bonus.meret) and (ex+bonus.meret>abon.x) then
 begin
  playb(B_PICI);
  score:=score+5210;
  case bontyp of
   1:begin zeromemory(@bonus,sizeof(bonus)); bonus.meret:=1; bonus.ball:=0.1;end;
   2:bonus.at:=true;
   3:bonus.mfog:=true;
   4:dupball;
   5:if 4>bonus.meret then bonus.meret:=bonus.meret*2;
   6:if bonus.meret>0.5 then bonus.meret:=bonus.meret/2;
   7:Xball;
   8:bonus.ball:=0.05;
   9:bonus.ball:=0.15;
   10:inc(lives);
   11:allseb(3);
   12:allseb(1);
   13:Eball;
   14:suprob(false);
   15:suprob(true);
   16:zrob;
   17:setlength(Xtras,0);
   18:zap;
   19:robmax;
   20:eltimrob;
   21:pluszkoc;
   22:bonus.ford:=not bonus.ford;
   23:bonus.tuz:=true;
  end;
  bvolt:=bontyp;
  bscale:=100;
  bontyp:=0;
 end;

 if abon.y>0 then
 begin
  bontyp:=0;
 end;

end;
procedure animpaly(ido:single);
var
i:integer;
begin
 for i:=0 to high(kockak) do
 if kockak[i].vy>0 then
  kockak[i].vy:=kockak[i].vy-0.002*ido
 else
  kockak[i].vy:=0;
end;

procedure dofiz;
var
ati,kti,aj:cardinal;
i:integer;
begin
 ati:=timegettime;
 if vti=0 then vti:=timegettime;
 if ati>vti then
   kti:=ati-vti
 else
 kti:=0;
 if score>highs then highs:=score;
 corrbill;
 if inittime>timegettime then
  animpaly(kti)
 else
 begin
  aj:=1;
  if (frh>10) and (kti>20) then aj:=frh div 2;
  if 15>kti then aj:=10;
  if 10>kti then aj:=20;
  if 17>kti then aj:=3;

  if kti>50 then aj:=aj+10;
  if kti>20 then
  frh:=frh-aj
  else
  frh:=frh+aj;
  if 1>frh then frh:=1;
  for i:=1 to frh do
  begin
   dopaly(kti/frh);
   doallXtra(kti/frh);
   if bontyp>0 then
    dobon(kti/frh);
  end
 end;
 pontall(kti);
 vti:=ati;
 if bscale>0 then bscale:=bscale-kti/20 else bscale:=0;
end;

procedure sr(ezt:Iunknown);
begin
 if ezt<>nil then
 begin
  //ezt._Release;
  ezt:=nil;
 end;
end;

procedure cleanDS;
var
i:integer;
begin
 if DS=nil then exit;
 i:=0;
 for i:=0 to BUFS do
 if DSBuf[i]<>nil then
 begin
  //messagebox(0,pchar(inttostr(i)),'',0);
  DSBuf[i].Stop;
  //DSBuf[i]._Release;
  DSBuf[i]:=nil;
 end;


 if DSBuf1<>nil then
 begin
  DSBuf1.Stop;
  //DSBuf1._Release;
  DSBuf1:=nil;
 end;

 SR(ds);
end;
//-----------------------------------------------------------------------------
// Name: Cleanup()
// Desc: Releases all previously initialized objects
//-----------------------------------------------------------------------------
procedure Cleanup;
var
i:integer;
begin
  //áfílgúd dödodöö
  //Cleanup comes here:
 // if kfont<>nil then kfont.Destroy;
  for i:=low(bontex) to high(bontex) do
   sr(bontex[i]);
  sr(szVB);
  sr(sztex);
  sr(mszel);
  sr(mbon);
  sr(mtak);
  sr(mgoly);
  sr(mkoc);
  sr(g_pd3ddevice);
  sr(g_pd3d);
  cleanDS;
  exit;
end;

//-----------------------------------------------------------------------------
// Name: SetupMatrices()
// Desc: Sets up the world, view, and projection transform matrices.
//-----------------------------------------------------------------------------
procedure SetupMatrices;
var

  matWorld,matrot: TD3DMatrix;
  iTime: LongWord;
  fAngle: Single;

  vEyePt, vLookatPt, vUpVec: TD3DVector;
  matView: TD3DMatrix;
  matProj: TD3DMatrix;
begin
  g_pd3ddevice.SetMaterial(nullmat);
  d3dxmatrixtranslation(matworld,ex,0,ey);
  g_pd3dDevice.SetTransform(D3DTS_world, matworld);
  d3dxmatrixscaling(matworld,bonus.meret,1,1);
  g_pd3ddevice.MultiplyTransform(D3DTS_world,matworld);
  d3dxmatrixrotationx(matworld,(timegettime mod 1000)*2*d3dx_pi/1000);
  g_pd3ddevice.MultiplyTransform(D3DTS_world,matworld);

  //setwindowtex(hwindow,pchar(floattostr(i1)));
  vEyePt:= D3DXVector3(25*sin(cx)*sin(cy)*czoom,25*cos(cy)*czoom,-mag/2+25*cos(cx)*sin(cy)*czoom);
  vLookatPt:= D3DXVector3(0,6,-mag/2);
  vUpVec:= D3DXVector3(0.0, 1.0, 0.0);
  D3DXMatrixLookAtLH(matView, vEyePt, vLookatPt, vUpVec);
  g_pd3dDevice.SetTransform(D3DTS_VIEW, matView);
  //g_pd3ddevice.SetRenderState(D3DRS_FILLMODE,D3DFILL_WIREFRAME);
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/4, 1.0, 1.0, 2000.0);
  g_pd3dDevice.SetTransform(D3DTS_PROJECTION, matProj);

end;

procedure SetupMatricesgoly;
var
  matWorld,matrot: TD3DMatrix;
begin
  d3dxmatrixtranslation(matworld,golyo.x,0,golyo.y);
  g_pd3dDevice.SetTransform(D3DTS_world, matworld);
  //d3dxmatrixscaling(matworld,0.1,0.1,0.1);
  //g_pd3ddevice.MultiplyTransform(D3DTS_world,matworld);
end;

procedure SetupMatricesbon;
var
  matWorld,matrot: TD3DMatrix;
begin
  d3dxmatrixtranslation(matworld,abon.x,0,abon.y);
  g_pd3dDevice.SetTransform(D3DTS_world, matworld);
  d3dxmatrixscaling(matworld,0.7,0.7,0.7);
  g_pd3ddevice.MultiplyTransform(D3DTS_world,matworld);
  d3dxmatrixrotationx(matworld,-D3DX_PI*3/4);
  g_pd3ddevice.MultiplyTransform(D3DTS_world,matworld);
  g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $00FFFFFF);
end;

procedure SetupLights;
var
  mtrl: TD3DMaterial9;
  vecDir: TD3DXVector3;
  light: TD3DLight9;
begin
  // Set up a material. The material here just has the diffuse and ambient
  // colors set to yellow. Note that only one material can be used at a time.
  g_pd3ddevice.SetMaterial(nullmat);
  ZeroMemory(@mtrl, SizeOf(TD3DMaterial9));
  mtrl.Diffuse.r := 1.0; mtrl.Ambient.r := 1;
  mtrl.Diffuse.g := 1.0; mtrl.Ambient.g := 1;
  mtrl.Diffuse.b := 1.0; mtrl.Ambient.b := 1;
  mtrl.Diffuse.a := 0.5; mtrl.Ambient.a := 0.5;
  g_pd3dDevice.SetMaterial(mtrl);

  ZeroMemory(@light, SizeOf(TD3DLight9));
  light._Type      := D3DLIGHT_DIRECTIONAL;
  light.Diffuse.r  := 1;
  light.Diffuse.g  := 1;
  light.Diffuse.b  := 1;
  vecDir:= D3DXVector3(-1.0,
                       -1.0,
                       1.0);
  D3DXVec3Normalize(light.Direction, vecDir);
  light.Range := 1000.0;
  g_pd3dDevice.SetLight(0, light);
  g_pd3dDevice.LightEnable(0, True);
  g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iTrue);

  // Set up the default texture states.
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_Selectarg2);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP,   D3DTOP_DISABLE);

    // Set up the default sampler states.
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR );
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR );
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_NONE );
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  1 );
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  1 );
  // Finally, turn on some ambient light.
  g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $00404040);
end;

procedure renderpaly;
const
RGBlist:array[2..7,1..2,1..3] of single=
        (((0.4,0.4,0.4),(0,0,0)),
         ((0.6,0.6,0.6),(0,0,0)),
         ((0.8,0.8,0.8),(0,0,0)),
         ((2,0,0),(0,2,0)),
         ((2,0,2),(0,2,0)),
         ((2,2,0),(1,0,0)));
var
i:integer;
matworld:D3dmatrix;
mtrl:d3dmaterial9;
begin
 zeromemory(@mtrl,sizeof(mtrl));
 for i:=0 to high(kockak) do
 if (kockak[i].extra<>1) or kockak[i].no then
  with kockak[i] do
  begin
   d3dxmatrixtranslation(matworld,x,y+vy,z);
   if robban and no then
   begin
    mtrl.Diffuse.r:=2;
    mtrl.Diffuse.g:=2;
    mtrl.Diffuse.b:=1;
    mtrl.ambient.r:=2;
    mtrl.ambient.g:=2;
    mtrl.ambient.b:=1;
   end
   else
   if extra=0 then
   begin
    mtrl.Diffuse.r:=r;
    mtrl.Diffuse.g:=g;
    mtrl.Diffuse.b:=b;
    mtrl.ambient.r:=r/2;
    mtrl.ambient.g:=g/2;
    mtrl.ambient.b:=b/2;
   end
   else
   begin
    mtrl.Diffuse.r:=RGBlist[extra,1,1];
    mtrl.Diffuse.g:=RGBlist[extra,1,2];
    mtrl.Diffuse.b:=RGBlist[extra,1,3];
    mtrl.ambient.r:=RGBlist[extra,2,1];
    mtrl.ambient.g:=RGBlist[extra,2,2];
    mtrl.ambient.b:=RGBlist[extra,2,3];
   end;
   begin
   end;
   g_pd3dDevice.SetMaterial(mtrl);
   g_pd3dDevice.SetTransform(D3DTS_world, matworld);
   if extra=7 then
   begin
    d3dxmatrixscaling(matworld,0.9+random(100)/500,0.9+random(100)/500,0.9+random(100)/500);
    g_pd3dDevice.multiplyTransform(D3DTS_world, matworld);
   end;
   if no then
   begin
   if not kockak[i].robban then
    d3dxmatrixscaling(matworld,(100-tl)/100,(100-tl)/100,(100-tl)/100)
   else
    d3dxmatrixscaling(matworld,(100+tl)/100,(100+tl)/100,(100+tl)/100);
   g_pd3dDevice.multiplyTransform(D3DTS_world, matworld);
   end;
   mkoc.DrawSubset(0);
  end;
end;

procedure renderszel;
var
mtrl:d3dmaterial9;
tmat:D3dmatrix;
begin
 g_pd3ddevice.SetMaterial(nullmat);
 zeromemory(@mtrl,sizeof(mtrl));
 mtrl.Diffuse.r:=10;
 mtrl.Diffuse.g:=10;
 mtrl.Diffuse.b:=10;
 mtrl.ambient.r:=0.5;
 mtrl.ambient.g:=0.5;
 mtrl.ambient.b:=0.5;
 g_pd3dDevice.SetMaterial(mtrl);
 g_pd3dDevice.SetTransform(D3DTS_world, szelmat);
 mszel.DrawSubset(0);
 zeromemory(@mtrl,sizeof(mtrl));
 g_pd3dDevice.SetMaterial(nullmat);
 d3dxmatrixscaling(tmat,100,100,100);
 g_pd3dDevice.SetTransform(D3DTS_world, tmat);
 D3DXMatrixRotationX(tmat,D3DX_pi/2);
 g_pd3dDevice.MultiplyTransform(D3DTS_world, tmat);

 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_Selectarg1);

 g_pd3ddevice.SetTexture(0,htex);
 {
 g_pd3dDevice.GetTransform(D3DTS_VIEW, tmat);

 g_pd3dDevice.setTransform(D3DTS_TEXTURE0, tmat);

 d3dxmatrixscaling(tmat,0.2,0.2,0.2);
 g_pd3dDevice.multiplyTransform(D3DTS_TEXTURE0, tmat);

 g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_COUNT4);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXCOORDINDEX, D3DTSS_TCI_CAMERASPACEPOSITION);
 //}
 g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CW);
 mbon.DrawSubset(0);
 g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
 d3dxmatrixidentity(tmat);
 g_pd3dDevice.SetTransform(D3DTS_TEXTURE0, tmat);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_Selectarg2);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXCOORDINDEX, D3DTSS_TCI_PASSTHRU);
end;

procedure rendertext;
var
mymat:TD3dmatrix;
i,j:integer;
aszam:cardinal;
myscor:cardinal;
dats:array [1..4] of cardinal;
mat:D3dmatrix;
begin
 {g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
 g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_ONE);
 g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
 g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iFalse);
  //}
 g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iFalse);
 g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, ifalse);
 g_pd3ddevice.SetTexture(0,sztex);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_Selectarg1);
 d3dxmatrixidentity(mymat);
 g_pd3ddevice.SetTransform(D3DTS_view,mymat);
 g_pd3dDevice.SetStreamSource(0, szVB, 0, SizeOf(TCustomVertex));
 g_pd3dDevice.SetFVF(D3DFVF_CUSTOMVERTEX);
 myscor:=round(score*200/10160);
 dats[1]:=myscor;
 myscor:=round(highs*200/10160);
 dats[2]:=myscor; //high
 dats[3]:=level;      //level
 dats[4]:=lives;
 if dm then
 dats[4]:=frh;      //lives
 for j:=1 to 4 do
 for i:=6 downto 0 do
 begin
  aszam:=dats[j] div mytiz(i);
  if (aszam>0) or (i=0) then g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_Selectarg1)
                        else g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_Selectarg2);

  aszam:=aszam mod 10;
  d3dxmatrixtranslation(mymat,texpos[j].x-aszam+6-i,texpos[j].y-2,50);
  g_pd3ddevice.SetTransform(D3DTS_world,mymat);
  g_pd3dDevice.DrawPrimitive(D3DPT_TRIANGLESTRIP, aszam*2, 2);
 end;
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_Selectarg1);
 for i:=1 to 4 do
 begin
  g_pd3ddevice.SetTexture(0,textex[i]);
  d3dxmatrixtranslation(mymat,texpos[i].x,texpos[i].y,50);
  g_pd3ddevice.SetTransform(D3DTS_world,mymat);
  d3dxmatrixscaling(mymat,7/10,1,1);
  g_pd3ddevice.MultiplyTransform(D3DTS_world,mymat);
  g_pd3dDevice.DrawPrimitive(D3DPT_TRIANGLESTRIP, 10*2, 2);
 end;
 if bscale>0 then
 begin
 //{
 g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
 g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_ONE);
 g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
 g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iFalse);
  //}
 mat._11 :=-0.5; mat._12 := 0.00; mat._13 := 0.00; mat._14 := 0.00;
 mat._21 := 0.00; mat._22 :=-0.5; mat._23 := 0.00; mat._24 := 0.00;
 mat._31 := 0.75; mat._32 := 0.75; mat._33 := 1.00; mat._34 := 0.00;
 mat._41 := 0.25 ; mat._42 := -0.25; mat._43 := 0.00; mat._44 := 1.00;

 g_pd3dDevice.SetTransform(D3DTS_TEXTURE0, mat);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_COUNT2);
 g_pd3dDevice.SetTexture(0,bontex[bvolt]);
 //g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_Modulate);
 d3dxmatrixtranslation(mymat,-5,-1,bscale*8);
 g_pd3ddevice.SetTransform(D3DTS_world,mymat);
 d3dxmatrixscaling(mymat,1,10,1);
 g_pd3ddevice.MultiplyTransform(D3DTS_world,mymat);
 g_pd3dDevice.DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 20);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_Disable);
 end;
 g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, ifalse);
 g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, itrue)
end;
procedure setuptextures;
begin
// Set up the default texture states.
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG2);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP,   D3DTOP_DISABLE);

 // Set up the default sampler states.
end;

procedure renderXtra(ind:word);
var
  matWorld,matrot: TD3DMatrix;
begin
  case Xtras[ind].typ of
  0:begin
   d3dxmatrixtranslation(matworld,Xtras[ind].pos.x,0,Xtras[ind].pos.y);
   g_pd3dDevice.SetTransform(D3DTS_world, matworld);
   d3dxmatrixscaling(matworld,bonus.ball*3,bonus.ball*3,bonus.ball*3);
   g_pd3dDevice.MultiplyTransform(D3DTS_world, matworld);
   d3dxmatrixidentity(matrot);
   matrot._11:=1;matrot._12:=0;matrot._13:=0;
   matrot._21:=0;matrot._22:=1;matrot._23:=0;
   matrot._31:=0;matrot._32:=0;matrot._33:=1;
   matrot._41:=(timegettime mod 1000)/1000;matrot._32:=(timegettime mod 1500)/1500;matrot._43:=1;
   g_pd3dDevice.SetTransform(D3DTS_TEXTURE0, matrot);
   g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_COUNT2);

   d3dxmatrixidentity(matrot);
   if bonus.tuz then g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_Modulate) else
                         g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_Selectarg2);
   g_pd3dDevice.SetTexture(0,Ftex);
   mbon.DrawSubset(0);
   g_pd3dDevice.SetTransform(D3DTS_TEXTURE0, matrot);
   g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_Selectarg2)
   end;
  end;
end;

procedure renderpont;
var
mymat:D3dmatrix;
var
mtrl:d3dmaterial9;
begin
 {
 g_pd3ddevice.SetMaterial(nullmat);
 zeromemory(@mtrl,sizeof(mtrl));
 mtrl.Diffuse.r:=1;
 mtrl.Diffuse.g:=1;
 mtrl.Diffuse.b:=1;
 mtrl.ambient.r:=1;
 mtrl.ambient.g:=1;
 mtrl.ambient.b:=1;
 //}
 d3dxmatrixidentity(mymat);

 g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, ifalse);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_Selectarg2);
 g_pd3ddevice.SetTransform(D3DTS_world,mymat);
 g_pd3dDevice.SetStreamSource(0, pontVB, 0, SizeOf(TCustomVertex));
 g_pd3dDevice.SetFVF(D3DFVF_CUSTOMVERTEX);
 g_pd3dDevice.DrawPrimitive(D3DPT_LINELIST, 0, hponti);
 g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iTrue);
end;

procedure renderbon;
var
matrot:D3dmatrix;
begin
 d3dxmatrixidentity(matrot);
 matrot._11:=1;matrot._12:=0;matrot._13:=0;
 matrot._21:=0;matrot._22:=1;matrot._23:=0;
 matrot._31:=0;matrot._32:=0;matrot._33:=1;
 matrot._41:=(timegettime mod 1000)/1000;matrot._32:=(timegettime mod 1000)/1000;matrot._43:=1;
 g_pd3dDevice.SetTransform(D3DTS_TEXTURE0, matrot);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_COUNT2);

 d3dxmatrixidentity(matrot);
 g_pd3dDevice.SetTexture(0,bontex[bontyp]);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_Modulate);
 setupmatricesbon;
 mbon.DrawSubset(0);
 g_pd3dDevice.SetTransform(D3DTS_TEXTURE0, matrot);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_Selectarg2)

end;
//-----------------------------------------------------------------------------
// Name: Render()
// Desc: Draws the scene
//-----------------------------------------------------------------------------
procedure Render;
var
i:integer;
mat:D3dmatrix;
begin
  dofiz;
  // Clear the backbuffer to a black color
  g_pd3dDevice.Clear(0, nil,D3DCLEAR_ZBUFFER, D3DCOLOR_XRGB(92,188,252), 1.0, 0);

  // Begin the scene
  if (SUCCEEDED(g_pd3dDevice.BeginScene)) then
  begin
    // Setup the world, view, and projection matrices
    SetupMatrices;
    Setuplights;
    setuptextures;
    g_pd3dDevice.SetTexture(0,nil);
    mtak.DrawSubset(0);
    if timegettime>inittime then
    for i:=0 to high(Xtras) do
     renderXtra(i);
    renderpont;
    renderszel;
    renderpaly;
    setuplights;
    if bontyp>0 then
     renderbon;
    rendertext;
    g_pd3dDevice.EndScene;
  end;

  g_pd3dDevice.Present(nil, nil, 0, nil);
end;


procedure camkez(tx,ty,tz:single);
begin
 cx:=tx;
 cy:=ty;
 czoom:=tz;
end;


//-----------------------------------------------------------------------------
// Name: MsgProc()
// Desc: The window's message handler
//-----------------------------------------------------------------------------
function MsgProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
tp:Tpoint;
begin
 result:=0;
  case uMsg of
    WM_DESTROY:
    begin
      PostQuitMessage(0);
      Result:= 0;
      Exit;
    end;
    WM_KEYDOWN:
    begin
     case wparam of
      VK_ESCAPE:msgproc(hwnd,WM_DESTROY,0,0);
      VK_F1:camkez(0,D3DX_PI/3,1.5);
      VK_F2:camkez(0,0.697,1.5);
      VK_F3:camkez(-0.764,1.127,1.5);
      VK_F4:camkez(0,0.01,1.1);
      VK_SPACE:
      begin
       szg:=not szg;
       szg:=szg and dm;
       cx:=0;
       cy:=D3DX_PI/3;
      end;
      VK_LEFT:if dm then suprob(true);
     end;
    end;
    WM_MOUSEMOVE:
    begin
     tp.x:=loword(lparam);
     tp.y:=hiword(lparam);
     clienttoscreen(hwindow,tp);
     if cam then
     begin
      cx:=cx-(tp.x-400)/200;
      cy:=cy+(tp.y-300)/200;
     end
     else
     begin
      if bonus.ford then tp.x:=800-tp.x;
      ex:=ex-(tp.x-400)/30;
      ey:=ey+(tp.y-300)/30;
     end;

     if not ((tp.x=400) and (tp.y=300)) then
     setcursorpos(400,300);
    end;
    WM_LBUTTONUP:
    begin
     doclck;
    end;
    WM_RBUTTONDOWN:
     cam:=true;
    WM_RBUTTONUP:
     cam:=false;
    WM_MOUSEWHEEL:
    begin
     tp.x:=shortint(HIWORD(wParam));
     czoom:=czoom-tp.x/1000;
    end;
  end;
  Result:= DefWindowProc(hWnd, uMsg, wParam, lParam);
end;

procedure Loadhigh;
var
reg:Tregistry;
begin
Reg:=Tregistry.Create;
if not reg.OpenKey('software\Speedy software\DXB',false)
   then
   begin
    reg.openkey('software\Speedy software\DXB',true);
    highs:=0;
    reg.Writeinteger('rekord',highs);
   end;
highs:=reg.ReadInteger('rekord');
reg.Destroy;
end;
procedure Savehigh;
var
reg:Tregistry;
begin
Reg:=Tregistry.Create;
reg.openkey('software\Speedy software\DXB',true);
reg.Writeinteger('rekord',highs);
reg.Destroy;
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
    lpszClassName: 'dxb3d';
    hIconSm: 0);
var
  msg: TMsg;
begin
  // Register the window class
(*  WNDCLASSEX wc = { sizeof(WNDCLASSEX), CS_CLASSDC, MsgProc, 0L, 0L,
                    GetModuleHandle(NULL), NULL, NULL, NULL, NULL,
                    "D3D Tutorial", NULL }; *)
  dm:=(paramstr(1)='devmode');                  
  wc.hInstance:= GetModuleHandle(nil);
  RegisterClassEx(wc);

  // Create the application's window
  hWindow := CreateWindow('dxb3d', '3d DX-Breakout',
                          WS_VISIBLE+WS_POPUP, 80, 60, 256,256,
                          GetDesktopWindow, 0, wc.hInstance, nil);

  // Initialize Direct3D
  if SUCCEEDED(InitD3D(hWindow)) and SUCCEEDED(InitDS) then
  begin
    // Create the scene geometry
    if SUCCEEDED(InitGeometry) then
    begin
      // Show the window
      loadhigh;
      ShowWindow(hWindow, SW_SHOWMAXIMIZED);
      showcursor(false);
      UpdateWindow(hWindow);
      setcursorpos(400,300);
      // Enter the message loop
      FillChar(msg, SizeOf(msg), 0);
      while (msg.message <> WM_QUIT) do
      begin
        if PeekMessage(msg, 0, 0, 0, PM_REMOVE) then
        begin
          TranslateMessage(msg);
          DispatchMessage(msg);
        end else
          Render;
      end;
    end
    else
    messagebox(0,'Fájlbetöltési hiba!','Hiba!',0);
  end;
  cleanup;
  savehigh;
  showcursor(true);
  UnregisterClass('D3D Tutorial', wc.hInstance);
end.

