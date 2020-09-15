//遮罩允许我们保护某些区域，使它们免于修改
//使用遮罩纹理来控制光照，可以得到更加细腻的效果
//使用遮罩纹理可以控制纹理的混合，比如裸露土地、草地的纹理
//利用一张遮罩的RGBA四个通道，来存储不同的属性：
//比如把高光反射的强度存储在R通道，把边缘光照的强度存储在G通道，把高光反射的指数部分存储在B通道，最后把自发光强度存储在A通道
Shader "Custom/MaskTexture"
{
	
	Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex)", 2D) = "white" {} //主紋理
		_BumpMap ("Normal Map",2D)= "bump" {}  //法線紋理
		_BumpScale("Bump Scale",Float)=1.0
		_SpecularMask("Specular Mask",2D)="white"{} //需要使用的高光反射遮罩紋理
		_SpecularScale("Specular Scale",Float)=1.0 //控制遮罩影響度的係數
		_Specular("Specular",Color)=(1,1,1,1)
        _Gloss ("Gloss", Range(8.0,256)) = 20
    }
    SubShader
    {
	    Pass{
		    Tags { "LightMode"="ForwardBase" } //LightMode標籤是Pass標籤中的一種，它用於定義該Pass再Unity的光照流水線中的角色
            LOD 200
		    //使用CGPROGRAM 和ENDCG包住Cg程式碼片段，一定義最終的頂點著色器和片元著色器程式碼。使用#pragma指令來告訴Unity，我們定義的頂點著色器和片元著色器程式碼
            CGPROGRAM
		    #pragma vertex vert
		    #pragma fragment frag
		    //為了使用Unity內建的一些變數，如_LightColor0,還需要包含進Unity的內建檔案Lighting.cginc
		    #include "Lighting.cginc"
		    //定義和Properties中各個屬性型別相匹配的變數
		    fixed4 _Color;
		    sampler2D _MainTex;
		    float4 _MainTex_ST; //為主紋理，法線紋理和遮罩紋理定義了他們共同使用的紋理屬性變數，這意味著在材質面板中修改主紋理的平鋪係數和偏移係數會同時影響
		    //3個紋理的採樣。使用這種方式可以讓我們節省需要儲存的紋理坐標數目，如果我們為每一個紋理都使用一個單獨的屬性變數TextureName_ST,那麼隨著使用的紋理數目的增加
		    //我們會迅速佔滿頂點著色器中可以使用的插值暫存器。
		    sampler2D _BumpMap;
		    float _BumpScale;
		    sampler2D _SpecularMask;
		    float _SpecularScale;
		    fixed4 _Specular;
		    float _Gloss;

		    //定義頂點著色器的輸入和輸出結構體
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;//頂點的切向量
				float4 texcoord : TEXCOORD0;//頂點的第一個uv坐標
			};
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 lightDir: TEXCOORD1;//第一張貼圖的uv坐標
				float3 viewDir : TEXCOORD2;
			};
		   //在頂點著色器中，對光照方向和視角方向進行了坐標空間的轉換，把他們從模型空間轉換到了切線空間中，以便在片元著色器中和發現進行光照運算。
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex); //UnityObjectToClipPos 將坐標點從模型空間轉換到裁剪空間
				
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				
				TANGENT_SPACE_ROTATION;//TANGENTA_SPACE_ROTATION 是內建在 UnityCG.cginc 中的一個巨集，作用是實現從模型空間到切線空間的轉換
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;//用ObjSpaceLightDir()來獲得的模型空間的光照方向然後轉換到切線空間
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;//用ObjSpaceViewDir()來獲得的模型空間的視點方向然後轉換到切線空間
				
				return o;
			}
		   //使用遮罩紋理的地方是片元著色器。我們使用它來控制模型表面的高光反射強度
			fixed4 frag(v2f i) : SV_Target {
			 	fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));//UnpackNormal()函式是對法線紋理的採樣結果的一個反對映操作，其對應的法線紋理需要設定為Normal map的格式，才能使用該函式
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));//saturate(x)的作用是如果x取值小於0，則回傳值為0。如果x取值大於1，則回傳值為1。若x在0到1之間，則直接回傳x的值

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;//tex2D()這是CG程式中用來在一張貼圖中對一個點進行採樣的方法，回傳一個float4
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;//UNITY_LIGHTMODEL_AMBIENT表示系統的環境光
				
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
				
			 	fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);//Blinn-Phong高光光照模型，相對於普通的Phong高光模型，會更加光
			 	// Get the mask value
			 	fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
			 	// Compute specular term with the specular mask
			 	fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) * specularMask;
			
				return fixed4(ambient + diffuse + specular, 1.0);
			}
             ENDCG
		}
    }
    FallBack "Specular"




}
