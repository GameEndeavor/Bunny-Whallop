extends KinematicBody2D

const SLOPE_SLIDE_STOP = 5
const MIN_JUMP_HEIGHT = 0.8 * 64

var move_speed = 8 * Global.UNIT_SIZE

var velocity = Vector2()
var is_grounded = false
var move_direction = 0 # Direction player is attempting to move
var facing = 1 # Direction the player is facing

onready var max_jump_velocity = -sqrt(2 * Global.gravity * Global.PLAYER_JUMP_HEIGHT)
onready var min_jump_velocity = -sqrt(2 * Global.gravity * MIN_JUMP_HEIGHT)

onready var camera = $PlatformerCamera
onready var ground_raycasts = $GroundRaycasts
onready var body = $Body
onready var state_machine = $PlayerStateMachine

func _physics_process(delta):
	state_machine.state_physics_process(delta)
	
	var was_grounded = is_grounded
	is_grounded = _check_raycasts(ground_raycasts) || is_on_floor()
	
	# Steady the camera if the player recently came off of the ground
	if !is_grounded && was_grounded:
		camera.is_steady = true
	# Return the camera to normal when they're grounded again
	elif is_grounded && !was_grounded:
		camera.is_steady = false

func _input(event):
	state_machine.state_input(event)

func _apply_h_movement():
	# Get input to determine which way to attempt to move
	move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	# Apply linear interpolation to create acceleration and deceleration
	velocity.x = lerp(velocity.x, move_direction * move_speed, _get_h_weight())
	# Determine facing from move_direction
	if move_direction != 0:
		facing = move_direction

# Set which way the player is facing. Can be used to face the opposite of facing during a wall jump.
func set_body_facing(facing = self.facing):
	body.scale.x = facing

func _apply_gravity(delta, modifier = 1):
	velocity.y += Global.gravity * delta * modifier

# Move player with physics
func _apply_movement():
	velocity = move_and_slide(velocity, Global.UP_VEC, SLOPE_SLIDE_STOP)

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

func _check_wall_sliding():
	if move_direction == Global.RIGHT && $WallJumpRaycasts/RightWallRaycast.is_colliding() \
			|| move_direction == Global.LEFT && $WallJumpRaycasts/LeftWallRaycast.is_colliding():
		return true
	else: return false