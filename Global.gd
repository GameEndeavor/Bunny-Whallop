extends Node

const UNIT_SIZE = 64

const PLAYER_JUMP_HEIGHT = 3.75 * UNIT_SIZE
const JUMP_DURATION = 0.4

const UP_VEC = Vector2(0, -1)

const LEFT = -1
const RIGHT = 1

onready var gravity = 2 * PLAYER_JUMP_HEIGHT / pow(JUMP_DURATION, 2)