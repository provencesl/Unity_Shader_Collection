using UnityEngine;

public class Demo : MonoBehaviour
{
	public NPRCartoonEffect[] m_Cartoons;
	
    void Start ()
	{
		QualitySettings.antiAliasing = 8;
		m_Cartoons = GameObject.FindObjectsOfType<NPRCartoonEffect> ();
		for (int i = 0; i < m_Cartoons.Length; i++)
			m_Cartoons[i].Initialize ();
	}
	void Update ()
    {
		for (int i = 0; i < m_Cartoons.Length; i++)
			m_Cartoons[i].UpdateSelfParameters ();
    }
	void OnGUI()
	{
		GUI.Box (new Rect (10, 10, 230, 26), "NPR Cartoon Effect Demo");
	}
}
