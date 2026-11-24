extends Control
## Main menu: Campaign, Local Battle, Wi-Fi Multiplayer, Character Selection, Settings, Credits.
## Hero layout: logo + buttons on the left, the Rift portal with the player's fighter on the right.

var _backdrop: MenuBackdrop
var _fighters: Array[ClassPreview] = []
var _dais: Control
var _buttons: Array[Button] = []


class Dais extends Control:
	var t := 0.0

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		draw_rect(Rect2(-230, 0, 460, 18), Color("#1a1030"))
		draw_rect(Rect2(-230, 0, 460, 4), Color(0.7, 0.4, 1.0, 0.6 + 0.2 * sin(t * 2.0)))
		draw_rect(Rect2(-190, 18, 380, 14), Color("#100a22"))
		draw_set_transform(Vector2(0, 6), 0.0, Vector2(1.0, 0.18))
		draw_arc(Vector2.ZERO, 150.0, t * 0.6, t * 0.6 + TAU * 0.8, 32, Color(1.0, 0.82, 0.3, 0.7), 6.0)
		draw_arc(Vector2.ZERO, 110.0, -t * 0.8, -t * 0.8 + TAU * 0.6, 32, Color(0.8, 0.4, 1.0, 0.7), 6.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


class Pips extends Control:
	## Campaign progress: five nodes joined by a line, filled by progress, stars underneath.
	func _ready() -> void:
		custom_minimum_size = Vector2(440, 54)

	func _draw() -> void:
		var f := PixelUI.FONT
		var n := Library.level_count()
		for i in n:
			var x := 24.0 + i * 98.0
			if i < n - 1:
				draw_rect(Rect2(x + 14, 16, 70, 6), Color("#08050f"))
				draw_rect(Rect2(x + 16, 18, 66, 2), Color("#ffd24a") if SaveManager.get_stars(i + 1) > 0 else Color("#3a3050"))
			var unlocked := SaveManager.is_level_unlocked(i + 1)
			var st := SaveManager.get_stars(i + 1)
			var col := Color("#ffd24a") if st > 0 else (Color("#b04cff") if unlocked else Color("#3a3050"))
			draw_rect(Rect2(x - 14, 5, 28, 28), Color("#08050f"))
			draw_rect(Rect2(x - 10, 9, 20, 20), col)
			draw_string(f, Vector2(x - 6, 26), str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#08050f") if unlocked else Color("#6a6080"))
		draw_string(f, Vector2(0, 50), "STARS %d/15" % SaveManager.total_stars(), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, PixelUI.C_DIM)


func _ready() -> void:
	var m := PixelUI.screen(self, 28, true)
	_backdrop = get_child(0)
	AudioManager.play_music("menu")
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	col.custom_minimum_size = Vector2(470, 0)
	col.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	m.add_child(col)
	var logo := RiftLogo.new()
	logo.font_size = 50
	logo.sub_size = 18
	col.add_child(logo)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 6)
	col.add_child(gap)
	_add(col, "CAMPAIGN", Color("#9a6a1a"), "res://scenes/ui/LevelSelect.tscn", 24, 68)
	_add(col, "LOCAL BATTLE", Color("#3a5aa8"), "res://scenes/ui/MatchModeSelect.tscn", 20, 58)
	_add(col, "WI-FI MULTIPLAYER", Color("#2f7a6a"), "res://scenes/ui/OnlineLobby.tscn", 20, 58)
	_add(col, "CHARACTER SELECTION", Color("#7a3a9a"), "browse", 18, 58)
	var small := HBoxContainer.new()
	small.add_theme_constant_override("separation", 10)
	col.add_child(small)
	for item in [["SETTINGS", "res://scenes/ui/Settings.tscn"], ["CREDITS", "res://scenes/ui/Credits.tscn"]]:
		var b := _add(small, item[0], PixelUI.C_PANEL_LIGHT, item[1], 16, 52)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(Pips.new())
	if not OS.has_feature("web") and not OS.has_feature("mobile"):
		var q := PixelUI.button("X", Color("#8a3a3a"), 16, Vector2(52, 48))
		q.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		q.position = Vector2(-84, 20)
		q.pressed.connect(func(): get_tree().quit())
		add_child(q)
	# right side: portal stage
	_dais = Dais.new()
	add_child(_dais)
	var lead_class := SaveManager.player_class if Library.class_ids().has(SaveManager.player_class) else "vanguard"
	var others: Array = Library.class_ids().filter(func(c): return c != lead_class)
	for spec in [[others[1], 1, 2.1, -250.0, 0.0], [others[3], -1, 2.1, 250.0, 0.0], [lead_class, -1, 3.1, 0.0, 1.0]]:
		var p := ClassPreview.new()
		_fighters.append(p)
		add_child(p)
		p.show_class(spec[0], spec[1])
		p.scale = Vector2.ONE * float(spec[2])
		p.set_meta("dx", spec[3])
		if float(spec[4]) < 0.5:
			p.modulate = Color(0.16, 0.08, 0.3, 0.9)   # silhouettes
	resized.connect(_layout)
	_layout()
	_intro(col)
	UIManager.back_requested.connect(_on_back)


func _add(parent: Control, text: String, color: Color, target: String, size: int, h: int) -> Button:
	var b := PixelUI.button(text, color, size, Vector2(0, h))
	b.focus_mode = Control.FOCUS_ALL
	b.pressed.connect(func(): _go(target))
	parent.add_child(b)
	_buttons.append(b)
	return b


func _layout() -> void:
	var cx := size.x - 400.0
	_backdrop.portal = Vector2(cx / size.x, 0.40)
	var floor_y := size.y * 0.80
	_dais.position = Vector2(cx, floor_y)
	for p in _fighters:
		p.position = Vector2(cx + float(p.get_meta("dx")), floor_y)


func _intro(col: Control) -> void:
	# staggered slide-in of the buttons
	for i in _buttons.size():
		var b := _buttons[i]
		b.modulate.a = 0.0
		b.pivot_offset = b.size * 0.5
		var tw := create_tween()
		tw.tween_interval(0.08 * i + 0.1)
		tw.tween_property(b, "modulate:a", 1.0, 0.25)
	if not _buttons.is_empty():
		_buttons[0].call_deferred("grab_focus")


func _exit_tree() -> void:
	if UIManager.back_requested.is_connected(_on_back):
		UIManager.back_requested.disconnect(_on_back)


func _on_back() -> void:
	UIManager.go("res://scenes/ui/TitleScreen.tscn")


func _go(target: String) -> void:
	AudioManager.play_sfx("click")
	if target == "browse":
		GameState.pending_flow = {"type": "browse"}
		UIManager.go("res://scenes/ui/ClassSelect.tscn")
	else:
		UIManager.go(target)
