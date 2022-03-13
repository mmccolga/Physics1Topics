//
// SunShader 1.3.0
//
// Panteleymonov Aleksandr 2017
//
// foxes@bk.ru
// mail@panteleymonov.ru
//

// UNITY_SHADER_NO_UPGRADE

Shader "Space/Star/Sun_rnd2_low"
{
	Properties
	{
    _RND("Noise", 2D) = "defaulttexture" {}
    _Exposure("Exposure",Range(0,8)) = 1
		_Radius("Radius", Float) = 0.5
		_Light("Light",Color) = (1,1,1,1)
		_Color("Color", Color) = (1,1,0,1)
		_Base("Base", Color) = (1,0,0,1)
		_Dark("Dark", Color) = (1,0,1,1)
		_Detail("Detail Body", Range(0,5)) = 3
		_Glow("Glow", Range(1.0,100.0)) = 4.0
		_Zoom("Zoom", Float) = 1.0
		_SpeedHi("Speed Hi", Range(0.0,10)) = 2.0
		_SpeedLow("Speed Low", Range(0.0,10)) = 2.0
		_Seed("Seed", Range(-10,10)) = 0
		_BodyNoiseL("Body Noise Light", Vector) = (0.625,0.125,0.0625,0.03125)
		_BodyNoiseS("Body Noise Scale", Vector) = (3.6864,61.44,307.2,600.0)

    _RayString("Ray String", Range(0.02,10.0)) = 1.0
    _RayLight("Ray Light", Color) = (1,0.95,1.0,1)
    _Ray("Ray End", Color) = (1,0.6,0.1,1)
    _Rays("Rays", Range(1.0,10.0)) = 2.0
    _RayRing("Ray Ring", Range(1.0,10.0)) = 1.0
    _RayGlow("Ray Glow", Range(1.0,10.0)) = 2.0
    _SpeedRay("Speed Ray", Range(0.0,10)) = 5.0
    _SpeedRing("Speed Ring", Range(0.0,20)) = 2.0
    _RayNoiseS("Ray Noise Scale", Vector) = (1.0,10.0,5.0,3.0)
	}
		SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		LOD 100

    // Body pass
		Pass
		{
			Blend One OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			
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

			sampler2D _RND;
      float _Exposure;
      float4 _RND_ST;
			float _Radius;
			float _RayString;
			fixed4 _Light;
			fixed4 _Color;
			fixed4 _Base;
			fixed4 _Dark;
			fixed4 _Ray;
			fixed4 _RayLight;
			int _Detail;
			float _Rays;
			float _RayRing;
			float _RayGlow;
			float _Zoom;
			float _SpeedHi;
			float _SpeedLow;
			float _SpeedRay;
			float _SpeedRing;
			float _Glow;
			float _Seed;
			float4 _BodyNoiseL;
			float4 _BodyNoiseS;

			float3 posGlob; // center position
									
			v2f vert (appdata v)
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

      fixed noise2t(fixed4 x, float scale)
      {
        scale *= _RND_ST.x;
        float3 pos = x.xyz * _RND_ST.x;//0.001953125;
        float3 mix = pos.xyz * pos.xyz;
        mix = mix / (mix.x + mix.y + mix.z);
        float4 hm1 = tex2D(_RND, pos.yz)*mix.x + tex2D(_RND, pos.xz*scale).yzwx*mix.y + tex2D(_RND, pos.xy).zwxy*mix.z;
        float4 hm2 = tex2D(_RND, pos.yz + 11.5*scale)*mix.x + tex2D(_RND, pos.xz + 11.5*scale).yzwx*mix.y + tex2D(_RND, pos.xy + 454.5*scale).zwxy*mix.z;
        float4 t1 = frac(x.w * 0.25 + float4(0, 0.25, 0.5, 0.75));
        float4 t3 = frac(x.w * 0.25 + float4(0, 0.25, 0.5, 0.75) + 0.125);
        return (dot(hm1, clamp(1.0 - abs(t1 - 0.25)*4.0, 0, 1)) + dot(hm2, clamp(1.0 - abs(t3 - 0.25)*4.0, 0, 1)))*0.5;
      }

      fixed noise4t(fixed4 x)
      {
        return noise2t(x, length(x.xyz));
      }
						
			float RayProj;
			float sqRadius; // sphere radius
			float fragTime;
			float sphere; // sphere distance
			float3 surfase; // position on surfase

			// body of a star
			fixed noiseSpere(float zoom, float3 subnoise, float anim)
			{
				fixed s = 0.0;

				if (sphere <sqRadius) {
					if (_Detail>0.0) s = noise4t(fixed4(surfase*zoom*_BodyNoiseS.x + subnoise, fragTime*_SpeedHi))*_BodyNoiseL.x;//*0.625;
					if (_Detail>1.0) s =s*0.85+noise4t(fixed4(surfase*zoom*_BodyNoiseS.y + subnoise*3.0, fragTime*_SpeedHi*3.0))*_BodyNoiseL.y;//*0.125;
					if (_Detail>2.0) s =s*0.94+noise4t(fixed4(surfase*zoom*_BodyNoiseS.z + subnoise*5.0, anim*5.0))*_BodyNoiseL.z;//*0.0625;//*0.03125;
					if (_Detail>3.0) s =s*0.98+noise4t(fixed4(surfase*zoom*_BodyNoiseS.w + subnoise*6.0, fragTime*_SpeedLow*6.0))*_BodyNoiseL.w;//*0.03125;
					if (_Detail>4.0) s =s*0.98+noise4t(fixed4(surfase*zoom*_BodyNoiseS.w*2.0 + subnoise*9.0, fragTime*_SpeedLow*9.0))*_BodyNoiseL.w*0.36; //0.01125
				}

				return s;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float invz =1/_Zoom;
				_Radius*=invz;
				fragTime=_Time.x*10.0;
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

				RayProj = dot(ray, posGlob.xyz);
				float sqDist=dot(posGlob.xyz, posGlob.xyz);
				sphere = sqDist - RayProj*RayProj;
				sqRadius = _Radius*_Radius;
				if (RayProj<=0.0) sphere=sqRadius;
				float3 pr = ray*abs(RayProj) - (float3)posGlob;
				
				fixed4 col = fixed4(0, 0, 0, 0);
				if (sqDist<=sqRadius) {
					surfase=(float3)-posGlob;
					sphere=sqDist;
				} else if (sphere <sqRadius) {
					float l1 = sqrt(sqRadius - sphere);
					surfase = mul(m,pr - ray*l1);
					col.w = 1.0;
				} else {
					surfase=(float3)0;
				}

				if (_Detail >= 1.0) {
					float s1 = noiseSpere(0.5*_Zoom, float3(45.78, 113.04, 28.957)*_Seed, fragTime*_SpeedLow);
          s1 = s1*5.76*s1;
					float s2 = noiseSpere(4.0*_Zoom, float3(83.23, 34.34, 67.453)*_Seed, fragTime*_SpeedHi);
					s2 = s2*2.2;
					
					col.xyz = fixed3(lerp((float3)_Color, (float3)_Light, pow(s1, 60.0))*s1);
					col.xyz += fixed3(lerp(lerp((float3)_Base, (float3)_Dark, s2*s2), (float3)_Light, pow(s2, 10.0))*s2);
				}
				
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

    // Ray pass
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

    sampler2D _RND;
    float _Exposure;
    float4 _RND_ST;
    float _Radius;
    float _RayString;
    fixed4 _Light;
    fixed4 _Color;
    fixed4 _Base;
    fixed4 _Dark;
    fixed4 _Ray;
    fixed4 _RayLight;
    int _Detail;
    float _Rays;
    float _RayRing;
    float _RayGlow;
    float _Zoom;
    float _SpeedHi;
    float _SpeedLow;
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

    fixed noise2t(fixed4 x, float scale)
    {
      scale *= _RND_ST.x;
      float3 pos = x.xyz * _RND_ST.x;//0.001953125;
      float3 mix = pos.xyz * pos.xyz;
      mix = mix / (mix.x + mix.y + mix.z);
      float4 hm1 = tex2D(_RND, pos.yz)*mix.x + tex2D(_RND, pos.xz).yzwx*mix.y + tex2D(_RND, pos.xy).zwxy*mix.z;
      float4 hm2 = tex2D(_RND, pos.yz + 454.5*scale)*mix.x + tex2D(_RND, pos.xz + 454.5*scale).yzwx*mix.y + tex2D(_RND, pos.xy + 454.5*scale).zwxy*mix.z;
      float4 t1 = frac(x.w * 0.25 + float4(0, 0.25, 0.5, 0.75));
      float4 t3 = frac(x.w * 0.25 + float4(0, 0.25, 0.5, 0.75) + 0.125);
      return (dot(hm1, clamp(1.0 - abs(t1 - 0.25)*4.0, 0, 1)) + dot(hm2, clamp(1.0 - abs(t3 - 0.25)*4.0, 0, 1)))*0.43;
    }

    fixed noise4t(fixed4 x)
    {
      return noise2t(x, length(x.xyz));
    }

    float RayProj;
    float sqRadius; // sphere radius
    float fragTime;
    float sphere; // sphere distance
    float3 surfase; // position on surfase

                    // body of a star
    fixed noiseSpere(float zoom, float3 subnoise, float anim)
    {
      fixed s = 0.0;

      if (sphere <sqRadius) {
        if (_Detail>0.0) s = noise4t(fixed4(surfase*zoom*3.6864 + subnoise, fragTime*_SpeedHi))*0.625;
        if (_Detail>1.0) s = s*0.85 + noise4t(fixed4(surfase*zoom*61.44 + subnoise*3.0, fragTime*_SpeedHi*3.0))*0.125;
        if (_Detail>2.0) s = s*0.94 + noise4t(fixed4(surfase*zoom*307.2 + subnoise*5.0, anim*5.0))*0.0625;//*0.03125;
        if (_Detail>3.0) s = s*0.98 + noise4t(fixed4(surfase*zoom*600.0 + subnoise*6.0, fragTime*_SpeedLow*6.0))*0.03125;
        if (_Detail>4.0) s = s*0.98 + noise4t(fixed4(surfase*zoom*1200.0 + subnoise*9.0, fragTime*_SpeedLow*9.0))*0.01125;
      }

      return s;
    }

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
    if (RayProj <= 0.0) sphere = sqRadius;
    float3 pr = ray*abs(RayProj) - (float3)posGlob;
    //RayProj=max(0,min(1.0,RayProj*1000.0));

    if (sqDist <= sqRadius) {
      sphere = sqDist;
    }

    fixed4 col = fixed4(0,0,0,0);

    fixed c = length(pr)*_Zoom;
    pr = normalize(mul(m, pr))*_RayNoiseS.x;//-ray;
    fixed s = max(0.0, (1.0 - abs(_Radius*_Zoom - c) / _RayString));//*RayProj;
    float3 noises01 = float3(83.23, 34.34, 67.453)*_Seed;
    fixed nd = noise4t(float4(pr + noises01, -fragTime*_SpeedRing + c))*2.0;
    nd = pow(nd, 2.0);
    fixed dr = 1.0;
    if (sphere < sqRadius) dr = sphere / sqRadius;
    pr *= _RayNoiseS.y;
    fixed n = noise4t(float4(pr + noises01, -fragTime*_SpeedRing + c))*dr;
    pr *= _RayNoiseS.z;
    fixed ns = noise4t(float4(pr + noises01, -fragTime*_SpeedRay + c*2.0))*2.0*dr;
    if (_Detail >= 3.0) {
      pr *= _RayNoiseS.w;
      ns = ns*0.5 + noise4t(float4(pr + noises01, -fragTime*_SpeedRay + 0))*dr;
    }
    n = pow(n, _Rays)*pow(nd,_RayRing)*ns;
    fixed s3 = pow(s, _Glow) + pow(s, _RayGlow)*n;

    //float s3 = ringRayNoise(ray, (float3)posGlob, _Radius, _RayString, m, fragTime);
    //if (sphere < sqRadius) col.w = 1.0-s3*dr;
    if (sqDist>sqRadius)
      col.xyz = col.xyz + lerp((fixed3)_Ray, (fixed3)_RayLight, s3*s3*s3)*s3; //pow(s3, 3.0)

    col *= _Exposure;
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
