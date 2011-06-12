unit installermain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, zlibexgz, FileCtrl;

type
  TForm1 = class(TForm)
    ProgressBar1: TProgressBar;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure WMNCHitTest(var Msg: TWMNCHitTest) ; message WM_NCHitTest;

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

implementation

{$R *.DFM}

procedure deltree(start:string);
var
myrec:Tsearchrec;
begin
 if findfirst(start+'*.*',faAnyFile,myrec)=0 then
 repeat
  Deletefile(start+myrec.Name);
 until not (findnext(myrec)=0);
 findclose(myrec);
 if findfirst(start+'*',fadirectory,myrec)=0 then
 repeat
  if (not ((myrec.name='.') or (myrec.name='..'))) and ((myrec.Attr and fadirectory)>0) then
  deltree(start+myrec.name+'\');
 until not (findnext(myrec)=0);
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
 label1.caption:='Intitializing';
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
 label1.caption:='Installing';
 progressbar1.Repaint;
 label1.Repaint;
 curroffs:=filepos(fil);
 for i:=0 to high(fajlok) do
 begin
  fajlok[i].infiloffset:=curroffs;
  inc(curroffs,fajlok[i].gzsiz);
 end;

 for i:=0 to high(fajlok) do
 begin
  ProgressBar1.Position:=i;
  label1.caption:='Installing:'+fajlok[i].nev;
   progressbar1.Repaint;
 label1.Repaint;
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


procedure TForm1.FormCreate(Sender: TObject);
begin
 Edit1.text:=ExtractFileDir(application.exename)+'\Stickman';
end;

procedure TForm1.Button1Click(Sender: TObject);
var
 str:string;
begin
 str:=EDit1.text;
 if SelectDirectory('Install Directory',str,str) then
 Edit1.text:=str;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 if Edit1.text[lengtH(Edit1.text)]<>'\' then
  Edit1.text:=Edit1.text+'\';
 if fileexists(Edit1.text+'stickman.exe') then
   deltree(Edit1.text+'data\');
   
 olvasfajl(application.exename,Edit1.text,367104);
  if Application.MessageBox(
        'Finished installig.'#13#10#13#10'Launch Stickman Warfare?',

        'Install Complete',
        MB_YESNO + MB_DEFBUTTON1) = IDYES then
   winexec(PChar(edit1.text+'Stickman.exe'),SW_SHOW);
 close;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
 close;
end;

end.
