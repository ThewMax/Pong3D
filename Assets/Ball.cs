using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ball : MonoBehaviour {
	public Vector3 initialImpulse;
    public bool isPlaying = true;
    public ParticleSystem imp;
	
    // Start is called before the first frame update
    void Start() {
        GetComponent<Rigidbody>().AddForce(initialImpulse, ForceMode.Impulse);
    }

    // Update is called once per frame
    void Update() {
        Vector3 vel = GetComponent<Rigidbody>().velocity;
        vel *= -1;
        float magni = vel.magnitude / 8;
        Vector3 origvel = Vector3.Normalize(vel);
        float toSumDegr = 0;
        if (vel.x < 0 & vel.z < 0) {
            toSumDegr = 180;
            vel.x *= -1;
            vel.z *= -1;
        }
        else if (vel.z < 0){
            toSumDegr = 90;
            vel = new Vector3(-vel.z,0f,vel.x);
        } else if (vel.x < 0) {
            toSumDegr = 270;
            vel = new Vector3(vel.z,0f,-vel.x);
        }
        float cossi = vel.z / Mathf.Sqrt(Mathf.Pow(vel.x, 2f) + Mathf.Pow(vel.z, 2f));
        float degr = toSumDegr + (Mathf.Rad2Deg * Mathf.Acos(cossi));
        Transform cone = transform.GetChild(0);
        cone.localPosition = origvel * magni;
        cone.localScale = new Vector3(cone.localScale.x, cone.localScale.y, magni * 100);
        cone.rotation = Quaternion.Euler(0f, degr, 0f);
    }

    void OnCollisionEnter(Collision col) {
        if(isPlaying) {
            PlayerBorder p = col.gameObject.GetComponent<PlayerBorder>();
            if (p == null) {
                imp.transform.position = transform.position;
                imp.Play();
                Vector3 vel = GetComponent<Rigidbody>().velocity;
                float a = 1.05f;
                vel.x *= a;
                vel.y *= a;
                vel.z *= a;
                GetComponent<Rigidbody>().velocity = vel;
            }
        }
    }
}
