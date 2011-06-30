unit MADXDllInterface;
interface
uses
  Windows,sysutils,typestuff,winsock2;

const
  MADX_INPUT_BUFFER_SIZE = (5*1152*8);
  MADX_OUTPUT_BUFFER_SIZE = (1152*8);
  MAD_BUFFER_GUARD    =8;

type
  madx_sig = (
    ERROR_OCCURED,
    MORE_INPUT,
    FLUSH_BUFFER,
    EOF_REACHED, 
    CALL_AGAIN  );

type

  size_t=longint;

  madx_stat = record
    msg: Array[0..256-1] of Char;
    write_size: SIZE_T;
    is_eof: Integer;
    readsize: SIZE_T;
    remaining: SIZE_T;
{/// Will reference some }
{/// "middle part" of in_buffer: }
    buffstart: PByte;
  end;

function madx_init(out_buffer: PByte;
                      mxhouse: pointer): Integer cdecl  {$IFDEF WIN32} stdcall {$ENDIF};

 function madx_read( in_buffer: PByte;
                       out_buffer: PByte;
                       mxhouse: pointer;
                      var mxstat: MADX_STAT): MADX_SIG cdecl  {$IFDEF WIN32} stdcall {$ENDIF};

  procedure madx_deinit(mxhouse: pointer) cdecl  {$IFDEF WIN32} stdcall {$ENDIF};


type
  TMp3File=class(Tobject)
  private
   fil:file of byte;
   in_buffer: array [0..MADX_INPUT_BUFFER_SIZE -1] of byte ;
   out_buffer: array [0..MADX_OUTPUT_BUFFER_SIZE+ MAD_BUFFER_GUARD-1] of byte ;
   mxhouse:pointer;
   pnagybuf:Pointer;
   mxstat:madx_stat;
  public
   iseof:boolean;
   samplerate:integer;
   constructor create(filnam:string);
   destructor destroy; override;
   procedure read(var hova:Tsmallintdynarr);
  end;

  TMp3Stream=class(Tobject)
  private
   in_buffer: array [0..MADX_INPUT_BUFFER_SIZE -1] of byte ;
   out_buffer: array [0..MADX_OUTPUT_BUFFER_SIZE+ MAD_BUFFER_GUARD-1] of byte ;
   mxhouse:pointer;
   pnagybuf:Pointer;
   mxstat:madx_stat;
   sck:dword;
   mxsig:madx_sig;
  public
   error:integer;  //0 ha minen oké.
   samplerate:integer;//url:port, ha lehet. 8000-re defaultol
   nev:string;
   constructor create(url:string);
   destructor destroy; override;
   procedure read(var hova:Tsmallintdynarr);
  end;

type
  Pstaticintarr = ^Tstaticintarr;
  Tstaticintarr = array [0..500] of integer;

implementation
procedure madx_deinit; external 'madmp3.DLL' name '_madx_deinit@4';
function madx_read; external 'madmp3.DLL' name '_madx_read@16';
function madx_init; external 'madmp3.dll' name '_madx_init@8';

//////////////////////////////////////////////////////
////////--------MP3FILE----------////////////////////
//////////////////////////////////////////////////////
constructor Tmp3File.create(filnam:string);
begin
 inherited create;

 assignfile(fil,filnam);
 reset(fil);
 getmem(mxhouse,128*1024); //Ez se lehet több fél megánál
 zeromemory(mxhouse,128*1024);
 zeromemory(@out_buffer[0],sizeof(out_buffer));
 zeromemory(@in_buffer[0],sizeof(in_buffer));
 madx_init(@out_buffer[0],mxhouse);

 zeromemory(@mxstat,sizeof(mxstat));
end;

procedure Tmp3file.read(var hova:Tsmallintdynarr);
var
a:integer;
mxsig:madx_sig;
label
again;
begin
 setlength(hova,0);
 again:
 if eof(fil) then
 begin
  iseof:=true;
  exit;
 end;

 mxsig := madx_read (@in_buffer[0], @out_buffer[0], mxhouse, mxstat );

 if (mxsig = ERROR_OCCURED) then
 begin
  iseof:=true;

  exit;
 end;

  if (mxsig = MORE_INPUT) then		// Fill buffer
  begin
   if (mxstat.buffstart<>nil)	then
   begin
    blockread(fil,mxstat.buffstart^,mxstat.readsize,a);
    if a<>mxstat.readsize then
  //   if eof(fil) then
     begin
      mxstat.is_eof := 1;
      mxstat.readsize := a;
      iseof:=true;
     end
   //  else
    //  exit
   end
   else
   begin
    blockread(fil,in_buffer[0],mxstat.readsize,a);
    if a<>mxstat.readsize then
   //  if eof(fil) then
     begin
      mxstat.is_eof := 1;
      mxstat.readsize := a;
      iseof:=true;
     end
   //  else
   //   exit
   end;
  end;

   if (mxsig = FLUSH_BUFFER) or (mxsig = EOF_REACHED) then	// Output to file
   begin
     samplerate:=(Pinteger(Dword(mxhouse)+84))^;  //hát igen, ez a lusta megoldás
     setlength(hova,mxstat.write_size shr 1);
     copymemory(@hova[0], @out_buffer[0],mxstat.write_size);
     if (mxsig = EOF_REACHED) then iseof:=true;
     exit;
   end;
  goto again

end;



destructor Tmp3file.destroy;
begin
 closefile(fil);
 madx_deinit(mxhouse);
 freemem(mxhouse);
 freemem(pnagybuf);
 inherited;
end;


//////////////////////////////////////////////////////
////////--------MP3STREAM------------////////////////
//////////////////////////////////////////////////////



constructor TMP3Stream.create(url:string);
const
maxwait = 3000;
maxheadsiz = 4*1024;
var
 strhost,strport,strfil:string;
 incim:Tincim;
 srvc:sockaddr_in;
 mit:shortstring;
 tmp:dword;
 tmpchr:char;
 recvd:integer;
 elsostr:boolean;
 headsiz:integer;
 headwait:integer;
begin
 inherited create;
 //writeln(logfile,'madx crt1');flush(logfile);
 error:=1;

 getmem(mxhouse,256*1024); //Ez se lehet több fél megánál
 zeromemory(mxhouse,256*1024);
 zeromemory(@out_buffer[0],sizeof(out_buffer));
 zeromemory(@in_buffer[0],sizeof(in_buffer));

 madx_init(@out_buffer[0],mxhouse);

 zeromemory(@mxstat,sizeof(mxstat));

 mxsig:=CALL_AGAIN;

 strhost:=copy(url,pos('://',url)+3,1000);
 strport:=copy(strhost,pos(':',strhost)+1,1000);
 if pos('/',strport)>0 then
  strport:=copy(strport,1,pos('/',strport)-1);
 if strport='' then strport:='8000';

 if pos('/',strhost)>0 then
  strfil:=copy(strhost,pos('/',strhost),1000)
 else
  strfil:='/';
 strhost:=copy(strhost,1,pos(':',strhost)-1);


 gethostbynamewrap2(strhost,@(incim.sin_addr),false);
 incim.sin_port:=htons(strtoint(strport));

 sck:=socket(AF_INET,SOCK_STREAM, IPPROTO_TCP);
 srvc:=incimtosockaddr(incim);
// writeln(logfile,'madx crt1a');flush(logfile);
 tmp:=gettickcount;
 if SOCKET_ERROR=connectwithtimeout(sck,@srvc,sizeof(srvc),3) then
 begin
//  writeln(logfile,'navégre ',gettickcount-tmp); flush(logfile);
   exit;
 end;
 // writeln(logfile,'madx crt1b');flush(logfile);
 tmp:=0;
 ioctlsocket(sck, FIONBIO, tmp);

// writeln(logfile,'madx crt1c');flush(logfile);
 mit:='GET '+strfil+' HTTP/1.0'#13#10;
  send(sck,mit[1],length(mit),0);
 //0d 0a
  mit:='Host: '+strhost+#13#10;
  send(sck,mit[1],length(mit),0);
  mit:='Accept: */*'#13#10;
  send(sck,mit[1],length(mit),0);
  mit:='User-Agent: Stickman Warfare Radio'#13#10;
  send(sck,mit[1],length(mit),0);
  mit:='Icy-MetaData:0'#13#10;
  send(sck,mit[1],length(mit),0);
  mit:='Connection: close'#13#10;
  send(sck,mit[1],length(mit),0);
  mit:=#13#10;
  send(sck,mit[1],length(mit),0);


 tmp:=0;
 ioctlsocket(sck, FIONBIO, tmp);

 elsostr:=true;
 mit:='';
 headwait:=gettickcount;
 headsiz:=0;
 nev:='Unnamed radio';
 repeat
  recvd:=recv(sck,tmpchr,1,0);
  inc(headsiz);
  mit:=mit+tmpchr;
  if (mit[length(mit)-1]=#13) and (mit[length(mit)]=#10) then
  begin
   if elsostr and (pos('200',mit)=0) then exit;
   if length(mit)=2 then break;

   if lowercase(copy(mit,1,8))='icy-name' then
    nev:=copy(mit,10,length(mit)-11);

   mit:='';
   elsostr:=false;
  end;
  if headwait+maxwait<integer(gettickcount) then begin recvd:=0; break; end;
  if headsiz>maxheadsiz then break;
 until recvd<=0;


 if recvd<=0 then
  error:=1
 else
  error:=0;

 // writeln(logfile,'madx crt2');flush(logfile);
end;

procedure TMP3Stream.read(var hova:Tsmallintdynarr);
var
a:integer;
label
again;
begin
 setlength(hova,0);
 again:
 if error>0 then exit;
// if mxsig=CALL_AGAIN then
  mxsig := madx_read (@in_buffer[0], @out_buffer[0], mxhouse, mxstat );

 if (mxsig = ERROR_OCCURED) then
 begin
  error:=5;
  exit;
 end;

  if (mxsig = MORE_INPUT) then		// Fill buffer
  begin
  // a:=mxstat.readsize;
   if (mxstat.buffstart<>nil)	then
   begin
    a:=recvall(sck,mxstat.buffstart^,mxstat.readsize,3000);
    if a<>mxstat.readsize then
     begin
      mxstat.is_eof := 1;
      mxstat.readsize := a;
      error:=2;
     end
   end
   else
   begin
    a:=recvall(sck,in_buffer[0],mxstat.readsize,3000);
    if a<>mxstat.readsize then
     begin
      mxstat.is_eof := 1;
      mxstat.readsize := a;
      error:=2;
     end
   end;
   mxsig:=CALL_AGAIN;
  end;

   if (mxsig = FLUSH_BUFFER) or (mxsig = EOF_REACHED) then	// Output to file
   begin                                 
     samplerate:=(Pinteger(Dword(mxhouse)+84))^;  //hát igen, ez a lusta megoldás
     setlength(hova,mxstat.write_size shr 1);
     copymemory(@hova[0], @out_buffer[0],mxstat.write_size);
     if (mxsig = EOF_REACHED) then error:=3;
     mxsig:=CALL_AGAIN;
     exit;
   end;
 goto again;
end;



destructor TMP3Stream.destroy;
begin
 //writeln(logfile,'madx dest1');flush(logfile);
 closesocket(sck);
 madx_deinit(mxhouse);
 freemem(mxhouse);
 freemem(pnagybuf);
 //writeln(logfile,'madx dest2');flush(logfile);
 inherited;
end;


end.
