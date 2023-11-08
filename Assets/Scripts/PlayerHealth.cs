using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Doozy.Engine;

public class PlayerHealth : MonoBehaviour
{
    [SerializeField] private int maxHealth = 3;
    [SerializeField] private int currentHealth = 3;

    private void Start() 
    {
        currentHealth = maxHealth;
    }
    
    private void OnCollisionEnter(Collision other) 
    {
        if(other.gameObject.CompareTag("Obstacle"))
        {
            currentHealth--;
            if(currentHealth <= 0)
            {
                GameEventMessage.SendEvent("GameOver");
                gameObject.layer = 0;
            }
        }
    }

    private void OnTriggerEnter(Collider other) 
    {
        if(other.gameObject.CompareTag("Goal"))
        {
            GameEventMessage.SendEvent("LevelCompleted");
            gameObject.layer = 0;
        }
    }
}
