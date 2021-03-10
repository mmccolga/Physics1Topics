using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class RaytraceableClick : MonoBehaviour
{
    private bool LastButtonState;

    public UnityEvent OnClick;
    public UnityEvent OnTouch;

    public GameObject Object;
    public Camera Camera;


    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.mousePresent)
        {
            if (Input.GetMouseButton(0) && !LastButtonState)
            {

                if (GetHit())
                {
                    OnClick.Invoke();
                }
            }
            LastButtonState = Input.GetMouseButton(0);
        }
        else
        {
            if (Input.touches[0].phase == TouchPhase.Began)
            {

                if (GetHit())
                {
                    OnTouch.Invoke();
                }
            }
        }
    }

    private bool GetHit()
    {
        Vector3 pos = Input.mousePosition;
        Ray ray = Camera.ScreenPointToRay(pos);
        
        RaycastHit hit;
        return Physics.Raycast(ray, out hit, Mathf.Infinity) && hit.transform.gameObject == Object;
    }
}
