extends NumberDisplay
class_name KnotDisplay

signal knot_edited(index: int, value: float)

var _knot_index: int = -1


func set_knot_index(index: int) -> void:
	_knot_index = index
	
func _on_value_changed(value: float) -> void:
	super._on_value_changed(value)
	knot_edited.emit(_knot_index, value)
