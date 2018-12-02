extends KinematicBody2D

var velocity = Vector2()

func _physics_process(delta):
	velocity.y += Global.gravity * delta
	
	velocity = move_and_slide(velocity, Global.UP_VEC)

func _on_Hitbox_body_entered(body):
	queue_free()
