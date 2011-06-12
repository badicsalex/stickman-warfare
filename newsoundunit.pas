unit newsoundunit;

{.$DEFINE nosound}

interface
uses
  MMSystem,
  windows,
  math,
  sysutils,
  DSUtil,
  DirectSound,
  direct3d9,
  d3dx9,
  speex,
  typestuff,
  MADXDllinterface,
  DXErr9,
   ActiveX;

const
 DefSmpRt= 16000;
 vDefsmprt:integer=Defsmprt;
 MAX_PLAYING_BUFFERS=15;
type

 TCombinedSoundBuffer = record
  DSBuf,effbuf:IDirectSoundBuffer8;
  DS3D,eff3d:IDirectSound3DBuffer8;
  FX:IDirectSoundFXI3DL2Reverb;
  FXdesc:DSEFFECTDESC;
  FXhibaszar:cardinal;
  id:cardinal;
  typ:integer;
  pos:TD3DXVector3;
  tav:single;
  state:byte;
  played:cardinal;
  epmd:single;
  hangero:single;
 end;  

 T3DSoundStream = record
  DSbuf:IDirectSoundBuffer;
  DS3D:IDirectSound3DBuffer8;
  id:cardinal;
  played:cardinal;
  playing:boolean;
  bufferbytes:integer;
  lastwrite,lastpos:cardinal;
  buffered:Tsmallintdynarr;
 end;


 TMemoryBuffer = record
  format:TWaveFormatex;
  caps:DSBCaps;
  mindis:single;
  data:pointer;
 end;

 TDSCapture = class(Tobject)
 protected
  DScapture:IDirectSoundCapture;
  buf:IDirectSoundCaptureBuffer;
 public
  captured:Tsmallintdynarr;
  lastread:cardinal;
  constructor Create;
  destructor destroy;override;
  procedure start;
  procedure update;
  procedure stop;
 end;

 TSpeexEncoder = class(Tobject)
 protected
  framesize:integer;
  encbits: TSpeexBits;
  encstate,prepstate: Pointer;
  
 public
  innerbuf:Tsmallintdynarr;
  datasize:integer;
  constructor Create;
  destructor destroy;override;
  procedure encode(const mit:Tsmallintdynarr);
  procedure getdata(var hova:Tbytearr);
 end;

 TSpeexDecoder = class(Tobject)
 protected
  framesize:integer;
  decbits: TSpeexBits;
  decstate: Pointer;
 public
  lastused:cardinal;
  constructor Create;
  destructor destroy;override;
  procedure Decode(const mit:Tbytearr;var decoded:Tsmallintdynarr);
  procedure NeedData(var decoded:Tsmallintdynarr);
 end;

function InitSound(hwindow:HWND):Hresult;
procedure PlaySound(mit:integer;loop:boolean;aid:cardinal;effects:boolean;hol:TD3DXVector3);
                                                       //1,1, ha nem érdekes...            Vec3Zero ha nem érdekes
procedure SetSoundProperties(mit:integer; aid:cardinal;vol:longint;freq:cardinal;effects:boolean;hol:TD3DXVector3);
procedure SetSoundVelocity(mit:integer; aid:cardinal;vel:TD3DXVector3);

procedure WriteToStreamBuffered(aid:integer;const mit:Tsmallintdynarr;samplerate:integer = 0;vol:integer =0);
function  WriteToStream(aid:integer;hely:TD3DXVector3;const mit:Tsmallintdynarr;samplerate:integer = 0;vol:integer =0;channels:integer = 0):boolean;
procedure WriteToStreamSmallAmounts(aid:integer;var mit:Tsmallintdynarr;samplerate:integer = 0;vol:integer =0;channels:integer = 0);
function StopStream(aid:integer):boolean;

procedure LoadStrm(fnev:string);
procedure PlayStrm(mit:integer;aid:integer;vol:integer=0;onlycreate:boolean=false);

procedure StopSound(mit:integer; aid:cardinal);
procedure LoadSound(fnev:string;haromd,freq,effects:boolean;mindistance:single);
procedure PlaceListener(vec:TD3DXvector3;szogx,szogy:single);
procedure StopAll;
procedure MainVolume(vol:single);
procedure CommitDeferredSoundStuff;
procedure CloseSound;
procedure zeneinit;
function zenefresh(volp:Pointer):integer;
procedure zenecleanup;


const
unitname='sound';

wfx:TWaveformatex=
   (wFormatTag: WAVE_FORMAT_PCM;         { format type }
    nChannels: 1;          { number of channels (i.e. mono, stereo, etc.) }
    nSamplesPerSec: Defsmprt;  { sample rate }
    nAvgBytesPerSec: Defsmprt*2; { for buffer estimation }
    nBlockAlign: 2;      { block size of data }
    wBitsPerSample: 16;   { number of bits per sample of mono data }
    cbSize: sizeof(TWaveformatex));
var
 mp3filelist:array of string;
 mp3strms:array [0..2] of array of string;
 mp3strmp:array [0..2] of integer;
 mp3strmp2:integer;
 mp3strmpvalts:boolean;
 mp3action,mp3ambient,mp3car:boolean;
 mp3stationname:string;

 mp3pos:integer;
 lastsoundaction:string;
 bufPlaying:array of TCombinedSoundBuffer;
 bufplayingcount,playsoundcount,stopsoundcount,specialcreatecount:integer;
 streams:array of T3DSoundStream;
 zenebuffer:Tsmallintdynarr;


implementation
{const
testpreset:TDSFXWavesReverb=
 ( fInGain:0;
    fReverbMix:-5;
    fReverbTime:2000;
    fHighFreqRTRatio: 0); }
const
BUFFERSTATUS_STOPPED=0;
BUFFERSTATUS_PLAYING=1;
BUFFERSTATUS_QFORPLAY=2;
//BUFFERSTATUS_QFORDELETE=3;
BUFFERSTATUS_QFORPLAYLOOPED=4;
BUFFERSTATUS_QFORSTOP=5;
var
  DS:IDirectsound8;

  DSBuf1: IDirectSoundBuffer;

  bufLoaded, strmLoaded:array of TMemoryBuffer;

  listener:IDirectSound3DListener;
  listenerpos:TD3DXVector3;
  effparam:TDSFXI3DL2REVERB=
  ( lRoom: 000;                  // [-10000, 0]      default: -1000 mB
    lRoomHF: 0000;                // [-10000, 0]      default: 0 mB
    flRoomRolloffFactor: 0;     // [0.0, 10.0]      default: 0.0
    flDecayTime: 0.5;             // [0.1, 20.0]      default: 1.49s
    flDecayHFRatio: 0.83;          // [0.1, 2.0]       default: 0.83
    lReflections: -1000;           // [-10000, 1000]   default: -2602 mB
    flReflectionsDelay: 0.003;      // [0.0, 0.3]       default: 0.007 s
    lReverb: -1000;                // [-10000, 2000]   default: 200 mB
    flReverbDelay: 0.1;           // [0.0, 0.1]       default: 0.011 s
    flDiffusion: 50;             // [0.0, 100.0]     default: 100.0 %
    flDensity: 20;               // [0.0, 100.0]     default: 100.0 %
    flHFReference: 5000;           // [20.0, 20000.0]  default: 5000.0 Hz)
  );
  //zene
  zene2:Tmp3file;
  zene3:Tmp3stream;
  zenestrm:cardinal;

function korbekozott(a,b,x:cardinal):boolean;
begin
 result:=((a<b) and ((a<x) and (b>x))) or
         ((a>b) and ((b>x) or  (a<x)));
end;



procedure zeneinit;
var
rnd:integer;
tmp:string;
i:integer;
begin
 if DS=nil then exit;


 if high(mp3filelist)<0 then exit;

 for i:=0 to high(mp3filelist) do
 begin
  rnd:=random(length(mp3filelist)-i)+i;
  tmp:=mp3filelist[i];
  mp3filelist[i]:=  mp3filelist[rnd] ;
  mp3filelist[rnd]:=tmp;
 end;
 mp3pos:=0;
 zene2:= Tmp3file.create(mp3filelist[random(length(mp3filelist))]);
 zenestrm:=gettickcount;
 setlength(zenebuffer,0);
end;

procedure zenecleanup;
begin
 if DS=nil then exit;
   if high(mp3filelist)<0 then exit;
 zene2.destroy;
end;

var
 zenethdvege:boolean=true;

function zenefreshthd(nulla:Pointer):integer;
var
i:integer;
tmp:string;
rnd:integer;
tmpbuffer:Tsmallintdynarr;
lngt:integer;
begin
 result:=1;
 if DS=nil then exit;

 if high(mp3filelist)<0 then
 begin
  if ((mp3strmp2=1) and mp3action) or
     ((mp3strmp2=0) and mp3ambient) or
     ((mp3strmp2=2) and mp3car) then
  begin

   if mp3strmpvalts or (zene3=nil) then
    mp3stationname:='Tuning in...'
   else
    mp3stationname:=zene3.nev;

   if zene3=nil then
   begin
    zene3:=Tmp3stream.create(mp3strms[mp3strmp2,mp3strmp[mp3strmp2]]);
    zenestrm:=gettickcount;
   end;

   if mp3strmpvalts then
   begin
    setlength(zenebuffer,0);
    if zene3<>nil then
    zene3.destroy;
    stopstream(zenestrm);
    zene3:=Tmp3stream.create(mp3strms[mp3strmp2,mp3strmp[mp3strmp2]]);
    zenestrm:=gettickcount;
    mp3strmpvalts:=false;
   end;

  for i:=0 to 1 do
  begin
   setlength(tmpbuffer,0);
   zene3.read(tmpbuffer);
   lngt:=length(zenebuffer);
   if length(tmpbuffer)>0 then
   begin
    setlength(zenebuffer,lngt+length(tmpbuffeR));
    copymemory(@(zenebuffer[lngt]),@(tmpbuffer[0]),length(tmpbuffeR)*sizeof(smallint));
   end;

   if zene3.error>0 then
   begin
    mp3stationname:='Tune error '+inttostr(zene3.error);
    mp3strmpvalts:=true;
    if mp3strmp[mp3strmp2]<high(mp3strms[mp3strmp2]) then
     inc(mp3strmp[mp3strmp2])
    else
     mp3strmp[mp3strmp2]:=0;
   end;

  end;
 end;
 setlength(tmpbuffer,0);
 
 end
 else
 begin


 if zene2=nil then
  zeneinit;


 for i:=0 to 1 do
 begin
  setlength(tmpbuffer,0);
  zene2.read(tmpbuffer);
  lngt:=length(zenebuffer);
  if length(tmpbuffer)>0 then
  begin
   setlength(zenebuffer,lngt+length(tmpbuffeR));
   copymemory(@(zenebuffer[lngt]),@(tmpbuffer[0]),length(tmpbuffeR)*sizeof(smallint));
  end;
 end;
 setlength(tmpbuffer,0);
 if zene2.iseof then
 begin
  setlength(zenebuffer,0);
  rnd:=random(length(mp3filelist));
  tmp:=mp3filelist[mp3pos];
  mp3filelist[mp3pos]:=  mp3filelist[rnd];
  mp3filelist[rnd]:=tmp;
  if mp3pos<high(mp3filelist) then inc(mp3pos) else mp3pos:=0;
  zene2.destroy;
  zene2:= Tmp3file.create(mp3filelist[mp3pos]);
  zenestrm:=gettickcount+random(1000);
 end;
 end;
 result:=0;
 zenethdvege:=true;
end;

var
 zenethdid:cardinal;

function zenefresh(volp:Pointer):integer;
var
mire:single;
vol:single;
begin
 result:=0;

 if DS=nil then exit;

 //if high(mp3filelist)<0 then exit;                                 

 if not zenethdvege then exit;

 vol:=Psingle(volp)^;
 if vol<=0 then mire:=0 else
  mire:=(vol-1)*5000;

 if zene2<>nil then
  WritetostreamSmallAmounts(zenestrm,zenebuffer,zene2.samplerate,round(mire),2)
 else
 if zene3<>nil then
   begin
   if mp3strmp2=0 then mire:=mire-500;
   WritetostreamSmallAmounts(zenestrm,zenebuffer,zene3.samplerate,round(mire),2);
  end;

 if length(zenebuffer)<22000 then
 begin
  zenethdvege:=false;
  beginthread(nil,0,zenefreshthd,nil,0,zenethdid);
 end;

 result:=0;
end;


//SOUND INNENTÕL LEFELÉ!!!!!!!


function Loadbuf(var buf:Tmemorybuffer;flags:cardinal;fnev:string):Hresult;
var
mfile:Cwavefile;
pwfx:PWaveFormatex;
plb2: PChar;
dwWavDataRead: DWORD;
osszread:integer;
begin
 Result:= E_FAIL;
 if DS=nil then exit;

 mFile:=Cwavefile.Create;
 pwfx:=nil;
 //getmem(pwfx,sizeof(Twaveformatex));
 mfile.Open(Pchar(fnev),pwfx,WAVEFILE_READ);
  mfile.ResetFile;
 zeromemory(@buf.caps,sizeof(buf.caps));
 buf.caps.dwSize:=sizeof(buf.caps);
 //if (flags and  DSBCAPS_CTRL3d)<>0 then flags:=(flags xor  DSBCAPS_CTRL3d);
 if (flags and  DSBCAPS_CTRLFX)<>0 then
  buf.caps.dwFlags:=DSBCAPS_CTRLVOLUME  or  flags
 else
  buf.caps.dwFlags:=DSBCAPS_CTRLVOLUME  or DSBCAPS_STATIC or flags;
 buf.caps.dwBufferBytes:=mfile.m_dwSize;

 zeromemory(@buf.format,sizeof(buf.format));
 copymemory(@buf.format,mfile.m_pwfx,sizeof(buf.format));

 getmem(buf.data,buf.caps.dwBufferBytes);


 plb2:=buf.data;
 osszread:=0;
 repeat
 mfile.Read(pbyte(plb2),
                             mfile.m_dwSize-osszread,
                             @dwWavDataRead);
 plb2:=plb2+dwWavdataread;
 osszread:=osszread+dwWavDataRead;
 until (0=dwWavDataRead) or (buf.caps.dwBufferBytes<=osszread);
 mfile.Destroy;
 Result:= S_OK;
end;

function InitSound(hwindow:HWND):Hresult;
var
adesc:_DSbufferdesc;
hib:HRESULT;
begin
 result:=E_FAIL;
 coinitialize(nil);
 if failed(directsoundcreate8(nil,DS,nil)) then exit;
 if failed(DS.SetCooperativeLevel(hwindow,DSSCL_PRIORITY)) then exit;
// if failed(DS.Initialize(nil)) then exit;
 zeromemory(@adesc,sizeof(adesc));
 adesc.dwSize:=sizeof(adesc);
 adesc.dwFlags:=DSBCAPS_PRIMARYBUFFER or DSBCAPS_CTRL3D or DSBCAPS_CTRLVOLUME;

 hib:=DS.CreateSoundBuffer(adesc,DSBuf1,nil);
 if failed(hib)then exit;

 DSBuf1.QueryInterface(IID_IDirectSound3DListener, listener);
 DSBuf1.SetVolume(0);
 Result:=S_OK;

end;


procedure LoadSound(fnev:string;haromd,freq,effects:boolean;mindistance:single);
var
flags:cardinal;
begin
 if DS=nil then exit;
 //effects:=false;
 setlength(bufLoaded,length(bufLoaded)+1);
 zeromemory(@bufloaded[high(bufLoaded)],sizeof(TMemorybuffer));
 flags:=0;
 if haromd  then flags:=flags or DSBCAPS_CTRL3D or DSBCAPS_MUTE3DATMAXDISTANCE;
 if freq    then flags:=flags or DSBCAPS_CTRLFREQUENCY;
 //if effects then flags:=flags or DSBCAPS_CTRLFX;
 loadbuf(bufloaded[high(bufLoaded)],flags,'data\snd\'+fnev+'.wav');
 bufloaded[high(bufLoaded)].mindis:=mindistance;
end;

procedure LoadStrm(fnev:string);
begin
  if DS=nil then exit;
 setlength(strmLoaded,length(strmLoaded)+1);
 zeromemory(@strmLoaded[high(strmLoaded)],sizeof(TMemorybuffer));
 loadbuf(strmLoaded[high(strmLoaded)],DSBCAPS_CTRLVOLUME,'data\snd\rad\'+fnev+'.wav');
end;

procedure StopAll;
var
i:integer;
begin
 if DS=nil then exit;
  for i:=0 to high(bufPlaying) do
 begin
  if bufPlaying[i].DSBuf<>nil then bufPlaying[i].DSBuf.Stop;
  if bufPlaying[i].effBuf<>nil then bufPlaying[i].effBuf.Stop;
 end;
 for i:=0 to high(streams) do
 begin
  if streams[i].DSBuf<>nil then streams[i].DSBuf.Stop;
 end;
end;

procedure closesound;
var
i:integer;
begin

stopall;
for i:=0 to high(bufPlaying) do
 begin
  if bufPlaying[i].DS3D <>nil then bufPlaying[i].DS3D:=nil;
  if bufPlaying[i].DSbuf<>nil then bufPlaying[i].DSbuf:=nil;
  if bufPlaying[i].effbuf<>nil then bufPlaying[i].effbuf:=nil;
 end;

for i:=0 to high(streams) do
 begin
  if streams[i].DS3D <>nil then streams[i].DS3D:=nil;
  if streams[i].DSbuf<>nil then streams[i].DSbuf:=nil;
 end;

{$IFNDEF kurvaDELPHIFOS}
  for i:=0 to high(bufLoaded) do
 begin
  if bufLoaded[i].data<>nil then freemem(bufLoaded[i].data,bufloaded[i].caps.dwBufferBytes);
 end;
 setlength(bufplaying,0);
 setlength(bufloaded ,0);
{$ENDIF}
 //if zenefil<>nil then zenefil.Destroy;
 //if zenebuf<>nil then zenebuf:=nil;
 //ds:=nil;
end;

procedure PlaceListener(vec:TD3DXvector3;szogx,szogy:single);
var
vb,ve,vn:TD3DXvector3;
begin
 if DS=nil then exit;
 if listener=nil then exit;
 listener.SetPosition(vec.x,vec.y,vec.z,DS3D_DEFERRED);
 listenerpos:=vec;
 ve:=D3DXVector3(sin(szogx)*cos(szogy),sin(szogy),cos(szogx)*cos(szogy));
 vb:=D3DXVector3(ve.z,0,-ve.x);
 d3dxvec3cross(vn,ve,vb);
 d3dxvec3normalize(vb,vn);
 d3dxvec3normalize(ve,ve);
 listener.SetOrientation(ve.x,ve.y,ve.z,vb.x,vb.y,vb.z,DS3D_DEFERRED);

end;

procedure AddEffects(mi:integer);
var
hib:HRESULT;
caps:_DSBCaps;
begin
 exit;
 lastsoundaction:=lastsoundaction+'-and-AddEffects( typ:'+inttostr(bufplaying[mi].typ)+')';
 with bufPlaying[mi] do
 begin
  if effbuf=nil then exit;
  if FX<>nil then exit;
  caps.dwSize:=sizeof(caps);
  effbuf.getcaps(caps);
  effbuf.stop;
  if (caps.dwFlags and DSBCAPS_CTRLFX)=0 then exit;


  FXdesc.dwSize:=(sizeof(FXdesc));
  FXdesc.dwFlags:=0;

  FXdesc.guidDSFXClass:=GUID_DSFX_STANDARD_I3DL2REVERB;

  FXdesc.dwReserved1:=0;
  FXdesc.dwReserved2:=0;
                                              
  hib := effbuf.SetFX(1,@FXdesc,nil);
  if FAILED(hib) or FAILED(FXhibaszar) then Exit;

  if effbuf<>nil then
  hib := effbuf.GetObjectInPath(FXdesc.guidDSFXClass, 0,IDirectSoundFXI3DL2Reverb, FX);
  if FAILED(hib) then
  begin FX:=nil;   exit; end;

  FX.SetQuality(DSFX_I3DL2REVERB_QUALITY_MIN);
  FX.SetAllParameters(effparam);

 end;
end;

                                                //1, ha nem érdekel  itt meg 0
procedure SetSoundProperties(mit:integer; aid:cardinal;vol:longint;freq:cardinal;effects:boolean;hol:TD3DXVector3);
var
mi:integer;
i:integer;
begin
 if DS=nil then exit;
//   effects:=false;
constraintvec(hol);
lastsoundaction:='SetSoundProperties('+inttostr(mit)+','+inttostr(aid)+')';
 mi:=-1;
 for i:=0 to high(bufPlaying) do
  if (bufPlaying[i].typ=mit) and (bufPlaying[i].id=aid) then
  begin
   mi:=i;
   break;
  end;
  
 if mi=-1 then exit;

 if (bufPlaying[mi].state=BUFFERSTATUS_STOPPED) or
    (bufPlaying[mi].state=BUFFERSTATUS_QFORSTOP) then exit;
 with bufPlaying[mi] do
 begin
  if DSBuf=nil then exit;

  if freq<>1 then
   DSbuf.SetFrequency(freq);

  if vol<>1 then
   DSbuf.SetVolume(vol);

  if DS3d<>nil then
  if (hol.y<>0) or (hol.x<>0) or (hol.z<>0) then
  begin
   DS3D.SetPosition(hol.x,hol.y,hol.z,DS3D_DEFERRED) ;
   pos:=hol;
   tav:=tavpointpointsq(pos,listenerpos)*hangero;
  end;

  if effbuf=nil then exit;

  if freq<>1 then
   effbuf.SetFrequency(freq);

  if vol<>1 then
   effbuf.SetVolume(vol);

  if eff3d<>nil then
  if (hol.y<>0) or (hol.x<>0) or (hol.z<>0) then
   eff3D.SetPosition(hol.x,hol.y,hol.z,DS3D_DEFERRED)

 end;
end;

procedure SetSoundVelocity(mit:integer; aid:cardinal;vel:TD3DXVector3);
var
mi:integer;
i:integer;
begin
 if DS=nil then exit;

constraintvec(vel);
lastsoundaction:='SetSoundVelocity('+inttostr(mit)+','+inttostr(aid)+')';
 mi:=-1;
 for i:=0 to high(bufPlaying) do
  if (bufPlaying[i].typ=mit) and (bufPlaying[i].id=aid) then
  begin
   mi:=i;
   break;
  end;
  
 if mi=-1 then exit;

 //if bufPlaying[mi].state=BUFFERSTATUS_QFORDELETE then exit;
 with bufPlaying[mi] do
 begin
  if DSBuf=nil then exit;
  if DS3d<>nil then
    DS3D.SetVelocity(vel.x,vel.y,vel.z,DS3D_DEFERRED) ;
 end;
end;

procedure SpecialDuplicate(mirol:TMemoryBuffer; var mire:IDirectSoundBuffer8);
var
caps:_DSBCaps;
desc:_DSBufferDesc;
format:TWaveformatex;
LockedBuffer1,LockedBuffer2:Pointer;
LBSize1,LBSize2:Dword;
hib:HRESULT;
ass:cardinal;
begin
 if DS=nil then exit;
 mire:=nil;
 if mirol.data=nil then exit;

 inc(specialcreatecount);
 caps:=mirol.caps;
 format:=mirol.format;
                                 
 zeromemory(@desc,sizeof(desc));
 desc.dwSize:=sizeof(desc);
 desc.dwFlags:=caps.dwFlags and (DSBCAPS_CTRLVOLUME  or DSBCAPS_CTRL3D or DSBCAPS_CTRLFREQUENCY{ or DSBCAPS_CTRLFX});
 desc.lpwfxFormat:=@format;
 //desc.dwBufferBytes:=max(caps.dwBufferBytes,format.nAvgBytesPerSec*2);
 desc.dwBufferBytes:=caps.dwBufferBytes;

 hib:=DS.CreateSoundBuffer(desc,IDirectSoundBuffer(mire),nil);
 if FAILED(hib) then exit;

  if FAILED(mire.Lock(0, desc.dwBufferBytes,
                      @LockedBuffer2, @LBsize2, @lockedbuffer1, @LBsize1, DSBLOCK_ENTIREBUFFER)) then exit;
 ass:=min(LBsize2,caps.dwBufferBytes);
 copymemory(lockedbuffer2,mirol.data,ass);

{ if (LBsize2>ass) then
  zeromemory(pointer(cardinal(lockedbuffer2)+ass),LBSize2-ass); }
 mire.Unlock(LockedBuffer2, LBsize2, LockedBuffer1, LBSize1);
end;

                                                                                                                                          //ha megtelt, true
function WriteToStream(aid:integer;hely:TD3DXVector3;const mit:Tsmallintdynarr;samplerate:integer = 0;vol:integer =0;channels:integer = 0):boolean;
var
 i:integer;
 hol:integer;
 desc:_DSBufferDesc;
 writepos,playpos:cardinal;
 writing:integer;
 LB1,LB2:Psmallintarray;
 lbs1,lbs2:cardinal;
 wfx2:TWaveformatex;
begin
  result:=false;
 if DS=nil then exit;

  if length(mit)=0 then exit;
  hol:=-1;
  for i:=0 to high(streams) do
   if (streams[i].id=aid) then
    hol:=i;

  if hol<0 then
  begin
   setlength(streams,length(streams)+1);
   with streams[high(streams)] do
   begin
    id:=aid;
    playing:=false;
    lastpos:=0;
    lastwrite:=0;
    zeromemory(@desc,sizeof(desc));
    desc.dwSize:=sizeof(desc);
    desc.dwFlags:=DSBCAPS_GLOBALFOCUS;

    if (hely.y<>0) and (hely.x<>0) and (hely.z<>0) then
     desc.dwFlags:=desc.dwFlags or DSBCAPS_CTRL3D;

    if vol<>0 then
     desc.dwFlags:=desc.dwFlags or DSBCAPS_CTRLVOLUME;

    wfx2:=wfx;

    if samplerate<>0 then
     wfx2.nSamplesPerSec:=samplerate;
    if channels<>0 then
     wfx2.nchannels:=channels;

    wfx2.nAvgBytesPerSec:=wfx2.nSamplesPerSec*2*wfx2.nChannels;
    wfx2.nBlockalign:=2*wfx2.nChannels;
    desc.lpwfxFormat:=@wfx2;
    bufferbytes:=wfx2.nAvgBytesPerSec*3;
    desc.dwBufferBytes:=bufferbytes;
   
    if DS=nil then exit;
    DS.CreateSoundBuffer(desc,DSBuf,nil);



    if DSbuf<>nil then
    begin
     DSBuf.QueryInterface(IID_IDirectSound3DBuffer, DS3D);
     if DS3D <> nil then
     begin
      DS3D.SetMinDistance(1,DS3D_DEFERRED);
      DS3D.SetMaxDistance(50,DS3D_DEFERRED);
     end
    end;
   end;
   hol:=high(streams);
  end;

 with streams[hol] do
 begin
  if DSbuf=nil then exit;

  if vol<>0 then
     DSBuf.SetVolume(vol);

  DSbuf.GetCurrentPosition(@playpos,@writepos);

 { if korbekozott(lastwrite,(lastwrite+length(mit)*2) mod bufferbytes,(playpos +bufferbytes shr 1) mod bufferbytes) then
  begin
   result:=true;
   exit;
  end; //}

  if korbekozott(lastwrite,(lastwrite+length(mit)*2) mod bufferbytes,playpos)
  or  korbekozott(lastwrite,(lastwrite+length(mit)*2) mod bufferbytes,lastpos)
      then
  begin
   //lastwrite:=writepos;
   result:=true;
   exit;
  end;


 { if korbekozott(lastwrite,(lastwrite+length(mit)*2) mod bufferbytes,writepos) then
   lastwrite:=writepos; }

  played:=gettickcount;
  DSbuf.Lock(lastwrite,length(mit)*2,@LB1,@lbs1,@lb2,@lbs2,0);
  writing:=0;
  if LB1<>nil then
  begin
   copymemory(LB1,@mit[writing shr 1],lbs1);
   inc(writing,lbs1);
  end;

  if LB2<>nil then
  begin
   copymemory(LB2,@mit[writing shr 1],lbs2);
   inc(writing,lbs2);
  end;

  inc(lastwrite,writing);

  DSBuf.Unlock(LB1,lbs1,lb2,lbs2);


  if lastwrite>=bufferbytes then lastwrite:=lastwrite-bufferbytes;

  if not playing then
  DSBuf.Play(0,0,DSBPLAY_LOOPING);
  if DS3d<>nil then
   DS3D.SetPosition(hely.x,hely.y,hely.z,DS3D_DEFERRED);

 end;

end;

function StopStream(aid:integer):boolean;
var
 i:integer;
 hol:integer;
begin
  result:=false;
 if DS=nil then exit;

  hol:=-1;
  for i:=0 to high(streams) do
   if (streams[i].id=aid) then
    hol:=i;

  if hol<0 then exit;

 with streams[hol] do
 begin
  if DSbuf=nil then exit;
  DSBuf.Stop;
 end;

end;
procedure WriteToStreamSmallAmounts(aid:integer;var mit:Tsmallintdynarr;samplerate:integer = 0;vol:integer =0;channels:integer = 0);
var
 tmp:Tsmallintdynarr;
 i:integer;
begin

// repeat
  if (length(mit)<=0) then exit;
  if samplerate=0 then
   i:=min(length(mit),22000 div 4)
  else
   i:=min(length(mit),samplerate div 4);
  setlength(tmp,i);
  copymemory(@tmp[0],@mit[0],length(tmp)*sizeof(smallint));
  if writetostream(aid,d3dxvector3zero,tmp,samplerate,vol,channels) then exit;

  for i:=0 to high(mit)-length(tmp) do
  // if (i+length(tmp))<=high(mit) then
    mit[i]:=mit[i+length(tmp)];

  setlength(mit,max(length(mit)-length(tmp),0));
// until false;
end;


procedure WriteToStreamBuffered(aid:integer;const mit:Tsmallintdynarr;samplerate:integer = 0;vol:integer =0);
var
hol:integer;
tmp:Tsmallintdynarr;
i:integer;
ind:integer;
begin
if length(mit)=0 then exit;
 hol:=-1;
 for i:=0 to high(streams) do
  if (streams[i].id=aid) then
   hol:=i;
 if hol<0 then
 begin
  setlength(tmp,length(mit));
  copymemory(@tmp[0],@mit[0],length(mit)*sizeof(smallint));
  WriteToStreamSmallAmounts(aid,tmp,samplerate,vol);

  hol:=-1;
  for i:=0 to high(streams) do
   if (streams[i].id=aid) then
    hol:=i;
  if hol<0 then exit;
  setlength(streams[hol].buffered,length(tmp));
  for i:=0 to high(tmp) do
   streams[hol].buffered[i]:=tmp[i];

 end
 else
 begin
  ind:=length(streams[hol].buffered);
  setlength(streams[hol].buffered,length(streams[hol].buffered)+length(mit));
  for i:=0 to high(mit) do
   streams[hol].buffered[ind+i]:=mit[i];
 end;
 
   setlengtH(tmp,0)
end;

procedure delstream(i:integer);
begin

   if streams[i].DSBuf<>nil then
   begin
    streams[i].DSBuf.Stop;
   end;

   if streams[i].DS3D <>nil then streams[i].DS3D:=nil;
   if streams[i].DSbuf<>nil then streams[i].DSbuf:=nil;

   streams[i]:=streams[high(streams)];

   if streams[high(streams)].DS3D <>nil then streams[high(streams)].DS3D:=nil;
   if streams[high(streams)].DSbuf<>nil then streams[high(streams)].DSbuf:=nil;
   
   setlength(streams,high(streams));
end;

procedure PlayStrm(mit:integer;aid:integer;vol:integer=0;onlycreate:boolean=false);
var
tmp:Tsmallintdynarr;
i:integer;
cucc1:Psmallintarray;
cucc2:Pshortintarray;
begin

if DS=nil then exit;
if onlycreate then
 for i:=0 to high(streams) do
  if (streams[i].id=aid) then
  begin
   delstream(i);
   break;
  end;

if high(strmloaded)<=mit then exit;

if strmLoaded[mit].format.wBitsPerSample=8 then
begin
 setlength(tmp,strmLoaded[mit].caps.dwBufferBytes);
 cucc2:=strmloaded[mit].data;
 for i:=0 to high(tmp) do
  tmp[i]:=(cucc2[i]-128)*256;
end
else
begin
 setlength(tmp,strmLoaded[mit].caps.dwBufferBytes div 2);
 cucc1:=strmloaded[mit].data;
 for i:=0 to high(tmp) do
  tmp[i]:=cucc1[i];
end;

WritetostreamBuffered(aid,tmp,strmLoaded[mit].format.nSamplesPerSec,vol);
end;

                                      //1, ha nem érdekel  itt meg 0
procedure PlaySound(mit:integer;loop:boolean;aid:cardinal;effects:boolean;hol:TD3DXVector3);
var
i:integer;
atav:single;
max: single;
kisebbek,nagyobbak,maxhely:integer;
begin
 if DS=nil then exit;
  lastsoundaction:='Playsound('+inttostr(mit)+','+inttostr(aid)+')';

  effects:=false;
 {$IFDEF nosound}exit;{$ENDIF}
 if bufloaded[mit].mindis=0 then bufloaded[mit].mindis:=1;
 if (hol.y=0) and (hol.x=0) and (hol.z=0) then
  atav:=0
 else
  atav:=tavpointpointsq(hol,listenerpos)/bufloaded[mit].mindis;

 repeat
  max:=-1;
 maxhely:=-1;
 kisebbek:=0; nagyobbak:=0;
 for i:=0 to high(bufPlaying) do
  if (bufPlaying[i].state<>BUFFERSTATUS_STOPPED) and
     (bufPlaying[i].state<>BUFFERSTATUS_QFORSTOP)  then
  begin
   if bufPlaying[i].tav<=atav then inc(kisebbek) else inc(nagyobbak);
   if bufPlaying[i].tav>max then begin max:=bufPlaying[i].tav; maxhely:=i; end;
  end;

 if (kisebbek+nagyobbak)>max_playing_buffers then
  if nagyobbak=0 then exit
  else
   bufPlaying[maxhely].state:=BUFFERSTATUS_QFORSTOP;
 until (kisebbek+nagyobbak)<=max_playing_buffers;

  for i:=0 to high(bufPlaying) do
  if (bufPlaying[i].typ=mit) and (bufPlaying[i].id=aid) then
  begin

   if (bufPlaying[i].state<>BUFFERSTATUS_PLAYING) then
    if not loop then
  //   bufPlaying[i].state:=BUFFERSTATUS_QFORPLAYLOOPED
  //  else
     bufPlaying[i].state:=BUFFERSTATUS_QFORPLAY;
   bufPlaying[i].tav:=atav;
   BufPlaying[i].pos:=hol;
   SetSoundProperties(mit,aid,1,0,effects,hol);
   exit;
  end;
   
 for i:=0 to high(bufPlaying) do
  if (bufPlaying[i].typ=mit) and
     ((bufPlaying[i].state=BUFFERSTATUS_STOPPED) or (bufPlaying[i].state=BUFFERSTATUS_QFORSTOP))  then
  begin

   bufPlaying[i].id:=aid;

   if loop then
    bufPlaying[i].state:=BUFFERSTATUS_QFORPLAYLOOPED
   else
    bufPlaying[i].state:=BUFFERSTATUS_QFORPLAY;
   bufPlaying[i].tav:=atav;
   BufPlaying[i].pos:=hol;
   SetSoundProperties(mit,aid,1,0,effects,hol);
   exit;
  end;

  setlength(bufPlaying,length(bufPlaying)+1);

  with bufPlaying[high(bufPlaying)] do
  begin
   DSBuf:=nil;
   DS3D:=nil;
   effbuf:=nil;
   FX:=nil;
   id:=aid;
   typ:=mit;

   bufPlaying[high(bufPlaying)].tav:=atav;
    if loop then
     bufPlaying[high(bufPlaying)].state:=BUFFERSTATUS_QFORPLAYLOOPED
    else
     bufPlaying[high(bufPlaying)].state:=BUFFERSTATUS_QFORPLAY;
   SpecialDuplicate(bufLoaded[mit],DSBuf);
   if effects then
    SpecialDuplicate(bufLoaded[mit],effBuf);
   if DSbuf<>nil then
   begin
    DSBuf.QueryInterface(IID_IDirectSound3DBuffer, DS3D);
    if DS3D <> nil then
    begin
     DS3D.SetMinDistance(bufloaded[mit].mindis,DS3D_DEFERRED);
     DS3D.SetMaxDistance(300,DS3D_DEFERRED);
    end
   end;

   if effbuf<>nil then
   begin
    effBuf.QueryInterface(IID_IDirectSound3DBuffer, eff3D);
    if eff3D <> nil then
    begin
     eff3D.SetMinDistance(bufloaded[mit].mindis,DS3D_DEFERRED);
     eff3D.SetMaxDistance(500,DS3D_DEFERRED);
    end
   end;

   epmd:=1/bufloaded[mit].mindis;
   pos:=hol;
   tav:=atav;
   if (hol.y=0) and (hol.x=0) and (hol.z=0) then
    hangero:=0
   else
    hangero:=1/bufloaded[mit].mindis;
   SetSoundProperties(mit,aid,1,0,effects,hol);
   


  end;

end;

procedure StopSound(mit:integer; aid:cardinal);
var
mi:integer;
i:integer;
begin
 if DS=nil then exit;
 
 mi:=-1;
 for i:=0 to high(bufPlaying) do
  if (bufPlaying[i].typ=mit) and (bufPlaying[i].id=aid) then
  begin
   mi:=i;
   break;
  end;
  
 if mi=-1 then exit;

if BufPlaying[mi].state<>BUFFERSTATUS_STOPPED then
 BufPlaying[mi].state:=BUFFERSTATUS_QFORSTOP;
end;

procedure MainVolume(vol:single);
var
mire:single;
begin
 if vol<=0 then mire:=0 else
  mire:=(vol-1)*5000;
 if DS=nil then exit;
 if DSBuf1=nil then exit;
  DSbuf1.SetVolume(round(mire));
end;




procedure CommitDeferredSoundStuff;
var
i:integer;
stat:cardinal;
gtc:cardinal;
playpos:cardinal;
begin
 if DS=nil then exit;
 gtc:=gettickcount;
 bufplayingcount:=0;
 for i:=0 to high(bufPlaying) do
 begin
  if BufPlaying[i].DSbuf=nil then continue;

  if (BufPlaying[i].state=BUFFERSTATUS_QFORPLAY) or (BufPlaying[i].state=BUFFERSTATUS_QFORPLAYLOOPED) then
   begin
     if  BufPlaying[i].state=BUFFERSTATUS_QFORPLAY then
     begin
      BufPlaying[i].DSbuf.Stop;
      BufPlaying[i].DSbuf.SetCurrentPosition(0);
     end;
     addeffects(high(bufPlaying));
    inc(playsoundcount);
    if (BufPlaying[i].state=BUFFERSTATUS_QFORPLAYLOOPED) then
     BufPlaying[i].DSbuf.Play(0,0,DSBPLAY_LOOPING)
    else
     BufPlaying[i].DSbuf.Play(0,0,0);

    if BufPlaying[i].effbuf<>nil then
     if (BufPlaying[i].state=BUFFERSTATUS_QFORPLAYLOOPED) then
      BufPlaying[i].effbuf.Play(0,0,DSBPLAY_LOOPING)
     else
      BufPlaying[i].effbuf.Play(0,0,0);
    BufPlaying[i].state:=BUFFERSTATUS_PLAYING;
   end;


  if (BufPlaying[i].state=BUFFERSTATUS_QFORSTOP) then
  begin
    inc(stopsoundcount);
   BufPlaying[i].DSbuf.Stop;
 //  BufPlaying[i].DSbuf.SetCurrentPosition(0);
   if BufPlaying[i].effbuf<> nil then
    BufPlaying[i].effbuf.Stop;

  end;

  stat:=0;
  if (BufPlaying[i].state<>BUFFERSTATUS_STOPPED) then
  begin
   BufPlaying[i].DSBuf.GetStatus(stat);
   if ((stat and (DSBSTATUS_PLAYING or DSBSTATUS_LOOPING) )<>0) then
    BufPlaying[i].state:=BUFFERSTATUS_PLAYING
   else
    BufPlaying[i].state:=BUFFERSTATUS_STOPPED;
  end;

  if (BufPlaying[i].state and (DSBSTATUS_PLAYING or DSBSTATUS_LOOPING))>0 then
  begin
   inc(bufplayingcount);
   BufPlaying[i].played:=gtc;
   BufPlaying[i].tav:=tavpointpointsq(BufPlaying[i].pos,listenerpos)*BufPlaying[i].hangero;
  end;

  if stat=DSBSTATUS_BUFFERLOST then BufPlaying[i].DSBuf:=nil;
 end;

 for i:=0 to high(streams) do
 with streams[i] do
 begin
  if DSbuf=nil then continue;

  DSBuf.GetStatus(stat);

  if (stat and (DSBSTATUS_PLAYING or DSBSTATUS_LOOPING))>0 then
  begin
   playing:=true;
   played:=gtc;
  end
  else
   playing:=false;


  DSbuf.GetCurrentPosition(nil,@playpos);
  if korbekozott(lastpos,playpos,lastwrite) then
  begin
   DSBuf.Stop;
   //lastwrite:=0;
   //lastpos:=0;
   playing:=false;
  end;

  lastpos:=playpos;

  if length(buffered)>0 then
   WritetostreamSmallamounts(id,buffered);
   
  if stat=DSBSTATUS_BUFFERLOST then streams[i].DSBuf:=nil;
 end;


 i:=0;
 while i<=high(bufPlaying) do
  if (BufPlaying[i].DSBuf=nil) or (BufPlaying[i].played<gtc-3000) then
  begin

   if BufPlaying[i].DSBuf<>nil then
   begin
    BufPlaying[i].DSBuf.Stop;

  //  BufPlaying[i].DSBuf.setFX(0,nil,nil);
   end;

   if BufPlaying[i].effBuf<>nil then
   begin
    BufPlaying[i].effBuf.Stop;

  //  BufPlaying[i].DSBuf.setFX(0,nil,nil);
   end;

   if bufPlaying[i].DS3D <>nil then bufPlaying[i].DS3D:=nil;
   if bufPlaying[i].FX<>nil then bufPlaying[i].FX:=nil;
   if bufPlaying[i].DSbuf<>nil then bufPlaying[i].DSbuf:=nil;
   if bufPlaying[i].effbuf<>nil then bufPlaying[i].effbuf:=nil;
   BufPlaying[i]:=BufPlaying[high(Bufplaying)];

   if bufPlaying[high(Bufplaying)].DS3D <>nil then bufPlaying[high(Bufplaying)].DS3D:=nil;
   if bufPlaying[high(Bufplaying)].FX<>nil then bufPlaying[high(Bufplaying)].FX:=nil;
   if bufPlaying[high(Bufplaying)].DSbuf<>nil then bufPlaying[high(Bufplaying)].DSbuf:=nil;
   if bufPlaying[high(Bufplaying)].effbuf<>nil then bufPlaying[high(Bufplaying)].effbuf:=nil;
   //zeromemory(@bufPlaying[high(Bufplaying)],sizeof(bufPlaying[high(Bufplaying)]));
   setlength(Bufplaying,high(bufplaying));
  end
  else inc(i);

  i:=0;
 while i<=high(streams) do
  if (streams[i].DSBuf=nil) or (streams[i].played<gtc-3000) then
  begin
   delstream(i);
  end
  else inc(i);

 if listener=nil then exit;
 listener.CommitDeferredSettings;

end;

constructor TDSCapture.Create;
var
dsc:TDSCBufferdesc;
begin
 inherited;
 DSCapture:=nil;
 if FAILED(DirectSoundcapturecreate(nil,DSCapture,nil)) then exit;
 if DSCapture=nil then exit;


  dsc.dwSize := sizeof(DSCBUFFERDESC);
  dsc.dwFlags := 0;
  dsc.dwBufferBytes := wfx.nAvgBytesPerSec;
  dsc.dwReserved := 0;
  dsc.lpwfxFormat := @wfx;
  dsc.dwFXCount := 0;
  dsc.lpDSCFXDesc := nil;
  buf:=nil;
  DSCapture.CreateCaptureBuffer(dsc, buf,nil);
  if buf=nil then exit;
  lastread:=0;
end;


destructor TDSCapture.destroy;
begin

 DSCapture:=nil;
 inherited;
end;

procedure TDSCapture.update;
var
status,readnow:cardinal;
hov:integer;
LB1,LB2:Psmallintarray;
lbs1,lbs2:cardinal;
mennyit:integer;
begin
  if DSCapture=nil then exit;
  if buf=nil then exit;
  buf.GetStatus(@status);
  if (status and DSCBSTATUS_CAPTURING)=0 then exit;

  buf.GetCurrentPosition(nil,@readnow);

  if readnow>=lastread then
   mennyit:=readnow-lastread
  else
   mennyit:=readnow+wfx.nAvgBytesPerSec-lastread;
   
  if FAILED(buf.Lock(lastread,mennyit,@LB1,@lbs1,@lb2,@lbs2,0)) then exit;
  if (lbs1>0) then
  begin
   hov:=length(captured);
   setlength(captured,length(captured)+(lbs1+lbs2) shr 1);
   if lb1<>nil then
   copymemory(@(captured[hov]),LB1,lbs1);
   if lb2<>nil then   
   copymemory(@(captured[hov+lbs1 shr 1]),LB2,lbs2);
   lastread:=readnow;
  end;
  buf.Unlock(lb1,lbs1,lb2,lbs2);
end;


procedure TDSCapture.start;
begin
  if DSCapture=nil then exit;
  if buf=nil then exit;
  buf.Start(DSCBSTART_LOOPING)
end;

procedure TDSCapture.stop;
begin
  if DSCapture=nil then exit;
  if buf=nil then exit;
  buf.Stop;
end;






constructor TSpeexEncoder.Create;
var
a:integer;
b:single;
begin
 inherited;

 speex_bits_init(@encbits);
 encstate := speex_encoder_init(speex_lib_get_mode(SPEEX_MODEID_WB));

 speex_encoder_ctl(encstate,SPEEX_SET_SAMPLING_RATE,@vdefsmpRt);
 a:=0;
 speex_encoder_ctl(encstate,SPEEX_SET_VBR,@a);
 a:=1;
 speex_encoder_ctl(encstate,SPEEX_SET_VAD,@a);
 speex_encoder_ctl(encstate,SPEEX_SET_DTX,@a);
 a:=10;
 speex_encoder_ctl(encstate,SPEEX_SET_QUALITY,@a);

 b:=2;
 speex_encoder_ctl(encstate,SPEEX_SET_VBR_QUALITY,@b);

 speex_encoder_ctl(encstate,SPEEX_GET_FRAME_SIZE,@framesize);

 setlength(innerbuf,0);
 speex_bits_reset(@encbits);


 prepstate:=speex_preprocess_state_init(framesize,defsmprt);

 a:=1;
 speex_preprocess_ctl(prepstate,SPEEX_PREPROCESS_SET_AGC,@a);
 speex_preprocess_ctl(prepstate,SPEEX_PREPROCESS_SET_DENOISE,@a);

 b:=32768*0.9;
 speex_preprocess_ctl(prepstate,SPEEX_PREPROCESS_SET_AGC_LEVEL,@b);

end;

destructor TSpeexEncoder.destroy;
begin
 speex_bits_destroy(@encbits);
 speex_encoder_destroy(encstate);
 speex_preprocess_state_destroy(prepstate);
 inherited;
end;

procedure TSpeexEncoder.encode(const mit:Tsmallintdynarr);
var
hol:integer;
lngtvolt:integer;
//ossz:longint;
begin
 hol:=0;
 while length(innerbuf)+length(mit)-hol>=framesize do
 begin
  lngtvolt:=length(innerbuf);
  setlength(innerbuf,framesize);

 { for i:=lngtvolt to framesize-1 do
   innerbuf[i]:=mit[hol+i-lngtvolt]; }
  copymemory(@innerbuf[lngtvolt],@mit[hol],(framesize-lngtvolt)*2);

  inc(hol,framesize-lngtvolt);

  speex_preprocess(prepstate,@innerbuf[0],nil);

  {ossz:=0;
  for i:=0 to framesize-1 do
   ossz:=ossz+innerbuf[i];
  if ossz<framesize*300 then zeromemory(@innerbuf[0],length(innerbuf)*2);   //}

  speex_encode_int(encstate,@innerbuf[0], @encbits);
  setlength(innerbuf,0);
 end;

 lngtvolt:=length(innerbuf);
 setlength(innerbuf,length(innerbuf)+length(mit)-hol);
 {for i:=lngtvolt to high(innerbuf) do
   innerbuf[i]:=mit[hol+i-lngtvolt]; }
 copymemory(@innerbuf[lngtvolt],@mit[hol],(length(innerbuf)-lngtvolt)*2);
 datasize:=speex_bits_nbytes(@encbits);

end;

procedure TSpeexEncoder.getdata(var hova:Tbytearr);
var
sz:integer;
begin
 sz:=speex_bits_nbytes(@encbits);
 if sz=0 then exit;
 setlength(hova,sz);
 speex_bits_write(@encbits,pointer(@hova[0]),sz);
 speex_bits_reset(@encbits);
 datasize:=0;
end;



constructor TSpeexDecoder.Create;
var
a:integer;
begin
 inherited;
 speex_bits_init(@decbits);
 decstate := speex_decoder_init(speex_lib_get_mode(SPEEX_MODEID_WB));

 speex_decoder_ctl(decstate,SPEEX_GET_FRAME_SIZE,@framesize);
 a:=1;
 speex_decoder_ctl(decstate,SPEEX_SET_ENH,@a);

end;

destructor TSpeexDecoder.destroy;
begin
 speex_bits_destroy(@decbits);
 speex_decoder_destroy(decstate);
 inherited;
end;

procedure TSpeexDecoder.Decode(const mit:Tbytearr;var decoded:Tsmallintdynarr);
var
i:integer;
begin
 speex_bits_reset(@decbits);
 speex_bits_read_from(@decbits,pointer(@mit[0]),length(mit));
 setlength(decoded,framesize);
 while speex_decode_int(decstate,@decbits,@decoded[length(decoded)-framesize])=0 do
  setlength(decoded, length(decoded)+framesize);
 setlength(decoded,length(decoded)-framesize);
 for i:=0 to high(decoded) do
  decoded[i]:=decoded[i];
 lastused:=gettickcount;
end;

procedure TSpeexDecoder.NeedData(var decoded:Tsmallintdynarr);
begin
 setlength(decoded,framesize*3);
 speex_decode_int(decstate,nil,@decoded[0]);
 speex_decode_int(decstate,nil,@decoded[framesize]);
 speex_decode_int(decstate,nil,@decoded[framesize*2]);
end;

initialization
Speex_Load_DLL;
end.
