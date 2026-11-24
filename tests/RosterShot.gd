extends Node
## Visual check of the second six: all in one arena using their zone / companion abilities. Windowed run.

func _ready() -> void:
	SaveManager.save_path = "user://shots_save.cfg"
	SaveManager.reset_to_defaults()
	var ids := ["riftblade", "warden", "stormcaller", "reaper", "chronomancer", "beastbound"]
	var cfg := GameState.build_quick_config(3, ids[5], "normal", "forest")
	for i in 6:
		cfg["fighters"][i]["class_id"] = ids[(i + 5) % 6]
	GameState.pending_match = cfg
	var m: MatchManager = load("res://scenes/levels/Match.tscn").instantiate()
	add_child(m)
	await get_tree().create_timer(0.3).timeout
	m._countdown = 0.0
	m._start_fight()
	for i in 6:
		var f := m.fighters[i]
		f.controller = null
		f.health.setup(9999.0)
		f.global_position = Vector2(130.0 + i * 205.0, m.arena.floor_y)
		f.mech.res = f.mech.max_res
	await get_tree().create_timer(2.6).timeout
	m.fighters[0].try_skill(2)  # beastbound: summon wolf
	m.fighters[2].try_skill(2)  # warden: ward
	m.fighters[5].try_skill(2)  # chronomancer: bubble
	await get_tree().create_timer(1.0).timeout
	DirAccess.make_dir_recursive_absolute("user://shots")
	get_viewport().get_texture().get_image().save_png("user://shots/roster2_match.png")
	get_tree().quit()
