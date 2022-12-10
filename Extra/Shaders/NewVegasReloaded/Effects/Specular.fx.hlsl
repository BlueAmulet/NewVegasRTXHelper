// Specular multiplier fullscreen shader for Oblivion/Skyrim Reloaded

float4 TESR_ReciprocalResolution;
float4 TESR_SpecularData;					// x: strength, y:blurMultiplier, z:glossiness, w:drawDistance
float4 TESR_ScreenSpaceLightDir;

sampler2D TESR_RenderedBuffer : register(s0) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_DepthBuffer : register(s1) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };
sampler2D TESR_SourceBuffer : register(s2) = sampler_state { ADDRESSU = CLAMP; ADDRESSV = CLAMP; MAGFILTER = LINEAR; MINFILTER = LINEAR; MIPFILTER = LINEAR; };

static const float Strength = TESR_SpecularData.x;
static const float BlurRadius = TESR_SpecularData.y;
static const float Glossiness = TESR_SpecularData.z;
static const float DrawDistance = TESR_SpecularData.w;
 
struct VSOUT
{
	float4 vertPos : POSITION;
	float2 UVCoord : TEXCOORD0;
};
 
struct VSIN
{
	float4 vertPos : POSITION0;
	float2 UVCoord : TEXCOORD0;
};
 
VSOUT FrameVS(VSIN IN)
{
	VSOUT OUT = (VSOUT)0.0f;
	OUT.vertPos = IN.vertPos;
	OUT.UVCoord = IN.UVCoord;
	return OUT;
}

#include "Includes/Depth.hlsl"
#include "Includes/Blur.hlsl"

static const float2 texelSize = float2(TESR_ReciprocalResolution.x, TESR_ReciprocalResolution.y);


float4 Desaturate(float4 input)
{
	float greyscale = input.r * 0.3f + input.g * 0.59f +input.b * 0.11f;
	return float4(greyscale, greyscale, greyscale, input.a);
}


float4 specularHighlight( VSOUT IN) : COLOR0
{
	float2 coord = IN.UVCoord;
	float3 origin = reconstructPosition(coord);
	if (origin.z > DrawDistance) return 0.0;

	//reorient our sample kernel along the origin's normal
	float3 normal = GetNormal(IN.UVCoord);
	float3 viewRay = normalize(origin);
	float3 reflection = reflect(TESR_ScreenSpaceLightDir.xyz, normal);

	// float diffuse = dot(normal, TESR_ScreenSpaceLightDir.xyz);
	float specular = pow(dot(viewRay, reflection), Glossiness) * Glossiness * Glossiness;
	
	specular = lerp(specular, 0.0, origin.z/DrawDistance);

	// return diffuse;
	return specular.xxxx;
	// return specular + diffuse;
}


float4 CombineSpecular(VSOUT IN) :COLOR0
{
	float4 color = tex2D(TESR_SourceBuffer, IN.UVCoord);
	float specular = tex2D(TESR_RenderedBuffer, IN.UVCoord).r;
	float luminance = Desaturate(color).r;
	float lt = luminance;

	// scale effect with scene luminance
	specular = lerp(0.0, specular, luminance) * TESR_SpecularData.x;
	color += specular * color * TESR_SpecularData.x;

	return float4 (color.rgb, 1.0f);
}
 
technique
{

	pass
	{ 
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 specularHighlight();
	}

	pass
	{ 
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 BlurRChannel(float2(1.0f, 0.0f), BlurRadius, 1, DrawDistance);
	}
	
	pass
	{ 
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 BlurRChannel(float2(0.0f, 1.0f), BlurRadius, 1, DrawDistance);
	}

	pass
	{
		VertexShader = compile vs_3_0 FrameVS();
		PixelShader = compile ps_3_0 CombineSpecular();
	}
}