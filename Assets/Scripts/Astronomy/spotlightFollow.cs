using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class spotlightFollow : MonoBehaviour
{
    public GameObject theObject;

    // Update is called once per frame
    void Update()
    {
        transform.LookAt(theObject.transform);
    }
}
