extends TextEdit
tool

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var player = get_parent().get_node("mobs/player")
onready var player_body = get_parent().get_node("mobs/player/KinematicBody")
onready var player_env = get_parent().get_node("mobs/player/WorldEnvironment")

var speed_enabled = false
var fast_enabled = false
var boing_enabled = false
var explore_enabled = false

var bright_store = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	grab_focus()
	pass # Replace with function body.

func _on_cheatcodes_text_changed():
	if (text.ends_with("dfcclip")):
		toggle_noclip()
	elif (text.ends_with("dfcmoon")):
		toggle_moon_jump()
	elif (text.ends_with("dfcspeed")):
		toggle_speed()
	elif (text.ends_with("dfcfast")):
		toggle_fast()
	elif (text.ends_with("dfcboing")):
		toggle_boing()
	elif (text.ends_with("dfcexplore") ||
			(explore_enabled && text.ends_with("~"))):
		explore_enabled = !explore_enabled
		toggle_noclip()
		toggle_moon_jump()
		toggle_speed()
		toggle_fog()
		toggle_bright()
		toggle_boing()
	elif (text.ends_with("dfcreset")):
		get_tree().reload_current_scene()
	elif (text.ends_with("dfcfog")):
		toggle_fog()
	elif (text.ends_with("dfcbright")):
		toggle_bright()

func toggle_noclip():
	if (player_body.collision_layer == 1):
		player_body.collision_layer = 2
		player_body.collision_mask = 2
	else:
		player_body.collision_layer = 1
		player_body.collision_mask = 1

func toggle_moon_jump():
	player.moon_jump = !player.moon_jump

func toggle_speed():
	if (speed_enabled):
		player.move_speed /= 10.0
		player.sprint_speed /= 10.0
	else:
		player.move_speed *= 10.0
		player.sprint_speed *= 10.0

	speed_enabled = !speed_enabled

func toggle_fast():
	if (fast_enabled):
		player.move_speed /= 2.0
		player.sprint_speed /= 2.0
	else:
		player.move_speed *= 2.0
		player.sprint_speed *= 2.0

	fast_enabled = !fast_enabled

func toggle_boing():
	if (boing_enabled):
		player.jump_power /= 4.0
	else:
		player.jump_power *= 4.0

	boing_enabled = !boing_enabled

func toggle_fog():
	player_env.environment.fog_enabled = !player_env.environment.fog_enabled

func toggle_bright():
	var t = bright_store
	bright_store = player_env.environment.ambient_light_energy
	player_env.environment.ambient_light_energy = t
