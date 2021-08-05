using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem.LowLevel;

public class ChemistryScreenHandler : MonoBehaviour
{
    public Animator mechanismAnimator;
    public GameObject lastMechanism;
    public GameObject lastMenuScreen;
    private float _currentAnimSpeed = 0;

    private void Start() { }

    public void SetMechanismAnimator(Animator newMechanismAnimator)
    {
        if (_currentAnimSpeed != 0)
            mechanismAnimator.speed = _currentAnimSpeed;

        mechanismAnimator = newMechanismAnimator;
        _currentAnimSpeed = newMechanismAnimator.speed;
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
        mechanismAnimator.speed = _currentAnimSpeed;
    }

    public void Pause()
    {
        mechanismAnimator.speed = 0;
    }
}