using UnityEngine;

public class CircularMovement : MonoBehaviour
{
    public Transform center;
    private Vector3 startingLocalPosition;
    private Quaternion startingLocalRotation;

    public float initialVelocity;
    public Vector3 inititalVDirection;
    public bool rotate = true;
    public float maxSize = 1;
    public float minSize = 1;

    private Vector3 velocity;
    private float radius;
    private Vector3 vCenter;
    private float centripetalForce;
    private bool revolving;
    private Vector3 lastVelocity;
    private Vector3 centripetalAccel;

    private void Awake()
    {
        revolving = true;
    }

    private void OnEnable()
    {
        radius = (center.localPosition - transform.localPosition).magnitude;
        velocity = inititalVDirection * initialVelocity;
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
        velocity = Vector3.zero;
    }

    private void FixedUpdate()
    {
        if (revolving)
        {
            ApplyCentripetalForce();
            
            if (maxSize != minSize)
                OscilateSize();
            
            transform.localPosition = transform.localPosition + (velocity * Time.fixedDeltaTime);

            if (rotate)
                Rotate();
        }
    }

    private void ApplyCentripetalForce()
    {
        vCenter = center.localPosition - transform.localPosition;
        centripetalForce = velocity.sqrMagnitude / radius;    // ac = (v^2 / r) * M
        centripetalAccel = vCenter.normalized * centripetalForce;

        velocity += centripetalAccel * Time.fixedDeltaTime; // apply ac
    }

    private void Rotate()
    {
        if (inititalVDirection == Vector3.forward)
        {
            transform.localRotation = Quaternion.LookRotation(velocity, Vector3.up);
            return;
        }

        if (inititalVDirection == Vector3.right)
        {
            transform.localRotation = Quaternion.LookRotation(Vector3.forward, vCenter);
            return;
        }
    }

    public float GetOscilationValue()
    {
        return 1 - ((transform.localPosition.y - startingLocalPosition.y) / (2 * radius));
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
            revolving = false;
            lastVelocity = velocity;
            velocity = Vector3.zero;
        }
        else
        {
            revolving = true;
            velocity = lastVelocity;
        }
    }

    public void Reset()
    {
        OnDisable();
        OnEnable();
    }
}