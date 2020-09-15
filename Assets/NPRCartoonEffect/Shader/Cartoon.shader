// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "NPR Cartoon Effect/Cartoon" {
	Properties {
		_MainTex ("Base", 2D) = "white" {}
		_BumpTex ("Bump", 2D) = "bump" {}
		_StylizedShadowTex ("Stylized Shadow", 2D) = "white" {}
		
		_HighlitColor ("Highlit", Color) = (0.6, 0.6, 0.6, 1.0)
		_DarkColor ("Dark", Color) = (0.4, 0.4, 0.4, 1.0)
		_RampTex ("Ramp", 2D) = "white" {}
		_RampThreshold ("Ramp Threshold", Float) = 0.5
		_RampSmooth ("Ramp Smoothing", Float) = 0.1
		
		_SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
		_SpecPower ("Specular Power", Float) = 128
		_SpecSmooth ("Specular Smooth", Float) = 0.1
		
		_SpecularScale ("Specular Scale", Range(0, 0.05)) = 0.01
		_SpecularTranslationX ("Specular Translation X", Range(-1, 1)) = 0
		_SpecularTranslationY ("Specular Translation Y", Range(-1, 1)) = 0
		_SpecularRotationX ("Specular Rotation X", Range(-180, 180)) = 0
		_SpecularRotationY ("Specular Rotation Y", Range(-180, 180)) = 0
		_SpecularRotationZ ("Specular Rotation Z", Range(-180, 180)) = 0
		_SpecularScaleX ("Specular Scale X", Range(-1, 1)) = 0
		_SpecularScaleY ("Specular Scale Y", Range(-1, 1)) = 0
		_SpecularSplitX ("Specular Split X", Range(0, 1)) = 0
		_SpecularSplitY ("Specular Split Y", Range(0, 1)) = 0
		
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 0)
		_OutlineWidth ("Outline Width", Float) = 0.02
		_ExpandFactor ("Outline Factor", Float) = 1
		
		_RimColor ("Rim Color", Color) = (0.8, 0.8, 0.8, 0.6)
		_RimMin ("Rim Min", Float) = 0.5
		_RimMax ("Rim Max", Float) = 1
	}
	SubShader {
		Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
		Pass {
			CGPROGRAM
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#pragma multi_compile_fwdbase
			#pragma multi_compile _ NCE_BUMP
			#pragma multi_compile _ NCE_RAMP_TEXTURE
			#pragma multi_compile _ NCE_SPECULAR
			#pragma multi_compile _ NCE_STYLIZED_SPECULAR
			#pragma multi_compile _ NCE_STYLIZED_SHADOW
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex, _RampTex, _StylizedShadowTex, _BumpTex;
			float4 _MainTex_ST, _StylizedShadowTex_ST;
			fixed4 _SpecularColor, _HighlitColor, _DarkColor, _RimColor;
			float _SpecularScale;
			float _SpecularTranslationX, _SpecularTranslationY;
			float _SpecularRotationX, _SpecularRotationY, _SpecularRotationZ;
			float _SpecularScaleX, _SpecularScaleY;
			float _SpecularSplitX, _SpecularSplitY;
			fixed _RampThreshold, _RampSmooth, _SpecPower, _SpecSmooth, _RimMin, _RimMax;

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				float3 tgsnor : TEXCOORD1;    // tangent space normal
				float3 tgslit : TEXCOORD2;    // tangent space light
				float3 tgsview : TEXCOORD3;   // tangent space view
				LIGHTING_COORDS(4, 5)
			};
			v2f vert (appdata_tan v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.tex.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.tex.zw = TRANSFORM_TEX(v.texcoord, _StylizedShadowTex);
				TANGENT_SPACE_ROTATION;
				o.tgsnor = mul(rotation, v.normal);
				o.tgslit = mul(rotation, ObjSpaceLightDir(v.vertex));
				o.tgsview = mul(rotation, ObjSpaceViewDir(v.vertex));
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}
			fixed calcRamp (float ndl)
			{
#if NCE_RAMP_TEXTURE
				fixed ramp = tex2D(_RampTex, float2(ndl, 0.5)).r;
#else
				fixed ramp = smoothstep(_RampThreshold - _RampSmooth * 0.5, _RampThreshold + _RampSmooth * 0.5, ndl);
#endif
				return ramp;
			}
			fixed3 calcSpecular (float3 N, float3 H)
			{
#if NCE_STYLIZED_SPECULAR
				// specular highlights scale
				H = H - _SpecularScaleX * H.x * float3(1, 0, 0);
				H = normalize(H);
				H = H - _SpecularScaleY * H.y * float3(0, 1, 0);
				H = normalize(H);

				// specular highlights rotation
				#define DegreeToRadian 0.0174533
				float radX = _SpecularRotationX * DegreeToRadian;
				float3x3 rotMatX = float3x3(
					1,	0, 		 	0,
					0,	cos(radX),	sin(radX),
					0,	-sin(radX),	cos(radX));
				float radY = _SpecularRotationY * DegreeToRadian;
				float3x3 rotMatY = float3x3(
					cos(radY), 	0, 		-sin(radY),
					0,			1,		0,
					sin(radY), 	0, 		cos(radY));
				float radZ = _SpecularRotationZ * DegreeToRadian;
				float3x3 rotMatZ = float3x3(
					cos(radZ), 	sin(radZ), 	0,
					-sin(radZ), cos(radZ), 	0,
					0, 			0,			1);
				H = mul(rotMatZ, mul(rotMatY, mul(rotMatX, H)));
				H = normalize(H);
				
				// specular highlights translation
				H = H + float3(_SpecularTranslationX, _SpecularTranslationY, 0);
				H = normalize(H);
				
				// specular highlights split
				float signX = 1;
				if (H.x < 0)
					signX = -1;

				float signY = 1;
				if (H.y < 0)
					signY = -1;

				H = H - _SpecularSplitX * signX * float3(1, 0, 0) - _SpecularSplitY * signY * float3(0, 1, 0);
				H = normalize(H);
				
				// stylized specular light
				float spec = dot(N, H);
				float w = fwidth(spec);
				return lerp(float3(0, 0, 0), _SpecularColor.rgb, smoothstep(-w, w, spec + _SpecularScale - 1.0));
#else
				float ndh = saturate(dot(N, H));
				float spec = pow(ndh, _SpecPower);
				spec = smoothstep(0.5 - _SpecSmooth * 0.5, 0.5 + _SpecSmooth * 0.5, spec);
				return _SpecularColor * spec;
#endif
			}
			float4 frag (v2f i) : SV_TARGET
			{
#if NCE_BUMP
				float3 N = UnpackNormal(tex2D(_BumpTex, i.tex.xy));
#else
				float3 N = normalize(i.tgsnor);
#endif
				float3 L = normalize(i.tgslit);
				float3 V = normalize(i.tgsview);
				float3 H = normalize(V + L);

				//
				// cartoon light model
				//
				
				// ambient light from Unity render setting
				float3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// rim light
				half rim = 1.0 - saturate(dot(V, N));
				rim = smoothstep(_RimMin, _RimMax, rim) * _RimColor.a;
				
				fixed4 albedo = tex2D(_MainTex, i.tex.xy);
				albedo = lerp(albedo, _RimColor, rim);
				
				// diffuse cartoon light
				float diff = saturate(dot(N, L)) * LIGHT_ATTENUATION(i);

				fixed4 darkColor = _DarkColor;
#if NCE_STYLIZED_SHADOW
				darkColor = tex2D(_StylizedShadowTex, i.tex.zw);
#endif
				fixed ramp = calcRamp(diff);

				fixed4 c = lerp(_HighlitColor, darkColor, _DarkColor.a);
				fixed4 rampColor = lerp(c, _HighlitColor, ramp);				
				float4 diffuseColor = albedo * rampColor;

#if NCE_SPECULAR				
				fixed3 specularColor = calcSpecular(N, H);
#else
				fixed3 specularColor = fixed3(0, 0, 0);
#endif
				
				return float4(ambientColor + diffuseColor.rgb + specularColor, 1.0) * _LightColor0;
            }
			ENDCG
		}
		Pass {
			Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
			Cull Front

			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag

			float4 _OutlineColor;
			float _OutlineWidth, _ExpandFactor;
			struct v2f
			{
				float4 pos : SV_POSITION;
			};
			v2f vert (appdata_base v)
			{
				float3 dir1 = normalize(v.vertex.xyz);
				float3 dir2 = v.normal;
				float3 dir = lerp(dir1, dir2, _ExpandFactor);
				dir = mul((float3x3)UNITY_MATRIX_IT_MV, dir);
				float2 offset = TransformViewToProjection(dir.xy);
				offset = normalize(offset);
				float dist = distance(mul(unity_ObjectToWorld, v.vertex), _WorldSpaceCameraPos);
			
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
#if UNITY_VERSION > 540
				o.pos.xy += offset * o.pos.z * _OutlineWidth * dist;
#else
				o.pos.xy += offset * o.pos.z * _OutlineWidth / dist;
#endif
				return o;
			}
			float4 frag (v2f i) : SV_TARGET
			{
				return _OutlineColor;
            }
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
