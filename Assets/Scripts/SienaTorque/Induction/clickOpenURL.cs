using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/**
 * Description: This opens a url in the device's preffered browser.
 * 
 * @author Nevno48
 * @version 6/21/19
 */
public class clickOpenURL : MonoBehaviour
{

    public string urlAddress;
    /**
     * Description: opens the url
     */
    public void openURL()
    {
        Application.OpenURL(urlAddress);
    }
}
