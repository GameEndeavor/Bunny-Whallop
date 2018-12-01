extends Node

func get_velocity_from_height(height):
	return -sqrt(2 * Global.gravity * height)