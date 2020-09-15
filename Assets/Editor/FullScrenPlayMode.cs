using UnityEditor;
using UnityEngine;

namespace FullScreenPlayModes
{
    [InitializeOnLoad]
    public class FullScreenPlayMode : Editor
    {
        ////The size of the toolbar above the game view, excluding the OS border.
        //private static int toolbarHeight = 22;

        //static FullScreenPlayMode()
        //{
        //    EditorApplication.playModeStateChanged -= PlayModeStateChanged;
        //    EditorApplication.playModeStateChanged += PlayModeStateChanged;
        //}

        //static void PlayModeStateChanged(PlayModeStateChange _playModeStateChange)
        //{
        //    if (PlayerPrefs.GetInt("PlayMode_FullScreen", 0) == 1)
        //    {
        //        // Get game editor window
        //        EditorApplication.ExecuteMenuItem("Window/Game");
        //        System.Type T = System.Type.GetType("UnityEditor.GameView,UnityEditor");
        //        System.Reflection.MethodInfo GetMainGameView = T.GetMethod("GetMainGameView", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
        //        System.Object Res = GetMainGameView.Invoke(null, null);
        //        EditorWindow gameView = (EditorWindow)Res;

        //        switch (_playModeStateChange)
        //        {
        //            case PlayModeStateChange.EnteredPlayMode:

        //                Rect newPos = new Rect(0, 0 - toolbarHeight, Screen.currentResolution.width, Screen.currentResolution.height + toolbarHeight);

        //                gameView.position = newPos;
        //                gameView.minSize = new Vector2(Screen.currentResolution.width, Screen.currentResolution.height + toolbarHeight);
        //                gameView.maxSize = gameView.minSize;
        //                gameView.position = newPos;

        //                break;

        //            case PlayModeStateChange.EnteredEditMode:

        //                gameView.Close();

        //                break;
        //        }
        //    }
        //}

        //[MenuItem("Tools/Editor/Play Mode/Full Screen", false, 0)]
        //public static void PlayModeFullScreen()
        //{
        //    PlayerPrefs.SetInt("PlayMode_FullScreen", 1);
        //}

        //[MenuItem("Tools/Editor/Play Mode/Full Screen", true, 0)]
        //public static bool PlayModeFullScreenValidate()
        //{
        //    return PlayerPrefs.GetInt("PlayMode_FullScreen", 0) == 0;
        //}

        //[MenuItem("Tools/Editor/Play Mode/Window", false, 0)]
        //public static void PlayModeWindow()
        //{
        //    PlayerPrefs.SetInt("PlayMode_FullScreen", 0);
        //}

        //[MenuItem("Tools/Editor/Play Mode/Window", true, 0)]
        //public static bool PlayModeWindowValidate()
        //{
        //    return PlayerPrefs.GetInt("PlayMode_FullScreen", 0) == 1;
        //}
    }
}