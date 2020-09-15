extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (float) var min_speak_time = 5
export (float) var max_speak_time = 30
export (Vector3) var spin_speed = Vector3(0.5, 1, 2)

var speak_time

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var pitch = rng.randf_range(0.8, 1.2)
	$sound.pitch_scale = pitch
	$ambient.pitch_scale = pitch
	reset_speak_time()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	speak_time -= delta
	print(speak_time)
	if (speak_time <= 0 && !$sound.playing):
		reset_speak_time()
		$sound.play()

	$umbral_sprite_model.rotate_x(spin_speed.x)
	$umbral_sprite_model.rotate_y(spin_speed.y)
	$umbral_sprite_model.rotate_z(spin_speed.z)

func reset_speak_time():
	speak_time = rng.randf_range(min_speak_time, max_speak_time)
