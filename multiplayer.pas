unit multiplayer;

interface

uses sysutils, socketstuff, typestuff, D3DX9, windows, sha1;
const
 servername = 'localhost';
type
 TMMOServerClient = class(TObject)
 private
  myport:integer; //általam kijelölt port
  host,nev,jelszo:string;
  fegyver,fejcucc:integer;
  sock:TBufferedSocket;
  crypto:array [0..19] of byte; //kill csodacryptocucc
  UID:integer;
  laststatus:integer; //idõ amikor utoljára lett státuszüzenet küldve
  procedure SendLogin(nev,jelszo:string;fegyver,fejrevalo,port,checksum:integer);
  procedure SendChat(uzenet:string);
  procedure SendStatus(x,y:integer);
  procedure SendKill(UID:integer);

  procedure ReceiveLoginok(frame:TSocketFrame);
  procedure ReceivePlayerlist(frame:TSocketFrame);
  procedure ReceiveChat(frame:TSocketFrame);
  procedure ReceiveKick(frame:TSocketFrame);

 public
  loggedin:boolean; //read only
  playersonserver:integer;
  chats:array [0..8] of string; //detto
  kicked:string;
  kickedhard:boolean;
  kills:integer;
  killscamping:integer; //readwrite
  killswithoutdeath:integer; // readwrite
  constructor Create(ahost,anev,ajelszo:string;afegyver,afejcucc:integer);
  destructor Destroy;
  procedure Update(posx,posy:integer);
  procedure Chat(mit:string);
  procedure Killed(kimiatt:integer); //ez nem UID, hanem ppl index
 end;

 //megjegyzés: 20 bájtba kell beleférni egy ATM packethez, 68-ba kettõhöz
 TUDPFrame = class (TSocketFrame)
 public
  procedure WriteFloat(mit,scale:single);
  function ReadFloat(scale:single):single;
 end;


  Tloves = record
   pos,v2:Td3DXvector3;
   kilotte:integer;
   fegyv:byte;
  end;

  Thulla = record
   apos,vpos,gmbvec:TD3DXVector3;
   irany:single;
   animstate:single;
   mlgmb:byte;
   kimiatt:byte;
   state:byte;
   fegyver:integer;
  end;


 TMMOPeerToPeer = class(Tobject)
 public
  procedure Update(posx,posy,posz,iranyx,iranyy:single;state:integer;
                   campos:TD3DXvector3;//a prioritásokhoz
                   autoban:boolean; vanauto:boolean; autopos:TD3DXVector3; autoaxes:array {0..2} of TD3DXVector3);
  procedure Killed(apos,vpos:TD3DXVector3;irany:single;state:byte;animstate:single;
                   mlgmb:byte;gmbvec:TD3DXVector3;
                   kimiatt:integer);
  procedure Loves(v1,v2:TD3DXVector3;fegyv:byte);
 end;

var
 ppl:array of Tplayer;
 multisc:TMMOServerClient=nil;
 multip2p:TMMOPeerToPeer=nil;

 lovesek:array of Tloves; //a multip2p ezen keresztül kommunikálja le a lövéseket.
 hullak:array of Thulla; //ezen pedig a keletkezett rongybabákat

implementation

const
 shared_key:array [0..19] of byte=(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19);

 CLIENT_VERSION=30000;

 CLIENTMSG_LOGIN=1;
 {Login üzenet. Erre válasz: LOGINOK, vagy KICK
	int kliens_verzió
	string név
	string jelszó
	int fegyver
	int fejrevaló
	char[2] port
	int checksum
 }

 CLIENTMSG_STATUS=2;
 {Ennek az üzenetnek sok értelme nincs csak a kapcsolatot tartja fenn.
	int x
	int y
 }

 CLIENTMSG_CHAT=3;
 {Chat, ennyi.
	string uzenet
 }

 CLIENTMSG_KILLED=4;
 {Ha megölte a klienst valaki, ezt küldi.
	int UID
	char [20] crypto
 }

 SERVERMSG_LOGINOK=1;
 {
	int UID
	char [20] crypto
 }

 SERVERMSG_PLAYERLIST=2;
 {
 	int num
	num*
		char[4] ip
		char[2] port
		int uid
		string nev
		int fegyver
		int fejrevalo
		int killek

 }

 SERVERMSG_KICK=3;
 {
	char hardkick (bool igazából)
	string indok
 }

 SERVERMSG_CHAT=4;
 {
	string uzenet
 }


procedure TMMOServerClient.SendLogin(nev,jelszo:string;fegyver,fejrevalo,port,checksum:integer);
var
 frame:TSocketFrame;
begin
 frame:=TSocketFrame.Create;
 frame.WriteChar(CLIENTMSG_LOGIN);
 frame.WriteInt(CLIENT_VERSION);
 frame.WriteString(nev);
 frame.WriteString(jelszo);
 frame.WriteInt(fegyver);
 frame.WriteInt(fejrevalo);
 frame.WriteChar(port);
 frame.WriteChar(port shr 8);
 frame.WriteInt(checksum);
 sock.SendFrame(frame);
 frame.Free;
end;

procedure TMMOServerClient.SendChat(uzenet:string);
var
 frame:TSocketFrame;
begin
 frame:=TSocketFrame.Create;
 frame.WriteChar(CLIENTMSG_CHAT);
 frame.WriteString(uzenet);
 sock.SendFrame(frame);
 frame.Free;
end;

procedure TMMOServerClient.SendStatus(x,y:integer);
var
 frame:TSocketFrame;
begin
 frame:=TSocketFrame.Create;
 frame.WriteChar(CLIENTMSG_STATUS);
 frame.WriteInt(x);
 frame.WriteInt(y);
 sock.SendFrame(frame);
 frame.Free;
end;

procedure TMMOServerClient.SendKill(UID:integer);
var
 frame:TSocketFrame;
 i:integer;
 ujcrypto:TSHA1Digest;
begin
 for i:=0 to 19 do
  crypto[i]:=crypto[i] xor shared_key[i];
 ujcrypto:=SHA1Hash(@crypto[0],20);
 for i:=0 to 19 do
  crypto[i]:=ujcrypto[i];

 frame:=TSocketFrame.Create;
 frame.WriteChar(CLIENTMSG_KILLED);
 frame.WriteInt(UID);
 for i:=0 to 19 do
  frame.WriteChar(crypto[i]);
 sock.SendFrame(frame);
 frame.Free;
end;

procedure TMMOServerClient.ReceiveLoginok(frame:TSocketFrame);
var
i:integer;
begin
 loggedin:=true;
 UID:=frame.ReadInt;
 for i:=0 to 19 do
  crypto[i]:=frame.ReadChar;
end;

procedure TMMOServerClient.ReceivePlayerlist(frame:TSocketFrame);
var
i,j,n:integer;
nev:string;
ip,port,uid,fegyver,fejrevalo,killek:integer;
tmp:byte;
begin
 {!TODO faszom}
 n:=frame.ReadInt;
 for i:=0 to n-1 do
 begin
  ip:=frame.ReadChar+
      (frame.ReadChar shl 8)+
      (frame.ReadChar shl 16)+
      (frame.ReadChar shl 24);
  port:=frame.ReadChar+
        (frame.ReadChar shl 8);
  uid:=frame.ReadInt;
  nev:=frame.ReadString;
	fegyver:=frame.ReadInt;
  fejrevalo:=frame.ReadInt;
  killek:=frame.ReadInt;
 end;
end;

procedure TMMOServerClient.ReceiveChat(frame:TSocketFrame);
var
i:integer;
begin
 for i:=high(chats) downto 1 do
  chats[i]:=chats[i-1];
 chats[0]:=frame.ReadString;
end;

procedure TMMOServerClient.ReceiveKick(frame:TSocketFrame);
begin
 kickedhard:=frame.ReadChar=0;
 kicked:=frame.ReadString;
end;

constructor TMMOServerClient.Create(ahost,anev,ajelszo:string;afegyver,afejcucc:integer);
begin
 inherited Create;
 host:=ahost;
 nev:=anev;
 jelszo:=ajelszo;
 fegyver:=afegyver;
 fejcucc:=afejcucc;
 //!TODO egyéb cuccokat nullázni
end;

destructor TMMOServerClient.Destroy;
begin
 if sock<>nil then
 begin
  sock.Free;
  sock:=nil;
 end;

 inherited Destroy;
end;

procedure TMMOServerClient.Update(posx,posy:integer);
var
frame:TSocketFrame;
begin
 if sock=nil then
 begin
  TBufferedSocket.Create(CreateClientSocket(servername,25252));
  SendLogin(nev,jelszo,fegyver,fejcucc,myport,checksum);
  exit;
 end;

 sock.Update;
 if sock.error<>0 then
 begin
  sock.Free;
  sock:=nil;
  exit;
 end;

 frame:=TSocketFrame.Create;
 while sock.RecvFrame(frame) do
 begin
  case frame.ReadChar of
   SERVERMSG_LOGINOK: ReceiveLoginok(frame);
   SERVERMSG_CHAT: ReceiveChat(frame);
   SERVERMSG_KICK: ReceiveKick(frame);
   SERVERMSG_PLAYERLIST: ReceivePlayerList(frame);
  end;
 end;
 frame.Free;

 if laststatus<GetTickCount-3000 then
 begin
  laststatus:=GetTickCount;
  SendStatus(random(1000),random(1000));
 end;
end;

procedure TMMOServerClient.Chat(mit:string);
begin

end;

procedure TMMOServerClient.Killed(kimiatt:integer); //ez nem UID, hanem ppl index
begin

end;

{
function packpos(mit:Tmukspos):Tpackedpos;
begin
 with result do
 begin
  pos.x:=packfloat(mit.pos.x,2500);
  pos.y:=packfloat(mit.pos.y,400);
  pos.z:=packfloat(mit.pos.z,2500);
  irany:=packfloatheavy(mit.irany,D3DX_PI);
  prior:=round(mit.prior);
  irany2:=packfloatheavy(mit.irany2,D3DX_PI);
  state:=mit.state;
  BG:=mit.BG;
 end;
end;
}

procedure TUDPFrame.WriteFloat(mit,scale:single);
begin

end;

function TUDPFrame.ReadFloat(scale:single):single;
begin
 result:=0;
end;



procedure TMMOPeerToPeer.Update(posx,posy,posz,iranyx,iranyy:single;state:integer;
                   campos:TD3DXvector3;//a prioritásokhoz
                   autoban:boolean; vanauto:boolean; autopos:TD3DXVector3; autoaxes:array {0..2} of TD3DXVector3);
begin

end;

procedure TMMOPeerToPeer.Killed(apos,vpos:TD3DXVector3;irany:single;state:byte;animstate:single;
                   mlgmb:byte;gmbvec:TD3DXVector3;
                   kimiatt:integer);
begin

end;

procedure TMMOPeerToPeer.Loves(v1,v2:TD3DXVector3;fegyv:byte);
begin

end;

end.
