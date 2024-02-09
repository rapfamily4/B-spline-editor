extends Node2D

@onready var spline: Spline = $Spline
@onready var ui: UI = $UI
@onready var knot_display_scene: PackedScene = preload("res://scenes/ui/knot_display.tscn")


func _ready() -> void:
	ui.degree_display.spin_box.value = spline.spline_degree
	ui.degree_display.value_edited.connect(_on_degree_display_edited)
	
	ui.resolution_display.spin_box.value = spline.spline_resolution
	ui.resolution_display.value_edited.connect(_on_resolution_display_edited)
	
	ui.curve_connections_button.set_pressed_no_signal(spline.show_curve_connection_markers)
	ui.curve_connections_button.toggled.connect(_on_curve_connections_button_toggled)
	
	_init_knot_vector(spline.knots)
	spline.knot_generation_finished.connect(_on_knot_generation_finished)
	spline.knot_vector_sorted.connect(_on_knot_vector_sorted)
	
	ui.knot_gen_dropdown.select(int(spline.knots_generation_mode))
	ui.knot_gen_dropdown.item_selected.connect(_on_knot_gen_dropdown_selected)
	ui.knot_gen_button.pressed.connect(_on_knot_gen_button_pressed)

# Handling signals from Spline.
func _on_knot_generation_finished(knots: Array[float]) -> void:
	_init_knot_vector(knots)

func _on_knot_vector_sorted(knots: Array[float]) -> void:
	ui.refresh_knot_vector(knots)

# Handling signals from UI.
func _on_degree_display_edited(value: float) -> void:
	spline.spline_degree = int(value)
	spline.generate_knots()

func _on_resolution_display_edited(value: float) -> void:
	spline.spline_resolution = int(value)
	spline.update_curve()

func _on_knot_edited(index: int, value: float) -> void:
	spline.set_knot(index, value)

func _on_curve_connections_button_toggled(toggled_on: int) -> void:
	spline.show_curve_connection_markers = toggled_on

func _on_knot_gen_dropdown_selected(value: int) -> void:
	spline.knots_generation_mode = value as Spline.KnotsGenerationMode

func _on_knot_gen_button_pressed() -> void:
	spline.generate_knots()

# Support functions.
func _init_knot_vector(knots: Array[float]) -> void:
	for knot_display: KnotDisplay in ui.knot_vector.get_children():
		knot_display.knot_edited.disconnect(_on_knot_edited)
	ui.init_knot_vector(knots, spline.spline_degree)
	for knot_display: KnotDisplay in ui.knot_vector.get_children():
		knot_display.knot_edited.connect(_on_knot_edited)
