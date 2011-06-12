unit Serverstatsmain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ExtCtrls, StdCtrls, shellapi, ImgList, winsock2, registry;
const
 WM_ICONTRAY=WM_USER + 1;
type
  TForm1 = class(TForm)
    Label1: TLabel;
    PopupMenu1: TPopupMenu;
    menuitem1: TMenuItem;
    menuitem3: TMenuItem;
    Timer1: TTimer;
    IML: TImageList;
    menuitem2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure menuitem3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    TrayIconData: TNotifyIconData;

    { Private declarations }
  public
    { Public declarations }
    procedure TrayMessage(var Msg: TMessage); message WM_ICONTRAY;
  end;

var
  Form1: TForm1;
  p2:byte;
  frlen,tolen:integer;
  sock:integer;
  sajatport:word;
  serveraddr:array [0..4] of Tinaddr;
  utsoservermsg:array [0..4] of cardinal;
  playernum:array [0..4] of smallint;
  servers: array [0..6] of string = ('gagyi.game-host.org','sticktop.teteny.bme.hu','stickman.teteny.bme.hu','stickmanlabs.homeip.net','walter.sch.bme.hu','pityuli.dontexist.org','scdserver1.game-host.org');
  servernames: array [0..6] of string = ('Main server','SubMain server','BME server','Bolint''s server','Walter''s TMP server','Pityuli''s server','Calmarius'' server');

const
APP_SOCK_DEFAULT_PORT=25252;
implementation

{$R *.DFM}

procedure refreshimg(mit:integer);
var
biti:Tbitmap;
begin
 biti:=Tbitmap.create;
 biti.width:=16;
 biti.height:=16;
 with  biti.Canvas do
 begin
  Brush.Color:=claqua;
  pen.color:=clblack;
  font.color:=clblack;
  rectangle(-1,-1,17,17);
  font.Name:='Arial';
  font.Height:=-10;
  textout(2,2,inttostr(mit));
 end;
 form1.IML.Add(biti,nil);
end;

function gethostbynamewrap(nam:string):Tinaddr;
var
hste:Phostent;
az:cardinal;
begin
  az:=inet_addr(Pchar(nam));
  if az<>INADDR_NONE then
  begin
   result.S_addr:=az;
   exit;
  end;
  hste:=gethostbyname(Pchar(nam));
  if hste=nil then begin result.s_addr:=0; exit; end;
  result := Pinaddr(hste.h_addr^ )^;
end;

procedure Createsck(hwnd:Thandle);
var
dat:TWSAData;
srvc:sockaddr_in;
amode:cardinal;
//ideiglenes socket
hiba:integer;
hostname:PChar;
i:integer;
begin
  randomize;

  //Socket stuff
  frlen:=sizeof(sockaddr);
  tolen:=sizeof(sockaddr);

  WSAStartup(MAKEWORD(2,2),dat);
  sock:=socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP);
   if sock=SOCKET_ERROR then
  begin
   messagebox(hwnd,'Hiba','Socket hiba.',0);
   form1.close;
  end;

  Srvc.sin_family := AF_INET;
  Srvc.sin_addr.S_addr := htonl(INADDR_ANY);
  //Srvc.sin_addr.S_addr :=inet_addr(Pchar(edit1.text));


  sajatport:=APP_SOCK_DEFAULT_PORT+5{+random(200)};
  Srvc.sin_port := htons(sajatport);
                                                       
  hiba:=bind(sock,@srvc,sizeof(srvc));
  if hiba=SOCKET_ERROR then
  begin
   messagebox(hwnd,'Hiba','Socket hiba.',0);
   form1.close;
  end;

  amode:=1;
  ioctlsocket(sock, FIONBIO, amode);
  for i:=0 to high(servers) do
   serveraddr[i]:=gethostbynamewrap(servers[i]);
end;

procedure refreshsck(kulddis:boolean);
var
msg:byte;
msg2:array [1..50] of byte ;
jott:integer;
fraddr,toaddr:TSockAddr;
frlen:integer;
mylen:integer;
i:integer;
begin
   if sock=SOCKET_ERROR then
  begin
   messagebox(form1.handle,'Hiba','Socket hiba.',0);
   form1.close;
  end;
  if kulddis then
  for i:=0 to high(servers) do
  begin
   

   toaddr.sin_family := AF_INET;
   toaddr.sin_addr := serveraddr[i];
   toaddr.sin_port := htons(APP_SOCK_DEFAULT_PORT);
   tolen:=sizeof(toaddr);
   msg:=111;
   mylen:=sizeof(msg);
   sendto(sock,msg,mylen,0,@toaddr,tolen);
   sleep(30);
  end;
  
  zeromemory(@fraddr,sizeof(sockaddr));
  fraddr.sin_family := AF_INET;
  frlen:=sizeof(fraddr);
  repeat
    msg2[1]:=0;
   jott:=recvfrom(sock,msg2,50,0,@fraddr,@frlen);

   if (jott>=1) then
   for i:=0 to high(servers) do
    if(fraddr.sin_addr.S_addr=serveraddr[i].S_addr) then
    begin
     playernum[i]:=msg2[1];
     utsoservermsg[i]:=gettickcount;
    end;
  until jott<=0;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
i:integer;
Icon:TIcon;
begin
 sleep(3000);
 createsck(handle);
 Icon:=TIcon.Create;
 icon.LoadFromFile('data\miniicon.ico');
 IML.AddIcon(icon);

 //reg.Writestring('Stickman Server Stats',application.exename);
 //WM_ICONTRAY:=registerwindowmessage('SMWFservermsg');
 //image1.Picture.LoadFromFile('data\miniicon.bmp');
 for i:=0 to 99 do
  refreshimg(i);
 with TrayIconData do
  begin
    cbSize := SizeOf(TrayIconData);
    Wnd := Handle;
    uID := 0;
    uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
    uCallbackMessage := WM_ICONTRAY;
    hIcon := icon.Handle;
    StrPCopy(szTip, 'Stickman Warfare players on server: NOT INITIALIZED');
  end;
  Shell_NotifyIcon(NIM_ADD, @TrayIconData);
  icon.destroy;
  for i:=0 to high(servers) do
  playernum[i]:=-1;
 // reg.Writeinteger('rekord',rekord);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
 Shell_NotifyIcon(NIM_DELETE, @TrayIconData);
 closesocket(sock);
 WSACleanup;
end;

procedure TForm1.TrayMessage(var Msg: TMessage);
var
p:Tpoint;
begin
  case Msg.lParam of
    WM_LBUTTONDOWN,WM_RBUTTONDOWN:
    begin
      SetForegroundWindow(Handle);
       GetCursorPos(p);
       PopUpMenu1.Popup(p.x, p.y);
       PostMessage(Handle, WM_NULL, 0, 0);
    end;
  end;
end;

procedure TForm1.menuitem3Click(Sender: TObject);
begin
 close;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
Icon:TIcon;
ln,i,lnh:integer;
begin
 ln:=-1;
 lnh:=0;
 for i:=0 to high(servers) do
 begin
  if (utsoservermsg[i]<gettickcount-10000) then playernum[i]:=-1;
  if playernum[i]>ln then
  begin
   ln:=playernum[i];
   lnh:=i;
  end;
 end;

 p2:=(p2+1) mod 6;
 refreshsck((p2 mod 3)=0);
 Icon:=Ticon.create;
 if p2<3 then
  IML.GetIcon(0,icon)
 else
  IML.GetIcon(ln+1,icon);
 if ln>=0 then
  StrPCopy(TrayIconData.szTip, 'Stickman Warfare players on '+servernames[lnh]+': '+inttostr(ln))
 else
  StrPCopy(TrayIconData.szTip, 'Stickman Warfare: NO SERVERS ONLINE');

 TrayIconData.hIcon := Icon.Handle;
 Shell_NotifyIcon(NIM_Modify, @TrayIconData);
 icon.destroy;

 if ln>=0 then
  menuitem2.Caption:='Players on '+servernames[lnh]+': '+inttostr(ln)
 else
  menuitem2.Caption:='NO SERVERS ONLINE';

end;

end.
