unit fegyverek;

interface
uses sysutils,windows,typestuff,math,Direct3d9,d3dx9,ParticleSystem;
const

M4_Golyoido=0.3;
type
 Tprojectile = record
  p1,p2:TD3DXvector3;
  ido,mido:single;
 end;

 Tprojectilearray=array of Tprojectile;


 TF_M4A1 = class (Tobject)
 private
   g_pMesh:ID3DXMesh;
   g_pD3Ddevice:IDirect3ddevice9;
   g_pEffect:ID3DXEffect;
   m4tex:IDirect3DTexture9;
   muzz:array [0..17] of TCustomVertex;
   procedure makemuzzle;
   procedure makemuzzlequad(hol:integer;v1,v2,v3,v4:TCustomVertex);
 public
  betoltve:boolean;
  fc:single;
  muzzez:array of TCustomvertex;
  constructor Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
  procedure draw;
  procedure pluszmuzzmatr(siz:single);
  procedure drawmuzzle(siz:single);
  destructor Destroy;reintroduce;
 end;


 TF_M82A1 = class (Tobject)
 private
   g_pMesh:ID3DXMesh;
   g_pD3Ddevice:IDirect3ddevice9;
   m4tex,scaltex:IDirect3DTexture9;
   muzz:array [0..17] of TCustomVertex;
   scal:array [0..11] of Tskyvertex;
   procedure makemuzzle;
   procedure makemuzzlequad(hol:integer;v1,v2,v3,v4:TCustomVertex);
   procedure makescalequad(hol:integer;m1,m2,m3,m4:TD3DXVector3);
 public
  betoltve:boolean;
  fc:single;
  muzzez:array of TCustomvertex;
  constructor Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
  procedure draw;
  procedure drawscope;
  procedure pluszmuzzmatr(siz:single);
  procedure drawmuzzle(siz:single);

  destructor Destroy;reintroduce;
 end;

 TF_LAW = class (Tobject)
 private
   g_pMesh:ID3DXMesh;
   g_pD3Ddevice:IDirect3ddevice9;
   m4tex:IDirect3DTexture9;
   muzz:array [0..17] of TCustomVertex;
   procedure makemuzzle;
   procedure makemuzzlequad(hol:integer;v1,v2,v3,v4:TCustomVertex);
 public
  betoltve:boolean;
  fc:single;
  muzzez:array of TCustomvertex;
  constructor Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
  procedure draw;
  procedure pluszmuzzmatr(siz:single);
  procedure drawmuzzle(siz:single);

  destructor Destroy;reintroduce;
 end;


 TF_MP5A3 = class (Tobject)
 private
   g_pMesh:ID3DXMesh;
   g_pD3Ddevice:IDirect3ddevice9;
   m4tex:IDirect3DTexture9;
   muzz:array [0..17] of TCustomVertex;
   procedure makemuzzle;
   procedure makemuzzlequad(hol:integer;v1,v2,v3,v4:TCustomVertex);
 public
  betoltve:boolean;
  fc:single;
  muzzez:array of TCustomvertex;
  constructor Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
  procedure draw;
  procedure pluszmuzzmatr(siz:single);
  procedure drawmuzzle(siz:single);

  destructor Destroy;reintroduce;
 end;


 TF_MPG = class (Tobject)
 private
   g_pMesh:ID3DXMesh;
   g_pD3Ddevice:IDirect3ddevice9;

   mpgtex:IDirect3DTexture9;
   mpgemap:IDirect3DTexture9;
   muzz:array [0..5] of TCustomVertex;
   procedure makemuzzle(alpha:byte);
 public
  betoltve:boolean;
  fc:single;
  muzzez:array of TCustomvertex;
  constructor Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
  procedure draw;
  procedure pluszmuzzmatr(siz:single);
  procedure drawmuzzle(siz:single);

  destructor Destroy;reintroduce;
 end;

 TF_quadgun = class (Tobject)
 private
   g_pMesh:ID3DXMesh;
   g_pD3Ddevice:IDirect3ddevice9;
   quadguntex:IDirect3DTexture9;
   quadgunemap:IDirect3DTexture9;
   muzz:array [0..5] of TCustomVertex;
   procedure makemuzzle(alpha:byte);

 public
  betoltve:boolean;
  fc:single;
  muzzez:array of TCustomvertex;
  constructor Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
  procedure draw;
  procedure pluszmuzzmatr(siz:single);
  procedure drawmuzzle(siz:single);
  destructor Destroy;reintroduce;
 end;


 TF_Noobcannon = class (Tobject)
 private
   g_pMesh:ID3DXMesh;
   g_pD3Ddevice:IDirect3ddevice9;
   tex:IDirect3DTexture9;
   emap:IDirect3DTexture9;
 //  muzz:array [0..3] of TCustomVertex;
//   procedure makemuzzle(alpha:byte);
 public
  betoltve:boolean;
  fc:single;
  muzzez:array of TCustomvertex;
  constructor Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
  procedure draw;
  procedure pluszmuzzmatr(siz:single);
  procedure drawmuzzle(siz:single);
  destructor Destroy;reintroduce;
 end;


 TF_X72 = class (Tobject)
 private
   g_pMesh:ID3DXMesh;
   g_pD3Ddevice:IDirect3ddevice9;
   tex,emap:IDirect3DTexture9;
   muzz:array [0..17] of TCustomVertex;
   procedure makemuzzle;
   procedure makemuzzlequad(hol:integer;v1,v2,v3,v4:TCustomVertex);
 public
  betoltve:boolean;
  fc:single;
  muzzez:array of TCustomvertex;
  constructor Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
  procedure draw;
  procedure pluszmuzzmatr(siz:single);
  procedure drawmuzzle(siz:single);
  destructor Destroy;reintroduce;
 end;

 TF_H31 = class (Tobject)
 private
   g_pMesh:ID3DXMesh;
   g_pD3Ddevice:IDirect3ddevice9;
   tex:IDirect3DTexture9;
 public
  betoltve:boolean;
  fc:single;
  muzzez:array of TCustomvertex;
  constructor Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
  procedure draw;
  procedure pluszmuzzmatr(siz:single);
  destructor Destroy;reintroduce;
 end;


 TFegyv = class (TObject)
 private
   g_pD3Ddevice:IDirect3ddevice9;
   M4proj,mpgproj:Tprojectilearray;
   M4A1:TF_M4A1;
   M82A1:TF_M82A1;
   MPG:TF_MPG;
   Law:TF_Law;
   noobcannon:TF_Noobcannon;
   quadgun:TF_quadgun;
   mp5a3:TF_mp5a3;
   x72:TF_X72;
   H31:TF_H31;
   gunmuztex,mpgmuztex,x72muztex:IDirect3DTexture9;
   g_pVB:IDirect3DVertexBuffer9;
 public
   betoltve:boolean;
   constructor Create(a_D3Ddevice:IDirect3ddevice9);
   procedure drawfegyv(mit:byte);
   procedure drawscope(mit:byte);
   procedure preparealpha;
   procedure drawfegyeffekt(mit:byte;mekkora:single);
   procedure FlushFegyeffekt;
   procedure unpreparealpha;
   function bkez(afegyv:word;astate:byte):TD3DXVector3;
   function jkez(afegyv:word;astate:byte):TD3DXVector3;
   destructor Destroy;reintroduce;
 end;

 
implementation



////////////////////////////////
//            M4A1
///////////////////////////////

constructor TF_M4A1.Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
var
 tempmesh:ID3DXMesh;
 pVert:PCustomvertexarray;
 vmi,vma,tmp:TD3DVector;
 scl:single;
 i:integer;
 adj:PDword;
begin
 inherited Create;
 betoltve:=false;
 g_pD3Ddevice:=a_D3Ddevice;
 addfiletochecksum(fnev+'.x');

 if not LTFF(g_pd3dDevice, fnev+'.jpg',m4tex) then
   Exit;

  makemuzzle;

  if FAILED(D3DXLoadMeshFromX(PChar(fnev+'.x'),0,g_pd3ddevice,nil,nil,nil,nil,tempmesh)) then exit;
  if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_CUSTOMVERTEX,g_pd3ddevice,g_pMesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;
  g_pMesh.LockVertexBuffer(0,pointer(pvert));
  D3DXComputeboundingbox(pointer(pvert),g_pMesh.GetNumVertices,g_pMesh.GetNumBytesPerVertex,vmi,vma);
  scl:=max(vma.x-vmi.x,max(vma.y-vmi.y,vma.z-vmi.z));
  scl:=scl/0.7;
  fc:=(vma.z-vmi.z)*0.5;
  for i:=0 to g_pMesh.GetNumVertices-1 do
  begin
   tmp.z:=-(pvert[i].position.x-vmi.x)/scl-0.04;
   tmp.y:=(pvert[i].position.y-vma.y)/scl+0.001;
   tmp.x:=(pvert[i].position.z-vma.z+fc)/scl;
   //if abs(tmp.x)<0.005 then tmp.x:=0;
   pvert[i].color:=RGB(200,200,200);
   pvert[i].position:=tmp;
 end;
  g_pMesh.UnlockVertexBuffer;
  getmem(adj,g_pmesh.getnumfaces*12);
  g_pMesh.generateadjacency(0.001,adj);
  D3DXComputenormals(g_pMesh,adj);
  g_pMesh.OptimizeInplace(D3DXMESHOPT_COMPACT+D3DXMESHOPT_ATTRSORT+D3DXMESHOPT_VERTEXCACHE,adj,nil,nil,nil);
  freemem(adj);  
  betoltve:=true;
end;

procedure TF_M4A1.makemuzzlequad(hol:integer;v1,v2,v3,v4:TCustomVertex);
begin
 muzz[hol+0]:=v1;
 muzz[hol+1]:=v2;
 muzz[hol+2]:=v3;
 muzz[hol+3]:=v4;
 muzz[hol+4]:=v2;
 muzz[hol+5]:=v3;
end;

procedure TF_M4A1.makemuzzle;
begin
 makemuzzlequad(0,CustomVertex(-0.5,-0.5,   0,0,0,0,ARGB(255,255,255,255),0,0,0,0),
                  CustomVertex( 0.5,-0.5,   0,0,0,0,ARGB(255,255,255,255),2,0,0,0),
                  CustomVertex(-0.5, 0.5,   0,0,0,0,ARGB(255,255,255,255),0,2,0,0),
                  CustomVertex( 0.5, 0.5,   0,0,0,0,ARGB(255,255,255,255),2,2,0,0));
 makemuzzlequad(6,CustomVertex(   0,   0,   0,0,0,0,ARGB(255,255,255,255),0,0,0,0),
                  CustomVertex(   0, 0.5,-0.5,0,0,0,ARGB(255,255,255,255),1,0,0,0),
                  CustomVertex(   0,-0.5,-0.5,0,0,0,ARGB(255,255,255,255),0,1,0,0),
                  CustomVertex(   0,   0,  -1,0,0,0,ARGB(255,255,255,255),1,1,0,0));
makemuzzlequad(12,CustomVertex(   0,   0,   0,0,0,0,ARGB(255,255,255,255),0,0,0,0),
                  CustomVertex( 0.5,   0,-0.5,0,0,0,ARGB(255,255,255,255),1,0,0,0),
                  CustomVertex(-0.5,   0,-0.5,0,0,0,ARGB(255,255,255,255),0,1,0,0),
                  CustomVertex(   0,   0,  -1,0,0,0,ARGB(255,255,255,255),1,1,0,0));

end;

procedure TF_M4A1.draw;
begin
 g_pd3dDevice.Settexture(0,m4tex);
 g_pMesh.DrawSubset(0);
end;

procedure TF_M4A1.pluszmuzzmatr(siz:single);
var
  matWorld,matWorld2: TD3DMatrix;
begin

   D3DXMatrixTranslation(matWorld,-0.00,-0.06,-0.72);
   D3DXMatrixScaling(matWorld2,siz/2,siz/2,siz);
   D3DXmatrixMultiply(matWorld,matWorld2,MatWorld);
   g_pd3dDevice.MultiplyTransform(D3DTS_WORLD, matWorld);

end;

procedure TF_M4A1.drawmuzzle(siz:single);
var
mat:TD3DMatrix;
lngt,i:integer;
begin
 if siz=0 then exit;

 pluszmuzzmatr(siz);

 g_pd3ddevice.GetTransform(D3DTS_WORLD,mat);
 lngt:=length(muzzez);
 setlength(muzzez,lngt+length(muzz));
 for i:=0 to high(muzz) do
 begin
  muzzez[i+lngt]:=muzz[i];
  D3DXVec3TransformCoord(muzzez[i+lngt].position,muzz[i].position,mat);
 end;
// g_pd3ddevice.drawprimitiveUP(D3DPT_TRIANGLELIST,6,muzz,sizeof(TCustomvertex));
end;

destructor TF_M4A1.Destroy;
begin
 if m4tex<>nil then
 m4tex:=nil;
 if g_pmesh<>nil then
 g_pmesh:=nil;
 if g_pd3ddevice<>nil then
 g_pd3ddevice:=nil;
end;


////////////////////////////////
//            M82A1
///////////////////////////////

constructor TF_M82A1.Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
var
 tempmesh:ID3DXMesh;
 pVert:PCustomvertexarray;
 vmi,vma,tmp:TD3DVector;
 scl:single;
 i:integer;
 adj:PDword;
begin
 inherited Create;
 betoltve:=false;
 g_pD3Ddevice:=a_D3Ddevice;
 addfiletochecksum(fnev+'.x');

 if not LTFF(g_pd3dDevice, fnev+'.jpg',m4tex) then
   Exit;
  if not LTFF(g_pd3dDevice, 'data/gui/scale.png',scaltex) then
   Exit;


  makemuzzle;

  if FAILED(D3DXLoadMeshFromX(PChar(fnev+'.x'),0,g_pd3ddevice,nil,nil,nil,nil,tempmesh)) then exit;
  if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_CUSTOMVERTEX,g_pd3ddevice,g_pMesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;
  g_pMesh.LockVertexBuffer(0,pointer(pvert));
  D3DXComputeboundingbox(pointer(pvert),g_pMesh.GetNumVertices,g_pMesh.GetNumBytesPerVertex,vmi,vma);
  scl:=max(vma.x-vmi.x,max(vma.y-vmi.y,vma.z-vmi.z));
  scl:=1.3/scl;
  fc:=(vma.z-vmi.z);
  for i:=0 to g_pMesh.GetNumVertices-1 do
  begin
   tmp.x:=-(pvert[i].position.x-vmi.x)*scl+0.05;
   tmp.y:=(pvert[i].position.y-vma.y)*scl+0.05;
   tmp.z:=-(pvert[i].position.z-vma.z+fc)*scl+0.001;
   //if abs(tmp.x)<0.005 then tmp.x:=0;
   pvert[i].color:=RGB(200,200,200);
   pvert[i].position:=tmp;
  end;
  g_pMesh.UnlockVertexBuffer;
  getmem(adj,g_pmesh.getnumfaces*12);
  g_pMesh.generateadjacency(0.001,adj);
  D3DXComputenormals(g_pMesh,adj);
  g_pMesh.OptimizeInplace(D3DXMESHOPT_COMPACT+D3DXMESHOPT_ATTRSORT+D3DXMESHOPT_VERTEXCACHE,adj,nil,nil,nil);
  freemem(adj); 
  betoltve:=true;
end;

procedure TF_M82A1.makemuzzlequad(hol:integer;v1,v2,v3,v4:TCustomVertex);
begin
 muzz[hol+0]:=v1;
 muzz[hol+1]:=v2;
 muzz[hol+2]:=v3;
 muzz[hol+3]:=v4;
 muzz[hol+4]:=v2;
 muzz[hol+5]:=v3;
end;

procedure TF_M82A1.makescalequad(hol:integer;m1,m2,m3,m4:TD3DXVector3);
var
v1,v2,v3,v4:TSkyVertex;
const
uvszorzo=5;
begin
 v1.position:=m1; v2.position:=m2; v3.position:=m3; v4.position:=m4;
 v1.u:=v1.position.x*uvszorzo; v1.v:=v1.position.y*uvszorzo;
 v2.u:=v2.position.x*uvszorzo; v2.v:=v2.position.y*uvszorzo;
 v3.u:=v3.position.x*uvszorzo; v3.v:=v3.position.y*uvszorzo;
 v4.u:=v4.position.x*uvszorzo; v4.v:=v4.position.y*uvszorzo;
 //v5.u:=v5.position.x*uvszorzo; v5.v:=v5.position.y*uvszorzo;
 scal[hol+0]:=v1;
 scal[hol+1]:=v2;
 scal[hol+2]:=v3;
 scal[hol+3]:=v3;
 scal[hol+4]:=v2;
 scal[hol+5]:=v4;
end;

procedure TF_M82A1.makemuzzle;
begin
 makemuzzlequad(0,CustomVertex(-0.5,-0.5,   0,0,0,0,ARGB(255,255,255,255),0,0,0,0),
                  CustomVertex( 0.5,-0.5,   0,0,0,0,ARGB(255,255,255,255),2,0,0,0),
                  CustomVertex(-0.5, 0.5,   0,0,0,0,ARGB(255,255,255,255),0,2,0,0),
                  CustomVertex( 0.5, 0.5,   0,0,0,0,ARGB(255,255,255,255),2,2,0,0));
 makemuzzlequad(6,CustomVertex(   0,   0,   0,0,0,0,ARGB(255,255,255,255),0,0,0,0),
                  CustomVertex(   0, 0.5,-0.5,0,0,0,ARGB(255,255,255,255),1,0,0,0),
                  CustomVertex(   0,-0.5,-0.5,0,0,0,ARGB(255,255,255,255),0,1,0,0),
                  CustomVertex(   0,   0,  -1,0,0,0,ARGB(255,255,255,255),1,1,0,0));
 makemuzzlequad(12,CustomVertex(   0,   0,   0,0,0,0,ARGB(255,255,255,255),0,0,0,0),
                  CustomVertex( 0.5,   0,-0.5,0,0,0,ARGB(255,255,255,255),1,0,0,0),
                  CustomVertex(-0.5,   0,-0.5,0,0,0,ARGB(255,255,255,255),0,1,0,0),
                  CustomVertex(   0,   0,  -1,0,0,0,ARGB(255,255,255,255),1,1,0,0));

 makescalequad(0,D3DXVector3(-0.02,0.00003,-0.2),D3DXVector3(-0.02,-0.000025,-0.2),
                 D3DXVector3( 0.02,0.00003,-0.2),D3DXVector3( 0.02,-0.000025,-0.2));
  makescalequad(6,D3DXVector3(-0.00003,0.02,-0.2),D3DXVector3(-0.000025,-0.02,-0.2),
                 D3DXVector3( 0.00003,0.02,-0.2),D3DXVector3(  0.000025,-0.02,-0.2));
end;

procedure TF_M82A1.draw;
begin
 g_pd3dDevice.Settexture(0,m4tex);
 g_pMesh.DrawSubset(0);
end;

procedure TF_M82A1.drawscope;
begin
 g_pd3dDevice.SetFVF(D3DFVF_SKYVERTEX);
 g_pd3ddevice.settexture(0,scaltex);
 g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_ONE);
 g_pd3ddevice.drawprimitiveUP(D3DPT_TRIANGLELIST,4,scal,sizeof(Tskyvertex));
end;

procedure TF_M82A1.pluszmuzzmatr(siz:single);
var
  matWorld,matWorld2: TD3DMatrix;
begin

   D3DXMatrixTranslation(matWorld,-0.00,-0.05,-1.3);
   D3DXMatrixScaling(matWorld2,siz/2,siz/2,siz);
   D3DXmatrixMultiply(matWorld,matWorld2,MatWorld);
   g_pd3dDevice.MultiplyTransform(D3DTS_WORLD, matWorld);

end;


procedure TF_M82A1.drawmuzzle(siz:single);
var
mat:TD3DMatrix;
lngt,i:integer;
begin
 if siz=0 then exit;

 pluszmuzzmatr(siz);

 g_pd3ddevice.GetTransform(D3DTS_WORLD,mat);
 lngt:=length(muzzez);
 setlength(muzzez,lngt+length(muzz));
 for i:=0 to high(muzz) do
 begin
  muzzez[i+lngt]:=muzz[i];
  D3DXVec3TransformCoord(muzzez[i+lngt].position,muzz[i].position,mat);
 end;
// g_pd3ddevice.drawprimitiveUP(D3DPT_TRIANGLELIST,6,muzz,sizeof(TCustomvertex));
end;

destructor TF_M82A1.Destroy;
begin
 if m4tex<>nil then
 m4tex:=nil;
 if g_pmesh<>nil then
 g_pmesh:=nil;
 if g_pd3ddevice<>nil then
 g_pd3ddevice:=nil;
end;



////////////////////////////////
//            LAW
///////////////////////////////

constructor TF_LAW.Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
var
 tempmesh:ID3DXMesh;
 pVert:PCustomvertexarray;
 vmi,vma,tmp:TD3DVector;
 scl:single;
 i:integer;
 adj:PDword;
begin
 inherited Create;
 betoltve:=false;
 g_pD3Ddevice:=a_D3Ddevice;
 addfiletochecksum(fnev+'.x');
 if not LTFF(g_pd3dDevice, 'data/models/m4a1muzz.jpg',m4tex) then
   Exit;

 if not LTFF(g_pd3dDevice,fnev+'.jpg',m4tex) then
   Exit;

  makemuzzle;

  if FAILED(D3DXLoadMeshFromX(PChar(fnev+'.x'),0,g_pd3ddevice,nil,nil,nil,nil,tempmesh)) then exit;
  if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_CUSTOMVERTEX,g_pd3ddevice,g_pMesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;
  g_pMesh.LockVertexBuffer(0,pointer(pvert));
  D3DXComputeboundingbox(pointer(pvert),g_pMesh.GetNumVertices,g_pMesh.GetNumBytesPerVertex,vmi,vma);
  scl:=max(vma.x-vmi.x,max(vma.y-vmi.y,vma.z-vmi.z));
  scl:=scl/0.7;
  fc:=(vma.z-vmi.z)*0.5;
  for i:=0 to g_pMesh.GetNumVertices-1 do
  begin
   tmp.z:=-(pvert[i].position.x-vmi.x)*1.5/scl+0.2;
   tmp.y:=(pvert[i].position.y-vma.y)/scl+0.03;
   tmp.x:=(pvert[i].position.z-vma.z+fc)/scl-0.084;
 //  if abs(tmp.x)<0.005 then tmp.x:=0;
   pvert[i].color:=RGB(200,200,200);
   pvert[i].position:=tmp;
  end;
  g_pMesh.UnlockVertexBuffer;
  getmem(adj,g_pmesh.getnumfaces*12);
  g_pMesh.generateadjacency(0.001,adj);
  D3DXComputenormals(g_pMesh,adj);
  g_pMesh.OptimizeInplace(D3DXMESHOPT_COMPACT+D3DXMESHOPT_ATTRSORT+D3DXMESHOPT_VERTEXCACHE,adj,nil,nil,nil);
  freemem(adj);
  betoltve:=true;
end;

procedure TF_LAW.makemuzzlequad(hol:integer;v1,v2,v3,v4:TCustomVertex);
begin
 muzz[hol+0]:=v1;
 muzz[hol+1]:=v2;
 muzz[hol+2]:=v3;
 muzz[hol+3]:=v4;
 muzz[hol+4]:=v2;
 muzz[hol+5]:=v3;
end;

procedure TF_LAW.makemuzzle;
begin
 makemuzzlequad(0,CustomVertex(-0.5,-0.5,   0,0,0,0,ARGB(255,255,255,255),0,0,0,0),
                  CustomVertex( 0.5,-0.5,   0,0,0,0,ARGB(255,255,255,255),2,0,0,0),
                  CustomVertex(-0.5, 0.5,   0,0,0,0,ARGB(255,255,255,255),0,2,0,0),
                  CustomVertex( 0.5, 0.5,   0,0,0,0,ARGB(255,255,255,255),2,2,0,0));
 makemuzzlequad(6,CustomVertex(   0,   0,   0,0,0,0,ARGB(255,255,255,255),0,0,0,0),
                  CustomVertex(   0, 0.5,-0.5,0,0,0,ARGB(255,255,255,255),1,0,0,0),
                  CustomVertex(   0,-0.5,-0.5,0,0,0,ARGB(255,255,255,255),0,1,0,0),
                  CustomVertex(   0,   0,  -1,0,0,0,ARGB(255,255,255,255),1,1,0,0));
makemuzzlequad(12,CustomVertex(   0,   0,   0,0,0,0,ARGB(255,255,255,255),0,0,0,0),
                  CustomVertex( 0.5,   0,-0.5,0,0,0,ARGB(255,255,255,255),1,0,0,0),
                  CustomVertex(-0.5,   0,-0.5,0,0,0,ARGB(255,255,255,255),0,1,0,0),
                  CustomVertex(   0,   0,  -1,0,0,0,ARGB(255,255,255,255),1,1,0,0));

end;

procedure TF_LAW.draw;
begin
 g_pd3dDevice.Settexture(0,m4tex);
 g_pMesh.DrawSubset(0);
end;

procedure TF_LAW.pluszmuzzmatr(siz:single);
var
  matWorld,matWorld2: TD3DMatrix;
begin

   D3DXMatrixTranslation(matWorld,-0.00,-0.08,-0.7);
   D3DXMatrixScaling(matWorld2,siz/2,siz/2,siz);
   D3DXmatrixMultiply(matWorld,matWorld2,MatWorld);
   g_pd3dDevice.MultiplyTransform(D3DTS_WORLD, matWorld);

end;

procedure TF_LAW.drawmuzzle(siz:single);
var
mat:TD3DMatrix;
lngt,i:integer;
begin
 if siz=0 then exit;

 pluszmuzzmatr(siz);

 g_pd3ddevice.GetTransform(D3DTS_WORLD,mat);
 lngt:=length(muzzez);
 setlength(muzzez,lngt+length(muzz));
 for i:=0 to high(muzz) do
 begin
  muzzez[i+lngt]:=muzz[i];
  D3DXVec3TransformCoord(muzzez[i+lngt].position,muzz[i].position,mat);
 end;
// g_pd3ddevice.drawprimitiveUP(D3DPT_TRIANGLELIST,6,muzz,sizeof(TCustomvertex));
end;

destructor TF_LAW.Destroy;
begin
 if m4tex<>nil then
 m4tex:=nil;
 if g_pmesh<>nil then
 g_pmesh:=nil;
 if g_pd3ddevice<>nil then
 g_pd3ddevice:=nil;
end;

////////////////////////////////
//            MP5A3
///////////////////////////////

constructor TF_MP5A3.Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
var
 tempmesh:ID3DXMesh;
 pVert:PCustomvertexarray;
 vmi,vma,tmp:TD3DVector;
 scl:single;
 i:integer;
 adj:PDword;
begin
 inherited Create;
 betoltve:=false;
 g_pD3Ddevice:=a_D3Ddevice;
 addfiletochecksum(fnev+'.x');

 if not LTFF(g_pd3dDevice,fnev+'.jpg',m4tex) then
   Exit;

  makemuzzle;

  if FAILED(D3DXLoadMeshFromX(PChar(fnev+'.x'),0,g_pd3ddevice,nil,nil,nil,nil,tempmesh)) then exit;
  if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_CUSTOMVERTEX,g_pd3ddevice,g_pMesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;
  g_pMesh.LockVertexBuffer(0,pointer(pvert));
  D3DXComputeboundingbox(pointer(pvert),g_pMesh.GetNumVertices,g_pMesh.GetNumBytesPerVertex,vmi,vma);
  scl:=max(vma.x-vmi.x,max(vma.y-vmi.y,vma.z-vmi.z));
  scl:=scl/0.6;
  fc:=(vma.x-vmi.x)*0.5;
  for i:=0 to g_pMesh.GetNumVertices-1 do
  begin
   tmp.z:=-0.6+(pvert[i].position.z-vmi.z)/scl;
   tmp.y:=(pvert[i].position.y-vma.y)/scl+0.006;
   tmp.x:=(pvert[i].position.x-vma.x+fc)/scl;
   //if abs(tmp.x)<0.005 then tmp.x:=0;
   pvert[i].color:=RGB(200,200,200);
   pvert[i].position:=tmp;
  end;
  g_pMesh.UnlockVertexBuffer;
  getmem(adj,g_pmesh.getnumfaces*12);
  g_pMesh.generateadjacency(0.001,adj);
  D3DXComputenormals(g_pMesh,adj);
  g_pMesh.OptimizeInplace(D3DXMESHOPT_COMPACT+D3DXMESHOPT_ATTRSORT+D3DXMESHOPT_VERTEXCACHE,adj,nil,nil,nil);
  freemem(adj);
  betoltve:=true;
end;

procedure TF_MP5A3.makemuzzlequad(hol:integer;v1,v2,v3,v4:TCustomVertex);
begin
 muzz[hol+0]:=v1;
 muzz[hol+1]:=v2;
 muzz[hol+2]:=v3;
 muzz[hol+3]:=v4;
 muzz[hol+4]:=v2;
 muzz[hol+5]:=v3;
end;

procedure TF_MP5A3.makemuzzle;
begin
 makemuzzlequad(0,CustomVertex(-0.5,-0.5,   0,0,0,0,ARGB(255,255,255,255),0,0,0,0),
                  CustomVertex( 0.5,-0.5,   0,0,0,0,ARGB(255,255,255,255),2,0,0,0),
                  CustomVertex(-0.5, 0.5,   0,0,0,0,ARGB(255,255,255,255),0,2,0,0),
                  CustomVertex( 0.5, 0.5,   0,0,0,0,ARGB(255,255,255,255),2,2,0,0));
 makemuzzlequad(6,CustomVertex(   0,   0,   0,0,0,0,ARGB(255,255,255,255),0,0,0,0),
                  CustomVertex(   0, 0.5,-0.5,0,0,0,ARGB(255,255,255,255),1,0,0,0),
                  CustomVertex(   0,-0.5,-0.5,0,0,0,ARGB(255,255,255,255),0,1,0,0),
                  CustomVertex(   0,   0,  -1,0,0,0,ARGB(255,255,255,255),1,1,0,0));
makemuzzlequad(12,CustomVertex(   0,   0,   0,0,0,0,ARGB(255,255,255,255),0,0,0,0),
                  CustomVertex( 0.5,   0,-0.5,0,0,0,ARGB(255,255,255,255),1,0,0,0),
                  CustomVertex(-0.5,   0,-0.5,0,0,0,ARGB(255,255,255,255),0,1,0,0),
                  CustomVertex(   0,   0,  -1,0,0,0,ARGB(255,255,255,255),1,1,0,0));

end;

procedure TF_MP5A3.draw;
begin
 g_pd3dDevice.Settexture(0,m4tex);
 g_pMesh.DrawSubset(0);
end;

procedure TF_MP5A3.pluszmuzzmatr(siz:single);
var
  matWorld,matWorld2: TD3DMatrix;
begin

   D3DXMatrixTranslation(matWorld,-0.00,-0.06,-0.6);
   D3DXMatrixScaling(matWorld2,siz/2,siz/2,siz);
   D3DXmatrixMultiply(matWorld,matWorld2,MatWorld);
   g_pd3dDevice.MultiplyTransform(D3DTS_WORLD, matWorld);

end;

procedure TF_MP5A3.drawmuzzle(siz:single);
var
mat:TD3DMatrix;
lngt,i:integer;
begin
 if siz=0 then exit;

 pluszmuzzmatr(siz);

 g_pd3ddevice.GetTransform(D3DTS_WORLD,mat);
 lngt:=length(muzzez);
 setlength(muzzez,lngt+length(muzz));
 for i:=0 to high(muzz) do
 begin
  muzzez[i+lngt]:=muzz[i];
  D3DXVec3TransformCoord(muzzez[i+lngt].position,muzz[i].position,mat);
 end;
// g_pd3ddevice.drawprimitiveUP(D3DPT_TRIANGLELIST,6,muzz,sizeof(TCustomvertex));
end;

destructor TF_MP5A3.Destroy;
begin
 if m4tex<>nil then
 m4tex:=nil;
 if g_pmesh<>nil then
 g_pmesh:=nil;
 if g_pd3ddevice<>nil then
 g_pd3ddevice:=nil;
end;


/////////////////////////////////////
//               MPG
////////////////////////////////////


constructor TF_MPG.Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
var
 tempmesh:ID3DXMesh;
 pVert:PCustomvertexarray;
 vmi,vma,tmp:TD3DVector;
 scl:single;
 i:integer;
 adj:Pdword;
begin
 inherited Create;
 betoltve:=false;
 g_pD3Ddevice:=a_D3Ddevice;
 addfiletochecksum(fnev+'.x');
 if not LTFF(g_pd3dDevice,fnev+'.jpg',mpgtex) then
   Exit;
 if not LTFF(g_pd3dDevice,fnev+'em.jpg',mpgemap) then
   Exit;
 // makemuzzle(255);

  if FAILED(D3DXLoadMeshFromX(PChar(fnev+'.x'),0,g_pd3ddevice,nil,nil,nil,nil,tempmesh)) then exit;
  if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_CUSTOMVERTEX,g_pd3ddevice,g_pMesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;
  g_pMesh.LockVertexBuffer(0,pointer(pvert));
  D3DXComputeboundingbox(pointer(pvert),g_pMesh.GetNumVertices,g_pMesh.GetNumBytesPerVertex,vmi,vma);
  scl:=max(vma.x-vmi.x,max(vma.y-vmi.y,vma.z-vmi.z));
  scl:=scl/0.7;
  fc:=(vma.z-vmi.z)*0.5/scl;
  for i:=0 to g_pMesh.GetNumVertices-1 do
  begin
   tmp.z:=-(pvert[i].position.x-vmi.x)*0.9/scl;
   tmp.y:=(pvert[i].position.y-vma.y)/scl;
   tmp.x:=(pvert[i].position.z-vma.z)/scl+fc;
   pvert[i].color:=ARGB(0,200,200,200);
   pvert[i].position:=tmp;
   pvert[i].u2:=pvert[i].u;
   pvert[i].v2:=pvert[i].v;
  end;
  g_pMesh.UnlockVertexBuffer;

  getmem(adj,g_pmesh.getnumfaces*12);
  g_pMesh.generateadjacency(0.001,adj);
  D3DXComputenormals(g_pMesh,adj);
  g_pMesh.OptimizeInplace(D3DXMESHOPT_COMPACT+D3DXMESHOPT_ATTRSORT+D3DXMESHOPT_VERTEXCACHE,adj,nil,nil,nil);
  freemem(adj);
  betoltve:=true;
end;

procedure TF_MPG.makemuzzle(alpha:byte);
begin
 muzz[0]:=CustomVertex(-0.5,-0.5,   0,0,0,0,ARGB(alpha,0,0,0)+weapons[1].col[4],0,0,0,0);
 muzz[1]:=CustomVertex( 0.5,-0.5,   0,0,0,0,ARGB(alpha,0,0,0)+weapons[1].col[4],1,0,0,0);
 muzz[2]:=CustomVertex(-0.5, 0.5,   0,0,0,0,ARGB(alpha,0,0,0)+weapons[1].col[4],0,1,0,0);
 muzz[3]:=CustomVertex( 0.5, 0.5,   0,0,0,0,ARGB(alpha,0,0,0)+weapons[1].col[4],1,1,0,0);
 muzz[4]:=CustomVertex( 0.5,-0.5,   0,0,0,0,ARGB(alpha,0,0,0)+weapons[1].col[4],1,0,0,0);
 muzz[5]:=CustomVertex(-0.5, 0.5,   0,0,0,0,ARGB(alpha,0,0,0)+weapons[1].col[4],0,1,0,0);
end;

procedure TF_MPG.draw;
begin

  g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG1, D3DTA_TEXTURE);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG2, D3DTA_CURRENT);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_ADD);
 g_pd3dDevice.Settexture(0,mpgtex);
 g_pd3dDevice.Settexture(1,mpgemap);
 g_pMesh.DrawSubset(0);

 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
end;

procedure TF_MPG.pluszmuzzmatr(siz:single);
var
  matWorld,matWorld2: TD3DMatrix;
begin

   D3DXMatrixTranslation(matWorld,-0.00,-0.08,-0.7);
   D3DXMatrixScaling(matWorld2,siz,siz,siz);
   D3DXmatrixMultiply(matWorld,matWorld2,MatWorld);
   g_pd3dDevice.MultiplyTransform(D3DTS_WORLD, matWorld);

end;


procedure TF_MPG.drawmuzzle(siz:single);
var
mat:TD3DMatrix;
lngt,i:integer;
begin
 if siz>0.9 then exit;

  makemuzzle(round(250*(1-siz)));
 pluszmuzzmatr(siz);

 g_pd3ddevice.GetTransform(D3DTS_WORLD,mat);
 lngt:=length(muzzez);
 setlength(muzzez,lngt+length(muzz));
 for i:=0 to high(muzz) do
 begin
  muzzez[i+lngt]:=muzz[i];
  D3DXVec3TransformCoord(muzzez[i+lngt].position,muzz[i].position,mat);
 end;
end;

destructor TF_MPG.Destroy;
begin
 if mpgtex<>nil then
 mpgtex:=nil;
 if g_pmesh<>nil then
 g_pmesh:=nil;
 if g_pd3ddevice<>nil then
 g_pd3ddevice:=nil;
end;



/////////////////////////////////////
//               quadgun
////////////////////////////////////


constructor TF_quadgun.Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
var
 tempmesh:ID3DXMesh;
 pVert:PCustomvertexarray;
 vmi,vma,tmp:TD3DVector;
 scl:single;
 i:integer;
 adj:Pdword;
begin
 inherited Create;
 betoltve:=false;
 g_pD3Ddevice:=a_D3Ddevice;
 addfiletochecksum(fnev+'.x');

 if not LTFF(g_pd3dDevice,fnev+'.jpg',quadguntex) then
   Exit;

 if not LTFF(g_pd3dDevice,fnev+'em.jpg',quadgunemap) then
   Exit;
 // makemuzzle(255);

  if FAILED(D3DXLoadMeshFromX(PChar(fnev+'.x'),0,g_pd3ddevice,nil,nil,nil,nil,tempmesh)) then exit;
  if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_CUSTOMVERTEX,g_pd3ddevice,g_pMesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;
  g_pMesh.LockVertexBuffer(0,pointer(pvert));
  D3DXComputeboundingbox(pointer(pvert),g_pMesh.GetNumVertices,g_pMesh.GetNumBytesPerVertex,vmi,vma);
  scl:=max(vma.x-vmi.x,max(vma.y-vmi.y,vma.z-vmi.z));
  scl:=scl/0.8;
  fc:=(vma.z-vmi.z)*0.5/scl;
  for i:=0 to g_pMesh.GetNumVertices-1 do
  begin
   tmp.z:=(pvert[i].position.x-vma.x)*0.9/scl;
   tmp.y:=(pvert[i].position.y-vma.y)/scl+0.06;
   tmp.x:=-(pvert[i].position.z-vma.z)/scl-fc;
   pvert[i].color:=RGB(200,200,200);
   pvert[i].position:=tmp;
   pvert[i].u2:=pvert[i].u;
   pvert[i].v2:=pvert[i].v;
  end;
  g_pMesh.UnlockVertexBuffer;

  getmem(adj,g_pmesh.getnumfaces*12);
  g_pMesh.generateadjacency(0.001,adj);
  D3DXComputenormals(g_pMesh,adj);
  g_pMesh.OptimizeInplace(D3DXMESHOPT_COMPACT+D3DXMESHOPT_ATTRSORT+D3DXMESHOPT_VERTEXCACHE,adj,nil,nil,nil);
  freemem(adj);
  betoltve:=true;
end;

procedure TF_quadgun.makemuzzle(alpha:byte);
begin
 muzz[0]:=CustomVertex(-0.5,-0.5,   0,0,0,0,ARGB(alpha,0,0,0)+weapons[2].col[7],0,0,0,0);
 muzz[1]:=CustomVertex( 0.5,-0.5,   0,0,0,0,ARGB(alpha,0,0,0)+weapons[2].col[7],1,0,0,0);
 muzz[2]:=CustomVertex(-0.5, 0.5,   0,0,0,0,ARGB(alpha,0,0,0)+weapons[2].col[7],0,1,0,0);
 muzz[3]:=CustomVertex( 0.5, 0.5,   0,0,0,0,ARGB(alpha,0,0,0)+weapons[2].col[7],1,1,0,0);
 muzz[4]:=CustomVertex( 0.5,-0.5,   0,0,0,0,ARGB(alpha,0,0,0)+weapons[2].col[7],1,0,0,0);
 muzz[5]:=CustomVertex(-0.5, 0.5,   0,0,0,0,ARGB(alpha,0,0,0)+weapons[2].col[7],0,1,0,0);
end;

procedure TF_quadgun.draw;
begin
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG1, D3DTA_TEXTURE);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG2, D3DTA_CURRENT);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_ADD);
 g_pd3dDevice.Settexture(0,quadguntex);
 g_pd3dDevice.Settexture(1,quadgunemap);
 g_pMesh.DrawSubset(0);

 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
end;

procedure TF_quadgun.pluszmuzzmatr(siz:single);
var
  matWorld,matWorld2: TD3DMatrix;
begin

   D3DXMatrixTranslation(matWorld,-0.00,-0.08,-0.8);
   D3DXMatrixScaling(matWorld2,siz,siz,siz);
   D3DXmatrixMultiply(matWorld,matWorld2,MatWorld);
   g_pd3dDevice.MultiplyTransform(D3DTS_WORLD, matWorld);

end;

procedure TF_quadgun.drawmuzzle(siz:single);
var
mat:TD3DMatrix;
lngt,i:integer;
begin
 if siz>2.9 then exit;

  makemuzzle(round(250*(1-siz)));
 pluszmuzzmatr(siz);

 g_pd3ddevice.GetTransform(D3DTS_WORLD,mat);
 lngt:=length(muzzez);
 setlength(muzzez,lngt+length(muzz));
 for i:=0 to high(muzz) do
 begin
  muzzez[i+lngt]:=muzz[i];
  D3DXVec3TransformCoord(muzzez[i+lngt].position,muzz[i].position,mat);
 end;
end;

destructor TF_quadgun.Destroy;
begin
 if quadguntex<>nil then
 quadguntex:=nil;
 if g_pmesh<>nil then
 g_pmesh:=nil;
 if g_pd3ddevice<>nil then
 g_pd3ddevice:=nil;
end;


/////////////////////////////////////
//               NOOBcannon
////////////////////////////////////


constructor TF_NOOBcannon.Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
var
 tempmesh:ID3DXMesh;
 pVert:PCustomvertexarray;
 vmi,vma,tmp:TD3DVector;
 scl:single;
 i:integer;
 adj:Pdword;
begin
 inherited Create;
 betoltve:=false;
 g_pD3Ddevice:=a_D3Ddevice;
 addfiletochecksum(fnev+'.x');

 if not LTFF(g_pd3dDevice,fnev+'.jpg',tex) then
   Exit;

 if not LTFF(g_pd3dDevice,fnev+'em.jpg',emap) then
   Exit;
 // makemuzzle(255);

  if FAILED(D3DXLoadMeshFromX(PChar(fnev+'.x'),0,g_pd3ddevice,nil,nil,nil,nil,tempmesh)) then exit;
  if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_CUSTOMVERTEX,g_pd3ddevice,g_pMesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;
  g_pMesh.LockVertexBuffer(0,pointer(pvert));
  D3DXComputeboundingbox(pointer(pvert),g_pMesh.GetNumVertices,g_pMesh.GetNumBytesPerVertex,vmi,vma);
  scl:=max(vma.x-vmi.x,max(vma.y-vmi.y,vma.z-vmi.z));
  scl:=scl/0.4;
  fc:=(vma.z-vmi.z)*0.5/scl;
  for i:=0 to g_pMesh.GetNumVertices-1 do
  begin
   tmp.z:=(pvert[i].position.z+vmi.z)*1/scl-0.05;
   tmp.y:=(pvert[i].position.y-vma.y)/scl;
   tmp.x:=(pvert[i].position.x-vma.x)/scl+fc+0.0465;
   pvert[i].color:=RGB(200,200,200);
   pvert[i].position:=tmp;
   pvert[i].u2:=pvert[i].u;
   pvert[i].v2:=pvert[i].v;
  end;
  g_pMesh.UnlockVertexBuffer;

  getmem(adj,g_pmesh.getnumfaces*12);
  g_pMesh.generateadjacency(0.001,adj);
  D3DXComputenormals(g_pMesh,adj);
  g_pMesh.OptimizeInplace(D3DXMESHOPT_COMPACT+D3DXMESHOPT_ATTRSORT+D3DXMESHOPT_VERTEXCACHE,adj,nil,nil,nil);
  freemem(adj);
  betoltve:=true;
end;

{procedure TF_NOOBcannon.makemuzzle(alpha:byte);
begin
 muzz[0]:=CustomVertex(-0.5,-0.5,   0,0,0,0,ARGB(alpha,255,255,255),0,0,0,0);
 muzz[1]:=CustomVertex( 0.5,-0.5,   0,0,0,0,ARGB(alpha,255,255,255),1,0,0,0);
 muzz[2]:=CustomVertex(-0.5, 0.5,   0,0,0,0,ARGB(alpha,255,255,255),0,1,0,0);
 muzz[3]:=CustomVertex( 0.5, 0.5,   0,0,0,0,ARGB(alpha,255,255,255),1,1,0,0);
end; }

procedure TF_NOOBcannon.draw;
begin
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG1, D3DTA_TEXTURE);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG2, D3DTA_CURRENT);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_ADD);
 g_pd3dDevice.Settexture(0,tex);
 g_pd3dDevice.Settexture(1,emap);
 g_pMesh.DrawSubset(0);

 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
end;

procedure TF_NOOBcannon.pluszmuzzmatr(siz:single);
var
  matWorld,matWorld2: TD3DMatrix;
begin

   D3DXMatrixTranslation(matWorld,-0.00,-0.08,-0.7);
   D3DXMatrixScaling(matWorld2,siz,siz,siz);
   D3DXmatrixMultiply(matWorld,matWorld2,MatWorld);
   g_pd3dDevice.MultiplyTransform(D3DTS_WORLD, matWorld);

end;

procedure TF_NOOBcannon.drawmuzzle(siz:single);
begin
 //roflmao
end;

destructor TF_NOOBcannon.Destroy;
begin
 if tex<>nil then
 tex:=nil;
 if g_pmesh<>nil then
 g_pmesh:=nil;
 if g_pd3ddevice<>nil then
 g_pd3ddevice:=nil;
end;

////////////////////////////////
//            x72
///////////////////////////////

constructor TF_x72.Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
var
 tempmesh:ID3DXMesh;
 pVert:PCustomvertexarray;
 vmi,vma,tmp:TD3DVector;
 scl:single;
 i:integer;
 adj:PDword;
begin
 inherited Create;
 betoltve:=false;
 g_pD3Ddevice:=a_D3Ddevice;
 addfiletochecksum(fnev+'.x');


 if not LTFF(g_pd3dDevice, fnev+'tex.jpg',tex) then
   Exit;

 if not LTFF(g_pd3dDevice,fnev+'em.jpg',emap) then
   Exit;

  makemuzzle;

  if FAILED(D3DXLoadMeshFromX(PChar(fnev+'.x'),0,g_pd3ddevice,nil,nil,nil,nil,tempmesh)) then exit;
  if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_CUSTOMVERTEX,g_pd3ddevice,g_pMesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;
  g_pMesh.LockVertexBuffer(0,pointer(pvert));
  D3DXComputeboundingbox(pointer(pvert),g_pMesh.GetNumVertices,g_pMesh.GetNumBytesPerVertex,vmi,vma);
  scl:=max(vma.x-vmi.x,max(vma.y-vmi.y,vma.z-vmi.z));
  scl:=scl/0.7;
  fc:=(vma.z-vmi.z)*0.5;
  for i:=0 to g_pMesh.GetNumVertices-1 do
  begin
   tmp.x:=(pvert[i].position.x)/scl;
   tmp.y:=(pvert[i].position.y-vma.y)/scl;
   tmp.z:=(pvert[i].position.z-vma.z)/scl;//+0.001;
   if abs(tmp.x)<0.005 then tmp.x:=0;
   pvert[i].color:=RGB(200,200,200);
   pvert[i].position:=tmp;
  end;

  g_pMesh.UnlockVertexBuffer;
  getmem(adj,g_pmesh.getnumfaces*12);
  g_pMesh.generateadjacency(0.001,adj);
  D3DXComputenormals(g_pMesh,adj);
  g_pMesh.OptimizeInplace(D3DXMESHOPT_COMPACT+D3DXMESHOPT_ATTRSORT+D3DXMESHOPT_VERTEXCACHE,adj,nil,nil,nil);
  freemem(adj);
  betoltve:=true;
end;

procedure TF_x72.makemuzzlequad(hol:integer;v1,v2,v3,v4:TCustomVertex);
begin
 muzz[hol+0]:=v1;
 muzz[hol+1]:=v2;
 muzz[hol+2]:=v3;
 muzz[hol+3]:=v4;
 muzz[hol+4]:=v2;
 muzz[hol+5]:=v3;
end;

procedure TF_x72.makemuzzle;
begin
 makemuzzlequad(0,CustomVertex(-0.5,-0.5,   0,0,0,0,weapons[4].col[8],0,0,0,0),
                  CustomVertex( 0.5,-0.5,   0,0,0,0,weapons[4].col[8],0,2,0,0),
                  CustomVertex(-0.5, 0.5,   0,0,0,0,weapons[4].col[8],1,0,0,0),
                  CustomVertex( 0.5, 0.5,   0,0,0,0,weapons[4].col[8],1,2,0,0));
 makemuzzlequad(6,CustomVertex(   0, 0.5,   0,0,0,0,weapons[4].col[8],0,1,0,0),
                  CustomVertex(   0,-0.5,   0,0,0,0,weapons[4].col[8],1,1,0,0),
                  CustomVertex(   0, 0.5,  -1,0,0,0,weapons[4].col[8],0,0,0,0),
                  CustomVertex(   0,-0.5,  -1,0,0,0,weapons[4].col[8],1,0,0,0));
makemuzzlequad(12,CustomVertex( 0.5,   0,   0,0,0,0,weapons[4].col[8],0,1,0,0),
                  CustomVertex(-0.5,   0,   0,0,0,0,weapons[4].col[8],1,1,0,0),
                  CustomVertex( 0.5,   0,  -1,0,0,0,weapons[4].col[8],0,0,0,0),
                  CustomVertex(-0.5,   0,  -1,0,0,0,weapons[4].col[8],1,0,0,0));
end;

procedure TF_x72.draw;
begin
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG1, D3DTA_TEXTURE);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG2, D3DTA_CURRENT);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_ADD);
 g_pd3dDevice.Settexture(0,tex);
 g_pd3dDevice.Settexture(1,emap);
 g_pMesh.DrawSubset(0);

 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
end;

procedure TF_x72.pluszmuzzmatr(siz:single);
var
  matWorld,matWorld2: TD3DMatrix;
begin

   D3DXMatrixTranslation(matWorld,-0.00,-0.08,-0.7);
   D3DXMatrixScaling(matWorld2,(1-siz),siz,siz*2);
   D3DXmatrixMultiply(matWorld,matWorld2,MatWorld);
   g_pd3dDevice.MultiplyTransform(D3DTS_WORLD, matWorld);

end;

procedure TF_x72.drawmuzzle(siz:single);
var
mat:TD3DMatrix;
lngt,i:integer;
begin
 if siz=0 then exit;

 pluszmuzzmatr(siz);

 g_pd3ddevice.GetTransform(D3DTS_WORLD,mat);
 lngt:=length(muzzez);
 setlength(muzzez,lngt+length(muzz));
 for i:=0 to high(muzz) do
 begin
  muzzez[i+lngt]:=muzz[i];
  D3DXVec3TransformCoord(muzzez[i+lngt].position,muzz[i].position,mat);
 end;
// g_pd3ddevice.drawprimitiveUP(D3DPT_TRIANGLELIST,6,muzz,sizeof(TCustomvertex));
end;

destructor TF_x72.Destroy;
begin
 if tex<>nil then
 tex:=nil;
 if g_pmesh<>nil then
 g_pmesh:=nil;
 if g_pd3ddevice<>nil then
 g_pd3ddevice:=nil;
end;


/////////////////////////////////////
//               H31
////////////////////////////////////


constructor TF_H31.Create(a_D3Ddevice:IDirect3ddevice9;fnev:string);
var
 tempmesh:ID3DXMesh;
 pVert:PCustomvertexarray;
 vmi,vma,tmp:TD3DVector;
 scl:single;
 i:integer;
 adj:Pdword;
begin
 inherited Create;
 betoltve:=false;
 g_pD3Ddevice:=a_D3Ddevice;
 addfiletochecksum(fnev+'.x');

 if not LTFF(g_pd3dDevice,fnev+'.jpg',tex) then
   Exit;

 // makemuzzle(255);

  if FAILED(D3DXLoadMeshFromX(PChar(fnev+'.x'),0,g_pd3ddevice,nil,nil,nil,nil,tempmesh)) then exit;
  if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_CUSTOMVERTEX,g_pd3ddevice,g_pMesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;
  g_pMesh.LockVertexBuffer(0,pointer(pvert));
  D3DXComputeboundingbox(pointer(pvert),g_pMesh.GetNumVertices,g_pMesh.GetNumBytesPerVertex,vmi,vma);
  scl:=max(vma.x-vmi.x,max(vma.y-vmi.y,vma.z-vmi.z));
  scl:=scl/0.4;
  fc:=(vma.z-vmi.z)*0.5/scl;
  for i:=0 to g_pMesh.GetNumVertices-1 do
  begin
   tmp.x:=(pvert[i].position.z+vmi.z)*1/scl+0.065;
   tmp.y:=-(pvert[i].position.y-vma.y)/scl-0.03;
   tmp.z:=(pvert[i].position.x-vma.x)/scl+fc-0.3;
   pvert[i].color:=RGB(200,200,200);
   pvert[i].position:=tmp;
   pvert[i].u2:=pvert[i].u;
   pvert[i].v2:=pvert[i].v;
  end;
  g_pMesh.UnlockVertexBuffer;

  getmem(adj,g_pmesh.getnumfaces*12);
  g_pMesh.generateadjacency(0.001,adj);
  D3DXComputenormals(g_pMesh,adj);
  g_pMesh.OptimizeInplace(D3DXMESHOPT_COMPACT+D3DXMESHOPT_ATTRSORT+D3DXMESHOPT_VERTEXCACHE,adj,nil,nil,nil);
  freemem(adj);
  betoltve:=true;
end;

procedure TF_H31.draw;
begin
 g_pd3dDevice.Settexture(0,tex);
 g_pMesh.DrawSubset(0);
end;

procedure TF_H31.pluszmuzzmatr(siz:single);
var
  matWorld,matWorld2: TD3DMatrix;
begin

   D3DXMatrixTranslation(matWorld,-0.00,-0.08,-0.7);
   D3DXMatrixScaling(matWorld2,siz,siz,siz);
   D3DXmatrixMultiply(matWorld,matWorld2,MatWorld);
   g_pd3dDevice.MultiplyTransform(D3DTS_WORLD, matWorld);

end;


destructor TF_H31.Destroy;
begin
 if tex<>nil then
 tex:=nil;
 if g_pmesh<>nil then
 g_pmesh:=nil;
 if g_pd3ddevice<>nil then
 g_pd3ddevice:=nil;
end;


//***************************************
//***************************************
//*******TOVÁBBI FEGYVEREK HELYE!!!******
//***************************************
//***************************************

constructor TFegyv.Create(a_D3Ddevice:IDirect3ddevice9);
begin
 inherited Create;
 betoltve:=false;
 g_pD3Ddevice:=a_D3Ddevice;
 addfiletochecksum('data\models\m4a1.x');
 M4A1:=TF_M4A1.create(a_D3Ddevice,'data\models\m4a1');
 if not M4A1.betoltve then exit;
 addfiletochecksum('data\models\m82.x');
 M82A1:=TF_M82A1.create(a_D3Ddevice,'data\models\m82');
 if not M82A1.betoltve then exit;
 addfiletochecksum('data\models\mpr.x');
 MPG:=TF_MPG.create(a_D3Ddevice,'data\models\mpg');
 if not MPG.betoltve then exit;
 addfiletochecksum('data\models\quad.x');
 quadgun:=TF_quadgun.create(a_D3Ddevice,'data\models\quad');
 if not quadgun.betoltve then exit;
 addfiletochecksum('data\models\law.x');
 law:=TF_law.create(a_D3Ddevice,'data\models\law');
 if not law.betoltve then exit;
 addfiletochecksum('data\models\noobcannon.x');
 noobcannon:=TF_noobcannon.create(a_D3Ddevice,'data\models\noobcannon');
 if not noobcannon.betoltve then exit;
 Mp5a3:=TF_Mp5a3.create(a_D3Ddevice,'data\models\Mp5');
 if not Mp5a3.betoltve then exit;
 addfiletochecksum('data\models\x72.x');
 x72:=TF_x72.create(a_D3Ddevice,'data\models\x72');
 if not x72.betoltve then exit;
 addfiletochecksum('data\models\wand.x');
 H31:=TF_H31.create(a_D3Ddevice,'data\models\wand');
 if not H31.betoltve then exit;

 if not LTFF (g_pd3dDevice,'data\models\m4a1muzz.jpg',gunmuztex) then
   Exit;

 if not LTFF (g_pd3dDevice,'data\models\mpgmuzzn.jpg',mpgmuztex) then
   Exit;

 if not LTFF (g_pd3dDevice,'data\pju.png',x72muztex) then
   Exit;

 if FAILED(g_pd3dDevice.CreateVertexBuffer(5000*sizeof(TCustomVertex),
                                            D3DUSAGE_WRITEONLY+D3DUSAGE_DYNAMIC, D3DFVF_CUSTOMVERTEX,
                                            D3DPOOL_DEFAULT, g_pVB, nil))
  then Exit;

 betoltve:=true;
end;

procedure TFegyv.drawfegyv(mit:byte);
begin
 case mit of
  FEGYV_M4A1:M4A1.draw;
  FEGYV_M82A1:M82A1.draw;
  FEGYV_LAW:LAW.draw;
  FEGYV_MPG :MPG .draw;
  FEGYV_QUAD :quadgun.draw;
  FEGYV_NOOB:noobcannon.draw;
  FEGYV_MP5A3:mp5a3.draw;
  FEGYV_X72:x72.draw;
  FEGYV_H31_G:H31.draw;
  FEGYV_H31_T:H31.draw;
 end;
end;

//ez a bal kéz egyébként
function TFegyv.jkez(afegyv:word;astate:byte):TD3DXVector3;
var
bol:boolean;
begin
 bol:=(0=(astate and MSTAT_CSIPO));

// if bol then afegyv:=afegyv+256;

 if bol then
 case afegyv of
  FEGYV_M82A1:result:=D3DXVector3(-0.05,1.4 ,-0.6);
  FEGYV_QUAD:result:=D3DXVector3(0,1.25 ,-0.48);
  FEGYV_X72:result:=D3DXVector3(-0.05,1.27 ,-0.45);
  FEGYV_NOOB:result:=D3DXVector3(-0.05,1.17,-0.35);
  FEGYV_LAW:result:=D3DXVector3(-0.1,1.37,-0.45);
  FEGYV_MP5A3:result:=D3DXVector3(-0.05,1.41,-0.45);
  FEGYV_H31_T:result:=D3DXVector3(0,1.3 ,-0.1);
  FEGYV_H31_G:result:=D3DXVector3(0,1.3 ,-0.1);
  else result:=D3DXVector3(-0.05,1.37,-0.45);
 end
 else
 case afegyv of
  FEGYV_NOOB: result:=D3DXVector3(0.15,1.0,-0.13) ;
  FEGYV_LAW:result:=D3DXVector3(-0.05,1.07,-0.27);
  FEGYV_MP5A3:result:=D3DXVector3(-0.05,1.10,-0.45);
  FEGYV_QUAD:result:=D3DXVector3(-0.00,1.01 ,-0.28);
  FEGYV_X72:result:=D3DXVector3(0.01,1,-0.37);
  FEGYV_H31_T:result:=D3DXVector3(0,1.0 ,-0.1);
  FEGYV_H31_G:result:=D3DXVector3(0,1.0 ,-0.1);
  else result:=D3DXVector3(-0.05,1.05,-0.45);
 end;

 if 0<(astate and MSTAT_GUGGOL) then
 begin
  result.y:=result.y-0.5;
 end;
end;

//ez meg a jobb kéz
function TFegyv.bkez(afegyv:word;astate:byte):TD3DXVector3;
var
bol:boolean;
begin
 bol:=0=(astate and MSTAT_CSIPO);

// if bol then afegyv:=afegyv+256;

 if bol then
 case afegyv of
  FEGYV_M82A1:result:=D3DXVector3(-0.05,1.4,-0.35);
  FEGYV_QUAD:result:=D3DXVector3(0,1.28 ,-0.13);
  FEGYV_X72:result:=D3DXVector3(-0.05,1.27,-0.15);
  FEGYV_NOOB:result:=D3DXVector3(-0.05,1.15,-0.10);
  FEGYV_LAW:result:=D3DXVector3(-0.1,1.35,-0.27);
  FEGYV_H31_T:result:=D3DXVector3(-0.05,1.48 ,-0.30);
  FEGYV_H31_G:result:=D3DXVector3(-0.05,1.48 ,-0.30);
  else result:=D3DXVector3(-0.05,1.35,-0.27);
 end
 else
 case afegyv of
  FEGYV_NOOB: result:=D3DXVector3(-0.17,1.07,-0.1) ;
  FEGYV_LAW:result:=D3DXVector3(-0.15,1.1,-0.45);
  FEGYV_QUAD:result:=D3DXVector3(-0.05,1.00 ,-0.07);
  FEGYV_X72:result:=D3DXVector3(-0.07,0.95,-0.15);
  FEGYV_H31_T:result:=D3DXVector3(-0.05,1.18 ,-0.30);
  FEGYV_H31_G:result:=D3DXVector3(-0.05,1.18 ,-0.30);
  else result:=D3DXVector3(-0.05,1.05,-0.27);
 end;

 if 0<(astate and MSTAT_GUGGOL) then
 begin
  result.y:=result.y-0.5;
 end;

end;



procedure TFegyv.drawscope(mit:byte);
begin
 case mit of
  FEGYV_M82A1:M82A1.drawscope;
 end;
end;

procedure TFegyv.preparealpha;
begin
 g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
 g_pd3dDevice.SetRenderState(D3DRS_AMBIENT, $FFFFFFFF);
 g_pd3ddevice.SetRenderState(D3DRS_BLENDFACTOR,$FFFFFFFF);
 g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
 g_pd3dDevice.SetRenderState(D3DRS_ZWriteENABLE, iFalse);
 g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iFalse);

 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG1);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP,   D3DTOP_SELECTARG2);
 
// g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_BLENDFACTOR);
// g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_BLENDFACTOR);

 g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
 g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,D3DBLEND_INVSRCALPHA );
 g_pd3ddevice.SetRenderState(D3DRS_BLENDOP,D3DBLENDOP_ADD);

 //g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_NONE );

 g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_MIRROR);
 g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_MIRROR);
 g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_POINT );
end;

procedure Tfegyv.drawfegyeffekt(mit:byte;mekkora:single);
begin
case mit of
  FEGYV_M4A1:M4A1.drawmuzzle(mekkora);
  FEGYV_M82A1:M82A1.drawmuzzle(mekkora);
  FEGYV_MP5A3:MP5A3.drawmuzzle(mekkora);
 // FEGYV_LAW:LAW.drawmuzzle(mekkora);
  FEGYV_MPG :MPG .drawmuzzle(mekkora*2);
  FEGYV_QUAD:quadgun.drawmuzzle(mekkora*3);
  //FEGYV_NOOB:Noobcannon.drawmuzzle(mekkora);
  FEGYV_X72:X72.drawmuzzle(mekkora);
 end;
end;

procedure TFegyv.FlushFegyeffekt;
const
PUFFER_MERET = 5000;
var
pVert:PCustomvertexarray;
curr,mpgstart,x72start:integer;
label
unlock;
begin
 mpgstart:=0; x72start:=0;
 g_pd3ddevice.SetTransform(D3DTS_WORLD,identmatr);
  g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
 curr:=0;
 if FAILED(g_pVB.Lock(0, PUFFER_MERET*sizeof(Tcustomvertex), Pointer(pVert), D3DLOCK_DISCARD))
  then Exit;

 if curr+length(M4A1.muzzez)>=PUFFER_MERET then goto unlock;
 copymemory(@(pVert[curr]),@(M4A1.muzzez[0]),length(M4A1.muzzez)*sizeof(TCustomvertex));
 inc(curr,length(M4A1.muzzez));
 setlength(M4A1.muzzez,0);

 if curr+length(M82A1.muzzez)>=PUFFER_MERET then goto unlock;
 copymemory(@(pVert[curr]),@(M82A1.muzzez[0]),length(M82A1.muzzez)*sizeof(TCustomvertex));
 inc(curr,length(M82A1.muzzez));
 setlength(M82A1.muzzez,0); 

 if curr+length(MP5A3.muzzez)>=PUFFER_MERET then goto unlock;
 copymemory(@(pVert[curr]),@(MP5A3.muzzez[0]),length(MP5A3.muzzez)*sizeof(TCustomvertex));
 inc(curr,length(MP5A3.muzzez));
 setlength(MP5A3.muzzez,0);

 mpgstart:=curr;

 if curr+length(MPG.muzzez)>=PUFFER_MERET then goto unlock;
 copymemory(@(pVert[curr]),@(MPG.muzzez[0]),length(MPG.muzzez)*sizeof(TCustomvertex));
 inc(curr,length(MPG.muzzez));
 setlength(MPG.muzzez,0);

 if curr+length(quadgun.muzzez)>=PUFFER_MERET then goto unlock;
 copymemory(@(pVert[curr]),@(quadgun.muzzez[0]),length(quadgun.muzzez)*sizeof(TCustomvertex));
 inc(curr,length(quadgun.muzzez));
 setlength(quadgun.muzzez,0);

 x72start:=curr;

 if curr+length(X72.muzzez)>=PUFFER_MERET then goto unlock;
 copymemory(@(pVert[curr]),@(X72.muzzez[0]),length(X72.muzzez)*sizeof(TCustomvertex));
 inc(curr,length(X72.muzzez));
 setlength(X72.muzzez,0);
 unlock:
 g_pVB.Unlock;
 g_pd3ddevice.SetStreamSource(0,g_pVB,0,sizeof(TCustomvertex));
 g_pd3ddevice.SetFVF(D3DFVF_CUSTOMVERTEX);
 g_pd3ddevice.settexture(0,gunmuztex);
 g_pd3ddevice.DrawPrimitive(D3DPT_TRIANGLELIST,0,mpgstart div 3);
 g_pd3ddevice.settexture(0,mpgmuztex);
 g_pd3ddevice.DrawPrimitive(D3DPT_TRIANGLELIST,mpgstart,(x72start-mpgstart) div 3);
 g_pd3ddevice.settexture(0,x72muztex);
 g_pd3ddevice.DrawPrimitive(D3DPT_TRIANGLELIST,x72start,(curr-x72start) div 3);
 setlength(m4A1.muzzez,0);

end;

procedure TFegyv.unpreparealpha;
begin
 g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
 g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);
 g_pd3dDevice.SetRenderState(D3DRS_ZWriteENABLE, iTrue);
 g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR );

end;


destructor TFegyv.Destroy;
begin
 M4A1.destroy;
 MPG.destroy;
 if g_pd3ddevice<>nil then
 g_pd3ddevice:=nil;
 setlength(M4proj,0);
 setlength(Mpgproj,0);
 inherited;
end;
end.
