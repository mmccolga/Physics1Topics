using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneSwitcher : MonoBehaviour
{
    public Object loadThisScene;

    /*
     * This methods switches the scene to the selected scene the user specifies in the inspector.
     */
    public void SwitchScene()
    {
        //Debug.Log(loadThisScene.name);
        SceneManager.LoadScene(loadThisScene.name);
    }

    /*
     * This methods switches the scene to the selected scene the user specifies in the inspector via string.
     */
    public void SwitchSceneByName(string name)
    {
        SceneManager.LoadScene(name);
    }
}
