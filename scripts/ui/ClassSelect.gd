extends Control
## Class selection before a campaign level or quick match. Uses GameState.pending_flow.

var _picker: ClassPicker
var _flow: Dictionary


func _ready() -> void:
	_flow = GameState.pending_flow
	if _flow.is_empty():
		_flow = {"type": "quick", "arena": "forest"}
	var m := PixelUI.screen(self)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	m.add_child(v)
	v.add_child(PixelUI.label("CHOOSE YOUR CLASS", 32, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var sub := ""
	if _flow["type"] == "campaign":
		var lvl := Library.get_level(int(_flow["level_id"]))
		sub = "Level %d - %s: %s" % [lvl["id"], lvl["name"], lvl["objective"]]
	else:
		var n: int = GameState.quick_team_size
		sub = "%dv%d - %s (%s AI)" % [n, n, GameState.ARENA_NAMES.get(_flow.get("arena", "forest"), ""), GameState.quick_difficulty]
	var s := PixelUI.wrap_label(sub, 14, PixelUI.C_DIM, HORIZONTAL_ALIGNMENT_CENTER)
	s.custom_minimum_size = Vector2(900, 0)
	v.add_child(s)
	_picker = ClassPicker.new()
	_picker.selected = SaveManager.player_class if Library.class_ids().has(SaveManager.player_class) else "vanguard"
	_picker.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_picker.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(_picker)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(row)
	var back := PixelUI.button("BACK", PixelUI.C_PANEL_LIGHT, 18, Vector2(220, 64))
	back.pressed.connect(_on_back)
	row.add_child(back)
	var go := PixelUI.button("FIGHT!", Color("#2f7a4a"), 22, Vector2(300, 64))
	go.pressed.connect(_on_fight)
	row.add_child(go)
	UIManager.back_requested.connect(_on_back)


func _exit_tree() -> void:
	if UIManager.back_requested.is_connected(_on_back):
		UIManager.back_requested.disconnect(_on_back)


func _on_fight() -> void:
	AudioManager.play_sfx("click")
	var cls := _picker.selected
	GameState.selected_class = cls
	SaveManager.set_setting("player_class", cls)
	if _flow["type"] == "campaign":
		GameState.start_campaign_level(int(_flow["level_id"]), cls)
	else:
		GameState.start_match(GameState.build_quick_config(GameState.quick_team_size, cls, GameState.quick_difficulty, str(_flow.get("arena", "forest"))))


func _on_back() -> void:
	AudioManager.play_sfx("back")
	if _flow["type"] == "campaign":
		UIManager.go("res://scenes/ui/LevelSelect.tscn")
	else:
		UIManager.go("res://scenes/ui/MatchModeSelect.tscn")
