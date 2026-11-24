class_name LocalController
extends RefCounted
## Reads the shared Input actions. Keyboard maps to them directly; the on-screen TouchControls
## press/release the very same actions, so touch and keyboard behave identically.

var _intent := Intent.new()


func update(_fighter, _delta: float) -> Intent:
	var it := _intent
	it.move = Input.get_axis("move_left", "move_right")
	it.down = Input.get_action_strength("move_down") > 0.6
	it.jump_pressed = Input.is_action_just_pressed("jump")
	it.jump_held = Input.is_action_pressed("jump")
	it.attack_pressed = Input.is_action_just_pressed("attack")
	it.dodge_pressed = Input.is_action_just_pressed("dodge")
	it.skill_pressed[0] = Input.is_action_just_pressed("skill1")
	it.skill_pressed[1] = Input.is_action_just_pressed("skill2")
	it.skill_pressed[2] = Input.is_action_just_pressed("skill3")
	return it
