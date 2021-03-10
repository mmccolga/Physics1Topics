using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

/// <summary>
/// The class that controls and manages Force calculation and renders force vectors as arrows.
/// </summary>
public class ForceManager : MonoBehaviour
{
    public const float CoulombsConstant = 10f;

    public List<ChargedParticle> Particles;
    internal Vector3 NetForce;
    internal Vector3 Force;

    public int MainParticleIndex;
    public ChargedParticle SelectedParticle;

    public ForceArrowDisplay NetForceArrowRenderer;
    public ForceArrowDisplay ForceArrowRenderer;

    public ChargedParticle MainParticle
    {
        get => Particles[MainParticleIndex];
    }

    // Start is called before the first frame update
    private void Start()
    {
        MainParticleIndex = 0;
        // Deactivate force renderers, so they are not distracting at the start.
        if (ForceArrowRenderer != null)
        {
            ForceArrowRenderer.gameObject.SetActive(false);
        }

        if (NetForceArrowRenderer != null)
        {
            NetForceArrowRenderer.gameObject.SetActive(false);
        }
    }

    // Update is called once per frame
    private void Update()
    {
        // Calculate force between selected particle and main particle 
        if (SelectedParticle != null)
        {
            Force = CalculateForce(Particles[MainParticleIndex], SelectedParticle);
        }
        else
        {
            Force = Vector3.zero;
        }

        // Calculate the net force between the main particle and all the particles
        NetForce = CalculateNetForce(Particles[MainParticleIndex], Particles.ToArray());

        if (NetForceArrowRenderer != null)
        {
            // Render the net force arrow if net force is not zero
            if (NetForce != Vector3.zero)
            {
                NetForceArrowRenderer.Direction = NetForce;
                NetForceArrowRenderer.Position = Particles[MainParticleIndex].Position;
                NetForceArrowRenderer.gameObject.SetActive(true);
            }
            else
            {
                NetForceArrowRenderer.gameObject.SetActive(false);
            }
        }


        if (ForceArrowRenderer != null)
        {
            // Render the selected force arrow if selected force is not zero
            if (Force != Vector3.zero)
            {
                ForceArrowRenderer.Direction = Force;
                ForceArrowRenderer.Position = Particles[MainParticleIndex].Position;
                ForceArrowRenderer.gameObject.SetActive(true);
            }
            else
            {
                ForceArrowRenderer.gameObject.SetActive(false);
            }
        }
    }

    /// <summary>
    /// Calculates the force between two charged particles using Coulombs Law
    /// </summary>
    /// <param name="particle1">First particle</param>
    /// <param name="particle2">Second Particle</param>
    /// <returns>A Vector that represents the force magnitude and direction</returns>
    private Vector3 CalculateForce(ChargedParticle particle1, ChargedParticle particle2)
    {
        if (particle1.Position == particle2.Position && Math.Abs(particle1.Magnitude - particle2.Magnitude) < 0.001f)
        {
            return Vector3.zero;
        }

        float force = CoulombsConstant * ((particle1.Magnitude * particle2.Magnitude) /
                                          Mathf.Pow(Vector3.Distance(particle1.Position, particle2.Position),
                                              2)); // Source: https://en.wikipedia.org/wiki/Coulomb%27s_law

        Vector3 diff = particle2.Position - particle1.Position;
        return -diff * force;
    }

    /// <summary>
    /// Calculate the net force between a single particle and many other particles
    /// </summary>
    /// <param name="particle">First/Main Particle</param>
    /// <param name="particles">An array of particle that are influencing the First/Main particle</param>
    /// <returns>A Vector that represents the force magnitude and direction</returns>
    private Vector3 CalculateNetForce(ChargedParticle particle, params ChargedParticle[] particles)
    {
        if (particles.Length > 1)
        {
            Vector3 netForce = Vector3.zero;
            for (int i = 0; i < particles.Length; i++)
            {
                netForce += CalculateForce(particle, particles[i]);
            }

            return netForce;
        }

        return Vector3.zero;
    }

    /// <summary>
    /// Set the selected particle
    /// </summary>
    /// <param name="newSelectedParticle">The new particle that be the new selected particle</param>
    public void SetSelectedParticle(ChargedParticle newSelectedParticle)
    {
        bool unselect = false;

        foreach (ChargedParticle particle in Particles)
        {
            if (SelectedParticle == newSelectedParticle)
            {
                unselect = true;
                Force = Vector3.zero;
            }

            particle.Unselect();
        }

        if (!unselect)
        {
            SelectedParticle = newSelectedParticle;
            SelectedParticle.Select();
        }
        else
        {
            SelectedParticle = null;
        }
    }

    /// <summary>
    /// Set main particle to next one in the list. If the main particle is already the last one, then it will go to beginning.
    /// </summary>
    public void NextMain(GameObject textGameObject)
    {
        if (gameObject.activeSelf == true)
        {
            TextMeshProUGUI tmp = textGameObject.GetComponent<TextMeshProUGUI>();
            MainParticleIndex++;
            Debug.Log(MainParticleIndex + "before");

            if (MainParticleIndex >= Particles.Count)
            {
                MainParticleIndex = 0;
                tmp.text = "Q1";
            }
            else
            {
                tmp.text = "Q" + (MainParticleIndex + 1).ToString();
            }
            Debug.Log(MainParticleIndex + "after");
        }
    }

    /// <summary>
    /// Change the strength/magnitude of the main particle.
    /// </summary>
    /// <param name="newValue">New magnitude of the main particle</param>
    public void ChangeMainMagnitude(float newValue)
    {
        Particles[MainParticleIndex].Magnitude = newValue;
    }

    /// <summary>
    /// Change the strength/magnitude of the selected particle.
    /// </summary>
    /// <param name="newValue">New magnitude of the selected particle</param>
    public void ChangeSelectedMagnitude(float newValue)
    {
        if (SelectedParticle != null)
            SelectedParticle.Magnitude = newValue;
    }

    public void NudgeMainX(float amount)
    {
        if (Particles[MainParticleIndex] != null)
            Particles[MainParticleIndex].NudgeX(amount);
    }

    public void NudgeMainY(float amount)
    {
        if (Particles[MainParticleIndex] != null)
            Particles[MainParticleIndex].NudgeY(amount);
    }


    public void NudgeMainZ(float amount)
    {
        if (Particles[MainParticleIndex] != null)
            Particles[MainParticleIndex].NudgeZ(amount);
    }

    public void NudgeSelectedX(float amount)
    {
        if (SelectedParticle != null)
        {
            SelectedParticle.NudgeX(amount);
        }
    }

    public void NudgeSelectedY(float amount)
    {
        if (SelectedParticle != null)
        {
            SelectedParticle.NudgeY(amount);
        }
    }


    public void NudgeSelectedZ(float amount)
    {
        if (SelectedParticle != null)
        {
            SelectedParticle.NudgeZ(amount);
        }
    }

    public void SetSelectedNeutral()
    {
        if (SelectedParticle != null)
        {
            SelectedParticle.Magnitude = 0;
        }
    }

    /// <summary>
    /// Reset all of the particles to their default position and magnitude
    /// </summary>
    public void Reset()
    {
        foreach (ChargedParticle particle in Particles)
        {
            particle.Reset();
        }
    }

    private void OnDisable()
    {
        MainParticleIndex = 0;
    }
}