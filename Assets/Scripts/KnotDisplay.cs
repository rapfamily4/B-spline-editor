using UnityEngine;
using UnityEngine.Events;


public class UnityEventKnot : UnityEvent<int, float> { }

public class KnotDisplay : NumberDisplay {
    [HideInInspector] public UnityEventKnot knotEdited;

    public int knotID = -1;

    protected override void Awake() {
        base.Awake();
        knotEdited = new UnityEventKnot();
    }

    protected override void HandleValueChanged(string text) {
        base.HandleValueChanged(text);
        // I'm validating input twice. This is painful, but if works.
        knotEdited.Invoke(knotID, ValidateInput(text));
    }
}
