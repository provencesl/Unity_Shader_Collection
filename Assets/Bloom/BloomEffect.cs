using UnityEngine;
using UnityEngine.Rendering;
using System.Collections;
 
namespace AZEffects
{
    [ExecuteInEditMode]
    public class BloomEffect : MonoBehaviour
    {
        [SerializeField]
        Shader _shader;

        [SerializeField]
        [Range(0, 20)]
        float _intencity1 = 1;

        [SerializeField]
        [Range(0, 5)]
        float _threshold1 = 1;

        [SerializeField]
        [Range(2, 10)]
        float _radius1 = 8;

        [SerializeField]
        [Range(0, 20)]
        float _intencity2 = 1;

        [SerializeField]
        [Range(0, 5)]
        float _threshold2 = 1;

        [SerializeField]
        [Range(2, 40)]
        float _radius2 = 8;

        Material _material;

        int _intencity1ID;
        int _intencity2ID;
        int _thresholdID;
        int _radiusID;

        int _thresholdRT_ID;

        int _small1RT_ID;
        int _small2RT_ID;

        int _middleRT_ID;

        int _bloomSource1ID;
        int _bloomSource2ID;
        int _bloomSource1RT_ID;
        int _bloomSource2RT_ID;

        void Start()
        {
            _material = new Material(_shader);

            _intencity1ID = Shader.PropertyToID("_Intencity1");
            _intencity2ID = Shader.PropertyToID("_Intencity2");
            _thresholdID = Shader.PropertyToID("_Threshold");
            _radiusID = Shader.PropertyToID("_Radius");

            _thresholdRT_ID = Shader.PropertyToID("_ThresholdRT");

            _small1RT_ID = Shader.PropertyToID("_Small1RT");
            _small2RT_ID = Shader.PropertyToID("_Small2RT");

            _middleRT_ID = Shader.PropertyToID("_MiddleRT1");

            _bloomSource1ID = Shader.PropertyToID("_BloomSource1");
            _bloomSource2ID = Shader.PropertyToID("_BloomSource2");
            _bloomSource1RT_ID = Shader.PropertyToID("_BloomSourceRT1");
            _bloomSource2RT_ID = Shader.PropertyToID("_BloomSourceRT2");
        }

        void RenderBloom(CommandBuffer commandBuffer, RenderTargetIdentifier src, int outputBufferID, float threshold, float radius, bool isCrossBloom)
        {
            // データを設定
            commandBuffer.SetGlobalFloat(_thresholdID, threshold);
            commandBuffer.SetGlobalFloat(_radiusID, radius);

            // Thresholdを適用
            int bloomWidth = (int)(Screen.width / radius);
            int bloomHeight = (int)(Screen.height / radius);
            commandBuffer.GetTemporaryRT(_thresholdRT_ID, bloomWidth, bloomHeight, 0, FilterMode.Bilinear);
            commandBuffer.Blit(src, _thresholdRT_ID, _material, 0);

            // ブルームフィルタ
            commandBuffer.GetTemporaryRT(_small1RT_ID, bloomWidth, bloomHeight, 0, FilterMode.Bilinear);
            if (isCrossBloom)
            {
                commandBuffer.Blit(_thresholdRT_ID, _small1RT_ID, _material, 1);
            }
            else
            {
                commandBuffer.GetTemporaryRT(_small2RT_ID, bloomWidth, bloomHeight, 0, FilterMode.Bilinear);

                commandBuffer.Blit(_thresholdRT_ID, _small2RT_ID, _material, 2);
                commandBuffer.Blit(_small2RT_ID, _small1RT_ID, _material, 3);
            }

            // 出力を少し拡大してぼかす
            commandBuffer.SetGlobalFloat(_radiusID, radius / 2);

            commandBuffer.GetTemporaryRT(_middleRT_ID, bloomWidth * 2, bloomHeight * 2, 0, FilterMode.Bilinear);
            commandBuffer.GetTemporaryRT(outputBufferID, bloomWidth * 2, bloomHeight * 2, 0, FilterMode.Bilinear);

            commandBuffer.Blit(_small1RT_ID, _middleRT_ID, _material, 2);
            commandBuffer.Blit(_middleRT_ID, outputBufferID, _material, 3);

        }


        void OnRenderImage(RenderTexture src, RenderTexture dst)
        {
            var commandBuffer = new CommandBuffer();

            // 元画像と加算合成する
            commandBuffer.SetGlobalFloat(_intencity1ID, _intencity1);
            commandBuffer.SetGlobalFloat(_intencity2ID, _intencity2);
            RenderBloom(commandBuffer, src, _bloomSource1RT_ID, _threshold1, _radius1, true);
            RenderBloom(commandBuffer, src, _bloomSource2RT_ID, _threshold2, _radius2, false);
            commandBuffer.SetGlobalTexture(_bloomSource1ID, _bloomSource1RT_ID);
            commandBuffer.SetGlobalTexture(_bloomSource2ID, _bloomSource2RT_ID);
            commandBuffer.Blit((RenderTargetIdentifier)src, dst, _material, 4);

            // 実行
            Graphics.ExecuteCommandBuffer(commandBuffer);
        }
    }
}