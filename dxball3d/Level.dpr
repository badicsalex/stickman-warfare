program Level;

uses
  Windows,
  sysutils,
  Messages,
  MMSystem,
  Direct3D9,
  graphics,
  D3DX9;

//-----------------------------------------------------------------------------
// Global variables
//-----------------------------------------------------------------------------
const
szel=10;
mag=20;
maxbon=3;
nullmat:D3dmaterial9=();
type
  TCustomVertex = packed record
    x, y, z: Single;      // The untransformed, 3D position for the vertex
    color: DWORD;         // The vertex color
    tu,tv:single; // Texture ccord
  end;

  Tfiz = record
    x,y:single;
    xs,ys:single;
  end;

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
   at:boolean;
   fx:single;
  end;
const
BON_ATMEGY=1;
nullkoc:Tkoc=();
var
  g_pD3D: IDirect3D9 = nil; // Used to create the D3DDevice
  g_pd3dDevice: IDirect3DDevice9 = nil; // Our rendering device
  mtak,mgoly,mkoc,mbon,mszel:Id3dxmesh;
  kockak:array of Tkoc;
  bontex:array [1..maxbon] of IDirect3dtexture9; 
  hwindow:Thandle;
  golyo,abon:Tfiz;
  bontyp:byte;
  bonus:Tpaddle;
  inittime:cardinal;
  ex,ey,cx,cy,czoom:single;
  vti:cardinal;
  az:single;
  myex,rr,gg,bb:byte;
  szg,cam:boolean;
  szam:word;
  szelmat:D3dmatrix;
  hon:D3dvector;
const
  // Our custom FVF, which describes our custom vertex structure
  D3DFVF_CUSTOMVERTEX = (D3DFVF_XYZ or D3DFVF_DIFFUSE or D3DFVF_TEX1);

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
 0:result:=intersect(x-0.55,y-0.55,x+0.55,y-0.55,g1.x,g1.y,g2.x,g2.y);
 1:result:=intersect(x+0.55,y-0.55,x+0.55,y+0.55,g1.x,g1.y,g2.x,g2.y);
 2:result:=intersect(x-0.55,y+0.55,x+0.55,y+0.55,g1.x,g1.y,g2.x,g2.y);
 3:result:=intersect(x-0.55,y-0.55,x-0.55,y+0.55,g1.x,g1.y,g2.x,g2.y);
end;
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
  if (g_pD3D = nil) then Exit;

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

  g_pd3ddevice.SetNPatchMode(3);
  Result:= S_OK;
end;
procedure initall;
begin
 setlength(kockak,0);
 cx:=0;
 cy:=D3DX_PI/3;
 czoom:=1.1;
end;
procedure initpaly;
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
 setlength(kockak,9*15);
 anim:=random(5);
 maxvy:=0;
 for y:=6 to 14 do
  for x:=-7 to 7 do
  begin
   akoc.x:=random(15)-7;
   akoc.y:=y;
   akoc.vy:=0;
   case anim of
    0:akoc.vy:=(x+y)/4;
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

//-----------------------------------------------------------------------------
// Name: InitGeometry()
// Desc: Creates the scene geometry
//-----------------------------------------------------------------------------
function InitGeometry: HRESULT;
var
mtmesh:id3dxmesh;
tmat:D3dmatrix;
begin
  Result:= E_FAIL;
  //kocka
  if FAILED(D3DXLoadMeshFromX('koci.x', D3DXMESH_SYSTEMMEM,
                                g_pd3dDevice, nil,
                                nil, nil, nil,
                                mtmesh)) then exit;
  Result:= mtmesh.CloneMeshFVF(mtmesh.GetOptions,
                                      mtmesh.GetFVF or D3DFVF_NORMAL,
                                      g_pd3dDevice, mkoc);
  if FAILED(Result) then Exit;
  mtmesh:=nil;
  D3DXComputeNormals(mkoc, nil);
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
  //D3DXCreatepolygon(g_pd3ddevice,1,4,mplan,nil);
  D3dxmatrixscaling(szelmat,szel*2,2.05,mag);
  d3dxmatrixtranslation(tmat,0,0.75,-mag/2);
  d3dxmatrixmultiply(szelmat,szelmat,tmat);
  D3DXMatrixRotationY(tmat,D3DX_PI*1.5);
  d3dxmatrixmultiply(szelmat,tmat,szelmat);
  
  initall;
  Result:= S_OK;
end;

procedure corrbill;
begin
 if ex>szel-0.5 then ex:=szel-0.5;
 if -(szel-0.5)>ex then ex:=-(szel-0.5);
 if ey>-3.5 then ey:=-3.5;
 if -(mag-1)>ey then ey:=-(mag-1);
end;

procedure sr(ezt:Iunknown);
begin
 if ezt<>nil then ezt:=nil;
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
  for i:=low(bontex) to high(bontex) do
   sr(bontex[i]); 
  sr(mbon);
  sr(mtak);
  sr(mgoly);
  sr(mkoc);
  sr(g_pd3ddevice);
  sr(g_pd3d);
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
  d3dxmatrixtranslation(matworld,round(ex-0.5)+0.5,az,round(ey-0.5)+0.5);
  g_pd3dDevice.SetTransform(D3DTS_world, matworld);
  //d3dxmatrixrotationy(matworld,(timegettime mod 1000)*2*d3dx_pi/1000);
  //g_pd3ddevice.MultiplyTransform(D3DTS_world,matworld);

  //setwindowtex(hwindow,pchar(floattostr(i1)));
  vEyePt:= D3DXVector3(25*sin(cx)*sin(cy)*czoom,25*cos(cy)*czoom,-mag/2+25*cos(cx)*sin(cy)*czoom);
  vLookatPt:= D3DXVector3(0,6,-mag/2);
  vUpVec:= D3DXVector3(0.0, 1.0, -0.01);
  D3DXMatrixLookAtLH(matView, vEyePt, vLookatPt, vUpVec);
  g_pd3dDevice.SetTransform(D3DTS_VIEW, matView);
  //g_pd3ddevice.SetRenderState(D3DRS_FILLMODE,D3DFILL_WIREFRAME);
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/4, 1.0, 1.0, 200.0);
  g_pd3dDevice.SetTransform(D3DTS_PROJECTION, matProj);

end;

procedure SetupLights;
var
  mtrl: TD3DMaterial9;
  vecDir: TD3DXVector3;
  light: TD3DLight9;
begin
  // Set up a material. The material here just has the diffuse and ambient
  // colors set to yellow. Note that only one material can be used at a time.

  ZeroMemory(@light, SizeOf(TD3DLight9));
  light._Type      := D3DLIGHT_DIRECTIONAL;
  light.Diffuse.r  := 0.5;
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

  // Finally, turn on some ambient light.
  g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $00c0c0c0);
end;

procedure renderpaly;
const
RGBlist:array[1..8,1..2,1..3] of single=
        (((1,0,0),(0.5,0,0)),
         ((0.4,0.4,0.4),(0,0,0)),
         ((0.6,0.6,0.6),(0,0,0)),
         ((0.8,0.8,0.8),(0,0,0)),
         ((2,-1,0),(0,1,0)),
         ((2,-1,2),(0,1,0)),
         ((2,2,0),(1,0,0)),
         ((2,2,2),(2,2,2)));
var
i:integer;
matworld:D3dmatrix;
mtrl:d3dmaterial9;
begin
 for i:=0 to high(kockak) do
 if az>=kockak[i].y-0.1 then
  with kockak[i] do
  begin
   d3dxmatrixtranslation(matworld,x,y+vy,z);
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
   if extra=1 then
   begin
    g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
    g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_ONE);
    g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ZERO);
    g_pd3dDevice.SetRenderState(D3DRS_ZWriteENABLE, iFalse)
   end
   else
   begin
    g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, ifalse);
    g_pd3dDevice.SetRenderState(D3DRS_ZWriteENABLE, itrue)
   end;
   mkoc.DrawSubset(0);

   g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, ifalse);
   g_pd3dDevice.SetRenderState(D3DRS_ZWriteENABLE, itrue)

  end;
end;

procedure renderkoc;
const
RGBlist:array[1..8,1..2,1..3] of single=
        (((1,0,0),(0.5,0,0)),
         ((0.4,0.4,0.4),(0,0,0)),
         ((0.6,0.6,0.6),(0,0,0)),
         ((0.8,0.8,0.8),(0,0,0)),
         ((2,-1,0),(0,1,0)),
         ((2,-1,2),(0,1,0)),
         ((2,2,0),(1,0,0)),
         ((2,2,2),(2,2,2)));
nullmat:d3dmaterial9=();
var
i:integer;
matworld:D3dmatrix;
mtrl:d3dmaterial9;
koc1:Tkoc;
begin
  koc1.x:=round(ex-0.5)+0.5;
  koc1.y:=az;
  koc1.z:=round(ey-0.5)+0.5;
  koc1.vy:=0;
  koc1.r:=rr/2;
  koc1.g:=gg/2;
  koc1.b:=bb/2;
  koc1.extra:=myex;
  koc1.no:=false;

  with koc1 do
  begin
   d3dxmatrixtranslation(matworld,x,y+vy,z);
   if extra=0 then
   begin
    mtrl.Diffuse.r:=r;
    mtrl.Diffuse.g:=g;
    mtrl.Diffuse.b:=b;
    mtrl.ambient.r:=r/2-1;
    mtrl.ambient.g:=g/2;
    mtrl.ambient.b:=b/2;
   end
   else
   begin
    mtrl.Diffuse.r:=RGBlist[extra,1,1];
    mtrl.Diffuse.g:=RGBlist[extra,1,2];
    mtrl.Diffuse.b:=RGBlist[extra,1,3];
    mtrl.ambient.r:=RGBlist[extra,2,1]-1;
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
   if extra=1 then
   begin
    g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
    g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_ONE);
    g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
    g_pd3dDevice.SetRenderState(D3DRS_ZWriteENABLE, iFalse)
   end
   else
   begin
    g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, ifalse);
    g_pd3dDevice.SetRenderState(D3DRS_ZWriteENABLE, itrue)
   end;
   
   if 8>extra then
    g_pd3ddevice.SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID)
   else
    g_pd3ddevice.SetRenderState(D3DRS_FILLMODE, D3DFILL_WIREFRAME);
   mkoc.DrawSubset(0);
   g_pd3ddevice.SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);
   g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, ifalse);
   g_pd3dDevice.SetRenderState(D3DRS_ZWriteENABLE, itrue)

  end;
end;

procedure setuptextures;
begin
// Set up the default texture states.
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG2);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP,   D3DTOP_DISABLE);

 // Set up the default sampler states.
 g_pd3dDevice.SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_NONE );
 g_pd3dDevice.SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_NONE );
 g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_NONE );
 g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_CLAMP );
 g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_CLAMP );
end;
procedure clicked;
const
RGBlist:array[1..7,1..3] of single=
        ((1,0,0),
         (0.2,0.2,0.2),
         (0.2,0.2,0.2),
         (0.2,0.2,0.2),
         (1,1,0),
         (1,1,1),
         (1,1,0));
var
i,cx,cy,cz,bx,by,bz,xx,yy,zz:integer;
koc1:Tkoc;
tx,ty,tz:single;
bol:boolean;
begin
 if ex>hon.x then
 begin
  cx:=round(0.5+hon.x);
  bx:=round(0.5+ex);
 end
 else
 begin
  cx:=round(0.5+ex);
  bx:=round(0.5+hon.x)
 end;
 if ey>hon.z then
 begin
  cy:=round(0.5+hon.z);
  by:=round(0.5+ey);
 end
 else
 begin
  cy:=round(0.5+ey);
  by:=round(0.5+hon.z);
 end;
 if az>hon.y then
 begin
  cz:=round(hon.y*2);
  bz:=round(az*2);
 end
 else
 begin
  cz:=round(az*2);
  bz:=round(hon.y*2);
 end;
 for xx:=cx to bx do
 for yy:=cy to by do
 for zz:=cz to bz do
 begin
   i:=0;
   tx:=xx-0.5;
   ty:=zz/2;
   tz:=yy-0.5;
   while high(kockak)>=i do
   begin
    bol:=(0.5>abs(tx-kockak[i].x));
    bol:=bol and (0.5>abs(ty-kockak[i].y));
    bol:=bol and (0.5>abs(tz-kockak[i].z));
    if bol then
    begin
     kockak[i]:=kockak[high(kockak)];
     setlength(kockak,high(kockak));
    end
    else
     i:=i+1;
    end;
   if 8>myex then
   begin
    setlength(kockak,length(kockak)+1);
    koc1.x:=round(tx-0.5)+0.5;
    koc1.y:=ty;
    koc1.z:=round(tz-0.5)+0.5;
    koc1.vy:=0;
    if myex=0 then
    begin
     koc1.r:=rr/2;
     koc1.g:=gg/2;
     koc1.b:=bb/2;
    end
    else
    begin
     koc1.r:=RGBList[myex,1];
     koc1.g:=RGBList[myex,1];
     koc1.b:=RGBList[myex,1];
    end;
    koc1.extra:=myex;
    koc1.no:=false;
    koc1.tl:=0;
    kockak[high(kockak)]:=koc1
   end;
  end;

end;

procedure loadpaly(mit:string);
var
fili:file of Tkoc;
i,j,lngt:integer;
tekoc:Tkoc;
begin
 if not fileexists('trk\'+mit+'.dxb') then exit;
 assignfile(fili,'trk\'+mit+'.dxb');
 reset(fili);
 lngt:=0;
 setlength(kockak,0);
 repeat
  read(fili,tekoc);
  lngt:=lngt+1;
  if lngt>length(kockak) then
   setlength(kockak,length(kockak)+20);
  kockak[lngt-1]:=tekoc;
 until (tekoc.z=nullkoc.z);
 setlength(kockak,lngt-1);
 write(fili,nullkoc);
 closefile(fili);
end;

procedure save;
var
fili:file of Tkoc;
koc:Tkoc;
i,j:integer;
begin
 //Blugy..bluggy
 for i:=0 to high(kockak) do
  for j:=0 to i do
  if kockak[i].y>kockak[j].y then
  begin
   koc:=kockak[i];
   kockak[i]:=kockak[j];
   kockak[j]:=koc;
  end;
 assignfile(fili,'trk\trk.dxb');
 rewrite(fili);
 for i:=0 to high(kockak) do
  write(fili,kockak[i]);
 write(fili,nullkoc);
 closefile(fili);
end;
procedure renderszel;
var
mtrl:d3dmaterial9;
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
end;

//-----------------------------------------------------------------------------
// Name: Render()
// Desc: Draws the scene
//-----------------------------------------------------------------------------
procedure Render;
begin
  corrbill;
  // Clear the backbuffer to a black color
  g_pd3dDevice.Clear(0, nil, D3DCLEAR_TARGET+D3DCLEAR_ZBUFFER, D3DCOLOR_XRGB(92,188,252), 1.0, 0);

  // Begin the scene
  if (SUCCEEDED(g_pd3dDevice.BeginScene)) then
  begin
    // Setup the world, view, and projection matrices
    SetupMatrices;
    Setuplights;
    setuptextures;
    renderszel;
    renderpaly;
    setuplights;
    renderkoc;
    setuplights;
    g_pd3dDevice.EndScene;
  end;

  g_pd3dDevice.Present(nil, nil, 0, nil);
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
      save;
      Cleanup;
      PostQuitMessage(0);
      Result:= 0;
      Exit;
    end;
    WM_KEYDOWN:
    begin
     case wparam of
      VK_ESCAPE:msgproc(hwnd,WM_DESTROY,0,0);
      VK_SPACE:loadpaly('trk') ;
      ord('A'):if myex>0 then dec(myex) else myex:=8;
      ord('S'):if 8>myex then inc(myex) else myex:=0;
      ord('Q'):if az>0 then az:=az-0.5;
      ord('W'):if 15>az then az:=az+0.5;
      ord('R'):if 2>rr then inc(rr) else rr:=0;
      ord('G'):if 2>gg then inc(gg) else gg:=0;
      ord('B'):if 2>bb then inc(bb) else bb:=0;
      VK_RETURN:save;
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
      ex:=ex-(tp.x-400)/50;
      ey:=ey+(tp.y-300)/50;
     end;
     if not ((tp.x=400) and (tp.y=300)) then
     setcursorpos(400,300);
    end;
    WM_LBUTTONDOWN:
    begin
     hon.x:=round(ex-0.5)+0.5;
     hon.y:=az;
     hon.z:=round(ey-0.5)+0.5;
    end;
    WM_LBUTTONUP:
    begin
     clicked;
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
  wc.hInstance:= GetModuleHandle(nil);
  RegisterClassEx(wc);

  // Create the application's window
  hWindow := CreateWindow('dxb3d', '3d DX-Breakout',
                          WS_VISIBLE+WS_POPUP, 80, 60, 256,256,
                          GetDesktopWindow, 0, wc.hInstance, nil);

  // Initialize Direct3D
  if SUCCEEDED(InitD3D(hWindow)) then
  begin
    // Create the scene geometry
    if SUCCEEDED(InitGeometry) then
    begin
      // Show the window
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
    end;
  end;
  cleanup;
  showcursor(true);
  UnregisterClass('D3D Tutorial', wc.hInstance);
end.

