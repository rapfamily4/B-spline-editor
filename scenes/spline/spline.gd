extends Node2D

const SPLINE_DEGREE: int = 2
const STARTING_CONTROL_POINTS_COUNT: int = 10

@onready var line_renderer: Line2D = $LineRenderer
@onready var control_points_tree: Node2D = $ControlPoints
@onready var control_point_scene: PackedScene = preload("res://scenes/control_point/control_point.tscn")

var knots: Array[float] # The knot vector is normalized in the interval [0, 1].


func _ready():
	# Palcement is not parametrized: it needs refactoring.
	var window_resolution: Vector2 = get_window().size
	for i in range(STARTING_CONTROL_POINTS_COUNT):
		var new_x: float = i * window_resolution.x * 0.1 + window_resolution.x * 0.05
		var new_y: float = randf_range(0, window_resolution.y * 0.3) + window_resolution.y * 0.35
		add_control_point(Vector2(new_x, new_y))
	
	for i in range(STARTING_CONTROL_POINTS_COUNT + SPLINE_DEGREE + 1):
		if i in range(SPLINE_DEGREE):
			knots.append(0)
		elif i in range(STARTING_CONTROL_POINTS_COUNT + 1, STARTING_CONTROL_POINTS_COUNT + SPLINE_DEGREE + 1):
			knots.append(1)
		else:
			knots.append(float(i - SPLINE_DEGREE + 1) / float(STARTING_CONTROL_POINTS_COUNT - SPLINE_DEGREE + 3))
		print("Knot #" + str(i) + ":    " + str(knots[i]))
	
	update_curve()

func _process(_delta):
	pass

func add_control_point(point_position: Vector2 = Vector2.ZERO) -> void:
	var new_point: Marker2D = control_point_scene.instantiate()
	new_point.position = point_position
	control_points_tree.add_child(new_point)

func remove_control_point(point: Marker2D) -> void:
	control_points_tree.remove_child(point)

func update_curve() -> void:
	pass
