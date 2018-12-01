extends Camera2D

const SHIFT_TRANS = Tween.TRANS_CIRC
const SHIFT_EASE = Tween.EASE_OUT
const SHIFT_DURATION = 0.5
const LOOK_AHEAD_FACTOR = 0.2
const STEADY_TOP_MARGIN = 0.8

var facing = 0
var is_steady = false setget _set_is_steady
var default_drag_margin_top

onready var previous_position = get_camera_position()
onready var shift_tween = $ShiftTween

func _ready():
	default_drag_margin_top = drag_margin_top

func _process(delta):
	_check_facing()
	previous_position = get_camera_position()

# Check to see if the camera has moved in the opposite direction
# If it has then shift it's position so that it's in front of the player
func _check_facing():
	var new_facing = sign((get_camera_position() - previous_position).x)
	if new_facing != 0 && new_facing != facing:
		facing = new_facing
		
		var target_offset = get_viewport_rect().size.x * LOOK_AHEAD_FACTOR * facing
		
		shift_tween.interpolate_property(self, "position:x", position.x, target_offset, SHIFT_DURATION, SHIFT_TRANS, SHIFT_EASE)
		shift_tween.start()

# If "is_steady" is changed outside of this script, then this method will
# trigger and adjust the top margin. This is meant to minimize camera movement when
# The player is jumping.
func _set_is_steady(value):
	if value:
		drag_margin_top = STEADY_TOP_MARGIN
	else:
		drag_margin_top = default_drag_margin_top