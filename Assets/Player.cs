using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum ePlayer {
	Left,
	Right
}

public class Player : MonoBehaviour {
	public float speed = 15f;
	public ePlayer player;

    // Update is called once per frame
	// Função que move o player de acordo com a input do teclado
    void Update() {
		float inputSpeed = 0f;
		if (player == ePlayer.Left) {
			inputSpeed = Input.GetAxisRaw("PlayerLeft");
        } else if (player == ePlayer.Right) {
			inputSpeed = Input.GetAxisRaw("PlayerRight");
		}		
		transform.position += new Vector3(0f, 0f, inputSpeed * speed * Time.deltaTime);
    }
}
