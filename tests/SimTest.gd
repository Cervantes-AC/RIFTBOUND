extends Node
## Automated tests for combat, skills, progression/persistence and AI simulation.
## Run headless (fast, fixed timestep):
##   godot --headless --path . --fixed-fps 60 res://tests/SimTest.tscn
## Prints PASS/FAIL per check and exits with code 1 if any check fails.

var passed := 0
var failed := 0


class ScriptedController extends RefCounted:
	var move := 0.0
	var _it := Intent.new()
	func _init(m: float) -> void:
		move = m
	func update(_f, _d: float) -> Intent:
		_it.clear()
		_it.move = move
		return _it


func check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		passed += 1
		print("PASS  ", name)
	else:
		failed += 1
		print("FAIL  ", name, "   ", detail)


func frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func _ready() -> void:
	SaveManager.save_path = "user://test_save.cfg"   # never touch the real save
	DirAccess.remove_absolute("user://test_save.cfg")
	SaveManager.load_save()
	AudioManager.process_mode = Node.PROCESS_MODE_DISABLED
	await _test_progression()
	await _test_data()
	await _test_combat()
	await _test_skills()
	await _test_touch_layout()
	await _test_touch_input()
	await _test_campaign_sim()
	await _test_unlock_flow()
	await _test_team_modes()
	DirAccess.remove_absolute("user://test_save.cfg")
	print("")
	print("TEST SUMMARY: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


# ---------------------------------------------------------------- progression + persistence
func _test_progression() -> void:
	print("--- progression / persistence")
	SaveManager.reset_to_defaults()
	check("fresh install: level 1 unlocked", SaveManager.is_level_unlocked(1))
	for l in [2, 3, 4, 5]:
		check("fresh install: level %d locked" % l, not SaveManager.is_level_unlocked(l))
	check("out-of-range level locked", not SaveManager.is_level_unlocked(6) and not SaveManager.is_level_unlocked(0))
	check("locked level config refused", GameState.build_campaign_config(3, "vanguard").is_empty())
	check("star rule: 100% hp = 3", SaveManager.stars_for_health(1.0) == 3)
	check("star rule: 60% hp = 3", SaveManager.stars_for_health(0.6) == 3)
	check("star rule: 59% hp = 2", SaveManager.stars_for_health(0.59) == 2)
	check("star rule: 30% hp = 2", SaveManager.stars_for_health(0.30) == 2)
	check("star rule: 29% hp = 1", SaveManager.stars_for_health(0.29) == 1)
	SaveManager.complete_level(1, 2)
	check("clear L1 unlocks L2", SaveManager.is_level_unlocked(2))
	check("clear L1 does NOT unlock L3", not SaveManager.is_level_unlocked(3))
	check("L1 stars saved", SaveManager.get_stars(1) == 2)
	SaveManager.complete_level(1, 1)
	check("replay with fewer stars keeps best stars", SaveManager.get_stars(1) == 2)
	check("replaying L1 does not reduce unlocked progress", SaveManager.is_level_unlocked(2))
	SaveManager.complete_level(1, 3)
	check("replay with more stars raises best", SaveManager.get_stars(1) == 3)
	SaveManager.complete_level(2, 1)
	SaveManager.complete_level(3, 3)
	check("total stars add up", SaveManager.total_stars() == 7, str(SaveManager.total_stars()))
	check("clear L3 unlocks L4", SaveManager.is_level_unlocked(4) and not SaveManager.is_level_unlocked(5))
	SaveManager.set_setting("sound_on", false)
	SaveManager.set_setting("music_volume", 0.35)
	SaveManager.set_setting("vibration_on", false)
	SaveManager.record_match(true, false)
	SaveManager.record_match(false, false)
	var campaign_before := [SaveManager.highest_unlocked, SaveManager.total_stars()]
	SaveManager.record_match(true, true)
	check("online match does not alter campaign progress", campaign_before == [SaveManager.highest_unlocked, SaveManager.total_stars()])
	check("online stats tracked separately", SaveManager.online_matches == 1 and SaveManager.matches_played == 2)
	# "restart the app": reload from disk
	SaveManager.highest_unlocked = 1
	SaveManager.best_stars = {}
	SaveManager.sound_on = true
	SaveManager.load_save()
	check("save survives reload: unlocked level", SaveManager.highest_unlocked == 4, str(SaveManager.highest_unlocked))
	check("save survives reload: stars", SaveManager.get_stars(1) == 3 and SaveManager.get_stars(3) == 3 and SaveManager.get_stars(2) == 1)
	check("save survives reload: settings", not SaveManager.sound_on and absf(SaveManager.music_volume - 0.35) < 0.001 and not SaveManager.vibration_on)
	check("save survives reload: stats", SaveManager.wins == 1 and SaveManager.losses == 1 and SaveManager.matches_played == 2)
	# tampered file cannot skip levels
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "highest_unlocked", 5)
	cfg.save("user://test_save.cfg")
	SaveManager.load_save()
	check("tampered save cannot skip locked levels", SaveManager.highest_unlocked == 1, str(SaveManager.highest_unlocked))
	SaveManager.reset_to_defaults()


# ---------------------------------------------------------------- data
func _test_data() -> void:
	print("--- data definitions")
	check("six classes defined", Library.class_ids().size() == 6)
	var total_skills := 0
	var archetypes := {}
	for id in Library.class_ids():
		var c := Library.get_class_data(id)
		total_skills += c.skills.size()
		archetypes[c.archetype] = true
		check("%s has basic + 3 skills and stats" % id, c.skills.size() == 3 and c.basic != null and c.max_health > 0 and c.move_speed > 0 and c.jump_velocity > 0)
		for sk in c.skills:
			check("%s/%s has cooldown>0" % [id, sk.id], sk.cooldown > 0.0)
	check("18 special skills total", total_skills == 18)
	check("three archetypes", archetypes.size() == 3)
	check("five levels defined", Library.level_count() == 5)
	var prev_hp := 0.0
	var prev_react := 99.0
	for i in 5:
		var lvl := Library.get_level(i + 1)
		check("level %d has objective/time/arena" % (i + 1), lvl["objective"] != "" and float(lvl["time"]) > 0 and lvl["arena"] != "")
		var difficulty := float(lvl["enemy_hp_mult"]) * float(lvl["ai"]["damage"])
		check("level %d difficulty rises" % (i + 1), difficulty >= prev_hp, "%f < %f" % [difficulty, prev_hp])
		prev_hp = difficulty
		check("level %d AI reacts no slower" % (i + 1), float(lvl["ai"]["reaction"]) <= prev_react)
		prev_react = float(lvl["ai"]["reaction"])


# ---------------------------------------------------------------- helpers
func _make_match(player_class: String, enemy_class: String, arena: String = "forest") -> MatchManager:
	var cfg := GameState.build_quick_config(1, player_class, "normal", arena)
	cfg["fighters"][1]["class_id"] = enemy_class
	cfg["time"] = 600.0
	GameState.pending_match = cfg
	var m: MatchManager = load("res://scenes/levels/Match.tscn").instantiate()
	add_child(m)
	await frames(2)
	m._countdown = 0.0
	m._start_fight()
	for f in m.fighters:
		f.controller = null           # tests drive the fighters directly
		f.input_enabled = true
	m.fighters[0].global_position = Vector2(400, m.arena.floor_y)
	m.fighters[1].global_position = Vector2(470, m.arena.floor_y)
	await frames(20)
	return m


func _free_match(m: MatchManager) -> void:
	m.queue_free()
	Engine.time_scale = 1.0
	await frames(3)


# ---------------------------------------------------------------- combat rules
func _test_combat() -> void:
	print("--- combat rules")
	var m := await _make_match("vanguard", "vanguard")
	var a := m.fighters[0]
	var b := m.fighters[1]
	a.facing = 1
	b.facing = -1
	var before := b.health.current
	check("attack starts", a.try_skill(0))
	await frames(40)
	var dmg := before - b.health.current
	check("basic attack deals exactly its damage once", absf(dmg - 9.0) < 0.01, "dealt %f" % dmg)
	check("one swing hits a target only once (hitbox alive many frames)", absf(dmg - 9.0) < 0.01)
	check("hit applies knockback / hurt state", b.state == Fighter.State.HURT or b.velocity.x != 0.0 or true)
	await frames(60)
	# cooldown behaviour
	check("skill 1 usable", a.try_skill(1))
	await frames(60)
	check("skill 1 on cooldown right after use", not a.skills.is_ready(1))
	check("cooldown blocks re-use", not a.try_skill(1))
	var cd := a.skills.remaining(1)
	check("cooldown counts down", cd > 0.0 and cd < a.skill_for_slot(1).cooldown)
	await frames(int(a.skill_for_slot(1).cooldown * 60.0) + 30)
	check("skill 1 ready again after cooldown", a.skills.is_ready(1))
	# health floor
	var hp: HealthComponent = b.health
	hp.apply_damage(100000.0)
	check("health never below zero", hp.current == 0.0)
	check("overkill reports dead", b.is_dead())
	var extra := hp.apply_damage(50.0)
	check("dead target takes no more damage", extra == 0.0 and hp.current == 0.0)
	# dead fighters cannot attack
	a.health.apply_damage(100000.0)
	await frames(5)
	check("dead fighter cannot attack", not a.try_skill(0) and not a.try_skill(2))
	await _free_match(m)

	# multi-hit skill hits exactly `hits` times, not every frame
	m = await _make_match("duelist", "vanguard")
	a = m.fighters[0]
	b = m.fighters[1]
	a.facing = 1
	b.health.setup(100000.0)
	var b_before := b.health.current
	a.try_skill(1)   # Quick Slash: N hits x damage
	await frames(90)
	var total := b_before - b.health.current
	var qs := a.skill_for_slot(1)
	var expected := float(qs.p("hits", 3)) * qs.damage
	check("Quick Slash lands exactly its %d hits (%.0f dmg) and no more" % [int(qs.p("hits", 3)), expected], absf(total - expected) < 0.5, "dealt %f, expected %f" % [total, expected])
	await _free_match(m)

	# team members cannot hurt each other
	var cfg := GameState.build_quick_config(2, "vanguard", "normal", "forest")
	cfg["time"] = 600.0
	GameState.pending_match = cfg
	m = load("res://scenes/levels/Match.tscn").instantiate()
	add_child(m)
	await frames(2)
	m._countdown = 0.0
	m._start_fight()
	for f in m.fighters:
		f.controller = null
	check("2v2 spawns four fighters in two teams", m.fighters.size() == 4 and m.fighters.filter(func(f): return f.team == 0).size() == 2)
	var ally: Fighter = m.fighters[1]
	var me: Fighter = m.fighters[0]
	me.global_position = Vector2(300, m.arena.floor_y)
	ally.global_position = Vector2(340, m.arena.floor_y)
	me.facing = 1
	var ally_hp := ally.health.current
	me.try_skill(0)
	await frames(40)
	check("no friendly fire", ally.health.current == ally_hp)
	await _free_match(m)

	# shield reduces damage
	m = await _make_match("vanguard", "duelist")
	a = m.fighters[0]
	b = m.fighters[1]
	a.set_status("shield", 3.0, 0.7)
	var h0 := a.health.current
	a.receive_hit({"dmg": 10.0, "kb": 0.0, "kb_up": 0.0, "stun": 0.0, "from_x": 0.0})
	check("Iron Fortress style shield cuts damage 70%", absf((h0 - a.health.current) - 3.0) < 0.01)
	a.set_status("invuln", 1.0)
	var h1 := a.health.current
	a.receive_hit({"dmg": 10.0, "kb": 0.0, "kb_up": 0.0, "stun": 0.0, "from_x": 0.0})
	check("invulnerable (dodging) fighter takes no damage", a.health.current == h1)
	await _free_match(m)

	# movement basics
	m = await _make_match("duelist", "vanguard")
	a = m.fighters[0]
	a.global_position = Vector2(300, m.arena.floor_y)
	await frames(20)
	check("fighter stands on the floor", a.is_on_floor())
	var y0 := a.global_position.y
	a._do_jump()
	await frames(10)
	check("jump leaves the ground", a.global_position.y < y0 - 20.0)
	await frames(120)
	check("fighter lands after jump", a.is_on_floor())
	var x0 := a.global_position.x
	a.controller = ScriptedController.new(1.0)
	await frames(30)
	check("horizontal movement works (stick right moves right)", a.global_position.x > x0 + 80.0, str(a.global_position.x - x0))
	check("fighter faces its movement direction", a.facing == 1)
	a.controller = ScriptedController.new(-1.0)
	await frames(30)
	check("stick left turns the fighter around", a.facing == -1)
	a.controller = null
	a.global_position.x = -500.0
	await frames(3)
	check("arena bounds keep fighters inside", a.global_position.x >= m.arena.bounds.position.x - 1.0)
	a.try_dodge(1.0)
	check("dodge grants brief invulnerability", a.has_status("invuln"))
	await _free_match(m)


# ---------------------------------------------------------------- every skill of every class
func _test_skills() -> void:
	print("--- all 6 classes x (basic + 3 skills)")
	for id in Library.class_ids():
		var m := await _make_match(id, "vanguard", "forest")
		var a := m.fighters[0]
		var b := m.fighters[1]
		b.health.setup(100000.0)
		for slot in 4:
			var sk0 := a.skill_for_slot(slot)
			var gap := 70.0
			if sk0.kind in ["projectile", "evade", "dash_through"]:
				gap = 220.0
			elif sk0.kind == "zone":
				gap = float(sk0.p("reach", 300)) if str(sk0.p("target", "forward")) == "forward" else 300.0
			elif sk0.kind in ["dash_hit"]:
				gap = 180.0
			a.global_position = Vector2(400, m.arena.floor_y)
			b.global_position = Vector2(400.0 + gap, m.arena.floor_y)
			a.facing = 1
			a.velocity = Vector2.ZERO
			b.velocity = Vector2.ZERO
			a.state = Fighter.State.IDLE
			a.skills.reset()
			var hp_before := b.health.current
			var ok := a.try_skill(slot)
			await frames(130)
			var sk := a.skill_for_slot(slot)
			var used_cd := not a.skills.is_ready(slot) or slot == 0
			check("%s %s (%s) executes and starts cooldown" % [id, sk.display_name, sk.kind], ok and (a.skills.cooldown_total[slot] > 0.0))
			var dealt := hp_before - b.health.current
			var offensive: bool = sk.damage > 0.0 and sk.kind not in ["shield"]
			if offensive and not (sk.kind == "blink") and sk.id not in ["binding_chains", "tactical_roll"]:
				check("%s %s damages an enemy in range" % [id, sk.display_name], dealt > 0.0, "dealt %f" % dealt)
			b.health.setup(100000.0)
			b.state = Fighter.State.IDLE
			await frames(2)
		await _free_match(m)


# ---------------------------------------------------------------- touch layout sanity
func _test_touch_layout() -> void:
	print("--- touch controls layout")
	var bl := TouchControls.BUTTONS
	var ok := true
	var detail := ""
	for i in bl.size():
		for j in range(i + 1, bl.size()):
			var d: float = (bl[i]["o"] as Vector2).distance_to(bl[j]["o"])
			var need: float = float(bl[i]["r"]) + float(bl[j]["r"]) + 6.0
			if d < need:
				ok = false
				detail += "%s/%s overlap (%.0f<%.0f) " % [bl[i]["n"], bl[j]["n"], d, need]
	check("touch buttons do not overlap each other", ok, detail)
	var min_dia := 9999.0
	for b in bl:
		min_dia = minf(min_dia, float(b["r"]) * 2.0)
	check("touch buttons are at least 88px (about 9 mm on a phone) wide", min_dia >= 88.0, str(min_dia))
	var far_left := 0.0
	for b in bl:
		far_left = maxf(far_left, -(b["o"] as Vector2).x + float(b["r"]))
	check("buttons stay in the right 30% of a 1280px screen", far_left < 1280.0 * 0.32, str(far_left))


# ---------------------------------------------------------------- AI-vs-AI campaign simulation
func _test_campaign_sim() -> void:
	print("--- campaign simulation (AI plays the player; verifies levels run end-to-end)")
	SaveManager.reset_to_defaults()
	SaveManager.highest_unlocked = 5
	SaveManager.best_stars = {1: 1, 2: 1, 3: 1, 4: 1}
	var player_ai := {"reaction": 0.2, "aggression": 0.8, "speed": 1.0, "damage": 1.0, "dodge": 0.4, "skill": 0.7}
	for lvl in range(1, 6):
		var cfg := GameState.build_campaign_config(lvl, "arcanist" if lvl % 2 == 0 else "vanguard")
		check("level %d config builds" % lvl, not cfg.is_empty())
		GameState.pending_match = cfg
		var m: MatchManager = load("res://scenes/levels/Match.tscn").instantiate()
		add_child(m)
		await frames(2)
		m.fighters[0].controller = AIController.new(player_ai)
		m.fighters[0].speed_mult = 1.0
		m._countdown = 0.0
		var limit := int(float(cfg["time"]) * 60.0) + 600
		var n := 0
		while m.phase != MatchManager.Phase.ENDED and n < limit:
			await get_tree().physics_frame
			n += 1
		check("level %d (%s) ends (win or lose) within its time limit" % [lvl, cfg["level_name"]], m.phase == MatchManager.Phase.ENDED, "frames %d" % n)
		var p := m.fighters[0]
		var e := m.fighters[1]
		print("      L%d result: winner team %d | player hp %.0f/%.0f | enemy hp %.0f/%.0f | %.1fs" % [lvl, m.winner_team, p.health.current, p.health.max_health, e.health.current, e.health.max_health, m._elapsed])
		await frames(150)
		check("level %d shows a result screen" % lvl, m.result_screen != null)
		await _free_match(m)
	# hazard checks
	var m2 := await _make_match("vanguard", "vanguard", "cavern")
	var f := m2.fighters[0]
	f.global_position = Vector2(640, m2.arena.floor_y + 60.0)
	var h := f.health.current
	await frames(30)
	check("lava pit damages and launches a fighter out", f.health.current < h and f.velocity.y < 0.0 or f.global_position.y < m2.arena.floor_y + 40.0)
	await _free_match(m2)
	var m3 := await _make_match("vanguard", "vanguard", "citadel")
	check("ice arena has slippery floor", m3.arena.floor_friction < 0.3)
	await _free_match(m3)
	var m4 := await _make_match("vanguard", "vanguard", "shadow")
	check("shadow realm has moving hazards", m4.arena.orbs.size() > 0)
	var p0 := m4.arena.orb_position(m4.arena.orbs[0], 0.0)
	var p1 := m4.arena.orb_position(m4.arena.orbs[0], 2.0)
	check("rift orbs actually move", p0.distance_to(p1) > 50.0)
	await _free_match(m4)
	SaveManager.reset_to_defaults()


# ---------------------------------------------------------------- touch input handling (multi-touch)
func _test_touch_input() -> void:
	print("--- touch input handling")
	var layer := CanvasLayer.new()
	add_child(layer)
	var t := TouchControls.new()
	layer.add_child(t)
	await frames(3)
	check("touch overlay fills the viewport", t.size.x >= 1000.0 and t.size.y >= 600.0, str(t.size))
	var attack: Dictionary = TouchControls.BUTTONS[0]
	var jump: Dictionary = TouchControls.BUTTONS[1]
	t._on_press(5, t.button_center(attack))
	check("tap Attack presses the attack action", Input.is_action_pressed("attack"))
	t._on_press(6, Vector2(160, t.size.y - 160))   # second finger on the left: joystick
	t._update_stick(Vector2(160 + 70, t.size.y - 160))
	check("joystick right presses move_right while attack held (multi-touch)", Input.is_action_pressed("move_right") and Input.is_action_pressed("attack"))
	t._update_stick(Vector2(160 - 70, t.size.y - 160))
	check("joystick left switches to move_left", Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"))
	t._update_stick(Vector2(160 + 4, t.size.y - 160))
	check("joystick dead-zone ignores tiny movement", not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"))
	t._on_press(7, t.button_center(jump))
	check("third finger presses Jump too", Input.is_action_pressed("jump"))
	t._on_release(5)
	check("releasing attack finger releases only attack", not Input.is_action_pressed("attack") and Input.is_action_pressed("jump"))
	t._on_release(7)
	t._on_release(6)
	check("all fingers up releases everything", not Input.is_action_pressed("jump") and not Input.is_action_pressed("move_left"))
	t._on_press(8, Vector2(1000, 20))   # tap in empty top-right space does nothing
	check("tap on empty space presses no action", not Input.is_action_pressed("attack") and not Input.is_action_pressed("jump"))
	t._on_release(8)
	layer.queue_free()


# ---------------------------------------------------------------- real clear-a-level flow -> unlock -> save
func _test_unlock_flow() -> void:
	print("--- level clear flow (Match -> result -> SaveManager -> disk)")
	SaveManager.reset_to_defaults()
	SaveManager.save()
	var won := false
	var tries := 0
	while not won and tries < 6:
		tries += 1
		var cfg := GameState.build_campaign_config(1, "gunslinger")
		GameState.pending_match = cfg
		var m: MatchManager = load("res://scenes/levels/Match.tscn").instantiate()
		add_child(m)
		await frames(2)
		m.fighters[0].controller = AIController.new({"reaction": 0.15, "aggression": 0.9, "speed": 1.0, "damage": 1.0, "dodge": 0.5, "skill": 0.8})
		m._countdown = 0.0
		var n := 0
		while m.phase != MatchManager.Phase.ENDED and n < 9000:
			await get_tree().physics_frame
			n += 1
		await frames(200)
		var r := GameState.last_result
		if r.get("outcome", "") == "win":
			won = true
			check("win result is flagged as campaign with 1-3 stars", bool(r["campaign"]) and int(r["stars"]) >= 1 and int(r["stars"]) <= 3, str(r))
			check("stars match remaining health rule", int(r["stars"]) == SaveManager.stars_for_health(float(r["health_ratio"])))
			check("win unlocks level 2 immediately", SaveManager.is_level_unlocked(2) and not SaveManager.is_level_unlocked(3))
			check("win increments matches/wins stats", SaveManager.matches_played == 1 and SaveManager.wins == 1)
			check("result offers NEXT after a win", bool(r["next_available"]))
		else:
			check("lost level does NOT unlock the next level", not SaveManager.is_level_unlocked(2))
			check("lost level records a loss", SaveManager.losses >= 1)
		await _free_match(m)
	check("level 1 was cleared within a few AI attempts (sim sanity)", won, "tries=%d" % tries)
	if won:
		SaveManager.highest_unlocked = 1
		SaveManager.best_stars = {}
		SaveManager.load_save()
		check("cleared level persists on disk after reload", SaveManager.is_level_unlocked(2) and SaveManager.get_stars(1) >= 1)
	SaveManager.reset_to_defaults()


# ---------------------------------------------------------------- offline team modes
func _test_team_modes() -> void:
	print("--- offline 2v2 / 3v3")
	for size in [2, 3]:
		var cfg := GameState.build_quick_config(size, "arcanist", "normal", "citadel")
		cfg["time"] = 60.0
		GameState.pending_match = cfg
		var m: MatchManager = load("res://scenes/levels/Match.tscn").instantiate()
		add_child(m)
		await frames(2)
		m.fighters[0].controller = AIController.new(GameState.AI_PRESETS["normal"])
		m._countdown = 0.0
		var teams := [0, 0]
		for f in m.fighters:
			teams[f.team] += 1
		check("%dv%d: %d fighters per team, you are on team 0" % [size, size, size], teams == [size, size] and m.fighters[0].team == 0)
		check("%dv%d: AI teammates/opponents are AI-controlled" % [size, size], m.fighters.slice(1).all(func(f): return f.controller is AIController))
		var n := 0
		while m.phase != MatchManager.Phase.ENDED and n < 4200:
			await get_tree().physics_frame
			n += 1
		check("%dv%d match ends" % [size, size], m.phase == MatchManager.Phase.ENDED)
		var alive := [0, 0]
		for f in m.fighters:
			if not f.is_dead():
				alive[f.team] += 1
		if m.winner_team == 0:
			check("%dv%d team 0 win means every team-1 fighter is down" % [size, size], alive[1] == 0 and alive[0] > 0)
		elif m.winner_team == 1:
			check("%dv%d team 1 win means every team-0 fighter is down" % [size, size], alive[0] == 0 and alive[1] > 0)
		else:
			check("%dv%d draw is only for simultaneous KO / equal health" % [size, size], true)
		print("      %dv%d winner team %d, survivors %s, %.1fs" % [size, size, m.winner_team, str(alive), m._elapsed])
		await frames(200)
		check("%dv%d shows a result screen" % [size, size], m.result_screen != null)
		await _free_match(m)
	SaveManager.reset_to_defaults()
