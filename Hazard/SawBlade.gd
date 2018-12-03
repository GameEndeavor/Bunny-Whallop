extends Area2D



func _on_SawBlade_area_entered(area):
	var entity = area.get_parent()
	if entity.has_method("kill"):
		entity.kill()
