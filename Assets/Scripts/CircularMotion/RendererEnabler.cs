using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RendererEnabler {

    private ArrayList renderers;
    public bool enabled;
    public bool Enabled {
        get { return enabled; }
        set {
            foreach (Renderer r in renderers) { r.enabled = value; }
        }
    }

    public RendererEnabler() {
        renderers = new ArrayList();
    }

    public RendererEnabler(Renderer[] renderers) {
        this.renderers = new ArrayList();
        foreach (Renderer r in renderers) { this.renderers.Add(r); }
    }

    public void Add(Renderer renderer) {
        if (renderer) { renderers.Add(renderer); }
    }

    public void Add(Renderer[] renderers) {
        if (renderers != null) {
            foreach (Renderer r in renderers) { this.renderers.Add(r); }
        }
    }

    public bool IsEmpty() {
        return renderers.Count <= 0;
    }

    public void Enable() {
        foreach (Renderer r in renderers) { r.enabled = true; }
        enabled = true;
    }

    public void Disable() {
        foreach (Renderer r in renderers) { r.enabled = false; }
        enabled = false;
    }

    public void Toggle() {
        foreach (Renderer r in renderers) { r.enabled = !r.enabled; }
    }

    public void Toggle(bool enabled) {
        foreach (Renderer r in renderers) { r.enabled = enabled; }
    }
}
