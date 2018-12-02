extends KinematicBody2D

const SLOPE_SLIDE_STOP = 5
const MIN_JUMP_HEIGHT = 0.8 * 64
const FALL_DURATION = 0.5
const WALL_STICK_CHECK = 2.5 # Time in seconds player can move away from wall but still stick to it.
const WALL_CLIMB_HEIGHT = 4.25 * 64
const WALL_LEAP_HEIGHT = 2.5 * 64
const DEFAULT_MAX_VELOCITY = 1500
const WALL_SLIDE_MAX_VELOCITY = 150
const WALL_SLIDE_GRAVITY_MODIFIER = 0.25


var move_speed = 8 * Global.UNIT_SIZE

var velocity = Vector2()
var max_fall_speed = DEFAULT_MAX_VELOCITY
var is_grounded = false
var move_direction = 0 # Direction player is attempting to move
var facing = 1 # Direction the player is facing
var wall_direction = 0 setget ,_get_wall_direction # Direction of the wall if the player is wall_sliding
var wall_stick_duration = 0 # Current duration player has been moving away from wall

onready var max_jump_velocity = Utility.get_velocity_from_height(Global.PLAYER_JUMP_HEIGHT)
onready var min_jump_velocity = Utility.get_velocity_from_height(MIN_JUMP_HEIGHT)
onready var fall_gravity = 2 * Global.PLAYER_JUMP_HEIGHT / pow(FALL_DURATION, 2)
onready var wall_climb_velocity = Vector2(800, Utility.get_velocity_from_height(WALL_CLIMB_HEIGHT))
onready var wall_leap_velocity = Vector2(1200, Utility.get_velocity_from_height(WALL_LEAP_HEIGHT))

onready var camera = $PlatformerCamera
onready var ground_raycasts = $GroundRaycasts
onready var body = $Body
onready var state_machine = $PlayerStateMachine
onready var wall_slide_wait_timer = $WallSlideWaitTimer

func _physics_process(delta):
	# Get input to determine which way to attempt to move
	move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	state_machine.state_physics_process(delta)
	
	var was_grounded = is_grounded
	is_grounded = is_on_floor()

func _input(event):
	state_machine.state_input(event)

func _apply_h_movement():
	# Apply linear interpolation to create acceleration and deceleration
	var target_speed = move_direction * move_speed
	velocity.x = lerp(velocity.x, target_speed, _get_h_weight(target_speed))
	# Determine facing from move_direction
	if move_direction != 0:
		facing = move_direction

# Set which way the player is facing. Can be used to face the opposite of facing during a wall jump.
func set_body_facing(facing = self.facing):
	body.scale.x = facing

func _apply_gravity(delta, modifier = 1):
	if velocity.y < 0:
		velocity.y += Global.gravity * delta * modifier
	else:
		velocity.y += fall_gravity * delta * modifier
	
	velocity.y = min(velocity.y, max_fall_speed)

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
func _get_h_weight(target_speed):
	var weight = 0.4 if is_grounded else 0.125
	
	# If player is pressing move towards velocity
	# And player is moving faster than their speed
	# This is meant to provide less deceleration in air while maintaining tight controls
	if move_direction == sign(velocity.x) && abs(velocity.x) > abs(target_speed):
		if !is_grounded:
			weight *= 0.25
	
	return weight

# Checks to see if a player is moving towards a wall and is colliding with the wall
func _check_wall_sliding():
	if move_direction == Global.RIGHT && $WallJumpRaycasts/RightWallRaycast.is_colliding() \
			|| move_direction == Global.LEFT && $WallJumpRaycasts/LeftWallRaycast.is_colliding():
		return true
	else: return false

func _get_wall_direction():
	if $WallJumpRaycasts/RightWallRaycast.is_colliding():
		wall_direction = Global.RIGHT
	elif $WallJumpRaycasts/LeftWallRaycast.is_colliding():
		wall_direction = Global.LEFT
	else:
		wall_direction = 0
	
	return wall_direction