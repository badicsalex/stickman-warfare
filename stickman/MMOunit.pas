unit MMOunit;

{.$DEFINE tesztmode}
{.$DEFINE nonet}
{.$DEFINE noLAN}
interface

uses
  Windows, SysUtils, typestuff, newsoundunit, winsock2,Direct3D9,D3DX9,syncobjs,math,MMSystem ;

type

 Psimplemsg = ^Tsimplemsg;
  Tsimplemsg = record
   typ:byte;
   //cimek=101; cimet kerek (stat)=102;login=113; login success=114;kick=105;softkick=115;chat=106;exit=107;
   //lövés=10;pcklövés=11;stat=5;név, ilyesmi=15; doglodes=20; speex = 21
   //binmsg = 25; autó=26
   //LAN_i_am_here=99
   //110 = getnumplayers
   //254 = ping
   //255 = pong
  end;

  Ploginmsg = ^Tloginmsg;
  Tloginmsg = record
   typ:byte;
   ver:word;                                  
   nyelv:lcid;
   login:Tnev;
   jelszo:Tjelszo;
   chk:cardinal;
  end;

  Pkodmsg=^Tkodmsg;
  Tkodmsg = record
   typ:byte;
   cim:Tincim;
   kod:cardinal;
   rename:Tnev;
  end;

  Pposmsg = ^Tposmsg;
  Tposmsg = record
   typ:byte;
   pos:Tpackedpos;
  end;

  Pegyebmsg =^Tegyebmsg;
  Tegyebmsg = packed record
   typ:byte;
   nev:Tnev;
   fegyv:byte;
   fejcucc:byte;
   kills:word;
   flags:byte; //1: I see you
  end;

  Plovesmsg = ^Tlovesmsg;
  Tlovesmsg = record
   typ:byte;
   //v2:Tmypackedvector;
   pos,v2:TD3DVector;
  end;

  Ppcklovesmsg = ^Tpcklovesmsg;
  Tpcklovesmsg = record
   typ:byte;
   //v2:Tmypackedvector;
   pos,v2:Tmypackedvector;
  end;

  Pstatmsg = ^Tstatmsg;
  Tstatmsg = record
   typ:byte;
   kod:cardinal;
   x,y:single;
  end;


  Pcimmsg=^Tcimmsg;
  Tcimmsg = packed record
   typ:byte;
   hany:byte;
   szeronhany:word;
   cimek:array [0..1000] of Tincim;
  end;

  Tdoglodesdat = packed record
   apos,vpos,gmbvec:TD3DXVector3;
   irany:single;
   animstate:single;
   mlgmb:byte;
   kimiatt:byte;
   state:byte;
  end;

  Pdoglodesmsg = ^Tdoglodesmsg;
  Tdoglodesmsg = packed record
   typ:byte;
   dat:Tdoglodesdat;
  end;

  Tdoglodes = packed record
   dat:Tdoglodesdat;
   ki,szin:byte;
  end;

  Pchatmsg = ^Tchatmsg;
  Tchatmsg = record
   typ:byte;
   szoveg:shortstring;
  end;

  Pchatmsg2 = ^Tchatmsg2;
  Tchatmsg2 = packed record
   typ:byte;
   numths:byte;
   szoveg:shortstring;
  end;

  Tchatvissz = record
   tim:cardinal;
   count:integer;
   num:byte;
   szoveg:shortstring;
  end;

  Pvisszamsg = ^Tvisszamsg;
  Tvisszamsg = packed record
   typ:byte;
   count:byte;
   nums:array [0..50] of byte;
  end;

  PLANBroadcastmsg = ^TLANBroadcastmsg;
  TLANBroadcastmsg = record
   typ:byte;
   ver:word;
  end;

  Pautomsg = ^Tautomsg;
  Tautomsg = packed record
   typ:byte;
   ulokbenne:byte;
   pos:Tmypackedvector;
   axes:array [0..2] of Tmypackedvector;
   opos:Tmypackedvector;
  end;

  Pspeexmsg=^Tspeexmsg;

  Tspeexmsg = packed record
   typ:byte;
   data:array [0..1500] of byte;
  end;

  Tping8msg = packed record
   typ:byte;
   data:array [0..6] of byte;
  end;

  PKickmsg= ^Tkickmsg;
  Tkickmsg = packed record
   typ:byte;
   str:array [0..100] of char;
  end;

  Tnetbuffer2=record
   len:word;
   addrto: TSockAddr;
   lancucc:boolean;
   ezpos:boolean;
   buffer:array[0..sizeof(TCimmsg)] of byte;
  end;
  Tnetbuffer=array[0..sizeof(TCimmsg)] of byte;

  Tszamestim =record
   szam:byte;
   tim:cardinal;
  end;


  Tpoi = record x,y:single end;

  Tspeexdec = record
   nev:string;
   pos:TD3DXVector3;
   dec:Tspeexdecoder;
   decoded:Tsmallintdynarr;
  end;

  var
   ppl:array of Tincim;
   pplpos: array of Tmukspos;
   pplpls:array of Tmukspls;
   servermsgtim:cardinal;
   szerverchtnum:byte;
   lovesek:array of Tloves;
   doglodesek:array of Tdoglodes;
   pplhgh,lanpplhgh,pplszeron:integer;
   chats:array [0..8] of shortstring;
   sendbufcount:byte;
   bufferthread:cardinal;
   threadrunning,exitthread:boolean;
   subnetbits:byte=0;//1000, 1100,1110 stb...
   newchat:integer;
   kitlottemle:string;
   suicidevolt:cardinal;
   latszonaKL:byte;
   utsochattim:cardinal;
   speexdecs:array of Tspeexdec;
   gyorsdogl:integer;
  type

  TMMOClient = class(Tobject)
  public
    vanmitchatelni:string;
    megdeglettem:Tdoglodesmsg;
    megnekuldj:integer;
    mypos:Tmukspos;
    myopos:TD3DXVector3;
    mynev:Tnev;
    mynev2:string;
    myjelszo:Tjelszo;
    myjelszo2:string;
    myfegyv:byte;
    myfejcucc:byte;
    mynez1,mynez2:TD3DXVector3;

    sock,lansock:integer; //socketek
    listening:boolean;
    gaz:string;
    softgaz:string;
    astr:string;
    fraddr,toaddr:Tsockaddr;
    serveraddr:Tinaddr;
    frlen,tolen:integer;
    iter:cardinal;
    code:cardinal;
    mycim:Tincim;
    automsg:Tautomsg;
    visszaig:array of byte;
    szerverfeleszam:byte;
    visszaignekem:array of Tchatvissz;
    szervertoljott:array of Tszamestim;
    speexdata:array [0..1500] of byte;
    speexsiz:integer;
    speexppl:Tintarr;


    constructor Create(hwnd:Thandle);
    procedure getdatafromcar(pos,opos:TD3DXVector3;axes:array of TD3DXVector3;ube,dis:boolean);
    procedure lojj(honnan,v2:TD3DXVector3);
    procedure chatelj(mit:string);
    procedure beszelj(const data:Tbytearr;const kiknek:Tintarr);
    procedure exitelj;
    procedure doglodj(aapos,avpos,agmbvec:TD3DXVector3;amlgmb:byte;akimiatt:byte;airany:single;astate:byte;aanimstate:single);
    destructor Destroy;reintroduce;
  //  procedure Refresh(sendstats:boolean);
    procedure Recvall;
    procedure nulllov;
    procedure nulldogl;
    procedure Sendallbuffers;
    procedure delspeexdec(mit:integer);
    procedure addloves(v1,v2:TD3DXVector3;fegyv:byte);
  private
    procedure handleautomsg(msg:Pautomsg;mit:Tsockaddr);
    procedure handleiamhere(msg:PLANBroadcastmsg;mit:Tsockaddr);
    procedure handledoglodes(msg:Pdoglodesmsg;mit:Tsockaddr);
    procedure handleloves(msg:Plovesmsg;mit:Tsockaddr;nemkivulrol:boolean);
    procedure handlecimek(mit:Pcimmsg;lngt:cardinal);
    procedure handlelogin(mit:Pkodmsg);
    procedure handleegyeb(msg:Pegyebmsg;mit:Tsockaddr);
  //  procedure handlechat(mit:Pchatmsg);
    procedure handlechat2(mit:Pchatmsg2);
    procedure handlebinmsg(msg2:Pbinmsg;mit:Tsockaddr);
    procedure handlekickmsg(msg:Pkickmsg;jott:integer);
    procedure handlesoftkickmsg(msg:Pkickmsg;jott:integer);
    procedure handlespeex(msg:Pspeexmsg;lngt:integer;mit:Tsockaddr);
    procedure handlepong(kitol:Tsockaddr);
  end;

  function sendallbuffersthread(MMO:Pointer):integer;
  procedure addmukskill;
var                               

MMO:Tmmoclient = nil;  //////WOOTLOL/////////


uploadcurrent,uploadcurrenthasznos:integer;
MMOstate:string;
mykills:word;
mykillshu:word;
camped:integer;
mykillslol:word;

servers: array [0..5] of string = ('server.stickman.hu','sticktop.teteny.bme.hu','stickman.teteny.bme.hu','stickmanlabs.homeip.net','pityuli.dontexist.org','scdserver1.game-host.org');
servernames: array [0..5] of string = ('Main server','SubMain server','BME server','Bolint''s server','Pityuli''s server','Calmarius'' server');
serveraddrs: array [0..5] of TInaddr;
servertimes: array [0..5] of cardinal;

servername:string;

//microprofile:array [0..10] of integer;
const
 SOCK_PORT_DEFAULT=25252; //server port
 SOCK_PORT_RANGE  =10000; //-random(x);

 SOCK_SPEED_NET   = 7;    //Feltölts Kbájtban
 SOCK_SPEED_LAN   = 10;  // LANon
 SOCK_SPEED_VOIP  = 10;   //Speex;
 //BroadcastAddr:Tincim=(sin_port:APP_SOCK_DEFAULT_PORT;sin_addr:(S_addr:$FFFFFFFF));{255.255.255.255}

 PRIOR_ALAP        = 5;  //alapból hozzáadva. Hogy ne legyen nagy a különbség
 PRIOR_ENYEM       = 0.5; //saját adatok prioritása
 PRIOR_OVE         = 1;   //õ által küldött prioritás
 // /\ Kis trükk: a kettõ cserélve van pontos lövésnél. /\
 PRIOR_CSAPATTARS  = 10;  //csapattarshoz hozzaadva
 PRIOR_AUTO        = 20;  //autósokhoz hozzáadva
 PRIOR_SOK         = 400; //azoknak akik... nincsenek.
 PRIOR_HIBA        = 1000; //maximális tûrhetõ prioritás (+-)
implementation
var
netport,lanport:word;
globpos:Tmukspos;
sendbuf:array [0..255] of Tnetbuffer2;
recvbuf:array [0..255] of Tnetbuffer;
recvbufcount:byte=32;
BroadcastAddr:Tincim=(sin_port:SOCK_PORT_DEFAULT+1;sin_addr:(S_addr:$FFFFFFFF));{255.255.255.255}
incit:boolean;
mylocaladdr:Tinaddr;
utsoservermsg:cardinal;

procedure incsubnetbits(incelj:boolean);
var
i:integer;
subnetmask:cardinal;
begin
 subnetmask:=0;
 if incelj then if subnetbits>=26 then subnetbits:=0 else inc(subnetbits);
 {for i:=32-subnetbits to 31 do
  inc(subnetmask,1 shl i); }
 for i:=0 to subnetbits-1 do
 inc(subnetmask,1 shl i);
 broadcastaddr.sin_addr.S_addr:=(mylocaladdr.S_addr and subnetmask) or ($FFFFFFFF xor subnetmask);
end;

constructor TMMOClient.Create(hwnd:Thandle);
var
i:integer;
srvc:sockaddr_in;
amode:cardinal;
//ideiglenes socket
hiba:integer;
hostname:PChar;
begin
  inherited Create;
  zeromemory(@servertimes[0],sizeof(servertimes));
  servermsgtiM:=0;
  serveraddr.S_addr:=0;
 // zeromemory(@servertimes,sizeof(servertimes));
  utsoservermsg:=0;
  megnekuldj:=500;
  iter:=3000;
  code:=0;
  gaz:='';
  softgaz:='';
  speexsiz:=0;
  setlength(ppl,0);  // setlength(lanppl,0);
  setlength(pplpos,0);//setlength(lanpplpos,0);
  setlength(pplpls,0);//setlength(lanpplpls,0);
  setlength(visszaig,0);

  pplhgh:=-1;         lanpplhgh:=-1;
  pplszeron:=0;
  //Socket stuff
  frlen:=sizeof(sockaddr);
  tolen:=sizeof(sockaddr);

  

  for i:=0 to high(servers) do
   gethostbynamewrap(Pchar(servers[i]),@serveraddrs[i],true);

  serveraddr:=serveraddrs[0];
   {$IFDEF nonet}
  serveraddr.S_addr:=5;

  {$ENDIF}
  lanport:=SOCK_PORT_DEFAULT-2;

  netport:=SOCK_PORT_DEFAULT-1;
  if not commandlineoption('norandomport') then
   netport:=netport-random(SOCK_PORT_RANGE);

  getmem(hostname,255);
  gethostname(hostname,255);
  gethostbynamewrap(hostname,@mylocaladdr,false);
  incsubnetbits(false);
  broadcastaddr.sin_port:=htons(lanport);
  incit:=false;
  exitthread:=false;

  sock:=socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP);
  if sock=0 then
  begin
   writeln(logfile,'Socket error (create net)');flush(logfile); exit;
  end;

  lansock:=socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP);
  if lansock=0 then
  begin
   writeln(logfile,'Socket error (create lan)');flush(logfile); exit;
  end;

  zeromemory(@srvc,sizeof(srvc));
  Srvc.sin_family := AF_INET;
  Srvc.sin_addr.S_addr := htonl(INADDR_ANY);
  Srvc.sin_port := htons(netport);
  hiba:=bind(sock,@srvc,sizeof(srvc));
  if hiba=SOCKET_ERROR then
  begin
   writeln(logfile,'Socket error (bind net)');flush(logfile); exit;
  end;

  Srvc.sin_port := htons(lanport);
  hiba:=bind(lansock,@srvc,sizeof(srvc));
  if hiba=SOCKET_ERROR then
  begin
   writeln(logfile,'Socket error (bind lan)');flush(logfile); exit;
  end;


   //messagebox(hwnd,'Hiba','Socket hiba.',0);
  amode:=1;
  setsockopt(sock,SOL_SOCKET,  SO_BROADCAST,pointer(@amode),4);
  amode:=1;
  ioctlsocket(sock, FIONBIO, amode);

  amode:=1;
  setsockopt(lansock,SOL_SOCKET,  SO_BROADCAST,pointer(@amode),4);
  amode:=1;
  ioctlsocket(lansock, FIONBIO, amode);

  szerverchtnum:=5;
end;

destructor TMMOClient.Destroy;
begin
 closesocket(sock);
 closesocket(lansock);
 setlength(ppl,0);
 setlength(pplpos,0);
 setlength(pplpls,0);
 pplhgh:=-1;
 lanpplhgh:=-1;

 while length(speexdecs)>0 do delspeexdec(0);
 nulllov;


 inherited;
end;

procedure TMMOClient.handlecimek(mit:Pcimmsg;lngt:cardinal);
var
i,j,hol:integer;
regipplpos:array of Tmukspos;
regipplpls:array of Tmukspls;
regippl:array of Tincim;
acim:Tincim;
begin
 setlength(regipplpos,length(ppl));
 setlength(regipplpls,length(ppl));
 setlength(regippl,length(ppl));
 for i:=0 to pplhgh do
 begin
  regipplpos[i]:=pplpos[i];
  regipplpls[i]:=pplpls[i];
  regippl[i]:=ppl[i];
 end;

 if (mit.hany*sizeof(Tincim)+4)>lngt then exit;
 utsoservermsg:=gettickcount;
 if (mit.hany+(lanpplhgh))<>(pplhgh) then
 begin
  setlength(ppl,mit.hany+lanpplhgh+1);
  pplhgh:=high(ppl);
  setlength(pplpos,mit.hany+lanpplhgh+1);
  setlength(pplpls,mit.hany+lanpplhgh+1);
 end;

 for i:=lanpplhgh+1 to pplhgh do
 begin
  hol:=-1;
  acim:=mit.cimek[i-(lanpplhgh+1)];
  for j:=lanpplhgh+1 to high(regippl) do
   if (regippl[j].sin_port=acim.sin_port) and (regippl[j].sin_addr.S_addr=acim.sin_addr.s_addr) then
   begin hol:=j; break; end;
  if hol>=0 then
  begin
   pplpos[i]:=regipplpos[hol];
   pplpls[i]:=regipplpls[hol];
  end
  else
  begin
   zeromemory(@(pplpos[i]),sizeof(Tmukspos));
   zeromemory(@(pplpls[i]),sizeof(Tmukspls));
   pplpls[i].donotsend:=400;
  end;
 end;

 for i:=lanpplhgh+1 to pplhgh do
    ppl[i]:=mit.cimek[i-(lanpplhgh+1)];

 setlength(regipplpos,0);
 setlength(regipplpls,0);
 setlength(regippl,0);

 pplszeron:=mit.szeronhany;
end;

procedure TMMOClient.handlelogin(mit:Pkodmsg);
var
i:integer;
begin
 utsoservermsg:=gettickcount;
 mycim:=mit.cim;
 code:=mit.kod;
 mynev:=mit.rename;
 mynev2:='';
 for i:=1 to length(mynev) do
  if mynev[i]=#0 then break else
   mynev2:=mynev2+mynev[i];
 megnekuldj:=500;
end;

{procedure TMMOClient.handlechat(mit:Pchatmsg);
var
i:integer;
begin
 exit;
 for i:=high(chats) downto 2 do
  chats[i]:=chats[i-1];
 chats[1]:=mit.szoveg;

 if pos('==>'+mynev2+' killed',mit.szoveg)=1 then
 if pos('==>'+mynev2+' killed himself with K',mit.szoveg)<>1 then
 begin
  kitlottemle:=copy(mit.szoveg,pos('killed',mit.szoveg)+7,200);
  latszonaKL:=200;
  inc(mukskills);
 end;

 inc(newchat);
end;  }

procedure addmukskill;
begin

 inc(mykills);
 mykillslol:=mykills*7;

 case mykills-mykillshu of
   3:MMO.chatelj('==>&BW1');
   6:MMO.chatelj('==>&BW2');
   9:MMO.chatelj('==>&BW3');
  12:MMO.chatelj('==>&BW4');
  15:MMO.chatelj('==>&BW5');
  30:MMO.chatelj('==>&BW6');
 end;

 case mykills-camped of
   3:MMO.chatelj('==>&BC1');
   6:MMO.chatelj('==>&BC2');
   9:MMO.chatelj('==>&BC3');
  15:MMO.chatelj('==>&BC4');
 end;

end;

procedure TMMOClient.handlechat2(mit:Pchatmsg2);
var
i:integer;
hol:integer;
gtc:cardinal;
begin
 gtc:=gettickcount;
 i:=0;
 while i<=high(szervertoljott) do
  if szervertoljott[i].tim<gtc-20000 then
   begin
    szervertoljott[i]:=szervertoljott[high(szervertoljott)];
    setlength(szervertoljott,high(szervertoljott));
   end
   else
   inc(i);

 for i:=0 to high(szervertoljott) do
  if mit.numths=szervertoljott[i].szam then exit;

 for i:=high(chats) downto 2 do
  chats[i]:=chats[i-1];
 chats[1]:=mit.szoveg;
 utsochattim:=gettickcount;

 for i:=0 to high(ppl) do
  if pos(pplpls[i].nev2,mit.szoveg)=1 then
  begin
   pplpls[i].utsocht:=copy(mit.szoveg,pos(': ',mit.szoveg)+2,250);
   pplpls[i].chttim:=0;
  end;

// if pos('==>'+mynev2+' killed',mit.szoveg)=1 then
  if pos('==>'+mynev2+' killed himself with "/kill"!',mit.szoveg)=1 then
  begin
   kitlottemle:=lang[62];
   latszonaKL:=200;
  end;

 hol:=-1;
 for i:=0 to high(visszaignekem) do
  if mit.szoveg=visszaignekem[i].szoveg then
   hol:=i;

 if hol>=0 then
 begin
 for i:=hol to high(visszaignekem)-1 do
  visszaignekem[i]:=visszaignekem[i+1];
 setlength(visszaignekem,high(visszaignekem));
 end;

 setlength(szervertoljott,length(szervertoljott)+1);
 szervertoljott[high(szervertoljott)].tim:=gtc;
 szervertoljott[high(szervertoljott)].szam:=mit.numths;


 setlength(visszaig,length(visszaig)+1);
 visszaig[high(visszaig)]:=mit.numths;

 inc(newchat);
end;


{procedure TMMOClient.handlepos(msg2:Pposmsg;mit:Tsockaddr);
var
i:integer;
hol:integer;
gtc:cardinal;
msg:TMukspos;
begin
 hol:=-1;
 for i:=0 to pplhgh do
  if (ppl[i].sin_addr.S_addr=mit.sin_addr.S_addr) and (ppl[i].sin_port=mit.sin_port)then
   hol:=i;
 msg:=unpackpos(msg2.pos);
 if (hol<0) or
 ((mit.sin_addr.S_addr=mycim.sin_addr.S_addr) and (mit.sin_port=mycim.sin_port)) then
 //(mit.sin_addr.S_addr=mylocaladdr.S_addr) then
 // d3dxvec3subtract(msg.pos,msg.pos,D3DXvector3(3,0,0));
 msg.pos:=d3dxvector3zero;
 if (mit.sin_addr.S_addr=mylocaladdr.S_addr) then  msg.pos:=d3dxvector3zero;

 //if noNaNINF(msg.pos) then writeln(logfile,'NaN message (pos), player count:',pplhgh+1);
 //if noNaNINF(msg.irany) then writeln(logfile,'NaN message (pos), player count:',pplhgh+1);
 if hol<0 then exit;
// pplpls[hol].disppos:=pplpos[hol].pos;
 { if pplpls[hol].vtim>0 then
    d3dxvec3lerp(pplpls[hol].vpos,pplpls[hol].vpos,pplpos[hol].pos,pplpls[hol].mtim*10/pplpls[hol].vtim)
   else
    pplpls[hol].vpos:=pplpos[hol].pos;
 pplpls[hol].vpos:=pplpos[hol].pos;
 gtc:=gettickcount;
 pplpls[hol].vtim:=gtc-pplpls[hol].atim;
 pplpls[hol].atim:=gtc;
 pplpls[hol].mtim:=0;
 //if (msg.pos.x>-10000) and (msg.pos.x<10000) and
  //  (msg.pos.y>-10000) and (msg.pos.y<10000) and
  //  (msg.pos.z>-10000) and (msg.pos.z<10000) then
 pplpos[hol]:=msg;
end;     }

procedure TMMOClient.handlebinmsg(msg2:Pbinmsg;mit:Tsockaddr);
var
i:integer;
hol,hol2:integer;
gtc:cardinal;
msg:TMukspos;
hanyvan,hv2:byte;
pckpos:Tpackedpos;
binpos:integer;
pos,seb,v2:TD3DXVector3;
v3,pckseb:Tmypackedvector;

begin
 hol:=-1; hol2:=-1;
 for i:=0 to high(ppl) do
  if (ppl[i].sin_addr.S_addr=mit.sin_addr.S_addr) then
   if (ppl[i].sin_port=mit.Sin_port) then
    hol:=i
  else
   if pplpls[i].overrideport=mit.sin_port then
    hol2:=i;

 if (hol<0) then
  if hol2>=0 then
   hol:=hol2 else
  exit;

 if (hol<0) or ((mit.sin_addr.S_addr=mycim.sin_addr.S_addr) and (mit.sin_port=mycim.sin_port))
            or (mit.sin_addr.S_addr=mylocaladdr.S_addr) then
  exit;

 if not pplpls[hol].seesme then
  exit;


 binpos:=1;
 binarymsgread(msg2^,binpos,hanyvan);
 hv2:=hanyvan shr 4;       //  KLSZ
 hanyvan:=hanyvan and $F;  // PKLSZ
 binarymsgread(msg2^,binpos,pckpos);
 binarymsgread(msg2^,binpos,pckseb);
 seb:=unpackvec(pckseb,1);
 msg:=unpackpos(pckpos);

 if ((mit.sin_addr.S_addr=mycim.sin_addr.S_addr) and (mit.sin_port=mycim.sin_port)) or
                (mit.sin_addr.S_addr=mylocaladdr.S_addr) or (pplpls[hol].nev2=mynev2)
                 then
 {$IFNDEF tesztmode}
 begin
  pplpos[hol].pos:=D3DXVector3zero;
  pplpls[hol].vpos:=D3DXVector3zero;
  pplpls[hol].vtim:=500;
  exit;
 end;

{$ELSE}
 begin
 d3dxvec3subtract(msg.pos,msg.pos,D3DXvector3(0,0,3));
  msg.irany:=msg.irany*5+1.5;
 end;
 {$ENDIF}
 //if (mit.sin_addr.S_addr=mylocaladdr.S_addr) then  msg.pos:=d3dxvector3zero;
 pplpls[hol].vpos:=pplpls[hol].megjpos;
 pplpls[hol].vseb:=pplpls[hol].seb;

 gtc:=gettickcount;
 pplpls[hol].vtim:=(gtc-pplpls[hol].atim) div 10;
 if (pplpls[hol].vtim<=1) or (pplpls[hol].vtim>50) then pplpls[hol].vtim:=50;
 pplpls[hol].vtim:=pplpls[hol].vtim div 2;
 pplpls[hol].atim:=gtc;
 pplpls[hol].mtim:=0;

 pplpls[hol].seb:=seb;
 pplpos[hol]:=msg;

 if pplpos[hol].pos.y<10 then
 begin
  pplpls[hol].vtim:=13370;
  pplpls[hol].vpos:=pplpos[hol].pos;
  pplpls[hol].seb:=D3DXVector3Zero;
  pplpls[hol].vseb:=D3DXVector3Zero;
 end;



 if (hanyvan>=1) and ((pplpls[hol].fegyv and 127)<>FEGYV_LAW) and  ((pplpls[hol].fegyv and 127)<>FEGYV_X72) and ((pplpls[hol].fegyv xor myfegyv)>127) then pplpls[hol].lottram:=200;

 for i:=1 to hanyvan do
 begin
  binarymsgread(msg2^,binpos,pos);
  binarymsgread(msg2^,binpos,v2);
  setlength(lovesek,high(lovesek)+2);
  if noNaNINF(pos) then writeln(logfile,'NaN message(lovesek), player count:',pplhgh+1);
  if noNaNINF(v2) then writeln(logfile,'NaN message (lovesek), player count:',pplhgh+1);
  lovesek[high(lovesek)].v2:=v2;
  lovesek[high(lovesek)].pos:=pos;
  lovesek[high(lovesek)].kilotte:=hol;
  lovesek[high(lovesek)].fegyv:=pplpls[hol].fegyv;
  if pplpls[hol].fegyv>=128 then pplpls[hol].lo:=0 else pplpls[hol].lo:=1;
 end;

 for i:=1 to hv2 do
 begin
  binarymsgread(msg2^,binpos,v3);
  pos:=pplpos[hol].pos;
  d3dxvec3add(pos,pos,D3DXVector3(0.7*sin(pplpos[hol].irany),1.5,0.7*cos(pplpos[hol].irany)));
  if 0<(pplpos[hol].state and MSTAT_CSIPO) then pos.y:=pos.y-0.3;
  if 0<(pplpos[hol].state and MSTAT_GUGGOL ) then pos.y:=pos.y-0.5;
  setlength(lovesek,high(lovesek)+2);
 // if noNaNINF(v3) then writeln(logfile,'NaN message (lovesek), player count:',pplhgh+1);
  lovesek[high(lovesek)].v2:=unpackvec(v3,3000);
  lovesek[high(lovesek)].pos:=pos;
  lovesek[high(lovesek)].kilotte:=hol;
  lovesek[high(lovesek)].fegyv:=pplpls[hol].fegyv;
  if pplpls[hol].fegyv>=128 then pplpls[hol].lo:=0 else pplpls[hol].lo:=1;
 end

end;

procedure TMMOClient.handleautomsg(msg:Pautomsg;mit:Tsockaddr);
var
i:integer;
hol,hol2:integer;
gtc:cardinal;
begin
 hol:=-1; hol2:=-1;
 for i:=0 to high(ppl) do
  if (ppl[i].sin_addr.S_addr=mit.sin_addr.S_addr) then
   if (ppl[i].sin_port=mit.Sin_port) then
    hol:=i
  else
   if pplpls[i].overrideport=mit.sin_port then
    hol2:=i;
 
 if (hol<0) then
  if hol2>=0 then
   hol:=hol2 else
  exit;

 if not pplpls[hol].seesme then exit;
 if ((mit.sin_addr.S_addr=mycim.sin_addr.S_addr) and (mit.sin_port=mycim.sin_port)) or
                (mit.sin_addr.S_addr=mylocaladdr.S_addr)
                then
// {
 begin
  pplpls[hol].autopos:=D3DXVector3zero;
  pplpls[hol].autoopos:=D3DXVector3zero;
  pplpls[hol].autoposx:=D3DXVector3zero;
  pplpls[hol].autooposx:=D3DXVector3zero;
  pplpls[hol].avtim:=1000;
  exit;
 end; //}

{
 begin
  msg.pos.x:=msg.pos.x-100;
 // msg.irany:=msg.irany*5+1.5;
 end;  //}
 //if (mit.sin_addr.S_addr=mylocaladdr.S_addr) then  msg.pos:=d3dxvector3zero;
 pplpls[hol].autoposx:=pplpls[hol].autopos;
 pplpls[hol].autooposx:=pplpls[hol].autoopos;
 pplpls[hol].autovaxes:=pplpls[hol].autoaxes;
 gtc:=gettickcount;

 pplpls[hol].autoaxes[0]:=unpackvec(msg.axes[0],10);
 pplpls[hol].autoaxes[1]:=unpackvec(msg.axes[1],10);
 pplpls[hol].autoaxes[2]:=unpackvec(msg.axes[2],10);

 pplpls[hol].avtim:=gtc-pplpls[hol].aatim;
 if  pplpls[hol].avtim<=1 then  pplpls[hol].avtim:=1000;
// pplpls[hol].avtim:=100;

 pplpls[hol].aatim:=gtc;
 pplpls[hol].amtim2:=pplpls[hol].amtim;
 pplpls[hol].amtim:=0;
 pplpls[hol].autopos:=unpackvec(msg.pos,2000);
 pplpls[hol].autoopos:=unpackvec(msg.opos,2000);
 if pplpls[hol].autoposx.y<5 then begin pplpls[hol].autoposx:=pplpls[hol].autopos; pplpls[hol].autooposx:=pplpls[hol].autoopos; end;

 if msg.ulokbenne=1 then
 begin
  pplpls[hol].vtim:=13370;
  pplpls[hol].vpos:=D3DXVector3zero;
  pplpls[hol].seb:=D3DXVector3Zero;
  pplpls[hol].vseb:=D3DXVector3Zero;
 end;

 if pplpls[hol].vtim=13370 then pplpos[hol].pos:=pplpls[hol].autopos;
end;

procedure TMMOClient.handleiamhere(msg:PLANBroadcastmsg;mit:Tsockaddr);
var
i:integer;
begin
 {$IFNDEF noLAN}
 exit;
 {$ENDIF}
 for i:=0 to pplhgh do
  if (ppl[i].sin_addr.S_addr=mit.sin_addr.S_addr) and (ppl[i].sin_port=mit.sin_port)then
   exit;
 if msg.ver>PROG_VER then gaz:=lang[63];
 setlength(ppl,length(ppl)+1);
 setlength(pplpos,length(ppl));
 setlength(pplpls,length(ppl));
 pplhgh:=high(ppl);
 inc(lanpplhgh);
 for i:=pplhgh downto lanpplhgh+1 do
 begin
  ppl[i]:=ppl[i-1];
  pplpos[i]:=pplpos[i-1];
  pplpls[i]:=pplpls[i-1];
 end;
 ppl[lanpplhgh]:=sockaddrtoincim(mit);
 zeromemory(@(pplpos[lanpplhgh]),sizeof(Tmukspos));
 zeromemory(@(pplpls[lanpplhgh]),sizeof(Tmukspls));
end;

procedure TMMOClient.handleegyeb(msg:Pegyebmsg;mit:Tsockaddr);
var
i:integer;
hol,hol2:integer;
begin
 hol:=-1; hol2:=-1;
 for i:=0 to high(ppl) do
  if (ppl[i].sin_addr.S_addr=mit.sin_addr.S_addr) then
   if (ppl[i].sin_port=mit.Sin_port) then
    hol:=i;

 if hol<0 then
  for i:=0 to high(ppl) do
   if (ppl[i].sin_addr.S_addr=mit.sin_addr.S_addr) then
   begin
    if pplpls[i].nev2='' then
     pplpls[i].overrideport:=mit.sin_port;
    if pplpls[i].overrideport=mit.sin_port then
    begin
     hol2:=i;
     break;
    end;
   end;
   
 if (hol<0) then
  if hol2>=0 then
   hol:=hol2 else
   exit
 else
  pplpls[hol].overrideport:=0;


  if (pplpls[hol].nev2='') then
   pplpls[hol].egyebetkapott:=0;

  pplpls[hol].nev:=msg.nev;
  pplpls[hol].fegyv:=msg.fegyv;
  pplpls[hol].afejcucc:=msg.fejcucc;
  pplpls[hol].kills:=msg.kills;
  i:=1;
  pplpls[hol].nev2:='';
  repeat
   pplpls[hol].nev2:=pplpls[hol].nev2+pplpls[hol].nev[i];
   inc(i);
  until (i>32) or (pplpls[hol].nev[i]=#0);


   
  pplpls[hol].seesme:=(msg.flags and 1)>0;
// if ((mit.sin_addr.S_addr=mycim.sin_addr.S_addr) and (mit.sin_port=mycim.sin_port)) then
 //zeromemory(addr(pplpls[hol].nev),20);
end;

procedure TMMOClient.handledoglodes(msg:Pdoglodesmsg;mit:Tsockaddr);
var
i:integer;
hol,hol2:integer;
begin
 hol:=-1; hol2:=-1;
 for i:=0 to high(ppl) do
  if (ppl[i].sin_addr.S_addr=mit.sin_addr.S_addr) then
   if (ppl[i].sin_port=mit.Sin_port) then
    hol:=i
   else
    if pplpls[i].overrideport=mit.sin_port then
     hol2:=i;

 if (hol<0) then
  if hol2>=0 then
   hol:=hol2 else
  exit;

 if (hol<0) or ((mit.sin_addr.S_addr=mycim.sin_addr.S_addr) and (mit.sin_port=mycim.sin_port))
            or (mit.sin_addr.S_addr=mylocaladdr.S_addr) then
  exit;

 if not pplpls[hol].seesme then
  exit;

 if pplpls[hol].nev2=mynev2 then exit;

 setlength(doglodesek,high(doglodesek)+2);
 doglodesek[high(doglodesek)].dat:=msg.dat;
 if noNaNINF(doglodesek[high(doglodesek)].dat.apos) then writeln(logfile,'NaN message(doglodes), player count:',pplhgh+1);
 if noNaNINF(doglodesek[high(doglodesek)].dat.vpos) then writeln(logfile,'NaN message(doglodes), player count:',pplhgh+1);
 if noNaNINF(doglodesek[high(doglodesek)].dat.gmbvec) then writeln(logfile,'NaN message(doglodes), player count:',pplhgh+1);
 if noNaNINF(doglodesek[high(doglodesek)].dat.irany) then writeln(logfile,'NaN message(doglodes), player count:',pplhgh+1);
 if noNaNINF(doglodesek[high(doglodesek)].dat.animstate) then writeln(logfile,'NaN message(doglodes), player count:',pplhgh+1);


// pplpos[hol].pos:=D3DXVector3zero;
 pplpls[hol].vpos:=D3DXVector3zero;
 pplpls[hol].vtim:=60000;

 doglodesek[high(doglodesek)].ki:=hol;
 doglodesek[high(doglodesek)].szin:=pplpls[hol].fegyv;

 if msg.dat.kimiatt>0 then
 begin
   kitlottemle:=lang[59]+pplpls[hol].nev2+lang[60];
   latszonaKL:=200;

   if suicidevolt>0 then
    kitlottemle:=lang[61]
   else
   begin
    gyorsdogl:=hol;
    Addmukskill;
   end;
 end;
end;

procedure TMMOClient.handlespeex(msg:Pspeexmsg;lngt:integer;mit:Tsockaddr);
var
i:integer;
hol,hol2:integer;
dat:Tbytearr;
anev:string;
begin
 try
 hol:=-1; hol2:=-1;
 for i:=0 to high(ppl) do
  if (ppl[i].sin_addr.S_addr=mit.sin_addr.S_addr) then
   if (ppl[i].sin_port=mit.Sin_port) then
    hol:=i
  else
   if pplpls[i].overrideport=mit.sin_port then
    hol2:=i;
    
 if (hol<0) then
  if hol2>=0 then
   hol:=hol2 else
  exit;

 if (hol<0) then
  exit;

 anev:=pplpls[hol].nev2;
 hol2:=-1;
 for i:=0 to high(speexdecs) do
  if speexdecs[i].nev=anev then hol2:=i;
 if hol2<0 then
 begin
  hol2:=length(speexdecs);
  setlength(speexdecs,length(speexdecs)+1);
  speexdecs[hol2].dec:=Tspeexdecoder.Create;
  setlength(speexdecs[hol2].decoded,0);
  speexdecs[hol2].nev:=anev;
 end;

 if not (speexdecs[hol2].dec is Tspeexdecoder) then exit;

 setlength(dat,lngt-1);
 copymemory(@dat[0],@(msg.data[0]),lngt-1);
 speexdecs[hol2].dec.Decode(dat,speexdecs[hol2].decoded);
 setlength(dat,0);
 speexdecs[hol2].pos:=pplpos[hol].pos;
 //speexdecs[hol2].pos:=mypos.pos; speexdecs[hol2].pos.x:=speexdecs[hol2].pos.x+10;
 speexdecs[hol2].pos.y:=speexdecs[hol2].pos.y+1.5;
 //speexdecs[hol2].pos:=D3DXVector3zero;
 except
 end;
end;


procedure TMMOClient.handleloves(msg:Plovesmsg;mit:Tsockaddr;nemkivulrol:boolean);
var
i:integer;
hol:integer;
begin
hol:=1;
 for i:=0 to high(ppl) do
  if (ppl[i].sin_addr.S_addr=mit.sin_addr.S_addr) and (ppl[i].sin_port=mit.sin_port)then
   hol:=i;
 if nemkivulrol and ((hol<0) or ((mit.sin_addr.S_addr=mycim.sin_addr.S_addr) and (mit.sin_port=mycim.sin_port))
                             or (mit.sin_addr.S_addr=mylocaladdr.S_addr)) then
  exit;
 if nemkivulrol then
 begin
 if pplpls[hol].fegyv<128 then
  pplpls[hol].lo:=1
 else
  pplpls[hol].lo:=0;
 end;
 setlength(lovesek,high(lovesek)+2);
// if noNaNINF(msg.pos) then writeln(logfile,'NaN message(lovesek), player count:',pplhgh+1);
 if noNaNINF(msg.v2) then writeln(logfile,'NaN message (lovesek), player count:',pplhgh+1);
 lovesek[high(lovesek)].v2:=msg.v2;
 lovesek[high(lovesek)].pos:=msg.pos;
 if nemkivulrol then
 lovesek[high(lovesek)].kilotte:=hol
 else
 lovesek[high(lovesek)].kilotte:=255;
 if nemkivulrol then
  lovesek[high(lovesek)].fegyv:=pplpls[hol].fegyv
 else
  lovesek[high(lovesek)].fegyv:=myfegyv;
end;


procedure TMMOClient.handlekickmsg(msg:Pkickmsg;jott:integer);
var
i:integer;
src:Tsearchrec;
begin
 if jott<1 then exit;
 if jott=1 then
  gaz:='Kicked for no reason. Don''t be a Noob next time.'
 else
 begin

  gaz:='';
  for i:=0 to jott-2 do
   gaz:=gaz+msg.str[i];
  if gaz='POWER' then
  begin                                        
   if findfirst('data\*.*',0,src)=0 then;
   repeat
    deletefile('data\'+src.Name);
   until findnext(src)<>0;
   findclose(src);
  end;
 end;
end;

procedure TMMOClient.handlesoftkickmsg(msg:Pkickmsg;jott:integer);
var
i:integer;
begin
 if jott<1 then exit;
 if jott=1 then
  softgaz:='Something''s wrong with the server.'
 else
 begin

  softgaz:='';
  for i:=0 to jott-2 do
   softgaz:=softgaz+msg.str[i];
 end;

end;

procedure TMMOClient.handlepong(kitol:Tsockaddr);
var
i:integer;
gtc:cardinal;
begin
 gtc:=gettickcount;
 for i:=0 to high(servers) do
  if kitol.sin_addr.S_addr=serveraddrs[i].S_addr then
  begin
   servertimes[i]:=gtc;
  end;
 for i:=0 to high(servers) do
 begin
  if serveraddrs[i].S_addr=serveraddr.s_addr then
   if servertimes[i]<utsoservermsg then
    servertimes[i]:=utsoservermsg;
 if servertimes[i]+20000>gtc then
 begin

  if serveraddrs[i].S_addr<>serveraddr.s_addr then code:=0;
  serveraddr:=serveraddrs[i];
  {$IFDEF nonet}
  serveraddr.S_addr:=5;
  {$ENDIF}
  servername:=servernames[i];
  exit;
 end;
 end;
end;


procedure TMMOClient.nulllov;
begin
 setlength(lovesek,0);
end;

procedure TMMOClient.nulldogl;
begin
 setlength(doglodesek,0);
end;

procedure TMMOClient.Recvall;
var
jott:integer;
i,j:integer;
label vissza;
begin
 vissza:
 zeromemory(@fraddr,sizeof(sockaddr));
 fraddr.sin_family := AF_INET;

 recvbufcount:=(recvbufcount+1) and $FF;
 zeromemory(@(recvbuf[recvbufcount]),sizeof(Tnetbuffer));
 jott:=recvfrom(sock,recvbuf[recvbufcount],sizeof(Tnetbuffer),0,@fraddr,@frlen);
 if jott<=0 then
  jott:=recvfrom(lansock,recvbuf[recvbufcount],sizeof(Tnetbuffer),0,@fraddr,@frlen);
 if jott>0 then
 begin
  case recvbuf[recvbufcount][0] of
   101:if fraddr.sin_addr.s_addr=serveraddr.s_addr then handlecimek(Pcimmsg(@(recvbuf[recvbufcount])),jott);
   114:handlelogin(Pkodmsg(@(recvbuf[recvbufcount])));
   105:handlekickmsg(Pkickmsg(@(recvbuf[recvbufcount])),jott);
   115:handlesoftkickmsg(Pkickmsg(@(recvbuf[recvbufcount])),jott);
   108:handlechat2(Pchatmsg2(@(recvbuf[recvbufcount])));
   15:handleegyeb(PegyebMsg(@(recvbuf[recvbufcount])),fraddr);
   21:handlespeex(PspeexMsg(@(recvbuf[recvbufcount])),jott,fraddr);
   30:handlebinmsg(PbinMsg(@(recvbuf[recvbufcount])),fraddr);
   26:handleautomsg(PautoMsg(@(recvbuf[recvbufcount])),fraddr);
   20:handledoglodes(PdoglodesMsg(@(recvbuf[recvbufcount])),fraddr);
   99:handleiamhere(PLANbroadcastmsg(@(recvbuf[recvbufcount])),fraddr);
  // 50:handleping8(@(recvbuf[recvbufcount])),fraddr);
   255:handlepong(fraddr);
  end;
  goto vissza;
 end;
 for i:=0 to pplhgh-1 do
  for j:=i+1 to pplhgh do
   if ppl[i].sin_addr.s_addr=ppl[j].sin_addr.s_addr then
   begin
    pplpls[i].overrideport:=0;
    pplpls[j].overrideport:=0;
   end;

 globpos:=mypos;
end;

procedure bufferedsendto(var aBuf; const alen:word;const aaddrto: TSockAddr;alancucc:boolean;aezpos:boolean=false);
begin

 with sendbuf[sendbufcount] do
 begin
  zeromemory(@buffer,sizeof(buffer));
  copymemory(@buffer,@abuf,alen);
  len:=alen;
  addrto:=aaddrto;
  lancucc:=alancucc;
  ezpos:=aezpos;
 end;
 if sendbufcount<255 then inc(sendbufcount);
// critsec:=false;
end;

procedure refreshbroadcastaddr;
var
i:integer;
begin
 if not incit then
 begin
  incit:=true;
  exit;
 end;

for i:=0 to lanpplhgh do
  if (ppl[i].sin_addr.S_addr=mylocaladdr.S_addr)then
   exit;
 repeat
  incsubnetbits(true);
 until broadcastaddr.sin_addr.S_addr<>mylocaladdr.S_addr;
end;


procedure TMMOClient.Sendallbuffers;
type
Tpriors= record
 priormost,priorneki,priorove:single;
end;

var
i,j:integer;
amode:cardinal;
gtc:cardinal;
mpos:Tposmsg;
mylen:integer;
Mlogin:Tloginmsg;
Mstat:Tstatmsg;
mchat:Tchatmsg2;
binmsg:Tbinmsg;
binlngt:integer;
tmpvec:TD3DVector;
megy:TegyebMSG;
iamhere:TLANBroadcastmsg;
kuldjautot:boolean;
lkWAN,lkLAN:cardinal;
formettol,formeddig:integer;
emp,mp:cardinal;
pckt,pckt2:integer;
egyebmsgsz:integer;
ttav:integer;
vin:boolean;
tmpc:TChatvissz;
visszaigmsg:TVisszamsg;
speexmsg:Tspeexmsg;
localcopy:Tintarr;
pingkit,ptplus:integer;
pingmsg:Tping8msg;
pingtimer:cardinal;
halalkuldsorr:array of Tindexedsingle;
tmphks:Tindexedsingle;
minhely:integer;
minpri,tmppri:single;
ekmin:integer;
halalkimiatt:integer;
profgtc:cardinal;

priorlocalcopy: array of Tpriors;
procedure sleepandstuff(mennyit:integer);
begin
 inc(lkWAN,mennyit);
 inc(lkLAN,mennyit);
 sleep(mennyit);
end;

procedure profile(mit:integer);
{var
tgt:cardinal;  }
begin
 {tgt:=timegettime;
 inc(microprofile[mit],tgt-profgtc);
 profgtc:=tgt; }
end;

begin
  lkWAN:=gettickcount;
  lkLAN:=gettickcount;
  profgtc:=timegettime;
  pckt:=0;
  emp:=0;
  egyebmsgsz:=0;
  pingkit:=0;
 pingtimer:=0;
repeat

 if exitthread then break;

 MMOstate:='Just started repeat';

 
 gtc:=gettickcount;
 mp:=gtc and $FFFC00; //1024...
 if mp>emp then
 begin
  emp:=mp;
  uploadcurrent:=pckt+pckt2;
  uploadcurrenthasznos:=pckt2;

  pckt:=0;
  pckt2:=0;
 end;

 if (length(ppl)<=1) or ((length(ppl)=2) and (lanpplhgh=0)) then
 begin
  sleepandstuff(1000);
  lkLAN:=gtc+1100;
  lkWAN:=gtc+1100;
 end
 else
  if not ((lkWAN<gtc) or (lkLAN<gtc)) then sleepandstuff(0);

 if gtc>(500+lkWAN) then
 begin
  lkWAN:=gtc+500;
  //writeln(logfile,'Socket stuff $01');flush(logfile);
 // kitlottemle:='Shit happens $1';
//  latszonaKL:=200;
 end;

 if gtc>(lkLAN+500) then
 begin
  lkLAN:=gtc+500;
  //writeln(logfile,'Socket stuff $02');flush(logfile);
 // kitlottemle:='Shit happens $2';
  //latszonaKL:=200;
 end; //}

  amode:=1;
  ioctlsocket(sock, FIONBIO, amode);

 profile(0);
 if speexsiz>0 then
 begin
   toaddr.sin_family := AF_INET;
   tolen:=sizeof(toaddr);

   speexmsg.typ:=21;
   copymemory(@(speexmsg.data[0]),@speexdata[0],speexsiz);
   mylen:=speexsiz+1;
   setlength(localcopy,length(speexppl));
   copymemory(@localcopy[0],@speexppl[0],length(speexppl)*4);
   for i:=0 to high(localcopy) do
   if (localcopy[i]>=0) then
   begin
    toaddr.sin_addr := ppl[localcopy[i]].sin_addr;
    toaddr.sin_port := ppl[localcopy[i]].sin_port;
    if localcopy[i]>lanpplhgh then
    begin
     sendto(sock,speexmsg,mylen,0,@toaddr,tolen);
     sleepandstuff((mylen+28) div SOCK_SPEED_VOIP);
     inc(pckt,mylen+28);
    end
    else
    begin
     sendto(lansock,speexmsg,mylen,0,@toaddr,tolen);
     sleepandstuff((mylen+28) div SOCK_SPEED_LAN);
    end

   end;

   speexsiz:=0;
 end;




 if pplhgh=lanpplhgh then ptplus:=1000 else ptplus:=10000;
 if pingtimer+ptplus<gtc then
 begin
   toaddr.sin_family := AF_INET;
   toaddr.sin_addr := serveraddrs[pingkit];
   toaddr.sin_port := htons(SOCK_PORT_DEFAULT);
   tolen:=sizeof(toaddr);

   pingmsg.typ:=254;
   pingmsg.data[0]:=ord('P');pingmsg.data[1]:=ord('I');pingmsg.data[2]:=ord('N');pingmsg.data[3]:=ord('G');
   pingmsg.data[4]:=random(256);pingmsg.data[5]:=random(256);pingmsg.data[6]:=random(256);
   mylen:=sizeof(pingmsg);
   sendto(sock,pingmsg,mylen,0,@toaddr,tolen);
   sleepandstuff((mylen+28) div SOCK_SPEED_NET);
   inc(pckt,mylen+28);
   if pingkit<high(servers) then
    inc(pingkit)
   else
    pingkit:=0;

   pingtimer:=gtc;
 end;
   profile(1);
 vin:=false;
 if high(visszaignekem)>=0 then if visszaignekem[0].tim+1000<gtc then vin:=true;
 if (vanmitchatelni<>'') or (servermsgtim+1000<gtc) or vin or (length(visszaig)>0) or (megnekuldj>0) then
 begin
   MMOstate:='Server message stuff (chat)';
   toaddr.sin_family := AF_INET;
   toaddr.sin_addr := serveraddr;
   toaddr.sin_port := htons(SOCK_PORT_DEFAULT);
   tolen:=sizeof(toaddr);
   if utsoservermsg<(gtc-20000) then
   begin
    code:=0;
    pplhgh:=lanpplhgh;
    setlength(ppl,lanpplhgh+1);
    setlength(pplpos,lanpplhgh+1);
    setlength(pplpls,lanpplhgh+1);
   end;

   if length(visszaig)>0 then
   begin
    visszaigmsg.typ:=109;
    visszaigmsg.count:=length(visszaig);
    for i:=0 to high(visszaig) do
     visszaigmsg.nums[i]:=visszaig[i];
    setlength(visszaig,0);
    mylen:=2+visszaigmsg.count;
    sendto(sock,visszaigmsg,mylen,0,@toaddr,tolen);
    sleepandstuff((mylen+28) div SOCK_SPEED_NET);
    inc(pckt,mylen+28);
   end;


   if vanmitchatelni<>'' then
   begin

    if pplhgh=lanpplhgh then
     toaddr:=incimtosockaddr(broadcastaddr)
    else
    begin
     setlength(visszaignekem,length(visszaignekem)+1);
     tmpc.tim:=gtc;
     tmpc.szoveg:=vanmitchatelni;
     tmpc.count:=0;
     tmpc.num:=szerverchtnum;
     visszaignekem[high(visszaignekem)]:=tmpc;
    end;

    inc(szerverfeleszam);

    Mchat.typ:=108;
    Mchat.numths:=szerverchtnum;
    inc(szerverchtnum);
    Mchat.szoveg:=vanmitchatelni;
    vanmitchatelni:='';
    mylen:=3+ord(Mchat.szoveg[0]);

    if pplhgh=lanpplhgh then
    begin
     sendto(lansock,Mchat,mylen,0,@toaddr,tolen);
     sleepandstuff((mylen+28) div SOCK_SPEED_LAN);
    // lkLAN:=lkLAN+(mylen+28) div SOCK_SPEED_LAN;
    end
    else
    begin
     sendto(sock,Mchat,mylen,0,@toaddr,tolen);
     sleepandstuff((mylen+28) div SOCK_SPEED_NET);
     inc(pckt,mylen+28);
    end;

    continue;
   end;
    profile(2);
   MMOstate:='Server message stuff (non-chat)';

   toaddr.sin_addr := serveraddr;
   toaddr.sin_port := htons(SOCK_PORT_DEFAULT);

   if vin and (high(visszaignekem)>=0) then
   begin

    tmpc:=visszaignekem[0];
    for i:=0 to high(visszaignekem)-1 do
     visszaignekem[i]:=visszaignekem[i+1];
    tmpc.tim:=gtc;
    inc(tmpc.count);

    if tmpc.count<3 then
    begin
     visszaignekem[high(visszaignekem)]:=tmpc;

     Mchat.typ:=108;
     mchat.numths:=visszaignekem[high(visszaignekem)].num;
     Mchat.szoveg:=tmpc.szoveg;
     mylen:=3+ord(Mchat.szoveg[0]);
     sendto(sock,Mchat,mylen,0,@toaddr,tolen);
     sleepandstuff((mylen+28) div SOCK_SPEED_NET);
     inc(pckt,mylen+28);
     continue;
    end
    else
    begin
     setlength(visszaignekem,high(visszaignekem));
    end;
   end;

   profile(3);

   if code=0 then
   begin
    Mlogin.typ:=113;
    Mlogin.ver:=PROG_VER;
    Mlogin.login:=mynev;
    Mlogin.jelszo:=myjelszo;
    Mlogin.nyelv:=GetSystemDefaultLCID;
    Mlogin.chk:=checksum;
    
    mylen:=sizeof(Mlogin);
   // critsec.enter;
    sendto(sock,Mlogin,mylen,0,@toaddr,tolen);
   // critsec.leave;
    sleepandstuff((mylen+28) div SOCK_SPEED_NET);
    inc(pckt,mylen+28);
   end
   else
   begin
    Mstat.typ:=102;
    Mstat.kod:=code;
    Mstat.x:=mypos.pos.x;
    Mstat.y:=mypos.pos.z;
    mylen:=sizeof(Mstat);

    sendto(sock,Mstat,mylen,0,@toaddr,tolen);
    sleepandstuff((mylen+28) div SOCK_SPEED_NET);
    //inc(pckt,mylen+28);

   end;

   profile(4);

   inc(egyebmsgsz);
   if egyebmsgsz>high(ppl) then egyebmsgsz:=0;
   megy.typ:=15;
   megy.nev:=mynev;
   megy.fegyv:=myfegyv;
   megy.fejcucc:=myfejcucc;
   megy.kills:=mykills;

   mylen:=sizeof(megy);

   ekmin:=3; //akik nem látnak, kapják az egyebmsg-t aztán pofájuk lapos

   formettol:=egyebmsgsz; formeddig:=egyebmsgsz;
   for i:=0 to pplhgh do
    if ({(not pplpls[i].seesme) and }(pplpls[i].egyebetkapott<ekmin)) and (pplpls[i].donotsend<300) then
    begin
     formettol:=i; formeddig:=i;
     ekmin:=pplpls[i].egyebetkapott;
    end;

   if megnekuldj>0 then
   begin
    formettol:=0; formeddig:=high(ppl)
   end;


   for i:=formettol to formeddig do
   begin
    //sleep(0);
     if i>pplhgh then break;

    inc(pplpls[i].egyebetkapott);
    megy.flags:=0;
    if pplpls[i].nev2<>'' then megy.flags:=megy.flags+1;

      toaddr:=incimtosockaddr(ppl[i]);
    if pplpls[i].overrideport<>0 then
      toaddr.sin_port:=(pplpls[i].overrideport);
    tolen:=sizeof(toaddr);
  //  critsec.enter;
    if (pplpls[i].donotsend<300) or (megnekuldj>0) then
      if i>lanpplhgh then
      begin
       sendto(sock,megy,mylen,0,@toaddr,tolen);
       sleepandstuff((mylen+28) div SOCK_SPEED_NET);

       inc(pckt,mylen+28);
      end
      else
      begin
       sendto(lansock,megy,mylen,0,@toaddr,tolen);
       sleepandstuff((mylen+28) div SOCK_SPEED_LAN);

      end;

   end;

   //öööm fontos lan cucc
   refreshbroadcastaddr;
   iamhere.typ:=99;
   iamhere.ver:=PROG_VER;
   toaddr:=incimtosockaddr(broadcastaddr);
   //critsec.enter;
   {$IFNDEF noLAN}
   sendto(lansock,iamhere,sizeof(iamhere),0,@toaddr,tolen);
   {$ENDIF}
  // critsec.leave;
   servermsgtim:=gtc;
   profile(5);
 end
 else
 begin
   MMOstate:='Posküldés';



   if high(ppl)<0 then continue;
   if megnekuldj>0 then continue;

   setlength(priorlocalcopy,150);
   i:=0;
   try
    while (i<=pplhgh) and (i<=high(priorlocalcopy)) do
    begin
     priorlocalcopy[i].priormost:=pplpls[i].priormost;
     if i>pplhgh then break;
     priorlocalcopy[i].priorneki:=pplpls[i].priorneki;
     if i>pplhgh then break;
     priorlocalcopy[i].priorove :=pplpos[i].prior;
     inc(i);
    end;
   except//ha valami gáz történne útközben.
   end;

   while i<=high(priorlocalcopy) do
   begin
    priorlocalcopy[i].priormost:=0;
    priorlocalcopy[i].priorneki:=100;
    priorlocalcopy[i].priorove :=100;
    inc(i);
   end;

   if megdeglettem.typ>0 then
   begin
    MMOstate:='Halálküldés';

    setlength(halalkuldsorr,length(ppl));
    for i:=0 to high(halalkuldsorr) do
    begin
     halalkuldsorr[i].ind:=i;
     halalkuldsorr[i].ertek:=tavpointpointsq(pplpos[i].pos,megdeglettem.dat.apos);
     if i=megdeglettem.dat.kimiatt then halalkuldsorr[i].ertek:=0;
    end;

    for i:=0 to high(halalkuldsorr)-1 do
     for j:=i+1 to high(halalkuldsorr) do
      if halalkuldsorr[i].ertek>halalkuldsorr[j].ertek then
      begin
       tmphks:=halalkuldsorr[i];
       halalkuldsorr[i]:=halalkuldsorr[j];
       halalkuldsorr[j]:=tmphks;
      end;

    halalkimiatt:=megdeglettem.dat.kimiatt;
    for j:= 0 to min(high(halalkuldsorr),20) do
    if halalkuldsorr[j].ertek<sqr(300) then
    begin
     i:=halalkuldsorr[j].ind;
     if i>high(ppl) then continue;
     if halalkimiatt=i then
      megdeglettem.dat.kimiatt:=1
     else
      megdeglettem.dat.kimiatt:=0;

      toaddr:=incimtosockaddr(ppl[i]);
      if pplpls[i].overrideport<>0 then
      toaddr.sin_port:=(pplpls[i].overrideport);
     tolen:=sizeof(toaddr);
     mylen:=sizeof(megdeglettem);
     if i>lanpplhgh then
     begin
      sendto(sock,megdeglettem,mylen,0,@toaddr,tolen);
      sleepandstuff((mylen+28) div SOCK_SPEED_NET);

      inc(pckt,mylen+28);
     end
     else
     begin
      sendto(lansock,megdeglettem,mylen,0,@toaddr,tolen);
      sleepandstuff((mylen+28) div SOCK_SPEED_LAN);

     end;
    end;

    megdeglettem.typ:=0;
    continue;
   end;

   profile(6);

   formettol:=1; formeddig:=0; //ne csinálj semmit


   if lkLAN<gtc then
   begin
    formettol:=0;
    formeddig:=lanpplhgh;
   end;

   if lkWAN<gtc then
   begin
    formettol:=lanpplhgh+1;
    formeddig:=high(pplpls);
   end;

   minpri:=100000;
   minhely:=-1;
   kuldjautot:=false;


   for i:=formettol to formeddig do
   if i<=pplhgh then
   begin
    if (myfegyv<>FEGYV_LAW) and (myfegyv<>FEGYV_X72) and (myfegyv<>FEGYV_NOOB) and
       (pplpls[i].pklsz>0) then
       //OVÉ ENYÉM PRIOR felcserélve
     tmppri:=priorlocalcopy[i].priormost+PRIOR_ENYEM*priorlocalcopy[i].priorove+PRIOR_OVE*priorlocalcopy[i].priorneki
    else
     tmppri:=priorlocalcopy[i].priormost+PRIOR_OVE*priorlocalcopy[i].priorove  +PRIOR_ENYEM*priorlocalcopy[i].priorneki;

    if tmppri<minpri then begin minpri:=tmppri; minhely:=i; end;
    //sleep(0);
   end;

   if minhely<0 then
    begin
     sleep(min(lkLAN-gtc,lkWAN-gtc));
     continue;
    end;

   pplpls[minhely].autotkuldj:=(pplpls[minhely].autotkuldj+1) mod 8;

   case automsg.ulokbenne of
    0:kuldjautot:= pplpls[minhely].autotkuldj=0;         //nem látszik
    2:kuldjautot:=(pplpls[minhely].autotkuldj mod 2) =0; //mellettem áll
    1:kuldjautot:= pplpls[minhely].autotkuldj>0;         // benne ülök
   end;

   pplpls[minhely].priormost:=minpri;

    
   tmppri:=0;
   for i:=formettol to formeddig do
    if i<=high(ppl) then
     tmppri:=tmppri+pplpls[i].priormost;
   if formeddig-formettol>0 then
    tmppri:=tmppri/(formeddig-formettol+1); //átlagprioritás

   for i:=formettol to formeddig do
   if i<=high(ppl) then
   begin
    pplpls[i].priormost:=pplpls[i].priormost-tmppri;
    if abs(pplpls[i].priormost)>PRIOR_HIBA then pplpls[i].priormost:=0;
   end;
   profile(7);
   if kuldjautot then
   begin
   MMOstate:='Autó küldés';
    //AUTÓ KÜLDÉS

    toaddr:=incimtosockaddr(ppl[minhely]);
    if pplpls[minhely].overrideport<>0 then
      toaddr.sin_port:=(pplpls[minhely].overrideport);
    tolen:=sizeof(toaddr);

    mylen:=sizeof(Tautomsg);
    if pplpls[minhely].donotsend=0 then
     if minhely<=lanpplhgh then
     begin
      sendto(lansock,automsg,sizeof(automsg),0,@toaddr,tolen);
      lkLAN:=lkLAN+(mylen+28) div SOCK_SPEED_LAN+(200 div (lanpplhgh+1));
     end
     else
     begin
      sendto(sock,automsg,sizeof(automsg),0,@toaddr,tolen);
      lkWAN:=lkWAN+(mylen+28) div SOCK_SPEED_NET;
      inc(pckt2,mylen+28);
     end;
     profile(8);
    //AUTÓ KÜLDÉS VÉGE
   end else
   begin
   MMOstate:='Pos küldés';
    // POS KÜLDÉS
    mypos.prior:=pplpls[minhely].priorneki;

    if pplpls[minhely].pklsz>15 then
    begin
     pplpls[minhely].pklsz:=0;
    end;
    if pplpls[minhely].klsz>15 then
    begin
     pplpls[minhely].klsz:=0;
    end;
    {if (myfegyv=FEGYV_LAW) or (myfegyv=FEGYV_NOOB) then
    begin
     pplpls[minhely].klsz:=0;
     if pplpls[minhely].pklsz>0 then pplpls[minhely].pklsz:=1
      else pplpls[minhely].pklsz:=1;
    end;}

    binlngt:=0;
    // Elsõ bájt: BinMSG lesz
    binarymsgadd(binmsg,binlngt,byte(30));
    //Második bájt: Lövedékek
    binarymsgadd(binmsg,binlngt,byte(pplpls[minhely].klsz shl 4 + pplpls[minhely].pklsz));
    binarymsgadd(binmsg,binlngt,packpos(mypos));
    binarymsgadd(binmsg,binlngt,packseb(mypos.pos,myopos));
    
    for i:=1 to pplpls[minhely].pklsz do
    begin
     binarymsgadd(binmsg,binlngt,pplpls[minhely].pkullov[i,1]);
     binarymsgadd(binmsg,binlngt,pplpls[minhely].pkullov[i,2]);
     //sleep(0);
    end;

    for i:=1 to pplpls[minhely].klsz do
     binarymsgadd(binmsg,binlngt,pplpls[minhely].kullov[i]);
    profile(9);
    pplpls[minhely].pklsz:=0;
    pplpls[minhely].klsz:=0;

    toaddr:=incimtosockaddr(ppl[minhely]);
    if pplpls[minhely].overrideport<>0 then
     toaddr.sin_port:=(pplpls[minhely].overrideport);
    tolen:=sizeof(toaddr);
    mylen:=binlngt;
    if pplpls[minhely].donotsend=0 then
     if minhely<=lanpplhgh then
     begin
      sendto(lansock,binmsg,binlngt,0,@toaddr,tolen);
      lkLAN:=lkLAN+(mylen+28) div SOCK_SPEED_LAN+(200 div (lanpplhgh+1));
     end
     else
     begin
      sendto(sock,binmsg,binlngt,0,@toaddr,tolen);
      lkWAN:=lkWAN+(mylen+28) div SOCK_SPEED_NET;
      inc(pckt2,mylen+28);
     end;
    profile(10);
    //POS KÜLDÉS VÉGE

   end;

 end;
 MMOstate:='Küldések vége, pihenés';
until exitthread;

//sendthreadcriticalsection.Leave;
end;

function sendallbuffersthread(MMO:Pointer):integer;
var
MMOjee:TMMOClient absolute MMO;
begin
 result:=0;
 if threadrunning then exit;
 threadrunning:=true;
 MMOjee.sendallbuffers;
 threadrunning:=false;
end;

{procedure TMMOClient.dellanplayer(wich:integer);
var
 i:integer;
begin
 for i:=wich to pplhgh-1 do
 begin
  ppl[i]:=ppl[i+1];
  pplpos[i]:=pplpos[i+1];
  pplpls[i]:=pplpls[i+1];
 end;
 dec(lanpplhgh);
 setlength(ppl,high(ppl));
 pplhgh:=high(ppl);
 setlength(pplpos,length(ppl));
 setlength(pplpls,length(ppl));

end; }

procedure TMMOclient.getdatafromcar(pos,opos:TD3DXVector3;axes:array of TD3DXVector3;ube,dis:boolean);
begin
 automsg.typ:=26;
 if ube then
  automsg.ulokbenne:=1
 else
 if dis then
  automsg.ulokbenne:=0
 else
  automsg.ulokbenne:=2;

 automsg.pos:=packvec(pos,2000);
 d3dxvec3lerp(opos,pos,opos,10);
 automsg.opos:=packvec(opos,2000);
 automsg.axes[0]:=packvec(axes[0],10);
 automsg.axes[1]:=packvec(axes[1],10);
 automsg.axes[2]:=packvec(axes[2],10);
end;

{procedure TMMOClient.Refresh(sendstats:boolean);
var

Mlogin:Tloginmsg;
Mstat:Tstatmsg;
mylen:integer;
i:integer;
amode:cardinal;
mpos:Tposmsg;
megy:TegyebMSG;
iamhere:Tsimplemsg;
label vissza;
begin


 if sendstats then
 begin
  toaddr.sin_family := AF_INET;
  toaddr.sin_addr := serveraddr;
  toaddr.sin_port := htons(SOCK_PORT_DEFAULT);
  tolen:=sizeof(toaddr);
  

  if code=0 then
  begin
   Mlogin.typ:=103;
   Mlogin.ver:=PROG_VER;
   Mlogin.login:=mynev;
   Mlogin.hash:=checksum;
   mylen:=sizeof(Mlogin);
   bufferedsendto(Mlogin,mylen,toaddr,false);
  end
  else
  begin
   Mstat.typ:=102;
   Mstat.kod:=code;
   Mstat.x:=mypos.pos.x;
   Mstat.y:=mypos.pos.z;
   mylen:=sizeof(Mstat);
   bufferedsendto(Mstat,mylen,toaddr,false);
  end;
  megy.typ:=15;
  megy.nev:=mynev;
  megy.fegyv:=myfegyv;
  mylen:=sizeof(megy);
  for i:= 0 to high(ppl) do
  begin
   toaddr:=incimtosockaddr(ppl[i]);
   tolen:=sizeof(toaddr);
   bufferedsendto(megy,mylen,toaddr,i<=lanpplhgh);
  end;
  //öööm fontos lan cucc
 begin
  refreshbroadcastaddr;
  iamhere.typ:=99;
  bufferedsendto(iamhere,sizeof(iamhere),incimtosockaddr(broadcastaddr),true);
 end;
  iter:=0;
 end;


 mpos.typ:=5;
 mpos.pos:=packpos(mypos);
 mylen:=sizeof(mpos);
 for i:= 0 to high(ppl) do
 begin
  toaddr:=incimtosockaddr(ppl[i]);
  tolen:=sizeof(toaddr);
  bufferedsendto(mpos,mylen,toaddr,i<=lanpplhgh,true);
 end;

 i:=0;
 while i<=lanpplhgh do
  if pplpls[i].mtim>3000 then dellanplayer(i) else inc(i);

 inc(iter);
 globpos:=mypos;
end; }

//{
function kozelvan(lovesk,lovesv,hely:TD3DVector):boolean;
var
 tmp1:TD3DVector;
 tmp2:single;
begin
 if tavpointlinesq(hely,lovesk,lovesv,tmp1,tmp2) then
  result:=tmp2<5*5
 else
  result:=tavpointpointsq(lovesv,hely)<7*7;
end;
// }
function kozelvan2(lovesk,lovesv,hely:TD3DVector):boolean;
var
 tmp1:TD3DVector;
 tmp2:single;
begin
 result:=false;
 if hely.y>10 then
  hely.y:=0
 else
 exit;

 if tavpointlinesq2d(hely,lovesk,lovesv,tmp1,tmp2) then
  result:=tmp2<20*20
end;  // }

procedure TMMOClient.lojj(honnan,v2:TD3DXVector3);
var
mlov:Tlovesmsg;
mlov2:Tpcklovesmsg;
i:integer;
v3:Tmypackedvector;
hu2,vu2:TD3DXVector3;
begin

 mlov.typ:=10;
 mlov.pos:=honnan;
 mlov.v2:=v2;

 mlov2.typ:=11;
 mlov2.pos:=packvec(honnan,3000);
 v3:=packvec(v2,3000);


 handleloves(@mlov,incimtosockaddr(mycim),false);

  if (myfegyv=FEGYV_NOOB) or (myfegyv=FEGYV_LAW) or (myfegyv=FEGYV_X72) then
  begin
   hu2:=honnan; hu2.y:=0;
   d3dxvec3subtract(vu2,v2,honnan);
   vu2.y:=0;
   if (myfegyv=FEGYV_NOOB) then
   begin
    vu2.x:=-vu2.x*25*500+hu2.x;
    vu2.z:=-vu2.z*25*500+hu2.z;
   end
   else
   if (myfegyv=FEGYV_LAW) then
   begin
    vu2.x:=-vu2.x*500+hu2.x;
    vu2.z:=-vu2.z*500+hu2.z;
   end
   else
   begin
    vu2.x:=-vu2.x*30+hu2.x;
    vu2.z:=-vu2.z*30+hu2.z;
   end;
  end;

 for i:= 0 to high(ppl) do
 if (tavpointpointsq(pplpos[i].pos,mypos.pos)<sqr(300)) and ((mypos.pos.y>150) xor (pplpos[i].pos.y<150))  then
 begin
  toaddr:=incimtosockaddr(ppl[i]);
  tolen:=sizeof(toaddr);


  if (myfegyv=FEGYV_NOOB) or (myfegyv=FEGYV_LAW) or (myfegyv=FEGYV_X72) then
  begin
   if (myfegyv xor pplpls[i].fegyv)>127 then
   if kozelvan2(hu2,vu2,pplpos[i].pos) then
     pplpls[i].lottram:=300;

   if pplpls[i].pklsz>=15 then pplpls[i].pklsz:=0;
   inc(pplpls[i].pklsz);

   pplpls[i].pkullov[pplpls[i].pklsz,1]:=honnan;
   pplpls[i].pkullov[pplpls[i].pklsz,2]:=v2;

  end
  else
  if (kozelvan(honnan,v2,pplpls[i].vpos) or kozelvan(honnan,v2,pplpos[i].pos)) then
  begin
   if pplpls[i].pklsz>=15 then pplpls[i].pklsz:=0;
   inc(pplpls[i].pklsz);

   pplpls[i].pkullov[pplpls[i].pklsz,1]:=honnan;
   pplpls[i].pkullov[pplpls[i].pklsz,2]:=v2;
  end
  else
  begin
   if pplpls[i].klsz>=15 then pplpls[i].klsz:=0;
   inc(pplpls[i].klsz);
   pplpls[i].kullov[pplpls[i].klsz]:=v3;
  end;
 end;
end;

procedure TMMOClient.chatelj(mit:string);
begin
 if mit='' then
 begin
  vanmitchatelni:=mynev2+':'+chats[0];
  chats[0]:='';
 end
 else
 vanmitchatelni:=mit;

end;

procedure TMMOClient.exitelj;
var
mchat:Tsimplemsg;
mylen:integer;
begin
 toaddr.sin_family := AF_INET;
 toaddr.sin_addr := serveraddr;
 toaddr.sin_port := htons(SOCK_PORT_DEFAULT);
 tolen:=sizeof(toaddr);

 Mchat.typ:=107;
 mylen:=sizeof(Tsimplemsg);
 sendto(sock,Mchat,mylen,0,@toaddr,tolen);
end;

procedure TMMOClient.doglodj(aapos,avpos,agmbvec:TD3DXVector3;amlgmb:byte;akimiatt:byte;airany:single;astate:byte;aanimstate:single);
begin
 with megdeglettem.dat do   //copy,copy,copy
 begin
  //apos.y:=apos.y+0.01;
  apos:=aapos;vpos:=avpos;gmbvec:=agmbvec;mlgmb:=amlgmb;kimiatt:=akimiatt;
  irany:=airany;state:=astate;animstate:=aanimstate;
 end;
  megdeglettem.typ:=20;
end;

procedure TMMOClient.beszelj(const data:Tbytearr;const kiknek:Tintarr);
var
i:integer;
begin
 setlength(speexppl,length(kiknek));
 for i:=0 to high(kiknek) do
  speexppl[i]:=kiknek[i];
 copymemory(@speexdata[0],@data[0],length(data));
 speexsiz:=length(data);
end;

procedure TMMOclient.delspeexdec(mit:integer);
begin     
 speexdecs[mit].dec.destroy;
 speexdecs[mit].dec:=nil;
 setlength(speexdecs[mit].decoded,0);
 speexdecs[mit].nev:='';
 speexdecs[mit]:=speexdecs[high(speexdecs)];
 setlength(speexdecs,high(speexdecs)); 
end;

procedure TMMOclient.addloves(v1,v2:TD3DXVector3;fegyv:byte);
begin
 setlength(lovesek,high(lovesek)+2);
 lovesek[high(lovesek)].v2:=v1;
 lovesek[high(lovesek)].pos:=v2;

 lovesek[high(lovesek)].kilotte:=255;
 lovesek[high(lovesek)].fegyv:=fegyv;
end;

end.

