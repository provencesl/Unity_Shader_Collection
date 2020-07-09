using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using UnityEngine.UI;

public class UIButton : MonoBehaviour {

	// Use this for initialization
	void Start () {

		this.GetComponent<Button>().onClick.AddListener(() => {
			this.GetComponent<Image>().material.SetFloat("_Edge",0.15f);
		});

	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
