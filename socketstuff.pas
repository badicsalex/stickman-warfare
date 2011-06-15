unit socketstuff;

interface
uses sysutils,winsock2,windows;

type

  TDynByteArray = array of byte;
  TSocketFrame=class
  public
    data:TDynByteArray; // csínján.
    cursor:integer;
	  // átveszi a char* kezelését, felszabadítja destruáláskor.
	  constructor CreateFromData(adata:TDynByteArray);
	  constructor Create;

	  procedure Reset;
	  function ReadChar:byte;
	  function ReadInt:integer;
	  function ReadString:string;

	  procedure WriteChar(mit:byte);
	  procedure WriteInt(mit:integer);
	  procedure WriteString(const mit:string);
  end;


  TBufferedSocket=class
  private
    sock:TSocket;
    recvbuf:TDynByteArray;
    sendbuf:TDynByteArray;
  public
    error:integer;
    closeaftersend:boolean;
    constructor Create(asock:Tsocket);
    destructor Destroy;override;
    procedure Update;
    function RecvFrame(var hova:TSocketFrame):boolean;
    procedure SendFrame(var mit:TSocketFrame);
  end;

  function SelectForRead(sock:TSocket):integer;
  function SelectForWrite(sock:TSocket):integer;
  function SelectForError(sock:TSocket):integer;
  function CreateClientSocket(hostname:string;port:integer):TSocket;
implementation

procedure InitWinsock;
var
dat:TWSAData;
begin
 WSAStartup(MAKEWORD(2,2),dat);
end;

function gethostbynamewrap(nam:string):Tinaddr;
var
hste:Phostent;
begin
  hste:=gethostbyname(Pchar(nam));
  if hste=nil then begin result.s_addr:=0; exit; end;
  result := Pinaddr(hste.h_addr^ )^;
end;

function CreateClientSocket(hostname:string;port:integer):TSocket;
var
srvc:sockaddr_in;
begin
  result:=socket(AF_INET,SOCK_STREAM, IPPROTO_TCP);
  Srvc.sin_family := AF_INET;
  Srvc.sin_addr:=gethostbynamewrap(hostname);
  Srvc.sin_port := htons(port);
  connect(result,@srvc,sizeof(srvc));
end;

constructor TSocketFrame.CreateFromData(adata:TDynByteArray);
var
i:integer;
begin
 setlength(data,length(adata));
 for i:=0 to high(data) do
  data[i]:=adata[i];
 cursor:=0;
end;

constructor TSocketFrame.Create;
begin
 inherited Create;
 cursor:=0;
end;

procedure TSocketFrame.Reset;
begin
 cursor:=0;
end;

function TSocketFrame.ReadChar:byte;
begin
 cursor:=cursor+1;
 if cursor<=length(data) then
  result:=data[cursor-1]
 else
  result:=0;
end;

function TSocketFrame.ReadInt:integer;
begin
 cursor:=cursor+4;
 if cursor<=length(data) then
  result:=data[cursor-4] or
         (data[cursor-3] shl 8) or
         (data[cursor-2] shl 16) or
         (data[cursor-1] shl 24)
 else
  result:=0;
end;

function TSocketFrame.ReadString:string;
var
lngt:integer;
i:integer;
begin
 lngt:=ReadChar;
 if cursor+lngt<=length(data) then
 begin
  SetLength(result,lngt);
  for i:=1 to lngt do
   result[i]:=chr(data[cursor+i-1]);
  cursor:=cursor+lngt;
 end
 else
  result:='';
end;

procedure TSocketFrame.WriteChar(mit:byte);
begin
 setlength(data,length(data)+1);
 data[high(data)]:=mit;
end;

procedure TSocketFrame.WriteInt(mit:integer);
begin
 setlength(data,length(data)+4);
 data[high(data)-3]:=mit;
 data[high(data)-2]:=mit shr 8;
 data[high(data)-1]:=mit shr 16;
 data[high(data)  ]:=mit shr 24;
end;

procedure TSocketFrame.WriteString(const mit:string);
var
 lngt:byte;
 tmp:integer;
 i:integer;
begin
 lngt:=length(mit);
 tmp:=length(data);
 setlength(data,length(data)+1+lngt);
 data[tmp]:=lngt;
 for i:=1 to lngt do
  data[tmp+i]:=ord(mit[i]);
end;


constructor TBufferedSocket.Create(asock:Tsocket);
begin
 inherited Create;
 sock:=asock;
 closeaftersend:=false;
end;

destructor TBufferedSocket.Destroy;
begin
 closesocket(sock);
 inherited Destroy;
end;

procedure erasefront(var arr:TDynByteArray; mennyit:integer);
var
i:integer;
begin
 if length(arr)<=mennyit then
  setlength(arr,0)
 else
 begin
  for i:=0 to high(arr)-mennyit do
   arr[i]:=arr[i+mennyit];
  setlength(arr,length(arr)-mennyit);
 end;
end;

procedure TBufferedSocket.Update;
var
 mit:PByteArray;
 mennyit,mennyilett:integer;
 hova: array[0..16*1024] of byte;
 i,tmp:integer;
begin
  while (length(sendbuf)>0) and (SelectForWrite(sock)<>0) do
  begin
    mit:=@sendbuf[0];
		mennyit:=length(sendbuf);
		if mennyit>16*1024 then
			mennyit:=16*1024;

		mennyilett:=send(sock,mit^,mennyit,0);

		if (mennyilett=SOCKET_ERROR) then
			error:=WSAGetLastError()
		else
			erasefront(sendbuf,mennyilett);

    if closeaftersend and (length(sendbuf)=0) then
     error:=1;

		if (mennyit<>mennyilett) then
			break;
  end;

 //recv
	while SelectForRead(sock)<>0 do
  begin
    mennyit:=1024*16;
		mennyilett:=recv(sock,hova,mennyit,0);

		if (mennyilett=SOCKET_ERROR) then
			error:=WSAGetLastError()
		else
		if (mennyilett=0) then //connection closed
			error:=1
		else
		begin
      tmp:=length(recvbuf);
      setlength(recvbuf,length(recvbuf)+mennyilett);
      for i:=0 to mennyilett-1 do
       recvbuf[tmp+i]:=hova[i];
    end;

		if (mennyit<>mennyilett) then
			break;
  end;

	if(SelectForError(sock))<>0 then
		error:=2;//ezt észre fogod venni.
	if (length(sendbuf)=0) and closeaftersend then
		error:=3;//ezt is. Ez után töröld és csá
end;

function TBufferedSocket.RecvFrame(var hova:TSocketFrame):boolean;
var
siz:integer;
i:integer;
begin
  result:=false;
  if (length(recvbuf)<2) then
		exit;

	siz:=recvbuf[0] or (recvbuf[1] shl 8);

	if (siz<1) then //faszom.
		exit;

	if (length(recvbuf)<2+siz) then
		exit;

	setlength(hova.data,siz);

	for i:=0 to siz-1 do
		hova.data[i]:=recvbuf[2+i];
  hova.cursor:=0;
	erasefront(recvbuf,siz+2);
	result:=true;
end;

procedure TBufferedSocket.SendFrame(var mit:TSocketFrame);
var
 tmp:integer;
 i:integer;
 meret:integer;
begin
  if (length(mit.data)<=0) then // me no like
   exit;

 tmp:=length(sendbuf);
 setlength(sendbuf,length(sendbuf)+2+length(mit.data));
 meret:=length(mit.data);
 sendbuf[tmp]:=meret;
 sendbuf[tmp+1]:=meret shr 8;
 tmp:=tmp+2;
 for i:=0 to high(mit.data) do
  sendbuf[tmp+i]:=mit.data[i];
end;


function SelectForRead(sock:TSocket):integer;
var
 csillamvaltozo:TFDSet;
 csodavaltozo:Ttimeval;
begin
 csodavaltozo.tv_sec :=0;
 csodavaltozo.tv_usec:=0;
 FD_ZERO(csillamvaltozo);
 FD_SET(sock,csillamvaltozo);
 result:=select(1,@csillamvaltozo,nil,nil,@csodavaltozo);
end;

function SelectForWrite(sock:TSocket):integer;
var
 csillamvaltozo:TFDSet;
 csodavaltozo:Ttimeval;
begin
 csodavaltozo.tv_sec :=0;
 csodavaltozo.tv_usec:=0;
 FD_ZERO(csillamvaltozo);
 FD_SET(sock,csillamvaltozo);
 result:=select(1,nil,@csillamvaltozo,nil,@csodavaltozo);
end;

function SelectForError(sock:TSocket):integer;
var
 csillamvaltozo:TFDSet;
 csodavaltozo:Ttimeval;
begin
 csodavaltozo.tv_sec :=0;
 csodavaltozo.tv_usec:=0;
 FD_ZERO(csillamvaltozo);
 FD_SET(sock,csillamvaltozo);
 result:=select(1,nil,nil,@csillamvaltozo,@csodavaltozo);
end;

initialization
 InitWinsock;
end.
