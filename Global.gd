extends Node

const UNIT_SIZE = 64

const PLAYER_JUMP_HEIGHT = 3.75 * UNIT_SIZE
const JUMP_DURATION = 0.4

const UP_VEC = Vector2(0, -1)

const LEFT = -1
const RIGHT = 1

const END_SCENE = "res://EndScene.tscn"

var current_level = 0

onready var gravity = 2 * PLAYER_JUMP_HEIGHT / pow(JUMP_DURATION, 2)

const LEVELS = [
	"res://Level/Levels/FirstWallSteps.tscn",
	"res://Level/Levels/ThePits.tscn",
	"res://Level/Levels/TheClimb.tscn",
	"res://Level/Levels/OfcSaws.tscn"
]

func next_level():
	current_level += 1
	load_level_index(current_level)

func load_level_index(level_index):
	if level_index < LEVELS.size():
		get_tree().change_scene(LEVELS[level_index])
	else:
		get_tree().change_scene(END_SCENE)