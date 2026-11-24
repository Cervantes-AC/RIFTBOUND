extends Control
## Class selection before a campaign level or quick match. Uses GameState.pending_flow.

var _picker: ClassPicker
var _flow: Dictionary
var _go_btn: Button
var _guide_btn: Button


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
	if _flow["type"] == "browse":
		sub = "Your fighter is used in every mode. Tap a class to preview it."
	elif _flow["type"] == "training":
		sub = "Training room - pick a fighter to practise with."
	elif _flow["type"] == "campaign":
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
	var guide := PixelUI.button("GUIDE", Color("#3a5aa8"), 18, Vector2(220, 64))
	guide.pressed.connect(func():
		if _picker.is_playable(_picker.selected):
			AudioManager.play_sfx("click")
			MoveGuide.open(self, _picker.selected))
	row.add_child(guide)
	_guide_btn = guide
	var go := PixelUI.button("SELECT" if _flow["type"] == "browse" else ("TRAIN!" if _flow["type"] == "training" else "FIGHT!"), Color("#2f7a4a"), 22, Vector2(300, 64))
	go.pressed.connect(_on_fight)
	row.add_child(go)
	_go_btn = go
	_picker.class_selected.connect(_on_class_changed)
	_on_class_changed(_picker.selected)
	UIManager.back_requested.connect(_on_back)


func _exit_tree() -> void:
	if UIManager.back_requested.is_connected(_on_back):
		UIManager.back_requested.disconnect(_on_back)


func _on_class_changed(id: String) -> void:
	var ok := _picker.is_playable(id)
	_go_btn.disabled = not ok
	_guide_btn.disabled = not ok


func _on_fight() -> void:
	if not _picker.is_playable(_picker.selected):
		UIManager.toast("That fighter is planned, not playable yet.")
		return
	AudioManager.play_sfx("click")
	var cls := _picker.selected
	GameState.selected_class = cls
	SaveManager.set_setting("player_class", cls)
	if _flow["type"] == "browse":
		UIManager.toast("%s selected!" % Library.get_class_data(cls).display_name)
		UIManager.go("res://scenes/ui/MainMenu.tscn")
		return
	if _flow["type"] == "training":
		GameState.start_match(GameState.build_training_config(cls, str(_flow.get("arena", "forest"))))
	elif _flow["type"] == "campaign":
		GameState.start_campaign_level(int(_flow["level_id"]), cls)
	else:
		GameState.start_match(GameState.build_quick_config(GameState.quick_team_size, cls, GameState.quick_difficulty, str(_flow.get("arena", "forest"))))


func _on_back() -> void:
	AudioManager.play_sfx("back")
	if _flow["type"] == "browse":
		UIManager.go("res://scenes/ui/MainMenu.tscn")
	elif _flow["type"] == "campaign":
		UIManager.go("res://scenes/ui/LevelSelect.tscn")
	else:
		UIManager.go("res://scenes/ui/MatchModeSelect.tscn")
