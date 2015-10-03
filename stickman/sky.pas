unit sky;

interface

uses
  sysutils,math,typestuff,Direct3D9,D3DX9,windows;

type

  TFelhoVertex=record
    pos:TD3DXVector3;
    col:cardinal;
    u1,v1:single;
    u2,v2:single;
  end;
  PFelhoVertexarr=^Tfelhovertexarr;
  Tfelhovertexarr=array[0..10000] of TFelhoVertex;


  T127AccStruct=record
    lt2:single;
    deltaX,deltaY,deltaZ,deltaY2:single;
    pls,pls2,plsa,pls2a:single;
    stepx,stepz,stepx2,stepz2:integer;
    steps:integer;
    mny:integer;
  end;

  Tsundata=record
    lt:array[0..127,0..127] of T127Accstruct;
  end;

  TFelho=class(TObject)
    sun:Tsundata;
    hol:single;
    swaptim:integer;//0..127
    pluszind:integer;
    fseb:single;
    col:TD3DXColor;
    sky_ambientval:integer;
    villam1,villam2:boolean;
    tex1,tex2,texsysmem:IDirect3DTexture9;
    g_pVB:IDirect3DVertexBuffer9;
    g_pIB:IDirect3DIndexBuffer9;
    g_pd3ddevice:IDirect3DDevice9;
    at:array[0..31,0..31] of single;
    a1:array[0..255,0..255] of single;// alpha
    a2:array[0..127,0..127] of single;// color
    colormap:array[0..255,0..255,0..3] of byte;
    coverage:byte;
    procedure makenew;
    constructor Create(A_D3DDevice:IDirect3DDevice9;sky_ambi:integer;cloud_spd:single;color:longword);
    procedure Render(alulis:boolean);
    procedure Update;
    procedure villamolj;
  private
    mat:TD3DMatrix;
    procedure copytotex;
    procedure gennew;
    procedure genlght(i:integer);
    procedure genvillam(i:integer);
    procedure makesun(sx,sy,sz:single);
  end;
var
  sky_voros:boolean;
implementation


const
  D3DFVF_FELHOVERTEX=(D3DFVF_XYZ or D3DFVF_DIFFUSE or D3DFVF_TEX2);
  skyfelbontas=50;
  pow2:array[0..8] of single=(1,2,4,8,16,32,64,128,256);
  invpow2:array[0..8] of single=(1,1/2,1/4,1/8,1/16,1/32,1/64,1/128,1/256);
  divpow2:array[0..7] of integer=(128,64,32,16,8,4,2,1);

  //fseb=0.0005;

function phase(mi1,mi2:TD3DXVector3):single;
begin
  result:=(1+sqr(d3dxvec3dot(mi1,mi2))/(d3dxvec3lengthsq(mi2)*d3dxvec3lengthsq(mi1)));
  // result:=1;
end;


procedure TFelho.makenew;
var
  i:integer;
begin
  try
    gennew;
    pluszind:=0;
    for i:=0 to 127 do
      genlght(i);
    swaptim:=0;
    copytotex;
  except end;
end;

procedure TFelho.copytotex;
var
  tmp:IDirect3DTexture9;
  lr:TD3DLockedRect;
  pbits:PDWORD;
  i:integer;
begin
  tmp:=tex1;
  tex1:=tex2;
  tex2:=tmp;
  tmp:=nil;

  if Failed(texsysmem.LockRect(0,lr,nil,0)) then Exit;
  for i:=0 to 255 do
  begin
    pBits:=PDWORD(Integer(lr.pBits)+i*lr.Pitch);
    copymemory(pbits,addr(colormap[i]),256*4);
  end;
  texsysmem.UnlockRect(0);

  g_pd3ddevice.UpdateTexture(texsysmem,tex2);
end;

procedure Tfelho.villamolj;
begin
  villam1:=true;
end;

constructor TFelho.Create(A_D3DDevice:IDirect3DDevice9;sky_ambi:integer;cloud_spd:single;color:longword);
var
  i,j,k:integer;
  pindices:PWORDArray;
  pVertices:Pfelhovertexarr;
  szog,ax,az:single;
  ai:single;
  ac:cardinal;
begin
  write(logfile,'Creating sky...');flush(logfile);

  hol:=0;
  villam1:=false;
  villam2:=false;
  sky_ambientval:=sky_ambi;
  fseb:=cloud_spd;
  pluszind:=0;
  swaptim:=0;
  coverage:=13;
  col:=D3DXColorFromDWord(color);

  zeromemory(@at,sizeof(at));
  zeromemory(@a1,sizeof(a1));
  zeromemory(@a2,sizeof(a1));
  zeromemory(@colormap,sizeof(colormap));
  zeromemory(@sun,sizeof(sun));

  g_pd3ddevice:=a_d3ddevice;
  if Failed(g_pd3dDevice.CreateTexture(256,256,1,0,D3DFMT_A8R8G8B8,D3DPOOL_DEFAULT,tex1,nil)) then Exit;
  if Failed(g_pd3dDevice.CreateTexture(256,256,1,0,D3DFMT_A8R8G8B8,D3DPOOL_DEFAULT,tex2,nil)) then Exit;
  if Failed(g_pd3dDevice.CreateTexture(256,256,1,0,D3DFMT_A8R8G8B8,D3DPOOL_SYSTEMMEM,texsysmem,nil)) then Exit;

  if FAILED(g_pd3dDevice.CreateVertexBuffer((sqr(skyfelbontas)+3*skyfelbontas)*sizeof(TFelhoVertex),
    D3DUSAGE_WRITEONLY,D3DFVF_FELHOVERTEX,
    D3DPOOL_DEFAULT,g_pVB,nil))
    then Exit;

  if FAILED(g_pd3dDevice.CreateIndexBuffer((sqr(skyfelbontas-1)*6+2*6*skyfelbontas)*2,
    D3DUSAGE_WRITEONLY,D3DFMT_INDEX16,
    D3DPOOL_DEFAULT,g_pIB,nil))
    then Exit;

  if FAILED(g_pIB.Lock(0,sqr(skyfelbontas-1)*6*2,Pointer(pindices),0)) //D3DLOCK_DISCARD
    then Exit;

  if FAILED(g_pVB.Lock(0,sqr(skyfelbontas)*sizeof(TFelhoVertex),Pointer(pVertices),0)) //D3DLOCK_DISCARD
    then Exit;

  write(logfile,'buffers...');flush(logfile);
  for i:=0 to skyfelbontas-1 do
    for j:=0 to skyfelbontas-1 do
      with pVertices[i*skyfelbontas+j] do
      begin
        pos:=D3DXVector3((i-skyfelbontas/2)*4800/skyfelbontas,0,(j-skyfelbontas/2)*4800/skyfelbontas);
        pos.y:=(1-sqr(pos.x/800)-sqr(pos.z/800))*60-20;
        u1:=i/(skyfelbontas-1);
        v1:=j/(skyfelbontas-1);
        u2:=i/(skyfelbontas-1);
        v2:=j/(skyfelbontas-1);
        col:=$FFFFFF;
      end;

  for i:=0 to skyfelbontas-2 do
    for j:=0 to skyfelbontas-2 do
    begin
      k:=(i*(skyfelbontas-1)+j)*6;
      pIndices[k+1]:=i*skyfelbontas+j;
      pIndices[k+0]:=i*skyfelbontas+j+1;
      pIndices[k+2]:=(i+1)*skyfelbontas+j;

      pIndices[k+4]:=i*skyfelbontas+j+1;
      pIndices[k+3]:=(i+1)*skyfelbontas+j+1;
      pIndices[k+5]:=(i+1)*skyfelbontas+j;
    end;
  { g_pIB.unlock;
   g_pVB.unlock;


   if FAILED(g_pIB.Lock(sqr(skyfelbontas-1)*6*2,skyfelbontas*2*6*2, Pointer(pindices), D3DLOCK_NOOVERWRITE))
   then Exit;

   if FAILED(g_pVB.Lock(sqr(skyfelbontas)*sizeof(TFelhoVertex),(skyfelbontas*3)*sizeof(TFelhoVertex), Pointer(pVertices), D3DLOCK_NOOVERWRITE))
   then Exit;}

  write(logfile,'more buffers...');flush(logfile);
  ai:=0;
  ac:=$FFFFFFCC;
  for i:=0 to 2 do
  begin
    case i of
      0:ai:=0;
      1:ai:=0.5;
      2:ai:=3;
    end;

    case i of
      2:ac:=$FFFFCC;
      0,1:ac:=$FFFFFFCC;
    end;

    for j:=0 to skyfelbontas-1 do
      with pVertices[i*skyfelbontas+j+skyfelbontas*skyfelbontas] do
      begin
        szog:=(j/skyfelbontas)*2*D3DX_PI;
        ax:=sin(szog);
        az:=cos(szog);


        pos:=D3DXVector3((ax*ai-2.0-ai/2)*2400/skyfelbontas,0,(az*ai)*2400/skyfelbontas);

        //pos:=D3DXVector3((i*5+10-skyfelbontas/2)*2400/skyfelbontas,0,(j-skyfelbontas/2)*2400/skyfelbontas);

        pos.y:=(1-sqr(pos.x/800)-sqr(pos.z/800))*120-30-(-ax+1)*ai*5;

        u1:=(ax*i-2.15)/(skyfelbontas-1)+0.5;
        v1:=(az*i)/(skyfelbontas-1)+0.5;
        u2:=u1;
        v2:=v1;
        col:=ac;
      end;

  end;
  for i:=0 to 1 do
    for j:=0 to skyfelbontas-1 do
    begin
      k:=(i*(skyfelbontas)+j+sqr(skyfelbontas-1))*6;
      pIndices[k+1]:=i*skyfelbontas+j;
      pIndices[k+0]:=i*skyfelbontas+(j+1)mod skyfelbontas;
      pIndices[k+2]:=(i+1)*skyfelbontas+j;

      pIndices[k+3]:=i*skyfelbontas+(j+1)mod skyfelbontas;
      pIndices[k+4]:=(i+1)*skyfelbontas+(j+1)mod skyfelbontas;
      pIndices[k+5]:=(i+1)*skyfelbontas+j;
    end;

  g_pIB.unlock;
  g_pVB.unlock;

  try
    write(logfile,'lighting...');flush(logfile);
    //NEHOGY ezt megváltoztasd.
    makesun(0,200,0);
    write(logfile,'alpha...');flush(logfile);
    makenew;
    write(logfile,'texture...');flush(logfile);
    copytotex;
    pluszind:=0;
    swaptim:=0;
    writeln(logfile,'done.');flush(logfile);
  except
    on E:Exception do
    begin
      writeln(logfile,'Error:',E.Message,'---ignoring...');flush(logfile);
    end;
  end;
end;

procedure TFelho.Update;
var
  i:integer;
begin
  laststate:='Weather.Update';
  inc(swaptim);
  if swaptim>127 then
  begin
    villam2:=villam1;
    villam1:=false;
    if villam2 then
      for i:=0 to 127 do
        genvillam(i);

    copytotex;
    swaptim:=0;
    pluszind:=round((hol+fseb*50)*255)+3;
  end;

  genlght(swaptim);

  hol:=hol+fseb;
  if hol>=1 then hol:=hol-1;
  mat._11:=1.00;mat._12:=0.00;mat._13:=0.00;mat._14:=0.00;
  mat._21:=0.00;mat._22:=1.00;mat._23:=0.00;mat._24:=0.00;
  mat._31:=0.00;mat._32:=hol;mat._33:=1.00;mat._34:=0.00;
  mat._41:=0.00;mat._42:=0.00;mat._43:=0.00;mat._44:=1.00;
end;


procedure TFelho.Render(alulis:boolean);
const
  forditvamat:TD3DMatrix=(_11:1;_22:-1;_33:1;_44:1);
var
  plan:TD3DXPlane;
  tmplw:cardinal;
begin
  laststate:='RenderWeather';
  g_pd3ddevice.SetStreamSource(0,g_pVB,0,sizeof(TFelhoVertex));
  g_pd3ddevice.SetIndices(g_pIB);

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,  D3DTOP_MODULATE );
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP,FAKE_HDR   );

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(2, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(2, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
    g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);

    g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
    g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,D3DBLEND_INVSRCALPHA );
    g_pd3ddevice.SetRenderState(D3DRS_BLENDOP,D3DBLENDOP_ADD);

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);

  g_pd3ddevice.SetTexture(0,tex1);
  g_pd3ddevice.SetTexture(1,tex2);
  //g_pd3ddevice.SetTexture(2,texdet);
  g_pd3ddevice.SetFVF(D3DFVF_FELHOVERTEX);

  g_pd3dDevice.SetTextureStageState(0,D3DTSS_ALPHAOP,D3DTOP_SELECTARG1);
  g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE,itrue);
  // g_pd3ddevice.SetRenderState(D3DRS_CULLMODE,D3DCULL_NONE);

  g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,D3DBLEND_INVSRCALPHA);
  g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,D3DBLEND_SRCALPHA);
  g_pd3ddevice.SetRenderState(D3DRS_BLENDOP,D3DBLENDOP_ADD);

 if villam2 then
  g_pd3ddevice.SetRenderState(D3DRS_TEXTUREFACTOR,0)
 else
  g_pd3ddevice.SetRenderState(D3DRS_TEXTUREFACTOR,swaptim*$02020202);


  if villam2 then
    cloudblend:=0
  else
    cloudblend:=swaptim/127;



  g_pd3dDevice.SetTextureStageState(0,D3DTSS_COLOROP,D3DTOP_SELECTARG1);
  g_pd3dDevice.SetTextureStageState(1,D3DTSS_COLOROP,D3DTOP_LERP);
  g_pd3dDevice.SetTextureStageState(1,D3DTSS_COLORARG0,D3DTA_TFACTOR);
  g_pd3dDevice.SetTextureStageState(1,D3DTSS_COLORARG1,D3DTA_TEXTURE);
  g_pd3dDevice.SetTextureStageState(1,D3DTSS_COLORARG2,D3DTA_CURRENT);


//  g_pd3dDevice.SetTextureStageState(2,D3DTSS_COLORARG1,D3DTA_CURRENT);
//  g_pd3dDevice.SetTextureStageState(2,D3DTSS_COLORARG2,D3DTA_DIFFUSE);

  g_pd3dDevice.SetTextureStageState(0,D3DTSS_ALPHAOP,D3DTOP_SELECTARG1);
  g_pd3dDevice.SetTextureStageState(1,D3DTSS_ALPHAOP,D3DTOP_LERP);
  g_pd3dDevice.SetTextureStageState(1,D3DTSS_ALPHAARG0,D3DTA_TFACTOR);
  g_pd3dDevice.SetTextureStageState(1,D3DTSS_ALPHAARG1,D3DTA_TEXTURE);
  g_pd3dDevice.SetTextureStageState(1,D3DTSS_ALPHAARG2,D3DTA_CURRENT);

  g_pd3dDevice.SetTextureStageState(2,D3DTSS_COLOROP,D3DTOP_DISABLE);
  g_pd3dDevice.SetTextureStageState(2,D3DTSS_ALPHAOP,D3DTOP_DISABLE);

  g_pd3dDevice.SetRenderState(D3DRS_ZWRITEENABLE,ifALSe);
  // g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, itrue);

  g_pd3dDevice.SetTransform(D3DTS_TEXTURE0,mat);
  g_pd3dDevice.SetTextureStageState(0,D3DTSS_TEXTURETRANSFORMFLAGS,D3DTTFF_COUNT2);
  g_pd3dDevice.SetTransform(D3DTS_TEXTURE1,mat);
  g_pd3dDevice.SetTextureStageState(1,D3DTSS_TEXTURETRANSFORMFLAGS,D3DTTFF_COUNT2);

  if alulis then
  begin
    // g_pd3dDevice.SetRenderState(D3DRS_ZWRITEENABLE, itrue);
    plan:=D3DXPlane(0,-1,0,0);

    g_pd3ddevice.SetTransform(D3DTS_WORLD,forditvamat);
    g_pd3ddevice.SetClipPlane(0,pointer(@plan));
    g_pd3ddevice.SetRenderstate(D3DRS_CLIPPLANEENABLE,1);

    if csicsahdr then
    begin
      g_peffect.SetTechnique('Cloud');
//      g_peffect.SetMatrix('flip',forditvamat);
      g_pEffect.SetTexture('g_Cloud1',tex1);
      g_pEffect.SetTexture('g_Cloud2',tex2);
      g_peffect.SetFloat('HDRszorzo',shaderhdr);
      g_peffect.SetFloat('cloudblend',cloudblend);
      g_peffect.SetBool('rays',false);



      g_peffect._Begin(@tmplw,0);
      g_peffect.BeginPass(0);
      g_pd3ddevice.drawindexedprimitive(D3DPT_TRIANGLELIST,0,0,sqr(skyfelbontas),0,sqr(skyfelbontas-1)*2);

    end
    else
    begin
     
      g_pd3ddevice.drawindexedprimitive(D3DPT_TRIANGLELIST,0,0,sqr(skyfelbontas),0,sqr(skyfelbontas-1)*2);
    end;




    // g_pd3dDevice.SetRenderState(D3DRS_ZWRITEENABLE, ifALSe);
    g_pd3ddevice.SetTransform(D3DTS_WORLD,identmatr);
    plan.b:=1;
    plan.d:=0;
    g_pd3ddevice.SetClipPlane(0,pointer(@plan));
    if csicsahdr then
    begin
      g_peffect.SetMatrix('flip',identmatr);
      g_pd3ddevice.drawindexedprimitive(D3DPT_TRIANGLELIST,0,0,sqr(skyfelbontas),0,sqr(skyfelbontas-1)*2);
      g_peffect.Endpass;
      g_peffect._end;

    end
    else
    begin
      g_pd3ddevice.drawindexedprimitive(D3DPT_TRIANGLELIST,0,0,sqr(skyfelbontas),0,sqr(skyfelbontas-1)*2);
    end;
    g_pd3ddevice.SetRenderstate(D3DRS_CLIPPLANEENABLE,0);
  end
  else
  begin

    g_pd3ddevice.SetTransform(D3DTS_WORLD,identmatr);
    if csicsahdr then
    begin
      g_peffect.SetTechnique('Cloud');
 //     g_peffect.SetMatrix('flip',identmatr);
      g_pEffect.SetTexture('g_Cloud1',tex1);
      g_pEffect.SetTexture('g_Cloud2',tex2);
      g_peffect.SetFloat('HDRszorzo',shaderhdr);
      g_peffect.SetFloat('cloudblend',cloudblend);
      g_peffect.SetBool('rays',false);


      g_peffect._Begin(@tmplw,0);
      g_peffect.BeginPass(0);
      g_pd3ddevice.drawindexedprimitive(D3DPT_TRIANGLELIST,0,0,sqr(skyfelbontas),0,sqr(skyfelbontas-1)*2);
      g_peffect.Endpass;
      g_peffect._end;

    end
    else
    begin

      g_pd3ddevice.drawindexedprimitive(D3DPT_TRIANGLELIST,0,0,sqr(skyfelbontas),0,sqr(skyfelbontas-1)*2);
    end;
  end;


  g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,D3DBLEND_SRCALPHA);
  g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,D3DBLEND_INVSRCALPHA);
  g_pd3ddevice.SetRenderState(D3DRS_BLENDOP,D3DBLENDOP_ADD);

  g_pd3dDevice.SetTextureStageState(2,D3DTSS_ALPHAARG1,D3DTA_DIFFUSE);
  g_pd3dDevice.SetTextureStageState(2,D3DTSS_ALPHAARG2,D3DTA_CURRENT);
  g_pd3dDevice.SetTextureStageState(2,D3DTSS_ALPHAOP,D3DTOP_MODULATE);

  g_pd3dDevice.SetTextureStageState(2,D3DTSS_COLOROP,D3DTOP_ADD);
  g_pd3dDevice.SetTextureStageState(2,D3DTSS_COLORARG1,D3DTA_DIFFUSE);
  g_pd3dDevice.SetTextureStageState(2,D3DTSS_COLORARG2,D3DTA_DIFFUSE);


  if csicsahdr then
  begin

    g_peffect.SetTechnique('Cloud');
//    g_peffect.SetMatrix('flip',identmatr);
    g_pEffect.SetTexture('g_Cloud1',tex1);
    g_pEffect.SetTexture('g_Cloud2',tex2);
    g_peffect.SetFloat('HDRszorzo',shaderhdr);
    g_peffect.SetFloat('cloudblend',cloudblend);
    g_peffect.SetBool('rays',true);

    g_peffect._Begin(@tmplw,0);
    g_peffect.BeginPass(0);
    g_pd3ddevice.drawindexedprimitive(D3DPT_TRIANGLELIST,sqr(skyfelbontas),0,+skyfelbontas*3,sqr(skyfelbontas-1)*6,skyfelbontas*4);
    g_peffect.Endpass;
    g_peffect._end;
  end
  else
  begin
    g_pd3ddevice.drawindexedprimitive(D3DPT_TRIANGLELIST,sqr(skyfelbontas),0,+skyfelbontas*3,sqr(skyfelbontas-1)*6,skyfelbontas*4);
  end;


  g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE,ifalse);
  g_pd3dDevice.SetTextureStageState(0,D3DTSS_TEXTURETRANSFORMFLAGS,D3DTTFF_DISABLE);
  g_pd3dDevice.SetTextureStageState(1,D3DTSS_TEXTURETRANSFORMFLAGS,D3DTTFF_DISABLE);
  g_pd3dDevice.SetTextureStageState(1,D3DTSS_ALPHAOP,D3DTOP_DISABLE);
  g_pd3dDevice.SetTextureStageState(1,D3DTSS_COLOROP,D3DTOP_DISABLE);
  g_pd3dDevice.SetTextureStageState(2,D3DTSS_COLOROP,D3DTOP_DISABLE);
  g_pd3dDevice.SetTextureStageState(2,D3DTSS_ALPHAOP,D3DTOP_DISABLE);
end;


procedure TFelho.makesun(sx,sy,sz:single);
var
  i,j:integer;
  angl,angw:TD3DXVector3;
  naphol,tmp:TD3DXVector3;
begin
  laststate:='Weather.Makesun';
  with sun do
  begin
    naphol:=D3DXVector3(sx,sy,sz);
    d3dxvec3normalize(angl,naphol);
    // d3dxvec3scale(naphol,angl,100);

    for i:=0 to 127 do
      for j:=0 to 127 do
        with lt[i,j] do
        begin
          angw:=D3DXVector3(i-64,30,j-64);

          d3dxvec3subtract(tmp,naphol,angw);
          lt2:=phase(angl,angw)*100;
          if tmp.x>0 then stepx:=1 else
            if tmp.x<0 then stepx:=-1 else
              stepx:=0;

          if tmp.z>0 then stepz:=1 else
            if tmp.z<0 then stepz:=-1 else
              stepz:=0;

          deltaX:=abs(tmp.z);deltaZ:=abs(tmp.x);

          if deltax+deltaz>0 then
            deltaY:=tmp.y/(deltax+deltaz)
          else
            deltaY:=100;
          steps:=10;
          //min(round(deltax+deltaz),32);
          if abs(tmp.x)+abs(tmp.z)>0.001 then
            d3dxvec3scale(tmp,tmp,1/(abs(tmp.x)+abs(tmp.z)));

          pls:=d3dxvec3length(tmp);

          if abs(deltaY)>0.0001 then
            pls2:=-pls/deltaY
          else
            pls2:=pls;
          deltay2:=deltay*2;
          stepx2:=stepx*2;
          stepz2:=stepz*2;
          plsa:=pls*2;
          pls2a:=pls2;

        end;
  end;
end;



procedure TFelho.gennew;
  procedure Smooth(var s:Single);
  begin
    s:=s*s*(3-2*s);
  end;
var
  i,j,k:integer;
  rnd:integer;
  x1,x2,y1,y2:integer;
  xf,yf:single;
  tmp:single;
  tmp2:single;
  tmp3:single;
  andmivel:integer;
  //t1,t2:array[0..255,0..255] of single;
  {const
  MAGIC=13.5134073; }
begin
  laststate:='Weather.Gennew';
  rnd:=random(300);
  for i:=0 to 31 do
    for j:=0 to 31 do
      at[i,j]:=perlin.qnoise(i+1,j+1,rnd+5)*0.5+0.5;

  for i:=0 to 255 do
    for j:=0 to 255 do
    begin
      {t1[i,j]:=0;
      t2[i,j]:=0;  }
      tmp2:=0;

      // egyébként azért, hogy minden pixel egyedi legyen.
      for k:=0 to 5 do
      begin
        andmivel:=min(31,divpow2[k]-1);
        tmp:=i*invpow2[k];
        x1:=floor(tmp);
        x2:=x1+1;
        xf:=tmp-x1;
        smooth(xf);
        x1:=x1 and andmivel;
        x2:=x2 and andmivel;

        tmp:=j*invpow2[k];
        y1:=floor(tmp);
        y2:=y1+1;
        yf:=tmp-y1;
        smooth(yf);
        y1:=y1 and andmivel;
        y2:=y2 and andmivel;

        tmp3:=lerp(lerp(at[x1,y1],at[x2,y1],xf),
          lerp(at[x1,y2],at[x2,y2],xf),yf)*pow2[k];
        // if k<=5 then
        tmp2:=tmp2+tmp3;
        { if (k=4) or (k=5) then t1[i,j]:=t1[i,j]+tmp3;
         t2[i,j]:=t2[i,j]+tmp3;   }
      end;
      {t1[i,j]:=t1[i,j]-coverage*1.5;
      t2[i,j]:=t2[i,j]/16;  }
      if not sky_voros then
        a1[i,j]:=max(tmp2/2-coverage,0)
      else
        a1[i,j]:=max(tmp2/2-4,0);
      //a1[i,j]:=20;
    end;


  for j:=0 to 255 do
    for k:=0 to 255 do
    begin
      colormap[j,k,3]:=round(power(0.95,a1[j,k]*16)*255);
    end;//}
end;
//hja, ezt kell forozni

procedure TFelho.genlght(i:integer);

//loop {
//if(tMaxX < tMaxY) {
//tMaxX= tMaxX + tDeltaX;
//X= X + stepX;
//} else {
//tMaxY= tMaxY + tDeltaY;
//Y= Y + stepY;
//}
//NextVoxel(X,Y);
//}

var
  j,k:integer;
  mst:double;
  ppi:integer;
  maxX,maxY,maxZ,tmp:double;
  tmp2:double;
  xi,yi:integer;
  bol:boolean;
begin
  try
    laststate:='Weather.Genlght '+inttostr(i);
    ppi:=pluszind shr 1;
    // pi:=0;
    // with sun do
     //for i:=0 to 127 do
    for j:=0 to 127 do
      with sun.lt[(i-ppi)and 127,j] do
      begin

        maxX:=deltaX;
        maxZ:=deltaZ;

        xi:=i;
        yi:=j;
        MaxY:=-a1[i,j];
        mst:=0;
        bol:=true;

        //ELSÕ FÁZIS
        for k:=1 to steps do
        begin
          MaxY:=MaxY+deltaY;
          if maxX<maxz then
          begin
            maxX:=maxX+deltaX;
            inc(xi,stepx);
            xi:=xi and 127;
          end else
          begin
            maxZ:=maxZ+deltaZ;
            inc(yi,stepz);
            yi:=yi and 127;
          end;
          tmp:=abs(MaxY);
          if tmp<a1[xi*2,yi*2] then
          begin
            bol:=true;
            mst:=mst+pls;
          end
          else
            if bol then
            begin
              bol:=false;//pls/DeltaY
              mst:=mst+pls-(a1[xi*2,yi*2]-tmp)*pls2;
            end;
        end;

        //MÁSODIK FÁZIS
        for k:=1 to steps do
        begin
          MaxY:=MaxY+deltaY2;
          if maxX<maxz then
          begin
            maxX:=maxX+deltaX;
            inc(xi,stepx2);
            xi:=xi and 127;
          end else
          begin
            maxZ:=maxZ+deltaZ;
            inc(yi,stepz2);
            yi:=yi and 127;
          end;
          tmp:=abs(MaxY);
          if tmp<a1[xi*2,yi*2] then
          begin
            bol:=true;
            mst:=mst+plsa;
          end
          else
            if bol then
            begin
              bol:=false;//pls/DeltaY
              mst:=mst+plsa-(a1[xi*2,yi*2]-tmp)*pls2a;
            end;
        end;
        //mst:=0;
       // lt2:=1;
        if mst<0 then mst:=0;
        if mst>100000 then mst:=0;
        if abs(lt2)>50000 then lt2:=0;

        a2[i,j]:=min(lt2*power(0.95,mst)+sky_ambientval,255);

      end;


    if swaptim=0 then
    felhoszin2:=felhoszin1;
    if swaptim=0 then
    felhoszin1:=0;

    for j:=0 to 127 do
    begin
      tmp2:=a2[i,j];
      colormap[i*2,j*2,0]:=round(tmp2*col.B);//round(lerp(255,tmp2,tmp)) itt van a szine a felhonek!!!;
      colormap[i*2,j*2,1]:=round(tmp2*col.G);//round(lerp(150,tmp2,tmp));
      colormap[i*2,j*2,2]:=round(tmp2*col.R);//round(lerp(0,tmp2,tmp));

      if swaptim=0 then
      felhoszin1:=felhoszin1+round(tmp2*col.B);
    end;

    if swaptim=0 then
    felhoszin1:=clip(0,1,felhoszin1/127/255);

    for j:=0 to 126 do
      for k:=0 to 2 do
        colormap[i*2,j*2+1,k]:=(colormap[i*2,j*2,k]+colormap[i*2,j*2+2,k])shr 1;
    for k:=0 to 2 do
      colormap[i*2,127*2+1,k]:=(colormap[i*2,127*2,k]+colormap[i*2,0,k])shr 1;

    if i>0 then
      for j:=0 to 255 do
        for k:=0 to 2 do
          colormap[i*2-1,j,k]:=(colormap[i*2,j,k]+colormap[i*2-2,j,k])shr 1
    else
      for j:=0 to 255 do
        for k:=0 to 2 do
          colormap[255,j,k]:=(colormap[0,j,k]);

  except end;
end;

procedure TFelho.genvillam(i:integer);
var
  j,k:integer;
begin
  laststate:='Weather.Genvillam';
  for j:=0 to 127 do
    for k:=0 to 2 do
    begin
      colormap[i*2,j*2,k]:=255;
      colormap[i*2+1,j*2,k]:=255;
      colormap[i*2,j*2+1,k]:=255;
      colormap[i*2+1,j*2+1,k]:=255;
    end;

  for j:=0 to 126 do
    for k:=0 to 2 do
      colormap[i*2,j*2+1,k]:=(colormap[i*2,j*2,k]+colormap[i*2,j*2+2,k])shr 1;
  for k:=0 to 2 do
    colormap[i*2,127*2+1,k]:=(colormap[i*2,127*2,k]+colormap[i*2,0,k])shr 1;

  if i>0 then
    for j:=0 to 255 do
      for k:=0 to 2 do
        colormap[i*2-1,j,k]:=(colormap[i*2,j,k]+colormap[i*2-2,j,k])shr 1
  else
    for j:=0 to 255 do
      for k:=0 to 2 do
        colormap[255,j,k]:=(colormap[0,j,k]);


end;
end.

