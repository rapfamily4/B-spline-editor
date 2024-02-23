using Newtonsoft.Json.Linq;
using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Events;

public class UnityEventFloat : UnityEvent<float> { }

public class NumberDisplay : MonoBehaviour {
    [HideInInspector] public UnityEventFloat valueEdited;

    public string labelText = "";
    public bool roundToIntegers = false;
    public float min = 0f;
    public float max = 100f;

    protected TMP_Text m_label;
    protected TMP_InputField m_inputField;

    protected virtual void Awake() {
        valueEdited = new UnityEventFloat();
        m_label = GetComponentInChildren<TMP_Text>();
        m_inputField = GetComponentInChildren<TMP_InputField>();
    }

    protected void Start() {
        if (m_label != null )
            m_label.text = labelText;
        if (m_inputField != null) {
            if (roundToIntegers)
                m_inputField.contentType = TMP_InputField.ContentType.IntegerNumber;
            else
                m_inputField.contentType = TMP_InputField.ContentType.DecimalNumber;
            m_inputField.onEndEdit.AddListener(HandleValueChanged);
        }
    }

    protected void OnDestroy() {
        if (m_inputField)
            m_inputField.onSubmit.RemoveAllListeners();
    }

    public void SetValue(float value, bool notify) {
        if (roundToIntegers) {
            Debug.LogWarning("Trying to put a float into an int display.");
            return;
        }
        string val = Mathf.Clamp(value, min, max).ToString();
        if (notify)
            m_inputField.text = val;
        else
            m_inputField.SetTextWithoutNotify(val);
    }

    public void SetValue(int value, bool notify) {
        if (!roundToIntegers) {
            Debug.LogWarning("Trying to put an int into a float display.");
            return;
        }
        string val = Mathf.Clamp(value, (int)min, (int)max).ToString();
        if (notify)
            m_inputField.text = val;
        else
            m_inputField.SetTextWithoutNotify(val);
    }

    protected virtual void HandleValueChanged(string text) {
        valueEdited.Invoke(ValidateInput(text));
    }

    protected float ValidateInput(string text) {
        float validated;
        if (string.IsNullOrEmpty(text))
            validated = roundToIntegers ? Mathf.FloorToInt(min) : min;
        else if (roundToIntegers)
            validated = Mathf.Clamp(int.Parse(text), Mathf.FloorToInt(min), Mathf.FloorToInt(max));
        else
            validated = Mathf.Clamp(float.Parse(text), min, max);
        m_inputField.SetTextWithoutNotify(validated.ToString());
        return validated;
    }
}
