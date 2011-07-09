program convert_20_21;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  qjson,
  typestuff;
const
menuscenes:array[0..6,0..4] of single =(
(-460.11, 49.90, -128.67,  1.14, -0.37),
(-368.52, 24.52,   49.50, -1.78,  0.37),
(-314.41, 40.95,  104.83,  2.23, -0.46),
(-281.39,  10.8,  -51.03, -0.42,  0.40),
(-152.68, 65.11,  -17.90,  2.49, -0.36),
(-128.98, 73.09,   47.41,  1.60,  0.30),
(-166.48, 42.02, -132.16, -0.31, -0.18));
var
 root:TQJSON;
 i,num:integer;
 fil:textfile;
 str:string;
 attr,val:string;
 epulet:string='';
 epuletnum:integer=-1;
 teleport:integer=-1;
 flt:TarrayofString;
begin
  DecimalSeparator:='.';
try
 root:=TQJSON.Create();
 root.SetVal(['modname'],'Converted pre 2.1 mod');
 root.SetVal(['random_seed'],25);

 root.SetVal(['color_grass'],ARGB($FF,116,178,67));
 root.SetVal(['color_sand'],ARGB($FF,250,200,200));
 root.SetVal(['color_rock'],ARGB($FF,110,110,108));
 root.SetVal(['color_water'],ARGB($FF,0,100,250));
 root.SetVal(['fog','color_sunny'],$FFC5F2FF);
 root.SetVal(['fog','color_rainy'],$FF909090);
 root.SetVal(['fog','radius_sunny'], 900);
 root.SetVal(['fog','radius_rainy'], 600);

 root.SetVal(['light','color_ambient'],$FF202020);
 root.SetVal(['light','color_sun'],ARGB($FF,255,255,230));
 root.SetVal(['light','color_shadow'],$252550);


 root.SetVal(['spawn_height'], 10);
 root.SetVal(['spawn_radius'], 5);

 root.SetValF(['vehicle','gun','scale','x'],2.3);
 root.SetValF(['vehicle','gun','scale','y'],0.7);
 root.SetValF(['vehicle','gun','scale','z'],1.3);
 root.SetVal (['vehicle','gun','effect'],true);

 root.SetValF(['vehicle','tech','scale','x'],1.8);
 root.SetValF(['vehicle','tech','scale','y'],0.9);
 root.SetValF(['vehicle','tech','scale','z'],1.5);
 root.SetVal (['vehicle','tech','effect'],true);

 assignfile(fil,'data\map.ini');
 reset(fil);
 repeat
  readln(fil,str);
  if length(str)=0 then
   continue;
  if str[1]='[' then
  begin
   epulet:='';
   teleport:=-1;
   if pos('[SPECIAL:',str)<=0 then
   begin
    epulet:=copy(str,2,length(str)-2);
    inc(epuletnum);
    if epuletnum=0 then
    begin
     root.SetVal(['buildings',epulet,'special',0],'spawngun');
     root.SetVal(['buildings',epulet,'special',1],'spawntech');
     root.SetVal(['buildings',epulet,'special',2],'vehiclegun');
     root.SetVal(['buildings',epulet,'special',3],'vehicletech');
    end;
   end
   else
    if str='[SPECIAL:teleport]' then
     teleport:=root.GetNum(['teleports'])
  end
  else
  if epulet<>'' then
  begin
   attr:=lowercase(copy(str,1,pos('=',str)-1));
   val :=copy(str,pos('=',str)+1,1000);
   if attr='scalex' then
    root.SetValF(['buildings',epulet,'scalex'],strtofloat(val));
   if attr='scaley' then
    root.SetValF(['buildings',epulet,'scaley'],strtofloat(val));
   if attr='zone' then
    root.SetVal(['buildings',epulet,'zone'],val);

   if attr='special' then
   begin
    //if val='pantheon'    then   panthepulet:=i;
   end;

   if attr='terrain' then
   begin
    num:= root.GetNum(['buildings',epulet,'special']);
    if val='fit' then
     root.SetVal(['buildings',epulet,'special',num],'fittoterrain');
    if val='dont' then
     root.SetVal(['buildings',epulet,'special',num],'dontflattenterrain');
   end;

   if attr='pos' then
   begin
    explode(val,' ',flt);
    if high(flt)<2 then
    begin
     writeln('Bad position value in map.ini at ',epulet);
     continue;
    end;
    num:= root.GetNum(['buildings',epulet,'position']);
    root.SetValF(['buildings',epulet,'position',num,'x'],strtofloat(flt[0]));
    root.SetValF(['buildings',epulet,'position',num,'y'],strtofloat(flt[1]));
    root.SetValF(['buildings',epulet,'position',num,'z'],strtofloat(flt[2]));
   end;
  end
  else
  if teleport>=0 then
  begin
   attr:=lowercase(copy(str,1,pos('=',str)-1));
   val :=copy(str,pos('=',str)+1,1000);

   if attr='radius' then
    root.SetValF(['teleports',teleport,'radius'],strtofloat(val));

   if attr='visible' then
    root.SetValF(['teleports',teleport,'visible_range'],strtofloat(val));

   if attr='from' then
   begin
    explode(val,' ',flt);
    if high(flt)<2 then
    begin
     writeln('Bad position value in map.ini at teleport nr.',teleport);
     continue;
    end;
    root.SetValF(['teleports',teleport,'from','x'],strtofloat(flt[0]));
    root.SetValF(['teleports',teleport,'from','y'],strtofloat(flt[1]));
    root.SetValF(['teleports',teleport,'from','z'],strtofloat(flt[2]));
   end;

   if attr='to' then
   begin
    explode(val,' ',flt);
    if high(flt)<2 then
    begin
     writeln('Bad position value in map.ini at teleport nr.',teleport);
     continue;
    end;
    root.SetValF(['teleports',teleport,'to','x'],strtofloat(flt[0]));
    root.SetValF(['teleports',teleport,'to','y'],strtofloat(flt[1]));
    root.SetValF(['teleports',teleport,'to','z'],strtofloat(flt[2]));
   end;

  end;

 until eof(fil);
 closefile(fil);

 for i:=0 to high(menuscenes) do
 begin
  root.SetValF(['menubackgrounds',i,'x'],menuscenes[i,0]);
  root.SetValF(['menubackgrounds',i,'y'],menuscenes[i,1]);
  root.SetValF(['menubackgrounds',i,'z'],menuscenes[i,2]);
  root.SetValF(['menubackgrounds',i,'angleH'],menuscenes[i,3]);
  root.SetValF(['menubackgrounds',i,'angleV'],menuscenes[i,4]);
 end;

 root.SaveToFile('data\stuff.json');
 Writeln('Success');
except
 on E:Exception do Writeln(E.Message);
end;
 Writeln('Press ENTER to continue.');
readln;
end.
