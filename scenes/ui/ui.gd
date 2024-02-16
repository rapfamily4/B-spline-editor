extends CanvasLayer
class_name UI

onready var degree_display: NumberDisplay = $"%DegreeDisplay"
onready var resolution_display: NumberDisplay = $"%ResolutionDisplay"
onready var curve_connections_button: CheckButton = $"%CurveConnectionsButton"
onready var knot_gen_dropdown: OptionButton = $"%KnotGenDropdown"
onready var knot_gen_button: Button = $"%KnotGenButton"
onready var knot_vector: Control = $"%KnotVector"
onready var knot_display_scene: PackedScene = preload("res://scenes/ui/knot_display.tscn")

export var evaluation_extreme_color: Color = Color(0, 1, 1)

func _ready():
	knot_gen_dropdown.add_item("Unclamped", 0)
	knot_gen_dropdown.add_item("Clamped", 1)
	knot_gen_dropdown.add_item("Clamped (averaged)", 2)
	knot_gen_dropdown.select(0)

func init_knot_vector(knots: Array, degree: int) -> void:
	for knot_display in knot_vector.get_children():
		knot_vector.remove_child(knot_display)
	for i in range(knots.size()):
		var knot_display: KnotDisplay = knot_display_scene.instance()
		knot_display.knot_index = i
		knot_display.startup_label_text = str(i)
		knot_vector.add_child(knot_display)
		knot_display.set_value_no_signal(float(knots[i]))
		if i == degree or i == knots.size() - degree - 1:
			knot_display.modulate = evaluation_extreme_color

func refresh_knot_vector(knots: Array) -> void:
	for i in range(knots.size()):
		knot_vector.get_child(i).set_value_no_signal(float(knots[i]))
