using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using UnityEditor;

public class ExampleShaderInspector : MaterialEditor
{

	// マテリアルへのアクセス
	Material material
	{
		get
		{
			return (Material)target;
		}
	}

	// Inspectorに表示される内容
	public override void OnInspectorGUI()
	{
		// マテリアルを閉じた時に非表示にする
		if (isVisible == false) { return; }

		// 入力内容が変更されたかチェック
		EditorGUI.BeginChangeCheck();

		// InspectorのGUIを定義
		Texture mainTex = EditorGUILayout.ObjectField(
			"main texture",
			material.GetTexture("_MainTex"),
			typeof(Texture),
			false) as Texture;
		Color color = EditorGUILayout.ColorField(
			"color",
			material.GetColor("_Color"));

		// 更新されたら内容を反映
		if (EditorGUI.EndChangeCheck())
		{
			material.SetTexture("_MainTex", mainTex);
			material.SetColor("_Color", color);
		}
	}
}