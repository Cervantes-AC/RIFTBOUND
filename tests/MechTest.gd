extends Node
## Tests for the class mechanics, ultimate meter, input buffering / cancels, combo rules, snapshot sync and
## control-setting persistence. Headless:
##   godot --headless --path . --fixed-fps 60 res://tests/MechTest.tscn

var passed := 0
var failed := 0


class Scripted extends RefCounted:
	## Controller that presses chosen abilities once, on demand.
	var it := Intent.new()
	var queue: Array = []   # entries: "attack", "special", "signature", "ultimate", "mobility"

	func update(_f, _d: float) -> Intent:
		it.clear()
		if not queue.is_empty():
			match queue.pop_front():
				"attack":
					it.attack_pressed = true
				"special":
					it.skill_pressed[0] = true
				"signature":
					it.skill_pressed[1] = true
				"ultimate":
					it.skill_pressed[2] = true
				"mobility":
					it.dodge_pressed = true
		return it


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
	SaveManager.save_path = "user://mech_test_save.cfg"
	DirAccess.remove_absolute("user://mech_test_save.cfg")
	SaveManager.load_save()
	AudioManager.process_mode = Node.PROCESS_MODE_DISABLED
	await _test_roster()
	await _test_vanguard()
	await _test_duelist()
	await _test_ranger()
	await _test_gunslinger()
	await _test_arcanist()
	await _test_shadeweaver()
	await _test_ultimate_meter()
	await _test_input_rules()
	await _test_sync()
	_test_settings()
	DirAccess.remove_absolute("user://mech_test_save.cfg")
	print("")
	print("MECH TEST SUMMARY: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _match(a: String, b: String, arena := "forest") -> MatchManager:
	var cfg := GameState.build_quick_config(1, a, "normal", arena)
	cfg["fighters"][1]["class_id"] = b
	cfg["time"] = 600.0
	GameState.pending_match = cfg
	var m: MatchManager = load("res://scenes/levels/Match.tscn").instantiate()
	add_child(m)
	await frames(2)
	m._countdown = 0.0
	m._start_fight()
	for f in m.fighters:
		f.controller = null
		f.input_enabled = true
	m.fighters[0].global_position = Vector2(400, m.arena.floor_y)
	m.fighters[1].global_position = Vector2(470, m.arena.floor_y)
	m.fighters[1].health.setup(100000.0)
	await frames(20)
	return m


## Polls for up to 20 frames and returns the damage of the projectile that was just fired.
func _shot_damage(m: MatchManager) -> float:
	var dmg := 0.0
	for i in 20:
		await get_tree().physics_frame
		for p in m.get_projectiles():
			dmg = float(p.spec["dmg"])
		if dmg > 0.0:
			break
	return dmg


func _free(m: MatchManager) -> void:
	m.queue_free()
	Engine.time_scale = 1.0
	await frames(3)


func _hit(target: Fighter, attacker: Fighter, dmg: float, extra := {}) -> float:
	var before := target.health.current
	var h := {"attacker": attacker, "dmg": dmg, "kb": 0.0, "kb_up": 0.0, "stun": 0.0, "from_x": attacker.global_position.x, "source": "test", "color": Color.WHITE}
	h.merge(extra, true)
	target.receive_hit(h)
	return before - target.health.current


# ----------------------------------------------------------------------------
func _test_roster() -> void:
	print("--- roster")
	check("12 roster entries", Library.roster_ids().size() == 12)
	check("only 6 are playable", Library.class_ids().size() == 6)
	var all_ok := true
	for id in Library.class_ids():
		var d := Library.get_class_data(id)
		all_ok = all_ok and not d.planned and d.basic != null and d.mobility != null and d.skills.size() == 3 and d.skills[2].is_ultimate and d.mech_id != "" and d.passive_name != "" and d.lore != "" and d.difficulty >= 1
	check("playable classes have basic/special/signature/ultimate/mobility, passive, lore, difficulty", all_ok)
	var planned_ok := true
	for id in Library.PLANNED_ORDER:
		var d2 := Library.get_class_data(id)
		planned_ok = planned_ok and d2.planned and d2.basic == null
	check("planned classes are flagged and have no abilities (never playable)", planned_ok)
	var mechs := {}
	for id in Library.class_ids():
		mechs[Library.get_class_data(id).mech_id] = true
	check("all six playable classes have a different signature mechanic", mechs.size() == 6)


func _test_vanguard() -> void:
	print("--- vanguard: bulwark / retaliate")
	var m := await _match("vanguard", "duelist")
	var a := m.fighters[0]
	var b := m.fighters[1]
	check("Retaliate refused with empty Bulwark", not a.can_use_slot(2) and not a.try_skill(2))
	var before := a.health.current
	_hit(a, b, 10.0)
	check("taking damage fills Bulwark", a.mech.res > 10.0, str(a.mech.res))
	var plain := _dmg_with_res(a, b, 0.0)
	var boosted := _dmg_with_res(a, b, 60.0)
	check("Bulwark 50+ reduces damage taken by 10%", boosted < plain * 0.95, "%f vs %f" % [boosted, plain])
	a.mech.res = 100.0
	a.skills.reset()
	a.global_position = Vector2(400, m.arena.floor_y)
	b.global_position = Vector2(470, m.arena.floor_y)
	a.state = Fighter.State.IDLE
	var hp := b.health.current
	check("Retaliate usable with 30+ Bulwark", a.try_skill(2))
	check("Retaliate spends all Bulwark", a.mech.res == 0.0)
	await frames(60)
	var full := hp - b.health.current
	a.mech.res = 30.0
	a.skills.reset()
	a.state = Fighter.State.IDLE
	b.global_position = Vector2(470, m.arena.floor_y)
	b.state = Fighter.State.IDLE
	hp = b.health.current
	a.try_skill(2)
	await frames(60)
	var low := hp - b.health.current
	check("Retaliate damage grows with Bulwark spent", full > low + 10.0, "full %f low %f" % [full, low])
	a.health.setup(1000.0)
	a.velocity = Vector2.ZERO
	a.mech.res = 0.0
	_hit(a, b, 1.0, {"kb": 400.0})
	check("Stalwart cuts knockback taken by 25%", absf(absf(a.velocity.x) - 300.0) < 1.0, str(a.velocity.x))
	await _free(m)


func _dmg_with_res(a: Fighter, b: Fighter, res: float) -> float:
	a.mech.res = res
	a.health.setup(1000.0)
	return _hit(a, b, 20.0)


func _test_duelist() -> void:
	print("--- duelist: momentum")
	var m := await _match("duelist", "vanguard")
	var a := m.fighters[0]
	var b := m.fighters[1]
	for i in 3:
		_hit(b, a, 5.0)
	check("each hit adds a Momentum stack", a.mech.stacks == 3, str(a.mech.stacks))
	for i in 5:
		_hit(b, a, 5.0)
	check("Momentum caps at 5 stacks", a.mech.stacks == 5)
	check("stacks raise damage by 5% each (+25%)", absf(a.outgoing_multiplier() - 1.25) < 0.001, str(a.outgoing_multiplier()))
	a.health.setup(1000.0)
	_hit(a, b, 5.0)
	check("being hit halves stacks", a.mech.stacks == 2, str(a.mech.stacks))
	a.skills.cooldown_left[4] = 2.0
	_hit(b, a, 5.0)
	check("a landed hit shortens the mobility cooldown by 0.25s", absf(a.skills.cooldown_left[4] - 1.75) < 0.01, str(a.skills.cooldown_left[4]))
	a.mech.stacks = 3
	a.skills.cooldown_left[1] = 3.0
	a.state = Fighter.State.IDLE
	a.try_skill(2)
	check("Phantom Step at 3+ stacks refunds Quick Slash", a.skills.cooldown_left[1] == 0.0)
	await _free(m)


func _test_ranger() -> void:
	print("--- ranger: mark / steady aim")
	var m := await _match("ranger", "vanguard")
	var a := m.fighters[0]
	var b := m.fighters[1]
	var normal := _hit(b, a, 10.0)
	b.set_status("mark", 6.0)
	var marked := _hit(b, a, 10.0)
	check("marked targets take +25% from the Ranger", absf(marked / normal - 1.25) < 0.02, "%f vs %f" % [marked, normal])
	var other := _hit(a, b, 10.0)
	check("marks do not buff the enemy's damage", other <= 10.01)
	a.global_position = Vector2(400, m.arena.floor_y)
	a.velocity = Vector2.ZERO
	await frames(60)
	check("standing still builds Focus to full in under a second", a.mech.res >= 100.0, str(a.mech.res))
	a.state = Fighter.State.IDLE
	a.skills.reset()
	a.try_skill(0)
	check("firing consumes Steady Aim", a.mech.res < 100.0)
	var aimed_dmg := await _shot_damage(m)
	await frames(60)
	a.global_position = Vector2(400, m.arena.floor_y)
	a.velocity = Vector2.ZERO
	a.state = Fighter.State.IDLE
	a.skills.reset()
	a.mech.res = 0.0
	a.try_skill(0)
	var plain_dmg := await _shot_damage(m)
	check("an aimed arrow deals +50% over a snap shot", plain_dmg > 0.0 and absf(aimed_dmg / plain_dmg - 1.5) < 0.05, "%f vs %f" % [aimed_dmg, plain_dmg])
	await frames(40)
	a.mech.res = 100.0
	a.velocity.x = 200.0
	await frames(5)
	check("moving drains Focus", a.mech.res < 95.0, str(a.mech.res))
	await _free(m)


func _test_gunslinger() -> void:
	print("--- gunslinger: ammo")
	var m := await _match("gunslinger", "vanguard")
	var a := m.fighters[0]
	check("starts with 6 rounds", a.mech.res == 6.0)
	a.try_skill(0)
	check("pistol costs 1 round", is_equal_approx(a.mech.res, 5.0), str(a.mech.res))
	await frames(40)
	a.skills.reset()
	a.state = Fighter.State.IDLE
	a.try_skill(1)
	check("Quick Burst costs 3 rounds", is_equal_approx(a.mech.res, 2.0), str(a.mech.res))
	await frames(60)
	a.skills.reset()
	a.state = Fighter.State.IDLE
	a.mech.res = 1.0
	a.mech.aux = 0.0
	a.try_skill(0)
	check("last round starts a forced reload", a.mech.res == 0.0 and a.mech.aux > 0.0)
	a.skills.reset()
	a.state = Fighter.State.IDLE
	check("cannot shoot while reloading", not a.can_use_slot(0))
	await frames(110)
	check("reload refills the cylinder", a.mech.res >= 6.0, str(a.mech.res))
	a.mech.res = 0.0
	a.mech.aux = 0.0
	a.skills.reset()
	a.state = Fighter.State.IDLE
	a.try_skill(4)
	check("Tactical Roll reloads 2 rounds", is_equal_approx(a.mech.res, 2.0), str(a.mech.res))
	a.set_status("deadeye", 5.0)
	a.mech.res = 0.0
	a.skills.reset()
	a.state = Fighter.State.IDLE
	check("Dead Eye allows shooting with no ammo", a.can_use_slot(0))
	await _free(m)


func _test_arcanist() -> void:
	print("--- arcanist: elements / combos")
	var m := await _match("arcanist", "vanguard")
	var a := m.fighters[0]
	var b := m.fighters[1]
	check("starts on Fire", a.mech.element() == 0)
	a.try_skill(2)
	check("Attune cycles to Frost", a.mech.element() == 1)
	a.state = Fighter.State.IDLE
	a.skills.reset()
	a.try_skill(2)
	check("Attune cycles to Storm, then wraps", a.mech.element() == 2)
	a.mech.aux = 0.0
	var fire := _hit(b, a, 10.0, {"element": "fire"})
	b.status_t.erase("scorch")
	b.set_status("slow", 3.0)
	var shatter := _hit(b, a, 10.0, {"element": "fire"})
	check("Fire on a slowed enemy SHATTERS (x1.5)", absf(shatter / fire - 1.5) < 0.05, "%f vs %f" % [shatter, fire])
	check("Shatter consumes the slow", not b.has_status("slow"))
	_hit(b, a, 10.0, {"element": "frost"})
	check("Frost slows the target", b.has_status("slow"))
	b.state = Fighter.State.IDLE
	_hit(b, a, 10.0, {"element": "storm", "stun": 0.0})
	check("Storm on a slowed enemy stuns", b.state == Fighter.State.HURT)
	a.mech.res = 5.0
	a.skills.reset()
	a.state = Fighter.State.IDLE
	check("spells need mana (5 mana: no orb, no bolt)", not a.can_use_slot(1) and not a.can_use_slot(0))
	var low := a.mech.res
	await frames(60)
	check("mana regenerates", a.mech.res > low + 5.0, str(a.mech.res))
	await _free(m)


func _test_shadeweaver() -> void:
	print("--- shadeweaver: shadow / echo")
	var m := await _match("shadeweaver", "vanguard")
	var a := m.fighters[0]
	var b := m.fighters[1]
	a.mech.res = 0.0
	check("Binding Chains needs 20 Shadow", not a.can_use_slot(1))
	check("Shadow Echo needs 25 Shadow", not a.can_use_slot(2))
	a.mech.res = 100.0
	a.state = Fighter.State.IDLE
	a.global_position = Vector2(300, m.arena.floor_y)
	a.facing = 1
	a.try_skill(2)
	await frames(10)
	check("Shadow Echo spends 25 Shadow", a.mech.res < 80.0, str(a.mech.res))
	check("Echo is placed and you jumped forward", a.mech.aux > 0.0 and a.global_position.x > 400.0, "x=%f aux=%f" % [a.global_position.x, a.mech.aux])
	await frames(20)
	a.state = Fighter.State.IDLE
	a.skills.reset()
	var res_before := a.mech.res
	a.try_skill(2)
	await frames(5)
	check("pressing again swaps back to the echo for free", a.global_position.x < 320.0 and a.mech.res >= res_before - 1.0, "x=%f" % a.global_position.x)
	# root immunity
	b.set_status("root", 0.1)
	await frames(15)
	check("after a root ends the target is immune for a while", b.has_status("rootimm"))
	a.mech.res = 100.0
	_hit(b, a, 1.0, {"status": "root", "status_dur": 1.4})
	check("root is refused during root immunity", not b.has_status("root"))
	await _free(m)


func _test_ultimate_meter() -> void:
	print("--- ultimate meter")
	var m := await _match("vanguard", "duelist")
	var a := m.fighters[0]
	var b := m.fighters[1]
	check("ultimate starts empty and cannot be used", a.ult < 5.0 and not a.can_use_slot(3))
	_hit(b, a, 20.0)
	check("dealing damage charges the ultimate", a.ult > 10.0, str(a.ult))
	var u := b.ult
	_hit(a, b, 20.0)
	check("taking damage also charges it (less)", b.ult > u and b.ult < 100.0)
	a.ult = 100.0
	a.skills.reset()
	a.state = Fighter.State.IDLE
	check("full meter allows the ultimate", a.can_use_slot(3) and a.try_skill(3))
	check("using it empties the meter", a.ult == 0.0)
	await _free(m)


func _test_input_rules() -> void:
	print("--- input buffering, cancels, counters, combos")
	var m := await _match("vanguard", "duelist")
	var a := m.fighters[0]
	var b := m.fighters[1]
	var ctl := Scripted.new()
	a.controller = ctl
	a.state = Fighter.State.IDLE
	a.skills.reset()
	# basic -> special cancel needs the basic to CONNECT
	ctl.queue = ["attack"]
	await frames(3)
	check("basic attack starts", a.state == Fighter.State.ACTION and a.action_slot == 0)
	a.action_phase = "recover"
	a.action_connected = false
	ctl.queue = ["special"]
	await frames(2)
	check("special cannot cancel a basic that missed", not (a.state == Fighter.State.ACTION and a.action_slot == 1), "slot %d" % a.action_slot)
	await frames(30)
	a.state = Fighter.State.IDLE
	a.skills.reset()
	b.global_position = Vector2(440, m.arena.floor_y)
	ctl.queue = ["attack"]
	await frames(14)
	a.action_connected = true
	if a.state == Fighter.State.ACTION and a.action_phase != "recover":
		a.action_phase = "recover"
		a.action_t = 0.0
	ctl.queue = ["special"]
	await frames(3)
	check("after a connected basic, special cancels the recovery", a.action_slot == 1, "slot %d" % a.action_slot)
	await frames(80)
	# buffer
	a.state = Fighter.State.IDLE
	a.skills.reset()
	ctl.queue = ["attack"]
	await frames(2)
	ctl.queue = ["attack"]    # pressed during the action: buffered
	await frames(2)
	check("a press during an action is buffered", a._buffer_slot == 0 and a._buffer_t > 0.0)
	await frames(60)
	# mobility cancel + dodge counter
	a.state = Fighter.State.IDLE
	a.skills.reset()
	ctl.queue = ["attack"]
	await frames(3)
	a.action_phase = "recover"
	ctl.queue = ["mobility"]
	await frames(3)
	check("mobility cancels an attack's recovery", a.action_slot == 4, "slot %d" % a.action_slot)
	await frames(30)
	a.controller = null
	a.state = Fighter.State.IDLE
	a.skills.reset()
	a.try_skill(4)
	await frames(2)
	var dodged := _hit(a, b, 10.0)
	check("hits during the mobility invulnerability are dodged", dodged == 0.0 and a.counter_t > 0.0, "dodged %f counter %f" % [dodged, a.counter_t])
	check("a dodge opens a counter window (+25%)", absf(a.outgoing_multiplier() - 1.25) < 0.001)
	_hit(b, a, 8.0)
	check("landing the counter consumes it", a.counter_t == 0.0)
	# combo counter and anti-lock
	a.counter_t = 0.0
	a.combo_t = 0.0
	for i in 4:
		_hit(b, a, 3.0)
	check("combo counter counts consecutive hits and damage", a.combo_count == 4 and absf(a.combo_dmg - 12.0) < 0.5, "%d %f" % [a.combo_count, a.combo_dmg])
	check("max combo and damage statistics are tracked", a.stat_max_combo >= 4 and a.stat_damage > 10.0)
	b.health.setup(100000.0)
	var stunned_every_time := true
	for i in 10:
		b.state = Fighter.State.IDLE
		_hit(b, a, 1.0, {"stun": 0.5})
		if i >= 6 and b.state == Fighter.State.HURT:
			stunned_every_time = false
	check("anti-lock: after 6 stunning hits the target cannot be stun-locked", stunned_every_time)
	await _free(m)


func _test_sync() -> void:
	print("--- multiplayer snapshot sync (host -> guest)")
	for id in Library.class_ids():
		var m := await _match(id, "vanguard")
		var host := m.fighters[0]
		host.ult = 63.0
		host.mech.res = 37.0 if id != "gunslinger" else 3.0
		host.mech.aux = 2.0 if id == "arcanist" else 0.0
		host.skills.cooldown_left[4] = 3.5
		host.combo_count = 4
		var snap := host.to_snapshot()
		var cfg := GameState.build_quick_config(1, id, "normal", "forest")
		var puppet := Fighter.new()
		puppet.setup(0, 0, Library.get_class_data(id), "P", 1.0, null)
		puppet.is_puppet = true
		add_child(puppet)
		puppet.from_snapshot(snap)
		check("%s: ultimate, resource, mobility cooldown and combo sync" % id, absf(puppet.ult - 63.0) < 0.01 and absf(puppet.mech.res - host.mech.res) < 0.01 and absf(puppet.skills.cooldown_left[4] - 3.5) < 0.01 and puppet.combo_count == 4 and absf(puppet.mech.aux - host.mech.aux) < 0.01, "ult %f res %f" % [puppet.ult, puppet.mech.res])
		check("%s: snapshot size is small (<= 25 values)" % id, snap.size() <= 25, str(snap.size()))
		puppet.queue_free()
		await _free(m)


func _test_settings() -> void:
	print("--- control settings persistence")
	SaveManager.ctl_preset = "custom"
	SaveManager.ctl_scale = 1.2
	SaveManager.ctl_opacity = 0.55
	SaveManager.ctl_sens = 1.3
	SaveManager.ctl_custom = {"attack": Vector2(-200, -150), "jump": Vector2(400, -90)}
	SaveManager.save()
	SaveManager.reset_controls()
	check("controls reset to defaults", SaveManager.ctl_preset == "standard" and SaveManager.ctl_scale == 1.0)
	SaveManager.load_save()
	check("preset, size, opacity and sensitivity persist after restart", SaveManager.ctl_preset == "custom" and absf(SaveManager.ctl_scale - 1.2) < 0.001 and absf(SaveManager.ctl_opacity - 0.55) < 0.001 and absf(SaveManager.ctl_sens - 1.3) < 0.001)
	var c: Dictionary = SaveManager.ctl_custom
	check("custom button positions persist", c.has("attack") and (c["attack"] as Vector2).is_equal_approx(Vector2(-200, -150)))
	var specs := ControlLayout.resolve(SaveManager.ctl_preset, SaveManager.ctl_custom, SaveManager.ctl_scale)
	check("custom layout resolves from saved data", (specs["attack"]["o"] as Vector2).is_equal_approx(Vector2(-240, -180)))
