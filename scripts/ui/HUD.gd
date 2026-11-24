class_name HUD
extends CanvasLayer
## Gameplay HUD: team health bars (with a delayed "damage trail"), match timer, objective banner,
## countdown/center messages and the pause button.

signal pause_pressed

var world = null
var bars: Bars
var timer_label: Label
var center_label: Label
var banner: Label
var hint_label: Label
var pause_button: Button
var _center_tween: Tween
var _hint_tween: Tween


class Bars extends Control:
	var world = null
	var trail: Dictionary = {}

	func _process(delta: float) -> void:
		if world == null:
			return
		for f in world.fighters:
			var r: float = f.health.ratio()
			var t: float = trail.get(f.slot, r)
			t = r if t < r else move_toward(t, r, delta * 0.45)
			trail[f.slot] = t
		queue_redraw()

	func _draw() -> void:
		if world == null:
			return
		var inset := PixelUI.safe_insets(get_viewport())
		var margin := 28.0
		for team in 2:
			var members: Array = world.fighters.filter(func(x): return x.team == team)
			var count := members.size()
			var w := 360.0 if count == 1 else 300.0
			var h := 30.0 if count == 1 else 22.0
			var y := 22.0
			for i in count:
				var f: Fighter = members[i]
				var x := margin + inset.x + 64.0 if team == 0 else size.x - margin - inset.y - w - 64.0
				_draw_bar(f, Vector2(x, y), Vector2(w, h), team == 1)
				if f.slot == world.local_slot:
					_draw_meters(f, Vector2(x, y + h + 34.0), team == 1)
					y += 40.0
					_draw_combo(f, inset)
				y += h + 38.0

	## Class resource bar + ultimate meter for the local player (all values synced from the host in online play).
	func _draw_meters(f: Fighter, pos: Vector2, mirrored: bool) -> void:
		var font := PixelUI.FONT
		var w := 230.0
		var x := pos.x if not mirrored else pos.x + (430.0 if false else 0.0)
		var align := HORIZONTAL_ALIGNMENT_LEFT
		if mirrored:
			x = pos.x + (300.0 if world.fighters.size() > 2 else 360.0) - w
		# class resource
		var m: Mechanic = f.mech
		draw_rect(Rect2(x - 3, pos.y - 3, w + 6, 20), Color("#08050f"))
		draw_rect(Rect2(x, pos.y, w, 14), Color("#1a0d14"))
		draw_rect(Rect2(x, pos.y, w * m.fraction(), 14), m.color)
		draw_rect(Rect2(x, pos.y, w * m.fraction(), 5), m.color.lightened(0.4))
		draw_string(font, Vector2(x + 4, pos.y + 12), m.label, align, w, 12, Color.WHITE)
		draw_string(font, Vector2(x, pos.y + 12), m.hud_text(), HORIZONTAL_ALIGNMENT_RIGHT, w - 4, 12, Color.WHITE)
		# ultimate
		var uy := pos.y + 24.0
		var uf := clampf(f.ult / Fighter.ULT_MAX, 0.0, 1.0)
		var ready := uf >= 1.0
		draw_rect(Rect2(x - 3, uy - 3, w + 6, 20), Color("#ffd24a") if ready and fmod(Time.get_ticks_msec() / 250.0, 2.0) < 1.0 else Color("#08050f"))
		draw_rect(Rect2(x, uy, w, 14), Color("#1a0d14"))
		draw_rect(Rect2(x, uy, w * uf, 14), Color("#ffc83a") if ready else Color("#b08a3a"))
		draw_string(font, Vector2(x + 4, uy + 12), "ULTIMATE", align, w, 12, Color.WHITE if not ready else Color("#08050f"))
		draw_string(font, Vector2(x, uy + 12), "READY" if ready else "%d%%" % int(uf * 100.0), HORIZONTAL_ALIGNMENT_RIGHT, w - 4, 12, Color.WHITE if not ready else Color("#08050f"))

	## Combo counter for the local player (hits, damage), fading with the combo timer.
	func _draw_combo(f: Fighter, inset: Vector2) -> void:
		if f.combo_count < 2:
			return
		var font := PixelUI.FONT
		var a := clampf(f.combo_t / 0.5, 0.0, 1.0)
		var pop := 1.0 + 0.25 * clampf((f.combo_t - (Fighter.COMBO_WINDOW - 0.15)) / 0.15, 0.0, 1.0)
		var fs := int(26.0 * pop)
		var x := 32.0 + inset.x
		draw_string(font, Vector2(x + 2, 322), "%d HITS" % f.combo_count, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0, 0, 0, a))
		draw_string(font, Vector2(x, 320), "%d HITS" % f.combo_count, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1.0, 0.82, 0.25, a))
		draw_string(font, Vector2(x, 346), "%d DAMAGE" % int(round(f.combo_dmg)), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1, a))

	func _draw_bar(f: Fighter, pos: Vector2, sz: Vector2, mirrored: bool) -> void:
		var font := PixelUI.FONT
		var ratio := f.health.ratio()
		var tr: float = trail.get(f.slot, ratio)
		var local: bool = f.slot == world.local_slot
		# frame
		draw_rect(Rect2(pos - Vector2(4, 4), sz + Vector2(8, 8)), Color("#08050f"))
		draw_rect(Rect2(pos - Vector2(2, 2), sz + Vector2(4, 4)), Color("#2c2250") if not local else Color("#ffd24a"))
		draw_rect(Rect2(pos, sz), Color("#1a0d14"))
		var fill_w := sz.x * ratio
		var trail_w := sz.x * tr
		var col := Color("#4fd36b")
		if ratio < 0.6:
			col = Color("#f0c23a")
		if ratio < 0.3:
			col = Color("#e8484f")
		if mirrored:
			draw_rect(Rect2(pos.x + sz.x - trail_w, pos.y, trail_w, sz.y), Color(1, 1, 1, 0.85))
			draw_rect(Rect2(pos.x + sz.x - fill_w, pos.y, fill_w, sz.y), col)
			draw_rect(Rect2(pos.x + sz.x - fill_w, pos.y, fill_w, sz.y * 0.35), col.lightened(0.35))
		else:
			draw_rect(Rect2(pos.x, pos.y, trail_w, sz.y), Color(1, 1, 1, 0.85))
			draw_rect(Rect2(pos.x, pos.y, fill_w, sz.y), col)
			draw_rect(Rect2(pos.x, pos.y, fill_w, sz.y * 0.35), col.lightened(0.35))
		# portrait (class art) with team-colour frame
		var pr := Rect2(pos.x - 62.0, pos.y - 2.0, 52, 52) if not mirrored else Rect2(pos.x + sz.x + 10.0, pos.y - 2.0, 52, 52)
		draw_rect(pr.grow(6.0), Color("#ffd24a") if local else (Color("#4a8aff") if not mirrored else Color("#e8484f")))
		Portrait.draw(self, f.data, pr, f.is_dead())
		# class colour chip + name
		var chip := Rect2(pos.x, pos.y + sz.y + 8.0, 16, 16)
		if mirrored:
			chip.position.x = pos.x + sz.x - 16.0
		draw_rect(chip.grow(2), Color("#08050f"))
		draw_rect(chip, f.data.color)
		var name_text := ("YOU: %s" if f.slot == world.local_slot else "%s") % f.data.display_name
		var align := HORIZONTAL_ALIGNMENT_RIGHT if mirrored else HORIZONTAL_ALIGNMENT_LEFT
		var tx := pos.x if not mirrored else pos.x
		draw_string(font, Vector2(tx + (-26.0 if mirrored else 26.0), pos.y + sz.y + 22.0), name_text, align, sz.x, 14, Color.WHITE if not f.is_dead() else Color(1, 1, 1, 0.4))
		if f.is_dead():
			draw_string(font, Vector2(pos.x, pos.y + sz.y - 6.0), "KO", HORIZONTAL_ALIGNMENT_CENTER, sz.x, 16, Color("#e8484f"))


func _ready() -> void:
	layer = 5
	process_mode = Node.PROCESS_MODE_PAUSABLE
	bars = Bars.new()
	bars.set_anchors_preset(Control.PRESET_FULL_RECT)
	bars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bars)
	timer_label = PixelUI.label("90", 40, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	timer_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	timer_label.position = Vector2(-60, 18)
	timer_label.custom_minimum_size = Vector2(120, 0)
	timer_label.size = Vector2(120, 50)
	add_child(timer_label)
	center_label = PixelUI.label("", 64, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	center_label.set_anchors_preset(Control.PRESET_CENTER)
	center_label.custom_minimum_size = Vector2(1000, 0)
	center_label.size = Vector2(1000, 90)
	center_label.position = Vector2(-500, -140)
	center_label.pivot_offset = Vector2(500, 45)
	center_label.modulate.a = 0.0
	add_child(center_label)
	banner = PixelUI.wrap_label("", 16, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner.custom_minimum_size = Vector2(640, 0)
	banner.size = Vector2(640, 40)
	banner.position = Vector2(-320, 86)
	banner.modulate.a = 0.0
	add_child(banner)
	hint_label = PixelUI.wrap_label("", 16, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	hint_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	hint_label.custom_minimum_size = Vector2(620, 0)
	hint_label.size = Vector2(620, 40)
	hint_label.position = Vector2(-310, 150)
	hint_label.modulate.a = 0.0
	add_child(hint_label)
	pause_button = PixelUI.button("II", PixelUI.C_PANEL_LIGHT, 18, Vector2(60, 56))
	pause_button.set_anchors_preset(Control.PRESET_CENTER_TOP)
	pause_button.position = Vector2(110, 20)
	pause_button.size = Vector2(60, 56)
	pause_button.pressed.connect(func(): pause_pressed.emit())
	add_child(pause_button)


func setup(p_world) -> void:
	world = p_world
	bars.world = p_world


func set_time(seconds: float) -> void:
	var s := maxi(int(ceil(seconds)), 0)
	timer_label.text = str(s)
	timer_label.add_theme_color_override("font_color", PixelUI.C_RED if s <= 10 else PixelUI.C_TEXT)


func show_center(text: String, seconds: float = 0.9, color: Color = PixelUI.C_GOLD, font_size: int = 64) -> void:
	center_label.text = text
	center_label.add_theme_font_size_override("font_size", font_size)
	center_label.add_theme_color_override("font_color", color)
	if _center_tween:
		_center_tween.kill()
	center_label.modulate.a = 1.0
	center_label.scale = Vector2(1.5, 1.5)
	_center_tween = create_tween()
	_center_tween.tween_property(center_label, "scale", Vector2.ONE, 0.18).set_ease(Tween.EASE_OUT)
	_center_tween.tween_interval(maxf(seconds - 0.4, 0.05))
	_center_tween.tween_property(center_label, "modulate:a", 0.0, 0.25)


## Round-start presentation: a dark band sweeps in with the arena name and objective, then out.
func show_intro(title: String, subtitle: String, accent: Color) -> void:
	var band := ColorRect.new()
	band.color = Color(0.03, 0.02, 0.08, 0.82)
	band.set_anchors_preset(Control.PRESET_TOP_WIDE)
	band.offset_top = 250.0
	band.offset_bottom = 370.0
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(band)
	for edge_y in [0.0, 116.0]:
		var e := ColorRect.new()
		e.color = accent
		e.set_anchors_preset(Control.PRESET_TOP_WIDE)
		e.offset_top = edge_y
		e.offset_bottom = edge_y + 4.0
		band.add_child(e)
	var t := PixelUI.label(title.to_upper(), 36, accent, HORIZONTAL_ALIGNMENT_CENTER)
	t.set_anchors_preset(Control.PRESET_TOP_WIDE)
	t.offset_top = 18.0
	t.offset_bottom = 62.0
	band.add_child(t)
	var s := PixelUI.label(subtitle, 16, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	s.set_anchors_preset(Control.PRESET_TOP_WIDE)
	s.offset_top = 74.0
	s.offset_bottom = 98.0
	band.add_child(s)
	band.position.x = -1400.0
	var tw := create_tween()
	tw.tween_property(band, "position:x", 0.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_interval(1.8)
	tw.tween_property(band, "position:x", 1400.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_callback(band.queue_free)


func show_banner(text: String, seconds: float = 4.0) -> void:
	banner.text = text
	banner.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(seconds)
	tw.tween_property(banner, "modulate:a", 0.0, 0.5)


func show_hint(text: String, seconds: float = 4.0) -> void:
	hint_label.text = text
	hint_label.modulate.a = 1.0
	if _hint_tween:
		_hint_tween.kill()
	_hint_tween = create_tween()
	_hint_tween.tween_interval(seconds)
	_hint_tween.tween_property(hint_label, "modulate:a", 0.0, 0.5)
