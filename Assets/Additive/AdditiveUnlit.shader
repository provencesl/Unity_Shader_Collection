// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Optimised/Additive/AdditiveUnlit" {
	Properties {
		_MainTex ("Diffuse (RGB) Transparency (A)", 2D) = "white" {}
		_Color ("Diffuse (RGB)", Color) = (1,1,1,1)
		}					
   SubShader {
   		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        LOD 100      
      Pass {
         Cull Back
         ZWrite Off
         Blend SrcAlpha One //additive
 
         CGPROGRAM 
         #pragma vertex vert  
         #pragma fragment frag 
         #include "UnityCG.cginc"
         
         sampler2D _MainTex;
         fixed4 _Color;
 
//VERTEX IN
         struct vertexInput {
            fixed vertex : POSITION;
            fixed4 texcoord1 : TEXCOORD1;
         };

//VERTEX OUT   
           struct vertexOutput {
            fixed4 pos : SV_POSITION;
            fixed4 tex : TEXCOORD1;
         };
 
         vertexOutput vert(appdata_full input) 
         {
            vertexOutput output; 
 
            output.tex = input.texcoord;
            output.pos =  UnityObjectToClipPos(input.vertex);
            
            return output;
         }

//FRAGMENT START  
         fixed4 frag(vertexOutput input) : COLOR 
         {
          	return (tex2D(_MainTex, fixed2(input.tex.xy))*_Color);
         }
 
         ENDCG  
      }
   }
}