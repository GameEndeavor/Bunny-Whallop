extends Node2D

const OPEN_TRANS = Tween.TRANS_SINE
const OPEN_EASE = Tween.EASE_OUT
const OPEN_DURATION = 0.4
const OPEN_DISTANCE = 128 - 16

func open():
	$StateTween.interpolate_property($KinematicBody2D, "position:y", 0, -OPEN_DISTANCE, OPEN_DURATION, OPEN_TRANS, OPEN_EASE)
	$StateTween.start()

func _on_Button_trigger_changed(trigger_state):
	if trigger_state:
		open()
