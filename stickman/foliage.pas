unit foliage;

interface
uses Sysutils,Direct3D9,D3DX9,Windows,Typestuff,
//  stopwatch, //TODO vedd ki
PerlinNoise;
type

  PFoliageVertex=^TFoliageVertex;
  TFoliageVertex=record
    position:TD3DVector;// The 3D position for the vertex
//    normal: TD3DVector; //�ber extra megbaszodany�d, x = terepsz�n  // kiv�ve
    u,v:single;
  end;

  PFoliageVertexArray=^TFoliageVertexArray;
  TFoliageVertexArray=array[0..100000] of TFoliageVertex;
  // vicces, a m�rete teljesen mindegy, mert soha nem lesz ilyen kre�lva

  TVertexGenerator=procedure(pVertices:PFoliageVertexArray);
  TIndexGenerator=procedure(pIndices:PWordArray);

  TFoliageShapeData=record
    vertexnum:integer;
    indexnum:integer;
    vertexgen:TVertexGenerator;
    indexgen:TIndexGenerator;
//    upsidedown:boolean;
  end;

  TFoliage=class(TObject)
  protected
    g_pD3Ddevice:IDirect3ddevice9;
    g_pVB:IDirect3DVertexBuffer9;
    g_pIB:IDirect3DIndexBuffer9;
    g_ptexture:IDirect3DTexture9;

    vertexnum:integer;//ez szumma
    indexnum:integer;

    icache:array[0..4096] of single; //x �s z koordin�t�k felv�ltva
    cache:array[0..100000] of TD3DXVector3; //vertexek //legal�bb icache*shape.vertexnum
    lastc:integer;//last cached index

  public
    level:byte;
    betoltve:boolean;
    scalfac:single;
    hscale,vscale,vpls:single;
    shape:TFoliageShapeData;
    constructor Create(dev:Idirect3ddevice9;texnam:string;ahscale,avscale,avpls:single;ashape:string);
    procedure Init(g_peff:ID3DXEffect;shader:boolean);
    procedure Render;
    procedure update(lvl:Plvl;yandnorm:Tyandnorm);
    destructor Destroy; reintroduce;
  end;

procedure defaultVertexGenerator(pVertices:PFoliageVertexArray);
procedure defaultIndexGenerator(pIndices:PWordArray);
procedure grassVertexGenerator(pVertices:PFoliageVertexArray);
procedure grassIndexGenerator(pIndices:PWordArray);
var

  defaultShape:TFoliageShapeData=(
    vertexnum:12;
    indexnum:2*8*3;
    vertexgen:defaultVertexGenerator;
    indexgen:defaultIndexGenerator;
//    upsidedown:true;
    );

  grassShape:TFoliageShapeData=(
    vertexnum:16;
    indexnum:16*3;
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
  fixarray:array[0..11] of TFoliageVertex=
    ((position:(x:0;y:1;z:1);u:1;v:0),
    (position:(x:0;y:1;z:-1);u:0;v:0),
    (position:(x:1;y:0;z:1);u:1;v:1),
    (position:(x:1;y:0;z:-1);u:0;v:1),
    (position:(x:-1;y:0;z:1);u:1;v:1),
    (position:(x:-1;y:0;z:-1);u:0;v:1),
    (position:(x:1;y:1;z:0);u:1;v:0),
    (position:(x:-1;y:1;z:0);u:0;v:0),
    (position:(x:1;y:0;z:1);u:1;v:1),
    (position:(x:-1;y:0;z:1);u:0;v:1),
    (position:(x:1;y:0;z:-1);u:1;v:1),
    (position:(x:-1;y:0;z:-1);u:0;v:1));
var
  i,j,shift:integer;
begin
  for i:=0 to 32*32-1 do
  begin
    shift:=i*12;
    for j:=0 to 11 do
      pVertices[shift+j]:=fixarray[j];
  end;
end;

procedure grassIndexGenerator(pIndices:PWordArray);
type
  TIntegerArray0to11=Array[0..11] of Integer;
const
  fixarray:TIntegerArray0to11=(
    0,1,2,2,3,0,2,1,0,0,3,2);
var
  i,j:integer;
begin
  for i:=0 to 32*32*4-1 do
  begin
    for j:=0 to 11 do
      pIndices[i*12+j]:=fixarray[j]+i*4;
  end;
end;


procedure grassVertexGenerator(pVertices:PFoliageVertexArray);
const
  fixarray:array[0..15] of TFoliageVertex=
    ((position:(x:-1;y:1;z:0.4);u:0;v:0),
    (position:(x:1;y:1;z:0.6);u:1;v:0),
    (position:(x:1;y:0;z:0.6);u:1;v:1),
    (position:(x:-1;y:0;z:0.4);u:0;v:1),

    (position:(x:-1;y:1;z:-0.4);u:0;v:0),
    (position:(x:1;y:1;z:-0.6);u:-1;v:0),
    (position:(x:1;y:0;z:-0.6);u:-1;v:1),
    (position:(x:-1;y:0;z:-0.4);u:0;v:1),

    (position:(x:-0.4;y:1;z:-1);u:0;v:0),
    (position:(x:-0.6;y:1;z:1);u:1;v:0),
    (position:(x:-0.6;y:0;z:1);u:1;v:1),
    (position:(x:-0.4;y:0;z:-1);u:0;v:1),


    (position:(x:0.4;y:1;z:-1);u:0;v:0),
    (position:(x:0.6;y:1;z:1);u:-1;v:0),
    (position:(x:0.6;y:0;z:1);u:-1;v:1),
    (position:(x:0.4;y:0;z:-1);u:0;v:1));


var
  i,j,shift:integer;
begin
  for i:=0 to 32*32-1 do
  begin
    shift:=i*16;
    for j:=0 to 15 do
      pVertices[shift+j]:=fixarray[j];
  end;
end;


procedure defaultIndexGenerator(pIndices:PWordArray);
type
  TIntegerArray0to11=Array[0..11] of Integer;
const
  fixarray:TIntegerArray0to11=(
    0,1,2,2,3,1,4,5,1,0,1,4);
var
  i,j,shift:integer;
begin
  for i:=0 to 32*32*2-1 do
  begin
    for j:=0 to 11 do
      pIndices[i*12+j]:=fixarray[j]+i*6;
  end;
end;

constructor TFoliage.Create(dev:Idirect3ddevice9;texnam:string;ahscale,avscale,avpls:single;ashape:string);
var
  pIndices:PWordArray;
  i:integer;
begin
  inherited Create;
  betoltve:=false;
  g_pD3Ddevice:=dev;

  if ashape='bush' then shape:=defaultShape
  else if ashape='grass' then shape:=grassShape
  else shape:=defaultShape;

  vertexnum:=32*32*shape.vertexnum;
  indexnum:=32*32*shape.indexnum;

  //g_pd3ddevice.CreateVertexDeclaration(@(declarr[0]),vertdecl);


  if FAILED(g_pd3dDevice.CreateVertexBuffer(sizeof(TFoliageVertex)*vertexnum,
    D3DUSAGE_WRITEONLY+D3DUSAGE_DYNAMIC,D3DFVF_bokorvertex,
    D3DPOOL_DEFAULT,g_pVB,nil))
    then Exit;

  if FAILED(g_pd3dDevice.CreateIndexBuffer(4*indexnum,
    D3DUSAGE_WRITEONLY,D3DFMT_INDEX16,
    D3DPOOL_DEFAULT,g_pIB,nil))

  then Exit;

  if FAILED(g_pIB.Lock(0,4*indexnum,Pointer(pindices),0))
    then Exit;

  shape.indexgen(pindices);

  g_pIB.unlock;

  if not LTFF(g_pd3dDevice,'data\'+texnam,g_ptexture) then
    Exit;
  addfiletochecksum('data\'+texnam);

  hscale:=ahscale;
  vscale:=avscale;
  vpls:=avpls;
  betoltve:=true;
end;

procedure TFoliage.Init(g_peff:ID3DXEffect;shader:boolean);
var
  tmplw:longword;
begin
  g_peffect:=g_peff;

  if csicsahdr then //bocccs
  begin
    g_peffect.SetTechnique('Foliage');
    g_pEffect.SetTexture('g_MeshTexture',g_ptexture);
    g_pEffect.SetTexture('g_Terrain', mt1);
    g_pEffect.SetTexture('g_Building', mt2);
    //g_pEffect.SetTexture('g_MeshHeightmap', g_pnormal);
//    g_pEffect.SetFloat('specHardness',10);
//    g_pEffect.SetFloat('specIntensity',0.6);
//    g_pEffect.SetBool('upsidedown',shape.upsidedown);
    g_peffect._Begin(@tmplw,0);
    g_peffect.BeginPass(0);
  end
  else
  begin
    g_pD3Ddevice.SetTexture(0,g_ptexture);

  end;


  g_pd3ddevice.SetRenderState(D3DRS_ALPHAREF,$AF);
  g_pd3ddevice.SetRenderState(D3DRS_ALPHATESTENABLE,iTRUE);
  g_pd3ddevice.SetRenderState(D3DRS_Lighting,iFALSE);
  g_pd3ddevice.SetRenderState(D3DRS_ALPHAFUNC,D3DCMP_GREATEREQUAL);
  g_pd3ddevice.SetRenderState(D3DRS_CULLMODE,D3DCULL_NONE);


  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,  FAKE_HDR);
//  g_pd3dDevice.SetTextureStageState(0,D3DTSS_COLOROP,D3DTOP_SELECTARG1);
  g_pd3dDevice.SetTextureStageState(0,D3DTSS_ALPHAOP,D3DTOP_MODULATE);

  g_pd3dDevice.SetTextureStageState(0, D3DTSS_CONSTANT, D3DCOLOR_ARGB(255,220,220,220));
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_CONSTANT);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_TEXTURE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_DIFFUSE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_TEXTURE);


//  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);
////
//  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1,  D3DTA_TEXTURE);
//  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2,  D3DTA_DIFFUSE );
////
//  g_pd3dDevice.SetRenderState(D3DRS_TEXTUREFACTOR,$FF0000FF);

//  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,  D3DTOP_SELECTARG2);
end;


procedure TFoliage.Render;
begin

  g_pd3dDevice.SetStreamSource(0,g_pVB,0,SizeOf(TFoliageVertex));
  g_pd3dDevice.SetIndices(g_pIB);
  g_pd3dDevice.SetFVF(D3DFVF_bokorvertex);

  g_pd3dDevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST,0,0,32*32*shape.vertexnum,0,32*32*shape.indexnum);

  if g_peffect<>nil then
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
  i,j,k:integer;
  pVertices:PFoliageVertexArray;
  vec:TD3DXVector3;
  pls,rot,sinv,cosv,rescale:single;
  n:TD3DXVector3;
  cached:integer;
  tmp:single;
//  sw : TStopWatch;
  tpos:TD3DXVector3;
begin
//  pls:=lvl[0].position.z-lvl[1].position.z; //meg a faszt
//pls:=((Random(1000))/1000)*pow2i[level];
pls:=pow2i[level];
//  pls:=pls;
  //jeah;
  g_pVB.lock(0,sizeof(TFoliageVertex)*vertexnum,pointer(pvertices),D3DLOCK_DISCARD);

  shape.vertexgen(pvertices);// itt betessz�k az alap poz�ci�kat meg UV-t


//    sw := TStopWatch.Create() ;
//    sw.Start;

  for i:=0 to 31 do
    for j:=0 to 31 do
    begin
      cached:=-1;
      vec:=lvl[i*32+j].position;

      for k:=0 to (high(icache) div 2) do
        if vec.x=icache[2*k] then //ide ak�r mehetne egy nagyon egyszer� hash
          if vec.z=icache[2*k+1] then
          begin
            cached:=2*k;
            break;
          end;

//          cached:=-1; //TODO
      if cached<0 then
      begin
        inc(lastc,2);
        if lastc>high(icache) then //p�ros hossz
          lastc:=low(icache);

        icache[lastc]:=vec.x;
        icache[lastc+1]:=vec.z;

//        d3dxvec3add(vec,vec,D3DXVector3(perlin.Noise(vec.x,0.5,vec.z)*pls,0,perlin.Noise(vec.x,1.5,vec.z)*pls));
        d3dxvec3add(vec,vec,D3DXVector3(perlin.Noise(vec.x,0.5,vec.z)*pls,0,perlin.Noise(vec.x,1.5,vec.z)*pls));

        if level<=2 then // ha bokor akkor �jrasz�mol�dik
        n:=lvl[i*32+j].normal;
//        n:=d3dxvector3(0,1,0);

        yandnorm(vec.x,vec.y,vec.z,n,1);

//        if (n.y>1)or(vec.y<15.7) then
//          vec:=D3DXVector3Zero;

        rot:=perlin.Noise(vec.x,0.5,vec.z);
        sinv:=sin(rot);
        cosv:=cos(rot);

        rescale:=1;
        if (vec.y<(grasslevel)) then
        begin
          vec:=D3DXVector3Zero;
          rescale:=0;
        end;


//        n.y:=1;
        
        if (n.y<0.86) then
        begin
          vec:=D3DXVector3Zero;
          rescale:=0;
        end;

        if level >2 then
        rescale:=rescale*(0.8+frac(abs(perlin.Noise(vec.x,1,vec.z))*456)*0.4); //0.8 +0.4 random
        


        for k:=0 to shape.vertexnum-1 do
          with pvertices[k+shape.vertexnum*(j+32*i)] do
          begin
            tpos:=position;

            tpos.x:=cosv*tpos.x-sinv*tpos.z;
            tpos.z:=sinv*tpos.x+cosv*tpos.z;

            if level >2 then
            begin
              if tpos.y<0.5 then
                tpos.y:=tpos.y-((n.x)*tpos.x)-((n.z)*tpos.z)-0.2*(abs(n.x)+abs(n.z)) //ne �gaskodj
              else
              begin
                tpos.x:=tpos.x+0.3*n.x;
                tpos.z:=tpos.z+0.3*n.z;
              end;

            end
            else
              tpos.y:=tpos.y-(n.x*tpos.x)-(n.z*tpos.z); //terephez d�nt�s

            tpos.x:=tpos.x*rescale*hscale+vec.x;
            tpos.z:=tpos.z*rescale*hscale+vec.z;
            tpos.y:=tpos.y*rescale*vscale+vec.y+rescale*vpls;

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
            cache[shape.vertexnum*lastc+k]:=tpos;
          end;

      end
      else
      begin
        for k:=0 to shape.vertexnum-1 do
          with pvertices[k+shape.vertexnum*(j+32*i)] do
          begin
//            normal.x:=cache[shape.vertexnum*cached].x;
//            position:=cache[shape.vertexnum*cached+k+1];
            position:=cache[shape.vertexnum*cached+k];
          end;
      end;


//              if useoldterrain then
//              for k:=0 to shape.vertexnum-1 do
//          with pvertices[k+shape.vertexnum*(j+32*i)] do
//          begin
//            normal:=d3dxvector3(0,1,0);
//          end;

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
  if g_pd3ddevice<>nil then
    g_pD3Ddevice:=nil;
  inherited Destroy;
end;


end.

