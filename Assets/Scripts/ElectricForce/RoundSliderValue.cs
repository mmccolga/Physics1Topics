using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.UI; 


    class RoundSliderValue : MonoBehaviour
    {
        public float RoundValue;

        void Update()
        {
            if (RoundValue == 0)
                return;

            RoundValue = Math.Abs(RoundValue);

            GetComponent<Slider>().value = (int)Math.Round(GetComponent<Slider>().value / RoundValue) * RoundValue;
        }
    }
