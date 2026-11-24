class_name MoveGuide
extends CanvasLayer
## Character guide / move list: lore, mechanic, passive, strengths, strategy and every ability with its input,
## effect, cooldown or resource cost and a suggested use. Opened from Character Select, the pause menu and training.

const COMBOS := {
	"vanguard": "Shield Bash (hit) > cancel into Ground Breaker or Retaliate. Take a few hits first: Retaliate scales with Bulwark.",
	"duelist": "Thrust > Quick Slash > Sidestep (cancel) > Phantom Step. At 3+ Momentum, Phantom Step refunds Quick Slash.",
	"ranger": "Hunter's Mark > stand still for the aimed arrow > Piercing Shot. Shadow Dash back and re-aim.",
	"gunslinger": "Quick Burst > Pistol x2 > Tactical Roll (reload 2) > Explosive Round. Dead Eye ignores ammo.",
	"arcanist": "Frost Orb (slow) > Attune to Fire > Fire Bolt = SHATTER. Storm hits chain and stun slowed foes.",
	"shadeweaver": "Binding Chains > Shadow Echo behind them > Void Lash. Swap back to escape. Eclipse for groups.",
}
const KEYS := {"attack": "J", "special": "U", "signature": "I", "mobility": "L", "ultimate": "O"}

var class_id := "vanguard"


static func open(parent: Node, id: String) -> MoveGuide:
	var g := MoveGuide.new()
	g.class_id = id
	parent.add_child(g)
	return g


func _ready() -> void:
	layer = 60
	process_mode = Node.PROCESS_MODE_ALWAYS
	var d := Library.get_class_data(class_id)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.01, 0.06, 0.88)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		m.add_theme_constant_override("margin_" + side, 40)
	m.add_theme_constant_override("margin_top", 20)
	m.add_theme_constant_override("margin_bottom", 20)
	add_child(m)
	var panel := PixelUI.panel(PixelUI.C_PANEL, d.color.lightened(0.2))
	m.add_child(panel)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	panel.add_child(root)
	# header
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 16)
	root.add_child(head)
	var pb := PortraitBox.new()
	pb.class_id = class_id
	pb.custom_minimum_size = Vector2(70, 70)
	head.add_child(pb)
	var hv := VBoxContainer.new()
	hv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hv.add_theme_constant_override("separation", 4)
	head.add_child(hv)
	hv.add_child(PixelUI.label("%s  -  %s" % [d.display_name.to_upper(), d.title], 22, d.color.lightened(0.35)))
	hv.add_child(PixelUI.label("%s    DIFFICULTY %s" % [d.role.to_upper(), "*".repeat(d.difficulty) + "-".repeat(5 - d.difficulty)], 14, PixelUI.C_GOLD))
	var close := PixelUI.button("CLOSE", Color("#8a3a3a"), 16, Vector2(150, 54))
	close.pressed.connect(queue_free)
	head.add_child(close)
	# scrolling body
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 22)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(body)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(410, 0)
	left.add_theme_constant_override("separation", 8)
	body.add_child(left)
	_block(left, "LORE", d.lore, PixelUI.C_DIM)
	_block(left, "SIGNATURE MECHANIC: " + d.mech_name, d.mech_desc, PixelUI.C_TEXT)
	_block(left, "PASSIVE: " + d.passive_name.to_upper(), d.passive_desc, PixelUI.C_TEXT)
	_block(left, "STRENGTHS", d.strengths, Color("#7fe8a0"))
	_block(left, "WEAKNESSES", d.weaknesses, Color("#ff9a8a"))
	_block(left, "STRATEGY", d.strategy, PixelUI.C_TEXT)
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(640, 0)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 8)
	body.add_child(right)
	right.add_child(PixelUI.label("MOVE LIST", 16, PixelUI.C_GOLD))
	var rows := [["attack", d.basic], ["special", d.skills[0]], ["signature", d.skills[1]], ["mobility", d.mobility], ["ultimate", d.skills[2]]]
	for r in rows:
		right.add_child(_move_row(r[0], r[1]))
	_block(right, "COMBOS", String(COMBOS.get(class_id, "")), PixelUI.C_TEXT)
	_block(right, "EVERYONE", "Mobility just before a hit = DODGE! and your next hit is a COUNTER (+25%). Ultimates charge as you deal and take damage. Keyboard: A/D move, SPACE jump, J attack, U special, I signature, L mobility, O ultimate.", PixelUI.C_DIM)


func _block(parent: Control, title: String, text: String, color: Color) -> void:
	parent.add_child(PixelUI.label(title, 14, PixelUI.C_GOLD))
	var l := PixelUI.wrap_label(text, 14, color)
	l.custom_minimum_size = Vector2(parent.custom_minimum_size.x - 8.0 if parent.custom_minimum_size.x > 0 else 600.0, 0)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(l)


func _move_row(input: String, sk: SkillData) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var icon := ClassPicker.SkillIconBox.new()
	icon.icon = sk.icon
	icon.color = sk.color
	icon.custom_minimum_size = Vector2(48, 48)
	icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_child(icon)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 2)
	row.add_child(col)
	var cost := ""
	if sk.is_ultimate:
		cost = "full ULT meter"
	elif sk.cost_text != "":
		cost = sk.cost_text + ", cd %.1fs" % sk.cooldown if sk.cooldown >= 1.0 else sk.cost_text
	elif sk.cooldown >= 1.0:
		cost = "cd %.1fs" % sk.cooldown
	else:
		cost = "repeatable"
	col.add_child(PixelUI.label("%s  [%s / key %s]  %s" % [sk.display_name, String(ControlLayout.LABELS[input]), KEYS[input], cost], 14, PixelUI.C_TEXT))
	var eff := PixelUI.wrap_label(sk.description, 14, PixelUI.C_DIM)
	eff.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	eff.custom_minimum_size = Vector2(560, 0)
	col.add_child(eff)
	if sk.tip != "":
		var tip := PixelUI.wrap_label("Use: " + sk.tip, 14, Color("#ffd24a"))
		tip.custom_minimum_size = Vector2(560, 0)
		col.add_child(tip)
	return row


class PortraitBox extends Control:
	var class_id := "vanguard"

	func _draw() -> void:
		Portrait.draw(self, Library.get_class_data(class_id), Rect2(8, 8, 52, 52))
