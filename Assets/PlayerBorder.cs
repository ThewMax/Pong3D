using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerBorder : MonoBehaviour {
	public ePlayer player;
	public ScoreUI score;
	public ParticleSystem ps;
	
	void OnCollisionEnter(Collision col) {
		Ball ball = col.gameObject.GetComponent<Ball>();
		if (ball != null) {
			ps.transform.position = ball.transform.position;
			ps.Play();
			ball.transform.position = new Vector3(0f, 1f, 0f);
			ball.GetComponent<Rigidbody>().velocity = new Vector3(0f,0f,0f);
			
			if (player == ePlayer.Left) {
				score.scorePlayerRight++;
				ball.GetComponent<Rigidbody>().AddForce(ball.initialImpulse, ForceMode.Impulse);
			} else if (player == ePlayer.Right) {
				score.scorePlayerLeft++;
				Vector3 n = ball.initialImpulse;
				n.x *= -1;
				n.y *= -1;
				n.z *= -1;
				ball.GetComponent<Rigidbody>().AddForce(n, ForceMode.Impulse);
			}				
		}
	}
}
