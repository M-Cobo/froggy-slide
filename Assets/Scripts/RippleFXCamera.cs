using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RippleFXCamera : MonoBehaviour
{
	public LayerMask layerMask;
	public int texSize = 1024;
	public float rippleDist = 20.0f;
	public Transform rippleTarget = null;
	
    private Camera rippleCam;
	private RenderTexture targetTex;

    void Awake() {
		CreateTexture();
		CreateCamera();

  		Shader.SetGlobalTexture("_RippleRT", targetTex);
  		Shader.SetGlobalFloat("_OrthographicCamSize", rippleDist);
	}

	void CreateTexture() {
		targetTex = new RenderTexture(texSize, texSize, 0, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear);
		targetTex.useMipMap = true;
		targetTex.Create();
	}

	void CreateCamera() {
		rippleCam = this.gameObject.AddComponent<UnityEngine.Camera>(); // add a camera to this game object
		rippleCam.renderingPath = RenderingPath.Forward; // simple forward render path
		rippleCam.transform.rotation = Quaternion.Euler(90, 0, 0); // rotate the camera to face down
		rippleCam.orthographic = true; // the camera needs to be orthographic
		rippleCam.orthographicSize = rippleDist; // the area size that ripples can occupy
		rippleCam.nearClipPlane = 1.0f; // near clip plane doesn't have to be super small
		rippleCam.farClipPlane = 100.0f; // generous far clip plane
		rippleCam.depth = -10; // make this camera render before everything else
		rippleCam.targetTexture = targetTex; // set the target to the render texture we created
		rippleCam.cullingMask = layerMask; // only render the "Ripples" layer
		rippleCam.clearFlags = CameraClearFlags.SolidColor; // clear the texture to a solid color each frame
		rippleCam.backgroundColor = Color.clear; // the ripples are rendered as overlay so clear to grey
		rippleCam.enabled = true;
	}	

	void LateUpdate() {

		if (rippleTarget != null) {
			this.transform.position = new Vector3(rippleTarget.position.x, 50.0f, rippleTarget.position.z);
        	this.transform.rotation = Quaternion.Euler(90, 0, 0);
		}
		
		Shader.SetGlobalVector("_CamPosition", transform.position);
	}
}