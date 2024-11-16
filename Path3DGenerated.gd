@tool
class_name Path3DGenerated
extends Path3D

@export var do_generate: bool:
	get:
		return false
	set(_b):
		generate()

# Called when the node enters the scene tree for the first time.
func _ready():
	generate()

func generate():
	print("hey")
	var points := [Vector3(0, 0, 0)]
	for i in 50:
		points.push_back(Vector3(i * 20, randf_range(-3, 3), randf_range(-10, 10)))
	curve.clear_points()
	var tilt := 0.0
	for i in range(1, points.size() - 1):
		curve.add_point(points[i], points[i-1], points[i+1])
		tilt += randf_range(-TAU / 20, TAU / 20)
		curve.set_point_tilt(curve.point_count - 1, tilt)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
