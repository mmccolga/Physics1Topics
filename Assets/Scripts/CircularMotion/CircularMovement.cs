using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CircularMovement : MonoBehaviour {
    new private Rigidbody rigidbody;
    public GameObject centerObject;
    private Transform center;
    private Vector3 startingLocalPosition;
    private Quaternion startingLocalRotation;

    public float initialVelocity;
    public bool rotate = true;
    public float maxSize = 1;
    public float minSize = 1;

    private float radius;
    private Vector3 vCenter;
    private float centripetalForce;
    private bool revolving;
    private Vector3 lastVelocity;

    private void Awake() {
        revolving = true;
    }

    private void OnEnable()
    {
        rigidbody = GetComponent<Rigidbody>();
        
        center = centerObject.transform;
        radius = (center.position - transform.position).magnitude;
        rigidbody.velocity = transform.forward * initialVelocity;
    }

    private void Start()
    {
        startingLocalPosition = transform.localPosition;
        startingLocalRotation = transform.localRotation;
    }

    private void OnDisable()
    {
        transform.localPosition = startingLocalPosition;
        transform.localRotation = startingLocalRotation;
        rigidbody.velocity = Vector3.zero;
    }

    private void FixedUpdate() {
        if (revolving) {
            ApplyCentripetalForce();
            if (rotate) { Rotate(); }
            if (maxSize != minSize) { OscilateSize(); }
            rigidbody.velocity = Vector3.ClampMagnitude(rigidbody.velocity, initialVelocity);
        }
    }

    private void ApplyCentripetalForce() {
        vCenter = center.position - transform.position;
        centripetalForce = (Mathf.Pow(rigidbody.velocity.magnitude, 2f) / radius) * rigidbody.mass; // ac = (v^2 / r) * M
        rigidbody.AddForce(vCenter.normalized * centripetalForce); // apply ac
    }

    private void Rotate() {
        if (Vector3.Dot(transform.up.normalized, vCenter.normalized) == 1) {
            transform.rotation = Quaternion.LookRotation(rigidbody.velocity, vCenter);
        } else {
            transform.rotation = Quaternion.LookRotation(rigidbody.velocity, transform.up);
        }
    }

    public float GetOscilationValue() {
        return 1 - ((transform.localPosition.y - startingLocalPosition.y) / (2 * radius));
    }

    private float OscilateBetweenFloats(float max, float min) {
        return (max - min) * GetOscilationValue();
    }

    private void OscilateSize() {
        transform.localScale = new Vector3(transform.localScale.x, OscilateBetweenFloats(maxSize, minSize), transform.localScale.z);
    }

    public void ToggleRevolution() {
        if (revolving) {
            revolving = false;
            lastVelocity = rigidbody.velocity;
            rigidbody.velocity = Vector3.zero;
        } else {
            revolving = true;
            rigidbody.velocity = lastVelocity;
        }
    }

    public void Reset()
    {
        OnDisable();
        OnEnable();
    }
}