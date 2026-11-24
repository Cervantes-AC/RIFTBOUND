class_name CombatComponent
extends Node
## Turns a SkillData (by `kind`) into hitboxes, projectiles, area effects and movement.
## Only the authority (offline game or online host) ever runs this; guests receive results.

var fighter: Fighter
var _scheduled: Array = []  # {t: float, cb: Callable}
var _owned_boxes: Array = []


func setup(f: Fighter) -> void:
	fighter = f


static func style_for(sk: SkillData) -> String:
	match sk.kind:
		"melee", "multi_melee", "dash_hit":
			return "slash"
		"slam":
			return "slam"
		"spin":
			return "spin"
		"shield":
			return "guard"
		"zone", "nova":
			return "cast_up"
		"evade", "dash_through", "blink":
			return "dash"
		"projectile":
			var st: String = str(sk.p("style", "orb"))
			return "shoot" if st in ["arrow", "arrow_big", "bullet", "shell"] else "cast"
	return "slash"


func _physics_process(delta: float) -> void:
	if _scheduled.is_empty() or fighter.is_puppet:
		return
	var due: Array = []
	for item in _scheduled:
		item["t"] -= delta
		if item["t"] <= 0.0:
			due.append(item)
	for item in due:
		_scheduled.erase(item)
		if not fighter.is_dead():
			item["cb"].call()


func cancel(_f: Fighter) -> void:
	_scheduled.clear()
	for b in _owned_boxes:
		if is_instance_valid(b):
			b.queue_free()
	_owned_boxes.clear()


func end_active(f: Fighter) -> void:
	if f.action_skill != null and f.action_skill.kind == "dash_through":
		f.auto_face_enemy()


## Executes the skill's effect. Returns how long the "active" phase lasts.
func fire(sk: SkillData, f: Fighter, it: Intent) -> float:
	if f.is_dead():
		return 0.0
	match sk.kind:
		"melee":
			return _fire_melee(sk, f, 0.12, 0.0)
		"multi_melee":
			var hits := int(sk.p("hits", 3))
			var interval: float = sk.p("interval", 0.1)
			return _fire_melee(sk, f, hits * interval, interval)
		"dash_hit":
			return _fire_dash_hit(sk, f)
		"slam":
			return _fire_slam(sk, f)
		"shield":
			f.set_status("shield", sk.p("dur", 3.0), sk.p("reduction", 0.7))
			AudioManager.play_sfx("shield")
			_fx("ring", f.global_position + Vector2(0, -45), {"color": sk.color, "radius": 90.0})
			return 0.05
		"spin":
			return _fire_spin(sk, f)
		"dash_through":
			return _fire_dash_through(sk, f)
		"projectile":
			return _fire_projectile(sk, f)
		"zone":
			return _fire_zone(sk, f)
		"nova":
			return _fire_nova(sk, f)
		"evade":
			return _fire_evade(sk, f)
		"blink":
			return _fire_blink(sk, f, it)
	return 0.1


# ------------------------------------------------------------------ helpers
func make_hit(sk: SkillData, dmg: float = -1.0) -> Dictionary:
	var base := sk.damage if dmg < 0.0 else dmg
	return {
		"attacker": fighter, "dmg": base * fighter.outgoing_multiplier(),
		"kb": float(sk.p("kb", 0.0)), "kb_up": float(sk.p("kb_up", 0.0)),
		"stun": float(sk.p("stun", 0.0)), "status": str(sk.p("status", "")),
		"status_dur": float(sk.p("status_dur", 1.0)), "from_x": fighter.global_position.x,
		"source": sk.id, "team": fighter.team, "color": sk.color,
	}


func _fx(kind: String, pos: Vector2, data: Dictionary = {}) -> void:
	if fighter.world:
		fighter.world.fx(kind, pos, data)


func _chest() -> float:
	return -46.0 * fighter.data.body_scale


func _spawn_box(size: Vector2, offset: Vector2, lifetime: float, hit: Dictionary, interval: float = 0.0, circle: bool = false, follow: bool = true) -> Hitbox:
	var hb := Hitbox.new()
	hb.setup(fighter, hit, size, lifetime, interval, circle)
	if follow:
		fighter.add_child(hb)
		hb.position = Vector2(offset.x * fighter.facing, offset.y)
		_owned_boxes.append(hb)
	else:
		fighter.get_parent().add_child(hb)
		hb.global_position = fighter.global_position + Vector2(offset.x * fighter.facing, offset.y)
	return hb


func _fire_melee(sk: SkillData, f: Fighter, lifetime: float, interval: float) -> float:
	var size := Vector2(sk.p("w", 80), sk.p("h", 60))
	_spawn_box(size, Vector2(sk.p("reach", 50), _chest()), lifetime, make_hit(sk), interval)
	AudioManager.play_sfx("swing", 0.9 + randf() * 0.2)
	_fx("slash", f.global_position + Vector2(f.facing * float(sk.p("reach", 50)), _chest()), {"dir": f.facing, "color": sk.color, "w": size.x})
	return lifetime


func _fire_dash_hit(sk: SkillData, f: Fighter) -> float:
	var dur: float = sk.p("dur", 0.25)
	f.start_dash(f.facing * float(sk.p("dist", 280)) / dur, dur)
	var size := Vector2(sk.p("w", 70), sk.p("h", 80))
	_spawn_box(size, Vector2(40, _chest()), dur, make_hit(sk))
	AudioManager.play_sfx("dash")
	_fx("trail", f.global_position, {"dir": f.facing, "color": sk.color})
	return dur


func _fire_slam(sk: SkillData, f: Fighter) -> float:
	var size := Vector2(sk.p("w", 150), sk.p("h", 60))
	_spawn_box(size, Vector2(sk.p("reach", 60), -30.0), 0.14, make_hit(sk))
	var spd: float = sk.p("wave_speed", 400)
	var spec := _projectile_spec(sk, f.global_position + Vector2(f.facing * 90.0, -26.0), Vector2(f.facing * spd, 0.0))
	spec["style"] = "wave"
	spec["dmg"] = float(sk.p("wave_dmg", 10)) * f.outgoing_multiplier()
	spec["life"] = float(sk.p("wave_range", 360)) / spd
	spec["radius"] = 30.0
	spec["ground"] = true
	spec["kb"] = float(sk.p("kb", 300)) * 0.6
	spec["kb_up"] = float(sk.p("kb_up", 400)) * 0.6
	if f.world:
		f.world.spawn_projectile(spec)
	AudioManager.play_sfx("explosion", 0.8)
	_fx("shockwave", f.global_position + Vector2(f.facing * 60.0, 0.0), {"color": sk.color, "radius": 150.0})
	if f.world:
		f.world.shake(8.0)
	return 0.14


func _fire_spin(sk: SkillData, f: Fighter) -> float:
	var dur: float = sk.p("dur", 0.5)
	var hits := int(sk.p("hits", 3))
	var r: float = sk.p("radius", 100)
	_spawn_box(Vector2(r, r), Vector2(0, _chest()), dur, make_hit(sk), dur / maxf(hits, 1), true)
	AudioManager.play_sfx("swing", 0.7)
	_fx("spin", f.global_position + Vector2(0, _chest()), {"color": sk.color, "radius": r, "dur": dur})
	return dur


func _fire_dash_through(sk: SkillData, f: Fighter) -> float:
	var dur: float = sk.p("dur", 0.2)
	f.set_status("invuln", sk.p("invuln", 0.3))
	f.set_status("empower", sk.p("empower_dur", 3.0), sk.p("empower", 1.6))
	f.start_dash(f.facing * float(sk.p("dist", 300)) / dur, dur)
	AudioManager.play_sfx("dash", 1.3)
	_fx("trail", f.global_position, {"dir": f.facing, "color": sk.color})
	return dur


func _projectile_spec(sk: SkillData, pos: Vector2, vel: Vector2) -> Dictionary:
	return {
		"style": str(sk.p("style", "orb")), "color": sk.color, "pos": pos, "vel": vel,
		"dmg": sk.damage * fighter.outgoing_multiplier(), "kb": float(sk.p("kb", 0.0)),
		"kb_up": float(sk.p("kb_up", 0.0)), "stun": float(sk.p("stun", 0.0)),
		"pierce": int(sk.p("pierce", 0)), "explode": float(sk.p("explode", 0.0)),
		"explode_dmg": float(sk.p("explode_dmg", 0.0)) * fighter.outgoing_multiplier(),
		"homing": float(sk.p("homing", 0.0)), "life": float(sk.p("life", 1.0)),
		"radius": 12.0, "status": str(sk.p("status", "")), "status_dur": float(sk.p("status_dur", 1.0)),
		"team": fighter.team, "owner": fighter.slot, "ground": false, "source": sk.id,
	}


func _fire_projectile(sk: SkillData, f: Fighter) -> float:
	var count := int(sk.p("count", 1))
	var stagger: float = sk.p("stagger", 0.0)
	_launch(sk)
	for i in range(1, count):
		_scheduled.append({"t": stagger * i, "cb": _launch.bind(sk)})
	return stagger * maxi(count - 1, 0) + 0.02


func _launch(sk: SkillData) -> void:
	var f := fighter
	var origin := f.global_position + Vector2(f.facing * 30.0 * f.data.body_scale, _chest() - 4.0)
	var spec := _projectile_spec(sk, origin, Vector2(f.facing * float(sk.p("speed", 700)), 0.0))
	var style: String = spec["style"]
	if style == "arrow_big":
		spec["radius"] = 16.0
	elif style == "shell":
		spec["radius"] = 14.0
	elif style == "bullet":
		spec["radius"] = 8.0
	elif style in ["bolt", "dark", "chain"]:
		spec["radius"] = 16.0
	if f.world:
		f.world.spawn_projectile(spec)
	var cast := style in ["orb", "bolt", "dark", "chain"]
	AudioManager.play_sfx("magic" if cast else "shoot", 0.9 + randf() * 0.2)
	_fx("muzzle", origin, {"color": sk.color, "dir": f.facing})


func _fire_zone(sk: SkillData, f: Fighter) -> float:
	var x := f.global_position.x
	if str(sk.p("target", "forward")) == "enemy":
		var e = f.world.nearest_enemy(f) if f.world else null
		x = e.global_position.x if e != null else f.global_position.x + f.facing * 300.0
	else:
		x += f.facing * float(sk.p("reach", 300))
	var floor_y: float = f.world.arena.floor_y if (f.world and f.world.arena) else f.global_position.y
	if f.world and f.world.arena:
		var b: Rect2 = f.world.arena.bounds
		x = clampf(x, b.position.x, b.end.x)
	var spec := {
		"style": str(sk.p("style", "arrows")), "color": sk.color, "pos": Vector2(x, floor_y),
		"radius": float(sk.p("radius", 120)), "delay": float(sk.p("delay", 0.5)),
		"ticks": int(sk.p("ticks", 1)), "interval": float(sk.p("interval", 0.2)),
		"dmg": sk.damage * f.outgoing_multiplier(), "kb": float(sk.p("kb", 0)),
		"kb_up": float(sk.p("kb_up", 0)), "stun": float(sk.p("stun", 0)),
		"status": str(sk.p("status", "")), "status_dur": float(sk.p("status_dur", 1.0)),
		"team": f.team, "owner": f.slot, "source": sk.id,
	}
	if f.world:
		f.world.spawn_area(spec)
	AudioManager.play_sfx("magic", 0.6)
	return 0.05


func _fire_nova(sk: SkillData, f: Fighter) -> float:
	var r: float = sk.p("radius", 180)
	_spawn_box(Vector2(r, r), Vector2(0, _chest()), 0.12, make_hit(sk), 0.0, true)
	AudioManager.play_sfx("nova")
	_fx("ring", f.global_position + Vector2(0, _chest()), {"color": sk.color, "radius": r})
	_fx("burst", f.global_position + Vector2(0, _chest()), {"color": sk.color, "count": 18})
	if f.world:
		f.world.shake(6.0)
	return 0.12


func _fire_evade(sk: SkillData, f: Fighter) -> float:
	var dir := f.facing
	if str(sk.p("dir", "forward")) == "back":
		dir = -f.facing
	var dur: float = sk.p("dur", 0.2)
	f.set_status("invuln", sk.p("invuln", 0.25))
	if sk.p("haste", 0.0) > 0.0:
		f.set_status("haste", sk.p("haste_dur", 3.0), sk.p("haste", 1.3))
	if sk.p("cdr", 0.0) > 0.0:
		f.skills.reduce_all(sk.p("cdr", 0.0), f.action_slot)
	f.start_dash(dir * float(sk.p("dist", 250)) / dur, dur)
	AudioManager.play_sfx("dash")
	_fx("trail", f.global_position, {"dir": dir, "color": sk.color})
	return dur


func _fire_blink(sk: SkillData, f: Fighter, it: Intent) -> float:
	var dir := f.facing
	if it != null and absf(it.move) > 0.3:
		dir = 1 if it.move > 0.0 else -1
	var origin := f.global_position
	var burst := make_hit(sk)
	var hb := Hitbox.new()
	hb.setup(f, burst, Vector2(sk.p("burst_radius", 90), sk.p("burst_radius", 90)), 0.12, 0.0, true)
	f.get_parent().add_child(hb)
	hb.global_position = origin + Vector2(0, _chest())
	var target_x := origin.x + dir * float(sk.p("dist", 280))
	if f.world and f.world.arena:
		var b: Rect2 = f.world.arena.bounds
		target_x = clampf(target_x, b.position.x, b.end.x)
	f.set_status("invuln", sk.p("invuln", 0.25))
	f.global_position.x = target_x
	f.facing = dir
	AudioManager.play_sfx("magic", 1.6)
	_fx("ring", origin + Vector2(0, _chest()), {"color": sk.color, "radius": 90.0})
	_fx("ring", f.global_position + Vector2(0, _chest()), {"color": sk.color, "radius": 70.0})
	_fx("burst", f.global_position + Vector2(0, _chest()), {"color": sk.color, "count": 12})
	return 0.05
