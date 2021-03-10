using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// 
/// If put on a button, the size of individual particles in particle system selected will increase by an amount set by an input box. 
/// 
/// @author s28orli
/// @version 1/9/2021
/// 
public class CustomIncrementScaleParticleSystem : CustomIncrementScale
{
    // Start is called before the first frame update
    void Start()
    {
        base.Start();
    }

    // Update is called once per frame
    void Update()
    {
        base.Update();
    }


    public override void increment()
    {
        scaleParticleSystem();
        base.increment();
       
    }

    private void scaleParticleSystem()
    {
        ParticleSystem system = ScalableObject.GetComponent<ParticleSystem>();
        var sz = system.sizeOverLifetime;
        sz.enabled = true;


        ParticleSystem.MinMaxCurve curve = new ParticleSystem.MinMaxCurve();
        curve.mode = ParticleSystemCurveMode.TwoConstants;
        if (sz.size.constantMax + CustomIncrementAmount < Max)
        {
            curve.constantMin = sz.size.constant + CustomIncrementAmount;
            curve.constantMax = sz.size.constantMax + CustomIncrementAmount;
            curve.constant = sz.size.constantMin + CustomIncrementAmount;

        }
        else if(sz.size.constantMin + CustomIncrementAmount > Min)
        {
            curve.constantMin = sz.size.constant + CustomIncrementAmount;
            curve.constantMax = sz.size.constantMax + CustomIncrementAmount;
            curve.constant = sz.size.constantMin + CustomIncrementAmount;

        }

        sz.size = curve;

    }
}