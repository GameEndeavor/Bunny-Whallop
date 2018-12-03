extends Node2D

const FALL_DISTANCE = 128

var velocity = Vector2()
onready var platform = $KinematicBody2D

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	velocity.y += Global.gravity * delta
	platform.position.y = min(platform.position.y + velocity.y * delta, FALL_DISTANCE)
	if platform.position.y == FALL_DISTANCE:
		set_physics_process(false)

func interact():
	if platform.position.y != FALL_DISTANCE:
		set_physics_process(true)