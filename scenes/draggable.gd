extends Node2D
class_name Draggable

signal control_point_moved

enum InputState {
	Nothing,
	Primary,
	Secondary
}

@export_category("Draggable")
@export_group("Commands")
## The mouse button to press in order to drag the node around.
@export var button_to_press: MouseButton = MOUSE_BUTTON_LEFT
@export_subgroup("Modifier Combo")
## Whether the secondary command combination is allowed or not.
@export var allow_modifier_combo: bool = false
## The mouse button to press, while keeping the modifier key pressed, in order to drag the node around.
@export var button_to_press_with_modifier: MouseButton = MOUSE_BUTTON_LEFT
## The modifier key necessary to use the secondary combination of commands.
@export var modifier_key: Key = KEY_CTRL
@export_group("Behaviour")
## If true, the node will then be dragged only if the cursor is over it.
@export var mouse_must_be_over: bool = true
## If true, then the mouse delta will be inverted.
@export var invert_mouse_delta: bool = false

var _lifted: bool = false
var _input_state: InputState = InputState.Nothing

func _unhandled_input(event):
	if !mouse_must_be_over:
		_input_event(null, event, null)
	if _check_input(event, false):
		_lifted = false
	if _lifted and event is InputEventMouseMotion:
		control_point_moved.emit()
		position += -event.relative if invert_mouse_delta else event.relative

func _input_event(_viewport, event, _shape_idx):
	if _check_input(event, true):
		_lifted = true

func _check_input(event: InputEvent, check_pressed: bool) -> bool:
	if not (event is InputEventMouseButton and (event.pressed == check_pressed)):
		return false
		
	if event.button_index == button_to_press and _input_state != InputState.Secondary:
		_input_state = InputState.Primary if check_pressed else InputState.Nothing
		return true
	
	if allow_modifier_combo and _input_state != InputState.Primary:
		if check_pressed and not Input.is_key_pressed(modifier_key):
			return false
		if event.button_index == button_to_press_with_modifier:
			_input_state = InputState.Secondary if check_pressed else InputState.Nothing
			return true
	
	return false
