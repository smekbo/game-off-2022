extends Camera

const MIN_LOOK = -90
const MAX_LOOK = 60

const RIG_MOVE_THRESHOLD_LEFT = 100
const RIG_MOVE_THRESHOLD_RIGHT = 270

var MOUSE_SENSITIVITY = 10
onready var rig = $"../deemongal"
onready var pivot = $".."
onready var skeleton = rig.get_child(0).get_child(0)

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

func intro_done():
	intro_playing = false
	$gun.show()
	rig.get_node("AnimationTree")["parameters/shrink_head/blend_amount"] = 1
	$camera_animation.play("RESET")

func process_camera_movement(delta):
	var rot = Vector3(mouse_event.relative.x, mouse_event.relative.y, 0) * MOUSE_SENSITIVITY * delta
	var rig_threshold = abs(rig.rotation_degrees.y - rotation_degrees.y)	
	
	rotation_degrees.x -= rot.y
	rotation_degrees.x = clamp(rotation_degrees.x, MIN_LOOK, MAX_LOOK)
	
	if rig_threshold >= RIG_MOVE_THRESHOLD_RIGHT and rot.x > 0:
		pivot.rotation_degrees.y -= rot.x
	elif rig_threshold <= RIG_MOVE_THRESHOLD_LEFT and rot.x < 0:
		pivot.rotation_degrees.y -= rot.x
	
	elif rig_threshold < RIG_MOVE_THRESHOLD_RIGHT or rig_threshold > RIG_MOVE_THRESHOLD_LEFT:
		rotation_degrees.y -= rot.x
			
	mouse_event = false

func _input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_event = event
