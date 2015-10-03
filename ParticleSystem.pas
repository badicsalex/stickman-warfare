unit ParticleSystem;
interface
uses windows, math, direct3D9, D3DX9, typestuff, Sysutils;


const
  TX_SEMMI = 0;
  TX_HOMALY = 1;
  TX_CSEPP = 2;
  TX_FIRE = 3;
  TX_SMOKE = 4;
  TX_LIGHT = 5;

  D3DFVF_PARTICLEVERTEX = (D3DFVF_XYZ or D3DFVF_DIFFUSE or D3DFVF_TEX1);

type
  Tparticlevertex = record
    pos:TD3DXVector3;
    color:cardinal;
    u, v:single;
  end;


  Tupdateproc = procedure(mit:integer);
  Trenderproc = procedure(mit:integer);
  Tstartcollproc = procedure(out t1, t2:TD3DXVector3);
  Tendcollpos = procedure(const t:TD3DXVector3;const coll:boolean);


  Tparticle = record
    vispls, vispls2, n, pl1, pl2:TD3DXVector3;
    k, kp, bszor, bszor2, ssz, weight:single;
    col, batch:cardinal; //a batch M4nél a szikra-boolean
    v1, v2:TD3DXVector3;
    tex, ido:word;
    render:Trenderproc;
    update:Tupdateproc;
  end;


procedure ParticleSystem_Init(a_pd3ddevice:IDirect3DDevice9);
procedure ParticleSystem_Render(viewmatrix:TD3DMatrix);
procedure ParticleSystem_Update;
procedure ParticleSystem_Add(mit:Tparticle);
procedure Particlesystem_Add_Villam(hol, merre:TD3DXVector3;scalfac, esely:single;db:integer;vst:single;col, lifetime:Dword);

procedure particle_special_mpg(honnan, hova:TD3DXVector3);
procedure particle_special_quad(honnan, hova:TD3DXVector3);
procedure particle_special_hpl(honnan, hova:TD3DXVector3);
procedure setWindStrength(power:single);

function esocseppcreate(av1, av2:TD3DXVector3;seb, sebszorzo:single;acol, abatch:cardinal):Tparticle;
//0 nem; 1: igen;
function bulletcreate(av1, av2:TD3DXVector3;seb, sebszorzo, vst:single;acol:cardinal;szikra:word;smoke:boolean):Tparticle;
function MPGcreate(av1, av2:TD3DXVector3;aido:single;acol:cardinal):Tparticle;
function Quadcreate(av1, av2:TD3DXVector3;seb, sebszorzo:single;acol:cardinal):Tparticle;
//function Gunmuzzcreate (honnan,merre:TD3DXVector3; frames:cardinal):Tparticle;
function Simpleparticlecreate(pos, vec:TD3DXVector3;startsiz, endsiz:single;startcolor, endcolor:cardinal;lifetime:word;texture:integer = TX_HOMALY):Tparticle;
function Gravityparticlecreate(pos, vec:TD3DXVector3;startsiz, endsiz, weig:single;startcolor, endcolor:cardinal;lifetime:word;texture:integer = TX_HOMALY):Tparticle;
function Coolingparticlecreate(pos, vec:TD3DXVector3;startsiz, endsiz, temperature:single;startcolor, endcolor:cardinal;lifetime:word;texture:integer = TX_HOMALY):Tparticle;
function ExpSebparticlecreate(pos, vec:TD3DXVector3;startsiz, endsiz, sebmul:single;startcolor, endcolor:cardinal;lifetime:word;texture:integer = TX_HOMALY):Tparticle;

function Langcreatorparticlecreate(pos, pos2:TD3DXVector3;szorzo:single):Tparticle;
function simplecreatorparticlecreate(pos, seb:TD3DXVector3;sebvisz, szoras, startsiz, endsiz:single;startcolor, endcolor:cardinal;partlt, partltszoras, idokoz, lifetime:word):Tparticle;

function fenycsikcreate(av1, av2:TD3DXVector3;vst:single;acol:cardinal;lifetime:word):Tparticle;
function fenycsik2create(av1, av2:TD3DXVector3;vst:single;acol, acol2:cardinal;lifetime:word):Tparticle;
function fenycsik3create(av1, av2:TD3DXVector3;vst:single;acol:cardinal;lifetime, megjtime:word):Tparticle;
function fenycsikubercreate(av1, av2, seb1, seb2:TD3DXVector3;vst, vst2:single;acol, acol2:cardinal;lifetime:word):Tparticle;
function fenycsiknoobcreate(av1, av2, seb1, seb2:TD3DXVector3;vst, vst2:single;acol, acol2:cardinal;lifetime:word):Tparticle;

function fenykorcreate(pos, seb, szel, hossz:TD3DXVector3;szor1, szor2, vstszor:single;acol, acol2:cardinal;lifetime:word):Tparticle;

function fenylightcreate(pos, vec:TD3DXVector3;startsiz, endsiz:single;startcolor, endcolor:cardinal;lifetime:word;texture:integer = TX_HOMALY):Tparticle;
var
  particles, rparticles, tparticles:array of Tparticle;

  particlehgh:integer = -1;
implementation
var
  ps_VB:IDirect3DVertexBuffer9 = nil;
  ps_IB:IDirect3DIndexBuffer9 = nil;
  ps_vert:array[0..20000] of Tparticlevertex;
  ps_ind:array[0..30000] of word;
  vertszam, indszam:integer;
  sortind:integer;

  g_pd3ddevice:IDirect3DDevice9;
  ps_texes:array[0..5] of IDirect3DTexture9;
  //TODO: VERTEX BUFFER DOLOG

  wind_str:single;

procedure ParticleSystem_Init(a_pd3ddevice:IDirect3DDevice9);
begin
  g_pd3ddevice:=a_pd3ddevice;
  if FAILED(g_pd3dDevice.CreateVertexBuffer(20000 * SizeOf(Tparticlevertex),
    D3DUSAGE_WRITEONLY or D3DUSAGE_DYNAMIC, D3DFVF_PARTICLEVERTEX,
    D3DPOOL_DEFAULT, ps_VB, nil))
    then Exit;

  if FAILED(g_pd3dDevice.CreateIndexBuffer(30000 * SizeOf(word),
    D3DUSAGE_WRITEONLY or D3DUSAGE_DYNAMIC, D3DFMT_INDEX16,
    D3DPOOL_DEFAULT, ps_IB, nil))
    then Exit;

  addfiletochecksum('data\homaly.png');
  addfiletochecksum('data\csepp2.png');
  addfiletochecksum('data\fire.png');
  addfiletochecksum('data\smoke.png');
  addfiletochecksum('data\light.png');

  LTFF(g_pd3ddevice, 'data\homaly.png', ps_texes[1], TEXFLAG_FIXRES);
  LTFF(g_pd3ddevice, 'data\csepp2.png', ps_texes[2], TEXFLAG_FIXRES);
  LTFF(g_pd3ddevice, 'data\fire.png', ps_texes[3], TEXFLAG_FIXRES);
  LTFF(g_pd3ddevice, 'data\smoke.png', ps_texes[4], TEXFLAG_FIXRES);
  LTFF(g_pd3ddevice, 'data\light.png', ps_texes[5], TEXFLAG_FIXRES);
end;

procedure ParticleSystem_Add(mit:Tparticle);
begin
  if particlehgh > 4000 then
  begin
    particles[random(particlehgh)]:=mit;
    exit;
  end;

  inc(particlehgh);
  if high(particles) < particlehgh then
  begin
    setlength(particles, length(particles) + 256);
    setlength(rparticles, length(particles));
  end;

  particles[particlehgh]:=mit;
end;

procedure ParticleSystem_Render(viewmatrix:TD3DMatrix);

var
  mat:TD3DMatrix;
  i, j:integer;
  tmp:Tparticle;
  tmost:word;
  pindices, pvertices:pointer;
  ev:TD3DXVector3;
  hmin, hmax:integer;
  planv:TD3DXVector3;
  plan:TD3DXPlane;

begin
  d3dxmatrixidentity(mat);
  g_pd3dDevice.SetTransform(D3DTS_WORLD, mat);
  g_pd3dDevice.SetTransform(D3DTS_TEXTURE0, mat);
  g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
  g_pd3dDevice.SetRenderState(D3DRS_ZWRITEENABLE, ifalse);
  //     g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iFalse);

  d3dxmatrixinverse(mat, nil, viewmatrix);

  {d3dxvec3transformcoord(campos,d3dxvector3(0,0,0.01),mat);
  D3DXVec3normalize(upvec,D3DXVector3(mat._11,mat._12,mat._13));
  D3DXVec3normalize(lvec,D3DXVector3(mat._21,mat._22,mat._23));  }
  D3DXVec3normalize(ev, D3DXVector3(mat._31, mat._32, mat._33));

  planv.x:=campos.x + ev.x * 0.3;
  planv.y:=campos.y + ev.y * 0.3;
  planv.z:=campos.z + ev.z * 0.3;
  D3DXPlanefrompointnormal(plan, planv, ev);
  g_pd3ddevice.Setclipplane(0, pointer(@plan));
  g_pd3ddevice.SetRenderState(D3DRS_CLIPPLANEENABLE, 1);

  g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, itrue);
  g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_ONE);
  g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);

  //    g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,D3DBLEND_SRCALPHA);
  //  g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,D3DBLEND_INVSRCALPHA);
  g_pd3ddevice.SetRenderState(D3DRS_BLENDOP, D3DBLENDOP_ADD);
  g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE, ifalse);


  g_pd3dDevice.SetTexture(0, nil);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP, FAKE_HDR);
  g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);
  g_pd3dDevice.SetTextureStageState(1, D3DTSS_ALPHAOP, D3DTOP_DISABLE);
  //g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG0,  D3DTA_TFACTOR);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);

  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);

  g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_NONE);

  g_pd3dDevice.SetStreamSource(0, ps_VB, 0, SizeOf(TParticleVertex));
  g_pd3dDevice.SetFVF(D3DFVF_PARTICLEVERTEX);
  g_pd3dDevice.SetIndices(ps_IB);


  { //Pointer csere
   tparticles:=particles;
   particles:=rparticles;
   rparticles:=tparticles;

   k:=-1;
   ///Nem elfelejteni ápdételni
   for i:=0 to TX_CSEPP do
    for j:=0 to particlehgh do
     if rparticles[j].tex=i then
     begin
      inc(k);
      particles[k]:=rparticles[j];
     end;    }

  { h1:=0;
   h2:=particlehgh;
   if (h1<h2) and (particles[h1].tex<=TX_HOMALY) and (particles[h2].tex>=TX_HOMALY) then
   begin
     while abs(h1-h2)>1 do
     begin
      h3:=(h1+h2) shr 1;
      if particles[h3].tex<TX_HOMALY then h1:=h3 else h2:=h3;
     end;
     hmin:=h1;

     h1:=0;
     h2:=particlehgh;
     while abs(h1-h2)>1  do
     begin
      h3:=(h1+h2) shr 1;
      if particles[h3].tex>=TX_HOMALY then h1:=h3 else h2:=h3;
     end;
     hmax:=h1;   }

  laststate:= 'Sorting Particle System';

  inc(sortind, 256);
  if sortind > particlehgh then sortind:=0;
  hmin:=sortind;
  hmax:=min(particlehgh, sortind + 512);

  for i:=hmin to hmax - 1 do
    for j:=i + 1 to hmax do
      //      if (D3DXvec3dot(particles[i].v1,ev)<D3DXvec3dot(particles[j].v1,ev)) then // LFnagyobb(particles[i],particles[j],ev) then
      if (particles[i].v1.x * ev.x + particles[i].v1.y * ev.y + particles[i].v1.z * ev.z)<(particles[j].v1.x * ev.x + particles[j].v1.y * ev.y + particles[j].v1.z * ev.z) then //inline.
      begin
        tmp:=particles[i];
        particles[i]:=particles[j];
        particles[j]:=tmp;
      end;
  //end;
  tmost:=0;

  indszam:=0;
  vertszam:=0;
  laststate:= 'Drawing Particle System';

  for j:=low(ps_texes) to high(ps_texes) do
    for i:=0 to particlehgh do
    begin
      if particles[i].tex <> j then continue;
      if (tmost <> particles[i].tex) or (indszam > 25000) or (vertszam > 17000) then
      begin
        if vertszam > 0 then
        begin
          //Flush1

          if FAILED(ps_VB.Lock(0, vertszam * sizeof(Tparticlevertex), pVertices, 0)) //D3DLOCK_DISCARD
          then exit;
          copymemory(pvertices, @ps_vert, vertszam * sizeof(Tparticlevertex));
          ps_VB.Unlock;

          if FAILED(ps_IB.Lock(0, indszam * 2, pindices, 0)) //D3DLOCK_DISCARD
          then exit;
          copymemory(pindices, @ps_ind, indszam * 2);
          ps_Ib.Unlock;

          if (indszam div 3) > 0 then
            g_pd3dDevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, vertszam, 0, indszam div 3);

          vertszam:=0;
          indszam:=0;
        end;
        g_pd3ddevice.SetTexture(0, ps_texes[particles[i].tex]);
        tmost:=particles[i].tex;
      end;
      particles[i].render(i);
    end;

  if vertszam > 0 then
  begin
    //Flush2

    if FAILED(ps_VB.Lock(0, vertszam * sizeof(Tparticlevertex), pVertices, 0)) //D3DLOCK_DISCARD
    then exit;
    copymemory(pvertices, @ps_vert, vertszam * sizeof(Tparticlevertex));
    ps_VB.Unlock;

    if FAILED(ps_IB.Lock(0, indszam * 2, pindices, 0)) //D3DLOCK_DISCARD
    then exit;
    copymemory(pindices, @ps_ind, indszam * 2);
    ps_Ib.Unlock;

    if (indszam div 3) > 0 then
      g_pd3dDevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, vertszam, 0, indszam div 3); //megáll

    vertszam:=0;
    indszam:=0;
  end;
  g_pd3ddevice.SetRenderState(D3DRS_CLIPPLANEENABLE, 0);
end;

procedure ParticleSystem_Update;
var
  i:integer;
  phgh2:integer;
begin

  for i:=0 to particlehgh do
    particles[i].update(i);
  i:=0;
  phgh2:=particlehgh;
  while i <= phgh2 do
  begin
    if particles[i].ido <= 0 then
    begin

      particles[i]:=particles[phgh2];
      dec(phgh2);
    end
    else
      inc(i);
  end;
  particlehgh:=phgh2;
end;


procedure particle_special_mpg(honnan, hova:TD3DXVector3);
var
  honhov:single;
  hossz, invhossz:single;
  tmp, tmpe, seb, sebe:TD3dXVector3;
  i, seed:integer;
begin
  hossz:=tavpointpoint(honnan, hova);
  if hossz < 0.1 then exit;
  invhossz:=1 / hossz;
  seed:=random(50000);
  for i:=0 to 3 do
  begin
    tmp:=honnan;
    seb:=D3DXVector3zero;
    honhov:=0;
    while honhov < 1 do
    begin
      tmpe:=tmp;
      sebe:=seb;

      d3dxvec3lerp(tmp, honnan, hova, honhov);
      honhov:=honhov + invhossz * tavpointpointkock(campos, tmp) * 0.3;
      seb:=randomvec(seed + i * 1000 + honhov * hossz * 0.2, 0.01);
      Particlesystem_add(Fenycsikubercreate(tmpe, tmp, sebe, seb, 0.005, 0.01, weapons[1].col[1], 0, 50));
    end;
    Particlesystem_add(Fenycsikubercreate(tmp, hova, seb, d3dxvector3zero, 0.005, 0.01, weapons[1].col[1], 0, 50));

  end;

  Particlesystem_add(Fenycsikcreate(honnan, hova, 0.1, weapons[1].col[2], 40));
  Particlesystem_add(Fenycsikcreate(honnan, hova, 0.02, weapons[1].col[3], 60));
  //Particlesystem_add(MPGcreate(aloves.pos,aloves.v2,0.255*1.5,$FFA000));

end;

procedure particle_special_quad(honnan, hova:TD3DXVector3);
begin
  ParticleSystem_add(simpleparticlecreate(honnan, d3dxvector3zero, 0.2, 0, 0, weapons[2].col[1] div 4, 20));
  ParticleSystem_add(simpleparticlecreate(honnan, d3dxvector3zero, 0, 0.05, weapons[2].col[2] div 4, 0, 20));
  ParticleSystem_add(bulletcreate(honnan, hova, 4, 8, 0.2, weapons[2].col[3], 0, false));
  ParticleSystem_add(bulletcreate(honnan, hova, 4, 6, 0.1, weapons[2].col[4], 0, false));
  ParticleSystem_add(bulletcreate(honnan, hova, 4, 4, 0.05, weapons[2].col[5], 0, false));
  //Particlesystem_add(QUADcreate(aloves.pos,aloves.v2,4,8,$0000FF00));
end;

procedure particle_special_hpl(honnan, hova:TD3DXVector3);
begin
  ParticleSystem_add(bulletcreate(honnan, hova, 4, 8, 0.2, weapons[5].col[3], 0, false));
  ParticleSystem_add(bulletcreate(honnan, hova, 4, 6, 0.1, weapons[5].col[4], 0, false));
  ParticleSystem_add(bulletcreate(honnan, hova, 4, 4, 0.05, weapons[5].col[5], 0, false));
end;

////////////////////////////////////////////

procedure uresupdate(mit:integer);
begin

end;

////////////////////////////////////////////

procedure createszikra(mit:integer);
var
  i:integer;
  av1, av2:TD3DXVector3;
begin
  with particles[mit] do
  begin
    d3dxvec3add(av1, v1, vispls);
    av2:=av1;
  end;

  for i:=0 to 5 do
  begin
    //randomplus(av2,i+animstat*200,0.3);
    randomplus(av2, random(10000), 0.3);
    ParticleSystem_Add(bulletcreate(av1, av2, 3, 5, particles[mit].bszor, particles[mit].col, 0, false));
    // av2:=av1;
  end;

end;


procedure bulletupdate(mit:integer);
begin
  with particles[mit] do
  begin
    d3dxvec3add(v1, v1, v2);
    dec(ido);
    if (ido = 0) and (batch <> 0) then createszikra(mit);
  end;
end;

procedure bulletrender(mit:integer);
var
  v2a, vp, tmp:TD3DXVector3;
  ind, ind2:integer;
  tmp3:single;
  vec:Tparticlevertex;
begin
  with particles[mit] do
  begin
    d3dxvec3subtract(tmp, campos, v1);
    d3dxvec3cross(vp, tmp, vispls);
    tmp3:=d3dxvec3lengthsq(vp);
    if tmp3 > 0.0001 then
      d3dxvec3scale(vp, vp, bszor * fastinvsqrt(tmp3));

    ind:=vertszam;
    vertszam:=vertszam + 4;

    d3dxvec3add(v2a, v1, vispls);

    vec.pos:=v1;
    vec.color:=col;
    vec.u:=0;
    vec.v:=0;


    d3dxvec3add(vec.pos, v1, vp);
    ps_vert[ind + 0]:=vec;
    vec.v:=1;
    d3dxvec3add(vec.pos, v2a, vp);
    ps_vert[ind + 1]:=vec;
    vec.u:=1;
    vec.v:=0;
    d3dxvec3subtract(vec.pos, v1, vp);
    ps_vert[ind + 2]:=vec;
    vec.v:=1;
    d3dxvec3subtract(vec.pos, v2a, vp);
    ps_vert[ind + 3]:=vec;

    ind2:=indszam;
    indszam:=indszam + 6;
    ps_ind[ind2 + 0]:=ind + 0;
    ps_ind[ind2 + 1]:=ind + 1;
    ps_ind[ind2 + 2]:=ind + 2;
    ps_ind[ind2 + 3]:=ind + 3;
    ps_ind[ind2 + 4]:=ind + 1;
    ps_ind[ind2 + 5]:=ind + 2;
  end;
end;

function bulletcreate(av1, av2:TD3DXVector3;seb, sebszorzo, vst:single;acol:cardinal;szikra:word;smoke:boolean):Tparticle;
var
  lngt:single;
begin
  with result do
  begin
    //if tavpointpointsq(av2,campos)>sqr(25) then szikra:=0;
    batch:=szikra;
    ido:=0;
    v1:=av1;
    d3dxvec3subtract(v2, av1, av2);
    lngt:=d3dxvec3length(v2);
    if lngt < 0.001 then lngt:=1;
    d3dxvec3scale(v2, v2, -seb / lngt);
    d3dxvec3scale(vispls, v2, sebszorzo);
    if seb * sebszorzo < lngt then
    begin
      ido:=round((lngt - seb * sebszorzo) / seb);
    end
    else
    begin
      ido:=5;
      v2:=d3dxvector3zero;
      d3dxvec3subtract(vispls, av2, av1);
    end;

    bszor:=vst;
    col:=acol;
    //OMFGWTF
    if smoke then
      tex:=TX_SMOKE
    else
      tex:=TX_HOMALY;

    update:=bulletupdate;
    render:=bulletrender;
    //update:=uresupdate;
    //render:=gunmuzzrender;
  end;
end;



////////////////////////////////////////////

procedure esocseppupdate(mit:integer);
begin
  with particles[mit] do
  begin
    d3dxvec3add(v1, v1, v2);
    k:=k + kp;
    dec(ido);
  end;
end;

procedure esocsepprender(mit:integer);
var
  v2a, vp, tmp:TD3DXVector3;
  ind, ind2:integer;
  tmp3:single;
  vec:Tparticlevertex;
begin
  with particles[mit] do
  begin
    d3dxvec3subtract(tmp, campos, v1);
    d3dxvec3cross(vp, tmp, vispls);
    tmp3:=d3dxvec3lengthsq(vp);
    if tmp3 > 0.0001 then
      d3dxvec3scale(vp, vp, batch * 0.03 * fastinvsqrt(tmp3));

    vp.y:=vp.y + k * bszor;
    ind:=vertszam;
    vertszam:=vertszam + 4;

    d3dxvec3add(v2a, v1, vispls);

    vec.pos:=v1;
    vec.color:=col;
    vec.u:=0;
    vec.v:=0;


    d3dxvec3add(vec.pos, v1, vp);
    ps_vert[ind + 0]:=vec;
    vec.v:=1;
    d3dxvec3add(vec.pos, v2a, vp);
    ps_vert[ind + 1]:=vec;
    vec.u:=batch;
    vec.v:=0;
    d3dxvec3subtract(vec.pos, v1, vp);
    ps_vert[ind + 2]:=vec;
    vec.v:=1;
    d3dxvec3subtract(vec.pos, v2a, vp);
    ps_vert[ind + 3]:=vec;

    ind2:=indszam;
    indszam:=indszam + 6;
    ps_ind[ind2 + 0]:=ind + 0;
    ps_ind[ind2 + 1]:=ind + 1;
    ps_ind[ind2 + 2]:=ind + 2;
    ps_ind[ind2 + 3]:=ind + 3;
    ps_ind[ind2 + 4]:=ind + 1;
    ps_ind[ind2 + 5]:=ind + 2;
  end;
end;

function esocseppcreate(av1, av2:TD3DXVector3;seb, sebszorzo:single;acol, abatch:cardinal):Tparticle;
var
  lngt:single;
begin
  with result do
  begin
    ido:=0;
    v1:=av1;
    d3dxvec3subtract(v2, av1, av2);
    lngt:=d3dxvec3length(v2);
    if lngt < 0.001 then lngt:=1;
    d3dxvec3scale(v2, v2, -seb / lngt);
    d3dxvec3scale(vispls, v2, sebszorzo);
    if seb * sebszorzo < lngt then
    begin
      ido:=round((lngt - seb * sebszorzo) / seb);
    end
    else
    begin
      ido:=1;
      v2:=d3dxvector3zero;
      d3dxvec3subtract(vispls, av2, av1);
    end;

    col:=acol;
    batch:=abatch;
    k:=(random(5) - 2.5) / 20;
    kp:=(random(5) - 2.5) / 5000;
    bszor:=power(batch, 2);
    d3dxvec3scale(vispls, vispls, 1 + sqr(batch / 10));
    tex:=TX_CSEPP;

    update:=esocseppupdate;
    render:=esocsepprender;
  end;
end;

////////////////////////////////////////////

procedure MPGupdate(mit:integer);
begin
  with particles[mit] do
  begin
    k:=k - kp;
    dec(ido);
  end;
end;

procedure MPGrender(mit:integer);
var
  i:integer;
  vec:Tparticlevertex;
  ind, ind2:integer;
begin
  with particles[mit] do
  begin
    vec.color:=colorlerp(0, col, k);
    vec.u:=0;
    vec.v:=0;
    ind:=vertszam;
    vertszam:=vertszam + 6;
    for i:=0 to 3 do
    begin
      vec.pos:=v1;
      randomplus(vec.pos, i * 100 + animstat * 30, 0.1);
      ps_vert[ind + i * 2 + 0]:=vec;
      vec.pos:=v2;
      randomplus(vec.pos, i * 100 + animstat * 30, 0.1);
      ps_vert[ind + i * 2 + 1]:=vec;
    end;



    ind2:=indszam;
    indszam:=indszam + 6;
    ps_ind[ind2 + 0]:=ind + 0;
    ps_ind[ind2 + 1]:=ind + 1;
    ps_ind[ind2 + 2]:=ind + 2;
    ps_ind[ind2 + 3]:=ind + 3;
    ps_ind[ind2 + 4]:=ind + 4;
    ps_ind[ind2 + 5]:=ind + 5;
  end;
end;

function MPGcreate(av1, av2:TD3DXVector3;aido:single;acol:cardinal):Tparticle;
begin
  with result do
  begin
    v1:=av1;
    v2:=av2;
    ido:=round(aido * 100);
    k:=1;
    kp:=k / ido;
    batch:=0;

    col:=acol;

    tex:=0;

    update:=MPGupdate;
    render:=MPGrender;
  end;
end;

/////////////

procedure Quadrender(mit:integer);
var
  i:integer;
  vec:Tparticlevertex;
  ind, ind2:integer;
  v2a:TD3DXVector3;
begin
  with particles[mit] do
  begin
    d3dxvec3add(v2a, v1, vispls);

    vec.color:=round(k) shl 24 + col;
    vec.u:=0;
    vec.v:=0;
    ind:=vertszam;
    vertszam:=vertszam + 6;
    for i:=0 to 3 do
    begin
      vec.pos:=v1;
      randomplus(vec.pos, i * 100 + animstat * 30, 0.4);
      ps_vert[ind + i * 2 + 0]:=vec;
      vec.pos:=v2a;
      randomplus(vec.pos, i * 100 + animstat * 30, 0.4);
      ps_vert[ind + i * 2 + 1]:=vec;
    end;



    ind2:=indszam;
    indszam:=indszam + 6;
    ps_ind[ind2 + 0]:=ind + 0;
    ps_ind[ind2 + 1]:=ind + 1;
    ps_ind[ind2 + 2]:=ind + 2;
    ps_ind[ind2 + 3]:=ind + 3;
    ps_ind[ind2 + 4]:=ind + 4;
    ps_ind[ind2 + 5]:=ind + 5;
  end;
end;


function Quadcreate(av1, av2:TD3DXVector3;seb, sebszorzo:single;acol:cardinal):Tparticle;
var
  lngt:single;
begin
  with result do
  begin

    ido:=0;
    v1:=av1;
    d3dxvec3subtract(v2, av1, av2);
    lngt:=d3dxvec3length(v2);
    if lngt < 0.001 then lngt:=1;
    d3dxvec3scale(v2, v2, -seb / lngt);
    d3dxvec3scale(vispls, v2, sebszorzo);
    if seb * sebszorzo < lngt then
    begin
      ido:=round((lngt - seb * sebszorzo) / seb);
    end
    else
    begin
      ido:=5;
      v2:=d3dxvector3zero;
      d3dxvec3subtract(vispls, av2, av1);
    end;

    k:=255;
    kp:=0;

    col:=acol;
    //OMFGWTF
    tex:=0;
    batch:=0;

    update:=bulletupdate;
    render:=QUADrender;
  end;
end;

//Gun muzzle

procedure Gunmuzzrender(mit:integer);
var
  i:integer;
  vec:Tparticlevertex;
  ind, ind2:integer;
  av1, v3, v4:TD3DXVector3;
  asin, acos:extended;
begin
  with particles[mit] do
  begin
    //V1 a pozíció
    //V2 az elõre
    //Vispls lehetnének az elõre és fel, de a fel mindig (0,1,0);
    d3dxvec3cross(v3, v2, D3DXVector3(0, 1, 0));
    fastvec3normalize(v3);
    d3dxvec3scale(v3, v3, 0.2);
    d3dxvec3cross(v4, v2, v3);
    fastvec3normalize(v4);
    d3dxvec3scale(v4, v4, 0.2);

    vec.color:=$A0A0A0;
    vec.u:=0.5;
    vec.v:=1;
    vec.pos:=v1;


    //A körül lévõ szar elõször
    ps_vert[vertszam]:=vec;

    ind:=vertszam + 1;
    vertszam:=vertszam + 7;
    ind2:=indszam;
    indszam:=indszam + 18;
    vec.u:=0;
    vec.v:=0;
    for i:=0 to 5 do
    begin
      vec.u:=1 - vec.u;
      sincos(i * D3DX_PI * 2 / 6, asin, acos);
      //asin:=asin*0.3;
     // acos:=acos*0.3;
      vec.pos:=D3DXVector3(v3.x * asin + v4.x * acos + v1.x, v3.y * asin + v4.y * acos + v1.y, v3.z * asin + v4.z * acos + v1.z);
      ps_vert[ind + i]:=vec;

      ps_ind[ind2 + i * 3 + 0]:=ind - 1;
      ps_ind[ind2 + i * 3 + 1]:=ind + i;
      if i = 0 then
        ps_ind[ind2 + i * 3 + 2]:=ind + 5
      else
        ps_ind[ind2 + i * 3 + 2]:=ind + i - 1;
    end;

    //Aztán az elõre ívelõ két háromszeg
    ind:=vertszam;
    vertszam:=vertszam + 5;
    d3dxvec3scale(av1, v2, 0.1);
    d3dxvec3subtract(av1, v1, av1);

    //vec.u és vec.v =0;
    vec.pos:=D3DXVector3(v3.x + av1.x, v3.y + av1.y, v3.z + av1.z); //balra
    ps_vert[ind + 0]:=vec;
    vec.pos:=D3DXVector3(v4.x + av1.x, v4.y + av1.y, v4.z + av1.z); //fel
    ps_vert[ind + 3]:=vec;

    vec.u:=1;
    vec.pos:=D3DXVector3(av1.x - v3.x, av1.y - v3.y, av1.z - v3.z); //jobbra
    ps_vert[ind + 1]:=vec;
    vec.pos:=D3DXVector3(av1.x - v4.x, av1.y - v4.y, av1.z - v4.z); //lé
    ps_vert[ind + 4]:=vec;

    vec.u:=0.5;
    vec.v:=1;
    vec.pos:=D3DXVector3(av1.x + v2.x, av1.y + v2.y, av1.z + v2.z);
    ps_vert[ind + 2]:=vec;

    ind2:=indszam;
    indszam:=indszam + 6;
    ps_ind[ind2 + 0]:=ind + 0;
    ps_ind[ind2 + 1]:=ind + 1;
    ps_ind[ind2 + 2]:=ind + 2;

    ps_ind[ind2 + 3]:=ind + 3;
    ps_ind[ind2 + 4]:=ind + 4;
    ps_ind[ind2 + 5]:=ind + 2;

    Dec(ido);
  end;
end;

{function Gunmuzzcreate (honnan,merre:TD3DXVector3; frames:cardinal):Tparticle;
begin
 with result do
 begin

 ido:=frames;
 v1:=honnan;
 v2:=merre;

 //OMFGWTF
 tex:=TX_LANG1;

 update:=uresupdate;
 render:=gunmuzzrender;
 end;
end;  }

/////////////////////////////////////

procedure Simpleparticleupdate(mit:integer);
begin
  with particles[mit] do
  begin
    d3dxvec3add(v1, v1, v2);
    dec(ido);
    k:=k + kp;
    bszor:=bszor + bszor2;
  end;
end;

procedure Gravityparticleupdate(mit:integer);
begin
  with particles[mit] do
  begin
    d3dxvec3add(v2, v2, d3dxvector3(0, -0.02 * weight, 0));
    d3dxvec3add(v1, v1, v2);
    dec(ido);
    k:=k + kp;
    bszor:=bszor + bszor2;
  end;
end;

procedure Coolingparticleupdate(mit:integer);
begin
  with particles[mit] do
  begin
    weight:=weight * 0.994;
    D3DXVec3Scale(v2, v2, 0.98);
    d3dxvec3add(v2, v2, d3dxvector3(0.0009 * wind_str, +0.02 * weight, 0));
    d3dxvec3add(v1, v1, v2);
    dec(ido);
    k:=k + kp;
    bszor:=bszor + bszor2;
  end;
end;

procedure setWindStrength(power:single);
begin
  wind_str:=power;
end;

procedure lightrender(mit:integer);
var
  vu, vl, distvec:TD3DXVector3;
  ind, ind2:integer;
  dist:single;
  vec:Tparticlevertex;
begin
  with particles[mit] do
  begin
    D3DXVec3Subtract(distvec, campos, v1);
    dist:=D3DXVec3Length(distvec);
    d3dxvec3scale(vu, upvec, dist * bszor); //upvec
    d3dxvec3scale(vL, lvec, dist * bszor); //lvec

    ind:=vertszam;
    vertszam:=vertszam + 4;

    vec.pos:=v1;
    vec.color:=colorlerp(col, batch, k);

    vec.u:=0;
    vec.v:=0;


    d3dxvec3add(vec.pos, v1, vu);
    ps_vert[ind + 0]:=vec;
    vec.v:=1;
    d3dxvec3add(vec.pos, v1, vl);
    ps_vert[ind + 1]:=vec;

    vec.u:=1;
    vec.v:=1;
    d3dxvec3subtract(vec.pos, v1, vu);
    ps_vert[ind + 2]:=vec;
    vec.u:=0;
    d3dxvec3subtract(vec.pos, v1, vl);
    ps_vert[ind + 3]:=vec;

    ind2:=indszam;
    indszam:=indszam + 6;
    ps_ind[ind2 + 0]:=ind + 0;
    ps_ind[ind2 + 1]:=ind + 1;
    ps_ind[ind2 + 2]:=ind + 2;
    ps_ind[ind2 + 3]:=ind + 0;
    ps_ind[ind2 + 4]:=ind + 2;
    ps_ind[ind2 + 5]:=ind + 3;
  end;
end;


procedure Simpleparticlerender(mit:integer);
var
  vu, vl:TD3DXVector3;
  ind, ind2:integer;
  vec:Tparticlevertex;
begin
  with particles[mit] do
  begin


    d3dxvec3scale(vu, upvec, bszor); //bszor
    d3dxvec3scale(vL, lvec, bszor);

    ind:=vertszam;
    vertszam:=vertszam + 4;

    vec.pos:=v1;
    vec.color:=colorlerp(col, batch, k);

    vec.u:=0;
    vec.v:=0;


    d3dxvec3add(vec.pos, v1, vu);
    ps_vert[ind + 0]:=vec;
    vec.v:=1;
    d3dxvec3add(vec.pos, v1, vl);
    ps_vert[ind + 1]:=vec;

    vec.u:=1;
    vec.v:=1;
    d3dxvec3subtract(vec.pos, v1, vu);
    ps_vert[ind + 2]:=vec;
    vec.u:=0;
    d3dxvec3subtract(vec.pos, v1, vl);
    ps_vert[ind + 3]:=vec;

    ind2:=indszam;
    indszam:=indszam + 6;
    ps_ind[ind2 + 0]:=ind + 0;
    ps_ind[ind2 + 1]:=ind + 1;
    ps_ind[ind2 + 2]:=ind + 2;
    ps_ind[ind2 + 3]:=ind + 0;
    ps_ind[ind2 + 4]:=ind + 2;
    ps_ind[ind2 + 5]:=ind + 3;
  end;
end;


function Simpleparticlecreate(pos, vec:TD3DXVector3;startsiz, endsiz:single;startcolor, endcolor:cardinal;lifetime:word;texture:integer = TX_HOMALY):Tparticle;
begin
  with result do
  begin
    v1:=pos;
    v2:=vec;
    col:=startcolor;
    batch:=endcolor;
    ido:=lifetime;
    k:=0;
    kp:=1 / lifetime;
    bszor:=startsiz;
    bszor2:=(endsiz - startsiz) / lifetime;
    tex:=texture;


    update:=simpleparticleupdate;
    render:=simpleparticlerender;
  end;
end;

function Gravityparticlecreate(pos, vec:TD3DXVector3;startsiz, endsiz, weig:single;startcolor, endcolor:cardinal;lifetime:word;texture:integer = TX_HOMALY):Tparticle;
begin
  with result do
  begin
    v1:=pos;
    v2:=vec;
    weight:=weig;
    col:=startcolor;
    batch:=endcolor;
    ido:=lifetime;
    k:=0;
    kp:=1 / lifetime;
    bszor:=startsiz;
    bszor2:=(endsiz - startsiz) / lifetime;
    tex:=texture;


    update:=gravityparticleupdate;
    render:=simpleparticlerender;
  end;
end;

function Coolingparticlecreate(pos, vec:TD3DXVector3;startsiz, endsiz, temperature:single;startcolor, endcolor:cardinal;lifetime:word;texture:integer = TX_HOMALY):Tparticle;
begin
  with result do
  begin
    v1:=pos;
    v2:=vec;
    weight:=temperature;
    col:=startcolor;
    batch:=endcolor;
    ido:=lifetime;
    k:=0;
    kp:=1 / lifetime;
    bszor:=startsiz;
    bszor2:=(endsiz - startsiz) / lifetime;
    tex:=texture;


    update:=coolingparticleupdate;
    render:=simpleparticlerender;
  end;
end;

//////////////////////////////////////////////////////

procedure Expsebparticleupdate(mit:integer);
begin
  with particles[mit] do
  begin
    d3dxvec3scale(v2, v2, ssz);
    d3dxvec3add(v1, v1, v2);
    dec(ido);
    k:=k + kp;
    bszor:=bszor + bszor2;

  end;
end;

function ExpSebparticlecreate(pos, vec:TD3DXVector3;startsiz, endsiz, sebmul:single;startcolor, endcolor:cardinal;lifetime:word;texture:integer = TX_HOMALY):Tparticle;
begin
  with result do
  begin
    v1:=pos;
    v2:=vec;
    col:=startcolor;
    batch:=endcolor;
    ido:=lifetime;
    k:=0;
    kp:=1 / lifetime;
    bszor:=startsiz;
    bszor2:=(endsiz - startsiz) / lifetime;
    ssz:=sebmul;
    tex:=texture;


    update:=expsebparticleupdate;
    render:=simpleparticlerender;
  end;
end;



///////////////////////////


procedure Langcreatorparticleupdate(mit:integer);
begin
  with particles[mit] do
  begin
    dec(ido);
    d3dxvec3add(v1, v1, v2);
    v2.y:=v2.y - GRAVITACIO / 3;
    particlesystem_add(ExpsebparticleCreate(v1, d3dxvector3((random(100) - 50) / 100000, (random(50) + 50) / 10000, (random(100) - 50) / 100000), 1, 0, 1.01, $FF0000FF + cardinal($100 * (150 + random(100))), $A0000000, word(ido shr 2 + 10 + random(50))));
  end;
end;

//ms

function Langcreatorparticlecreate(pos, pos2:TD3DXVector3;szorzo:single):Tparticle;
begin
  with result do
  begin
    //if tavpointpointsq(av2,campos)>sqr(25) then szikra:=0;
    batch:=1;
    ido:=round(1 / szorzo);
    v1:=pos;
    d3dxvec3subtract(v2, pos2, pos);
    d3dxvec3scale(v2, v2, szorzo);
    v2.y:=v2.y + ido * GRAVITACIO / 6;
    col:=$FFFFFFFF;
    //OMFGWTF
    tex:=TX_HOMALY;

    update:=Langcreatorparticleupdate;
    render:=uresupdate;
    //update:=uresupdate;
    //render:=gunmuzzrender;
  end;
end;

///////////////////////////


procedure simplecreatorparticleupdate(mit:integer);
var
  tmp, pos:TD3DXvector3;
begin
  with particles[mit] do
  begin
    dec(ido);
    d3dxvec3add(v1, v1, v2);
    k:=k - 1;
    if k <= 0 then
    begin
      d3dxvec3scale(pos, v2, -kp * random(10000) * 0.0001);
      d3dxvec3add(pos, v1, pos);
      tmp:=randomvec(animstat * 100000 + v1.x + v1.y + v1.z, vispls2.y);
      tmp:=D3DXVector3(tmp.x + v2.x * vispls2.x,
        tmp.y + v2.y * vispls2.x,
        tmp.z + v2.z * vispls2.x);
      particlesystem_add(simpleparticlecreate(pos, tmp, bszor, bszor2, col, batch, round(vispls.x) + random(round(vispls.y))));
      k:=kp;
    end;

  end;
end;



function simplecreatorparticlecreate(pos, seb:TD3DXVector3;sebvisz, szoras, startsiz, endsiz:single;startcolor, endcolor:cardinal;partlt, partltszoras, idokoz, lifetime:word):Tparticle;
begin
  with result do
  begin
    //if tavpointpointsq(av2,campos)>sqr(25) then szikra:=0;

    k:=idokoz;
    kp:=idokoz;
    ido:=lifetime;
    v1:=pos;
    v2:=seb;
    vispls.x:=partlt;
    vispls.y:=partltszoras;
    vispls2.x:=sebvisz;
    vispls2.y:=szoras;
    col:=startcolor;
    batch:=endcolor;
    ido:=lifetime;
    bszor:=startsiz;
    bszor2:=endsiz;

    //OMFGWTF
    tex:=TX_HOMALY;

    update:=simplecreatorparticleupdate;
    render:=uresupdate;
  end;
end;

////////////////////////////////////

procedure fenycsikupdate(mit:integer);
begin
  with particles[mit] do
  begin
    k:=k - kp;
    dec(ido);
  end;
end;

procedure fenycsikrender(mit:integer);
var
  v2a, vp, tmp:TD3DXVector3;
  ind, ind2:integer;
  tmp3:single;
  vec:Tparticlevertex;
begin
  with particles[mit] do
  begin
    d3dxvec3subtract(tmp, campos, v1);
    d3dxvec3cross(vp, tmp, vispls);
    tmp3:=d3dxvec3lengthsq(vp);
    if tmp3 > 0.000001 then
      d3dxvec3scale(vp, vp, ssz * fastinvsqrt(tmp3));

    ind:=vertszam;
    vertszam:=vertszam + 4;

    d3dxvec3add(v2a, v1, vispls);

    vec.pos:=v1;
    vec.color:=colorlerp(0, col, k);
    vec.u:=0;
    vec.v:=0.5;


    d3dxvec3add(vec.pos, v1, vp);
    ps_vert[ind + 0]:=vec;
    //  vec.v:=1;
    d3dxvec3add(vec.pos, v2a, vp);
    ps_vert[ind + 1]:=vec;
    vec.u:=1;
    //vec.v:=0;
    d3dxvec3subtract(vec.pos, v1, vp);
    ps_vert[ind + 2]:=vec;
    //  vec.v:=1;
    d3dxvec3subtract(vec.pos, v2a, vp);
    ps_vert[ind + 3]:=vec;

    ind2:=indszam;
    indszam:=indszam + 6;
    ps_ind[ind2 + 0]:=ind + 0;
    ps_ind[ind2 + 1]:=ind + 1;
    ps_ind[ind2 + 2]:=ind + 2;
    ps_ind[ind2 + 3]:=ind + 3;
    ps_ind[ind2 + 4]:=ind + 1;
    ps_ind[ind2 + 5]:=ind + 2;
  end;
end;

function fenylightcreate(pos, vec:TD3DXVector3;startsiz, endsiz:single;startcolor, endcolor:cardinal;lifetime:word;texture:integer = TX_HOMALY):Tparticle;
begin

  result:=Simpleparticlecreate(pos, vec, startsiz, endsiz, startcolor, endcolor, lifetime, texture);
  result.render:=lightrender;
end;

function fenycsikcreate(av1, av2:TD3DXVector3;vst:single;acol:cardinal;lifetime:word):Tparticle;

begin
  with result do
  begin
    //if tavpointpointsq(av2,campos)>sqr(25) then szikra:=0;
    ido:=lifetime;
    v1:=av1;
    d3dxvec3subtract(vispls, av2, av1);
    k:=1;
    kp:=k / ido;
    ssz:=vst;
    col:=acol;
    batch:=lifetime;
    //OMFGWTF
    tex:=TX_HOMALY;

    update:=fenycsikupdate;
    render:=fenycsikrender;
    //update:=uresupdate;
    //render:=gunmuzzrender;
  end;
end;

////////////////////////////////////////////

procedure fenycsikuberupdate(mit:integer);
begin
  with particles[mit] do
  begin
    d3dxvec3add(v1, v1, vispls);
    d3dxvec3add(v2, v2, vispls2);
    k:=k - kp;
    bszor:=bszor + bszor2;
    dec(ido);
  end;
end;

procedure fenycsikuberrender(mit:integer);
var
  v2a, vp, tmp, kul:TD3DXVector3;
  ind, ind2:integer;
  tmp3:single;
  vec:Tparticlevertex;
begin
  with particles[mit] do
  begin
    d3dxvec3subtract(kul, v2, v1);
    d3dxvec3subtract(tmp, campos, v1);
    d3dxvec3cross(vp, tmp, kul);
    tmp3:=d3dxvec3lengthsq(vp);
    if tmp3 > 0.0001 then
      d3dxvec3scale(vp, vp, bszor * fastinvsqrt(tmp3));

    ind:=vertszam;
    vertszam:=vertszam + 4;

    v2a:=v2;

    vec.pos:=v1;
    vec.color:=colorlerp(batch, col, k);
    vec.u:=0;
    vec.v:=0.5;


    d3dxvec3add(vec.pos, v1, vp);
    ps_vert[ind + 0]:=vec;
    //  vec.v:=1;
    d3dxvec3add(vec.pos, v2a, vp);
    ps_vert[ind + 1]:=vec;
    vec.u:=1;
    //vec.v:=0;
    d3dxvec3subtract(vec.pos, v1, vp);
    ps_vert[ind + 2]:=vec;
    //  vec.v:=1;
    d3dxvec3subtract(vec.pos, v2a, vp);
    ps_vert[ind + 3]:=vec;

    ind2:=indszam;
    indszam:=indszam + 6;
    ps_ind[ind2 + 0]:=ind + 0;
    ps_ind[ind2 + 1]:=ind + 1;
    ps_ind[ind2 + 2]:=ind + 2;
    ps_ind[ind2 + 3]:=ind + 3;
    ps_ind[ind2 + 4]:=ind + 1;
    ps_ind[ind2 + 5]:=ind + 2;
  end;
end;


procedure fenycsiknoobrender(mit:integer);
var
  v1t, v2t, va, vb, vp, tmp, kul:TD3DXVector3;
  ind, ind2:integer;
  tmp3:single;
  vec:Tparticlevertex;
begin
  with particles[mit] do
  begin
    d3dxvec3subtract(kul, v2, v1);
    d3dxvec3subtract(tmp, campos, v1);
    d3dxvec3cross(vp, tmp, kul);
    tmp3:=d3dxvec3lengthsq(vp);
    if tmp3 > 0.0001 then
      d3dxvec3scale(vp, vp, bszor * fastinvsqrt(tmp3));

    ind:=vertszam;
    vertszam:=vertszam + 8;

    D3DXVec3Lerp(va, v1, v2, min(0.25, 0.05 / d3dxvec3length(kul)));
    D3DXVec3Lerp(vb, v2, v1, min(0.25, 0.05 / d3dxvec3length(kul)));

    D3DXVec3Normalize(kul, kul);
    d3dxvec3scale(kul, kul, 0.05);
    d3dxvec3subtract(v1t, v1, kul);
    d3dxvec3add(v2t, v2, kul);

    vec.color:=colorlerp(batch, col, k);
    vec.u:=0;

    vec.v:=0;
    d3dxvec3add(vec.pos, v1t, vp);
    ps_vert[ind + 0]:=vec;

    vec.v:=1;
    d3dxvec3add(vec.pos, v2t, vp);
    ps_vert[ind + 1]:=vec;

    vec.v:=0.5;
    d3dxvec3add(vec.pos, va, vp);
    ps_vert[ind + 2]:=vec;

    d3dxvec3add(vec.pos, vb, vp);
    ps_vert[ind + 3]:=vec;

    vec.u:=1;

    d3dxvec3subtract(vec.pos, va, vp);
    ps_vert[ind + 4]:=vec;

    d3dxvec3subtract(vec.pos, vb, vp);
    ps_vert[ind + 5]:=vec;

    vec.v:=0;
    d3dxvec3subtract(vec.pos, v1t, vp);
    ps_vert[ind + 6]:=vec;

    vec.v:=1;
    d3dxvec3subtract(vec.pos, v2t, vp);
    ps_vert[ind + 7]:=vec;

    ind2:=indszam;
    indszam:=indszam + 18;
    ps_ind[ind2 + 0]:=ind + 0;
    ps_ind[ind2 + 1]:=ind + 2;
    ps_ind[ind2 + 2]:=ind + 6;
    ps_ind[ind2 + 3]:=ind + 4;
    ps_ind[ind2 + 4]:=ind + 2;
    ps_ind[ind2 + 5]:=ind + 6;

    ps_ind[ind2 + 6]:=ind + 2;
    ps_ind[ind2 + 7]:=ind + 3;
    ps_ind[ind2 + 8]:=ind + 4;
    ps_ind[ind2 + 9]:=ind + 5;
    ps_ind[ind2 + 10]:=ind + 3;
    ps_ind[ind2 + 11]:=ind + 4;

    ps_ind[ind2 + 12]:=ind + 3;
    ps_ind[ind2 + 13]:=ind + 1;
    ps_ind[ind2 + 14]:=ind + 5;
    ps_ind[ind2 + 15]:=ind + 7;
    ps_ind[ind2 + 16]:=ind + 1;
    ps_ind[ind2 + 17]:=ind + 5;
  end;
end;

function fenycsikubercreate(av1, av2, seb1, seb2:TD3DXVector3;vst, vst2:single;acol, acol2:cardinal;lifetime:word):Tparticle;

begin
  with result do
  begin
    //if tavpointpointsq(av2,campos)>sqr(25) then szikra:=0;
    if lifetime <= 0 then lifetime:=1;
    ido:=lifetime;
    v1:=av1;
    v2:=av2;
    vispls:=seb1;
    vispls2:=seb2;
    k:=1;
    kp:=k / ido;
    bszor:=vst;
    bszor2:=(vst2 - vst) * kp;
    col:=acol;
    batch:=acol2;
    //OMFGWTF
    tex:=TX_HOMALY;

    update:=fenycsikuberupdate;
    render:=fenycsikuberrender;

  end;
end;

function fenycsiknoobcreate(av1, av2, seb1, seb2:TD3DXVector3;vst, vst2:single;acol, acol2:cardinal;lifetime:word):Tparticle;

begin
  with result do
  begin
    //if tavpointpointsq(av2,campos)>sqr(25) then szikra:=0;
    if lifetime <= 0 then lifetime:=1;
    ido:=lifetime;
    v1:=av1;
    v2:=av2;
    vispls:=seb1;
    vispls2:=seb2;
    k:=1;
    kp:=k / ido;
    bszor:=vst;
    bszor2:=(vst2 - vst) * kp;
    col:=acol;
    batch:=acol2;
    //OMFGWTF
    tex:=TX_HOMALY;

    update:=fenycsikuberupdate;
    render:=fenycsiknoobrender;

  end;
end;

////////////////////////////////////////////

procedure fenycsik2render(mit:integer);
var
  v2a, vp, tmp:TD3DXVector3;
  ind, ind2:integer;
  tmp3:single;
  vec:Tparticlevertex;
begin
  with particles[mit] do
  begin
    d3dxvec3subtract(tmp, campos, v1);
    d3dxvec3cross(vp, tmp, vispls);
    tmp3:=d3dxvec3lengthsq(vp);
    if tmp3 > 0.0001 then
      d3dxvec3scale(vp, vp, ssz * fastinvsqrt(tmp3));

    ind:=vertszam;
    vertszam:=vertszam + 4;

    d3dxvec3add(v2a, v1, vispls);

    vec.pos:=v1;
    vec.color:=colorlerp(0, col, k);
    vec.u:=0;
    vec.v:=0.5;


    d3dxvec3add(vec.pos, v1, vp);
    ps_vert[ind + 0]:=vec;
    //  vec.v:=1;
    vec.color:=colorlerp(0, batch, k);
    d3dxvec3add(vec.pos, v2a, vp);
    ps_vert[ind + 1]:=vec;
    vec.u:=1;
    //vec.v:=0;
    vec.color:=colorlerp(0, col, k);
    d3dxvec3subtract(vec.pos, v1, vp);
    ps_vert[ind + 2]:=vec;
    //  vec.v:=1;
    vec.color:=colorlerp(0, batch, k);
    d3dxvec3subtract(vec.pos, v2a, vp);
    ps_vert[ind + 3]:=vec;

    ind2:=indszam;
    indszam:=indszam + 6;
    ps_ind[ind2 + 0]:=ind + 0;
    ps_ind[ind2 + 1]:=ind + 1;
    ps_ind[ind2 + 2]:=ind + 2;
    ps_ind[ind2 + 3]:=ind + 3;
    ps_ind[ind2 + 4]:=ind + 1;
    ps_ind[ind2 + 5]:=ind + 2;
  end;
end;

function fenycsik2create(av1, av2:TD3DXVector3;vst:single;acol, acol2:cardinal;lifetime:word):Tparticle;

begin
  with result do
  begin
    //if tavpointpointsq(av2,campos)>sqr(25) then szikra:=0;
    ido:=lifetime;
    v1:=av1;
    d3dxvec3subtract(vispls, av2, av1);
    k:=1;
    kp:=k / ido;
    ssz:=vst;
    col:=acol;
    batch:=acol2;
    //OMFGWTF
    tex:=TX_HOMALY;

    update:=fenycsikupdate;
    render:=fenycsik2render;
    //update:=uresupdate;
    //render:=gunmuzzrender;
  end;
end;

////////////////////////////////////////////


procedure fenycsik3render(mit:integer);
var
  v2a, vp, tmp:TD3DXVector3;
  ind, ind2:integer;
  tmp3:single;
  vec:Tparticlevertex;
begin
  with particles[mit] do
  begin
    if k > 1 then exit;
    d3dxvec3subtract(tmp, campos, v1);
    d3dxvec3cross(vp, tmp, vispls);
    tmp3:=d3dxvec3lengthsq(vp);
    if tmp3 > 0.0001 then
      d3dxvec3scale(vp, vp, ssz * fastinvsqrt(tmp3));

    ind:=vertszam;
    vertszam:=vertszam + 4;

    d3dxvec3add(v2a, v1, vispls);

    vec.pos:=v1;
    vec.color:=colorlerp(0, col, k);
    vec.u:=0;
    vec.v:=0.5;


    d3dxvec3add(vec.pos, v1, vp);
    ps_vert[ind + 0]:=vec;
    //  vec.v:=1;
    d3dxvec3add(vec.pos, v2a, vp);
    ps_vert[ind + 1]:=vec;
    vec.u:=1;
    //vec.v:=0;
    d3dxvec3subtract(vec.pos, v1, vp);
    ps_vert[ind + 2]:=vec;
    //  vec.v:=1;
    d3dxvec3subtract(vec.pos, v2a, vp);
    ps_vert[ind + 3]:=vec;

    ind2:=indszam;
    indszam:=indszam + 6;
    ps_ind[ind2 + 0]:=ind + 0;
    ps_ind[ind2 + 1]:=ind + 1;
    ps_ind[ind2 + 2]:=ind + 2;
    ps_ind[ind2 + 3]:=ind + 3;
    ps_ind[ind2 + 4]:=ind + 1;
    ps_ind[ind2 + 5]:=ind + 2;
  end;
end;

function fenycsik3create(av1, av2:TD3DXVector3;vst:single;acol:cardinal;lifetime, megjtime:word):Tparticle;

begin
  with result do
  begin
    //if tavpointpointsq(av2,campos)>sqr(25) then szikra:=0;
    ido:=lifetime;
    v1:=av1;
    d3dxvec3subtract(vispls, av2, av1);

    kp:=k / (megjtime);
    k:=1 + kp * (lifetime - megjtime);
    ssz:=vst;
    col:=acol;
    batch:=0;
    //OMFGWTF
    tex:=TX_HOMALY;

    update:=fenycsikupdate;
    render:=fenycsik3render;
  end;
end;

////////////////////////////////////

procedure fenykorupdate(mit:integer);
begin
  with particles[mit] do
  begin
    d3dxvec3add(v1, v1, v2);
    k:=k + kp;
    bszor:=bszor + bszor2;
    dec(ido);
  end;
end;

procedure fenykorrender(mit:integer);
var
  vec1, vec2:Tparticlevertex;
  i:integer;
  ind, ind2:integer;
  mat, mat1, mat2:TD3DMatrix;
  si, ci:extended;
begin
  with particles[mit] do
  begin



    mat1._11:=vispls.x;mat1._12:=vispls.y;mat1._13:=vispls.z;mat1._14:=0;
    mat1._21:=vispls2.x;mat1._22:=vispls2.y;mat1._23:=vispls2.z;mat1._24:=0;
    mat1._31:=0;mat1._32:=0;mat1._33:=0;mat1._34:=0;
    mat1._41:=v1.x;mat1._42:=v1.y;mat1._43:=v1.z;mat1._44:=1;
    D3DXMatrixscaling(mat2, bszor, bszor, bszor);
    d3dxmatrixmultiply(mat, mat2, mat1);

    vec1.color:=colorlerp(col, batch, k);
    vec1.u:=0;
    vec1.v:=0.5;

    vec2.color:=vec1.color;
    vec2.u:=1;
    vec2.v:=0.5;

    ind:=vertszam;
    vertszam:=vertszam + 16 * 2;
    for i:=0 to 15 do
    begin
      sincos(i * 2 * D3DX_PI / 16, si, ci);
      d3dxvec3transformcoord(vec1.pos, D3DXvector3(si, ci, 0), mat);
      ps_vert[ind + i * 2 + 0]:=vec1;
      d3dxvec3transformcoord(vec2.pos, D3DXvector3(si * ssz, ci * ssz, 0), mat);
      ps_vert[ind + i * 2 + 1]:=vec2;
    end;

    ind2:=indszam;
    indszam:=indszam + 16 * 6;

    for i:=0 to 15 do
    begin // mod 32
      ps_ind[ind2 + i * 6 + 0]:=ind + (i * 2 + 0) and 31;
      ps_ind[ind2 + i * 6 + 1]:=ind + (i * 2 + 1) and 31;
      ps_ind[ind2 + i * 6 + 2]:=ind + (i * 2 + 2) and 31;
      ps_ind[ind2 + i * 6 + 3]:=ind + (i * 2 + 3) and 31;
      ps_ind[ind2 + i * 6 + 4]:=ind + (i * 2 + 1) and 31;
      ps_ind[ind2 + i * 6 + 5]:=ind + (i * 2 + 2) and 31;
    end;
  end;
end;

function fenykorcreate(pos, seb, szel, hossz:TD3DXVector3;szor1, szor2, vstszor:single;acol, acol2:cardinal;lifetime:word):Tparticle;
var
  tmp, tmp2:single;
begin
  with result do
  begin
    ido:=lifetime;

    v1:=pos;
    v2:=seb;
    k:=0;
    kp:=1 / ido;

    tmp:=d3dxvec3lengthsq(szel);

    tmp2:=fastinvsqrt(tmp);

    D3DXVec3scale(vispls, szel, tmp2);
    D3DXVec3scale(vispls2, hossz, tmp2);

    tmp:=1 / tmp;
    bszor:=tmp * szor1;
    bszor2:=tmp * (szor2 - szor1) * kp;

    ssz:=vstszor + 1;

    col:=acol;
    batch:=acol2;

    //OMFGWTF
    tex:=TX_HOMALY;

    update:=fenykorupdate;
    render:=fenykorrender;
  end;
end;

////////////////////////////////////////////

procedure particlesystem_Add_Villam(hol, merre:TD3DXVector3;scalfac, esely:single;db:integer;vst:single;col, lifetime:Dword);
var
  v2:TD3DXVector3;
  i:integer;
begin
  d3dxvec3add(v2, hol, merre);
  d3dxvec3add(v2, v2, D3DXVector3((random(1000) / 500 - 1) * scalfac, (random(1000) / 500 - 1) * scalfac, (random(1000) / 500 - 1) * scalfac));

  Particlesystem_add(fenycsikcreate(hol, v2, vst, col, lifetime));

  if db > 1 then
  begin
    i:=1;
    repeat
      particlesystem_add_villam(v2, merre, scalfac, esely / i, db - 1, vst * (db - 1) / (db), col, lifetime);
      inc(i)
    until random(1000) > esely * 1000;
  end;
end;


end.

