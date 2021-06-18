extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (float) var min_time = 60
export (float) var max_time = 90

export (float) var pitch_variance = 1.0

export (AudioStream) var stream
export (float) var loudness_db = -6

export (bool) var disabled = false

var rng = RandomNumberGenerator.new()

var time_until_play


# Called when the node enters the scene tree for the first time.
func _ready():

	$AudioStreamPlayer.stream = stream
	$AudioStreamPlayer.volume_db = loudness_db

	rng.randomize()

	time_until_play = rng.randf_range(0, max_time)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_until_play -= delta
	if (time_until_play <= 0 && !$AudioStreamPlayer.playing && !disabled):
		time_until_play = rng.randf_range(min_time, max_time)
		$AudioStreamPlayer.pitch_scale = rng.randf_range(1 / pitch_variance, pitch_variance)
		$AudioStreamPlayer.play()
