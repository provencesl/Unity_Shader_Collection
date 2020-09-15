Shader "Pandora/Cel/OutlineRimDiffuse"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _LightingRamp("Lighting Ramp", 2D) = "white" {}

        _Color ("Tint Color", Color) = (1,1,1,1)
        _Gloss("Shininess", Float) = 400
        _Antialiasing("Band Smoothing", Float) = 5.0
        _Fresnel("Fresnel/Rim Amount", Range(0, 1)) = 0.5

        _OutlineSize("Outline Size", Float) = 0.01
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)

        _ID("Stencil ID", Int) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Stencil{
            Ref [_ID]
            Comp always
            Pass replace
            Fail keep
            ZFail keep
        }

        CGPROGRAM
        #pragma surface surf Cel fullforwardshadows
        #include "UnityPBSLighting.cginc"
        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _LightingRamp;


        fixed4 _Color;
        float _Antialiasing;
        float _Gloss;
        float _Fresnel;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        
        //defining a new light model to get rid of all the smooothing and blendingt
        //that is done by the stadarnd shader
        half4 LightingCel(SurfaceOutput s, half3 lightdir, half3 viewdir, half atten)
        {

            float3 lightDir = normalize(lightdir);
            float3 normal = normalize(s.Normal);

            float diffuse = (dot (normal, lightDir)*0.5 + 0.5) * atten;
            
            float3 diffuseSmooth = tex2D(_LightingRamp, float2(diffuse * 0.5 + 0.5, 0.5));


            //specular
            float3 halfVec = normalize(lightDir + viewdir);
            float specular = dot(normal, halfVec);

            specular = pow(specular * diffuseSmooth, _Gloss);
            //smooth it 
            float specularSmooth = smoothstep(0, 0.01 * _Antialiasing, specular);

            //rim lighting 
            float rim = 1 - dot(normal, viewdir);
            //no need to light things that arent hit by a lot of light
            rim *= diffuse;

            float fresnelSize = 1 - _Fresnel;
            //smooth  it 
            float rimSmooth = smoothstep(fresnelSize, fresnelSize * 1.1, rim);

            float3 col = s.Albedo * ((diffuseSmooth + specularSmooth + rimSmooth) * _LightColor0 + unity_AmbientSky);

            return float4(col, s.Alpha);
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            float3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Normal = normal;
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
        }

        ENDCG

        //VERTEX FRAGMENET SHADER AS A SECOND PASS TO THE SURFACE SHADER
        //APPDATA RECEIVES ..DATA.. FROM THE SURFACE SHADER PASS ABOVE

        Pass{
            ZWrite off
            ZTest on

            Stencil {
                Ref [_ID]
                Comp notequal
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _OutlineSize;
            float4 _OutlineColor;

            struct appdata{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f{
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v){
                v2f o;
                float3 normal = normalize(v.normal) * _OutlineSize;
                float3 pos = v.vertex + normal;

                o.vertex = UnityObjectToClipPos(pos);
                return o;
            }

            float4 frag(v2f i) : SV_TARGET{
                return _OutlineColor;
            }

            ENDCG
        }
    }

    Fallback "VertexLit"
    // FallBack "Diffuse"
}