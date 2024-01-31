extends Node2D

const SPLINE_DEGREE: int = 2 # k
const STARTING_CONTROL_POINTS_COUNT: int = 10 # n + 1

@onready var line_renderer: Line2D = $LineRenderer
@onready var control_points_tree: Node2D = $ControlPoints
@onready var control_point_scene: PackedScene = preload("res://scenes/control_point/control_point.tscn")

var knots: Array[float] # The knot vector is normalized in the interval [0, 1].


func _ready():
	# Palcement is not parametrized: it needs refactoring.
	var window_resolution: Vector2 = get_window().size
	for i: int in range(STARTING_CONTROL_POINTS_COUNT):
		var new_x: float = i * window_resolution.x * 0.1 + window_resolution.x * 0.05
		var new_y: float = randf_range(0, window_resolution.y * 0.3) + window_resolution.y * 0.35
		add_control_point(Vector2(new_x, new_y))
	
	generate_knots(true)
	update_curve(1024)

func _process(_delta):
	pass

func add_control_point(point_position: Vector2 = Vector2.ZERO) -> void:
	var new_point: Marker2D = control_point_scene.instantiate()
	new_point.position = point_position
	control_points_tree.add_child(new_point)

func remove_control_point(point: Marker2D) -> void:
	control_points_tree.remove_child(point)

func generate_knots(clamped: bool = false) -> void:
	for i: int in range(STARTING_CONTROL_POINTS_COUNT + SPLINE_DEGREE):
		if clamped:
			if i in range(SPLINE_DEGREE):
				knots.append(0)
			elif i in range(STARTING_CONTROL_POINTS_COUNT, STARTING_CONTROL_POINTS_COUNT + SPLINE_DEGREE):
				knots.append(1)
			else:
				knots.append(float(i - SPLINE_DEGREE + 1) / float(STARTING_CONTROL_POINTS_COUNT - SPLINE_DEGREE + 1))
		else:
			knots.append(float(i) / float(STARTING_CONTROL_POINTS_COUNT + SPLINE_DEGREE - 1))
		
		print("Generated knot #" + str(i) + ":    " + str(knots[i]))

func update_curve(resolution: int = 128) -> void:
	for i: int in range(resolution + 1):
		line_renderer.add_point(evaluate_curve(float(i) / float(resolution)))

func evaluate_curve(evaluation_point: float) -> Vector2:
	var spline_point: Vector2 = Vector2.ZERO
	var blend_value: float
	for i: int in range(STARTING_CONTROL_POINTS_COUNT):
		blend_value = _blend(i, SPLINE_DEGREE, evaluation_point)
		spline_point += blend_value * control_points_tree.get_child(i).position
	return spline_point

func _aux0(control_point: int, degree: int, evaluation: float) -> float:
	var to_return: float = (evaluation - knots[control_point]) / (knots[control_point + degree - 1] - knots[control_point])
	return to_return

func _aux1(control_point: int, degree: int, evaluation: float) -> float:
	var to_return: float = (knots[control_point + degree] - evaluation) / (knots[control_point + degree] - knots[control_point + 1])
	return to_return

func _blend(control_point: int, degree: int, evaluation: float) -> float:
	var result: float
	if degree == 1:
		result = 1 if (knots[control_point] <= evaluation) and (evaluation < knots[control_point + 1]) else 0
		return result
	var aux0: float = _aux0(control_point, degree, evaluation)
	var aux1: float = _aux1(control_point, degree, evaluation)
	var blend0: float = _blend(control_point, degree - 1, evaluation)
	var blend1: float = _blend(control_point + 1, degree - 1, evaluation)
	result = aux0 * blend0 + aux1 * blend1
	return result
