using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ArrowHeadScaler : MonoBehaviour {

    private Vector3 originalScale;
    private Vector3 parentOriginalScale;

    private void Awake() {
        originalScale = transform.localScale;
        parentOriginalScale = transform.parent.localScale;
    }

    private void LateUpdate() {
        Vector3 currentParentScale = transform.parent.localScale;

        Vector3 diff;

        // Get the relative difference to the original scale
        diff.x = currentParentScale.x / parentOriginalScale.x;
        diff.y = currentParentScale.y / parentOriginalScale.y;
        diff.z = currentParentScale.z / parentOriginalScale.z;

        // This inverts the scale differences
        if (diff.x != 0) {
            diff.x = 1 / diff.x;
        }
        if (diff.y != 0) {
            diff.y = 1 / diff.y;
        }
        if (diff.z != 0) {
            diff.z = 1 / diff.z;
        }

        // Apply the inverted differences to the original scale
        transform.localScale = Vector3.Scale(originalScale, diff);
    }
}
