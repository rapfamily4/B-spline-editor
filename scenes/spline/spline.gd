extends Node2D
class_name Spline

signal knot_generation_finished(knots: Array[float])
signal knot_vector_sorted(knots: Array[float])

enum KnotsGenerationMode {
	Unclamped,
	Clamped,
	ClampedAveraged,
}

const CONTROL_POINTS_COUNT: int = 10 # n
# m = n + k = knots.size - 1

@onready var line_renderer: Line2D = $LineRenderer
@onready var control_points_tree: Node2D = $ControlPoints
@onready var knot_markers_tree: Node2D = $KnotMarkers
@onready var control_point_scene: PackedScene = preload("res://scenes/control_point/control_point.tscn")
@onready var knot_marker_scene: PackedScene = preload("res://scenes/knot_marker/knot_marker.tscn")

var spline_degree: int = 2: # k
	set(value):
		assert(value >= 0)
		spline_degree = value
var spline_resolution: int = 96:
	set(value):
		assert(value >= 0)
		spline_resolution = value
var knots: Array[float] # It must be normalized in the interval [0, 1].
var knots_generation_mode: KnotsGenerationMode = KnotsGenerationMode.Unclamped
var show_curve_connection_markers: bool = false:
	set(value):
		knot_markers_tree.visible = value
		show_curve_connection_markers = value
var evaluation_min: float = -INF: # a
	set(value):
		assert(value >= knots[spline_degree])
		evaluation_min = value
var evaluation_max: float = INF: # b
	set(value):
		assert(value <= knots[CONTROL_POINTS_COUNT])
		evaluation_max = value


func _ready():
	show_curve_connection_markers = show_curve_connection_markers
	var window_resolution: Vector2 = get_window().size
	for i: int in range(CONTROL_POINTS_COUNT):
		var new_x: float = lerpf(-window_resolution.x * 0.2, window_resolution.x * 0.2, float(i) / float(CONTROL_POINTS_COUNT - 1))
		var new_y: float = randf_range(-window_resolution.y * 0.075, window_resolution.y * 0.075)
		add_control_point(Vector2(new_x, new_y))
	generate_knots()

func _process(_delta):
	pass

func add_control_point(point_position: Vector2 = Vector2.ZERO) -> void:
	var new_point: Marker2D = control_point_scene.instantiate()
	new_point.position = point_position
	new_point.control_point_moved.connect(update_curve, spline_resolution)
	control_points_tree.add_child(new_point)

func generate_knots() -> void:
	knots.clear()
	for i: int in range(CONTROL_POINTS_COUNT + spline_degree + 1):
		if knots_generation_mode != KnotsGenerationMode.Unclamped:
			if i in range(spline_degree + 1):
				knots.append(0)
			elif i in range(CONTROL_POINTS_COUNT, CONTROL_POINTS_COUNT + spline_degree + 1):
				knots.append(1)
			elif knots_generation_mode == KnotsGenerationMode.ClampedAveraged:
				# De Boor's parameter averaging; parameters are generated on the fly.
				var sum: float = 0
				for j: int in range(i - spline_degree, i):
					sum += float(j) / float(CONTROL_POINTS_COUNT - 1)
				knots.append(sum / float(spline_degree))
			else:
				knots.append(float(i - spline_degree) / float(CONTROL_POINTS_COUNT - spline_degree))
		else:
			knots.append(float(i) / float(CONTROL_POINTS_COUNT + spline_degree))
		print("Generated knot #" + str(i) + ":\t\t" + str(knots[i]))
		
	evaluation_min = knots[spline_degree]
	evaluation_max = knots[CONTROL_POINTS_COUNT]
	print("Set evaluation range:\t[" + str(evaluation_min) + ", " + str(evaluation_max) + "]")
	
	for marker: Marker2D in knot_markers_tree.get_children():
		marker.free()
	for i: int in range(knots.size() - 2 * spline_degree - 2):
		knot_markers_tree.add_child(knot_marker_scene.instantiate())
	
	update_curve()
	knot_generation_finished.emit(knots)

func set_knot(index: int, value: float) -> void:
	knots[index] = value
	knots.sort()
	evaluation_min = knots[spline_degree]
	evaluation_max = knots[CONTROL_POINTS_COUNT]
	knot_vector_sorted.emit(knots)
	update_curve()

func update_curve() -> void:
	line_renderer.clear_points()
	for i: int in range(spline_resolution):
		var evaluation_point: float = lerpf(evaluation_min, evaluation_max, float(i) / float(spline_resolution - 1))
		line_renderer.add_point(evaluate_curve(evaluation_point))
	
	for i: int in range(spline_degree + 1, knots.size() - spline_degree - 1):
		var marker: Marker2D = knot_markers_tree.get_child(i - spline_degree - 1)
		marker.position = evaluate_curve(knots[i])

func evaluate_curve(evaluation_point: float) -> Vector2:
	assert(evaluation_min < evaluation_point or is_equal_approx(evaluation_min, evaluation_point))
	assert(evaluation_point < evaluation_max or is_equal_approx(evaluation_max, evaluation_point))
	for j: int in range(spline_degree, CONTROL_POINTS_COUNT):
		if knots[j] <= evaluation_point and evaluation_point < knots[j + 1]:
			return de_boor_cox(j, spline_degree, evaluation_point)
	return de_boor_cox(CONTROL_POINTS_COUNT - 1, spline_degree, evaluation_point)

func aux(control_point: int, degree: int, evaluation_point: float) -> float:
	if(knots[control_point] < knots[control_point + spline_degree + 1 - degree]):
		return ((evaluation_point - knots[control_point])
				/ (knots[control_point + spline_degree + 1 - degree] - knots[control_point]))
	return 0

func de_boor_cox(control_point: int, degree: int, evaluation_point: float) -> Vector2:
	assert(0 <= control_point and control_point < CONTROL_POINTS_COUNT)
	assert(0 <= degree and degree <= spline_degree)
	if degree == 0:
		return control_points_tree.get_child(control_point).position
	var aux_val: float = aux(control_point, degree, evaluation_point)
	var de_boor0: Vector2 = de_boor_cox(control_point, degree - 1, evaluation_point)
	var de_boor1: Vector2 = de_boor_cox(control_point - 1, degree - 1, evaluation_point)
	return aux_val * de_boor0 + (1 - aux_val) * de_boor1
