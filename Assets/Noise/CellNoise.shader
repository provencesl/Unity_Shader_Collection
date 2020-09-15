Shader "Custom/CellNoise"
{
    Properties
    {
        _SquareNum ("SquareNum", int) = 10
        _Brightness ("Brightness", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            int _SquareNum;
            float _Brightness;

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

            float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)),
                            dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float2 st = i.uv;
                st *= _SquareNum; //格子状の１辺のマス目数

                float2 ist = floor(st);//整数
                float2 fst = frac(st);//小数点以下

                float distance = 5;

                //自身含む周囲のマスを探索
                for (int y = -1; y <= 1; y++)
                for (int x = -1; x <= 1; x++)
                {
                    //マスの起点(0,0)
                    float2 neighbor = float2(x, y);

                    //マスの起点を基準にした白点のxy座標
                    float2 p = 0.5 + 0.5 * sin(_Time.y  + 6.2831 * random2(ist + neighbor));

                    //白点と処理対象のピクセルとの距離ベクトル
                    float2 diff = neighbor + p - fst;

                    //白点との距離が短くなれば更新
                    distance = min(distance, length(diff));
                }

                //白点から最も短い距離を色に反映
                return distance * _Brightness;
            }
            ENDCG
        }
    }
}