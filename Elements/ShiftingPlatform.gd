extends Node2D

var velocity = Vector2()
onready var platform = $KinematicBody2D

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	velocity.y += Global.gravity * delta
	velocity = platform.move_and_slide(velocity, Global.UP_VEC)
	if platform.is_on_floor():
		set_physics_process(false)

func interact():
	set_physics_process(true)