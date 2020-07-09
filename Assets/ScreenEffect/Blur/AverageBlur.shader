﻿
Shader "ImageEffect/AverageBlur"
{
	Properties		//变量定义
	{
		_MainTex ("Texture", 2D) = "white" {}	//主贴图
		_BlurRadius("BlurRadius",float) = 1
	}
	CGINCLUDE
	#include "UnityCG.cginc"
	struct v2f
	{
		float4 pos:SV_POSITION;
		float2 uv:TEXCOORD0;
	};
	sampler2D _MainTex;		//基础颜色贴图输入
	float4 _MainTex_TexelSize;		//XX_TexelSize，XX纹理的像素相关大小width，height对应纹理的分辨率，
									//x = 1/width, y = 1/height, z = width, w = height
	float _BlurRadius;		//模糊采样半径
	v2f  vert (appdata_img v)
	{
		v2f  o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv=v.texcoord.xy;
		return o;
	}
	fixed4 frag (v2f i) : SV_Target		//frag片段函数 会对每一个像素点执行此函数 输入像素颜色等信息 输出最终该点颜色
	{
		fixed4 col = fixed4(0,0,0,0);	//初始化颜色为黑色 fixed4及四维向量 精度为fixed以此类推 

		fixed2 offset=_BlurRadius*_MainTex_TexelSize;	//用offset保存 半径对应贴图的uv偏移量

		for (int x=0;x<3;x++){			//循环遍历周围像素点
			for (int y=0;y<3;y++){
				col+=tex2D(_MainTex,i.uv+fixed2(x-1,y-1)*offset);	//全部加和
			}
		}
		col=col/9;
		col.a=1;
		return col;		//因遍历周围9各像素点
	} 
	ENDCG
	SubShader
	{
		Cull Off ZWrite Off ZTest Always 
		Pass	//Pass 通道 主要是实现一些顶点和片段着色器功能
		{
			CGPROGRAM	//CG程序开始
			 //声明顶点着色器函数名字为vert
			#pragma vertex vert	
			 //声明片段着色器函数名字为frag
			#pragma fragment frag
			ENDCG		 //CG程序结束
		}
	}
}
