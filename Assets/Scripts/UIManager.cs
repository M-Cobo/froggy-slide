using Doozy.Engine.Progress;
using Doozy.Engine;
using UnityEngine;
using DG.Tweening;
using TMPro;

public class UIManager : MonoBehaviour
{
    [SerializeField] Progressor levelProgressor = null;
    [SerializeField] TextMeshProUGUI barLevelText = null;
    [SerializeField] TextMeshProUGUI endLevelText = null;
    private Transform player = null;
    private Transform goal = null;

    private void Start() 
    {
        string sLevel = PlayerPrefs.GetInt("CurrentLevel", 1).ToString();
        barLevelText.SetText(sLevel);
        endLevelText.SetText(sLevel);

        player = GameObject.FindGameObjectWithTag("Player").transform;
        goal = GameObject.FindGameObjectWithTag("Goal").transform;
        levelProgressor.SetMax(Mathf.Abs(player.position.z - goal.position.z));

    }

    private void Update() 
    {

        if(levelProgressor.Value > 0.5f){
            levelProgressor.SetValue(Mathf.Abs(player.position.z - goal.position.z));
        } else {
            levelProgressor.SetValue(0);
        }
    }

    /*public void StartPlaying()
    {
        TinySauce.OnGameStarted(levelNumber: PlayerPrefs.GetInt("CurrentLevel").ToString());
    }*/
}
