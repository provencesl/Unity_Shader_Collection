Shader "Custom/VertexMovement" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	}
 
	SubShader{
		Tags { "RenderType" = "Opaque" }
 
		CGPROGRAM
		//Notice the "vertex:vert" at the end of the next line
		#pragma surface surf Standard fullforwardshadows vertex:vert
 
		sampler2D _MainTex;
 
		struct Input {
			float2 uv_MainTex;
		};
 
		fixed4 _Color;
 
 
		void vert(inout appdata_full v, out Input o) {
			//通过顶点移动对象
			v.vertex.x += sin(_Time * 30) * .3;
 
			UNITY_INITIALIZE_OUTPUT(Input, o);
		}
 
		void surf(Input IN, inout SurfaceOutputStandard o) {
 
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
 
			o.Alpha = c.a;
		}
		ENDCG
	}
	
FallBack "Diffuse"
}