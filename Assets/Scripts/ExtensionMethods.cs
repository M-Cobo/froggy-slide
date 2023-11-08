using System.Collections.Generic;
using UnityEngine;

public static class ExtensionMethods {
    public static float ReMap(this float value, float fromMin, float fromMax, float toMin, float toMax) {
        return (value - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin;
    }

    public static List<GameObject> Shuffle(this List<GameObject> value)
    {
        for (int i = 0; i < value.Count - 1; i++)
        {
            GameObject tempGO = null;
            int rnd = UnityEngine.Random.Range(i, value.Count);

            tempGO = value[rnd];
            value[rnd] = value[i];
            value[i] = tempGO;
        }
        
        return value;
    }
}
