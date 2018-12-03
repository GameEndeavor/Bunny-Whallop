extends KinematicBody2D

const RUN_SPEED = 8 * 64 # Number tiles the player will run per second and full speed
const SLOPE_SLIDE_STOP = 5
const MIN_JUMP_HEIGHT = 0.8 * 64
const FALL_DURATION = 0.5 # Time in seconds it should take the player to fall 'Global.PLAYER_JUMP_HEIGHT' distance
const WALL_STICK_CHECK = 0.3 # Time in seconds player can move away from wall but still stick to it.
const WALL_CLIMB_HEIGHT = 5.25 * 64
const WALL_HOP_HEIGHT = 3.5 * 64
const WALL_LEAP_HEIGHT = 2.5 * 64
const THROW_HEIGHT = 2.5 * 64
const MAX_VELOCITY = 1200
const WALL_SLIDE_MAX_VELOCITY = 150
const WALL_SLIDE_GRAVITY_MODIFIER = 0.25

var velocity = Vector2()
var is_grounded = false
var move_direction = 0 # Direction player is attempting to move
var facing = 1 # Direction the player is facing
var wall_direction = 0 setget ,_get_wall_direction # Direction of the wall if the player is wall_sliding
var wall_stick_duration = 0 # Current duration player has been moving away from wall
var held_object = null setget _set_held_object,_get_held_object
var obj_container
var is_force_walking = false
var can_glide = false

onready var fall_gravity = 2 * Global.PLAYER_JUMP_HEIGHT / pow(FALL_DURATION, 2)
onready var max_jump_velocity = Utility.get_velocity_from_height(Global.PLAYER_JUMP_HEIGHT)
onready var min_jump_velocity = Utility.get_velocity_from_height(MIN_JUMP_HEIGHT)
onready var wall_climb_velocity = Vector2(1200, Utility.get_velocity_from_height(WALL_CLIMB_HEIGHT))
onready var wall_hop_velocity = Vector2(600, Utility.get_velocity_from_height(WALL_HOP_HEIGHT))
onready var wall_leap_velocity = Vector2(800, Utility.get_velocity_from_height(WALL_LEAP_HEIGHT))
onready var throw_velocity = Vector2(600, Utility.get_velocity_from_height(THROW_HEIGHT))

onready var camera = $PlatformerCamera
onready var ground_raycasts = $GroundRaycasts
onready var body = $Body
onready var state_machine = $PlayerStateMachine
onready var wall_slide_wait_timer = $WallSlideWaitTimer
onready var coyote_timer = $CoyoteTimer
onready var grab_detection = $GrabDetection
onready var anim_player = $Body/PlayerRig/AnimationPlayer

func _ready():
	_set_on_ground()
	$HoldControls.start()

func _physics_process(delta):
	# Get input to determine which way to attempt to move
	state_machine.state_physics_process(delta)
	_check_raycasts(ground_raycasts)
	
	var was_grounded = is_grounded
	is_grounded = state_machine.state != state_machine.JUMPING && (is_on_floor() || _check_raycasts(ground_raycasts))
	
	if !is_grounded && was_grounded:
		coyote_timer.start()

func _input(event):
	if $HoldControls.is_stopped():
		state_machine.state_input(event)

func _get_move_input():
	if $HoldControls.is_stopped():
		move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))

func _apply_h_movement():
	# Apply linear interpolation to create acceleration and deceleration
	var target_speed = move_direction * RUN_SPEED
	velocity.x = lerp(velocity.x, target_speed, _get_h_weight(target_speed))
	# Determine facing from move_direction
	if move_direction != 0:
		facing = move_direction

# Set which way the player is facing. Can be used to face the opposite of facing during a wall jump.
func set_body_facing(facing = self.facing):
	body.scale.x = facing

# Apply gravity based on whether character is jumping or falling. Slow gravity when falling to allow
# the player more time to align their landing.
func _apply_gravity(delta, max_velocity = MAX_VELOCITY):
	if velocity.y < 0:
		velocity.y += Global.gravity * delta
	else:
		velocity.y += fall_gravity * delta
	
	velocity.y = min(velocity.y, max_velocity)

# Move player with physics
func _apply_movement():
	velocity = move_and_slide(velocity, Global.UP_VEC, SLOPE_SLIDE_STOP)

func _set_on_ground():
	var space_state = get_world_2d().direct_space_state
	var check_distance = 256
	var result = space_state.intersect_ray(position, position + Vector2(0, check_distance), [self], collision_mask)
	if result:
		position.y = result.position.y - $CollisionShape2D.shape.extents.y - 1

func grab_nearest():
	# Get bodies within reach
	var bodies = grab_detection.get_overlapping_bodies()
	# Set closest distance to max range so we can find what's even closer
	var closest_distance = grab_detection.get_node("CollisionShape2D").shape.radius
	var closest = null
	
	for body in bodies:
		if (body.position - position).length() <= closest_distance:
			closest = body
	
	if closest != null:
		pickup(closest)

func pickup(entity):
	# Disable processing such as gravity for the object
	entity.set_physics_process(false)
	# Reparent to our hand
	obj_container = entity.get_parent()
	obj_container.remove_child(entity)
	$Body/Hand.add_child(entity)
	entity.position = Vector2()
	_set_held_object(entity)

func throw_held_object():
	var held_object = _get_held_object()
	if held_object != null:
		var pos = held_object.global_position
		$Body/Hand.remove_child(held_object)
		obj_container.add_child(held_object)
		held_object.global_position = pos
		held_object.velocity = throw_velocity * Vector2(facing, 1)
		held_object.set_physics_process(true)
		_set_held_object(null)
	

# Loop through the children of a given node, checking for RayCast2D's and returns
# a boolean based on whether any collision was detected
func _check_raycasts(raycasts):
	var is_colliding = false
	for raycast in raycasts.get_children():
		if raycast is RayCast2D and raycast.is_colliding():
			var collider = raycast.get_collider()
			if !collider is TileMap && collider.get_parent().has_method("interact"):
				collider.get_parent().interact()
			is_colliding = true
	return is_colliding

func _set_velocity_to_floor(raycasts = ground_raycasts):
	var min_velocity = MAX_VELOCITY
	var is_colliding = false
	for raycast in raycasts.get_children():
		if raycast is RayCast2D && raycast.is_colliding() && raycast.get_collider().get_parent().get("velocity"):
			is_colliding = true
			min_velocity = raycast.get_collider().get_parent().velocity.y
	if is_colliding:
		velocity.y = min_velocity

# Checks conditions to determine what weight to apply to character acceleration / deceleration
func _get_h_weight(target_speed):
	var weight = 0.4 if is_grounded else 0.125
	
	# If player is pressing move towards velocity
	# And player is moving faster than their speed
	# This is meant to provide less deceleration in air while maintaining tight controls
	if can_glide && move_direction == sign(velocity.x) && abs(velocity.x) > abs(target_speed):
		if !is_grounded:
			weight = 0
	
	return weight

# Checks to see if a player is moving towards a wall and is colliding with the wall
func _check_wall_sliding():
	if move_direction == Global.RIGHT && $WallJumpRaycasts/RightWallRaycast.is_colliding() \
			|| move_direction == Global.LEFT && $WallJumpRaycasts/LeftWallRaycast.is_colliding():
		return true
	else: return false

# Check the wall raycasts to determine which direction a wall is next to the player if any.
func _get_wall_direction():
	if $WallJumpRaycasts/RightWallRaycast.is_colliding():
		wall_direction = Global.RIGHT
	elif $WallJumpRaycasts/LeftWallRaycast.is_colliding():
		wall_direction = Global.LEFT
	else:
		wall_direction = 0
	
	return wall_direction

func kill():
	get_tree().reload_current_scene()

func _on_HitboxArea_body_entered(body):
	if body is TileMap:
		kill()

func _set_held_object(value):
	if value != null:
		held_object = weakref(value)
	else:
		held_object = null

func _get_held_object():
	if held_object == null: return null
	else:
		return held_object.get_ref()

func _on_level_complete():
	is_force_walking = true