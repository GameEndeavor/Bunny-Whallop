extends Node2D

const TRANS = Tween.TRANS_QUAD
const EASE = Tween.EASE_IN_OUT
const DRAW_COLOR = Color(1.0, 0.0, 0.0)
const INSET_DISTANCE = 8
const SIDE_DISTANCE_SHIFT = 128 - 2 * INSET_DISTANCE

export (int) var side = 1

export (Vector2) var move_to = Vector2(0, 256)
export (float) var move_time = 1.5
onready var neutral_position = $SawBlade.position

onready var blade = $SawBlade
onready var tween = $Tween
onready var trigger_tween = $TriggerTween

func _ready():
	if !Engine.is_editor_hint():
		_move_blade()
	
	position.x += INSET_DISTANCE if side == Global.RIGHT else -INSET_DISTANCE

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

func _on_Button_trigger_changed(trigger_state):
	if trigger_state && $TriggerTimer.is_stopped():
		trigger_tween.interpolate_property(self, "position:x", self.position.x, self.position.x + SIDE_DISTANCE_SHIFT * side, $TriggerTimer.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		trigger_tween.start()
		$TriggerTimer.start()
		side = -side
