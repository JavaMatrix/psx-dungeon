extends Spatial

export (PackedScene) var model_pack

var ACTIVATION_TIME

var horizontal_area : Area
var vertical_area : Area
var downleft_area : Area
var downright_area : Area

var attack_area : Area = null
var delay = 0

var sword
var model
var animation

var active
var distance

var activation_timer = 0

var last_power
var last_direction

var rng = RandomNumberGenerator.new()

func _input(event):
	if event is InputEventMouseMotion:
		if (active):
			distance += event.relative

func _ready():
	sword = model_pack.instance()
	model = sword.get_node("Model")
	add_child(sword)
	model.visible = false
	animation = model.get_node("AnimationPlayer")
	animation.connect("animation_finished", self, "anim_finished")

	horizontal_area = sword.get_node("horizontal_area")
	vertical_area = sword.get_node("vertical_area")
	downleft_area = sword.get_node("downleft_area")
	downright_area = sword.get_node("downright_area")

	distance = Vector2(0, 0)

	ACTIVATION_TIME = sword.activation_time


func _process(delta):
	if (animation.is_playing()):
		return

	if (Input.is_action_just_pressed("sw_activate")):
		activation_timer = ACTIVATION_TIME
		active = true

	activation_timer -= delta

	if (active && (Input.is_action_just_released("sw_activate") || (activation_timer <= 0 && attack_area == null))):
		var power = min(distance.length(), sword.max_power)
		last_power = power
		var angle = int(distance.angle() * 4.0 / PI) + 4
		if (abs(distance.angle()) > 7 * PI / 8.0):
			angle = 0
		last_direction = angle
		if (angle == 0):
			model.visible = true
			animation.play("swing-l-r", -1, -2, true)
			attack_area = horizontal_area
		elif (angle == 1):
			model.visible = true
			animation.play("swing-se", -1, -2, true)
			attack_area = downright_area
		elif (angle == 2):
			model.visible = true
			animation.play("swing-t-d", -1, -2, true)
			attack_area = vertical_area
		elif (angle == 3):
			model.visible = true
			animation.play("swing-sw", -1, -2, true)
			attack_area = downleft_area
		elif (angle == 4):
			model.visible = true
			animation.play("swing-l-r", -1, 2)
			attack_area = horizontal_area
		elif (angle == 5):
			model.visible = true
			animation.play("swing-se", -1, 2)
			attack_area = downright_area
		elif (angle == 6):
			model.visible = true
			animation.play("swing-t-d", -1, 2)
			attack_area = vertical_area
		elif (angle == 7):
			model.visible = true
			animation.play("swing-sw", -1, 2)
			attack_area = downleft_area
		active = false
		distance = Vector2(0, 0)

	delay -= delta
	if (delay < 0 && attack_area != null):
		var overlapped = attack_area.get_overlapping_bodies()
		var clink = false
		var hit = false
		for node in overlapped:
			if (node.is_in_group("monsters")):
				node.handle_sword_hit(sword.damage * last_power, last_direction)
				hit = true
				pass
			else:
				clink = true
				var fpv = 1.2
				$clink.pitch_scale = rng.randf_range(1/fpv, fpv)
				$clink.play()
		if (hit):
			$clink.stop()
		attack_area = null



func anim_finished(anim_name):
	model.visible = false
