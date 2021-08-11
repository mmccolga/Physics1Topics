using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GravityArrowHandler : MonoBehaviour
{
    public void Update()
    {
        transform.rotation = Quaternion.Euler(0, 0, 180);
    }
}
