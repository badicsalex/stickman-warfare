unit foliage;

interface
uses  Sysutils, Direct3D9, D3DX9, Windows, Typestuff, PerlinNoise;
type

 PBokorVertex = ^TBokorVertex;
 TBokorVertex = record
    position: TD3DVector; // The 3D position for the vertex
    normal: TD3DVector;
    u,v:single;
  end;

  PBokorVertexArray = ^TBokorVertexArray;
  TBokorVertexArray = array [0..100000] of TBokorVertex;


 TFoliage = class (TObject)
 protected
   g_pD3Ddevice:IDirect3ddevice9;
   g_pVB:IDirect3DVertexBuffer9;
   g_pIB:IDirect3DIndexBuffer9;
   g_ptexture:IDirect3DTexture9;
 public
  bokrok:array [0..31,0..31,0..11] of Tbokorvertex;  //félrevezetõ név, pozíciók...
  betoltve:boolean;
  scalfac:single;
  hscale,vscale,vpls:single;
  constructor Create(dev:Idirect3ddevice9; texnam:string; ahscale,avscale,avpls:single);
  procedure Init;
  procedure Render;
  procedure update(lvl:Plvl;yandnorm:Tyandnorm);
  destructor Destroy;reintroduce;
 end;

 Trockindvert = record
  verts:array of Tposnormuv;
  inds:array of word;
 end;

 {TRocks = class (TObject)
 protected
   g_pD3Ddevice:IDirect3ddevice9;
   g_pVB:IDirect3DVertexBuffer9;
   g_pIB:IDirect3DIndexBuffer9;
   g_ptexture:IDirect3DTexture9;
 public
  kovek:array of Trockindvert;
  betoltve:boolean;
  scalfac:single;
  hscale,vscale,vpls:single;
  constructor Create(dev:Idirect3ddevice9; texnam:string; ahscale,avscale,avpls:single);
  procedure Init;
  procedure Render;
  procedure update(lvl:Plvl;advwove:Tadvwove);
  destructor Destroy;reintroduce;
 end; }
 
procedure generaterock(seed,size:single;var rock:Trockindvert);

implementation

const
 D3DFVF_BOKORVERTEX = (D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_TEX1);

magicbushvertices:array [0..11] of Tbokorvertex =((position:(x: 0;y:1;z: 1);u:1;v:1),  //egyik /\ teteje
                                                (position:(x: 0;y:1;z:-1);u:0;v:1),
                                                (position:(x: 1;y:0;z: 1);u:1;v:0),  //alja
                                                (position:(x: 1;y:0;z:-1);u:0;v:0),
                                                (position:(x:-1;y:0;z: 1);u:1;v:0),
                                                (position:(x:-1;y:0;z:-1);u:0;v:0),

                                                (position:(x: 1;y:1;z: 0);u:1;v:1), //másik /\ teteje
                                                (position:(x:-1;y:1;z: 0);u:0;v:1),
                                                (position:(x: 1;y:0;z: 1);u:1;v:0), //alja
                                                (position:(x:-1;y:0;z: 1);u:0;v:0),
                                                (position:(x: 1;y:0;z:-1);u:1;v:0),
                                                (position:(x:-1;y:0;z:-1);u:0;v:0));


constructor TFoliage.Create(dev:Idirect3ddevice9; texnam:string; ahscale,avscale,avpls:single);
var
pIndices:PWordArray;
i:integer;
begin
 inherited Create;
 betoltve:=false;
 g_pD3Ddevice:=dev;
  if FAILED(g_pd3dDevice.CreateVertexBuffer(sizeof(bokrok),
                                            D3DUSAGE_WRITEONLY+D3DUSAGE_DYNAMIC, D3DFVF_bokorvertex,
                                            D3DPOOL_DEFAULT, g_pVB, nil))
  then Exit;
  if FAILED(g_pd3dDevice.CreateIndexBuffer(32*32*24*2,
                                            D3DUSAGE_WRITEONLY,D3DFMT_INDEX16,
                                            D3DPOOL_DEFAULT, g_pIB, nil))

  then Exit;

  if FAILED(g_pIB.Lock(0, 32*32*12*2*2, Pointer(pindices), 0))
  then Exit;
  for i:=0 to 32*32*2-1 do
  begin
   pindices[i*12+ 0]:=i*6+0;  //V egyik szára
   pindices[i*12+ 1]:=i*6+1;
   pindices[i*12+ 2]:=i*6+2;

   pindices[i*12+ 3]:=i*6+2;
   pindices[i*12+ 4]:=i*6+3;
   pindices[i*12+ 5]:=i*6+1;

   pindices[i*12+ 6]:=i*6+4; //V másik szára
   pindices[i*12+ 7]:=i*6+5;
   pindices[i*12+ 8]:=i*6+1;

   pindices[i*12+ 9]:=i*6+0;
   pindices[i*12+10]:=i*6+1;
   pindices[i*12+11]:=i*6+4;
  end;

  g_pIB.unlock;

  if not LTFF(g_pd3dDevice, 'data\'+texnam,g_ptexture) then
   Exit;
  hscale:=ahscale;
  vscale:=avscale;
  vpls:=avpls;
  betoltve:=true;
end;

procedure TFoliage.Init;
begin

 g_pd3ddevice.SetRenderState(D3DRS_ALPHAREF, $EF);
 g_pd3ddevice.SetRenderState(D3DRS_ALPHATESTENABLE, iTRUE);
 g_pd3ddevice.SetRenderState(D3DRS_Lighting, iTRUE);
 g_pd3ddevice.SetRenderState(D3DRS_ALPHAFUNC,  D3DCMP_GREATEREQUAL );
 g_pd3ddevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);

 g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);

 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1,  D3DTA_TEXTURE);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2,  D3DTA_DIFFUSE );

 g_pd3dDevice.SetRenderState(D3DRS_TEXTUREFACTOR,$FFFFFFFF);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,  FAKE_HDR);
 //g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,  D3DTOP_SELECTARG2);
end;


procedure TFoliage.Render;
begin
 g_pd3dDevice.SetStreamSource(0, g_pVB, 0, SizeOf(Tbokorvertex));
 g_pd3dDevice.SetIndices(g_pIB);
 g_pd3dDevice.SetTexture(0,g_pTexture);

 g_pd3dDevice.SetFVF(D3DFVF_bokorvertex);
 g_pd3dDevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST,0,0,32*32*12,0,32*32*8);
//  g_pd3dDevice.DrawPrimitive(D3DPT_TRIANGLELIST,0,32*32*4)
end;

                                //1,2,3,4, jobb,bal,fel,le
{procedure Tfoliage.update(lvl:Tlvl;jbfl:byte);
var
i,j:integer;
begin
//jeah;
case jbfl of
1: for i:=31 downto 1 do
    bokrok[i]:=bokrok[i-1];
2: for i:=0 to 30 do
    bokrok[i]:=bokrok[i+1];
3: for i:=0 to 31 do
    for j:=31 downto 1 do
     bokrok[i,j]:=bokrok[i,j-1];
4: for i:=0 to 31 do
    for j:=0 to 30 do
     bokrok[i,j]:=bokrok[i,j+1];
end;
end;  }

procedure Tfoliage.update(lvl:Plvl;yandnorm:Tyandnorm);
var
i,j,k:integer;
Vmost:Tbokorvertex;
pVertices:PbokorvertexArray;
vec:TD3DXVector3;
pls:single;
n:TD3DXVector3;
begin
pls:=lvl[0].position.z-lvl[1].position.z;
pls:=pls;
//jeah;
g_pVB.lock(0,sizeof(bokrok),pointer(pvertices),D3DLOCK_DISCARD);
for i:=0 to 31 do
 for j:=0 to 31 do
 begin

  vec:=lvl[i*32+j].position;
  d3dxvec3add(vec,vec,D3DXVector3(perlin.Noise(vec.x,0.5,vec.z)*pls,0, perlin.Noise(vec.x,1.5,vec.z)*pls));

  n:=lvl[i*32+j].normal;

  yandnorm(vec.x,vec.y,vec.z,n,1);

  if  (n.y=-2) or (n.y<0.83) or (n.y>1) or (vec.y<16) then
   vec:=D3DXVector3Zero;


  for k:=0 to 11 do
  begin
   Vmost:=magicbushvertices[k];
   Vmost.normal:=n;
   with Vmost.position do
   begin
    x:=x*hscale+vec.x;
    z:=z*hscale+vec.z;
    y:=vpls+y*vscale+vec.y;
   end;

   pvertices[k+12*(j+32*i)]:=Vmost;
  end;
 end;
g_pVB.unlock;
end;

destructor TFoliage.Destroy;
begin
 g_pIB:=nil;
 g_pVB:=nil;
 if g_pd3ddevice<> nil then
 g_pD3Ddevice:=nil;
 inherited Destroy;
end;


procedure generaterock(seed,size:single;var rock:Trockindvert);
var
i,j,k,l:integer;
hol:integer;
edges:array of array [0..1] of word;
vane:array of boolean;
remap:array of word;
pos,n,v1,v2,v3:TD3DXVector3;
e1,e2,tmp:integer;
begin
with rock do
begin
 setlength(verts,10);
 setlength(inds,6);
 for i:=0 to high(verts) do
  verts[i].position:=randomvec(seed*107.8+i*37.73,size);
 inds[0]:=0;
 inds[1]:=1;
 inds[2]:=2;

 inds[3]:=1;
 inds[4]:=0;
 inds[5]:=2;

 for i:=3 to high(verts) do
 begin
  j:=0;
  setlength(edges,0);
  pos:=verts[i].position;
  while j<=high(inds) do
  begin
   v1:=verts[inds[j+0]].position;
   v2:=verts[inds[j+1]].position;
   v3:=verts[inds[j+2]].position;
   d3dxvec3subtract(v2,v2,v1);
   d3dxvec3subtract(v3,v3,v1);
   d3dxvec3cross(n,v2,v3);
   if d3dxvec3dot(n,v1)<d3dxvec3dot(n,pos) then
   begin
    for k:=0 to 2 do
    begin
     e1:=inds[j+k];
     e2:=inds[j+(k+1) mod 3];
    // if e1>e2 then begin tmp:=e1; e1:=e2; e2:=tmp end;
     hol:=-1;
     for l:=0 to high(edges) do
      if ((edges[l,1]=e1) and (edges[l,0]=e2)) or
         ((edges[l,1]=e2) and (edges[l,0]=e1)) then
       hol:=l;
     if hol>=0 then
     begin
      edges[hol]:=edges[high(edges)];
      setlength(edges,high(edges));
     end
     else
     begin
      setlength(edges,length(edges)+1);
      edges[high(edges),0]:=e1;
      edges[high(edges),1]:=e2;
     end;
    end;
    inds[j]  :=inds[high(inds)-2];
    inds[j+1]:=inds[high(inds)-1];
    inds[j+2]:=inds[high(inds)  ];
    setlength(inds,length(inds)-3);
   end
   else
   inc(j,3);
  end;

  tmp:=length(inds);
  setlength(inds,length(inds)+length(edges)*3);
  for j:=0 to high(edges) do
  begin
   inds[tmp+j*3+0]:=edges[j,0];
   inds[tmp+j*3+1]:=edges[j,1];
   inds[tmp+j*3+2]:=i;
  end;
 end;

 setlength(vane,length(verts));
 setlength(remap,length(verts));
 for i:=0 to high(vane) do
 begin
  vane[i]:=false;
  remap[i]:=i;
 end;

 for i:=0 to high(inds) do
  vane[inds[i]]:=true;

 i:=0;
 while i<=high(verts) do
  if not vane[i] then
  begin
   vane[i] :=vane [high(verts)];
   remap[high(verts)]:=remap[i];
   verts[i]:=verts[high(verts)];
   setlength(verts,high(verts));
  end
  else inc(i);

  for i:=0 to high(inds) do
   inds[i]:=remap[inds[i]];

  for i:=0 to high(verts) do
   verts[i].normal:=D3DXVector3zero;

  for i:=0 to high(inds) div 3 do
  begin
   v1:=verts[inds[i*3+0]].position;
   v2:=verts[inds[i*3+1]].position;
   v3:=verts[inds[i*3+2]].position;
   d3dxvec3subtract(v2,v2,v1);
   d3dxvec3subtract(v3,v3,v1);
   d3dxvec3cross(n,v2,v3);
   fastvec3normalize(n);
   d3dxvec3add(verts[inds[i*3+0]].normal,verts[inds[i*3+0]].normal,n);
   d3dxvec3add(verts[inds[i*3+1]].normal,verts[inds[i*3+1]].normal,n);
   d3dxvec3add(verts[inds[i*3+2]].normal,verts[inds[i*3+2]].normal,n);
  end;

  for i:=0 to high(verts) do
  begin
   fastvec3normalize(verts[i].normal);
   verts[i].u:=random(100)/100;// verts[i].position.x;
   verts[i].v:=random(100)/100;// verts[i].position.z;
  end;
end;

 
end;



end.
