texture g_MeshTexture;               // Color texture for mesh
texture g_SpecTexture;				//Specular map for guns
texture g_MeshHeightmap;               // POM heightmap
texture g_MeshLightmap;               // Lightmap for mesh 
texture g_Wavemap;                  // Normal mapp
texture g_Torchtexture;
texture g_Cloud1;
texture g_Cloud2;
texture g_Emap;
texture g_Terrain;
texture g_Building;

texture g_Grass;
texture g_Sand;
texture g_Rock;
texture g_Rock2;
texture g_Rock3;
texture g_hnoise;

float4x4 g_mWorldViewProjection : WORLDVIEWPROJECTION;	// World * View * Projection 
float4x4 g_mWorldView : WORLDVIEW;	          // World * View matrix
float4x4 g_mProjectionKorr;	  // World * Korr

float4x4 g_mWorldViewProj;
float4x4 g_mViewProj;
float4x4 g_mWorldView2;
float4x4 g_mProj;	
float4x4 g_mView;
float4 g_vMotionVec;
float4 g_CameraPosition;

bool vanemap;

float FogStart;
float FogEnd;
float Fogc;
float4 FogColor;

float HDRszorzo;

float BlendFactor;

float specHardness = 10;
float specIntensity = 0.5;
float emission = 0;
float lightness = 0;

float lightIntensity;
float4 lightColor;

float time;

float resParam;
float glowInt;

bool vanNormal;

float aspect;

float lamp = 1;

float4 translation = float4(0,0,0,0);
float rotation;
float scale;

float movement;
//float4 ambient = float4(0.92,0.90,0.99,1);
//float4 ambient = float4(0.9,0.0,0.0,1);
float wpnambient = 0.3;
//float4 ambient = float4(0.90196,0.94510,0.98824,1);
//float4 ambient = float4(0,0,0,1);
float ambient = 1;
float ambientpow = 0.01;
float4 sun = float4(1,1,1,0.95);
float3 sundir = normalize(float3(-1,1,0));

//float3 sundir = normalize(float3(0,1,0));
float3 updir = float3(0,1,0);

float weather;
//bool upsidedown;

float waterstart = 0;
float waterend = 0.1;
float sandstart = 0.2;
float sandpeak = 0.25;
float sandend = 0.3;
float grassstart = 0.4;
float grasspeak = 0.45;
float grassend = 0.5;
float gravelstart = 0.6;
float gravelpeak = 0.65;
float gravelend = 0.7;
float stonestart = 0.8;
float stoneend = 0.9;

float4 vizcol;
float4 homokcol;
float4 vizeshomokcol;

float cloudblend;
bool rays;

float4x4 World;
float4x4 View;
float4x4 Projection;
float4x4 invWorld;
float4x4 flip;

float fegylit;

float sunpow;

sampler MeshTextureSampler = 
sampler_state
{
    Texture = <g_MeshTexture>;
    MipFilter = NONE;
    MinFilter = POINT;
    MagFilter = POINT;
    AddressU = CLAMP;
    AddressV = CLAMP; 
};

sampler MeshTextureSampler2 = 
sampler_state
{
    Texture = <g_MeshTexture>;
    MipFilter = NONE;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = MIRROR;
    AddressV = MIRROR; 
};

sampler MeshTextureSampler3 = 
sampler_state
{
    Texture = <g_MeshTexture>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;  
};

sampler MeshTextureSampler4 = 
sampler_state
{
    Texture = <g_MeshTexture>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;  
};

sampler MeshLightmapSampler = 
sampler_state
{
    Texture = <g_MeshLightmap>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;  
};


sampler MeshHeightmapSampler = 
sampler_state
{
    Texture = <g_MeshHeightmap>;
    MipFilter = NONE;
    MinFilter = POINT;
    MagFilter = POINT;
    AddressU = WRAP;
    AddressV = WRAP;  
};

sampler MeshHeightmapSampler2 = 
sampler_state
{
    Texture = <g_MeshHeightmap>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;  
};

sampler WaveSampler = 
sampler_state
{
    Texture = <g_Wavemap>;
    MipFilter = NONE;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = MIRROR;
    AddressV = MIRROR; 
};

sampler WaveTexSampler = 
sampler_state
{
    Texture = <g_Wavemap>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP; 
};

sampler TorchTextureSampler = 
sampler_state
{
    Texture = <g_Torchtexture>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP; 
};

sampler GrassTextureSampler = 
sampler_state
{
    Texture = <g_Grass>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP; 
};

sampler RockTextureSampler = 
sampler_state
{
    Texture = <g_Rock>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP; 
};

sampler Rock2TextureSampler = 
sampler_state
{
    Texture = <g_Rock2>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP; 
};

sampler Rock3TextureSampler = 
sampler_state
{
    Texture = <g_Rock3>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP; 
};

sampler SandTextureSampler = 
sampler_state
{
    Texture = <g_Sand>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP; 
};

sampler HnoiseTextureSampler = 
sampler_state
{
    Texture = <g_hnoise>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP; 
};

  
sampler EmapTextureSampler = 
sampler_state
{
    Texture = <g_Emap>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP; 
};
    
sampler CloudTextureSampler1 = 
sampler_state
{
    Texture = <g_Cloud1>;
    MipFilter = NONE;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP; 
};

sampler CloudTextureSampler2 = 
sampler_state
{
    Texture = <g_Cloud2>;
    MipFilter = NONE;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP; 
};

sampler TerrainSampler = 
sampler_state
{
    Texture = <g_Terrain>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;  
};

sampler BuildingSampler = 
sampler_state
{
    Texture = <g_Building>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;  
};


//float2 g_Offset[12];



//--------------------------------------------------------------------------------------
// Pixel shader output structure
//--------------------------------------------------------------------------------------
struct PS_OUTPUT
{
    float4 RGBColor : COLOR0;    
};

struct PS_INPUT
{   
    float4 TexUV1 : TEXCOORD0;     
};

struct VS_OUTPUT
{   
    float4 Position  : POSITION;   
    float4 TextureUV : TEXCOORD2;
    float2 TexUV1    : TEXCOORD0;
    float2 TexUV2    : TEXCOORD1;
};

struct PS_INPUT2
{   
    float2 TexUV1    : TEXCOORD0;
    float2 TexUV2    : TEXCOORD1;
    float4 TextureUV : TEXCOORD2;    
};

struct VS_INPUT_POM
{
    float4 Position  : POSITION;    
    float2 TexUV1    : TEXCOORD0;
    float2 TexUV2    : TEXCOORD1;
    float3 normal    : NORMAL;    
    float3 tangent   : TANGENT0;
    float3 binormal  : BINORMAL0;
};



struct PS_INPUT_POM
{   
    float  Fog       : FOG;
    float4 Position  : POSITION;
    float2 TexUV1    : TEXCOORD0;
    float2 TexUV2    : TEXCOORD1;
    float3 ray    : TEXCOORD2;    
};

struct VS_INPUT_TERRAIN
{
    float4 Position  : POSITION;    
    float2 TexUV1    : TEXCOORD0;
    float2 TexUV2    : TEXCOORD1;
};

struct PS_INPUT_TERRAIN
{   

    float4 Position  : POSITION;
    float2 TexUV1    : TEXCOORD0;
    float2 TexUV2    : TEXCOORD1; 
    float Fog       : FOG;
  	float3 CameraVector : TEXCOORD4;
};

struct PS_INPUT_METAL
{   
    float  Fog       : FOG;
    float4 Position  : POSITION;
    float2 TexUV1    : TEXCOORD0;
    float2 TexUV2    : TEXCOORD1;
    float3 normal    : TEXCOORD2;  
    float3 tangent    : TEXCOORD3;
    float3 binormal    : TEXCOORD4;
    float3 worldPosition  : TEXCOORD5;	
};

struct VS_INPUT_FOLIAGE
{
    float4 Position  : POSITION;    
    float2 TexUV1    : TEXCOORD0;
    //float4 normal    : NORMAL;    
};

struct PS_INPUT_FOLIAGE
{   
    float  Fog       : FOG;
    float4 Position  : POSITION;
    float2 TexUV1    : TEXCOORD0;
    //float4 normal : TEXCOORD1;
    float3 worldPosition  : TEXCOORD2;
    
};

struct VS_INPUT_PARTICLE
{
    float4 Position  : POSITION;    
    float2 TexUV1    : TEXCOORD0;
    float4 color    : COLOR0;    
};

struct PS_INPUT_PARTICLE
{   
    float4 Position  : POSITION;
    float2 TexUV1    : TEXCOORD0;
    float4 color : COLOR0;
};


struct VS_INPUT_WM
{
    float4 Position  : POSITION;    
    float2 TexUV1    : TEXCOORD0;
    //float4 color : COLOR0;
    float4 Normal    : NORMAL;   

};

struct PS_INPUT_WN
{   
    float4 Position  : POSITION;
    float2 TexUV1    : TEXCOORD0;
	  float3 Normal    : TEXCOORD1;
    float3 worldPosition  : TEXCOORD2;
    float3 LightDir  : TEXCOORD3;
    //float4 pos  : TEXCOORD4;
    float Fog        : FOG;
    float4 Color     : COLOR0;
};

struct VS_INPUT_TEX_FOG_COL
{
    float4 Position  : POSITION;    
    float2 TexUV1    : TEXCOORD0;
    float4 color : COLOR0;
};

struct PS_INPUT_TEX_FOG_COL
{   
    float4 Position  : POSITION;
    float2 TexUV1    : TEXCOORD0;
    float Fog : FOG;
    float4 color : COLOR0;
};


//--------------------------------------------------------------------------------------
// Full screen glow
//--------------------------------------------------------------------------------------

/*
PS_OUTPUT FullScreenGlowPS( PS_INPUT In) 
{ 
    PS_OUTPUT Output;
	
	float treshold = 0.75;
	float4 tex = float4(treshold,treshold,treshold,treshold);
	
	tex = max(tex,0.11* tex2D(MeshTextureSampler, In.TextureUV));
	
	glowInt = 11;
	resParam = 0.7;
	
	tex = max(tex,glowInt * 0.098 * tex2D(MeshTextureSampler, In.TextureUV+float2(0.002,0.0005)*resParam)); 
	tex = max(tex,glowInt * 0.098 * tex2D(MeshTextureSampler, In.TextureUV+float2(-0.002,-0.0005)*resParam)); 
	tex = max(tex,glowInt * 0.098 * tex2D(MeshTextureSampler, In.TextureUV+float2(-0.0005,0.002)*resParam)); 
	tex = max(tex,glowInt * 0.098 * tex2D(MeshTextureSampler, In.TextureUV+float2(0.0005,-0.002)*resParam)); 
	
	tex = max(tex,glowInt * 0.075 * tex2D(MeshTextureSampler, In.TextureUV+float2(0.004,-0.0005)*resParam)); 
	tex = max(tex,glowInt * 0.075 * tex2D(MeshTextureSampler, In.TextureUV+float2(-0.004,0.0005)*resParam)); 
	tex = max(tex,glowInt * 0.075 * tex2D(MeshTextureSampler, In.TextureUV+float2(0.0005,0.004)*resParam)); 
	tex = max(tex,glowInt * 0.075 * tex2D(MeshTextureSampler, In.TextureUV+float2(-0.0005,-0.004)*resParam)); 

	tex = max(tex,glowInt * 0.065 * tex2D(MeshTextureSampler, In.TextureUV+float2(0.005,0.001)*resParam)); 
	tex = max(tex,glowInt * 0.065 * tex2D(MeshTextureSampler, In.TextureUV+float2(-0.005,-0.001)*resParam)); 
	tex = max(tex,glowInt * 0.065 * tex2D(MeshTextureSampler, In.TextureUV+float2(-0.001,0.005)*resParam)); 
	tex = max(tex,glowInt * 0.065 * tex2D(MeshTextureSampler, In.TextureUV+float2(0.001,-0.005)*resParam)); 
	
	tex -=float4(treshold,treshold,treshold,treshold);
    
	//flat módon kicsit szar lenne
	//valami "random" mód kéne
	
	Output.RGBColor = tex2D(MeshTextureSampler, In.TextureUV) + pow(tex*1.1,2);
	
    return Output;
}

PS_OUTPUT FullScreenGlowPS( PS_INPUT In) 
{ 
    PS_OUTPUT Output;  
    float4 ertek;
    float4 tex=tex2D(MeshTextureSampler, In.TextureUV);
    Output.RGBColor  = 0 ;// tex2D(MeshTextureSampler, In.TextureUV);
    ertek=tex+0.5;

	for(int i=0; i < 12; i++ )
	{
          
          Output.RGBColor += max(0,tex2D(MeshTextureSampler,In.TextureUV + g_Offset[i])-ertek);
       
	}  

    Output.RGBColor =Output.RGBColor/10;
    return Output;
}

float4 FullScreenGlowPS( PS_INPUT In) : COLOR0
{
  return 
  
  max( 0,((
    tex2D(MeshTextureSampler,In.TextureUV + float2(0.000,0.040)) * 0.6 +
    
    tex2D(MeshTextureSampler,In.TextureUV + float2(0.010,0.030)) * 0.6 +
    tex2D(MeshTextureSampler,In.TextureUV + float2(-0.010,0.030)) * 0.6 +
    
    tex2D(MeshTextureSampler,In.TextureUV + float2(0.020,0.020)) * 0.8 +
    tex2D(MeshTextureSampler,In.TextureUV + float2(0.000,0.020)) +
    tex2D(MeshTextureSampler,In.TextureUV + float2(-0.020,0.020)) * 0.8 +
    
    tex2D(MeshTextureSampler,In.TextureUV + float2(0.030,0.010)) * 0.6 +
    tex2D(MeshTextureSampler,In.TextureUV + float2(0.010,0.010)) +
    tex2D(MeshTextureSampler,In.TextureUV + float2(-0.010,0.010)) +
    tex2D(MeshTextureSampler,In.TextureUV + float2(-0.030,0.010)) * 0.6 +

    
    tex2D(MeshTextureSampler,In.TextureUV + float2(0.040,0.000)) * 0.6 +
    tex2D(MeshTextureSampler,In.TextureUV + float2(0.020,0.000)) +
    //tex2D(MeshTextureSampler,In.TextureUV + float2(0.000,0.000)) +
    tex2D(MeshTextureSampler,In.TextureUV + float2(-0.020,0.000)) +
    tex2D(MeshTextureSampler,In.TextureUV + float2(-0.040,0.000)) * 0.6 +
    
    tex2D(MeshTextureSampler,In.TextureUV + float2(0.030,-0.010)) * 0.6 +
    tex2D(MeshTextureSampler,In.TextureUV + float2(0.010,-0.010)) +
    tex2D(MeshTextureSampler,In.TextureUV + float2(-0.010,-0.010)) +
    tex2D(MeshTextureSampler,In.TextureUV + float2(-0.030,-0.010)) * 0.6 +
    
    tex2D(MeshTextureSampler,In.TextureUV + float2(0.020,-0.020)) * 0.8 +
    tex2D(MeshTextureSampler,In.TextureUV + float2(0.000,-0.020)) +
    tex2D(MeshTextureSampler,In.TextureUV + float2(-0.020,-0.020)) * 0.8 +
    
    tex2D(MeshTextureSampler,In.TextureUV + float2(0.010,-0.030)) * 0.6 +
    tex2D(MeshTextureSampler,In.TextureUV + float2(-0.010,-0.030)) * 0.6 +
    
    tex2D(MeshTextureSampler,In.TextureUV + float2(0.000,-0.040)) * 0.6
    
  ) / 12) - tex2D(MeshTextureSampler, In.TextureUV) - 0.5);
  
  //27 szempli a max, most 24 van
}
*/

float4 FullScreenGlowPS( PS_INPUT In) : COLOR0
{
  return
  0.5*
  max( 0,((
    tex2D(MeshTextureSampler,In.TexUV1 + float2(-0.100,0.100)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(-0.100,0.000)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(-0.100,-0.100)) +
                                        
    tex2D(MeshTextureSampler,In.TexUV1 + float2(-0.050,0.050)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(-0.050,0.000)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(-0.050,-0.050)) +
                                        
    tex2D(MeshTextureSampler,In.TexUV1 + float2(-0.020,0.020)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(-0.020,0.000)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(-0.020,-0.020)) +
                                        
    tex2D(MeshTextureSampler,In.TexUV1 + float2(0.000,0.100)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(0.000,0.050)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(0.000,0.020)) +
                                       
    tex2D(MeshTextureSampler,In.TexUV1 + float2(0.000,-0.100)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(0.000,-0.050)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(0.000,-0.020)) +
                                         
    tex2D(MeshTextureSampler,In.TexUV1 + float2(0.100,0.100)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(0.100,0.000)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(0.100,-0.100)) +
                                         
    tex2D(MeshTextureSampler,In.TexUV1 + float2(0.050,0.050)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(0.050,0.000)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(0.050,-0.050)) +
                                        
    tex2D(MeshTextureSampler,In.TexUV1 + float2(0.020,0.020)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(0.020,0.000)) +
    tex2D(MeshTextureSampler,In.TexUV1 + float2(0.020,-0.020)) 
    
  ) / 24) - tex2D(MeshTextureSampler, In.TexUV1) - 0.3);
  
  //27 szempli a max, most 24 van, így:
  
  //*     *     *
  //  *   *   *
  //    * * *
  //* * *   * * *
  //    * * *
  //  *   *   *
  //*     *     *
}

//--------------------------------------------------------------------------------------
// Full screen red-grey-stuff.
//--------------------------------------------------------------------------------------


PS_OUTPUT FullScreenGreyscalePS( PS_INPUT In) 
{ 
    PS_OUTPUT Output;  
    float3 tex=tex2D(MeshTextureSampler, In.TexUV1);
    float2 ujUV = In.TexUV1-0.5;
    float tav =1.3-sqrt(ujUV.x*ujUV.x+ujUV.y*ujUV.y);
    float szurk=(tex.r+tex.g+tex.b)*2*tav-1.2;
    szurk=saturate(szurk);
    float4 vegso;
    vegso.r = szurk;
    szurk = szurk*szurk;
    vegso.g = szurk;
    vegso.b = szurk;
    vegso.a = saturate(pow(length(In.TexUV1-float2(0.5,0.5)),2)-0.5+BlendFactor); //In.TexUV1.x; // BlendFactor
    Output.RGBColor  = vegso;
    
    return Output;
}


PS_OUTPUT GunSniperEffectPS( PS_INPUT In) 
{ 
    PS_OUTPUT Output;  
    float4 tex=tex2D(MeshTextureSampler, In.TexUV1);
	float2 ujuv = In.TexUV1-float2(0.5,0.5);
	ujuv.x *= aspect;
	if (length(ujuv)>0.48) tex = float4(0,0,0,1);
    Output.RGBColor  = tex;
    
    return Output;
}

PS_OUTPUT TechSniperEffectPS( PS_INPUT In) 
{ 
    PS_OUTPUT Output;  
    float4 tex=tex2D(MeshTextureSampler, In.TexUV1);
	float2 ujuv = In.TexUV1-float2(0.5,0.5);
	ujuv.x *= aspect;
	float dist = length(ujuv);
	if (dist>0.65 || abs(ujuv.y)>0.40)
	{
		tex = float4(0,0,0,1);
	}
	else
	{
		float wave =(sin(ujuv.y*600)/2+0.5);
		float fac = 2 * max(0,dist-0.4);
		tex = fac * float4(1,0,0,1) + fac * 0.5 * wave * float4(1,1,1,1) + (1-fac) * tex;
	}
    Output.RGBColor  = tex;
    
    return Output;
}

//--------------------------------------------------------------------------------------
// Full screen motion blur
//--------------------------------------------------------------------------------------


PS_OUTPUT MotionBlurPS( PS_INPUT In) 
{ 
    PS_OUTPUT Output;  
    float2 vOffset;
    float2 vPrecomp=(In.TexUV1.xy-0.5)*g_vMotionVec.z+g_vMotionVec.xy;
    vPrecomp*=0.01;
    float fKill= vPrecomp.x*vPrecomp.x+vPrecomp.y*vPrecomp.y;
    clip(fKill-0.00000015);
    Output.RGBColor = 0;
    for(int i=0; i < 8; i++ )
    {
          vOffset=vPrecomp*i;     
          Output.RGBColor += tex2D(MeshTextureSampler,In.TexUV1 + vOffset)*(8-i);
       
	}    
    Output.RGBColor = Output.RGBColor/36;
    return Output;
}


//--------------------------------------------------------------------------------------
// Simple Water reflection shader
//--------------------------------------------------------------------------------------

VS_OUTPUT WaterReflectionVS( float4 vPos : POSITION, 
                         float4 vTexCoord0 : TEXCOORD0,
                         float4 vTexCoord1 : TEXCOORD1)
{
    VS_OUTPUT Output;
  
    Output.Position = mul(vPos, g_mWorldViewProjection);
   
    Output.TextureUV = mul(vPos, g_mWorldView);
    
    Output.TexUV1 = vTexCoord0;
    Output.TexUV2 = vTexCoord1;
    return Output;    
}


PS_OUTPUT WaterReflectionPS( VS_OUTPUT In) 
{ 
    PS_OUTPUT Output; 
    float4 reflvec=tex2D(WaveTexSampler,In.TexUV1)+tex2D(WaveTexSampler,In.TexUV2)-1;
    reflvec.w=0;
    
    reflvec*=0.5;

    float3 ref2=mul(reflvec.xzyw,g_mWorldView);
    float3 ev=normalize(In.TextureUV.xyz);
    float fresnel=dot(ref2,ev)+1;
    

    reflvec.z=0;
    float4 hova=In.TextureUV+reflvec;
    
    hova=mul(hova,g_mProjectionKorr);
    
    float4 vizcol={0, 0.392, 0.98,1};
        Output.RGBColor=lerp(tex2Dproj(MeshTextureSampler2,hova),vizcol,0.1)*HDRszorzo;
    Output.RGBColor.a=fresnel*0.6;
  
    return Output;
}

PS_INPUT_METAL ShineVS ( VS_INPUT_POM In)
{
  PS_INPUT_METAL Output;

  Output.worldPosition = (float3)In.Position;
  Output.Position= mul(In.Position, g_mWorldViewProjection);
  Output.normal  = normalize((float3)In.normal);
  Output.tangent  = normalize((float3)In.tangent);
  Output.binormal  = normalize((float3)In.binormal);
  Output.TexUV1  = In.TexUV1;
  Output.TexUV2  = In.TexUV2;
  Output.Fog = 1- saturate((Output.Position.z-FogStart)/(FogEnd-FogStart));   
  return Output;

}


PS_OUTPUT ShinePS( PS_INPUT_METAL In) 
{
	PS_OUTPUT Output;
	
	float3 cv = In.worldPosition-g_CameraPosition;
	float3 refl;
	
	float3 n = float3(0,0,0);
	if (vanNormal)
	{
		float3 normtex = tex2D(MeshHeightmapSampler2,In.TexUV1).rgb-float3(0.5,0.5,1.0);
    n = normtex.r * (In.binormal) - normtex.g * (In.tangent) - normtex.b * In.normal;	//NE!
	}
  
  float rain = 1;
  if (weather < 6)
    rain = 1+(-0.2+0.4*saturate(tex2D(HnoiseTextureSampler,In.TexUV2*10).g*2-1))*max(0,In.normal.y);
	
  refl = normalize(reflect(cv,In.normal+n));
  //refl = normalize(reflect(cv,n)); < bloom
	//float shine = pow(max(0,dot(refl,sundir)),specHardness);

	
	float4 kdtex = tex2D(MeshTextureSampler3,In.TexUV1);
  //kdtex = kdtex*0.0001 +0.3;
  float4 lmap = tex2D(MeshLightmapSampler,In.TexUV2); // pow kéne de elfogyott

	
	float li;
	if (lightIntensity>0)
		li = lightIntensity * 2 *
		max(0,10-distance(g_CameraPosition,In.worldPosition))/15*max(0,dot(-normalize(cv),normalize(In.normal+n)));
	
    Output.RGBColor  = 
      HDRszorzo*
	kdtex* (
		(ambient*ambientpow+lmap)+  			//ambient
		(lmap*pow(max(0,dot(refl,sundir)),specHardness)*specIntensity)*Fogc*rain+	//specular
		(lightColor*max(li,pow(li,specHardness)*specIntensity))		//point light
	);
	
	Output.RGBColor.a = kdtex.a;
  

  //Output.RGBColor = kdtex*0.0000001+lmap;
  
    return Output;
}

  
PS_INPUT_FOLIAGE FoliageVS ( VS_INPUT_FOLIAGE In)
{
PS_INPUT_FOLIAGE Output;

	float4 pos = In.Position;
	//vigyázat a weather meg van fordítva: 22* a vihar, 0 a napos
	float str = weather/20; 
	if (weather>20) str = weather/11;
	float2 ujuv = 1-In.TexUV1;
	//if (upsidedown) ujuv = (1-In.TexUV1);
	
	float s1,s2,z1,z2;
	//sincos((str/7+1)*(time*(1+str)+pos.x*0.5+pos.y),s1,z1);
  sincos((str/7+1)*(pos.x*0.5+pos.y)+time,s1,z1);
	//sincos((str/2+1)*((pos.x+pos.y*0.5))+time*(8+str),s2,z2);
  sincos((str/2+1)*((pos.x+pos.y*0.5))+time,s2,z2);

	pos.x += str *-0.075* ujuv.y + str * 0.10 * ujuv.y * (s1+0.72 + z1 * 0.001);
	pos.z += str *-0.020* ujuv.y + str * 0.03 * ujuv.y * (z1+0.72 + s2 * 0.001);

    Output.worldPosition = (float3)pos;
	Output.Position= mul(pos, g_mWorldViewProjection);
    //Output.normal  = saturate(In.normal.x-(0.5-ujuv.y)/5);
  //In.normal.x = sin(In.normal.x)+0.1;
      
//      Output.normal  = saturate((ujuv.y)/1);
  //Output.normal  = saturate((In.normal.x));
  //Output.normal  = 1;
    //Output.normal  = normalize((float3)In.normal);
    
    Output.worldPosition = (Output.worldPosition+1024)/2048;
    
    
    Output.TexUV1  = In.TexUV1;
    Output.Fog = 1- saturate((Output.Position.z-FogStart)/(FogEnd-FogStart));
    
    return Output;
}


PS_OUTPUT FoliagePS( PS_INPUT_FOLIAGE In) 
{
	PS_OUTPUT Output;
  
	//float4 sun = float4(1,0.95,0.94,1);
  float4 tex = tex2D(MeshTextureSampler4,In.TexUV1);
	//Output.RGBColor = tex * (sunpow * sun) * HDRszorzo* In.normal.x; //a sampler clamp kell legyen az alfa miatt
    
    
  //Output.RGBColor =In.normal.x;
  
  float terrain = tex2D(TerrainSampler,float2(In.worldPosition.x,In.worldPosition.z)).g; //piros meredekség, zöld árnyék
  //*0.8+0.5
    
  //float steep = tex2D(TerrainSampler,float2(In.worldPosition.x,In.worldPosition.z)).r; //piros meredekség, zöld árnyék
    
  terrain = (terrain+0.25)/1.15;
    Output.RGBColor = terrain;
    //Output.RGBColor.a = 1;
    Output.RGBColor *= tex*HDRszorzo;
    Output.RGBColor.a = tex.a;
    
    
  float build = tex2D(BuildingSampler,float2(In.worldPosition.x,In.worldPosition.z)).r; //piros meredekség, zöld árnyék
  
    
    //Output.RGBColor =1;
    
  if (build >= 0.7)
    Output.RGBColor =0;
  
  
  
  //if (steep >= 0.5)
    //Output.RGBColor =0;
  //Output.RGBColor.a = tex.a;
    

  
  //Output.RGBColor = terrain*float4(0.4,0.6,0.2,1)*0.9*In.normal.x;
    

//  Output.RGBColor.a = tex.a;

    return Output;
}


PS_INPUT_METAL PropVS ( VS_INPUT_POM In)
{

PS_INPUT_METAL Output;

	float3 normal = In.normal;
	float4 pos = In.Position;
	if (rotation!=0)
	{
	float s,c;
	sincos(rotation,s,c);
    normal.x = In.normal.x*c-In.normal.z*s;
    normal.z = In.normal.x*s+In.normal.z*c;
    pos.x = In.Position.x*c-In.Position.z*s;
    pos.z = In.Position.x*s+In.Position.z*c;
	}
  pos.x*=scale;
  pos.y*=scale;
  pos.z*=scale;
  
	pos += translation;
  Output.worldPosition = (float3)pos;
  Output.Position= mul(pos, g_mWorldViewProjection);
  Output.normal  = normalize((float3)normal);
  Output.tangent  = normalize((float3)In.tangent);
  Output.binormal  = normalize((float3)In.binormal);
  Output.TexUV1  = In.TexUV1;
  Output.TexUV2  = In.TexUV2;
  Output.Fog = 1- saturate((Output.Position.z-FogStart)/(FogEnd-FogStart));
  //Output.Fog = 1;
  return Output;
}


PS_OUTPUT PropPS( PS_INPUT_METAL In) 
{
  PS_OUTPUT Output;
  float4 kdtex = tex2D(MeshTextureSampler3,In.TexUV1);
  Output.RGBColor  = kdtex * (lightness * max(0,dot(In.normal,sundir)-0.3)+ ambient*0.5 + emission) * HDRszorzo;
  Output.RGBColor.a = kdtex.a;

  return Output;
}

PS_INPUT_TERRAIN TerrainVS( VS_INPUT_TERRAIN In) 
{ 
    PS_INPUT_TERRAIN Output;

    Output.Position = mul(In.Position, g_mWorldViewProjection);
    
    Output.TexUV1  = In.TexUV1;
    Output.TexUV2  = In.TexUV2;
    Output.Fog = 1- saturate((Output.Position.z-FogStart)/(FogEnd-FogStart));   
	//Output.Normal = In.normal;
	Output.CameraVector = Output.Position - g_CameraPosition;
    return Output;
}

PS_INPUT_TERRAIN Terrain2VS( VS_INPUT_TERRAIN In) 
{ 
    PS_INPUT_TERRAIN Output;

    //Output.Position = mul(In.Position, g_mWorldViewProjection);
    float4 worldPosition = mul(In.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    Output.Position = mul(viewPosition, Projection);
    
    Output.TexUV1  = In.TexUV1;
    Output.TexUV2  = In.TexUV2;
    Output.Fog = 1- saturate((Output.Position.z-FogStart)/(FogEnd-FogStart));   
	//Output.Normal = In.normal;
	Output.CameraVector = Output.Position - g_CameraPosition;
    return Output;
}

PS_OUTPUT TerrainPS( PS_INPUT_TERRAIN In) 
{ 
    PS_OUTPUT Output;
	float4 col = tex2D(MeshTextureSampler4,In.TexUV1);
  float noise = tex2D(HnoiseTextureSampler,In.TexUV2*0.2).g;
	float4 end = 
        //saturate(1-(col.x-waterend)*10)*vizcol*tex2D(SandTextureSampler,In.TexUV2) //víz

        saturate((-(col.x-0.1)+0.1)*10)
        *(tex2D(SandTextureSampler,In.TexUV2) + 0.25)
        *(tex2D(HnoiseTextureSampler,In.TexUV2*0.56)/20 + 0.95)
        *lerp(vizeshomokcol,vizcol,saturate(-col.x+waterend)*10) //vizeshomok
        
        //+ saturate((-abs(col.x-sandpeak)+0.15)*10)*homokcol*tex2D(SandTextureSampler,In.TexUV2)*tex2D(HnoiseTextureSampler,In.TexUV2*0.2) //homok
        //+ saturate((-abs(col.x-sandpeak)+0.15)*10)
        
        +
        (
        saturate((-(col.x-grassstart))*10+tex2D(HnoiseTextureSampler,In.TexUV2*0.031415)-0.5)
        -saturate(-(col.x-sandstart)*10)
        )
          
        *(tex2D(SandTextureSampler,In.TexUV2) + 0.25)
        *(tex2D(HnoiseTextureSampler,In.TexUV2*0.56)/20 + 0.95)
        *(tex2D(HnoiseTextureSampler,In.TexUV2*0.18)/20 + 0.95)
        *homokcol  //homok

				//+ saturate((-abs(col.x-grasspeak)+0.15)*10)*(tex2D(GrassTextureSampler,In.TexUV2))
        //*saturate(tex2D(HnoiseTextureSampler,In.TexUV2*0.87)/5 + 0.9)
        //*(tex2D(HnoiseTextureSampler,In.TexUV2*0.56)/16 + 0.9375)
        //*(tex2D(HnoiseTextureSampler,In.TexUV2*0.18)/16 + 0.9375) //fű
        
        //+ saturate((-abs(col.x-grasspeak)+0.15)*10+noise*2)*(tex2D(GrassTextureSampler,In.TexUV2))
        +
        (
        saturate((-(col.x-gravelpeak-0.1))*10+noise*2-1)
        -saturate(-(col.x-grassstart)*10+tex2D(HnoiseTextureSampler,In.TexUV2*0.031415)-0.5)
        )
        *(tex2D(GrassTextureSampler,In.TexUV2))
        //+pow(saturate((-(col.x-gravelpeak-0.1))*10+noise*2-1)*(tex2D(GrassTextureSampler,In.TexUV2)),0.9)*0.9
        //*saturate(tex2D(HnoiseTextureSampler,In.TexUV2*0.431415)/8 + 0.93)
        *saturate(tex2D(HnoiseTextureSampler,In.TexUV2*0.17)/8 + 0.92)
        *saturate(tex2D(HnoiseTextureSampler,In.TexUV2*0.041415)/16 + 0.94)
        *1.1
          
        //*saturate(tex2D(HnoiseTextureSampler,In.TexUV2*0.27)/8 + 0.93)
        
        //*saturate((saturate((tex2D(HnoiseTextureSampler,In.TexUV2*0.02)-0.2)*1)+0.95))
        
        //+tex2D(RockTextureSampler,In.TexUV2*0.211)
        
        //*saturate((1-(tex2D(HnoiseTextureSampler,In.TexUV2*0.02)-0.2)*10))
        //*tex2D(GnoiseTextureSampler,In.TexUV2*0.2)) //nope
        
        //+saturate((-abs(col.x-gravelpeak)+0.15)*10)*noise*tex2D(Rock3TextureSampler,In.TexUV2*1) //kő füves
        
        //-saturate((-abs(col.x-gravelpeak)+0.15)*10)*noise
          
//				+ saturate((-abs(col.x-gravelpeak)+0.15)*10)*tex2D(Rock2TextureSampler,In.TexUV2*0.5) //kő füves
        
 				//+saturate((-abs(col.x-gravelpeak)+0.15)*10)*tex2D(RockTextureSampler,In.TexUV2*0.5) //kő füves
          
        
        //+saturate(((col.x-gravelpeak)+0.15)*10-noise*2)
        +saturate(((col.x-gravelpeak))*10-noise*2+1)
        *(
        tex2D(RockTextureSampler,In.TexUV2*0.211)
        //+tex2D(RockTextureSampler,float2(0.311,-0.311)*float2(In.TexUV2.g,In.TexUV2.r))
        )*1
          //(tex2D(RockTextureSampler,In.TexUV2*0.111)+
        //tex2D(RockTextureSampler,In.TexUV2*float2(0.311,-0.311)))/2
        //*(tex2D(Rock3TextureSampler,In.TexUV2)).g
          
        *(tex2D(HnoiseTextureSampler,In.TexUV2*0.031415)*0.4 + 0.6)
          
          
        //-saturate(((col.x-gravelpeak))*10-noise*2+1)  
        //*(tex2D(HnoiseTextureSampler,In.TexUV2*0.031415)/3.5)
          
          
        //*(tex2D(HnoiseTextureSampler,In.TexUV2*0.241415)/2 + 1)/1.25
        
        //+ saturate((col.x-gravelend)*10)
        //*1
        //*((tex2D(RockTextureSampler,In.TexUV2*0.5))/5+0.8)
        
        //*(tex2D(RockTextureSampler,In.TexUV2*0.111)+ tex2D(RockTextureSampler,In.TexUV2*float2(0.311,-0.311)))/2
        
        
        //*(tex2D(HnoiseTextureSampler,In.TexUV2*5.15)/2 + 0.7)
        //*(tex2D(HnoiseTextureSampler,In.TexUV2*0.12)/1.5 + 0.7)
        //*0.9*pow(
        //+(tex2D(RockTextureSampler,In.TexUV2*0.34)*tex2D(Rock3TextureSampler,In.TexUV2*0.2))
        
        //,1/1.8)
        
          
        ; //kő

  //Output.RGBColor = HDRszorzo  * sun * end * (col.y * ((2*Fogc-1)/5 + 0.8) + 0.2*(1-Fogc) + 0.3 * ambient); //col.y == fény
  Output.RGBColor = sun * end * (col.y + 0.3 * ambient) * HDRszorzo
  //* tex2D(MeshLightmapSampler,In.TexUV2*0.01);
  ; //col.y == fény
	//Output.RGBColor = dot(normalize(In.Normal),normalize(In.CameraVector));
	//dot(normalize(reflect(sundir,In.Normal)),normalize(In.CameraVector));
    return Output;
}


PS_INPUT_POM ParallaxOcclusionVS( VS_INPUT_POM In) 
{ 
    PS_INPUT_POM Output;
    float3 rayws = g_CameraPosition-In.Position;
    float3 ray;
    ray.y = -dot(rayws,In.tangent);
    ray.x = dot(rayws,In.binormal);
    ray.z = dot(rayws,In.normal);
    

    Output.Position= mul(In.Position, g_mWorldViewProjection);
   if (ray.z>0)
   {
    ray.z += 0.3;
   }else
   {
    ray.z = 0.1-ray.z;
   };
    //ray=normalize(ray);
   // ray.z= max(0,ray.z*10);
    ray.z=ray.z*10;
    Output.ray  = ray;
    Output.TexUV1  = In.TexUV1;
    Output.TexUV2  = In.TexUV2;
    Output.Fog = 1- saturate((Output.Position.z-FogStart)/(FogEnd-FogStart));   
 
    return Output;
}

PS_OUTPUT ParallaxOcclusionPS( PS_INPUT_POM In) 
{ 
    PS_OUTPUT Output;
    float2 texpos=In.TexUV1;
    
    float3 ray=In.ray/In.ray.z;
    float3 currpos;
    float3 texmin;
    texmin.xy = texpos.xy - ray.xy*0.5;
    texmin.z=0;

    currpos = texmin;

    ray=ray/7;


    float elozo;
    float kovetkezo=tex2D(MeshHeightmapSampler2,currpos).r;
    float doles=1;
    float kul=0;
    float kul2;

    for (int i=0; i<7; i++)
    { 
       currpos=currpos+ray;
      elozo=kovetkezo;
      kovetkezo=tex2D(MeshHeightmapSampler2,currpos).r;
      kul2=elozo-currpos.z;

      if (kul2>0)
      { 
       texmin=currpos;
       kul=kul2;
       doles=elozo-kovetkezo+ray.z;
      };            
    };
    
    texmin=texmin+ray*(kul/doles);
    Output.RGBColor  = tex2D(MeshTextureSampler3,texmin)*tex2D(MeshLightmapSampler,In.TexUV2)*HDRszorzo;

    return Output;
}

PS_OUTPUT HDRPS( PS_INPUT In) 
{ 
    PS_OUTPUT Output;  

    Output.RGBColor  = tex2D(MeshTextureSampler4, In.TexUV1) * HDRszorzo;

    return Output;
}

PS_OUTPUT BuildingHDRPS( PS_INPUT_POM In) 
{ 
    PS_OUTPUT Output;  

    Output.RGBColor  = tex2D(MeshTextureSampler3,In.TexUV1) * (ambientpow+tex2D(MeshLightmapSampler,In.TexUV2));

    Output.RGBColor.rgb  *= HDRszorzo;
	
	//Output.RGBColor.a = kdtex.a;
    
    return Output;
}

/*
PS_INPUT_PARTICLE BulletholeVS( VS_INPUT_PARTICLE In)
{ 
    PS_INPUT_PARTICLE Output;  

    Output.Position= mul(In.Position, g_mWorldViewProjection);
    //Output.Position= In.Position;
    Output.color = In.color;
    Output.TexUV1  = In.TexUV1;
    //Output.Fog = 1- saturate((Output.Position.z-FogStart)/(FogEnd-FogStart));   
    
    return Output;
}*/


PS_OUTPUT BulletholePS( PS_INPUT_PARTICLE In) 
{ 
    PS_OUTPUT Output;  

    Output.RGBColor  = tex2D(MeshTextureSampler4, In.TexUV1) * In.color * HDRszorzo;
    
    Output.RGBColor.a  = tex2D(MeshTextureSampler4, In.TexUV1).a*4-2;
    
    return Output;
}

PS_INPUT_TEX_FOG_COL CloudVS( VS_INPUT_TEX_FOG_COL In) 
{
    PS_INPUT_TEX_FOG_COL Output;

    Output.Position= mul(In.Position, flip);
    Output.Position = mul(Output.Position, View);
    Output.Position = mul(Output.Position, Projection);
    
    Output.TexUV1 = In.TexUV1;
    Output.Fog = 1- saturate((Output.Position.z-FogStart)/(FogEnd-FogStart));
    Output.color = In.color;

    return Output;
  
}

PS_OUTPUT CloudPS( PS_INPUT_TEX_FOG_COL In) 
{ 
    PS_OUTPUT Output;  

    Output.RGBColor  =  lerp(tex2D(CloudTextureSampler1, In.TexUV1), tex2D(CloudTextureSampler2, In.TexUV1),cloudblend) * HDRszorzo;
    
    if (rays)
    {
      Output.RGBColor.rgb = 1;
      Output.RGBColor.a  *=  In.color.a;
    }
    
    return Output;
}

PS_INPUT_WN WnVS( VS_INPUT_WM In) 
{
    PS_INPUT_WN Output;

    float4 worldPosition = mul(In.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    Output.Position = mul(viewPosition, Projection);
    //Output.pos = In.Position;

    Output.worldPosition =worldPosition;
    Output.Normal  = normalize((float3)In.Normal);
  
    float3 obj_light=mul(sundir,invWorld);
    Output.LightDir = normalize(obj_light - (float3)In.Position);
    
    Output.Color = max(0, dot(Output.Normal, Output.LightDir) );
   
    Output.TexUV1 = In.TexUV1;
    Output.Fog = 1- saturate((Output.Position.z-FogStart)/(FogEnd-FogStart));
    

    return Output;
  
}
PS_OUTPUT WnPS( PS_INPUT_WN In) 
{ 
    PS_OUTPUT Output;

    
    float3 cv = (In.worldPosition-g_CameraPosition);

    float4 kdtex = tex2D(MeshTextureSampler4, In.TexUV1);
    
    float4 light = wpnambient;
        
    //float3 obj_light=mul(sundir,invWorld);
    //float3 LightDir = normalize(obj_light - (float3)In.pos);
    
    float3 HalfVect = normalize(reflect(In.LightDir,cv)/2);
    float SpecularAttn =  max(0,pow(  dot(In.Normal, HalfVect),15));
    
    light += fegylit*In.Color*(1 + sunpow*SpecularAttn);

    
    if (vanemap)
    Output.RGBColor  =  (kdtex * light + tex2D(EmapTextureSampler, In.TexUV1)) * HDRszorzo;

    if (!vanemap)
    Output.RGBColor  =  kdtex* light * HDRszorzo; 
  
  
    return Output;
}

PS_INPUT_WN WnHDRVS( VS_INPUT_WM In)  //butított verzió
{
    PS_INPUT_WN Output;

    float4 worldPosition = mul(In.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    Output.Position = mul(viewPosition, Projection);

    Output.worldPosition =0;
    Output.Normal  = normalize((float3)In.Normal);
  
    float3 obj_light=mul(sundir,invWorld);
    Output.LightDir = normalize(obj_light - (float3)In.Position);
    
    Output.Color = max(0, dot(Output.Normal, Output.LightDir) );
   
    Output.TexUV1 = In.TexUV1;
    Output.Fog = 1- saturate((Output.Position.z-FogStart)/(FogEnd-FogStart));
    

    return Output;
  
}
PS_OUTPUT WnHDRPS( PS_INPUT_WN In) 
{ 
    PS_OUTPUT Output;

    float4 kdtex = tex2D(MeshTextureSampler4, In.TexUV1);
    
    float4 light = wpnambient + fegylit*In.Color; //amient + árnyékban*shade*sunpower
        

    if (vanemap)
    Output.RGBColor  =  (kdtex * light + tex2D(EmapTextureSampler, In.TexUV1)) * HDRszorzo;

    if (!vanemap)
    Output.RGBColor  =  kdtex* light * HDRszorzo; 

    return Output;
}



technique FullScreenGlow
{
    pass P0
    {
        PixelShader  = compile ps_2_0 FullScreenGlowPS(); 
    }
}

technique GunSniperEffect
{
    pass P0
    {
        PixelShader  = compile ps_2_0 GunSniperEffectPS(); 
    }
}

technique TechSniperEffect
{
    pass P0
    {
        PixelShader  = compile ps_2_0 TechSniperEffectPS(); 
    }
}
technique FullScreenGreyscale
{
    pass P0
    {
        PixelShader  = compile ps_2_0 FullScreenGreyscalePS(); 
    }
}

technique MotionBlur
{
    pass P0
    {
        PixelShader  = compile ps_2_0 MotionBlurPS(); 
    }
}


technique WaterReflection
{
    pass P0
    {
        VertexShader = compile vs_2_0 WaterReflectionVS(); 
        PixelShader  = compile ps_2_0 WaterReflectionPS(); 
    }
}

technique ParallaxOcclusion
{
    pass P0
    {   
        VertexShader = compile vs_2_0 ParallaxOcclusionVS();
        PixelShader  = compile ps_2_0 ParallaxOcclusionPS(); 
    }
}

technique Shine
{
    pass P0
    {   
        VertexShader = compile vs_2_0 ShineVS();
        PixelShader  = compile ps_2_0 ShinePS(); 
    }
}

technique Foliage
{
    pass P0
    {   
        VertexShader = compile vs_2_0 FoliageVS();
        PixelShader  = compile ps_2_0 FoliagePS(); 
    }
}

technique Prop
{
    pass P0
    {   
        VertexShader = compile vs_2_0 PropVS();
        PixelShader  = compile ps_2_0 PropPS(); 
    }
}

technique Terrain
{
    pass P0
    {
        VertexShader = compile vs_2_0 TerrainVS();
        PixelShader  = compile ps_2_0 TerrainPS(); 
    }
}

technique Terrain2
{
    pass P0
    {
        VertexShader = compile vs_2_0 Terrain2VS();
        PixelShader  = compile ps_2_0 TerrainPS(); 
    }
}

technique HDR
{
    pass P0
    {
        PixelShader  = compile ps_2_0 HDRPS(); 
    }
}

technique BuildingHDR
{
    pass P0
    {
        PixelShader  = compile ps_2_0 BuildingHDRPS(); 
    }
}



technique Bullethole
{
    pass P0
    {
        PixelShader  = compile ps_2_0 BulletholePS(); 
    }
}

technique Cloud
{
    pass P0
    {
 //       VertexShader = compile vs_2_0 CloudVS();
        PixelShader  = compile ps_2_0 CloudPS(); 
    }
}

technique Wn
{
    pass P0
    {
        VertexShader = compile vs_2_0 WnVS();
        PixelShader  = compile ps_2_0 WnPS(); 
    }
}

technique WnHDR
{
    pass P0
    {
        VertexShader = compile vs_2_0 WnHDRVS();
        PixelShader  = compile ps_2_0 WnHDRPS(); 
    }
}