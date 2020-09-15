Shader "Test/Cull"
{
	
	Properties {
		_Color ("主颜色", Color) = (1,1,1,1)
		_SpecColor ("高光颜色", Color) = (1,1,1,1)
		_Emission ("光泽颜色", Color) = (0,0,0,0)
		_Shininess ("光泽度", Range(0.01, 1)) = 0.7
		_MainTex ("基础纹理(RGB)-透明度(A)", 2D) = "white" {}
	}
	
	SubShader {
		// 通道1
		// 绘制对象的前面部分,使用简单的白色材质，并应用主纹理
		Pass{
			Cull Back
			Material{
				Diffuse[_Color]
				Ambient[_Color]
				Specular[_Color]
				Emission[_Emission]
				Shininess[_Shininess]
			}
			
			Lighting On
			
			SetTexture[_MainTex]{
				combine Primary * texture
			}
		}

		// 通道2
		// 采用亮蓝色来渲染背面
		Pass{
			Color(0,0,1,1)
			Cull Front
		}
	}


}
