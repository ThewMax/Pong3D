using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerBorder : MonoBehaviour {
	public ePlayer player;
	public ScoreUI score;
	public ParticleSystem ps;
	public int timer;
	public Ball ball;
	public GameObject cylinder;
	public Transform ballPivot;
	
	// Função que verifica colisão da bola com os gols
	void OnCollisionEnter(Collision col) {
		ball = col.gameObject.GetComponent<Ball>();
		if (ball != null) {
			// Move o sistema de particulas de comemoração do gol e dá play nele
			ps.transform.position = ball.transform.position;
			ps.Play();

			// Dá restart na posição e velocidade da bolinha
			ball.GetComponent<Rigidbody>().constraints = RigidbodyConstraints.FreezeAll;
			ball.transform.position = new Vector3(0f, 1f, 0f);
			ball.GetComponent<Rigidbody>().velocity = new Vector3(0f,0f,0f);	

			// registra score do jogo
			if (player == ePlayer.Left) {
				score.scorePlayerRight++;
			} else if (player == ePlayer.Right) {
				score.scorePlayerLeft++;
			}

			// Cilindro de pausa entre os gols
			cylinder.SetActive(true);
			timer = 3;
			StartCoroutine(Respawn());
		}
	}

	// Rotina que faz o respawn da bolinha com a animação do cilindro
    IEnumerator Respawn() {
		ball.transform.SetParent(ballPivot);
		ball.transform.localPosition = Vector3.zero;
		if(!cylinder.GetComponent<Animation>().IsPlaying("Cylinder Animation")) {
			cylinder.GetComponent<Animation>().Play();
		}
		score.timer = timer.ToString();
        if(timer > 0) {
			score.GetComponent<Animation>().Play();
            timer--;
            yield return new WaitForSeconds(1f);
			score.GetComponent<Animation>().Stop();
            StartCoroutine(Respawn());
        } else {
			score.timer = "GO!!!";
			score.timerSize = 200;
            yield return new WaitForSeconds(1f);
			score.timer = "";
			cylinder.SetActive(false);
			ResetBall();
		}
    }

	// Reinicializa a bola e seus componentes
	public void ResetBall() {	
		cylinder.GetComponent<Animation>().Stop();
		ball.transform.SetParent(null);
		ball.transform.position = new Vector3(0f, 1f, 0f);
		ball.GetComponent<Rigidbody>().constraints = RigidbodyConstraints.None;
		ball.GetComponent<Rigidbody>().constraints = RigidbodyConstraints.FreezePositionY;
		if (player == ePlayer.Left) {
			ball.GetComponent<Rigidbody>().AddForce(ball.initialImpulse, ForceMode.Impulse);
		} else if (player == ePlayer.Right) {
			Vector3 n = ball.initialImpulse;
			n.x *= -1;
			n.y *= -1;
			n.z *= -1;
			ball.GetComponent<Rigidbody>().AddForce(n, ForceMode.Impulse);
		}
	}
}
