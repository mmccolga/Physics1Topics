//
// SunShader 1.3.0
//
// Panteleymonov Aleksandr 2017
//
// foxes@bk.ru
// mail@panteleymonov.ru
//

// UNITY_SHADER_NO_UPGRADE

Shader "Space/Star/Sun_soft_animated"
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
		_RayGlow("Ray Glow", Range(1.0,10.0)) = 2.0
		_Glow("Glow", Range(1.0,100.0)) = 4.0
    _Zoom("Zoom", Float) = 1.0
    _Speed("Speed", Range(0.0,10)) = 1.0
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
        float3 uv : TEXCOORD0;
#ifdef UNITY_5_PLUS
				UNITY_FOG_COORDS(1)
#endif
				float4 vertex : SV_POSITION;
			};

      sampler2D _AT;
      float4 _AT_ST;
      float _Exposure;
      fixed4 _Light;
      fixed4 _Color;
      fixed4 _Base;
      fixed4 _Dark;
			float _Radius;
			float _RayString;
			fixed4 _Ray;
			fixed4 _RayLight;
			float _RayGlow;
      float _Zoom;
			float _Speed;
			float _Glow;

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
			float fragTime;
			float sphere; // sphere distance
			float3 surfase; // position on surfase

      float3 Sphere(float3 pos, float scale)
      {
        float2 l = pos.xz / max(abs(pos.x), abs(pos.z));
        float y = atan2(length(pos.xz), abs(pos.y)) * scale / 3.141592653589793238;
        return float3(l*abs(y) + 0.5, clamp((pos.y + 0.03125)*32.0f, 0, 1));
      }

			fixed4 frag (v2f i) : SV_Target
			{
        float invz = 1 / _Zoom;
        _Radius *= invz;
				fragTime=_Time.x*_Speed * 50.0;
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
				fixed c = length(prs);
				fixed s = max(0.0, (1.0 - abs(_Radius - c) / _RayString));
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
				
        float3 pos = Sphere(surfase, 1.0 / 1.5);
				if (RayProj>0.0) {
          float2 frames = 1.0 / _AT_ST.xy;
          float id = floor(frames.x*frames.y*0.5);
          float t = floor(frac(fragTime/id)*id) * 2;
          float f = frac(fragTime);
          float3 val = tex2D(_AT, (pos.xy + floor(float2(frac(t/frames.x) * frames.x, t / frames.x)))*_AT_ST.xy).xyz;
          val = lerp(tex2D(_AT, (pos.xy + +floor(float2((frac(t/frames.x) * frames.x) + 1, t / frames.x)))*_AT_ST.xy).xyz, val, pos.z);
          t = floor(frac((fragTime + 1)/id)*id) * 2;
          float3 c2 = tex2D(_AT, (pos.xy + floor(float2(frac(t/frames.x) * frames.x, t / frames.x)))*_AT_ST.xy).xyz;
          c2 = lerp(tex2D(_AT, (pos.xy + floor(float2((frac(t/frames.x) * frames.x) + 1, t / frames.x)))*_AT_ST.xy).xyz, c2, pos.z);
          val = lerp(val, c2, f)*2.0f;
          
          col.xyz = float3(lerp((float3)_Color, (float3)_Light, val.y)*val.x);
          col.xyz += float3(lerp(lerp((float3)_Base, (float3)_Dark, val.z*val.z), (float3)_Light, pow(abs(val.z), 10.0))*val.z);

          col*=sc;
					col*=lerp(dot(col.xyz,float3(0.33, 0.33, 0.33)),1.0,sc);
					s=s*pow(s, _Glow);
					col+=lerp(_Ray, _RayLight,s)*s;
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
