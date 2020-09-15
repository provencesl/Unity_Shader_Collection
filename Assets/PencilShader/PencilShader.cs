using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PencilShader : MonoBehaviour
{

    Material material;

    void Start()
    {
        material = new Material(Shader.Find("Hidden/PencilShader"));
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, material);
    }
}