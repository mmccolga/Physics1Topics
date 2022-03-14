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
            if (_onIonEnter.queuedIon != null) return;
            
            Ion ion = other.gameObject.GetComponent<Ion>();
            if (ion == null) return;

            if (this.elementToReceive != ion.element) return;

            Debug.Log(elementToReceive + " protein queued a(n) " + ion.element + " ion");
            _onIonEnter.queuedIon = ion;
            ion.MoveToward(travelTime, transform.position);
        }
    }
}
