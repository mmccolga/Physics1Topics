//
// SunShader 1.3.0
//
// Panteleymonov Aleksandr 2017
//
// foxes@bk.ru
// mail@panteleymonov.ru
//

// UNITY_SHADER_NO_UPGRADE

Shader "Space/Sky Box/Stars Space"
{
  Properties
  {
    _Exposure("Exposure",Range(0,8)) = 1
    _StarsColor1("Stars Color1",Color) = (1,0,0,1)
    _StarsColor2("Stars Color2",Color) = (0,0,1,1)
    _StarsColor3("Stars Color3",Color) = (1,1,1,1)
    _FirstStarsBright("First Stars Bright", Float) = 1.0
    _SecondStarsBright("Second Stars Bright", Float) = 0.5
    _CloudColor1("Cloud Color1",Color) = (1,0,0,1)
    _CloudColor2("Cloud Color2",Color) = (0,0,1,1)
    _CloudColor3("Cloud Color3",Color) = (0.9, 1.0, 0.1,1)
    _Zoom("Zoom", Float) = 1.0
    _VPMix("Voronov Perlin Mix", Range(0.0,1.0)) = 0.5
    _LightStage("Light Stage", Range(0.0001,1)) = 0.8
    _ScaleStage("Scale Stage", Range(0.0001,1)) = 0.5
    _Bright("Cloud Bright", Float) = 1.5
    _CloudSeed("Cloud Seed", Range(0,1000)) = 1
    _StarsSeed("Stars Seed", Range(0,1000)) = 1
	}
	SubShader
	{
		Tags { "Queue" = "Background" "RenderType" = "Background" "PreviewType" = "Skybox" }
		LOD 100
    Cull Off
    ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

#if UNITY_VERSION>=500
#define UNITY_5_PLUS
#else
#define UNITY_4_PLUS
#endif

			struct appdata
			{
				float4 vertex : POSITION;
				float3 uv : TEXCOORD0;
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
      float _Zoom;
      float _VPMix;
      float _LightStage;
      float _ScaleStage;
      float _Bright;
      float _CloudSeed;
      float _StarsSeed;
      fixed4 _CloudColor1;
      fixed4 _CloudColor2;
      fixed4 _CloudColor3;
      fixed4 _StarsColor1;
      fixed4 _StarsColor2;
      fixed4 _StarsColor3;
      float _FirstStarsBright;
      float _SecondStarsBright;
			
			v2f vert (appdata v)
			{
				v2f o;
#ifdef UNITY_4_PLUS
        o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
#endif
#ifdef UNITY_5_PLUS
				o.vertex = UnityObjectToClipPos(v.vertex);
        UNITY_TRANSFER_FOG(o, o.vertex);
#endif
        o.uv = normalize(v.vertex.xyz);
				return o;
			}
			
      float3 hash3(float3 n) { return frac(sin(n)*(float)1399763.5453123); }
      fixed4 hash4(fixed4 n) { return frac(sin(n)*(fixed)1399763.5453123); }
      float3 hash1to3(float p) { return hash3(float3(p, p, p) + float3(0, 3245.432, 12356.547)); }
      float3 hash3to3(float3 p) { return hash1to3(dot(p, float3(1, 157, 113))); }

      float voronoi(float3 p) {

        float3 b, r, g = floor(p);
        p = frac(p);

        float d = 1.;

        for (int j = -1; j <= 1; j++) {
          for (int i = -1; i <= 1; i++) {

            b = float3(i, j, -1);
            r = b - p + hash3to3(g + b);
            d = min(d, dot(r, r));

            b.z = 0.0;
            r = b - p + hash3to3(g + b);
            d = min(d, dot(r, r));

            b.z = 1.;
            r = b - p + hash3to3(g + b);
            d = min(d, dot(r, r));

          }
        }

        return d; // Range: [0, 1]
      }

      float noise3a(float3 x)
      {
        float3 p = floor(x);
        float3 f = frac(x);
        f = f*f*(3.0 - 2.0*f);

        float n = p.x + dot(p.yz, float2(157.0, 113.0));
        float4 s1 = lerp(hash4(float4(n,n,n,n) +float4(0.0, 157.0, 113.0, 270.0)), hash4(float4(n,n,n,n) + float4(1.0, 158.0, 114.0, 271.0)), f.xxxx);
        return lerp(lerp(s1.x, s1.y, f.y), lerp(s1.z, s1.w, f.y), f.z);
      }

      float noise3(float3 x)
      {
        return (noise3a(x) + noise3a(x + float3(11.5, 11.5, 11.5)))*0.5;
      }

      float4 noiseSpace(float3 ray, float zoom, float3 subnoise)
      {
        float s = 0;
        float d = 0.4;
        float f = 5.0;
        float scale = 0;
        float invst = 1.0 / _ScaleStage;

        for (int i = 0; i < 5; i++) {
          s += lerp(voronoi(ray*f*zoom + subnoise*f), noise3(ray*f*zoom + subnoise*f), _VPMix)*d;
          f *= invst;
          scale += d;
          d *= _LightStage;
        }
        s /= scale;

        return float4(s, abs(noise3(ray*3.1*zoom + subnoise)), abs(noise3(ray*3.1*zoom + subnoise*6.0)), abs(noise3(ray*3.1*zoom + subnoise*13.0)));
      }

			fixed4 frag (v2f i) : SV_Target
			{
        float3 ray = normalize(i.uv.xyz);
        fixed4 col = fixed4(0,0,0,0);
        float4 s4 = noiseSpace(ray, _Zoom, hash1to3(_CloudSeed)*10.0);
        s4.x = pow(s4.x, 3.0)*_Bright;
        col.xyz += lerp(lerp(_CloudColor1.xyz, _CloudColor2.xyz, s4.y*1.9), _CloudColor3.xyz, s4.w*0.75)*s4.x*pow(s4.z*2.5, 3.0)*0.2;
        float3 seed = hash1to3(_StarsSeed)*10.0;
        float st = clamp(0.005 - voronoi(ray*20.0 + seed), 0, 1);
        float stf = pow(st*200.0, 6.0);
        col.xyz += lerp(lerp(_StarsColor1.xyz, _StarsColor2.xyz, noise3(ray*10.0 + seed)), _StarsColor3.xyz, stf)*stf * _FirstStarsBright;
        col.xyz += _StarsColor3.xyz*st*20.0*s4.w*_FirstStarsBright;
        col.xyz += _StarsColor3.xyz*pow(clamp(0.01 - voronoi(ray*100.0 + seed), 0, 1)*100.0,5.0)*_SecondStarsBright*s4.w;
        col *= _Exposure;

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
