using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

/**
 * Description: This script makes the metal ring with the blue energy move based on the intensity of the 
 * magnetic fields. The merge cube has a platform with the magnetic fields extruding from it.
 * As the metal ring gets closer towards the middle of the platform, the ring moves faster.
 * 
 * @author Nevno48
 * @version August 30 2018
 * 
 **/
public class interactiveAnimations : MonoBehaviour {

    //public allows objects to be dragged in the GUI
    //ring object has animation attached to it
     public GameObject ring;

    //different levels of objects speed of animation is reacting to
    public GameObject speed1;
    public GameObject speed2;
    public GameObject speed3;
    public GameObject speed4;


    /**
     * Description: This method starts at the beginning of the execution of the app. 
     * The ring is set to an animation(either one, because it doesn't matter) and the speed is set to 0.
     * 
     * @param none
     * 
     **/
    private void Start()
    {
        this.gameObject.GetComponent<Animator>().Play("interactiveRingClockwise");
        this.gameObject.GetComponent<Animator>().speed = 0.0f;
    }


    /**
     * Description: This method starts when the ring touches another object. If statements separate the collision
     * between different objects. When the ring comes in contact with the field lines, the ring should turn 
     * different speeds.
     * 
     * @param Collider col   This is the object that the ring is colliding with.
     * 
     **/
    private void OnTriggerEnter(Collider col)
    {

        this.gameObject.GetComponent<Animator>().Play("interactiveRingClockwise");
        if (col.gameObject.name.Equals(speed1.gameObject.name))
        {
            this.gameObject.GetComponent<Animator>().speed = 2.0f;
            this.gameObject.GetComponent<Animator>().SetFloat("Direction", 1);
        }
        else if(col.gameObject.name.Equals(speed2.gameObject.name))
        {
            this.gameObject.GetComponent<Animator>().speed = 3.0f;
            this.gameObject.GetComponent<Animator>().SetFloat("Direction", 1);
        }
        else if(col.gameObject.name.Equals(speed3.gameObject.name))
        {
            this.gameObject.GetComponent<Animator>().speed = 5.0f;
            this.gameObject.GetComponent<Animator>().SetFloat("Direction", 1);
        }
        else if(col.gameObject.name.Equals(speed4.gameObject.name))
        {
            this.gameObject.GetComponent<Animator>().speed = 10.0f;
            this.gameObject.GetComponent<Animator>().SetFloat("Direction", 1);
        }
        else
        {
            this.gameObject.GetComponent<Animator>().speed = 0.0f;
        }
        
    }

    /**
     * Description: This method starts when the ring exits another object. If statements separate the collision
     * between different objects. When the ring leaves field rings, the ring should turn 
     * different speeds.
     * 
     * @param Collider col   This is the object that the ring is colliding with.
     * 
     **/
    private void OnTriggerExit(Collider col)
    {

        this.gameObject.GetComponent<Animator>().Play("interactiveRingClockwise");
        if (col.gameObject.name.Equals(speed1.gameObject.name))
        {
            this.gameObject.GetComponent<Animator>().speed = 0.0f;
        }
        else if(col.gameObject.name.Equals(speed2.gameObject.name))
        {
            this.gameObject.GetComponent<Animator>().speed = 2.0f;
            this.gameObject.GetComponent<Animator>().SetFloat("Direction", -1);
        }
        else if(col.gameObject.name.Equals(speed3.gameObject.name))
        {
            this.gameObject.GetComponent<Animator>().speed = 3.0f;
            this.gameObject.GetComponent<Animator>().SetFloat("Direction", -1);
        }
        else if(col.gameObject.name.Equals(speed4.gameObject.name))
        {
            this.gameObject.GetComponent<Animator>().speed = 5.0f;
            this.gameObject.GetComponent<Animator>().SetFloat("Direction", -1);
        }
        

    }
}
