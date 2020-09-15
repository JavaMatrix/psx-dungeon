extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var noise = OpenSimplexNoise.new()
export (float, 0, 16) var average_energy = 0.1
export (float, 0, 16) var flicker_depth = 0.07
export (float, .01, 1) var flicker_speed = 0.1
export (bool) var debug_disable_light = false
export (Color) var light_color = Color(242.0 / 255.0, 138.0 / 255.0, 53.0 / 255.0)



# Called when the node enters the scene tree for the first time.
func _ready():
	$OmniLight.light_color = light_color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	var noise_val = noise.get_noise_1d(OS.get_ticks_msec() * flicker_speed)
	$OmniLight.light_energy = average_energy + noise_val * flicker_depth
	if (debug_disable_light):
		$OmniLight.light_energy = 0
