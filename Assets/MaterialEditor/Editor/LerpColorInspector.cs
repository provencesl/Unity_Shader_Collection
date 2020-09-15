using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class LerpColorInspector : MaterialEditor
{
    const string keyUseLerpColor = "_USE_LERP_COLOR";

    public override void OnInspectorGUI()
    {
        if (!isVisible)
            return;

        //現在のマテリアルからキーワードを得る
        Material targetMat = target as Material;
        string[] oldKeyWords = targetMat.shaderKeywords;

        bool useLerpColor = false;
        foreach (var key in oldKeyWords)
        {
            if (key.Equals(keyUseLerpColor))
            {
                useLerpColor = true;
            }
        }

        //GUIの変更をチェック開始
        EditorGUI.BeginChangeCheck();

        //パラメータを描画
        EditorGUILayout.BeginVertical("Box");
        DrawProperties("_MainTex");
        EditorGUILayout.EndVertical();

        EditorGUILayout.BeginVertical("Box");
        useLerpColor = EditorGUILayout.Toggle("Use Lerp Color", useLerpColor);
        if (useLerpColor)
        {
            DrawProperties("_LerpColor");
        }
        EditorGUILayout.EndVertical();

        //変更があったら反映させる
        if (EditorGUI.EndChangeCheck())
        {
            //キーワードリスト作成
            List<string> newKeyWords = new List<string>();
            if (useLerpColor)
            {
                newKeyWords.Add(keyUseLerpColor);
            }

            //新しいキーワードリストをマテリアルへ設定
            //これによって適切なバリアントのシェーダーが選択される
            targetMat.shaderKeywords = newKeyWords.ToArray();
            EditorUtility.SetDirty(targetMat);
        }
    }

    void DrawProperties(string showParam)
    {
        Shader shader = ((Material)target).shader;
        for (int i = 0; i < ShaderUtil.GetPropertyCount(shader); i++)
        {
            string name = ShaderUtil.GetPropertyName(shader, i);
            if (name.Contains(showParam))
            {
                MaterialProperty prop = GetMaterialProperty(targets, i);
                ShaderProperty(prop, prop.displayName);
            }
        }
    }
}