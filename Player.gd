class_name Player
extends Camera3D


@export_range(0, 1) var speed: float

@export var path: Path3DGenerated
@export var path_follow: PathFollow3D
@export var anim: AnimationPlayer
@export var audio: AudioStreamPlayer
@export var music: AudioStreamPlayer
@export var end_label: Label
var end_tmpl: String

@export var env: WorldEnvironment

@export var fog_gradient: Gradient
@export var curvature_to_vel_x: Curve
@export var mouse_x_to_vel_x: Curve
@export var pos_x_to_accel_z: Curve
@export var speed_z_to_anim_speed: Curve
@export var speed_z_to_audio_pitch: Curve
@export var speed_z_to_music_pitch: Curve

var secs := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	end_tmpl = end_label.text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()
		return

	secs += delta

	var size_v := get_viewport().get_visible_rect().size
	var pos_v := get_viewport().get_mouse_position()
	var mouse_x := clampf(pos_v.x / size_v.x, 0, 1) * 2 - 1
	var curvature := path.get_curvature_at_perc(path_follow.progress_ratio)

	var vel_x := curvature_to_vel_x.sample(absf(curvature) / PI) * signf(curvature) * -300 * sqrt(anim.speed_scale)
	vel_x += mouse_x_to_vel_x.sample(absf(mouse_x)) * signf(mouse_x) * 500 * sqrt(anim.speed_scale)

	position.x = clampf(position.x + vel_x * delta, -25, 25)
	
	var accel_z := pos_x_to_accel_z.sample(absf(position.x) / 25) * 0.2
	speed = clampf(speed + accel_z * delta, 0, 1)

	var anim_speed := speed_z_to_anim_speed.sample(speed) * 0.4
	anim.speed_scale = anim_speed

	audio.pitch_scale = speed_z_to_audio_pitch.sample(speed)
	music.pitch_scale = speed_z_to_music_pitch.sample(speed)

	env.environment.fog_light_color = fog_gradient.sample(speed)

func finish():
	const file := "user://default.save"
	var best := secs
	if FileAccess.file_exists(file):
		var read_file = FileAccess.open(file, FileAccess.READ)
		best = float(read_file.get_line())
	best = min(secs, best)
	var write_file = FileAccess.open(file, FileAccess.WRITE)
	write_file.store_line(str(best))

	end_label.text = end_tmpl.replace("%SECS%", "%.2f" % secs).replace("%BEST%", "%.2f" % best)
	