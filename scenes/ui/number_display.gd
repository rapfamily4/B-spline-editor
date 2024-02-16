extends HBoxContainer
class_name NumberDisplay

signal value_edited(value)

export var startup_label_text: String = ""
export var round_to_integers: bool = false
export var startup_min: float = 0
export var startup_max: float = 100

onready var label: Label = $Label
onready var spin_box: SpinBox = $SpinBox

var _emit_value_edited: bool = true


func _ready() -> void:
	label.text = startup_label_text
	spin_box.connect("value_changed", self, "_on_value_changed")
	if round_to_integers:
		spin_box.step = 1
		spin_box.rounded = true
	spin_box.min_value = startup_min
	spin_box.max_value = startup_max

func set_value_no_signal(value: float) -> void:
	_emit_value_edited = false
	spin_box.value = value
	_emit_value_edited = true

func set_range_no_signal(min_value: float, max_value: float) -> void:
	_emit_value_edited = false
	spin_box.min_value = min_value
	spin_box.max_value = max_value
	_emit_value_edited = true

func _on_value_changed(value: float) -> void:
	if _emit_value_edited:
		emit_signal("value_edited", value)
