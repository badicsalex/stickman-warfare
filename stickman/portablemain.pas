unit portablemain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, zlibexgz, FileCtrl, ExtCtrls;

type
  TForm1 = class(TForm)
    ProgressBar1: TProgressBar;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Timer1: TTimer;

    procedure Button3Click(Sender: TObject);
    procedure WMNCHitTest(var Msg: TWMNCHitTest) ; message WM_NCHitTest;
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TBufferstream = class(TStream)
  protected
   belsobuf:pointer;
   procedure SetSize(NewSize: Longint);
  public
    position,size:integer;
    function Read(var Buffer; Count: Longint): Longint;override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint;override;
    constructor Create(buf:pointer; siz:integer);
    destructor destroy;virtual;
  end;

 Tmyfilerecord = record
  nev:string;
  gzsiz:integer;
  infiloffset:integer;
 end;
var
  Form1: TForm1;
  fajlok:array of Tmyfilerecord;
  procid:cardinal;
  adir:string;
implementation

{$R *.DFM}
uses ShellAPI;
Function DelTree(DirName : string): Boolean;
var
  SHFileOpStruct : TSHFileOpStruct;
  DirBuf : array [0..255] of char;
begin
  try
   Fillchar(SHFileOpStruct,Sizeof(SHFileOpStruct),0) ;
   FillChar(DirBuf, Sizeof(DirBuf), 0 ) ;
   StrPCopy(DirBuf, DirName) ;
   with SHFileOpStruct do begin
    Wnd := 0;
    pFrom := @DirBuf;
    wFunc := FO_DELETE;
    fFlags := FOF_ALLOWUNDO;
    fFlags := fFlags or FOF_NOCONFIRMATION;
    fFlags := fFlags or FOF_SILENT;
   end; 
    Result := (SHFileOperation(SHFileOpStruct) = 0) ;
   except
    Result := False;
  end;
end;


procedure TBufferStream.SetSize(NewSize: Longint);
begin
 //üres...
end;

function TBufferStream.Read(var Buffer; Count: Longint): Longint;
begin

 if count>size-position then
  count:=size-position;

 copymemory(@Buffer,pointer(dword(belsobuf)+position),count);

 position:=position+count;
 result:=count;

end;

function TBufferStream.Write(const Buffer; Count: Longint): Longint;
begin
 messagebox(0,'Read only stream','not good',0);
end;


constructor TBufferStream.Create(buf:pointer; siz:integer);
begin
 inherited Create;
 position:=0;
 size:=siz;
 getmem(belsobuf,siz);
 copymemory(belsobuf,buf,siz);
end;

destructor TBufferStream.destroy;
begin
 freemem(belsobuf);
 inherited;

end;


function TBufferStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
 case origin of
  soFromBeginning:position:=offset;
  soFromCurrent  :position:=position+offset;
  soFromEnd      :position:=size-offset;
 end;
 result:=position;
end;

procedure msde(nev:string);
var
str2:string;
begin
 str2:='';
 while pos('\',nev)>0 do
 begin
  str2:=str2+copy(nev,1,pos('\',nev));
  if not directoryexists(str2) then
   mkdir(str2);
  nev:=copy(nev,pos('\',nev)+1,1000);
 end;
end;


procedure olvasfajl(filname:string;dir:string;offset:integer);
var
 i,ln:integer;
 fil:file;
 str:string;
 curroffs:integer;
 chr:char;
 buf:pointer;
 uzbuf:pointer;
 uzsiz:integer;
 buf2:TStream;
 OutputStream: TFileStream;

begin
with Form1 do begin
 assignfile(fil,filname);
 filemode:=0;
 reset(fil,1);
 seek(fil,offset);
 setlength(fajlok,1000);
 i:=0;
 repeat
  str:='';
  repeat
   blockread(fil,chr,1);
   str:=str+chr;
  until pos(#13#10,str)>0;
  setlength(str,length(str)-2);
  if str='' then break;

  fajlok[i].nev:=dir+stringreplace(str,'/','\',[rfReplaceAll]);
  str:='';
  repeat
   blockread(fil,chr,1);
   str:=str+chr;
  until pos(#13#10,str)>0;
  setlength(str,length(str)-2);

   fajlok[i].gzsiz:=strtoint(str);
  inc(i);
 until false;
 setlength(fajlok,i);

 ProgressBar1.Max:=i-1;
 progressbar1.Repaint;
 curroffs:=filepos(fil);
 for i:=0 to high(fajlok) do
 begin
  fajlok[i].infiloffset:=curroffs;
  inc(curroffs,fajlok[i].gzsiz);
 end;

 for i:=0 to high(fajlok) do
 begin
  ProgressBar1.Position:=i;
   progressbar1.Repaint;
  msde(fajlok[i].nev);

  seek(fil,fajlok[i].infiloffset);
  getmem(buf,fajlok[i].gzsiz);
  blockread(fil,buf^,fajlok[i].gzsiz);
  buf2:=Tbufferstream.Create(buf,fajlok[i].gzsiz);
  freemem(buf);
    if fileexists(fajlok[i].nev) then deletefile(fajlok[i].nev);
    
  OutputStream := TFileStream.Create(fajlok[i].nev, fmCreate);
  GZDecompressStream(buf2,Outputstream);

  Freeandnil(Outputstream);
  freeandnil(buf2);
 end;
 closefile(fil);
end; end;


procedure TForm1.WMNCHitTest(var Msg: TWMNCHitTest) ;
begin
   inherited;
   if Msg.Result = htClient then Msg.Result := htCaption;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
 close;
end;

procedure startprocwithid(mit,params:string);
var
startupinfo:Tstartupinfo;
procinf:TProcessInformation;
begin
 zeromemory(@startupinfo, sizeof(startupinfo));
 startupinfo.cb:=sizeof(startupinfo);
 createprocess(nil,Pchar(mit+' '+params),nil,nil,false,0,nil,nil,startupinfo,procinf);
 procid:=procinf.hProcess;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
var
tmp:Pchar;
tmpdir:string;
begin
 Timer1.onTimer:=Timer2Timer;
 Timer1.enabled:=false;

 getmem(tmp,1000);
 gettemppath(1000,tmp);
 tmpdir:=string(tmp);
 freemem(tmp);

 repaint;
 adir:=extractfilepath(Application.exename)+'\Stickman';
 if not DirectoryExists(tmpdir+'Stickman') then
 begin
  if CreateDir(tmpdir+'Stickman') then
    adir:=tmpdir+'Stickman'
  else
  if not DirectoryExists(adir) then
   if not CreateDir(adir) then
   begin
    application.messagebox('Could not unpack','SMWF Portable',0);
    close;
    exit;
   end;
 end
 else
  adir:=tmpdir+'Stickman';

 adir:=adir+'\';
 if fileexists(adir+'Setup.exe') then
   deltree(adir+'data\');


 olvasfajl(application.exename,adir,356864);

 startprocwithid(adir+'Setup.exe','');
 Timer1.enabled:=true;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
var
exitc:cardinal;
begin
 exitc:=0;
 Getexitcodeprocess(procid,exitc);
 if exitc<>STILL_ACTIVE then
 begin
  deltree(copy(adir,0,length(adir)-1));
  close;
 end;

end;

end.
