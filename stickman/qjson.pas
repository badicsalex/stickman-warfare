unit qjson;

interface
uses SysUtils,Classes,windows,math;
type

 EJSONParserError = class(EParserError)
 public
  constructor Create(const str:string;i:integer;const msg:string);
 end;

 TQJSONType = (
   QJSON_NULL,
   QJSON_INT,
   QJSON_FLOAT,
   QJSON_BOOLEAN,
   QJSON_STRING,
   QJSON_ARRAY,
   QJSON_MAP
 );

 PQJSONData = ^TQJSONData;

 PQJSONArray = ^TQJSONArray;
 TQJSONArray = array of PQJSONData;

 TQJSONKeyValue = record
  key:string;
  data:PQJSONData;
 end;

 PQJSONMap = ^TQJSONMap;
 TQJSONMap = array of TQJSONKeyValue;

 TQJSONData = record
  case typ:TQJSONType of
   QJSON_NULL	:(null:integer);
   QJSON_INT	:(intval:integer);
   QJSON_FLOAT	:(floatval:double);
   QJSON_BOOLEAN:(boolval:boolean);
   QJSON_STRING	:(strval:PString);
   QJSON_ARRAY	:(arrval:PQJSONArray);
   QJSON_MAP	:(mapval:PQJSONMap);
 end;

 TQJSON = class(TObject)
 private
  root:PQJSONData;
  procedure clear(data:PQJSONData);overload;
  procedure SkipWhiteSpace(const str:string;var i:integer);
  function ReadToken(const str:string;var i:integer):string;
  function CreateQJSONFromString(const str:string;var i:integer):PQJSONData;
  procedure SaveToFile2(data:PQJSONData;indent:integer;var fil:TextFile);
  function Resolve(data:PQJSONData;keys:array of const;create:boolean=false):PQJSONData;
 public
  constructor Create();
  constructor CreateFromFile(const filename:string);
  procedure SaveToFile(const filename:string);
  destructor Destroy();override;
  procedure SetVal(keys:array of const;mire:integer);overload;
  procedure SetValF(keys:array of const;mire:single);overload;
  procedure SetVal(keys:array of const;mire:boolean);overload;
  procedure SetVal(keys:array of const;mire:string);overload;

  procedure Clear(keys:array of const);overload;

  function GetInt(keys:array of const):integer;
  function GetFloat(keys:array of const):double;
  function GetString(keys:array of const):string;
  function GetBool(keys:array of const):boolean;

  function GetKey(keys:array of const;numkey:integer):string; //numerikusból text key-t csinál

  function GetNum(keys:array of const):integer; //array length
 end;

implementation
const
 QJSON_NULLVAL:TQJSONData=(typ:QJSON_NULL);

constructor EJSONParserError.Create(const str:string;i:integer;const msg:string);
begin
 if length(str)>i+10 then
  inherited Create('JSON parse error ('+msg+') near "'+copy(str,i,30)+'"')
 else
  inherited Create('JSON parse error ('+msg+') near "'+copy(str,length(str)-20,30)+'"');
end;

constructor TQJSON.Create();
begin
 inherited;
 New(root);
 root.typ:=QJSON_NULL;
end;

destructor TQJSON.Destroy;
begin
 Clear(root);
 Dispose(root);
 inherited;
end;

procedure TQJSON.SkipWhiteSpace(const str:string;var i:integer);
begin
 while (ord(str[i])<=32) and (length(str)>=i) do
  inc(i);
end;

function TQJSON.ReadToken(const str:string;var i:integer):string;
var
 start:integer;
begin
 DecimalSeparator:='.';
 SkipWhitespace(str,i);
 start:=i;
 result:='';
 if str[i]='"' then //idézõjeles string, parse-olunk
 begin
  inc(i);
  inc(start);
  result:='';
  while true do
  begin
//   while (str[i]<>'"') and (str[i]<>'\') and (length(str)>=i) do
   while (str[i]<>'"') and (length(str)>=i) do
    inc(i);

   if length(str)<i then
    raise EJSONParserError.Create(str,i,'unterminated string');
//   if (length(str)<i+1) and (str[i]='\') then
//    raise EJSONParserError.Create(str,i,'unterminated backslash');

     result:=copy(str,start,i-start);

   if str[i]='"' then
   begin
    inc(i);
    result := StringReplace(result, '\b', char(8), [rfReplaceAll]);
    result := StringReplace(result, '\t', char(9), [rfReplaceAll]);
    result := StringReplace(result, '\n', char(10), [rfReplaceAll]);
    result := StringReplace(result, '\f', char(12), [rfReplaceAll]);
    result := StringReplace(result, '\r', char(13), [rfReplaceAll]);
    break;
   end;
  end;
 end
 else
 begin //nincs idézõjel, olvasás különleges karakterig

  while (ord(str[i])>32) and (length(str)>=i) and
        (str[i]<>'{') and (str[i]<>'}') and
        (str[i]<>'[') and (str[i]<>']') and
        (str[i]<>'(') and (str[i]<>')') and
        (str[i]<>':') and (str[i]<>',') do
   inc(i);
  result:=copy(str,start,i-start);
 end;
end;

function TQJSON.CreateQJSONFromString(const str:string;var i:integer):PQJSONData;
var
token:string;
begin
 New(result);
 SkipWhiteSpace(str,i);
 if length(str)<i then
 begin
  result.typ:=QJSON_NULL;
  exit;
 end;

 if str[i]='{' then //ojjektum
 begin
  result.typ:=QJSON_MAP;
  New(result.mapval);
  inc(i);
  while true do
  begin
   SkipWhiteSpace(str,i);
   if length(str)<i then
    raise EJSONParserError.Create(str,i,'unterminated {');

   if str[i]='}' then
   begin
    inc(i);
    break;
   end;
   if str[i]=',' then
   begin
    inc(i);
    continue;
   end;

   token:=ReadToken(str,i);
   SkipWhiteSpace(str,i);
   if str[i]<>':' then
    raise EJSONParserError.Create(str,i,': expected');
   inc(i);

   setlength(result.mapval^,length(result.mapval^)+1);
   result.mapval^[high(result.mapval^)].key:=token;
   result.mapval^[high(result.mapval^)].data:=CreateQJSONFromString(str,i);
  end;
 end
 else
 if str[i]='[' then //tömb
 begin
  result.typ:=QJSON_ARRAY;
  New(result.arrval);
  inc(i);
  while true do
  begin
   SkipWhiteSpace(str,i);
   if length(str)<i then
    raise EJSONParserError.Create(str,i,token+'unterminated [');

   if str[i]=']' then
   begin
    inc(i);
    break;
   end;

   if str[i]=',' then
   begin
    inc(i);
    continue;
   end;

   setlength(result.arrval^,length(result.arrval^)+1);
   result.arrval^[high(result.mapval^)]:=CreateQJSONFromString(str,i);
  end;
 end
 else
 if str[i]='"' then
 begin
  result.typ:=QJSON_STRING;
  New(result.strval);
  result.strval^:=ReadToken(str,i);
 end
 else
 begin
  token:=ReadToken(str,i);
  if token='null' then
   result.typ:=QJSON_NULL
  else
  if token='true' then
  begin
   result.typ:=QJSON_BOOLEAN;
   result.boolval:=true;
  end
  else
  if token='false' then
  begin
   result.typ:=QJSON_BOOLEAN;
   result.boolval:=false;
  end
  else
  begin
     if TryStrToInt(token,result.intval) then      //delphi 7 alatt try-olni kell
       result.typ:=QJSON_INT
     else
     if TryStrToFloat(token,result.floatval) then
       result.typ:=QJSON_FLOAT
     else
       raise EJSONParserError.Create(str,i,token+' is not a valid token');
  end
 end
end;

constructor TQJSON.CreateFromFile(const filename:string);
var
 fil:File;
 filehandle:Integer absolute fil; //muhhhuhuhuhahaha
 str:string;
 vfm:byte;
 n,i,j:integer;
 buf:array [0..1024] of char;
begin
 inherited Create();

 AssignFile(fil,Filename);
 {szánalmas ez a csodásan nem thread-safe vagy OOP módja a file lockolásnak}
 vfm:=FileMode;
 FileMode:=fmShareDenyWrite or fmOpenRead;
 Reset(fil,1);
 FileMode:=vfm;

 n:=GetFileSize(filehandle,nil);
 SetLength(str,n);
 i:=1;
 while i<=n do
 begin
  if i+1024<=n then
   BlockRead(fil,buf,1024)
  else
   BlockRead(fil,buf,n-i+1);
  j:=0;
  while (i<=n) and (j<1024) do
  begin
   str[i]:=buf[j];
   inc(i);inc(j);
  end;
 end;
 CloseFile(fil);

 i:=1;
 root:=CreateQJSONFromString(str,i);
end;

procedure TQJSON.SaveToFile2(data:PQJSONData;indent:integer;var fil:TextFile);
var
i,hgh:integer;
begin
 case data.typ of
  QJSON_NULL:write(fil,'null');
  QJSON_INT:write(fil,data.intval);
  QJSON_FLOAT:write(fil,FloatToStrF(data.floatval,ffGeneral,7,1));
  QJSON_BOOLEAN: if data.boolval then write(fil,'true') else write(fil,'false');
  QJSON_STRING: write(fil,'"',data.strval^,'"');
  QJSON_ARRAY:
  begin
   hgh:=high(data.arrval^);

   write(fil,'[') ;

   if hgh>=3 then
     writeln(fil);

   for i:=0 to hgh do
   begin
    if hgh>=3 then
     write(fil,StringOfChar(#9,indent+1));
    SaveToFile2(data.arrval^[i],indent+1,fil);
    if i=hgh then
     write(fil)
    else
     write(fil,', ');

    if hgh>=3 then
     writeln(fil);
   end;
   if hgh>=3 then
    write(fil,StringOfChar(#9,indent));
   write(fil,']');
  end;
  QJSON_MAP:
  begin
   hgh:=high(data.mapval^);
   write(fil,'{');
   if hgh>=3 then
     writeln(fil);
   for i:=0 to hgh do
   begin
    if hgh>=3 then
     write(fil,StringOfChar(#9,indent+1));
    write(fil,'"',data.mapval^[i].key,'": ');
    SaveToFile2(data.mapval^[i].data,indent+1,fil);
    if i=hgh then
     write(fil)
    else
     write(fil,', ');

    if hgh>=3 then
     writeln(fil);
   end;
   if hgh>=3 then
    write(fil,StringOfChar(#9,indent));
   write(fil,'}');
  end;
 end;
 flush(fil);
end;

procedure TQJSON.SaveToFile(const filename:string);
var
 fil:TextFile;
begin
 Assignfile(fil,filename);
 rewrite(fil);
 SaveToFile2(root,0,fil);
 closefile(fil);
end;

function TQJSON.Resolve(data:PQJSONData;keys:array of const;create:boolean=false):PQJSONData;
var
i,j,tmp:integer;
key:string;
begin
 result:=data;
 for i:=0 to high(keys) do
 with keys[i] do
 begin


  if VType=vtInteger then
  begin
   if Vinteger<0 then
    raise EInvalidArgument.Create('Negative index');

   if (result.typ<>QJSON_ARRAY) and (result.typ<>QJSON_MAP) then //akkor csinálunk belõle
   if not create then
    raise EInvalidArgument.Create('Not an array')
   else
   begin
    if result.typ=QJSON_STRING then
     Dispose(result.strval);
    result.typ:=QJSON_ARRAY;
    New(result.arrval);
   end;

   if result.typ=QJSON_ARRAY then
   begin
    tmp:=Length(result.arrval^);
    if tmp<=VInteger then
     if not create then
     begin
      result:=@QJSON_NULLVAL; //return 0
      exit;
     end
     else
     begin
      Setlength(result.arrval^,VInteger+1);
      for j:=tmp to VInteger do
      begin
       New(result.arrval^[j]);
       result.arrval^[j].typ:=QJSON_NULL;
      end;
     end;

    result:=result.arrval^[VInteger];
   end
   else //ezek szerint MAP
   begin
    if Length(result.mapval^)<=VInteger then
     if not create then
     begin
      result:=@QJSON_NULLVAL; //return 0
      exit;
     end
     else
      raise EInvalidArgument.Create('Overindexed map');
    result:=result.mapval^[VInteger].data;
   end
  end
  else
  if (VType=vtString) or (VType=vtChar) or (VType=vtAnsiString) then
  begin
   if (VType=vtChar) then
    key:=VChar
   else
   if (VType=vtAnsiString) then
    key:=String(VAnsiString)
   else
    key:=VString^;

   if key='' then
    raise EInvalidArgument.Create('Zero length key string');

   if result.typ=QJSON_ARRAY then
    raise EInvalidArgument.Create('Array indexed with string');

   if (result.typ<>QJSON_MAP) then //akkor csinálunk belõle
   if not create then
    raise EInvalidArgument.Create('Not a map')
   else
   begin
    if result.typ=QJSON_STRING then
     Dispose(result.strval);
    result.typ:=QJSON_MAP;
    New(result.mapval);
   end;

   tmp:=-1;
   for j:=0 to high(result.mapval^) do
    if result.mapval^[j].key=key then
     tmp:=j;

   if tmp<0 then
    if not create then
    begin
     result:=@QJSON_NULLVAL; //return 0
     exit;
    end
    else
    begin
     tmp:=length(result.mapval^);
     setlength(result.mapval^,tmp+1);
     result.mapval^[tmp].key:=key;
     New(result.mapval^[tmp].data);
     result.mapval^[tmp].data.typ:=QJSON_NULL;
    end;
    result:=result.mapval^[tmp].data;
  end
  else
   raise EInvalidArgument.Create('Unknown key type');
 end;
end;

procedure TQJSON.Setval(keys:array of const;mire:integer);
var
data:PQJSONData;
begin
 data:=Resolve(root,keys,true);
 Clear(data);
 data.typ:=QJSON_INT;
 data.intval:=mire;
end;

procedure TQJSON.SetvalF(keys:array of const;mire:single);
var
data:PQJSONData;
begin
 data:=Resolve(root,keys,true);
 Clear(data);
 data.typ:=QJSON_FLOAT;
 data.floatval:=mire;
end;

procedure TQJSON.Setval(keys:array of const;mire:boolean);
var
data:PQJSONData;
begin
 data:=Resolve(root,keys,true);
 Clear(data);
 data.typ:=QJSON_BOOLEAN;
 data.boolval:=mire;
end;

procedure TQJSON.Setval(keys:array of const;mire:string);
var
data:PQJSONData;
begin
 data:=Resolve(root,keys,true);
 if data.typ<>QJSON_STRING then
 begin
  Clear(data);
  data.typ:=QJSON_STRING;
  New(data.strval);
 end;
 data.strval^:=mire;
end;

procedure TQJSON.Clear(data:PQJSONData);
var
i:integer;
begin
 if data.typ=QJSON_STRING then
  Dispose(data.strval)
 else
 if data.typ=QJSON_ARRAY then
 begin
  for i:=0 to High(data.arrval^) do
  begin
   Clear(data.arrval^[i]);
   Dispose(data.arrval^[i]);
  end;
  Dispose(data.arrval);
 end
 else
 if data.typ=QJSON_MAP then
 begin
  for i:=0 to High(data.mapval^) do
  begin
   Clear(data.mapval^[i].data);
   Dispose(data.mapval^[i].data);
  end;
  Dispose(data.mapval);
 end;
 data.typ:=QJSON_NULL;
end;

procedure TQJSON.Clear(keys:array of const);
var
data:PQJSONData;
begin
 data:=Resolve(root,keys,true);
 Clear(data);
end;

function TQJSON.GetInt(keys:array of const):integer;
var
data:PQJSONData;
begin
 data:=Resolve(root,keys);
 result:=0;
 with data^ do
 case typ of
   QJSON_NULL	:result:=0;
   QJSON_INT	:result:=intval;
   QJSON_FLOAT	:result:=round(floatval);
   QJSON_BOOLEAN:raise EConvertError.Create('Cant convert from bool to int');
   QJSON_STRING	:result:=StrToInt(strval^);
   QJSON_ARRAY	:raise EConvertError.Create('Cant convert from array to int');
   QJSON_MAP	:raise EConvertError.Create('Cant convert from map to int');
 end;
end;

function TQJSON.GetFloat(keys:array of const):double;
var
data:PQJSONData;
begin
 data:=Resolve(root,keys);
 result:=0;
 with data^ do
 case typ of
   QJSON_NULL	:result:=0;
   QJSON_INT	:result:=intval;
   QJSON_FLOAT	:result:=floatval;
   QJSON_BOOLEAN:raise EConvertError.Create('Cant convert from bool to float');
   QJSON_STRING	:result:=StrToFloat(strval^);
   QJSON_ARRAY	:raise EConvertError.Create('Cant convert from array to float');
   QJSON_MAP	:raise EConvertError.Create('Cant convert from map to float');
 end;
end;

function TQJSON.GetString(keys:array of const):string;
var
data:PQJSONData;
begin
 data:=Resolve(root,keys);
 with data^ do
 case typ of
   QJSON_NULL	:result:='';
   QJSON_INT	:result:=Inttostr(intval);
   QJSON_FLOAT	:result:=FloatToStrF(floatval,ffGeneral,12,1);
   QJSON_BOOLEAN:if boolval then result:='true' else result:='false';
   QJSON_STRING	:result:=strval^;
   QJSON_ARRAY	:raise EConvertError.Create('Cant convert from array to string');
   QJSON_MAP	:raise EConvertError.Create('Cant convert from map to string');
 end;
end;

function TQJSON.GetBool(keys:array of const):boolean;
var
data:PQJSONData;
begin
 data:=Resolve(root,keys);
 result:=false;
 with data^ do
 case typ of
   QJSON_NULL	:result:=false;
   QJSON_INT	:result:=intval=0;
   QJSON_FLOAT	:result:=floatval=0;
   QJSON_BOOLEAN:result:=boolval;
   QJSON_STRING	:result:=strval^='';
   QJSON_ARRAY	:raise EConvertError.Create('Cant convert from array to int');
   QJSON_MAP	:raise EConvertError.Create('Cant convert from map to int');
 end;
end;

function TQJSON.GetKey(keys:array of const;numkey:integer):string; //numerikusból text key-t csinál
var
data:PQJSONData;
begin
 data:=Resolve(root,keys);
 if data.typ<>QJSON_MAP then
  raise EInvalidArgument.Create('Only maps have keys');
 if numkey<0 then
  raise EInvalidArgument.Create('Negative key index');
 if numkey>High(data.mapval^) then
  raise EInvalidArgument.Create('Overindexed map');

 result:=data.mapval^[numkey].key;
end;

function TQJSON.GetNum(keys:array of const):integer;
var
data:PQJSONData;
begin
 data:=Resolve(root,keys);
 if data.typ=QJSON_MAP then
  result:=Length(data.mapval^)
 else
 if data.typ=QJSON_ARRAY then
  result:=Length(data.arrval^)
 else
  result:=0;
end;

end.
