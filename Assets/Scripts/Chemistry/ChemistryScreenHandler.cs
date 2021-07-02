using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class ChemistryScreenHandler : MonoBehaviour
{
    private Animator mechanismAnimator;
    private GameObject lastMenuScreen;
    private float animSpeed;
    public void SetMechanismAnimator(Animator mechanismAnimator)
    {
        this.mechanismAnimator = mechanismAnimator;
    }
    public void SetLastMenuScreen(GameObject lastMenuScreen)
    {
        this.lastMenuScreen = lastMenuScreen;
    }
    public void EnableLastMenuScreen()
    {
        lastMenuScreen.SetActive(true);
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