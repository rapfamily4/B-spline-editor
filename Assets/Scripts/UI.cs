using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;


public class UI : MonoBehaviour {
    [Header("UI References")]
    public RectTransform contentRect;
    public NumberDisplay degreeDisplay;
    public NumberDisplay resolutionDisplay;
    public Toggle curveConnectionsButton;
    public TMP_Dropdown knotGenDropdown;
    public Button knotGenButton;
    public RectTransform knotVector;

    [Header("Other References")]
    public KnotDisplay knotDisplayPrefab;
    public Spline spline;

    [Header("Evaluation Extreme Colors")]
    public ColorBlock evaluationExtremeColors;

    private float m_defaultContentHeight;


    private void Start() {
        m_defaultContentHeight = contentRect.rect.height;

        degreeDisplay.SetValue(spline.degree, false);
        degreeDisplay.valueEdited.AddListener((newDegree) => spline.degree = Mathf.FloorToInt(newDegree));
        
        resolutionDisplay.SetValue(spline.resolution, false);
        resolutionDisplay.valueEdited.AddListener((newRes) => spline.resolution = Mathf.FloorToInt(newRes));
        
        curveConnectionsButton.SetIsOnWithoutNotify(false);
        curveConnectionsButton.onValueChanged.AddListener((toggle) => spline.ShowConnectionMarkers(toggle));

        InitKnotVector(spline.GetClonedKnots(), spline.degree);
        spline.knotGenerationFinished.AddListener((knots) => InitKnotVector(knots, spline.degree));
        spline.knotVectorSorted.AddListener((knots) => RefreshKnotVector(knots));

        knotGenDropdown.SetValueWithoutNotify((int)spline.knotsGenerationMode);
        knotGenDropdown.onValueChanged.AddListener((option) => spline.knotsGenerationMode = (Spline.KnotsGenerationMode)option);
        knotGenButton.onClick.AddListener(() => spline.GenerateKnots(true));
    }

    public void InitKnotVector(List<float> knots, int degree) {
        foreach (KnotDisplay display in knotVector.GetComponentsInChildren<KnotDisplay>()) {
            display.knotEdited.RemoveAllListeners();
            Destroy(display.gameObject);
        }

        float displayHeight = ((RectTransform)knotDisplayPrefab.transform).rect.height;
        for (int i = 0; i < knots.Count; i++) {
            KnotDisplay display = Instantiate(knotDisplayPrefab);
            display.knotID = i;
            display.labelText = i.ToString();
            display.transform.SetParent(knotVector, false);
            float posY = -(displayHeight * 0.5f + displayHeight * i);
            display.transform.localPosition = new Vector3(0f, posY, 0f);
            display.SetValue(knots[i], false);
            display.knotEdited.AddListener((id, value) => spline.SetKnot(id, value));
            if (i == degree || i == knots.Count - degree - 1)
                display.SetBackgroundColor(evaluationExtremeColors);
        }
        contentRect.sizeDelta = new Vector2(contentRect.sizeDelta.x, m_defaultContentHeight + knots.Count * displayHeight);
    }

    public void RefreshKnotVector(List<float> knots) {
        int i = 0;
        foreach (KnotDisplay display in knotVector.GetComponentsInChildren<KnotDisplay>()) {
            display.SetValue(knots[i], false);
            i++;
        }
    }
}
