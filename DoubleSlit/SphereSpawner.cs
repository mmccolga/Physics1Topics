using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SphereSpawner : MonoBehaviour
{

    ObjectPooler objPooler;

    private void Start()
    {
        objPooler = ObjectPooler.Instance;
    }

    void FixedUpdate()
    {
        objPooler.SpawnFromPool("Sphere", transform.position, Quaternion.identity);
    }

}
