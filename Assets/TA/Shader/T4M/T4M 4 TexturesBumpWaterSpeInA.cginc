#include "UnityCG.cginc"
#include "../../Shader/FogCommon.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc" //第三步// 
#include "t4m.cginc"
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
	float4 tangent : TANGENT;
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

		float4 posWorld:TEXCOORD2;
	UBPA_FOG_COORDS(3)
		float3 normalDir : TEXCOORD4;
	float3 SH : TEXCOOR7;

	float3 tangentDir : TEXCOORD8;
	float3 bitangentDir : TEXCOORD9;
	float4 pos : SV_POSITION;
	//shadow mark
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

sampler2D _Control;
sampler2D _Control2;
sampler2D _Splat0, _Splat1, _Splat2, _Splat3, _Splat4;
float4 _Splat0_ST, _Splat1_ST, _Splat2_ST, _Splat3_ST;
sampler2D _BumpSplat0, _BumpSplat1, _BumpSplat2, _BumpSplat3, _BumpSplat4;

float4 _SpColor0, _SpColor1, _SpColor2, _SpColor3, _SpColor4;
uniform sampler2D _NormaLMap; uniform float4 _NormaLMap_ST;
#ifdef BRIGHTNESS_ON
fixed3 _Brightness;
#endif



half ArmBRDF(half roughness, half NdotH, half LdotH)
{
	half n4 = roughness * roughness*roughness*roughness;
	half c = NdotH * NdotH   *   (n4 - 1) + 1;
	half b = 4 * 3.14*       c*c  *     LdotH*LdotH     *(roughness + 0.5);
	return n4 / b;

}
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
	float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
	o.posWorld = posWorld;
	o.uv = v.uv;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
	TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif
	o.normalDir = UnityObjectToWorldNormal(v.normal);
	o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
	o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);

	o.SH = ShadeSH9(float4(o.normalDir, 1));
	UBPA_TRANSFER_FOG(o, v.vertex);
	return o;
}
float _Gloss0, _Gloss1, _Gloss2, _Gloss3, _Gloss4, _Gloss5;


uniform float4 _WaveSpeed;
uniform float _WaveScale;
uniform float _WaveNormalPower;
uniform float _GNormalPower;

float4 _TopColor;
float4	_ButtonColor;
float _Gloss;


float metallic_power;


inline float2 ToRadialCoords(float3 coords)
{
	float3 normalizedCoords = normalize(coords);
	float latitude = acos(normalizedCoords.y);
	float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
	float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
	return float2(0.5, 1.0) - sphereCoords;
}
fixed4 frag(v2f i) : SV_Target
{

	//shadow mark
#if COMBINE_SHADOWMARK
		UNITY_SETUP_INSTANCE_ID(i);
#endif
	half3 viewDir = normalize(UnityWorldSpaceViewDir(i.posWorld));
	float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);


	T4M_NORMAL_TEXTURE(0);
	T4M_NORMAL_TEXTURE(1);
	T4M_NORMAL_TEXTURE(2);
	T4M_NORMAL_TEXTURE(3);
	T4M_WATER_NORMAL(4);


	half4 splat0 = tex2D(_Splat0, TRANSFORM_TEX(i.uv, _Splat0));
	half4 splat1 = tex2D(_Splat1, TRANSFORM_TEX(i.uv, _Splat1));
	half4 splat2 = tex2D(_Splat2, TRANSFORM_TEX(i.uv, _Splat2));
	half4 splat3 = tex2D(_Splat3, TRANSFORM_TEX(i.uv, _Splat3));


	half4 splat_control = tex2D(_Control, i.uv);
	half4 splat_control2 = tex2D(_Control2, i.uv);



	half3 nor = normalDirection0 * splat_control.r;
	nor += normalDirection1 * splat_control.g;
	nor += normalDirection2 * splat_control.b;
	nor += normalDirection3 * splat_control.a;
	nor = nor + waterNormal * splat_control2.r;

	float3 normalDirection = normalize(nor);

	half3 col;
	col = splat_control.r * splat0.rgb;
	col += splat_control.g * splat1.rgb;
	col += splat_control.b * splat2.rgb;
	col += splat_control.a * splat3.rgb;

#if _ISMETALLIC_OFF
			half3 waterColor = lerp(_TopColor, _ButtonColor, splat_control2.r);

#else
			T4M_WATER_COLOR(4,r);

#endif

			col += splat_control2.r * waterColor;

			//splat3
			//shadow mark
#if ADD_PASS
			float3 lightDir = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz, _WorldSpaceLightPos0.w));
#else
			float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
#endif
			half4 c = half4(col.rgb,1);
			fixed3 lm = 1;
			//shadow mark
			half nl = saturate(dot(normalDirection, lightDir));
#if ADD_PASS
 
			c.rgb = (_LightColor0 * nl ) * c.rgb;
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
			UNITY_LIGHT_ATTENUATION(attenuation, i, i.posWorld);
			c.rgb = (i.SH + _LightColor0 * nl * attenuation) * c.rgb;
#endif

			float _Gloss = _Gloss0 * splat_control.r *splat0.a;
			_Gloss += _Gloss1 * splat_control.g *splat1.a;
			_Gloss += _Gloss2 * splat_control.b *splat2.a;
			_Gloss += _Gloss3 * splat_control.a *splat3.a;
			_Gloss += _Gloss4 * splat_control2.r ;
			float4 _SpColor = _SpColor0 * splat_control.r;
			_SpColor += _SpColor1 * splat_control.g;
			_SpColor += _SpColor2 * splat_control.b;
			_SpColor += _SpColor3 * splat_control.a;
			_SpColor += _SpColor4 * splat_control2.r;
			half perceptualRoughness = 1.0 - _Gloss;
			half roughness = perceptualRoughness * perceptualRoughness;
			float3 halfDirection = normalize(viewDir + lightDir);
			float LdotH = saturate(dot(lightDir, halfDirection));
			float NdotH = saturate(dot(normalDirection, halfDirection));
			float specular = saturate(ArmBRDF(roughness, NdotH, LdotH));
			specular = saturate(specular);
			float ml0 = min(min(lm.r, lm.b), lm.g);
			ml0 = ml0 * ml0*ml0;
#ifdef BRIGHTNESS_ON
			c.rgb = c.rgb * _Brightness * 2 + _SpColor.rgb*ml0;
#else
			c.rgb += _SpColor.rgb*specular*ml0;

#endif
			UBPA_APPLY_FOG(i, c);
			return c;
}
