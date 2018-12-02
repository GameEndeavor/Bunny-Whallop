extends Node2D

const TEXTURE_DOWN = preload("res://Elements/ButtonDown.png")

signal trigger_changed(trigger_state)

func _on_Area2D_body_entered(body):
	$Sprite.set_texture(TEXTURE_DOWN)
	emit_signal("trigger_changed", true)