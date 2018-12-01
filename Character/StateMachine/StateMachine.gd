extends Node

var current_state

onready var controller = get_parent()

func _physics_process(delta):
	if current_state != null:
		current_state._state_physics_process(controller, delta)

func change_state(new_state):
	var old_state = current_state
	
	if current_state != null:
		current_state.exit_state(controller, new_state)
	if new_state != null:
		new_state.enter_state(controller, old_state)
	
	current_state = new_state