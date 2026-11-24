extends Control
## Offline mode selection: Campaign (5 levels) or Quick Match (1v1 / 2v2 / 3v3 vs computer).


func _ready() -> void:
	var m := PixelUI.screen(self)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 22)
	m.add_child(v)
	v.add_child(PixelUI.label("PLAY OFFLINE", 36, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	v.add_child(PixelUI.label("No internet needed - works in airplane mode", 16, PixelUI.C_DIM, HORIZONTAL_ALIGNMENT_CENTER))
	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation", 30)
	cards.alignment = BoxContainer.ALIGNMENT_CENTER
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(cards)
	cards.add_child(_card("CAMPAIGN", "5 arenas, rising difficulty.\nClear a level to unlock the next.\nEarn up to 15 stars.", Color("#8a5a2a"), "res://scenes/ui/LevelSelect.tscn"))
	cards.add_child(_card("QUICK MATCH", "1v1 Duel, 2v2 Team Battle\nor 3v3 Rift Clash against the\ncomputer. Pick any arena.", Color("#3a5aa8"), "res://scenes/ui/MatchModeSelect.tscn"))
	var back := PixelUI.button("BACK", PixelUI.C_PANEL_LIGHT, 18, Vector2(220, 60))
	back.pressed.connect(_on_back)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(back)
	UIManager.back_requested.connect(_on_back)


func _exit_tree() -> void:
	if UIManager.back_requested.is_connected(_on_back):
		UIManager.back_requested.disconnect(_on_back)


func _card(title: String, desc: String, color: Color, target: String) -> Control:
	var b := PixelUI.button("", color, 18, Vector2(480, 300))
	b.pressed.connect(func():
		AudioManager.play_sfx("click")
		UIManager.go(target))
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 20)
	b.add_child(box)
	var t := PixelUI.label(title, 30, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(t)
	var d := PixelUI.wrap_label(desc, 16, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	d.mouse_filter = Control.MOUSE_FILTER_IGNORE
	d.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(d)
	return b


func _on_back() -> void:
	AudioManager.play_sfx("back")
	UIManager.go("res://scenes/ui/MainMenu.tscn")
