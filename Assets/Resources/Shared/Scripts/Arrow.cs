using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Arrow : MonoBehaviour {
    
    public Material material;

    void Start() {
        if (!material) {
            material =  Resources.Load("Materials/BlueMatte") as Material;
        }
    }

    void Update() {
        MeshRenderer[] meshRenderers = GetComponentsInChildren<MeshRenderer>();
        foreach (MeshRenderer meshRenderer in meshRenderers) {
            meshRenderer.material = material;
        }
    }
}
