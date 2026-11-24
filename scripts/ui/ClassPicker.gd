class_name ClassPicker
extends HBoxContainer
## Six class cards + a detail panel: big animated preview on a class-coloured stage, role, stat bars
## (health / damage / speed / jumps) and the basic attack + three skills with one-line descriptions.
## Used by Class Select (full) and the Online Lobby (`compact` = small preview, no skill list).

signal class_selected(class_id: String)

const ROLES := {"vanguard": "TANK", "duelist": "SKIRMISHER", "ranger": "MARKSMAN", "gunslinger": "GUNNER", "arcanist": "CASTER", "shadeweaver": "TRICKSTER"}
const SKILL_TEXT := {
	"vanguard_basic": "Heavy shield strike", "shield_rush": "Charge, knock foes back", "ground_breaker": "Slam: ground shockwave", "iron_fortress": "Barrier blocks damage",
	"duelist_basic": "Fast rapier slash", "quick_slash": "Rapid triple slash", "blade_spin": "Spin: hits all around", "phantom_step": "Step through enemies",
	"ranger_basic": "Quick arrow", "piercing_shot": "Arrow pierces enemies", "arrow_rain": "Arrow rain over an area", "shadow_dash": "Evasive dash",
	"gunslinger_basic": "Pistol shot", "quick_burst": "Rapid burst fire", "explosive_round": "Explodes on impact", "tactical_roll": "Roll away from danger",
	"arcanist_basic": "Arcane orb", "arcane_bolt": "Strong magic bolt", "frost_nova": "Freezing blast, slows", "meteor_fall": "Meteor crashes down",
	"shadeweaver_basic": "Scythe sweep", "shadow_bolt": "Dark energy bolt", "binding_chains": "Chains root the target", "rift_blink": "Teleport through the rift",
}

var selected := "vanguard"
var compact := false
var _cards: Dictionary = {}
var _preview: ClassPreview
var _stage: Stage
var _detail_box: VBoxContainer
var _name_label: Label
var _desc_label: Label


func _ready() -> void:
	add_theme_constant_override("separation", 16)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	grid.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	add_child(grid)
	for id in Library.class_ids():
		var card := _make_card(id)
		grid.add_child(card)
		_cards[id] = card
	var detail := PixelUI.panel()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.custom_minimum_size = Vector2(450 if compact else 600, 0)
	add_child(detail)
	var root := HBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	detail.add_child(root)
	_detail_box = VBoxContainer.new()
	_detail_box.add_theme_constant_override("separation", 6)
	_detail_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if compact:
		root.add_child(_detail_box)
	else:
		_stage = Stage.new()
		_stage.custom_minimum_size = Vector2(190, 0)
		root.add_child(_stage)
		root.add_child(_detail_box)
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
	b.pivot_offset = Vector2(sz, sz) * 0.5
	b.pressed.connect(func():
		AudioManager.play_sfx("click")
		select(id))
	return b


func _build_detail_frame() -> void:
	_preview = ClassPreview.new()
	var head: Control
	if compact:
		var top := HBoxContainer.new()
		top.add_theme_constant_override("separation", 10)
		var holder := Control.new()
		holder.custom_minimum_size = Vector2(110, 140)
		top.add_child(holder)
		_preview.position = Vector2(55, 132)
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
		head = top
	else:
		_preview.scale = Vector2(2.1, 2.1)
		_stage.add_child(_preview)
		_name_label = PixelUI.label("", 26, PixelUI.C_GOLD)
		_desc_label = PixelUI.wrap_label("", 14, PixelUI.C_DIM)
		_desc_label.custom_minimum_size = Vector2(340, 0)
	if head != null:
		_detail_box.add_child(head)
	else:
		_detail_box.add_child(_name_label)
		_detail_box.add_child(_desc_label)


func _fixed_children() -> int:
	return 1 if compact else 2


func select(id: String, emit: bool = true) -> void:
	selected = id
	var d := Library.get_class_data(id)
	for cid in _cards:
		var b: Button = _cards[cid]
		var sel: bool = cid == id
		b.add_theme_stylebox_override("normal", PixelBox.make(PixelUI.C_PANEL_LIGHT.lightened(0.12) if sel else PixelUI.C_PANEL, PixelUI.C_GOLD if sel else PixelUI.C_EDGE))
		if sel and emit:
			var tw := create_tween()
			tw.tween_property(b, "scale", Vector2(1.08, 1.08), 0.08)
			tw.tween_property(b, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK)
	_preview.show_class(id, 1)
	if _stage != null:
		_stage.class_color = d.color
		_stage.pulse()
		_preview.position = Vector2(95, _stage.size.y - 70.0 if _stage.size.y > 0.0 else 330.0)
		_stage.preview = _preview
	_name_label.text = d.display_name.to_upper()
	_name_label.add_theme_color_override("font_color", d.color.lightened(0.35))
	var first_sentence := d.description.split(". ")[0].trim_suffix(".")
	_desc_label.text = "%s - %s\n%s." % [d.archetype.to_upper(), ROLES.get(id, ""), first_sentence]
	while _detail_box.get_child_count() > _fixed_children():
		var c := _detail_box.get_child(_fixed_children())
		_detail_box.remove_child(c)
		c.queue_free()
	var dmgs: Array = []
	for sk in [d.basic] + d.skills:
		if sk.damage > 0.0:
			dmgs.append(sk.damage)
	var avg := 0.0
	for v in dmgs:
		avg += float(v)
	avg /= maxf(dmgs.size(), 1.0)
	_detail_box.add_child(_stat_row("HEALTH", d.max_health / 180.0, "%d" % int(d.max_health), Color("#e8484f")))
	_detail_box.add_child(_stat_row("DAMAGE", avg / 20.0, "%d" % int(round(avg)), Color("#ffb02a")))
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
	l.custom_minimum_size = Vector2(110, 0)
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
	var cd := "basic" if is_basic else "%.0fs" % sk.cooldown
	col.add_child(PixelUI.label("%s  [%s]" % [sk.display_name, cd], 14, PixelUI.C_TEXT))
	col.add_child(PixelUI.label(str(SKILL_TEXT.get(sk.id, "")), 14, PixelUI.C_DIM))
	row.add_child(col)
	return row


class Stage extends Control:
	## Class-coloured spotlight under the big preview: glow, rotating rune ring and a one-shot pulse on select.
	var class_color := Color.WHITE
	var preview: Node2D
	var _t := 0.0
	var _pulse := 0.0

	func pulse() -> void:
		_pulse = 1.0

	func _process(delta: float) -> void:
		_t += delta
		_pulse = maxf(0.0, _pulse - delta * 2.2)
		if preview != null:
			preview.position = Vector2(size.x * 0.5, size.y - 60.0)
		queue_redraw()

	func _draw() -> void:
		var c := Vector2(size.x * 0.5, size.y - 56.0)
		draw_rect(Rect2(Vector2.ZERO, size), Color(class_color.r, class_color.g, class_color.b, 0.10))
		for i in 4:
			draw_circle(c + Vector2(0, -90), 120.0 - i * 24.0, Color(class_color.r, class_color.g, class_color.b, 0.05 + i * 0.015))
		draw_set_transform(c, 0.0, Vector2(1.0, 0.22))
		draw_arc(Vector2.ZERO, 82.0, _t * 0.9, _t * 0.9 + TAU * 0.8, 32, Color(class_color.lightened(0.3), 0.9), 8.0)
		draw_arc(Vector2.ZERO, 58.0, -_t * 1.2, -_t * 1.2 + TAU * 0.6, 24, Color(1, 0.85, 0.4, 0.8), 6.0)
		if _pulse > 0.0:
			draw_arc(Vector2.ZERO, 40.0 + (1.0 - _pulse) * 120.0, 0.0, TAU, 32, Color(1, 1, 1, _pulse), 8.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		for k in 8:   # rising motes
			var my := fmod(_t * (30.0 + k * 6.0) + k * 47.0, 220.0)
			draw_rect(Rect2(c.x + sin(_t + k * 2.0) * 60.0, c.y - my, 4, 4), Color(class_color.lightened(0.4), 1.0 - my / 220.0))


class StatBar extends Control:
	var value := 0.5
	var color := Color.WHITE

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#08050f"))
		draw_rect(Rect2(3, 3, size.x - 6, size.y - 6), Color("#1a0d14"))
		draw_rect(Rect2(3, 3, (size.x - 6) * value, size.y - 6), color)
		draw_rect(Rect2(3, 3, (size.x - 6) * value, 4), color.lightened(0.35))


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
		Portrait.draw(self, d, Rect2(size.x * 0.5 - 30.0, 14.0, 60.0, 60.0))
		var font := PixelUI.FONT
		draw_string(font, Vector2(0, size.y - 38), d.display_name.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, size.x, 14 if d.display_name.length() < 10 else 12, Color.WHITE)
		draw_string(font, Vector2(0, size.y - 20), String(ClassPicker.ROLES.get(class_id, d.archetype)), HORIZONTAL_ALIGNMENT_CENTER, size.x, 12, d.color.lightened(0.4))
		draw_rect(Rect2(14, size.y - 12, size.x - 28, 4), d.color)
