using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.UIElements;
using UnityEngine;

namespace Neuroscience
{
    public class IonInRangeTrigger : MonoBehaviour
    {
        private OnIonEnter _onIonEnter;
        public string elementToReceive;
        public float travelTime;

        private void Start()
        {
            _onIonEnter = GetComponentInChildren<OnIonEnter>();
        }

        private void OnTriggerEnter(Collider other)
        {
            Ion ion = other.gameObject.GetComponent<Ion>();
            if (ion == null) return;

            bool hasQueuedIon = _onIonEnter.queuedIon != null;
            if (hasQueuedIon) return;

            bool ionMatchesProtein = this.elementToReceive == ion.element;
            if (!ionMatchesProtein) return;

            Debug.Log(elementToReceive + " protein queued a(n) " + ion.element + " ion");
            _onIonEnter.queuedIon = ion;
            ion.GetComponent<Renderer>().material.color = Color.green;
            ion.MoveToward(travelTime, transform.position);
        }
    }
}
