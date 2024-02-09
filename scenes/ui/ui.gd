extends CanvasLayer
class_name UI

@onready var degree_display: NumberDisplay = %DegreeDisplay
@onready var resolution_display: NumberDisplay = %ResolutionDisplay
@onready var knot_vector: Control = %KnotVector
@onready var knot_gen_dropdown: OptionButton = %KnotGenDropdown
@onready var knot_gen_button: Button = %KnotGenButton
@onready var knot_display_scene: PackedScene = preload("res://scenes/ui/knot_display.tscn")

func init_knot_vector(knots: Array[float]) -> void:
	for knot_display: KnotDisplay in knot_vector.get_children():
		knot_vector.remove_child(knot_display)
	for i: int in range(knots.size()):
		var knot_display: KnotDisplay = knot_display_scene.instantiate()
		knot_display.knot_index = i
		knot_display.startup_label_text = str(i)
		knot_vector.add_child(knot_display)
		knot_display.spin_box.set_value_no_signal(float(knots[i]))

func refresh_knot_vector(knots: Array[float]) -> void:
	for i: int in range(knots.size()):
		knot_vector.get_child(i).spin_box.set_value_no_signal(float(knots[i]))
