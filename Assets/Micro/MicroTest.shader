// シェーダのマクロショートコード
Shader "SL/Custom/MacroTest"
{
    Properties
    {
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        #ifdef SHIBUYA24
            #define TEST_MACRO(abc) abc.x = 0;
        #else
            #define TEST_MACRO(abc) abc.z = 0;
        #endif

        fixed4 frag (v2f_img i) : SV_Target
        {
            fixed4 col = fixed4(1,1,1,1);
            // マクロ適用
            TEST_MACRO(col);
            return col;
        }
        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            // 下記のように書いてしまうとSHIBUYA24が存在しないShaderがコンパイルされない
            // #pragma multi_compile SHIBUYA24
            #pragma multi_compile _ SHIBUYA24
            ENDCG
        }
    }
}