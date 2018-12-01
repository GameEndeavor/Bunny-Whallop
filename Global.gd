extends Node

const UNIT_SIZE = 64

const PLAYER_JUMP_HEIGHT = 2.25 * UNIT_SIZE
const JUMP_DURATION = 0.4

const UP = Vector2(0, -1)

onready var gravity = 2 * PLAYER_JUMP_HEIGHT / pow(JUMP_DURATION, 2)