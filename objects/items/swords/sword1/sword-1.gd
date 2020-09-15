extends Spatial

export (PackedScene) var model_pack

var model
var animation


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	model = model_pack.instance()
	add_child(model)
	model.visible = false
	animation = model.get_node("AnimationPlayer")
	animation.connect("animation_finished", self, "anim_finished")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (animation.is_playing()):
		return

	if (Input.is_action_just_pressed("ui_right")):
		model.visible = true
		animation.play("swing-l-r", -1, 1)
	elif (Input.is_action_just_pressed("ui_left")):
		model.visible = true
		animation.play("swing-l-r", -1, -1, true)
	if (Input.is_action_just_pressed("ui_down")):
		model.visible = true
		animation.play("swing-t-d", -1, 1)
	elif (Input.is_action_just_pressed("ui_up")):
		model.visible = true
		animation.play("swing-t-d", -1, -1, true)

func anim_finished(anim_name):
	model.visible = false
