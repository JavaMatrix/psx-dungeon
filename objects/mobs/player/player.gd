extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var last_mouse_movement = null
var look_enabled = true
var moving = false
var sprinting = false

var speed

var vert_speed = 0

var is_on_floor

var coyote_time = 0.2

var fall_time = 0

const MAX_VERT_SPEED = 10

const GRAVITY_UP = 10
const GRAVITY_DOWN = 15

const SENSITIVITY_X = -0.03
const SENSITIVITY_Y = -0.03

const DEATH_FALL_TIME = 5

export (float) var move_speed = 3
export (float) var sprint_speed = 5
export (float) var jump_power = 7


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		last_mouse_movement = event.relative
	elif event is InputEventMouseButton:
		if (event.button_index == BUTTON_LEFT):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			look_enabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var gravity
	if (vert_speed > 0):
		gravity = GRAVITY_UP
	else:
		gravity = GRAVITY_DOWN

	vert_speed -= gravity * delta

	if (vert_speed < -MAX_VERT_SPEED):
		vert_speed = -MAX_VERT_SPEED

	if ($KinematicBody.is_on_floor() && vert_speed < 0):
		vert_speed = 0
	var vert_movement = Vector3(0, vert_speed, 0)
	$KinematicBody.move_and_slide(vert_movement)
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		look_enabled = false

	if Input.is_action_just_pressed("ctl_toggle_sprint"):
		sprinting = true

	if Input.is_action_just_pressed("ui_scroll_up"):
		$WorldEnvironment.environment.ambient_light_energy += 0.1
		print ("light_up")

	if Input.is_action_just_pressed("ui_scroll_down"):
		$WorldEnvironment.environment.ambient_light_energy -= 0.1

	if (Input.is_action_pressed("debug_zoom")):
		$KinematicBody/Camera.fov = 30
	else:
		$KinematicBody/Camera.fov = 70


	if (Input.is_action_pressed("ctl_jump") && is_on_floor):
		vert_speed = jump_power

	if (last_mouse_movement != null && look_enabled):
		$KinematicBody.rotate_y(last_mouse_movement.x * SENSITIVITY_X)
		$KinematicBody/Camera.rotate_x(last_mouse_movement.y * SENSITIVITY_Y)
		if $KinematicBody/Camera.rotation.x > PI / 2:
			$KinematicBody/Camera.rotation.x = PI / 2
		elif $KinematicBody/Camera.rotation.x < -PI / 2:
			$KinematicBody/Camera.rotation.x = -PI / 2
		last_mouse_movement = null

	var target_camera_height = .9
	if (moving && is_on_floor):
		var bob_speed
		if (sprinting):
			bob_speed = (sprint_speed / 3.0) * (1.0 / 100000.0)
		else:
			bob_speed = (move_speed / 3.0) * (1.0 / 100000.0)
		target_camera_height = .9 + sin(OS.get_ticks_usec() * bob_speed) * 0.05
	var cam_move_speed = 0.5 * delta
	if ($KinematicBody/Camera.transform.origin.y < target_camera_height):
		if (target_camera_height - $KinematicBody/Camera.transform.origin.y < cam_move_speed):
			$KinematicBody/Camera.transform.origin.y = target_camera_height
		else:
			$KinematicBody/Camera.transform.origin.y += cam_move_speed
	else:
		if ($KinematicBody/Camera.transform.origin.y - target_camera_height < cam_move_speed):
			$KinematicBody/Camera.transform.origin.y = target_camera_height
		else:
			$KinematicBody/Camera.transform.origin.y -= cam_move_speed

func _physics_process(delta):

	var gravity
	if (vert_speed > 0):
		gravity = GRAVITY_UP
	else:
		gravity = GRAVITY_DOWN

	vert_speed -= gravity * delta

	if (vert_speed < -MAX_VERT_SPEED):
		vert_speed = -MAX_VERT_SPEED

	if ($KinematicBody.is_on_floor() && vert_speed < 0):
		vert_speed = 0
	var vert_movement = Vector3(0, vert_speed, 0)
	var actual_vert_move = $KinematicBody.move_and_slide(vert_movement).y

	if (abs(actual_vert_move) < 0.001):
		actual_vert_move = 0

	if (vert_speed < -0.1 && actual_vert_move == 0):
		fall_time = 0
		is_on_floor = true
		coyote_time = 0.2
	else:
		if (vert_speed < 0):
			coyote_time -= delta
			if (coyote_time < 0):
				is_on_floor = false
			else:
				is_on_floor = true
			fall_time += delta
			if (fall_time > DEATH_FALL_TIME):
				get_tree().reload_current_scene()
		else:
			fall_time = 0
			coyote_time = 0
			is_on_floor = false

	if (vert_speed > 0 && actual_vert_move == 0):
		# we hit a ceiling
		vert_speed = 0

	var movement = Vector3(0, 0, 0)

	if (sprinting):
		speed = sprint_speed
	else:
		speed = move_speed

	if (Input.is_action_pressed("ctl_fwd")):
		movement.z += speed
	if (Input.is_action_pressed("ctl_back")):
		movement.z -= speed
	if (Input.is_action_pressed("ctl_strafe_l")):
		movement.x += speed
	if (Input.is_action_pressed("ctl_strafe_r")):
		movement.x -= speed

	moving = Vector2(movement.x, movement.z).length() > 0.01

	if (!moving):
		sprinting = false

	movement = movement.rotated(Vector3(0,1,0), $KinematicBody.rotation.y)
	$KinematicBody.move_and_collide(movement * delta)


	$Label.text = str(Engine.get_frames_per_second())
