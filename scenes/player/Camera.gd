extends Camera

const MIN_LOOK = -90
const MAX_LOOK = 60

const RIG_MOVE_THRESHOLD_LEFT = 50
const RIG_MOVE_THRESHOLD_RIGHT = -50

const RIG_ROTATE_TO_CAMERA_SPEED = 50

var MOUSE_SENSITIVITY = 10
onready var rig = $"../../deemongal"
onready var player_pivot = $"../.."
onready var camera_pivot = $".."
onready var skeleton = $"../../deemongal/Armature/Skeleton"

var mouse_event
var intro_playing = false

func _ready():
	if intro_playing:
		$camera_animation.play("intro")
		$gun.hide()
		rig.get_node("AnimationTree")["parameters/shrink_head/blend_amount"] = 0
	else:
		rig.get_node("AnimationTree")["parameters/shrink_head/blend_amount"] = 1
	pass

func _process(delta):
	if intro_playing:
		look_at(rig.get_node("intro_lookat").global_translation, Vector3.UP)
	if !intro_playing:
		if Input.is_action_just_pressed("escape"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and mouse_event:
			process_camera_movement(delta)
	
	# rotate rig toward running direction
	rig.rotation_degrees.y = move_toward(rig.rotation_degrees.y, camera_pivot.rotation_degrees.y, RIG_ROTATE_TO_CAMERA_SPEED * delta)

func intro_done():
	intro_playing = false
	$gun.show()
	rig.get_node("AnimationTree")["parameters/shrink_head/blend_amount"] = 1
	$camera_animation.play("RESET")

func process_camera_movement(delta):
	var rotating_camera = false
	var rotation_strength = Vector3(mouse_event.relative.x, mouse_event.relative.y, 0) * MOUSE_SENSITIVITY * delta
	var camera_rotation_y = camera_pivot.rotation_degrees.y
	
	# rotate the camera up and down
	rotation_degrees.x -= rotation_strength.y
	rotation_degrees.x = clamp(rotation_degrees.x, MIN_LOOK, MAX_LOOK)
	
	# rotate the model if the camera rotates far enough
	# if the camera is moving left
	if camera_rotation_y >= RIG_MOVE_THRESHOLD_LEFT and rotation_strength.x < 0:
		player_pivot.rotation_degrees.y -= rotation_strength.x
	# if the camera is moving right
	elif camera_rotation_y <= RIG_MOVE_THRESHOLD_RIGHT and rotation_strength.x > 0:
		player_pivot.rotation_degrees.y -= rotation_strength.x
	else: 
		camera_pivot.rotation_degrees.y -= rotation_strength.x
	
	mouse_event = false

func _input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_event = event
