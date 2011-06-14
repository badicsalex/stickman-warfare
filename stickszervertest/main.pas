unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,tcp_socket_stuff, StdCtrls, ExtCtrls, Mask;

type
  TForm1 = class(TForm)
    Button1: TButton;
    clients: TMemo;
    chat: TMemo;
    Edit1: TEdit;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Bevel1: TBevel;
    Timer1: TTimer;
    Edit3: TEdit;
    Label8: TLabel;
    Label5: TLabel;
    Edit4: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TServerContext = record
    loggedin:boolean;
    crypto:array [0..19] of byte;
    UID:integer;
  end;

const
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

var
  Form1: TForm1;
  sock:TBufferedSocket;
  context:TServerContext=(loggedin:false);
implementation

{$R *.dfm}

procedure SendLogin(nev,jelszo:string;fegyver,fejrevalo,port,checksum:integer);
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

procedure SendChat(uzenet:string);
var
 frame:TSocketFrame;
begin
 frame:=TSocketFrame.Create;
 frame.WriteChar(CLIENTMSG_CHAT);
 frame.WriteString(uzenet);
 sock.SendFrame(frame);
 frame.Free;
 Form1.Button2.Enabled:=true;
end;

procedure SendStatus(x,y:integer);
var
 frame:TSocketFrame;
begin
 frame:=TSocketFrame.Create;
 frame.WriteChar(CLIENTMSG_STATUS);
 frame.WriteInt(x);
 frame.WriteInt(y);
 sock.SendFrame(frame);
 frame.Free;
 Form1.Button2.Enabled:=true;
end;

procedure RecieveLoginok(frame:TSocketFrame);
var
i:integer;
begin
 context.loggedin:=true;
 context.UID:=frame.ReadInt;
 for i:=0 to 19 do
  context.crypto[i]:=frame.ReadChar;
 Form1.Label5.Caption:='UID: '+inttostr(context.UID);
 Form1.Button2.Enabled:=true;
end;

function qntoa(ip:integer):string;
begin
 result:=inttostr((ip       ) and $ff)+'.'+
         inttostr((ip shr 8 ) and $ff)+'.'+
         inttostr((ip shr 16) and $ff)+'.'+
         inttostr((ip shr 24) and $ff);
end;

procedure RecievePlayerlist(frame:TSocketFrame);
var
i,j,n:integer;
nev:string;
ip,port,uid,fegyver,fejrevalo,killek:integer;
tmp:byte;
begin
 Form1.clients.Lines.Clear;
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
  Form1.clients.Lines.Add(inttostr(UID)+':'+nev+'@'+qntoa(ip))
 end;
end;

procedure RecieveChat(frame:TSocketFrame);
begin
 Form1.chat.Lines.Add(frame.ReadString);
end;

procedure RecieveKick(frame:TSocketFrame);
var
uzi:string;
begin
 if frame.ReadChar=0 then
  uzi:='Kicked soft: '
 else
  uzi:='Kicked hard: ';
 Form1.chat.Lines.Add(uzi+frame.ReadString);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 context.loggedin:=false;
 sock:=TBufferedSocket.Create(CreateClientSocket(Edit3.Text,25252));
 Button1.Enabled:=false;
 SendLogin(Edit2.Text,Edit4.Text,1234,5678,2345,12345678);
end;

var
laststatus:integer;

procedure TForm1.Timer1Timer(Sender: TObject);
var
 frame:TSocketFrame;
begin
 if sock=nil then
  exit;
 sock.Update;
 if sock.error<>0 then
 begin
  chat.Lines.Add('Error van '+inttostr(sock.error));
  sock.Free;
  sock:=nil;
  Button1.Enabled:=true;
  Button2.Enabled:=false;
  exit;
 end;

 frame:=TSocketFrame.Create;
 while sock.RecvFrame(frame) do
 begin
  case frame.ReadChar of
   SERVERMSG_LOGINOK: RecieveLoginok(frame);
   SERVERMSG_CHAT: RecieveChat(frame);
   SERVERMSG_KICK: RecieveKick(frame);
   SERVERMSG_PLAYERLIST: RecievePlayerList(frame);
  end;
 end;
 frame.Free;

 if laststatus<GetTickCount-3000 then
 begin
  laststatus:=GetTickCount;
  SendStatus(random(1000),random(1000));
 end;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 SendChat(Edit1.Text);
end;

end.
