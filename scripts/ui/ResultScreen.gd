class_name ResultScreen
extends CanvasLayer
## Victory / Defeat / Draw screen with stars and Retry / Next / Menu buttons (lab requirement R3).

signal retry_pressed
signal next_pressed
signal menu_pressed
signal lobby_pressed


class StarRow extends Control:
	var stars := 0
	var _t := 0.0

	func _ready() -> void:
		custom_minimum_size = Vector2(420, 96)

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		for i in 3:
			var c := Vector2(size.x * 0.5 + (i - 1) * 130.0, size.y * 0.5)
			var appear := clampf((_t - 0.5 - i * 0.35) / 0.25, 0.0, 1.0)
			var earned := i < stars
			var r := 40.0 * (1.0 if not earned else (0.6 + 0.4 * appear + 0.25 * sin(appear * PI)))
			var pts := PackedVector2Array()
			for k in 10:
				var a := -PI / 2.0 + k * TAU / 10.0
				var rr := r if k % 2 == 0 else r * 0.45
				pts.append(c + Vector2(cos(a), sin(a)) * rr)
			var outline := PackedVector2Array()
			for p in pts:
				outline.append(c + (p - c) * 1.18)
			draw_colored_polygon(outline, Color("#08050f"))
			if earned and appear > 0.0:
				draw_colored_polygon(pts, Color("#ffd24a"))
				draw_colored_polygon(PackedVector2Array([pts[0], pts[1], pts[9]]), Color("#fff2a0"))
			else:
				draw_colored_polygon(pts, Color("#3a3050"))


class PortraitBox extends Control:
	var class_id := "vanguard"
	var defeated := false

	func _draw() -> void:
		Portrait.draw(self, Library.get_class_data(class_id), Rect2(12, 12, 52, 52), defeated)


## Gold/violet confetti raining over the victory screen (CPU particles, cheap on phones).
func _confetti() -> void:
	var p := CPUParticles2D.new()
	p.position = Vector2(640, -10)
	p.amount = 60
	p.lifetime = 3.2
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(640, 4)
	p.direction = Vector2.DOWN
	p.spread = 12.0
	p.gravity = Vector2(0, 90)
	p.initial_velocity_min = 120.0
	p.initial_velocity_max = 220.0
	p.scale_amount_min = 4.0
	p.scale_amount_max = 8.0
	var g := Gradient.new()
	g.set_color(0, Color("#ffd24a"))
	g.set_color(1, Color(0.7, 0.3, 1.0, 0.0))
	p.color_ramp = g
	add_child(p)


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS


func show_result(r: Dictionary) -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.01, 0.06, 0.78)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var outcome := str(r.get("outcome", "lose"))
	var accent := PixelUI.C_GOLD if outcome == "win" else (PixelUI.C_RED if outcome == "lose" else PixelUI.C_DIM)
	var panel := PixelUI.panel(PixelUI.C_PANEL, accent)
	panel.custom_minimum_size = Vector2(760, 0)
	var sb := panel.get_theme_stylebox("panel") as StyleBoxFlat
	sb.content_margin_top = 26.0
	sb.content_margin_bottom = 24.0
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)
	var head := HBoxContainer.new()
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_theme_constant_override("separation", 24)
	box.add_child(head)
	var pcard := PortraitBox.new()
	pcard.class_id = SaveManager.player_class
	pcard.defeated = outcome == "lose"
	pcard.custom_minimum_size = Vector2(76, 76)
	head.add_child(pcard)
	var title_text := "VICTORY!" if outcome == "win" else ("DEFEAT" if outcome == "lose" else "DRAW")
	var title := PixelUI.label(title_text, 52, accent, HORIZONTAL_ALIGNMENT_CENTER)
	head.add_child(title)
	if outcome == "win":
		_confetti()
	box.add_child(PixelUI.label(str(r.get("level_name", "")), 16, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(PixelUI.wrap_label(str(r.get("reason", "")), 16, PixelUI.C_DIM, HORIZONTAL_ALIGNMENT_CENTER))
	if bool(r.get("campaign", false)):
		var sr := StarRow.new()
		sr.stars = int(r.get("stars", 0)) if outcome == "win" else 0
		box.add_child(sr)
		if outcome == "win":
			var best := int(r.get("best_stars", 0))
			box.add_child(PixelUI.label("Best: %d/3   Total stars: %d" % [best, int(r.get("total_stars", 0))], 16, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER))
		else:
			box.add_child(PixelUI.label("Clear the level to earn stars!", 16, PixelUI.C_DIM, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(PixelUI.label("Health left: %d%%     Time: %ds" % [int(round(float(r.get("health_ratio", 0.0)) * 100.0)), int(r.get("time_used", 0))], 16, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER))
	if r.has("max_combo"):
		box.add_child(PixelUI.label("Best combo: %d hits     Damage dealt: %d" % [int(r["max_combo"]), int(r.get("damage", 0))], 16, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	if r.get("note", "") != "":
		box.add_child(PixelUI.wrap_label(str(r["note"]), 16, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(row)
	if bool(r.get("online", false)):
		var lobby := PixelUI.button("LOBBY", PixelUI.C_PANEL_LIGHT, 18, Vector2(210, 66))
		lobby.pressed.connect(func(): lobby_pressed.emit())
		row.add_child(lobby)
	else:
		var retry := PixelUI.button("RETRY", Color("#8a3a3a"), 18, Vector2(210, 66))
		retry.pressed.connect(func(): retry_pressed.emit())
		row.add_child(retry)
		if bool(r.get("campaign", false)):
			var nxt := PixelUI.button("NEXT", Color("#2f7a4a"), 18, Vector2(210, 66))
			var can_next := bool(r.get("next_available", false))
			nxt.disabled = not can_next
			nxt.pressed.connect(func(): next_pressed.emit())
			row.add_child(nxt)
	var menu := PixelUI.button("MENU", PixelUI.C_PANEL_LIGHT, 18, Vector2(210, 66))
	menu.pressed.connect(func(): menu_pressed.emit())
	row.add_child(menu)
	if bool(r.get("campaign", false)) and not bool(r.get("next_available", false)) and outcome == "win":
		box.add_child(PixelUI.label("You cleared the final level - the Rift is sealed!", 16, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.8, 0.8)
	panel.pivot_offset = Vector2(380, 200)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(panel, "modulate:a", 1.0, 0.3)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	AudioManager.play_sfx("win" if outcome == "win" else "lose")
