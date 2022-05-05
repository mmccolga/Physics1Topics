using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Neuroscience
{
    public class OnIonEnter : MonoBehaviour
    {
        public OnIonEnter otherOnIonEnter;
        public int yDirection; // 1 or -1
        public float travelTime;

        [HideInInspector]
        public bool ionReadyToEnter = false;
        
        [HideInInspector]
        public Ion queuedIon;
    }
}