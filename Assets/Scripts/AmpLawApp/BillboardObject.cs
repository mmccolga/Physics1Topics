using System.Collections;
using System.Collections.Generic;
using UnityEngine;


/*
 * Description: Place theis script on a 3d text mesh pro object, 
 * not a 3d object the shape of text from tinkercad. This will make the object
 * alwasy face the camera.
 * @author Sam O and Nick Giordano
 * @date 03/19/21
 * 
 */
public class BillboardObject : MonoBehaviour
{
     
    public Camera Camera;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //makes sure the object always faces the camera
        transform.rotation = Camera.transform.rotation;
    }
}
