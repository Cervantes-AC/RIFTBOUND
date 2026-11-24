extends Node
## Loads every script and scene in the project and reports anything that fails to compile/load.
## Run: godot --headless --path . res://tests/CheckAll.tscn

func _ready() -> void:
	var bad := 0
	var count := 0
	for path in _collect("res://"):
		count += 1
		var res = load(path)
		if res == null:
			print("FAIL load: ", path)
			bad += 1
		elif res is PackedScene:
			var inst = res.instantiate()
			if inst == null:
				print("FAIL instantiate: ", path)
				bad += 1
			else:
				inst.free()
	print("CHECK RESULT: checked %d files, %d failures" % [count, bad])
	get_tree().quit(1 if bad > 0 else 0)

func _collect(dir_path: String) -> Array:
	var out: Array = []
	var d := DirAccess.open(dir_path)
	if d == null:
		return out
	for sub in d.get_directories():
		if sub.begins_with(".") or sub == "docs" or sub == "android" or sub == "build":   # generated Android build template is not game code
			continue
		out.append_array(_collect(dir_path.path_join(sub)))
	for f in d.get_files():
		if f.ends_with(".gd") or f.ends_with(".tscn"):
			out.append(dir_path.path_join(f))
	return out
