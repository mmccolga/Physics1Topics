using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

/// 
/// If put on a button, the size of the object selected will increase by an amount set by an input box. 
/// 
/// @author Nevno48
/// @version 6/1/19 - 6/3/19
/// 
public class CustomIncrementScale : MonoBehaviour
{
    //object to increase scale
    public GameObject ScalableObject;
    //amount to increment scale; if positive, will increment by customIncrementAmount; if negative will decrease by customIncrementAmount;
    public float CustomIncrementAmount;
    //default max and min values, can be adjusted with input field
    public float Max = 2;
    public float Min = 0;

    /**
     * This activates at the start of the program and sets the minimum to prevent the 
     * min from being a negative value.
     */
    public void Start()
    {
        if (Min == 0)
        {
            Min -= CustomIncrementAmount;
        }
    }
	
	// Update is called once per frame
    public virtual void Update()
    {

    }
	
	
    /**
    * Every frame, sets the size of the variable to the increment unless max or min is
    * the size of the object.
    */
    public virtual void increment()
    {
        //if increment isn't negative
        if(CustomIncrementAmount > 0)
        {
            //if the size isn't the max
            if (ScalableObject.transform.localScale.x < Max && ScalableObject.transform.localScale.y < Max && ScalableObject.transform.localScale.z < Max)
            {
                ScalableObject.transform.localScale += new Vector3(CustomIncrementAmount, CustomIncrementAmount, CustomIncrementAmount);
            }
            //if the size is the max
            if (ScalableObject.transform.localScale.x == Max && ScalableObject.transform.localScale.y == Max && ScalableObject.transform.localScale.z == Max)
            {
                ScalableObject.transform.localScale += new Vector3((CustomIncrementAmount * -1), (CustomIncrementAmount * -1), (CustomIncrementAmount * -1));
            }
        }
        //if increment is negative
        if (CustomIncrementAmount < 0)
        {
            //if the size isn't the min
            if (ScalableObject.transform.localScale.x > Min && ScalableObject.transform.localScale.y > Min && ScalableObject.transform.localScale.z > Min)
            {
                ScalableObject.transform.localScale += new Vector3(CustomIncrementAmount, CustomIncrementAmount, CustomIncrementAmount);
            }
            //if the size is the min
            if (ScalableObject.transform.localScale.x == Min && ScalableObject.transform.localScale.y == Min && ScalableObject.transform.localScale.z == Min)
            {
                ScalableObject.transform.localScale += new Vector3((CustomIncrementAmount * -1), (CustomIncrementAmount * -1), (CustomIncrementAmount * -1));
            }
        }

    }
}
