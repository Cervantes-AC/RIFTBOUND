extends Control
## Touch-control editor: pick a preset, tune size / opacity / stick sensitivity, then drag any button
## to where your thumb likes it. Everything is saved immediately (user://save.cfg) and used by every match.

var _tc: TouchControls
var _preset_buttons: Dictionary = {}
var _hint: Label


func _ready() -> void:
	PixelUI.screen(self)
	AudioManager.play_music("menu")
	var cls_id := SaveManager.player_class if Library.class_ids().has(SaveManager.player_class) else "vanguard"
	_tc = TouchControls.new()
	_tc.edit_mode = true
	_tc.preview_class = Library.get_class_data(cls_id)
	add_child(_tc)
	# top panel with presets + sliders (kept above the drag area so it never covers the buttons)
	var panel := PixelUI.panel()
	panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	panel.offset_left = 40.0
	panel.offset_right = -40.0
	panel.offset_top = 16.0
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	row.add_child(PixelUI.label("CONTROLS", 24, PixelUI.C_GOLD))
	for p in [["standard", "STANDARD"], ["compact", "COMPACT"]]:
		var b := PixelUI.button(p[1], PixelUI.C_PANEL_LIGHT, 14, Vector2(150, 48))
		b.pressed.connect(func():
			AudioManager.play_sfx("click")
			SaveManager.ctl_preset = p[0]
			SaveManager.set_setting("ctl_preset", p[0])
			_refresh())
		row.add_child(b)
		_preset_buttons[p[0]] = b
	var rst := PixelUI.button("RESET", Color("#8a3a3a"), 14, Vector2(110, 48))
	rst.pressed.connect(func():
		AudioManager.play_sfx("click")
		SaveManager.reset_controls()
		SaveManager.set_setting("ctl_preset", "standard")
		_refresh())
	row.add_child(rst)
	var done := PixelUI.button("SAVE & BACK", Color("#2f7a4a"), 14, Vector2(190, 48))
	done.pressed.connect(_on_back)
	row.add_child(done)
	var sliders := HBoxContainer.new()
	sliders.add_theme_constant_override("separation", 18)
	box.add_child(sliders)
	sliders.add_child(_slider("SIZE", "ctl_scale", ControlLayout.MIN_SCALE, ControlLayout.MAX_SCALE))
	sliders.add_child(_slider("OPACITY", "ctl_opacity", 0.3, 1.0))
	sliders.add_child(_slider("STICK", "ctl_sens", 0.5, 1.5))
	_hint = PixelUI.label("", 14, PixelUI.C_DIM)
	box.add_child(_hint)
	_tc.layout_edited.connect(_refresh)
	_refresh()
	UIManager.back_requested.connect(_on_back)


func _exit_tree() -> void:
	if UIManager.back_requested.is_connected(_on_back):
		UIManager.back_requested.disconnect(_on_back)


func _slider(title: String, key: String, lo: float, hi: float) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(PixelUI.label(title, 14, PixelUI.C_TEXT))
	var s := HSlider.new()
	s.min_value = lo
	s.max_value = hi
	s.step = 0.05
	s.value = SaveManager.get(key)
	s.custom_minimum_size = Vector2(230, 40)
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var trough := PixelUI.box(Color("#08050f"), PixelUI.C_EDGE, 3, 0)
	trough.content_margin_top = 4
	trough.content_margin_bottom = 4
	s.add_theme_stylebox_override("slider", trough)
	s.add_theme_stylebox_override("grabber_area", PixelUI.box(PixelUI.C_RIFT, PixelUI.C_BORDER, 3, 0))
	s.add_theme_stylebox_override("grabber_area_highlight", PixelUI.box(PixelUI.C_GOLD, PixelUI.C_BORDER, 3, 0))
	s.value_changed.connect(func(v): SaveManager.set_setting(key, v))
	row.add_child(s)
	return row


func _refresh() -> void:
	for p in _preset_buttons:
		var on: bool = SaveManager.ctl_preset == p
		PixelUI.style_button(_preset_buttons[p], Color("#7a3a9a") if on else PixelUI.C_PANEL_LIGHT, 14)
	_hint.text = "Layout: %s.  Drag any button to move it (switches to CUSTOM)." % SaveManager.ctl_preset.to_upper()
	_tc.reload_layout()


func _on_back() -> void:
	AudioManager.play_sfx("back")
	SaveManager.save()
	UIManager.go("res://scenes/ui/Settings.tscn")
