extends Node
## Visual smoke test: renders each screen/arena in a real window and saves PNGs to user://shots/.
## Run (not headless): godot --path . res://tests/Screenshots.tscn

const UI_SCENES := ["TitleScreen", "MainMenu", "ModeSelect", "MatchModeSelect", "LevelSelect", "ClassSelect", "OnlineLobby", "Settings", "ControlEditor", "Credits"]


func shot(name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	DirAccess.make_dir_recursive_absolute("user://shots")
	img.save_png("user://shots/%s.png" % name)
	print("saved ", name, " ", img.get_size())


func wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout


func _ready() -> void:
	SaveManager.save_path = "user://shots_save.cfg"
	SaveManager.reset_to_defaults()
	SaveManager.highest_unlocked = 3
	SaveManager.best_stars = {1: 3, 2: 2}
	GameState.pending_flow = {"type": "campaign", "level_id": 2}
	for n in UI_SCENES:
		var inst: Node = load("res://scenes/ui/%s.tscn" % n).instantiate()
		add_child(inst)
		await wait(1.2)
		await shot("ui_" + n)
		inst.queue_free()
		await get_tree().process_frame
	var lobby: Node = load("res://scenes/ui/OnlineLobby.tscn").instantiate()
	add_child(lobby)
	await wait(0.6)
	lobby._show_join()
	await wait(0.4)
	await shot("ui_lobby_join")
	lobby._show_choose()
	lobby._on_host_pressed()
	await wait(0.6)
	await shot("ui_lobby_host")
	NetworkManager.leave()
	lobby.queue_free()
	var pm := PauseMenu.new()
	add_child(pm)
	await wait(0.4)
	await shot("ui_pause")
	pm.queue_free()
	var arenas := ["forest", "cavern", "citadel", "shadow", "sanctuary"]
	var classes := Library.class_ids()
	for i in arenas.size():
		var cfg := GameState.build_quick_config(2 if i % 2 == 0 else 1, classes[i], "hard", arenas[i])
		GameState.pending_match = cfg
		var m: MatchManager = load("res://scenes/levels/Match.tscn").instantiate()
		add_child(m)
		await wait(0.5)
		await shot("match_%s_countdown" % arenas[i])
		m.fighters[0].controller = AIController.new(GameState.AI_PRESETS["hard"])
		await wait(5.0)
		await shot("match_%s_fight" % arenas[i])
		m.queue_free()
		Engine.time_scale = 1.0
		await get_tree().process_frame
	# result screen
	var r := ResultScreen.new()
	add_child(r)
	r.show_result({"outcome": "win", "level_name": "Forgotten Forest", "reason": "You eliminated the opposing team!", "health_ratio": 0.72, "time_used": 31, "campaign": true, "stars": 3, "best_stars": 3, "total_stars": 8, "next_available": true})
	await wait(2.4)
	await shot("result_win")
	get_tree().quit()
