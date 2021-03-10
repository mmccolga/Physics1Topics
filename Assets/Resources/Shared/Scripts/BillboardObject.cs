using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// This script rotates the object it is attached to, so that it always faces the camera.
/// </summary>
///
/// <example>
/// INSTRUCTIONS
/// First, import this script into Unity.
/// Attach this script as a component to a object in Unity. Most useful is to attach to a 3D Text object.
/// Find the main camera in the scene and drag it to the Camera section of  thr script.
/// </example>
public class BillboardObject : MonoBehaviour
{
    // The camera of the scene that will be used to rotate the object
    public Camera Camera;
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        transform.rotation = Camera.transform.rotation;
    }
}
