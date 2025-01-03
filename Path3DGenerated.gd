@tool
class_name Path3DGenerated
extends Path3D

@export var do_generate: bool:
	get:
		return false
	set(_b):
		generate()

@export var do_clear: bool:
	get:
		return false
	set(_b):
		curve.clear_points()
		for c in tree_parent.get_children():
			tree_parent.remove_child(c)
			c.queue_free()

@export var meshInstance: MeshInstance3D

@export var tree_obj: PackedScene
@export var tree_parent: Node3D

var curvature: Array[float] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	generate()

func generate():
	var points := [Vector3(0, 0, 0)]
	const step := 40
	var segments := 120
	if Engine.is_editor_hint():
		segments = segments / 12
	
	for i in segments:
		points.push_back(Vector3(i * step, randf_range(-6, 6), randf_range(-20, 20)))
	curve.clear_points()
	curvature.clear()
	var tilt := 0.0
	for i in range(1, points.size() - 1):
		var progress := float(i) / points.size()
		var progress_sq := progress * progress
		curve.add_point(points[i], points[i-1], points[i+1])
		var tilt_mult: float = lerp(16, 2, min(1.0, progress_sq * 1.2))
		var tilt_shift := randf_range(-TAU / tilt_mult, TAU / tilt_mult)
		tilt += tilt_shift
		curve.set_point_tilt(curve.point_count - 1, tilt)
		curvature.push_back(tilt_shift)

	for c in tree_parent.get_children():
		tree_parent.remove_child(c)
		c.queue_free()

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var n := 0
	var step_mesh := 1
	for d in range(0, step * segments - step_mesh, step_mesh):
		var t1 := curve.sample_baked_with_rotation(d, true, true)
		var t2 := curve.sample_baked_with_rotation(d + step_mesh, true, true)
		
		st.set_uv(Vector2(0, 0))
		st.add_vertex(t2.origin + (t2.basis.x *  -50) + (t2.basis.y * -3.5))
		st.set_uv(Vector2(1, 0))
		st.add_vertex(t1.origin + (t1.basis.x *  50) + (t1.basis.y * -3.5))
		st.set_uv(Vector2(0, 0))
		st.add_vertex(t1.origin + (t1.basis.x *  -50) + (t1.basis.y * -3.5))

		if not Engine.is_editor_hint():
			if n % 5 == 0 || n % 9 == 0:
				var inst1: Node3D = tree_obj.instantiate()
				tree_parent.add_child(inst1)
				inst1.position = t1.origin + (t1.basis.x * randf_range(-35, -25)) + (t1.basis.z *  randf_range(-4, 4))
				inst1.transform.basis = t1.basis
				var inst2: Node3D = tree_obj.instantiate()
				tree_parent.add_child(inst2)
				inst2.position = t1.origin + (t1.basis.x * randf_range(35, 25)) + (t1.basis.z *  randf_range(-4, 4))
				inst2.transform.basis = t1.basis
			
		st.set_uv(Vector2(1, 0))
		st.add_vertex(t1.origin + (t1.basis.x *  50) + (t1.basis.y * -3.5))
		st.set_uv(Vector2(0, 0))
		st.add_vertex(t2.origin + (t2.basis.x *  -50) + (t2.basis.y * -3.5))
		st.set_uv(Vector2(1, 0))
		st.add_vertex(t2.origin + (t2.basis.x *  50) + (t2.basis.y * -3.5))

		n += 1

	st.generate_normals()
	st.generate_tangents()
	var mesh := st.commit()
	mesh.surface_set_material(0, meshInstance.mesh.surface_get_material(0))
	meshInstance.mesh = mesh

func get_curvature_at_perc(perc: float) -> float:
	var t := clampf(perc, 0.0, 0.9999)
	var i := t * (curvature.size() - 1)
	var i0 := floori(i)
	var i1 := ceili(i)
	var remainder := i - i0;
	return lerp(curvature[i0], curvature[i1], remainder)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
