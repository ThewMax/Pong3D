using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScoreUI : MonoBehaviour {
	public int scorePlayerLeft = 0;
	public int scorePlayerRight = 0;
	public GUIStyle style;
	public GUIStyle styleTimer;
	public string timer;
	public int timerSize;
	
	void OnGUI() {
		float x = Screen.width / 2f;
		float y = 30f;
		float width = 300f;
		float height = 20f;
		string text = scorePlayerLeft + " x " + scorePlayerRight;
		
		GUI.Label(new Rect(x - (width / 2), y, width, height), text, style);
		GUI.Label(new Rect(x - (width / 2), Screen.height / 2, width, height), timer, styleTimer);
		styleTimer.fontSize = timerSize;
	}
}
