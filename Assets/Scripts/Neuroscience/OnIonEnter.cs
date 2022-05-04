using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Neuroscience
{
    public class OnIonEnter : MonoBehaviour
    {
        [HideInInspector]
        public Ion queuedIon;
        public OnIonEnter otherOnIonEnter;
        
        public int yDirection; // 1 or -1
        public float velocityTowardEntrance;

        private bool _ionStopped = false;
        
        private void OnTriggerEnter(Collider other)
        {
            Ion ion = other.gameObject.GetComponent<Ion>();
            if (ion == null) return;

            if (queuedIon != ion) return;
            queuedIon.GetComponent<Renderer>().material.color = Color.white;

            _ionStopped = true;
            ion.StopMoving();

            if (otherOnIonEnter.queuedIon == null) return;
            if (!otherOnIonEnter._ionStopped) return;

            _ionStopped = false;

            otherOnIonEnter.queuedIon.movingThroughProtein = true;
            Vector3 otherIonDirection = otherOnIonEnter.transform.position + Vector3.up * -.5f * yDirection;
            otherOnIonEnter.queuedIon.MoveToward(velocityTowardEntrance, otherIonDirection);

            ion.movingThroughProtein = true;
            ion.MoveToward(velocityTowardEntrance, transform.position + Vector3.up * .5f * yDirection);
            
            queuedIon = null;
            otherOnIonEnter.queuedIon = null;
        }
    }
}