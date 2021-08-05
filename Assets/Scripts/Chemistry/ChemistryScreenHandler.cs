using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class ChemistryScreenHandler : MonoBehaviour
{
    public Animator mechanismAnimator;
    public GameObject lastMechanism;
    public GameObject lastMenuScreen;
    private float animSpeed;

    public void SetMechanismAnimator(Animator mechanismAnimator)
    {
        this.mechanismAnimator = mechanismAnimator;
    }

    public void SetLastMenuScreen(GameObject lastMenuScreen)
    {
        this.lastMenuScreen = lastMenuScreen;
    }

    public void SetLastMechanism(GameObject lastMechanism)
    {
        this.lastMechanism = lastMechanism;
    }

    public void EnableLastMenuScreen()
    {
        lastMenuScreen.SetActive(true);
    }

    public void DisableLastMechanism()
    {
        lastMechanism.SetActive(false);
    }

    public void Play()
    {
        mechanismAnimator.speed = animSpeed;
    }

    public void Pause()
    {
        animSpeed = mechanismAnimator.speed;
        mechanismAnimator.speed = 0;
    }
}