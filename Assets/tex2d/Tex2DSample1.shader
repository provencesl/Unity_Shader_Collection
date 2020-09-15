// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Tex2DSample1"
{
	
	Properties {
		// 2d纹理，内部包含纹理贴图以及采样平铺和偏移系数 
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}

	SubShader {
		pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "unitycg.cginc"

			struct v2f {
				// 模型世界空间坐标
				float4 pos:POSITION0;
				// 2d纹理采样坐标
				float2 uv_2d:TEXCOORD0;
				// 光照纹理采样坐标
				float2 uv_lm:TEXCOORD1;
			};

			// 2d纹理对象
			sampler2D _MainTex;
			// 2d纹理对象的采样系数,unity自动传入，其中xy分量代表平铺系数，zw、分量代表偏移系数
			float4 _MainTex_ST;
			// 2d光照纹理对象
			// sampler2D unity_Lightmap;
			// 2d光照纹理对象采样系数，unity自动传入，其中xy分量代表平铺系数，zw、分量代表偏移系数
			// float4 unity_LightmapST;

			v2f vert(appdata_full v)
			{
				v2f o;
				// 将模型空间顶点坐标转换到世界空间中
				o.pos = UnityObjectToClipPos(v.vertex);
				// 获取2d纹理对象采样坐标：模型采样坐标乘以平铺系数再加上偏移系数
				o.uv_2d = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				// 获取2d光照纹理对象采样坐标：模型采样坐标乘以平铺系数再加上偏移系数
				o.uv_lm = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;

				return o;
			}

			fixed4 frag(v2f v):COLOR0
			{
				// 对2d纹理对象进行采样：采样坐标对应像素不存在就获取未知像素，否则如果纹理采用Point模式就会取采样坐标
				// 位置对应的整数像素，如果纹理采用Bilinear模式就会取采样坐标附近像素按照权重累加的像素值
				fixed4 col_2d = tex2D(_MainTex, v.uv_2d);
				// 对2d光照纹理进行采样
				fixed3 col_lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, v.uv_lm));
				// 返回采样混合色
				return fixed4(col_2d.rgb * col_lm, col_2d.a);
			}
		
			ENDCG
		}
	}



}
