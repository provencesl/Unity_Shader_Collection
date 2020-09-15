// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "SL/PostEffects/CRT"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseX("NoiseX", Range(0, 1)) = 0
		_Offset("Offset", Vector) = (0, 0, 0, 0)
		_RGBNoise("RGBNoise", Range(0, 1)) = 0
		_SinNoiseWidth("SineNoiseWidth", Float) = 1
		_SinNoiseScale("SinNoiseScale", Float) = 1
		_SinNoiseOffset("SinNoiseOffset", Float) = 1
		_ScanLineTail("Tail", Float) = 0.5
		_ScanLineSpeed("TailSpeed", Float) = 100
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
 
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			
			#include "UnityCG.cginc"
 
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
 
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};
 
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
 
			float rand(float2 co) {
				return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
			}
 
			float2 mod(float2 a, float2 b)
			{
				return a - floor(a / b) * b;
			}
			sampler2D _MainTex;
			float _NoiseX;
			float2 _Offset;
			float _RGBNoise;
			float _SinNoiseWidth;
			float _SinNoiseScale;
			float _SinNoiseOffset;
			float _ScanLineTail;
			float _ScanLineSpeed;
 
			fixed4 frag (v2f i) : SV_Target
			{
				float2 inUV = i.uv;
				float2 uv = i.uv - 0.5;
				
				// UV座標を再計算し、画面を歪ませる
				float vignet = length(uv);
				uv /= 1 - vignet * 0.2;
				float2 texUV = uv + 0.5;
 
				// 画面外なら描画しない
				if (max(abs(uv.y) - 0.5, abs(uv.x) - 0.5) > 0)
				{
					return float4(0, 0, 0, 1);
				}
 
				// 色を計算
				float3 col;
 
				// ノイズ、オフセットを適用
				texUV.x += sin(texUV.y * _SinNoiseWidth + _SinNoiseOffset) * _SinNoiseScale;
				texUV += _Offset;
				texUV.x += (rand(floor(texUV.y * 500) + _Time.y) - 0.5) * _NoiseX;
				texUV = mod(texUV, 1);
 
				// 色を取得、RGBを少しずつずらす
				col.r = tex2D(_MainTex, texUV).r;
				col.g = tex2D(_MainTex, texUV - float2(0.002, 0)).g;
				col.b = tex2D(_MainTex, texUV - float2(0.004, 0)).b;
 
				// RGBノイズ
				if (rand((rand(floor(texUV.y * 500) + _Time.y) - 0.5) + _Time.y) < _RGBNoise)
				{
					col.r = rand(uv + float2(123 + _Time.y, 0));
					col.g = rand(uv + float2(123 + _Time.y, 1));
					col.b = rand(uv + float2(123 + _Time.y, 2));
				}
 
				// ピクセルごとに描画するRGBを決める
				float floorX = fmod(inUV.x * _ScreenParams.x / 3, 1);
				col.r *= floorX > 0.3333;
				col.g *= floorX < 0.3333 || floorX > 0.6666;
				col.b *= floorX < 0.6666;
 
				// スキャンラインを描画
				float scanLineColor = sin(_Time.y * 10 + uv.y * 500) / 2 + 0.5;
				col *= 0.5 + clamp(scanLineColor + 0.5, 0, 1) * 0.5;
 
				// スキャンラインの残像を描画
				float tail = clamp((frac(uv.y + _Time.y * _ScanLineSpeed) - 1 + _ScanLineTail) / min(_ScanLineTail, 1), 0, 1);
				col *= tail;
 
				// 画面端を暗くする
				col *= 1 - vignet * 1.3;
				
				return float4(col, 1);
			}
			ENDCG
		}
	}
}