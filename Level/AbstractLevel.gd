extends Node2D

signal level_complete()

const LIMIT_BORDER = 128
const MIN_X_LIMIT = 640
const MIN_Y_LIMIT = 384

onready var player = $Characters/Player
onready var camera = $Characters/Player/PlatformerCamera
onready var tilemap = $Tilemaps/Layer0

var is_level_won = false

func _ready():
	_auto_limit_camera()
	connect("level_complete", player, "_on_level_complete")

# Kill the player if they move outside of the tileset.
func _process(delta):
	# Kill the player if they go out of bounds
	if (player.position.x < camera.limit_left && player.position.x < -MIN_X_LIMIT) \
			|| (player.position.y < camera.limit_top && player.position.y < -MIN_Y_LIMIT) \
			|| (player.position.y > camera.limit_bottom && player.position.y > MIN_Y_LIMIT):
		player.kill()
	elif player.position.x > camera.limit_right && player.position.x > MIN_X_LIMIT:
		Global.next_level()
#	# If the player walks off of the right side of the screen then they won
#	elif !is_level_won && player.position.x > camera.limit_right && player.position.x > MIN_X_LIMIT:

# Set camera's limits to used area of the main tilemap.
func _auto_limit_camera():
	var rect = tilemap.get_used_rect()
	camera.limit_left = min(rect.position.x * tilemap.cell_size.x + LIMIT_BORDER, -MIN_X_LIMIT)
	camera.limit_top = min(rect.position.y * tilemap.cell_size.y + LIMIT_BORDER, -MIN_Y_LIMIT)
	camera.limit_right = max((rect.size.x + rect.position.x) * tilemap.cell_size.x - LIMIT_BORDER, MIN_X_LIMIT)
	camera.limit_bottom = max((rect.size.y + rect.position.y) * tilemap.cell_size.y - LIMIT_BORDER, MIN_Y_LIMIT)

func _level_complete():
	is_level_won = true
	emit_signal("level_complete")
	$TransitionAnimation.play("scene_end")
	# Wait before transitioning to a new scene
#	yield(get_tree().create_timer(1.2), "timeout")
#	Global.next_level()

func _on_LevelFinish_body_entered(body):
	if body.is_in_group("player"):
		_level_complete()