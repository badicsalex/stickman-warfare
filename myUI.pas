unit myUI;

interface
uses Windows, SysUtils, typestuff, Direct3D9, D3DX9, directinput, sha1, math;

type
  Tmatteg = record
    mats:array[0..8] of D3DMatrix;
    //Color:cardinal;
    visible:boolean;
  end;

  Tglyph = record
    melyik:integer;
    x, y:single;
  end;

  T3DMenuitem = class(Tobject)
  public
    focused, focusable, handleschar:boolean;
    clicked:boolean;
    minx, miny, maxx, maxy, scale:single;
    elx, ely:single; //egérlent
    rect:Trect;
    value:single;
    valueS:string;

    color:cardinal;
    visible:boolean;
    procedure HandleChar(mit:char); virtual;
    procedure Draw(font:ID3DXFont;sprit:ID3DXSprite); virtual;
  end;

  T3DMIText = class(T3DMenuItem)
  public
    constructor create(aminx, aminy, amaxx, amaxy, scala:single;szoveg:string;fable:boolean);
    procedure Draw(font:ID3DXFont;sprit:ID3DXSprite); override;
  end;

  T3DMITextbox = class(T3DMenuItem)
  public
    hely:TD3DXVector3;
    mmat:TD3DMatrix;
    constructor create(aminx, aminy, amaxx, amaxy, scala:single;szoveg:string;maxs:integer);
    procedure HandleChar(mit:char); override;
    procedure Draw(font:ID3DXFont;sprit:ID3DXSprite); override;
  end;

  T3DMIcsuszka = class(T3DMenuItem)
    hely:TD3DXVector3;
    mmat, mmat2:TD3DMatrix;
    constructor create(aminx, aminy, amaxx, amaxy:single;value:single);
    procedure Draw(font:ID3DXFont;sprit:ID3DXSprite); override;
  end;

  T3DMIPasswordbox = class(T3DMITextbox)
  public
    sha1cnt:TSHA1Context;
    sha1hex:string;
    constructor create(aminx, aminy, amaxx, amaxy, scala:single;szoveghossz:integer;maxs:integer;asha1hex:string);
    procedure HandleChar(mit:char); override;
    function GetPasswordMD5:string;
  end;

  T3DMenu = class(Tobject)
  private
    g_pd3ddevice:IDirect3DDevice9;
  public
    g_pfont, g_pfontmini, g_pfontingame, g_pfontchat:ID3DXFont;
    fckep:IDirect3DTexture9;
    //   chatbubble:IDirect3DTexture9;
    glyphs, cglyphs:IDirect3DTexture9;
    chtalultex:IDirect3DTexture9;
    g_pSprite:ID3DXSprite;
    keyb, lastkeyb:array[0..255] of boolean;
    loaded:boolean;
    lap:integer;
    safemode:boolean;
    mousepos:TD3DXvector2;
    lowermenutext:String;
    sens:single;
    splashinfo:TD3DXImageInfo;
    splashwidth, splashheight:integer;
    splashratio:single;

    medal:string;
    medaltex:IDirect3DTexture9;
    medalanimstart:integer;
    medalstate:integer;


    divisor:integer;

    lclick, rclick, mclick:boolean;
    items:array[0..40] of array of T3DMenuItem;
    tegs:array[0..30] of array of Tmatteg;
    cursor, sarok, logo0, logo2:IDirect3DTexture9;
    splash:IDirect3DTexture9;
    el:boolean;
    constructor Create(aDevice:IDirect3DDevice9;sm:boolean);
    procedure FinishCreate;
    procedure Definishcreate;
    procedure HandleWMMouseMove(mit:lparam);
    procedure HandleWMLup; //WM_LBUTTONUP
    procedure HandleWMLdown;
    procedure HandleWMChar(mit:wparam);
    procedure AddText(aminx, aminy, amaxx, amaxy, scale:single;alap:integer;szoveg:string;fable:boolean);
    procedure AddTextBox(aminx, aminy, amaxx, amaxy, scale:single;alap:integer;szoveg:string;maxs:integer);
    procedure AddPasswordBox(aminx, aminy, amaxx, amaxy, scala:single;alap:integer;szoveghossz:integer;maxs:integer;amd5hex:string);
    procedure AddCsuszka(aminx, aminy, amaxx, amaxy, scale:single;alap:integer;szoveg:string;value:single);
    procedure Addteg(aminx, aminy, amaxx, amaxy:single;alap:integer);
    procedure Draw;
    procedure DrawKerekitett(mit:Tmatteg);
    procedure DrawLoadScreen(szazalek:byte);
    procedure DrawMedal;
    procedure DrawTextsInGame(texts:array of string;pos, pos2:array of TD3DXVector3;alpha:array of single;micro:boolean);
    procedure DrawGlyphsInGame(glyphsarr:array of Tglyph);
    procedure DrawChatsInGame(texts:array of string;pos:array of TD3DXVector3;alpha:array of single);
    procedure DrawChatGlyph(hash:cardinal;posx, posy:single;alpha:byte);
    procedure DrawText(mit:string;posx, posy, posx2, posy2:single;meret:byte;color:cardinal);
    procedure DrawMultilineText(mit:string;posx, posy, posx2, posy2:single;meret:byte;color:cardinal);
    procedure DrawSzinesChat(mit:string;posx, posy, posx2, posy2:single;color:cardinal;shadow:bool = false);
    procedure DrawRect(ax1, ay1, ax2, ay2:single;color:cardinal);
    destructor Destroy; reintroduce;
  protected
    procedure mousefocus;
    procedure mousedrag;
    procedure clickfocused;
  end;


  MFIEnumTyp = (MI_NEV, MI_TEAM, MI_FEGYV, MI_HEAD, MI_CONNECT, MI_REGISTERED, MI_PASS_LABEL,
    MI_GRAPHICS, MI_SOUND, MI_CONTROLS, MI_MOREGRAPHICS,
    MI_DETAIL, MI_EFFECTS, MI_WATER, MI_PARTICLE, MI_MOTIONBLUR, MI_GLOW, MI_RAIN, MI_SCREENSHOT, MI_IMPOSTER,
    MI_VOL, MI_MP3_VOL, MI_TAUNTS, MI_R_ACTION, MI_R_AMBIENT, MI_R_CAR,
    MI_MOUSE_SENS, MI_MOUSE_SENS_LAB, MI_MOUSE_ACC,
    MI_GAZMSG,
    MI_HEADBAL, MI_HEADJOBB,
    MI_INTERFACE, MI_RADAR, MI_CHAT, MI_ZONES, MI_TIPS,
    MI_SAVEPW,
    MI_TALLGRASS, MI_HDR, MI_BULLETHOLES, MI_MUZZLEFLASH, MI_GREYSCALE, MI_MINVX, MI_MINVY
    );
var
  menufi:array[MFIEnumTyp] of T3DMenuItem;
  menufipass:T3DMIPasswordBox;
implementation
var
  boxtex, feh, csusztex, csusz2tex:IDirect3DTexture9;
  //curpoi:Tpoint=(x:500;y:400);

procedure T3DMenuitem.Draw(font:ID3DXFont;sprit:ID3DXSprite);
begin
  //NAGY SEMMI
end;

procedure T3DMenuitem.HandleChar(mit:char);
begin
  //MÉG NAGYOBB SEMMI (ezért "virtual")
end;

constructor T3DMIText.create(aminx, aminy, amaxx, amaxy, scala:single;szoveg:string;fable:boolean);
begin
  inherited create;
  scale:=scala;
  minx:=aminx;miny:=aminy;maxx:=amaxx;maxy:=amaxy;
  rect.Left:=round(aminx * SCwidth);
  rect.Right:=round(amaxx * SCwidth);
  rect.top:=round(aminy * SCheight);
  rect.bottom:=round(amaxy * SCheight);
  ValueS:=szoveg;
  focusable:=fable;
  handleschar:=false;
  color:=color_menu_normal;
  visible:=true;
end;

procedure T3DMIText.Draw(font:ID3DXFont;sprit:ID3DXSprite);
var
  rect2:TRect;
begin
  if not visible then exit;visible:=true;
  if focused then
    font.DrawTextA(sprit, Pchar(ValueS), length(values), @rect, DT_CENTER or DT_VCENTER or DT_WORDBREAK, color_menu_select)
  else
  begin
    font.DrawTextA(sprit, Pchar(ValueS), length(values), @rect, DT_CENTER or DT_VCENTER or DT_WORDBREAK, $A0000000);
    rect2.Left:=Rect.Left - 2;
    rect2.Top:=Rect.Top - 2;
    rect2.Right:=Rect.Right - 2;
    rect2.Bottom:=Rect.Bottom - 2;
    font.DrawTextA(sprit, Pchar(ValueS), length(values), @rect2, DT_CENTER or DT_VCENTER or DT_WORDBREAK, color);
  end;
end;

constructor T3DMITextBox.create(aminx, aminy, amaxx, amaxy, scala:single;szoveg:string;maxs:integer);
begin
  inherited create;
  scale:=scala;
  minx:=aminx;miny:=aminy;maxx:=amaxx;maxy:=amaxy;
  rect.Left:=round(aminx * SCwidth) + round(5 * vertScale);
  rect.Right:=round(amaxx * SCwidth);
  rect.top:=round(aminy * SCheight + 1);
  rect.bottom:=round((amaxy - 0.01) * SCheight);
  hely:=D3DXVector3(aminx * SCwidth / ((amaxx - aminx) * SCwidth / 256), aminy * SCheight / ((amaxy - aminy) * SCheight / 32), 0);
  Value:=maxs;
  ValueS:=szoveg;
  focusable:=true;
  handleschar:=true;
  d3dxmatrixscaling(mmat, (amaxx - aminx) * SCwidth / 256, (amaxy - aminy) * SCheight / 32, 0);

  visible:=true;
end;

procedure T3DMITextBox.Draw(font:ID3DXFont;sprit:ID3DXSprite);
var
  rect2:Trect;
  mat2:TD3DMatrix;
  //center:TD3DXVector3;
begin
  if not visible then exit;visible:=true;

  sprit.GetTransform(mat2);
  sprit.SetTransform(mmat);
  sprit.Draw(boxtex, nil, nil, @hely, color_menu_normal);
  sprit.SetTransform(mat2);
  //font.DrawTextA(sprit,Pchar(ValueS),length(values),@rect,DT_VCENTER,color_menu_select);
  if clicked then
  begin
    if ((gettickcount mod 700) > 350) then
      font.DrawTextA(sprit, Pchar(ValueS + '|'), length(values) + 1, @rect, DT_VCENTER, color_menu_select)
    else
      font.DrawTextA(sprit, Pchar(ValueS), length(values), @rect, DT_VCENTER, color_menu_select);
  end
  else
  begin
    font.DrawTextA(sprit, Pchar(ValueS), length(values), @rect, DT_VCENTER, color_menu_normal);
  end;

end;

procedure T3DMITextBox.HandleChar(mit:char);
begin
  if mit = chr(VK_BACK) then
  begin
    ValueS:=copy(valueS, 0, length(valueS) - 1);
    exit;
  end;
  if mit = chr(VK_TAB) then exit;
  if mit = ' ' then mit:= '_';
  if length(ValueS) >= value then exit;
  //if (keycode>=low(DIKchar)) and (keycode<=high(DIKchar)) then
  ValueS:=ValueS + mit;
end;

const
  sha1so:string = 'luke, en vagyok az apad';
  sha1bors:string = 'mert ez egy jo hosszu salt';

constructor T3DMIPasswordBox.create(aminx, aminy, amaxx, amaxy, scala:single;szoveghossz:integer;maxs:integer;asha1hex:string);

begin
  inherited create(aminx, aminy, amaxx, amaxy, scala, stringofchar('*', szoveghossz), maxs);
  SHA1Init(sha1cnt);
  SHA1Update(sha1cnt, @sha1so[1], length(sha1so));
  sha1hex:=asha1hex;
  if not (lasthash = '-') then
    ValueS:= '********';
end;

procedure T3DMIPasswordBox.HandleChar(mit:char);
begin
  if mit = chr(VK_TAB) then exit;

  lasthash:= '-';


  if (mit = chr(VK_BACK)) or (sha1hex <> '') then
  begin
    ValueS:= '';
    sha1hex:= '';
    SHA1Init(sha1cnt);
    SHA1Update(sha1cnt, @sha1so[1], length(sha1so));
    if mit = chr(VK_BACK) then exit;
  end;

  if length(ValueS) < value then
    ValueS:=ValueS + '*';
  SHA1Update(sha1cnt, @mit, 1);
end;

function T3DMIPasswordBox.GetPasswordMD5:string;
var
  dig:TSHA1Digest;
begin
  if sha1hex <> '' then
    result:=sha1hex
  else
  begin
    if valueS <> '' then
    begin
      SHA1Update(sha1cnt, @sha1bors[1], length(sha1bors));
      SHA1Final(sha1cnt, dig);
      sha1hex:=SHA1GetHex(dig);
    end
    else
      //   sha1hex:='----------------------------------------';
      sha1hex:= '';
    result:=sha1hex;
  end;
end;


constructor T3DMIcsuszka.create(aminx, aminy, amaxx, amaxy:single;value:single);
var
  tmpm:TD3DMatrix;
begin
  inherited create;
  minx:=aminx;miny:=aminy;maxx:=amaxx;maxy:=amaxy;
  rect.Left:=round(aminx * SCwidth);
  rect.Right:=round(amaxx * SCwidth);
  rect.top:=round(aminy * SCheight);
  rect.bottom:=round(amaxy * SCheight);
  elx:=value;
  self.value:=value;
  focusable:=true;
  d3dxmatrixscaling(tmpm, (amaxx - aminx) * SCwidth / (256), (amaxy - aminy) * SCheight / 16 / 4, 0);
  D3DXMatrixTranslation(mmat, aminx * SCwidth / ((amaxx - aminx) * SCwidth / (256)), aminy * SCheight / ((amaxy - aminy) * SCheight / 16 / 4), 0);
  D3DXMatrixMultiply(mmat, mmat, tmpm);

  d3dxmatrixscaling(tmpm, (amaxx - aminx) * SCwidth / (256), (amaxy - aminy) * SCheight / 128, 0);
  D3DXMatrixTranslation(mmat2, aminx * SCwidth / ((amaxx - aminx) * SCwidth / (256)), aminy * SCheight / ((amaxy - aminy) * SCheight / 128), 0);
  D3DXMatrixMultiply(mmat2, mmat2, tmpm);


end;

procedure T3DMIcsuszka.Draw(font:ID3DXFont;sprit:ID3DXSprite);
var
  mat2:TD3DMatrix;
begin
  value:=elx;
  sprit.getTransform(mat2);
  sprit.SetTransform(mmat);

  hely:=D3DXVector3(0, -16, 0);
  sprit.Draw(csusz2tex, nil, @hely, nil, $FFFFFFFF);

  hely:=D3DXVector3(value * 256 - 8, 0, 0);
  sprit.SetTransform(mmat2);
  if focused then
    sprit.Draw(csusztex, nil, nil, @hely, color_menu_select)
  else
    sprit.Draw(csusztex, nil, nil, @hely, color_menu_normal);
  sprit.SetTransform(mat2);
end;


constructor T3DMenu.Create(aDevice:IDirect3DDevice9;sm:boolean);
var
  szam, splashnev:string;
begin
  inherited Create;
  safemode:=sm;
  lap:=0;
  loaded:=false;
  sens:=0.002;
  mousepos.x:=0.5;mousepos.y:=0.5;
  zeromemory(@keyb, sizeof(keyb));
  zeromemory(@lastkeyb, sizeof(lastkeyb));
  g_pd3ddevice:=aDevice;
  write(logfile, 'Loading fonts...');flush(logfile);
  if (AddFontResource('data\eurostar.ttf') = 0) then
    writeln(logfile, 'unsuccesful...');flush(logfile);
  write(logfile, 'font, ');flush(logfile);
  if FAILED(D3DXCreateFont(g_pD3dDevice, trunc(12 + 12 * (SCHeight / 600)), 0, FW_NORMAL, 0, FALSE, DEFAULT_CHARSET, OUT_STRING_PRECIS, PROOF_QUALITY, DEFAULT_PITCH or FF_SWISS, 'Eurostar Black Extended', g_pFont)) then
    if FAILED(D3DXCreateFont(g_pD3dDevice, trunc(15 + 15 * (SCHeight / 600)), 0, FW_BOLD, 0, FALSE, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, PROOF_QUALITY, DEFAULT_PITCH or FF_SWISS, 'Arial', g_pFont)) then
      Exit;
  write(logfile, 'fontmini, ');flush(logfile);
  if FAILED(D3DXCreateFont(g_pD3dDevice, trunc(9 + 9 * (SCHeight / 600)), 0, FW_NORMAL, 0, FALSE, DEFAULT_CHARSET, OUT_RASTER_PRECIS, PROOF_QUALITY, DEFAULT_PITCH or FF_SWISS, 'Verdana', g_pFontmini)) then
    Exit;
  write(logfile, 'fontingame, ');flush(logfile);
  if FAILED(D3DXCreateFont(g_pD3dDevice, trunc(12.5 + 12.5 * (SCHeight / 600)), 0, FW_NORMAL, 0, FALSE, DEFAULT_CHARSET, OUT_RASTER_PRECIS, PROOF_QUALITY, DEFAULT_PITCH or FF_SWISS, 'Verdana', g_pFontingame)) then
    Exit;
  writeln(logfile, 'fontchat.');flush(logfile);
  if FAILED(D3DXCreateFont(g_pD3dDevice, trunc(6.5 + 6.5 * (SCHeight / 600)), 0, FW_NORMAL, 0, FALSE, DEFAULT_CHARSET, OUT_RASTER_PRECIS, PROOF_QUALITY, DEFAULT_PITCH or FF_SWISS, 'Verdana', g_pFontchat)) then
    Exit;
  write(logfile, 'Other...');flush(logfile);
  if FAILED(D3DXCreateSprite(g_pd3dDevice, g_pSprite)) then
    Exit;
  writeln(logfile, 'Textures...');flush(logfile);
  if FAILED(D3DXCreateTextureFromFileEx(g_pd3dDevice, 'data/textures/feh.bmp', 2, 2, 0, 0, D3DFMT_X8R8G8B8, D3DPOOL_DEFAULT, D3DX_FILTER_NONE, D3DX_DEFAULT, 0, nil, nil, feh)) then
  begin
    writeln(logfile, 'Could not load data/textures/feh.bmp');flush(logfile);
    Exit;
  end;

  if FAILED(D3DXCreateTextureFromFileEx(g_pd3dDevice, 'data/gui/glyphs.bmp', 32, 32, 0, 0, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, D3DX_DEFAULT, D3DX_DEFAULT, $FF000000, nil, nil, glyphs)) then
  begin
    writeln(logfile, 'Could not load data/gui/glyphs.bmp');flush(logfile);
    Exit;
  end;

  if FAILED(D3DXCreateTextureFromFileEx(g_pd3dDevice, 'data/gui/cglyphs.png', 16, 16, 0, 0, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, D3DX_FILTER_POINT, D3DX_FILTER_POINT, 0, nil, nil, cglyphs)) then
  begin
    writeln(logfile, 'Could not load data/gui/cglyphs.png');flush(logfile);
    Exit;
  end;

  if FAILED(D3DXCreateTextureFromFileEx(g_pd3dDevice, 'data/gui/chtalul.bmp', 32, 32, 0, 0, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, D3DX_DEFAULT, D3DX_DEFAULT, $FF000000, nil, nil, chtalultex)) then
  begin
    writeln(logfile, 'Could not load data/gui/chtalul.bmp');flush(logfile);
    Exit;
  end;

  splashnev:=stuffjson.GetString(['splashes', random(stuffjson.GetNum(['splashes']))]);
  D3DXGetImageInfoFromFile(PChar('data/gui/' + splashnev), splashinfo); //feltételezzük, hogy egyformák a splashek

  splashratio:=splashinfo.Width / splashinfo.Height;
  splashwidth:=round(SCheight * splashratio);
  splashheight:=SCheight;
  divisor:=1;

  case texture_res of
    TEXTURE_COLOR:
      begin

      end;

    TEXTURE_SUPERLOW:
      begin
        divisor:=8;
      end;

    TEXTURE_LOW:
      begin
        divisor:=4;
      end;
    TEXTURE_MED:
      begin
        divisor:=2;
      end;
    TEXTURE_HIGH:
      begin

      end;
    TEXTURE_VERYHIGH:
      begin

      end;
  end;

  //  if divisor > 0 then
  begin
    splashwidth:=splashwidth div divisor;
    splashheight:=splashheight div divisor;
  end;

  if FAILED(D3DXCreateTextureFromFileEx(g_pd3dDevice, Pchar('data/gui/' + splashnev), splashwidth, splashheight, 0, 0, D3DFMT_X8R8G8B8, D3DPOOL_DEFAULT, D3DX_DEFAULT, D3DX_DEFAULT, 0, nil, nil, splash)) then
  begin
    writeln(logfile, 'Could not load data/gui/' + splashnev);flush(logfile);
    Exit;
  end;

  if FAILED(D3DXCreateTextureFromFileEx(g_pd3dDevice, 'data/gui/circ2.png', 16, 16, 0, 0, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, D3DX_DEFAULT, D3DX_DEFAULT, 0, nil, nil, sarok)) then
  begin
    writeln(logfile, 'Could not load data/gui/circ2.png');flush(logfile);
    Exit;
  end;

  loaded:=true;
end;

procedure T3DMenu.Finishcreate;
begin
  if FAILED(D3DXCreateTextureFromFileEx(g_pd3dDevice, 'data/gui/logo0.png', trunc(512 * vertScale), trunc(256 * vertScale), 0, 0, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, D3DX_DEFAULT, D3DX_DEFAULT, 0, nil, nil, logo0)) then
    Exit;

  if FAILED(D3DXCreateTextureFromFileEx(g_pd3dDevice, 'data/gui/4919.png', 256, 128, 0, 0, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, D3DX_DEFAULT, D3DX_DEFAULT, 0, nil, nil, logo2)) then
    Exit;

  if FAILED(D3DXCreateTextureFromFileEx(g_pd3dDevice, 'data/gui/cursor.png', 64, 64, 0, 0, D3DFMT_UNKNOWN, D3DPOOL_DEFAULT, D3DX_DEFAULT, D3DX_DEFAULT, 0, nil, nil, cursor)) then
    Exit;
  if FAILED(D3DXCreateTextureFromFileEx(g_pd3dDevice, 'data/gui/beiro.png', 250, 25, 0, 0, D3DFMT_UNKNOWN, D3DPOOL_DEFAULT, D3DX_DEFAULT, D3DX_DEFAULT, 0, nil, nil, boxtex)) then
    Exit;
  if FAILED(D3DXCreateTextureFromFileEx(g_pd3dDevice, 'data/gui/csuszka.png', 16, 128, 0, 0, D3DFMT_UNKNOWN, D3DPOOL_DEFAULT, D3DX_DEFAULT, D3DX_DEFAULT, 0, nil, nil, csusztex)) then
    Exit;
  if FAILED(D3DXCreateTextureFromFileEx(g_pd3dDevice, 'data/gui/cssin.png', 256, 32, 0, 0, D3DFMT_UNKNOWN, D3DPOOL_DEFAULT, D3DX_DEFAULT, D3DX_DEFAULT, 0, nil, nil, csusz2tex)) then
    Exit;

  splash:=nil;
end;

procedure T3DMenu.Definishcreate;
begin
  logo0:=nil;
  cursor:=nil;
  boxtex:=nil;
  csusztex:=nil;
  csusz2tex:=nil;
end;

destructor T3DMenu.Destroy;
var
  i, j:integer;
begin
  for i:=0 to high(items) do
  begin
    for j:=0 to high(items[i]) do
      items[i, j].Destroy;
    setlength(items[i], 0);
  end;
  if g_pfont <> nil then
    g_pfont:=nil;
  if g_psprite <> nil then
    g_psprite:=nil;
  if g_pd3ddevice <> nil then
    g_pd3ddevice:=nil;
  inherited;
end;

procedure T3DMenu.mousefocus;
var
  i:integer;
begin
  for i:=0 to high(items[lap]) do
  begin
    if items[lap, i].focusable and items[lap, i].visible then
      with items[lap, i].rect do
        if (Left < mousepos.x * SCwidth) and (Right > mousepos.x * SCwidth)
          and (top < mousepos.y * SCheight) and (Bottom > mousepos.y * SCheight) then
          items[lap, i].focused:=true
        else
          items[lap, i].focused:=false;
  end;
end;

procedure T3DMenu.mousedrag;
var
  i:integer;
begin
  for i:=0 to high(items[lap]) do
  begin
    if items[lap, i].focusable then
      with items[lap, i].rect do
        if (Left < mousepos.x * SCwidth) and (Right > mousepos.x * SCwidth)
          and (top < mousepos.y * SCheight) and (Bottom > mousepos.y * SCheight) then
        begin
          items[lap, i].elx:=(mousepos.x * SCwidth - left) / (right - left);
          items[lap, i].ely:=(mousepos.y * SCheight - top) / (bottom - top);
          if (lap = 4) and (i = 8) then
        end;
  end;
end;

procedure T3DMenu.clickfocused;
var
  i, j:integer;
begin
  for j:=lap to lap do
    for i:=0 to high(items[j]) do
      items[j, i].clicked:=items[j, i].focused;
end;


procedure T3DMenu.HandleWMChar(mit:wparam);
var
  i:integer;
begin
  if mit = VK_ESCAPE then
    case lap of
      0:lap:=3;
      1, 2:lap:=0;
      4, 5, 6, 7, 8:lap:=2; //TODO ezt frissíteni kell mindig
      3:items[3, 4].clicked:=true; //exit gomb
    end
  else
    if (mit = VK_TAB) and (lap = 1) then
    begin
      if not menufipass.clicked then
      begin
        menufi[MI_NEV].clicked:=false;
        menufi[MI_REGISTERED].clicked:=true;
      end
      else
      begin
        menufi[MI_NEV].clicked:=true;
        menufipass.clicked:=false;
      end;
    end
    else
      if (mit = VK_RETURN) and (lap = 1) and menufi[MI_CONNECT].focusable then menufi[MI_CONNECT].clicked:=true
      else
        if (mit = VK_RETURN) and (lap = 0) and items[0, 0].focusable then items[0, 0].clicked:=true // Connect! gomb
        else
          for i:=0 to high(items[lap]) do
            if items[lap, i].clicked and items[lap, i].handleschar then
              items[lap, i].HandleChar(chr(mit));
end;

procedure T3DMenu.HandleWMLup;
begin
  clickfocused;
  el:=false;
end;

procedure T3DMenu.HandleWMLdown;
begin
  el:=true;
  mousedrag;
end;

procedure T3DMenu.HandleWMMouseMove(mit:lparam);
var
  x, y:integer;
begin
  x:=word(mit);
  y:=cardinal(mit) shr 16;
  { if (x<>curpoi.x) or (y<>curpoi.y) then
   begin
    if setcpos then
    begin
     curpoi.x:=x;
     curpoi.y:=y;
     setcpos:=false;
    end
    else
    begin
     setcursorpos(500,400);
     setcpos:=true;
    end;
   end;  }
  mousepos.x:=(x / SCWidth) * 0.95;
  mousepos.y:=(y / SCHeight) * 0.95;
  {mousepos.x:=mousepos.x+((x-curpoi.x)/SCWidth);
  mousepos.y:=mousepos.y+((y-curpoi.y)/SCHeight);
  if mousepos.x<0 then mousepos.x:=0;
  if mousepos.y<0 then mousepos.y:=0;
  if mousepos.x>0.95 then mousepos.x:=0.95;
  if mousepos.y>0.95 then mousepos.y:=0.95; }
  mousefocus;
  if el then mousedrag;
end;

procedure T3DMenu.DrawKerekitett(mit:Tmatteg);
const
  tegs:array[0..8] of Trect =
    ((Left:0;Top:0;Right:8;Bottom:8),
    (Left:7;Top:0;Right:8;Bottom:8),
    (Left:8;Top:0;Right:16;Bottom:8),

    (Left:0;Top:7;Right:8;Bottom:8),
    (Left:7;Top:7;Right:8;Bottom:8),
    (Left:8;Top:7;Right:16;Bottom:8),

    (Left:0;Top:8;Right:8;Bottom:16),
    (Left:7;Top:8;Right:8;Bottom:16),
    (Left:8;Top:8;Right:16;Bottom:16));
var
  i:integer;
begin
  for i:=0 to MENULAP_MAX do
  begin
    g_pSprite.SetTransform(mit.mats[i]);
    g_psprite.draw(sarok, @(tegs[i]), nil, nil, $FFFFFFFF);
  end;
  g_pSprite.SetTransform(identmatr);
end;



procedure T3DMenu.DrawMedal;
var
  y:single;

  mat, mat2:TD3DMatrix;
  apos:TD3DXvector3;
  pCenter:TD3DXVector3;
begin

  //divisor:=2;
  D3DXMatrixScaling(mat, divisor, divisor, divisor);
  d3dxmatrixtranslation(mat2, -SCWidth / 2 * divisor + SCWidth / 2, -SCHeight / 2 * divisor + SCHeight / 2, 0);
  d3dxmatrixmultiply(mat, mat, mat2);

  g_pSprite.SetTransform(mat);

  //  state := GetTickCount - medalanimstart;
  medalstate:=medalstate + 10;

  if medalstate > 2000 then
  begin
    medalanimstart:=0;
    medalstate:=0;
    medaltex:=nil;
  end;

  if (medalstate >= 400) and (medalstate <= 1600) then y:=0.5
  else
    if medalstate < 400 then y:=1.0 - (medalstate / 800)
    else
      if medalstate > 1600 then y:=0.5 + ((medalstate - 1600) / 800);

  apos:=D3DXVector3(SCWidth / 2, SCHeight * y, 0);

  pCenter:=D3DXVector3(100/divisor, 0, 0);

  g_pSprite.Draw(medaltex, nil, @pCenter, @apos, $FFFFFFFF);

  g_pSprite.SetTransform(identmatr);

end;


procedure T3DMenu.Draw;
var
  a:single;
  i:integer;
  mat:TD3DMatrix;
  apos:TD3DXvector3;
  AlphaValue:DWORD;
begin

  //g_pd3dDevice.Clear(0, nil, D3DCLEAR_TARGET or D3DCLEAR_ZBUFFER, $FFFFFFFF, 1.0, 0);

    // Begin the scene
  if SUCCEEDED(g_pd3dDevice.BeginScene) then
  begin
    g_pSprite._Begin(D3DXSPRITE_ALPHABLEND);
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_NONE); {
    AlphaValue := D3DCOLOR_ARGB(trunc(opacity*256),255,255,255);

    g_pd3dDevice.SetTextureStageState(0, D3DTSS_CONSTANT, AlphaValue);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_CONSTANT);  {}
    g_pSprite.SetTransform(identmatr);

    apos:=D3DXVector3(SCwidth / 2 - trunc(256 * vertScale), -trunc(45 * vertScale), 0);
    g_pSprite.Draw(logo0, nil, nil, @apos, $FFFFFFFF);

    apos:=D3DXVector3(SCwidth - 192 - trunc(64 * vertScale), SCheight - 50 - trunc(50 * vertScale), 0);
    g_pSprite.Draw(logo2, nil, nil, @apos, $FFFFFFFF);

    for i:=0 to high(tegs[lap]) do
      if tegs[lap, i].visible then
        drawkerekitett(tegs[lap, i]);

    for i:=0 to high(items[lap]) do
    begin
      g_pSprite.SetTransform(identmatr);
      if items[lap, i].scale > 0.7 then
        items[lap, i].Draw(g_pFont, g_pSprite)
      else
        items[lap, i].Draw(g_pFontmini, g_pSprite)
    end;

    g_pSprite.SetTransform(identmatr);

    Drawtext(lowermenutext, 0.005, 0.98, 1, 1, 0, color_menu_info);
    Drawtext('v2.' + inttostr((PROG_VER div 1000) mod 100) + '.' + inttostr((PROG_VER div 10) mod 100) + '.', 0.8, 0.85, 1, 0.9, 1, color_menu_info);


    apos:=D3DXVector3(0.5 * SCwidth + 0.32 * SCheight - vertScale * 32, SCheight * 0.62 - vertScale * 32, 0);
    if lap = 1 then g_psprite.Draw(fckep, nil, nil, @apos, $FFFFFFFF);


    apos:=D3DXVector3(-mousepos.x * SCwidth, -mousepos.y * SCheight, 0);

    g_pSprite.Draw(cursor, nil, @apos, nil, $FFFFFFFF);
    g_pSprite._End;
    g_pd3dDevice.EndScene;
  end;
  // Present the backbuffer contents to the display
//  g_pd3dDevice.Present(nil, nil, 0, nil);
end;

procedure T3DMenu.DrawTextsInGame(texts:array of string;pos, pos2:array of TD3DXVector3;alpha:array of single;micro:boolean);
var
  i:integer;
  mat:TD3DMatrix;
  rect:TRect;
  a:single;
  cent:TD3DXVector2;
begin
  for I:=low(texts) to high(texts) do
  begin
    noNANINF(pos[i]);
    noNANINF(pos2[i]);
  end;

  for I:=low(texts) to high(texts) do
    if (pos[i].x > -500) and (pos[i].x < SCWidth + 500) and
      (pos[i].y > -500) and (pos[i].y < SCHeight + 500) and
      (pos[i].z < 1) then
    begin
      a:= -(pos2[i].y - pos[i].y) / 40;
      //     if a<1/40 then continue;
      mat._11:=a;mat._12:=0;mat._13:=0;mat._14:=0;
      mat._21:=0;mat._22:=a;mat._23:=0;mat._24:=0;
      mat._31:=0;mat._32:=0;mat._33:=a;mat._34:=0;
      mat._41:=pos[i].x;mat._42:=pos[i].y;mat._43:=0;mat._44:=1;

      g_pSprite.SetTransform(mat);
      rect.Left:= -200;
      rect.right:= +200;
      rect.top:= -20;
      rect.bottom:=0;

      //    if isTyping[i] then
      //    begin
      //    cent.x := -35;
      //    cent.y := -70;
      //    g_pSprite.Draw(chatbubble,nil,nil,@cent,$FFFFFFFF);
      //    end;

      if micro then
        g_pfontchat.DrawTextA(g_psprite, Pchar(texts[i]), length(texts[i]), @rect, DT_VCENTER or DT_CENTER, round(alpha[i] * $FF) * $1000000 + betuszin)
      else
        g_pfontmini.DrawTextA(g_psprite, Pchar(texts[i]), length(texts[i]), @rect, DT_VCENTER or DT_CENTER, round(alpha[i] * $FF) * $1000000 + betuszin)
    end;
end;



procedure T3DMenu.DrawChatsInGame(texts:array of string;pos:array of TD3DXVector3;alpha:array of single);
var
  i:integer;
  rect:array of TRect;
  wdt:integer;

begin
  setlength(rect, length(texts));
  for I:=low(texts) to high(texts) do
  begin
    noNANINF(pos[i]);
  end;

  for I:=low(texts) to high(texts) do
    if (pos[i].x > -500) and (pos[i].x < SCWidth + 500) and
      (pos[i].y > -500) and (pos[i].y < SCHeight + 500) and
      (pos[i].z < 1) and (texts[i] <> '') then
    begin
      pos[i].y:=pos[i].y - 32;
      pos[i].z:=0;
      //pos[i].z:=0.0;
      { a:=1;
       mat._11:=a;mat._12:=0;mat._13:=0;mat._14:=0;
       mat._21:=0;mat._22:=a;mat._23:=0;mat._24:=0;
       mat._31:=0;mat._32:=0;mat._33:=a;mat._34:=0;
       mat._41:=1;mat._42:=1;mat._43:=0;mat._44:=1;   }
      rect[i].left:=0;
      rect[i].top:=0;
      rect[i].right:=300;
      rect[i].Bottom:=1000;

      g_pfontmini.DrawTextA(g_psprite, Pchar(texts[i]), length(texts[i]), @(rect[i]), DT_CALCRECT or DT_WORDBREAK, $FFFFFF00);
      wdt:=rect[i].right - rect[i].left;
      rect[i].left:=round(pos[i].x - wdt / 2);
      rect[i].right:=round(pos[i].x + wdt / 2);
      rect[i].Top:=2 * rect[i].top - rect[i].bottom + round(pos[i].y);
      rect[i].Bottom:=round(pos[i].y);
      drawrect(rect[i].left / SCwidth, rect[i].top / SCheight, rect[i].right / SCwidth, rect[i].bottom / SCHeight, round(alpha[i] * $A0) * $1000000);
    end;

  g_psprite.Flush;
  g_pSprite.SetTransform(identmatr);

  for I:=low(texts) to high(texts) do
    if (pos[i].x > -500) and (pos[i].x < SCWidth + 500) and
      (pos[i].y > -500) and (pos[i].y < SCHeight + 500) and
      (pos[i].z < 1) and (texts[i] <> '') then
    begin
      g_pfontmini.DrawTextA(g_psprite, Pchar(texts[i]), length(texts[i]), @(rect[i]), DT_WORDBREAK, round(alpha[i] * $FF) * $1000000 + $FFFFFF);
      {if pos[i].x>1 then  }
      g_psprite.Draw(chtalultex, nil, nil, @(pos[i]), round(alpha[i] * $A0) * $1000000);
    end;
end;


procedure T3Dmenu.drawglyphsingame(glyphsarr:array of Tglyph);
var
  i:integer;
  src:Trect;
  cent:TD3DXVector2;
begin
  for i:=0 to high(glyphsarr) do
  begin

    src.Top:=(glyphsarr[i].melyik mod 2) * 16;
    src.Left:=(glyphsarr[i].melyik div 2) * 16;
    src.Bottom:=src.top + 16;
    src.Right:=src.left + 16;

    cent.x:=glyphsarr[i].x - 8;
    cent.y:=glyphsarr[i].y - 8;
    g_psprite.Draw(glyphs, @src, nil, @cent, $FFFFFFFF);

  end;
end;

procedure T3DMenu.DrawChatGlyph(hash:cardinal;posx, posy:single;alpha:byte);
var
  minta:array[0..3] of integer;
  i:integer;
  pos:TD3DXVector3;
  src:TRect;
begin
  for i:=0 to 3 do
  begin
    minta[i]:=hash mod 16;
    hash:=hash div 16;
  end;
  pos.z:=0;
  posx:=round(posx * SCWidth);
  posy:=round(posy * SCHeight);
  hash:=(hash * 674506111) and $FFFFFF; {szin} {vkek=756065159}
  for i:=0 to 3 do
  begin
    pos.x:=posx - (i mod 2) * 4;
    pos.y:=posy - (i div 2) * 4;
    src.Left:=(minta[i] mod 4) * 4;
    src.Top:=(minta[i] div 4) * 4;
    src.Right:=src.Left + 4;
    src.Bottom:=src.Top + 4;
    g_psprite.Draw(cglyphs, @src, nil, @pos, (alpha shl 24) + hash);
  end;
end;

procedure T3DMenu.DrawText(mit:string;posx, posy, posx2, posy2:single;meret:byte;color:cardinal);
var
  rect:TRect;
begin
  if mit = '' then exit;
  rect.Top:=round(posy * SCheight);rect.Bottom:=round(posy2 * SCheight);
  rect.Left:=round(posx * SCwidth);rect.Right:=round(posx2 * SCwidth);
  case meret of
    0:
      begin
        g_pfontchat.DrawTextA(g_psprite, Pchar(mit), length(mit), @rect, DT_NOCLIP, color);
      end;
    1:
      begin
        g_pfontingame.DrawTextA(g_psprite, Pchar(mit), length(mit), @rect, DT_CENTER + DT_NOCLIP, color);
      end;
    2:
      begin
        g_pfont.DrawTextA(g_psprite, Pchar(mit), length(mit), @rect, DT_CENTER + DT_NOCLIP, $A0000000);
        rect.Left:=Rect.Left - 2;
        rect.Top:=Rect.Top - 2;
        rect.Right:=Rect.Right - 2;
        rect.Bottom:=Rect.Bottom - 2;
        g_pfont.DrawTextA(g_psprite, Pchar(mit), length(mit), @rect, DT_CENTER + DT_NOCLIP, color);
      end;
  end;
end;

procedure T3DMenu.DrawMultilineText(mit:string;posx, posy, posx2, posy2:single;meret:byte;color:cardinal);
var
  rect:TRect;
begin
  if mit = '' then exit;
  rect.Top:=round(posy * SCheight);rect.Bottom:=round(posy2 * SCheight);
  rect.Left:=round(posx * SCwidth);rect.Right:=round(posx2 * SCwidth);
  case meret of
    0:g_pfontchat.DrawTextA(g_psprite, Pchar(mit), length(mit), @rect, DT_CENTER or DT_VCENTER or DT_WORDBREAK, color);
    1:g_pfontmini.DrawTextA(g_psprite, Pchar(mit), length(mit), @rect, DT_CENTER or DT_VCENTER or DT_WORDBREAK, color);
    2:
      begin
        g_pfont.DrawTextA(g_psprite, Pchar(mit), length(mit), @rect, DT_CENTER or DT_VCENTER or DT_WORDBREAK, $A0000000);
        rect.Left:=Rect.Left - 2;
        rect.Top:=Rect.Top - 2;
        rect.Right:=Rect.Right - 2;
        rect.Bottom:=Rect.Bottom - 2;
        g_pfont.DrawTextA(g_psprite, Pchar(mit), length(mit), @rect, DT_CENTER or DT_VCENTER or DT_WORDBREAK, color);
      end;
  end;
end;


procedure T3DMenu.DrawSzinesChat(mit:string;posx, posy, posx2, posy2:single;color:cardinal;shadow:bool = false);
var
  rect, crect, rect2:TRect;
  str:string;
  escapepos:integer;
  nextcolor:integer;
  alpha2:integer;
  i, j:integer;
begin
  rect.Top:=round(posy * SCheight);rect.Bottom:=round(posy2 * SCheight);
  rect.Left:=round(posx * SCwidth);rect.Right:=round(posx2 * SCwidth);

  nextcolor:=color;
  alpha2:=(color shr 2) and $FF000000;
  while length(mit) > 0 do
  begin
    escapepos:=pos(chr(17), mit);
    if escapepos > 0 then
    begin
      str:=copy(mit, 1, escapepos - 1);
      if length(mit) >= escapepos + 1 then
        nextcolor:=Palettetorgb(ord(mit[escapepos + 1]), color shr 24);
      mit:=copy(mit, escapepos + 2, 1000);
    end
    else
    begin
      str:=mit;
      mit:= '';
    end;

    if length(str) > 0 then
    begin
      rect2:=rect;

      if shadow then begin
        rect2.Right:=rect.Right + 1;
        rect2.Bottom:=rect.Bottom + 1;
        g_pfontchat.DrawTextA(g_psprite, Pchar(str), length(str), @rect2, DT_NOCLIP, $55FFFFFF);
        rect2:=rect;
        rect2.Top:=rect.Top + 1;
        rect2.Left:=rect.Left + 1;
        g_pfontchat.DrawTextA(g_psprite, Pchar(str), length(str), @rect2, DT_NOCLIP, $55FFFFFF);
      end;

      g_pfontchat.DrawTextA(g_psprite, Pchar(str), length(str), @rect, DT_NOCLIP, color); //COLOR!!!

      zeromemory(@crect, sizeof(crect));
      if str[length(str)] = ' ' then
        str[length(str)]:= 'l'; //lol trailing space hack
      g_pfontchat.DrawTextA(g_psprite, Pchar(str), length(str), @crect, DT_NOCLIP + DT_CALCRECT, color);
      rect.Left:=rect.Left + crect.Right;
    end;
    color:=nextcolor;
  end;

end;

procedure T3DMenu.DrawLoadScreen(szazalek:byte);
var
  mat:TD3DMatrix;
  mat2:TD3DMatrix;
  apos:TD3DXVector3;
  fullrect:Trect;
  shift, ratio:single;
begin
  if szazalek <= 100 then
    g_pd3dDevice.Clear(0, nil, D3DCLEAR_TARGET or D3DCLEAR_ZBUFFER,
      $FF000000, 1.0, 0);
  // Begin the scene
  if SUCCEEDED(g_pd3dDevice.BeginScene) then
  begin
    //    D3DXMatrixIdentity(mat);

    D3DXMatrixScaling(mat, divisor, divisor, divisor);
    d3dxmatrixtranslation(mat2, -SCWidth / 2 * divisor + SCWidth / 2, 0, 0);
    d3dxmatrixmultiply(mat, mat, mat2);
    g_pSprite._Begin(D3DXSPRITE_ALPHABLEND);
    if szazalek <= 100 then
    begin
      g_psprite.SetTransform(mat);
      apos:=D3DXVector3((SCwidth - splashwidth) / 2, 0, 0);
      fullrect.Left:=0;
      fullrect.Top:=0;
      fullrect.Right:=800;
      fullrect.Bottom:=600;
      g_pSprite.Draw(splash, nil, nil, @apos, $FFFFFFFF);

      ratio:=SCheight * 4 / 3 / SCwidth;
      shift:=(1 - ratio) / 2;

    end;
    d3dxmatrixtranslation(mat, -20, -15, 0);
    g_pSprite.SetTransform(mat);
    if szazalek <= 100 then
    begin
      Drawtext(lang[32] + ' ' + inttostr(szazalek) + '%   ' + laststate, shift + 0.17 + pixelX, 0.97 + pixelY, shift + 0.6, 1, 0, $88000000);
      Drawtext(lang[32] + ' ' + inttostr(szazalek) + '%   ' + laststate, shift + 0.17, 0.97, shift + 0.6, 1, 0, color_menu_normal);
      //if szazalek<=100 then
      //Drawtext(txt,0.2,0.6,0.8,0.7,0,color_menu_normal);
      DrawRect(shift + ratio * 0.11, 0.932, shift + ratio * (0.11 + 0.3 * 100 * 0.015), 0.936, color_menu_normal);
      DrawRect(shift + ratio * 0.11, 0.928, shift + ratio * (0.11 + 0.3 * szazalek * 0.015), 0.94, color_menu_normal);
      DrawRect(shift + ratio * 0.11 + pixelX, 0.928 + pixelY, shift + ratio * (0.11 + 0.3 * szazalek * 0.015) - pixelX, 0.94 - pixelY, D3DXColorToDWord(D3DXColor(D3DXColorFromDWord(color_menu_normal).r * 1.5, D3DXColorFromDWord(color_menu_normal).g * 1.5, D3DXColorFromDWord(color_menu_normal).b * 1.5, D3DXColorFromDWord(color_menu_normal).a))); //todo $FFF89030

    end;


    //  Drawtext(inttostr(g_pd3ddevice.GetAvailableTextureMem div (1024*1024)),0.4,0.7,0.6,0.8,1,$FF70C0FF);
    g_pSprite._End;
    g_pd3dDevice.EndScene;
  end;
  // Present the backbuffer contents to the display
  g_pd3dDevice.Present(nil, nil, 0, nil);
end;


procedure T3DMenu.drawrect(ax1, ay1, ax2, ay2:single;color:cardinal);
var
  matika:TD3DMatrix;
begin
  with matika do
  begin
    _11:=int((ax2 - ax1) * SCwidth / 2);_12:=0;_13:=0;_14:=0;
    _21:=0;_22:=int((ay2 - ay1) * SCHeight / 2);_23:=0;_24:=0;
    _31:=0;_32:=0;_33:=0;_34:=0;
    _41:=int(ax1 * SCWidth);_42:=int(ay1 * SCHeight);_43:=0;_44:=1;
  end;
  g_pSprite.SetTransform(matika);
  g_psprite.draw(feh, nil, nil, nil, color);
end;

procedure T3DMenu.AddText(aminx, aminy, amaxx, amaxy, scale:single;alap:integer;szoveg:string;fable:boolean);
begin
  setlength(items[alap], length(items[alap]) + 1);
  items[alap, high(items[alap])]:=T3DMIText.create(aminx, aminy, amaxx, amaxy, scale, szoveg, fable);
end;

procedure T3DMenu.AddTextBox(aminx, aminy, amaxx, amaxy, scale:single;alap:integer;szoveg:string;maxs:integer);
begin
  setlength(items[alap], length(items[alap]) + 1);
  items[alap, high(items[alap])]:=T3DMITextbox.create(aminx, aminy, amaxx, amaxy, scale, szoveg, maxs);
end;

procedure T3DMenu.AddPasswordBox(aminx, aminy, amaxx, amaxy, scala:single;alap:integer;szoveghossz:integer;maxs:integer;amd5hex:string);
begin
  setlength(items[alap], length(items[alap]) + 1);
  items[alap, high(items[alap])]:=T3DMIPasswordbox.create(aminx, aminy, amaxx, amaxy, scala, szoveghossz, maxs, amd5hex);
end;

procedure T3DMenu.AddCsuszka(aminx, aminy, amaxx, amaxy, scale:single;alap:integer;szoveg:string;value:single);
begin
  setlength(items[alap], length(items[alap]) + 1);
  items[alap, high(items[alap])]:=T3DMICsuszka.create(aminx, aminy, amaxx, amaxy, value);
end;

procedure T3DMenu.AddTeg(aminx, aminy, amaxx, amaxy:single;alap:integer);
var
  i:integer;
begin

  if (alap<(MENULAP_MAX - 1)) or (length(tegs[alap]) = 0) then //TAB vagy label és üres
    setlength(tegs[alap], length(tegs[alap]) + 1);

  with tegs[alap, high(tegs[alap])] do
  begin

    for i:=0 to 8 do
      with mats[i] do
      begin
        _12:=0;_13:=0;_14:=0;
        _21:=0;_23:=0;_24:=0;
        _31:=0;_32:=0;_33:=1;_34:=0;
        _43:=0;_44:=1;

        if (i = 1) or (i = 4) or (i = 7) then
          _11:=(amaxx - aminx) * SCwidth
        else
          _11:=1;

        if (i = 3) or (i = 4) or (i = 5) then
          _22:=(amaxy - aminy) * SCHeight
        else
          _22:=1;

        if (i = 2) or (i = 5) or (i = 8) then
          _41:=amaxx * SCWidth
        else
          if (i = 1) or (i = 4) or (i = 7) then
            _41:=aminx * SCWidth
          else
            _41:=aminx * SCWidth - 8;

        if (i = 6) or (i = 7) or (i = 8) then
          _42:=amaxy * SCHeight
        else
          if (i = 3) or (i = 4) or (i = 5) then
            _42:=aminy * SCHeight
          else
            _42:=aminy * SCHeight - 8;


      end;
  end;
  tegs[alap, high(tegs[alap])].visible:=true;
end;

end.

