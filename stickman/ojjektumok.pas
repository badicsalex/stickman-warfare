unit ojjektumok;

{.$DEFINE testtris}
{.$DEFINE normaltest}
{.$DEFINE reKD}
{.$DEFINE tereprendezes}
interface
uses sysutils,windows,typestuff,math,Direct3d9,d3dx9,graphics;
type

 PminmaxTriarr=^Tminmaxtriarr;
 Tminmaxtriarr=array [0..100000] of Tminmaxtri;

 PTriarr=^Ttriarr;
 Ttriarr=array [0..100000] of Ttri;

const
BGnevek:array [0..0] of string =('BG1');
BGscalek:array [0..0] of TD3DXVector2= ((x:-3;y:3));

type

 T3dojjektum = class (Tobject)
 public
  myMesh:TStickMesh;
  textures: array [0..20] of integer;
  texszam:shortint;
  triangles,felestri,tmptri:Tacctriarr;
  lightmap:IDirect3DTexture9;
  trilght:array of integer;
  trinum:integer;
  KDtree:TKDTree;
  KDData:TKDdata;
  KDLoaded:boolean;
  hvszam:integer;
  holvannak:Pvecarr2;
  vmi,vma,vce,vce2:Td3DXvector3;
  rad,rad2:single;
  betoltve:boolean;
  nincsrad:boolean;
  filenev:string;
  constructor Create(fnev:string;a_d3ddevice:IDirect3DDevice9;scale,yscale:single;posok:array of TD3DXVector3;flags:cardinal);
  procedure Draw(g_pd3ddevice:IDirect3DDevice9;cp:TD3DXVector3;frust:TFrustum);
  function raytest(v1,v2:TD3DXVector3;melyik:integer;collision:cardinal):TD3DXVector3;
  function raytestlght(v1:TD3DXVector3;var v2:TD3DXVector3;melyik:integer;collision:cardinal):integer;
  function raytestbol(v1,v2:TD3DXVector3;melyik:integer;collision:cardinal):boolean;
  function raytestbolfromcurrent(v1,v2:TD3DXVector3;melyik:integer):boolean;
  function tavtest(poi:TD3DXVector3;gmbnagy:single;out pi:TD3DXVector3;melyik:integer;feles:boolean;collision:cardinal):single;overload;
//  function tavtest(poi:TD3DXVector3;gmbnagy:single;out pi:TD3DXVector3;melyik:integer;feles:boolean;miket:TKDData):single;overload;
  function tavtestfromcurrent(poi:TD3DXVector3;gmbnagy:single;out pi:TD3DXVector3;melyik:integer):single;overload;

  procedure makecurrent(miket:TKDData);
  procedure getacctris(var tris:Tacctriarr;miket:TKDData;plusz:TD3DXVector3;collision:cardinal);
  destructor Destroy; reintroduce;
  procedure pluszegy(hova:TD3DXVector3);
  procedure minuszegy(mit:integer);
  procedure NeedKD;
 end;

 T3DOR_DIPdata = record
  facestart,vertstart,faceCount,VertCount:integer;
  VBind:integer;//Melyik Vertex buffer
  tex:integer;
 end;

 T3DOR_DrawData = record
  DIPdata:array of T3DOR_DIPdata;
  xasz:integer;
  RenderZ:array of boolean;
  visible:array of boolean;
 end;

 TimposterData = record
  imposter:boolean;
  tav:single;
  legu:Td3dxvector3;
  lstfrsh:integer;
  atmenet:integer;
  q4a,q4b:array [0..3] of TD3DXVector3;
  quad:array [0..5] of TImpostervertex;
 end;

 T3DORenderer = class (Tobject)
 public
  lightmap:IDirect3DTexture9;
  imposters:IDirect3DTexture9;
  imposrender:ID3DXRenderToSurface;
  impossurf:IDirect3DSurface9;
  imposarr:array of array of TimposterData;
  imposrects:Tojjrectarr;
  g_pIB:IDirect3DIndexBuffer9;
  g_pVB:IDirect3DVertexBuffer9;
  g_pd3ddevice:IDirect3DDevice9;
  osszvert,osszind:integer;
  drawtable:array of T3DOR_DrawData;

  constructor Create(ad3ddevice:IDirect3DDevice9);
  procedure Draw(frust:TFrustum;g_pEffect:ID3DXEffect;matView,matProj:TD3DMatrix;fogstart,fogend:single;renderimposters:boolean);
  procedure DrawOne(ind1,ind2:integer);
  procedure RefreshImposters(mhk:TD3DXVector3);
  Destructor Destroy; reintroduce;
 end;

 Tposrad= record
  posx,posy,posz:single;
  radd,raddn:single;
  //ground:boolean;
 end;

 Tbubble= record
  posx,posy,posz:single;
  rad:single;
  gomb:ID3DXMesh;
 end;

 TOjjektumTexture = record
  tex:IDirect3DTexture9;
  heightmap:IDirect3DTexture9;
  name:string;
  alphatest:boolean;
  emitting:boolean;
  collisionflags:cardinal;
 end;

procedure initojjektumok(g_pd3ddevice:IDirect3DDevice9;hdrtop:cardinal);
procedure uninitojjektumok(g_pd3ddevice:IDirect3DDevice9);

procedure loadojjektumokfromjson;

const
OF_FITTOTERRAIN=1 shl 0;
OF_DONTFLATTEN= 1 shl 1;
OF_SPAWNGUN=    1 shl 2;
OF_SPAWNTECH=   1 shl 3;
OF_VEHICLEGUN=  1 shl 4;
OF_VEHICLETECH= 1 shl 5;
var

 ojjektumarr: array of T3dojjektum;

 {ojjektumnevek:array [0..20] of string =       ( 'bunker4','nafta'   ,'gyar1'   ,'haz3'      ,'radio2'      ,'almacomp1'    ,'almacomp2'    ,'bananker','pantheon','TowerT'     ,'mayan'      ,'maya_a3'    ,'maya_b3'    ,'stickportal' ,'towerF'       ,'towerV'    ,'TowerB'        ,'kikoto'  ,'reactor'            ,'markolo'  ,'meder');
 ojjektumscalek:array [0..20] of TD3DXVector2= ((x:-3;y:2),(x:-5;y:5),(x:-5;y:5),(x:-3;y:3)  ,(x:-2.2;y:2.2),(x:-1.7;y:1.7) ,(x:-1.7;y:1.7) ,(x:-3;y:4),(x:-4;y:4),(x:-4;y:3)   ,(x:-7;y:7)   ,(x:-2;y:2)   ,(x:-2;y:2)   ,(x:-2.2;y:2.2),(x:-2.5;y:2.5) ,(x:-3;y:3)  ,(x:-6;y:6)      ,(x:-6;y:6),(x:-5;y:5)           ,(x:-4;y:4) ,(x:-2;y:2));
 ojjektumzone:array [0..20] of string=         ( 'Bunker' ,'NaFTa'   ,'Factory' ,'Lighthouse','Radio Tower' ,'AlComp'       ,'AlComp'       ,'BaniComp','Pantheon','Black Tower','Mayan ruins','Mayan ruins','Mayan ruins','Stick Portal','Fantasy Tower','Lighthouse','Medieval Tower','Port'    ,'Dark Energy Reactor','Excavator','Excavator');
 ojjektumhv:array [0..20] of array of Td3dxvector3;//}

 ojjektumnevek:array of string;
 ojjektumscalek:array of TD3DXVector2;
 ojjektumzone:array of string;
 ojjektumhv:array of array of Td3dxvector3;
 ojjektumflags:array of cardinal;


 ojjektumTextures:array [0..100] of TojjektumTexture;
 oTPszam:integer=-1;
 otNszam:integer=-1;
 currenttriarr:Tacctriarr;
 posrads:array of Tposrad;
 bubbles:array of Tbubble;
 lightmapbm:array [0..2047,0..2047,0..3] of byte;
 panthepulet:integer;
 portalepulet:integer;
 ATportalhely:integer;
 DNSvec:TD3DXVector3;
 DNSrad:single;

 ReliefMappingEnabled:boolean;
 vertdecl,vertdeclgagyi:IDirect3DVertexDeclaration9;

 Use32bitIndices:boolean;// A f�program �ll�tja �s haszn�lja
 maxindices:integer; //caps.MaxVertexIndex+1;
 ImposterTexSize:integer=1024;
 invimpostertexsize:single=1/1024;
implementation
var
 teszttris:array of array [0..2] of TD3DXVector3;
{$IFDEF normaltest}
 normalvon:array of array [0..1] of TD3DXVector3;
{$ENDIF}

function LoadOjjektumTexture(a_d3ddevice:IDirect3DDevice9;nev,dir:string):integer;
var
 i,j:integer;
 hmnev:string;
 special:string;
begin
  result:=-1;
  if (nev='') then
   exit;

  for j:=0 to otnszam do
   if ojjektumtextures[j].name=nev then
   begin
    result:=j;
    exit;
   end;

 inc(otnszam);

 with ojjektumtextures[otnszam] do
 begin
  collisionflags:=$FFFFFFFF;

  for i:=0 to stuffjson.GetNum(['materials',nev,'special'])-1 do
  begin
   special:=stuffjson.GetString(['materials',nev,'special',i]);
   if special='disabled' then
    exit
   else
   if special='notbulletproof' then
    collisionflags:=collisionflags and (not COLLISION_BULLET)
   else
   if special='notsolid' then
    collisionflags:=collisionflags and (not COLLISION_SOLID)
   else
   if special='noshadow' then
    collisionflags:=collisionflags and (not COLLISION_SHADOW)
   else
   if special='alphatest' then
    alphatest:=true
   else
      if special='emitting' then
    emitting:=true;
  end;

  name:=nev;
  tex:=nil;
  if not LTFF(a_d3dDevice,dir+'/'+nev,tex) then
   exit;
  addfiletochecksum(dir+'/'+nev);

  hmnev:=stuffjson.GetString(['materials',nev,'heightmap']);
  if (hmnev<>'') then
   if LTFF(a_d3dDevice,dir+'/'+hmnev,heightmap) then
    addfiletochecksum(dir+'/'+hmnev);
 end;
 result:=otnszam;
end;

constructor T3dojjektum.Create(fnev:string;a_d3ddevice:IDirect3DDevice9;scale,yscale:single;posok:array of TD3DXVector3;flags:cardinal);
 procedure inlinescale(var mit:TD3DXVector3);
 begin
  mit.x:=mit.x*scale;
  mit.z:=mit.z*scale;
  mit.y:=mit.y*yscale;
 end;
type
  PD3DXMaterialArray = ^TD3DXMaterialArray;
  TD3DXMaterialArray = array[0..100] of TD3DXMaterial;
var
i,j,k,tritex:integer;
subsetszam:integer;
szam,akarmi:integer;
teg:TAABB;
indexes:TKDData;
mystr:string;
tmpflatverts:array of TD3DXVector3;
tv0,tv1,tv2:TD3DXVector3;
hiba:HRESULT;
adj:pointer;
mn,mx:integer;
hol:TD3DXvector3;
pVertices:POjjektumvertex2Array;
pindices:PDwordarray;
label
Ltriangles,Ltemptri;
begin
{$R-}
 inherited create;
  betoltve:=false;
  

  nincsrad:=((flags and OF_DONTFLATTEN)>0) or ((flags and OF_FITTOTERRAIN)>0);

  filenev:=fnev;

  addfiletochecksum(fnev+'_lm.bmp');
  if length(posok)>0 then
  begin
   hvszam:=length(posok);
   getmem(holvannak,(hvszam)*sizeof(TD3DXVector3));
   for i:=0 to high(posok) do
    holvannak[i]:=posok[i];
  end
  else
  begin
   hvszam:=1;
   getmem(holvannak,sizeof(TD3DXVector3));
   holvannak[0]:=D3DXVector3zero;
  end;

  //if fileexists(fnev+'.x') then stickmeshconverttox(fnev,a_d3ddevice);

  if not fileexists(fnev+'.sm0') then exit;

  addfiletochecksum(fnev+'.sm0');

  myMesh:=StickMeshLoad(fnev+'.sm0');

  subsetszam:=length(mymesh.attrtable);

  i:= 0;
  texszam:=subsetszam;
  {$R+}
  while (i < subsetszam) do
  begin
    akarmi:=-1;
    // Make the texture
    textures[i]:=LoadOjjektumTexture(a_d3ddevice,string(mymesh.texturetable[i]),ExtractFileDir(fnev));
    Inc(i);
  end;
  {$R-}

 with mymesh do
 begin

  D3DXComputeboundingbox(pointer(@(vertices[0])),length(vertices),sizeof(Tojjektumvertex),vmi,vma);

  trinum:=length(indices) div 3;
  setlength(triangles,trinum);
  setlength(indexes,trinum);
  setlength(felestri,trinum);


  setlength(tmpflatverts,length(vertices));
  if felestri=nil then exit;
  if triangles=nil then exit;

  if (flags and OF_DONTFLATTEN)>0 then vmi.y:=0;

  if (flags and OF_FITTOTERRAIN)>0 then
  for i:=0 to length(vertices)-1 do
  begin
   Inlinescale(vertices[i].position);
   vertices[i].position.y:=vertices[i].position.y-holvannak[0].y+azadvwove(holvannak[0].x+vertices[i].position.x,holvannak[0].z+vertices[i].position.z);

   tmpflatverts[i]:=vertices[i].position;
   tmpflatverts[i].y:=0;
  end
  else
  for i:=0 to length(vertices)-1 do
  begin
   //vertices[i].color:=RGB(255,255,255);
   vertices[i].position.y:=(vertices[i].position.y-vmi.y);
   Inlinescale(vertices[i].position);
 {  Inlinescale(normals[i].normal);
   Inlinescale(normals[i].binormal);
   Inlinescale(normals[i].tangent);   }
   tmpflatverts[i]:=vertices[i].position;
   tmpflatverts[i].y:=0;
  end;

  j:=0;
  for i:=0 to trinum-1 do
  begin

   tritex:=-1;
   for k:=0 to high(mymesh.attrtable) do
    if (i>=integer(attrtable[k].FaceStart)) and
      (i<integer(attrtable[k].FaceStart)+integer(attrtable[k].FaceCount)) then
    begin
     tritex:=textures[k];
     break;
    end;

   if tritex<0 then
     continue;

   if (indices[i*3+0]<0) or
      (indices[i*3+1]<0) or
      (indices[i*3+2]<0) or
      (indices[i*3+0]>high(vertices)) or
      (indices[i*3+1]>high(vertices)) or
      (indices[i*3+2]>high(vertices)) then
      raise ERangeError.Create('Modding error: bad indices in model '+fnev);

   if tritex>high(ojjektumtextures) then
    raise ERangeError.Create('Alex error: bad texture index in model '+fnev);

   if j>high(triangles) then
    raise ERangeError.Create('Alex error: wtf @ '+fnev);

   triangles[j]:=makeacc(vertices[indices[i*3+0]].position,vertices[indices[i*3+1]].position,vertices[indices[i*3+2]].position,ojjektumtextures[tritex].collisionflags);
   if triangles[j].n.y>1.5 then continue;
   tv0:=vertices[indices[i*3+0]].position; tv0.y:=tv0.y*0.5;
   tv1:=vertices[indices[i*3+1]].position; tv1.y:=tv1.y*0.5;
   tv2:=vertices[indices[i*3+2]].position; tv2.y:=tv2.y*0.5;

   felestri[j]:=makeacc(tv0,tv1,tv2,ojjektumtextures[tritex].collisionflags);
   indexes[j]:=j;

   j:=j+1;
  end;
  
  trinum:=j;
  setlength(triangles,trinum);
  setlength(indexes,trinum);
  setlength(felestri,trinum);

  D3DXComputeboundingbox(pointer(@(vertices[0])),length(verticeS),sizeof(Tojjektumvertex),vmi,vma);
  D3DXComputeboundingsphere(pointer(@(vertices[0])),length(verticeS),sizeof(Tojjektumvertex),vce,rad);
  if pos('bunker',fnev)>0 then rad:=rad*2;
  D3DXcomputeboundingsphere(@(tmpflatverts[0]),length(verticeS),sizeof(TD3DXVector3),vce2,rad2);


  setlength(tmpflatverts,0);
 { getmem(adj,g_pmesh.getnumfaces*6);
  g_pMesh.generateadjacency(0.001,adj);
  D3DXComputenormals(g_pMesh,adj);
  freemem(adj); }

  if fileexists(fnev+'.kd1')  {$IFDEF reKD} and false {$ENDIF} then
  begin
   KDLoaded:=false;
 //  loadKDTree(fnev+'.kd2',KDTreefeles,KDDatafeles);
  end
  else
  begin
   KDLoaded:=true;
   teg.min:=D3DXVector3(-10000,-10000,-10000);
   teg.max:=D3DXVector3( 10000, 10000, 10000);
   ConstructKDTree(KDTree,KDData,indexes,0,triangles,teg);
  // ConstructKDTree(KDTreefeles,KDDatafeles,indexes,0,felestri,teg);
   saveKDTree(fnev+'.kd1',KDTree,KDData);
  // saveKDTree(fnev+'.kd2',KDTreefeles,KDDatafeles);
  end;

  stickmeshcomputentb(mymesh);
  //stickmeshinvertnormals(mymesh);
 end;

  setlength(indexes,0);

  addfiletochecksum(fnev+'.kd1');

  if not nincsrad then
  begin
   j:=length(posrads);
   setlength(posrads,length(posrads)+hvszam);
   for i:=0 to hvszam-1 do
   with posrads[i+j] do
   begin
    posx:=holvannak[i].x+vce2.x;
    posy:=holvannak[i].y;
    posz:=holvannak[i].z+vce2.z;
    radd:=rad2;
    raddn:=rad*1.5;
   end;
  end;

  setlength(trilght,trinum);
  betoltve:=true;
end;

procedure T3dojjektum.NeedKD;
begin
 if not KDloaded then
 begin
  loadKDTree(filenev+'.kd1',KDTree,KDData);
  KDLoaded:=true;
 end;
end;

procedure T3dojjektum.pluszegy(hova:TD3DXVector3);
var
 tmp:PVecarr2;
 i:integer;
begin
 getmem(tmp,(hvszam+1)*sizeof(TD3DVector));
 for i:=0 to hvszam-1 do
  tmp[i]:=holvannak[i];
 tmp[hvszam]:=hova;
 hvszam:=hvszam+1;
 freemem(holvannak,(hvszam-1)*sizeof(TD3DVector));
 holvannak:=tmp;
end;

procedure T3dojjektum.minuszegy(mit:integer);
begin
 holvannak[mit]:=holvannak[hvszam-1];
 hvszam:=hvszam-1;
end;

procedure T3dojjektum.Draw(g_pd3ddevice:IDirect3DDevice9;cp:TD3DXVector3;frust:TFrustum);
begin
 messagebox(0,'Elavult: T3dojjektum.Draw','Assert helyett',0);
end;

destructor T3dojjektum.Destroy;
begin
 //if g_pMesh<> nil then
 //g_pMesh:=nil;
 setlength(triangles,0);
 setlength(felestri,0);
 inherited;
end;

procedure T3dojjektum.makecurrent(miket:TKDData);
var
i:integer;
begin
 setlength(currenttriarr, length(miket));
 for i:=0 to high(miket) do
  currenttriarr[i]:=triangles[miket[i]];
end;


function T3dojjektum.raytest(v1,v2:TD3DXVector3;melyik:integer;collision:cardinal):TD3DXVector3;
var
az,bz,hv:TD3DXVector3;
al,bl:single;
i:integer;
miket:TKDData;
begin
 hv:=holvannak[melyik];

 d3dxvec3subtract(v1,v1,hv);
 d3dxvec3subtract(v2,v2,hv);
 az:=vce;
 if not tavpointlinesq(az,v1,v2,bz,bl) then
 begin
  if not (tavpointpointsq(az,v1)<sqr(rad+1)) then
   if not (tavpointpointsq(az,v2)<sqr(rad+1)) then
   begin
    d3dxvec3add(result,v2,hv); exit;
   end;
 end
 else
 begin
  if bl>sqr(rad+1) then begin
   d3dxvec3add(result,v2,hv); exit;
  end;
{ bol:=true;
 d3dxvec3subtract(tmp,v1,v2);
 d3dxvec3normalize(tmp,tmp);
 tmp1:=d3dxvector3(bz.x+tmp.x*(rad+1),bz.y+tmp.y*(rad+1),bz.z+tmp.z*(rad+1));
 tmp2:=d3dxvector3(bz.x-tmp.x*(rad+1),bz.y-tmp.y*(rad+1),bz.z-tmp.z*(rad+1));}
 end;

 //Egyszer�bb m�dszer
 {if bol then
  traverseKDTreelin(tmp1,tmp2,miket,KDData,KDTree,triangles)
 else  }

 NeedKD;
 
  traverseKDTreelin(v1,v2,miket,KDData,KDTree,triangles,collision);

 az:=v2;
 al:=100000;

 {$IFDEF testtrisd}
 kul:=false;
 {$ENDIF}
 for i:=0 to length(miket)-1 do
 begin

  if ((triangles[miket[i]].collision and collision)<>0) and
     intLineTri(triangles[miket[i]].v0,triangles[miket[i]].v1,triangles[miket[i]].v2,v1,az,bz) then
  begin
   bl:=tavPointPointsq(v1,bz);
   {$IFDEF testtrisd}
   kul:=true;
   {$ENDIF}
   if al>bl then
   begin
    al:=bl;
    az:=bz;
   end;
  end
 end;
 {$IFDEF testtrisd}
 if kul then
 begin
  setlength(teszttris,length(miket));
  for i:=0 to length(miket)-1 do
  begin
   d3dxvec3add(teszttris[i,0],triangles[miket[i]].v0,hv);
   d3dxvec3add(teszttris[i,1],triangles[miket[i]].v1,hv);
   d3dxvec3add(teszttris[i,2],triangles[miket[i]].v2,hv);
  end;
 end;
 {$ENDIF}
 d3dxvec3add(result,az,hv);
// result:=az;
end;

function T3dojjektum.raytestlght(v1:TD3DXVector3;var v2:TD3DXVector3;melyik:integer;collision:cardinal):integer;
var
az,bz,hv:TD3DXVector3;
al,bl:single;
i:integer;
miket:TKDData;
begin
 result:=-1;
 hv:=holvannak[melyik];

 d3dxvec3subtract(v1,v1,hv);
 d3dxvec3subtract(v2,v2,hv);
 az:=vce;
 if not tavpointlinesq(az,v1,v2,bz,bl) then
 begin
  if not (tavpointpointsq(az,v1)<sqr(rad+1)) then
   if not (tavpointpointsq(az,v2)<sqr(rad+1)) then
   begin
    d3dxvec3add(v2,v2,hv); exit;
   end;
 end
 else
 begin
  if bl>sqr(rad+1) then begin
   d3dxvec3add(v2,v2,hv); exit;
  end;
 end;

  NeedKD;

  traverseKDTreelin(v1,v2,miket,KDData,KDTree,triangles,collision);


 az:=v2;
 al:=100000;

 for i:=0 to length(miket)-1 do
 begin

  if ((triangles[miket[i]].collision and collision)<>0) and
     intLineTri(triangles[miket[i]].v0,triangles[miket[i]].v1,triangles[miket[i]].v2,v1,az,bz) then
  begin
   bl:=tavPointPointsq(v1,bz);
   if al>bl then
   begin
    al:=bl;
    az:=bz;
    result:=trilght[miket[i]];
   end;
  end
 end;
  d3dxvec3add(v2,az,hv);
end;


function T3dojjektum.raytestbol(v1,v2:TD3DXVector3;melyik:integer;collision:cardinal):boolean;
var
az,bz,hv:TD3DXVector3;
bl:single;
i:integer;
miket:TKDData;
begin
 hv:=holvannak[melyik];
 result:=false;
 d3dxvec3subtract(v1,v1,hv);
 d3dxvec3subtract(v2,v2,hv);
 az:=vce;
 if not tavpointlinesq(az,v1,v2,bz,bl) then
 begin
  if not (tavpointpointsq(az,v1)<sqr(rad+1)) then
   if not (tavpointpointsq(az,v2)<sqr(rad+1)) then exit;
 end
 else
 begin
  if bl>sqr(rad+1) then  exit;

 end;


 NeedKD;
 
 traverseKDTreelin(v1,v2,miket,KDData,KDTree,triangles,collision);

 for i:=0 to high(miket) do
 begin
   if ((triangles[miket[i]].collision and collision)<>0) and
      intlinetriacc(triangles[miket[i]],v1,v2) then
    result:=true;
 end;
 setlength(miket,0);
end;

function T3dojjektum.raytestbolfromcurrent(v1,v2:TD3DXVector3;melyik:integer):boolean;
var
az,bz,hv:TD3DXVector3;
bl:single;
i:integer;
begin
 hv:=holvannak[melyik];
 result:=false;
 d3dxvec3subtract(v1,v1,hv);
 d3dxvec3subtract(v2,v2,hv);
 az:=vce;
 if not tavpointlinesq(az,v1,v2,bz,bl) then
 begin
  if not (tavpointpointsq(az,v1)<sqr(rad+1)) then
   if not (tavpointpointsq(az,v2)<sqr(rad+1)) then exit;
 end
 else
  if bl>sqr(rad+1) then  exit;


 for i:=0 to high(currenttriarr) do
 begin
   if intlinetriacc(currenttriarr[i],v1,v2) then
   begin
    result:=true;
    exit;
   end;
 end;

end;
     
function T3dojjektum.tavtestfromcurrent(poi:TD3DXVector3;gmbnagy:single;out pi:TD3DXVector3;melyik:integer):single;
var
az,bz,hv:TD3DXVector3;
al,bl:single;
i:integer;
begin

 if melyik=-1 then
  hv:=D3DXVector3Zero
 else

 if melyik=-1 then
  hv:=D3DXVector3Zero
 else
 hv:=holvannak[melyik];


 d3dxvec3subtract(poi,poi,hv);

 az:=vce;

 if tavpointpointsq(az,poi)>sqr(rad+gmbnagy+1) then begin result:=tavpointpointsq(az,poi); exit; end;

 az:=poi;
 al:=sqr(rad+gmbnagy+1);

 for i:=0 to high(currenttriarr) do
 begin

  if (poi.x-gmbnagy>currenttriarr[i].vmax.x) or (poi.x+gmbnagy<currenttriarr[i].vmin.x) or
     (poi.z-gmbnagy>currenttriarr[i].vmax.z) or (poi.z+gmbnagy<currenttriarr[i].vmin.z) or
     (poi.y-gmbnagy>currenttriarr[i].vmax.y) or (poi.y+gmbnagy<currenttriarr[i].vmin.y) then continue;//}
 
   bl:=tavPointTrisq(currenttriarr[i],poi,bz);
   if al>bl then
   begin
    al:=bl;
    az:=bz;
   end;
 end;

 d3dxvec3add(pi,az,hv);
 result:=al;
end;


procedure T3dojjektum.getacctris(var tris:Tacctriarr;miket:TKDData;plusz:TD3DXvector3;collision:cardinal);
var
i,j:integer;
begin
 setlength(tris,length(miket));
 j:=0;
 for i:=0 to high(miket) do
 begin
  if miket[i]>high(triangles) then
   continue;
  if (triangles[miket[i]].collision and collision)=0 then
   continue;
  tris[j]:=triangles[miket[i]];

  d3dxvec3add(tris[j].v0,tris[j].v0,plusz);
  d3dxvec3add(tris[j].v1,tris[j].v1,plusz);
  d3dxvec3add(tris[j].v2,tris[j].v2,plusz);
  d3dxvec3add(tris[j].vmin,tris[j].vmin,plusz);
  d3dxvec3add(tris[j].vmax,tris[j].vmax,plusz);
  j:=j+1;
 end;
 setlength(tris,j);
end;

function T3dojjektum.tavtest(poi:TD3DXVector3;gmbnagy:single;out pi:TD3DXVector3;melyik:integer;feles:boolean;collision:cardinal):single;
var
az,bz,hv:TD3DXVector3;
al,bl:single;
i:integer;
miket:TKDData;
gmbAABB:TAABB;
begin
 if feles then tmptri:=felestri else tmptri:=triangles;

 gmbnagy:=gmbnagy;
 //az:=poi;
 //az.x:=az.x+gmbnagy;
 if melyik=-1 then
  hv:=D3DXVector3Zero
 else
 hv:=holvannak[melyik];
 if feles then hv.y:=hv.y*0.5;

 d3dxvec3subtract(poi,poi,hv);


 az:=vce;
 //if feles then  az.y:=az.y*0.5;
 if tavpointpointsq(az,poi)>sqr(rad+gmbnagy+3) then begin result:=tavpointpointsq(az,poi); exit; end;


 az:=poi;
 al:=sqr(rad+gmbnagy+1);

 if feles then
 begin
  d3dxvec3subtract(gmbAABB.min,poi,D3DXVector3(gmbnagy,gmbnagy,gmbnagy));
  d3dxvec3add     (gmbAABB.max,poi,D3DXVector3(gmbnagy,gmbnagy,gmbnagy));
  gmbAABB.min.y:= gmbAABB.min.y*2;
  gmbAABB.max.y:= gmbAABB.max.y*2;
 end
 else
 begin
  d3dxvec3subtract(gmbAABB.min,poi,D3DXVector3(gmbnagy,gmbnagy,gmbnagy));
  d3dxvec3add     (gmbAABB.max,poi,D3DXVector3(gmbnagy,gmbnagy,gmbnagy));
 end;

// traverseKDTree(gmbAABB,miket,KDDatafeles,KDTreefeles) else

 NeedKD;
 
  traverseKDTree(gmbAABB,miket,KDData,KDTree,collision);

 setlength(teszttris,length(miket));
 for i:=0 to high(miket) do
 begin
 //{
  d3dxvec3add(teszttris[i,0],triangles[miket[i]].v0,holvannak[melyik]);
  d3dxvec3add(teszttris[i,1],triangles[miket[i]].v1,holvannak[melyik]);
  d3dxvec3add(teszttris[i,2],triangles[miket[i]].v2,holvannak[melyik]);
 // }
  if (poi.x-gmbnagy>tmptri[miket[i]].vmax.x) or (poi.x+gmbnagy<tmptri[miket[i]].vmin.x) or
     (poi.z-gmbnagy>tmptri[miket[i]].vmax.z) or (poi.z+gmbnagy<tmptri[miket[i]].vmin.z) or
     (poi.y-gmbnagy>tmptri[miket[i]].vmax.y) or (poi.y+gmbnagy<tmptri[miket[i]].vmin.y) then continue;//}

  if (tmptri[miket[i]].collision and collision)=0 then
   continue;

   bl:=tavPointTrisq(tmptri[miket[i]],poi,bz);
   if al>bl then
   begin
    al:=bl;
    az:=bz;
   end;
 end;
 setlength(miket,0);
 d3dxvec3add(pi,az,hv);
 result:=al;
end;



procedure initojjektumok(g_pd3ddevice:IDirect3DDevice9;hdrtop:cardinal);
begin
 g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iFalse);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG1);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP,   hdrtop);

 g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_BLENDFACTOR);
 g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVBLENDFACTOR);
 g_pd3ddevice.SetRenderState(D3DRS_BLENDOP,D3DBLENDOP_ADD);

 g_pd3ddevice.SetRenderState(D3DRS_BLENDFACTOR,$505050);
end;

procedure uninitojjektumok(g_pd3ddevice:IDirect3DDevice9);
begin
 g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iTrue);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP,   D3DTOP_DISABLE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);
  {g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_BLENDFACTOR);
 g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_BLENDFACTOR);
 g_pd3ddevice.SetRenderState(D3DRS_BLENDOP,D3DBLENDOP_ADD); }
end;

{procedure saveojjektumini(hova:string);
var
 i,j:integer;
 fil:Textfile;
begin
  DecimalSeparator:='.';
 assignfile(fil,hova);
 rewrite(fil);
 for i:=0 to high(ojjektumnevek) do
 begin
  //ojjektumnevek:array [0..20] of string
  //ojjektumscalek:array [0..20] of TD3DXVector2
  //ojjektumzone:array [0..20] of string
  //ojjektumhv:array [0..20] of array of Td3dxvector3;
  writeln(fil,'[',ojjektumnevek[i],']');
  writeln(fil,'scalex=',FloatToStrF(-ojjektumscalek[i].x,ffFixed,7,2));
  writeln(fil,'scaley=',FloatToStrF( ojjektumscalek[i].y,ffFixed,7,2));
  writeln(fil,'zone=',ojjektumzone[i]);
  for j:=0 to ojjektumarr[i].hvszam-1 do
  with ojjektumarr[i].holvannak[j] do
   writeln(fil,'pos=',FloatToStrF(x,ffFixed,7,2),' ',FloatToStrF(y,ffFixed,7,2),' ',FloatToStrF(z,ffFixed,7,2));
 end;

 closefile(fil);
end;
}

procedure loadojjektumokfromjson;
var
i,j,n:integer;
special:string;
begin
 n:=stuffjson.GetNum(['buildings']);
 setlength(ojjektumnevek,n);
 setlength(ojjektumscalek,n);
 setlength(ojjektumzone,n);
 setlength(ojjektumhv,n);
 setlength(ojjektumflags,n);

 for i:=0 to n-1 do
 begin
  ojjektumnevek[i]:=stuffjson.GetKey(['buildings'],i);
  ojjektumflags[i]:=0;
  ojjektumscalek[i].x:=-stuffjson.GetFloat(['buildings',i,'scalex']);
  ojjektumscalek[i].y:= stuffjson.GetFloat(['buildings',i,'scaley']);
  ojjektumzone[i]:=stuffjson.GetString(['buildings',i,'zone']);

  if stuffjson.GetKey(['buildings'],i)='pantheon' then
   panthepulet:=i;

  if stuffjson.GetKey(['buildings'],i)='kispiri' then
   portalepulet:=i;

  if stuffjson.GetKey(['buildings'],i)='portal_inst' then
   ATportalhely:=i;






  for j:=0 to stuffjson.GetNum(['buildings',i,'special']) do
  begin
   special:=stuffjson.GetString(['buildings',i,'special',j]);
   if special='fittoterrain' then
    ojjektumflags[i]:=ojjektumflags[i] or OF_FITTOTERRAIN;
   if special='dontflattenterrain' then
    ojjektumflags[i]:=ojjektumflags[i] or OF_DONTFLATTEN;

   if special='spawngun' then
    ojjektumflags[i]:=ojjektumflags[i] or OF_SPAWNGUN;
   if special='spawntech' then
    ojjektumflags[i]:=ojjektumflags[i] or OF_SPAWNTECH;

   if special='vehiclegun' then
    ojjektumflags[i]:=ojjektumflags[i] or OF_VEHICLEGUN;
   if special='vehicletech' then
    ojjektumflags[i]:=ojjektumflags[i] or OF_VEHICLETECH;
  end;

  n:=stuffjson.GetNum(['buildings',i,'position']);
  setlength(ojjektumhv[i],n);
  for j:=0 to n-1 do
   with ojjektumhv[i][j] do
   begin
    x:=stuffjson.GetFloat(['buildings',i,'position',j,'x']);
    y:=stuffjson.GetFloat(['buildings',i,'position',j,'y']);
    z:=stuffjson.GetFloat(['buildings',i,'position',j,'z']);
   end;


 end;
end;

constructor T3DORenderer.Create(ad3ddevice:IDirect3DDevice9);
type
 TD3DXAttributerangearr= array [0..100] of TD3DXAttributerange;
 PD3DXAttributerangearr = ^TD3DXAttributerangearr;

const
 CSICSA_LOCK_FLAG=0; //D3DLOCK_DISCARD
 declarr:array [0..6] of D3DVERTEXELEMENT9 =
   ((Stream:0  ; Offset:0   ; _Type:D3DDECLTYPE_FLOAT3; Method:D3DDECLMETHOD_DEFAULT; Usage:D3DDECLUSAGE_POSITION; UsageIndex:0),
    (Stream:0  ; Offset:3*4 ; _Type:D3DDECLTYPE_FLOAT2; Method:D3DDECLMETHOD_DEFAULT; Usage:D3DDECLUSAGE_TEXCOORD; UsageIndex:0),
    (Stream:0  ; Offset:5*4 ; _Type:D3DDECLTYPE_FLOAT2; Method:D3DDECLMETHOD_DEFAULT; Usage:D3DDECLUSAGE_TEXCOORD; UsageIndex:1),
    (Stream:0  ; Offset:7*4 ; _Type:D3DDECLTYPE_FLOAT3; Method:D3DDECLMETHOD_DEFAULT; Usage:D3DDECLUSAGE_NORMAL  ; UsageIndex:0),
    (Stream:0  ; Offset:10*4; _Type:D3DDECLTYPE_FLOAT3; Method:D3DDECLMETHOD_DEFAULT; Usage:D3DDECLUSAGE_TANGENT ; UsageIndex:0),
    (Stream:0  ; Offset:13*4; _Type:D3DDECLTYPE_FLOAT3; Method:D3DDECLMETHOD_DEFAULT; Usage:D3DDECLUSAGE_BINORMAL; UsageIndex:0),
    (Stream:$FF; Offset:0   ; _Type:D3DDECLTYPE_UNUSED; Method:TD3DDeclMethod(0)    ; Usage:TD3DDeclUsage(0)     ; UsageIndex:0));
var
i,j,k,ii,jj:integer;
l:cardinal;
attrarr:TD3DXAttributerangearr;
attrszam:integer;
facecnt,vertcnt:integer;
facecur,vertcur,vertcurdyn:integer;
indlckd,vertlckd:integer;
pVert:Pojjektumvertex2array;
pvertojj:Pojjektumvertexarray;
pInd16:PWORDarray;
pInd32:PDwordarray;
pindojj:Pwordarray;
tmp1:Dword;
tmp2,tmp2a:TD3dxvector3;
tmp3:integer;
lmaps:array of TBitmap;
lmapsorrend:array of integer;
lmapx:array of array [0..2] of integer; //X,Y,size
lmapcells:array [0..15,0..15] of integer;
lmapsize:integer; //cell�kban (64x64)
cursize:integer;
tryx,tryy:integer;
bol:boolean;
Xbitmap:Tbitmap;
poi:pbytearray;
lr:TD3DLOCKEDRECT;
pbits:PByteArray;
szin:cardinal;
lu2,lv2:single;
declarr2:array [0..6] of D3DVERTEXELEMENT9;
lasterror:cardinal;
label
 retry,breakall;
begin
 inherited Create;
 write(logfile,'Ojjektum renderer:');flush(logfile);

 setlength(Drawtable,length(ojjektumnevek));
 setlength(lmaps,length(ojjektumnevek));
 setlength(lmapsorrend,length(ojjektumnevek));
 setlength(lmapx,length(ojjektumnevek));

 //DEVICE
 g_pd3ddevice:=ad3ddevice;
 //LIGHTMAPPEK M�SOL�SA

 for i:=0 to high(ojjektumnevek) do
 begin
  lmaps[i]:=TBitmap.create;
  lmaps[i].LoadFromFile(ojjektumarr[i].filenev+'lm.bmp');
  lmapsorrend[i]:=i;
 end;
 zeromemory(@lmapx[0],sizeof(integer)*3*length(lmapx));
 zeromemory(@lmapcells[0],sizeof(lmapcells));

  write(logfile,'lightmaps...');flush(logfile);

 lmapsize:=16;
 for i:=0 to high(ojjektumnevek) do
 begin
  retry:
  cursize:=lmaps[lmapsorrend[i]].Width div 64;
  j:=0;
  while j<lmapsize do
  begin
   k:=0;
   while k<lmapsize do
   begin
    tryx:=j; tryy:=k;
    bol:=true;
    for ii:=tryx to tryx+cursize-1 do
     for jj:=tryy to tryy+cursize-1 do
      bol:=bol and (lmapcells[ii,jj]=0);
    if bol then
    begin
     for ii:=tryx to tryx+cursize-1 do
      for jj:=tryy to tryy+cursize-1 do
       lmapcells[ii,jj]:=lmapsorrend[i]+1;
     lmapx[lmapsorrend[i],0]:=tryx*64;
     lmapx[lmapsorrend[i],1]:=tryy*64;
     lmapx[lmapsorrend[i],2]:=cursize*64;
     goto breakall;
    end;
    inc(k,cursize);
   end;
   inc(j,cursize)
  end;
  write(logfile,'out of lightmaps :''(\n');flush(logfile);
  exit;
  breakall:
 end;
 Xbitmap:=TBitmap.Create;
 Xbitmap.PixelFormat:=pf24bit;
 Xbitmap.Height:=2048;
 Xbitmap.Width:=2048;
 Xbitmap.Canvas.brush.color:=clblack;
 Xbitmap.canvas.Rectangle(0,0,2047,2047);
 for i:=0 to high(ojjektumarr) do
 begin
  XBitmap.Canvas.Draw(lmapx[i,0],lmapx[i,1],lmaps[i]);
  lmaps[i].Destroy;
 end;

  write(logfile,'more lightmaps...');flush(logfile);
 for i:=0 to XBitmap.Height-1 do
 begin
  pbits:=Xbitmap.ScanLine[i];
  for j:=0 to XBitmap.width-1 do
  begin
   lightmapbm[i,j,0]:=pbits[j*3+0];
   lightmapbm[i,j,1]:=pbits[j*3+0];
   lightmapbm[i,j,2]:=pbits[j*3+1];
   lightmapbm[i,j,3]:=pbits[j*3+2];
  end;
 end;

 XBitmap.SaveToFile('data\TMPlmap.bmp');
 XBitmap.destroy;

 write(logfile,'even more lightmaps...');flush(logfile);

 LTFF(G_pd3ddevice,'data\TMPlmap.bmp',lightmap);
 writeln(logfile,'lm texture...');flush(logfile);
 deletefile('data\TMPlmap.bmp');


 writeln(logfile,'imposters...');flush(logfile);
  lasterror := D3DXCreateTexture(g_pd3dDevice, IMPOSTERTEXSIZE,IMPOSTERTEXSIZE,0, D3DUSAGE_RENDERTARGET,D3DFMT_A8R8G8B8,D3DPOOL_DEFAULT, imposters);
  if FAILED(lasterror) then
  begin
    lasterror := D3DXCreateTexture(g_pd3dDevice, IMPOSTERTEXSIZE,IMPOSTERTEXSIZE, 0, 0, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, imposters);
    if FAILED(lasterror) then
    begin
     //felez�nk �s retry
     impostertexsize:=512;
     invimpostertexsize:=1/impostertexsize;
     lasterror := D3DXCreateTexture(g_pd3dDevice, IMPOSTERTEXSIZE,IMPOSTERTEXSIZE,0, D3DUSAGE_RENDERTARGET,D3DFMT_A8R8G8B8,D3DPOOL_DEFAULT, imposters);
     if FAILED(lasterror) then
     begin
      lasterror := D3DXCreateTexture(g_pd3dDevice, IMPOSTERTEXSIZE,IMPOSTERTEXSIZE, 0, 0, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, imposters);
      if FAILED(lasterror) then
       exit;
     end;
    end;
  end;


   writeln(logfile,'2...');flush(logfile);
   imposters.GetSurfaceLevel(0, impossurf);

  lasterror := D3DXCreateRenderToSurface(g_pd3dDevice, IMPOSTERTEXSIZE,IMPOSTERTEXSIZE,
              D3DFMT_A8R8G8B8, true, D3DFMT_D16, imposrender);

 if FAILED(lasterror) then Exit;

 imposrender.BeginScene(impossurf,nil);
 g_pd3ddevice.Clear(0,nil,D3DCLEAR_TARGET,0,0,0);
 imposrender.EndScene(D3DTEXF_NONE);

 setlength(imposarr,length(ojjektumarr));
 for i:=0 to high(ojjektumarr) do
 begin
  setlength(imposarr[i],ojjektumarr[i].hvszam);
  for j:=0 to ojjektumarr[i].hvszam-1 do
   zeromemory(@(imposarr[i,j]),sizeof(Timposterdata));
 end;

 writeln(logfile,'read...');flush(logfile);

 //POLIK M�SOL�SA
 facecnt:=0; vertcnt:=0;
 for i:=0 to high(ojjektumarr) do
 with ojjektumarr[i] do
  begin
   attrszam:=length(mymesh.attrtable);
   copymemory(@(attrarr[0]),@(mymesh.attrtable[0]),attrszam*sizeof(TD3DXAttributerange));
  // writeln(logfile,ojjektumnevek[i],':');
    for k:=0 to attrszam-1 do
    begin
     inc(facecnt,integer(attrarr[k].FaceCount)*hvszam*3);
     inc(vertcnt,integer(attrarr[k].vertexCount)*hvszam);
     //write(logfile,attrarr[k].FaceCount,'/',attrarr[k].VertexCount,'---');
    end;
  end;
 {$IFDEF normaltest}
  setlength(normalvon,vertcnt);
 {$ENDIF}
    //asd
  write(logfile,'VBuffer...');flush(logfile);
  lasterror:=g_pd3dDevice.CreateVertexBuffer(vertcnt*sizeof(Tojjektumvertex2),
                                            D3DUSAGE_WRITEONLY, 0,
                                            D3DPOOL_DEFAULT, g_pVB, nil);
  if FAILED(lasterror)
  then
  begin
   writeln(logfile,'Failed creating static buffer of ',vertcnt,' size (',lasterror,')');flush(logfile);
   Exit;
  end;


  write(logfile,'IBuffer...');flush(logfile);

  
  if use32bitindices then
  begin
   if FAILED(g_pd3dDevice.CreateIndexBuffer(facecnt*SizeOf(dword),
                                             D3DUSAGE_WRITEONLY,D3DFMT_INDEX32,
                                             D3DPOOL_DEFAULT , g_pIB, nil))
   then Exit;
  end
  else
  begin
    if FAILED(g_pd3dDevice.CreateIndexBuffer(facecnt*SizeOf(word),
                                             D3DUSAGE_WRITEONLY,D3DFMT_INDEX16,
                                             D3DPOOL_DEFAULT , g_pIB, nil))
    then Exit;

  end;
 write(logfile,'locking...');flush(logfile);

 facecur:=0; vertcur:=0; vertcurdyn:=0;
 for i:=0 to high(ojjektumarr) do
 with ojjektumarr[i] do
  begin
   attrszam:=length(mymesh.attrtable);
   copymemory(@(attrarr[0]),@(mymesh.attrtable[0]),attrszam*sizeof(TD3DXAttributerange));

   pindojj:=pointer(@mymesh.Indices[0]);
   pvertojj:=pointer(@mymesh.vertices[0]);

   setlength(drawtable[i].DIPData,attrszam*hvszam);
   setlength(drawtable[i].visible,hvszam);
   setlength(drawtable[i].RenderZ,hvszam);

   drawtable[i].xasz:=attrszam;
    for j:=0 to attrszam-1 do
     for k:=0 to hvszam-1 do
     with  drawtable[i].DIPData[j*hvszam+k] do
     begin

      facecount:=attrarr[j].FaceCount;
      vertcount:=attrarr[j].VertexCount;

      facestart:=facecur;

      vertstart:=vertcur;
      if FAILED(g_pVB.Lock(vertstart*sizeof(Tojjektumvertex2), vertcount*sizeof(Tojjektumvertex2),pointer(pVert) , CSICSA_LOCK_FLAG)) then exit;
     

      if use32bitindices then
      begin
       if FAILED(g_pIB.Lock(facestart*SizeOf(dword)           , facecount*SizeOf(dword)          ,pointer(pind32), CSICSA_LOCK_FLAG)) then exit;
      end
      else
      begin
       if FAILED(g_pIB.Lock(facestart*SizeOf(word)            , facecount*SizeOf(word)           ,pointer(pind16), CSICSA_LOCK_FLAG)) then exit;
      end;
      
      if textures[j]<0 then
      begin
       facecount:=0;
       vertcount:=0;
       continue;
      end;
      tex:=textures[attrarr[j].AttribId];
      for l:=0 to facecount*3-1 do
      begin
       tmp1:=pindojj[attrarr[j].FaceStart*3+l]-attrarr[j].VertexStart{+vertstart};
       if use32bitindices then
        pind32[l]:=tmp1
       else
        pind16[l]:=tmp1;
      end;

      for l:=0 to vertcount-1 do
      begin
       pvert[l].tu:=pvertojj[l+attrarr[j].vertexStart].tu;
       pvert[l].tv:=pvertojj[l+attrarr[j].vertexStart].tv;
       pvert[l].lu:=pvertojj[l+attrarr[j].vertexStart].lu*lmapx[i,2]/2048+lmapx[i,0]/2048;
       pvert[l].lv:=pvertojj[l+attrarr[j].vertexStart].lv*lmapx[i,2]/2048+lmapx[i,1]/2048;
       d3dxvec3add(tmp2,      pvertojj[l+attrarr[j].vertexStart].position,holvannak[k]);

       pvert[l].position:=tmp2;
       pvert[l].normal  :=mymesh.normals[l+attrarr[j].vertexStart].normal;
       pvert[l].tangent :=mymesh.normals[l+attrarr[j].vertexStart].tangent;
       pvert[l].binormal:=mymesh.normals[l+attrarr[j].vertexStart].binormal;

       {$IFDEF normaltest}
       normalvon[(vertcur+l)][0]:=tmp2;
       d3dxvec3normalize(tmp2a,mymesh.normals[l+attrarr[j].vertexStart].binormal);
       d3dxvec3scale(tmp2a,tmp2a,0.5);
       d3dxvec3add(normalvon[(vertcur+l)][1],tmp2,tmp2a);
       {$ENDIF}
      end;
      g_pVB.Unlock;
      g_pIb.Unlock;

      inc(facecur,facecount*3);
      inc(vertcur,vertcount);

     end;

   for j:=0 to trinum-1 do
   begin
    with pvertojj[pindojj[3*j+0]] do
    begin lu2:=    lu; lv2:=    lv; end;

    with pvertojj[pindojj[3*j+1]] do
    begin lu2:=lu2+lu; lv2:=lv2+lv; end;

    with pvertojj[pindojj[3*j+2]] do
    begin lu2:=lu2+lu; lv2:=lv2+lv; end;

    szin:=lightmapbm[round((lv2/3)*lmapx[i,2]+lmapx[i,1]),round((lu2/3)*lmapx[i,2]+lmapx[i,0]),1];
    trilght[j]:=min(szin,128);
   end;

  end;

  write(logfile,'decls...');flush(logfile);
 g_pd3ddevice.CreateVertexDeclaration(@(declarr[0]),vertdecl);
 declarr2[0]:=declarr[0];
 declarr2[1]:=declarr[1];
 declarr2[2]:=declarr[2];
 declarr2[3]:=declarr[6];
 g_pd3ddevice.CreateVertexDeclaration(@(declarr2[0]),vertdeclgagyi);

 osszvert:=vertcur;
 osszind:=facecur;


 writeln(logfile,'Success.');flush(logfile);
end;

destructor T3DORenderer.Destroy;
begin
 g_pIB:=nil;
 g_pVB:=nil;
 lightmap:=nil;
 g_pd3ddevice:=nil;
 inherited;
end;
                                       //MiHezK�pest
procedure T3DORenderer.RefreshImposters(mhk:TD3DXVector3);
const
 MIN_FRESH=25;
 MAX_FRESH=1000;
 ATMENET_IDO=25;
const
avp:TD3DViewport9=(X:0;Y:0;width:0;Height:0;minZ:0;maxZ:1);
var
i,j,k:integer;
viPo:TD3DViewport9;
hol,tlegu:TD3DXVector3;
kelluj:boolean;
ttav:single;
nagyx,nagyy,unx,uny,unz:single;
vmi,vma,lat,pv1,pv2,pvmi,pvma:TD3DXVector3;
q1,q2,q3,q2a,q3a:TD3DXVector3;
qz:single;
matv2,matproj:TD3DMatrix;
rect,rectmb:Tojjrect;
begin

  g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iTrue);
  g_pd3dDevice.SetRenderState(D3DRS_ZWRITEENABLE, iTrue);
 for i:=0 to high(ojjektumarr) do
  for j:=0 to ojjektumarr[i].hvszam-1 do
  with imposarr[i,j] do
  begin
   inc(lstfrsh);
   hol:=ojjektumarr[i].holvannak[j];
   ttav:=tavpointpointsq(hol,mhk);
   if ttav>sqr(max(150,ojjektumarr[i].rad2*4)) then
   begin
    kelluj:=not imposter;
    qz:=1/ojjektumarr[i].rad;
    ttav:=fastinvsqrt(ttav);
    kelluj:=kelluj or ((tav-ttav)>0.01*qz);
    d3dxvec3subtract(tlegu,hol,mhk);
    d3dxvec3normalize(tlegu,tlegu);
    kelluj:=kelluj or (d3dxvec3dot(legu,tlegu)<(1-0.05*qz));
    kelluj:=kelluj or ((lstfrsh>MAX_FRESH) and (random(5)=0));
    if imposter then kelluj:=kelluj and (lstfrsh>MIN_FRESH);
    if kelluj then
    begin
     lstfrsh:=0;
     legu:=tlegu;
     tav:=ttav;
     d3dxvec3add(vmi,ojjektumarr[i].vmi,ojjektumarr[i].holvannak[j]);
     d3dxvec3add(vma,ojjektumarr[i].vma,ojjektumarr[i].holvannak[j]);
     d3dxvec3lerp(lat,vmi,vma,0.5);
     D3DXMatrixLookAtLH(matv2, mhk, lat, d3dxvector3(0,1,0));
     D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/3, 4/3, 1, 1100.0);

     vipo:=avp;
     vipo.Width:=SCwidth;
     vipo.Height:=SCheight;

     nagyx:=0; nagyy:=0;

     for k:=0 to 7 do
     begin
      if (k and 1)=0 then pv1.x:=vmi.x else pv1.x:=vma.x;
      if (k and 2)=0 then pv1.y:=vmi.y else pv1.y:=vma.y;
      if (k and 4)=0 then pv1.z:=vmi.z else pv1.z:=vma.z;

      D3Dxvec3project(pv2,pv1,vipo,matproj,matv2,identmatr);
      unx:=abs(pv2.x-SCWidth*0.5);
      uny:=abs(pv2.y-SCHeight*0.5);
      if unx>nagyx then nagyx:=unx;
      if uny>nagyy then nagyy:=uny;
     end;

     rectremove(imposrects,i,not j);
     rectmegbasztat(imposrects,i,j,not j);

     rectresize(imposrects,i,j,round(nagyx),round(nagyy));

     rect:=rectget(imposrects,i,j);
     rectmb:=rectget(imposrects,i, not j);

     vipo.X:=rect.px;
     vipo.y:=rect.py;
     vipo.Width:=rect.mx;
     vipo.Height:=rect.my;

     d3dxvec3subtract(q1,lat,mhk);
     qz:=d3dxvec3length(q1);//-ojjektumarr[i].rad2;
     if qz<0.00001 then qz:=1;
     if rect.mx<1 then rect.mx:=1;
     if rect.my<1 then rect.my:=1;
     D3DXMatrixPerspectiveLH(matProj, d3dxvec3length(q1)*rect.mx/SCHeight,d3dxvec3length(q1)*rect.my/SCHeight, qz*0.5, 1100.0);
     //if d3dxvec3lengthsq(q1)<0.0001 then q1:=D3DXVector3(1,1,1);
     d3dxvec3lerp(q1,lat,mhk,1{qz/d3dxvec3length(q1)});
     D3DXMatrixLookAtLH(matv2, q1, lat, d3dxvector3(0,1,0));

     if (vipo.Height<>0) and (vipo.Width<>0) then
     if SUCCEEDED(imposrender.BeginScene(impossurf,@vipo)) then
     begin


      g_pd3ddevice.SetTransform(D3DTS_VIEW,matv2);
      g_pd3ddevice.SetTransform(D3DTS_WORLD,identmatr);
      g_pd3ddevice.SetTransform(D3DTS_PROJECTION,matproj);


      g_pd3dDevice.Clear(0, nil, D3DCLEAR_ZBUFFER+D3DCLEAR_TARGET,
                       $A0A0A0 , 1.0, 0);
      DrawOne(i,j);
      imposrender.EndScene(D3DTEXF_NONE)
     end;

     quad[0].u1:=(rect.px+0.5)    *invimpostertexsize;
     quad[0].v1:=(rect.py+0.5)        *invimpostertexsize;

     quad[2].u1:=(rect.px+0.5)    *invimpostertexsize;
     quad[2].v1:=(rect.py+rect.my-0.5)*invimpostertexsize;

     quad[1].u1:=(rect.px+rect.mx-0.5)*invimpostertexsize;
     quad[1].v1:=(rect.py+0.5)         *invimpostertexsize;

     quad[3].u1:=(rect.px+rect.mx-0.5)*invimpostertexsize;
     quad[3].v1:=(rect.py+rect.my-0.5)*invimpostertexsize;

     quad[0].u2:=(rectmb.px+0.5)    *invimpostertexsize;
     quad[0].v2:=(rectmb.py+0.5)        *invimpostertexsize;

     quad[2].u2:=(rectmb.px+0.5)    *invimpostertexsize;
     quad[2].v2:=(rectmb.py+rectmb.my-0.5)*invimpostertexsize;

     quad[1].u2:=(rectmb.px+rectmb.mx-0.5)*invimpostertexsize;
     quad[1].v2:=(rectmb.py+0.5)         *invimpostertexsize;

     quad[3].u2:=(rectmb.px+rectmb.mx-0.5)*invimpostertexsize;
     quad[3].v2:=(rectmb.py+rectmb.my-0.5)*invimpostertexsize;

     d3dxvec3subtract(q1,lat,mhk);
     qz:=d3dxvec3length(q1)-ojjektumarr[i].rad2;
     d3dxvec3scale(q1,q1,     qz/d3dxvec3length(q1));
     //qz:=qz*0.5;
     d3dxvec3cross(q2,q1,d3dxvector3(0,1,0));
     d3dxvec3scale(q2,q2,qz*rect.mx/(SCHeight*d3dxvec3length(q2)));
     d3dxvec3cross(q3,q1,q2);
     d3dxvec3scale(q3,q3,qz*rect.my/(SCHeight*d3dxvec3length(q3)));

     d3dxvec3scale(q2a,q2,-1);
     d3dxvec3scale(q3a,q3,-1);

     q4b:=q4a;

     q4a[0]:=vec3add4(mhk,q1,q2 ,q3a);
     q4a[1]:=vec3add4(mhk,q1,q2a,q3a);
     q4a[2]:=vec3add4(mhk,q1,q2 ,q3 );
     q4a[3]:=vec3add4(mhk,q1,q2a,q3 );

     quad[0].position:=q4b[0];
     quad[1].position:=q4b[1];
     quad[2].position:=q4b[2];
     quad[3].position:=q4b[3];

     quad[5]:=quad[1];
     quad[4]:=quad[2];
     if imposter then
     atmenet:=ATMENET_IDO
     else
     atmenet:=1;
     imposter:=true;
    end;
    if (atmenet>0) then
    begin            
     dec(atmenet);
     for k:=0 to 5 do
      quad[k].color:=(((atmenet)*$FF) div ATMENET_IDO)*$01010101;

     d3dxvec3lerp(quad[0].position,q4a[0],q4b[0],atmenet/ATMENET_IDO);
     d3dxvec3lerp(quad[1].position,q4a[1],q4b[1],atmenet/ATMENET_IDO);
     d3dxvec3lerp(quad[2].position,q4a[2],q4b[2],atmenet/ATMENET_IDO);
     d3dxvec3lerp(quad[3].position,q4a[3],q4b[3],atmenet/ATMENET_IDO);

     quad[5].position:=quad[1].position;
     quad[4].position:=quad[2].position;

     if atmenet=0 then
      rectremove(imposrects,i,not j);
    end;
   end
   else
   if imposter then
   begin
    imposter:=false;
    rectremove(imposrects,i,j);
    rectremove(imposrects,i,not j);
   end;
  end;

end;

procedure T3DORenderer.DrawOne(ind1,ind2:integer);
var
i,j,jj,k:integer;
begin
 g_pd3dDevice.SetRenderState(D3DRS_FOGENABLE, iFalse);
 g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iFalse);
 g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
 g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);
 g_pd3ddevice.SetRenderState(D3DRS_ALPHATESTENABLE, iFALSE);


 g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_DISABLE);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_DISABLE);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG1);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP,   D3DTOP_MODULATE);

 g_pd3ddevice.SetTransform(D3DTS_TEXTURE0,identmatr);
 g_pd3ddevice.SetTransform(D3DTS_TEXTURE1,identmatr);
 g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
 g_pd3dDevice.SetSamplerState(1, D3DSAMP_MIPFILTER, D3DTEXF_NONE );

 g_pd3ddevice.SetStreamSource(0,g_pVB,0,sizeof(Tojjektumvertex2));
 g_pd3ddevice.SetIndices(g_pIB);
 g_pd3ddevice.SetTexture(1,lightmap);

 for k:=0 to OTnSzam do
 begin
  g_pd3ddevice.SetTexture(0,ojjektumtextures[k].tex);
   g_pd3ddevice.SetVertexdeclaration(vertdeclgagyi);

   i:=ind1;
   jj:=ind2;
   for j:=0 to drawtable[i].xasz-1 do
    if drawtable[i].DIPdata[j*ojjektumarr[i].hvszam].tex=k then
       with drawtable[i].DIPdata[j*ojjektumarr[i].hvszam+jj] do
         g_pd3ddevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST,vertstart,0,vertcount,facestart,facecount);
 end;

end;

procedure T3DORenderer.Draw(frust:TFrustum;g_pEffect:ID3DXEffect;matView,matProj:TD3DMatrix;fogstart,fogend:single;renderimposters:boolean);
var
i,j,jj,k:integer;
aabb:TAABB;
tmplw:longword;
matViewProj:TD3DMatrix;
trukkproj:TD3Dmatrix;
hdrszorzo:single;
vec:TD3DXVector3;
emit:boolean;
begin

 g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iFalse);
 g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);
 g_pd3ddevice.SetRenderState(D3DRS_ALPHAREF, $A0);
 g_pd3ddevice.SetRenderState(D3DRS_ALPHAFUNC,  D3DCMP_GREATER);
                                                             
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG1);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP,   FAKE_HDR);

 g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP,   D3DTOP_SELECTARG1);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_ALPHAARG1, D3DTA_CURRENT);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_ALPHAOP,   D3DTOP_SELECTARG1);

 g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_BLENDFACTOR);
 g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVBLENDFACTOR);
 g_pd3ddevice.SetRenderState(D3DRS_BLENDOP,D3DBLENDOP_ADD);

 g_pd3ddevice.SetRenderState(D3DRS_BLENDFACTOR,$505050);
 g_pd3ddevice.SetStreamSource(0,g_pVB,0,sizeof(Tojjektumvertex2));
 g_pd3ddevice.SetIndices(g_pIB);

 g_pd3ddevice.SetTransform(D3DTS_WORLD,identmatr);
 g_pd3ddevice.SetTexture(1,lightmap);

 case FAKE_HDR of
  D3DTOP_MODULATE:hdrszorzo:=1;
  D3DTOP_MODULATE2X:hdrszorzo:=2;
  D3DTOP_MODULATE4X:hdrszorzo:=4;
 else
  hdrszorzo:=0;
 end;

 for i:=0 to high(ojjektumarr) do
 with ojjektumarr[i] do
 begin
  for j:=0 to hvszam-1 do
  begin
   d3dxvec3add(aabb.min,vmi,holvannak[j]);
   d3dxvec3add(aabb.max,vma,holvannak[j]);
   drawtable[i].visible[j]:=(not (imposarr[i,j].imposter and renderimposters)) and AABBvsfrustum(aabb,frust);
   d3dxvec3add(vec,holvannak[j],vce);
   drawtable[i].RenderZ[j]:=tavpointpointsq(vec,campos)<sqr(rad+10);
  end;
 end;

 trukkproj:=matproj;
 trukkproj._43:=trukkproj._43+0.001;
 g_pd3ddevice.SetTransform(D3DTS_PROJECTION,trukkproj);
 g_pd3ddevice.SetTransform(D3DTS_WORLD,identmatr);
 //Render Z first... rem�lj�k nem lass�t t�bbet mint a POM fillrate :S
 if (g_peffect<>nil) then
  begin
    g_pd3dDevice.SetRenderState(D3DRS_COLORWRITEENABLE, 0);
   for i:=0 to high(drawtable) do
   begin
   for j:=0 to ojjektumarr[i].hvszam-1 do
   if drawtable[i]. visible[j] and drawtable[i].RenderZ[j] then
    for k:=0 to drawtable[i].xasz-1 do
    if (drawtable[i].DIPdata[j+k].tex>=0) then
    begin
    if not ojjektumtextures[drawtable[i].DIPdata[j+k].tex].alphatest and
    not ojjektumtextures[drawtable[i].DIPdata[j+k].tex].emitting then
     with drawtable[i].DIPdata[j+k] do
       g_pd3ddevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST,vertstart,0,vertcount,facestart,facecount);    //}
       end;
   end;
   g_pd3dDevice.SetRenderState(D3DRS_COLORWRITEENABLE, 255);
  end;

 g_pd3ddevice.SetTransform(D3DTS_PROJECTION,matproj);
 //Azt�n a color �s a POM
 for k:=0 to OTnSzam do
 begin

  if ojjektumtextures[k].alphatest then
   g_pd3ddevice.SetRenderState(D3DRS_ALPHATESTENABLE, iTrue)
  else
   g_pd3ddevice.SetRenderState(D3DRS_ALPHATESTENABLE, iFalse);
  g_pd3ddevice.SetTexture(0,ojjektumtextures[k].tex);

  if ojjektumtextures[k].emitting then
  g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE)
  else
  g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, FAKE_HDR);

  //g_pd3ddevice.SetTexture(0,imposters);
   // g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_NONE);
  if (g_peffect<>nil) and (ojjektumtextures[k].heightmap<>nil) then
  begin
   if FAILED(g_peffect.SetTechnique('ParallaxOcclusion')) then
    g_peffect:=nil
   else
   begin
    d3dxmatrixmultiply(matViewproj,matView,matProj);
    g_pEffect.SetMatrix('g_mWorldViewProjection', matViewproj);
    g_peffect.SetFloat ('FogStart',fogstart);
    g_peffect.SetFloat ('FogEnd',fogend);
    g_pEffect.SetTexture('g_MeshTexture', ojjektumtextures[k].tex);
    g_pEffect.SetTexture('g_MeshHeightmap', ojjektumtextures[k].heightmap);
    g_pEffect.SetTexture('g_MeshLightmap',lightmap);
    g_pEffect.SetFloat ('HDRszorzo',HDRszorzo);
    g_peffect.SetVector('g_CameraPosition',D3DXVector4(campos.x,campos.y,campos.z,0));
    g_pd3ddevice.SetVertexdeclaration(vertdecl);
    g_peffect._Begin(@tmplw,0);
    g_peffect.BeginPass(0);
   end;
  end
  else
   g_pd3ddevice.SetVertexdeclaration(vertdeclgagyi);

  for i:=0 to high(drawtable) do
  begin

   if ojjektumarr[i].hvszam>0 then
   for j:=0 to drawtable[i].xasz-1 do
    if drawtable[i].DIPdata[j*ojjektumarr[i].hvszam].tex=k then
      for jj:=0 to ojjektumarr[i].hvszam-1 do
       if drawtable[i].visible[jj] then
        with drawtable[i].DIPdata[j*ojjektumarr[i].hvszam+jj] do
         g_pd3ddevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST,vertstart,0,vertcount,facestart,facecount);
  end;

  if (g_peffect<>nil) and (ojjektumtextures[k].heightmap<>nil) then
  begin
   g_peffect.Endpass;
   g_peffect._end;
  end;

 end;
 //g_pd3dDevice.SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);

 //g_pd3
 //for i:=0 to
 {$IFDEF testtris}
   g_pd3ddevice.drawprimitiveUP(D3DPT_TRIANGLELIST,length(teszttris),teszttris[0,0],sizeof(TD3DXVector3));
 {$ENDIF}

 {$IFDEF normaltest}
   // g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iFalse);
   g_pd3ddevice.drawprimitiveUP(D3DPT_LINELIST,15000{length(normalvon)},normalvon[0,0],sizeof(TD3DXVector3));
  // g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iTrue);
 {$ENDIF}


  g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_NONE );
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG1);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP,   D3DTOP_SELECTARG1);
 g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);

 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP,   D3DTOP_LERP);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG0, D3DTA_DIFFUSE);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG2, D3DTA_CURRENT);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG1, D3DTA_TEXTURE);

 g_pd3dDevice.SetTextureStageState(1, D3DTSS_ALPHAOP,   D3DTOP_LERP);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_ALPHAARG0, D3DTA_DIFFUSE);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_ALPHAARG2, D3DTA_CURRENT);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);

 g_pd3ddevice.SetTexture(0,imposters);
 g_pd3ddevice.SetTexture(1,imposters);
 g_pd3dDevice.SetRenderState(D3DRS_ALPHATESTENABLE, iTrue);

 g_pd3ddevice.SetRenderState(D3DRS_ALPHAREF, $A0);
 g_pd3ddevice.SetRenderState(D3DRS_ALPHAFUNC,  D3DCMP_GREATER);

{ g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iTrue);
 g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_ONE);
 g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
 g_pd3ddevice.SetRenderState(D3DRS_BLENDOP,D3DBLENDOP_ADD); }

 g_pd3ddevice.SetFVF(D3DFVF_IMPOSTERVERTEX);
 if renderimposters then
 for i:=0 to high(imposarr) do
  for j:=0 to high(imposarr[i]) do
   if imposarr[i,j].imposter then
    g_pd3ddevice.drawprimitiveUP(D3DPT_TRIANGLELIST,2,imposarr[i,j].quad[0],sizeof(TImposterVertex));

    g_pd3ddevice.SetRenderState(D3DRS_ALPHAREF, $0);
 g_pd3dDevice.SetRenderState(D3DRS_ALPHATESTENABLE, iFalse);
 g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_ALPHAOP, D3DTOP_DISABLE);
  g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR );
end;


end.

