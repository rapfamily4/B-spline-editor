extends Node2D

const SPLINE_DEGREE: int = 3 # k
const CONTROL_POINTS_COUNT: int = 10 # n + 1

@onready var line_renderer: Line2D = $LineRenderer
@onready var control_points_tree: Node2D = $ControlPoints
@onready var control_point_scene: PackedScene = preload("res://scenes/control_point/control_point.tscn")

var knots: Array[float] # The knot vector is normalized in the interval [0, 1].


func _ready():
	# Palcement is not parametrized: it needs refactoring.
	var window_resolution: Vector2 = get_window().size
	for i: int in range(CONTROL_POINTS_COUNT):
		var new_x: float = i * window_resolution.x * 0.1 + window_resolution.x * 0.05
		var new_y: float = randf_range(0, window_resolution.y * 0.3) + window_resolution.y * 0.35
		add_control_point(Vector2(new_x, new_y))
	
	generate_knots(true)
	update_curve()

func _process(_delta):
	pass

func add_control_point(point_position: Vector2 = Vector2.ZERO) -> void:
	var new_point: Marker2D = control_point_scene.instantiate()
	new_point.position = point_position
	control_points_tree.add_child(new_point)

func remove_control_point(point: Marker2D) -> void:
	control_points_tree.remove_child(point)

func generate_knots(clamped: bool = false) -> void:
	for i: int in range(CONTROL_POINTS_COUNT + SPLINE_DEGREE):
		if clamped:
			if i in range(SPLINE_DEGREE):
				knots.append(0)
			elif i in range(CONTROL_POINTS_COUNT, CONTROL_POINTS_COUNT + SPLINE_DEGREE):
				knots.append(1)
			else:
				knots.append(float(i - SPLINE_DEGREE + 1) / float(CONTROL_POINTS_COUNT - SPLINE_DEGREE + 1))
		else:
			knots.append(float(i) / float(CONTROL_POINTS_COUNT + SPLINE_DEGREE - 1))
		
		print("Generated knot #" + str(i) + ":    " + str(knots[i]))

func update_curve(resolution: int = 256) -> void:
	for i: int in range(resolution + 1):
		var evaluation_point: float = lerpf(knots[SPLINE_DEGREE - 1], knots[CONTROL_POINTS_COUNT],
				float(i) / float(resolution))
		line_renderer.add_point(evaluate_curve(evaluation_point))

func evaluate_curve(evaluation_point: float) -> Vector2:
	assert(knots[SPLINE_DEGREE - 1] <= evaluation_point and evaluation_point <= knots[CONTROL_POINTS_COUNT])
	for i: int in range(SPLINE_DEGREE - 1, CONTROL_POINTS_COUNT + SPLINE_DEGREE - 1):
		if knots[i] <= evaluation_point and evaluation_point <= knots[i + 1]:
			return de_boor_cox(i, SPLINE_DEGREE - 1, evaluation_point)
	return Vector2.ZERO

func aux(control_point: int, degree: int, evaluation_point: float) -> float:
	return ((evaluation_point - knots[control_point])
			/ (knots[control_point + SPLINE_DEGREE - degree] - knots[control_point]))

func de_boor_cox(control_point: int, degree: int, evaluation_point: float) -> Vector2:
	assert(0 <= control_point and control_point < CONTROL_POINTS_COUNT)
	assert(0 <= degree and degree <= SPLINE_DEGREE - 1)
	assert(knots[0] <= evaluation_point and evaluation_point <= knots[CONTROL_POINTS_COUNT + SPLINE_DEGREE - 1])
	if degree == 0:
		return control_points_tree.get_child(control_point).position
	var aux_val: float = aux(control_point, degree, evaluation_point)
	var de_boor0: Vector2 = de_boor_cox(control_point - 1, degree - 1, evaluation_point)
	var de_boor1: Vector2 = de_boor_cox(control_point, degree - 1, evaluation_point)
	return (1 - aux_val) * de_boor0 + aux_val * de_boor1
