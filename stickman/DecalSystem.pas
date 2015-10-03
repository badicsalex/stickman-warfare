unit DecalSystem;
interface
uses windows,math,direct3D9,D3DX9,typestuff,Sysutils;


const
  D3DFVF_PARTICLEVERTEX=(D3DFVF_XYZ or D3DFVF_DIFFUSE or D3DFVF_TEX1);

type
  Tparticlevertex=record
    pos:TD3DXVector3;
    color:cardinal;
    u,v:single;
  end;


  Tupdateproc=procedure(mit:integer);
  Trenderproc=procedure(mit:integer);
  Tstartcollproc=procedure(out t1,t2:TD3DXVector3);
  Tendcollpos=procedure(const t:TD3DXVector3;const coll:boolean);

  //  Tmaterialtexture=record
  //    tex:IDirect3DTexture9;
  //    material:byte;
  //  end;

  Tparticle=record
    n,pl1,pl2:TD3DXVector3;
    k,kp,bszor,bszor2:single;
    col,batch:cardinal;//a batch M4nél a szikra-boolean
    v1,v2:TD3DXVector3;
    ido:word;
    tex:byte;
    material:byte;
    render:Trenderproc;
    update:Tupdateproc;
  end;


procedure DecalSystem_Init(a_pd3ddevice:IDirect3DDevice9);
procedure DecalSystem_Render(viewmatrix:TD3DMatrix);
procedure DecalSystem_Update;
procedure DecalSystem_Add(mit:Tparticle);

function Bulletholecreate(pos,vec:TD3DXVector3;startsiz,endsiz:single;startcolor,endcolor:cardinal;lifetime:word;normal,pl:TD3DXVector3;lottmat:byte):Tparticle;

var
  particles,rparticles,tparticles:array of Tparticle;

  particlehgh:integer=-1;

  decalslive:boolean;// volt-e init
implementation
var
  ps_VB:IDirect3DVertexBuffer9=nil;
  ps_IB:IDirect3DIndexBuffer9=nil;
  ps_vert:array[0..20000] of Tparticlevertex;
  ps_ind:array[0..30000] of word;
  vertszam,indszam:integer;
  //sortind:integer;

  g_pd3ddevice:IDirect3DDevice9;
  ps_texes:array of IDirect3DTexture9;
  texindices:array of integer;
  texnum:array of integer;
  //TODO: VERTEX BUFFER DOLOG

procedure DecalSystem_Init(a_pd3ddevice:IDirect3DDevice9);
var
  i,j:integer;
begin
  g_pd3ddevice:=a_pd3ddevice;
  if FAILED(g_pd3dDevice.CreateVertexBuffer(20000*SizeOf(Tparticlevertex),
    D3DUSAGE_WRITEONLY or D3DUSAGE_DYNAMIC,D3DFVF_PARTICLEVERTEX,
    D3DPOOL_DEFAULT,ps_VB,nil))
    then Exit;

  if FAILED(g_pd3dDevice.CreateIndexBuffer(30000*SizeOf(word),
    D3DUSAGE_WRITEONLY or D3DUSAGE_DYNAMIC,D3DFMT_INDEX16,
    D3DPOOL_DEFAULT,ps_IB,nil))
    then Exit;

  SetLength(ps_texes,1);//ez a geci nem megy 0 indexszel
  SetLength(texindices,MAT_MAX+1);
  SetLength(texnum,MAT_MAX+1);

  j:=0;//kell ide
  for i:=0 to MAT_MAX do
  begin
    texnum[i]:=stuffjson.GetNum(['bullethole_textures',matname(i)]);
    texindices[i]:=High(ps_texes)+1;
    for j:=0 to texnum[i]-1 do
    begin
      SetLength(ps_texes,Length(ps_texes)+1);

      addfiletochecksum(stuffjson.GetString(['bullethole_textures',matname(i),j]));
      LTFF(g_pd3ddevice,'data/'+stuffjson.GetString(['bullethole_textures',matname(i),j]),ps_texes[High(ps_texes)]);
    end;
  end;

  decalslive:=true;
end;

procedure DecalSystem_Add(mit:Tparticle);
begin
  if particlehgh>4000 then
  begin
    particles[random(particlehgh)]:=mit;
    exit;
  end;

  inc(particlehgh);
  if high(particles)<particlehgh then
  begin
    setlength(particles,length(particles)+256);
    setlength(rparticles,length(particles));
  end;

  particles[particlehgh]:=mit;
end;

procedure DecalSystem_Render(viewmatrix:TD3DMatrix);

var
  mat:TD3DMatrix;
  i,j:integer;
  tmost:word;
  pindices,pvertices:pointer;
  ev:TD3DXVector3;
  planv:TD3DXVector3;
  plan:TD3DXPlane;
  tmplw:longword;
begin
  d3dxmatrixidentity(mat);
  g_pd3dDevice.SetTransform(D3DTS_WORLD,mat);
  g_pd3dDevice.SetTransform(D3DTS_TEXTURE0,mat);
  //  g_pd3dDevice.SetRenderState(D3DRS_CULLMODE,D3DCULL_NONE);
  g_pd3dDevice.SetRenderState(D3DRS_ZWRITEENABLE,ifalse);
//     g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iFalse);

  d3dxmatrixinverse(mat,nil,viewmatrix);

  {d3dxvec3transformcoord(campos,d3dxvector3(0,0,0.01),mat);
  D3DXVec3normalize(upvec,D3DXVector3(mat._11,mat._12,mat._13));
  D3DXVec3normalize(lvec,D3DXVector3(mat._21,mat._22,mat._23));  }
  D3DXVec3normalize(ev,D3DXVector3(mat._31,mat._32,mat._33));

  planv.x:=campos.x+ev.x*0.3;
  planv.y:=campos.y+ev.y*0.3;
  planv.z:=campos.z+ev.z*0.3;
  D3DXPlanefrompointnormal(plan,planv,ev);
  g_pd3ddevice.Setclipplane(0,pointer(@plan));
  g_pd3ddevice.SetRenderState(D3DRS_CLIPPLANEENABLE,1);

  g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE,itrue);
  //  g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,D3DBLEND_DESTCOLOR);
  g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,D3DBLEND_SRCALPHA);
  g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,D3DBLEND_INVSRCALPHA);
  //  g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,D3DBLEND_ONE); //both
  g_pd3ddevice.SetRenderState(D3DRS_BLENDOP,D3DBLENDOP_ADD);
  g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE,ifalse);


  //D3DBLEND_INVDESTCOLOR
  //D3DBLEND_BOTHINVSRCALPHA


  g_pd3dDevice.SetTexture(0,nil);
  g_pd3dDevice.SetTextureStageState(0,D3DTSS_COLOROP,FAKE_HDR);
  g_pd3dDevice.SetTextureStageState(1,D3DTSS_COLOROP,D3DTOP_DISABLE);
  g_pd3dDevice.SetTextureStageState(0,D3DTSS_ALPHAOP,D3DTOP_MODULATE);
  g_pd3dDevice.SetTextureStageState(1,D3DTSS_ALPHAOP,D3DTOP_DISABLE);
  //g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG0,  D3DTA_TFACTOR);
  g_pd3dDevice.SetTextureStageState(0,D3DTSS_COLORARG1,D3DTA_TEXTURE);
  //  g_pd3dDevice.SetTextureStageState(0,D3DTSS_COLORARG2,D3DTA_DIFFUSE);
  g_pd3dDevice.SetTextureStageState(0,D3DTSS_COLORARG2,D3DTA_CURRENT);

  //    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,FAKE_HDR   );



  g_pd3dDevice.SetTextureStageState(0,D3DTSS_ALPHAARG1,D3DTA_TEXTURE);
  g_pd3dDevice.SetTextureStageState(0,D3DTSS_ALPHAARG2,D3DTA_DIFFUSE);

  g_pd3dDevice.SetSamplerState(0,D3DSAMP_MIPFILTER,D3DTEXF_NONE);

  g_pd3dDevice.SetStreamSource(0,ps_VB,0,SizeOf(TParticleVertex));
  g_pd3dDevice.SetFVF(D3DFVF_PARTICLEVERTEX);
  g_pd3dDevice.SetIndices(ps_IB);

  laststate:='Sorting Decal System';


  tmost:=0;

  indszam:=0;
  vertszam:=0;
  laststate:='Drawing Decal System';

  //  g_pd3dDevice.SetRenderState(D3DRS_SLOPESCALEDEPTHBIAS,depthbiasP^);
  //  g_pd3dDevice.SetRenderState(D3DRS_DEPTHBIAS,depthbiasP^);
  g_pd3dDevice.SetRenderState(D3DRS_CULLMODE,D3DCULL_CCW);

  for j:=low(ps_texes)to high(ps_texes) do
    for i:=0 to particlehgh do
    begin
      if particles[i].tex<>j then continue;
      if (tmost<>particles[i].tex)or(indszam>25000)or(vertszam>17000) then
      begin
        if vertszam>0 then
        begin
          //Flush1

          if FAILED(ps_VB.Lock(0,vertszam*sizeof(Tparticlevertex),pVertices,D3DLOCK_DISCARD))
            then exit;
          copymemory(pvertices,@ps_vert,vertszam*sizeof(Tparticlevertex));
          ps_VB.Unlock;

          if FAILED(ps_IB.Lock(0,indszam*2,pindices,D3DLOCK_DISCARD))
            then exit;
          copymemory(pindices,@ps_ind,indszam*2);
          ps_Ib.Unlock;

          if (G_peffect<>nil) then
          begin
            g_peffect.SetTechnique('Bullethole');
            g_pEffect.SetTexture('g_MeshTexture',ps_texes[particles[i].tex]);
            g_peffect.SetFloat('HDRszorzo',shaderhdr);

            g_peffect._Begin(@tmplw,0);
            g_peffect.BeginPass(0);
            g_pd3dDevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST,0,0,vertszam,0,indszam div 3);
            g_peffect.Endpass;
            g_peffect._end;
          end
          else
          begin
            g_pd3dDevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST,0,0,vertszam,0,indszam div 3);
          end;

          vertszam:=0;
          indszam:=0;
        end;
        g_pd3ddevice.SetTexture(0,ps_texes[particles[i].tex]);
        tmost:=particles[i].tex;
      end;
      particles[i].render(i);
    end;

  if vertszam>0 then
  begin
    //Flush2

    if FAILED(ps_VB.Lock(0,vertszam*sizeof(Tparticlevertex),pVertices,D3DLOCK_DISCARD))
      then exit;
    copymemory(pvertices,@ps_vert,vertszam*sizeof(Tparticlevertex));
    ps_VB.Unlock;

    if FAILED(ps_IB.Lock(0,indszam*2,pindices,D3DLOCK_DISCARD))
      then exit;
    copymemory(pindices,@ps_ind,indszam*2);
    ps_Ib.Unlock;

    if (G_peffect<>nil) then
    begin
      g_peffect.SetTechnique('Bullethole');
      g_pEffect.SetTexture('g_MeshTexture',ps_texes[tmost]);
      g_peffect.SetFloat('HDRszorzo',shaderhdr);

      g_peffect._Begin(@tmplw,0);
      g_peffect.BeginPass(0);
      g_pd3dDevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST,0,0,vertszam,0,indszam div 3);
      g_peffect.Endpass;
      g_peffect._end;
    end
    else
    begin
      g_pd3dDevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST,0,0,vertszam,0,indszam div 3);
    end;



    vertszam:=0;
    indszam:=0;
  end;

  //  g_pd3dDevice.SetRenderState(D3DRS_SLOPESCALEDEPTHBIAS,0);
  //  g_pd3dDevice.SetRenderState(D3DRS_DEPTHBIAS,0);
  g_pd3dDevice.SetRenderState(D3DRS_CULLMODE,D3DCULL_NONE);

  g_pd3dDevice.SetRenderState(D3DRS_ZWRITEENABLE,itrue);
//  g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, itrue);
  g_pd3ddevice.SetRenderState(D3DRS_CLIPPLANEENABLE,0);
end;

procedure DecalSystem_Update;
var
  i:integer;
  phgh2:integer;
begin

  for i:=0 to particlehgh do
    particles[i].update(i);
  i:=0;
  phgh2:=particlehgh;
  while i<=phgh2 do
  begin
    if particles[i].ido<=0 then
    begin

      particles[i]:=particles[phgh2];
      dec(phgh2);
    end
    else
      inc(i);
  end;
  particlehgh:=phgh2;
end;


procedure Decalupdate(mit:integer);
begin
  with particles[mit] do
  begin
    d3dxvec3add(v1,v1,v2);
    dec(ido);
    k:=k+kp;
    bszor:=bszor+bszor2;
  end;
end;


procedure Decalrender(mit:integer);
var
  vu,vl:TD3DXVector3;
  ind,ind2:integer;
  vec:Tparticlevertex;
begin
  with particles[mit] do
  begin
    d3dxvec3scale(vu,pl1,bszor);
    d3dxvec3scale(vL,pl2,bszor);

    ind:=vertszam;
    vertszam:=vertszam+4;

    vec.pos:=v1;
    vec.color:=colorlerp(col,batch,k);

    vec.u:=0;
    vec.v:=0;

    d3dxvec3add(vec.pos,v1,vu);
    ps_vert[ind+0]:=vec;
    vec.v:=1;
    d3dxvec3add(vec.pos,v1,vl);
    ps_vert[ind+1]:=vec;

    vec.u:=1;
    vec.v:=1;
    d3dxvec3subtract(vec.pos,v1,vu);
    ps_vert[ind+2]:=vec;
    vec.u:=0;
    d3dxvec3subtract(vec.pos,v1,vl);
    ps_vert[ind+3]:=vec;

    ind2:=indszam;
    indszam:=indszam+6;
    ps_ind[ind2+0]:=ind+0;
    ps_ind[ind2+1]:=ind+1;
    ps_ind[ind2+2]:=ind+2;

    //90 fok
    vec.u:=1;
    vec.v:=0;

    d3dxvec3add(vec.pos,v1,vu);
    ps_vert[ind+0]:=vec;
    vec.v:=1;
    d3dxvec3add(vec.pos,v1,vl);
    ps_vert[ind+1]:=vec;

    vec.u:=0;
    d3dxvec3subtract(vec.pos,v1,vu);
    ps_vert[ind+2]:=vec;
    vec.v:=0;
    d3dxvec3subtract(vec.pos,v1,vl);
    ps_vert[ind+3]:=vec;


    ps_ind[ind2+3]:=ind+0;
    ps_ind[ind2+4]:=ind+2;
    ps_ind[ind2+5]:=ind+3;
  end;
end;


function Bulletholecreate(pos,vec:TD3DXVector3;startsiz,endsiz:single;startcolor,endcolor:cardinal;lifetime:word;normal,pl:TD3DXVector3;lottmat:byte):Tparticle;
var
  mat2:TD3DMatrix;
begin
  with result do
  begin

    //    v1:=pos;
    D3DXVec3Scale(normal,normal,0.01);//z bias helyett tegyük a cuccot picivel a poli elé
    D3DXVec3Add(v1,pos,normal);
    v2:=vec;
    col:=startcolor;
    batch:=endcolor;
    ido:=lifetime;
    k:=0;
    kp:=1/lifetime;
    bszor:=startsiz;
    bszor2:=(endsiz-startsiz)/lifetime;
    tex:=texindices[lottmat]+Random(texnum[lottmat]);
    n:=normal;
    pl1:=pl;
    material:=lottmat;

    D3DXMatrixRotationAxis(mat2,n,D3DX_PI*Random(2001)/1000);
    D3DXVec3TransformCoord(pl1,pl1,mat2);

    D3DXMatrixRotationAxis(mat2,n,D3DX_PI/2);
    D3DXVec3TransformCoord(pl2,pl1,mat2);

    update:=Decalupdate;
    render:=Decalrender;
  end;
end;

end.

