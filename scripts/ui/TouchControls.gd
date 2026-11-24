class_name TouchControls
extends Control
## On-screen controls for Android landscape: floating joystick (left half), Jump (bottom-left) and a fan of
## Attack / Special / Signature / Mobility / Ultimate buttons (bottom-right). Layout, size, opacity and joystick
## sensitivity come from SaveManager (see ControlLayout); `edit_mode` turns the same control into the layout editor.
## Multi-touch aware: every finger is tracked by its touch index. Buttons press the same Input actions the keyboard
## uses (see GameState._register_input_actions), so touch and keyboard behave identically.

signal layout_edited

const STICK_RADIUS := 78.0
const DEADZONE := 0.22
const DEBOUNCE_MS := 70   # ignore a second press of the same button this soon after the first (touch bounce)
const ACTIONS_ALL := ["move_left", "move_right", "move_down", "move_up", "jump", "attack", "dodge", "skill1", "skill2", "skill3"]

var fighter: Fighter
var preview_class: ClassData          # used by the editor (no fighter)
var edit_mode := false
var _specs: Dictionary = {}
var _touch_target: Dictionary = {}    # touch index -> "stick" or button name
var _pressed: Dictionary = {}         # button name -> true
var _last_press: Dictionary = {}      # button name -> tick ms
var _stick_index := -1
var _stick_origin := Vector2.ZERO
var _stick_pos := Vector2.ZERO
var _stick_vec := Vector2.ZERO
var _insets := Vector2.ZERO
var _t := 0.0


func _ready() -> void:
	anchor_left = 0.0   # explicit anchors/offsets: set_anchors_preset under a CanvasLayer leaves size 0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_insets = PixelUI.safe_insets(get_viewport())
	reload_layout()
	if not SaveManager.settings_changed.is_connected(reload_layout):
		SaveManager.settings_changed.connect(reload_layout)


func _exit_tree() -> void:
	if SaveManager.settings_changed.is_connected(reload_layout):
		SaveManager.settings_changed.disconnect(reload_layout)
	release_all()


func reload_layout() -> void:
	_specs = ControlLayout.resolve(SaveManager.ctl_preset, SaveManager.ctl_custom, SaveManager.ctl_scale)
	queue_redraw()


func release_all() -> void:
	for a in ACTIONS_ALL:
		Input.action_release(a)
	_touch_target.clear()
	_pressed.clear()
	_stick_index = -1
	_stick_vec = Vector2.ZERO


func button_center(n: String) -> Vector2:
	return ControlLayout.center(_specs[n], size, _insets)


func button_radius(n: String) -> float:
	return float(_specs[n]["r"])


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or (get_tree().paused and not edit_mode):
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_on_press(event.index, event.position)
		else:
			_on_release(event.index)
	elif event is InputEventScreenDrag:
		if edit_mode:
			_drag_button(event.index, event.position)
		elif event.index == _stick_index:
			_update_stick(event.position)


func _hit_button(pos: Vector2) -> String:
	var best := ""
	var best_d := 1e9
	for n in ControlLayout.NAMES:
		var d := pos.distance_to(button_center(n))
		if d <= button_radius(n) + 14.0 and d < best_d:   # nearest centre wins when hit areas overlap
			best = n
			best_d = d
	return best


func _on_press(index: int, pos: Vector2) -> void:
	var n := _hit_button(pos)
	if n != "":
		_touch_target[index] = n
		if edit_mode:
			queue_redraw()
			return
		var now := Time.get_ticks_msec()
		if now - int(_last_press.get(n, -1000)) < DEBOUNCE_MS:
			return
		_last_press[n] = now
		_pressed[n] = true
		Input.action_press(ControlLayout.ACTIONS[n])
		queue_redraw()
		return
	if edit_mode:
		return
	if pos.x < size.x * 0.5 and pos.y > size.y * 0.2 and _stick_index == -1:
		_stick_index = index
		_touch_target[index] = "stick"
		_stick_origin = pos
		_stick_pos = pos
		_stick_vec = Vector2.ZERO
		queue_redraw()


func _on_release(index: int) -> void:
	var target: String = _touch_target.get(index, "")
	_touch_target.erase(index)
	if target == "stick":
		_stick_index = -1
		_stick_vec = Vector2.ZERO
		_apply_stick()
	elif target != "":
		if _pressed.has(target):
			_pressed.erase(target)
			Input.action_release(ControlLayout.ACTIONS[target])
		if edit_mode:
			layout_edited.emit()
	queue_redraw()


## Editor: drag the touched button; the first drag converts the active preset into "custom".
func _drag_button(index: int, pos: Vector2) -> void:
	var n: String = _touch_target.get(index, "")
	if n == "" or n == "stick":
		return
	if SaveManager.ctl_preset != "custom":
		var cur := {}
		for k in ControlLayout.NAMES:
			cur[k] = ControlLayout.offset_for(_specs[k]["anchor"], ControlLayout.center(_specs[k], size, _insets), size, _insets, SaveManager.ctl_scale)
		SaveManager.ctl_custom = cur
		SaveManager.ctl_preset = "custom"
	var anchor: String = _specs[n]["anchor"]
	var clamped := Vector2(clampf(pos.x, 40.0, size.x - 40.0), clampf(pos.y, 80.0, size.y - 40.0))
	SaveManager.ctl_custom[n] = ControlLayout.offset_for(anchor, clamped, size, _insets, SaveManager.ctl_scale)
	reload_layout()


func _update_stick(pos: Vector2) -> void:
	var d := pos - _stick_origin
	if d.length() > STICK_RADIUS:
		d = d.normalized() * STICK_RADIUS
	_stick_pos = _stick_origin + d
	_stick_vec = d / STICK_RADIUS
	_apply_stick()
	queue_redraw()


func _apply_stick() -> void:
	var x := _stick_vec.x
	var ax := absf(x)
	var strength := 0.0 if ax < DEADZONE else clampf((ax - DEADZONE) / (1.0 - DEADZONE) * 1.6 * SaveManager.ctl_sens, 0.0, 1.0)
	if x < 0.0:
		Input.action_press("move_left", strength) if strength > 0.0 else Input.action_release("move_left")
		Input.action_release("move_right")
	else:
		Input.action_press("move_right", strength) if strength > 0.0 else Input.action_release("move_right")
		Input.action_release("move_left")
	if _stick_vec.y > 0.6:
		Input.action_press("move_down")
	else:
		Input.action_release("move_down")


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


# ------------------------------------------------------------------ drawing
func _skill_for(n: String) -> SkillData:
	var d: ClassData = fighter.data if fighter != null else preview_class
	if d == null:
		return null
	match n:
		"attack":
			return d.basic
		"special":
			return d.skills[0]
		"signature":
			return d.skills[1]
		"ultimate":
			return d.skills[2]
		"mobility":
			return d.mobility
	return null


func _slot_for(n: String) -> int:
	return {"attack": 0, "special": 1, "signature": 2, "ultimate": 3, "mobility": 4}.get(n, -1)


func _button_color(n: String) -> Color:
	match n:
		"attack":
			return Color("#e8584f")
		"jump":
			return Color("#4fb0e8")
		"mobility":
			return Color("#4fd36b")
		"ultimate":
			return Color("#ffc83a")
		_:
			var d: ClassData = fighter.data if fighter != null else preview_class
			return d.color.lightened(0.15) if d != null else Color("#9a55d8")


func _draw() -> void:
	if _specs.is_empty():
		return
	var font := PixelUI.FONT
	var op := SaveManager.ctl_opacity
	# joystick (hint at home position until a finger is down)
	var home := Vector2(150 + _insets.x, size.y - 150)
	var base := _stick_origin if _stick_index != -1 else home
	draw_circle(base, STICK_RADIUS + 6, Color(0.03, 0.02, 0.08, 0.45 * op))
	draw_arc(base, STICK_RADIUS, 0, TAU, 32, Color(0.75, 0.65, 1.0, (0.55 if _stick_index != -1 else 0.3) * op), 4.0)
	var knob := _stick_pos if _stick_index != -1 else home
	draw_circle(knob, 34, Color(0.03, 0.02, 0.08, 0.7 * op))
	draw_circle(knob, 29, Color(0.62, 0.5, 0.95, (0.65 if _stick_index != -1 else 0.35) * op))
	for n in ControlLayout.NAMES:
		_draw_button(n, font, op)


func _draw_button(n: String, font: Font, op: float) -> void:
	var c := button_center(n)
	var r := button_radius(n)
	var down: bool = _pressed.has(n) or (edit_mode and _touch_target.values().has(n))
	var col := _button_color(n)
	var sk := _skill_for(n)
	var slot := _slot_for(n)
	var frac := 0.0
	var secs := 0.0
	var usable := true
	if fighter != null and slot >= 0:
		if slot == 3:
			usable = fighter.can_use_slot(3)
		else:
			var cd_total := maxf(fighter.skill_for_slot(slot).cooldown * fighter.cd_scale, 0.01)
			secs = fighter.skills.cooldown_left[slot]
			frac = clampf(secs / cd_total, 0.0, 1.0)
			usable = fighter.can_use_slot(slot)
	var rr := r * (0.92 if down else 1.0)
	draw_circle(c + Vector2(0, 4), rr + 4, Color(0, 0, 0, 0.45 * op))
	draw_circle(c, rr + 4, Color("#08050f", 0.85 * op))
	draw_circle(c, rr, Color(col.darkened(0.45 if down else 0.15), 0.62 * op))
	draw_arc(c, rr - 2, 0, TAU, 28, Color(col.lightened(0.3), 0.9 * op), 3.0)
	var icon := "jump" if n == "jump" else (sk.icon if sk != null else "")
	var icon_col := Color(1, 1, 1, op) if (frac <= 0.0 and usable) else Color(1, 1, 1, 0.4 * op)
	SkillIcons.draw(self, icon, c, rr, icon_col)
	if edit_mode:
		draw_string(font, c + Vector2(-80, r + 18), String(ControlLayout.LABELS[n]), HORIZONTAL_ALIGNMENT_CENTER, 160.0, 12, Color(1, 1, 1, 0.9))
		return
	if n == "ultimate" and fighter != null:
		# meter ring: fills as the ultimate charges, pulses gold when ready
		var f := clampf(fighter.ult / Fighter.ULT_MAX, 0.0, 1.0)
		draw_arc(c, rr + 7, -PI / 2.0, -PI / 2.0 + TAU * f, 36, Color("#ffd24a") if f >= 1.0 else Color("#b08a3a"), 5.0)
		if f >= 1.0:
			draw_arc(c, rr + 11 + 3.0 * sin(_t * 8.0), 0, TAU, 28, Color(1.0, 0.85, 0.3, 0.5 * op), 3.0)
		elif f < 1.0:
			draw_string(font, c + Vector2(-r, 6), "%d%%" % int(f * 100.0), HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, 14, Color(1, 1, 1, 0.85 * op))
	if frac > 0.0:
		var pts := PackedVector2Array([c])
		var start := -PI / 2.0
		var steps := 24
		for i in steps + 1:
			var a := start + TAU * frac * float(i) / steps
			pts.append(c + Vector2(cos(a), sin(a)) * (rr - 2))
		if pts.size() > 2:
			draw_colored_polygon(pts, Color(0, 0, 0, 0.6 * op))
		if secs > 0.0:
			var txt := "%.0f" % ceilf(secs) if secs >= 1.0 else "%.1f" % secs
			draw_string(font, c + Vector2(-r, 8), txt, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, 18, Color(1, 1, 1, op))
	elif not usable and n != "ultimate" and n != "jump":
		draw_arc(c, rr - 6, 0, TAU, 24, Color(1.0, 0.3, 0.3, 0.7 * op), 3.0)   # off cooldown but missing resource
