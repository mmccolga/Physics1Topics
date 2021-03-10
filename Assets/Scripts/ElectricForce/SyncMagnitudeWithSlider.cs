using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.UI;

class SyncMagnitudeWithSlider : MonoBehaviour
{
    public Slider TargetSlider;
    public ChargedParticle Particle;

    private void Update()
    {
        if (TargetSlider != null)
        {
            if (Particle != null && Particle.Selected)
            {
                TargetSlider.value = Particle.Magnitude;
            }
        }
    }
}