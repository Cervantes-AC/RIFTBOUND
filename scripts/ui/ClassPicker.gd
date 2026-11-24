class_name ClassPicker
extends HBoxContainer
## Roster grid (6 playable fighters + 6 planned, clearly locked) and a detail panel: big animated preview on a
## class-coloured stage, role, difficulty, stat bars (health / damage / speed / jumps), mechanic + passive names and
## the five abilities with one-line descriptions. Planned fighters show their design but can never be selected to play.
## `compact` (online lobby) = playable fighters only, small preview, no ability list.

signal class_selected(class_id: String)

const SKILL_TEXT := {
	"vanguard_basic": "Heavy shield strike", "ground_breaker": "Slam: ground shockwave", "retaliate": "Counter: spends Bulwark", "shield_rush": "Charge, knock foes back", "bastion": "ULT: team shield + blast",
	"duelist_basic": "Fast rapier slash", "quick_slash": "Rapid triple slash", "phantom_step": "Step through enemies", "sidestep": "Short invulnerable step", "thousand_cuts": "ULT: blink + 8 cuts",
	"ranger_basic": "Quick arrow (aimed +50%)", "piercing_shot": "Arrow pierces enemies", "hunters_mark": "Mark: +25% damage taken", "shadow_dash": "Evasive dash backwards", "arrow_storm": "ULT: storm of arrows",
	"gunslinger_basic": "Pistol shot, 1 ammo", "quick_burst": "4 rapid shots, 3 ammo", "explosive_round": "Explosive shell, 2 ammo", "tactical_roll": "Roll and reload 2", "dead_eye": "ULT: fan + infinite ammo",
	"arcanist_basic": "Orb of attuned element", "arcane_bolt": "Homing elemental bolt", "attune": "Cycle Fire/Frost/Storm", "arcane_slip": "Slip backwards", "cataclysm": "ULT: colossal meteor",
	"shadeweaver_basic": "Scythe sweep (+Shadow)", "binding_chains": "Roots target 1.4s", "shadow_echo": "Teleport, swap back", "rift_blink": "Blink + burst", "eclipse": "ULT: roots all nearby",
}
const SLOT_NAMES := ["BASIC", "SPECIAL", "SIGNATURE", "ULTIMATE", "MOBILITY"]

var selected := "vanguard"
var compact := false
var _cards: Dictionary = {}
var _preview: ClassPreview
var _stage: Stage
var _detail_box: VBoxContainer
var _name_label: Label
var _desc_label: Label


func ids() -> Array:
	return Library.class_ids() if compact else Library.roster_ids()


func _ready() -> void:
	add_theme_constant_override("separation", 14)
	var grid := GridContainer.new()
	grid.columns = 3 if compact else 4
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	grid.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	add_child(grid)
	for id in ids():
		var card := _make_card(id)
		grid.add_child(card)
		_cards[id] = card
	var detail := PixelUI.panel()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.custom_minimum_size = Vector2(450 if compact else 560, 0)
	add_child(detail)
	var root := HBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	detail.add_child(root)
	_detail_box = VBoxContainer.new()
	_detail_box.add_theme_constant_override("separation", 4)
	_detail_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if compact:
		root.add_child(_detail_box)
	else:
		_stage = Stage.new()
		_stage.custom_minimum_size = Vector2(170, 0)
		root.add_child(_stage)
		root.add_child(_detail_box)
	_build_detail_frame()
	select(selected, false)


func _make_card(id: String) -> Button:
	var b := Button.new()
	var sz := 140.0 if compact else 124.0
	b.custom_minimum_size = Vector2(sz, sz)
	b.focus_mode = Control.FOCUS_NONE
	b.text = ""
	PixelUI.style_button(b, PixelUI.C_PANEL_LIGHT, 16)
	var card_draw := ClassCardArt.new()
	card_draw.class_id = id
	card_draw.compact = compact
	card_draw.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(card_draw)
	b.pivot_offset = Vector2(sz, sz) * 0.5
	b.pressed.connect(func():
		AudioManager.play_sfx("click" if not Library.get_class_data(id).planned else "lock")
		select(id))
	return b


func _build_detail_frame() -> void:
	_preview = ClassPreview.new()
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
		_detail_box.add_child(top)
	else:
		_preview.scale = Vector2(1.9, 1.9)
		_stage.add_child(_preview)
		_name_label = PixelUI.label("", 22, PixelUI.C_GOLD)
		_desc_label = PixelUI.wrap_label("", 14, PixelUI.C_DIM)
		_desc_label.custom_minimum_size = Vector2(340, 0)
		_detail_box.add_child(_name_label)
		_detail_box.add_child(_desc_label)


func _fixed_children() -> int:
	return 1 if compact else 2


func is_playable(id: String) -> bool:
	return not Library.get_class_data(id).planned


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
	if not d.planned:
		_preview.visible = true
		_preview.show_class(id, 1)
	else:
		_preview.visible = false
	if _stage != null:
		_stage.class_color = d.color
		_stage.planned = d.planned
		_stage.class_id = id
		_stage.pulse()
		_stage.preview = _preview
	_name_label.text = d.display_name.to_upper()
	_name_label.add_theme_color_override("font_color", d.color.lightened(0.35))
	var stars := "*".repeat(d.difficulty) + "-".repeat(5 - d.difficulty)
	_desc_label.text = "%s\n%s  DIFFICULTY %s" % [d.title, d.role.to_upper(), stars] if not compact else "%s\n%s" % [d.archetype.to_upper(), d.description.split(". ")[0].trim_suffix(".")]
	while _detail_box.get_child_count() > _fixed_children():
		var c := _detail_box.get_child(_fixed_children())
		_detail_box.remove_child(c)
		c.queue_free()
	if d.planned:
		var tag := PixelUI.label("PLANNED - NOT PLAYABLE YET", 14, PixelUI.C_RED)
		_detail_box.add_child(tag)
		_detail_box.add_child(_text_row("LORE", d.lore))
		_detail_box.add_child(_text_row("MECHANIC: " + d.mech_name, d.mech_desc))
		_detail_box.add_child(_text_row("PASSIVE: " + d.passive_name, d.passive_desc))
		_detail_box.add_child(PixelUI.wrap_label("Designed in docs/COMBAT_REDESIGN.md. It is shown here so you can see the roster, but it cannot be selected to fight until it is implemented.", 14, PixelUI.C_DIM))
		if emit:
			class_selected.emit(id)
		return
	var dmgs: Array = []
	for sk in [d.basic] + d.skills:
		if sk.damage > 0.0 and not sk.is_ultimate:
			dmgs.append(sk.damage)
	var avg := 0.0
	for v in dmgs:
		avg += float(v)
	avg /= maxf(dmgs.size(), 1.0)
	_detail_box.add_child(_stat_row("HEALTH", d.max_health / 180.0, "%d" % int(d.max_health), Color("#e8484f")))
	_detail_box.add_child(_stat_row("DAMAGE", avg / 20.0, "%d" % int(round(avg)), Color("#ffb02a")))
	_detail_box.add_child(_stat_row("SPEED", d.move_speed / 320.0, "%d" % int(d.move_speed), Color("#4fb0e8")))
	_detail_box.add_child(_stat_row("JUMPS", d.jump_velocity / 700.0, "x%d" % d.max_jumps, Color("#4fd36b")))
	if not compact:
		_detail_box.add_child(PixelUI.label("MECHANIC %s   PASSIVE %s" % [d.mech_name, d.passive_name.to_upper()], 12, Color("#ffd24a")))
		var order := [[d.basic, 0], [d.skills[0], 1], [d.skills[1], 2], [d.mobility, 4], [d.skills[2], 3]]
		for o in order:
			_detail_box.add_child(_skill_row(o[0], o[1]))
	if emit:
		class_selected.emit(id)


func _text_row(title: String, text: String) -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	v.add_child(PixelUI.label(title, 14, PixelUI.C_GOLD))
	var l := PixelUI.wrap_label(text, 14, PixelUI.C_TEXT)
	l.custom_minimum_size = Vector2(340, 0)
	v.add_child(l)
	return v


func _stat_row(label_text: String, value: float, value_text: String, color: Color) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var l := PixelUI.label(label_text, 14, PixelUI.C_DIM)
	l.custom_minimum_size = Vector2(110, 0)
	row.add_child(l)
	var bar := StatBar.new()
	bar.value = clampf(value, 0.0, 1.0)
	bar.color = color
	bar.custom_minimum_size = Vector2(170, 16)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(bar)
	row.add_child(PixelUI.label(value_text, 14, PixelUI.C_TEXT))
	return row


func _skill_row(sk: SkillData, slot: int) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var icon := SkillIconBox.new()
	icon.icon = sk.icon
	icon.color = sk.color
	icon.custom_minimum_size = Vector2(38, 38)
	row.add_child(icon)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	col.add_child(PixelUI.label("%s [%s]" % [sk.display_name, SLOT_NAMES[slot]], 14, PixelUI.C_GOLD if slot == 3 else PixelUI.C_TEXT))
	col.add_child(PixelUI.label(str(SKILL_TEXT.get(sk.id, "")), 14, PixelUI.C_DIM))
	row.add_child(col)
	return row


class Stage extends Control:
	## Class-coloured spotlight under the big preview: glow, rotating rune ring and a one-shot pulse on select.
	var class_color := Color.WHITE
	var class_id := ""
	var planned := false
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
			draw_circle(c + Vector2(0, -90), 110.0 - i * 22.0, Color(class_color.r, class_color.g, class_color.b, 0.05 + i * 0.015))
		draw_set_transform(c, 0.0, Vector2(1.0, 0.22))
		draw_arc(Vector2.ZERO, 76.0, _t * 0.9, _t * 0.9 + TAU * 0.8, 32, Color(class_color.lightened(0.3), 0.9), 8.0)
		draw_arc(Vector2.ZERO, 54.0, -_t * 1.2, -_t * 1.2 + TAU * 0.6, 24, Color(1, 0.85, 0.4, 0.8), 6.0)
		if _pulse > 0.0:
			draw_arc(Vector2.ZERO, 40.0 + (1.0 - _pulse) * 110.0, 0.0, TAU, 32, Color(1, 1, 1, _pulse), 8.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if planned:   # silhouette placeholder for a roster entry that is not implemented yet
			var d := Library.get_class_data(class_id)
			Portrait.draw(self, d, Rect2(size.x * 0.5 - 40.0, size.y * 0.5 - 90.0, 80.0, 80.0), true)
			draw_string(PixelUI.FONT, Vector2(0, size.y * 0.5 + 20.0), "PLANNED", HORIZONTAL_ALIGNMENT_CENTER, size.x, 16, PixelUI.C_RED)
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
	var compact := false

	func _draw() -> void:
		var d := Library.get_class_data(class_id)
		var s := 60.0 if compact else 52.0
		Portrait.draw(self, d, Rect2(size.x * 0.5 - s * 0.5, 10.0, s, s), d.planned)
		var font := PixelUI.FONT
		var fs := 14 if compact else 12
		if not compact and d.display_name.length() > 9:
			fs = 10
		draw_string(font, Vector2(0, size.y - 30 if compact else size.y - 26), d.display_name.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, size.x, fs, Color.WHITE if not d.planned else Color(1, 1, 1, 0.55))
		var sub := "PLANNED" if d.planned else d.role.split(" / ")[0].to_upper()
		draw_string(font, Vector2(0, size.y - 12 if compact else size.y - 10), sub, HORIZONTAL_ALIGNMENT_CENTER, size.x, 11 if not compact else 12, PixelUI.C_RED if d.planned else d.color.lightened(0.4))
		draw_rect(Rect2(14, size.y - 8, size.x - 28, 3), d.color if not d.planned else Color("#3a3050"))
		if d.planned:
			var lc := Vector2(size.x - 16.0, 16.0)   # small padlock
			draw_arc(lc + Vector2(0, -4), 5.0, PI, TAU, 8, Color("#c8c8d8"), 3.0)
			draw_rect(Rect2(lc.x - 8, lc.y - 2, 16, 12), Color("#08050f"))
			draw_rect(Rect2(lc.x - 6, lc.y, 12, 8), Color("#d8a83a"))
