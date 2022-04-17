//
// Generated by Microsoft (R) HLSL Shader Compiler 9.23.949.2378
//
// Parameters:

float4 EyePos : register(c1);
float4 ShallowColor : register(c2);
float4 DeepColor : register(c3);
float4 ReflectionColor : register(c4);
float4 FresnelRI : register(c5);
float4 BlendRadius : register(c6);
float4 VarAmounts : register(c8);
float4 FogParam : register(c9);
float4 FogColor : register(c10);
float2 DepthFalloff : register(c11);
float4 SunDir : register(c12);
float4 SunColor : register(c13);
float4 TESR_WaveParams : register(c14);
float4 TESR_WaterVolume : register(c15);

sampler2D ReflectionMap : register(s0);
sampler2D RefractionMap : register(s1);
sampler2D NoiseMap : register(s2);
sampler2D DisplacementMap : register(s3);
sampler2D DepthMap : register(s4);

// Registers:
//
//   Name            Reg   Size
//   --------------- ----- ----
//   EyePos          const_1       1
//   ShallowColor    const_2       1
//   DeepColor       const_3       1
//   ReflectionColor const_4       1
//   FresnelRI       const_5       1
//   BlendRadius     const_6       1
//   VarAmounts      const_8       1
//   FogParam        const_9       1
//   FogColor        const_10      1
//   DepthFalloff    const_11      1
//   SunDir          const_12      1
//   SunColor        const_13      1
//   ReflectionMap   texture_0       1
//   RefractionMap   texture_1       1
//   NoiseMap        texture_2       1
//   DisplacementMap texture_3       1
//   DepthMap        texture_4       1
//


// Structures:

struct VS_INPUT {
    float4 LTEXCOORD_0 : TEXCOORD0_centroid;
    float4 LTEXCOORD_1 : TEXCOORD1_centroid;
    float4 LTEXCOORD_2 : TEXCOORD2_centroid;
    float4 LTEXCOORD_3 : TEXCOORD3_centroid;
    float4 LTEXCOORD_4 : TEXCOORD4_centroid;
    float4 LTEXCOORD_5 : TEXCOORD5_centroid;
	float4 LTEXCOORD_6 : TEXCOORD6;
    float2 LTEXCOORD_7 : TEXCOORD7;
};

struct VS_OUTPUT {
    float4 color_0 : COLOR0;
};

// Code:

VS_OUTPUT main(VS_INPUT IN) {
    VS_OUTPUT OUT;

#define	expand(v)		(((v) - 0.5) / 0.5)
#define	compress(v)		(((v) * 0.5) + 0.5)
#define	shade(n, l)		max(dot(n, l), 0)
#define	shades(n, l)		saturate(dot(n, l))
#define	weight(v)		dot(v, 1)
#define	sqr(v)			((v) * (v))

    const float4 const_14 = {1, 4, -9.99999975e-005, 100};
    const float4 const_15 = {-0.569999993, 0.819999993, 0, 0};
    const int4 const_16 = {0, 2, -1, 1};

    float1 q10;
    float1 q11;
    float1 q13;
	float3 q21;
	float3 q23;
    float3 q29;
    float3 q30;
	float3 q39;
	float1 q47;
    float1 q51;
    float3 q55;
    float1 q7;
    float1 q8;
    float4 r0;
    float4 r1;
    float4 r2;
    float4 r3;
    float4 r4;
    float4 r5;
    float4 r6;
    float3 r7;
	float choppiness = TESR_WaveParams.x;
	float waveWidth = TESR_WaveParams.y;
	float reflectivity = TESR_WaveParams.w;
	float turbidity = TESR_WaterVolume.z;
	
    r3.xyzw = tex2D(NoiseMap, IN.LTEXCOORD_7.xy * waveWidth);
    r5.xyzw = tex2D(DisplacementMap, IN.LTEXCOORD_6.xy);
    r2.xyz = EyePos.xyz - IN.LTEXCOORD_0.xyz;
    q55.xyz = r2.xyz / length(r2.xyz);
    r1.w = dot(IN.LTEXCOORD_5.xyzw, IN.LTEXCOORD_1.xyzw);
    r1.y = r1.w - dot(IN.LTEXCOORD_3.xyzw, IN.LTEXCOORD_1.xyzw);
    r1.z = dot(IN.LTEXCOORD_4.xyzw, IN.LTEXCOORD_1.xyzw);
    r1.x = dot(IN.LTEXCOORD_2.xyzw, IN.LTEXCOORD_1.xyzw);
    r0.xyzw = tex2Dproj(DepthMap, r1.xyzw);
    q51.x = saturate((r0.y - DepthFalloff.x) / (DepthFalloff.y - DepthFalloff.x));
    r1.yw = VarAmounts.yw;
    q7.x = 1 - saturate((FogParam.x - length(r2.xyz)) / FogParam.y);
    r3.w = 1;
    r5.xy = (r5.zw - 0.5) * BlendRadius.w;
    r5.z = 0.04;
    r0.w = (r0.y * q51.x) * ((saturate(length(r2.xy) * 0.0002) * (r1.w - 4)) + 4);
    r4.xy = saturate(lerp(r0.xy * turbidity, 1, 1 - saturate(1 - ((length(r2.xy) - 4096) * 0.000244140625))));
    q8.x = 1 - saturate((FogParam.x - (r4.y + length(r2.xyz))) / FogParam.y);
    q10.x = 1 - saturate((FogParam.z - (r4.x * FogParam.z)) / FogParam.w);
    r3.xyz = (q51.x * expand(r3.xyz) * choppiness) + const_16.xxw;
    r3.xy = saturate(1 - ((length(r2.xy) - 4096) * 0.000244140625)) * r3.xy;
    r1.xzw = r3.xyz - (r5.xyz / length(r5.xyz));
    r3.xyz = normalize(r5.xyz);
    r3.xyz = normalize((saturate(r3.z) * r1.xzw) + r3.xyz);
    q13.x = pow(abs(saturate(dot(r3.xz, const_15.xy))), 100);
    q29.xyz = (q13.x + pow(abs(shades(reflect(-q55.xyz, r3.xyz), SunDir.xyz)), VarAmounts.x)) * SunColor.rgb;
    r5.zw = (IN.LTEXCOORD_1.z * const_16.wx) + const_16.xw;
    r5.xy = ((r0.w * r3.xy) / IN.LTEXCOORD_0.w) + IN.LTEXCOORD_1.xy;
    r6.xyzw = mul(float4x4(IN.LTEXCOORD_2.xyzw, IN.LTEXCOORD_3.xyzw, IN.LTEXCOORD_4.xyzw, IN.LTEXCOORD_5.xyzw), r5.xyzw);
    r7.xyz = tex2Dproj(ReflectionMap, r6.xyzw).xyz;
    r5.xzw = r6.xzw;
    r5.y = r5.w - r6.y;
    r5.xyzw = tex2Dproj(RefractionMap, r5.xyzw);
	q11.x = 1 - shades(q55.xyz, r3.xyz);
	q47.x = pow(abs(q8.x), FresnelRI.y);
	q21.xyz = (r5.xyz - (q47.x * FogColor.rgb)) / (1 - (q47.x - 9.99999975e-005));
	r6.xyz = (r4.y * (DeepColor.xyz - ShallowColor.xyz)) + ShallowColor.xyz;
	r0.xyw = (r1.y * (r7.xyz - ReflectionColor.rgb)) + ReflectionColor.xyz;
	r0.z = q51.x * (q10.x * FogColor.a);
	q21.xyz = (r4.y * (r6.xyz - q21.xyz)) + q21.xyz;
	q39.xyz = (r0.z * (r6.xyz - q21.xyz)) + q21.xyz;
	q23.xyz = ((r4.y * 0.5 * lerp(FresnelRI.x, 1, q11.x * sqr(sqr(q11.x)))) * ((r0.xyw * reflectivity * FresnelRI.w) - q39.xyz)) + q39.xyz;
	q30.xyz = (SunDir.w * q29.xyz) + q23.xyz;
    OUT.color_0.a = IN.LTEXCOORD_6.w;
    OUT.color_0.rgb = (pow(abs(q7.x), FresnelRI.y) * (FogColor.rgb - q30.xyz)) + q30.xyz;
    return OUT;
	
};