Shader "SL/Transition/Transition_BlockNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
		_Size ("Size", Vector) = (1, 1, 0, 0)
		_Seed ("Seed", Int) = 0
		_Value ("Value", Range(0, 1)) = 0
		_Smoothing ("Smoothing", Range(0.00001, 0.5)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "RenderType"="Transparent" }
 
		Blend SrcAlpha OneMinusSrcAlpha
 
        Pass
        {
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
 
			float4 _Color;
            int2 _Size;
            float _Seed;
            float _Value;
			float _Smoothing;
 
			float random(float2 st, int seed)
			{
				return frac(sin(dot(st.xy, float2(12.9898, 78.233)) + seed) * 43758.5453123);
			}
 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
 
            fixed4 frag (v2f i) : SV_Target
            {
				float2 st = i.uv * _Size;
				float2 i_st = floor(st);
				
				float sm = _Smoothing;
				float val = _Value * (1 + sm);
				float a = smoothstep(val - sm, val, random(i_st, _Seed));
 
                fixed4 col = _Color;
				col.a = a;
                return col;
            }
            ENDCG
        }
    }
}