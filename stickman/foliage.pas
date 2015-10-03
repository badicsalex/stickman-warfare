unit foliage;

interface
uses Sysutils, Direct3D9, D3DX9, Windows, Typestuff, IniFiles,
  //  stopwatch, //TODO vedd ki
  PerlinNoise;
const
  icachehigh = 2047;
  cachehigh = 100000;
  racsnum = 32 * 32;
type

  PFoliageVertex = ^TFoliageVertex;
  TFoliageVertex = record
    position:TD3DVector; // The 3D position for the vertex
    //    normal: TD3DVector; //über extra megbaszodanyád, x = terepszín  // kivéve
    u, v:single;
  end;

  PWordBigArray = ^TWordBigArray;
  TWordBigArray = array[0..65535] of Word;

  PFoliageVertexArray = ^TFoliageVertexArray;
  TFoliageVertexArray = array[0..100000] of TFoliageVertex;
  // vicces, a mérete teljesen mindegy, mert soha nem lesz ilyen kreálva

  TVertexGenerator = procedure(pVertices:PFoliageVertexArray);
  TIndexGenerator = procedure(pIndices:PWordBigArray);

  TFoliageShapeData = record
    vertexnum:integer;
    indexnum:integer;
    vertexgen:TVertexGenerator;
    indexgen:TIndexGenerator;
    //    upsidedown:boolean;
  end;


  TFoliage = class(TObject)
  protected
    g_pD3Ddevice:IDirect3ddevice9;
    g_pVB:IDirect3DVertexBuffer9;
    g_pIB:IDirect3DIndexBuffer9;
    g_ptexture:IDirect3DTexture9;

    totalvertexnum:integer; //ez szumma
    totalindexnum:integer;

    icache:array[0..icachehigh, 0..1] of single; //x és z koordináták
    cache:array[0..cachehigh] of TD3DXVector3; //vertexek //legalább icache*shape.vertexnum
    lastc:integer; //last cached index

    shaderrelvolt:boolean;
  public
    level:byte;
    betoltve:boolean;
    scalfac:single;
    hscale, vscale, vpls:single;
    shape:TFoliageShapeData;
    constructor Create(dev:Idirect3ddevice9;texnam:string;ahscale, avscale, avpls:single;ashape:string);
    procedure Init;
    procedure Render;
    procedure update(lvl:Plvl;yandnorm:Tyandnorm);
    destructor Destroy; reintroduce;
  end;

procedure defaultVertexGenerator(pVertices:PFoliageVertexArray);
procedure defaultIndexGenerator(pIndices:PWordBigArray);
procedure grassVertexGenerator(pVertices:PFoliageVertexArray);
procedure grassIndexGenerator(pIndices:PWordBigArray);
var

  defaultShape:TFoliageShapeData = (
    vertexnum:12;
    //    indexnum:2 * 8 * 3;
    indexnum:12 * 2;
    vertexgen:defaultVertexGenerator;
    indexgen:defaultIndexGenerator;
    //    upsidedown:true;
    );

  grassShape:TFoliageShapeData = (
    vertexnum:16;
    //    indexnum:16 * 3;
    indexnum:12 * 4;
    vertexgen:grassVertexGenerator;
    indexgen:grassIndexGenerator;
    //    upsidedown:true;
    );

  //vertdecl:IDirect3DVertexDeclaration9;

implementation

const
  // D3DFVF_BOKORVERTEX = (D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_TEX1);
  D3DFVF_BOKORVERTEX = (D3DFVF_XYZ or D3DFVF_TEX1);


  //declarr:array [0..3] of D3DVERTEXELEMENT9 =
  // ((Stream:0  ; Offset:0   ; _Type:D3DDECLTYPE_FLOAT3; Method:D3DDECLMETHOD_DEFAULT; Usage:D3DDECLUSAGE_POSITION; UsageIndex:0),
  //  (Stream:0  ; Offset:3*4 ; _Type:D3DDECLTYPE_FLOAT2; Method:D3DDECLMETHOD_DEFAULT; Usage:D3DDECLUSAGE_TEXCOORD; UsageIndex:0),
  //  (Stream:0  ; Offset:5*4 ; _Type:D3DDECLTYPE_FLOAT4; Method:D3DDECLMETHOD_DEFAULT; Usage:D3DDECLUSAGE_COLOR  ; UsageIndex:0),
  //  (Stream:$FF; Offset:0   ; _Type:D3DDECLTYPE_UNUSED; Method:TD3DDeclMethod(0)    ; Usage:TD3DDeclUsage(0)     ; UsageIndex:0));


procedure defaultVertexGenerator(pVertices:PFoliageVertexArray);
const
  fixarray:array[0..11] of TFoliageVertex =
    ((position:(x:0;y:1;z:1);u:1;v:0),
    (position:(x:0;y:1;z: - 1);u:0;v:0),
    (position:(x:1;y:0;z:1);u:1;v:1),
    (position:(x:1;y:0;z: - 1);u:0;v:1),
    (position:(x: - 1;y:0;z:1);u:1;v:1),
    (position:(x: - 1;y:0;z: - 1);u:0;v:1),
    (position:(x:1;y:1;z:0);u:1;v:0),
    (position:(x: - 1;y:1;z:0);u:0;v:0),
    (position:(x:1;y:0;z:1);u:1;v:1),                                      
    (position:(x: - 1;y:0;z:1);u:0;v:1),
    (position:(x:1;y:0;z: - 1);u:1;v:1),
    (position:(x: - 1;y:0;z: - 1);u:0;v:1));
var
  i, j, shift:integer;
begin
  for i:=0 to racsnum - 1 do
  begin
    shift:=i * 12;
    for j:=0 to 11 do
    begin
      pVertices[shift + j]:=fixarray[j];
    end;
  end;
end;

procedure defaultIndexGenerator(pIndices:PWordBigArray);
type
  TIntegerArray0to11 = Array[0..11] of Integer;
const
  fixarray:TIntegerArray0to11 = (
    0, 1, 2, 2, 3, 1, 4, 5, 1, 0, 1, 4);
var
  i, j, shift:integer;
begin

  for i:=0 to racsnum * 2 - 1 do
  begin
    for j:=0 to 11 do
    begin
      pIndices[i * 12 + j]:=fixarray[j] + i * 6;
    end;
  end;

end;

procedure grassVertexGenerator(pVertices:PFoliageVertexArray);
const
  fixarray:array[0..15] of TFoliageVertex =
    ((position:(x: - 1;y:1;z:0.4);u:0;v:0),
    (position:(x:1;y:1;z:0.6);u:1;v:0),
    (position:(x:1;y:0;z:0.6);u:1;v:1),
    (position:(x: - 1;y:0;z:0.4);u:0;v:1),

    (position:(x: - 1;y:1;z: - 0.4);u:0;v:0),
    (position:(x:1;y:1;z: - 0.6);u: - 1;v:0),
    (position:(x:1;y:0;z: - 0.6);u: - 1;v:1),
    (position:(x: - 1;y:0;z: - 0.4);u:0;v:1),

    (position:(x: - 0.4;y:1;z: - 1);u:0;v:0),
    (position:(x: - 0.6;y:1;z:1);u:1;v:0),
    (position:(x: - 0.6;y:0;z:1);u:1;v:1),
    (position:(x: - 0.4;y:0;z: - 1);u:0;v:1),


    (position:(x:0.4;y:1;z: - 1);u:0;v:0),
    (position:(x:0.6;y:1;z:1);u: - 1;v:0),
    (position:(x:0.6;y:0;z:1);u: - 1;v:1),
    (position:(x:0.4;y:0;z: - 1);u:0;v:1));


var
  i, j, shift:integer;
begin
  for i:=0 to racsnum - 1 do
  begin
    shift:=i * 16;
    for j:=0 to 15 do
      pVertices[shift + j]:=fixarray[j];
  end;
end;


procedure grassIndexGenerator(pIndices:PWordBigArray);
type
  TIntegerArray0to11 = Array[0..11] of Integer;
const
  fixarray:TIntegerArray0to11 = (
    0, 1, 2, 2, 3, 0, 2, 1, 0, 0, 3, 2);
var
  i, j:integer;
begin
  for i:=0 to racsnum * 4 - 1 do
  begin
    for j:=0 to 11 do
    begin
      pIndices[i * 12 + j]:=fixarray[j] + i * 4;
    end;
  end;

end;




constructor TFoliage.Create(dev:Idirect3ddevice9;texnam:string;ahscale, avscale, avpls:single;ashape:string);
var
  pIndices:PWordBigArray;
  i:integer;
  j:integer;
begin
  inherited Create;
  betoltve:=false;
  g_pD3Ddevice:=dev;

  ZeroMemory(@icache, (icachehigh + 1) * 2 * SizeOf(single));
  ZeroMemory(@cache, (cachehigh + 1) * SizeOf(TD3DXVector3));
  lastc:=0;


  if ashape = 'bush' then shape:=defaultShape
  else if ashape = 'grass' then shape:=grassShape
  else shape:=defaultShape;

  totalvertexnum:=racsnum * shape.vertexnum;
  totalindexnum:=racsnum * shape.indexnum;

  //g_pd3ddevice.CreateVertexDeclaration(@(declarr[0]),vertdecl);


  if FAILED(g_pd3dDevice.CreateVertexBuffer(sizeof(TFoliageVertex) * totalvertexnum,
    D3DUSAGE_WRITEONLY or D3DUSAGE_DYNAMIC, D3DFVF_bokorvertex,
    D3DPOOL_DEFAULT, g_pVB, nil))
  then Exit;

  if FAILED(g_pd3dDevice.CreateIndexBuffer(sizeof(Word) * totalindexnum,
    D3DUSAGE_WRITEONLY, D3DFMT_INDEX16,
    D3DPOOL_DEFAULT, g_pIB, nil))
  then Exit;

  if FAILED(g_pIB.Lock(0, sizeof(Word) * totalindexnum, Pointer(pindices), 0))
  then Exit;

  shape.indexgen(pindices);

  if FAILED(g_pIB.unlock)
   then Exit;

  if not LTFF(g_pd3dDevice, 'data\' + texnam, g_ptexture) then
    Exit;
  addfiletochecksum('data\' + texnam);

  hscale:=ahscale;
  vscale:=avscale;
  vpls:=avpls;
  betoltve:=true;

end;

procedure TFoliage.Init;
var
  tmplw:longword;
begin

  shaderrelvolt:=csicsahdr;

  if shaderrelvolt then //bocccs
  begin
    g_peffect.SetTechnique('Foliage');
    g_pEffect.SetTexture('g_MeshTexture', g_ptexture);
    g_pEffect.SetTexture('g_Terrain', mt1);
    g_pEffect.SetTexture('g_Building', mt2);
    //g_pEffect.SetTexture('g_MeshHeightmap', g_pnormal);
//    g_pEffect.SetFloat('specHardness',10);
//    g_pEffect.SetFloat('specIntensity',0.6);
//    g_pEffect.SetBool('upsidedown',shape.upsidedown);
    g_peffect._Begin(@tmplw, 0);
    g_peffect.BeginPass(0);
  end
  else
  begin
    g_pD3Ddevice.SetTexture(0, g_ptexture);

  end;

  g_pd3ddevice.SetRenderState(D3DRS_ALPHAREF, $AF);
  g_pd3ddevice.SetRenderState(D3DRS_ALPHATESTENABLE, iTRUE);
  g_pd3ddevice.SetRenderState(D3DRS_Lighting, iFALSE);
  g_pd3ddevice.SetRenderState(D3DRS_ALPHAFUNC, D3DCMP_GREATEREQUAL);
  g_pd3ddevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);

  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP, FAKE_HDR);
  //  g_pd3dDevice.SetTextureStageState(0,D3DTSS_COLOROP,D3DTOP_SELECTARG1);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);

  g_pd3dDevice.SetTextureStageState(0, D3DTSS_CONSTANT, D3DCOLOR_ARGB(255, 220, 220, 220));
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_CONSTANT);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_TEXTURE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
  //  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_TEXTURE);

  g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
  g_pd3dDevice.SetTextureStageState(1, D3DTSS_ALPHAOP, D3DTOP_DISABLE);

  g_pd3dDevice.SetTextureStageState(2, D3DTSS_COLOROP, D3DTOP_DISABLE);
  g_pd3dDevice.SetTextureStageState(2, D3DTSS_ALPHAOP, D3DTOP_DISABLE);

end;


procedure TFoliage.Render;
begin
  g_pd3dDevice.SetStreamSource(0, g_pVB, 0, SizeOf(TFoliageVertex));
  g_pd3dDevice.SetFVF(D3DFVF_bokorvertex);
  g_pd3dDevice.SetIndices(g_pIB);
  g_pd3dDevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, totalvertexnum, 0, totalindexnum div 3);
  if shaderrelvolt then
  begin
    g_peffect.Endpass;
    g_peffect._end;
  end;
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_CONSTANT, $FFFFFFFF);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_TEXTURE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_TEXTURE);
end;


procedure Tfoliage.update(lvl:Plvl;yandnorm:Tyandnorm);
var
  i, j, k:integer;
  pVertices:PFoliageVertexArray;
  vec:TD3DXVector3;
  pls, rot, sinv, cosv, rescale:single;
  n:TD3DXVector3;
  cached:integer;
  tmp:single;
  //  sw : TStopWatch;
  tpos:TD3DXVector3;
begin
  pls:=pow2i[level];

  if FAILED(g_pVB.lock(0, sizeof(TFoliageVertex) * totalvertexnum, pointer(pvertices), 0)) //D3DLOCK_DISCARD
    then
  begin
    logerror('Failed to lock foliage verticles');
    Exit;
  end;

  shape.vertexgen(pvertices); // itt betesszük az alap pozíciókat meg UV-t

  //    sw := TStopWatch.Create() ;
  //    sw.Start;


  for i:=0 to 31 do
    for j:=0 to 31 do
    begin
      cached:= -1;
      vec:=lvl[i * 32 + j].position;

      for k:=0 to high(icache) do
        if vec.x = icache[k, 0] then //ide akár mehetne egy nagyon egyszerû hash
          if vec.z = icache[k, 1] then
          begin
            cached:=k;
            break;
          end;

      //          cached:=-1;
      if cached < 0 then
      begin
        inc(lastc);
        if lastc > high(icache) then
          lastc:=low(icache);

        icache[lastc][0]:=vec.x;
        icache[lastc][1]:=vec.z;

        d3dxvec3add(vec, vec, D3DXVector3(perlin.Noise(vec.x, 0.5, vec.z) * pls, 0, perlin.Noise(vec.x, 1.5, vec.z) * pls));

        if level <= 2 then // ha fû akkor jó lesz a terep normál
          n:=lvl[i * 32 + j].normal;
        yandnorm(vec.x, vec.y, vec.z, n, 1); // ha bokor akkor újraszámoljuk

        rot:=perlin.Noise(vec.x, 0.5, vec.z);
        sinv:=sin(rot);
        cosv:=cos(rot);

        rescale:=1;
        if (vec.y<(grasslevel)) then //homok
        begin
          vec:=D3DXVector3Zero;
          rescale:=0;
        end;

        if (n.y < 0.86) then //hegyoldal
        begin
          vec:=D3DXVector3Zero;
          rescale:=0;
        end;

        if level > 2 then
          rescale:=rescale * (0.8 + frac(abs(perlin.Noise(vec.x, 1, vec.z)) * 456) * 0.4); //0.8 +0.4 random



        for k:=0 to shape.vertexnum - 1 do
          with pvertices[k + shape.vertexnum * (j + 32 * i)] do
          begin
            tpos:=position;

            tpos.x:=cosv * tpos.x - sinv * tpos.z;
            tpos.z:=sinv * tpos.x + cosv * tpos.z;

            if level > 2 then
            begin
              if tpos.y < 0.5 then
                tpos.y:=tpos.y - ((n.x) * tpos.x) - ((n.z) * tpos.z) - 0.2 * (abs(n.x) + abs(n.z)) //ne ágaskodj
              else
              begin
                tpos.x:=tpos.x + 0.3 * n.x;
                tpos.z:=tpos.z + 0.3 * n.z;
              end;

            end
            else
              tpos.y:=tpos.y - (n.x * tpos.x) - (n.z * tpos.z); //terephez döntés

            tpos.x:=tpos.x * rescale * hscale + vec.x;
            tpos.z:=tpos.z * rescale * hscale + vec.z;
            tpos.y:=tpos.y * rescale * vscale + vec.y + rescale * vpls;

            position:=tpos;

            //            if level >2 then
            //            begin
            //            tmp:=D3DXVec3dot(n,sundir);
            //            if tmp<0 then tmp:=0;
            ////            color:=tmp;
            ////            color:=D3DXColor(1,1,1,1);
            //            normal.x:=tmp;
            //            end
            //            else
            //            normal.x:=0;

            //            if k=0 then
            //            cache[shape.vertexnum*lastc+k].x:=tmp;
            //
            //            cache[shape.vertexnum*lastc+k+1]:=tpos;
            cache[shape.vertexnum * lastc + k]:=tpos;
          end;

      end
      else
      begin
        for k:=0 to shape.vertexnum - 1 do
          with pvertices[shape.vertexnum * (j + 32 * i) + k] do
          begin
            //            normal.x:=cache[shape.vertexnum*cached].x;
            //            position:=cache[shape.vertexnum*cached+k+1];
            position:=cache[shape.vertexnum * cached + k];
          end;
      end;


    end;

  //    sw.Stop;
  //    if (sw.ElapsedMilliseconds)<>0 then
  //    writeln(logfile,  sw.ElapsedTicks div 100);
  //    writeln(logfile,  sw.elapsedmilliseconds);


  g_pVB.unlock;
end;


destructor TFoliage.Destroy;
begin
  g_pIB:=nil;
  g_pVB:=nil;
  if g_pd3ddevice <> nil then
    g_pD3Ddevice:=nil;
  inherited Destroy;
end;


end.

