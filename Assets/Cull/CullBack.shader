Shader "Test/CullBack"
{
	Properties
	{
	}
	SubShader
	{
		Pass{

			Material{
				Emission(0.3,0.3,0.3,0.3)
				Diffuse(1,1,1,1)
				Ambient(1,1,1,1)
			}
			Lighting On
			
			Cull Front
		}

	}
}
