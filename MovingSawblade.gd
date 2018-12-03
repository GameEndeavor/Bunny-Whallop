tool
extends Node2D

const TRANS = Tween.TRANS_QUAD
const EASE = Tween.EASE_IN_OUT
const DRAW_COLOR = Color(1.0, 0.0, 0.0)


export (Vector2) var move_to = Vector2(0, 256)
export (float) var move_time = 4.0
onready var neutral_position = $SawBlade.position

onready var blade = $SawBlade
onready var tween = $Tween

func _ready():
	if !Engine.is_editor_hint():
		_move_blade()
	else:
		upate()

func _move_blade():
	var target_position = neutral_position
	if blade.position != move_to + neutral_position:
		target_position = move_to + neutral_position
	
	tween.interpolate_property(blade, "position", blade.position, target_position, move_time, TRANS, EASE)
	tween.start()

func _on_Tween_tween_completed(object, key):
	_move_blade()

func _draw():
	if Engine.is_editor_hint():
		draw_line(blade.position, move_to, DRAW_COLOR)