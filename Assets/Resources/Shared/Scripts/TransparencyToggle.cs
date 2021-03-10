using UnityEngine;

public class TransparencyToggle : MonoBehaviour {

    public GameObject firstObject;
    public GameObject secondObject;
    public Material firstMaterial;
    public Material secondMaterial;
    public Material firstTransparentMaterial;
    public Material secondTransparentMaterial;
    private bool toggled = false;
    
    public void ToggleTransparency() {
        toggled = (toggled) ? false : true;

        MeshRenderer firstMR = firstObject.GetComponent<MeshRenderer>();
        MeshRenderer secondMR = secondObject.GetComponent<MeshRenderer>();

        if (toggled) {
            firstMR.material = firstTransparentMaterial;
            secondMR.material = secondTransparentMaterial;
        }
        else {
            firstMR.material = firstMaterial;
            secondMR.material = secondMaterial;
        }
    }
}
