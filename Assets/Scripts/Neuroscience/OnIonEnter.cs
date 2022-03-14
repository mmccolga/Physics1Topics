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
            if (!ion) return;

            if (queuedIon != ion) return;

            if (!otherOnIonEnter._ionStopped)
            {
                ion.StopMoving();
                _ionStopped = true;
                return;
            }
            
            ion.StopMoving();

            otherOnIonEnter.queuedIon.movingThroughProtein = true;
            otherOnIonEnter.queuedIon.MoveToward(velocityTowardEntrance, 
                otherOnIonEnter.transform.position + Vector3.up * -2 * yDirection);
            ion.movingThroughProtein = true;
            ion.MoveToward(velocityTowardEntrance, transform.position + Vector3.up * 2 * yDirection);
            
            queuedIon = null;
            otherOnIonEnter.queuedIon = null;
        }
    }
}