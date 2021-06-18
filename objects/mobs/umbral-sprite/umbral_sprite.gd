extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (float) var min_speak_time = 30
export (float) var max_speak_time = 90
export (Vector3) var spin_variance_speed = Vector3(0.001, 0.002, 0.003)
export var spin_damping = 0.05

var noise = OpenSimplexNoise.new()

var speak_time

var rng = RandomNumberGenerator.new()

var health = 1000

var angry = false

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	var pitch = rng.randf_range(0.8, 1.2)
	$sound.pitch_scale = pitch
	$ambient.pitch_scale = pitch
#	reset_speak_time()
	speak_time = rng.randf_range(0, max_speak_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	speak_time -= delta
	if (speak_time <= 0 && !$sound.playing):
		reset_speak_time()
		$sound.play()

	var spin_x = noise.get_noise_1d(OS.get_ticks_msec() * spin_variance_speed.x) * spin_damping
	var spin_y = noise.get_noise_1d(OS.get_ticks_msec() * spin_variance_speed.y) * spin_damping
	var spin_z = noise.get_noise_1d(OS.get_ticks_msec() * spin_variance_speed.z) * spin_damping
	$umbral_sprite_model.rotate_x(spin_x)
	$umbral_sprite_model.rotate_y(spin_y)
	$umbral_sprite_model.rotate_z(spin_z)

func reset_speak_time():
	speak_time = rng.randf_range(min_speak_time, max_speak_time)

func handle_sword_hit(damage, direction):
	if (direction == 6): # weak to downwards attacks
		damage *= 10
	health -= damage
	if (health <= 0):
		get_parent().remove_child(self)
	if (!angry):
		$Tween.interpolate_property($ambient, "max_db", $ambient.max_db, 6, 1.0, Tween.TRANS_LINEAR)
		$Tween.interpolate_property($ambient, "unit_db", $ambient.unit_db, 24, 1.0, Tween.TRANS_LINEAR)
		$Tween.interpolate_property($ambient, "unit_db", $ambient.unit_db, 24, 1.0, Tween.TRANS_LINEAR)
		$ambient.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
		$Tween.interpolate_property($darkness, "light_energy", $darkness.light_energy, 3.0, 3.0, Tween.TRANS_LINEAR)
		$Tween.interpolate_property($darkness, "omni_range", $darkness.omni_range, 4.5, 3.0, Tween.TRANS_LINEAR)
		$Tween.interpolate_property(self, "spin_damping", spin_damping, 0.15, 1.0, Tween.TRANS_LINEAR)
		$Tween.interpolate_property(self, "translation", self.translation, Vector3(self.translation.x, self.translation.y - .5, self.translation.z), 3.0, Tween.TRANS_LINEAR)
		$Tween.start()

		min_speak_time /= 20.0
		max_speak_time /= 20.0
		$sound.pitch_scale *= 0.8
		speak_time = 0
		$particles.visible = false
		$anger_particles.visible = true
		angry = true
	print(health)
