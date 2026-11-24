extends Node
## Quick visual check: renders each arena (no fighters) to user://shots/arena_<id>.png. Windowed run.

func _ready() -> void:
	var cam := Camera2D.new()
	cam.position = Vector2(640, 360)
	add_child(cam)
	for id in ["forest", "cavern", "citadel", "shadow", "sanctuary"]:
		var a := Arena.new()
		a.arena_id = id
		add_child(a)
		await get_tree().create_timer(1.3).timeout
		var img := get_viewport().get_texture().get_image()
		DirAccess.make_dir_recursive_absolute("user://shots")
		img.save_png("user://shots/arena_%s.png" % id)
		a.queue_free()
		await get_tree().process_frame
	get_tree().quit()
