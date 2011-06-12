unit Soundunit;

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
  MADXDllinterface,DXErr9;
function InitDS(hwindow:HWND):Hresult;
procedure loadbuffers(bn:array of string);
procedure Init3DS;
procedure load3dmultibuf(nev:string;szam:byte;withfreq:boolean;mintav,maxtav:single);
procedure stopb(mi:integer);
procedure stop3Dmultibuf(mi:integer;id:cardinal);
procedure playb(mi:integer;repet:boolean);
procedure play3Dmultibuf(mi:integer;repet:boolean;id:cardinal;vec:TD3DXVector3);
procedure frecvol3dmultibuf(mi:integer;id:cardinal;vol:integer;freq:cardinal);
procedure update3Dmultibuf(mi:integer;id:cardinal;vec:TD3DXVector3);
procedure DS3DPlaceListener(vec:TD3DXvector3;szogx,szogy:single);
procedure DS3Dcommitdeferred;
procedure frecb(mi:integer;frek:single);
procedure volb(mi:integer;vol:single);
procedure stopall;
procedure closeds;
procedure zeneinit;
procedure zenefresh;
procedure zenestop;
procedure zenecleanup;
procedure zeneplay;
procedure zenevol(mire:single);
const
unitname='sound';
var
 mp3filelist:array of string;
type
CMP3Streamer = class (Tobject)
  private
   function RestoreBuffer(pDSB: IDirectSoundBuffer; pbWasRestored: PBOOL): HRESULT;
  public
   m_apDSBuffer: PAIDirectSoundBuffer;
    m_dwDSBufferSize: DWORD;
    m_dwNumBuffers: DWORD;
    m_dwCreationFlags: DWORD;
    m_dwLastPlayPos: DWORD;
    m_dwPlayProgress: DWORD;
    m_dwNotifySize: DWORD;
    m_dwNextWriteOffset: DWORD;
    m_bFillNextNotificationWithSilence:  BOOL;
    m_pthebuffer:Idirectsoundbuffer;
    constructor Create(pDS:IDirectSound;
                        var pDSBuffer: IDirectSoundBuffer;
                          dwDSBufferSize: DWORD; lpwfx:Pwaveformatex;dwNotifySize: DWORD);
    function Reset: HRESULT;
    function HandleWaveStreamNotification(bLoopedPlay: BOOL): HRESULT;
  end;

implementation

function korbekozott(a,b,x:cardinal):boolean;
begin
 result:=((a<b) and ((a<x) and (b>x))) or
         ((a>b) and ((b<x) and (a>x)));
end;

function CMP3Streamer.RestoreBuffer(pDSB: IDirectSoundBuffer; pbWasRestored: PBOOL): HRESULT;
var
  dwStatus: DWORD;
begin
  if (pDSB = nil) then
  begin
    Result:= CO_E_NOTINITIALIZED;
    Exit;
  end;

  if Assigned(pbWasRestored) then pbWasRestored^ := False;

  Result := pDSB.GetStatus(dwStatus);
  if FAILED(Result) then
  begin
    DXTRACE_ERR('GetStatus', Result, UnitName, $FFFFFFFF);
    Exit;
  end;

  if (dwStatus and DSBSTATUS_BUFFERLOST <> 0) then
  begin
    // Since the app could have just been activated, then
    // DirectSound may not be giving us control yet, so
    // the restoring the buffer may fail.
    // If it does, sleep until DirectSound gives us control.
    Result := pDSB.Restore;
    while (Result = DSERR_BUFFERLOST) do
    begin
      Sleep(10);
      Result := pDSB.Restore;
    end;

    if Assigned(pbWasRestored) then pbWasRestored^ := True;

    Result:= S_OK;
  end else
  begin
    Result:= S_FALSE;
  end;
end;


function CMP3Streamer.HandleWaveStreamNotification(bLoopedPlay: BOOL): HRESULT;
var
  dwCurrentPlayPos: DWORD;
  dwPlayDelta: DWORD;
  dwBytesWrittenToBuffer: DWORD;
  pDSLockedBuffer: Pointer;
  pDSLockedBuffer2: Pointer;
  dwDSLockedBufferSize: DWORD;
  dwDSLockedBufferSize2: DWORD;
  bRestored: BOOL;
  dwReadSoFar: DWORD;
begin
  Result := m_pthebuffer.GetCurrentPosition(@dwCurrentPlayPos, nil);
  if FAILED(Result) then
  begin
    DXTRACE_ERR('GetCurrentPosition', Result, UnitName, $FFFFFFFF);
    Exit;
  end;


  //improved testing, and looks like its good
  if korbekozott(dwCurrentplaypos-m_dwNotifysize,dwCurrentplaypos,m_dwNextWriteOffset+m_dwNotifysize)
     then exit;
  pDSLockedBuffer := nil;
  pDSLockedBuffer2 := nil;

  if (m_pthebuffer = nil)  then
  begin
    Result:= CO_E_NOTINITIALIZED;
    Exit;
  end;

  // Restore the buffer if it was lost
  Result := RestoreBuffer(m_pthebuffer, @bRestored);
  if FAILED(Result) then
  begin
    DXTRACE_ERR('RestoreBuffer', Result, UnitName, $FFFFFFFF);
    Exit;
  end;

  if (bRestored) then
  begin
    // The buffer was restored, so we need to fill it with new data
    pDSLockedBuffer      := nil;
    dwDSLockedBufferSize := 0;

  {  Result := FillBufferWithSound(m_pthebuffer, False);
    if FAILED(Result) then
    begin
      DXTRACE_ERR('FillBufferWithSound', Result, UnitName, $FFFFFFFF);
    end else Result:= S_OK;    }
    Exit;
  end;

  // Lock the DirectSound buffer
  Result := m_pthebuffer.Lock(m_dwNextWriteOffset, m_dwNotifySize,
                                 @pDSLockedBuffer, @dwDSLockedBufferSize,
                                 @pDSLockedBuffer2, @dwDSLockedBufferSize2, 0);
  if FAILED(Result) then
  begin
    DXTRACE_ERR('Lock', Result, UnitName, $FFFFFFFF);
    Exit;
  end;

  // m_dwDSBufferSize and m_dwNextWriteOffset are both multiples of m_dwNotifySize,
  // it should the second buffer, so it should never be valid
  if (pDSLockedBuffer2 <> nil)then
  begin
    Result:= E_UNEXPECTED;
    Exit;
  end;

  if (not m_bFillNextNotificationWithSilence) then
  begin
    // Fill the DirectSound buffer with wav data

    MP3E_Read(pDSLockedBuffer,
                               dwDSLockedBufferSize,
                               dwBytesWrittenToBuffer);

  end else
  begin
    // Fill the DirectSound buffer with silence
    FillMemory(pDSLockedBuffer, dwDSLockedBufferSize,
               FillValuesStaticA[false]);
    dwBytesWrittenToBuffer := dwDSLockedBufferSize;
  end;

  // If the number of bytes written is less than the
  // amount we requested, we have a short file.
  if (dwBytesWrittenToBuffer < dwDSLockedBufferSize) then
  begin
    if (not bLoopedPlay) then
    begin
      // Fill in silence for the rest of the buffer.
      FillMemory(Pointer(DWORD(pDSLockedBuffer) + dwBytesWrittenToBuffer),
                 dwDSLockedBufferSize - dwBytesWrittenToBuffer,
                 FillValuesStaticA[false]);

      // Any future notifications should just fill the buffer with silence
      m_bFillNextNotificationWithSilence := True;
    end else
    begin
      // We are looping, so reset the file and fill the buffer with wav data
      dwReadSoFar := dwBytesWrittenToBuffer;    // From previous call above.
      while (dwReadSoFar < dwDSLockedBufferSize) do
      begin
        // This will keep reading in until the buffer is full (for very short files).
        mp3E_newfile(mp3filelist[random(length(mp3filelist))]);
        MP3E_Read(Pointer(DWORD(pDSLockedBuffer) + dwReadSoFar),
                                   dwDSLockedBufferSize - dwReadSoFar,
                                   dwBytesWrittenToBuffer);

        dwReadSoFar := dwReadSoFar + dwBytesWrittenToBuffer;
      end;
    end;
  end;

  // Unlock the DirectSound buffer
  m_pthebuffer.Unlock(pDSLockedBuffer, dwDSLockedBufferSize, nil, 0);

  // Figure out how much data has been played so far.  When we have played
  // past the end of the file, we will either need to start filling the
  // buffer with silence or starting reading from the beginning of the file,
  // depending if the user wants to loop the sound
  Result := m_pthebuffer.GetCurrentPosition(@dwCurrentPlayPos, nil);
  if FAILED(Result) then
  begin
    DXTRACE_ERR('GetCurrentPosition', Result, UnitName, $FFFFFFFF);
    Exit;
  end;

  // Check to see if the position counter looped
  if (dwCurrentPlayPos < m_dwLastPlayPos)
  then dwPlayDelta := (m_dwDSBufferSize - m_dwLastPlayPos) + dwCurrentPlayPos
  else dwPlayDelta := dwCurrentPlayPos - m_dwLastPlayPos;

  m_dwPlayProgress := m_dwPlayProgress + dwPlayDelta;
  m_dwLastPlayPos := dwCurrentPlayPos;

  // If we are now filling the buffer with silence, then we have found the end so
  // check to see if the entire sound has played, if it has then stop the buffer.
 { if (m_bFillNextNotificationWithSilence) then
  begin
    // We don't want to cut off the sound before it's done playing.
    if (m_dwPlayProgress >= m_pWaveFile.GetSize) then
    begin
      m_pthebuffer.Stop;
    end;
  end;  }

  // Update where the buffer will lock (for next time)
  m_dwNextWriteOffset := m_dwNextWriteOffset + dwDSLockedBufferSize;
  m_dwNextWriteOffset := m_dwNextWriteOffset mod m_dwDSBufferSize; // Circular buffer

  Result:= S_OK;
end;

constructor CMP3Streamer.Create(pDS:IDirectSound;
  var pDSBuffer: IDirectSoundBuffer;
  dwDSBufferSize: DWORD; lpwfx:Pwaveformatex; dwNotifySize: DWORD);
var
dsc:_DSbufferdesc;
begin
 //modified create
 zeromemory(@dsc,sizeof(dsc));
 dsc.dwSize:=sizeof(dsc);
 dsc.dwFlags:=DSBCAPS_CTRLVOLUME;
 dsc.dwBufferBytes:=dwDSBufferSize;
 dsc.lpwfxFormat:=lpwfx;

  if failed(pDS.CreateSoundBuffer(dsc,pDSBuffer,nil))then exit;

  m_dwLastPlayPos     := 0;
  m_dwPlayProgress    := 0;
  m_dwNotifySize      := dwNotifySize;
  m_dwNextWriteOffset := 0;
  m_dwDSBufferSize  := dwDSBufferSize;
  m_dwCreationFlags := 0;
  m_bFillNextNotificationWithSilence := False;
  m_pthebuffer:=pDSbuffer;
end;

function CMP3Streamer.Reset: HRESULT;
var
  bRestored: BOOL;
begin
  if (m_pthebuffer = nil)  then
  begin
    Result:= CO_E_NOTINITIALIZED;
    Exit;
  end;

  m_dwLastPlayPos     := 0;
  m_dwPlayProgress    := 0;
  m_dwNextWriteOffset := 0;
  m_bFillNextNotificationWithSilence := False;

  // Restore the buffer if it was lost
  Result := RestoreBuffer(m_pthebuffer, @bRestored);
  if FAILED(Result) then
  begin
    DXTRACE_ERR('RestoreBuffer', Result, UnitName, $FFFFFFFF);
    Exit;
  end;

  if (bRestored) then
  begin
    // The buffer was restored, so we need to fill it with new data



   { Result := FillBufferWithSound(m_pthebuffer, False);
    if FAILED(Result) then
    begin
      DXTRACE_ERR('FillBufferWithSound', Result, UnitName, $FFFFFFFF);
    end else Result:= S_OK; }
    Exit;
  end;

  mp3E_newfile(mp3filelist[random(length(mp3filelist))]);

  Result:= m_pthebuffer.SetCurrentPosition(0);
end;

var
  DS:IDirectsound;

  DSBuf1: IDirectSoundBuffer;
  DSBuf:array [0..1000] of IDirectSoundBuffer;
  DS3D:array [0..1000] of IDirectSound3DBuffer;
  mbc:array [-1..100] of shortint; //mbc: multibufcoords;
  mbid:array [0..1000] of cardinal;
  BUFS,MBUFS:integer;
  listener:IDirectSound3DListener;
  //zene
  zene:CMP3Streamer;
  zeneBuf:IDirectSoundBuffer;
  zenefil:CWavefile;


function Loadbuf(var buf:IDirectsoundbuffer;fs:string;haromd,withfreq:boolean):Hresult;
var
dsc:_DSbufferdesc;
mfile:Cwavefile;
pwfx:Pwaveformatex;
pDSLockedBuffer,plb2: PChar;
dwDSLockedBufferSize: DWORD;
dwWavDataRead: DWORD;
pluszbuf:PBytearray;
begin
 Result:= E_FAIL;
 mFile:=Cwavefile.Create;
 pwfx:=nil;
 mfile.Open(Pchar(fs),pwfx,WAVEFILE_READ);
 zeromemory(@dsc,sizeof(dsc));
 dsc.dwSize:=sizeof(dsc);
 dsc.dwFlags:=DSBCAPS_CTRLVOLUME  or  DSBCAPS_STATIC;
 if withfreq then
  dsc.dwFlags:=DSBCAPS_CTRLFREQUENCY or dsc.dwFlags;
 if haromd then
  dsc.dwFlags:=DSBCAPS_CTRL3D or dsc.dwFlags;
 dsc.dwBufferBytes:=mfile.m_dwSize;
 dsc.lpwfxFormat:=mfile.m_pwfx;
 if failed(DS.CreateSoundBuffer(dsc,Buf,nil))then
  exit;

 Buf.Lock(0, mfile.m_dwSize,
                      @pDSLockedBuffer, @dwDSLockedBufferSize, nil, nil, 0);
 mfile.ResetFile;
 plb2:=pDSLockedBuffer;
 pluszbuf
 repeat
 mfile.Read(pbyte(plb2),
                             mfile.m_dwSize,
                             @dwWavDataRead);
 plb2:=plb2+dwWavdataread;
 until 0=dwWavDataRead;
// messagebox(0,pchar(inttostr(dwWavDataRead)+'/'+inttostr(mfile.m_dwSize)),'jeah',0);
 Buf.Unlock(pDSLockedBuffer, dwDSLockedBufferSize, nil, 0);
 mfile.Destroy;
 Result:= S_OK;
end;

function InitDS(hwindow:HWND):Hresult;
var
adesc:_DSbufferdesc;
hib:HRESULT;
begin
 result:=E_FAIL;
 bufs:=-1;
 mbufs:=-1;
 if failed(directsoundcreate(nil,DS,nil)) then exit;
 if failed(DS.SetCooperativeLevel(hwindow,DSSCL_PRIORITY)) then exit;
 zeromemory(@adesc,sizeof(adesc));
 adesc.dwSize:=sizeof(adesc);
 adesc.dwFlags:=DSBCAPS_PRIMARYBUFFER or DSBCAPS_CTRL3D;

 hib:=DS.CreateSoundBuffer(adesc,DSBuf1,nil);
 if failed(hib)then exit;
 Result:=S_OK
end;

procedure Init3DS;
begin
//ohje
DSBuf1.QueryInterface(IID_IDirectSound3DListener, listener);
 mbc[-1]:=-1;
end;

procedure loadbuffers(bn:array of string);
var
i:integer;
begin
 BUFS:=high(bn);
 inc(mbufs);
 for i:=0 to BUFS do
  Loadbuf(DSBuf[i],'snd\'+bn[i]+'.wav',false,true);
end;

procedure load3dmultibuf(nev:string;szam:byte;withfreq:boolean;mintav,maxtav:single);
var
i:integer;
begin
inc(mbufs);
inc(bufs);
loadbuf(DSBuf[bufs],'data\snd\'+nev+'.wav',true,withfreq);
if DSBuf[bufs]=nil then exit;
DSBuf[bufs].QueryInterface(IID_IDirectSound3DBuffer8, DS3D[bufs]);
for i:=2 to szam do
begin
 inc(bufs);
 DS.DuplicateSoundBuffer(DSBuf[bufs-1],DSBuf[bufs]);
 if DSBuf[bufs]= nil then exit;
 DSBuf[bufs].QueryInterface(IID_IDirectSound3DBuffer8, DS3D[bufs]);
 if DS3D[bufs]= nil then exit;
 DS3D[bufs].SetMinDistance(mintav,DS3D_DEFERRED);
 DS3D[bufs].SetMaxDistance(maxtav,DS3D_DEFERRED);
end;
mbc[mbufs]:=bufs;
end;

procedure stopall;
var
i:integer;
begin
for i:=0 to bufs do
  if DSBuf[i]<>nil then DSBuf[i].Stop;
end;

procedure closeds;
var
i:integer;
begin
 for i:=0 to bufs do
  if DSBuf[i]<>nil then DSBuf[i]:=nil;
 if zenefil<>nil then zenefil.Destroy;
 if zenebuf<>nil then zenebuf:=nil;
 //ds:=nil;
end;

procedure playb(mi:integer;repet:boolean);
begin
 if DSbuf[mi]<>nil then
 begin
  if repet then
   DSbuf[mi].Play(0,0,DSBPLAY_LOOPING)
  else
   DSbuf[mi].Play(0,0,0);
 end;
end;

procedure stopb(mi:integer);
begin
 if DSbuf[mi]<>nil then
 begin
   DSbuf[mi].Stop;
 end;
end;

procedure stop3Dmultibuf(mi:integer;id:cardinal);
var
i,min:integer;
begin
 min:=-1;
 for i:=mbc[mi-1]+1 to mbc[mi] do
 begin
  if mbid[i]=id then begin min:=i;break;end;
  min:=-1;
 end;
 if min>=0 then
 stopb(min);
end;

procedure frecvol3dmultibuf(mi:integer;id:cardinal;vol:integer;freq:cardinal);
var
i,min:integer;
begin
 min:=-1;
 for i:=mbc[mi-1]+1 to mbc[mi] do
 begin
  if mbid[i]=id then begin min:=i;break;end;
  min:=-1;
 end;
 if min>=0 then
 begin
  if DSbuf[min]=nil then exit;
  DSbuf[min].SetFrequency(freq);
  DSbuf[min].SetVolume(vol);
 end;
end;

procedure play3Dmultibuf(mi:integer;repet:boolean;id:cardinal;vec:TD3DXVector3);
var
i,min,min2:integer;
min2id:cardinal;
stat:cardinal;
begin
 min:=-1;
 min2id:=high(cardinal);
 min2:=0;
 for i:=mbc[mi-1]+1 to mbc[mi] do
 begin
  if mbid[i]=id then begin min:=i;break;end;
  if mbid[i]<min2id then begin min2id:=mbid[i];min2:=i;end;
 end;

 if min=-1 then
 begin
  for i:=mbc[mi-1]+1 to mbc[mi] do
  begin
   if DSBuf[i]=nil then exit;
   DSBuf[i].GetStatus(stat);
   if ((stat and (DSBSTATUS_PLAYING or DSBSTATUS_LOOPING) )=0) then
    begin min:=i; break;end;
  end;
 end
 else
 begin
  if DSBuf[min]=nil then exit;
  DSBuf[min].GetStatus(stat);
   if ((stat and (DSBSTATUS_PLAYING or DSBSTATUS_LOOPING) )>0) then
  begin
    DS3D[min].SetPosition(vec.x,vec.y,vec.z,DS3D_DEFERRED);
    exit;
   end;
 end;
 if min<0 then
  if id=25 then min:=mbc[mi-1]+1
           else min:=min2;
 playB(min,repet);
 mbid[min]:=id;
 if DS3D[min]=nil then exit;
 DS3D[min].SetPosition(vec.x,vec.y,vec.z,DS3D_DEFERRED);
end;

procedure DS3DPlaceListener(vec:TD3DXvector3;szogx,szogy:single);
var
vb,ve,vn:TD3DXvector3;
begin
 if listener=nil then exit;
 listener.SetPosition(vec.x,vec.y,vec.z,DS3D_DEFERRED);
 ve:=D3DXVector3(sin(szogx)*cos(szogy),sin(szogy),cos(szogx)*cos(szogy));
 vb:=D3DXVector3(ve.z,0,-ve.x);
 d3dxvec3cross(vn,ve,vb);
 d3dxvec3normalize(vb,vn);
 d3dxvec3normalize(ve,ve);
 listener.SetOrientation(ve.x,ve.y,ve.z,vb.x,vb.y,vb.z,DS3D_DEFERRED);
end;


procedure DS3Dcommitdeferred;
begin
 if listener=nil then exit;
 listener.CommitDeferredSettings;
end;

procedure update3Dmultibuf(mi:integer;id:cardinal;vec:TD3DXVector3);
var
i,min:integer;
begin
 if mi=0 then min:=0 else min:=mbc[mi-1];
 for i:=min to mbc[mi] do
 begin
  if mbid[i]=id then begin min:=i;break;end;
  min:=-1;
 end;
 if min>=0 then
 if DS3D[min]<>nil then
 DS3D[min].SetPosition(vec.x,vec.y,vec.z,DS3D_DEFERRED);
end;

procedure frecb(mi:integer;frek:single);
begin
 if DSbuf[mi]<>nil then
 begin
   DSbuf[mi].SetFrequency(round(3000*frek));
 end;
end;

procedure volb(mi:integer;vol:single);
begin
 if DSbuf[mi]<>nil then
 begin
   DSbuf[mi].SetVolume(round(vol));
 end;
end;

procedure zeneinit;
var
m_pwfx:PWaveformatex;
begin

 if high(mp3filelist)<0 then exit;

 mp3e_init(mp3filelist[random(length(mp3filelist))]);

 getmem(m_pwfx,sizeof(TWaveformatex));

 with m_pwfx^ do
 begin

  wFormatTag := WAVE_FORMAT_PCM;
  nChannels := 2;
  nSamplesPerSec := 44000;
   wBitsPerSample := 16;
  nAvgBytesPerSec := nSamplesPerSec * nChannels * wBitsPerSample div 8;
  nBlockAlign :=nAvgBytesPerSec div nSamplesPerSec;

  cbSize := 0;
 end;
 
 zene:=Cmp3streamer.Create(ds,zenebuf,MADX_OUTPUT_BUFFER_SIZE*8,m_pwfx,MADX_OUTPUT_BUFFER_SIZE);

 if zene=nil then messagebox(0,'Error in MP3 unit: stream','Error',0);
 if zenebuf=nil then messagebox(0,'Error in mp3 unit: Buffer','Error',0);

 //zene.Reset;
 zene.HandleWaveStreamNotification(true);
 //zenebuf.setvolume(-500);
 //zenebuf.Play(0,0,DSBPLAY_LOOPING);
end;

procedure zenecleanup;
begin
 zenestop;
 if zene<>nil then
 zene.Destroy;
 zenebuf:=nil;
 mp3e_cleanup;
end;

procedure zenestop;
begin
 if zenebuf<>nil then
 zenebuf.stop;
end;

procedure zeneplay;
begin
 if zenebuf<>nil then
  zenebuf.Play(0,0,DSBPLAY_LOOPING);
end;
                //0..1
procedure zenevol(mire:single);
begin
 if zenebuf= nil then exit;
 if mire<0.02 then
   zenebuf.setvolume(DSBVOLUME_MIN)
 else
 begin
  mire:=log10(mire)*1000;
  zenebuf.setvolume(round(mire));
 end;
end;


procedure zenefresh;
begin
 if zene<>nil then
 zene.HandleWaveStreamNotification(true);
end;

end.
