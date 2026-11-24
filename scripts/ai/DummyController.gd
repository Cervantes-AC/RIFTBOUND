class_name DummyController
extends RefCounted
## Training-room opponent: stands still, faces you and throws a weak basic attack every few seconds so you can
## practise dodging into a COUNTER. It never moves, never uses skills and is healed back up by the training room.

var _intent := Intent.new()
var _t := 2.5


func update(f: Fighter, delta: float) -> Intent:
	_intent.clear()
	if f.world == null or f.is_dead():
		return _intent
	var target: Fighter = f.world.nearest_enemy(f)
	if target == null:
		return _intent
	_t -= delta
	if _t <= 0.0 and absf(target.global_position.x - f.global_position.x) < 140.0:
		_t = 3.0
		_intent.attack_pressed = true
	return _intent
