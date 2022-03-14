//
// SunShader 1.3.0
//
// Panteleymonov Aleksandr 2017
//
// foxes@bk.ru
// mail@panteleymonov.ru
//

// UNITY_SHADER_NO_UPGRADE

Shader "Space/Star/Ray_low"
{
	Properties
	{
    _Exposure("Exposure",Range(0,8)) = 1
		_Radius("Radius", Float) = 0.5
    _RayString("Ray String", Range(0.02,10.0)) = 1.0
    _RayLight("Ray Light", Color) = (1,0.95,1.0,1)
    _Ray("Ray End", Color) = (1,0.6,0.1,1)
    _Rays("Rays", Range(1.0,10.0)) = 2.0
    _RayRing("Ray Ring", Range(1.0,10.0)) = 1.0
    _RayGlow("Ray Glow", Range(1.0,10.0)) = 2.0
    _Glow("Glow", Range(1.0,100.0)) = 4.0
    _Zoom("Zoom", Float) = 1.0
    _SpeedRay("Speed Ray", Range(0.0,10)) = 5.0
    _SpeedRing("Speed Ring", Range(0.0,20)) = 2.0
    _Seed("Seed", Range(-10,10)) = 0
    _RayNoiseS("Ray Noise Scale", Vector) = (1.0,10.0,5.0,3.0)
	}
		SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		//Tags { "RenderType" = "Opaque" }
		LOD 100

    // Ray Pass
    Pass
    {
      Blend One OneMinusSrcAlpha
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #pragma target 3.0

      #include "UnityCG.cginc"

#if UNITY_VERSION>=500
#define UNITY_5_PLUS
#else
#define UNITY_4_PLUS
#endif

    struct appdata
    {
      float4 vertex : POSITION;
      float2 uv : TEXCOORD0;
    };

    struct v2f
    {
      float3 uv : TEXCOORD0;
#ifdef UNITY_5_PLUS
      UNITY_FOG_COORDS(1)
#endif
      float4 vertex : SV_POSITION;
    };

    float _Exposure;
    float _Radius;
    float _RayString;
    fixed4 _Ray;
    fixed4 _RayLight;
    float _Rays;
    float _RayRing;
    float _RayGlow;
    float _Zoom;
    float _SpeedRay;
    float _SpeedRing;
    float _Glow;
    float _Seed;
    float4 _RayNoiseS;

    float3 posGlob; // center position

    v2f vert(appdata v)
    {
      v2f o;
      posGlob = WorldSpaceViewDir(float4(0.0, 0.0, 0.0, 1.0));
      float3 Z = -normalize(posGlob);
      float3 Y = cross(Z, float3(0.0, 1.0, 0.0));
      if (length(Y) == 0.0) Y = cross(Z, float3(1.0, 0.0, 0.0));
      Y = normalize(Y);
      float3 X = normalize(cross(Y, Z));
      float3x3 m = { X, Y, Z };
      o.uv = mul(transpose(m), (float3)v.vertex);

#ifdef UNITY_4_PLUS
      o.vertex = mul(UNITY_MATRIX_MVP,float4(o.uv, 1.0));
#endif
#ifdef UNITY_5_PLUS
      o.vertex = UnityObjectToClipPos(o.uv);
      UNITY_TRANSFER_FOG(o, o.vertex);
#endif
      return o;
    }

    // animated noise
    fixed4 hash4(fixed4 n) { return frac(sin(n)*(fixed)753.5453123); }

    // mix noise for alive animation
    fixed noise4d(fixed4 x)
    {
      fixed4 n3 = fixed4(0,0.5,0,0.5);
      fixed4 p1 = floor(x.xxww + n3);
      fixed4 p2 = floor(x.yyzz + n3);
      p1.xy = p1.xy + floor(x.yy + n3.xy)*157.0 + floor(x.zz + n3.xy)*113.0;
      p1 = p1.xxyy + frac((p1.zzww + fixed4(0, 1, 0, 1))*0.00390625)*fixed4(164352.0, 164352.0, -164352.0, -164352.0);
      //p1 = p1.xxyy+frac((p1.zzww + fixed4(0,1,0,1))*0.00390625)*164352.0;
      fixed4 f1 = frac(x.xxyy + n3);
      fixed4 f2 = frac(x.zzww + n3);
      fixed4 n1 = fixed4(0,1.0,157.0,158.0);
      fixed4 n2 = fixed4(113.0,114.0,270.0,271.0);
      fixed4 vs1 = lerp(hash4(p1), hash4(n1.yyyy + p1), f1.xxyy);
      fixed4 vs2 = lerp(hash4(n1.zzzz + p1), hash4(n1.wwww + p1), f1.xxyy);
      vs1 = lerp(vs1, vs2, f1.zzww);
      vs2 = lerp(hash4(n2.xxxx + p1), hash4(n2.yyyy + p1), f1.xxyy);
      fixed4 vs3 = lerp(hash4(n2.zzzz + p1), hash4(n2.wwww + p1), f1.xxyy);
      vs2 = lerp(vs2, vs3, f1.zzww);
      vs1 = lerp(vs1, vs2, f2.xxyy);
      fixed2 vs = lerp(vs1.xz, vs1.yw, f2.zw);
      return (vs.x + vs.y)*0.5;
    }

    float RayProj;
    float sqRadius; // sphere radius
    float fragTime;
    float sphere; // sphere distance

    fixed4 frag(v2f i) : SV_Target
    {
      float invz = 1 / _Zoom;
    _Radius *= invz;
    fragTime = _Time.x*10.0;
#ifdef UNITY_4_PLUS
    posGlob = float3(UNITY_MATRIX_MV[0].w, UNITY_MATRIX_MV[1].w, UNITY_MATRIX_MV[2].w);
    float3x3 m = transpose((float3x3)UNITY_MATRIX_V);
    float3 ray = normalize(mul((float3x3)UNITY_MATRIX_MV, i.uv) + posGlob.xyz);
#endif
#ifdef UNITY_5_PLUS
    posGlob = UnityObjectToViewPos(float4(0.0, 0.0, 0.0, 1.0));
    float3x3 m = transpose((float3x3)UNITY_MATRIX_V);
    float3 ray = normalize(UnityObjectToViewPos(float4(i.uv, 1.0)));
#endif

    RayProj = dot(ray, (float3)posGlob);
    sphere = dot((float3)posGlob, (float3)posGlob) - RayProj*RayProj;
    sqRadius = _Radius*_Radius;
    float sqDist = dot((float3)posGlob, (float3)posGlob);

    float3 pr = ray*abs(RayProj) - (float3)posGlob;

    fixed4 col = fixed4(0,0,0,0);

    fixed c = length(pr)*_Zoom;
    pr = normalize(mul(m, pr))*_RayNoiseS.x;
    fixed s = max(0.0, (1.0 - abs(_Radius*_Zoom - c) / _RayString));
    fixed nd = noise4d(float4(pr, -fragTime*_SpeedRing + c))*2.0;
    nd = pow(nd, 2.0);
    fixed dr = 1.0;
    if (sphere < sqRadius) dr = sphere / sqRadius;
    pr *= _RayNoiseS.y;
    fixed n = noise4d(float4(pr + _Seed, -fragTime*_SpeedRing + c))*dr;
    pr *= _RayNoiseS.z;
    fixed ns = noise4d(float4(pr + _Seed, -fragTime*_SpeedRay + c*2.0))*2.0*dr;
    n = pow(n, _Rays)*pow(nd,_RayRing)*ns;
    fixed s3 = pow(s, _Glow) + pow(s, _RayGlow)*n;

    //float s3 = ringRayNoise(ray, (float3)posGlob, _Radius, _RayString, m, fragTime);
    //if (sphere < sqRadius) col.w = 1.0-s3*dr;
    if (sqDist>sqRadius)
      col.xyz = col.xyz + lerp((fixed3)_Ray, (fixed3)_RayLight, s3*s3*s3)*s3; //pow(s3, 3.0)

    col.xyz *= _Exposure;
    col = clamp(col, 0, 1);

#ifdef UNITY_5_PLUS
    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, col);
#endif
    return col;
    }
      ENDCG
    }
	}
}
