extends Node
## Renders chosen UI scenes to user://shots/ui2_<name>.png. Windowed. Names come from the UISHOTS env var (comma list).

func _ready() -> void:
	SaveManager.save_path = "user://shots_save.cfg"
	SaveManager.reset_to_defaults()
	SaveManager.highest_unlocked = 3
	SaveManager.best_stars = {1: 3, 2: 2}
	GameState.pending_flow = {"type": "campaign", "level_id": 2}
	var names := OS.get_environment("UISHOTS").split(",")
	for n in names:
		var inst: Node = load("res://scenes/ui/%s.tscn" % n).instantiate()
		add_child(inst)
		if OS.get_environment("PICK") != "" and "_picker" in inst:
			inst._picker.select(OS.get_environment("PICK"))
		await get_tree().create_timer(1.6).timeout
		DirAccess.make_dir_recursive_absolute("user://shots")
		get_viewport().get_texture().get_image().save_png("user://shots/ui2_%s.png" % n)
		inst.queue_free()
		await get_tree().process_frame
	get_tree().quit()
