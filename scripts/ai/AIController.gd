class_name AIController
extends RefCounted
## Difficulty-scaled computer opponent. It produces the same Intent a human would, one decision every
## `reaction` seconds (smaller = smarter/faster). Behaviour depends on class archetype and the skill kinds.
## params: reaction, aggression, speed, damage, dodge, skill  (see GameState.AI_PRESETS and levels.json)

var params: Dictionary
var is_boss := false
var rng := RandomNumberGenerator.new()
var _intent := Intent.new()
var _think_t := 0.0
var _move := 0.0
var _hold_jump := false
var _strafe_t := 0.0
var _strafe_dir := 1.0


func _init(p_params: Dictionary = {}, boss: bool = false) -> void:
	params = p_params
	is_boss = boss
	rng.randomize()
	_think_t = rng.randf_range(0.2, 0.6)  # small delay at the start of a match


func update(f: Fighter, delta: float) -> Intent:
	var it := _intent
	it.clear()
	if f.world == null or f.is_dead():
		return it
	var target: Fighter = f.world.nearest_enemy(f)
	if target == null:
		return it
	_think_t -= delta
	_strafe_t -= delta
	it.move = _move
	it.jump_held = _hold_jump
	_hazard_reflex(f, it)
	if _think_t > 0.0:
		return it
	var reaction: float = float(params.get("reaction", 0.4))
	_think_t = reaction * rng.randf_range(0.7, 1.3)
	_decide(f, target, it)
	return it


func _is_ranged(f: Fighter) -> bool:
	return f.data.archetype != "Melee"


func _decide(f: Fighter, t: Fighter, it: Intent) -> void:
	var dx := t.global_position.x - f.global_position.x
	var dist := absf(dx)
	var dy := t.global_position.y - f.global_position.y
	var dir := 1.0 if dx >= 0.0 else -1.0
	var aggression: float = float(params.get("aggression", 0.5))
	var hp_ratio := f.health.ratio()
	var ranged := _is_ranged(f)
	var low_hp := hp_ratio < 0.35
	_hold_jump = false

	# ---- positioning
	var pref_min := 70.0
	var pref_max := 95.0
	if ranged:
		pref_min = 280.0 if f.data.archetype == "Ranged" else 240.0
		pref_max = 520.0
	if f.state == Fighter.State.ACTION or f.state == Fighter.State.HURT:
		pass
	if dist > pref_max:
		_move = dir if rng.randf() < 0.55 + 0.45 * aggression else 0.0
	elif dist < pref_min:
		if ranged:
			_move = -dir if _can_retreat(f, -dir) else dir * 0.0
		else:
			_move = 0.0
			if rng.randf() < 0.25 * (1.0 - aggression) and _strafe_t <= 0.0:
				_strafe_dir = -dir
				_strafe_t = 0.5
			if _strafe_t > 0.0:
				_move = _strafe_dir * 0.8
	else:
		_move = 0.0
		if ranged and rng.randf() < 0.35:
			_move = _strafe_dir * 0.6
	if low_hp and not is_boss and rng.randf() < 0.4:
		_move = -dir if _can_retreat(f, -dir) else _move

	# ---- vertical movement
	if dy < -110.0 and dist < 340.0 and f.is_on_floor() and rng.randf() < 0.7:
		it.jump_pressed = true
		_hold_jump = true
	elif dy < -230.0 and not f.is_on_floor() and f.data.max_jumps > 1:
		it.jump_pressed = true
	elif dy > 110.0 and f.is_on_floor() and dist < 220.0 and rng.randf() < 0.4:
		it.down = true
		it.jump_pressed = true
	elif f.is_on_floor() and rng.randf() < 0.04:
		it.jump_pressed = true

	# ---- defence
	var dodge_chance: float = float(params.get("dodge", 0.3))
	var threatened := _threat_near(f, t)
	if threatened and rng.randf() < dodge_chance + (0.2 if is_boss else 0.0):
		if f.dodge_cooldown_left() <= 0.0:
			it.dodge_pressed = true
			it.move = dir if rng.randf() < 0.5 else -dir
			_move = it.move
			return

	# ---- offence
	var aligned := absf(dy) < 110.0
	var skill_chance: float = float(params.get("skill", 0.5))
	for i in 3:
		if not f.skills.is_ready(i + 1):
			continue
		if rng.randf() > skill_chance:
			continue
		if _skill_useful(f, t, f.data.skills[i], dist, dy, aligned, threatened, low_hp):
			it.skill_pressed[i] = true
			if f.data.skills[i].kind in ["blink", "evade"]:
				it.move = (-dir if low_hp or threatened else dir)
			return
	if f.skills.is_ready(0):
		var reach := 105.0 if not ranged else 700.0
		if f.data.basic.kind == "melee":
			reach = float(f.data.basic.p("reach", 50)) + float(f.data.basic.p("w", 80)) * 0.5 + 18.0
		if dist < reach and (aligned or dy > 0.0 and dy < 160.0) and rng.randf() < 0.45 + 0.55 * aggression:
			it.attack_pressed = true


func _skill_useful(f: Fighter, t: Fighter, sk: SkillData, dist: float, dy: float, aligned: bool, threatened: bool, low_hp: bool) -> bool:
	match sk.kind:
		"projectile":
			return dist > 140.0 and dist < 720.0 and aligned
		"melee", "multi_melee":
			return dist < float(sk.p("reach", 50)) + float(sk.p("w", 80)) * 0.5 + 10.0 and aligned
		"dash_hit":
			return dist > 90.0 and dist < float(sk.p("dist", 280)) and aligned
		"slam":
			return dist < 190.0 and aligned
		"spin":
			return dist < float(sk.p("radius", 100)) + 30.0 and absf(dy) < 90.0
		"nova":
			return dist < float(sk.p("radius", 180)) and absf(dy) < 120.0
		"zone":
			if str(sk.p("target", "forward")) == "enemy":
				return dist < 800.0
			return dist > 150.0 and dist < 460.0
		"dash_through":
			return dist > 110.0 and dist < float(sk.p("dist", 300)) and aligned
		"shield":
			return threatened or (t.is_attacking() and dist < 220.0)
		"evade":
			if str(sk.p("dir", "forward")) == "back":
				return threatened or dist < 160.0
			return threatened or dist > 320.0
		"blink":
			return threatened or low_hp or dist < 120.0
	return false


func _threat_near(f: Fighter, t: Fighter) -> bool:
	var dist := absf(t.global_position.x - f.global_position.x)
	if t.is_attacking() and dist < 230.0:
		return true
	if f.world:
		for p in f.world.get_projectiles():
			if int(p.spec["team"]) == f.team or p.visual_only:
				continue
			var rel: float = p.global_position.x - f.global_position.x
			if absf(rel) < 260.0 and signf(rel) != signf(p.velocity.x) and absf(p.global_position.y - f.center().y) < 70.0:
				return true
	return false


func _can_retreat(f: Fighter, dir: float) -> bool:
	if f.world == null or f.world.arena == null:
		return true
	var b: Rect2 = f.world.arena.bounds
	var nx := f.global_position.x + dir * 120.0
	return nx > b.position.x + 30.0 and nx < b.end.x - 30.0


## Per-frame reflexes that do not wait for the next "thought": do not walk into lava, hop over the pit.
func _hazard_reflex(f: Fighter, it: Intent) -> void:
	var a: Arena = f.world.arena if f.world else null
	if a == null or not f.is_on_floor():
		return
	if a.has_pit() and absf(it.move) > 0.1:
		var x := f.global_position.x
		var ahead := x + it.move * 70.0
		if f.global_position.y <= a.floor_y + 4.0 and ahead > a.pit.x - 20.0 and ahead < a.pit.y + 20.0 and not (x > a.pit.x and x < a.pit.y):
			it.jump_pressed = true
			it.jump_held = true
			_hold_jump = true
	for o in a.orbs:
		var op := a.orb_position(o, a.time)
		if f.center().distance_to(op) < float(o["r"]) + 90.0 and f.dodge_cooldown_left() <= 0.0 and rng.randf() < 0.1:
			it.dodge_pressed = true
