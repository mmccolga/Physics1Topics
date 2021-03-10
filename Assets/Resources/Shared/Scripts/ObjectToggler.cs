using UnityEngine;

public class ObjectToggler : MonoBehaviour {

    public GameObject objectToToggle;
    public bool onlyToggleRenderer;
    public bool startOn;
    private bool toggled;
    private RendererEnabler rendererEnabler;

    private void Start() {
        toggled = startOn;
        if (onlyToggleRenderer) {
            rendererEnabler = new RendererEnabler();
            Renderer objectRenderer = objectToToggle.GetComponent<Renderer>();
            if (objectRenderer) { rendererEnabler.Add(objectRenderer); }
            rendererEnabler.Add(objectToToggle.GetComponentsInChildren<Renderer>());
            rendererEnabler.Toggle(startOn);
        } else {
            objectToToggle.SetActive(startOn);
        }
    }

    public void ToggleObject() {
        toggled = (toggled) ? false : true;
        objectToToggle.SetActive(toggled);
    }

    public void ToggleRenderer() {
        if (toggled) {
            rendererEnabler.Disable();
            toggled = false;
        } else {
            rendererEnabler.Enable();
            toggled = true;
        }
    }
}
