using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ball : MonoBehaviour {
	public Vector3 initialImpulse;
	
    // Start is called before the first frame update
    void Start() {
        GetComponent<Rigidbody>().AddForce(initialImpulse, ForceMode.Impulse);
    }

    // Update is called once per frame
    void Update() {
    }

    void OnCollisionEnter(Collision col) {
        PlayerBorder p = col.gameObject.GetComponent<PlayerBorder>();
        if (p == null) {
            Vector3 vel = GetComponent<Rigidbody>().velocity;
            float a = 1.1f;
            vel.x *= a;
            vel.y *= a;
            vel.z *= a;
            GetComponent<Rigidbody>().velocity = vel;
        }
    }
}
