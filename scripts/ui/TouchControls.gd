class_name TouchControls
extends Control
## On-screen controls: floating virtual joystick (left) and Jump / Attack / Dodge / Skill 1-3 (right).
## Multi-touch aware: every finger is tracked by its touch index, so you can move and attack at once.
## Presses the same Input actions the keyboard uses (see GameState._register_input_actions).

const BUTTONS := [
	# name, action, offset from bottom-right corner, radius
	{"n": "attack", "a": "attack", "o": Vector2(-112, -112), "r": 60.0},
	{"n": "jump", "a": "jump", "o": Vector2(-258, -66), "r": 48.0},
	{"n": "dodge", "a": "dodge", "o": Vector2(-100, -244), "r": 46.0},
	{"n": "s1", "a": "skill1", "o": Vector2(-244, -176), "r": 44.0},
	{"n": "s2", "a": "skill2", "o": Vector2(-198, -278), "r": 44.0},
	{"n": "s3", "a": "skill3", "o": Vector2(-344, -130), "r": 44.0},
]
const STICK_RADIUS := 78.0
const DEADZONE := 0.22

var fighter: Fighter
var _touch_target: Dictionary = {}   # touch index -> "stick" or button name
var _pressed: Dictionary = {}        # button name -> true
var _stick_index := -1
var _stick_origin := Vector2.ZERO
var _stick_pos := Vector2.ZERO
var _stick_vec := Vector2.ZERO
var _joy_home := Vector2.ZERO
var _insets := Vector2.ZERO


func _ready() -> void:
	anchor_left = 0.0
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


func _exit_tree() -> void:
	release_all()


func release_all() -> void:
	for a in ["move_left", "move_right", "move_down", "move_up", "jump", "attack", "dodge", "skill1", "skill2", "skill3"]:
		Input.action_release(a)
	_touch_target.clear()
	_pressed.clear()
	_stick_index = -1
	_stick_vec = Vector2.ZERO


func button_center(b: Dictionary) -> Vector2:
	return size + (b["o"] as Vector2) - Vector2(_insets.y, 0.0)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or get_tree().paused:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_on_press(event.index, event.position)
		else:
			_on_release(event.index)
	elif event is InputEventScreenDrag:
		if event.index == _stick_index:
			_update_stick(event.position)
		elif _touch_target.get(event.index, "") != "" and _touch_target[event.index] != "stick":
			pass


func _on_press(index: int, pos: Vector2) -> void:
	for b in BUTTONS:
		if pos.distance_to(button_center(b)) <= float(b["r"]) + 14.0:
			_touch_target[index] = b["n"]
			_pressed[b["n"]] = true
			Input.action_press(b["a"])
			queue_redraw()
			return
	if pos.x < size.x * 0.48 and pos.y > size.y * 0.25 and _stick_index == -1:
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
		_pressed.erase(target)
		for b in BUTTONS:
			if b["n"] == target:
				Input.action_release(b["a"])
	queue_redraw()


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
	var strength := 0.0 if ax < DEADZONE else clampf((ax - DEADZONE) / (1.0 - DEADZONE) * 1.6, 0.0, 1.0)
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


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var font := PixelUI.FONT
	# joystick
	var home := Vector2(150 + _insets.x, size.y - 150)
	var base := _stick_origin if _stick_index != -1 else home
	draw_circle(base, STICK_RADIUS + 6, Color(0.03, 0.02, 0.08, 0.45))
	draw_arc(base, STICK_RADIUS, 0, TAU, 32, Color(0.75, 0.65, 1.0, 0.55 if _stick_index != -1 else 0.3), 4.0)
	var knob := _stick_pos if _stick_index != -1 else home
	draw_circle(knob, 34, Color(0.03, 0.02, 0.08, 0.7))
	draw_circle(knob, 29, Color(0.62, 0.5, 0.95, 0.65 if _stick_index != -1 else 0.35))
	# buttons
	for b in BUTTONS:
		var c := button_center(b)
		var r: float = b["r"]
		var down: bool = _pressed.has(b["n"])
		var col := _button_color(b["n"])
		var sk: SkillData = _skill_for(b["n"])
		var frac := _cooldown_fraction(b["n"])
		draw_circle(c + Vector2(0, 4), r + 4, Color(0, 0, 0, 0.45))
		draw_circle(c, r + 4, Color("#08050f", 0.85))
		draw_circle(c, r, Color(col.darkened(0.45 if down else 0.15), 0.62))
		draw_arc(c, r - 2, 0, TAU, 28, Color(col.lightened(0.3), 0.9), 3.0)
		var icon: String = {"attack": sk.icon if sk else "sword", "jump": "jump", "dodge": "dodge"}.get(b["n"], sk.icon if sk else "")
		SkillIcons.draw(self, icon, c, r, Color.WHITE if frac <= 0.0 else Color(1, 1, 1, 0.45))
		if frac > 0.0:
			# cooldown sweep
			var pts := PackedVector2Array([c])
			var start := -PI / 2.0
			var steps := 24
			for i in steps + 1:
				var a := start + TAU * frac * float(i) / steps
				pts.append(c + Vector2(cos(a), sin(a)) * (r - 2))
			if pts.size() > 2:
				draw_colored_polygon(pts, Color(0, 0, 0, 0.6))
			var secs := _cooldown_seconds(b["n"])
			if secs > 0.0:
				var txt := "%.0f" % ceilf(secs) if secs >= 1.0 else "%.1f" % secs
				draw_string(font, c + Vector2(-r, 8), txt, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, 18, Color.WHITE)


func _button_color(n: String) -> Color:
	match n:
		"attack":
			return Color("#e8584f")
		"jump":
			return Color("#4fb0e8")
		"dodge":
			return Color("#4fd36b")
		_:
			return fighter.data.color.lightened(0.15) if fighter else Color("#9a55d8")


func _skill_for(n: String) -> SkillData:
	if fighter == null:
		return null
	match n:
		"attack":
			return fighter.data.basic
		"s1":
			return fighter.data.skills[0]
		"s2":
			return fighter.data.skills[1]
		"s3":
			return fighter.data.skills[2]
	return null


func _slot_for(n: String) -> int:
	return {"attack": 0, "s1": 1, "s2": 2, "s3": 3}.get(n, -1)


func _cooldown_fraction(n: String) -> float:
	if fighter == null:
		return 0.0
	if n == "dodge":
		return clampf(fighter.dodge_cooldown_left() / maxf(fighter.data.dodge_cooldown, 0.01), 0.0, 1.0)
	var s := _slot_for(n)
	if s < 0:
		return 0.0
	var sk := fighter.skill_for_slot(s)
	return clampf(fighter.skills.cooldown_left[s] / maxf(sk.cooldown * fighter.cd_scale, 0.01), 0.0, 1.0)


func _cooldown_seconds(n: String) -> float:
	if fighter == null:
		return 0.0
	if n == "dodge":
		return fighter.dodge_cooldown_left()
	var s := _slot_for(n)
	return fighter.skills.cooldown_left[s] if s >= 0 else 0.0
