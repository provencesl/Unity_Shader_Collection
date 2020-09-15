﻿//溶解实现：
//通过clip函数丢弃像素
//通过discard命令中断片源着色的计算达到丢弃像素的目的
//通过alpha通道设置为0来隐藏像素的显示
//
//取数据图单通道作为[0,1]值，进行clip
Shader "Custom/Dissolve/SimpleDisSolve"
{
		Properties	
		{
			_MainTex ("Texture", 2D) = "white" {}
			_NoiseTex("Noise", 2D) = "white" {}
			_Threshold("Threshold", Range(0.0, 1.0)) = 0.5
		}
		SubShader
		{
			Tags { "Queue"="Geometry" "RenderType"="Opaque" }

			Pass
			{
				Cull Off //要渲染背面保证效果正确

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
			
				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					float2 uvMainTex : TEXCOORD0;
					float2 uvNoiseTex : TEXCOORD1;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _NoiseTex;
				float4 _NoiseTex_ST;
				float _Threshold;
			
				v2f vert (appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uvMainTex = TRANSFORM_TEX(v.uv, _MainTex);
					o.uvNoiseTex = TRANSFORM_TEX(v.uv, _NoiseTex);
					return o;
				}
			
				fixed4 frag (v2f i) : SV_Target
				{
					fixed cutout = tex2D(_NoiseTex, i.uvNoiseTex).r;
					clip(cutout - _Threshold);

					fixed4 col = tex2D(_MainTex, i.uvMainTex);
					return col;
				}
				ENDCG
			}
		}



}
