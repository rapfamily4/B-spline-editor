extends NumberDisplay
class_name KnotDisplay

signal knot_edited(index: int, value: float)

var knot_index: int = -1


func _on_value_changed(value: float) -> void:
	super._on_value_changed(value)
	knot_edited.emit(knot_index, value)
