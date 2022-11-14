extends KinematicBody

export(float) var blend_space_transition_speed = 1
export(float) var SPEED = 1000
export(float) var JUMP_STRENGTH = 3
export(float) var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

var velocity : Vector3 = Vector3()

onready var player_pivot = $player_pivot
onready var camera_pivot = $player_pivot/camera_pivot
onready var camera = $player_pivot/camera_pivot/Camera
onready var rig = $player_pivot/deemongal
onready var animation_tree = $player_pivot/deemongal/AnimationTree

var current_vector = Vector2(0,0)

var DEBUG_TIME = 0.2
var debug_timer = 0

func _ready():
	pass

func _physics_process(delta):
	# get input strength as a 2d vector, x = left/right y = forward/back
	var input_strength = get_input_strength()
	
	# try to blend animations by smoothing input
	current_vector.x = move_toward(current_vector.x, input_strength.x, delta * blend_space_transition_speed)
	current_vector.y = move_toward(current_vector.y, input_strength.y, delta * blend_space_transition_speed)
	animation_tree["parameters/BlendSpace2D/blend_position"] = current_vector
	
	# movement relative to camera basis
	var basis_rot_x = camera_pivot.global_transform.basis.x * input_strength.x
	var basis_rot_y = camera_pivot.global_transform.basis.z * input_strength.y
	var basis_rot = basis_rot_x + basis_rot_y
	velocity = Vector3(basis_rot.x, velocity.y, basis_rot.z)
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_STRENGTH
	else:
		velocity.y -= GRAVITY * delta
		velocity.y = clamp(velocity.y, -200, JUMP_STRENGTH)
	
	move_and_slide(velocity * SPEED * delta, Vector3.UP)
	
	if debug_timer >= DEBUG_TIME:
#		print([velocity.y, is_on_floor()])
		debug_timer = 0
	debug_timer += delta
	
func get_input_strength():
	var x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	var y = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	
	return Vector2(x,y)
