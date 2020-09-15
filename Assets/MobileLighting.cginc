sampler2D _Ramp;

inline half3 DirLightmapDiffuseMobile(in half3x3 dirBasis, fixed4 color, fixed4 scale, half3 normal, bool surfFuncWritesNormal, out half3 scalePerBasisVector)
{
	half3 lm = DecodeLightmap (color);
	
	// will be compiled out (and so will the texture sample providing the value)
	// if it's not used in the lighting function, like in LightingLambert
	scalePerBasisVector = DecodeLightmap (scale);

	// will be compiled out when surface function does not write into o.Normal
	if (surfFuncWritesNormal)
	{
		half3 normalInRnmBasis = saturate (mul (dirBasis, normal));
		lm *= dot (normalInRnmBasis, scalePerBasisVector);
	}

	return lm;
}

inline fixed4 LightingLambertMobile (SurfaceOutput s, fixed3 lightDir, fixed atten)
{
	fixed diff = max (0, dot (s.Normal, lightDir));
	fixed4 c;
	c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2);
	c.a = s.Alpha;
	return c;
}


inline fixed4 LightingLambertMobile_PrePass (SurfaceOutput s, half4 light)
{
	fixed4 c;
	c.rgb = s.Albedo * light.rgb;
	c.a = s.Alpha;
	return c;
}

inline half4 LightingLambertMobile_DirLightmap (SurfaceOutput s, fixed4 color, fixed4 scale, bool surfFuncWritesNormal)
{
	UNITY_DIRBASIS
	half3 scalePerBasisVector;
	
	half3 lm = DirLightmapDiffuse (unity_DirBasis, color, scale, s.Normal, surfFuncWritesNormal, scalePerBasisVector);
	
	return half4(lm, 0);
}


// NOTE: some intricacy in shader compiler on some GLES2.0 platforms (iOS) needs 'viewDir' & 'h'
// to be mediump instead of lowp, otherwise specular highlight becomes too bright.
inline fixed4 LightingBlinnPhongMobile (SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten)
{
	fixed3 h = normalize (lightDir + viewDir);
	fixed diff = max (0, dot (s.Normal, lightDir));
	fixed nh = max (0, dot (s.Normal, h));
	fixed spec = pow (nh, s.Specular*128.0) * s.Gloss;
	fixed4 c;
	c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * _SpecColor.rgb * spec) * (atten * 2);
	c.a = s.Alpha + _LightColor0.a * _SpecColor.a * spec * atten;
	return c;
}

inline fixed4 LightingBlinnPhongMobile_PrePass (SurfaceOutput s, half4 light)
{
	fixed spec = light.a * s.Gloss;
	
	fixed4 c;
	c.rgb = (s.Albedo * light.rgb + light.rgb * _SpecColor.rgb * spec);
	c.a = s.Alpha + spec * _SpecColor.a;
	return c;
}

inline half4 LightingBlinnPhongMobileMobile_DirLightmap (SurfaceOutput s, fixed4 color, fixed4 scale, half3 viewDir, bool surfFuncWritesNormal, out half3 specColor)
{
	UNITY_DIRBASIS
	half3 scalePerBasisVector;
	
	half3 lm = DirLightmapDiffuse (unity_DirBasis, color, scale, s.Normal, surfFuncWritesNormal, scalePerBasisVector);
	
	half3 lightDir = normalize (scalePerBasisVector.x * unity_DirBasis[0] + scalePerBasisVector.y * unity_DirBasis[1] + scalePerBasisVector.z * unity_DirBasis[2]);
	half3 h = normalize (lightDir + viewDir);

	float nh = max (0, dot (s.Normal, h));
	float spec = pow (nh, s.Specular * 128.0);
	
	// specColor used outside in the forward path, compiled out in prepass
	specColor = lm * _SpecColor.rgb * s.Gloss * spec;
	
	// spec from the alpha component is used to calculate specular
	// in the Lighting*_Prepass function, it's not used in forward
	return half4(lm, spec);
}

inline fixed4 LightingLambertWrapMobile (SurfaceOutput s, fixed3 lightDir, fixed atten) 
{
	fixed NdotL = dot (s.Normal, lightDir);
	fixed diff = NdotL * 0.5 + 0.5;
	fixed4 c;
	c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2);
	c.a = s.Alpha;
	return c;
}

inline fixed4 LightingBlinnPhongWrapMobile (SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten) 
{
    fixed3 h = normalize (lightDir + viewDir);
	fixed diff = (dot (s.Normal, lightDir)) * 0.5 + 0.5;
	fixed nh = max (0, dot (s.Normal, h));
	fixed spec = pow (nh, s.Specular*20.0) * (s.Gloss);
	fixed4 c;
	c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * _SpecColor.rgb * spec) * (atten * 2);
	c.a = s.Alpha + _LightColor0.a * _SpecColor.a * spec * atten;
	return c;
}

inline fixed4 LightingLambertRampMobile (SurfaceOutput s, fixed3 lightDir, fixed atten) 
{
    fixed NdotL = dot (s.Normal, lightDir);
    fixed diff = NdotL * 0.5 + 0.5;
    fixed4 ramp = tex2D(_Ramp, fixed2(diff, diff));
    fixed4 c;
    c.rgb = s.Albedo.rgb * _LightColor0.rgb * ramp.rgb * (atten * 2);
    c.a = s.Alpha;
    return c;
}

fixed4 LightingBlinnPhongRampMobile (SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten) {
    fixed3 h = normalize (lightDir + viewDir);
	fixed diff = (dot (s.Normal, lightDir)) * 0.5 + 0.5;
	fixed nh = max (0, dot (s.Normal, h));
	fixed spec = pow (nh, s.Specular*20.0) * (s.Gloss);
	fixed4 ramp = tex2D(_Ramp, fixed2(diff, diff));
	fixed4 c;
	c.rgb = ((s.Albedo * _LightColor0.rgb * ramp) + (_LightColor0.rgb * _SpecColor.rgb * spec)) * (atten * 2);
	c.a = s.Alpha + _LightColor0.a * _SpecColor.a * spec * atten;
	return c;
}

fixed4 LightingLambertToonMobile (SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten) {
	    fixed3 h = normalize (lightDir + viewDir);
		fixed diff = (dot (s.Normal, lightDir)) * 0.5 + 0.5;
		fixed4 ramp = tex2D(_Ramp, fixed2(diff,diff));
		fixed4 c;
		c.rgb = (s.Albedo * _LightColor0.rgb * ramp.rgb) * (atten * 2);
		c.a = s.Alpha + _LightColor0.a * atten;
		return c;
}

fixed4 LightingBlinnPhongToonMobile (SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten) {
	    fixed3 h = normalize (lightDir + viewDir);
		fixed diff = (dot (s.Normal, lightDir)) * 0.5 + 0.5;
		fixed nh = max (0, dot (s.Normal, h));
		fixed spec = pow (nh, s.Specular*20) * (s.Gloss);
		 if (spec < 0.5) 
            {
               spec = 0; // drop the fragment if y coordinate > 0
            }
         if (spec > 0.5) 
            {
               spec = 1; // drop the fragment if y coordinate > 0
            }
		fixed4 ramp = tex2D(_Ramp, fixed2(diff,diff));
		fixed4 c;
		c.rgb = ((s.Albedo * _LightColor0.rgb * ramp.rgb) + (_LightColor0.rgb * _SpecColor.rgb * spec * ramp)) * (atten * 2);
		c.a = s.Alpha + _LightColor0.a * _SpecColor.a * spec * atten;
		return c;
}