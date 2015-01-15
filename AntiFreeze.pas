unit AntiFreeze;

interface
uses sysutils,windows,typestuff;

procedure AFstart;
procedure AFquit;
procedure AFtick;

procedure AFUPstart(elbaszando:pointer);//mint antifreeze unpause
procedure AFUPquit;

implementation
var
AFgtcvolt:cardinal;
AFquitb:boolean;
AFupquitb:boolean;

function antifreezethread(nulla:pointer):integer;
begin
 result:=0;
 AFgtcvolt:=gettickcount;
 repeat
  sleep(500);
 until AFquitb or ((AFgtcvolt+5000)<gettickcount);

 if not AFquitb then
 begin
  messagebox(0,PChar('Sorry, but the software has frozen. Now closing'),'Freeze',MB_SETFOREGROUND);
  writeln(logfile,'Software freezed');
  writeln(logfile,'Last state: ',laststate);
  writeln(logfile,'Freeze at:',formatdatetime('yyyy.mm.dd/hh:nn:ss',date+time));
  closefile(logfile);
  exitprocess(0);
 end;

end;

procedure AFstart;
var
tID:cardinal;
begin
  afquitb:=false;
  beginthread(nil,0,antifreezethread,nil,0,tID);
end;

procedure AFtick;
begin
  AFgtcvolt:=gettickcount;
end;

procedure AFquit;
begin
 AFquitb:=true;
end;

var
bassz_el:pdword;

function antifreezeunpausethread(ures:pointer):integer;
var
 gtc,gtcu:cardinal;
begin
 result:=0;
 gtc:=gettickcount;
 repeat
  sleep(100);
  gtcu:=gettickcount;
  if (gtc<gtcu-1000) then bassz_el^:=$D3AD1EE8;
  gtc:=gtcu;
 until AFUPquitb;
end;


procedure AFUPstart(elbaszando:pointer);//mint antifreeze unpause
var
tID:cardinal;
begin
 bassz_el:=elbaszando;
 beginthread(nil,0,antifreezeunpausethread,nil,0,tID);
 setthreadpriority(tid,THREAD_PRIORITY_HIGHEST );
end;

procedure AFUPquit;
begin
 AFUPquitb:=true;
end;

end.
