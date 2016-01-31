unit main;

interface

uses
  Windows,Messages,SysUtils,Classes,Graphics,Controls,Forms,Dialogs,
  StdCtrls,Direct3D9,D3DX9,typestuff,math,perlinnoise,ExtCtrls;

type
  TForm1=class(TForm)
    Button1:TButton;
    OD1:TOpenDialog;
    resg:TRadioGroup;
    jpgchk:TCheckBox;
    Label1:TLabel;
    kellLMchk:TCheckBox;
    buttonLang:TButton;
    procedure Buton1Click(Sender:TObject);
    procedure FormCreate(Sender:TObject);
    procedure FormClose(Sender:TObject;var Action:TCloseAction);
    procedure Button2Click(Sender:TObject);
    procedure LangClick(Sender:TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
const
  q1=50;//quality...
  q2=200;

  lghtszor=0.002;
  blurszam=0;
  sorok:array[0..5] of byte=(9,8,7,6,4,1);
var
  Form1:TForm1;
  g_pD3D:IDirect3d9;
  g_pd3ddevice:Idirect3ddevice9;
  tris:Tacctriarr;
  flaggie:array of boolean;
  PRT:ID3DXPRTEngine;
  mesh,mesh2:ID3DXMesh;
  myrand1:array[0..q1*10+13] of TD3DXVector3;
  myrand2:array[0..q2*10+17] of TD3DXVector3;
  mrnd1,mrnd2:integer;
  KDTree:TKDTree;
  KDData,aktual:TKDData;
  mitne:integer;
  lghtvert:array of TD3DXVector3;
  siz:integer=256;
  szetvalaszt:single=2;//1 az alap
  LanguageId:integer;

  procedure setUiLanguage(lang:Single);


implementation

{$R *.DFM}

function TRY3D(hwVP:boolean;hWnd:HWND):boolean;
var
  d3dpp:TD3DPresentParameters;
  hiba:HRESULT;

begin
  FillChar(d3dpp,SizeOf(d3dpp),0);
  d3dpp.Windowed:=true;
  d3dpp.SwapEffect:=D3DSWAPEFFECT_DISCARD;
  d3dpp.BackBufferFormat:=D3DFMT_UNKNOWN;
  d3dpp.BackBufferWidth:=100;
  d3dpp.BackBufferHeight:=100;
  d3dpp.EnableAutoDepthStencil:=True;
  d3dpp.AutoDepthStencilFormat:=D3DFMT_D16;

  hiba:=g_pD3D.CreateDevice(D3DADAPTER_DEFAULT,D3DDEVTYPE_HAL,hWnd,
    D3DCREATE_SOFTWARE_VERTEXPROCESSING,
    @d3dpp,g_pd3dDevice);
  result:=not FAILED(hiba);
end;
//-----------------------------------------------------------------------------
// Name: InitD3D()
// Desc: Initializes Direct3D
//-----------------------------------------------------------------------------

function InitD3D(hWnd:HWND):HRESULT;

begin
  Result:=E_FAIL;

  // Create the D3D object.
  g_pD3D:=Direct3DCreate9(D3D_SDK_VERSION);
  if (g_pD3D=nil) then
  begin
    messagebox(hwnd,'D3DCreate error.','Error',0);
    Exit;
  end;

  // Set up the structure used to create the D3DDevice. Since we are now
  // using more complex geometry, we will create a device with a zbuffer.
  if not TRY3D(false,hwnd) then
  begin
    messagebox(hWnd,'No available D3D9 devices.','Error',0);
    exit;
  end;
  Result:=S_OK;
end;

procedure computeflaggie(origin,normal:TD3DXVector3);
var
  i:integer;
  tmp0,tmp1,tmp2:TD3DVector;
  szam:integer;
begin
  exit;
  szam:=0;
  for i:=0 to high(tris) do
    with tris[i] do
    begin
      d3dxvec3subtract(tmp0,v0,origin);
      d3dxvec3subtract(tmp1,v1,origin);
      d3dxvec3subtract(tmp2,v2,origin);
      flaggie[i]:=(d3dxvec3dot(n,normal)<0)and(
        (d3dxvec3dot(tmp0,normal)<=0)or
        (d3dxvec3dot(tmp1,normal)<=0)or
        (d3dxvec3dot(tmp2,normal)<=0));
      if flaggie[i] then inc(szam);
      //flaggie[i]:=true;

    end;
  exit;
  if szam<high(flaggie)div 2 then exit;

  for i:=0 to high(tris) do
    with tris[i] do
    begin
      d3dxvec3subtract(tmp0,v0,origin);
      d3dxvec3subtract(tmp1,v1,origin);
      d3dxvec3subtract(tmp2,v2,origin);
      flaggie[i]:=(d3dxvec3dot(n,normal)>0)and(
        (d3dxvec3dot(tmp0,normal)<=0)or
        (d3dxvec3dot(tmp1,normal)<=0)or
        (d3dxvec3dot(tmp2,normal)<=0));
      //if flaggie[i] then inc(szam);
      //flaggie[i]:=true;

    end;


end;


function raytrace(r1,r2:TD3DXVector3):boolean;
var
  i:integer;
  r3:TD3DXVector3;
  res:longbool;
  az,bz:word;
  buf:ID3DXBuffer;

  a,b,c:single;
begin
  setlength(aktual,0);
  traverseKDTreelinDNT(r1,r2,aktual,KDData,KDTree,tris,COLLISION_SHADOW);
  d3dxvec3subtract(r3,r1,r2);
  { setlength(AKTUAL,length(tris));
   for i:=0 to high(tris) do
    aktual[i]:=i;   }

  for i:=0 to high(aktual) do
    if aktual[i]<>mitne then
      //if d3dxvec3dot(tris[aktual[i]].n,r3)>0 then
      if intlinetriacc(tris[aktual[i]],r1,r2) then
      begin
        result:=true;exit; end;

  result:=false;

end;


procedure tracelightmaptri(tri:array of TojjektumVertex;hova:TCanvas;meret:word);
var
  i,j,x,y,rtx,rty:integer;
  minu,minv,maxu,maxv:single;
  bv:array[0..2] of TojjektumVertex;
  ib,it:double;
  fx,fy:single;
  bary,clamp:array[0..2] of single;
  lm,dist:array[0..1] of single;
  a,b,c:boolean;
  origin,normal,norm,r2,tv1,tv2:TD3DXvector3;
  vil,vil2,vil3,tmp:single;
  srtx:single;
  sy,cy,sx,cx:extended;

begin

  { create bverts from the drawverts }
  minu:=99999;
  minv:=99999;
  maxu:=-99999;
  maxv:=-99999;
  d3dxvec3subtract(tv1,tri[2].position,tri[0].position);
  d3dxvec3subtract(tv2,tri[1].position,tri[0].position);
  d3dxvec3cross(normal,tv1,tv2);
  d3dxvec3normalize(normal,normal);
  for i:=0 to 2 do
  begin
    { copy the relevant data }
    bv[i]:=tri[i];
    bv[i].lu:=tri[i].lu*meret;
    bv[i].lv:=tri[i].lv*meret;

    { expand bounds }
    if ((bv[i].lu-0.5)<minu) then
      minu:=(bv[i].lu-0.5);
    if ((bv[i].lv-0.5)<minv) then
      minv:=(bv[i].lv-0.5);
    if ((bv[i].lu-0.5)>maxu) then
      maxu:=(bv[i].lu+0.5);
    if ((bv[i].lv-0.5)>maxv) then
      maxv:=(bv[i].lv+0.5);
  end;

  { clamp bounds }
  if (minu<0) then
    minu:=0;
  if (minv<0) then
    minv:=0;
  if (maxu>(meret-1)) then
    maxu:=(meret-1);
  if (maxv>(meret-1)) then
    maxv:=(meret-1);

  { calculate inverse baricentric divisor }
  ib:=((bv[1].lu-bv[0].lu)*(bv[2].lv-bv[0].lv)-
    (bv[2].lu-bv[0].lu)*(bv[1].lv-bv[0].lv));
  if ib<>0 then ib:=1/ib else ib:=1;
  { rasterize the triangle }
  for y:=Floor(minv)to ceil(maxv) do
  begin
    for x:=Floor(minu)to ceil(maxu) do
    begin
      { make floating point coords }
      fx:=x+0.5;
      fy:=y+0.5;

      { calculate barycentric coordinates for this sample (fixme: optimize this) }
      bary[0]:=ib*((bv[1].lu-fx)*(bv[2].lv-fy)-
        (bv[2].lu-fx)*(bv[1].lv-fy));
      bary[1]:=ib*((bv[2].lu-fx)*(bv[0].lv-fy)-
        (bv[0].lu-fx)*(bv[2].lv-fy));
      bary[2]:=ib*((bv[0].lu-fx)*(bv[1].lv-fy)-
        (bv[1].lu-fx)*(bv[0].lv-fy));

      { make positive edge flags }
      a:=(bary[0]>=0);
      b:=(bary[1]>=0);
      c:=(bary[2]>=0);

      { make clamped barycentric coords }
      if (a and b and c) then
        clamp:=bary//* fully inside triangle */
      else continue;



      { calculate clamped lightmap coordinates }
      lm[0]:=0;
      lm[1]:=0;
      for i:=0 to 2 do
      begin
        lm[0]:=lm[0]+clamp[i]*bv[i].lu;
        lm[1]:=lm[1]+clamp[i]*bv[i].lv;
      end;


      { calculate xyz and normal for this sample }
      origin:=d3dxvector3zero;

      for i:=0 to 2 do
      begin
        origin.x:=origin.x+clamp[i]*bv[i].position.x;
        origin.y:=origin.y+clamp[i]*bv[i].position.y;
        origin.z:=origin.z+clamp[i]*bv[i].position.z;
      end;

      origin.x:=origin.x-normal.x*0.001;
      origin.y:=origin.y-normal.y*0.001;
      origin.z:=origin.z-normal.z*0.001;

      computeflaggie(origin,normal);

      vil:=0;
      vil2:=0;
      if d3dxvec3dot(normal,d3dxvector3(sqrt2/2,sqrt2/2,0))<0 then
        for i:=1 to q1 do
        begin

          inc(mrnd1);if mrnd1>high(myrand1) then mrnd1:=0;
          d3dxvec3add(r2,origin,myrand1[mrnd1]);
          if not raytrace(r2,origin) then
            vil:=vil+1;
        end;
      vil:=-vil*d3dxvec3dot(normal,d3dxvector3(sqrt2/2,sqrt2/2,0))/q1;

      if vil<0 then vil:=0;
      for i:=1 to q2 do
      begin

        inc(mrnd2);if mrnd2>high(myrand2) then mrnd2:=0;
        r2:=myrand2[mrnd2];

        tmp:=-d3dxvec3dot(r2,normal);
        d3dxvec3add(r2,r2,origin);
        if tmp>0 then
          if not raytrace(r2,origin) then
            vil2:=vil2+tmp;
      end;

      vil3:=0;
      for i:=0 to high(lghtvert) do
      begin

        d3dxvec3subtract(r2,origin,lghtvert[i]);
        tmp:=d3dxvec3lengthsq(r2);
        tmp:=d3dxvec3dot(r2,normal)*fastinvsqrt(tmp)/tmp;
        if tmp>0 then
          if not raytrace(lghtvert[i],origin) then
            vil3:=vil3+tmp;
      end;
      if vil3*lghtszor>0.8 then vil3:=0.8/lghtszor;
      vil2:=(1-power(0.1,(vil2/(q2*100))))/2;
      vil:=vil*0.5+vil2+vil3*lghtszor+0.1;

      if vil<0 then vil:=0;
      { vil:=(vil/4+1-power(0.1,vil))*0.7;   }
      if vil>1 then vil:=1;
      hova.pixels[x,y]:=$010101*round(vil*$FF);
    end
  end
end;

procedure TForm1.FormCreate(Sender:TObject);
begin
  randomize;
  if FAILED(InitD3D(handle)) then close;
  OD1.InitialDir:=extractfilepath(application.ExeName);
  LanguageId:=GetSystemDefaultLangID and $3FF;
  SetUiLanguage(LanguageId);

end;

var
  procid:cardinal;

procedure startprocwithid(mit,params:string);
var
  startupinfo:Tstartupinfo;
  procinf:TProcessInformation;
begin
  zeromemory(@startupinfo,sizeof(startupinfo));
  startupinfo.cb:=sizeof(startupinfo);
  createprocess(nil,Pchar(mit+' '+params),nil,nil,false,0,nil,nil,startupinfo,procinf);
  procid:=procinf.hProcess;
end;


procedure TForm1.Buton1Click(Sender:TObject);
type
  PD3DXMaterialArray=^TD3DXMaterialArray;
  TD3DXMaterialArray=array[0..100] of TD3DXMaterial;
var
  pVert:POjjektumvertexarray;
  pInd:Pwordarray;
  pattr:Pdwordarray;
  i,j,k,trinum,hol,hol2,oda,x,y:integer;
  hch:integer;// High(charts)
  kapcsk,charts:array of Tintarr;
  ind:Tintarr;
  tegs,ktegs:array of Tsinglerect;
  minu,minv,maxu,maxv,scal,scal2:single;
  ossz:Tintarr;
  rect,wantrect:array of Tsinglerect;
  tmp:Tsinglerect;
  itmp:integer;
  mx,my:single;
  trimost:array[0..2] of Tojjektumvertex;
  bmp:Tbitmap;
  nummat:dword;
  mat:ID3DXBuffer;
  error:HRESULT;
  most:cardinal;
  fil:string;
  indexes:TKDData;
  teg:TAABB;
  mats:PD3DXMaterialArray;
  lght:integer;
  lghtsind:Tintarr;
  adj:pointer;
  exitc:cardinal;
  str:string;
  buf:Pchar;
  kellLM:boolean;
  whydoweneedthis:TOjjektumTexture;
begin
  siz:=strtoint(resg.items[resg.itemindex]);
  label1.caption:='Loading';
  repaint;
  randomize;
  perlin:=Tperlinnoise.create(25);
  OD1.Execute;
  fil:=OD1.FileName;

  whydoweneedthis.collisionflags:=$FFFFFFFF;
  whydoweneedthis.material:=0;

  if ExtractFileExt(fil)='.3ds' then
  begin
    label1.caption:='Converting to .x';
    if jpgchk.Checked then
      startprocwithid('conv3ds.exe','-N -m -e "jpg" "'+fil+'" ')
    else
      startprocwithid('conv3ds.exe','-N -m "'+fil+'"');
    repeat
      Getexitcodeprocess(procid,exitc);
    until exitc<>STILL_ACTIVE;

    fil:=stringreplace(fil,'.3ds','.x', [rfReplaceAll,rfIgnoreCase]);
  end;

  kellLM:=false;
  if not kellLMchk.Checked then
    kellLM:=true;

  if FAILED(D3DXLoadMeshFromX(PChar(fil),D3DXMESH_SYSTEMMEM,g_pd3ddevice,nil,@mat,nil,@nummat,mesh2)) then exit;

  label1.caption:='Loading .x';

  mats:=mat.GetBufferPointer;
  lght:=-1;
  for i:=0 to nummat-1 do
  begin
    if mats[i].pTextureFilename=nil then
    begin
      MessageBox(0,Pchar('Material #'+inttostr(i)+' has no texture. This may cause a nuclear apocalypse. In order to prevent that, this program will now exit.'),'Hmpf',0);
      Close;
      exit;
    end
    else
    begin
      str:=string(mats[i].pTextureFilename);
      str:=ExtractFileName(str);
      strcopy(mats[i].pTextureFilename,PChar(str));
      if (mats[i].pTextureFilename='lght.bmp')or
        (mats[i].pTextureFilename='lght.jpg') then
        lght:=i;
    end;
  end;

  if FAILED(mesh2.CloneMeshFVF(D3DXMESH_SYSTEMMEM,D3DFVF_OJJEKTUMVERTEX,g_pd3ddevice,Mesh)) then exit;

  getmem(adj,mesh.getnumfaces*12);
  mesh.GenerateAdjacency(0.0001,adj);
  mesh.OptimizeInplace(D3DXMESHOPT_VERTEXCACHE+D3DXMESHOPT_ATTRSORT+D3DXMESHOPT_COMPACT+D3DXMESHOPT_DEVICEINDEPENDENT,adj,nil,nil,nil);
  freemem(adj);

  if FAILED(mesh.LockVertexBuffer(D3DLOCK_DISCARD,pointer(pvert))) then exit;
  if FAILED(mesh.LockIndexBuffer(D3DLOCK_DISCARD,pointer(pind))) then exit;
  if FAILED(mesh.LockAttributeBuffer(D3DLOCK_DISCARD,Pdword(pattr))) then exit;


  for i:=0 to mesh.GetNumVertices-1 do
  begin
    pvert[i].position:=D3DXVector3(-pvert[i].position.x,pvert[i].position.y,-pvert[i].position.z);//forgatás 180-al
  end;


  trinum:=mesh.GetNumFaces;

  for i:=0 to trinum-1 do //késõbb hozzáírva: itt végigmegyünk a triken és ahol tök azonos két tri uv-ja (lightmap uv?) ott eltoljuk az egyiket
    for j:=0 to trinum-1 do
    begin
      if
      (pvert[pind[i*3+0]].tu = pvert[pind[j*3+0]].tu) and
      (pvert[pind[i*3+1]].tu = pvert[pind[j*3+1]].tu) and
      (pvert[pind[i*3+2]].tu = pvert[pind[j*3+2]].tu) and
      
      (pvert[pind[i*3+0]].tv = pvert[pind[j*3+0]].tv) and
      (pvert[pind[i*3+1]].tv = pvert[pind[j*3+1]].tv) and
      (pvert[pind[i*3+2]].tv = pvert[pind[j*3+2]].tv)
      then
      begin
        k:=random(100) + 1;

        pvert[pind[j*3+0]].tu:=pvert[pind[j*3+0]].tu+k;
        pvert[pind[j*3+1]].tu:=pvert[pind[j*3+1]].tu+k;
        pvert[pind[j*3+2]].tu:=pvert[pind[j*3+2]].tu+k;

        pvert[pind[j*3+0]].tv:=pvert[pind[j*3+0]].tv+k;
        pvert[pind[j*3+1]].tv:=pvert[pind[j*3+1]].tv+k;
        pvert[pind[j*3+2]].tv:=pvert[pind[j*3+2]].tv+k;
      end;
    end;


  if lght>=0 then
    for i:=0 to trinum do
      if pattr[i]=lght then
      begin
        Badd(lghtsind,pind[i*3+0]);
        Badd(lghtsind,pind[i*3+1]);
        Badd(lghtsind,pind[i*3+2]);
      end;
  mesh.UnLockAttributeBuffer;

  setlength(lghtvert,length(lghtsind));
  for i:=0 to high(lghtsind) do
    lghtvert[i]:=pvert[lghtsind[i]].position;
  setlength(lghtsind,0);

  setlength(flaggie,trinum);
  setlength(tris,trinum);
{$R-}
  for i:=0 to trinum-1 do
  begin
    tris[i]:=makeacc(pvert[pind[i*3+0]].position,
      pvert[pind[i*3+1]].position,
      pvert[pind[i*3+2]].position,whydoweneedthis);
  end;

  setlength(indexes,length(tris));
  for i:=0 to high(indexes) do
    indexes[i]:=i;

  teg.min:=D3DXVector3(-10000,-10000,-10000);
  teg.max:=D3DXVector3(10000,10000,10000);


  label1.caption:='Tegs...';
  repaint;

  setlength(kapcsk,mesh.GetNumVertices);
  for i:=0 to trinum-1 do
  begin
    Badd(kapcsk[pind[i*3+0]],pind[i*3+1]);
    Badd(kapcsk[pind[i*3+0]],pind[i*3+2]);
    Badd(kapcsk[pind[i*3+1]],pind[i*3+0]);
    Badd(kapcsk[pind[i*3+1]],pind[i*3+2]);
    Badd(kapcsk[pind[i*3+2]],pind[i*3+0]);
    Badd(kapcsk[pind[i*3+2]],pind[i*3+1]);
  end;
  hch:=-1;
  repeat
    hol:=length(ossz);
    for i:=0 to high(ossz) do
      if ossz[i]<>i then begin hol:=i;break; end;
    inc(hch);
    setlength(charts,hch+1);
    Badd(charts[hch],hol);
    Badd(ossz,hol);
    repeat
      i:=0;
      hol:=0;//változások száma
      repeat
        oda:=charts[hch,i];
        for j:=0 to high(kapcsk[oda]) do
          if Badd(charts[hch],kapcsk[oda,j]) then //Huh :S
          begin
            Badd(ossz,kapcsk[oda,j]);
            inc(hol);
          end;
        inc(i);
      until high(charts[hch])<i;
    until hol=0;
  until high(ossz)>=high(kapcsk);

  szetvalaszt:=(sqrt(length(charts)/siz));
  for i:=0 to high(charts) do
  begin
    oda:=0;//Iterációk száma
    scal:=0;
    scal2:=0;
    for k:=0 to high(charts[i]) do
    begin
      hol:=charts[i,k];

      for j:=0 to high(kapcsk[hol]) do
      begin
        hol2:=kapcsk[hol,j];
        scal:=scal+sqrt(sqr(pvert[hol].position.x-pvert[hol2].position.x)+
          sqr(pvert[hol].position.y-pvert[hol2].position.y)+
          sqr(pvert[hol].position.z-pvert[hol2].position.z));
        scal2:=scal2+sqrt(sqr(pvert[hol].tu-pvert[hol2].tu)+
          sqr(pvert[hol].tv-pvert[hol2].tv));
        inc(oda);
      end;
    end;
    if scal2=0 then scal2:=1;
    scal:=scal/2/scal2;
    minu:=1000;minv:=1000;
    for j:=0 to high(charts[i]) do
    begin
      if pvert[charts[i,j]].tu<minu then minu:=pvert[charts[i,j]].tu;
      if pvert[charts[i,j]].tv<minv then minv:=pvert[charts[i,j]].tv;
    end;

    for j:=0 to high(charts[i]) do
      with pvert[charts[i,j]] do
      begin
        lu:=(tu-minu)*scal;
        lv:=(tv-minv)*scal;
      end;

  end;

  setlength(tegs,length(charts));
  setlength(ktegs,length(charts));
  setlength(ind,length(charts));


  for i:=0 to high(charts) do
    with tegs[i] do
    begin
      x1:=0;y1:=0;x2:=0;y2:=0;
      ind[i]:=i;
      for j:=0 to high(charts[i]) do
        with pvert[charts[i,j]] do
        begin
          if lu>x2 then x2:=lu;
          if lv>y2 then y2:=lv;
        end;
      x2:=x2+0.09*szetvalaszt;
      y2:=y2+0.09*szetvalaszt;
    end;

  for i:=0 to high(tegs)-1 do
    for j:=i+1 to high(tegs) do
      if tegs[i].x2*tegs[i].y2<tegs[j].x2*tegs[j].y2 then // area sort
        //if max(tegs[i].x2,tegs[i].y2)<max(tegs[j].x2,tegs[j].y2) then //biggest oldal
      begin
        tmp:=tegs[i];
        tegs[i]:=tegs[j];
        tegs[j]:=tmp;
        itmp:=ind[i];
        ind[i]:=ind[j];
        ind[j]:=itmp;
      end;
  packrect(tegs,ktegs,mx,my);
  mx:=1/max(mx,my);
  for i:=0 to high(tegs) do
    for j:=0 to high(charts[ind[i]]) do
      with pvert[charts[ind[i],j]] do
      begin
        lu:=(lu+ktegs[i].x1)*mx;
        lv:=(lv+ktegs[i].y1)*mx;
      end;

  //{//némi rajzolás
  {for i:=0 to high(ktegs) do
  canvas.Rectangle(round(ktegs[i].x1*256*mx),round(ktegs[i].y1*256*mx),round(ktegs[i].x2*256*mx),round(ktegs[i].y2*256*mx));
   }
  for i:=0 to trinum-1 do
  begin
    with pvert[pind[i*3]] do
      canvas.moveto(round(lu*siz),round(lv*siz));//ez mi a fasz?
    with pvert[pind[i*3+1]] do
      canvas.lineto(round(lu*siz),round(lv*siz));
    with pvert[pind[i*3+2]] do
      canvas.lineto(round(lu*siz),round(lv*siz));
    with pvert[pind[i*3]] do
      canvas.lineto(round(lu*siz),round(lv*siz));
    with pvert[pind[i*3]] do
      canvas.pixels[round(lu*siz),round(lv*siz)]:=clblack;
  end;//}
  { mesh.UnlockVertexBuffer;
   mesh.UnlockIndexBuffer;
   D3DXCreatePRTEngine(mesh,true,nil,PRT);
   if FAILED(mesh.LockVertexBuffer(D3DLOCK_READONLY,pointer(pvert))) then exit;
   if FAILED(mesh.LockIndexBuffer(D3DLOCK_READONLY,pointer(pind))) then exit;
   }
  label1.caption:='KDTree...';
  label1.repaint;
  ConstructKDTree(KDTree,KDData,indexes,0,tris,teg);

  if kellLM then begin

    bmp:=Tbitmap.Create;
    bmp.Width:=siz;
    bmp.Height:=siz;
    bmp.PixelFormat:=pf24bit;
    bmp.Canvas.Brush.color:=clfuchsia;
    bmp.Canvas.Rectangle(-1,-1,siz,siz);

    for i:=0 to high(myrand1) do
    begin
      myrand1[i].x:=9000+random(2000);
      myrand1[i].y:=9000+random(2000);
      myrand1[i].z:=1000-random(2000);
      d3dxvec3scale(myrand1[i],myrand1[i],1/100);
    end;

    for i:=0 to high(myrand2) do
    begin
      myrand2[i].x:=random(1000)-500;
      myrand2[i].z:=random(1000)-500;
      myrand2[i].y:=random(500)+2;
      d3dxvec3scale(myrand2[i],myrand2[i],100/d3dxvec3length(myrand2[i]));
    end;


    for i:=0 to trinum-1 do
    begin
      mitne:=i;
      trimost[0]:=pvert[pind[i*3+0]];
      trimost[1]:=pvert[pind[i*3+1]];
      trimost[2]:=pvert[pind[i*3+2]];
      tracelightmaptri(trimost,bmp.canvas,siz);
      if (i and 7)=0 then
      begin
        label1.caption:=floattostrf((i/trinum)*100,fffixed,7,2)+'%';
        repaint;
        canvas.Draw(0,0,bmp);
      end;
    end;

    i:=0;
    repeat
      hol2:=0;
      i:=i+1;
      for x:=0 to siz-1 do
        for y:=0 to siz-1 do
          if (((x+y)and 1)=0)xor((i and 1)=0) then
            if bmp.canvas.Pixels[x,y]=clfuchsia then
            begin
              hol:=0;
              most:=0;
              if x>0 then if bmp.canvas.pixels[x-1,y]<>clfuchsia then
                begin
                  inc(hol);most:=most+bmp.canvas.pixels[x-1,y]and $FF;
                end;
              if x<(siz-1) then if bmp.canvas.pixels[x+1,y]<>clfuchsia then
                begin
                  inc(hol);most:=most+bmp.canvas.pixels[x+1,y]and $FF;
                end;
              if y>0 then if bmp.canvas.pixels[x,y-1]<>clfuchsia then
                begin
                  inc(hol);most:=most+bmp.canvas.pixels[x,y-1]and $FF;
                end;
              if y<(siz-1) then if bmp.canvas.pixels[x,y+1]<>clfuchsia then
                begin
                  inc(hol);most:=most+bmp.canvas.pixels[x,y+1]and $FF;
                end;
              inc(hol2,hol);
              if hol>0 then
              begin
                bmp.canvas.Pixels[x,y]:=(most div hol)*$010101;

              end;
            end;
      canvas.draw(0,0,bmp);
    until hol2=0;
    for i:=1 to blurszam do
    begin
      for x:=1 to siz-2 do
        for y:=1 to siz-2 do
        begin
          most:=0;
          most:=most+bmp.canvas.pixels[x-1,y]and $FF;
          most:=most+bmp.canvas.pixels[x+1,y]and $FF;
          most:=most+bmp.canvas.pixels[x,y-1]and $FF;
          most:=most+bmp.canvas.pixels[x,y+1]and $FF;
          most:=most+3*(bmp.canvas.pixels[x,y]and $FF);
          bmp.canvas.Pixels[x,y]:=(most div 7)*$010101;
        end;
      canvas.draw(0,0,bmp);
    end;
    bmp.SaveToFile(stringreplace(fil,'.x','lm.bmp', [rfReplaceAll]));
  end;


  mesh.UnlockVertexBuffer;
  mesh.UnlockIndexBuffer;

  error:=d3dxsavemeshtoX(Pchar(fil),mesh,nil,pointer(mats),nil,nummat,D3DXF_FILEFORMAT_BINARY);

  stickmeshconverttox(stringreplace(fil,'.x','', [rfReplaceAll]),g_pd3ddevice);

  // If FAILED(error) then exit;
  mesh:=nil;
  if mesh2<>nil then mesh2:=nil;

  close;
end;

procedure TForm1.FormClose(Sender:TObject;var Action:TCloseAction);
begin
  g_pd3ddevice:=nil;
  g_pd3d:=nil;
end;

procedure TForm1.Button2Click(Sender:TObject);
var
  arr:Tintarr;
  i,j:integer;
  arr1,arr2:array[0..100] of Tsinglerect;
  tmp:Tsinglerect;
  mx,my:single;
begin
  randomize;
  setlength(arr,0);
  for i:=0 to 20 do
    Badd(arr,random(20));
  label1.caption:='';
  for i:=0 to high(arr) do
    label1.caption:=label1.caption+inttostr(arr[i])+';';

  for i:=0 to 100 do
    with arr1[i] do
    begin
      x1:=0;x2:=5+random(20);
      y1:=0;y2:=2+random(round(400/x2));
    end;
  for i:=0 to 99 do
    for j:=i+1 to 100 do
      if arr1[i].x2*arr1[i].y2<arr1[j].x2*arr1[j].y2 then
      begin
        tmp:=arr1[i];
        arr1[i]:=arr1[j];
        arr1[j]:=tmp;
      end;//}
  packrect(arr1,arr2,mx,my);
  for i:=0 to 100 do
    canvas.Rectangle(round(arr2[i].x1),round(arr2[i].y1),round(arr2[i].x2),round(arr2[i].y2));
end;

procedure setUiLanguage(lang:Single);
var
i:integer;
begin
if (lang = LANG_HUNGARIAN) then
  begin
    Form1.Caption := 'Stick Lightmap generáló és Konverter';
    Form1.resg.Caption := 'Felbontás';
    Form1.jpgchk.Caption := 'JPG textúrák';
    Form1.kellLMchk.Caption := 'Nem kérek lightmapot';
    Form1.Button1.Caption := 'Tallózás';

  end
  else
  begin
    Form1.Caption := 'Stick Lightmapper and Converter';
    Form1.resg.Caption := 'Resolution';
    Form1.jpgchk.Caption := 'JPG textures';
    Form1.kellLMchk.Caption := 'Don''t generate lightmap';
    Form1.Button1.Caption := 'Choose file';
  end
end;

procedure TForm1.LangClick(Sender:TObject);
begin
  if (LanguageId=14) then
  begin
    LanguageId:=9;
  end
  else
  begin
    LanguageId:=14;
  end;
  SetUiLanguage(LanguageId);
end;



end.
//rev3
