Shader "Custom/SpriteDiffuse"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}

	_AlphaCutOff("AlphaCutOff", Range(0,1)) = 0.05
	}

		SubShader
	{
		Pass
	{
		Tags{ "LightMode" = "ForwardBase" }

		CGPROGRAM

#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

		sampler2D _MainTex;
	fixed _AlphaCutOff;

	struct appdata
	{
		half3 normal : NORMAL;
		float4 vertex : POSITION;
		float2 uv : TEXCOORD;
		fixed4 color : COLOR;
	};

	struct v2f
	{
		float2 uv : TEXCOORD;
		fixed4 color : COLOR;
		float4 vertex : SV_POSITION;
	};

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		o.color = v.color;

		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv) * i.color;
		clip(col.a - _AlphaCutOff);
		return col;
	}
		ENDCG
	}
		Pass
	{
		Tags{ "LightMode" = "ShadowCaster" }

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_shadowcaster

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

		sampler2D _MainTex;
	fixed _AlphaCutOff;

	struct v2f {
		V2F_SHADOW_CASTER;
		float4 texcoord : TEXCOORD1;
		fixed4 color : COLOR;
	};

	v2f vert(appdata_full v)
	{
		v2f o;
		o.texcoord = v.texcoord;
		o.color = v.color;
		TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
			return o;
	}

	float4 frag(v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.texcoord) * i.color;
	clip(col.a - _AlphaCutOff);
	SHADOW_CASTER_FRAGMENT(i)
	}
		ENDCG
	}
	}
}