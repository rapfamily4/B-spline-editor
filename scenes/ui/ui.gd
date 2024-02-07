extends CanvasLayer
class_name UI

@onready var degree_display: NumberDisplay = %DegreeDisplay
@onready var resolution_display: NumberDisplay = %ResolutionDisplay
@onready var eval_min_display: NumberDisplay = %EvalMinDisplay
@onready var eval_max_display: NumberDisplay = %EvalMaxDisplay
@onready var knot_vector: Control = %KnotVector
@onready var knot_gen_dropdown: OptionButton = %KnotGenDropdown
@onready var knot_gen_button: Button = %KnotGenButton
@onready var knot_display_scene: PackedScene = preload("res://scenes/ui/knot_display.tscn")

func update_knot_vector(knots: Array[float], degree: int, eval_min: float, eval_max: float) -> void:
	for knot_display: KnotDisplay in knot_vector.get_children():
		knot_vector.remove_child(knot_display)
	for i: int in range(knots.size()):
		var knot_display: KnotDisplay = knot_display_scene.instantiate()
		knot_display.knot_index = i
		knot_display.startup_label_text = str(i)
		knot_vector.add_child(knot_display)
	update_knot_ranges(degree, knots.size() - degree - 1, eval_min, eval_max)
	refresh_knot_vector(knots)

func update_knot_ranges(degree: int, control_points_count: int, eval_min: float, eval_max: float) -> void:
	for i: int in range(degree + control_points_count + 1):
		var knot_display: KnotDisplay = knot_vector.get_child(i)
		if i <= degree:
			knot_display.set_range_no_signal(-1000, eval_min)
		elif i >= control_points_count:
			knot_display.set_range_no_signal(eval_max, 1000)
		else:
			knot_display.set_range_no_signal(eval_min, eval_max)

func refresh_knot_vector(knots: Array[float]) -> void:
	for i: int in range(knots.size()):
		knot_vector.get_child(i).spin_box.set_value_no_signal(float(knots[i]))
