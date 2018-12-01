extends Node

enum States {
	IDLE, RUNNING, JUMPING, FALLING, WALL_SLIDING
}

var state = IDLE
var previous_state = null

onready var parent = get_parent()

func state_physics_process(delta):
	if state == IDLE || state == RUNNING || state == JUMPING || state == FALLING:
		parent._apply_gravity(delta)
		parent._apply_h_movement()
		parent.set_body_facing()
		parent._apply_movement()
	
	# WALL_SLIDING
	elif state == WALL_SLIDING:
		parent._apply_gravity(delta, 0.1)
		parent.set_body_facing(-parent.facing)
		parent._apply_movement()
	
	previous_state = state
	_state_transitions()
	
	# Detect state change, to be able to perform exit conditions
	if state != previous_state:
		_state_exit(previous_state)
		_state_enter(state)

func state_input(event):
	if state == IDLE || state == RUNNING:
		# Jump
		if event.is_action_pressed("jump") && parent.is_grounded:
			parent.velocity.y = parent.max_jump_velocity
	if state == JUMPING:
		# Variable Jump
		if event.is_action_released("jump") && parent.velocity.y < parent.min_jump_velocity:
			parent.velocity.y = parent.min_jump_velocity

func _state_transitions():
	# IDLE
	if state == IDLE:
		if parent.velocity.y < 0:
			state = JUMPING
		elif parent.velocity.y > 0:
			state = FALLING
		elif parent.move_direction != 0:
			state = RUNNING
	
	# RUNNING
	elif state == RUNNING:
		if parent.velocity.y < 0:
			state = JUMPING
		elif parent.velocity.y > 0:
			state = FALLING
		elif parent.move_direction == 0:
			state = IDLE
	
	# JUMPING
	elif state == JUMPING:
		if parent.velocity.y > 0:
			state = FALLING
		elif parent.is_grounded:
			if parent.move_direction == 0:
				state = IDLE
			else:
				state = RUNNING
	
	# FALLING
	elif state == FALLING:
		if parent.velocity.y < 0:
			state = JUMPING
		elif parent.is_grounded:
			if parent.move_direction == 0:
				state = IDLE
			else:
				state = RUNNING
		elif parent._check_wall_sliding():
			state = WALL_SLIDING
	
	# WALL_SLIDING
	elif state == WALL_SLIDING:
		if parent.is_grounded:
			if parent.move_direction == 0:
				state = IDLE
			else:
				state = RUNNING

func _state_enter(state):
	if state == null: return

func _state_exit(state):
	if state == null: return