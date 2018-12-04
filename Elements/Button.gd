extends Node2D

const TEXTURE_UP = preload("res://Elements/ButtonUp.png")
const TEXTURE_DOWN = preload("res://Elements/ButtonDown.png")

signal trigger_changed(trigger_state)

func _set_state(state):
	if state:
		$Sprite.set_texture(TEXTURE_DOWN)
	else:
		$Sprite.set_texture(TEXTURE_UP)
	
	emit_signal("trigger_changed", state)

func _on_Area2D_body_entered(body):
	_set_state(true)

func _on_Area2D_body_exited(body):
	if $Area2D.get_overlapping_bodies().size() == 1:
		_set_state(false)
