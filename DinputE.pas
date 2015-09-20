unit DinputE;
interface
uses windows,typestuff,directinput;
type
 TDinputEasy = class (TObject)
   protected
    Dinp:IDIRECTINPUT8;
    keybrd,mous:IDirectinputdevice8;
    mousespeed:single;
    mmex,mmey:single;
    procedure AccelerateMouse;
   public

    vmouss,mouss:DIMousestate;
    betoltve:boolean;
    MouseAcceleration:boolean;
    MouseSensitivity:single;
    MousMovX,MousMovY,MousMovScrl:single;
    vkeys,keys:TKeyArray;

    function keyd(mit:byte):boolean;
    function keyd2(mit:byte):boolean;
    function keyprsd(mit:byte):boolean;
    constructor Create(hwnd:THandle);
    destructor Destroy;reintroduce;
    procedure Update(cpos:Tpoint);
    procedure Reset;
   end;

implementation

constructor TDinputEasy.Create(hwnd:THandle);
begin
inherited Create;
betoltve:=false;
if FAILED(directinput8create(getmodulehandle(nil),DIRECTINPUT_VERSION,IID_IDirectInput8,Dinp,nil)) then exit;
if FAILED(Dinp.CreateDevice(GUID_SysKeyboard,keybrd, nil)) then exit;
if FAILED(keybrd.SetDataFormat(c_dfDIKeyboard)) then exit;
if FAILED(keybrd.SetCooperativeLevel(hWND,DISCL_BACKGROUND+DISCL_NONEXCLUSIVE)) then exit;
if FAILED(keybrd.Acquire) then exit;

if FAILED(Dinp.CreateDevice(GUID_SysMouse,mous,nil)) then exit;
if FAILED(mous.SetDataFormat(c_dfDIMouse)) then exit;
if FAILED(mous.SetCooperativeLevel(hWND,DISCL_BACKGROUND+DISCL_NONEXCLUSIVE)) then exit;;
if FAILED(mous.Acquire) then exit;
betoltve:=true;
MouseAcceleration:=true;
end;

destructor TDinputEasy.Destroy;
begin
//stuff
 if keybrd<> nil then
 keybrd:=nil;
 if mous<> nil then
 mous:=nil;
 if Dinp<> nil then
 Dinp:=nil;
inherited;
end;


procedure TDinputEasy.AccelerateMouse;
const
falloff=0.5;
szorzo=0.01;
var
seb:single;
tmpx,tmpy:single;
begin
 tmpx:=mousmovx;
 tmpy:=mousmovy;
 mmex:=mousmovx;
 mmey:=mousmovy;
 seb:=sqrt(sqr(tmpx+mmex)+sqr(tmpy+mmey));
 mousespeed:=mousespeed*falloff+seb*(1-falloff);
 Mousmovx:=(Mousmovx)*0.8*(1+mousespeed*szorzo);
 Mousmovy:=(Mousmovy)*0.8*(1+mousespeed*szorzo);
end;


procedure TDinputEasy.Update(cpos:Tpoint);
begin
 vkeys:=keys;
 vmouss:=mouss;
 keybrd.GetDeviceState(sizeof(keys),pointer(@keys));
 mous.GetDeviceState(sizeof(mouss),pointer(@mouss));
 mousmovx:=mouss.lX*Mousesensitivity*mouseInvX;
 mousmovy:=mouss.lY*Mousesensitivity*mouseInvY;
 mousmovscrl:=mouss.lZ;
 if mouseacceleration then AccelerateMouse;
 if (cpos.x>0) and (cpos.y>0) then
 setcursorpos(cpos.x,cpos.y);
end;

function TDinputEasy.keyd(mit:byte):boolean;
begin
 result:=(keys[mit] and $80)=$80;
end;

function TDinputEasy.keyprsd(mit:byte):boolean;
begin
 result:=((vkeys[mit] and $80)=$80) and ((keys[mit] and $80)=$0);
end;

function TDinputEasy.keyd2(mit:byte):boolean;
begin
 result:=((vkeys[mit] and $80)=$00) and ((keys[mit] and $80)=$80);
end;

procedure TDinputEasy.Reset;
begin
 zeromemory(pointer(@keys),sizeof(keys));
 zeromemory(pointer(@mouss),sizeof(mouss));
 vkeys:=keys;
 vmouss:=mouss;
 mousmovx:=0;
 mousmovy:=0;
 mousmovscrl:=0;
end;

end.
