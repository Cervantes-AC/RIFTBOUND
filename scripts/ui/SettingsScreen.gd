extends Control
## Settings: sound/music/vibration toggles and volume sliders (saved in user://save.cfg), progress reset.

var _toggles: Dictionary = {}
var _confirm: PanelContainer


func _ready() -> void:
	var m := PixelUI.screen(self)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	m.add_child(v)
	v.add_child(PixelUI.label("SETTINGS", 36, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var panel := PixelUI.panel()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.custom_minimum_size = Vector2(900, 0)
	v.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)
	var toggles := HBoxContainer.new()
	toggles.add_theme_constant_override("separation", 14)
	box.add_child(toggles)
	for key in [["sound_on", "SOUND"], ["music_on", "MUSIC"], ["vibration_on", "VIBRATION"]]:
		var b := PixelUI.button("", PixelUI.C_PANEL_LIGHT, 16, Vector2(0, 66))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(func():
			SaveManager.set_setting(key[0], not SaveManager.get(key[0]))
			AudioManager.play_sfx("click")
			if key[0] == "vibration_on":
				UIManager.vibrate(60)
			_refresh())
		toggles.add_child(b)
		_toggles[key[0]] = [b, key[1]]
	box.add_child(_slider("MASTER VOLUME", "master_volume"))
	box.add_child(_slider("MUSIC VOLUME", "music_volume"))
	box.add_child(_slider("EFFECTS VOLUME", "sfx_volume"))
	var reset := PixelUI.button("RESET PROGRESS", Color("#8a3a3a"), 16, Vector2(0, 60))
	reset.pressed.connect(_ask_reset)
	box.add_child(reset)
	box.add_child(PixelUI.label("Matches: %d   Wins: %d   Losses: %d   Online: %d (%d wins)" % [SaveManager.matches_played, SaveManager.wins, SaveManager.losses, SaveManager.online_matches, SaveManager.online_wins], 14, PixelUI.C_DIM, HORIZONTAL_ALIGNMENT_CENTER))
	var back := PixelUI.button("BACK", PixelUI.C_PANEL_LIGHT, 18, Vector2(220, 60))
	back.pressed.connect(_on_back)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(back)
	_refresh()
	UIManager.back_requested.connect(_on_back)


func _exit_tree() -> void:
	if UIManager.back_requested.is_connected(_on_back):
		UIManager.back_requested.disconnect(_on_back)


func _slider(title: String, key: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	var l := PixelUI.label(title, 16, PixelUI.C_TEXT)
	l.custom_minimum_size = Vector2(260, 0)
	row.add_child(l)
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = SaveManager.get(key)
	s.custom_minimum_size = Vector2(480, 44)
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var trough := PixelUI.box(Color("#08050f"), PixelUI.C_EDGE, 3, 0)
	trough.content_margin_top = 4
	trough.content_margin_bottom = 4
	s.add_theme_stylebox_override("slider", trough)
	s.add_theme_stylebox_override("grabber_area", PixelUI.box(PixelUI.C_RIFT, PixelUI.C_BORDER, 3, 0))
	s.add_theme_stylebox_override("grabber_area_highlight", PixelUI.box(PixelUI.C_GOLD, PixelUI.C_BORDER, 3, 0))
	s.value_changed.connect(func(val):
		SaveManager.set_setting(key, val))
	s.drag_ended.connect(func(_changed): AudioManager.play_sfx("click"))
	row.add_child(s)
	return row


func _refresh() -> void:
	for key in _toggles:
		var b: Button = _toggles[key][0]
		var on: bool = SaveManager.get(key)
		b.text = "%s: %s" % [_toggles[key][1], "ON" if on else "OFF"]
		PixelUI.style_button(b, Color("#2f7a4a") if on else Color("#5a3a3a"), 16)


func _ask_reset() -> void:
	if _confirm != null:
		return
	AudioManager.play_sfx("click")
	var layer := CenterContainer.new()
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	move_child(dim, get_child_count() - 2)
	_confirm = PixelUI.panel(PixelUI.C_PANEL, PixelUI.C_RED)
	layer.add_child(_confirm)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	_confirm.add_child(box)
	box.add_child(PixelUI.label("Erase all progress and stars?", 16, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	box.add_child(row)
	var yes := PixelUI.button("YES, ERASE", Color("#8a3a3a"), 16, Vector2(240, 60))
	yes.pressed.connect(func():
		SaveManager.reset_to_defaults()
		SaveManager.save()
		SaveManager.settings_changed.emit()
		UIManager.go("res://scenes/ui/Settings.tscn"))
	row.add_child(yes)
	var no := PixelUI.button("CANCEL", PixelUI.C_PANEL_LIGHT, 16, Vector2(240, 60))
	no.pressed.connect(func():
		layer.queue_free()
		dim.queue_free()
		_confirm = null)
	row.add_child(no)


func _on_back() -> void:
	AudioManager.play_sfx("back")
	UIManager.go("res://scenes/ui/MainMenu.tscn")
