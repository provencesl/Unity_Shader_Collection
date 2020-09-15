//ChangeBlend.shader
Shader "SL/Unlit/ChangeBlend"
{
  Properties
  {
    _MainTex("Texture", 2D) = "white" {}
    _BlendSrc("Blend Src", Float) = 5
    _BlendDst("Blend Dst", Float) = 6
  }
  SubShader
  {
    Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
    Blend [_BlendSrc] [_BlendDst]
    LOD 100

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

      v2f vert(appdata v)
      {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        return o;
      }

      fixed4 frag(v2f i) : SV_Target
      {
        fixed4 t = tex2D(_MainTex, i.uv);  //テクスチャの色を取得
        return t;
      }
        ENDCG
    }
  }
}