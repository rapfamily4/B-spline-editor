using System.Collections;
using System.Collections.Generic;
using UnityEngine.Events;
using UnityEngine;

public class Draggable : MonoBehaviour {
    [HideInInspector] public UnityEvent wasMoved;

    private enum InputState {
        Nothing,
        Primary,
        Secondary,
    }

    [Header("Commands")]
    //The mouse button to press in order to drag the node around.
    [Range(0, 2)] public int buttonToPress = 0;
    [Header("Modifier Combo")]
    // Whether the secondary command combination is allowed or not.
    public bool allowModifierCombo = false;
    // The mouse button to press, while keeping the modifier key pressed, in order to drag the node around.
    [Range(0, 2)] public int buttonToPressWithModifier = 0;
    // The modifier key necessary to use the secondary combination of commands.
    public KeyCode modifierKey = KeyCode.LeftControl;
    [Header("Behaviour")]
    // If true, the node will then be dragged only if the cursor is over it.
    public bool mouseMustBeOver = true;
    // If true, then the mouse delta will be inverted.
    public bool invertMouseDelta = false;

    private InputState m_input_state = InputState.Nothing;
    private Vector3 m_lastMousePosition = Vector3.zero;


    private void Awake() {
        if (wasMoved == null)
            wasMoved = new UnityEvent();
    }

    private void OnMouseOver() {
        if (m_input_state != InputState.Nothing || !mouseMustBeOver)
            return;
        CheckPressed();
    }

    private void Update() {
        if (m_input_state == InputState.Nothing && !mouseMustBeOver)
            CheckPressed();
        if (m_input_state != InputState.Nothing && !CheckReleased()) {
            Vector3 newMousePosition = Camera.main.ScreenToViewportPoint(Input.mousePosition);
            newMousePosition.x *= Camera.main.orthographicSize * Camera.main.aspect * 2;
            newMousePosition.y *= Camera.main.orthographicSize * 2;
            newMousePosition.z = transform.position.z;
            Vector3 mouseDelta = newMousePosition - m_lastMousePosition;
            m_lastMousePosition = newMousePosition;
            transform.Translate(mouseDelta * (invertMouseDelta ? -1 : 1));
            if (mouseDelta.sqrMagnitude > 0)
                wasMoved.Invoke();
        }
    }

    private bool CheckPressed() {
        bool is_pressed = false;
        if (Input.GetMouseButton(buttonToPress)) {
            m_input_state = InputState.Primary;
            is_pressed = true;
        } else if (allowModifierCombo && Input.GetMouseButton(buttonToPressWithModifier) && Input.GetKey(modifierKey)) {
            m_input_state = InputState.Secondary;
            is_pressed = true;
        }
        if (is_pressed) {
            m_lastMousePosition = Camera.main.ScreenToViewportPoint(Input.mousePosition);
            m_lastMousePosition.x *= Camera.main.orthographicSize * Camera.main.aspect * 2;
            m_lastMousePosition.y *= Camera.main.orthographicSize * 2;
            m_lastMousePosition.z = transform.position.z;
        }

        return is_pressed;
    }

    private bool CheckReleased() {
        if ((m_input_state == InputState.Primary && !Input.GetMouseButton(buttonToPress))
        || (m_input_state == InputState.Secondary && !Input.GetMouseButton(buttonToPressWithModifier))) {
            m_input_state = InputState.Nothing;
            return true;
        }

        return false;
    }
}
