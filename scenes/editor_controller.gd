extends Node2D

@onready var spline: Spline = $Spline
@onready var ui: UI = $UI
@onready var knot_display_scene: PackedScene = preload("res://scenes/ui/knot_display.tscn")


func _ready() -> void:
	ui.degree_display.spin_box.value = spline.spline_degree
	ui.degree_display.value_edited.connect(_on_degree_display_edited)
	
	ui.resolution_display.spin_box.value = spline.spline_resolution
	ui.resolution_display.value_edited.connect(_on_resolution_display_edited)
	
	ui.eval_min_display.spin_box.value = spline.evaluation_min
	ui.eval_max_display.spin_box.value = spline.evaluation_max
	ui.eval_min_display.value_edited.connect(_on_min_display_edited)
	ui.eval_max_display.value_edited.connect(_on_max_display_edited)
	spline.evaluation_min_changed.connect(_on_evaluation_min_changed)
	spline.evaluation_max_changed.connect(_on_evaluation_max_changed)

# Handling signals from Spline.
func _on_evaluation_min_changed(value: float) -> void:
	ui.eval_min_display.spin_box.set_value_no_signal(value)
	_update_eval_range()

func _on_evaluation_max_changed(value: float) -> void:
	ui.eval_max_display.spin_box.set_value_no_signal(value)
	_update_eval_range()

# Handling signals from UI.
func _on_degree_display_edited(value: float) -> void:
	spline.spline_degree = int(value)
	spline.generate_knots()
	spline.update_curve()

func _on_resolution_display_edited(value: float) -> void:
	spline.spline_resolution = int(value)
	spline.update_curve()

func _on_min_display_edited(value: float) -> void:
	spline.evaluation_min = value
	spline.update_curve()
	_update_eval_range()

func _on_max_display_edited(value: float) -> void:
	spline.evaluation_max = value
	spline.update_curve()
	_update_eval_range()

# Support functions.
func _update_eval_range() -> void:
	ui.eval_min_display.spin_box.min_value = spline.knots[spline.spline_degree]
	ui.eval_min_display.spin_box.max_value = spline.evaluation_max
	ui.eval_max_display.spin_box.min_value = spline.evaluation_min
	ui.eval_max_display.spin_box.max_value = spline.knots[spline.CONTROL_POINTS_COUNT]
