extends Control
## Main menu: Offline / Online mode selection (lab requirement R8), Settings, Credits, Quit.


func _ready() -> void:
	var m := PixelUI.screen(self)
	AudioManager.play_music("menu")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 40)
	m.add_child(row)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	col.custom_minimum_size = Vector2(500, 0)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(col)
	var title := PixelUI.label("RIFTBOUND", 52, PixelUI.C_GOLD)
	title.add_theme_constant_override("outline_size", 10)
	col.add_child(title)
	col.add_child(PixelUI.label("ARENA CLASH", 20, PixelUI.C_RIFT))
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	col.add_child(spacer)
	col.add_child(_btn("PLAY OFFLINE", Color("#2f7a4a"), func(): _go("res://scenes/ui/ModeSelect.tscn")))
	col.add_child(_btn("PLAY ONLINE (WI-FI)", Color("#3a5aa8"), func(): _go("res://scenes/ui/OnlineLobby.tscn")))
	var small := HBoxContainer.new()
	small.add_theme_constant_override("separation", 12)
	col.add_child(small)
	var s := _btn("SETTINGS", PixelUI.C_PANEL_LIGHT, func(): _go("res://scenes/ui/Settings.tscn"), 16)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	small.add_child(s)
	var c := _btn("CREDITS", PixelUI.C_PANEL_LIGHT, func(): _go("res://scenes/ui/Credits.tscn"), 16)
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	small.add_child(c)
	if not OS.has_feature("web"):
		col.add_child(_btn("QUIT", Color("#8a3a3a"), func(): get_tree().quit(), 16))
	col.add_child(PixelUI.label("Stars: %d/15    Unlocked level: %d/5" % [SaveManager.total_stars(), SaveManager.highest_unlocked], 14, PixelUI.C_DIM))
	var stage := Control.new()
	stage.custom_minimum_size = Vector2(560, 560)
	row.add_child(stage)
	var a := ClassPreview.new()
	a.position = Vector2(150, 470)
	a.scale = Vector2(2.6, 2.6)
	stage.add_child(a)
	a.show_class(SaveManager.player_class, 1)
	var b := ClassPreview.new()
	b.position = Vector2(430, 470)
	b.scale = Vector2(2.6, 2.6)
	stage.add_child(b)
	b.show_class("shadeweaver" if SaveManager.player_class != "shadeweaver" else "ranger", -1)
	UIManager.back_requested.connect(_on_back)


func _exit_tree() -> void:
	if UIManager.back_requested.is_connected(_on_back):
		UIManager.back_requested.disconnect(_on_back)


func _on_back() -> void:
	UIManager.go("res://scenes/ui/TitleScreen.tscn")


func _btn(text: String, color: Color, cb: Callable, size: int = 22) -> Button:
	var b := PixelUI.button(text, color, size, Vector2(0, 72 if size > 18 else 60))
	b.pressed.connect(cb)
	return b


func _go(path: String) -> void:
	AudioManager.play_sfx("click")
	UIManager.go(path)
