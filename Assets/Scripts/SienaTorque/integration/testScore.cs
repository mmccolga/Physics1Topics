using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TMPro;

/**
 * Description: This adds up the total amount of correct objects and assigns
 * score to a value.
 * 
 * @author Nevno48
 * @version 6/21/19
 */
public class testScore : MonoBehaviour
{

    //array of objects to click on for increasing score by 1(1 part questions)
    public GameObject[] correctObjects1;
    //array of objects to click on for increasing score by .5(2 part questions)
    public GameObject[] correctObjects2;
    //array of objects to click on for increasing score by .33(3 part questions)
    public GameObject[] correctObjects3;
    //array of objects to click on for increasing score by .25(4 part questions)
    public GameObject[] correctObjects4;



    //object to set the score to
    public GameObject scoreKeeper;

    //total score after click on correct object
    public double totalScore;
    
    //this makes sure the code activates only once
    private bool checkOnce = true;

    /**
     * Description:This checks the correct objects to determing the score value
     */
    public void checkCorrect()
    {
        //makes sure it checks once when called
        if (checkOnce == true)
        {
            //makes sure score isn't larger than the amount of correct objects
            if (totalScore < ((correctObjects1.Length * 1) + (correctObjects2.Length * .5) + (correctObjects3.Length * .33) + (correctObjects4.Length * .25)))
            {
                //adds all 1 part questions
                for (int index = 0; index < correctObjects1.Length; index++)
                {
                    if (correctObjects1[index].gameObject.activeSelf == true)
                    {
                        totalScore += 1;
                    }
                }

                //adds all 2 part questions
                for (int index = 0; index < correctObjects2.Length; index++)
                {
                    if (correctObjects2[index].gameObject.activeSelf == true)
                    {
                        totalScore += .5;
                    }
                }

                //adds all 3 part questions
                for (int index = 0; index < correctObjects3.Length; index++)
                {
                    if (correctObjects3[index].gameObject.activeSelf == true)
                    {
                        totalScore += .33;
                    }
                }

                //adds all 4 part questions
                for (int index = 0; index < correctObjects4.Length; index++)
                {
                    if (correctObjects4[index].gameObject.activeSelf == true)
                    {
                        totalScore += .25;
                    }
                }
                //assigns text of scoreKeeper to score value
                scoreKeeper.GetComponent<TextMeshProUGUI>().text = "Your score is: " + totalScore;
            }
            checkOnce = false;
        }
        
    }

    /**
     * Description: this resets the score value
     * 
     * @param totalScore   The new value the score is set to
     */
    public void resetScore(int totalScore)
    {
        this.totalScore = totalScore;
        checkOnce = true;
    }

}
