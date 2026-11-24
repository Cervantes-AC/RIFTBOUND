extends Control
## Quick match setup: team size (1v1 / 2v2 / 3v3), AI difficulty and arena, then class select.

var _diff_buttons: Dictionary = {}
var _arena_label: Label
var _arena_index := 0
var _team_buttons: Dictionary = {}


func _ready() -> void:
	var m := PixelUI.screen(self)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 16)
	m.add_child(v)
	v.add_child(PixelUI.label("QUICK MATCH", 36, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation", 24)
	cards.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(cards)
	cards.add_child(_mode_card(1, "1v1 DUEL", "You vs one AI fighter"))
	cards.add_child(_mode_card(2, "2v2 TEAM BATTLE", "You + AI ally vs two AI"))
	cards.add_child(_mode_card(3, "3v3 RIFT CLASH", "You + 2 allies vs three AI"))
	var opts := HBoxContainer.new()
	opts.add_theme_constant_override("separation", 14)
	opts.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(opts)
	opts.add_child(PixelUI.label("AI LEVEL", 16, PixelUI.C_DIM))
	for d in ["easy", "normal", "hard"]:
		var b := PixelUI.button(d.to_upper(), PixelUI.C_PANEL_LIGHT, 16, Vector2(170, 60))
		b.pressed.connect(func():
			GameState.quick_difficulty = d
			AudioManager.play_sfx("click")
			_refresh())
		opts.add_child(b)
		_diff_buttons[d] = b
	var arena_row := HBoxContainer.new()
	arena_row.add_theme_constant_override("separation", 14)
	arena_row.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(arena_row)
	arena_row.add_child(PixelUI.label("ARENA", 16, PixelUI.C_DIM))
	var prev := PixelUI.button("<", PixelUI.C_PANEL_LIGHT, 20, Vector2(64, 54))
	prev.pressed.connect(func(): _cycle_arena(-1))
	arena_row.add_child(prev)
	_arena_label = PixelUI.label("", 16, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_arena_label.custom_minimum_size = Vector2(380, 0)
	arena_row.add_child(_arena_label)
	var next := PixelUI.button(">", PixelUI.C_PANEL_LIGHT, 20, Vector2(64, 54))
	next.pressed.connect(func(): _cycle_arena(1))
	arena_row.add_child(next)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(spacer)
	var back := PixelUI.button("BACK", PixelUI.C_PANEL_LIGHT, 18, Vector2(220, 60))
	back.pressed.connect(_on_back)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(back)
	_arena_index = maxi(GameState.ARENA_IDS.find(GameState.online_arena), 0)
	_refresh()
	UIManager.back_requested.connect(_on_back)


func _exit_tree() -> void:
	if UIManager.back_requested.is_connected(_on_back):
		UIManager.back_requested.disconnect(_on_back)


func _mode_card(size: int, title: String, sub: String) -> Control:
	var b := PixelUI.button("", Color("#3a5aa8"), 18, Vector2(340, 190))
	b.pressed.connect(func():
		AudioManager.play_sfx("click")
		GameState.quick_team_size = size
		GameState.pending_flow = {"type": "quick", "arena": GameState.ARENA_IDS[_arena_index]}
		UIManager.go("res://scenes/ui/ClassSelect.tscn"))
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 14)
	b.add_child(box)
	var icons := PixelUI.label("O ".repeat(size).strip_edges() + "  vs  " + "X ".repeat(size).strip_edges(), 18, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	icons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(icons)
	var t := PixelUI.label(title, 17, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(t)
	var s := PixelUI.wrap_label(sub, 14, PixelUI.C_DIM, HORIZONTAL_ALIGNMENT_CENTER)
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(s)
	return b


func _cycle_arena(dir: int) -> void:
	_arena_index = posmod(_arena_index + dir, GameState.ARENA_IDS.size())
	AudioManager.play_sfx("click")
	_refresh()


func _refresh() -> void:
	for d in _diff_buttons:
		var sel: bool = d == GameState.quick_difficulty
		PixelUI.style_button(_diff_buttons[d], Color("#2f7a4a") if sel else PixelUI.C_PANEL_LIGHT, 16)
	_arena_label.text = GameState.ARENA_NAMES[GameState.ARENA_IDS[_arena_index]]


func _on_back() -> void:
	AudioManager.play_sfx("back")
	UIManager.go("res://scenes/ui/MainMenu.tscn")
