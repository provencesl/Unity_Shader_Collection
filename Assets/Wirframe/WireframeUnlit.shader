Shader "SL/Custom/Wireframe Unlit"
{
 Properties
 {
  _Color("Color", Color) = (1,1,1,1)
  _Width("Width", Range(0, 1)) = 0.2
  _Thickness("Thickness", Range(0, 1)) = 0.01
 }
 SubShader
 {
  Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
  LOD 100
  
  Zwrite Off
  Blend SrcAlpha OneMinusSrcAlpha
 
  Pass
  {
   CGPROGRAM
   #pragma target 4.0
   #pragma vertex vert
   #pragma geometry geo
   #pragma fragment frag
   #pragma multi_compile_fog
   
   #include "UnityCG.cginc"
 
   struct appdata {
    float4 vertex : POSITION;
    float3 normal : NORMAL;
   };
   
   struct v2g {
    float4 vertex : SV_POSITION;
    float3 normal : TEXCOORD0;
   };
 
   struct g2f {
    float4 vertex : SV_POSITION;
    float3 normal : TEXCOORD0;
    UNITY_FOG_COORDS(1)
   };
 
   v2g vert (appdata v)
   {
    v2g o;
    o.vertex = v.vertex;
    o.normal = v.normal;
    return o;
   }
 
   struct vData {
    float3 pos;
    float3 normal;
   };
 
   g2f SetVertex(vData data)
   {
    g2f o;
    o.vertex = UnityObjectToClipPos(float4(data.pos, 1));
    o.normal = data.normal;
    UNITY_TRANSFER_FOG(o, o.vertex);
    return o;
   }
 
   fixed4 _Color;
   float _Width;
   float _Thickness;
 
   [maxvertexcount(54)]
   void geo(triangle v2g IN[3], inout TriangleStream<g2f> triStream)
   {
    #define ADDV(v) triStream.Append(SetVertex(v))
    #define ADDTRI(v1, v2, v3) ADDV(v1); ADDV(v2); ADDV(v3); triStream.RestartStrip()
 
    float width = lerp(0, 2.0 / 3.0, _Width);
    float thickness = width * _Thickness;
    float3 triNormal = normalize(IN[0].normal + IN[1].normal + IN[2].normal);
 
    vData v[3][4];
 
    for (uint i = 0; i < 3; i++)
    {
     v2g IN_b = IN[(i + 0) % 3];
     v2g IN_1 = IN[(i + 1) % 3];
     v2g IN_2 = IN[(i + 2) % 3];
 
     /* もとの頂点 */
     v[i][0].pos = IN_b.vertex.xyz;
     v[i][0].normal = normalize(IN_b.normal);
 
     /* もとの位置から横にずらした頂点(側面の表側の頂点) */
     v[i][1].pos = IN_b.vertex.xyz + ((IN_1.vertex.xyz + IN_2.vertex.xyz) * 0.5 - IN_b.vertex.xyz) * width;
     v[i][1].normal = lerp(v[i][0].normal, triNormal, _Width);
 
     /* 横にずらした頂点の裏(側面の裏側の頂点) */
     v[i][2].pos = v[i][1].pos - v[i][1].normal * thickness;
     v[i][2].normal = -v[i][1].normal;
 
     /* もとの頂点位置の裏 */
     v[i][3].pos = v[i][0].pos - v[i][0].normal * thickness;
     v[i][3].normal = -v[i][0].normal;
    }
 
    /* 表面 */
    ADDTRI(v[1][0], v[1][1], v[0][0]);
    ADDTRI(v[0][1], v[0][0], v[1][1]);
    ADDTRI(v[0][0], v[0][1], v[2][0]);
    ADDTRI(v[2][1], v[2][0], v[0][1]);
    ADDTRI(v[2][0], v[2][1], v[1][0]);
    ADDTRI(v[1][1], v[1][0], v[2][1]);
    
    /* 側面 */
    ADDTRI(v[1][1], v[0][2], v[0][1]);
    ADDTRI(v[0][2], v[1][1], v[1][2]);
    ADDTRI(v[0][1], v[2][2], v[2][1]);
    ADDTRI(v[2][2], v[0][1], v[0][2]);
    ADDTRI(v[2][1], v[1][2], v[1][1]);
    ADDTRI(v[1][2], v[2][1], v[2][2]);
    
    /* 裏面 */
    ADDTRI(v[1][2], v[1][3], v[0][2]);
    ADDTRI(v[0][3], v[0][2], v[1][3]);
    ADDTRI(v[0][2], v[0][3], v[2][2]);
    ADDTRI(v[2][3], v[2][2], v[0][3]);
    ADDTRI(v[2][2], v[2][3], v[1][2]);
    ADDTRI(v[1][3], v[1][2], v[2][3]);
   }
   
   fixed4 frag (g2f i) : SV_Target
   {
    fixed4 col = _Color;
    UNITY_APPLY_FOG(i.fogCoord, col);
    return col;
   }
   ENDCG
  }
 }
}