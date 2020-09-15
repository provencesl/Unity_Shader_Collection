Shader "Optimised/Additive/AdditiveBump" {
	Properties {
		_MainTex ("Diffuse (RGB) Transparency (A)", 2D) = "white" {}
		_BumpMap ("Normal Map (RGB)", 2D) = "bump" {}
		_Color ("Main Color (RGB)", Color) = (1,1,1,1)
	}
	SubShader {
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 300
		Cull Back
        ZWrite Off
        Blend SrcAlpha One //additive
		
		CGPROGRAM
		#pragma surface surf LambertMobile addshadow fullforwardshadows
		#include "../MobileLighting.cginc"
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpMap;
        fixed3 _Color;
                
		struct Input {
			fixed2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
		
		  o.Albedo = (tex2D(_MainTex, IN.uv_MainTex)).rgb * _Color.rgb;
		  o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
          o.Alpha = (tex2D(_MainTex, IN.uv_MainTex)).a;
          
		}
		ENDCG
	} 
	FallBack "Hotgen/Additive/Additive"
}