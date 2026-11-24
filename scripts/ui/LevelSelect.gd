extends Control
## Campaign level select. Locked levels show a padlock and cannot be opened (lab requirements R1, R4).


class LevelCard extends Button:
	var level: Dictionary
	var unlocked := false
	var stars := 0

	func _draw() -> void:
		var font := PixelUI.FONT
		var arena_theme := ArenaArt.theme_for(str(level["arena"]))
		var w := size.x
		# arena thumbnail
		var thumb := Rect2(14, 54, w - 28, 120)
		for i in 8:
			draw_rect(Rect2(thumb.position.x, thumb.position.y + i * 15.0, thumb.size.x, 16), arena_theme["sky_a"].lerp(arena_theme["sky_b"], i / 7.0))
		_landmark(thumb, str(level["arena"]), arena_theme)
		draw_rect(Rect2(thumb.position.x, thumb.end.y - 28, thumb.size.x, 28), arena_theme["body"])
		draw_rect(Rect2(thumb.position.x, thumb.end.y - 28, thumb.size.x, 8), arena_theme["top"])
		draw_rect(Rect2(thumb.position.x + 30, thumb.end.y - 62, 60, 8), arena_theme["plat"])
		draw_rect(Rect2(thumb.end.x - 90, thumb.end.y - 62, 60, 8), arena_theme["plat"])
		draw_string(font, Vector2(0, 38), "LEVEL %d" % int(level["id"]), HORIZONTAL_ALIGNMENT_CENTER, w, 18, PixelUI.C_GOLD)
		var words: PackedStringArray = str(level["name"]).to_upper().split(" ")
		for wi in words.size():
			draw_string(font, Vector2(4, 198 + wi * 22), words[wi], HORIZONTAL_ALIGNMENT_CENTER, w - 8, 14, PixelUI.C_TEXT)
		if stars > 0 and unlocked:
			draw_rect(Rect2(w - 82, 60, 62, 24), Color("#08050f"))
			draw_string(font, Vector2(w - 78, 79), "CLEAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, PixelUI.C_GREEN)
		# stars
		for i in 3:
			var c := Vector2(w * 0.5 + (i - 1) * 46.0, 262)
			_star(c, 17.0, Color("#ffd24a") if i < stars else Color("#3a3050"))
		var text := _short_objective()
		var y := 316.0
		for line in text:
			draw_string(font, Vector2(4, y), line, HORIZONTAL_ALIGNMENT_CENTER, w - 8, 14, PixelUI.C_DIM)
			y += 22.0
		if not unlocked:
			draw_rect(Rect2(6, 6, w - 12, size.y - 12), Color(0.02, 0.01, 0.05, 0.85))
			_padlock(Vector2(w * 0.5, size.y * 0.42), 1.0)
			draw_string(font, Vector2(0, size.y * 0.42 + 92), "LOCKED", HORIZONTAL_ALIGNMENT_CENTER, w, 18, PixelUI.C_RED)
			draw_string(font, Vector2(4, size.y * 0.42 + 120), "Clear level %d" % (int(level["id"]) - 1), HORIZONTAL_ALIGNMENT_CENTER, w - 8, 14, PixelUI.C_TEXT)

	## One recognisable landmark per arena inside the thumbnail, so the five levels read differently at a glance.
	func _landmark(thumb: Rect2, arena_id: String, th: Dictionary) -> void:
		var c := Vector2(thumb.position.x + thumb.size.x * 0.5, thumb.position.y + 52.0)
		var glow: Color = th["glow"]
		match arena_id:
			"forest":
				draw_arc(c, 26.0, 0.0, TAU, 20, Color("#5a7a6a"), 7.0)
				draw_arc(c, 17.0, 0.0, TAU, 16, Color(glow, 0.9), 4.0)
				for k in 3:
					draw_rect(Rect2(thumb.position.x + 10 + k * 70, thumb.position.y, 14, 90), th["far"].darkened(0.3))
			"cavern":
				draw_rect(Rect2(thumb.position.x, thumb.end.y - 46, thumb.size.x, 18), Color(1.0, 0.4, 0.1, 0.5))
				for k in 4:
					draw_colored_polygon(PackedVector2Array([Vector2(thumb.position.x + 8 + k * 48, thumb.position.y), Vector2(thumb.position.x + 36 + k * 48, thumb.position.y), Vector2(thumb.position.x + 22 + k * 48, thumb.position.y + 34 + (k % 2) * 18)]), Color("#120808"))
				draw_rect(Rect2(c.x - 3, thumb.position.y, 6, 90), Color(1.0, 0.55, 0.15, 0.8))
			"citadel":
				draw_rect(Rect2(c.x - 16, c.y - 4, 32, 54), th["near"].lightened(0.2))
				draw_colored_polygon(PackedVector2Array([Vector2(c.x - 20, c.y - 4), Vector2(c.x + 20, c.y - 4), Vector2(c.x, c.y - 40)]), Color("#c8e4ff"))
				draw_rect(Rect2(c.x - 4, c.y + 10, 8, 12), Color(0.7, 0.95, 1.0))
				draw_colored_polygon(PackedVector2Array([Vector2(thumb.position.x + 14, thumb.end.y - 28), Vector2(thumb.position.x + 24, thumb.end.y - 62), Vector2(thumb.position.x + 34, thumb.end.y - 28)]), Color("#9fe8ff"))
			"shadow":
				draw_circle(c, 30.0, Color("#2e1450"))
				draw_circle(c, 17.0, Color("#e0204a"))
				draw_rect(Rect2(c.x - 3, c.y - 14, 6, 28), Color("#08020c"))
			"sanctuary":
				for k in 4:
					draw_arc(c, 34.0 - k * 7.0, k * 0.8, k * 0.8 + TAU * 0.75, 16, Color("#b04cff") if k % 2 == 0 else Color("#ffd24a"), 4.0)
				draw_circle(c, 6.0, Color.WHITE)

	func _short_objective() -> Array:
		var enemy := Library.get_class_data(str(level["enemy_class"]))
		return [str(level["enemy_name"]), "(%s)" % enemy.display_name, "%ds limit" % int(level["time"])]

	func _star(c: Vector2, r: float, col: Color) -> void:
		var pts := PackedVector2Array()
		for k in 10:
			var a := -PI / 2.0 + k * TAU / 10.0
			pts.append(c + Vector2(cos(a), sin(a)) * (r if k % 2 == 0 else r * 0.45))
		var outline := PackedVector2Array()
		for p in pts:
			outline.append(c + (p - c) * 1.2)
		draw_colored_polygon(outline, Color("#08050f"))
		draw_colored_polygon(pts, col)

	func _padlock(c: Vector2, s: float) -> void:
		draw_arc(c + Vector2(0, -22) * s, 22.0 * s, PI, TAU, 16, Color("#08050f"), 14.0 * s)
		draw_arc(c + Vector2(0, -22) * s, 22.0 * s, PI, TAU, 16, Color("#c8c8d8"), 8.0 * s)
		draw_rect(Rect2(c + Vector2(-34, -24) * s, Vector2(68, 56) * s), Color("#08050f"))
		draw_rect(Rect2(c + Vector2(-29, -19) * s, Vector2(58, 46) * s), Color("#d8a83a"))
		draw_rect(Rect2(c + Vector2(-6, -4) * s, Vector2(12, 22) * s), Color("#3a2a10"))
		draw_circle(c + Vector2(0, 0) * s, 7.0 * s, Color("#3a2a10"))


func _ready() -> void:
	var m := PixelUI.screen(self)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	m.add_child(v)
	v.add_child(PixelUI.label("CAMPAIGN", 36, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	v.add_child(PixelUI.label("Total stars: %d / 15     Unlocked: %d / 5" % [SaveManager.total_stars(), SaveManager.highest_unlocked], 14, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(row)
	for i in Library.level_count():
		var lvl := Library.get_level(i + 1)
		var card := LevelCard.new()
		card.level = lvl
		card.unlocked = SaveManager.is_level_unlocked(i + 1)
		card.stars = SaveManager.get_stars(i + 1)
		card.custom_minimum_size = Vector2(222, 400)
		PixelUI.style_button(card, PixelUI.C_PANEL_LIGHT if card.unlocked else PixelUI.C_PANEL, 12)
		card.pressed.connect(_on_level_pressed.bind(i + 1, card))
		row.add_child(card)
		card.modulate.a = 0.0
		var tw := create_tween()
		tw.tween_interval(0.07 * i)
		tw.tween_property(card, "modulate:a", 1.0, 0.25)
	var back := PixelUI.button("BACK", PixelUI.C_PANEL_LIGHT, 18, Vector2(220, 60))
	back.pressed.connect(_on_back)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(back)
	UIManager.back_requested.connect(_on_back)


func _exit_tree() -> void:
	if UIManager.back_requested.is_connected(_on_back):
		UIManager.back_requested.disconnect(_on_back)


func _on_level_pressed(level_id: int, card: Control) -> void:
	if not SaveManager.is_level_unlocked(level_id):
		AudioManager.play_sfx("lock")
		UIManager.toast("Level %d is locked. Clear level %d first!" % [level_id, level_id - 1])
		var tw := create_tween()
		for i in 3:
			tw.tween_property(card, "position:x", card.position.x + 8, 0.04)
			tw.tween_property(card, "position:x", card.position.x - 8, 0.04)
		tw.tween_property(card, "position:x", card.position.x, 0.04)
		return
	AudioManager.play_sfx("click")
	GameState.pending_flow = {"type": "campaign", "level_id": level_id}
	UIManager.go("res://scenes/ui/ClassSelect.tscn")


func _on_back() -> void:
	AudioManager.play_sfx("back")
	UIManager.go("res://scenes/ui/MainMenu.tscn")
