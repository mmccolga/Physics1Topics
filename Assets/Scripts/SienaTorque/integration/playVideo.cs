using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Video;

/**
 * Description: When put on a GUI image, will allow a video to play on the
 * canvas.
 * 
 * @author Nevno48
 * @version 6/21/19
 * 
 */
public class playVideo : MonoBehaviour
{
    //current image object
    public RawImage rawImage;
    //video player object
    public VideoPlayer videoPlayer;
    //audio player object
    public AudioSource audioSource;

    /**
     * Description: This executes at the start of when the program is played. 
     * This starts the video immediately.
     * 
     */
    private void Update()
    {
        StartCoroutine(PlayVideo());
    }
    /**
     * Description:This is a method that makes the video and audio play.
     * 
     */
    IEnumerator PlayVideo()
    {
        videoPlayer.Prepare();
        WaitForSeconds waitForSeconds = new WaitForSeconds(1);
        while (!videoPlayer.isPrepared)
        {
            yield return waitForSeconds;
            break;
        }
        rawImage.texture = videoPlayer.texture;
        videoPlayer.Play();
        audioSource.Play();
    }
}
