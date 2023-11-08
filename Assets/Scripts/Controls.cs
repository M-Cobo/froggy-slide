using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Controls : MonoBehaviour
{
    [Header("Raycast Variables")]
    public LayerMask waterLayer;
    public LayerMask movablesLayer;
    private Ray camRay;
    private RaycastHit raycastHit;

    [Header("Wave Variables")]
	public float force;
	public float radius;
    private float distance;
    public float maxSpeed;
    [SerializeField] ParticleSystem waveEffect = null;

    private bool firstTouch = true;

    private void Update() 
    {
        if(Input.GetMouseButton(0))
        {
            camRay = Camera.main.ScreenPointToRay(Input.mousePosition);

            if(Physics.Raycast(camRay, out raycastHit, Mathf.Infinity, waterLayer))
            {
                WaveExplotion();
            }
        }

        if(Input.GetMouseButtonUp(0)) {
            if(!firstTouch){
                firstTouch = true;
            }
        }
    }

    private void WaveExplotion()
    {
        waveEffect.transform.position = raycastHit.point;

        if(firstTouch) {
            waveEffect.Play();
            firstTouch = false;
        }

        Collider[] movableObjects = Physics.OverlapSphere(raycastHit.point, radius, movablesLayer);

        foreach (Collider movableObject in movableObjects)
        {
            distance = ExtensionMethods.ReMap(Vector3.Distance(raycastHit.point, movableObject.transform.position), 0f, radius * 2f, 1f, 0f);
            Rigidbody rb = movableObject.GetComponent<Rigidbody>();

            if(rb != null)
            {
                rb.AddExplosionForce(force * distance, raycastHit.point, radius);
                if(rb.velocity.magnitude > maxSpeed)
                {
                    rb.velocity = Vector3.ClampMagnitude(rb.velocity, maxSpeed);
                    rb.angularVelocity = Vector3.ClampMagnitude(rb.angularVelocity, maxSpeed);
                }
            }
        }
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(raycastHit.point, radius);
        Gizmos.DrawRay(camRay);
    }
}
