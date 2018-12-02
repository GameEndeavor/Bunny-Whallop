extends Node2D

var velocity = Vector2()
onready var platform = $KinematicBody2D
onready var rider_raycasts = $RiderRaycasts

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	velocity.y += Global.gravity * delta
#	platform.position.y += velocity.y * delta
#	_shift_riders(velocity, delta)
	velocity = platform.move_and_slide(velocity, Global.UP_VEC)
	if platform.is_on_floor():
		set_physics_process(false)

func interact():
	if !platform.is_on_floor():
		set_physics_process(true)
		_enable_raycasts()

func _enable_raycasts():
	for raycast in rider_raycasts.get_children():
		raycast.collision_mask = 1 << 5
		raycast.cast_to.y = -64
		raycast.enabled = true

func _shift_riders(velocity, delta):
	var riders = []
	for raycast in rider_raycasts.get_children():
		if raycast is RayCast2D:
			if raycast.is_colliding():
				var collider = raycast.get_collider()
				if collider is KinematicBody2D && !riders.has(collider):
					collider.move_and_slide(velocity, Global.UP_VEC)
					riders.append(collider)
					