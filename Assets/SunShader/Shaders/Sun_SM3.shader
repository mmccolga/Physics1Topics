//
// SunShader 1.3.0
//
// Panteleymonov Aleksandr 2017
//
// foxes@bk.ru
// mail@panteleymonov.ru
//

// UNITY_SHADER_NO_UPGRADE

Shader "Space/Star/Sun_low"
{
	Properties
	{
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
		//Tags { "RenderType" = "Opaque" }
		LOD 100

    // Body Pass
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
			fixed4 _Light;
			fixed4 _Color;
			fixed4 _Base;
			fixed4 _Dark;
			int _Detail;
			float _Zoom;
			float _SpeedHi;
			float _SpeedLow;
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
        o.vertex = mul(UNITY_MATRIX_MVP,float4(o.uv,1.0));
#endif
#ifdef UNITY_5_PLUS
        o.vertex = UnityObjectToClipPos(o.uv);
				UNITY_TRANSFER_FOG(o,o.vertex);
#endif
				return o;
			}

			// animated noise
			fixed4 hash4(fixed4 n) { return frac(sin(n)*(fixed)753.5453123); }
			//float4 hash4(float4 n) { return frac(sin(n)*(fixed)753.5453123); }

			// just a noise
			fixed noise4(fixed4 x)
			{
				fixed4 p = floor(x);
				p.x = p.x + dot(p.yz, fixed2(157.0, 113.0));
				p.xy = p.xx+frac((p.ww + fixed2(0,1))*0.00390625)*164352.0;//256.0*642.0;
				fixed4 f = frac(x);
				//f=smoothstep(0,1,f);//f = f*f*(3.0 - 2.0*f);
				fixed4 n1 = fixed4(0,113.0,157.0,270.0);
				fixed4 n2 = fixed4(1,114.0,158.0,271.0);
				fixed4 vs1 = lerp(hash4(n1.xyxy+p.xxyy), hash4(n2.xyxy+p.xxyy), f.xxxx);
				fixed4 vs2 = lerp(hash4(n1.zwzw+p.xxyy), hash4(n2.zwzw+p.xxyy), f.xxxx);
				vs1 = lerp(vs1, vs2, f.yyyy);
				fixed2 vs = lerp(vs1.xz, vs1.yw, f.zz);
				return lerp(vs.x, vs.y, f.w);
			}

			// mix noise for alive animation
			fixed noise4d(fixed4 x)
			{
				fixed4 n3 = fixed4(0,0.5,0,0.5);
				fixed4 p1 = floor(x.xxww+n3);
				fixed4 p2 = floor(x.yyzz+n3);
				p1.xy = p1.xy + floor(x.yy+n3.xy)*157.0 + floor(x.zz+n3.xy)*113.0;
				p1 = p1.xxyy+frac((p1.zzww + fixed4(0,1,0,1))*0.00390625)*fixed4(164352.0, 164352.0, -164352.0, -164352.0);
				//p1 = p1.xxyy + frac((p1.zzww + fixed4(0, 1, 0, 1))*0.00390625)*164352.0;
				fixed4 f1 = frac(x.xxyy+n3);
				fixed4 f2 = frac(x.zzww+n3);
				fixed4 n1 = fixed4(0,1.0,157.0,158.0);
				fixed4 n2 = fixed4(113.0,114.0,270.0,271.0);
				fixed4 vs1 = lerp(hash4(p1), hash4(n1.yyyy+p1), f1.xxyy);
				fixed4 vs2 = lerp(hash4(n1.zzzz+p1), hash4(n1.wwww+p1), f1.xxyy);
				vs1 = lerp(vs1, vs2, f1.zzww);
				vs2 = lerp(hash4(n2.xxxx+p1), hash4(n2.yyyy+p1), f1.xxyy);
				fixed4 vs3 = lerp(hash4(n2.zzzz+p1), hash4(n2.wwww+p1), f1.xxyy);
				vs2 = lerp(vs2, vs3, f1.zzww);
				vs1 = lerp(vs1, vs2, f2.xxyy);
				fixed2 vs=lerp(vs1.xz, vs1.yw, f2.zw);
				return dot(vs,fixed2(0.5, 0.5));
			}
		
			//fixed noise4t(fixed4 x)
			//{
			//	fixed4 p1=floor(x);
			//	fixed4 f1=frac(x);
			//	float of=dot(p1.xyz,fixed3(1.0,113.0,157.0))*0.015625*0.1;
			//	fixed4 ofv=of+fixed4(0,0.015625,1.765625,1.78125)*0.1;
			//	fixed2 ofv2=fixed2(x.w*0.015625,ofv.x);
			//	ofv.x=ofv2.x;
			//	fixed4 vs1=fixed4(tex2D(_MainTex,ofv2).r,tex2D(_MainTex,ofv.xy).r,tex2D(_MainTex,ofv.xz).r,tex2D(_MainTex,ofv.xw).r);
			//	ofv+=fixed4(0,2.453125,2.453125,2.453125)*0.1;
			//	ofv2.y+=2.453125*0.1;
			//	fixed4 vs2=fixed4(tex2D(_MainTex,ofv2).r,tex2D(_MainTex,ofv.xy).r,tex2D(_MainTex,ofv.xz).r,tex2D(_MainTex,ofv.xw).r);
			//	//fixed4 vs2=fixed4(tex2D(_MainTex,fixed2(x.w,of)).r,tex2D(_MainTex,fixed2(x.w,of+0.015625)).r,tex2D(_MainTex,fixed2(x.w,of+1.765625)).r,tex2D(_MainTex,fixed2(x.w,of+1.78125)).r);
			//	vs1=lerp(vs1, vs2, f1.zzzz);
			//	fixed2 vs=lerp(vs1.xy, vs1.zw, f1.yy);
			//	return lerp(vs.x, vs.y, f1.x);
			//}

			//fixed noise4r(fixed4 x)
			//{
				//return (noise4(x) + noise4(x += 0.25) + noise4(x += 0.25) + noise4(x += 0.25))*0.25;
				//return noise4q(x);
				//return (noise4(x) + noise4(x += 0.3333) + noise4(x += 0.3333))*0.3333;
				//return (noise4(x) + noise4(x += 0.5))*0.5;
				//return noise4d(x);
				//return noise4(x);
			//}
					
			float RayProj;
			float sqRadius; // sphere radius
			float fragTime;
			float sphere; // sphere distance
			float3 surfase; // position on surfase

			// body of a star
			fixed noiseSpereA(float zoom, fixed3 subnoise, float anim)
			{
				fixed s = 0.0;

				if (sphere <sqRadius) {
					fixed3 vs=surfase*zoom;
          if (_Detail>0.0) s = noise4d(fixed4(vs*_BodyNoiseS.x + subnoise, fragTime*_SpeedHi))*_BodyNoiseL.x;//0.625;
          if (_Detail>1.0) s =s*0.85+noise4d(fixed4(vs*_BodyNoiseS.y + subnoise*3.0, fragTime*_SpeedHi*3.0))*_BodyNoiseL.y;//0.125;
          //if (_Detail>2.0) s =s*0.94+noise4(fixed4(vs*307.2 + subnoise*5.0, anim*5.0))*0.0625;//0.03125;
          //if (_Detail>3.0) s =s*0.98+noise4(fixed4(vs*600.0 + subnoise*6.0, anim*6.0))*0.03125;
          //if (_Detail>4.0) s =s*0.98+noise4(fixed4(vs*1200.0 + subnoise*9.0, anim*9.0))*0.01125;
				}
				return s;
			}
			
			// body of a star
			fixed noiseSpereB(float zoom, fixed3 subnoise, float anim)
			{
				fixed s = 0.0;

				if (sphere <sqRadius) {
					fixed3 vs=surfase*zoom;
          if (_Detail>0.0) s = noise4d(fixed4(vs*_BodyNoiseS.x + subnoise, fragTime*_SpeedHi))*_BodyNoiseL.x;//0.625;
          if (_Detail>1.0) s =s*0.85+noise4(fixed4(vs*_BodyNoiseS.y + subnoise*3.0, fragTime*_SpeedHi*3.0))*_BodyNoiseL.y;//0.125;
          if (_Detail>2.0) s =s*0.94+noise4(fixed4(vs*_BodyNoiseS.z + subnoise*5.0, anim*5.0))*_BodyNoiseL.z;//0.0625;//0.03125;
          //if (_Detail>3.0) s =s*0.98+noise4(fixed4(vs*600.0 + subnoise*6.0, anim*6.0))*0.03125;
          //if (_Detail>4.0) s =s*0.98+noise4(fixed4(vs*1200.0 + subnoise*9.0, anim*9.0))*0.01125;
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
				float3 pr = ray*abs(RayProj) - posGlob.xyz;

				fixed4 col = fixed4(0,0,0,0);				
				if (sqDist<=sqRadius) {
					surfase=-posGlob;
					sphere=sqDist;
				} else if (sphere <sqRadius) {
					float l1 = sqrt(sqRadius - sphere);
					surfase = mul(m,pr - ray*l1);
					col.w=1.0;
				} else {
					surfase=(float3)0;
				}
				//surfase=(float3)0;
				//col.w=0.0;

				if (_Detail >= 1.0) {
					fixed s1 = noiseSpereA(0.5*_Zoom, fixed3(45.78, 113.04, 28.957)*_Seed, fragTime*_SpeedLow);
					s1 = pow(s1*2.4, 2.0);
					fixed s2 = noiseSpereB(4.0*_Zoom, fixed3(83.23, 34.34, 67.453)*_Seed, fragTime*_SpeedHi);
					s2 = s2*2.2;

					col.xyz = fixed3(lerp((fixed3)_Color, (fixed3)_Light, pow(s1, 60.0))*s1);
					col.xyz += fixed3(lerp(lerp((fixed3)_Base, (fixed3)_Dark, s2*s2), (float3)_Light, pow(s2, 10.0))*s2);
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

    // Ray Pass
    Pass
    {
      //Tags{ "Queue" = "Transparent" }
      Blend One OneMinusSrcAlpha
      //ZWrite Off
      //Cull Front
      //ColorMask 0
      CGPROGRAM
#pragma vertex vert
#pragma fragment frag
      // make fog work
      //#pragma multi_compile_fog
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
      o.vertex = UnityObjectToClipPos(float4(o.uv, 1.0));
#endif
#ifdef UNITY_5_PLUS
      o.vertex = UnityObjectToClipPos(o.uv);
#endif

#ifdef UNITY_5_PLUS
      UNITY_TRANSFER_FOG(o,o.vertex);
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

    if (sqDist>sqRadius)
      col.xyz = col.xyz + lerp((fixed3)_Ray, (fixed3)_RayLight, s3*s3*s3)*s3; //pow(s3, 3.0)

    col.xyz *= _Exposure;
    col = clamp(col, 0, 1);

#ifdef UNITY_5_0
    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, col);
#endif
    return col;
    }
      ENDCG
    }
	}
}
