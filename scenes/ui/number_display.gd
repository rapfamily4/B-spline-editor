extends HBoxContainer
class_name NumberDisplay

signal value_edited(value: float)

@export var startup_label_text: String = ""
@export var round_to_integers: bool = false
@export var startup_min: float = 0
@export var startup_max: float = 100

@onready var label: Label = $Label
@onready var spin_box: SpinBox = $SpinBox


func _ready() -> void:
	label.text = startup_label_text
	spin_box.value_changed.connect(_on_value_changed)
	if round_to_integers:
		spin_box.step = 1
		spin_box.rounded = true
	spin_box.min_value = startup_min
	spin_box.max_value = startup_max
	
func _on_value_changed(value: float) -> void:
	value_edited.emit(value)
