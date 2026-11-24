extends Node
## Class balance sweep: every class vs every class (AI 'normal' on both sides), N rounds each.
## Run: godot --headless --path . --fixed-fps 60 res://tests/Balance.tscn
## Output is a win matrix (row class beats column class, as % of rounds) + average fight length.

var ROUNDS := int(OS.get_environment("ROUNDS")) if OS.get_environment("ROUNDS") != "" else 4


func _ready() -> void:
	SaveManager.save_path = "user://balance_save.cfg"
	AudioManager.process_mode = Node.PROCESS_MODE_DISABLED
	var ids := Library.class_ids()
	var wins := {}
	var draws := {}
	var total_time := 0.0
	var fights := 0
	for a in ids:
		for b in ids:
			if a == b:
				continue
			wins[a + b] = 0
			draws[a + b] = 0
			for r in ROUNDS:
				var cfg := GameState.build_quick_config(1, a, "normal", "forest")
				cfg["fighters"][1]["class_id"] = b
				cfg["time"] = 60.0
				GameState.pending_match = cfg
				var m: MatchManager = load("res://scenes/levels/Match.tscn").instantiate()
				add_child(m)
				await get_tree().physics_frame
				await get_tree().physics_frame
				m.fighters[0].controller = AIController.new(GameState.AI_PRESETS["normal"])
				m._countdown = 0.0
				var n := 0
				while m.phase != MatchManager.Phase.ENDED and n < 4500:
					await get_tree().physics_frame
					n += 1
				if m.winner_team == 0:
					wins[a + b] += 1
				elif m.winner_team == -1:
					draws[a + b] += 1
				total_time += m._elapsed
				fights += 1
				m.queue_free()
				Engine.time_scale = 1.0
				await get_tree().physics_frame
	print("")
	print("WIN RATE of ROW class vs COLUMN class (%d rounds each; AI vs AI, 'normal' difficulty, Forgotten Forest, 60s limit)" % ROUNDS)
	var header := "%-12s" % ""
	for b in ids:
		header += "%-12s" % b.substr(0, 10)
	header += "avg"
	print(header)
	for a in ids:
		var line := "%-12s" % a
		var sum := 0.0
		var cnt := 0
		for b in ids:
			if a == b:
				line += "%-12s" % "-"
			else:
				var pct: float = 100.0 * wins[a + b] / ROUNDS
				sum += pct
				cnt += 1
				line += "%-12s" % ("%d%%" % pct)
		line += "%d%%" % (sum / cnt)
		print(line)
	print("average fight length: %.1fs over %d fights" % [total_time / fights, fights])
	get_tree().quit()
