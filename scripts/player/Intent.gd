class_name Intent
extends RefCounted
## One frame of "what the controller wants". Produced by player input, AI or the network
## and consumed by Fighter, so there is exactly one movement/combat implementation.

var move: float = 0.0          # -1 (left) .. 1 (right)
var down: bool = false         # drop through one-way platforms (with jump)
var jump_pressed: bool = false
var jump_held: bool = false
var attack_pressed: bool = false
var dodge_pressed: bool = false
var skill_pressed: Array[bool] = [false, false, false]


func clear() -> void:
	move = 0.0
	down = false
	jump_pressed = false
	jump_held = false
	attack_pressed = false
	dodge_pressed = false
	skill_pressed = [false, false, false]
