// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "Custom/Xray" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}

		_XColor ("Xray Color", Color) = (1,1,1,1)
		_XTex ("Xray Tex", 2D) = "white" {}

		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		// Xray
		ZTEST GREATER
		ZWRITE OFF

		CGPROGRAM
		#pragma surface surf Unlit
		
		
		sampler2D _XTex;

		struct Input {
			float2 uv_MainTex;
		};

		fixed4 _XColor;

		half4 LightingUnlit(SurfaceOutput s, half3 lightDir, half atten){
			half4 col;
			col.rgb = s.Albedo;
			col.a = s.Alpha;

			return col;
		}

		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D (_XTex, IN.uv_MainTex) * _XColor;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG

		ZTEST LESS
		ZWRITE ON

		// Normal
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0
		
		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG

		
	}
	FallBack "Diffuse"
}
