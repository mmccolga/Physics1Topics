//
// SunShader 1.3.0
//
// Panteleymonov Aleksandr 2017
//
// foxes@bk.ru
// mail@panteleymonov.ru
//

// UNITY_SHADER_NO_UPGRADE

Shader "Space/Star/Sun_soft_low"
{
	Properties
	{
    _Exposure("Exposure",Range(0,8)) = 1
		_Radius("Radius", Float) = 0.5
		_Light("Light",Color) = (1,1,1,1)
		_Color("Color", Color) = (1,1,0,1)
		_Base("Base", Color) = (1,0,0,1)
		_Dark("Dark", Color) = (1,0,1,1)
		_RayString("Ray String", Range(0.02,10.0)) = 1.0
		_RayLight("Ray Light", Color) = (1,0.95,1.0,1)
		_Ray("Ray End", Color) = (1,0.6,0.1,1)
		_Detail("Detail Body", Range(0,5)) = 3
		_Rays("Rays", Range(1.0,10.0)) = 2.0
		_RayRing("Ray Ring", Range(1.0,10.0)) = 1.0
		_RayGlow("Ray Glow", Range(1.0,10.0)) = 2.0
		_Glow("Glow", Range(1.0,100.0)) = 4.0
		_Zoom("Zoom", Float) = 1.0
		_SpeedHi("Speed Hi", Range(0.0,10)) = 2.0
		_SpeedLow("Speed Low", Range(0.0,10)) = 2.0
		_SpeedRay("Speed Ray", Range(0.0,10)) = 5.0
		_SpeedRing("Speed Ring", Range(0.0,20)) = 2.0
		_Seed("Seed", Range(-10,10)) = 0
		_BodyNoiseL("Body Noise Light", Vector) = (0.625,0.125,0.0625,0.03125)
		_BodyNoiseS("Body Noise Scale", Vector) = (3.6864,61.44,307.2,600.0)
	}
		SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		LOD 100

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
        float4 uv : TEXCOORD0;
#ifdef UNITY_5_PLUS
				UNITY_FOG_COORDS(1)
#endif
				float4 vertex : SV_POSITION;
			};

      float _Exposure;
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
        o.uv.xyz = mul(transpose(m), (float3)v.vertex);
				o.uv.w = _Zoom;
				
#ifdef UNITY_4_PLUS
        o.vertex = mul(UNITY_MATRIX_MVP,float4(o.uv.xyz, 1.0));
#endif
#ifdef UNITY_5_PLUS
        o.vertex = UnityObjectToClipPos(o.uv.xyz);
        UNITY_TRANSFER_FOG(o, o.vertex);
#endif
				return o;
			}

			// animated noise
			fixed4 hash4(fixed4 n) { return frac(sin(n)*(fixed)1399763.5453123); }

			// just a noise
			fixed noise4(fixed4 x)
			{
				fixed4 p = floor(x);
				p.x = p.x + dot(p.yz, fixed2(157.0, 113.0));
				p.xy = p.xx + frac((p.ww + fixed2(0, 1))*0.00390625)*164352.0;//256.0*642.0;
				fixed4 f = frac(x);
				//f=smoothstep(0,1,f);//f = f*f*(3.0 - 2.0*f);
				fixed4 n1 = fixed4(0, 113.0, 157.0, 270.0);
				fixed4 n2 = fixed4(1, 114.0, 158.0, 271.0);
				fixed4 vs1 = lerp(hash4(n1.xyxy + p.xxyy), hash4(n2.xyxy + p.xxyy), f.xxxx);
				fixed4 vs2 = lerp(hash4(n1.zwzw + p.xxyy), hash4(n2.zwzw + p.xxyy), f.xxxx);
				vs1 = lerp(vs1, vs2, f.yyyy);
				fixed2 vs = lerp(vs1.xz, vs1.yw, f.zz);
				return lerp(vs.x, vs.y, f.w);
			}

			// mix noise for alive animation
			fixed noise4d(fixed4 x)
			{
				fixed4 n3 = fixed4(0, 0.5, 0, 0.5);
				fixed4 p1 = floor(x.xxww + n3);
				fixed4 p2 = floor(x.yyzz + n3);
				p1.xy = p1.xy + floor(x.yy + n3.xy)*157.0 + floor(x.zz + n3.xy)*113.0;
				p1 = p1.xxyy + frac((p1.zzww + fixed4(0, 1, 0, 1))*0.00390625)*fixed4(164352.0, 164352.0, -164352.0, -164352.0);
				fixed4 f1 = frac(x.xxyy + n3);
				fixed4 f2 = frac(x.zzww + n3);
				fixed4 n1 = fixed4(0, 1.0, 157.0, 158.0);
				fixed4 n2 = fixed4(113.0, 114.0, 270.0, 271.0);
				fixed4 vs1 = lerp(hash4(p1), hash4(n1.yyyy + p1), f1.xxyy);
				fixed4 vs2 = lerp(hash4(n1.zzzz + p1), hash4(n1.wwww + p1), f1.xxyy);
				vs1 = lerp(vs1, vs2, f1.zzww);
				vs2 = lerp(hash4(n2.xxxx + p1), hash4(n2.yyyy + p1), f1.xxyy);
				fixed4 vs3 = lerp(hash4(n2.zzzz + p1), hash4(n2.wwww + p1), f1.xxyy);
				vs2 = lerp(vs2, vs3, f1.zzww);
				vs1 = lerp(vs1, vs2, f2.xxyy);
				fixed2 vs = lerp(vs1.xz, vs1.yw, f2.zw);
				return dot(vs, fixed2(0.5, 0.5));
			}
					
			float RayProj;
			float sqRadius; // sphere radius
			float fragTime;
			float sphere; // sphere distance
			float3 surfase; // position on surfase

			// body of a star
			fixed noiseSpereA(float zoom, float3 subnoise, float anim)
			{
				fixed s = 0.0;

				//if (sphere <sqRadius) {
				fixed3 vs=surfase*zoom;
				if (_Detail>0.0) s = noise4d(fixed4(vs*_BodyNoiseS.x + subnoise, fragTime*_SpeedHi))*_BodyNoiseL.x;//0.625;
				if (_Detail>1.0) s =s*0.85+noise4d(fixed4(vs*_BodyNoiseS.y + subnoise*3.0, fragTime*_SpeedHi*3.0))*_BodyNoiseL.y;//*0.125;
				return s;
			}

			fixed noiseSpereB(float zoom, float3 subnoise, float anim)
			{
				fixed s = 0.0;

				//if (sphere <sqRadius) {
				fixed3 vs=surfase*zoom;
				if (_Detail>0.0) s = noise4d(fixed4(vs*_BodyNoiseS.x + subnoise, fragTime*_SpeedHi))*_BodyNoiseL.x;//*0.625;
				if (_Detail>1.0) s =s*0.85+noise4(fixed4(vs*_BodyNoiseS.y + subnoise*3.0, fragTime*_SpeedHi*3.0))*_BodyNoiseL.y;//*0.125;
				//if (_Detail>2.0) s =s*0.94+noise4(fixed4(vs*_BodyNoiseS.z + subnoise*5.0, anim*5.0))*_BodyNoiseL.z;//*0.0625;//*0.03125;

				return s;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float invz = 1/i.uv.w;
				_Radius*=invz;
				fragTime=_Time.x*10.0;
#ifdef UNITY_4_PLUS
        posGlob = float3(UNITY_MATRIX_MV[0].w, UNITY_MATRIX_MV[1].w, UNITY_MATRIX_MV[2].w);
        float3x3 m = transpose((float3x3)UNITY_MATRIX_V);
        float3 ray = normalize(mul((float3x3)UNITY_MATRIX_MV, i.uv.xyz) + posGlob.xyz);
#endif
#ifdef UNITY_5_PLUS
        posGlob = UnityObjectToViewPos(float4(0.0, 0.0, 0.0, 1.0));
        float3x3 m = transpose((float3x3)UNITY_MATRIX_V);
        float3 ray = normalize(UnityObjectToViewPos(float4(i.uv.xyz, 1.0)));
#endif

				float sqDist=dot(posGlob.xyz, posGlob.xyz);
				RayProj = dot(ray, posGlob.xyz);
				sphere = sqDist - RayProj*RayProj;
				sqRadius = _Radius*_Radius;
				if (RayProj<=0.0) sphere=sqRadius;
				float3 prs = ray*RayProj-posGlob;
				float3 pr = ray*sqDist/RayProj-posGlob;
				
				fixed sc = 1.0;
				fixed c = length(prs)*i.uv.w;
				fixed s = max(0.0, (1.0 - abs(_Radius*i.uv.w - c) / _RayString));
				s=pow(s, _RayGlow);
				float lr=_Radius;
				if (sqDist<=sqRadius) {
					surfase=-posGlob;
					sphere=sqDist;
				} else if (sphere <sqRadius) {
					float l1 = sqrt(sqRadius - sphere);
					surfase = mul(m,prs - ray*l1);
				} else {
					float l1 = length(pr);
					lr=pow(l1-_Radius+1.0,0.4)-1.0+_Radius;
					l1 = _Radius/l1;
					surfase = mul(m,pr*l1);
					sc=s;
				}

				fixed4 col = fixed4(0,0,0,0);
				
				if (_Detail >= 1.0 && RayProj>0.0) {
					float s1 = noiseSpereA(0.5*i.uv.w, float3(45.78, 113.04, 28.957)*_Seed, -lr*2.0);
					s1 = pow(s1*2.4, 2.0);
					float s2 = noiseSpereB(4.0*i.uv.w, float3(83.23, 34.34, 67.453)*_Seed, -lr*2.0);
					s2 = s2*2.2;

					col.xyz = clamp(fixed3(lerp((float3)_Color, (float3)_Light, pow(s1, 10.0))*s1), 0, 1);
					col.xyz += clamp(fixed3(lerp(lerp((float3)_Base, (float3)_Dark, s2*s2), (float3)_Light, pow(s2, 10.0))*s2), 0, 1);
					col*=sc;
					col*=lerp(s1-s2,1.0,sc);
					s=pow(s, _Glow);
					col += lerp(_Ray, _RayLight, s)*s;
					if (sphere < sqRadius) col.w = 1.0-s;
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
	}
}
