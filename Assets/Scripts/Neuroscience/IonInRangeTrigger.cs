using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.UIElements;
using UnityEngine;

namespace Neuroscience
{
    public class IonInRangeTrigger : MonoBehaviour
    {
        [HideInInspector]
        public OnIonEnter _onIonEnter;
        public string elementToReceive;

        public float speedMovingToProtein;

        [HideInInspector]
        public bool waitingForLastIonToFinishExiting;

        private void Start()
        {
            _onIonEnter = GetComponentInChildren<OnIonEnter>();
        }

        private void OnTriggerEnter(Collider other)
        {
            if (waitingForLastIonToFinishExiting) return;

            Ion ion = other.gameObject.GetComponent<Ion>();
            if (ion == null) return;

            bool hasQueuedIon = _onIonEnter.queuedIon != null;
            if (hasQueuedIon) return;

            bool ionMatchesProtein = this.elementToReceive == ion.element;
            if (!ionMatchesProtein) return;

            _onIonEnter.queuedIon = ion;
            ion.ionInRangeTrigger = this;
            waitingForLastIonToFinishExiting = true;
            StartCoroutine(ion.MoveToward(speedMovingToProtein, transform.position, false, _onIonEnter));
        }
    }
}
