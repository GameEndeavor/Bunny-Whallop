extends Node2D

const LIMIT_BORDER = 128
const MIN_X_LIMIT = 640
const MIN_Y_LIMIT = 384

onready var player = $Characters/Player
onready var camera = $Characters/Player/PlatformerCamera
onready var tilemap = $Tilemaps/Layer0

func _ready():
	_auto_limit_camera()

# Kill the player if they move outside of the tileset.
func _process(delta):
	if (player.position.x < camera.limit_left && player.position.x < -MIN_X_LIMIT) \
			|| (player.position.y < camera.limit_top && player.position.y < -MIN_Y_LIMIT) \
			|| (player.position.x > camera.limit_right && player.position.x > MIN_X_LIMIT) \
			|| (player.position.y > camera.limit_bottom && player.position.y > MIN_Y_LIMIT):
		player.kill()

# Set camera's limits to used area of the main tilemap.
func _auto_limit_camera():
	var rect = tilemap.get_used_rect()
	camera.limit_left = min(rect.position.x * tilemap.cell_size.x + LIMIT_BORDER, -MIN_X_LIMIT)
	camera.limit_top = min(rect.position.y * tilemap.cell_size.y + LIMIT_BORDER, -MIN_Y_LIMIT)
	camera.limit_right = max((rect.size.x + rect.position.x) * tilemap.cell_size.x - LIMIT_BORDER, MIN_X_LIMIT)
	camera.limit_bottom = max((rect.size.y + rect.position.y) * tilemap.cell_size.y - LIMIT_BORDER, MIN_Y_LIMIT)