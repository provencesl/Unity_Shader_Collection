// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/LowPoly/Water" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_ShinningColor("Shine Color",Color) = (1,1,1,1)
	}
	SubShader {
	Pass{
			Tags { "RenderType"="Opaque" }
			LOD 200
		
			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag
			 
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			fixed4 _Color;
			//float3 _CurrentNormal;
			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal: TEXCOORD0;
			};
			v2f vert(appdata_full v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			} 
			fixed4 _ShinningColor;
			fixed4 frag (v2f i):SV_Target{
				float3 normal = normalize(i.worldNormal);
				float3 lightDir =normalize(_WorldSpaceLightPos0).xyz;
				fixed diffuse = saturate(dot(normal,lightDir));

				fixed3 finalColor = lerp(_Color.rgb ,_ShinningColor.rgb,diffuse);
				return fixed4(finalColor,1.0);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}