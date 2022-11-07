extends KinematicBody

export(float) var blend_space_transition_speed = 2
export(float) var SPEED = 500

onready var pivot = $pivot
onready var camera = $pivot/Camera
onready var rig = $pivot/deemongal
onready var animation_tree = $pivot/deemongal/AnimationTree

var current_vector = Vector2(0,0)

var DEBUG_TIME = 1
var debug_timer = 0

func _ready():
	pass

func _physics_process(delta):
	var vector = get_input_strength()
	current_vector.x = move_toward(current_vector.x, vector.x, delta * blend_space_transition_speed)
	current_vector.y = move_toward(current_vector.y, vector.y, delta * blend_space_transition_speed)
	
	animation_tree["parameters/BlendSpace2D/blend_position"] = current_vector
	
	move_and_slide(Vector3(vector.x, 0, vector.y) * camera.transform.basis.y * SPEED * delta)
	
	if debug_timer >= DEBUG_TIME:
		print(camera.global_transform.basis.x)
		print(camera.global_transform.basis.y)
		print(camera.global_transform.basis.z)
		print("")
		debug_timer = 0
	debug_timer += delta
	
func get_input_strength():
	var x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	var y = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	
	return Vector2(x,y)
