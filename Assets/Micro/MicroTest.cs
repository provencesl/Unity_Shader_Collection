using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MicroTest : MonoBehaviour
{
    public Material mat;
    bool m_enableShibuya24;
    void OnGUI()
    {
        if (GUILayout.Button("Change"))
        {
            if (m_enableShibuya24)
                mat.DisableKeyword("SHIBUYA24");
            else
                mat.EnableKeyword("SHIBUYA24");
            m_enableShibuya24 = !m_enableShibuya24;
        }
        GUILayout.Label("m_enableMacro : " + m_enableShibuya24);
    }
}