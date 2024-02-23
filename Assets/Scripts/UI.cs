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


    private void Start(){
        m_defaultContentHeight = contentRect.rect.height;
        InitKnotVector(spline.GetClonedKnots(), spline.degree);
    }

    public void InitKnotVector(List<float> knots, int degree) {
        foreach (Transform knotDisplay in knotVector.transform)
            Destroy(knotDisplay.gameObject);

        float displayHeight = ((RectTransform)knotDisplayPrefab.transform).rect.height;
        for (int i = 0; i < knots.Count; i++) {
            KnotDisplay display = Instantiate(knotDisplayPrefab);
            display.knotID = i;
            display.labelText = i.ToString();
            display.transform.SetParent(knotVector, false);
            float posY = -(displayHeight * 0.5f + displayHeight * i);
            display.transform.localPosition = new Vector3(0f, posY, 0f);
            display.SetValue(knots[i], false);
            if (i == degree || i == knots.Count - degree - 1)
                display.SetBackgroundColor(evaluationExtremeColors);
        }
        contentRect.sizeDelta = new Vector2(contentRect.sizeDelta.x, m_defaultContentHeight + knots.Count * displayHeight);
    }


/*func refresh_knot_vector(knots: Array[float]) -> void:
	for i: int in range(knots.size()) :

        knot_vector.get_child(i).spin_box.set_value_no_signal(float(knots[i]))*/
}
