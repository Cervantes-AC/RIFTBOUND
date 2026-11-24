class_name CharacterVisual
extends Node2D
## PLACEHOLDER ART: procedurally drawn, chunky 16-bit-style fighters (one consistent palette/scale).
## Replace with sprite sheets later (see docs/CREDITS.md). Pose is a function of Fighter state, so all
## six classes share one animation system: idle, run, jump/fall, attack styles, hurt, dodge roll, death.

const OUT := Color("#120a1c")
const SKIN := Color("#f0c8a0")
const PX := 4.0

var fighter: Fighter
var _afterimage_t := 0.0


func _process(delta: float) -> void:
	if fighter == null:
		return
	scale.x = float(fighter.facing)
	var f := fighter
	var m := Color.WHITE
	if f.flash_t > 0.0:
		m = Color(2.2, 2.2, 2.2)
	elif f.has_status("slow"):
		m = Color(0.7, 0.9, 1.3)
	if f.has_status("invuln"):
		m.a = 0.55 + 0.25 * sin(f.anim_time * 40.0)
	modulate = m
	z_index = 3 if not f.is_dead() else 1
	_ghosts(delta)
	queue_redraw()


## Afterimages while dodging or dashing (spawned locally on every peer; nothing is networked).
func _ghosts(delta: float) -> void:
	var f := fighter
	var dashing := f.state == Fighter.State.DODGE or (f.state == Fighter.State.ACTION and f.act_style == "dash")
	if not dashing or f.world == null or f.is_dead():
		_afterimage_t = 0.0
		return
	_afterimage_t -= delta
	if _afterimage_t <= 0.0:
		_afterimage_t = 0.045
		Fx.spawn(f.world.entities, "ghost", f.global_position, {"color": f.data.color, "dir": float(f.facing)})


func _limb(from: Vector2, angle: float, length: float, width: float, color: Color) -> Vector2:
	var to := from + Vector2(sin(angle), cos(angle)) * length
	draw_line(from, to, OUT, width + 6.0)
	draw_line(from, to, color, width)
	return to


func _box(r: Rect2, color: Color, outline := true) -> void:
	if outline:
		draw_rect(r.grow(3.0), OUT)
	draw_rect(r, color)


func _draw() -> void:
	var f := fighter
	if f == null or f.data == null:
		return
	var d := f.data
	var s := d.body_scale
	var t := f.anim_time
	var state := f.state
	# --- shadow (not rotated)
	if state != Fighter.State.DEAD:
		draw_set_transform(Vector2(0, -2), 0.0, Vector2(1.0, 0.22))
		var ring := Color(0, 0, 0, 0.4)
		if f.world != null:
			ring = Color(0.2, 0.9, 0.4, 0.55) if f.team == f.world.local_team() else Color(1.0, 0.25, 0.25, 0.55)
		draw_circle(Vector2.ZERO, 28.0 * s, ring)
		draw_circle(Vector2.ZERO, 24.0 * s, Color(0, 0, 0, 0.45))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# --- pose parameters
	var bob := 0.0
	var rot := 0.0
	var pivot := Vector2(0, -14)
	var hip_lift := 0.0
	var leg_f := 0.15
	var leg_b := -0.15
	var arm_f := 0.35
	var arm_b := -0.1
	var arm_len := 22.0
	var squash := 1.0
	var weapon_swing := 0.0
	var guard := f.has_status("shield")
	var casting := false
	match state:
		Fighter.State.IDLE:
			bob = sin(t * 3.0) * 1.5
			arm_f = 0.35 + sin(t * 3.0) * 0.05
			match d.id:   # per-class idle personality
				"vanguard":     # planted, slow heavy breathing, shield-arm guard
					bob = sin(t * 1.8) * 1.2
					arm_b = 0.5
				"duelist":      # bouncing on the toes, rapier flicks
					bob = absf(sin(t * 6.0)) * -2.5
					arm_f = 0.9 + sin(t * 6.0) * 0.18
					leg_f = 0.25
					leg_b = -0.25
				"ranger":       # relaxed sway, bow hand low
					rot = sin(t * 1.4) * 0.04
					arm_f = 0.2
				"gunslinger":   # cocky: gun hand twitch
					arm_f = 0.7 + maxf(0.0, sin(t * 2.2)) * 0.5
					arm_b = -0.2
				"arcanist":     # hovers slightly
					hip_lift = 4.0 + sin(t * 2.4) * 3.0
					arm_f = 1.0 + sin(t * 2.4) * 0.15
				"shadeweaver":  # drifts, cloak trembles
					hip_lift = 2.0 + sin(t * 1.6) * 2.0
					rot = sin(t * 1.1) * 0.05
					arm_f = 0.45
			if f.world != null and f.world.winner_team == f.team and not f.is_dead():   # victory pose
				arm_f = 3.0 + sin(t * 9.0) * 0.25
				arm_b = 2.8 - sin(t * 9.0) * 0.25
				bob = absf(sin(t * 5.0)) * -6.0
		Fighter.State.RUN:
			var ph := t * 15.0
			bob = absf(sin(ph)) * -3.0
			leg_f = sin(ph) * 0.9
			leg_b = -sin(ph) * 0.9
			arm_f = -sin(ph) * 0.7
			arm_b = sin(ph) * 0.7
			rot = 0.08
		Fighter.State.AIR:
			if f.velocity.y < 0.0:
				leg_f = 0.7
				leg_b = -0.2
				arm_f = 2.3
				arm_b = 1.6
				squash = 1.06
			else:
				leg_f = 0.35
				leg_b = -0.45
				arm_f = 1.2
				arm_b = 0.9
		Fighter.State.DODGE:
			rot = clampf(t / 0.2, 0.0, 1.0) * TAU
			squash = 0.8
			leg_f = 1.2
			leg_b = 1.0
			arm_f = 2.6
			arm_b = 2.6
		Fighter.State.HURT:
			rot = -0.35
			arm_f = 2.2
			arm_b = 2.0
			leg_f = 0.5
			leg_b = -0.3
			bob = sin(t * 60.0) * 1.5
		Fighter.State.DEAD:
			var k := clampf(t / 0.45, 0.0, 1.0)
			rot = -1.45 * (k * k)
			hip_lift = 10.0 * k
			arm_f = 2.5
			arm_b = 2.2
			leg_f = 0.2
			leg_b = -0.2
		Fighter.State.ACTION:
			casting = true
			var p := f.act_progress
			match f.act_style:
				"slash":
					if p < 0.3:
						arm_f = lerpf(0.4, 3.0, p / 0.3)
					elif p < 0.55:
						arm_f = lerpf(3.0, 1.35, (p - 0.3) / 0.25)
					else:
						arm_f = lerpf(1.35, 0.5, clampf((p - 0.55) / 0.45, 0.0, 1.0))
					rot = 0.0 if p < 0.3 else 0.18
					arm_b = -0.4
				"slam":
					if p < 0.45:
						arm_f = lerpf(0.5, 3.1, p / 0.45)
						arm_b = arm_f
						squash = 1.0 + 0.05 * p
					else:
						arm_f = lerpf(3.1, 0.2, clampf((p - 0.45) / 0.15, 0.0, 1.0))
						arm_b = arm_f
						squash = 0.85
				"shoot":
					arm_f = 1.55
					arm_b = 1.4 + (0.3 if p < 0.4 else 0.0)
					rot = -0.05 * (1.0 - p)
					weapon_swing = -0.3 * maxf(0.0, (p - 0.3)) if p < 0.5 else 0.0
				"cast":
					arm_f = lerpf(2.6, 1.5, clampf(p * 1.6, 0.0, 1.0))
					arm_b = 2.3
				"cast_up":
					arm_f = 3.0
					arm_b = 2.8
					hip_lift = -sin(p * PI) * 3.0
				"spin":
					rot = p * TAU * 3.0
					arm_f = 1.57
					arm_b = -1.57
					squash = 0.95
				"guard":
					arm_f = 1.45
					arm_b = 0.6
				"dash":
					rot = 0.42
					arm_f = 2.1
					arm_b = -2.0
					leg_f = 1.0
					leg_b = -1.0
				_:
					arm_f = 1.2
	var feet_y := 0.0
	var hip_world := Vector2(0, -24.0 * s - hip_lift * s + bob * s)
	var xf := Transform2D(0.0, hip_world) * Transform2D(0.0, Vector2(s, s * squash), 0.0, Vector2.ZERO) \
		* Transform2D(0.0, pivot) * Transform2D(rot, Vector2.ZERO) * Transform2D(0.0, -pivot)
	_xf = xf
	draw_set_transform_matrix(xf)

	# --- body parts (local space: hip at origin, feet at +24, head top at -56)
	var cloth := d.color
	var trim := d.accent
	var dark := cloth.darkened(0.35)
	# back arm + back weapon part
	var back_shoulder := Vector2(-3, -24)
	var back_hand := _limb(back_shoulder, arm_b, arm_len, 7.0, dark)
	if d.weapon == "sword_shield" and not guard:
		pass
	# legs
	_limb(Vector2(-3, 0), leg_b, 24.0, 8.0, dark)
	_limb(Vector2(4, 0), leg_f, 24.0, 8.0, cloth.darkened(0.15))
	# torso
	_box(Rect2(-9, -30, 18, 32), cloth)
	draw_rect(Rect2(-9, -4, 18, 4), trim)           # belt
	draw_rect(Rect2(-9, -30, 18, 4), cloth.lightened(0.15))
	draw_rect(Rect2(3, -26, 4, 16), cloth.lightened(0.12))
	_class_torso_detail(d, cloth, trim)
	# head
	_box(Rect2(-9, -58, 18, 26), SKIN)
	draw_rect(Rect2(3, -49, 3, 5), Color.WHITE)     # eye
	draw_rect(Rect2(5, -48, 2, 3), OUT)
	var eye_glow := d.id == "shadeweaver"
	if eye_glow:
		draw_rect(Rect2(3, -49, 4, 5), d.accent)
	_headgear(d)
	# front arm with weapon
	var front_shoulder := Vector2(4, -24)
	var front_hand := _limb(front_shoulder, arm_f, arm_len, 8.0, cloth.lightened(0.1))
	draw_rect(Rect2(front_hand.x - 4, front_hand.y - 4, 8, 8), SKIN)
	var aim := atan2(cos(arm_f), sin(arm_f)) + weapon_swing
	_weapon(d, front_hand, aim, f, back_hand)
	draw_set_transform_matrix(Transform2D.IDENTITY)

	# --- overlays (screen-aligned in fighter space)
	var cy := -40.0 * s
	if f.has_status("shield"):
		var a := 0.25 + 0.1 * sin(t * 8.0)
		draw_circle(Vector2(0, cy), 52.0 * s, Color(0.5, 0.75, 1.0, a))
		draw_arc(Vector2(0, cy), 52.0 * s, 0.0, TAU, 28, Color(0.8, 0.95, 1.0, 0.9), 3.0)
	if f.has_status("root"):
		for i in 3:   # binding chains: dark links with a violet glint, tightening
			var rr := 24.0 - 2.0 * sin(t * 6.0 + i)
			draw_arc(Vector2(0, -8.0 - i * 14.0), rr, 0.0, TAU, 12, OUT, 8.0)
			draw_arc(Vector2(0, -8.0 - i * 14.0), rr, 0.0, TAU, 12, Color(0.62, 0.62, 0.8), 4.0)
			draw_arc(Vector2(0, -8.0 - i * 14.0), rr, t * 3.0 + i, t * 3.0 + i + 1.0, 6, Color(0.8, 0.5, 1.0), 3.0)
	if f.has_status("empower"):
		draw_circle(Vector2(0, cy), 46.0 * s, Color(0.7, 0.4, 1.0, 0.18 + 0.1 * sin(t * 12.0)))
	if f.enraged and state != Fighter.State.DEAD:
		draw_arc(Vector2(0, cy), 48.0 * s, 0.0, TAU, 24, Color(1.0, 0.3, 0.2, 0.5 + 0.3 * sin(t * 9.0)), 3.0)
	if f.has_status("haste"):
		for i in 3:
			draw_rect(Rect2(-40 - i * 14, cy - 10 + i * 8, 16, 3), Color(1, 1, 1, 0.35))
	if casting and f.act_style == "cast_up":
		draw_arc(Vector2(0, -2), 26.0, 0.0, TAU, 16, Color(f.action_skill.color if f.action_skill else Color.WHITE, 0.7), 3.0)
	# --- mini health bar + marker above head
	if state != Fighter.State.DEAD and f.world != null and f.world.show_overhead_bars:
		var top := -88.0 * s
		var w := 56.0
		draw_rect(Rect2(-w * 0.5 - 2, top - 2, w + 4, 10), OUT)
		var ratio := f.health.ratio()
		var local: bool = f.slot == f.world.local_slot
		var bar_col := Color("#4fd36b") if f.team == f.world.local_team() else Color("#e8484f")
		draw_rect(Rect2(-w * 0.5, top, w * ratio, 6), bar_col)
		if local:
			var ty := top - 18.0 + sin(t * 5.0) * 3.0
			draw_colored_polygon(PackedVector2Array([Vector2(-8, ty), Vector2(8, ty), Vector2(0, ty + 10)]), Color("#ffd24a"))


func _class_torso_detail(d: ClassData, cloth: Color, trim: Color) -> void:
	match d.id:
		"vanguard":
			draw_rect(Rect2(-9, -30, 18, 8), trim)       # pauldron / gorget
			draw_rect(Rect2(-2, -20, 4, 14), trim.darkened(0.2))
		"duelist":
			draw_rect(Rect2(-9, -22, 18, 3), trim)       # sash
			draw_rect(Rect2(-9, -30, 6, 6), trim)
		"ranger":
			draw_rect(Rect2(-9, -30, 18, 5), cloth.darkened(0.25))
			draw_rect(Rect2(-12, -26, 4, 18), Color("#6b4a2e"))   # quiver
			draw_rect(Rect2(-12, -30, 2, 5), trim)
		"gunslinger":
			draw_rect(Rect2(-9, -26, 18, 3), trim)       # bandolier
			draw_rect(Rect2(-9, -16, 18, 3), trim)
			draw_rect(Rect2(-10, -12, 5, 8), Color("#3a2a1a"))
		"arcanist":
			draw_rect(Rect2(-9, -2, 18, 6), cloth)       # robe hem
			draw_rect(Rect2(-9, 0, 18, 4), trim)
			draw_rect(Rect2(-2, -28, 4, 28), trim.darkened(0.3))
		"shadeweaver":
			draw_rect(Rect2(-11, -28, 5, 30), cloth.darkened(0.3))  # tattered cloak
			draw_rect(Rect2(-9, -14, 18, 3), trim)


func _headgear(d: ClassData) -> void:
	var hair := d.hair
	match d.id:
		"vanguard":
			_box(Rect2(-11, -64, 22, 18), d.accent)       # helm
			draw_rect(Rect2(-11, -50, 22, 4), d.accent.darkened(0.3))
			draw_rect(Rect2(1, -53, 10, 4), OUT)           # visor slit
			draw_rect(Rect2(-3, -72, 6, 10), d.color)     # crest
		"duelist":
			_box(Rect2(-10, -62, 20, 10), hair)
			draw_rect(Rect2(-12, -56, 6, 14), hair)
			draw_rect(Rect2(-14, -70, 4, 14), d.accent)   # feather
			draw_rect(Rect2(-4, -66, 14, 4), d.color)
		"ranger":
			_box(Rect2(-11, -64, 22, 22), d.color.darkened(0.1))   # hood
			draw_rect(Rect2(0, -50, 11, 12), SKIN)
			draw_rect(Rect2(3, -49, 3, 5), Color.WHITE)
			draw_rect(Rect2(5, -48, 2, 3), OUT)
		"gunslinger":
			_box(Rect2(-9, -62, 18, 8), hair)
			_box(Rect2(-16, -62, 32, 5), d.accent)        # wide brim
			_box(Rect2(-8, -72, 16, 12), d.accent)        # crown
			draw_rect(Rect2(-8, -64, 16, 3), d.color)
		"arcanist":
			_box(Rect2(-12, -62, 24, 6), d.color.darkened(0.15))   # brim
			_box(Rect2(-8, -76, 16, 16), d.color)
			_box(Rect2(-4, -88, 8, 14), d.color.lightened(0.1))
			draw_rect(Rect2(-8, -66, 16, 3), d.accent)
			draw_rect(Rect2(-10, -50, 5, 12), hair)       # long hair
		"shadeweaver":
			_box(Rect2(-12, -64, 24, 26), d.color.darkened(0.2))   # deep hood
			draw_rect(Rect2(0, -52, 12, 14), Color("#0a0610"))
			draw_rect(Rect2(3, -49, 4, 4), d.accent)
			draw_rect(Rect2(-14, -62, 4, 20), d.color.darkened(0.4))


func _weapon(d: ClassData, hand: Vector2, ang: float, f: Fighter, _back_hand: Vector2) -> void:
	var p := f.act_progress if f.state == Fighter.State.ACTION else 0.0
	var acting_shoot := f.state == Fighter.State.ACTION and f.act_style == "shoot"
	# shield for the Vanguard sits on the body, not the weapon arm
	if d.weapon == "sword_shield":
		draw_set_transform_matrix(_xf)
		var sx := 17.0 if f.has_status("shield") or f.act_style == "guard" else 8.0
		_box(Rect2(sx, -28, 12, 32), d.accent)
		draw_rect(Rect2(sx + 2, -26, 8, 28), d.color)
		draw_rect(Rect2(sx + 4, -20, 4, 16), d.accent)
	draw_set_transform_matrix(_xf * Transform2D(ang, hand))
	var c := d.accent
	match d.weapon:
		"sword_shield":
			_box(Rect2(2, -3, 44, 6), Color("#dfe6f2"))
			_box(Rect2(-2, -9, 7, 18), Color("#d8a83a"))
		"rapier":
			_box(Rect2(2, -2, 54, 4), Color("#f4f4ff"))
			_box(Rect2(0, -9, 7, 18), Color("#d8a83a"))
		"bow":
			var pull := 8.0 if acting_shoot and p < 0.45 else 0.0
			for i in range(-4, 4):
				var y0 := i * 7.0
				var y1 := (i + 1) * 7.0
				draw_line(Vector2(14.0 - y0 * y0 / 55.0, y0), Vector2(14.0 - y1 * y1 / 55.0, y1), OUT, 6.0)
				draw_line(Vector2(14.0 - y0 * y0 / 55.0, y0), Vector2(14.0 - y1 * y1 / 55.0, y1), Color("#8a5a2a"), 3.0)
			draw_line(Vector2(14.0 - 16.0 * 16.0 / 55.0 - 1, -28), Vector2(14.0 - pull, 0), Color("#f0f0e0"), 2.0)
			draw_line(Vector2(14.0 - 16.0 * 16.0 / 55.0 - 1, 28), Vector2(14.0 - pull, 0), Color("#f0f0e0"), 2.0)
			if acting_shoot and p < 0.45:
				draw_rect(Rect2(10 - pull, -2, 32, 4), c)
		"pistol":
			_box(Rect2(0, -5, 22, 10), Color("#4a4a58"))
			_box(Rect2(20, -4, 14, 8), Color("#8a8a98"))
			draw_rect(Rect2(2, 3, 7, 10), Color("#6b4a2e"))
			if acting_shoot and p > 0.3 and p < 0.55:
				draw_rect(Rect2(34, -8, 16, 16), Color("#ffd66b"))
				draw_rect(Rect2(38, -4, 14, 8), Color.WHITE)
		"staff":
			_box(Rect2(-14, -3, 72, 6), Color("#7a5230"))
			var glow := 9.0 + 2.0 * sin(f.anim_time * 8.0) + (6.0 if f.state == Fighter.State.ACTION else 0.0)
			draw_circle(Vector2(64, 0), glow + 5.0, Color(c, 0.3))
			draw_circle(Vector2(64, 0), glow, c)
			draw_circle(Vector2(64, 0), 4.0, Color.WHITE)
		"scythe":
			_box(Rect2(-14, -3, 70, 6), Color("#2a2036"))
			draw_colored_polygon(PackedVector2Array([Vector2(50, -4), Vector2(56, -30), Vector2(80, -36), Vector2(66, -16), Vector2(58, 2)]), OUT)
			draw_colored_polygon(PackedVector2Array([Vector2(54, -6), Vector2(59, -26), Vector2(74, -31), Vector2(64, -15), Vector2(58, -2)]), c)
	draw_set_transform_matrix(_xf)


var _xf := Transform2D.IDENTITY
