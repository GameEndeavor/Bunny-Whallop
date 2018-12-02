extends Node

enum States {
	IDLE, RUNNING, JUMPING, FALLING, WALL_SLIDING
}

var state = IDLE setget _set_state
var previous_state = null

onready var parent = get_parent()

func state_physics_process(delta):
	if state == null: return
	
	elif state == IDLE || state == RUNNING || state == JUMPING || state == FALLING:
		parent._apply_gravity(delta)
#		parent._set_velocity_to_floor()
		parent._apply_h_movement()
		parent.set_body_facing()
		parent._apply_movement()
	
	# WALL_SLIDING
	elif state == WALL_SLIDING:
		var max_velocity = parent.MAX_VELOCITY if Input.is_action_pressed("move_down") else parent.WALL_SLIDE_MAX_VELOCITY
		parent._apply_gravity(delta, max_velocity)
		parent.set_body_facing(-parent.facing)
		parent._apply_movement()
		# Timer that will keep the player stuck to the wall if they try moving off of it
		if parent.move_direction != 0 && !parent._check_wall_sliding():
			parent.wall_stick_duration += delta
		else:
			parent.wall_stick_duration = 0
		
	_state_transitions()

func state_input(event):
	if state == null: return
	
	# Grab / Throw
	elif event.is_action_pressed("grab"):
		# Grab nearest object within reach if parent isn't holding anything
		if parent.held_object == null:
			parent.grab_nearest()
		else:
			parent.throw_held_object()
	
	# Jump
	elif event.is_action_pressed("jump"):
		# Regular Jump
		if (state == IDLE || state == RUNNING || state == FALLING) && (parent.is_grounded || !parent.coyote_timer.is_stopped()):
			parent.velocity.y = parent.max_jump_velocity
		# Wall Jump
		elif state == WALL_SLIDING:
			# If player is moving towards wall then climb up the wall
			if parent.move_direction == parent.wall_direction:
				parent.velocity = parent.wall_climb_velocity * Vector2(-parent.wall_direction, 1)
			# If player isn't moving then hop off of the wall
			elif parent.move_direction == 0:
				parent.velocity = parent.wall_hop_velocity * Vector2(-parent.wall_direction, 1)
			# Else player is moving away from the wall, so leap off of it
			else:
				parent.velocity = parent.wall_leap_velocity * Vector2(-parent.wall_direction, 1)
			_set_state(JUMPING)
	elif event.is_action_released("jump") && parent.velocity.y < parent.min_jump_velocity && state == JUMPING:
			# Variable Jump
			parent.velocity.y = parent.min_jump_velocity

func _state_transitions():
	if state == null: return
	
	# IDLE
	elif state == IDLE:
		if parent.velocity.y < 0:
			_set_state(JUMPING)
		elif parent.velocity.y > 0:
			_set_state(FALLING)
		elif parent.move_direction != 0:
			_set_state(RUNNING)
	
	# RUNNING
	elif state == RUNNING:
		if parent.velocity.y < 0:
			_set_state(JUMPING)
		elif parent.velocity.y > 0:
			_set_state(FALLING)
		elif parent.move_direction == 0:
			_set_state(IDLE)
	
	# JUMPING
	elif state == JUMPING:
		if parent.velocity.y > 0:
			_set_state(FALLING)
		elif parent.is_grounded:
			if parent.move_direction == 0:
				_set_state(IDLE)
			else:
				_set_state(RUNNING)
		elif parent.wall_slide_wait_timer.is_stopped() && parent.move_direction != 0 && parent.wall_direction != 0:
			_set_state(WALL_SLIDING)
	
	# FALLING
	elif state == FALLING:
		if parent.velocity.y < 0:
			_set_state(JUMPING)
		elif parent.is_grounded:
			if parent.move_direction == 0:
				_set_state(IDLE)
			else:
				_set_state(RUNNING)
		elif parent.wall_slide_wait_timer.is_stopped() && parent.move_direction != 0 && parent.wall_direction != 0:
			_set_state(WALL_SLIDING)
	
	# WALL_SLIDING
	elif state == WALL_SLIDING:
		if parent.is_grounded:
			if parent.move_direction == 0:
				_set_state(IDLE)
			else:
				_set_state(RUNNING)
		elif parent.wall_stick_duration >= parent.WALL_STICK_CHECK \
				|| !parent._check_raycasts(parent.get_node("WallJumpRaycasts")):
			if parent.velocity.y < 0:
				_set_state(JUMPING)
			else:
				_set_state(FALLING)

func _state_enter(state):
	if state == null: return
	
	elif state == JUMPING && (previous_state == IDLE || previous_state == RUNNING):
		parent.camera.is_steady = true
	elif state == WALL_SLIDING:
		parent.wall_stick_duration = 0
		parent.velocity.x = 0
	
	# Animations
	if state == IDLE:
		parent.anim_player.play("idle")
	elif state == RUNNING:
		parent.anim_player.play("running")
	elif state == JUMPING:
		parent.anim_player.play("jumping")
	elif state == FALLING:
		parent.anim_player.play("falling")
	elif state == WALL_SLIDING:
		parent.anim_player.play("wall_sliding")

func _state_exit(old_state, new_state):
	if old_state == null: return
	
	elif (old_state == JUMPING && new_state != null && new_state != FALLING) || old_state == FALLING:
		parent.camera.is_steady = false
	elif old_state == WALL_SLIDING:
		parent.wall_slide_wait_timer.start()

func _set_state(value):
	previous_state = state
	state = value
	
	_state_exit(previous_state, state)
	_state_enter(state)