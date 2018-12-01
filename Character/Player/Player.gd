extends KinematicBody2D

const SLOPE_SLIDE_STOP = 5
const MIN_JUMP_HEIGHT = 0.8 * 64

var move_speed = 8 * Global.UNIT_SIZE

var velocity = Vector2()
var is_grounded = false

onready var max_jump_velocity = -sqrt(2 * Global.gravity * Global.PLAYER_JUMP_HEIGHT)
onready var min_jump_velocity = -sqrt(2 * Global.gravity * MIN_JUMP_HEIGHT)

onready var ground_raycasts = $GroundRaycasts

func _physics_process(delta):
	# Apply gravity and horizontal movement
	velocity.y += Global.gravity * delta
	_apply_h_movement()
	
	# Move player with physics
	velocity = move_and_slide(velocity, Global.UP, SLOPE_SLIDE_STOP)
	
	is_grounded = _check_raycasts(ground_raycasts) || is_on_floor()

func _input(event):
	# Jump
	if event.is_action_pressed("jump") && is_grounded:
		velocity.y = max_jump_velocity
	# Variable Jump
	if event.is_action_released("jump") && velocity.y < min_jump_velocity:
		velocity.y = min_jump_velocity

func _apply_h_movement():
	# Get input to determine which way to attempt to move
	var move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	# Apply linear interpolation to create acceleration and deceleration
	velocity.x = lerp(velocity.x, move_direction * move_speed, _get_h_weight())

# Loop through the children of a given node, checking for RayCast2D's and returns
# a boolean based on whether any collision was detected
func _check_raycasts(raycasts):
	for raycast in raycasts.get_children():
		if raycast is RayCast2D and raycast.is_colliding():
				return true
	# If loop completes then no raycast was detected.
	return false

# Checks conditions to determine what weight to apply to character acceleration / deceleration
func _get_h_weight():
	if is_grounded: return 0.4
	else: return 0.2