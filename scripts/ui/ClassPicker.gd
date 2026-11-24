class_name ClassPicker
extends HBoxContainer
## Six class cards + a detail panel (stats, basic attack and the three skills).
## Used by Class Select (full) and the Online Lobby (`compact` = no skill list, to save height).

signal class_selected(class_id: String)

var selected := "vanguard"
var compact := false
var _cards: Dictionary = {}
var _preview: ClassPreview
var _detail_box: VBoxContainer
var _name_label: Label
var _desc_label: Label


func _ready() -> void:
	add_theme_constant_override("separation", 20)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	add_child(grid)
	for id in Library.class_ids():
		var card := _make_card(id)
		grid.add_child(card)
		_cards[id] = card
	var detail := PixelUI.panel()
	detail.custom_minimum_size = Vector2(450, 0)
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(detail)
	_detail_box = VBoxContainer.new()
	_detail_box.add_theme_constant_override("separation", 6)
	detail.add_child(_detail_box)
	_build_detail_frame()
	select(selected, false)


func _make_card(id: String) -> Button:
	var b := Button.new()
	var sz := 140.0 if compact else 150.0
	b.custom_minimum_size = Vector2(sz, sz)
	b.focus_mode = Control.FOCUS_NONE
	b.text = ""
	PixelUI.style_button(b, PixelUI.C_PANEL_LIGHT, 16)
	var card_draw := ClassCardArt.new()
	card_draw.class_id = id
	card_draw.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(card_draw)
	b.pressed.connect(func():
		AudioManager.play_sfx("click")
		select(id))
	return b


func _build_detail_frame() -> void:
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	_detail_box.add_child(top)
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(110, 140)
	top.add_child(holder)
	_preview = ClassPreview.new()
	_preview.position = Vector2(55, 132)
	_preview.scale = Vector2(1.0, 1.0)
	holder.add_child(_preview)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 4)
	top.add_child(right)
	_name_label = PixelUI.label("", 22, PixelUI.C_GOLD)
	right.add_child(_name_label)
	_desc_label = PixelUI.wrap_label("", 14, PixelUI.C_DIM)
	_desc_label.custom_minimum_size = Vector2(300, 0)
	right.add_child(_desc_label)


func select(id: String, emit: bool = true) -> void:
	selected = id
	var d := Library.get_class_data(id)
	for cid in _cards:
		var b: Button = _cards[cid]
		var sel: bool = cid == id
		b.add_theme_stylebox_override("normal", PixelUI.box(PixelUI.C_PANEL_LIGHT.lightened(0.1) if sel else PixelUI.C_PANEL, PixelUI.C_GOLD if sel else PixelUI.C_EDGE))
	_preview.show_class(id)
	_name_label.text = d.display_name.to_upper()
	_name_label.add_theme_color_override("font_color", d.color.lightened(0.35))
	_desc_label.text = "%s\n%s." % [d.archetype.to_upper(), d.description.split(". ")[0].trim_suffix(".")]
	while _detail_box.get_child_count() > 1:
		var c := _detail_box.get_child(1)
		_detail_box.remove_child(c)
		c.queue_free()
	_detail_box.add_child(_stat_row("HEALTH", d.max_health / 170.0, "%d" % int(d.max_health), Color("#e8484f")))
	_detail_box.add_child(_stat_row("SPEED", d.move_speed / 300.0, "%d" % int(d.move_speed), Color("#4fb0e8")))
	_detail_box.add_child(_stat_row("JUMPS", d.jump_velocity / 700.0, "x%d" % d.max_jumps, Color("#4fd36b")))
	if not compact:
		for sk in [d.basic] + d.skills:
			_detail_box.add_child(_skill_row(sk, sk == d.basic))
	if emit:
		class_selected.emit(id)


func _stat_row(label_text: String, value: float, value_text: String, color: Color) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var l := PixelUI.label(label_text, 14, PixelUI.C_DIM)
	l.custom_minimum_size = Vector2(120, 0)
	row.add_child(l)
	var bar := StatBar.new()
	bar.value = clampf(value, 0.0, 1.0)
	bar.color = color
	bar.custom_minimum_size = Vector2(190, 18)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(bar)
	row.add_child(PixelUI.label(value_text, 14, PixelUI.C_TEXT))
	return row


func _skill_row(sk: SkillData, is_basic: bool) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var icon := SkillIconBox.new()
	icon.icon = sk.icon
	icon.color = sk.color
	icon.custom_minimum_size = Vector2(42, 42)
	row.add_child(icon)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.add_child(PixelUI.label(("%s (basic)" if is_basic else "%s") % sk.display_name, 16, PixelUI.C_TEXT))
	var sub := "attack, no cooldown" if is_basic else "cooldown %.0fs" % sk.cooldown
	col.add_child(PixelUI.label(sub, 14, PixelUI.C_DIM))
	row.add_child(col)
	return row


class StatBar extends Control:
	var value := 0.5
	var color := Color.WHITE

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#08050f"))
		draw_rect(Rect2(3, 3, size.x - 6, size.y - 6), Color("#1a0d14"))
		draw_rect(Rect2(3, 3, (size.x - 6) * value, size.y - 6), color)


class SkillIconBox extends Control:
	var icon := ""
	var color := Color.WHITE

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#08050f"))
		draw_rect(Rect2(2, 2, size.x - 4, size.y - 4), Color("#2c2250"))
		SkillIcons.draw(self, icon, size * 0.5, size.x * 0.5, color)


class ClassCardArt extends Control:
	var class_id := ""

	func _draw() -> void:
		var d := Library.get_class_data(class_id)
		draw_rect(Rect2(8, 8, size.x - 16, size.y - 52), d.color.darkened(0.55))
		draw_rect(Rect2(8, size.y - 52, size.x - 16, 6), d.color)
		var c := Vector2(size.x * 0.5, size.y - 62)
		draw_rect(Rect2(c.x - 16, c.y - 34, 32, 34), d.color)
		draw_rect(Rect2(c.x - 14, c.y - 62, 28, 26), Color("#f0c8a0"))
		draw_rect(Rect2(c.x - 14, c.y - 66, 28, 12), d.hair if d.id != "vanguard" else d.accent)
		draw_rect(Rect2(c.x - 16, c.y - 16, 32, 6), d.accent)
		var font := PixelUI.FONT
		var fs := 14
		draw_string(font, Vector2(0, size.y - 26), d.display_name.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, size.x, fs if d.display_name.length() < 10 else 12, Color.WHITE)
		draw_string(font, Vector2(0, size.y - 8), d.archetype.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, size.x, 12, d.color.lightened(0.4))
