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
		"slam", "retaliate":
			return "slam"
		"bastion":
			return "guard"
		"flurry", "echo":
			return "dash"
		"attune", "discharge":
			return "cast"
		"riftstep":
			return "dash"
		"ward":
			return "guard"
		"collapse", "siphon", "bubble", "summon", "howl":
			return "cast_up"
		"command":
			return "shoot"
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
			return "shoot" if st in ["arrow", "arrow_big", "bullet", "shell", "mark"] else "cast"
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
	f.mech.begin_fire(sk)
	var t := _fire_kind(sk, f, it)
	f.mech.end_fire()
	return t


func _fire_kind(sk: SkillData, f: Fighter, it: Intent) -> float:
	match sk.kind:
		"riftstep":
			return _fire_riftstep(sk, f)
		"collapse":
			return _fire_collapse(sk, f)
		"ward":
			return _fire_ward(sk, f)
		"discharge":
			return _fire_discharge(sk, f)
		"siphon":
			return _fire_siphon(sk, f)
		"bubble":
			return _fire_bubble(sk, f)
		"command":
			return _fire_command(sk, f)
		"summon":
			return _fire_summon(sk, f)
		"howl":
			return _fire_howl(sk, f)
		"retaliate":
			return _fire_retaliate(sk, f)
		"bastion":
			return _fire_bastion(sk, f)
		"flurry":
			return _fire_flurry(sk, f)
		"attune":
			return 0.05
		"echo":
			return _fire_echo(sk, f)
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
		"source": sk.id, "team": fighter.team, "color": fighter.mech.hit_color(sk),
		"element": fighter.mech.element_for(sk),
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
		"style": str(sk.p("style", "orb")), "color": fighter.mech.hit_color(sk), "pos": pos, "vel": vel,
		"element": fighter.mech.element_for(sk),
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
	var fan := float(sk.p("fan", 0.0))
	if str(sk.p("self_status", "")) != "":
		f.set_status(str(sk.p("self_status")), float(sk.p("self_dur", 3.0)))
	if fan > 0.0 and count > 1:   # fan pattern: all bullets at once, spread over +-fan degrees
		for i in count:
			_launch(sk, deg_to_rad(lerpf(-fan, fan, float(i) / float(count - 1))))
		return 0.05
	_launch(sk)
	for i in range(1, count):
		_scheduled.append({"t": stagger * i, "cb": _launch.bind(sk)})
	return stagger * maxi(count - 1, 0) + 0.02


func _launch(sk: SkillData, angle: float = 0.0) -> void:
	var f := fighter
	var origin := f.global_position + Vector2(f.facing * 30.0 * f.data.body_scale, _chest() - 4.0)
	var spec := _projectile_spec(sk, origin, Vector2(f.facing * float(sk.p("speed", 700)), 0.0).rotated(angle * f.facing))
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
	if style == "bullet":
		_fx("casing", origin, {"dir": f.facing})
	_fx("muzzle", origin, {"color": sk.color, "dir": f.facing})
	if cast:
		_fx("rune", f.global_position, {"color": sk.color, "radius": 56.0})


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
	if float(sk.p("self_haste", 0.0)) > 0.0:
		f.set_status("haste", float(sk.p("self_haste_dur", 3.0)), float(sk.p("self_haste", 1.3)))
	if float(sk.p("self_cdr", 0.0)) > 0.0:
		f.skills.reduce_all(float(sk.p("self_cdr", 0.0)), f.action_slot)
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
	if sk.damage > 0.0:   # a harmless blink (Time Skip) leaves no hitbox
		var hb := Hitbox.new()
		hb.setup(f, make_hit(sk), Vector2(sk.p("burst_radius", 90), sk.p("burst_radius", 90)), 0.12, 0.0, true)
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


# ------------------------------------------------------------------ class abilities
## Telegraph ring for big abilities and the ultimate banner. Runs when the ability STARTS (wind-up).
func announce(sk: SkillData) -> void:
	var f := fighter
	if f.world == null:
		return
	if sk.is_ultimate:
		_fx("ult", f.global_position, {"color": sk.color})
		_fx("text", f.global_position + Vector2(0, -130), {"text": sk.display_name.to_upper(), "color": sk.color.lightened(0.3), "size": 22})
		f.world.shake(8.0)
		AudioManager.play_sfx("nova", 0.7)
	if int(sk.p("telegraph", 0)) > 0 and sk.windup > 0.0:
		var r := float(sk.p("radius", 0.0))
		var pos := f.global_position
		match sk.kind:
			"slam":
				r = 150.0
				pos += Vector2(f.facing * 60.0, 0.0)
			"retaliate":
				r = 80.0
				pos += Vector2(f.facing * 60.0, 0.0)
			"flurry":
				r = 60.0
			"riftstep":   # mark where the rift will open
				r = 55.0
				var exit: Variant = _rift_exit(sk)
				if exit != null:
					pos = exit
			"command":    # mark where the wolf will land
				r = 60.0
				var prey = f.world.nearest_enemy(f)
				if prey != null:
					pos = prey.global_position
			"ward":
				r = float(sk.p("radius", 170))
			"bubble":
				r = float(sk.p("radius", 160))
				pos = Vector2(_forward_x(float(sk.p("reach", 260))), _floor_y())
			"discharge":
				r = 110.0
			"projectile":
				r = 50.0
				pos += Vector2(f.facing * 40.0, 0.0)
			"zone":
				r = 0.0   # zones draw their own marker on the ground
		if r > 0.0:
			_fx("warn", pos, {"color": sk.color, "radius": r, "dur": sk.windup + 0.05})


## Short ground burst (Shadow Echo expiring). Uses the same AreaEffect as zones.
func burst_at(pos: Vector2, dmg: float, radius: float, color: Color) -> void:
	var f := fighter
	if f.world == null:
		return
	f.world.spawn_area({
		"style": "burst", "color": color, "pos": pos, "radius": radius, "delay": 0.05, "ticks": 1, "interval": 0.1,
		"dmg": dmg * f.outgoing_multiplier(), "kb": 220.0, "kb_up": 200.0, "stun": 0.25, "status": "", "status_dur": 0.0,
		"team": f.team, "owner": f.slot, "source": "echo"})


func _fire_retaliate(sk: SkillData, f: Fighter) -> float:
	var spent: float = f.mech.spent if f.mech is VanguardMech else 0.0
	var hit := make_hit(sk, float(sk.damage) + spent * float(sk.p("scale", 0.28)))
	if spent >= 70.0:
		hit["kb"] = float(hit["kb"]) * 1.3
		hit["stun"] = float(hit["stun"]) + 0.15
	_spawn_box(Vector2(sk.p("w", 130), sk.p("h", 90)), Vector2(sk.p("reach", 62), _chest()), 0.14, hit)
	AudioManager.play_sfx("explosion", 1.0)
	_fx("shockwave", f.global_position + Vector2(f.facing * 70.0, 0.0), {"color": sk.color, "radius": 110.0 + spent})
	_fx("slash", f.global_position + Vector2(f.facing * 60.0, _chest()), {"dir": f.facing, "color": sk.color, "w": 130.0})
	if f.world:
		f.world.shake(6.0 + spent * 0.08)
	return 0.14


func _fire_bastion(sk: SkillData, f: Fighter) -> float:
	var r := float(sk.p("radius", 330))
	if f.world:
		for a in f.world.fighters:
			if a.team == f.team and not a.is_dead() and a.global_position.distance_to(f.global_position) <= r:
				a.set_status("shield", float(sk.p("dur", 4.0)), float(sk.p("reduction", 0.6)))
				_fx("ring", a.global_position + Vector2(0, -45), {"color": sk.color, "radius": 80.0})
	_spawn_box(Vector2(r * 0.5, r * 0.5), Vector2(0, _chest()), 0.12, make_hit(sk), 0.0, true)
	AudioManager.play_sfx("shield")
	_fx("shockwave", f.global_position, {"color": sk.color, "radius": r})
	_fx("ring", f.global_position + Vector2(0, _chest()), {"color": sk.color, "radius": r * 0.8})
	if f.world:
		f.world.shake(9.0)
	return 0.12


## Thousand Cuts: blink next to the nearest enemy (if within range) and slash `hits` times.
func _fire_flurry(sk: SkillData, f: Fighter) -> float:
	var target = f.world.nearest_enemy(f) if f.world else null
	var origin := f.global_position
	if target != null and absf(target.global_position.x - origin.x) <= float(sk.p("range", 460)):
		var side := 1 if origin.x < target.global_position.x else -1   # land on the side we came from
		var x: float = target.global_position.x - side * 60.0
		if f.world.arena:
			var b: Rect2 = f.world.arena.bounds
			x = clampf(x, b.position.x, b.end.x)
		f.global_position = Vector2(x, target.global_position.y)
		f.facing = 1 if target.global_position.x >= f.global_position.x else -1
		_fx("trail", origin, {"dir": f.facing, "color": sk.color})
	var hits := int(sk.p("hits", 8))
	var interval: float = sk.p("interval", 0.09)
	f.set_status("invuln", hits * interval + 0.1)
	_spawn_box(Vector2(sk.p("w", 120), sk.p("h", 100)), Vector2(40, _chest()), hits * interval, make_hit(sk), interval)
	AudioManager.play_sfx("swing", 1.2)
	_fx("spin", f.global_position + Vector2(0, _chest()), {"color": sk.color, "radius": 70.0, "dur": hits * interval})
	return hits * interval


## Shadow Echo: place an echo and jump forward, or (if an echo is active) swap back to it.
func _fire_echo(sk: SkillData, f: Fighter) -> float:
	var m := f.mech as ShadeweaverMech
	if m == null:
		return 0.05
	var origin := f.global_position
	_fx("ghost", origin, {"color": sk.color, "dir": float(f.facing)})
	if m.swapping:
		f.global_position = m.echo_pos
		m.clear_echo()
		f.velocity = Vector2.ZERO
	else:
		var x := origin.x + f.facing * float(sk.p("dist", 170))
		if f.world and f.world.arena:
			var b: Rect2 = f.world.arena.bounds
			x = clampf(x, b.position.x, b.end.x)
		m.place_echo(origin, float(sk.p("life", 3.0)))
		f.global_position.x = x
	f.set_status("invuln", 0.15)
	AudioManager.play_sfx("magic", 1.4)
	_fx("ring", f.global_position + Vector2(0, _chest()), {"color": sk.color, "radius": 70.0})
	_fx("burst", f.global_position + Vector2(0, _chest()), {"color": sk.color, "count": 12})
	return 0.05


# ------------------------------------------------------------------ abilities of the second six
func _floor_y() -> float:
	return fighter.world.arena.floor_y if (fighter.world and fighter.world.arena) else fighter.global_position.y


func _clamp_x(x: float) -> float:
	if fighter.world and fighter.world.arena:
		var b: Rect2 = fighter.world.arena.bounds
		return clampf(x, b.position.x, b.end.x)
	return x


func _forward_x(reach: float) -> float:
	return _clamp_x(fighter.global_position.x + fighter.facing * reach)


## Where Rift Step comes out: behind the nearest enemy in range (Vector2), or null when nobody is in range.
func _rift_exit(sk: SkillData) -> Variant:
	var target = fighter.world.nearest_enemy(fighter) if fighter.world else null
	if target == null or absf(target.global_position.x - fighter.global_position.x) > float(sk.p("range", 520)):
		return null
	return Vector2(_clamp_x(target.global_position.x - target.facing * float(sk.p("behind", 70))), target.global_position.y)


func _fire_riftstep(sk: SkillData, f: Fighter) -> float:
	var origin := f.global_position
	var target = f.world.nearest_enemy(f) if f.world else null
	var exit: Variant = _rift_exit(sk)
	if exit != null:
		f.global_position = exit
		f.facing = 1 if target.global_position.x >= f.global_position.x else -1
	else:
		f.global_position.x = _forward_x(220.0)
	f.set_status("invuln", 0.15)
	_spawn_box(Vector2(sk.p("w", 110), sk.p("h", 80)), Vector2(40, _chest()), 0.14, make_hit(sk))
	AudioManager.play_sfx("magic", 1.5)
	_fx("ring", origin + Vector2(0, _chest()), {"color": sk.color, "radius": 70.0})
	_fx("ring", f.global_position + Vector2(0, _chest()), {"color": sk.color, "radius": 80.0})
	_fx("slash", f.global_position + Vector2(f.facing * 40.0, _chest()), {"dir": f.facing, "color": sk.color, "w": 100.0})
	return 0.14


func _fire_collapse(sk: SkillData, f: Fighter) -> float:
	var r := float(sk.p("radius", 330))
	var pull := float(sk.p("pull", 650))
	if f.world:
		for e in f.world.fighters:
			if e.team == f.team or e.is_dead() or e.has_status("invuln") or e.global_position.distance_to(f.global_position) > r:
				continue
			var dx: float = f.global_position.x - e.global_position.x
			e.start_dash(signf(dx) * pull, clampf((absf(dx) - 50.0) / pull, 0.05, 0.4))
		f.world.shake(10.0)
	_spawn_box(Vector2(r * 0.4, r * 0.4), Vector2(0, _chest()), 0.42, make_hit(sk), 0.0, true)
	AudioManager.play_sfx("nova", 0.8)
	_fx("ring", f.global_position + Vector2(0, _chest()), {"color": sk.color, "radius": r})
	_fx("burst", f.global_position + Vector2(0, _chest()), {"color": sk.color, "count": 24})
	return 0.42


func _fire_ward(sk: SkillData, f: Fighter) -> float:
	var m := f.mech as WardenMech
	if m == null:
		return 0.05
	var r := float(sk.p("radius", 170))
	m.place_ward(f.global_position.x, float(sk.p("life", 6.0)), r, float(sk.p("reduction", 0.35)))
	if sk.damage > 0.0:   # the dome also blasts nearby enemies away
		_spawn_box(Vector2(r * 0.6, r * 0.6), Vector2(0, _chest()), 0.12, make_hit(sk), 0.0, true)
		if f.world:
			f.world.shake(9.0)
	AudioManager.play_sfx("shield")
	_fx("ring", f.global_position + Vector2(0, _chest()), {"color": sk.color, "radius": r})
	return 0.1


## Chain lightning: nearest enemy in range, then jumps to further enemies close to the last one struck.
func _fire_discharge(sk: SkillData, f: Fighter) -> float:
	var spent: float = f.mech.spent if f.mech is StormcallerMech else 0.0
	var from := f.global_position + Vector2(0, _chest())
	var reach := float(sk.p("range", 400))
	var done: Array = []
	if f.world:
		for i in int(sk.p("targets", 3)):
			var best: Fighter = null
			var best_d := reach
			for e in f.world.fighters:
				if e.team == f.team or e.is_dead() or done.has(e):
					continue
				var d: float = e.center().distance_to(from)
				if d <= best_d:
					best = e
					best_d = d
			if best == null:
				break
			done.append(best)
			var hit := make_hit(sk, float(sk.damage) + spent * float(sk.p("scale", 0.25)))
			hit["from_x"] = from.x
			_fx("bolt_line", from, {"to": best.center(), "color": sk.color})
			from = best.center()
			reach = float(sk.p("jump", 240))
			if best.receive_hit(hit):
				f.world.on_hit_landed(f, best, hit)
		f.world.shake(7.0)
	AudioManager.play_sfx("nova", 1.4)
	_fx("ring", f.global_position + Vector2(0, _chest()), {"color": sk.color, "radius": 90.0})
	return 0.1


func _fire_siphon(sk: SkillData, f: Fighter) -> float:
	var m := f.mech as ReaperMech
	if m != null:
		m.heal(minf(float(sk.p("heal", 8)) + m.spent * float(sk.p("scale", 0.2)), float(sk.p("cap", 24))))
	AudioManager.play_sfx("magic", 0.8)
	_fx("ring", f.global_position + Vector2(0, _chest()), {"color": sk.color, "radius": 80.0})
	_fx("burst", f.global_position + Vector2(0, _chest()), {"color": sk.color, "count": 14})
	return 0.1


func _fire_bubble(sk: SkillData, f: Fighter) -> float:
	var m := f.mech as ChronomancerMech
	var x := _forward_x(float(sk.p("reach", 260)))
	if m != null:
		m.place_bubble(x, float(sk.p("life", 4.0)))
	AudioManager.play_sfx("magic", 0.7)
	_fx("ring", Vector2(x, _floor_y() - 60.0), {"color": sk.color, "radius": float(sk.p("radius", 160))})
	return 0.05


## Sic 'Em: the wolf leaps next to the nearest enemy and bites shortly after; moving away in time makes it miss.
func _fire_command(sk: SkillData, f: Fighter) -> float:
	var m := f.mech as BeastboundMech
	var target = f.world.nearest_enemy(f) if f.world else null
	if m == null or target == null or absf(target.global_position.x - f.global_position.x) > float(sk.p("range", 520)):
		return 0.05
	var side := 1.0 if target.global_position.x >= m.wolf_x else -1.0
	var origin := Vector2(m.wolf_x, _floor_y())
	m.wolf_x = target.global_position.x - side * 50.0
	m.extra = m.wolf_x
	_fx("trail", origin, {"dir": int(side), "color": sk.color})
	_scheduled.append({"t": 0.18, "cb": _wolf_lunge.bind(sk, target)})
	AudioManager.play_sfx("dash", 0.7)
	return 0.24


func _wolf_lunge(sk: SkillData, target) -> void:
	var m := fighter.mech as BeastboundMech
	if m == null or not is_instance_valid(target) or target.is_dead() or absf(target.global_position.x - m.wolf_x) > 140.0:
		return
	var hit := make_hit(sk)
	hit["from_x"] = m.wolf_x
	_fx("slash", target.center(), {"dir": 1 if target.global_position.x >= m.wolf_x else -1, "color": sk.color, "w": 90.0})
	if target.receive_hit(hit) and fighter.world:
		fighter.world.on_hit_landed(fighter, target, hit)


func _fire_summon(sk: SkillData, f: Fighter) -> float:
	var m := f.mech as BeastboundMech
	if m != null:
		m.summon(float(sk.p("life", 10.0)))
	AudioManager.play_sfx("shield", 0.8)
	_fx("ring", f.global_position + Vector2(0, _chest()), {"color": sk.color, "radius": 90.0})
	return 0.05


func _fire_howl(sk: SkillData, f: Fighter) -> float:
	var m := f.mech as BeastboundMech
	if m != null:
		m.summon(m.max_res)
		m.aux = float(sk.p("frenzy", 6.0))
	f.set_status("haste", float(sk.p("frenzy", 6.0)), float(sk.p("haste", 1.3)))
	return _fire_nova(sk, f)
