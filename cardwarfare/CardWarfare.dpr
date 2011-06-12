program CardWarfare;
uses
  Windows,
  Messages,
  MMSystem,
  Direct3D9,
  D3DX9,
  fiz2,
  typestuff,
  cardsdll,
  Graphics;
type
  PCardvertex = ^TCardvertex;
  TCardvertex = packed record
    position: TD3DXVector3; // The position
    color:    TD3DColor;    // The color
    tu, tv:       Single;   // The texture coordinates
  end;

  PCardvertexArray = ^TCardvertexArray;
  TCardvertexArray = array [0..0] of TCardvertex;


var
  //Rendering Interfaces cumó
  g_pD3D:        IDirect3D9              = nil; // Used to create the D3DDevice
  g_pd3dDevice:  IDirect3DDevice9        = nil; // Our rendering device
  g_pVB:         IDirect3DVertexBuffer9  = nil; // Buffer to hold vertices
  g_pTexture:    IDirect3DTexture9       = nil; // Our texture

  
  //Rendering számos cumó
  matWorld, matView,matViewInv, matProj: TD3DMatrix;
  vEyePt, vLookatPt, vUpVec: TD3DVector;

  //Kártyák nagy cumó
  hanyszor:integer;
  cszam:integer=0;
  kartyu,kartyv:single;
  cpx,cpz:single;
  cursor:Tpoint;
  cursor2:TD3DXVector3;

/////////////////////////////////////////////////
/////////////////////////////////////////////////
//////////////////////BEGIN//////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////


const
  // Our custom FVF, which describes our custom vertex structure

  D3DFVF_Cardvertex = D3DFVF_XYZ or D3DFVF_DIFFUSE or D3DFVF_TEX1;


//-----------------------------------------------------------------------------
// Name: InitD3D()
// Desc: Initializes Direct3D
//-----------------------------------------------------------------------------
function InitD3D(hWnd: HWND): HRESULT;
var
  d3dpp: TD3DPresentParameters;
begin
  Result:= E_FAIL;

  // Create the D3D object.
  g_pD3D := Direct3DCreate9(D3D_SDK_VERSION);
  if (g_pD3D = nil) then Exit;

  // Set up the structure used to create the D3DDevice. Since we are now
  // using more complex geometry, we will create a device with a zbuffer.
  FillChar(d3dpp, SizeOf(d3dpp), 0);
  d3dpp.Windowed := True;
  d3dpp.SwapEffect := D3DSWAPEFFECT_DISCARD;
  d3dpp.BackBufferFormat := D3DFMT_UNKNOWN;
  d3dpp.EnableAutoDepthStencil := True;
  d3dpp.AutoDepthStencilFormat := D3DFMT_D16;

  // Create the D3DDevice
  Result:= g_pD3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, hWnd,
                               D3DCREATE_SOFTWARE_VERTEXPROCESSING,
                               @d3dpp, g_pd3dDevice);
  if FAILED(Result) then
  begin
    Result:= E_FAIL;
    Exit;
  end;

  // Turn off culling
  g_pd3dDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);

  // Turn off D3D lighting
  g_pd3dDevice.SetRenderState(D3DRS_LIGHTING, iFalse);

  // Turn on the zbuffer
  g_pd3dDevice.SetRenderState(D3DRS_ZENABLE, iTrue);

  Result:= S_OK;
end;

function Cardvertex(pos:TD3DXVector3;col:cardinal;u,v:single):TCardvertex;
begin
 with result do
 begin
 position:=pos;color:=col;tu:=u;tv:=v;
 end;
end;

procedure iranyit;
var
tmp:TD3DXVector3;
az:single;
begin
 if cursor.x<50          then cpx:=cpx-0.3;
 if cursor.x>SCWidth-50  then cpx:=cpx+0.3;

 if cursor.y<50          then cpz:=cpz+0.3;
 if cursor.y>SCHeight-50 then cpz:=cpz-0.3;

 d3dxvec3transformnormal(tmp,D3DXVector3((cursor.x*2-SCWidth),(SCheight-cursor.y*2),SCWidth*1.3),matViewInv);
 if tmp.y<0 then
 begin
  az:=-Veyept.y/tmp.y;
  tmp.x:=tmp.x*az+veyept.x;
  tmp.z:=tmp.z*az+veyept.z;
  tmp.y:=0;
  cursor2:=tmp;
 end;
end;


procedure DoTimesteps;
var
i,j:integer;
korlat:integer;
bol:boolean;
cardmost,cardmost2:Pcard;
cardaabb:TAABB;
arrofcoll:Tarrayofpointer;
begin

 korlat:=0;

 if (hanyszor*10<gettickcount) and (getasynckeystate(ord('A'))=0) then
 repeat
  inc(korlat);
  inc(hanyszor);

  Iranyit;


  //FELEZETT RÉSZ
  if (hanyszor mod 2)=0 then
  begin
   cardmost:=firstcard;
   while cardmost<>nil do
   begin
    if not cardmost.disabled then cardstep(cardmost);


    if (getasynckeystate(ord('R'))<>0 ) then
    if cardmost.ep[3].y>-9 then
    begin
     for i:=0 to 3 do
      d3dxvec3lerp(cardmost.p[i],cardmost.p[i],cardmost.ep[i],0.1);
     cardmost.disabled:=false;
     cardmost.alljmeg:=20;

     for i:=0 to 3 do
     begin
      cardmost.sp[i]:=D3DXVector3zero;
      cardmost.cp[i]:=D3DXVector3zero;
     end;
      cardmost.distimer:=0;
      cardmost.foldon:=false;

     if length(cardmost.colls)<>0 then
     setlength(cardmost.colls,0);
    end;

    if (getasynckeystate(ord('S'))<>0 ) or (cardmost.alljmeg>0) then
     cardmost.op:=cardmost.p;

    if cardmost.alljmeg>0 then dec(cardmost.alljmeg);

    cardmost:=cardmost.kovkartya;
   end;

  cardmost:=firstcard;

   if (getasynckeystate(ord('R'))=0 ) then
   while cardmost<>nil do
   begin
    if cardmost.foldon or cardmost.disabled then
    begin
     cardmost:=cardmost.kovkartya;
     continue;
    end;

    cardAABB.min:= cardmost.p[0];
    cardAABB.max:= cardmost.p[0];
    for i:=1 to 3 do
    begin
     d3dxvec3maximize(cardAABB.max,CardAABB.max,cardmost.p[i]);
     d3dxvec3minimize(cardAABB.min,CardAABB.min,cardmost.p[i]);
    end;
    d3dxvec3add(cardAABB.min,cardAABB.min,D3DXVector3(-3,-3,-3));
    d3dxvec3add(cardAABB.max,cardAABB.max,D3DXVector3( 3, 3, 3));
    setlength(arrofcoll,0);
    Octtreegetregion(octtree,cardaabb,arrofcoll);

    for i:=0 to high(arrofcoll) do
    begin
     cardmost2:=arrofcoll[i];
      if cardmost<>cardmost2 then
       if not cardmost2.foldon then
         if not (cardmost.disabled and cardmost2.disabled) then
       CardVCard(cardmost,cardmost2);
    end;

    cardmost:=cardmost.kovkartya;
   end;

  end;
  //FELEZETT RÉSZ VÉGE



 until ((hanyszor*10>gettickcount) or (korlat>10));

 if hanyszor*10<gettickcount then hanyszor:=gettickcount div 10;
end;

function AddCard:Pcard;
var
cardmost:Pcard;
begin
 cardmost:=firstcard;
 firstcard:=nil;
 getmem(firstcard,sizeof(TCard));
 zeromemory(firstcard,sizeof(TCard));
 firstcard.kovkartya:=cardmost;
 result:=firstcard;
end;



procedure Cardcreatepiramis(hx,hy,hz:single;emelet:integer);
var
  i,j,k,px,py: integer;
  cardmost:Pcard;
  tmp:TD3DXVector3;
  mennyit:integer;
begin
  px:=0; py:=0;
  emelet:=emelet+1;
  mennyit:=(3*(emelet+1)*emelet) shr 1-2;
  hx:=hx-emelet*1.25+1.25;
  for i:=0 to mennyit-1 do
  begin
   //if ((i mod 3)=0) and (py=0) then continue;
   cardmost:=addcard;
   case i mod 3 of
   2:begin
      cardmost.p[0]:=D3DXVector3(1.2,0,0);
      cardmost.p[1]:=D3DXVector3(1.2,0,1);
      cardmost.p[2]:=D3DXVector3(0,3.8,0);
      cardmost.p[3]:=D3DXVector3(0,3.8,1);
     end;
   1:begin
      cardmost.p[0]:=D3DXVector3(-1.2,0,0);
      cardmost.p[1]:=D3DXVector3(-1.2,0,1);
      cardmost.p[2]:=D3DXVector3(0,3.8,0);
      cardmost.p[3]:=D3DXVector3(0,3.8,1);
     end;
   0:begin
      cardmost.p[0]:=D3DXVector3(1,0,0);
      cardmost.p[1]:=D3DXVector3(1,0,1);
      cardmost.p[2]:=D3DXVector3(-1,0,0);
      cardmost.p[3]:=D3DXVector3(-1,0,1);
     end;
   end;

   for j:=0 to 3 do
   begin
    tmp:=D3DXVector3(px*2.5-py*1.250+hx,py*3.73+hy,0+hz);
    d3dxvec3add(cardmost.p[j],cardmost.p[j],tmp);
   end;


   for j:=0 to 3 do
   begin
    tmp:=D3DXVector3((random(1000)-500)/500000,
                     (random(1000)-500)/500000,
                     (random(1000)-500)/500000);
    d3dxvec3add(cardmost.p[j],cardmost.p[j],tmp);
   end;//  }



   setlength(cardmost.colls,0);
   CardConstraintShape(cardmost);
   CardConstraintShape(cardmost);
   CardConstraintShape(cardmost);
   CardConstraintShape(cardmost);
   cardmost.op:=cardmost.p;
   cardmost.ep:=cardmost.p;
   CardConstraintShape(cardmost);
   cardmost.szam:=random(13*4);
   cardmost.disabled:=false;
   cardmost.alljmeg:=20;
   if (i mod 3)=2 then
   begin
    inc(py);
    if py>px then begin inc(px); py:=0; end;
   end;

  end;

end;

procedure CardCreateFal(hx,hy,hz:single);
var
cardmost:PCard;
i,j:integer;
tmp:TD3DXVector3;
begin

 // | |
 cardmost:=AddCard;
 cardmost.p[0]:=D3DXVector3(2 ,2.5,1);
 cardmost.p[1]:=D3DXVector3(2 ,0.5,1.1);
 cardmost.p[2]:=D3DXVector3(0 ,2.5,1);
 cardmost.p[3]:=D3DXVector3(0 ,0.5,1.1);
 cardmost:=AddCard;
 cardmost.p[0]:=D3DXVector3( 0,2.5,-1);
 cardmost.p[1]:=D3DXVector3( 0,0.5,-1.1);
 cardmost.p[2]:=D3DXVector3(-2,2.5,-1);
 cardmost.p[3]:=D3DXVector3(-2,0.5,-1.1);

 // | | 2
 cardmost:=AddCard;
 cardmost.p[0]:=D3DXVector3(1 ,2.5, 0);
 cardmost.p[1]:=D3DXVector3(1.1 ,0.5, 0);
 cardmost.p[2]:=D3DXVector3(1 ,2.5,-2);
 cardmost.p[3]:=D3DXVector3(1.1 ,0.5,-2);
 cardmost:=AddCard;
 cardmost.p[0]:=D3DXVector3(-1,2.5, 0);
 cardmost.p[1]:=D3DXVector3(-1.1,0.5, 0);
 cardmost.p[2]:=D3DXVector3(-1,2.5, 2);
 cardmost.p[3]:=D3DXVector3(-1.1,0.5, 2);

 //  -/\-
 cardmost:=AddCard;
 cardmost.p[0]:=D3DXVector3(-3,3,-2);
 cardmost.p[1]:=D3DXVector3(0,3,-2);
 cardmost.p[2]:=D3DXVector3(-3,3,1);
 cardmost.p[3]:=D3DXVector3(0,3,1);

 cardmost:=AddCard;
 cardmost.p[0]:=D3DXVector3(3,3,-1);
 cardmost.p[1]:=D3DXVector3(0,3,-1);
 cardmost.p[2]:=D3DXVector3(3,3,2);
 cardmost.p[3]:=D3DXVector3(0,3,2);



 cardmost:=firstcard;
 for i:=0 to 5 do
 begin



   for j:=0 to 3 do
   begin
    tmp:=D3DXVector3((random(1000)-500)/500000,
                     (random(1000)-500)/500000,
                     (random(1000)-500)/500000);
    d3dxvec3add(cardmost.p[j],cardmost.p[j],tmp);
   end;//  }

   cardmost.op:=cardmost.p;
   setlength(cardmost.colls,0);
   CardConstraintShape(cardmost);
   CardConstraintShape(cardmost);
   CardConstraintShape(cardmost);
   CardConstraintShape(cardmost);

   for j:=0 to 3 do
   begin

    tmp:=D3DXVector3(hx,hy,hz);
   // if (i<6) and (i>1) then tmp.y:=tmp.y+0.3;
    d3dxvec3add(cardmost.p[j],cardmost.p[j],tmp);
   end;

   cardmost.op:=cardmost.p;
   cardmost.ep:=cardmost.p;
   CardConstraintShape(cardmost);
   cardmost.szam:=random(13*4);
   cardmost.disabled:=false;


  cardmost:=cardmost.kovkartya;
 end;
end;

//-----------------------------------------------------------------------------
// Name: InitGeometry()
// Desc: Creates the scene geometry
//-----------------------------------------------------------------------------
function InitGeometry: HRESULT;
var
  i,j,k,px,py: integer;
  theta: Single;
  pVertices: PCardvertexArray;
  cardmost,cardmost2:Pcard;
  tmp:TD3DXVector3;
  tmpbmp:TBitmap;
  knx,kny:integer;
begin
  Result:= E_FAIL;



  // Create the vertex buffer.
  if FAILED(g_pd3dDevice.CreateVertexBuffer(10000*6*SizeOf(TCardvertex),
                                            0, D3DFVF_Cardvertex,
                                            D3DPOOL_DEFAULT, g_pVB, nil))
  then Exit;

  //CARDS.DLL hívása, kártyák rajzolása, stb.stb.
  tmpbmp:=Tbitmap.create;
  tmpbmp.Width:=1024;
  tmpbmp.Height:=1024;
  cdtInit(knx,kny);
  kartyu:=knx/1024;
  kartyv:=kny/1024;
  for i:=0 to 12 do
   for j:=0 to 3 do
    cdtDraw(tmpbmp.canvas.handle,i*knx,j*kny,i*4+j,0,clWhite);
  cdtTerm;

  tmpbmp.SaveToFile('card.bmp');
  tmpbmp.destroy;
  // Use D3DX to create a texture from a file based image
  if FAILED(D3DXCreateTextureFromFile(g_pd3dDevice, 'card.bmp', g_pTexture)) then
  begin
      MessageBox(0, 'Could not find card.bmp', 'Textures.exe', MB_OK);
      exit;
  end;
  deletefile('card.bmp');

  CardCreatePiramis(0,0,4  ,7);

  {for i:=0 to 1 do
   for j:=0 to 1 do
    for k:=0 to 3 do
     CardCreateTorony(10+i*4,k*2.9 ,-4+j*4);}

  //}

  InitOcttree;
  Result:= S_OK;
end;



//-----------------------------------------------------------------------------
// Name: Cleanup()
// Desc: Releases all previously initialized objects
//-----------------------------------------------------------------------------
procedure Cleanup;
begin
  if (g_pTexture <> nil) then
    g_pTexture:= nil;


  if (g_pVB <> nil) then
    g_pVB:= nil;

  if (g_pd3dDevice <> nil) then
    g_pd3dDevice:= nil;

  if (g_pD3D <> nil) then
    g_pD3D:= nil;
end;



//-----------------------------------------------------------------------------
// Name: SetupMatrices()
// Desc: Sets up the world, view, and projection transform matrices.
//-----------------------------------------------------------------------------
procedure SetupMatrices;
begin
  // For our world matrix, we will just leave it as the identity
  D3DXMatrixIdentity(matWorld);
  g_pd3dDevice.SetTransform(D3DTS_WORLD, matWorld);

  // Set up our view matrix. A view matrix can be defined given an eye point,
  // a point to lookat, and a direction for which way is up. Here, we set the
  // eye five units back along the z-axis and up three units, look at the
  // origin, and define "up" to be in the y-direction.
  vEyePt:=    D3DXVector3(cpx, 50.0,cpz-30.0);
  vLookatPt:= D3DXVector3(cpx, 0.0 ,cpz);
  vUpVec:=    D3DXVector3(0.0, 1.0, 0.0);
  D3DXMatrixLookAtLH(matView, vEyePt, vLookatPt, vUpVec);
  D3DXMatrixInverse(matViewInv,nil,matView);
  g_pd3dDevice.SetTransform(D3DTS_VIEW, matView);

  // For the projection matrix, we set up a perspective transform (which
  // transforms geometry from 3D view space to 2D viewport space, with
  // a perspective divide making objects smaller in the distance). To build
  // a perpsective transform, we need the field of view (1/2 pi is common),
  // the aspect ratio, and the near and far clipping planes (which define at
  // what distances geometry should be no longer be rendered).
  D3DXMatrixPerspectiveFovLH(matProj, D3DX_PI/3, 4/3, 1.0, 200.0);
  g_pd3dDevice.SetTransform(D3DTS_PROJECTION, matProj);
end;


procedure FillBufWithCards;
var
pvertices:PCardvertexArray;
i,j,k:integer;
cardmost:PCard;
szin:cardinal;
as2:single;
ku1,kv1,ku2,kv2:single; cardaabb:TAABB;
arrofcoll:Tarrayofpointer;
begin
 // Fill the vertex buffer. We are setting the tu and tv texture
  // coordinates, which range from 0.0 to 1.0
  if FAILED(g_pVB.Lock(0, 0, Pointer(pVertices), 0))
  then Exit;

{  cardmost:=firstcard;
  d3dxvec3add(cardAABB.min,cardmost.octp,D3DXVector3(-6,-6,-6));
  d3dxvec3add(cardAABB.max,cardmost.octp,D3DXVector3( 6, 6, 6));
  setlength(arrofcoll,0);
  Octtreegetregion(octtree,cardaabb,arrofcoll);

  ezt meg a loopba:
  
   for k:=0 to high(arrofcoll) do
    if arrofcoll[k]=cardmost then szin:=$FF;
  }

  cardmost:=firstcard;
  i:=0;
   while cardmost<>nil do
   begin


  {
 0--1
 | /|
 |/ |
 2--3
}
   as2:=0;
   for j:=0 to 3 do
   begin
    as2:=as2+tavpointpointsq(cardmost.p[j],cardmost.ep[j]);
   end;
   as2:=as2/3;
   if as2>1 then as2:=1;
   
   if getasynckeystate(ord('D'))<>0 then
   begin
    szin:=colorlerp($00FF00,$0000FF,as2);

   end
   else
   szin:=$FFFFFF;
   if getasynckeystate(ord('F'))<>0 then
   begin
    szin:=colorlerp($00FF00,$0000FF,cardmost.distimer/200);
    if cardmost.disabled then szin:=$FF0000
   end;
   
    //if cardmost.disabled then szin:=$FF;
   ku1:= (cardmost.szam div 4)*kartyu; ku2:=ku1+kartyu;
   kv1:= (cardmost.szam mod 4)*kartyv; kv2:=kv1+kartyv;

   pvertices[i*6+0]:=Cardvertex(cardmost.p[0],szin,ku1,kv1);
   pvertices[i*6+1]:=Cardvertex(cardmost.p[1],szin,ku2,kv1);
   pvertices[i*6+2]:=Cardvertex(cardmost.p[2],szin,ku1,kv2);

   pvertices[i*6+3]:=Cardvertex(cardmost.p[3],szin,ku2,kv2);
   pvertices[i*6+4]:=Cardvertex(cardmost.p[2],szin,ku1,kv2);
   pvertices[i*6+5]:=Cardvertex(cardmost.p[1],szin,ku2,kv1);

   i:=i+1;
   cardmost:=cardmost.kovkartya;
   end;
  cszam:=i;
  g_pVB.Unlock;


end;




procedure Octgrid;
var
i,j:integer;
vec:TVecarray;
cardmost:Pcard;
begin


end;

//-----------------------------------------------------------------------------
// Name: Render()
// Desc: Draws the scene
//-----------------------------------------------------------------------------
procedure Render;
begin
  // Clear the backbuffer and the zbuffer
  g_pd3dDevice.Clear(0, nil, D3DCLEAR_TARGET or D3DCLEAR_ZBUFFER,
                      D3DCOLOR_XRGB(0,0,255), 1.0, 0);

  // Begin the scene
  if SUCCEEDED(g_pd3dDevice.BeginScene) then
  begin
    // Setup the world, view, and projection matrices
    SetupMatrices;

    // Setup our texture. Using textures introduces the texture stage states,
    // which govern how textures get blended together (in the case of multiple
    // textures) and lighting information. In this case, we are modulating
    // (blending) our texture with the diffuse color of the vertices.
    g_pd3dDevice.SetTexture(0, g_pTexture);

    // Set up the default texture states.
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_MODULATE);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
    g_pd3dDevice.SetTextureStageState(0, D3DTSS_ALPHAOP,   D3DTOP_DISABLE);

    // Set up the default sampler states.
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR );
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR );
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR );
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSU,  D3DTADDRESS_CLAMP );
    g_pd3dDevice.SetSamplerState(0, D3DSAMP_ADDRESSV,  D3DTADDRESS_CLAMP );

    FillBufWithCards;

    // Render the vertex buffer contents
    g_pd3dDevice.SetStreamSource(0, g_pVB, 0, SizeOf(TCardvertex));
    g_pd3dDevice.SetFVF(D3DFVF_Cardvertex);


    g_pd3dDevice.DrawPrimitive(D3DPT_TRIANGLELIST, 0, cszam*2);
    // End the scene
    g_pd3dDevice.EndScene;
  end;
  // Present the backbuffer contents to the display
  g_pd3dDevice.Present(nil, nil, 0, nil);

  DoTimesteps;

end;


procedure HandleClick;
const
egerero=0.5;
var
tmpc:Pcard;
tmp:TD3DXVector3;
i,j:integer;
begin


     addcard;
     for j:=0 to 3 do
     begin
     tmp:=D3DXVector3((random(1000)-500)/1000,
                      (random(1000)-500)/1000,
                      (random(1000)-500)/1000);
     d3dxvec3add(firstcard.p[j],veyept,tmp);

     end;//  }

   setlength(firstcard.colls,0);
   CardConstraintShape(firstcard);
   CardConstraintShape(firstcard);
   CardConstraintShape(firstcard);
   CardConstraintShape(firstcard);
   firstcard.op:=firstcard.p;
   firstcard.ep:=firstcard.p;

   CardConstraintShape(firstcard);
     for j:=0 to 3 do
     begin
      d3dxvec3transformnormal(tmp,D3DXVector3((cursor.x-400)*egerero/400,(350-cursor.y)*egerero/400,egerero*1.3),matViewInv);
      d3dxvec3add(firstcard.p[j],firstcard.p[j],tmp);

      d3dxvec3add(firstcard.ep[j],firstcard.p[j],D3DXVector3(-random(10),0,-random(10)));
      firstcard.ep[j].y:=-10;
     end;
     firstcard.szam:=3;
    firstcard.disabled:=false;
    inc(cszam);
end;

procedure HandleRClick;
begin
 CardCreatePiramis(cursor2.x,0,cursor2.z,4);



end;


//-----------------------------------------------------------------------------
// Name: MsgProc()
// Desc: The window's message handler
//-----------------------------------------------------------------------------
function MsgProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
xpos:word;
ypos:word;

begin
  case uMsg of
    WM_DESTROY:
    begin
      Cleanup;
      PostQuitMessage(0);
      Result:= 0;
      Exit;
    end;
    WM_LBUTTONUP: HandleClick;
    WM_RBUTTONUP: HandleRClick;
    WM_MOUSEMOVE:
    begin
     cursor.x:=LOWORD(lParam);
     cursor.y:=HIWORD(lParam);
    end;
  end;

  Result:= DefWindowProc(hWnd, uMsg, wParam, lParam);
end;



//-----------------------------------------------------------------------------
// Name: WinMain()
// Desc: The application's entry point
//-----------------------------------------------------------------------------
// INT WINAPI WinMain( HINSTANCE hInst, HINSTANCE, LPSTR, INT )
var
  wc: TWndClassEx = (
    cbSize: SizeOf(TWndClassEx);
    style: CS_CLASSDC;
    lpfnWndProc: @MsgProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0; // - filled later
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: 'CWFW';
    hIconSm: 0);
var
  hWindow: HWND;
  msg: TMsg;
begin
  // Register the window class
(*  WNDCLASSEX wc = { sizeof(WNDCLASSEX), CS_CLASSDC, MsgProc, 0L, 0L,
                    GetModuleHandle(NULL), NULL, NULL, NULL, NULL,
                    "D3D Tutorial", NULL }; *)
  wc.hInstance:= GetModuleHandle(nil);
  RegisterClassEx(wc);
  randomize;
  // Create the application's window
  hWindow := CreateWindow('CWFW', 'Card Warfare',
                          WS_OVERLAPPEDWINDOW, 100, 100, SCWidth, SCHeight+30,
                          GetDesktopWindow, 0, wc.hInstance, nil);
  ShowWindow(hWindow, SW_SHOWDEFAULT);
      UpdateWindow(hWindow);




  // Initialize Direct3D
  if SUCCEEDED(InitD3D(hWindow)) then
  begin

    // Create the scene geometry
    if SUCCEEDED(InitGeometry) then
    begin
      // Show the window


      // Enter the message loop
      FillChar(msg, SizeOf(msg), 0);
      while (msg.message <> WM_QUIT) do
      begin
        if PeekMessage(msg, 0, 0, 0, PM_REMOVE) then
        begin
          TranslateMessage(msg);
          DispatchMessage(msg);
        end else
          Render;
      end;
    end;
  end;

  UnregisterClass('D3D Tutorial', wc.hInstance);
end.

