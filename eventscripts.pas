unit eventscripts;

interface
uses
  Sysutils,
  Direct3D9,
  D3DX9,
  Windows,
  Math,
  Typestuff,
  PerlinNoise,
  ojjektumok,
  newsoundunit,
  ParticleSystem;
type
   TStickmanEvent = class (TObject)
   protected
    g_pD3Ddevice:IDirect3ddevice9;
   public
    error:integer;
    vege:boolean;
    phs,phstim:integer;
    kivec:TD3DXVector3;
    constructor Create;
    procedure Phase(mi:integer);virtual;
    procedure Step;virtual;
    procedure RenderModels;virtual ;
    //destructor Destroy;
  end;

  TSpaceshipEvent = class (TStickmanEvent)
   protected
    g_pD3Ddevice:IDirect3ddevice9;
    g_pMesh:ID3DXMesh;
    fotex,futotex,kekpirostex,csilltex:IDirect3DTexture9;
    verts:array of Ttri;
    vertbuf:IDirect3DVertexBuffer9;
    automatic,betoltve:boolean;
    futotim:single;
    beaconpos,spcpos,vegpos:TD3DXvector3;
    agpos,agvpos:array [0..49] of TD3DXVector3;
    matrot:TD3DMatrix;
    procedure fillvertbuf;
    procedure nagyrobbanas(hol:TD3DXVector3);
    procedure aghangok;
   public
    constructor Create(adevice : IDirect3ddevice9;auto:boolean;dir:string);
    procedure Phase(mi:integer); override;
    procedure Step;              override;
    procedure RenderModels;      override;
    destructor Destroy;          override;
  end;

  Treactortores=record
   vec1,vec2:TD3DXVector3;
   elagazik:integer;
   elozo:integer;
  end;
  TReactorEvent = class (TStickmanEvent)
   protected
    szikr_pos:array [0..9] of TD3DXVector3;
    szikr_seb:array [0..9] of TD3DXVector3;
    toresek:array of Treactortores;
    re_pos:TD3DXVector3;
    procedure alapeffect;
    procedure sounds;
   public
    constructor Create(adevice : IDirect3ddevice9;are_pos:TD3DXVector3;dir:string);
    procedure Phase(mi:integer); override;
    procedure Step;              override;
    procedure RenderModels;      override;
    destructor Destroy;          override;
  end;

  TPortalEvent = class (TStickmanEvent)
   protected
    framemesh:ID3DXMesh;
    eventpos,beaconpos:TD3DXVector3;
    darabok:array [0..7] of TD3DXVector3;
    darabhely:array [0..7] of TD3DXVector3;
    matrot:TD3DMatrix;
    frametex:IDirect3DTexture9;
    fordul,speed:single;
    procedure sounds;
   // procedure alapeffect;
  //  procedure sounds;
   public

   vege:boolean;


    constructor Create(adevice : IDirect3ddevice9;auto:boolean;dir:string);
    procedure Phase(mi:integer); override;
    procedure Step;              override;

    procedure RenderModels;      override;
    destructor Destroy;          override;


  end;

implementation

constructor TStickmanEvent.Create;
begin
 inherited create;
 phs:=0;
 phstim:=0;
 vege:=false;
end;

procedure TStickmanEvent.Phase(mi:integer);
begin
 //Virtaul
end;

procedure TStickmanEvent.Step;
begin
 //Virtaul
end;

procedure TStickmanEvent.Rendermodels;
begin
 //Virtaul
end;

constructor TPortalEvent.Create(adevice : IDirect3ddevice9;auto:boolean;dir:string);
var
a:integer;
iii:TD3DXVector3;
begin
 inherited create;
 g_pD3Ddevice:=adevice;
 if not LTFF (g_pd3dDevice,'data/textures/frame.jpg',frametex) then
   Exit;
  if FAILED(D3DXLoadMeshFromX(PChar(dir+'portal.x'),0,g_pd3ddevice,nil,nil,nil,nil,framemesh)) then Exit;


  if ATportalhely<>-1 then
    eventpos:=ojjektumarr[ATportalhely].holvannak[0]
  else
    eventpos:=d3dxvector3(0,-100,0);
  eventpos.z:=eventpos.z+7.5;
  eventpos.y:=eventpos.y+18.5;
  eventpos.x:=eventpos.x-9.7;
  fordul:=0;
  speed:=0;
  matrot:=identmatr;

  darabhely[0] := D3DXVector3(7,-2.64,-1);
  darabhely[1] := D3DXVector3(9.5,-2.64,-6);
  darabhely[2] := D3DXVector3(9,-2.64,-10);
  darabhely[3] := D3DXVector3(10,-2.64,-5.5);
  darabhely[4] := D3DXVector3(-5,-2.64,4);
  darabhely[5] := D3DXVector3(-7.5,-2.64,-3);
  darabhely[6] := D3DXVector3(-7,-2.64,-8.5);
  darabhely[7] := D3DXVector3(9.5,-2.75,-17);

  for a:=0 to 7 do begin
      iii:= D3DXVector3(sin(a/4*D3DX_PI)*-2,0,cos(a/2*D3DX_PI)*-2);    //-sin(a/16*D3DX_PI)*5
      D3DXVec3Add(darabhely[a],darabhely[a],iii);
      // darabhely[a] := iii;
      end;
  
  phase(0);
  error := 0;
end;

procedure TPortalEvent.Phase(mi:integer);
var
vec1:TD3DXVector3;
begin
phs:=mi;
if (phs=1) then phstim:=0;

if phs=1 then
begin
 speed:=0.0018;
 vec1 := pantheonPos;
 playsound(40,false,phstim,false,vec1);
end;



end;

procedure TPortalEvent.Rendermodels;
var
 a:integer;
 szint:single;
 hely,tmp:TD3DXVector3;
 mat,mat1,mat2,mat3:TD3DMatrix;
begin
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,  D3DTOP_SELECTARG1 );
  g_pd3ddevice.settexture(0,frametex);


  if framemesh=nil then exit;


  if phs>1 then
  begin
     mat2 := matrot;
    D3DXMatrixTranslation(mat1,eventpos.x,eventpos.y,eventpos.z);
    D3DXMatrixScaling(mat2,3.2,3.2,3.2);
    D3DXMatrixMultiply(mat,mat2,mat1);
    D3DXMatrixRotationZ(mat2,D3DX_PI*0.5);
    //D3DXMatrixRotationX(mat2,D3DX_PI*-0.5);
    D3DXMatrixMultiply(mat,mat2,mat);


    g_pd3ddevice.SetTransform(D3DTS_WORLD,mat);
    g_pd3ddevice.settexture(0,frametex);

    for a:=0 to 7 do
    begin
      mat2 :=matrot;
      D3DXMatrixRotationY(mat2,D3DX_PI*0.25*a+fordul);
      D3DXMatrixMultiply(mat3,mat2,mat);
      g_pd3ddevice.SetTransform(D3DTS_WORLD,mat3);
     framemesh.DrawSubset(0);
    end;
  end
  else
  begin
  for a:=0 to 7 do
    begin
    szint:=(phstim-a*250)/250;
    if szint>1 then szint:=1;
    if szint<0 then szint:=0;
    szint:=szint*szint;
    mat2 := matrot;
    D3DXVec3Add(tmp,darabhely[a],eventpos);
    D3DXVec3Lerp(hely,tmp,eventpos,szint);
    D3DXMatrixTranslation(mat1,hely.x,hely.y,hely.z);
    D3DXMatrixScaling(mat2,3.2,3.2,3.2);
    D3DXMatrixRotationX(mat2,D3DX_PI/2);
    D3DXMatrixMultiply(mat,mat2,mat1);



    g_pd3ddevice.SetTransform(D3DTS_WORLD,mat);
    g_pd3ddevice.settexture(0,frametex);


      mat2 :=matrot;
      D3DXMatrixRotationY(mat2,D3DX_PI*0.25*a+fordul*szint);
      D3DXMatrixMultiply(mat3,mat2,mat);
      g_pd3ddevice.SetTransform(D3DTS_WORLD,mat3);
     framemesh.DrawSubset(0);
    end;
  end;

  //framemesh.DrawSubset(1);
end;



procedure TPortalEvent.sounds;
begin

 if (phs=1) and ((phstim) mod 250=0) and (phstim>200) then
   playsound(35,false,phstim,false,eventpos);

 if phstim = 2000 then
   playsound(37,false,555,true,eventpos);
   
 if phstim = 3350 then
   playsound(36,false,556,true,eventpos);


end;


procedure TPortalEvent.Step;
var
m,i:integer;
vec1,vec2,plsvec:TD3DXVector3;
x,y:single;
atav:single;
begin
sounds;

m:=0;
 case phs of
     //0 - darabokban hever, külsõ indítás
  1:m:=2000;   //helyére másznak, lassan fordul
  2:m:=3350;   //gyorsul,néhány részecske
  3:m:=7000;   //kialakul az örvény, megnyílik a cucc

 end;
 if phstim>7000 then m:=3;

 if (phs<>0) and (phstim>m) then phase(phs+1);
 if phs=0 then phstim:=0;
 
 if (phs=2) and (speed<0.012) then speed:=speed+0.00001;


 if phstim=2000 then
 for i:=0 to 32 do begin
 vec1 := D3DXVector3(sin(i/16*D3DX_PI)*3,cos(i/16*D3DX_PI)*3,0);
 D3DXVec3Add(vec1,eventpos,vec1);
 Particlesystem_add(simpleparticleCreate(vec1,D3DXVector3(0,0,0),2,2,0,$FFFFFFFF,300))
 end;

  if phstim=2300 then
 for i:=0 to 32 do begin
 vec1 := D3DXVector3(sin(i/16*D3DX_PI)*3,cos(i/16*D3DX_PI)*3,0);
 D3DXVec3Add(vec1,eventpos,vec1);
 Particlesystem_add(simpleparticleCreate(vec1,D3DXVector3(0,0,0),2,2,$FFFFFFFF,0,300))
 end;

 atav:=tavpointpointsq(eventpos,d3dxvector3(cpx^,cpy^,cpz^));
 if (atav<sqr(100*opt_particle)) then
 if (phs=3) or ( ((phs=2) and (random(2000)<phstim-2000)))  then
 begin

 vec1 := D3DXVector3(0,cos(fordul+D3DX_PI*0.25*(phstim mod 8))*3,sin(fordul+D3DX_PI*0.25*(phstim mod 8))*3);
  D3DXVec3Add(vec1,eventpos,vec1);
 Particlesystem_add(simpleparticleCreate(vec1,D3DXVector3(0.05,0,0),0.2,0.02,$FF00FFFF,0,200));
 end;

 if (atav<sqr(100*opt_particle)) then
 if (phs=3) and ((phstim mod 10) = 0) then
 begin
        plsvec.x:=random(200)-100;
       plsvec.z:=random(200)-100;
       plsvec.y:=random(200)-100;
       fastvec3normalize(plsvec);
       plsvec.x:=plsvec.x*2;
       plsvec.y:=plsvec.z*2;
       plsvec.z:=plsvec.z*2;
       D3DXVec3Add(vec2,eventpos,plsvec);

      // Particlesystem_Add_Villam(vec2,plsvec,0.2,0.25,5,0.1,$FFfffdce,100);
 end;

 if (atav<sqr(100*opt_particle)) then
 if (phs=3) and ((phstim mod 2) = 0) then
 begin
 x:=cos(-fordul/2+D3DX_PI*0.1176*(phstim mod 17))*3;
 y:=sin(-fordul/2+D3DX_PI*0.1176*(phstim mod 17))*3;
 vec1 := D3DXVector3(0,x,y);
 D3DXVec3Add(vec1,eventpos,vec1);
 vec2.x := 0.035;
 vec2.y := x*-0.004;
 vec2.z := y*-0.004;
 Particlesystem_add(simpleparticleCreate(vec1,vec2,0.2+random(10)/10,0.02,$FF00FFFF,0,220));
 if ((phstim mod 30) = 0) then
  Particlesystem_add(fenykorcreate(eventpos,D3DXVector3(0.04,0,0),d3dxvector3(0,1,0),d3dxvector3(0,0,1),2.85,2.85,0.3,$8866FFFF,0,300));

 end;

 if phs=3 then speed:=0.02;

 fordul:= (fordul+D3DX_PI*speed);
 if fordul>4*D3DX_PI then fordul:=0;

 
 if phstim>6000 then phstim:=phstim-1000;
 inc(phstim);
end;

destructor TPortalEvent.Destroy;
begin
 framemesh:=nil;
 g_pd3ddevice:=nil;
 inherited;
end;

                                                                    // data\event\
constructor TSpaceshipEvent.Create(adevice : IDirect3ddevice9;auto:boolean;dir:string);
var
tempmesh:ID3DXMesh;
fc:TD3DXVector3;
adj:pointer;
pVert:Pcustomvertexarray;
pInd:Pwordarray;
pattr:Pdwordarray;
vmi,vma,tmp:TD3DXVector3;
scl:single;
i,j:integer;
trinum:integer;
tmptri:Ttri;
begin
 inherited create;
 betoltve:=false;
 vege:=true;
 g_pD3Ddevice:=adevice;
 if not LTFF (g_pd3dDevice,'data\textures\metal003.bmp',fotex) then
   Exit;
 if not LTFF (g_pd3dDevice,dir+'kekpiros.bmp',kekpirostex) then
   Exit;
 if not LTFF (g_pd3dDevice,dir+'futofeny.png',futotex) then
   Exit;
 if not LTFF (g_pd3dDevice,dir+'csill.bmp',csilltex) then
   Exit;
  if FAILED(D3DXLoadMeshFromX(PChar(dir+'spcshp.x'),0,g_pd3ddevice,nil,nil,nil,nil,tempmesh)) then exit;
  if FAILED(tempmesh.CloneMeshFVF(0,D3DFVF_CUSTOMVERTEX,g_pd3ddevice,g_pMesh)) then exit;
  if tempmesh<>nil then tempmesh:=nil;

  g_pMesh.LockVertexBuffer(0,pointer(pvert));
  D3DXComputeboundingbox(pointer(pvert),g_pMesh.GetNumVertices,g_pMesh.GetNumBytesPerVertex,vmi,vma);
  scl:=max(vma.x-vmi.x,max(vma.y-vmi.y,vma.z-vmi.z));
  scl:=scl/100;
  d3dxvec3subtract(fc,vma,vmi);
  d3dxvec3scale(fc,fc,-0.5/scl);
  for i:=0 to g_pMesh.GetNumVertices-1 do
  begin
   tmp.z:=(pvert[i].position.z-vmi.z)/scl;
   tmp.y:=(pvert[i].position.y-vmi.y)/scl;
   tmp.x:=(pvert[i].position.x-vmi.x)/scl;
   pvert[i].color:=RGB(200,200,200);
   d3dxvec3add(pvert[i].position,tmp,fc);
  end;
  g_pMesh.UnlockVertexBuffer;

  getmem(adj,g_pmesh.getnumfaces*12);
  g_pMesh.generateadjacency(0.001,adj);
  D3DXComputenormals(g_pMesh,adj);
  freemem(adj);


  if FAILED(g_pMesh.LockVertexBuffer(0,pointer(pvert))) then exit;
  if FAILED(g_pMesh.LockIndexBuffer(D3DLOCK_READONLY,pointer(pind))) then exit;
  if FAILED(g_pMesh.LockAttributeBuffer(D3DLOCK_READONLY,pdword(pattr))) then exit;

  trinum:=g_pMesh.GetNumFaces;

  setlength(verts,trinum);

  j:=0;
  for i:=0 to trinum-1 do
   if pattr[i]<>3 then
   begin
    verts[j,0]:=pvert[pind[i*3+0]].position;
    verts[j,1]:=pvert[pind[i*3+1]].position;
    verts[j,2]:=pvert[pind[i*3+2]].position;
    j:=j+1;
   end;
  trinum:=j;
  setlength(verts,trinum);

  g_pMesh.UnlockVertexBuffer;
  g_pMesh.UnlockIndexBuffer;
  g_pMesh.UnlockAttributeBuffer;

  for i:=0 to trinum-2 do
   for j:=i to trinum-1 do
   //if (verts[i,0].x+verts[i,0].y)>(verts[j,0].x+verts[j,0].y) then
   if random(2)=0 then
   begin
    tmptri:=verts[i];
    verts[i]:=verts[j];
    verts[j]:=tmptri;
   end;

  if FAILED(g_pd3dDevice.CreateVertexBuffer(trinum*3*sizeof(Tcoloredvert),
                                            D3DUSAGE_WRITEONLY+D3DUSAGE_DYNAMIC, D3DFVF_COLOREDVERTEX,
                                            D3DPOOL_DEFAULT, vertbuf, nil)) then exit;

  betoltve:=true;

  beaconpos:=pantheonPos;
  beaconpos.x:=beaconpos.x-300;
  beaconpos.y:=beaconpos.y+30;
  vegpos:=DNSVec;
  vegpos.x:=vegpos.x-200;
 // vegpos.y:=beaconpos.y;
  vege:=false;
  automatic:=auto;
  zeromemory(@agpos,sizeof(agpos));
  zeromemory(@agvpos,sizeof(agvpos));
  matrot:=identmatr;
  futotim:=0;
  phase(0);
end;



procedure TSpaceshipEvent.Phase(mi:integer);
var
i:integer;
v1,v2,pos,vec1,vec2:TD3DXVector3;
t:TD3DXVector3;
col:byte;
begin
 phs:=mi;
 phstim:=0;
 if mi=7 then
 begin
 for i:=0 to 50 do
 begin
  spcpos:=vegpos;
  vec1:=vegpos;
  randomplus(vec1,phstim,5);
  vec2:=vec1;
  vec2.x:=vec2.x+150;
  Particlesystem_add(fenycsikcreate(vec1,vec2,(60-i) div 5,$001020A0,10+i));
 end;

 end;

 if mi=9 then
 begin
  playsound(28,false,120,true,vegpos);
  setsoundproperties(28,120,0,5000,true,vegpos);
 end;
 if mi=10 then
 begin
  for i:=0 to 10 do
  begin
   v1:=D3DXVector3(0,(random(100)-50)/100,6);
   v2:=D3DXVector3(6,(random(100)-50)/100,0);
   // v1:=randomvec(i*10,0.1);
   // v2:=randomvec(i*10+3,0.1);
   Particlesystem_add(fenykorCreate(spcpos,randomvec(i*3.5,0.05),
                                        v1,v2,10,3000,0.5,$A0B02010,0,100));
  end;

  for i:=0 to 20 do
  begin
   v1:=randomvec(i*3+animstat,40);
   d3dxvec3add(v1,v1,spcpos);
   Particlesystem_add(fenycsik2Create(spcpos,v1,1,$FFFFFFFF,0,200+random(500)));
  end;

  for i:=0 to 50 do
  begin
   t:=randomvec(animstat*2+i*3,1.5);
   col:=round((-t.x+t.y)*80+70);
   Particlesystem_add(ExpsebparticleCreate(spcpos,t,random(100)/100+4.0,4.0,0.95,$FF000000+$20100*col {(random(50))},$00000000,random(500)+100));
  end;

  for i:=0 to 300 do
  begin
   t:=randomvec(animstat*2+i*3,1.5);
   d3dxvec3scale(t,t,2*fastinvsqrt(d3dxvec3lengthsq(t)));

   pos:=D3DXVector3(spcpos.x-t.x*10,spcpos.y-t.y*10,spcpos.z-t.z*10);
   pos:=spcpos;
   Particlesystem_add(ExpsebparticleCreate(pos,t,10.0,10.0,1-min(abs(t.y)/20,0.05),$10A02010,$00000000,random(50)+200));
  end;

  vege:=true;
 end;

 stopsound(31,123);
 stopsound(31,124);
 stopsound(31,1235);
end;

procedure TSpaceshipevent.aghangok;
var
sorrend:array [0..5] of shortint;
sortav:array [0..5] of single;
i,j,k:integer;
tt:single;
begin
 //admingömbök

 for i:=0 to 2 do
 begin
  sorrend[i]:=-1;
  sortav[i]:=100000;
 end;

 //Legközelebbi 6
 for i:=0 to high(agpos) do
 begin
  tt:=tavpointpointsq(agpos[i],campos);
  for j:=0 to 2 do
  begin
   if tt<sortav[j] then
   begin
    for k:=5 downto j+1 do
    begin
     sortav[k]:=sortav[k-1];
     sorrend[k]:=sorrend[k-1];
    end;
    sortav[j]:=tt;
    sorrend[j]:=i;
    break;
   end;
  end;
 end;

 for i:=0 to 2 do
 if sorrend[i]>=0 then
 begin
  if phstim<i*10 then break;
  playsound(15,false,i+123,false,agpos[sorrend[i]]);
  //d3dxvec3subtract(tmp,agpos[sorrend[i]],agvpos[sorrend[i]]);
  //d3dxvec3scale(tmp,tmp,-1000);
 // setsoundvelocity(15,i,tmp);
  setsoundproperties(15,i+123,0,round(15000+10000*perlin.Noise1D(phstim/100+i*3)+phstim*15),true,D3DXVector3zero);
 end
  else
   StopSound(30,i);
end;

procedure TSpaceshipEvent.nagyrobbanas(hol:TD3DXVector3);
var
i:integer;
t:TD3DXVector3;
col:byte;
begin
 for i:=0 to 50 do
 begin
  t:=hol;
  randomplus(t,animstat*10+i,15);
  Particlesystem_add(SimpleparticleCreate(t,randomvec(animstat*10+i,0.05),5,0,$00FFFF00,$01FF2010,random(20)+20));
 end;
 for i:=0 to 100 do
 begin
  t:=randomvec(animstat*2+i*3,1.5);
  col:=round((-t.x+t.y)*80+70);
  Particlesystem_add(ExpsebparticleCreate(hol,t,random(100)/100+3.0,3.0,0.95,$FF000000+$20100*col {(random(50))},$00000000,random(50)+20));
 end;
 if random(3)=0 then
 begin
  playsound(17,false,phstim,true,hol);
  setsoundproperties(17,phstim,-1000,11000+random(22000),true,hol);
 end;
end;

procedure TSpaceshipEvent.Step;
var
 m,i,j:integer;
 rnd,tmp:TD3DXVector3;
 vec1,vec2:TD3DXVector3;
 r2:single;
 sng:single;
 lfac:single;
 ap,eap:TD3DXVector3;
 plsvec:TD3DXVector3;
begin

{
 0: kis világító bigyó
 1:teleportálás
 2: megjelenik és elindul
 3: megáll és néz
 4: lõ kicsit
 5: lõ noobot
 6: tölt
 7: lõ
 8: admin lõ 50 kis golyót
 9: robbanás
 10: destroy
 }
 m:=0;
 if automatic then
 case phs of
  0:m:=7000;   //7000-re vissza!!!!!!!!444négy4
  1:m:=1000;
  2:m:=1000;
  3:m:=1500;
  4:m:=1000;
  5:m:=1000;
  6:m:=500;
  7:m:=700;
  8:m:=1500;
  9:m:=1200;
 end;

 if phstim>m then phase(phs+1);


  if (phs=0) or (phs=1) then
  begin
      //fekete lik
      spcpos:=beaconpos;
      vec1:=beaconpos;
      vec1.y:=vec1.y+30;
      vec1.x:=vec1.x+1;
      if (phstim mod 4)=0 then
       Particlesystem_add(fenykorCreate(vec1,randomvec(phstim,0.1),
                                        D3DXVector3(0,0,1),D3DXVector3(2.4,0,0),23,35,0.1,$FF000000,0,100));

     if (phstim mod 4)=0 then
      begin
       plsvec.x:=random(200)-100;
       plsvec.z:=random(200)-100;
       plsvec.y:=0;
       fastvec3normalize(plsvec);
       plsvec.x:=plsvec.x*5;
       plsvec.z:=plsvec.z*5;
       vec1.x:=vec1.x+plsvec.x*10;
       vec1.z:=vec1.z+plsvec.z*4;
       Particlesystem_Add_Villam(vec1,plsvec,5,0.25,5,1,$FF000000,20);
      end;
  end;

  if phs=1 then
  begin
   //megjelenik
   spcpos:=beaconpos;
  end;

  if phs=2 then
    begin
     //elindul
     //két alfázis: elindul
     D3DXVec3lerp(spcpos,beaconpos,vegpos,min(phstim/1000,1));
                                               //500/50=200/20
     rnd:=randomvec((phstim-1000)/100,1500/400);
     D3DXVec3add(spcpos,spcpos,rnd);
     D3DXVec3lerp(spcpos,beaconpos,spcpos,min(phstim/300,1));
    end;

  if phs=3 then
    begin
     //3: megáll és néz
     rnd:=randomvec(phstim/100,(1500-phstim)/400);
     D3DXVec3add(spcpos,vegpos,rnd);
    end;
  if phs=4 then
  begin
    //lõ kis lézereket
    spcpos:=vegpos;
    if phstim<800 then
    if (phstim mod 10)=0 then
    begin
     vec1:=vegpos;
     vec1.z:=vec1.z+40*(random(2)-0.5);
     randomplus(vec1,phstim,1);
     vec2:=vec1;
     vec2.x:=vec2.x+150;
     randomplus(vec2,phstim+100,20);
     vec2.x:=vec1.x+150;

     Particlesystem_add(fenycsikcreate(vec1,vec2,0.5,$A0FF1010,50));
     Particlesystem_add(fenycsikcreate(vec1,vec2,0.2,$A0A0A0A0,50));
     Particlesystem_add(simpleparticleCreate(vec2,D3DXvector3zero,1,10,$FFFF3030,0,70));

     playsound(29,false,phstim,true,vec1);
   //  setSoundProperties(29,phstim,0,40000,true,D3DXVector3Zero)
    end;
    if phstim=1100 then playsound(33,false,phstim,true,spcpos);
  end;

  if phs=5 then
  begin
    //lõ noobokat
    //... gondolom fõprogramban
    spcpos:=vegpos;
    kivec:=spcpos;
    kivec.y:=kivec.y-1;
    kivec.x:=kivec.x+40;
    kivec.z:=kivec.z+(random(2)-0.5)*2*(10+random(5));
    if phstim=800 then playsound(33,false,phstim,true,spcpos);
  end;

  if phs=6 then
    begin
     spcpos:=vegpos;
     playsound(31,true,123,true,spcpos);
     setsoundproperties(31,123,-200,22000+100*phstim,true,spcpos);

    end;

  if (phs>=6) and (phs<=8) then
    begin
     // töltés effekt

     tmp:=D3DXVector3(vegpos.x+random(phstim div 10)-10,vegpos.y,vegpos.z);
     Particlesystem_add(SimpleparticleCreate(tmp,D3DXvector3zero,5.0,4.0,$00C05025,0,40));

     for j:=0 to 2 do
     begin
      if (phs=6) then if j*150>phstim then break;
      vec1:=D3DXVector3(spcpos.x+9.7+j*7.7,spcpos.y+11,spcpos.z+9);
      vec2:=D3DXVector3(spcpos.x+9.7+j*7.7,spcpos.y-11,spcpos.z-9);
      for i:=0 to 9 do
      begin
       d3dxvec3lerp(ap,vec1,vec2,i/10);
       randomplus(ap,phstim*0.5,(5-abs(i-5)));
       d3dxvec3lerp(eap,vec1,vec2,(i+1)/10);
       randomplus(eap,phstim*0.5,(5-abs(i-4)));
       Particlesystem_add(fenycsikcreate(ap,eap,(6-abs(i-4.5))*0.2,$00B04020,5));
      end;
      vec1:=D3DXVector3(spcpos.x+9.7+j*7.7,spcpos.y+11,spcpos.z-9);
      vec2:=D3DXVector3(spcpos.x+9.7+j*7.7,spcpos.y-11,spcpos.z+9);
      for i:=0 to 9 do
      begin
       d3dxvec3lerp(ap,vec1,vec2,i/10);
       randomplus(ap,phstim*0.5,(5-abs(i-5)));
       d3dxvec3lerp(eap,vec1,vec2,(i+1)/10);
       randomplus(eap,phstim*0.5,(5-abs(i-4)));
       Particlesystem_add(fenycsikcreate(ap,eap,(6-abs(i-4.5))*0.2,$00B04020,5));
      end;
     end;

    end;

  if (phs=7) or (phs=8) then
    begin
     // lõ
     spcpos:=vegpos;
     vec1:=vegpos;
     randomplus(vec1,phstim,5);
     vec2:=vec1;
     vec2.x:=vec2.x+150;
     Particlesystem_add(fenycsikcreate(vec1,vec2,3,$00A02010,20));

     Particlesystem_add(simpleparticleCreate(vec2,D3DXvector3zero,10.0,10.0,$00C05025,0,20));
     vec1:=vegpos;
     vec2:=vec1;
     vec2.x:=vec2.x+150;
     for i:=3 to 9 do
     begin
      d3dxvec3lerp(ap,vec1,vec2,i/10);
      randomplus(ap,phstim,15);
      d3dxvec3lerp(eap,vec1,vec2,(i+1)/10);
      randomplus(eap,phstim,15);
      Particlesystem_add(fenycsikcreate(ap,eap,0.3,$00B04020,20));
     end;

     r2:=tavpointpoint(vec2,DNSVec);
     ap:=vec2;
     for i:=0 to 10 do
     begin
      eap:=ap;
      randomplus(ap,animstat+i*0.1,40);
      d3dxvec3subtract(ap,ap,DNSVec);
      d3dxvec3scale(ap,ap,fastinvsqrt(d3dxvec3lengthsq(ap))*r2);
      d3dxvec3add(ap,ap,DNSvec);

      Particlesystem_add(fenycsikcreate(eap,ap,(10-i)/3,colorlerp($00A02010,0,i/20),i*2+2));
     end;

     playsound(31,true,123,true,vec1);
     setsoundproperties(31,123,0,0,true,spcpos);
     if phstim>20 then
     playsound(31,true,124,true,vec2);

    end;
   if phs=8 then
    begin
     // admin lõ 50 kis golyót
     // 3 alfázis: fellövés, iránytartás,becsapódás
     agvpos:=agpos;
     for i:=0 to high(agpos) do
     begin
      vec1:=pantheonPos;
      vec1.y:=vec1.y-i*5+phstim*3;
      vec2:=randomvec(phstim*0.01+i*200,1);
      fastvec3normalize(vec2);                        
      if phstim>1000+i*5 then d3dxvec3scale(vec2,vec2,(100+1500-phstim)/(500-i*5));

      vec2:=D3DXVector3(vec2.x*90+vegpos.x,vec2.y*30+vegpos.y,vec2.z*60+vegpos.z);
      lfac:=(phstim*3-i*5-150)/500;
      if lfac<0 then lfac:=0;
      if lfac>1 then lfac:=1;
      D3DXVec3lerp(agpos[i],vec1,vec2,lfac);

      Particlesystem_add(Simpleparticlecreate(agpos[i],
                                          D3DXVector3Zero,
                                          3,0,$00606060,$00000060,20));
     end;


     if (random(10)=0) then
      if phstim>1250 then
      begin
       nagyrobbanas(D3DXVector3(vegpos.x+random(100)-50,vegpos.y+random(16)-8,vegpos.z+random(40)-20));
      end;


     aghangok;
    end;
  if phs=9 then
    begin
     // 7: robbanás és esés
     D3DXVec3subtract(spcpos,vegpos,D3DXVector3(-sqr(phstim/2000)*vegpos.y,sqr(phstim/2000)*vegpos.y,sqr(phstim/2000)*vegpos.y));

     sng:=1-1/(phstim*0.003+1);
     D3DXMatrixRotationAxis(matrot,D3DXVector3(1,0,1),-sng*0.7);

     
     if (random(5)=0) or (phstim<3) then
      if phstim<800 then
      begin
       d3dxvec3transformcoord(vec1,D3DXVector3(random(100)-50,random(16)-8,random(40)-20),matrot);
       d3dxvec3add(vec1,vec1,spcpos);
       nagyrobbanas(vec1);
      end
      else
      begin
       plsvec:=randomvec(phstim,1);
       fastvec3normalize(plsvec);
       d3dxvec3scale(plsvec,plsvec,7);
       Particlesystem_Add_Villam(spcpos,plsvec,7,0.25,5,1,$FFFFFFFF,20);
      end;

     if (phstim=1200-450) then
      playsound(32,false,12345,true,spcpos);
    end;

 if (phs>1) and (phs<9) then
 begin
  playsound(30,false,123,true,spcpos);
  //setsoundproperties(30,123,0,10000,true,spcpos);
 end;

 if phs<=1 then
 begin
  vec1:=beaconpos;
  vec1.y:=beaconpos.y+30;
  playsound(31,true,1235,true,vec1);

 end
 else
  stopsound(31,1235);

 inc(phstim);
 futotim:=futotim+0.03;
end;


procedure TSpaceshipEvent.fillvertbuf;
var
i,j:integer;
pvert:PColoredVertArray;
tmp:TD3DXVector3;
pls:single;
alph:byte;
col2:cardinal;
begin

  vertbuf.Lock(0,0,pointer(pvert),D3DLOCK_DISCARD);

  if phs=1 then
   for i:=0 to high(verts) do
    for j:=0 to 2 do
    begin
     tmp:=verts[i,j];
     pls:=max(i/6+30-phstim,0);
     tmp.y:=tmp.y+pls;
     alph:=round(255*
                (1-min(pls,30)/30)*
                 min(max((phstim/700),0.5),1)
                 );
     if phstim>745then alph:=max(round((1000-phstim)),0);
     pvert[i*3+j].position:=tmp;
     d3dxvec3scale(tmp,tmp,0.1);
     pvert[i*3+j].col:=$01000000*alph+colorlerp(0,round((perlin.Noise(tmp.x,tmp.y+phstim/20,tmp.z)+1.1)*120) shl 16,alph/255);
    end
  else
   for i:=0 to high(verts) do
    for j:=0 to 2 do
    begin
     tmp:=verts[i,j];
     if phstim>900 then
     begin
      //randomplus(tmp,phstim/100,(phstim-900)/2);
      pls:=1+perlin.Noise(tmp.x/20,tmp.y/20+phstim/20,tmp.z/20)*(phstim-900)*0.02;
      d3dxvec3scale(tmp,tmp,pls*(1200-phstim)/300);
      pvert[i*3+j].position:=tmp;
      d3dxvec3scale(tmp,tmp,0.1);
      col2:=$FFFF0000+round((perlin.Noise(tmp.x,tmp.y+phstim/200,tmp.z)+1.1)*120)*$0101;
      pvert[i*3+j].col:=colorlerp(col2,0,max(0,min(abs(1-pls),1)));
     end
     else
     begin
      pvert[i*3+j].position:=tmp;
      d3dxvec3scale(tmp,tmp,0.1);
      col2:=$FFFF0000+round((perlin.Noise(tmp.x,tmp.y+phstim/200,tmp.z)+1.1)*120)*$0101;
      pvert[i*3+j].col:=colorlerp(0,col2,min((phstim-800)/100,1));
     end;


    end;


  g_pMesh.UnlockVertexBuffer;


end;

procedure TSpaceshipEvent.RenderModels;
var
 mat,mat1,mat2:TD3DMatrix;
begin


 if (phs>1) and ((phs<9) or (phstim<900)) or ((phs=1) and (phstim>745)) then
 begin
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,  D3DTOP_MODULATE );
  D3DXMatrixTranslation(mat1,spcpos.x,spcpos.y,spcpos.z);
  D3DXMatrixMultiply(mat,matrot,mat1);

  g_pd3ddevice.SetTransform(D3DTS_WORLD,mat);
  g_pd3ddevice.settexture(0,fotex);
  g_pmesh.DrawSubset(0);

  g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_COUNT2);
  mat1:=identmatr;
  mat1._31:=futotim*0.25;
  g_pd3ddevice.SetTransform(D3DTS_TEXTURE0,mat1);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,  D3DTOP_SELECTARG1 );
  g_pd3ddevice.settexture(0,kekpirostex);
  g_pmesh.DrawSubset(2);

  mat1:=identmatr;
  mat1._31:=floor(futotim)*0.25;
  g_pd3ddevice.SetTransform(D3DTS_TEXTURE0,mat1);
  g_pd3ddevice.settexture(0,futotex);
  g_pmesh.DrawSubset(1);
 end;


 if (phs<2) then
 begin
   g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,  D3DTOP_SELECTARG1 );
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_COUNT3+D3DTTFF_PROJECTED);
    g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE, ifalse);
  mat1:=identmatr;
  mat1._11:=70;
  mat1._22:=70;
  mat1._31:=0;
  mat1._32:=0;

  mat2:=identmatr;
  mat2._31:=(campos.x-beaconpos.x)*0.5;
  mat2._32:=(campos.z-beaconpos.z)*0.5;
  mat2._33:=(beaconpos.y-campos.y+30)*0.2;

  d3dxmatrixmultiply(mat,mat1,mat2);
  g_pd3ddevice.SetTransform(D3DTS_TEXTURE0,mat);

  D3DXMatrixTranslation(mat,beaconpos.x,beaconpos.y+30,beaconpos.z);
  mat._11:=1.2;
  mat._22:=1.2;
  g_pd3ddevice.SetTransform(D3DTS_WORLD,mat);

  g_pd3ddevice.settexture(0,csilltex);
  g_pmesh.DrawSubset(3);
 end;

 if (phs=1) or ((phs=9) and (phstim>800)) then
 begin
  fillvertbuf;
  g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, itrue);
  g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, ifalse);
  g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_ONE);
  g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
  g_pd3ddevice.SetRenderState(D3DRS_BLENDOP,D3DBLENDOP_ADD);
  g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE, ifalse);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG2);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP,   D3DTOP_SELECTARG2);

  D3DXMatrixTranslation(mat1,spcpos.x,spcpos.y,spcpos.z);
  D3DXMatrixMultiply(mat,matrot,mat1);

  g_pd3ddevice.SetTransform(D3DTS_WORLD,mat);

  g_pd3dDevice.SetStreamSource(0, vertbuf, 0, SizeOf(TColoredVert));
  g_pd3dDevice.SetFVF(D3DFVF_COLOREDVERTEX);

  g_pd3dDevice.DrawPrimitive(D3DPT_TRIANGLELIST,0, length(verts));

  g_pd3dDevice.SetRenderState(D3DRS_ALPHABLENDENABLE, ifalse);
    g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, itrue);
 end;

   g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE, itrue);
 g_pd3ddevice.SetTransform(D3DTS_WORLD,identmatr);
 g_pd3ddevice.SetTransform(D3DTS_TEXTURE0,identmatr);

 g_pd3dDevice.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS,D3DTTFF_DISABLE);
end;

destructor TSpaceshipEvent.Destroy;
begin
 g_pMesh:=nil;
 fotex:=nil;
 g_pd3ddevice:=nil;
 inherited;
end;

// reactor

constructor TReactorEvent.Create(adevice : IDirect3ddevice9;are_pos:TD3DXVector3;dir:string);
begin
 inherited create;
 vege:=true;
 g_pD3Ddevice:=adevice;

 re_pos:=are_pos;
 kivec:=re_pos;
 kivec.y:=kivec.y+17;

 vege:=false;

 zeromemory(@(szikr_pos[0]),sizeof(TD3DXVector3)*5);
 zeromemory(@(szikr_seb[0]),sizeof(TD3DXVector3)*5);

 phase(0);
end;



procedure TReactorEvent.Phase(mi:integer);
var
vec1:TD3DXVector3;
seb1:TD3DXVector3;
i:integer;
begin

 phs:=mi;
 phstim:=0;

 {
 0: villámok
 1: összeszûkülõ fehér szar a felhõben (nagy fehér villanás a végén)
 2: nagy gömbök a reaktorba a felhõbõl (rövid)
 3:a reaktor megemelkedik, megnõ, a felhõ, kisülés eltûnik
 4: nagy kisülések (kanyargós izé... chain lightning, tudod te :D
 5: hasadások a gömbön (tremor style)
 6: elkezd rezegni mint a disznó, pöttyök mennek bele (sucking in lines)
 7: összemegy (HIRTELEN)
 8: fehér folt, várunk
 9: BIFF, elsõ lökéshullám, térrepedések (mint az üveg, eltörik a tér. De jól hangzik)
 10: Növevõ fehér folt
 11: teljes fehérség.
 }

 if (phs=1) then
 begin
  vec1:=re_pos;
  vec1.y:=vec1.y+200;
  d3dxvec3subtract(vec1,vec1,campos);
  d3dxvec3scale(vec1,vec1,1/100);
  particlesystem_add(simpleparticlecreate(campos,vec1,500,20,$202020,$FFFFFF,100));
   playsound(36,false,phstim,false,D3DXVector3(re_pos.x,re_pos.y+200,re_pos.z));

 end;

 if (phs=2) then
 begin
   vec1:=re_pos;
   vec1.y:=vec1.y+20;
   d3dxvec3lerp(vec1,campos,vec1,0.1);
   particlesystem_add(simpleparticlecreate(vec1,d3dxvector3zero,1,30,0,$40804020,200));


   vec1:=re_pos;
   vec1.y:=vec1.y+200;

   particlesystem_add(simpleparticlecreate(vec1,d3dxvector3zero,200,30,$FFFFFFFF,0,200));



  for i:=0 to 10 do
  begin
   seb1:=randomvec((i+phstim)*0.6456,500.5);
   seb1.y:=seb1.y/20;
   seb1.y:=seb1.y+200;
   d3dxvec3add(seb1,seb1,re_pos);

   particlesystem_add(fenycsik2create(vec1,seb1,5+random(5),$FFFFFFFF,0,200));
  end;

   playsound(38,false,5,false,D3DXVector3(re_pos.x,re_pos.y+200,re_pos.z));

 end;

 if phs=3 then
 begin
   vec1:=re_pos;
   vec1.y:=vec1.y+20;
   d3dxvec3lerp(vec1,campos,vec1,0.02);
   particlesystem_add(simpleparticlecreate(vec1,d3dxvector3zero,0,100,$FFFFFFFF,0,200));
   particlesystem_add(simpleparticlecreate(vec1,d3dxvector3zero,30,50,$40804020,0,100));
   d3dxvec3subtract(vec1,vec1,campos);
   d3dxvec3normalize(vec1,vec1);
   d3dxvec3add(vec1,vec1,campos);
   particlesystem_add(simpleparticlecreate(vec1,d3dxvector3zero,2,2,$808080,0,50));
    playsound(38,false,2,false,D3DXVector3(re_pos.x,re_pos.y+20,re_pos.z));

 end;

 if phs=7 then
 begin
  vec1:=re_pos;
  vec1.y:=vec1.y+20;
  d3dxvec3lerp(vec1,campos,vec1,0.02);
  particlesystem_add(simpleparticlecreate(vec1,d3dxvector3zero,4,0,$FFFFFF,0,50));
 end;

  if phs=9 then
 begin
  vec1:=re_pos;
  vec1.y:=vec1.y+20;
  d3dxvec3lerp(vec1,campos,vec1,0.02);
  particlesystem_add(simpleparticlecreate(vec1,d3dxvector3zero,40,0,$FFFFFF,0,50));
  playsound(39,false,2,false,D3DXVector3(re_pos.x,re_pos.y+20,re_pos.z));

 end;



end;


procedure TReactorEvent.Alapeffect;
var
tmp,vec1,tmp1,tmp2,vec2:TD3DXVector3;
i,j:integer;
camtav:single;
szog,tav:single;
re_Gk:TD3DXVector3;
begin
  re_gk:=kivec;

 
  camtav:=tavpointpoint(campos,re_gk);


   //Particlesystem_Add_Villam(re_szikr[random(length(re_szikr))],vec1,2,0.4,5,0.5,$FFFFFFFF,50);

   //kék háttér a gömbnek
 particlesystem_add(simpleparticlecreate(re_gk,randomvec(gettickcount mod 100000,0.5),40,40,$10402010,0,1));

 // az örvény
 tmp:=re_gk;
 tmp.y:=tmp.y+200;
 if phs<1 then
 for i:=0 to 2 do
 begin
  szog:=pi*random(10000)/5000;
  tav:=random(110);
  tmp1:=D3DXVector3(sin(szog)*tav,0,cos(szog)*tav);
  tmp2:=D3DXVector3(cos(szog)*0.3*150,0,-sin(szog)*0.3*150);
  d3dxvec3add(tmp1,tmp1,tmp);
  d3dxvec3subtract(tmp1,tmp1,tmp2);
  d3dxvec3scale(tmp2,tmp2,1/150);
  if tav>5 then
   particlesystem_add(simpleparticlecreate(tmp1,tmp2,(160-tav)/3,0,0,$FF000000+$010101*round(tav),150))
  else
   particlesystem_add(simpleparticlecreate(tmp1,tmp2,100,0,0,$80F08040,150))
 end;

 //a tripla csík cucc
 for i:=0 to 2 do
 begin
  vec1:=re_gk;
  for j:=0 to 20 do
  begin
   vec2:=vec1;
   tmp1:=randomvec(gettickcount/2000-j/20,j*5+5);
   tmp2:=randomvec(gettickcount/1000+i*100,30+j*2);
   if phs=1 then
   begin
    d3dxvec3scale(tmp1,tmp1,(100-phstim)/100);
    d3dxvec3scale(tmp2,tmp2,(100-phstim)/100);
   end;
   d3dxvec3lerp(vec1,tmp1,tmp2,sqr((j-10)/10));
   vec1.y:=(re_gk.y-re_pos.y+vec1.y*1+j*10);
   d3dxvec3add(vec1,vec1,re_pos);
   if j>0 then
   if (phs=1) and (phstim=99) then
    particlesystem_Add(fenycsik2create(vec1,vec2,2+j/4,min($808080,$101010*(10-abs(10-j))),min($808080,$101010*(10-abs(10-j))),200))
   else
    particlesystem_Add(fenycsik2create(vec1,vec2,2+j/4,min($808080,$101010*(10-abs(10-j))),min($808080,$101010*(10-abs(10-j))),1));
  end;
 end;

 //a szívott csíkok
 if camtav<150 then
 for i:=0 to 2 do
 begin
  tmp1:=randomvec(random(100000)/100+i*13.4567,3);
  d3dxvec3scale(tmp2,tmp1,1.2);
  d3dxvec3scale(vec1,tmp2,-50);
  d3dxvec3add(vec1,vec1,re_gk);
  particlesystem_Add(fenycsikubercreate(vec1,vec1,tmp1,tmp2,0.2,0,0,$808080,50));
 end;


 //for i:=0 to 0 do
 begin
  tmp1:=randomvec(gettickcount*1.234+random(100),70);
  tmp1.y:=0;
  d3dxvec3add(tmp1,tmp1,re_pos);
  d3dxvec3subtract(vec1,re_gk,tmp1);
  d3dxvec3scale(vec1,vec1,1/1000);
  particlesystem_Add(expsebparticlecreate(tmp1,vec1,5,2,1.03,0,$A0204020,100));
 end;


// particlesystem_add(simpleparticlecreate(re_gk,randomvec(gettickcount mod 100000,0.5),25,20,$FF000000,0,1));

end;

procedure TReactorEvent.sounds;
begin
 if (phs=0) then
  if random(150)=0 then
   playsound(40,false,phstim,false,D3DXVector3(re_pos.x,re_pos.y+200,re_pos.z));

 if (phs=5) and (phstim=300) then
  playsound(41,false,phstim,false,D3DXVector3(re_pos.x,re_pos.y+20,re_pos.z));

end;

procedure TReactorEvent.Step;
var
m:integer;
vec1,vec2:TD3DXVector3;
seb1:TD3DXVector3;
i:integer;
rnd:integer;
rad,rad2:single;
begin
 sounds;
{
 0: villámok
 1: összeszûkülõ fehér szar a felhõben (nagy fehér villanás a végén)
 2: nagy gömbök a reaktorba a felhõbõl
 3:a reaktor megemelkedik, megnõ, a felhõ, kisülés eltûnik
 4-5: nagy kisülések (kanyargós izé... chain lightning, tudod te :D
 5: hasadások a gömbön (tremor style)
 6: elkezd rezegni mint a disznó, pöttyök mennek bele (sucking in lines)
 7: összemegy (HIRTELEN)
 8: fehér folt, várunk
 9: BIFF, elsõ lökéshullám, térrepedések (mint az üveg, eltörik a tér. De jól hangzik)
 10: Növevõ fehér folt
 11: teljes fehérség.
 }
 m:=0;
 case phs of
 // 0:m:=2000;
  0:m:=2000;
  1:m:=100;
  2:m:=200;
  3:m:=300;
  4:m:=10;
  5:m:=500;
  6:m:=200;
  7:m:=100;
  8:m:=100;
  9:m:=100;
  10:m:=600;
  11:m:=10000;
 end;

 if phstim>m then phase(phs+1);

 if phs<2 then
  alapeffect;

 if phs<7 then
  particlesystem_add(simpleparticlecreate(kivec,randomvec(gettickcount mod 100000,0.5),25,20,$FF000000,0,1));

 if (phs=0) or (phs=1) then
 if random(30)=0 then
 begin
  vec1:=randomvec(phstim*1.2345,150);
  vec1.y:=200;
  d3dxvec3add(vec1,vec1,re_pos);
  seb1:=D3DXVector3Zero;
  seb1.y:=seb1.y-15;
  particlesystem_Add_villam(vec1,seb1,10,0.1,13,1,$FFFFFF,30);
 end;

 if phs=2 then
 if phstim<170 then
 if random(20)=0 then
 begin
  vec1:=re_pos;
  vec1.y:=vec1.y+200;
  particlesystem_add(simpleparticlecreate(vec1,d3dxvector3(0,-4,0),30,30,$A0A0A0,$A0A0A0,50));
  particlesystem_add(simpleparticlecreate(vec1,d3dxvector3(0,0,0),50,30,$A0A0A0,$A0A0A0,50));

 end;

 if phs=3 then
 begin
  //kivec:=re_pos;
  //kivec.y:=kivec.y+(phstim-phstim*phstim/600)*0.6;
 end;

 if (phs=3) or (phs=4) or (phs=5) then
 begin
  if (phstim mod 20)=0 then
  begin
   szikr_pos[(phstim div 20) mod 10]:=kivec;
   szikr_seb[(phstim div 20) mod 10]:=randomvec(random(100000)*1.234,30);
  end;

  for i:=0 to 9 do
  begin
   seb1:=randomvec((phstim+i*500)*0.05,30);
   seb1.y:=seb1.y-5;
   d3dxvec3lerp(szikr_seb[i],szikr_seb[i],seb1,0.02);
   vec1:=randomvec(phstim-1,10);
   d3dxvec3add(vec1,vec1,szikr_pos[i]);

   d3dxvec3add(szikr_pos[i],szikr_pos[i],szikr_seb[i]);

   vec2:=randomvec(phstim,10);
   d3dxvec3add(vec2,vec2,szikr_pos[i]);

   particlesystem_add(fenycsik2create(vec2,vec1,0.5,$FFFFFF,$FAFAFA,20));

   if random(10)=0 then
   if szikr_pos[i].y>10 then
   begin
    rnd:=(phstim div 20 + 5 + random(5)) mod 10 ;
    szikr_pos[rnd]:=szikr_pos[i];
    szikr_seb[rnd]:=szikr_seb[i];
    randomplus(szikr_seb[rnd],phstim*1.2345,4);
    //if phs>3 then
    playsound(37,false,phstim,false,szikr_pos[rnd]);

   end;
  end;
 end;

 if phs=7 then
  particlesystem_add(simpleparticlecreate(kivec,randomvec(gettickcount mod 100000,0.5),25-phstim/4,20-phstim/4,$FF000000+$010101*5*cardinal(phstim),0,1));
 if phs=8 then
  particlesystem_add(simpleparticlecreate(kivec,randomvec(gettickcount mod 100000,0.5),5,4,$FFFFFFFF,0,1));


 if phs=9 then
 begin
  for i:=0 to 30 do
  begin
   rad :=    i*D3DX_PI/15;
   rad2:=(i+1)*D3DX_PI/15;

   vec1:=D3DXVector3(sin(rad )*phstim*2,0,cos(rad )*phstim*2);
   vec2:=D3DXVector3(sin(rad2)*phstim*2,0,cos(rad2)*phstim*2);
   d3dxvec3add(vec1,vec1,kivec);
   d3dxvec3add(vec2,vec2,kivec);
   particlesystem_add(fenycsikubercreate(vec1,vec2,randomvec(i+phstim*100,2),randomvec(i+1+phstim*100,2),2,2,$A0A0A0,0,20));
  end;

  for i:=0 to phstim div 5 do
  begin
   rnd:=random(length(toresek)+1)-1;
   if (rnd=-1) or (random(20)=0) then
   begin
    setlength(toresek,length(toresek)+1);
    rnd:=high(toresek);
    toresek[rnd].vec1:=randomvec(random(10000),5);
    toresek[rnd].vec2:=randomvec(random(10000),5);
    toresek[rnd].elagazik:=0;
    toresek[rnd].elozo:=-1;
   end
   else
   begin
    if rnd<high(toresek) div 2 then
     rnd:=rnd+high(toresek) div 2;
    while (rnd<high(toresek)) and (toresek[rnd].elagazik>1) do
     inc(rnd);

    setlength(toresek,length(toresek)+1);
     toresek[high(toresek)]:=toresek[rnd];
    d3dxvec3add(vec1,toresek[high(toresek)].vec1,toresek[high(toresek)].vec2);
    d3dxvec3scale(vec1,vec1,50*fastinvsqrt(d3dxvec3lengthsq(vec1)));

    d3dxvec3add(toresek[high(toresek)].vec1,toresek[high(toresek)].vec1,vec1);
    d3dxvec3add(toresek[high(toresek)].vec1,toresek[high(toresek)].vec1,randomvec(random(10000),50));

    d3dxvec3add(toresek[high(toresek)].vec2,toresek[high(toresek)].vec2,vec1);
    d3dxvec3add(toresek[high(toresek)].vec2,toresek[high(toresek)].vec2,randomvec(random(10000),50));

    d3dxvec3subtract(vec1,toresek[high(toresek)].vec2,toresek[high(toresek)].vec1);
    d3dxvec3normalize(vec2,vec1);
    d3dxvec3scale(vec1,vec2,-(20-d3dxvec3length(vec1))*0.5);

    d3dxvec3add     (toresek[high(toresek)].vec1,toresek[high(toresek)].vec1,vec1);
    d3dxvec3subtract(toresek[high(toresek)].vec2,toresek[high(toresek)].vec2,vec1);

    toresek[high(toresek)].elozo:=rnd;
    inc(toresek[rnd].elagazik);
   end;
  end;
 end;

 if phs=10 then
 begin
  vec1:=re_pos;
  vec1.y:=vec1.y+20;
  d3dxvec3lerp(vec1,vec1,campos,phstim/600);
  particlesystem_add(simpleparticlecreate(vec1,d3dxvector3zero,phstim div 10,phstim div 10,$FF000000,0,1));
 end;

 inc(phstim);
end;

procedure TReactorEvent.RenderModels;
const
COLOR_ALUL=$FFFFFFFF;
COLOR_FELUL=$FFFFFF;
COLOR_TORES=$80000000;//$80FFFFFF;
var
 vecarr:array of TColoredVert;
 vechg:integer;
 ujvec,ujvec2,regivec:TD3DXVector3;
 vec,vec2:TD3DXVector3;
 i:integer;
 tim2,tim3:integer;
 mat,mat2,matossz:TD3DMAtrix;
begin

 if (phs>=5) and (phs<=8) then
 begin
  tim2:=phstim;
  if phs=6 then tim2:=tim2+300;
  if phs=7 then tim2:=tim2+500;
  if phs=8 then tim2:=tim2+500;
  if tim2>200 then tim3:=200 else tim3:=tim2;
  setlength(vecarr,tim3*2);
  vechg:=0;
  ujvec:=D3DXVector3zero;
  ujvec2:=ujvec;
  for i:=1 to tim3 do
  begin
   regivec:=ujvec;
   ujvec:=randomvec(tim2*0.01+i*0.05,1);
   fastvec3normalize(ujvec);

   if phs=6 then
    randomplus(ujvec,i*1+100,0.2+phstim*0.01)
   else
    randomplus(ujvec,i*1+100,0.2);

   d3dxvec3scale(ujvec,ujvec,17);
   if phs=7 then
    d3dxvec3scale(ujvec,ujvec,10/(phstim+10));
   if phs=8 then
    d3dxvec3scale(ujvec,ujvec,10/110);
    
   d3dxvec3scale(ujvec2,ujvec,4);
   vec:=randomvec(tim2*0.03+i*0.1+100,20);
   d3dxvec3add(ujvec2,ujvec2,vec);
   vecarr[vechg+0].position:=ujvec;
   vecarr[vechg+0].col     :=COLOR_ALUL;
   vecarr[vechg+1].position:=ujvec2;
   vecarr[vechg+1].col     :=COLOR_FELUL;

   vechg:=vechg+2;

   d3dxvec3add(vec,ujvec,kivec);
   d3dxvec3add(vec2,regivec,kivec);

   particlesystem_Add(fenycsikcreate(vec,vec2,0.4,$FFFFFFFF,5));
  end;
  d3dxmatrixtranslation(mat,kivec.x,kivec.y,kivec.z);
  g_pd3ddevice.SetTransform(D3DTS_WORLD,mat);
  g_pd3ddevice.SetFVF(D3DFVF_COLOREDVERTEX );

  g_pd3ddevice.setrenderstate(D3DRS_LIGHTING,ifalse);
  g_pd3ddevice.SetRenderState(D3DRS_ALPHABLENDENABLE,iTrue);
  g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
  g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,  D3DBLEND_INVSRCALPHA);
  g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE,iFalse);
  g_pd3ddevice.SetRenderstate(D3DRS_CULLMODE,D3DCULL_NONE);
  g_pd3ddevice.SetRenderstate(D3DRS_ZENABLE,iFalse);

  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG2);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_SELECTARG2);
  g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);

  g_pd3ddevice.DrawPrimitiveUP(D3DPT_TRIANGLESTRIP,tim3*2-2,vecarr[0],sizeof(TColoredvert));


  g_pd3ddevice.SetRenderstate(D3DRS_ZENABLE,iTrue);
  g_pd3ddevice.setrenderstate(D3DRS_LIGHTING,iTrue);
  g_pd3ddevice.SetRenderState(D3DRS_ALPHABLENDENABLE,iFalse);
  g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE,iTrue);
  g_pd3ddevice.SetTransform(D3DTS_WORLD,identmatr);
  g_pd3ddevice.SetRenderstate(D3DRS_CULLMODE,D3DCULL_CCW);
 end;

 if (phs=9) or (phs=10) then
 begin
  setlength(vecarr,0);
  for i:=0 to high(toresek) do
   if toresek[i].elozo>=0 then
   begin
    vechg:=length(vecarr);
    setlength(vecarr,length(vecarr)+6);
    vecarr[vechg+0].col:=COLOR_TORES;
    vecarr[vechg+0].position:=toresek[i].vec1;
    vecarr[vechg+1].col:=COLOR_TORES;
    vecarr[vechg+1].position:=toresek[i].vec2;
    vecarr[vechg+2].col:=COLOR_TORES;
    vecarr[vechg+2].position:=toresek[toresek[i].elozo].vec1;

    vecarr[vechg+3].col:=COLOR_TORES;
    vecarr[vechg+3].position:=toresek[toresek[i].elozo].vec2;
    vecarr[vechg+4].col:=COLOR_TORES;
    vecarr[vechg+4].position:=toresek[i].vec2;
    vecarr[vechg+5].col:=COLOR_TORES;
    vecarr[vechg+5].position:=toresek[toresek[i].elozo].vec1;
   end;
   d3dxmatrixrotationy(mat2,gettickcount/10000);
   d3dxmatrixtranslation(mat,kivec.x,kivec.y,kivec.z);
   d3dxmatrixmultiply(matossz,mat2,mat);
   d3dxmatrixscaling(mat,1+phstim/800,1+phstim/800,1+phstim/800);
   d3dxmatrixmultiply(mat2,mat,matossz);

  g_pd3ddevice.SetTransform(D3DTS_WORLD,mat2);


    g_pd3ddevice.setrenderstate(D3DRS_LIGHTING,ifalse);
  g_pd3ddevice.SetRenderState(D3DRS_ALPHABLENDENABLE,iTrue);
  g_pd3dDevice.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
  g_pd3dDevice.SetRenderState(D3DRS_DESTBLEND,  D3DBLEND_INVSRCALPHA);
  g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE,iFalse);
  g_pd3ddevice.SetRenderstate(D3DRS_CULLMODE,D3DCULL_NONE);
  g_pd3ddevice.SetRenderstate(D3DRS_ZENABLE,iTrue);

  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG2);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
  g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_SELECTARG2);
  g_pd3dDevice.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);

   g_pd3ddevice.SetFVF(D3DFVF_COLOREDVERTEX );
  g_pd3ddevice.DrawPrimitiveUP(D3DPT_TRIANGLELIST,length(vecarr) div 3,vecarr[0],sizeof(TColoredvert));


  g_pd3ddevice.SetRenderstate(D3DRS_ZENABLE,iTrue);
  g_pd3ddevice.setrenderstate(D3DRS_LIGHTING,iTrue);
  g_pd3ddevice.SetRenderState(D3DRS_ALPHABLENDENABLE,iFalse);
  g_pd3ddevice.SetRenderState(D3DRS_FOGENABLE,iTrue);
  g_pd3ddevice.SetTransform(D3DTS_WORLD,identmatr);
  g_pd3ddevice.SetRenderstate(D3DRS_CULLMODE,D3DCULL_CCW);
 end;

end;

destructor TReactorEvent.Destroy;
begin
 g_pd3ddevice:=nil;
 inherited;
end;

end.
