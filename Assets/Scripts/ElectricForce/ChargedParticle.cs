using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// A Charged Particle class. Attach to a GameObject that you want to be used as a charged particle.
/// </summary>
public class ChargedParticle : MonoBehaviour
{
    public const float ScaleFactor = 0.5f;

    //The signed magnitude of this particle
    internal float Magnitude;
    public float StartMagnitude;
    internal Vector3 Position;
    public Vector3 StartPosition;
    public Material PositiveChargeMaterial;
    public Material NeutralChargeMaterial;
    public Material NegativeChargeMaterial;

    public Material SelectedPositiveChargeMaterial;
    public Material SelectedNeutralChargeMaterial;
    public Material SelectedNegativeChargeMaterial;

    internal bool Selected;

    public Transform Transform
    {
        get => GetComponent<Transform>();
    }

    // Start is called before the first frame update
    private void Start()
    {
        Position = StartPosition;
        Magnitude = StartMagnitude;
        GetComponent<Transform>().localPosition = Position;
    }

    // Update is called once per frame
    private void Update()
    {
        Position = GetComponent<Transform>().localPosition;

        if (Magnitude != 0)
        {
            // Resize the particle based on the magnitude
            GetComponent<Transform>().localScale =
                new Vector3(Mathf.Abs(Magnitude * ScaleFactor), Mathf.Abs(Magnitude * ScaleFactor),
                    Mathf.Abs(Magnitude * ScaleFactor));
        }
        else
        {
            GetComponent<Transform>().localScale =
                new Vector3(ScaleFactor, ScaleFactor, ScaleFactor);
        }

        // Change the material corresponding to if the object is selected, and/or positive/negative/neutral.
        if (!Selected)
        {
            if (Magnitude > 0)
            {
                GetComponent<Renderer>().material = PositiveChargeMaterial;
            }
            else if (Magnitude < 0)
            {
                GetComponent<Renderer>().material = NegativeChargeMaterial;
            }
            else
            {
                GetComponent<Renderer>().material = NeutralChargeMaterial;
            }
        }
        else
        {
            if (Magnitude > 0)
            {
                GetComponent<Renderer>().material = SelectedPositiveChargeMaterial;
            }
            else if (Magnitude < 0)
            {
                GetComponent<Renderer>().material = SelectedNegativeChargeMaterial;
            }
            else
            {
                GetComponent<Renderer>().material = SelectedNeutralChargeMaterial;
            }
        }
    }


    public void NudgeX(float amount)
    {
        Position.x += amount;
        GetComponent<Transform>().localPosition = Position;
    }

    public void NudgeY(float amount)
    {
        Position.y += amount;
        GetComponent<Transform>().localPosition = Position;
    }


    public void NudgeZ(float amount)
    {
        Position.z += amount;
        GetComponent<Transform>().localPosition = Position;
    }

    /// <summary>
    /// Select this particle.
    /// </summary>
    public void Select()
    {
        Selected = true;
        GetComponentInChildren<TextMesh>().gameObject.SetActive(true);
    }

    /// <summary>
    /// Select this particle.
    /// </summary>
    public void Unselect()
    {
        Selected = false;
        GetComponentInChildren<TextMesh>().gameObject.SetActive(true);
    }

    /// <summary>
    /// Reset this particle by unselecting it and changing it's magnitude 
    /// </summary>
    public void Reset()
    {
        Unselect();
        Position = StartPosition;
        GetComponent<Transform>().localPosition = Position;
        Magnitude = StartMagnitude;
    }


    public override string ToString()
    {
        return "Charged Particle: " + Position + "     : " + Magnitude;
    }
}