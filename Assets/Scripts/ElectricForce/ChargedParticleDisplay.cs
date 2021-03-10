using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ChargedParticleDisplay : MonoBehaviour
{
    [SerializeField] public GameObject ForceManager;

    [SerializeField] public DisplayStat StatToDisplay;

    public enum DisplayStat
    {
        Magnitude,
        Force,
        NetForce
    }

    // Update is called once per frame
    private void Update()
    {
        if (ForceManager != null)
        {
            ForceManager manager = ForceManager.GetComponent<ForceManager>();
            Text text = GetComponent<Text>();
            if (StatToDisplay == DisplayStat.Magnitude)
            {
                if (manager.SelectedParticle != null)
                {
                    text.text = "Magnitude: " + manager.SelectedParticle.Magnitude;
                }
            }
            else if (StatToDisplay == DisplayStat.Force)
                text.text = "Force: " + decimal.Round((decimal) manager.Force.magnitude, 3);
            else if (StatToDisplay == DisplayStat.NetForce)
                text.text = "Net Force: " + decimal.Round((decimal) manager.NetForce.magnitude, 3);
        }
    }
}