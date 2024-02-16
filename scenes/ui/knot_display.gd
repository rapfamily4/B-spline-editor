extends NumberDisplay
class_name KnotDisplay

signal knot_edited(index, value)

var knot_index: int = -1


func _on_value_changed(value: float) -> void:
	._on_value_changed(value)
	if _emit_value_edited:
		emit_signal("knot_edited", knot_index, value)
