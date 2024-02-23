using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;


public class UnityEventKnot : UnityEvent<int, float> { }

public class KnotDisplay : NumberDisplay {
    [HideInInspector] public UnityEventKnot knotEdited;

    public int knotID = -1;


    public void SetBackgroundColor(ColorBlock colors) {
        m_inputField.colors = colors;
    }

    protected override void Start() {
        base.Start();
        knotEdited = new UnityEventKnot();
    }

    protected override void HandleValueChanged(string text) {
        base.HandleValueChanged(text);
        // I'm validating input twice. This is painful, but if works.
        knotEdited.Invoke(knotID, ValidateInput(text));
    }
}
