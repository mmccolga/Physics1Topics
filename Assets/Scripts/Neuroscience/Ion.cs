using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

namespace Neuroscience
{
    public class Ion : MonoBehaviour
    {
        private Rigidbody _rigidbody;
        private Vector3 _driftDirection;
        private bool stopped;

        public Vector3 direction;
        public string element;
        public float speed;
        public float speedMovingThroughProtein;
        private bool _movingToPoint;
        
        [HideInInspector]
        public IonInRangeTrigger ionInRangeTrigger;

        private void Start()
        {
            Physics.gravity = Vector3.zero;
            _rigidbody = GetComponent<Rigidbody>();
            ShootInRandomDirection();
            _movingToPoint = false;
        }

        private void FixedUpdate()
        {
            if (_movingToPoint || stopped) return;

            if (_rigidbody.velocity.sqrMagnitude < .01) ShootInRandomDirection();

            _rigidbody.AddForce(_driftDirection * speed, ForceMode.Force);
        }

        private Vector3 GetRandomVector3()
        {
            return new Vector3(Random.Range(-1f, 1f), Random.Range(-1f, 1f), Random.Range(-1f, 1f));
        }

        private void ShootInRandomDirection()
        {
            direction = GetRandomVector3().normalized;
            _rigidbody.AddForce(direction * speed, ForceMode.Impulse);
            _driftDirection = Vector3.Cross(direction, Vector3.up).normalized;
        }

        public IEnumerator MoveToward(Vector3 targetPosition, bool shootAtEnd, OnIonEnter onIonEnter)
        {
            _movingToPoint = true;
            _rigidbody.velocity = Vector3.zero;

            yield return StartCoroutine(LerpCoroutine(targetPosition, shootAtEnd, onIonEnter));

            Debug.Log(IsOtherIonReadyToEnter(onIonEnter));

            _movingToPoint = false;

            if (shootAtEnd == false)
            {
                onIonEnter.ionReadyToEnter = true;
                if (IsOtherIonReadyToEnter(onIonEnter)) StartCoroutine(FireIons(onIonEnter));
                stopped = true;
            }
            else 
            {
                ionInRangeTrigger.waitingForLastIonToFinishExiting = false;
                ShootInRandomDirection();
            }
        }

        private IEnumerator LerpCoroutine(Vector3 targetPosition, bool shootAtEnd, OnIonEnter onIonEnter)
        {
            Vector3 start = transform.position;
            float t = 0f;
            while (t < 1)
            {
                t += Time.deltaTime / speedMovingThroughProtein;
                if (t > 1) t = 1;

                transform.position = Vector3.Lerp(start, targetPosition, t);

                yield return null;
            }
            // Make sure we got there
            transform.position = targetPosition;
        }

        private bool IsOtherIonReadyToEnter(OnIonEnter onIonEnter)
        {
            if (onIonEnter.otherOnIonEnter.queuedIon == null) return false;
            if (onIonEnter.otherOnIonEnter.ionReadyToEnter == false) return false;

            return true;
        }

        private IEnumerator FireIons(OnIonEnter onIonEnter)
        {
            OnIonEnter otherOnIonEnter = onIonEnter.otherOnIonEnter;

            otherOnIonEnter.queuedIon.stopped = false;
            stopped = false;
            onIonEnter.ionReadyToEnter = false;
            otherOnIonEnter.ionReadyToEnter = false;

            float flipSign = 1;

            if (element == "K") flipSign = -1;

            Vector3 otherIonDirection = otherOnIonEnter.transform.position + Vector3.up * -.5f * flipSign;
            StartCoroutine(otherOnIonEnter.queuedIon.MoveToward(otherIonDirection, true, otherOnIonEnter));

            yield return StartCoroutine(this.MoveToward(transform.position + Vector3.up * .5f * flipSign, true, onIonEnter));

            onIonEnter.queuedIon = null;
            otherOnIonEnter.queuedIon = null;
        }
    }
}