@tool
class_name Path3DGenerated
extends Path3D

@export var do_generate: bool:
	get:
		return false
	set(_b):
		generate()

@export var meshInstance: MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready():
	generate()

func generate():
	print("hey")
	var points := [Vector3(0, 0, 0)]
	const step := 20
	const segments := 50
	for i in segments:
		points.push_back(Vector3(i * step, randf_range(-3, 3), randf_range(-10, 10)))
	curve.clear_points()
	var tilt := 0.0
	for i in range(1, points.size() - 1):
		curve.add_point(points[i], points[i-1], points[i+1])
		tilt += randf_range(-TAU / 12, TAU / 12)
		curve.set_point_tilt(curve.point_count - 1, tilt)

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var step_mesh := 1
	for d in range(0, step * segments - step_mesh, step_mesh):
		var t1 := curve.sample_baked_with_rotation(d, true, true)
		var t2 := curve.sample_baked_with_rotation(d + step_mesh, true, true)
		
		st.set_uv(Vector2(0, 0))
		st.add_vertex(t2.origin + (t2.basis.x *  -50) + (t2.basis.y * -1.5))
		st.set_uv(Vector2(1, 0))
		st.add_vertex(t1.origin + (t1.basis.x *  50) + (t1.basis.y * -1.5))
		st.set_uv(Vector2(0, 0))
		st.add_vertex(t1.origin + (t1.basis.x *  -50) + (t1.basis.y * -1.5))
		
		st.set_uv(Vector2(1, 0))
		st.add_vertex(t1.origin + (t1.basis.x *  50) + (t1.basis.y * -1.5))
		st.set_uv(Vector2(0, 0))
		st.add_vertex(t2.origin + (t2.basis.x *  -50) + (t2.basis.y * -1.5))
		st.set_uv(Vector2(1, 0))
		st.add_vertex(t2.origin + (t2.basis.x *  50) + (t2.basis.y * -1.5))

	st.generate_normals()
	st.generate_tangents()
	var mesh := st.commit()
	mesh.surface_set_material(0, meshInstance.mesh.surface_get_material(0))
	meshInstance.mesh = mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
