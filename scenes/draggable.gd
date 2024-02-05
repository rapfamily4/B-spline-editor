extends Node2D
class_name Draggable

signal control_point_moved

## The mouse button to press in order to drag the node around.
@export var button_to_press: MouseButton = MOUSE_BUTTON_LEFT
## If true, the node will then be dragged only if the cursor is over it.
@export var mouse_must_be_over: bool = true
## If true, then the mouse delta will be inverted.
@export var invert_mouse_delta: bool = false

var lifted: bool = false

func _unhandled_input(event):
	if !mouse_must_be_over:
		_input_event(null, event, null)
	if event is InputEventMouseButton and not event.pressed and event.button_index == button_to_press:
		lifted = false
	if lifted and event is InputEventMouseMotion:
		control_point_moved.emit()
		position += -event.relative if invert_mouse_delta else event.relative

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == button_to_press:
		lifted = true
