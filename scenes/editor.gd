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
	_update_eval_range()
	ui.eval_min_display.value_edited.connect(_on_min_display_edited)
	ui.eval_max_display.value_edited.connect(_on_max_display_edited)
	
	_update_knot_vector(spline.knots)
	spline.knot_generation_finished.connect(_on_knot_generation_finished)
	spline.knot_vector_sorted.connect(_on_knot_vector_sorted)
	
	ui.knot_gen_dropdown.select(int(spline.knots_generation_mode))
	ui.knot_gen_dropdown.item_selected.connect(_on_knot_gen_dropdown_selected)
	ui.knot_gen_button.pressed.connect(_on_knot_gen_button_pressed)

# Handling signals from Spline.
func _on_knot_generation_finished(knots: Array[float], eval_min: float, eval_max: float) -> void:
	_update_knot_vector(knots)
	_update_eval_range()
	ui.eval_min_display.spin_box.set_value_no_signal(eval_min)
	ui.eval_max_display.spin_box.set_value_no_signal(eval_max)

func _on_knot_vector_sorted(knots: Array[float]) -> void:
	ui.refresh_knot_vector(knots)
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
	ui.update_knot_ranges(spline.spline_degree, spline.CONTROL_POINTS_COUNT,
			spline.evaluation_min, spline.evaluation_max)
	_update_eval_range()
	spline.update_curve()

func _on_max_display_edited(value: float) -> void:
	spline.evaluation_max = value
	ui.update_knot_ranges(spline.spline_degree, spline.CONTROL_POINTS_COUNT,
			spline.evaluation_min, spline.evaluation_max)
	_update_eval_range()
	spline.update_curve()

func _on_knot_edited(index: int, value: float) -> void:
	spline.set_knot(index, value)
	spline.update_curve()

func _on_knot_gen_dropdown_selected(value: int) -> void:
	spline.knots_generation_mode = value as Spline.KnotsGenerationMode

func _on_knot_gen_button_pressed() -> void:
	spline.generate_knots()

# Support functions.
func _update_eval_range() -> void:
	ui.eval_min_display.set_range_no_signal(spline.knots[spline.spline_degree], spline.evaluation_max)
	ui.eval_max_display.set_range_no_signal(spline.evaluation_min, spline.knots[spline.CONTROL_POINTS_COUNT])

func _update_knot_vector(knots: Array[float]) -> void:
	for knot_display: KnotDisplay in ui.knot_vector.get_children():
		knot_display.knot_edited.disconnect(_on_knot_edited)
	ui.update_knot_vector(knots, spline.spline_degree, spline.evaluation_min, spline.evaluation_max)
	for knot_display: KnotDisplay in ui.knot_vector.get_children():
		knot_display.knot_edited.connect(_on_knot_edited)
