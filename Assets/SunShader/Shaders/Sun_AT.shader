//
// SunShader 1.3.0
//
// Panteleymonov Aleksandr 2017
//
// foxes@bk.ru
// mail@panteleymonov.ru
//

// UNITY_SHADER_NO_UPGRADE

Shader "Space/Star/Sun_animated"
{
	Properties
	{
    _Exposure("Exposure",Range(0,8)) = 1
    _AT("Animated", 2D) = "defaulttexture" {}
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
		_RayGlow("Ray Glow", Range(1.0,10.0)) = 2.0
		_Glow("Glow", Range(1.0,100.0)) = 4.0
		_Zoom("Zoom", Float) = 1.0
    _Speed("Speed", Range(0.0,10)) = 1.0
		_RayNoiseS("Ray Noise Scale", Vector) = (1.0,10.0,5.0,3.0)
	}
		SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		//Tags { "RenderType" = "Opaque" }
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

      sampler2D _AT;
      float4 _AT_ST;
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
			float _RayGlow;
			float _Zoom;
      float _Speed;
			float _Glow;
			float4 _BodyNoiseL;
			float4 _BodyNoiseS;
			float4 _RayNoiseS;

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
					
			float RayProj;
			float sqRadius; // sphere radius
			float sphere; // sphere distance
			float3 surfase; // position on surfase

      float2 Mercator(float3 pos)
      {
        float l = atan2(pos.z, pos.x);
        float b = length(pos.xz);
        if (b <= 0) l = 0;
        float pi = 3.141592653589793238;
        return float2(l * 0.5, atan2(pos.y, b)) / pi + 0.5;
      }

      float3 Sphere(float3 pos,float scale)
      {
        float2 l = pos.xz/max(abs(pos.x), abs(pos.z));
        float y = atan2(length(pos.xz), abs(pos.y)) * scale / 3.141592653589793238;
        return float3(l*abs(y)+0.5, clamp((pos.y+0.01)*100.0f,0,1));
      }

			fixed4 frag (v2f i) : SV_Target
			{
				float invz = 1/i.uv.w;
				_Radius*=invz;
        float fragTime=_Time.x*_Speed*50.0;
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

				RayProj = dot(ray, (float3)posGlob);
				float sqDist=dot(posGlob.xyz, posGlob.xyz);
				sphere = sqDist - RayProj*RayProj;
				sqRadius = _Radius*_Radius;
				if (RayProj<=0.0) sphere=sqRadius;
				float3 pr = ray*abs(RayProj) - (float3)posGlob;
				
				if (sqDist<=sqRadius) {
					surfase=-posGlob;
					sphere=sqDist;
				} else if (sphere <sqRadius) {
					float l1 = sqrt(sqRadius - sphere);
					surfase = mul(m,pr - ray*l1);
				} else {
					surfase=(float3)0;
				}

				fixed4 col = fixed4(0,0,0,0);

        float2 frames = 1.0 / _AT_ST.xy;
        float id = floor(frames.x*frames.y*0.5);
        float t;
        float f;

        float3 pos = Sphere(surfase, 1.0 / 1.5);
				if (_Detail >= 1.0 && sphere <sqRadius) {
          t = floor(frac(fragTime/id)*id)*2;
          f = frac(fragTime);
          float3 val = tex2D(_AT, (pos.xy + floor(float2(frac(t/frames.x) * frames.x, t / frames.x)))*_AT_ST.xy).xyz;
          val = lerp(tex2D(_AT, (pos.xy+ + floor(float2((frac(t/frames.x) * frames.x)+1, t / frames.x)))*_AT_ST.xy).xyz, val, pos.z);
          t = floor(frac((fragTime + 1)/id)*id)*2;
          float3 c2 = tex2D(_AT, (pos.xy + floor(float2(frac(t/frames.x) * frames.x, t / frames.x)))*_AT_ST.xy).xyz;
          c2 = lerp(tex2D(_AT, (pos.xy + floor(float2((frac(t/frames.x) * frames.x)+1, t / frames.x)))*_AT_ST.xy).xyz, c2, pos.z);
          val = lerp(val, c2, f)*2.0f;

          col.xyz = float3(lerp((float3)_Color, (float3)_Light, val.y)*val.x);
          col.xyz += float3(lerp(lerp((float3)_Base, (float3)_Dark, val.z*val.z), (float3)_Light, pow(abs(val.z), 10.0))*val.z);
				}

        fixed dr = 1.0;
        if (sphere < sqRadius) dr = sphere / sqRadius;
				fixed c = length(pr)*i.uv.w;
				pr = normalize(mul(m, pr))*_RayNoiseS.x;//-ray;
        pos = Sphere(pr, 1.0 / 1.5);
				fixed s = max(0.0, (1.0 - abs(_Radius*i.uv.w - c) / _RayString));

        fragTime *= 2.0f;
        t = floor(frac(fragTime/id)*id) * 2;
        f = frac(fragTime);
        float valw = tex2D(_AT, (pos.xy + floor(float2(frac(t/frames.x) * frames.x, t / frames.x)))*_AT_ST.xy).w;
        valw = lerp(tex2D(_AT, (pos.xy + +floor(float2((frac(t/frames.x) * frames.x) + 1, t / frames.x)))*_AT_ST.xy).w, valw, pos.z);
        t = floor(frac((fragTime + 1)/id)*id) * 2;
        float g2 = tex2D(_AT, (pos.xy + floor(float2(frac(t/frames.x) * frames.x, t / frames.x)))*_AT_ST.xy).w;
        g2 = lerp(tex2D(_AT, (pos.xy + floor(float2((frac(t/frames.x) * frames.x) + 1, t / frames.x)))*_AT_ST.xy).w, g2, pos.z);
        valw = lerp(valw, g2, f);

        fragTime += 2.0f;
        t = floor(frac(fragTime/id)*id) * 2;
        f = frac(fragTime);
        float valw2 = tex2D(_AT, (pos.xy + floor(float2(frac(t/frames.x) * frames.x, t / frames.x)))*_AT_ST.xy).w;
        valw2 = lerp(tex2D(_AT, (pos.xy + +floor(float2((frac(t/frames.x) * frames.x) + 1, t / frames.x)))*_AT_ST.xy).w, valw2, pos.z);
        t = floor(frac((fragTime + 1)/id)*id) * 2;
        g2 = tex2D(_AT, (pos.xy + floor(float2(frac(t/frames.x) * frames.x, t / frames.x)))*_AT_ST.xy).w;
        g2 = lerp(tex2D(_AT, (pos.xy + floor(float2((frac(t/frames.x) * frames.x) + 1, t / frames.x)))*_AT_ST.xy).w, g2, pos.z);
        valw2 = lerp(valw2, g2, f);
        valw = lerp(valw, valw2, clamp(sqrt(sphere - sqRadius)/_RayString,0,1));

        float n = valw*2.0f *pow(dr, _Rays + 1);
        fixed s3 = pow(s, _Glow) + pow(s, _RayGlow)*n;

        if (sphere < sqRadius) col.w = 1.0 -s3*dr;
				if (sqDist>sqRadius)
			  	col.xyz = col.xyz+lerp((fixed3)_Ray, (fixed3)_RayLight, s3*s3*s3)*s3;
				
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
