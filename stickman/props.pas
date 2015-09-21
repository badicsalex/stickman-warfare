unit props;

interface
uses
  Sysutils,
  Direct3D9,
  D3DX9,
  Windows,
  Typestuff,
  ojjektumok;
type



   TColl = record
    alak:byte;
    xmin,xmax:single;
    ymin,ymax:single;
    zmax,zmin:single;
   end;

  // TCollCylinder = record
  // public
 //   radius,ymin,ymax:single;
  //  xpos,ypos:single;
  //  function collide(poi:TD3DXVector3;gmbnagy:single;out pi:TD3DXVector3;melyik:integer):boolean;
  // end;

   TTexture = record
    name:string;
    tex:IDirect3DTexture9;
   end;

   PTexture = ^TTexture;
   
   TMaterial = record
    diffusename,normalname:string;
    diffuse:IDirect3DTexture9;
    normal:IDirect3DTexture9;
    specIntensity,specHardness:single;
    emission:single;
   end;

   PMaterial = ^TMaterial;

   TProp = record
    name:string;
    model:string;
    mesh:ID3DXMesh;
    subsetnum:integer;
    materials:array of PMaterial;
    colls:array of TColl;
   end;

   PProp = ^TProp;


   TPropInstance = record
    proto:PProp;
    pos:TD3DXvector3;
    rot:single;
    scale:single;
    visible:boolean;
    light:single;
    name:string;
   end;

   PPropInstance = ^TPropInstance;

   TDynamicInstance = record
    prop:PPropInstance;
    speed:TD3DXvector3;
    rotspeed:single;
    name:string;
   end;

   PDynamicInstance = ^TDynamicInstance;

   TPropsystem = class (TObject)
   protected
    g_pD3Ddevice:IDirect3ddevice9;
   public

    protos:array of PProp;
    objects:array of TPropInstance;
    textures:array of PTexture;
    dynamics:array of TDynamicInstance;

    lasttime:cardinal;

    constructor Create(adevice : IDirect3ddevice9);

    procedure addPrototype(name,model:string);
    procedure addObject(name:string;position:TD3DXvector3;rot,scale,lght:single;nam:string;visib:boolean);
    procedure removeLast;
    function getProtoByName(name:string):PProp;
    procedure RenderModels(g_peffect:ID3DXEffect);
    procedure useMaterial(g_peffect:ID3DXEffect;mat:PMaterial);
    procedure addMaterial(name:string;mat:TMaterial);
    procedure addColl(name,alak:string;x1,x2,y1,y2,z1,z2:single);
    function loadTexture(name:string):IDirect3DTexture9;
    function collision(poi:TD3DXVector3;gmbnagy:single;out pi:TD3DXVector3;melyik:integer):boolean;
    function collide(poi:TD3DXVector3;gmbnagy:single;out pi:TD3DXVector3;obj:TPropInstance;coll:TColl):boolean;

    function dynamizate(propname:string):PDynamicInstance;
    function getdynamic(propname:string):PDynamicInstance;
    function getprop(propname:string):PPropInstance;

    procedure updatedynamic;

    procedure setVisibility(name:string;vis:boolean);

  end;

const

COLL_BOX      = $01;
COLL_CYLINDER = $02;

implementation


constructor TPropsystem.Create(adevice : IDirect3ddevice9);
begin
 inherited create;
 
 g_pD3Ddevice :=   adevice;
 lasttime := GetTickCount;

end;

function TPropsystem.getProtoByName(name:string):PProp;
var
i:integer;
begin
 result := nil;
  for i:=0 to length(protos)-1 do
  begin
    if protos[i].name = name then
    begin
      result := protos[i];
      break;
    end;
  end;

end;

procedure TPropsystem.addPrototype(name,model:string);
var
i:integer;
prop:PProp;
tempmesh:ID3DXMesh;
nummat:dword;
res:HRESULT;
begin
 new(prop); 
 prop.name := name;
 prop.model := model;

 if FAILED(D3DXLoadMeshFromX(PChar('data/props/'+model),0,g_pd3ddevice,nil,nil,nil,@nummat,tempmesh)) then
 begin
  MessageBox(0,Pchar('Error loading: '+model),'Hiba',0);
  if (not FileExists('data/props/'+model)) then MessageBox(0,Pchar(model+' does not exists.'),'Hiba',0);
  exit;
 end;

 if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_CUSTOMVERTEX,g_pd3ddevice, prop.mesh)) then
 begin
  MessageBox(0,Pchar('Error loading: '+model),'Hiba',0);
  exit;
 end;

 //res :=D3DXComputeTangentFrameEx(tempmesh, 5, 0,
 //     7, 0, 6, 0,
 //     3, 0,
 //     $0400,
 //     nil, 0.01, 0.25, 0.01, prop.mesh, nil);

 //res :=D3DXComputeTangentFrameEx(tempmesh, D3DXTANGENT_GENERATE_IN_PLACE, 0,
 //     D3DDECLUSAGE_BINORMAL, 0, D3DDECLUSAGE_TANGENT, 0,
 //     D3DDECLUSAGE_NORMAL, 0,
 //    dwOptions | D3DXTANGENT_GENERATE_IN_PLACE,
 //     nil, 0.01f, 0.25f, 0.01f, tempmesh2, nil);

// if res<>S_OK then MessageBox(0,Pchar('Error generating tangent and binormal for: '+model),'Hiba',0);

 prop.subsetnum := DWORD(nummat);

 if tempmesh<>nil then tempmesh:=nil;




 i := high(protos)+1;
 SetLength(protos,i+1);
 protos[i] := prop;

 if i>0 then
 write(logfile,', ');
 write(logfile,name);flush(logfile);

end;


procedure TPropsystem.addColl(name,alak:string;x1,x2,y1,y2,z1,z2:single);
var
coll:TColl;
proto:PProp;
begin

 coll.alak := COLL_BOX;
 coll.xmin:=x1;
 coll.xmax:=x2;
 coll.ymin:=y1;
 coll.ymax:=y2;
 coll.zmin:=z1;
 coll.zmax:=z2;

 proto := getProtoByName(name);

 setlength(proto.colls,length(proto.colls)+1);
 proto.colls[length(proto.colls)-1] := coll;

end;


procedure TPropsystem.addObject(name:string;position:TD3DXvector3;rot,scale,lght:single;nam:string;visib:boolean);
var
prop:TPropInstance;
proto:PProp;
i:integer;
begin

  proto := getProtoByName(name);

  prop.proto := proto;
  prop.pos := position;
  prop.rot := rot;
  prop.scale := scale;
  prop.light := lght;
  prop.name := nam;
  prop.visible := visib;

  i := high(objects)+1;
  SetLength(objects,i+1);
  objects[i] := prop;

end;

procedure TPropsystem.removeLast;
begin
  if length(objects) > 0 then
    SetLength(objects,length(objects)-1);
end;

procedure TPropsystem.RenderModels(g_peffect:ID3DXEffect);
var
i,j:integer;
matViewproj:TD3DMatrix;
tmplw:longword;
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


  for i:=0 to high(objects) do
  begin
    //g_pd3ddevice.settexture(0,objects[i].proto.tex);
    if objects[i].proto.mesh=nil then Continue;
    if not objects[i].visible then Continue;
    if tavpointpointsq(objects[i].pos,campos) > 10000 then continue;

    if FAILED(g_peffect.SetTechnique('Prop')) then
    exit;

    d3dxmatrixmultiply(matViewproj,matView,matProj);
    g_pEffect.SetMatrix('g_mWorldViewProjection', matViewproj);

    g_pEffect.SetFloat('rotation',(objects[i].rot)/180*D3DX_PI);

    g_pEffect.SetFloat('scale',objects[i].scale);
    
    g_pEffect.SetVector('translation',D3DXVector4(objects[i].pos,0));

    g_peffect.SetVector('g_CameraPosition',D3DXVector4(campos.x,campos.y,campos.z,0));
    g_pd3ddevice.SetVertexdeclaration(vertdecl);

    g_peffect.setFloat('lightness',objects[i].light);

    g_pd3ddevice.SetRenderState(D3DRS_ALPHATESTENABLE, iTrue);

    if (length(objects[i].proto.materials) <  objects[i].proto.subsetnum) then
    begin
      MessageBox(0,Pchar('Model '+objects[i].proto.name+' has '+
            inttostr(objects[i].proto.subsetnum)+' submesh, but only '+
            inttostr(length(objects[i].proto.materials))+' materials'),'Hiba',0);
      exit;
    end;

    for j:=0 to objects[i].proto.subsetnum-1 do
    begin
      useMaterial(g_peffect,objects[i].proto.materials[j]);
      g_peffect._Begin(@tmplw,0);
      g_peffect.BeginPass(0);

      objects[i].proto.mesh.DrawSubset(j);
      g_peffect.Endpass;
      g_peffect._end;
    end;

// g_pd3ddevice.SetRenderState(D3DRS_ALPHAREF, $0);
 g_pd3dDevice.SetRenderState(D3DRS_ALPHATESTENABLE, iFalse);
// g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, iFalse);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
 g_pd3dDevice.SetTextureStageState(1, D3DTSS_ALPHAOP, D3DTOP_DISABLE);
// g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR );

  end;
end;

procedure TPropsystem.useMaterial(g_peffect:ID3DXEffect;mat:PMaterial);
begin

  g_peffect.SetTexture('g_MeshTexture',mat.diffuse);

  g_peffect.SetBool ('vanNormal',mat.normalname<>'');
  if mat.normalname<>'' then
    g_pEffect.SetTexture('g_MeshHeightmap', mat.normal);

  g_peffect.SetFloat('specHardness',mat.specHardness);
  g_peffect.SetFloat('specIntensity',mat.specIntensity);
  g_peffect.SetFloat('emission',mat.emission);

end;

procedure TPropsystem.addMaterial(name:string;mat:TMaterial);
var
proto:PProp;
i:integer;
pm:PMaterial;
begin
  proto := getProtoByName(name);

  
  mat.diffuse := loadTexture(mat.diffusename);
  if (mat.normalname<>'') then
    mat.normal := loadTexture(mat.normalname);

  new(pm);
  copymemory(pm,@mat,sizeof(TMaterial));

  i:=length(proto.materials);
  setlength(proto.materials,i+1);
  proto.materials[i] := pm;





end;

procedure TPropsystem.setVisibility(name:string;vis:boolean);
var
i,len:integer;
begin
  len := Length(objects);
  for i:=0 to len-1 do
    if objects[i].name=name then objects[i].visible := vis;

end;

function TPropsystem.dynamizate(propname:string):PDynamicInstance;
var
i,len:integer;
begin
  len := Length(objects);
  for i:=0 to len-1 do
    if objects[i].name=propname then
    begin
      setlength(dynamics,length(dynamics)+1);
      with dynamics[length(dynamics)-1] do
      begin
        name := propname;
        speed := D3DXVector3Zero;
        rotspeed := 0;
        prop := @objects[i];
      end;
      result := @dynamics[length(dynamics)-1];
      if length(dynamics) = 1 then
        lasttime := GetTickCount;
      exit;
    end;
   result := nil;
end;

function TPropsystem.getdynamic(propname:string):PDynamicInstance;
var
i,len:integer;
begin
  len := Length(dynamics);
  for i:=0 to len-1 do
    if dynamics[i].name=propname then
    begin
      result := @dynamics[i];
      exit;
    end;
   result := nil;
end;


function TPropsystem.getprop(propname:string):PPropInstance;
var
i,len:integer;
begin
  len := Length(objects);
  for i:=0 to len-1 do
    if objects[i].name=propname then
    begin
      result := @objects[i];
      exit;
    end;
   result := nil;
end;

procedure TPropsystem.updatedynamic;
var
dt:single;
i,len:integer;
vec:TD3DXVector3;
begin
  len := length(dynamics);
  if len = 0 then exit;

  dt := GetTickCount - lasttime;
  lasttime := GetTickCount;

  for i:=0 to len-1 do
  with dynamics[i] do
  begin
    if (speed.x <>0) or (speed.y <>0) or (speed.z <>0) then
    begin
      D3DXVec3Scale(vec,speed,dt/1000) ;
      D3DXVec3Add(prop.pos,prop.pos,vec);
    end;
    if rotspeed <> 0 then
      prop.rot := prop.rot + rotspeed * (dt/1000);
  end;


end;

function TPropsystem.loadTexture(name:string):IDirect3DTexture9;
var
i:integer;
tex:IDirect3DTexture9;
texobj:PTexture;
begin

for i:=0 to Length(textures)-1 do
  if textures[i].name = name then
  begin
    result:= textures[i].tex;
    exit;
  end;

SetLength(textures,Length(textures)+1);

if not LTFF(g_pd3dDevice, 'data\props\'+name,tex) then
begin
  MessageBox(0,Pchar('Missing prop texture: '+name),'Hiba',0);
  exit;
end;

new(texobj);

texobj.name := name;
texobj.tex := tex;
textures[Length(textures)-1] := texobj;

result := tex;

end;


function TPropsystem.collision(poi:TD3DXVector3;gmbnagy:single;out pi:TD3DXVector3;melyik:integer):boolean;
var
i:integer;
iri,iri2:boolean;
begin
 iri:= false;
 poi := pi;
 for i:=0 to length(objects[melyik].proto.colls)-1 do
 begin
    iri2:= collide(pi,gmbnagy,pi,objects[melyik],objects[melyik].proto.colls[i]);
    iri := iri or iri2;
 end;
 result := iri;
end;


function TPropsystem.collide(poi:TD3DXVector3;gmbnagy:single;out pi:TD3DXVector3;obj:TPropInstance;coll:TColl):boolean;
var
res,mid,pos,tmp:TD3DXVector3;
dist,radrot:single;
xt,yt,zt:byte;
const
height:single=1.6;
begin
 with coll do
 begin
 d3dxvec3subtract(pos,poi,obj.pos);

 //ergó a cucc relative az origóban van

  if obj.rot <> 0 then
  begin
    radrot := obj.rot/180*D3DX_PI;
    tmp.x := pos.x*cos(-radrot) + pos.z*sin(-radrot);
    tmp.z := pos.x*sin(-radrot) - pos.z*cos(-radrot);
    pos := tmp;
  end;


 mid := D3DXVector3((xmin+xmax)/2,0,(zmin+zmax)/2) ;

 res :=  pos;
 
 result := false;
 // flat check:

 if (pos.x>xmin-gmbnagy) and (pos.x<xmax+gmbnagy) and
    (pos.z>zmin-gmbnagy) and (pos.z<zmax+gmbnagy) and
    (pos.y<ymax) and (pos.y+height>ymin) then

 begin

 //najó kell valami szar rendszer :D
 //felsõ 15 centi = tetjére rak semmi más és még irányítható is
 //alatta oldalra rak, oké.



  if (pos.y<ymax) and (pos.y>ymax-0.10) then
   begin
    res.y:= ymax;
    result := true;
     end
  else
  if (pos.y+height>ymin) and (pos.y+height<ymin+0.40) then
     res.y:= ymin-height
  else
  begin

   if (pos.x>xmin-gmbnagy) and (pos.x<mid.x-gmbnagy) and (pos.z>zmin) and (pos.z<zmax) then res.x := xmin-gmbnagy;

   if (pos.x<xmax+gmbnagy) and (pos.x>mid.x+gmbnagy) and (pos.z>zmin) and (pos.z<zmax) then res.x := xmax+gmbnagy;

   if (pos.z>zmin-gmbnagy) and (pos.z<mid.z-gmbnagy) and (pos.x>xmin) and (pos.x<xmax) then res.z := zmin-gmbnagy;

   if (pos.z<zmax+gmbnagy) and (pos.z>mid.z+gmbnagy) and (pos.x>xmin) and (pos.x<xmax) then res.z := zmax+gmbnagy;

  end;

 if (abs(res.y-pos.y)>0.04) then
 begin
  if (res.y>pos.y) then
    res.y := pos.y+0.04
  else
    res.y := pos.y-0.04;
 end;

 D3DXVec3Subtract(tmp,res,pos);
 dist := D3DXVec3Length(tmp);
 if (dist>0.1) then
 begin
  D3DXVec3Scale(tmp,tmp,0.1/dist);
  d3dxvec3add(res,pos,tmp);
 end;

  if obj.rot <> 0 then
  begin
    tmp.x := res.x*cos(radrot) + res.z*sin(radrot);
    tmp.z := res.x*sin(radrot) - res.z*cos(radrot);
    res := tmp;
  end;

 d3dxvec3add(pi,res,obj.pos);

 end
 else
  pi :=  poi;
 end;
end;

end.
