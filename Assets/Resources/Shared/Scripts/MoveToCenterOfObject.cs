using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveToCenterOfObject : MonoBehaviour
{
    public MeshFilter MeshObject;

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        if (MeshObject != null)
        {
            // Debug.Log("MoveTo: " + MeshObject.mesh.bounds.center);
            GetComponent<Transform>().localPosition = MeshObject.mesh.bounds.center;
        }
    }
}