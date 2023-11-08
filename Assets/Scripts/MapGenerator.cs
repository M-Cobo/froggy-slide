using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using System.Linq;
using UnityEngine;
using System;

[Serializable]
public class TileTypes
{
    public GameObject[] tiles;
} 

public class MapGenerator : MonoBehaviour
{
    [SerializeField] int mapLength = 5;

    [SerializeField, Range(0.0f, 1.0f)] float densityOfObstacles = 0.75f;

    [SerializeField] GameObject waterPrefab = null;

    [SerializeField] Material[] waterMaterials = new Material[0]; 

    [SerializeField] TileSection[] tileSections = new TileSection[0];

    [SerializeField] TileTypes[] tileTypes = new TileTypes[0];

    [SerializeField] GameObject[] obstacles = new GameObject[0];

    [SerializeField] GameObject invisibleTile = null;

    [SerializeField] GameObject finishLine = null;

    private float[] tileRots = new float[] { 0, 60, 120, 180, 240, 300 };

    private CinemachineSmoothPath smoothPath = null;

    private void Awake() 
    {   
        smoothPath = GameObject.FindGameObjectWithTag("CameraTrack").GetComponent<CinemachineSmoothPath>();
    }

    private void Start() 
    {
        SpawnSections();
        SpawnWater();
        SpawnTiles();
        SpawnObstacles();
    }

    private void SpawnSections()
    {
        // Create section list to calculate waypoints path of camera and add first waypoint

        List<Transform> sectionsList = new List<Transform>();
        sectionsList.Add(transform);


        // Get first section random, spawn it. And get next spawnpoint

        TileSection currentSection = tileSections[UnityEngine.Random.Range(0, tileSections.Length)];

        Transform nextSectionSP = Instantiate(
            currentSection.Prefab,
            transform.position,
            Quaternion.identity
        )
        .transform.Find("SectionSP");
        nextSectionSP.parent.SetParent(transform);


        // Instantiate start section

        Instantiate(
            currentSection.GetStartSection,
            transform.position,
            Quaternion.Euler(0, 180, 0)
        )
        .transform.SetParent(transform);


        // Add second waypoint

        sectionsList.Add(nextSectionSP);


        // Spawn middle sections

        for (int i = 0; i < mapLength; i++)
        {
            currentSection = currentSection.GetCompatibleSection;

            nextSectionSP = Instantiate(
                currentSection.Prefab,
                nextSectionSP.position,
                Quaternion.identity
            )
            .transform.Find("SectionSP");
            nextSectionSP.parent.SetParent(transform);

            // Add middle and final sections waypoints

            sectionsList.Add(nextSectionSP);
        }
        

        // Spawn final section

        Instantiate(currentSection.GetFinalSection, nextSectionSP.position, Quaternion.identity).transform.SetParent(transform);


        // Spawn finish line 

        Instantiate(finishLine, nextSectionSP.position, Quaternion.identity).transform.SetParent(transform);
        

        // Setup waypoints to create the path of the camera

        smoothPath.m_Waypoints = new CinemachineSmoothPath.Waypoint[sectionsList.Count];

        for (int i = 0; i < sectionsList.Count; i++)
        {
            smoothPath.m_Waypoints[i].position = sectionsList[i].position;
        }
    }

    private void SpawnWater()
    {
        // Get water position

        Vector3 waterPos = new Vector3(transform.position.x, transform.position.y + 0.75f, 15 * ((mapLength + 2) / 2));


        // Set type of water material
        
        waterPrefab.GetComponent<MeshRenderer>().material = waterMaterials[UnityEngine.Random.Range(0, waterMaterials.Length)];


        // Spawn water

        Instantiate(
            waterPrefab,
            waterPos,
            Quaternion.identity
        )
        .transform.SetParent(transform);
    }

    private void SpawnTiles()
    {
        // Get invisible tiles spawn points list and spawn tiles

        GameObject[] inivisibleTilesSP = GameObject.FindGameObjectsWithTag("InvisibleTileSP");

        foreach (var spawnPoint in inivisibleTilesSP)
        {
            Instantiate(
                invisibleTile,
                spawnPoint.transform.position,
                Quaternion.Euler(0, tileRots[UnityEngine.Random.Range(0, tileRots.Length)], 0)
            )
            .transform.SetParent(transform);
        }


        // Get tile type list to spawn

        TileTypes type = tileTypes[UnityEngine.Random.Range(0, tileTypes.Length)];


        // Get spawn points list
        
        GameObject[] spawnPoints = GameObject.FindGameObjectsWithTag("TileSP");


        // Spawn tiles

        foreach (var spawnPoint in spawnPoints)
        {
            Instantiate(
                type.tiles[UnityEngine.Random.Range(0, type.tiles.Length)],
                spawnPoint.transform.position,
                Quaternion.Euler(0, tileRots[UnityEngine.Random.Range(0, tileRots.Length)], 0)
            )
            .transform.SetParent(transform);
        }


        // Get spawn points list
        
        GameObject[] dynamicSP = GameObject.FindGameObjectsWithTag("DynamicSP");


        // Spawn random dynamic

        foreach (var spawnPoint in dynamicSP)
        {
            GameObject objToSpawn = UnityEngine.Random.Range(0, 10) < 6 ? 
                type.tiles[UnityEngine.Random.Range(0, type.tiles.Length)] : 
                obstacles[UnityEngine.Random.Range(0, obstacles.Length)];

            Instantiate(
                objToSpawn,
                spawnPoint.transform.position,
                Quaternion.Euler(0, tileRots[UnityEngine.Random.Range(0, tileRots.Length)], 0)
            )
            .transform.SetParent(transform);
        }
    }

    private void SpawnObstacles()
    {
        // Get spawn points list and shuffle
        
        List<GameObject> spawnPoints = GameObject.FindGameObjectsWithTag("ObstacleSP").ToList().Shuffle();


        // Get number of obtacles to spawn

        int nToSpawn = Mathf.RoundToInt(spawnPoints.Count * densityOfObstacles);


        // Spawn obstacles

        for (int i = 0; i < nToSpawn; i++)
        {
            Instantiate(
                obstacles[UnityEngine.Random.Range(0, obstacles.Length)],
                spawnPoints[i].transform.position,
                Quaternion.Euler(0, UnityEngine.Random.Range(0, 180), 0)
            )
            .transform.SetParent(transform);
        }
    }

}
