using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "Tiles/Section")]
public class TileSection : ScriptableObject
{
    [SerializeField] GameObject prefab = null;
    public GameObject Prefab { get { return prefab; } }

    [SerializeField] GameObject[] startSections = new GameObject[0];
    public GameObject GetStartSection { get { return startSections[Random.Range(0, startSections.Length)]; } }

    [SerializeField] TileSection[] compaticleSections = new TileSection[0];
    public TileSection GetCompatibleSection { get { return compaticleSections[Random.Range(0, compaticleSections.Length)]; } }

    [SerializeField] GameObject[] finalSections = new GameObject[0];
    public GameObject GetFinalSection { get { return finalSections[Random.Range(0, finalSections.Length)]; } }
}
