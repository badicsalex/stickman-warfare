unit PerlinNoise;

interface

uses math;

const
   cPERLIN_TABLE_SIZE = 256;
   c2PI = 2*PI;

type

   TPerlinNoise = class (TObject)
   protected
     FPermutations : packed array [0..cPERLIN_TABLE_SIZE-1] of Integer;
     FGradients : packed array [0..cPERLIN_TABLE_SIZE*3-1] of Single;
   protected
     function Lerp(const start, stop, t : Single) : Single;
     function Lattice(ix, iy, iz : Integer; fx, fy, fz : Single) : Single;
   public
     constructor Create(randomSeed : Integer);
     procedure Initialize(randomSeed : Integer);
     function Noise(x, y, z : Single) : Single;
     function Noise1D(x: single) : Single;
     function Qnoise(ix, iy, iz : Integer): Single;
    function complexnoise(startsm,x,y:single;scale:single;octaves:integer;persistence:single):single;
  end;

implementation

constructor TPerlinNoise.Create(randomSeed : Integer);
begin
   inherited Create;
   Initialize(randomSeed);
end;

procedure SinCos(const theta, radius : Single; var Sin, Cos: Single);
var
   s, c : Extended;
begin
   Math.SinCos(Theta, s, c);
   Sin:=s*radius; Cos:=c*radius;
end;

procedure TPerlinNoise.Initialize(randomSeed : Integer);
var
   seedBackup : Integer;
   i, t, j : Integer;
   z, r : Single;
begin
   seedBackup:=RandSeed;
   RandSeed:=randomSeed;

   // Generate random gradient vectors.
   for i:=0 to cPERLIN_TABLE_SIZE-1 do begin
      z:=1-2*Random;
      r:=Sqrt(1-z*z);
      SinCos(c2PI*Random, r, FGradients[i*3], FGradients[i*3+1]);
      FGradients[i*3+2]:=z;
   end;
   // Initialize permutations table
   for i:=0 to cPERLIN_TABLE_SIZE-1 do
      FPermutations[i]:=i;
   // Shake up
   for i:=0 to cPERLIN_TABLE_SIZE-1 do begin
      j:=Random(cPERLIN_TABLE_SIZE);
      t:=FPermutations[i];
      FPermutations[i]:=FPermutations[j];
      FPermutations[j]:=t;
   end;

   RandSeed:=seedBackup;
end;

function TPerlinNoise.Lerp(const start, stop, t : Single) : Single;
begin
   Result:=start+(stop-start)*t;
end;

function TPerlinNoise.Lattice(ix, iy, iz : Integer; fx, fy, fz : Single): Single;
const
   cMask = cPERLIN_TABLE_SIZE-1;
var                                
   g : Integer;
begin                  
   g:=FPermutations[(ix+FPermutations[(iy+FPermutations[iz and cMask]) and cMask]) and cMask]*3;
   Result:=FGradients[g]*fx+FGradients[g+1]*fy+FGradients[g+2]*fz;
end;

function TPerlinNoise.Qnoise(ix, iy, iz : Integer): Single;
const
   cMask = cPERLIN_TABLE_SIZE-1;
var                                
   g : Integer;
begin                  
   g:=FPermutations[(ix+FPermutations[(iy+FPermutations[iz and cMask]) and cMask]) and cMask]*3;
   Result:=FGradients[g];
end;

function TPerlinNoise.Noise(x,y,z : single) : Single;

   function Smooth(var s : Single) : Single;
   begin
      Result:=s*s*(3-2*s);
   end;

var
   ix, iy, iz : Integer;
   fx0, fx1, fy0, fy1, fz0, fz1 : Single;
   wx, wy, wz : Single;
   vy0, vy1, vz0, vz1 : Single;
begin
   try
    ix:=Floor(x);

   fx0:=x-ix;
   fx1:=fx0-1;
   wx:=Smooth(fx0);

   iy:=Floor(y);
   fy0:=y-iy;                      
   fy1:=fy0-1;
   wy:=Smooth(fy0);
                            
   iz:=Floor(z);
   fz0:=z-iz;
   fz1:=fz0-1;
   wz:=Smooth(fz0);

   vy0:=Lerp(Lattice(ix, iy, iz, fx0, fy0, fz0),
             Lattice(ix+1, iy, iz, fx1, fy0, fz0),
             wx);
   vy1:=Lerp(Lattice(ix, iy+1, iz, fx0, fy1, fz0),
             Lattice(ix+1, iy+1, iz, fx1, fy1, fz0),
             wx);
   vz0:=Lerp(vy0, vy1, wy);

   vy0:=Lerp(Lattice(ix, iy, iz+1, fx0, fy0, fz1),
             Lattice(ix+1, iy, iz+1, fx1, fy0, fz1),
             wx);
   vy1:=Lerp(Lattice(ix, iy+1, iz+1, fx0, fy1, fz1),
             Lattice(ix+1, iy+1, iz+1, fx1, fy1, fz1),
             wx);
   vz1:=Lerp(vy0, vy1, wy);

   Result:=Lerp(vz0, vz1, wz);
   except
 result:=0;
 end;
end;

function TPerlinNoise.Noise1D(x: single) : Single;

   function Smooth(var s : Single) : Single;
   begin
      Result:=s*s*(3-2*s);
   end;

var
   ix: Integer;
   fx0, fx1: Single;
   wx: single;
begin
   try
    ix:=Floor(x);

   fx0:=x-ix;
   fx1:=fx0-1;
   wx:=Smooth(fx0);


   Result:=Lerp(Lattice(ix, 0, 0, fx0, 0, 0),
                Lattice(ix+1, 0, 0, fx1, 0, 0),
                wx);
   except
 result:=0;
 end;
end;

function TPerlinNoise.complexnoise(startsm,x,y:single;scale:single;octaves:integer;persistence:single):single;
var
i:integer;
sm,scal,invscal,ampl,norm:single;
begin
 norm:=0;
 sm:=startsm;
 scal:=scale;
 invscal:=1/scale;
 ampl:=1;

 for i:=1 to octaves do
 begin
   sm:=sm+(noise(2*scal+x*invscal,3*scal+y*invscal,0))*sm*ampl;
  norm:=norm+ampl;
  ampl:=ampl*persistence;
  scal:=scal*0.5;
  invscal:=invscal*2;
 end;
 result:=sm;

end;

end.
