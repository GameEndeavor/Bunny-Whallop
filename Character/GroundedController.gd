extends Node

var velocity = Vector2()
export (float) var move_speed = 5 * 64

func _physics_process(delta):
	