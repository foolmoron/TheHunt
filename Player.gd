class_name Player
extends Camera3D

@export var path: Path3DGenerated
@export var path_follow: PathFollow3D

@export var fog_gradient: Gradient

@export var env: WorldEnvironment

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var size_v := get_viewport().get_visible_rect().size
	var pos_v := get_viewport().get_mouse_position()
	var mouse_x : float = clamp(pos_v.x / size_v.x, 0, 1) * 2 - 1
	var curvature := path.get_curvature_at_perc(path_follow.progress_ratio)

	env.environment.fog_light_color = fog_gradient.sample((curvature + 1) / 2)
