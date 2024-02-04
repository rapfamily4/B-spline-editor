extends Marker2D
class_name Draggable

signal control_point_moved

var lifted: bool = false

func _unhandled_input(event):
	if event is InputEventMouseButton and not event.pressed:
		lifted = false
	if lifted and event is InputEventMouseMotion:
		control_point_moved.emit()
		position += event.relative

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		lifted = true
