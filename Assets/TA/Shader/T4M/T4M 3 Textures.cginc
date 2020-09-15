#include "UnityCG.cginc"
#include "../FogCommon.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc" //������// 
#include "../shadowmarkex.cginc"
struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	float2 uv2 : TEXCOORD1;
#else

#endif

	float3 normal : NORMAL;
	//shadow mark
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
	float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	float2 uv2 : TEXCOORD1;
#else
	UNITY_LIGHTING_COORDS(5, 6)
#endif

		float4 wpos:TEXCOORD2;
	UBPA_FOG_COORDS(3)
		float3 normalWorld : TEXCOORD4;
	
	
	float4 pos : SV_POSITION;
	//shadow mark
	UNITY_VERTEX_INPUT_INSTANCE_ID
	float3 posWorld : TEXCOOR8;
	float3 SH : TEXCOOR7;
};

sampler2D _Control;
sampler2D _Splat0, _Splat1, _Splat2;
float4 _Splat0_ST, _Splat1_ST, _Splat2_ST;
#ifdef BRIGHTNESS_ON
fixed3 _Brightness;
#endif

v2f vert(appdata v)
{
	v2f o;
	UNITY_INITIALIZE_OUTPUT(v2f, o);
	//shadow mark
#if COMBINE_SHADOWMARK
	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_TRANSFER_INSTANCE_ID(v, o);
#endif
	o.pos = UnityObjectToClipPos(v.vertex);
	float4 wpos = mul(unity_ObjectToWorld, v.vertex);
	o.wpos = wpos;
	o.uv = v.uv;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
	TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif
	o.normalWorld = UnityObjectToWorldNormal(v.normal);

	//shadow mark
	float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
	o.posWorld = posWorld;
	o.SH = ShadeSH9(float4(o.normalWorld, 1));
	UBPA_TRANSFER_FOG(o, v.vertex);
	return o;
}

fixed4 frag(v2f i) : SV_Target
{
	//shadow mark
#if COMBINE_SHADOWMARK
		UNITY_SETUP_INSTANCE_ID(i);
#endif
	half3 splat_control = tex2D(_Control, i.uv);
	half3 col;


	half4 splat0 = tex2D(_Splat0, TRANSFORM_TEX(i.uv, _Splat0));
	half4 splat1 = tex2D(_Splat1, TRANSFORM_TEX(i.uv, _Splat1));
	half4 splat2 = tex2D(_Splat2, TRANSFORM_TEX(i.uv, _Splat2));

	col = splat_control.r * splat0.rgb;

	col += splat_control.g * splat1.rgb;

	col += splat_control.b * splat2.rgb;
 


	//shadow mark
#if ADD_PASS
	float3 lightDir = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz, _WorldSpaceLightPos0.w));
#else
	float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
#endif
	half4 c = half4(col.rgb, 1);
	fixed3 lm = 1;
	//shadow mark
	half nl = saturate(dot(i.normalWorld, lightDir));
#if ADD_PASS

	c.rgb = (_LightColor0 * nl *  LIGHT_ATTENUATION(i)) * c.rgb;
	return c;
#endif
	//shadow mark
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)

	GETLIGHTMAP(i.uv2);
	lightmap.rgb *= LightMapInf.rgb *(1 + LightMapInf.a);//
	#if    SHADOWS_SHADOWMASK 
		c.rgb = (/*i.SH +*/ _LightColor0 * nl * attenuation + lightmap.rgb) * c.rgb;

	#else
		c.rgb *= lightmap;

	#endif
	 
#else
	UNITY_LIGHT_ATTENUATION(attenuation, i, i.wpos.xyz);
	//float attenuation = LIGHT_ATTENUATION(i);
	c.rgb = (i.SH + _LightColor0 * nl * attenuation) * c.rgb;
#endif

#ifdef BRIGHTNESS_ON
	c.rgb = c.rgb * _Brightness * 2;
#endif




	UBPA_APPLY_FOG(i, c);
	return c;
}