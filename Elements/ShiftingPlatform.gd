extends Node2D

var is_pushed_down = false

var velocity = Vector2()
onready var platform = $KinematicBody2D

func _physics_process(delta):
	if is_pushed_down:
		velocity.y += Global.gravity * delta
		velocity = platform.move_and_slide(velocity, Global.UP_VEC)

func interact():
	is_pushed_down = true