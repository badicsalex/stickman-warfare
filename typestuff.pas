unit Typestuff;

interface
uses
Sysutils,
D3DX9,
windows,
Direct3D9,
perlinnoise,
math,
Zlibex,
sha1,
winsock2;
type
  Tnev=array [1..32] of char;
  Tjelszo=array [1..32] of char;
  Tintarr= array of integer;


  Tfloatarr=array of single;
  Tbytearr=array of byte;

  Tsmallintdynarr=array of smallint;

  Tarrayofpointer = array of pointer;
  Psmallintarray = ^Tsmallintarray;
  Tsmallintarray = array [0..10000] of smallint;

  Pshortintarray = ^Tshortintarray;
  Tshortintarray = array [0..10000] of shortint;

  Tadvwove = function (xx,zz:single):single;
  
  P3DVertexarray=^T3DVertexarray;
  T3DVertexarray=array [0..1000000] of TD3DXVector3;

  PCustomVertex = ^TCustomVertex;
  TCustomVertex = record
    position: TD3DVector; // The 3D position for the vertex
    normal: TD3DVector;   // The surface normal for the vertex
    color:longword;
    u,v:single;
    u2,v2:single;
  end;

  PCustomVertexArray = ^TCustomVertexArray;
  TCustomVertexArray = array [0..100000] of TCustomVertex;

  Plvl=^Tlvl;
  Tlvl = array [0..33*33] of TCustomVertex;

  PSkyVertex = ^TSkyVertex;
  TSkyVertex = record
    position: TD3DVector; // The 3D position for the vertex
    u,v:single;
  end;

  PskyVertexArray = ^TskyVertexArray;
  TskyVertexArray = array [0..100000] of TskyVertex;

  POjjektumVertex = ^TOjjektumVertex;
  TOjjektumVertex = record
    position: TD3DVector; // The 3D position for the vertex
    tu,tv:single;
    lu,lv:single;
  end;

  POjjektumVertexArray = ^TOjjektumVertexArray;
  TOjjektumVertexArray = array [0..100000] of TOjjektumVertex;

  Tmypackedvector = record
   x,y,z:word;
  end;

  Tmypackednorm = record
   x,y:smallint;
  end;

  TPackedOjjektumVertex = record
    position: Tmypackedvector; // The 3D position for the vertex
    tu,tv:word;
    lu,lv:byte;
  end;


  PPosNormUV = ^TPosNormUV;
  TPosNormUV = record
    position: TD3DVector; // The 3D position for the vertex
    normal: TD3DVector;   // The surface normal for the vertex
    u,v:single;
  end;

  PPosNormUVArray = ^TPosNormUVArray;
  TPosNormUVArray = array [0..100000] of TPosNormUV;

  PColoredVert = ^TColoredVert;
  TColoredVert = record
   position:TD3DVector;
   col:Dword;
  end;

  PColoredVertarray = ^TColoredVertarray;
  TColoredVertarray = array[0..100000] of TColoredVert;


  TNormalTangentBinormal = record
   normal,tangent,binormal:TD3DXVector3;
  end;

  POjjektumVertex2 = ^TOjjektumVertex2;
  TOjjektumVertex2 = record
    position: TD3DVector; // The 3D position for the vertex
    tu,tv:single;
    lu,lv:single;
    normal,tangent,binormal:TD3DXVector3;
  end;

  POjjektumVertex2Array = ^TOjjektumVertex2Array;
  TOjjektumVertex2Array = array [0..100000] of TOjjektumVertex2;

  TImposterVertex = record
   position:TD3DVector;
   color:Dword;
   u1,v1:single;
   u2,v2:single;
  end;

  PImposterVertexArray = ^TImposterVertexArray;
  TImposterVertexArray = array [0..100000] of TImposterVertex;


  {Tpackedpos = packed record
   pos:Tmypackedvector;
   irany:byte;
   prior:byte;
   state:byte;
   irany2:byte;
   bg:byte;
  end;

  Tmukspos = record
   pos:TD3DXVector3;
   irany,irany2:single;
   state:byte;
   prior:single;
   bg:byte;
  end;

  Tmukspls = record
   seb,vseb:TD3DXVector3;           //sebess�g, volt sebess�g
   vpos,megjpos:TD3dxvector3;
   mtim,vtim,atim:word;             //k�l�nb�z� id�k a packetek k�zt
   amtim,avtim,aatim,amtim2:word;  //  --||-- aut�val
   pkullov:array [1..15,1..2] of TD3DVector; //pontos l�v�sek
   kullov:array [1..15] of Tmypackedvector;  //packed l�v�sek
   klsz,pklsz:byte;                          // sz�muk
   lo:single;
   nev:Tnev;
   nev2:string;
   fegyv:byte; //128 a csapat
   autopos,autoopos,autoposx,autooposx:TD3DXVector3;
   autoaxes,autovaxes,autovaxes2:array [0..2] of TD3DXVector3;
  // atmenetL:single;                         //���h
   lottram:integer;               //vmikor l�tt r�m pontosat
   fejh:TD3DXVector3;             //feje hol van (headstuff)
   afejcucc:byte;                 // headstuff
   donotsend:integer;                //kezdeti nek�ldjdolog
   overrideport:word;             // port dolog
   utsocht:string;                // megejeln�tend� chat
   chttim:integer;
   visible:boolean;              // Viewport culling
   kills:word;
   autotkuldj:byte; //0 1 2 3... tr�kk�s.
   priorneki:single; //ideiglenes sz�m, a fel� m�rt priorit�s (a c�lz�s. pplpos.prior n�lk�l)
   priormost: single; // sz�m, a legkisebb nyer, hozz�ad�dik a pplpls.priorneki �s a pplpos.prior
   seesme:boolean;    //lat
   egyebetkapott:integer;    //no minden esetben amikor egyebet kap :) F�k�nt a seesme miatt.
  end;}

  
  Tloves = record
   pos,v2:Td3DXvector3;
   kilotte:integer;
   fegyv:byte;
  end;

  { PRIVATE TYPEOK! }
  Tplayerpos = record
   pos:TD3DXVector3;
   irany,irany2:single;
   state:byte;
   seb,vseb:TD3DXVector3;           //sebess�g, volt sebess�g
   vpos,megjpos:TD3dxvector3;
  end;

  Tplayernet = record
   ip:DWORD;
   port:WORD;
   overrideport:word;             // nat port dolog
   UID:integer;
   kapottprior:single;     //�n milyen fontos vagyok neki
   nekemprior:single;      //� milyen fontos nekem
   prior:single;          //a kett� �sszege, ezzel egyenesen ar�nyos a kapott s�vsz�l
   priorbucket:single;    //ez t�lt�dik. Ha >0, lehet sendelni, akkor -=1
   mtim:word;             //legut�bbi packet �ta eltelt sz�zadm�sodpercek
   vtim:word;             //legut�bbi packet ideje GetTickCountban
   atim:word;
   amtim,avtim,aatim,vamtim:word;  //  --||-- aut�val
   lasthandshake:integer;
   gothandshake:boolean;
   connected:boolean;     //3 way handshake k�sz
   lovesek:array [0..15]of Tloves; //elkuldendo lovesek
   loveseksz:integer;
   plovesek:array [0..7] of Tloves; //elkuldendo pontos lovesek
   ploveseksz:integer;
  end;

  Tplayerpls = record
   lo:single;
   nev:string;
   fegyv:byte; //128 a csapat
   fejcucc:byte;                 // headstuff
   fejh:TD3DXVector3;             //feje hol van (headstuff)
   utsocht:string;                // megejeln�tend� chat
   chttim:integer;
   visible:boolean;              // Viewport culling
   kills:word;
   lottram:integer;             //l�tt r�m. visszasz�ml�l�
   autoban:boolean;
  end;

  Tplayerauto = record
   enabled:boolean;
   pos,seb,vpos,vseb:TD3DXVector3;
   axes,vaxes:array [0..2] of TD3DXVector3;
  end;

  Tplayer = record
   pos:Tplayerpos;
   net:Tplayernet;
   pls:Tplayerpls;
   auto:Tplayerauto
  end;

  const uresplayer:Tplayer=();

  type

  TTeleport = record
   vfrom,vto:TD3DXVector3;
   rad:single;
   vis:single;
  end;

  Pbinmsg = ^Tbinmsg;
  Tbinmsg =packed array [0..511] of byte;



  PVecArr2 =^TVecarr2;
  TVecarr2 =array [0..100000] of TD3DXVector3;
  
  TVecarray = array of TD3DXVector3;

  TKeyArray = array [0..255] of byte;

  Ttri= array[0..2] of TD3DXVector3;
  Tminmaxtri= array[0..4] of TD3DXVector3;
  Tminmaxtridynarr=array of Tminmaxtri;

  Tsinglerect = record
   x1,y1,x2,y2:single;
  end;

  Tacctri = record
   v0,v1,v2:TD3DXVector3;
   a,u,v,n:TD3DXVector3;
   uu,uv,vv:single;
   invD:single;
   vmin,vmax:TD3DXVector3
   //plane:TD3DXplane;
  end;

  Tacctriarr=array of Tacctri;

  TAABB= record
   min,max:TD3DXVector3;
  end;

  PKDnode =^TKDnode;
  TKDnode = record
   tricount,tristart:integer;
   split:single;
  // leftteg,rightteg:TAABB;
   left,right:integer;
  end;

  TKDtree=array of TKDnode;
  TKDData=array of integer;

  T7pbox = array [0..7] of TD3DXVector3;
  T7pboxbol= array [0..7] of boolean;

  TnamedProjectile = record
   v1,v2,v3:TD3DXVector3;
   name:Dword; //ez egy hash
   colltim:byte;
   eletkor:integer;
   kilotte:integer;
  end;
  
  TDbubble = record
   pos:TD3DXVector3;
   meret,erosseg:single;
   meretpls,erossegpls:single;
   meretplsszor:single;
   tim:integer;
  end;

  TDripple = record
   pos:TD3DXVector3;
   vsz,hsz:TD3DXVector3;
   meret,erosseg:single;
   meretpls,erossegpls:single;
   meretplsszor:single;
   tim:integer;
  end;

  Tarrayofstring =array of string;

  TFrustum=array [0..5] of TD3DXplane;

  Tindexedsingle = record
   ertek:single;
   ind:integer;
  end;

  Tindexedint = record
   ertek:integer;
   ind:integer;
  end;

  Tindexedintarr = array of Tindexedint;

  TStickmesh = record
   Indices:array of word;
   Vertices:array of TOjjektumvertex;
   Normals:array of TNormalTangentBinormal;
   Attrtable:array of TD3DXAttributeRange;
   texturetable:array of string[50];
  end;

  TInAddr = winsock2.Tinaddr;

  Tincim = record
   sin_port   : u_short;
   sin_addr   : TInAddr;
  end;

const
maxOTpoints=2;
type
  ToctPoint = record
   pos:TD3DXVector3;
   poi:pointer;
  end;

  POctLeaf= ^TOctLeaf;
  TOctleaf = record
   axe:byte;
   level:byte;
   split:single;
   AABB:TAABB;
   child0,child1,parent:POctLeaf;
   cumolngt:shortint;
   cumok:array [0..maxOTpoints-1] of Toctpoint;
  end;

  TGridElem = packed record
   meret,top:integer;
   elemek:Pointer; //1D Array, Dwordok term�szetesen Castolhat� pinterre de �hgyis index lesz
  end;

  TGrid = record
   meret:Integer;
   bufstep:integer;
   elemek:Pointer; //2D Array, PGridElemekre
  end;

  Tgriditems = array of dword;

  Tojjrect = record
   ind1,ind2:integer;
   px,py:integer;
   mx,my:integer;
  end;

  Tojjrectarr= array of Tojjrect;
const
 //STICKMAN
  PROG_VER=20100;
  datachecksum=$1ED51E69;
var
  checksum:Dword=0;
const
  GRAVITACIO=0.003;
  fav3DPOOL=D3DPOOL_DEFAULT;
var
  SCwidth:integer=800;
  SCheight:integer=(800*3) div 4;

const
  perlinlvl=6;
  betuszin=$0000B0;

  FEGYV_M4A1=0;
  FEGYV_M82A1=1;
  FEGYV_LAW=2;
  FEGYV_MP5A3=3;

  FEGYV_MPG=128;
  FEGYV_QUAD=129;
  FEGYV_NOOB=130;
  FEGYV_X72=131;

  MSTAT_MASK=15;
  MSTAT_ALL=0;
  MSTAT_ELORE=1;
  MSTAT_HATRA=2;
  MSTAT_JOBBRA=3;
  MSTAT_BALRA=4;
  MSTAT_FUT=5;
  MSTAT_GUGGOL=16; //flag
  MSTAT_CSIPO=32; //ez is flag

  // Our custom FVF, which describes our custom vertex structure
  D3DFVF_CUSTOMVERTEX = (D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_DIFFUSE or D3DFVF_TEX2 );
  D3DFVF_OJJEKTUMVERTEX = (D3DFVF_XYZ or D3DFVF_TEX2 );
  D3DFVF_IMPOSTERVERTEX = (D3DFVF_XYZ or D3DFVF_DIFFUSE or D3DFVF_TEX2);
  D3DFVF_SKYVERTEX = (D3DFVF_XYZ or D3DFVF_TEX1 );
  D3DFVF_PosNormUV = (D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_TEX1 );
  D3DFVF_COLOREDVERTEX = (D3DFVF_XYZ or D3DFVF_DIFFUSE);

  DIKChar:array [$01..$39] OF CHAR
                           =(' ','1','2','3','4','5','6','7','8','9','0','-','=','�',' ',
                         'Q','W','E','R','T','Y','U','I','O','P','[',']',' ',' ','A','S',
                         'D','F','G','H','J','K','L',';',' ',' ',' ','\','Z','X','C','V',
                         'B','N','M',',','.','/',' ','*',' ',' ');
  identmatr:TD3DMatrix=(_11:1;_12:0;_13:0;_14:0;
                        _21:0;_22:1;_23:0;_24:0;
                        _31:0;_32:0;_33:1;_34:0;
                        _41:0;_42:0;_43:0;_44:1);
  felematr:TD3DMatrix=(_11:0.5;_12:0;_13:0;_14:0;
                        _21:0;_22:0.5;_23:0;_24:0;
                        _31:0;_32:0;_33:0.5;_34:0;
                        _41:0;_42:0;_43:0;_44:1);
  sqrt2=1.414213;
function CustomVertex(x,y,z,nx,ny,nz:single;acolor:longword;au,av,au2,av2:single):TCustomVertex;overload;
function CustomVertex(pos:TD3DXVector3;nx,ny,nz:single;acolor:longword;au,av,au2,av2:single):TCustomVertex;overload;
//function CustomVertex(pos:TD3DXVector3;n:TD3DXVector3;acolor:longword;au,av:single):TCustomVertex;overload;

function SkyVertex(px,py,pz,au,av:single):TSkyVertex;

function ARGB(a,r,g,b:byte):cardinal;
function colorlerp(mit1,mit2:cardinal;mennyivel:single):cardinal;

function SingletoDword(mit:single):Dword;

function tavLineLine(p1,p2,p3,p4:TD3DXVector3;out pa,pb:TD3DXVector3;out Distance:single):boolean;
function tavLineLinesq(p1,p2,p3,p4:TD3DXVector3;out pa,pb:TD3DXVector3;out Distance:single):boolean;

function tavPointLine(point,linestart,lineend:TD3DXVector3;out Intersection:TD3DXVector3; out Distance:single ):boolean;
function tavPointLinesq(point,linestart,lineend:TD3DXVector3;out Intersection:TD3DXVector3; out Distance:single ):boolean;
function tavPointLinesq2d(point,linestart,lineend:TD3DXVector3;out Intersection:TD3DXVector3; out Distance:single ):boolean;
function tavPointLine2(point,linestart,lineend:TD3DXVector3):single;

function tavPointPoint(Point1,point2:TD3DXvector3):single;
function tavPointPointsq(Point1,point2:TD3DXvector3):single;
function tavPointPointKock(Point1,point2:TD3DXvector3):single;

function intLineSphere(const p1,p2,sc:TD3DXVector3;const r:single;var ep:TD3DXVector3):boolean;
function IntLineTri(v0,v1,v2,p0,p1:TD3DXVector3;out pi:TD3DXVector3):boolean;
function intlinetribol(tri:Tacctri;vec,ir:TD3DXVector3):boolean;

function tavpointtri(tri:Tacctri;poi:TD3DXVector3;out pi:Td3dxvector3):single;
function tavpointtrisq(tri:Tacctri;poi:TD3DXVector3;out pi:Td3dxvector3):single;
//function tavpointtrisqszorzo(v0,v1,v2,poi:TD3DXVector3;out pi:Td3dxvector3;szorzo:single):single;


function wove(x,y:single):single;

function scalecolor(mit:cardinal;mennyivel:single):cardinal;

function LTFF(adevice:IDirect3DDevice9;nev:string ;out tex:IDirect3DTexture9):boolean;

procedure randomplus(var mit:TD3DXVector3;az,scal:single);
procedure randomplus2(var mit:TD3DXVector3;az,scal:single);
function randomvec(az,scal:single):TD3DXVector3;

function BSearch(arr:Tintarr;mit:integer):integer; overload;  //BinarySearch
function Badd(var arr:Tintarr; mit:integer):boolean; overload;//BinaryAdd

function BSearch(arr:Tfloatarr;mit:single):integer; overload;  //BinarySearch
function Badd(var arr:Tfloatarr; mit:single):boolean; overload;//BinaryAdd

function BSearch(arr:TKDData;mit:word):integer; overload;  //BinarySearch
function Badd(var arr:TKDData; mit:word):boolean; overload;//BinaryAdd

function tegtegben(ax1,ay1,amx,amy,bx1,by1,bmx,bmy:integer):boolean;overload;
function tegtegben(a,b:Tsinglerect):boolean;overload;
function tegtegben(a,b:TAABB):boolean;overload;

function tritegben(a:Tacctri;b:TAABB):boolean;overload;
function tritegben(a:Tminmaxtri;b:TAABB):boolean;overload;

procedure packrect(rect:array of Tsinglerect;var wantrect:array of Tsinglerect;var maxx,maxy:single);

function intlinetriAcc(tri:Tacctri;p0,p1:TD3DXVector3):boolean;
function makeacc(av0,av1,av2:TD3DXVector3):Tacctri;

function noNaNINF(var mi:single):boolean; overload;
function noNaNINF(var mi:TD3DVector):boolean; overload;
procedure constraintfloat(var mi:single);
procedure constraintfloat2(var mi:single);
procedure constraintvec(var mi:TD3DVector);

function trisinAABB(alaptris:Tacctriarr;alapdata:TKDData;var hova:TKDData;teg:TAABB;masoldis:boolean):integer;

procedure ConstructKDtree(var  KDtree:TKDtree; var KDData:TKDData;indexes:TKDData;axis:byte;tris:Tacctriarr;teg:TAABB);
procedure traverseKDtree(teg:TAABB;var hova:TKDData;KDData:TKDData;KDTree:TKDTree);
procedure traverseKDtreelin(v1,v2:TD3DXVector3;var hova:TKDData;KDData:TKDData;KDTree:TKDTree;trik:Tacctriarr);
procedure traverseKDtreelinDNT(v1,v2:TD3DXVector3;var hova:TKDData;KDData:TKDData;KDTree:TKDTree;trik:Tacctriarr);
procedure saveKDtree(nev:string; KDTree:TKDTree; KDData:TKDData);
procedure loadKDtree(nev:string; var KDTree:TKDTree; var KDData:TKDData);

function point(ax,ay:integer):Tpoint;

function packfloat(mit:single;range:single):word;
function packfloatheavy(mit:single;range:single):byte;
function packvec(mit:TD3DXVector3;range:single):Tmypackedvector;
function packnormal(mit:TD3DXVector3):Tmypackednorm;
function packseb(pos,opos:TD3DXVector3):Tmypackedvector;
function unpackfloat(mit:word;range:single):single;
function unpackfloatheavy(mit:byte;range:single):single;
function unpackvec(mit:Tmypackedvector;range:single):TD3DXVector3;
function unpacknormal(mit:Tmypackednorm):TD3DXVector3;

function vec3add3(v1,v2,v3:TD3DXVector3):TD3DXVector3;
function vec3add4(v1,v2,v3,v4:TD3DXVector3):TD3DXVector3;

function kbegyenlo(mi,mivel:TD3DXVector3;epsilon:single=0.001):boolean;
procedure normalizemesh(g_pMesh:ID3DXMesh);

function doSAT(box:T7pbox;var boxbol:T7pboxbol;tri:Tacctri;var vec:TD3DXvector3):single;

function fastinvsqrt(mit:single):single;
function fastinvsqrt2(mit:single):single;
function lerp(a,b,v:single):single;

procedure fastvec3normalize(var mit:TD3DXVector3);

function XORHash2x12byte(v1,v2:TD3DXVector3):dword;
function StringHash(mit:string):cardinal;

procedure explode(str:string;const key:char;var hova:Tarrayofstring);

function Frustum(viewMatrix:TD3DMatrix;nearplane,farplane,fovy,ratio:single):TFrustum;
function AABBvsFrustum(aabb:TAABB;f:TFrustum):boolean;
function SpherevsFrustum(pos:TD3DXVector3;r:single;f:TFrustum):boolean;

procedure addtochecksum(mit:array of DWORD;hgh:integer);
procedure addfiletochecksum(nev:string);

procedure OctTreeAdd(const tree:POctLeaf;const hol:TD3DXVector3;const mit:Pointer);
procedure OctTreeDel(const tree:POctLeaf;const hol:TD3DXVector3;const mit:Pointer);
procedure OctTreeGetRegion(const tree:PoctLeaf;const aabb:TAABB;var res:Tarrayofpointer);

procedure StickMeshConvertToX(nev:string;a_d3ddevice:IDirect3DDevice9);
function StickMeshLoad(nev:string):TStickMesh;
procedure StickMeshSave(nev:string; mesh:TStickMesh);
procedure StickMeshComputeNTB(var mesh:Tstickmesh);
procedure StickMeshInvertNormals(var mesh:Tstickmesh);

procedure specialcopymem(dest,src:pointer;deststride,srcstride:integer;elements:integer);

function CommandLineOption(mi:string):boolean;

function SHA1GetHex(dig:TSha1Digest):string;

procedure gethostbynamewrap(nam:string;hova:PinAddr;canwait:boolean);
function sockaddrtoincim(sockaddr:sockaddr_in):Tincim;
function incimtosockaddr(incim:Tincim):sockaddr_in;
function recvall(sck:cardinal;var buffer;length,timeout:integer):integer;
function connectwithtimeout(sck:cardinal;name:PSockAddr; namelen:integer; timeout:integer):integer;

function readm3urecord(nam:string):string;
function readplsrecord(nam:string):string;

function isqr(a:integer):integer;

procedure gridgetitems(grid:Tgrid; hx,hy:integer; var itms:Tgriditems);
procedure gridremoveind(grid:Tgrid;hx,hy:integer;mit:dword);
procedure gridremoveval(grid:Tgrid;hx,hy:integer;ertek:dword);
procedure gridadd(grid:Tgrid;hx,hy:integer;mit:dword);
procedure gridinit(var grid:Tgrid;ameret,abufstep:integer);

procedure rectresize(var rect:Tojjrectarr; aind1,aind2,amx,amy:integer);
procedure rectremove(var rect:Tojjrectarr;aind1,aind2:integer);
procedure rectadd(var rect:Tojjrectarr; aind1,aind2,amx,amy:integer);
procedure rectmegbasztat(var rect:Tojjrectarr; aind1,aind2,aind2uj:integer);
function ojjrect(aind1,aind2,apx,apy,amx,amy:integer):Tojjrect;
function rectget(var rect:Tojjrectarr; aind1,aind2:integer):Tojjrect;

procedure qsort_reducetokth(var mit:Tindexedintarr; k:integer);
function qsort_partition(var mit:Tindexedintarr; left, right, pivotIndex:integer):integer;
procedure loadlang(honnan:string;id:integer);

var
perlin:Tperlinnoise;
animstat: single;
logfile:Textfile;  //ez fontos
laststate: string;
lflngt,lflngt2:integer;
campos,upvec,lvec:TD3DXVector3;
FAKE_HDR:cardinal;
azadvwove:Tadvwove;
lang:array of string;
implementation

var
//infcheckstuff
  Infinity:single= (1.00/0);
InfinityMask:cardinal absolute infinity;

function SingletoDword(mit:single):Dword;
begin
 result:=PDword(@mit)^;
end;

function lerp(a,b,v:single):single;
begin
 result:=a+(b-a)*v;
end;

function scalecolor(mit:cardinal;mennyivel:single):cardinal;
var
R,G,B:byte;
begin
 R:=(mit shr 16) mod 256;
 G:=(mit shr 8 ) mod 256;
 B:=(mit       ) mod 256;
 R:=round(R*mennyivel);
 G:=round(G*mennyivel);
 B:=round(B*mennyivel);
 result:=RGB(R,G,B);
end;

function colorlerp(mit1,mit2:cardinal;mennyivel:single):cardinal;
var
R1,G1,B1,R2,G2,B2:byte;
A1,A2:byte;
begin
 R1:=(mit1 shr 16) mod 256;
 G1:=(mit1 shr 8 ) mod 256;
 B1:=(mit1       ) mod 256;

 R2:=(mit2 shr 16) mod 256;
 G2:=(mit2 shr 8 ) mod 256;
 B2:=(mit2       ) mod 256;

 A1:=(mit1 shr 24) mod 256;
 A2:=(mit2 shr 24) mod 256;

 R1:=round(R1-(R1-R2)*mennyivel);
 G1:=round(G1-(G1-G2)*mennyivel);
 B1:=round(B1-(B1-B2)*mennyivel);

 A1:=round(A1-(A1-A2)*mennyivel);

 result:=A1 shl 24 + RGB(R1,g1,b1);// (R1 shl 16) and (G1 shl 8) and B1;
end;


function ohjef(a:single):single;
begin
 a:=1000-a;
 if a<0 then
  result:=0
 else
  result:=a/1000;
end;

function wove(x,y:single):single;
var
starting:single;
begin
 starting:=(0.5+perlin.noise(x/200,y/200,0))*ohjef(abs(y)+abs(x));
 result:=perlin.complexnoise(starting,x,y,100,perlinlvl,0.3)*100+perlin.Noise(x/2+0.5,y/2+0.5,0.5)*0.3;
end;

function ARGB(a,r,g,b:byte):cardinal;
begin
 result:=RGB(r,g,b) or (a shl 24);
end;

function CustomVertex(x,y,z,nx,ny,nz:single;acolor:longword;au,av,au2,av2:single):TCustomVertex;
begin
 with result do
 begin
  position.x:=x;position.y:=y;position.z:=z;
  normal.x:=nx ;normal.y:=ny ;normal.z:=nz ;
  color:=acolor;
  u:=au;v:=av;
  u2:=au2;v2:=av2;
 end;
end;

function CustomVertex(pos:TD3DXVector3;nx,ny,nz:single;acolor:longword;au,av,au2,av2:single):TCustomVertex;
begin
 with result do
 begin
  position:=pos;
  normal.x:=nx ;normal.y:=ny ;normal.z:=nz ;
  color:=acolor;
  u:=au;v:=av;
  u2:=au2;v2:=av2;
 end;
end;

function SkyVertex(px,py,pz,au,av:single):TSkyVertex;
begin
 with result do
 begin
  position.x:=px;position.y:=py;position.z:=pz;
  u:=au-0.29;v:=av;
 end;
end;

 {
function CustomVertex(pos:TD3DXVector3;n:TD3DXVector3;acolor:longword;au,av:single):TCustomVertex;
begin
 with result do
 begin
  position:=pos;
  normal:=n;
  color:=acolor;
  u:=au;v:=av;
 end;
end;  }

function tavPointPointKock(Point1,point2:TD3DXvector3):single;
begin
result:=abs(Point1.x-point2.x)+abs(Point1.y-point2.y)+abs(Point1.z-point2.z);
end;

function tavPointPoint(Point1,point2:TD3DXvector3):single;
begin
result:=sqrt(tavpointpointsq(point1,point2));
end;


function tavPointPointsq(Point1,point2:TD3DXvector3):single;
var
Vec:TD3DXVector3;
begin

    Vec.X := Point2.X - Point1.X;
    Vec.Y := Point2.Y - Point1.Y;
    Vec.Z := Point2.Z - Point1.Z;

    result:= Vec.X * Vec.X + Vec.Y * Vec.Y + Vec.Z * Vec.Z ;
end;

function tavPointLine(point,linestart,lineend:TD3DXVector3;out Intersection:TD3DXVector3; out Distance:single ):boolean;
var
dst:single;
begin
 result:=tavPointLinesq(point,linestart,lineend,intersection,dst);
 distance:=sqrt(dst);
end;

function tavPointLine2(point,linestart,lineend:TD3DXVector3):single;
var
dst,dst2:single;
tmp:TD3DXVector3;
begin
 if tavPointLinesq(point,linestart,lineend,tmp,dst) then
  result:=sqrt(dst)
 else
 begin
  dst :=tavpointpointsq(point,linestart);
  dst2:=tavpointpointsq(point,lineend);
  result:=sqrt(min(dst,dst2));
 end;
end;

function tavPointLinesq(point,linestart,lineend:TD3DXVector3;out Intersection:TD3DXVector3; out Distance:single ):boolean;
var
LineMag,U:single;
begin

    LineMag := tavPointPointsq( LineEnd, LineStart );
    if linemag<0.000001 then
    begin
     result:=false;
     exit;
    end;
    U := ( ( ( Point.X - LineStart.X ) * ( LineEnd.X - LineStart.X ) ) +
        ( ( Point.Y - LineStart.Y ) * ( LineEnd.Y - LineStart.Y ) ) +
        ( ( Point.Z - LineStart.Z ) * ( LineEnd.Z - LineStart.Z ) ) ) /
        ( LineMag);

    if( (U < 0.0) or (U > 1.0) ) then
    begin
     result:=false;   // closest point does not fall within the line segment
     exit;
    end;
    Intersection.X := LineStart.X + U * ( LineEnd.X - LineStart.X );
    Intersection.Y := LineStart.Y + U * ( LineEnd.Y - LineStart.Y );
    Intersection.Z := LineStart.Z + U * ( LineEnd.Z - LineStart.Z );

    Distance := tavPointPointsq( Point, Intersection );

    result:=true;
end;

function tavPointLinesq2d(point,linestart,lineend:TD3DXVector3;out Intersection:TD3DXVector3; out Distance:single ):boolean;
var
LineMag,U:single;
begin

    LineMag := tavPointPointsq( LineEnd, LineStart );
    if linemag<0.000001 then
    begin
     result:=false;
     exit;
    end;
    U := ( ( ( Point.X - LineStart.X ) * ( LineEnd.X - LineStart.X ) ) +
        ( ( Point.Z - LineStart.Z ) * ( LineEnd.Z - LineStart.Z ) ) ) /
        ( LineMag);

    if( (U < 0.0) or (U > 1.0) ) then
    begin
     result:=false;   // closest point does not fall within the line segment
     exit;
    end;
    Intersection.X := LineStart.X + U * ( LineEnd.X - LineStart.X );
    Intersection.Y := 0;
    Intersection.Z := LineStart.Z + U * ( LineEnd.Z - LineStart.Z );

    Distance := tavPointPointsq( Point, Intersection );

    result:=true;
end;

function tavLineLine(p1,p2,p3,p4:TD3DXVector3;out pa,pb:TD3DXVector3;out Distance:single):boolean;
var
dst:single;
begin
 result:=tavlineline(p1,p2,p3,p4,pa,pb,dst);
 distance:=sqrt(dst);
end;

function tavLineLinesq(p1,p2,p3,p4:TD3DXVector3;out pa,pb:TD3DXVector3;out Distance:single):boolean;
const
EPS=0.00001;
var
p13,p43,p21:TD3DXVector3;
d1343,d4321,d1321,d4343,d2121:single;
numer,denom:single;
mua,mub:single;
begin
   d3dxvec3subtract(p13,p1,p3);
   d3dxvec3subtract(p43,p4,p3);
   if ((ABS(p43.x)  < EPS) and (ABS(p43.y)  < EPS) and (ABS(p43.z)  < EPS)) then
    begin
     result:=false;
     exit;
    end;
   d3dxvec3subtract(p21,p2,p1);
   if ((ABS(p21.x)  < EPS) and (ABS(p21.y)  < EPS) and (ABS(p21.z)  < EPS)) then
    begin
     result:=false;
     exit;
    end;
   d1343 := p13.x * p43.x + p13.y * p43.y + p13.z * p43.z;
   d4321 := p43.x * p21.x + p43.y * p21.y + p43.z * p21.z;
   d1321 := p13.x * p21.x + p13.y * p21.y + p13.z * p21.z;
   d4343 := p43.x * p43.x + p43.y * p43.y + p43.z * p43.z;
   d2121 := p21.x * p21.x + p21.y * p21.y + p21.z * p21.z;

   denom := d2121 * d4343 - d4321 * d4321;
   if (ABS(denom) < EPS) then
    begin
     result:=false;
     exit;
    end;
   numer := d1343 * d4321 - d1321 * d4343;

   if (ABS(d4343) < EPS) then
    begin
     result:=false;
     exit;
    end;
   mua := numer / denom;
   mub := (d1343 + d4321 * (mua)) / d4343;
   if (mua<0) or (mua>1) or (mub<0) or (mub>1) then
   begin
    result:=false;
    exit;
   end;
   pa.x := p1.x + mua * p21.x;
   pa.y := p1.y + mua * p21.y;
   pa.z := p1.z + mua * p21.z;
   pb.x := p3.x + mub * p43.x;
   pb.y := p3.y + mub * p43.y;
   pb.z := p3.z + mub * p43.z;
   distance:=Tavpointpointsq(pa,pb);
   result:=true;
end;

function intLinesphere(const p1,p2,sc:TD3DXVector3;const r:single;var ep:TD3DXVector3):boolean;
var
dp:TD3DXvector3;
a,b,c,bb4ac,a2,cp,mu2:single;
begin

   result:=false;
   dp.x := p2.x - p1.x;
   dp.y := p2.y - p1.y;
   dp.z := p2.z - p1.z;
   a := dp.x * dp.x + dp.y * dp.y + dp.z * dp.z;
   a2:=0.5/a;
   cp := p1.x * p1.x + p1.y * p1.y + p1.z * p1.z;
   cp := cp - r * r;
   c := sc.x * sc.x + sc.y * sc.y + sc.z * sc.z;
    c := c+cp-2 * (sc.x * p1.x + sc.y * p1.y + sc.z * p1.z);
    b := 2 * (dp.x * (p1.x - sc.x) + dp.y * (p1.y - sc.y) + dp.z * (p1.z - sc.z));

    bb4ac := b * b - 4 * a * c;
    if ((ABS(a) < 0.001) or  (bb4ac < 0)) then
     exit;

    bb4ac:=sqrt(bb4ac);

    //mu1 := (-b + bb4ac) * a;
    mu2 := (-b - bb4ac) * a2;
    if (mu2>0) and (mu2<1) then
     d3dxvec3lerp(ep,p1,p2,mu2)
    else exit;
   result:=true;
end;



function IntLineTri(v0,v1,v2,p0,p1:TD3DXVector3;out pi:TD3DXVector3):boolean;
const
EPS=0.00001;
var
u, v, n:TD3DXVector3;             // triangle vectors
dir, w0, w:TD3DXVector3;            // ray vectors
r, a, b:single;
uu, uv, vv, wu, wv, D:single;
s, t:single; //parametric coords
begin
    d3dxvec3subtract(u,v1,v0);
    d3dxvec3subtract(v,v2,v0);
    d3dxvec3cross(n,u,v);
    if (n.x=0) and (n.y=0) and (n.z=0) then           // triangle is degenerate
    begin
     result:=false;                // do not deal with this case
     exit;
    end;

    d3dxvec3subtract(dir,p1,p0);         // ray direction vector
    d3dxvec3subtract(w0,p0,v0);    
    a := -d3dxvec3dot(n,w0);
    b := d3dxvec3dot(n,dir);
    if (abs(b) < EPS) then     // ray is parallel to triangle plane
    begin
     result:=false;
     exit;
    end;                      

    // get intersect point of ray with triangle plane
    r := a / b;
    if (r < 0.0) or (r>1) then                  // ray goes away from triangle
    begin
     result:=false;
     exit;
    end;
     /////////////
    pI.x := p0.x + r * dir.x;           // intersect point of ray and plane
    pI.y := p0.y + r * dir.y;
    pI.z := p0.z + r * dir.z;
    // is I inside T?

    uu := d3dxvec3dot(u,u);
    uv := d3dxvec3dot(u,v);
    vv := d3dxvec3dot(v,v);
    d3dxvec3subtract(w,pi,v0);
    wu := d3dxvec3dot(w,u);
    wv := d3dxvec3dot(w,v);
    D := uv * uv - uu * vv;

    // get and test parametric coords
    s := (uv * wv - vv * wu) / D;
    if ((s < 0.0) or (s > 1.0)) then       // I is outside T
    begin
     result:=false;
     exit;
    end;
    t := (uv * wu - uu * wv) / D;
    if ((t < 0.0) or ((s + t) > 1.0)) then // I is outside T
    begin
     result:=false;
     exit;
    end;

    result:=true;                      // I is in T
end;

function makeacc(av0,av1,av2:TD3DXVector3):Tacctri;
begin
with result do begin
 v0:=av0;
 v1:=av1;
 v2:=av2;
 
 d3dxvec3subtract(u,v1,v0);
 d3dxvec3subtract(v,v2,v0);
 d3dxvec3subtract(a,v2,v1);

 d3dxvec3cross(n,u,v);
 if d3dxvec3lengthsq(n)<0.00001 then
 begin
  n:=D3DXVector3zero; n.y:=2;
 end
 else
  d3dxvec3normalize(n,n);
 uu := d3dxvec3dot(u,u);
 uv := d3dxvec3dot(u,v);
 vv := d3dxvec3dot(v,v);
 if (uv * uv - uu * vv)=0 then
  invD:=1
 else
 invD:=1 / (uv * uv - uu * vv);
 d3dxvec3minimize(vmin,av0,av1);
 d3dxvec3minimize(vmin,vmin,av2);
 d3dxvec3maximize(vmax,av0,av1);
 d3dxvec3maximize(vmax,vmax,av2);
end;
end;

function intlinetriAcc(tri:Tacctri;p0,p1:TD3DXVector3):boolean;
const                                
EPS=0.00001;
var             // triangle vectors
dir, w0, w:TD3DXVector3;            // ray vectors
r:single;
wu, wv:single;
s, t:single; //parametric coords
begin
with tri do  begin
    d3dxvec3subtract(dir,p1,p0);         // ray direction vector
    d3dxvec3subtract(w0,p0,v0);
    // get intersect point of ray with triangle plane
    r:= d3dxvec3dot(n,dir);
    if r<>0 then
    r := -d3dxvec3dot(n,w0) / r;
    if (r < 0.0) or (r>1) then                  // ray goes away from triangle
    begin
     result:=false;
     exit;
    end;
     /////////////
    w.x := w0.x + r * dir.x;           // intersect point of ray and plane
    w.y := w0.y + r * dir.y;
    w.z := w0.z + r * dir.z;
    //D3DXPlaneIntersectLine(w,plane,p0,p1);
    wu := d3dxvec3dot(w,u);
    wv := d3dxvec3dot(w,v);

    // get and test parametric coords
    s := (uv * wv - vv * wu) * invD;
    if ((s < 0.0) or (s > 1.0)) then       // I is outside T
    begin
     result:=false;
     exit;
    end;
    t := (uv * wu - uu * wv) * invD;
    if ((t < 0.0) or ((s + t) > 1.0)) then // I is outside T
    begin
     result:=false;
     exit;
    end;

    result:=true;                      // I is in T
end;
end;

function RajtPointTri(tri:Tacctri;p0:TD3DXVector3;out pi:TD3DXVector3):boolean;
const
EPS=0.00001;
var
            // triangle vectors
w0, w:TD3DXVector3;            // ray vectors
r,  wu, wv:single;

s, t:single; //parametric coords
begin
with tri do
begin
   { if (n.x=0) and (n.y=0) and (n.z=0) then           // triangle is degenerate
    begin
     result:=false;                // do not deal with this case
     exit;
    end;  }

    d3dxvec3subtract(w0,p0,v0);
    r := -d3dxvec3dot(n,w0);

    // get intersect point of ray with triangle plane

    w.x := w0.x + r * n.x;           // intersect point of ray and plane
    w.y := w0.y + r * n.y;
    w.z := w0.z + r * n.z;
    // is I inside T?
    wu := d3dxvec3dot(w,u);
    wv := d3dxvec3dot(w,v);

    // get and test parametric coords
    s := (uv * wv - vv * wu) * invD;
    if ((s < 0.0) or (s > 1.0)) then       // I is outside T
    begin
     result:=false;
     exit;
    end;
    t := (uv * wu - uu * wv) * invD;
    if ((t < 0.0) or ((s + t) > 1.0)) then // I is outside T
    begin
     result:=false;
     exit;
    end;

    d3dxvec3add(pi,w,v0);
    result:=true;                      // I is in T
end;
end;

function intlinetribol(tri:Tacctri;vec,ir:TD3DXVector3):boolean;
var
 bol:boolean;
 a,b:TD3DXVector3;
begin
 result:=false;
 //d3dxvec3subtract(ir,ir,vec);
 d3dxvec3subtract(a,vec,tri.v0);

 d3dxvec3cross(b,tri.u,ir);
 bol:=d3dxvec3dot(a,b)>0;

 d3dxvec3subtract(a,vec,tri.v1);

 d3dxvec3cross(b,tri.a,ir);
 if (d3dxvec3dot(a,b)>0) xor bol then exit;

 d3dxvec3subtract(a,vec,tri.v2);
 d3dxvec3cross(b,tri.v,ir);

 //A V-vel ford�tva!!!
 if (d3dxvec3dot(a,b)<0) xor bol then exit;
// if bol2 then exit;

 a:=D3DXVector3(vec.x+ir.x*1000,vec.y+ir.y*1000,vec.z+ir.z*1000);
 d3dxvec3subtract(a,a,tri.v2);
 d3dxvec3subtract(b,vec,tri.v2);
 if (d3dxvec3dot(a,tri.n)>0) xor (d3dxvec3dot(b,tri.n)<0) then exit;
 
 result:=true;
end;




function tavpointtrisq(tri:Tacctri;poi:TD3DXVector3;out pi:Td3dxvector3):single;
var
adst,dst:single;
apoi:TD3dxvector3;
begin
 if rajtpointtri(tri,poi,pi) then
 begin
  result:=tavpointpointsq(poi,pi);
  exit;
 end;
 dst:=12345678;
 if tavpointlinesq(poi,tri.v0,tri.v1,apoi,adst) then
 begin
  dst:=adst;pi:=apoi;
 end;
 if tavpointlinesq(poi,tri.v1,tri.v2,apoi,adst) then
 if adst<dst then
 begin
  dst:=adst;pi:=apoi;
 end;
 if tavpointlinesq(poi,tri.v0,tri.v2,apoi,adst) then
 if adst<dst then
 begin
  dst:=adst;pi:=apoi;
 end;

 adst:=tavpointpointsq(poi,tri.v0);
 if adst<dst then
 begin
  dst:=adst;pi:=tri.v0;
 end;

 adst:=tavpointpointsq(poi,tri.v1);
 if adst<dst then
 begin
  dst:=adst;pi:=tri.v1;
 end;
 adst:=tavpointpointsq(poi,tri.v2);
 if adst<dst then
 begin
  dst:=adst;pi:=tri.v2;
 end;
 result:=dst;
end;

function tavpointtri(tri:Tacctri;poi:TD3DXVector3;out pi:Td3dxvector3):single;
begin
 result:=sqrt(tavpointtri(tri,poi,pi));
end;

function LTFF(adevice:IDirect3DDevice9;nev:string ;out tex:IDirect3DTexture9):boolean;
var
gotolni:boolean;
probal:byte;
label
vissz;
begin
// result:=false;
 probal:=0;
 vissz:
 gotolni:=false;
 try
  if FAILED(D3DXCreateTextureFromFileEx(aDevice,PChar(nev),D3DX_DEFAULT ,D3DX_DEFAULT,D3DX_DEFAULT ,0,D3DFMT_A8R8G8B8,
                                           fav3DPOOL,D3DX_DEFAULT,D3DX_DEFAULT ,0,nil,nil, tex)) then gotolni:=true;
 except
 gotolni:=true;
 end;

 if gotolni then begin inc(probal); if probal<5 then goto vissz end;
 if gotolni then begin writeln(logfile,'Could not load texture:',nev);flush(logfile); end;
 result:=not gotolni;

 //addfiletochecksum(nev);
end;

// 0..high ha megtal�lta, -1..-high-1 ha nem
function BSearch(arr:Tintarr;mit:integer):integer;overload;
var
first,upto,mid:integer;
begin
 first:=0;
 upto:=high(arr)+1;
 while (first < upto) do
 begin
   mid := (first + upto) div 2;
   if (mit < arr[mid]) then
            upto := mid
   else if (mit > arr[mid]) then
            first := mid + 1
   else
   begin result:= mid; exit; end;
 end;
 result:= -(first + 1);    // Failed to find key
end;

function Badd(var arr:Tintarr; mit:integer):boolean;overload;
var
hol,i:integer;
begin
 hol:=Bsearch(arr,mit);
 result:=false;
 if hol>=0 then exit;
 result:=true;
 hol:=-hol-1;
 setlength(arr,length(arr)+1);
 for i:=high(arr)-1 downto hol do arr[i+1]:=arr[i];
 arr[hol]:=mit;
end;

function BSearch(arr:Tfloatarr;mit:single):integer;overload;
var
first,upto,mid:integer;
begin
 first:=0;
 upto:=high(arr)+1;
 while (first < upto) do
 begin
   mid := (first + upto) div 2;
   if (mit < arr[mid]) then
            upto := mid
   else if (mit > arr[mid]) then
            first := mid + 1
   else
   begin result:= mid; exit; end;
 end;
 result:= -(first + 1);    // Failed to find key
end;

function Badd(var arr:Tfloatarr; mit:single):boolean;overload;
var
hol,i:integer;
begin
 hol:=Bsearch(arr,mit);
 result:=false;
 if hol>=0 then exit;
 result:=true;
 hol:=-hol-1;
 setlength(arr,length(arr)+1);
 for i:=high(arr)-1 downto hol do arr[i+1]:=arr[i];
 arr[hol]:=mit;
end;

function BSearch(arr:TKDData;mit:word):integer;overload;
var
first,upto,mid:integer;
begin
 first:=0;
 upto:=high(arr)+1;
 while (first < upto) do
 begin
   mid := (first + upto) div 2;
   if (mit < arr[mid]) then
            upto := mid
   else if (mit > arr[mid]) then
            first := mid + 1
   else
   begin result:= mid; exit; end;
 end;
 result:= -(first + 1);    // Failed to find key
end;

function Badd(var arr:TKDData; mit:word):boolean;overload;
var
hol,i:integer;
begin
 hol:=Bsearch(arr,mit);
 result:=false;
 if hol>=0 then exit;
 result:=true;
 hol:=-hol-1;
 setlength(arr,length(arr)+1);
 for i:=high(arr)-1 downto hol do arr[i+1]:=arr[i];
 arr[hol]:=mit;
end;

function tegtegben(ax1,ay1,amx,amy,bx1,by1,bmx,bmy:integer):boolean;overload;
begin
 result:=(max(ax1,bx1)<min(ax1+amx,bx1+bmx)) and
         (max(ay1,by1)<min(ay1+amy,by1+bmy));
end;

function tegtegben(a,b:Tsinglerect):boolean;overload;
begin
 result:=(max(a.x1,b.x1)<min(a.x2,b.x2)) and
         (max(a.y1,b.y1)<min(a.y2,b.y2));
end;

function tegtegben(a,b:TAABB):boolean;overload;
begin
 result:=(min(a.max.x,b.max.x)>=max(a.min.x,b.min.x)) and
         (min(a.max.y,b.max.y)>=max(a.min.y,b.min.y)) and
         (min(a.max.z,b.max.z)>=max(a.min.z,b.min.z));
{ result:= result or  ((a.max.x=b.min.x) or
                      (a.max.y=b.min.y) or
                      (a.max.z=b.min.z))}
end;

function tritegben(a:Tacctri;b:TAABB):boolean; overload;
var
aa:TAABB;
const
KIS_DELTA=0.00;
begin
 d3dxvec3maximize(aa.max,a.v0,a.v1);
 d3dxvec3maximize(aa.max,aa.max,a.v2);
 d3dxvec3minimize(aa.min,a.v0,a.v1);
 d3dxvec3minimize(aa.min,aa.min,a.v2);
 b.min.x:= b.min.x+KIS_DELTA; b.min.y:= b.min.y+KIS_DELTA; b.min.z:= b.min.z+KIS_DELTA;
 aa.min.x:= aa.min.x+KIS_DELTA; aa.min.y:= aa.min.y+KIS_DELTA; aa.min.z:= aa.min.z+KIS_DELTA;
 result:=tegtegben(aa,b);
end;

function tritegben(a:Tminmaxtri;b:TAABB):boolean;overload;
var
aa:TAABB;
const
KIS_DELTA=-0.000;
begin
 aa.min:=a[3];
 aa.max:=a[4];
// b.min.x:= b.min.x+KIS_DELTA; b.min.y:= b.min.y+KIS_DELTA; b.min.z:= b.min.z+KIS_DELTA;
 aa.min.x:= aa.min.x+KIS_DELTA; aa.min.y:= aa.min.y+KIS_DELTA; aa.min.z:= aa.min.z+KIS_DELTA;
 result:=tegtegben(aa,b);
end;

procedure packrect(rect:array of Tsinglerect;var wantrect:array of Tsinglerect;var maxx,maxy:single);
var
sarkok:array of TD3DXVector2;
sarokhi:integer;
i,j,k,l,josarok,josarok2:integer;
tmptav,mintav:single;
jo:boolean;
hrc:boolean;
wri,wrk:Tsinglerect;
begin
 maxx:=0;
 maxy:=0;
 sarokhi:=0;
 setlength(sarkok,100);
 sarkok[0].x:=0;sarkok[0].y:=0;

 hrc:=high(rect)>300;
 for i:=0 to high(rect) do
 begin
  mintav:=100000;
  josarok:=0;
  josarok2:=0;
  if hrc then
  begin { Gagyi algoritmus}
   for j:=sarokhi downto 0 do
   begin

    wantrect[i].x1:=rect[i].x1+sarkok[j].x; wantrect[i].x2:=rect[i].x2+sarkok[j].x;
    wantrect[i].y1:=rect[i].y1+sarkok[j].y; wantrect[i].y2:=rect[i].y2+sarkok[j].y;
    tmptav:=max(wantrect[i].x2,wantrect[i].y2);
    // ha el�g kicsi, ellen�rz�s
    if tmptav<mintav then
    begin
     jo:=true;
     wri:=wantrect[i];

     for k:=i-1 downto 0 do
     begin
      wrk:=wantrect[k];
      if (max(wri.x1,wrk.x1)<min(wri.x2,wrk.x2)) and
         (max(wri.y1,wrk.y1)<min(wri.y2,wrk.y2)) then begin jo:=false; break; end;
     end;

     if jo then
     begin
      mintav:=tmptav;
      josarok:=j;
     end;
    end;
    //ellen�rz�s v�ge
   end;
   wantrect[i].x1:=rect[i].x1+sarkok[josarok].x; wantrect[i].x2:=rect[i].x2+sarkok[josarok].x;
   wantrect[i].y1:=rect[i].y1+sarkok[josarok].y; wantrect[i].y2:=rect[i].y2+sarkok[josarok].y;
  end
  else  { �ber algoritmus }
  begin
   for j:=0 to sarokhi do
   for l:=0 to sarokhi do
   begin

    wantrect[i].x1:=rect[i].x1+sarkok[j].x; wantrect[i].x2:=rect[i].x2+sarkok[j].x;
    wantrect[i].y1:=rect[i].y1+sarkok[l].y; wantrect[i].y2:=rect[i].y2+sarkok[l].y;
    tmptav:=max(wantrect[i].x2,wantrect[i].y2);
    // ha el�g kicsi, ellen�rz�s
    if tmptav<mintav then
    begin
     jo:=true;
     for k:=0 to i-1 do
      if tegtegben(wantrect[i],wantrect[k]) then begin jo:=false; break; end;
     if jo then
     begin
      mintav:=tmptav;
      josarok:=j;
      josarok2:=l;
     end;
    end;
   end;
    //ellen�rz�s v�ge
   wantrect[i].x1:=rect[i].x1+sarkok[josarok].x; wantrect[i].x2:=rect[i].x2+sarkok[josarok].x;
   wantrect[i].y1:=rect[i].y1+sarkok[josarok2].y; wantrect[i].y2:=rect[i].y2+sarkok[josarok2].y;
  end;
  inc(sarokhi);
  if sarokhi>high(sarkok) then
   setlength(sarkok,sarokhi+100);
  sarkok[sarokhi].x:=wantrect[i].x1;sarkok[sarokhi].y:=wantrect[i].y2;
  sarkok[josarok     ].x:=wantrect[i].x2;sarkok[josarok     ].y:=wantrect[i].y1;
  if wantrect[i].x2>maxx then maxx:=wantrect[i].x2;
  if wantrect[i].y2>maxy then maxy:=wantrect[i].y2;
 end;
 //meglep�en kis k�d, meglep�en sokszor fut le.... n*n*n szerintem. Na mendegy
end;

procedure randomplus(var mit:TD3DXVector3;az,scal:single);
begin
 with mit do
 begin
  x:=x+perlin.noise(y,z,az)*scal;
  y:=y+perlin.noise(z,x,az)*scal;
  z:=z+perlin.noise(x,y,az)*scal;
 end;
end;

procedure randomplus2(var mit:TD3DXVector3;az,scal:single);
begin
 with mit do
 begin
  x:=x+perlin.noise(az,az*2,az*3)*scal;
  y:=y+perlin.noise(az*3,az,az*2)*scal;
  z:=z+perlin.noise(az*2,az*3,az)*scal;
 end;
end;


function randomvec(az,scal:single):TD3DXVector3;
begin
 with result do
 begin
  x:=perlin.noise(az,1.5,2.5)*scal;
  y:=perlin.noise(1.5,2.5,az)*scal;
  z:=perlin.noise(1.5,az,2.5)*scal;
 end;
end;



function noNaNINF(var mi:single):boolean;
var
mi2:cardinal absolute mi;
begin
 result:=(mi2 and infinitymask)=infinitymask;
 if result then mi:=0;
end;

function noNaNINF(var mi:TD3DVector):boolean;
begin
{$B+}
 result:=noNaNINF(mi.x) or noNaNINF(mi.y) or noNaNINF(mi.z);
 {$B-}
end;

procedure constraintfloat2(var mi:single);
begin
 if (mi<-5000*5000) and (mi>5000*5000) then mi:=0;
end;

procedure constraintfloat(var mi:single);
begin
 NoNANINF(mi);
 if (mi<-5000) and (mi>5000) then mi:=0;
end;

procedure constraintvec(var mi:TD3DVector);
begin
 constraintfloat(mi.x);
 constraintfloat(mi.y);
 constraintfloat(mi.z);
end;

function point(ax,ay:integer):Tpoint;
begin
 with result do begin
  x:=ax;y:=ay; end;
end;

function trisinAABB(alaptris:Tacctriarr;alapdata:TKDData;var hova:TKDData;teg:TAABB;masoldis:boolean):integer;
var
 i,hgh:integer;
begin
 if masoldis then
 setlength(hova,length(alapdata));
 hgh:=0;
 for i:=0 to high(alapdata) do
  if tritegben(alaptris[alapdata[i]],teg) then
  begin
   if masoldis then
   hova[hgh]:=alapdata[i];
   inc(hgh);
  end;
 if masoldis then
 setlength(hova,hgh);
 result:=hgh;
end;

var
globalhova,globalKDData:TKDData;
globalKDTree:TKDTree;

procedure ConstructKDtree(var  KDtree:TKDtree; var KDData:TKDData;indexes:TKDData;axis:byte;tris:Tacctriarr;teg:TAABB);
var
axisvec:TD3DXVector3;
lehetseges:Tfloatarr;
i,szam2:integer;
tt1,tt2:TKDData;
jo,jo2:TAABB;
josing:single;
joszam,tri1,tri2:integer;
teg1,teg2:TAABB;
thisleaf,voltlngt:integer;
label
megsejo;
const
KIS_DELTA=-0.0000;
begin
 joszam:=0;
 josing:=0;
 Setlength(KDtree,length(kdtree)+1);
 thisleaf:=high(KDtree);
 axisvec:=D3DXVector3zero;
 case axis of
  0:axisvec.x:=1;
  1:axisvec.y:=1;
  2:axisvec.z:=1;
 end;
 if (length(indexes)>1) then
 begin
  for i:=0 to high(indexes) do
  begin
   Badd(lehetseges,d3dxvec3dot(axisvec,tris[indexes[i]].v0));
   //Badd(lehetseges,d3dxvec3dot(axisvec,tris[indexes[i]].v0)+0.01);
   Badd(lehetseges,d3dxvec3dot(axisvec,tris[indexes[i]].v0)-0.01);

   Badd(lehetseges,d3dxvec3dot(axisvec,tris[indexes[i]].v1));
   //Badd(lehetseges,d3dxvec3dot(axisvec,tris[indexes[i]].v1)+0.01);
   Badd(lehetseges,d3dxvec3dot(axisvec,tris[indexes[i]].v1)-0.01);

   Badd(lehetseges,d3dxvec3dot(axisvec,tris[indexes[i]].v2));
   //Badd(lehetseges,d3dxvec3dot(axisvec,tris[indexes[i]].v2)+0.01);
   Badd(lehetseges,d3dxvec3dot(axisvec,tris[indexes[i]].v2)-0.01);
  end;
 // szam:=length(indexes) div 2;
  //szam:=trisinAABB(tris,indexes,tt1,teg,false) div 2;

   //keres�nk egy j� v�laszt� s�kot
  joszam:=0;
  josing:=0;
  teg1:=teg;teg2:=teg;
  for i:=0 to high(lehetseges) do
  begin
   case axis of
    0:teg1.max.x:=lehetseges[i]+KIS_DELTA;
    1:teg1.max.y:=lehetseges[i]+KIS_DELTA;
    2:teg1.max.z:=lehetseges[i]+KIS_DELTA;
   end;
   case axis of
    0:teg2.min.x:=lehetseges[i];//+KIS_DELTA;
    1:teg2.min.y:=lehetseges[i];//+KIS_DELTA;
    2:teg2.min.z:=lehetseges[i];//+KIS_DELTA;
   end;
   tri1:=trisinAABB(tris,indexes,tt1,teg1,false);
   tri2:=trisinAABB(tris,indexes,tt2,teg2,false);
   if (tri1=0) or (tri2=0) or (tri1=length(indexes)) or (tri2=length(indexes)) then continue;
   szam2:=min(length(indexes)-tri1,length(indexes)-tri2);

   if szam2>joszam then
   begin
    joszam:=szam2;
    jo:=teg1; jo2:=teg2;
    josing:=lehetseges[i]+KIS_DELTA;
   // if szam2<1 then break;
   end;
  end;
  setlength(lehetseges,0);
 end;
 //szam:= div 2;
 if (length(indexes)>1){ and (joszam<100000)} and (joszam>3) then
 begin
  teg1:=jo;
  KDtree[thisleaf].tricount:=0;
  KDtree[thisleaf].tristart:=0;
  KDtree[thisleaf].split:=josing;
//  KDtree[thisleaf].leftteg:=teg1;
  KDtree[thisleaf].left:=length(KDTree);
  trisinAABB(tris,indexes,tt1,teg1,true);
  ConstructKDTree(KDTree,KDDAta,tt1,(axis+1) mod 3,tris,teg1);

  teg2:=jo2;
  KDtree[thisleaf].right:=length(KDTree);
//  KDtree[thisleaf].rightteg:=teg2;
  trisinAABB(tris,indexes,tt1,teg2,true);
  ConstructKDTree(KDTree,KDDAta,tt1,(axis+1) mod 3,tris,teg2);
 end
 else
 begin
  //trisinAABB(tris,indexes,tt1,teg,true);
  KDtree[thisleaf].tricount:=length(indexes);
  voltlngt:=length(KDData);
  KDTree[thisleaf].tristart:=length(KDData);
  KDTree[thisleaf].split:=0;
  KDtree[thisleaf].left:=0;
  KDtree[thisleaf].right:=0;
  setlength(KDData,length(KDData)+length(indexes));
  inc(lflngt);
  inc(lflngt2,high(indexes));
  for i:=0 to high(indexes) do
   KDData[voltlngt+i]:=indexes[i];
 end;
end;

procedure doKDTreetraversal(teg:TAABB;wichleaf,axis:integer);
var
mmin,mmax:single;
i:integer;
begin

 mmin:=0;
 mmax:=0;
 if globalKDTree=nil then exit;
 case axis of
  0:begin mmin:=teg.min.x;mmax:=teg.max.x; end;
  1:begin mmin:=teg.min.y;mmax:=teg.max.y; end;
  2:begin mmin:=teg.min.z;mmax:=teg.max.z; end;
 end;
 if globalKDTree[wichleaf].left=0 then
 begin
 // volthgh:=high(globalhova)+1;
 // setlength(globalhova,length(globalhova)+globalKDTree[wichleaf].tricount);
  for i:=0 to globalKDTree[wichleaf].tricount-1 do
   Badd(globalhova,globalKDData[globalKDTree[wichleaf].tristart+i]);
 end
 else
 begin
  if mmin<globalKDtree[wichleaf].split then doKDTreetraversal(teg,globalKDTree[wichleaf].left,(axis+1) mod 3);
  if mmax>globalKDtree[wichleaf].split then doKDTreetraversal(teg,globalKDTree[wichleaf].right,(axis+1) mod 3);
 end;
end;

procedure traverseKDtree(teg:TAABB;var hova:TKDData;KDData:TKDData;KDTree:TKDTree);
begin
 setlength(hova,0);
 globalhova:=hova;
 globalKDData:=KDData;
 globalKDTree:=KDTree;
 doKDTreetraversal(teg,0,0);
 hova:=globalhova;
end;

var
globalKDTris:Tacctriarr;

procedure doKDTreetraversallin(v1,ir,invir:TD3DXVector3;rad:single;wichleaf,axis:integer;DNTtri:boolean);
var
i:integer;
tmp,r2:single;
tmp2:TD3DXVector3;
b1:boolean;
const
mod3lookup: array [0..2] of byte =(1,2,0);
begin
 b1:=false;
 tmp:=0;
 if not DNTtri then
  if length(globalhova)>0 then exit;
 if globalKDTree=nil then exit;
 if rad<0 then exit;
 if globalKDTree[wichleaf].left=0 then
 begin
 // volthgh:=high(globalhova)+1;
 // setlength(globalhova,length(globalhova)+globalKDTree[wichleaf].tricount);
  for i:=0 to globalKDTree[wichleaf].tricount-1 do
  if intlinetribol(globalKDtris[globalKDData[globalKDTree[wichleaf].tristart+i]],v1,ir) then
   Badd(globalhova,globalKDData[globalKDTree[wichleaf].tristart+i]);
 end
 else
 begin
  case axis of
   0:tmp:=(globalKDtree[wichleaf].split-v1.x)*invir.x;
   1:tmp:=(globalKDtree[wichleaf].split-v1.y)*invir.y;
   2:tmp:=(globalKDtree[wichleaf].split-v1.z)*invir.z;
  end;
  if (tmp>=0) and (tmp<=rad) then
  begin
   r2:=rad-tmp;
   d3dxvec3scale(tmp2,ir,tmp);
   d3dxvec3add(tmp2,v1,tmp2);
   case axis of
    0:b1:=(globalKDtree[wichleaf].split>v1.x);
    1:b1:=(globalKDtree[wichleaf].split>v1.y);
    2:b1:=(globalKDtree[wichleaf].split>v1.z);
   end;
   if b1 then
   begin
    doKDTreetraversallin(v1,ir,invir,tmp,globalKDTree[wichleaf].left,mod3lookup[axis],DNTtri);
    doKDTreetraversallin(tmp2,ir,invir,r2,globalKDTree[wichleaf].right,mod3lookup[axis],DNTtri);
   end
   else
   begin
    doKDTreetraversallin(v1,ir,invir,tmp,globalKDTree[wichleaf].right,mod3lookup[axis],DNTtri);
    doKDTreetraversallin(tmp2,ir,invir,r2,globalKDTree[wichleaf].left,mod3lookup[axis],DNTtri);
   end
  end
  else
  begin
   case axis of
    0:b1:=(globalKDtree[wichleaf].split>v1.x);
    1:b1:=(globalKDtree[wichleaf].split>v1.y);
    2:b1:=(globalKDtree[wichleaf].split>v1.z);
   end;
    if b1 then
     doKDTreetraversallin(v1,ir,invir,rad,globalKDTree[wichleaf].left,mod3lookup[axis],DNTtri)
    else
     doKDTreetraversallin(v1,ir,invir,rad,globalKDTree[wichleaf].right,mod3lookup[axis],DNTtri);
  end;
 end;
end;

procedure traverseKDtreelin(v1,v2:TD3DXVector3;var hova:TKDData;KDData:TKDData;KDTree:TKDTree;trik:Tacctriarr);
var
tmp,invtmp:TD3DXVector3;
lngt:single;
begin
 globalhova:=hova;
 globalKDData:=KDData;
 globalKDTree:=KDTree;
 globalkdtris:=trik;
 d3dxvec3subtract(tmp,v2,v1);
 lngt:=d3dxvec3length(tmp);
 if lngt=0 then lngt:=1;
 d3dxvec3scale(tmp,tmp,1/lngt);
 if tmp.x<>0 then invtmp.x:=1/tmp.x else invtmp.x:=10000000;
 if tmp.y<>0 then invtmp.y:=1/tmp.y else invtmp.y:=10000000;
 if tmp.z<>0 then invtmp.z:=1/tmp.z else invtmp.z:=10000000;

 doKDTreetraversallin(v1,tmp,invtmp,lngt,0,0,false);
 hova:=globalhova;
end;

procedure traverseKDtreelinDNT(v1,v2:TD3DXVector3;var hova:TKDData;KDData:TKDData;KDTree:TKDTree;trik:Tacctriarr);
var
tmp,invtmp:TD3DXVector3;
lngt:single;
begin
 globalhova:=hova;
 globalKDData:=KDData;
 globalKDTree:=KDTree;
 globalkdtris:=trik;
 d3dxvec3subtract(tmp,v2,v1);
 lngt:=d3dxvec3length(tmp);
 if lngt=0 then lngt:=1;
 d3dxvec3scale(tmp,tmp,1/lngt);
 if tmp.x<>0 then invtmp.x:=1/tmp.x else invtmp.x:=10000000;
 if tmp.y<>0 then invtmp.y:=1/tmp.y else invtmp.y:=10000000;
 if tmp.z<>0 then invtmp.z:=1/tmp.z else invtmp.z:=10000000;

 doKDTreetraversallin(v1,tmp,invtmp,lngt,0,0,true);
 hova:=globalhova;
end;

procedure loadKDtree(nev:string; var KDTree:TKDTree; var KDData:TKDData);
var
fil:file;
i:integer;
a,b:integer;
begin
 assignfile(fil,nev);
 reset(fil,1);
 blockread(fil,a,sizeof(integer));
 blockread(fil,b,sizeof(integer));
 setlength(KDTree,a);
 setlength(KDData,b);
 for i:=0 to a-1 do
  blockread(fil,KDTree[i],sizeof(TKDNode));
 for i:=0 to b-1 do
  blockread(fil,KDData[i],sizeof(word));
 closefile(fil);
end;


procedure saveKDtree(nev:string; KDTree:TKDTree; KDData:TKDData);
var
fil:file;
i:integer;
a,b:integer;
begin
 assignfile(fil,nev);
 rewrite(fil,1);
 a:=length(KDTree); b:=length(KDData);
 blockwrite(fil,a,sizeof(integer));
 blockwrite(fil,b,sizeof(integer));
 //setlength(KDTree,a);
 //setlength(KDData,b);
 for i:=0 to a-1 do
  blockwrite(fil,KDTree[i],sizeof(TKDNode));
 for i:=0 to b-1 do
  blockwrite(fil,KDData[i],sizeof(word));
 closefile(fil);
end;

function packfloat(mit:single;range:single):word;
begin
 noNANINF(mit);
 result:=round(((mit/range)+1)*high(word)/2);
end;

function unpackfloat(mit:word;range:single):single;
begin
 result:=((mit/high(word))*2-1)*range;
end;

function packfloatheavy(mit:single;range:single):byte;
begin
 noNANINF(mit);
 result:=round(((mit/range)+1)*high(byte)/2);
end;

function unpackfloatheavy(mit:byte;range:single):single;
begin
 result:=((mit/high(byte))*2-1)*range;
end;

function packvec(mit:TD3DXVector3;range:single):Tmypackedvector;
begin
 with result do
 begin
  x:=packfloat(mit.x,range);
  y:=packfloat(mit.y,range);
  z:=packfloat(mit.z,range);
 end;
end;

function packojjektumvertex(mit:Tojjektumvertex;range:TD3DXVector3):Tpackedojjektumvertex;
begin
 with result.position do
 begin
  x:=packfloat(mit.position.x,range.x);
  y:=packfloat(mit.position.y,range.y);
  z:=packfloat(mit.position.z,range.z);
 end;

 result.tu:=packfloat(mit.tu,128);
 result.tv:=packfloat(mit.tv,128);
 result.lu:=round(mit.lu*256);
 result.lv:=round(mit.lv*256);
end;

function packnormal(mit:TD3DXVector3):Tmypackednorm;
begin
 d3dxvec3normalize(mit,mit);
 with result do
 begin
  x:=round(mit.x*high(word)/2);
  y:=round(mit.y*high(word)/2);
 end;
end;

function unpacknormal(mit:Tmypackednorm):TD3DXVector3;
begin
 with result do
 begin
  x:=mit.x*2/high(word);
  y:=mit.y*2/high(word);
  z:=sqrt(1-x*x-y*y);
 end;
end;

function unpackvec(mit:Tmypackedvector;range:single):TD3DXVector3;
begin
 with result do
 begin
  x:=unpackfloat(mit.x,range);
  y:=unpackfloat(mit.y,range);
  z:=unpackfloat(mit.z,range);
 end;
end;

function unpackojjektumvertex(mit:Tpackedojjektumvertex;range:TD3DXVector3):Tojjektumvertex;
begin
 with result.position do
 begin
  x:=unpackfloat(mit.position.x,range.x);
  y:=unpackfloat(mit.position.y,range.y);
  z:=unpackfloat(mit.position.z,range.z);
 end;

 result.tu:=unpackfloat(mit.tu,128);
 result.tv:=unpackfloat(mit.tv,128);
 result.lu:=mit.lu/256;
 result.lv:=mit.lv/256;
end;

function packseb(pos,opos:TD3DXVector3):Tmypackedvector;
begin
 d3dxvec3subtract(pos,pos,opos);
 result:=packvec(pos,1);
end;

{
// BINMSG ADDOK
procedure binarymsgadd(var msg:Tbinmsg;var lngt:integer;mit:byte);
begin
 msg[lngt]:=mit;
 inc(lngt);
end;

procedure binarymsgadd(var msg:Tbinmsg;var lngt:integer;mit:word);
var
 mit2:array [1..2] of byte absolute mit;
begin
 msg[lngt]:=mit2[1];
 msg[lngt+1]:=mit2[2];
 inc(lngt,2);
end;

procedure binarymsgadd(var msg:Tbinmsg;var lngt:integer;mit:single);
var
 mit2:array [1..4] of byte absolute mit;
begin
 msg[lngt]:=mit2[1];
 msg[lngt+1]:=mit2[2];
 msg[lngt+2]:=mit2[3];
 msg[lngt+3]:=mit2[4];
 inc(lngt,4);
end;

procedure binarymsgadd(var msg:Tbinmsg;var lngt:integer;mit:TD3DVector);
begin
 binarymsgadd(msg,lngt,mit.x);
 binarymsgadd(msg,lngt,mit.y);
 binarymsgadd(msg,lngt,mit.z);
end;

procedure binarymsgadd(var msg:Tbinmsg;var lngt:integer;mit:TMypackedvector);
begin
 binarymsgadd(msg,lngt,mit.x);
 binarymsgadd(msg,lngt,mit.y);
 binarymsgadd(msg,lngt,mit.z);
end;

procedure binarymsgadd(var msg:Tbinmsg;var lngt:integer;mit:Tpackedpos);
begin
 binarymsgadd(msg,lngt,mit.pos);
 binarymsgadd(msg,lngt,mit.irany);
 binarymsgadd(msg,lngt,mit.irany2);
 binarymsgadd(msg,lngt,mit.state);
 binarymsgadd(msg,lngt,mit.prior);
 binarymsgadd(msg,lngt,mit.bg);

end;

// BINMSG READEK

procedure binarymsgread(var msg:Tbinmsg;var lngt:integer;var mit:byte);
begin
 mit:=msg[lngt];
 inc(lngt);
end;

procedure binarymsgread(var msg:Tbinmsg;var lngt:integer;var mit:word);
var
 mit2:array [1..2] of byte absolute mit;
begin
 mit2[1]:=msg[lngt];
 mit2[2]:=msg[lngt+1];
 inc(lngt,2);
end;

procedure binarymsgread(var msg:Tbinmsg;var lngt:integer;var mit:single);
var
 mit2:array [1..4] of byte absolute mit;
begin
 mit2[1]:=msg[lngt];
 mit2[2]:=msg[lngt+1];
 mit2[3]:=msg[lngt+2];
 mit2[4]:=msg[lngt+3];
 inc(lngt,4);
end;

procedure binarymsgread(var msg:Tbinmsg;var lngt:integer;var mit:TD3DVector);
begin
 binarymsgread(msg,lngt,mit.x);
 binarymsgread(msg,lngt,mit.y);
 binarymsgread(msg,lngt,mit.z);
end;

procedure binarymsgread(var msg:Tbinmsg;var lngt:integer;var mit:TMypackedvector);
begin
 binarymsgread(msg,lngt,mit.x);
 binarymsgread(msg,lngt,mit.y);
 binarymsgread(msg,lngt,mit.z);
end;

procedure binarymsgread(var msg:Tbinmsg;var lngt:integer;var mit:Tpackedpos);
begin
 binarymsgread(msg,lngt,mit.pos);
 binarymsgread(msg,lngt,mit.irany);
 binarymsgread(msg,lngt,mit.irany2);
 binarymsgread(msg,lngt,mit.state);
 binarymsgread(msg,lngt,mit.prior);
 binarymsgread(msg,lngt,mit.bg);
end;
        }
function kbegyenlo(mi,mivel:TD3DXVector3;epsilon:single=0.001):boolean;
begin
 result:=(abs(mi.x-mivel.x)<epsilon) and
         (abs(mi.y-mivel.y)<epsilon) and
         (abs(mi.z-mivel.z)<epsilon);
end;

function vec3add3(v1,v2,v3:TD3DXVector3):TD3DXVector3;
begin
 with result do
 begin
  x:=v1.x+v2.x+v3.x;
  y:=v1.y+v2.y+v3.y;
  z:=v1.z+v2.z+v3.z;
 end;
end;

function vec3add4(v1,v2,v3,v4:TD3DXVector3):TD3DXVector3;
begin
 with result do
 begin
  x:=v1.x+v2.x+v3.x+v4.x;
  y:=v1.y+v2.y+v3.y+v4.y;
  z:=v1.z+v2.z+v3.z+v4.z;
 end;
end;

procedure normalizemesh(g_pMesh:ID3DXMesh);
var
pvert:PD3DXVector3;
tmppvert:Pointer;
mat1,mat2:TD3DMatrix;
vmi,vma:TD3DXVector3;
siz:integer;
begin
 if FAILED(g_pMesh.LockVertexBuffer(0,pointer(pvert))) then exit;

 D3DXComputeboundingbox(pointer(pvert),g_pMesh.GetNumVertices,g_pMesh.GetNumBytesPerVertex,vmi,vma);
 zeromemory(@mat1,sizeof(mat1));
 d3dxmatrixtranslation(mat2,-vmi.x,-vmi.y,-vmi.z);
 d3dxmatrixscaling(mat1,2/(vma.x-vmi.x),2/(vma.y-vmi.y),2/(vma.z-vmi.z));
 d3dxmatrixmultiply(mat1,mat2,mat1);
 d3dxmatrixtranslation(mat2,-1,-1,-1);
 d3dxmatrixmultiply(mat1,mat1,mat2);
 siz:=g_pmesh.GetNumVertices*g_pmesh.GetNumBytesPerVertex;
 getmem(tmppvert,siz);
 copymemory(tmppvert,pvert,siz);
 d3dxvec3transformcoordarray(pvert,g_pMesh.GetNumBytesPerVertex,tmppvert,g_pMesh.GetNumBytesPerVertex,mat1,g_pMesh.GetNumVertices);
 freemem(tmppvert);
 g_pmesh.UnlockVertexBuffer;
 getmem(tmppvert,g_pmesh.GetNumFaces*12);
 g_pmesh.GenerateAdjacency(0.001,tmppvert);
 d3dxcomputenormals(g_pmesh,tmppvert);
 freemem(tmppvert);
 
end;

function doSAT(box:T7pbox;var boxbol:T7pboxbol;tri:Tacctri;var vec:TD3DXvector3):single;
var
i:integer;
mik2:array [0..7] of single;
mn,mx,mst:single;
lktp,lktm:single;
begin
 if d3dxvec3lengthsq(vec)<0.0000001 then
  begin
   result:=1; exit;
  end;

 // Minimum �s maximum
 mst:=d3dxvec3dot(vec,tri.v0);
 mx:=mst;mn:=mst;

 mst:=d3dxvec3dot(vec,tri.v1);
 if mx<mst then mx:=mst;
 if mn>mst then mn:=mst;
 
 mst:=d3dxvec3dot(vec,tri.v2);
 if mx<mst then mx:=mst;
 if mn>mst then mn:=mst;

 // a 8 pont �rt�ke
 for i:=0 to 7 do
  mik2[i]:=d3dxvec3dot(vec,box[i]);

 //merre mennyit
 lktp:=0;
 lktm:=0;
 for i:=0 to 7 do
 begin
  if (mik2[i]-mn)>=lktm then lktm:=mik2[i]-mn;
  if (mx-mik2[i])>=lktp then lktp:=mx-mik2[i];
 end;

 if (lktp=0) or (lktm=0) then begin result:=0; exit; end;
 //d�nt�s
 if lktp<=lktm then
 begin
  for i:=0 to 7 do
   boxbol[i]:= boxbol[i] and (mik2[i]<mx);
  d3dxvec3scale(vec,vec,lktp/(d3dxvec3lengthsq(vec)));
  result:=d3dxvec3lengthsq(vec);
 end
 else
 begin
  for i:=0 to 7 do
   boxbol[i]:= boxbol[i] and (mik2[i]>mn);
  d3dxvec3scale(vec,vec,-lktm/(d3dxvec3lengthsq(vec)));
  result:=d3dxvec3lengthsq(vec);
 end;
end;

function fastinvsqrt(mit:single):single;
var
felmit:single;
i:dword absolute mit;
begin
   felmit:=mit*0.5;
   i := $5f3759d5 - (i shr 1);
   mit := mit*(1.5 - felmit*mit*mit); 
   result:=mit;
end;

function fastinvsqrt2(mit:single):single;
var
felmit:single;
i:dword absolute mit; // store floating-point bits in integer
begin
   felmit:=mit*0.5;
   i := $5f3759d5 - (i shr 1); // initial guess for Newton's method
   mit := mit*(1.5 - felmit*mit*mit); // One round of Newton's method
   mit := mit*(1.5 - felmit*mit*mit); // One round of Newton's method
   result:=mit;
end;

procedure fastvec3normalize(var mit:TD3DXVector3);
var
scl:single;
begin
 scl:=fastinvsqrt(sqr(mit.x)+sqr(mit.y)+sqr(mit.z));
 with mit do
 begin
  x:=x*scl;y:=y*scl;z:=z*scl;
 end;
end;



procedure NormalTangentBinormal(el1,el2:TD3DXVector3; elu1,elv1,elu2,elv2:single; out normal,tangent,binormal:TD3DXVector3);
var
mul:single;
ltangent,lbinormal,lnormal:TD3DXVector3;
begin


  mul:=elv1 * elu2-elu1 * elv2;
  if mul<>0 then mul:=1/mul;

                   // a= elu2            b=elu1
  ltangent.x   := (El1.x * -elu2 + El2.x * elu1) * mul;
  ltangent.y   := (El1.y * -elu2 + El2.y * elu1) * mul;
  ltangent.z   := (El1.z * -elu2 + El2.z * elu1) * mul;

  lbinormal.x  := (El1.x * -elv2 + El2.x * elv1) * mul;
  lbinormal.y  := (El1.y * -elv2 + El2.y * elv1) * mul;
  lbinormal.z  := (El1.z * -elv2 + El2.z * elv1) * mul;

  d3dxvec3cross(lnormal,el1,el2);

  d3dxvec3normalize(normal,lnormal);

  binormal:=lbinormal;
  tangent:=ltangent;

  if d3dxvec3lengthsq(lbinormal)>0 then
  d3dxvec3scale(binormal,lbinormal,1/d3dxvec3lengthsq(lbinormal));
  
  if d3dxvec3lengthsq(ltangent)>0 then
  d3dxvec3scale(tangent ,ltangent ,1/d3dxvec3lengthsq(ltangent));
end;

function hextoint(mit:string):integer;
var
i:integer;
begin
 mit:=uppercase(mit);
 result:=0;
 for i:=1 to 4 do
 begin
  if i>length(mit) then break;
  case mit[i] of
   '0':inc(result, 0);
   '1':inc(result, 1);
   '2':inc(result, 2);
   '3':inc(result, 3);
   '4':inc(result, 4);
   '5':inc(result, 5);
   '6':inc(result, 6);
   '7':inc(result, 7);
   '8':inc(result, 8);
   '9':inc(result, 9);
   'A':inc(result,10);
   'B':inc(result,11);
   'C':inc(result,12);
   'D':inc(result,13);
   'E':inc(result,14);
   'F':inc(result,15);
  else
   break;
  end;
  result:=result*16;
 end;
end;


function XORHash2x12byte(v1,v2:TD3DXVector3):dword;
var
 a1:array [1..3] of DWORD absolute v1;
 a2:array [1..3] of DWORD absolute v2;
begin
 result:=a1[1] xor a1[2] xor a1[3] xor a2[1] xor a2[2] xor a2[3];
end;

function XORHexStr(str1,str2:string):string;
var
 szam:integer;
 i:integer;
begin
 szam:=min(length(str1),length(str2));
 result:='';
 for i:=0 to szam-1 do
  result:=result+inttohex(hextoint(copy(str1,i*2+1,2)) xor hextoint(copy(str2,i*2+1,2)),2);
end;

function StringHash(mit:string):cardinal;
var
i:integer;
begin
 result:=0;
 for i:=1 to length(mit) do
  result:=result*982451653+ord(mit[i]);
 result:=result*756065179;
end;

procedure explode(str:string;const key:char;var hova:Tarrayofstring);
var
str2:string;
begin
 setlength(hova,0);
 repeat
  if (pos(key,str)<1) then
  begin
   str2:=str; str:='';
  end
  else
  str2:=copy(str,1,pos(key,str)-1);
  if str2<>'' then
  begin
   setlength(hova,length(hova)+1);
   hova[high(hova)]:=str2;
  end;

  str:=copy(str,pos(key,str)+1,250);
 until  (str='');

end;


function Frustum(viewMatrix:TD3DMatrix;nearplane,farplane,fovy,ratio:single):TFrustum;
var
fr1,fr2:Array [0..5] of TD3DXVector3;
fr3:array [0..5] of TD3DXPlane;
sf,cf:single;
pos:TD3DXVector3;
mat:TD3DMatrix;
i:integer;
begin
  fovy:=fovy/2;
  d3dxmatrixinverse(mat,nil,viewmatrix);
  cf:=cos(fovy);
  sf:=sin(fovy);
  fr2[0]:=D3DXVector3(0,0,nearplane);
  fr2[1]:=D3DXVector3(cf,0,ratio*sf);
  fr2[2]:=D3DXVector3(-cf,0,ratio*sf);
  fr2[3]:=D3DXVector3(0, cf,sf);
  fr2[4]:=D3DXVector3(0, -cf,sf);
  fr2[5]:=D3DXVector3(0,0,nearplane-farplane);

  d3dxvec3transformnormalarray(pointer(@fr1),sizeof(TD3DXVector3),pointer(@fr2),sizeof(TD3DXVector3),mat,6);
  d3dxvec3transformcoord(pos,d3dxvector3zero,mat);
  for i:=1 to 4 do
   D3DXPlaneFromPointNormal(fr3[i],pos,fr1[i]);

  d3dxvec3add(pos,pos,fr1[0]);
  D3DXPlaneFromPointNormal(fr3[0],pos,fr1[0]);
  d3dxvec3subtract(pos,pos,fr1[5]);
  D3DXPlaneFromPointNormal(fr3[5],pos,fr1[5]);
  for i:=0 to 5 do
   D3DXPlaneNormalize(result[i],fr3[i]);
end;


function AABBvsFrustum(aabb:TAABB;f:TFrustum):boolean;
var
 m, n:single;
 mx,my,mz:single;
 dx,dy,dz:single;
 i:integer;
begin
 result:=true;
 with aabb do
 begin
  mx:=(min.x+max.x)*0.5;   my:=(min.y+max.y)*0.5;   mz:=(min.z+max.z)*0.5;
  dx:=mx-min.x;            dy:=my-min.y;            dz:=mz-min.z;
 end;

 for i := 0 to 5 do
  with f[i] do
  begin
     m := (mx * a) + (my * b) + (mz * c) + d;
     n := (dx * abs(a)) + (dy * abs(b)) + (dz * abs(c));
     if (m + n < 0) then
     begin
      result:=false;
      exit;
     end;
  end;

end;


function SpherevsFrustum(pos:TD3DXVector3;r:single;f:TFrustum):boolean;
var
m:single;
i:integer;
begin
 result:=true;
 for i := 0 to 5 do
  with f[i] do
  begin
   m := (pos.x * a) + (pos.y * b) + (pos.z * c) + d;
   if (m + r < 0) then
   begin
    result:=false;
    exit;
   end;
  end;

end;

procedure newchecksum(mit:integer);
asm
 ADD EAX,checksum
 MOV EDX,134775813
 MUL EDX
 INC EAX
 MOV checksum,EAX
end;

procedure addtochecksum(mit:array of DWORD;hgh:integer);
var
i:integer;
begin
 for i:=0 to hgh do
 begin
  newchecksum(mit[i]);
 end;
end;

procedure addfiletochecksum(nev:string);
var
 i:integer;
 fil:file;
 arr:array [0..127] of DWORD;
 tov:integer;
 vegul:integer;
begin
 if not fileexists(nev) then exit;
 tov:=1;
 for i:=1 to length(nev) do
  tov:=(tov+ord(nev[1])*i);
 checksum:=checksum+tov;
 assignfile(fil,nev);
 reset(fil,1);

 zeromemory(@arr,sizeof(arr));

 while not eof(fil) do
 begin
  zeromemory(@arr,sizeof(arr));
  blockread(fil,arr,127*4,vegul);
  addtochecksum(arr,vegul div 4);
 end;
 closefile(fil);
end;


                                       // (0,0,0) felett!!!
procedure OctTreeAdd(const tree:POctLeaf;const hol:TD3DXVector3;const mit:Pointer);
var
leaf:POctLeaf;
child0,child1:POctleaf;
i:integer;
label
vissza;
begin
 leaf:=Tree;

 vissza:
 //if leaf.axe>3 then messagebox(0,'OMG','OMG',0);
 while leaf.child0<>nil do
 case leaf.axe of
  0:if leaf.split>hol.x then leaf:=leaf.child0 else leaf:=leaf.child1;
  1:if leaf.split>hol.z then leaf:=leaf.child0 else leaf:=leaf.child1;
  2:if leaf.split>hol.y then leaf:=leaf.child0 else leaf:=leaf.child1;
 end;

 if (leaf.cumolngt<maxOTpoints) then
 begin
  leaf.cumok[leaf.cumolngt].poi:=mit;
  leaf.cumok[leaf.cumolngt].pos:=hol;
  inc(leaf.cumolngt);
 end
 else
 begin
  // Sok cum�, sz�t kell osztani
  new(child0);
  zeromemory(child0,sizeof(Toctleaf));
  new(child1);
  zeromemory(child1,sizeof(Toctleaf));

  leaf.child0:=child0;
  leaf.child1:=child1;

  if leaf.axe<2 then
  begin
   child0.axe:=leaf.axe+1;
   child1.axe:=leaf.axe+1;
  end else
  begin
   child0.axe:=0;
   child1.axe:=0;
  end;

  child0.parent:=leaf;
  child1.parent:=leaf;

  //childek k�z� a cum� kett�oszt�sa...
  case leaf.axe of

   0:begin
    // a child axe-ja 1-gyel od�bb van tolva!
    child0.split:=(leaf.AABB.min.z+leaf.AABB.max.z)*0.5;
    child1.split:=child0.split;

    // itt m�g az eredeti leaf.axe van
    child0.AABB:=leaf.AABB;
    child0.AABB.max.x:=leaf.split;

    child1.AABB:=leaf.AABB;
    child1.AABB.min.x:=leaf.split;

    // itt m�g az eredeti leaf.axe van
    for i:=0 to leaf.cumolngt-1 do
     if leaf.split>leaf.cumok[i].pos.x then
     begin
      child0.cumok[child0.cumolngt]:=leaf.cumok[i];
      inc(child0.cumolngt);
     end else
     begin
      child1.cumok[child1.cumolngt]:=leaf.cumok[i];
      inc(child1.cumolngt);
     end;
   end;

   1:begin
     // a child axe-ja 1-gyel od�bb van tolva!
    child0.split:=(leaf.AABB.min.y+leaf.AABB.max.y)*0.5;
    child1.split:=child0.split;

    // itt m�g az eredeti leaf.axe van
    child0.AABB:=leaf.AABB;
    child0.AABB.max.z:=leaf.split;

    child1.AABB:=leaf.AABB;
    child1.AABB.min.z:=leaf.split;

    // itt m�g az eredeti leaf.axe van
    for i:=0 to leaf.cumolngt-1 do
     if leaf.split>leaf.cumok[i].pos.z then
     begin
      child0.cumok[child0.cumolngt]:=leaf.cumok[i];
      inc(child0.cumolngt);
     end else
     begin
      child1.cumok[child1.cumolngt]:=leaf.cumok[i];
      inc(child1.cumolngt);
     end;
   end;

   2:begin
    // a child axe-ja 1-gyel od�bb van tolva!
    child0.split:=(leaf.AABB.min.x+leaf.AABB.max.x)*0.5;
    child1.split:=child0.split;

    // itt m�g az eredeti leaf.axe van
    child0.AABB:=leaf.AABB;
    child0.AABB.max.y:=leaf.split;

    child1.AABB:=leaf.AABB;
    child1.AABB.min.y:=leaf.split;

    // itt m�g az eredeti leaf.axe van
    for i:=0 to leaf.cumolngt-1 do
     if leaf.split>leaf.cumok[i].pos.y then
     begin
      child0.cumok[child0.cumolngt]:=leaf.cumok[i];
      inc(child0.cumolngt);
     end else
     begin
      child1.cumok[child1.cumolngt]:=leaf.cumok[i];
      inc(child1.cumolngt);
     end;
   end;
  end;
  leaf.cumolngt:=0;
  goto vissza;
 end;
end;

procedure OctTreeDel(const tree:POctLeaf;const hol:TD3DXVector3;const mit:Pointer);
var
leaf:PoctLeaf;
i,hi:integer;
begin
 leaf:=tree;
 while leaf.child0<>nil do
 case leaf.axe of
  0:if leaf.split>hol.x then leaf:=leaf.child0 else leaf:=leaf.child1;
  1:if leaf.split>hol.z then leaf:=leaf.child0 else leaf:=leaf.child1;
  2:if leaf.split>hol.y then leaf:=leaf.child0 else leaf:=leaf.child1;
 end;
 hi:=-1;
 for i:=0 to leaf.cumolngt-1 do
  if leaf.cumok[i].poi=mit then
  begin
   hi:=i;
   break;
  end;
 if hi<0 then
  exit;

 leaf.cumok[hi]:=leaf.cumok[leaf.cumolngt-1];
 dec(leaf.cumolngt);

 //Joinol�s
 repeat
  leaf:=leaf.parent;
  if leaf=nil then exit;
  // ha valamelyik is parent, kil�p�s
  if (leaf.child0.child0<>nil) or (leaf.child1.child0<>nil) then exit;
  // ha el�rik a maxim�lis pontsz�mot, kil�p�s
  if (leaf.child0.cumolngt+leaf.child1.cumolngt)>maxOTpoints then exit;

  // egy leafbe m�sol�s
  hi:=leaf.child0.cumolngt;
  for i:=0 to hi-1 do
   leaf.cumok[   i]:=leaf.child0.cumok[i];
  for i:=0 to leaf.child1.cumolngt-1 do
   leaf.cumok[hi+i]:=leaf.child1.cumok[i];
  leaf.cumolngt:=leaf.child0.cumolngt+leaf.child1.cumolngt;
  dispose(leaf.child0); leaf.child0:=nil;
  dispose(leaf.child1); leaf.child1:=nil;
 until false;
end;

var
globocttreeres:Tarrayofpointer;

procedure doOctTreeGetRegion(const tree:PoctLeaf;const aabb:TAABB);
var
spltmin,spltmax:single;
lngt,i:integer;
begin
 spltmin:=0; spltmax:=0;
 if tree.child0<>nil then
 begin
  case tree.axe of
   0:begin spltmin:=aabb.min.x; spltmax:=aabb.max.x end;
   1:begin spltmin:=aabb.min.z; spltmax:=aabb.max.z end;
   2:begin spltmin:=aabb.min.y; spltmax:=aabb.max.y end;
  end;

  if tree.split>=spltmin then dooctTreeGetRegion(tree.child0,aabb);
  if tree.split<=spltmax then dooctTreeGetRegion(tree.child1,aabb);
 end
 else
 begin
  lngt:=length(globocttreeres);
  setlength(globocttreeres,length(globocttreeres)+tree.cumolngt);
  for i:=0 to tree.cumolngt-1 do
   globocttreeres[lngt+i]:=tree.cumok[i].poi;
 end;

end;

procedure OctTreeGetRegion(const tree:PoctLeaf;const aabb:TAABB; var res:Tarrayofpointer);
begin
 setlength(res,0);
 globocttreeres:=res;
 doOcttreegetregion(tree,aabb);
 res:=globocttreeres;

end;


procedure StickMeshFeltordel(var mesh:TStickmesh);
type
 Ttordeloel=record
  e1,e2:word;
  p1,p2:word;
 end;
var
i,j,k:integer;
elek:array of Ttordeloel;
indek:TKDData;
ap1,ap2,ap3:integer;
tv1,tv2:TD3DXVector3;
v1,v2:TD3DXVector3;
flt:single;
label
 done;
begin
with mesh do begin

 for i:=0 to high(indices) div 3 do
  for j:=0 to 2 do
  begin
   ap1:=indices[i*3+(j+0)      ]; //e1 lesz
   ap2:=indices[i*3+(j+1) mod 3]; //e2 lesz
   ap3:=indices[i*3+(j+2) mod 3]; //e3 lesz
   for k:=0 to high(elek) do
    if (elek[k].e1=ap2) and (elek[k].e2=ap1) then
    begin
     elek[k].p2:=ap3;
     goto done;
    end;
   setlength(elek,length(elek)+1);
   with elek[high(elek)] do
   begin
    e1:=ap1;
    e2:=ap2;
    p1:=ap3;
    p2:=high(word);
   end;
   done:
  end;

 for i:=0 to high(elek) do
 begin
  with elek[i] do
  begin
   if p2=high(word) then continue;
   d3dxvec3subtract(tv1,vertices[e1].position,vertices[p1].position);
   d3dxvec3subtract(tv2,vertices[e2].position,vertices[p1].position);
   d3dxvec3cross(v1,tv1,tv2);
   fastvec3normalize(v1);

   d3dxvec3subtract(tv1,vertices[e1].position,vertices[p2].position);
   d3dxvec3subtract(tv2,vertices[e2].position,vertices[p2].position);
   d3dxvec3cross(v2,tv2,tv1);                             
   fastvec3normalize(v2);

   flt:=abs(d3dxvec3dot(v1,v2));
   if flt<cos(pi*0.4) then
   begin
    badd(indek,e1);
    badd(indek,e2);
   end
  end;
 end;

// messagebox(0,pchar(inttostr(indek[5])),'cucc',0);

end; end;

function StickmeshConvertX(mesh:ID3DXMesh;textures:array of string):TStickmesh;
type
 TD3DXAttributerangearr= array [0..100] of TD3DXAttributerange;
 PD3DXAttributerangearr = ^TD3DXAttributerangearr;
var
i:integer;
tmpattrtable:TD3DXAttributerangearr;
attrszam:dword;
adj:pointer;
pvert:POjjektumvertexarray;
pind:Pwordarray;
begin
 zeromemory(@result,sizeof(result));
 if mesh=nil then exit;
{ attrszam:=0;
 mesh.GetAttributeTable(@tmpattrtable,@attrszam);
 if attrszam=0 then   // }
 begin
  getmem(adj,mesh.getnumfaces*12);
  mesh.GenerateAdjacency(0.0001,adj);
  mesh.OptimizeInplace(D3DXMESHOPT_VERTEXCACHE+D3DXMESHOPT_ATTRSORT+D3DXMESHOPT_COMPACT+D3DXMESHOPT_DEVICEINDEPENDENT,adj,nil,nil,nil);
  mesh.GetAttributeTable(@tmpattrtable,@attrszam);
  if attrszam=0 then exit;
 end;

with result do
begin
 setlength(Attrtable,attrszam);
 for i:=0 to high(attrtable) do
  attrtable[i]:=tmpattrtable[i];

 setlengtH(texturetable,attrszam);
 for i:=0 to high(texturetable) do
  texturetable[i]:=textures[i];

 setlength(vertices,mesh.getnumvertices);
 setlength(indices,mesh.getnumfaces*3);

 if FAILED(Mesh.LockVertexBuffer(0,pointer(pvert))) then exit;
 if FAILED(Mesh.LockIndexBuffer(D3DLOCK_READONLY,pointer(pind))) then exit;
 for i:=0 to high(vertices) do
  vertices[i]:=pvert[i];

 for i:=0 to high(indices) do
  indices[i]:=pind[i];

 mesh.UnlockVertexBuffer;
 mesh.UnlockIndexBuffer;
end;
 StickMeshFeltordel(result);
end;

procedure StickMeshSave(nev:string; mesh:TStickMesh);
var
i:integer;
fil:file;
povarr:Array of Tpackedojjektumvertex;
aln,iln,vln:integer;
tom1,tom2:pointer;
tom1siz,tom2siz:integer;
min,max,scl:TD3DXVector3;
scx:single;
begin
with mesh do begin
 D3DXComputeboundingbox(@(vertices[0]),length(vertices),sizeof(TOjjektumvertex),min,max);
 d3dxvec3subtract(scl,max,min);
 //d3dxvec3scale(scl,scl,0.6);
 scx:=math.max(scl.x,math.max(scl.y,scl.z));
 scl:=D3DXvector3(scx,scx,scx);
 setlength(povarr,length(vertices));
 for i:=0 to high(vertices) do
  povarr[i]:=packojjektumvertex(vertices[i],scl);

 ZCompresS(Indices,length(Indices)*sizeof(word)                 ,tom1,tom1siz);
 ZCompresS(povarr, length(povarr) *sizeof(Tpackedojjektumvertex),tom2,tom2siz);

 aln:=length(attrtable);
 iln:=length(indices);
 vln:=length(vertices);

 assignfile(fil,nev);
 rewrite(fil,1);

 blockwrite(fil,aln,4);
 blockwrite(fil,iln,4);
 blockwrite(fil,vln,4);
 blockwrite(fil,tom1siz,4);
 blockwrite(fil,tom2siz,4);
 blockwrite(fil,scl,3*4);
 blockwrite(fil,texturetable[0],aln*51);
 blockwrite(fil,attrtable[0],aln*sizeof(TD3DXAttributeRange));
 blockwrite(fil,tom1^,tom1siz);
 blockwrite(fil,tom2^,tom2siz);
 closefile(fil);
end end;

function StickMeshLoad(nev:string):TStickMesh;
var
i:integer;
fil:file;
povarr:Array of Tpackedojjektumvertex;
aln,iln,vln:integer;
tom1,tom2,buf:pointer;
tom1siz,tom2siz,bufsiz:integer;
scl:TD3DXVector3;
begin
with result do begin

 assignfile(fil,nev);
 reset(fil,1);

 blockread(fil,aln,4);
 blockread(fil,iln,4);
 blockread(fil,vln,4);
 blockread(fil,tom1siz,4);
 blockread(fil,tom2siz,4);
 blockread(fil,scl,3*4);


 setlength(attrtable,aln);
 setlength(texturetable,aln);
 setlength(indices,iln);
 setlength(vertices,vln);
 setlength(povarr,vln);

 blockread(fil,texturetable[0],aln*51);
 blockread(fil,attrtable[0],aln*sizeof(TD3DXAttributeRange));
 getmem(tom1,tom1siz);
 getmem(tom2,tom2siz);
 blockread(fil,tom1^,tom1siz);
 blockread(fil,tom2^,tom2siz);
 closefile(fil);

 ZDecompress(tom1,tom1siz,buf,bufsiz);

 copymemory(@(indices[0]),buf,bufsiz);

 ZDecompress(tom2,tom2siz,buf,bufsiz);
 copymemory(@(povarr[0]),buf,bufsiz);

 for i:=0 to high(povarr) do
  vertices[i]:=unpackojjektumvertex(povarr[i],scl);
end;

 end;





                             // .x n�lk�l
procedure StickMeshConvertToX(nev:string;a_d3ddevice:IDirect3DDevice9);
type
 PD3DXMaterialArray = ^TD3DXMaterialArray;
 TD3DXMaterialArray = array[0..100] of TD3DXMaterial;
var
 pD3DXMtrlBuffer: ID3DXBuffer;
 d3dxMaterials: PD3DXMaterialArray;
 i:integer;
 subsetszam:integer;
 texs:array of string;
 szam:dword;
 tempmesh,tempmesh2:ID3DXMesh;
 mesh:TStickmesh;
begin
  // Load the mesh from the specified file
  // Load the mesh from the specified file

  if FAILED(D3DXLoadMeshFromX(PChar(nev+'.x'),D3DXMESH_SYSTEMMEM,a_d3ddevice,nil,@pD3DXMtrlBuffer, nil, @szam,tempmesh)) then exit;
  subsetszam:=szam;

  setlengtH(texs,subsetszam);
  d3dxMaterials := pD3DXMtrlBuffer.GetBufferPointer;
  for i:=0 to subsetszam-1 do
   texs[i]:=d3dxMaterials[i].pTextureFilename;

  tempmesh.CloneMeshFVF(D3DXMESH_SYSTEMMEM,D3DFVF_OJJEKTUMVERTEX,a_d3ddevice,tempmesh2);
  tempmesh:=nil;

  mesh:=StickmeshConvertX(tempmesh2,texs);
  tempmesh2:=nil;

  StickMeshSave(nev+'.sm0',mesh);
end;     //}

{procedure StickMeshInsertVertex(var mesh:Tstickmesh;ind:integer;vec:Tojjektumvertex;norm:TNormalTangentBinormal);
var
i:integer;
begin

with mesh do
begin
 setlength(vertices,length(vertices)+1);
 for i:=high(vertices) downto ind+1 do
  vertices[i]:=vertices[i-1];

 for i:=high(normals) downto ind+1 do
  normals[i]:=normals[i-1];

end;
end; }


procedure StickMeshComputeNTB(var mesh:Tstickmesh);
  function GetNormal(v1,v2,v3:Tojjektumvertex):TNormalTangentBinormal;
  var
   el1,el2:TD3DXVector3;
  begin

   d3dxvec3subtract(el1,v2.position,v1.position);
   d3dxvec3subtract(el2,v3.position,v1.position);

   NormalTangentBinormal(el1,el2,v2.tu-v1.tu,v2.tv-v1.tv,v3.tu-v1.tu,v3.tv-v1.tv,
                         result.normal,result.tangent,result.binormal);
  end;
var
i:integer;
ntb:TNormalTangentBinormal;
oszto:array of single;
mul:single;
begin

with mesh do
begin
 setlength(normals,length(vertices));
 setlength(oszto, length(normals));
 zeromemory(@(normals[0]),length(normals)*sizeof(TNormalTangentBinormal));
 zeromemory(@(oszto  [0]),length(oszto  )*sizeof(single));
 for i:=0 to length(indices) div 3 -1 do
 begin
  oszto[indices[i*3+0]]:=oszto[indices[i*3+0]]+1;
  oszto[indices[i*3+1]]:=oszto[indices[i*3+1]]+1;
  oszto[indices[i*3+2]]:=oszto[indices[i*3+2]]+1;


  ntb:=GetNormal(vertices[indices[i*3+0]],vertices[indices[i*3+1]],vertices[indices[i*3+2]]);
  d3dxvec3add(normals[indices[i*3+0]].normal  ,normals[indices[i*3+0]].normal  ,ntb.normal  );
  d3dxvec3add(normals[indices[i*3+0]].tangent ,normals[indices[i*3+0]].tangent ,ntb.tangent );
  d3dxvec3add(normals[indices[i*3+0]].binormal,normals[indices[i*3+0]].binormal,ntb.binormal);

  ntb:=GetNormal(vertices[indices[i*3+1]],vertices[indices[i*3+2]],vertices[indices[i*3+0]]);
  d3dxvec3add(normals[indices[i*3+1]].normal  ,normals[indices[i*3+1]].normal  ,ntb.normal  );
  d3dxvec3add(normals[indices[i*3+1]].tangent ,normals[indices[i*3+1]].tangent ,ntb.tangent );
  d3dxvec3add(normals[indices[i*3+1]].binormal,normals[indices[i*3+1]].binormal,ntb.binormal);

  ntb:=GetNormal(vertices[indices[i*3+2]],vertices[indices[i*3+0]],vertices[indices[i*3+1]]);
  d3dxvec3add(normals[indices[i*3+2]].normal  ,normals[indices[i*3+2]].normal  ,ntb.normal  );
  d3dxvec3add(normals[indices[i*3+2]].tangent ,normals[indices[i*3+2]].tangent ,ntb.tangent );
  d3dxvec3add(normals[indices[i*3+2]].binormal,normals[indices[i*3+2]].binormal,ntb.binormal);

 end;

 for i:=0 to high(oszto) do
  if oszto[i]>0 then
  begin
   mul:=1/oszto[i];
   d3dxvec3scale(normals[i].normal  ,normals[i].normal  ,mul);
   d3dxvec3scale(normals[i].tangent ,normals[i].tangent ,mul);
   d3dxvec3scale(normals[i].binormal,normals[i].binormal,mul);
  end;
end; end;



procedure StickMeshInvertNormals(var mesh:Tstickmesh);
var
tmpmat,invmat:TD3DMatrix;
i:integer;
begin
with mesh do begin

 for i:=0 to high(normals) do
 begin
  tmpmat:=identmatr;
  copymemory(@(tmpmat._11),@(normals[i].tangent) ,sizeof(TD3DXVector3));
  copymemory(@(tmpmat._21),@(normals[i].binormal),sizeof(TD3DXVector3));
  copymemory(@(tmpmat._31),@(normals[i].normal)  ,sizeof(TD3DXVector3));
  d3dxmatrixinverse(invmat,nil,tmpmat);

  copymemory(@(normals[i].tangent) ,@(tmpmat._11),sizeof(TD3DXVector3));
  copymemory(@(normals[i].binormal),@(tmpmat._21),sizeof(TD3DXVector3));
  copymemory(@(normals[i].normal)  ,@(tmpmat._31),sizeof(TD3DXVector3));
 end;

end; end;

procedure specialcopymem(dest,src:pointer;deststride,srcstride:integer;elements:integer);
var
 i,j:integer;
 dest2,src2:Pbyte;
begin
 dest2:=dest;
 src2:=src;
 for i:=0 to elements-1 do
 begin
  for j:=0 to deststride-1 do
   if j<srcstride then
   begin
    dest2^:=src2^;
    inc(dest2);
    inc(src2);
   end
   else
   begin
    dest2^:=0;
    inc(dest2);
   end;
  // Little Endian, azaz $ABCD =>$CD , $AB 
  if deststride<srcstride then
   inc(src2,srcstride-deststride);
 end;
end;

function CommandLineOption(mi:string):boolean;
var
i:integer;
begin
 result:=true;
 for i:=1 to paramcount do
  if paramstr(i)=mi then exit;
 result:=false;
end;

function HardwareID:cardinal;
var
tmp1,tmp2:cardinal;
begin
 windows.Getvolumeinformation(nil,nil,0,@result,tmp1,tmp2,nil,0);
end;
   {
function MD5Encode(mit:dword):string;overload;
var
cnt:MD5Context;
dig:MD5Digest;
begin
 MD5Init(cnt);
 MD5Update(cnt,pointer(@mit),4);
 MD5Final(cnt,dig);
 result:=MD5GetHex(dig);
end;

function MD5Encode(mit:string):string;overload;
var
dig:MD5Digest;
begin
 dig:=MD5String(mit);
 result:=MD5getHex(dig);
end;

function MD5GetHex(dig:MD5Digest):string;
var
i:integer;
begin
 result:='';
 for i:=0 to 15 do
  result:=result+inttohex(dig[i],2);
 result:=lowercase(result);
end;
        }

function SHA1GetHex(dig:TSHA1Digest):string;
var
i:integer;
begin
 result:='';
 for i:=0 to 19 do
  result:=result+inttohex(dig[i],2);
 result:=lowercase(result);
end;

function incimtosockaddr(incim:Tincim):sockaddr_in;
begin
 result.sin_family:=AF_INET;
 result.sin_port:=incim.sin_port;
 result.sin_addr:=incim.sin_addr;
end;

function sockaddrtoincim(sockaddr:sockaddr_in):Tincim;
begin
 result.sin_port:=sockaddr.sin_port;
 result.sin_addr:=sockaddr.sin_addr;
end;

type

 Pghbntrktyp = ^Tghbntrktyp;
 Tghbntrktyp = record
  nam:string[250];
  hova:Pinaddr;
 end;

function gethostbynamewrapthrd(param:Pointer):integer;
var
cucc:Pghbntrktyp;
hste:Phostent;
nam2:string;
begin
 result:=0;
 cucc:=param;
 nam2:=cucc.nam;
 hste:=gethostbyname(Pchar(nam2));
 if hste=nil then begin cucc^.hova^.s_addr:=0; exit; end;
 cucc^.hova^ := Pinaddr(hste.h_addr^ )^;
 dispose(cucc);
end;

procedure gethostbynamewrap(nam:string;hova:PinAddr;canwait:boolean);
var
hste:Phostent;
az:cardinal;
cucc:Pghbntrktyp;
begin
  az:=inet_addr(Pchar(nam));
  if az<>INADDR_NONE then
  begin
   hova^.S_addr:=az;
   exit;
  end;

  if canwait then
  begin
   new(cucc);
   cucc.nam:=nam;
   cucc.hova:=hova;
   beginthread(nil,0,gethostbynamewrapthrd,cucc,0,az);
  end
  else
  begin
   hste:=gethostbyname(Pchar(nam));
   if hste=nil then begin hova^.s_addr:=0; exit; end;
   hova^ := Pinaddr(hste.h_addr^ )^;
  end;
end;

function recvall(sck:cardinal;var buffer;length,timeout:integer):integer;
var
 tbtop:pbyte;
 most:integer;
 a:integer;
begin
 result:=-1;
 tbtop:=@buffer;
 most:=0;
 if length=0 then
 begin
  result:=0;
  exit;
 end;

 timeout:=timeout+gettickcount;
 repeat
  a:=recv(sck,tbtop^,length-most,0);
  inc(tbtop,a);
  inc(most,a);
  sleep(20);
 until (most>=length) or (a<=0) or (timeout<gettickcount);

 if a>=0 then result:=most;
end;
                                                                         //m�sodperc
function connectwithtimeout(sck:cardinal;name:PSockAddr; namelen:integer; timeout:integer):integer;
var
tmp:Dword;
wrtset:TFDset;
timval:TTimeval;
begin
 result:=SOCKET_ERROR;

 tmp:=1;
 ioctlsocket(sck, FIONBIO, tmp);

 if SOCKET_ERROR=connect(sck,name,namelen) then
  if WSAGEtlasterror<>WSAEWOULDBLOCK then exit;

 FD_ZERO(wrtset);
 FD_SET(sck,wrtset);

 timval.tv_sec:=timeout;
 timval.tv_usec:=0;
 if select(0,nil,@wrtset,nil,@timval)<=0 then exit;
 result:=0;
end;

function readm3urecord(nam:string):string;
var
 fil:textfile;
begin
 result:='';
 assignfile(fil,nam);
 reset(fil);
 while not eof(fil) do
 begin
  readln(fil,result);
  if result[1]<>'#' then break;
 end;
 closefile(fil);
end;


function readplsrecord(nam:string):string;
var
 fil:textfile;
begin
 result:='';
 assignfile(fil,nam);
 reset(fil);
 while not eof(fil) do
 begin
  readln(fil,result);
  if lowercase(copy(result,1,4))='file' then
  begin
   result:=copy(result,pos('=',result)+1,1000);
   break
  end;
 end;
 closefile(fil);
end;

function isqr(a:integer):integer;
begin
 result:=a*a;
end;

procedure gridinit(var grid:Tgrid;ameret,abufstep:integer);
begin
 grid.meret:=ameret;
 grid.bufstep:=abufstep;
 GetMem(grid.elemek,ameret*ameret*Sizeof(TGridElem));
 zeromemory(grid.elemek,ameret*ameret*Sizeof(TGridElem));
end;

procedure gridadd(grid:Tgrid;hx,hy:integer;mit:dword);
var
cim:^TgridElem;
dwcim1,dwcim2:pdword;
uj:pointer;
i:integer;
begin
 with grid do
 begin
  cim:=pointer(cardinal(elemek)+(meret*hy+hx)*Sizeof(TgridElem));
  if cim.top>=cim.meret then
  begin
   getmem(uj,(cim.meret+grid.bufstep)*4);
   dwcim1:=cim.elemek;
   dwcim2:=uj;
   for i:=0 to cim.top-1 do
   begin
    dwcim2^:=dwcim1^;
    inc(dwcim1); inc(dwcim2);
   end;

   for i:=cim.top to cim.meret do
   begin
    dwcim2^:=0;
    inc(dwcim2);
   end;
   freemem(cim.elemek,cim.meret*4);
   cim.elemek:=uj;
   cim.meret:=cim.meret+grid.bufstep;
  end;

  dwcim1:=pointer(dword(cim.elemek)+cim.top*4);
  dwcim1^:=mit;
  inc(cim.top);
 end;
end;

procedure gridremoveind(grid:Tgrid;hx,hy:integer;mit:dword);
var
cim:^TgridElem;
dwcim1,dwcim2:pdword;
uj:pointer;
i:integer;
begin
 with grid do
 begin

  cim:=pointer(cardinal(elemek)+(meret*hy+hx)*Sizeof(TgridElem));

  dwcim2:=pointer(dword(cim.elemek)+mit*4);
  dwcim1:=dwcim2;
  inc(dwcim1);
   for i:=mit to cim.top-2 do
   begin
    dwcim2^:=dwcim1^;
    inc(dwcim1); inc(dwcim2);
   end;
  dec(cim.top);


  if cim.top<=cim.meret-grid.bufstep then
  begin
   getmem(uj,(cim.meret-grid.bufstep)*4);
   dwcim1:=cim.elemek;
   dwcim2:=uj;
   for i:=0 to cim.top-1 do
   begin
    dwcim2^:=dwcim1^;
    inc(dwcim1); inc(dwcim2);
   end;
   freemem(cim.elemek,cim.meret*4);
   cim.elemek:=uj;
  end;

 end;
end;


procedure gridremoveval(grid:Tgrid;hx,hy:integer;ertek:dword);
var
cim:^TgridElem;
dwcim1,dwcim2:pdword;
uj:pointer;
i,mit:integer;
begin
 with grid do
 begin

  cim:=pointer(cardinal(elemek)+(meret*hy+hx)*Sizeof(TgridElem));
  dwcim1:= cim.elemek;
  mit:=0;
  for i:=0 to cim.top-1 do
  begin
   if dwcim1^=ertek then
   begin
    mit:=i;
    break;
   end;
   inc(dwcim1);
  end;

  dwcim2:=pointer(dword(cim.elemek)+mit*4);
  dwcim1:=dwcim2;
  inc(dwcim1);
   for i:=mit to cim.top-2 do
   begin
    dwcim2^:=dwcim1^;
    inc(dwcim1); inc(dwcim2);
   end;
  dec(cim.top);


  if cim.top<=cim.meret-grid.bufstep then
  begin
   getmem(uj,(cim.meret-grid.bufstep)*4);
   dwcim1:=cim.elemek;
   dwcim2:=uj;
   for i:=0 to cim.top-1 do
   begin
    dwcim2^:=dwcim1^;
    inc(dwcim1); inc(dwcim2);
   end;
   freemem(cim.elemek,cim.meret*4);
   cim.elemek:=uj;
  end;

 end;
end;


procedure gridgetitems(grid:Tgrid; hx,hy:integer; var itms:Tgriditems);
var
 cim:^Tgridelem;
begin
 setlength(itms,0);
 with grid do
 begin
  cim:=pointer(cardinal(elemek)+(meret*hy+hx)*Sizeof(TgridElem));
  setlength(itms,cim.top);
  copymemory(@(itms[0]),cim.elemek,cim.top*4);
 end;
end;


function ojjrect(aind1,aind2,apx,apy,amx,amy:integer):Tojjrect;
begin
 with result do
 begin
  ind1:=aind1;
  ind2:=aind2;
  px:=apx;
  py:=apy;
  mx:=amx;
  my:=amy;
 end;
end;


procedure rectadd(var rect:Tojjrectarr; aind1,aind2,amx,amy:integer);
var
i,j2,k:integer;
jo:boolean;
jorect,wantrect:Tojjrect;
tmptav,mintav:integer;
begin

 zeromemory(@jorect,sizeof(jorect));
 zeromemory(@wantrect,sizeof(wantrect));
 if length(rect)>0 then
  jorect.px:=1337;


 mintav:=100000;
 for j2:=-1 to length(rect)*4-1 do
 begin

  if j2<0 then
  begin
   wantrect.px:=0;
   wantrect.py:=0;
  end
  else
  begin
   i:=j2 shr 2;
   wantrect.px:=rect[i].px;
   wantrect.py:=rect[i].py;
   case j2 and 3 of
    0:wantrect.px:=rect[i].px+rect[i].mx+1;
    1:wantrect.py:=rect[i].py+rect[i].my+1;
    2:wantrect.px:=0;
    3:wantrect.py:=0;
   end;
  end;
  
  tmptav:=max(wantrect.px+amx,wantrect.py+amy);
  // ha el�g kicsi, ellen�rz�s
  if tmptav<mintav then
  begin
   jo:=true;
   for k:=high(rect) downto 0 do
    if tegtegben(wantrect.px,wantrect.py,amx,amy,
                 rect[k].px,rect[k].py,rect[k].mx,rect[k].my) then
    begin
     jo:=false;
     break;
    end;

   if jo then
   begin
    mintav:=tmptav;
    jorect:=wantrect;
   end;
  end;
   //ellen�rz�s v�ge
 end;

 if jorect.px=1337 then
  messagebox(0,'FAILZ!','Fail.',0);
 jorect.ind1:=aind1;
 jorect.ind2:=aind2;
 jorect.mx:=amx;
 jorect.my:=amy;
 setlength(rect,length(rect)+1);
 rect[high(rect)]:=jorect;
end;

procedure rectremove(var rect:Tojjrectarr;aind1,aind2:integer);
var
i,hol:integer;
begin
 hol:=-1;
 for i:=0 to high(rect) do
  if (rect[i].ind1=aind1) and (rect[i].ind2=aind2) then
  begin
   hol:=i; break;
  end;
 if hol>=0 then
 begin
  rect[hol]:=rect[high(rect)];
  setlength(rect,high(rect));
 end;
end;

function rectget(var rect:Tojjrectarr; aind1,aind2:integer):Tojjrect;
var
 i:integer;
begin
 for i:=0 to high(rect) do
  if (rect[i].ind1=aind1) and (rect[i].ind2=aind2) then
  begin
   result:=rect[i]; exit;
  end;
 zeromemory(@result,sizeof(result));
end;

procedure rectmegbasztat(var rect:Tojjrectarr; aind1,aind2,aind2uj:integer);
var
 i:integer;
begin
 for i:=0 to high(rect) do
  if (rect[i].ind1=aind1) and (rect[i].ind2=aind2) then
  begin
   rect[i].ind2:=aind2uj;
   exit;
  end;
end;

procedure rectresize(var rect:Tojjrectarr; aind1,aind2,amx,amy:integer);
var
i:integer;
hol:integer;
begin
 hol:=-1;
 for i:=0 to high(rect) do
  if (rect[i].ind1=aind1) and (rect[i].ind2=aind2) then
  begin
   hol:=i; break;
  end;
 if hol>=0 then
 begin
  rect[hol]:=rect[high(rect)];
  setlength(rect,high(rect));
 end;
 rectadd(rect,aind1,aind2,amx,amy);
end;


function qsort_partition(var mit:Tindexedintarr; left, right, pivotIndex:integer):integer;
var
tmp:Tindexedint;
pivotval,center:integer;
i:integer;
begin
 pivotval := mit[pivotIndex].ertek;
 tmp:=mit[pivotIndex];
 mit[pivotIndex]:=mit[right];  // Move pivot to end
 mit[right]:=tmp;
 center := left;
 for i:= left to right-1 do
  if mit[i].ertek < pivotval then
  begin
   tmp:=mit[center];
   mit[center]:=mit[i];
   mit[i]:=tmp;
   inc(center);
  end;
 tmp:=mit[center];
 mit[center]:=mit[right];  // Move pivot to center
 mit[right]:=tmp;
 result:=center;
end;

procedure qsort_reducetokth(var mit:Tindexedintarr; k:integer);
var
 left,right:integer;
 pivotind:integer;
begin
 left:=0;
 right:=high(mit);
 if (k<left) or (k>right) then exit;
 repeat
  pivotind:=left+random(right-left);
  pivotind := qsort_partition(mit, left, right, pivotind);
  if k = pivotind then
   break
  else
   if k < pivotind then
    right := pivotind-1
   else
    left := pivotind+1
 until false;
 setlength(mit,k);
end;

procedure loadlang(honnan:string;id:integer);
var
fil:textfile;
str:string;
langstr:string;
olvasd:boolean;
hova:integer;
begin
 langstr:='['+inttostr(id)+']';
 assignfile(fil,honnan);
 reset(fil);
 setlength(lang,1001);
 olvasd:=false;
 while not eof(fil) do
 begin
  readln(fil,str);

  if (str='[default]') or (str=langstr) then
  begin
   olvasd:=true;
   continue;
  end;

  if(length(str)>0) and (str[1]='[') then
   olvasd:=false;

  if not olvasd or (pos('=',str)=0) then
   continue;
  hova:=strtoint(copy(str,1,pos('=',str)-1));
  if (hova<0) or (hova>1000) then
   continue;
  lang[hova]:=copy(str,pos('=',str)+1,1000);
 end;

 closefile(fil);
end;

end.