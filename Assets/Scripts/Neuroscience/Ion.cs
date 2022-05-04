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
        public Vector3 direction;
        public string element;
        public float speed;

        [HideInInspector]
        public bool movingThroughProtein;

        private bool _movingToPoint;
        private Vector3 _targetPosition;
        private float _inRangeSpeed;

        private void Start()
        {
            Physics.gravity = Vector3.zero;
            _rigidbody = GetComponent<Rigidbody>();
            ShootInRandomDirection();
            _movingToPoint = false;
        }

        private void FixedUpdate()
        {
            if (_movingToPoint)
            {
                MoveToward(_inRangeSpeed, _targetPosition);
                return;
            }
            
            // is _freeFloating
            if (direction == Vector3.zero)
            {
                direction = GetRandomVector3().normalized;
                _rigidbody.AddForce(direction * speed, ForceMode.Impulse);
            }
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

        public void MoveToward(float velocity, Vector3 targetPosition)
        {
            if (!_movingToPoint) // If we were previously free floating we have to reinitialize these variables
            {
                Debug.Log("moving toward " + targetPosition);
                _movingToPoint = true;
                _targetPosition = targetPosition;
                _inRangeSpeed = velocity;
                _rigidbody.velocity = Vector3.zero;
            }
            
            transform.position = Vector3.Lerp(transform.position, targetPosition, velocity);

            if (transform.position != targetPosition) return;
            
            StopMoving();

            if (!movingThroughProtein) return;
            
            _rigidbody.velocity = Vector3.zero;
            transform.position = Vector3.up * speed;
            ShootInRandomDirection();
            var newVelocity = _rigidbody.velocity;
            newVelocity = new Vector3(newVelocity.x, -Mathf.Abs(newVelocity.y), newVelocity.z);
            _rigidbody.velocity = newVelocity;
            movingThroughProtein = false;
        }

        public void StopMoving()
        {
            _rigidbody.velocity = Vector3.zero;
            _movingToPoint = false;
        }
    }
}