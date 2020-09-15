using UnityEngine;
using UnityEditor;
using System.IO;

public class RampImageEditor : EditorWindow
{
	private static RampImageEditor sInstance = null;
	private static readonly int k_MaxGradientLevel = 4;
	private int m_Gradient = 1;
	private int[] m_GradientValues = new int[k_MaxGradientLevel];
	private int[] m_GradientColors = new int[k_MaxGradientLevel + 1];
	private Texture2D m_Ramp;
	private string m_RampName = "Default";
	
	[MenuItem("Window/NPR Cartoon Ramp Image Editor")]
	public static void Open ()
	{
		RampImageEditor rie = EditorWindow.GetWindow<RampImageEditor> (false, "Ramp Editor");
		rie.minSize = new Vector2 (600f, 300f);
		rie.Show ();
		sInstance = rie;
		sInstance.Init ();
	}
	public void Init ()
	{
		for (int i = 0; i < k_MaxGradientLevel; i++)
		{
			m_GradientValues[i] = 0;
			m_GradientColors[i] = 0;
		}
		m_GradientColors[k_MaxGradientLevel] = 0;
		CreateNewTexture ();
	}
	void OnGUI ()
	{
		GUILayout.BeginHorizontal ("box");
		{
			GUILayout.Label ("Gradient: ");
			if (GUILayout.Button ("-"))
			{
				if (m_Gradient == 1)
					return;
				--m_Gradient;
			}
			GUILayout.Label (m_Gradient.ToString ());
			if (GUILayout.Button ("+"))
			{
				if (m_Gradient == 3)
					return;
				++m_Gradient;
			}
			if (GUILayout.Button ("Reset"))
			{
				Init ();
			}
		}
		GUILayout.EndHorizontal ();
		
		for (int i = 0; i < m_Gradient; i++)
		{
			GUI.Box (new Rect (5, 30 + i * 20, Screen.width - 5, 20), "");
			GUI.Label (new Rect (5, 30 + i * 20, 65, 20), "Gradient " + (i + 1).ToString ());
			GUI.Label (new Rect (90, 30 + i * 20, 70, 20), "Level:");
			m_GradientValues[i] = (int)GUI.HorizontalSlider (new Rect (150, 30 + i * 20, 120, 20), (float)m_GradientValues[i], 0f, 256f);
			GUI.Label (new Rect (280, 30 + i * 20, 50, 20), m_GradientValues[i].ToString ());
			GUI.Label (new Rect (340, 30 + i * 20, 70, 20), "Luminance:");
			m_GradientColors[i] = (int)GUI.HorizontalSlider (new Rect (420, 30 + i * 20, 120, 20), (float)m_GradientColors[i], 0f, 255f);
			GUI.Label (new Rect (550, 30 + i * 20, 50, 20), m_GradientColors[i].ToString ());
		}
		int h = m_Gradient;
		GUI.Label (new Rect (5, 30 + h * 20, 65, 20), "Gradient " + (h + 1).ToString ());
		GUI.Label (new Rect (340, 30 + h * 20, 70, 20), "Luminance:");
		m_GradientColors[m_Gradient] = (int)GUI.HorizontalSlider (new Rect (420, 30 + h * 20, 120, 20), (float)m_GradientColors[m_Gradient], 0f, 255f);
		GUI.Label (new Rect (550, 30 + h * 20, 50, 20), m_GradientColors[m_Gradient].ToString ());
		if (m_Ramp)
			GUI.DrawTexture (new Rect (5, 35 + (h + 1) * 20, Screen.width - 15, 20), m_Ramp, ScaleMode.StretchToFill);
		m_RampName = GUI.TextField (new Rect (5, 40 + (h + 2) * 20, 120, 20), m_RampName);
		if (GUI.Button (new Rect (135, 40 + (h + 2) * 20, 120, 20), "Save"))
			SaveRampTexture ();
		
		UpdateRampTexture ();
		ApplyRampTexture ();
	}
	void CreateNewTexture ()
	{
		m_Ramp = new Texture2D (256, 1, TextureFormat.RGB24, false);
		m_Ramp.wrapMode = TextureWrapMode.Clamp;
	}
	void UpdateRampTexture ()
	{
		if (m_Ramp == null)
			return;
		Color[] pixels = m_Ramp.GetPixels ();
		if (m_Gradient == 1)
		{
			int start = 0;
			int end = m_GradientValues[0];
			float c = m_GradientColors[0] / 255f;
			for (int p = start; p < end; p++)
				pixels[p] = new Color (c, c, c, 1f);
			
			start = m_GradientValues[0];
			end = 256;
			c = m_GradientColors[1] / 255f;
			for (int p = start; p < end; p++)
				pixels[p] = new Color (c, c, c, 1f);
		}
		else if (m_Gradient == 2)
		{
			int start = 0;
			int end = m_GradientValues[0];
			float c = m_GradientColors[0] / 255f;
			for (int p = start; p < end; p++)
				pixels[p] = new Color (c, c, c, 1f);
			
			start = m_GradientValues[0];
			end = m_GradientValues[1];
			c = m_GradientColors[1] / 255f;
			for (int p = start; p < end; p++)
				pixels[p] = new Color (c, c, c, 1f);
			
			start = m_GradientValues[1];
			end = 256;
			c = m_GradientColors[2] / 255f;
			for (int p = start; p < end; p++)
				pixels[p] = new Color (c, c, c, 1f);
		}
		else if (m_Gradient == 3)
		{
			int start = 0;
			int end = m_GradientValues[0];
			float c = m_GradientColors[0] / 255f;
			for (int p = start; p < end; p++)
				pixels[p] = new Color (c, c, c, 1f);
			
			start = m_GradientValues[0];
			end = m_GradientValues[1];
			c = m_GradientColors[1] / 255f;
			for (int p = start; p < end; p++)
				pixels[p] = new Color (c, c, c, 1f);
			
			start = m_GradientValues[1];
			end = m_GradientValues[2];
			c = m_GradientColors[2] / 255f;
			for (int p = start; p < end; p++)
				pixels[p] = new Color (c, c, c, 1f);
			
			start = m_GradientValues[2];
			end = 256;
			c = m_GradientColors[3] / 255f;
			for (int p = start; p < end; p++)
				pixels[p] = new Color (c, c, c, 1f);
		}
		m_Ramp.SetPixels (pixels);
		m_Ramp.Apply (false);
	}
	void ApplyRampTexture ()
	{
		if (!Application.isPlaying)
			return;

		NPRCartoonEffect[] effs = GameObject.FindObjectsOfType<NPRCartoonEffect> ();
		for (int i = 0; i < effs.Length; i++)
			effs[i].m_Ramp = m_Ramp;
	}
	void SaveRampTexture ()
	{
		if (m_Ramp == null)
			return;
		byte[] bytes = m_Ramp.EncodeToPNG ();
		string filepath = Application.dataPath + "/NPRCartoonEffect/Texture/" + m_RampName + ".png";
		File.WriteAllBytes (filepath, bytes);
		EditorUtility.DisplayDialog ("Save Ramp Image", "Save " + m_RampName + ".png to NPRCartoonEffect/Texture/ successful", "ok");
	}
}
