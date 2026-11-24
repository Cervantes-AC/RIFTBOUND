extends Node
## Renders key screens at several aspect ratios to user://shots/size_*.png (needs a window).
const SIZES := [Vector2i(1920, 864), Vector2i(1024, 768), Vector2i(854, 480)]
const SCREENS := ["ClassSelect", "LevelSelect", "OnlineLobby", "MainMenu"]

func _ready() -> void:
	SaveManager.save_path = "user://sizes_save.cfg"
	SaveManager.reset_to_defaults()
	GameState.pending_flow = {"type": "campaign", "level_id": 1}
	for sz in SIZES:
		get_window().size = sz
		await get_tree().create_timer(0.5).timeout
		for n in SCREENS:
			var inst: Node = load("res://scenes/ui/%s.tscn" % n).instantiate()
			add_child(inst)
			await get_tree().create_timer(0.6).timeout
			_shot("size_%dx%d_%s" % [sz.x, sz.y, n])
			inst.queue_free()
			await get_tree().process_frame
		GameState.pending_match = GameState.build_quick_config(2, "gunslinger", "normal", "shadow")
		var m: MatchManager = load("res://scenes/levels/Match.tscn").instantiate()
		add_child(m)
		await get_tree().create_timer(0.4).timeout
		m.fighters[0].controller = AIController.new(GameState.AI_PRESETS["normal"])
		await get_tree().create_timer(4.5).timeout
		_shot("size_%dx%d_match" % [sz.x, sz.y])
		m.queue_free()
		Engine.time_scale = 1.0
		await get_tree().process_frame
	get_tree().quit()

func _shot(name: String) -> void:
	DirAccess.make_dir_recursive_absolute("user://shots")
	get_viewport().get_texture().get_image().save_png("user://shots/%s.png" % name)
