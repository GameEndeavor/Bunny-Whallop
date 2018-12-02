extends Node2D

func open():
	if $DoorAnimator.assigned_animation != "open":
		$DoorAnimator.play("open")

func _on_trigger_changed(trigger_state):
	open()