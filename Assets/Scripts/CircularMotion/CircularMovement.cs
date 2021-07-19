using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CircularMovement : MonoBehaviour
{
    //public GameObject 
    public Transform centerObject;
    public float initialVelocity;
    public bool rotate = true;
    public bool freezeLocalZRotation = false;
    public bool freezeLocalYRotation = false;
    public float maxSize = 1;
    public float minSize = 1;

    private Vector3 startPos;
    private Quaternion startRot;
    private bool revolving;

    private Vector3 velocity;
    private float radius;

    private Vector3 dirToLocalCenter;
    private float centripetalAccl;

    private void Awake()
    {
        startPos = transform.localPosition;
        startRot = transform.localRotation;
        radius = (centerObject.localPosition - transform.localPosition).magnitude;
        velocity = transform.rotation * transform.forward * initialVelocity;
    }

    private void OnEnable()
    {
        transform.localPosition = startPos;
        transform.localRotation = startRot;

        revolving = true;
    }

    private void OnDisable()
    {
        if (revolving)
            revolving = false;

        velocity = Vector3.zero;
    }

    private void FixedUpdate()
    {
        if (!revolving)
            return;

        if (maxSize != minSize)
            OscilateSize();

        CalculateCentripetalForce();

        if (rotate)
            Rotate();

        transform.localPosition += velocity * Time.fixedDeltaTime;
    }

    private void CalculateCentripetalForce()
    {
        dirToLocalCenter = (centerObject.localPosition - transform.localPosition).normalized;

        centripetalAccl = velocity.sqrMagnitude / radius; // ac = (v^2 / r) * M

        velocity += centripetalAccl * Time.fixedDeltaTime * dirToLocalCenter;
    }

    private void Rotate()
    {
        Quaternion forward = Quaternion.LookRotation(velocity, Vector3.up);

        if (freezeLocalZRotation)
            forward.eulerAngles = new Vector3(forward.eulerAngles.x, forward.eulerAngles.y, transform.localRotation.eulerAngles.z);

        if (freezeLocalYRotation)
            forward.eulerAngles = new Vector3(forward.eulerAngles.x, transform.localRotation.eulerAngles.y, forward.eulerAngles.z);

        transform.localRotation = forward;
    }

    public float GetOscilationValue()
    {
        return 1 - ((transform.localPosition.y - startPos.y) / (2 * radius));
    }

    private float OscilateBetweenFloats(float max, float min)
    {
        return (max - min) * GetOscilationValue();
    }

    private void OscilateSize()
    {
        transform.localScale = new Vector3(transform.localScale.x, OscilateBetweenFloats(maxSize, minSize), transform.localScale.z);
    }

    public void ToggleRevolution()
    {
        if (revolving)
        {
            OnDisable();
            return; 
        }
        OnEnable();
    }
}