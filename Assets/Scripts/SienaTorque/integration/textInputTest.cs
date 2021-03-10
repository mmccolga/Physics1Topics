using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TMPro;
using UnityEngine.UI;

/**
 * Description: This checks an input field object to determine if it
 * is correct or not. This is based on a test template.
 * 
 * @author Nevno48
 * @version 6/21/19
 */
public class textInputTest : MonoBehaviour
{
    //object to turn on that corresponds to question 
    public GameObject scoreObject;

    //object that has input
    public GameObject checkInputObject;

    //result object to appear when right
    public GameObject correctObject;

    //result object to appear when wrong
    public GameObject wrongObject;

    //put placeholder here(inside textInput)
    private GameObject placeHolderObject;

    //Text for inputField
    private GameObject inputFieldText;

    //String that needs to match user input
    public string correctText;
    public GameObject correctTextObject;

    //String for if user didn't put anything
    public string emptyText;

    //amount of tries the user gets
    public float totalTries = 3;

    //submit button active or decactive
    public Button submitButton;

    /**
     * Description: This resets the total score
     * 
     * @param newTotalTries   this is the new value of the score
     */
    public void setTotalTries(float newTotalTries)
    {
        totalTries = newTotalTries;
    }

    /**
     * Description:This preps the correct object for a comparison to the input
     * value and sets the children objects.
     */
    public void Start()
    {
        correctText = correctText.ToUpper();
        checkInputObject = this.gameObject;
        //This is because when you play the program, an inputText object is inserted, so the
        //object is actually 1 more than what you want
        placeHolderObject = this.transform.GetChild(0).GetChild(1).gameObject;
        inputFieldText = this.transform.GetChild(0).GetChild(2).gameObject;
    }
    /**
      * Description: This sets the object right or wrong based on the input.
      * If the input is blank, the score doesn't change and the hint is changed.
      * 
      */
    public void checkInput()
    {
        //ensures the tries aren't infinite
        if (totalTries > 0)
        {
            //preps input to compare with correct text
            string inputWord = checkInputObject.GetComponent<TMP_InputField>().text;
            inputWord = inputWord.ToUpper();
            //if the input is the same as the correct
            if (inputWord.Equals(correctText))
            {

                scoreObject.SetActive(true);
                correctObject.SetActive(true);
                wrongObject.SetActive(false);
                submitButton.interactable = false;
                correctTextObject.SetActive(true);
            }
            //if the input is empty
            else if (inputWord.Trim().Equals(""))
            {
                wrongObject.SetActive(false);
                correctObject.SetActive(false);
                placeHolderObject.GetComponent<TextMeshProUGUI>().text = emptyText;
                totalTries++;
            }
            //if the input is wrong
            else
            {
                correctObject.SetActive(false);
                wrongObject.SetActive(true);
                placeHolderObject.GetComponent<TextMeshProUGUI>().text = ("Tries left: " + (totalTries - 1));
            }
            totalTries--;
            //if the input is wrong
            if (totalTries == 0)
            {
                submitButton.interactable = false;
                correctTextObject.SetActive(true);
            }
        }
    }


}
