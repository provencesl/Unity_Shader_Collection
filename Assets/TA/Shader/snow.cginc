fixed _SnowPower;
fixed _SnowNormalPower;
fixed4 _SnowColor;
fixed _SnowEdge;
sampler2D _SnowNoise;
half _SnowNoiseScale;
half _SnowGloss;
half _SnowLocalPower;
half _SnowMeltPower;


/*
[Toggle]_snow_options("----------ѩѡ��-----------",int) = 0
_SnowNormalPower("  ѩ����ǿ��", Range(0.3, 1)) = 1
//_SnowColor("ѩ��ɫ", Color) = (0.784, 0.843, 1, 1)
_SnowEdge("  ѩ��Ե����", Range(0.01, 0.3)) = 0.2
//_SnowNoise("ѩ���", 2D) = "white" {}
_SnowNoiseScale("  ѩ�������", Range(0.1, 20)) = 1.28
//_SnowGloss("ѩ�߹�", Range(0, 1)) = 1
//_SnowMeltPower("  ѩ_����Ӱ�����", Range(1, 2)) =  1
_SnowLocalPower("  ѩ_����Ӱ�����", Range(-5, 0.3)) = 0
[Toggle(HARD_SNOW)] HARD_SNOW("  Ӳ��ѩ", Float) = 0
[Toggle(MELT_SNOW)] MELT_SNOW("  ����ѩ", Float) = 0
//[KeywordEnum(ON, OFF)] _IsWeather("�Ƿ��������", Float) = 0
*/
/*
#if _ISWEATHER_ON

	#if SNOW_ENABLE 
		fixed nt;
		CmpSnowNormalAndPower(i.uv0, i.normalDir.xyz, nt, normalDirection);
	#endif
	#endif
*/
/*
#if _ISWEATHER_ON
	#if SNOW_ENABLE
		diffuseColor.rgb = lerp(diffuseColor.rgb, _SnowColor.rgb, nt *_SnowColor.a);
	#endif
#endif
*/

/*
#if _ISWEATHER_ON
	#if RAIN_ENABLE
		gloss = saturate(gloss* get_smoothnessRate());
	#endif
	#if(SNOW_ENABLE)
		gloss = lerp(gloss, _SnowGloss, nt);
	#endif
#endif
*/
void CmpSnowNormalAndPower(in half2 uv,in float3 VertexNormal,out fixed t, inout float3 normalDirection)
{
#if   defined(HARD_SNOW) || defined(MELT_SNOW) 

	half snoize = tex2D(_SnowNoise, uv*_SnowNoiseScale).r;

#endif
#if MELT_SNOW
	half snl = snoize * _SnowMeltPower;

#else
	half snl = dot(normalDirection, half3(0, 1, 0));
	snl = (1.0 - _SnowLocalPower)*snl + _SnowLocalPower;
#endif

	t = smoothstep(_SnowPower, _SnowPower + _SnowEdge, snl);


#if HARD_SNOW
	t = step(snoize, t);
#endif

 
	normalDirection = lerp(VertexNormal.xyz, normalDirection, _SnowNormalPower);
}

//float snowT;
void CmpSnowNormalAndPowerSurface(in half2 uv, in float3 normalDirection, out fixed t,  inout float3 LocalNormal)
{
#if   defined(HARD_SNOW) || defined(MELT_SNOW) 

	half snoize = tex2D(_SnowNoise, uv*_SnowNoiseScale).r;

#endif
#if MELT_SNOW
	half snl = snoize * _SnowMeltPower;

#else
	half snl = dot(normalDirection, half3(0, 1, 0));
	snl = (1.0 - _SnowLocalPower)*snl + _SnowLocalPower;
#endif

	t = smoothstep(_SnowPower, _SnowPower + _SnowEdge, snl);

#if HARD_SNOW
	t = step(snoize, t);
#endif
	//LocalNormal = LocalNormal;

	LocalNormal = lerp(LocalNormal,float3(0, 0, 1), _SnowNormalPower);
}