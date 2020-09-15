//渐变纹理：通过对半兰伯特光照模型进行改良，让漫反射光照更加明显，从而达到一种卡通渲染风格

Shader "Custom/RampTexture"
{
	
	Properties{
		_Color("Color",Color) = (1,1,1,1)//贴图颜色
		_RampTex("Main Tex",2D) = "white"{}//渐变纹理
		_Sepcular("Sepcular",Color)=(1,1,1,1)//高光反射颜色
		_Gloss("Gloss",Range(8.0,256))=20//光泽度
	}
	SubShader
	{
		pass {
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag
			fixed4 _Color;//贴图颜色
			sampler2D _RampTex;//渐变纹理
			fixed4 _RampTex_ST;//渐变纹理的缩放与偏移
			fixed4 _Sepcular;//高光反射颜色
			float _Gloss;//光泽度
			struct a2v {
				float4 vertex:POSITION;//赋值模型空间顶点位置
				float3 normal:NORMAL;//赋值模型空间法线
				float4 texcoord:TEXCOORD0;//第一张贴图
			};
			struct v2f {
				float4 position:SV_POSITION;//输出的屏幕位置
				float3 worldNormal:TEXCOORD0;//世界坐标下法线
				float3 worldPos : TEXCOORD1;//世界坐标下位置
				float2 rampuv:TEXCOORD2;//渐变纹理的uv
			};
			v2f vert(a2v v) {
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);//剪裁空间的位置
				f.worldNormal = UnityObjectToWorldNormal(v.normal);//世界坐标系下法线
				f.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;//世界坐标的位置
				f.rampuv = TRANSFORM_TEX(v.texcoord, _RampTex);//渐变纹理的uv + 缩放平移
				return f;
			}
			fixed4 frag(v2f f) :SV_Target{
				fixed3 worldNormal = normalize(f.worldNormal);//单位化
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(f.worldPos));//环境光方向
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;//环境光
				fixed halfLambert = 0.5 * dot(worldNormal,worldLightDir) + 0.5;//半兰伯特光照
				fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb*_Color.rgb;//漫反射颜色 渐变纹理的核心代码
				fixed3 diffuse = diffuseColor * _LightColor0.rgb;//漫反射最终效果
				//Blinn-Phong模型的高光反射
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(f.worldPos));//v方向
				fixed3 halfDir = normalize(viewDir + worldLightDir);//h方向
				fixed3 specular = _LightColor0.rgb * _Sepcular.rgb * pow(max(dot(halfDir, worldNormal), 0), _Gloss);//h方向与法线的夹角决定高光补偿
				return fixed4(diffuse + specular + ambient, 1);//最终效果
			}
			ENDCG
		}
	}
	FallBack "Diffuse"


}
