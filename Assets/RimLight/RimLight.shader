Shader "Custom/Rim Lighting" {
		 //屬性域
		Properties {
			//紋理顏色
			 _MainColor ("Main Color", Color) = (1,1,1,1)
			  //主紋理屬性
			  _MainTex ("Texture", 2D) = "white" {}
			  //法線貼圖紋理屬性
			  _BumpMap ("Bumpmap", 2D) = "bump" {}
			  //邊緣光顏色值
			  _RimColor ("Rim Color", Color) = (1,1,1,1)
			  //邊緣光強度值
			  _RimPower ("Rim Power", Range(0.5,8.0)) = 3.0
	    }
		SubShader {
			  //標明渲染型別是不透明的物體
			  Tags { "RenderType" = "Opaque" }
			  //標明CG程式的開始
			  CGPROGRAM
			  //宣告表面著色器函式
			  #pragma surface surf Lambert
			  //定義著色器函式輸入的引數Input
			  struct Input {
			  	  //主紋理座標值
			      float2 uv_MainTex;
			      //法線貼圖座標值
			      float2 uv_BumpMap;
			      //檢視方向
			      float3 viewDir;
			  };
			  //宣告對屬性的引用
			  float4 _MainColor;
			  sampler2D _MainTex;
			  sampler2D _BumpMap;
			  float4 _RimColor;
			  float _RimPower;
			  //表面著色器函式
			  void surf (Input IN, inout SurfaceOutput o) {
			  	  fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			  	  
			  	  //賦值顏色資訊
				  o.Albedo = tex.rgb * _MainColor.rgb;
			      //賦值法線資訊
			      o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
			      half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
			      //賦值自發光顏色資訊
			      o.Emission = _RimColor.rgb * pow (rim, _RimPower);
			  }
			  //標明CG程式的結束
			  ENDCG
		} 
	    Fallback "Diffuse"
}