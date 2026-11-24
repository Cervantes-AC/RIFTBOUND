class_name RemoteController
extends RefCounted
## Host-side controller for the guest's fighter. The guest only sends *intent* (stick + button presses);
## the host simulates everything, so the guest cannot cheat damage, cooldowns or the match result.

const BTN_JUMP_HELD := 1
const BTN_DOWN := 2

var _move := 0.0
var _mask := 0
var _latched: Dictionary = {}
var _intent := Intent.new()


func receive_input(move: float, mask: int) -> void:
	_move = clampf(move, -1.0, 1.0)
	_mask = mask


func receive_press(button: String) -> void:
	if button in ["jump", "attack", "dodge", "skill1", "skill2", "skill3"]:
		_latched[button] = true


func update(_fighter, _delta: float) -> Intent:
	var it := _intent
	it.clear()
	it.move = _move
	it.down = (_mask & BTN_DOWN) != 0
	it.jump_held = (_mask & BTN_JUMP_HELD) != 0
	it.jump_pressed = _latched.has("jump")
	it.attack_pressed = _latched.has("attack")
	it.dodge_pressed = _latched.has("dodge")
	it.skill_pressed[0] = _latched.has("skill1")
	it.skill_pressed[1] = _latched.has("skill2")
	it.skill_pressed[2] = _latched.has("skill3")
	_latched.clear()
	return it
