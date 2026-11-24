class_name MatchManager
extends Node2D
## Runs one match (campaign level, quick 1v1/2v2/3v3, or online duel) from GameState.pending_match.
##
## AUTHORITY: offline games and the online HOST simulate everything (damage, cooldowns, timer, winner).
## The online GUEST only sends input and renders host snapshots/effects - it can never declare a result.

enum Phase { LOADING, COUNTDOWN, FIGHTING, ENDED }

const MAIN_MENU := "res://scenes/ui/MainMenu.tscn"
const LEVEL_SELECT := "res://scenes/ui/LevelSelect.tscn"
const LOBBY := "res://scenes/ui/OnlineLobby.tscn"
const CLASS_SELECT := "res://scenes/ui/ClassSelect.tscn"
const SNAPSHOT_EVERY := 2           # physics frames (30 Hz)

var config: Dictionary = {}
var arena: Arena
var fighters: Array[Fighter] = []
var entities: Node2D
var camera: Camera2D
var hud: HUD
var touch: TouchControls
var pause_menu: PauseMenu
var result_screen: ResultScreen
var phase: Phase = Phase.LOADING
var time_left := 90.0
var local_slot := 0
var is_authority := true
var online_role := ""
var show_overhead_bars := true
var winner_team := -2

var _countdown := 3.0
var _last_count := 4
var _shake := 0.0
var _projectile_id := 0
var _net_projectiles: Dictionary = {}
var _snap_tick := 0
var _local_controller := LocalController.new()
var _elapsed := 0.0
var _surge_t := 6.0
var _hint_index := 0
var _hint_t := 3.0
var _wait_guest_t := 0.0
var _result_pending := false
var _disconnected_msg := ""
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	config = GameState.pending_match
	if config.is_empty():
		config = GameState.build_quick_config(1, GameState.selected_class, "normal", "forest")
		GameState.pending_match = config
	# Progression guard: even if this scene is loaded directly, a locked level cannot be played.
	if config["mode"] == "campaign" and not SaveManager.is_level_unlocked(int(config["level_id"])):
		push_warning("Locked level requested - returning to menu.")
		UIManager.go.call_deferred(MAIN_MENU)
		return
	online_role = str(config.get("online_role", ""))
	is_authority = online_role != "guest"
	local_slot = int(config["local_slot"])
	time_left = float(config["time"])
	_build_world()
	_build_ui()
	AudioManager.play_music("battle")
	if online_role == "":
		_begin_countdown()
	else:
		_connect_network()
		if online_role == "guest":
			NetworkManager.send_loaded()
		else:
			phase = Phase.LOADING
			if NetworkManager.guest_is_loaded:
				_begin_countdown()
	UIManager.back_requested.connect(_toggle_pause)


func _exit_tree() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	if touch:
		touch.release_all()
	if UIManager.back_requested.is_connected(_toggle_pause):
		UIManager.back_requested.disconnect(_toggle_pause)


# ----------------------------------------------------------------- construction
func _build_world() -> void:
	var arena_id := str(config["arena"])
	var scene_path := "res://scenes/arenas/%s.tscn" % GameState.ARENA_SCENES.get(arena_id, "ForgottenForest")
	arena = load(scene_path).instantiate()
	arena.world = self
	add_child(arena)
	entities = Node2D.new()
	entities.name = "Entities"
	add_child(entities)
	camera = Camera2D.new()
	camera.position = Vector2(640, 378)
	add_child(camera)
	camera.make_current()
	var team_counts := [0, 0]
	var boss_level := bool(Library.get_level(int(config.get("level_id", 0))).get("boss", false))
	for cfg in config["fighters"]:
		var f := Fighter.new()
		var cd := Library.get_class_data(str(cfg["class_id"]))
		f.setup(int(cfg["slot"]), int(cfg["team"]), cd, str(cfg["name"]), float(cfg["hp_mult"]), self)
		var idx: int = team_counts[int(cfg["team"])]
		team_counts[int(cfg["team"])] += 1
		f.position = arena.spawn_point(int(cfg["team"]), idx)
		f.facing = 1 if int(cfg["team"]) == 0 else -1
		f.input_enabled = false
		match str(cfg["controller"]):
			"local":
				f.controller = _local_controller
			"ai":
				var params: Dictionary = cfg.get("ai", {})
				var boss: bool = boss_level and int(cfg["team"]) == 1
				f.controller = AIController.new(params, boss)
				f.speed_mult = float(params.get("speed", 1.0))
				f.damage_mult = float(params.get("damage", 1.0))
				f.is_boss = boss
			"dummy":
				f.controller = DummyController.new()
				f.damage_mult = 0.3
			"remote":
				f.controller = NetworkManager.remote_controller
			_:
				f.is_puppet = true
		entities.add_child(f)  # fighters live beside effects so z-ordering works
		fighters.append(f)
		f.damaged.connect(_on_fighter_damaged)
		f.eliminated.connect(_on_fighter_eliminated)
		f.health.changed.connect(_on_health_changed.bind(f))
	if config["mode"] == "online":
		show_overhead_bars = true
	arena.set_physics_process(true)


func _build_ui() -> void:
	hud = HUD.new()
	add_child(hud)
	hud.setup(self)
	hud.pause_pressed.connect(_toggle_pause)
	hud.set_time(time_left)
	var tl := CanvasLayer.new()
	tl.layer = 10
	add_child(tl)
	touch = TouchControls.new()
	tl.add_child(touch)
	touch.fighter = fighter_by_slot(local_slot)
	hud.show_intro(str(config["level_name"]), str(config["objective"]), arena.theme["glow"])
	if config["mode"] == "campaign":
		var lose_text: String = config.get("lose_text", "")
		hud.show_hint(lose_text, 5.0)


func _connect_network() -> void:
	var nm := NetworkManager
	nm.disconnected.connect(_on_net_disconnected)
	if online_role == "host":
		nm.guest_loaded.connect(_on_guest_loaded)
	else:
		nm.snapshot_received.connect(_on_snapshot)
		nm.fx_received.connect(func(kind, pos, data): Fx.spawn(entities, kind, pos, data))
		nm.projectile_received.connect(_on_net_projectile)
		nm.area_received.connect(_on_net_area)
		nm.projectile_ended_received.connect(_on_net_projectile_ended)
		nm.result_received.connect(_on_net_result)


func _begin_countdown() -> void:
	phase = Phase.COUNTDOWN
	_countdown = 3.0
	_last_count = 4


# ----------------------------------------------------------------- main loop
func _physics_process(delta: float) -> void:
	if online_role == "guest":
		_guest_tick()
		return
	match phase:
		Phase.LOADING:
			_wait_guest_t += delta
			if _wait_guest_t > 8.0 or NetworkManager.guest_is_loaded:
				_begin_countdown()
		Phase.COUNTDOWN:
			_countdown -= delta
			var n := ceili(_countdown)
			if n != _last_count and n >= 1:
				_last_count = n
				hud.show_center(str(n), 0.8, PixelUI.C_TEXT)
				AudioManager.play_sfx("tick", 1.0 + (3 - n) * 0.1)
			if _countdown <= 0.0:
				_start_fight()
		Phase.FIGHTING:
			_fight_tick(delta)
	if online_role == "host" and NetworkManager.guest_connected():
		_snap_tick += 1
		if _snap_tick % SNAPSHOT_EVERY == 0:
			NetworkManager.send_snapshot(_build_snapshot())


func _start_fight() -> void:
	phase = Phase.FIGHTING
	for f in fighters:
		f.input_enabled = true
	hud.show_center("FIGHT!", 0.9, PixelUI.C_GOLD)
	AudioManager.play_sfx("fight")
	_hint_t = 3.5


func _fight_tick(delta: float) -> void:
	_elapsed += delta
	time_left = maxf(time_left - delta, 0.0)
	hud.set_time(time_left)
	arena.update_hazards(delta, fighters)
	if arena.surges:
		_surge_t -= delta
		if _surge_t <= 0.0:
			_surge_t = _rng.randf_range(6.0, 9.0)
			_spawn_surges()
	_tutorial_hints(delta)
	if config["mode"] == "training":
		_training_tick(delta)
		return
	if _result_pending:
		return
	var alive_teams := {}
	for f in fighters:
		if not f.is_dead():
			alive_teams[f.team] = true
	if alive_teams.size() <= 1:
		var w: int = alive_teams.keys()[0] if alive_teams.size() == 1 else -1
		_finish(w, "knockout")
	elif time_left <= 0.0:
		_finish(_timeout_winner(), "timeout")


## Training room: heal the dummy (and you), refill the ultimate quickly, never end the match.
func _training_tick(delta: float) -> void:
	hud.timer_label.text = "TRAIN"
	for f in fighters:
		if f.is_dead():
			continue
		var heal := f.health.ratio() < (0.5 if f.team == 1 else 0.4)
		if heal:
			f.health.current = f.health.max_health
			f.health.changed.emit(f.health.current, f.health.max_health)
		if f.slot == local_slot:
			f.ult = minf(f.ult + delta * 25.0, Fighter.ULT_MAX)


func _timeout_winner() -> int:
	if config["mode"] == "campaign":
		return 1  # campaign win condition is elimination; running out of time loses
	var hp := [0.0, 0.0]
	var mx := [0.0, 0.0]
	for f in fighters:
		hp[f.team] += f.health.current
		mx[f.team] += f.health.max_health
	var r0: float = hp[0] / maxf(mx[0], 1.0)
	var r1: float = hp[1] / maxf(mx[1], 1.0)
	if absf(r0 - r1) < 0.001:
		return -1
	return 0 if r0 > r1 else 1


func _tutorial_hints(delta: float) -> void:
	var hints: Array = config.get("hints", [])
	if _hint_index >= hints.size():
		return
	_hint_t -= delta
	if _hint_t <= 0.0:
		hud.show_hint(str(hints[_hint_index]), 5.0)
		_hint_index += 1
		_hint_t = 6.0


func _spawn_surges() -> void:
	for i in 2:
		var x := _rng.randf_range(arena.bounds.position.x + 80.0, arena.bounds.end.x - 80.0)
		spawn_area({"style": "surge", "color": Color("#ffd24a"), "pos": Vector2(x, arena.floor_y), "radius": 70.0,
			"delay": 1.2, "ticks": 1, "interval": 0.1, "dmg": 14.0, "kb": 300.0, "kb_up": 520.0, "stun": 0.4,
			"status": "", "status_dur": 0.0, "team": -1, "owner": -1, "source": "surge"})


func _process(delta: float) -> void:
	if _shake > 0.5:
		camera.offset = Vector2(_rng.randf_range(-1, 1), _rng.randf_range(-1, 1)) * _shake
		_shake = move_toward(_shake, 0.0, delta * 60.0)
	else:
		camera.offset = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()


# ----------------------------------------------------------------- services used by combat code
func fighter_by_slot(slot: int) -> Fighter:
	for f in fighters:
		if f.slot == slot:
			return f
	return null


func local_team() -> int:
	var f := fighter_by_slot(local_slot)
	return f.team if f else 0


func nearest_enemy(f: Fighter) -> Fighter:
	return _nearest_of_other_team(f.team, f.global_position)


func nearest_enemy_to(team: int, pos: Vector2) -> Fighter:
	return _nearest_of_other_team(team, pos)


func _nearest_of_other_team(team: int, pos: Vector2) -> Fighter:
	var best: Fighter = null
	var best_d := INF
	for f in fighters:
		if f.team == team or f.is_dead():
			continue
		var d := f.global_position.distance_squared_to(pos)
		if d < best_d:
			best_d = d
			best = f
	return best


func get_projectiles() -> Array:
	return entities.get_children().filter(func(n): return n is Projectile)


func fx(kind: String, pos: Vector2, data: Dictionary = {}) -> void:
	Fx.spawn(entities, kind, pos, data)
	if online_role == "host":
		NetworkManager.send_fx(kind, pos, data)


## Strongest zone/aura damage reduction any teammate currently grants to `target` (they do not stack).
func zone_reduction(target: Fighter) -> float:
	var best := 0.0
	for f in fighters:
		best = maxf(best, f.mech.ward_reduction_for(target))
	return best


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


func spawn_projectile(spec: Dictionary) -> void:
	if not is_authority:
		return
	_projectile_id += 1
	spec["id"] = _projectile_id
	var p := Projectile.new()
	p.net_id = _projectile_id
	p.setup(spec, self, false)
	entities.add_child(p)
	if online_role == "host":
		NetworkManager.send_projectile(spec)


func projectile_ended(net_id: int, pos: Vector2, explode: bool) -> void:
	if online_role == "host":
		NetworkManager.send_projectile_end(net_id, pos, explode)


func spawn_area(spec: Dictionary) -> void:
	if not is_authority:
		return
	var a := AreaEffect.new()
	a.setup(spec, self, false)
	entities.add_child(a)
	if online_role == "host":
		NetworkManager.send_area(spec)


## Explosion damage (Explosive Round). Called by the authority when a shell detonates.
func explode_at(spec: Dictionary, pos: Vector2) -> void:
	var radius := float(spec["explode"])
	fx("ring", pos, {"color": spec["color"], "radius": radius})
	fx("burst", pos, {"color": spec["color"], "count": 16})
	AudioManager.play_sfx("explosion")
	shake(9.0)
	var shape := CircleShape2D.new()
	shape.radius = radius
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, pos)
	params.collision_mask = Fighter.LAYER_FIGHTER
	params.collide_with_bodies = true
	var attacker := fighter_by_slot(int(spec["owner"]))
	for r in get_world_2d().direct_space_state.intersect_shape(params, 12):
		var t = r["collider"]
		if t is Fighter and t.team != int(spec["team"]) and not t.is_dead():
			var h := {"attacker": attacker, "dmg": spec["explode_dmg"], "kb": spec["kb"], "kb_up": spec["kb_up"],
				"stun": spec["stun"], "from_x": pos.x, "source": spec["source"], "color": spec["color"]}
			if t.receive_hit(h):
				on_hit_landed(attacker, t, h)


func on_hit_landed(attacker, target: Fighter, hit: Dictionary) -> void:
	var heavy := float(hit.get("dmg", 0.0)) >= 14.0
	var cls := ""
	var dir := 0.0
	if attacker != null and is_instance_valid(attacker):
		cls = attacker.data.id
		dir = signf(target.global_position.x - attacker.global_position.x)
	fx("hit", target.center(), {"color": hit.get("color", Color.WHITE), "cls": cls, "dir": dir, "heavy": heavy})
	AudioManager.play_sfx("hit_heavy" if heavy else "hit", 0.9 + randf() * 0.2)
	if heavy:
		shake(6.0)


# ----------------------------------------------------------------- reactions
func _on_fighter_damaged(f: Fighter, amount: float, pos: Vector2) -> void:
	if amount > 0.0:
		fx("damage", pos, {"amount": amount})
		AudioManager.play_sfx("hurt", 1.0)
		if f.slot == local_slot:
			UIManager.vibrate(30)
			shake(4.0)


func _on_fighter_eliminated(f: Fighter) -> void:
	fx("burst", f.center(), {"color": f.data.color, "count": 24})
	fx("text", f.global_position + Vector2(0, -110), {"text": "KO!", "color": Color("#ff6a6a"), "size": 30})
	shake(10.0)
	UIManager.vibrate(120)


func _on_health_changed(current: float, maximum: float, f: Fighter) -> void:
	if f.is_boss and not f.enraged and not f.is_dead() and current / maxf(maximum, 1.0) <= 0.5:
		f.apply_enrage()
		hud.show_center("%s IS ENRAGED!" % f.display_name.to_upper(), 1.6, Color("#ff5a5a"), 36)


# ----------------------------------------------------------------- pause
func _toggle_pause() -> void:
	if phase == Phase.ENDED or phase == Phase.LOADING and online_role == "":
		return
	if pause_menu != null:
		_resume()
		return
	pause_menu = PauseMenu.new()
	pause_menu.allow_restart = online_role == ""
	var me := fighter_by_slot(local_slot)
	pause_menu.guide_class = me.data.id if me != null else GameState.selected_class
	add_child(pause_menu)
	pause_menu.resume_pressed.connect(_resume)
	pause_menu.restart_pressed.connect(_restart)
	pause_menu.quit_pressed.connect(_quit_to_menu)
	AudioManager.play_sfx("click")
	touch.release_all()
	touch.visible = false
	if online_role == "":
		get_tree().paused = true


func _resume() -> void:
	if pause_menu:
		pause_menu.queue_free()
		pause_menu = null
	touch.visible = true
	get_tree().paused = false
	AudioManager.play_sfx("click")


func _restart() -> void:
	get_tree().paused = false
	_restart_same_match()


func _quit_to_menu() -> void:
	get_tree().paused = false
	if online_role != "":
		NetworkManager.leave()
	AudioManager.play_sfx("back")
	UIManager.go(MAIN_MENU)


# ----------------------------------------------------------------- match end (authority only)
func _finish(winner: int, reason: String) -> void:
	if _result_pending or phase == Phase.ENDED:
		return
	_result_pending = true
	winner_team = winner
	var hp := [0.0, 0.0]
	var mx := [0.0, 0.0]
	for f in fighters:
		hp[f.team] += f.health.current
		mx[f.team] += f.health.max_health
	var result := {"winner": winner, "reason": reason, "time_used": _elapsed,
		"hp0": hp[0] / maxf(mx[0], 1.0), "hp1": hp[1] / maxf(mx[1], 1.0)}
	if online_role == "host":
		NetworkManager.send_result(result)
	_end_sequence(result)


func _end_sequence(result: Dictionary) -> void:
	phase = Phase.ENDED
	for f in fighters:
		f.input_enabled = false
	if touch:
		touch.release_all()
		touch.visible = false
	Engine.time_scale = 0.4
	await get_tree().create_timer(0.7, true, false, true).timeout
	Engine.time_scale = 1.0
	await get_tree().create_timer(0.6).timeout
	_present_result(result)


func _present_result(result: Dictionary) -> void:
	if not is_inside_tree() or result_screen != null:
		return
	phase = Phase.ENDED
	var my_team := local_team()
	var winner := int(result["winner"])
	var outcome := "draw" if winner == -1 else ("win" if winner == my_team else "lose")
	var me := fighter_by_slot(local_slot)
	var ratio := float(result["hp0"]) if my_team == 0 else float(result["hp1"])
	var mode: String = config["mode"]
	var r := {"outcome": outcome, "level_name": config["level_name"], "health_ratio": ratio,
		"time_used": result["time_used"], "campaign": mode == "campaign", "online": mode == "online", "reason": ""}
	if me != null:
		ratio = me.health.ratio()
		r["health_ratio"] = ratio
		r["max_combo"] = me.stat_max_combo
		r["damage"] = int(round(me.stat_damage))
	match str(result["reason"]):
		"knockout":
			r["reason"] = "You eliminated the opposing team!" if outcome == "win" else ("Your team was eliminated." if outcome == "lose" else "Both sides fell at once.")
		"timeout":
			if mode == "campaign":
				r["reason"] = "Time ran out before the enemy fell."
			else:
				r["reason"] = "Time is up - the team with more health wins." if outcome != "draw" else "Time is up - equal health."
		"disconnect":
			r["reason"] = "The other player disconnected. You win by forfeit." if outcome == "win" else "Connection lost."
	# persistence (offline progression is never touched by online matches)
	if mode == "campaign":
		var lvl := int(config["level_id"])
		if outcome == "win":
			var stars := SaveManager.stars_for_health(ratio)
			SaveManager.complete_level(lvl, stars)
			r["stars"] = stars
			r["best_stars"] = SaveManager.get_stars(lvl)
			r["total_stars"] = SaveManager.total_stars()
			r["next_available"] = lvl < Library.level_count() and SaveManager.is_level_unlocked(lvl + 1)
			if stars >= 3:
				AudioManager.play_sfx("star")
		SaveManager.record_match(outcome == "win", false)
	elif mode == "quick":
		SaveManager.record_match(outcome == "win", false)
	elif mode == "online":
		SaveManager.record_match(outcome == "win", true)
	GameState.last_result = r
	AudioManager.stop_music()
	result_screen = ResultScreen.new()
	add_child(result_screen)
	result_screen.show_result(r)
	result_screen.retry_pressed.connect(_restart_same_match)
	result_screen.next_pressed.connect(_next_level)
	result_screen.menu_pressed.connect(_quit_to_menu)
	result_screen.lobby_pressed.connect(_back_to_lobby)


func _restart_same_match() -> void:
	var mode: String = config["mode"]
	if mode == "campaign":
		GameState.start_campaign_level(int(config["level_id"]), GameState.selected_class)
	elif mode == "training":
		GameState.start_match(GameState.build_training_config(GameState.selected_class, str(config["arena"])))
	elif mode == "quick":
		var team_size: int = (config["fighters"].size()) / 2
		GameState.start_match(GameState.build_quick_config(team_size, GameState.selected_class, GameState.quick_difficulty, str(config["arena"])))
	else:
		UIManager.go(LOBBY)


func _next_level() -> void:
	var next_id := int(config["level_id"]) + 1
	if SaveManager.is_level_unlocked(next_id):
		GameState.start_campaign_level(next_id, GameState.selected_class)
	else:
		UIManager.go(LEVEL_SELECT)


func _back_to_lobby() -> void:
	NetworkManager.leave()
	UIManager.go(LOBBY)


# ----------------------------------------------------------------- online: host side
func _on_guest_loaded() -> void:
	if phase == Phase.LOADING:
		_begin_countdown()


func _on_net_disconnected(message: String) -> void:
	if phase == Phase.ENDED or _result_pending:
		return
	if online_role == "host":
		# guest left mid-match: the host wins by forfeit (host decides the result)
		_finish(0, "disconnect")
	else:
		_disconnected_msg = message
		phase = Phase.ENDED
		if touch:
			touch.release_all()
		_show_disconnect_panel(message)


func _show_disconnect_panel(message: String) -> void:
	Engine.time_scale = 1.0
	result_screen = ResultScreen.new()
	add_child(result_screen)
	result_screen.show_result({"outcome": "draw", "level_name": config["level_name"], "reason": message + " The match was cancelled.",
		"health_ratio": 0.0, "time_used": _elapsed, "campaign": false, "online": true, "note": "Return to the lobby to host or join again."})
	result_screen.lobby_pressed.connect(_back_to_lobby)
	result_screen.menu_pressed.connect(_quit_to_menu)


func _build_snapshot() -> Array:
	var snap: Array = [time_left, arena.time, int(phase), _countdown]
	for f in fighters:
		snap.append(f.to_snapshot())
	return snap


# ----------------------------------------------------------------- online: guest side
func _guest_tick() -> void:
	# send input only; the host decides what actually happens
	var it := _local_controller.update(null, 0.0)
	var mask := 0
	if it.jump_held:
		mask |= RemoteController.BTN_JUMP_HELD
	if it.down:
		mask |= RemoteController.BTN_DOWN
	if phase != Phase.ENDED and pause_menu == null:
		NetworkManager.send_input(it.move, mask)
		if it.jump_pressed:
			NetworkManager.send_press("jump")
		if it.attack_pressed:
			NetworkManager.send_press("attack")
		if it.dodge_pressed:
			NetworkManager.send_press("dodge")
		for i in 3:
			if it.skill_pressed[i]:
				NetworkManager.send_press("skill%d" % (i + 1))


func _on_snapshot(data: Array) -> void:
	if phase == Phase.ENDED:
		return
	time_left = data[0]
	arena.time = data[1]
	var new_phase := int(data[2]) as Phase
	var count := ceili(float(data[3]))
	if new_phase == Phase.COUNTDOWN and count != _last_count and count >= 1:
		_last_count = count
		hud.show_center(str(count), 0.8, PixelUI.C_TEXT)
		AudioManager.play_sfx("tick", 1.0 + (3 - count) * 0.1, 0.0, false)
	if new_phase == Phase.FIGHTING and phase != Phase.FIGHTING:
		hud.show_center("FIGHT!", 0.9, PixelUI.C_GOLD)
	phase = new_phase
	hud.set_time(time_left)
	for i in fighters.size():
		fighters[i].from_snapshot(data[4 + i])


func _on_net_projectile(spec: Dictionary) -> void:
	var p := Projectile.new()
	p.net_id = int(spec["id"])
	p.setup(spec, self, true)
	entities.add_child(p)
	_net_projectiles[p.net_id] = p


func _on_net_area(spec: Dictionary) -> void:
	var a := AreaEffect.new()
	a.setup(spec, self, true)
	entities.add_child(a)


func _on_net_projectile_ended(net_id: int, pos: Vector2, _explode: bool) -> void:
	var p = _net_projectiles.get(net_id)
	if p != null and is_instance_valid(p):
		p.finished = true
		p.queue_free()
	_net_projectiles.erase(net_id)


func _on_net_result(result: Dictionary) -> void:
	if online_role == "guest" and not _result_pending:
		_result_pending = true
		_end_sequence(result)
