extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	OS.window_borderless = true
#	OS.set_window_maximized(true)
	OS.window_fullscreen = true
	var current_size = OS.get_window_size()
	var ratio = current_size.x / current_size.y
	$ViewportContainer.set_size(Vector2(240 * ratio, 240))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("debug_toggle_fs")):
		OS.window_fullscreen = !OS.window_fullscreen
