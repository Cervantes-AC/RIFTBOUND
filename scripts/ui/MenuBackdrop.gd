class_name MenuBackdrop
extends Control
## Animated dark-fantasy backdrop shared by all menu screens (procedural pixel art, no image assets).
## `portal` places the Rift (fraction of screen); `intensity` 1.0 = hero look (title/main menu),
## lower = calmer version behind busy screens.

var portal := Vector2(0.5, 0.42)
var portal_radius := 190.0
var intensity := 0.55
var _t := 0.0
var _stars: Array[Vector3] = []
var _motes: Array[Vector3] = []


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rng := RandomNumberGenerator.new()
	rng.seed = 1337
	for i in 90:
		_stars.append(Vector3(rng.randf(), rng.randf() * 0.75, rng.randf() * 6.28))
	for i in 40:
		_motes.append(Vector3(rng.randf(), rng.randf(), rng.randf()))


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _snap(v: float) -> float:
	return floorf(v / 4.0) * 4.0


func _draw() -> void:
	var sz := size
	var bands := 20
	for i in bands:
		var f := float(i) / bands
		var c := Color("#0b0820").lerp(Color("#3a1a5e"), f * f)
		draw_rect(Rect2(0, sz.y * f, sz.x, sz.y / bands + 1), c)
	for s in _stars:
		var tw := 0.5 + 0.5 * sin(_t * 2.0 + s.z)
		draw_rect(Rect2(_snap(s.x * sz.x), _snap(s.y * sz.y), 4, 4), Color(1, 1, 1, 0.25 + 0.6 * tw))
	_draw_portal(sz)
	# distant mountain silhouettes
	for layer in 2:
		var base := sz.y * (0.80 + layer * 0.08)
		var col2 := Color("#120a22") if layer == 0 else Color("#07040f")
		var pts2 := PackedVector2Array([Vector2(0, sz.y)])
		var x := 0.0
		while x <= sz.x + 48:
			var h := 40.0 + 36.0 * absf(sin(x * 0.011 + layer * 2.3)) + 18.0 * sin(x * 0.043)
			pts2.append(Vector2(_snap(x), base - h))
			x += 48.0
		pts2.append(Vector2(sz.x, sz.y))
		draw_colored_polygon(pts2, col2)
	if intensity > 0.8:
		_draw_ruins(sz)
	# motes drawn toward the portal
	var pc := portal * sz
	for m in _motes:
		var k := fmod(_t * (0.05 + m.z * 0.06) + m.x, 1.0)
		var ang := m.y * TAU + _t * 0.2
		var r := (1.0 - k) * (sz.x * 0.5)
		var p := pc + Vector2(cos(ang), sin(ang) * 0.6) * r
		draw_rect(Rect2(_snap(p.x), _snap(p.y), 4, 4), Color(1.0, 0.7, 1.0, 0.65 * k * intensity))


func _draw_portal(sz: Vector2) -> void:
	var pc := portal * sz
	var r0 := portal_radius * (0.55 + 0.45 * intensity)
	var pulse := 0.5 + 0.5 * sin(_t * 1.3)
	# halo
	for i in 4:
		draw_circle(pc, r0 * (2.3 - i * 0.45), Color(0.6, 0.25, 1.0, 0.035 * intensity + 0.012 * pulse))
	# vertical tear running through the portal (drawn above and below it only)
	for layer in 3:
		var w := (16.0 - layer * 5.0) * (0.8 + 0.3 * pulse) * (0.5 + intensity * 0.5)
		for part in 2:
			var pts := PackedVector2Array()
			var y := 0.0 if part == 0 else pc.y + r0 + 10.0
			var y_end := pc.y - r0 - 10.0 if part == 0 else sz.y + 36.0
			while y <= y_end:
				pts.append(Vector2(pc.x + sin(y * 0.021 + 1.7) * 18.0 + sin(y * 0.057) * 8.0, y))
				y += 36.0
			if pts.size() >= 2:
				draw_polyline(pts, Color(0.75, 0.35, 1.0, 0.12 + layer * 0.12), w)
	# rotating rings
	for i in 7:
		var r := r0 - i * (r0 / 8.5)
		var col := Color("#b04cff") if i % 2 == 0 else Color("#ff4ab0")
		var a0 := _t * (0.35 + i * 0.12) * (1.0 if i % 2 == 0 else -1.0)
		draw_arc(pc, r, a0, a0 + TAU * 0.75, 40, Color(col.r, col.g, col.b, (0.35 + i * 0.07) * (0.55 + 0.45 * intensity)), 8.0 - i * 0.6)
	draw_circle(pc, r0 * 0.30, Color("#0a0220"))
	draw_circle(pc, r0 * (0.14 + 0.02 * pulse), Color(1.0, 0.85, 0.4, 0.55 * intensity + 0.2))
	draw_circle(pc, r0 * 0.07, Color(1, 1, 0.92, 0.9))
	# orbiting rune chips
	for k in 8:
		var a := _t * 0.3 + k * TAU / 8.0
		var p := pc + Vector2(cos(a), sin(a)) * (r0 * 1.12)
		var al := (0.3 + 0.6 * (0.5 + 0.5 * sin(_t * 2.0 + k))) * intensity
		draw_rect(Rect2(_snap(p.x) - 6, _snap(p.y) - 6, 12, 12), Color(1.0, 0.82, 0.3, al))
		draw_rect(Rect2(_snap(p.x) - 2, _snap(p.y) - 2, 4, 4), Color(0.1, 0.05, 0.2, al))


func _draw_ruins(sz: Vector2) -> void:
	# broken arch + pillars framing the portal (dark silhouettes, hero screens only)
	var pc := portal * sz
	var col := Color("#0a0618")
	var hi := Color("#17102c")
	var base := sz.y * 0.86
	for side in [-1.0, 1.0]:
		var sx: float = pc.x + side * (portal_radius * 1.7)
		var h := 320.0 if side < 0.0 else 220.0
		draw_rect(Rect2(sx - 28, base - h, 56, h), col)
		draw_rect(Rect2(sx - 28 + (30 if side < 0.0 else 0), base - h, 12, h), hi)
		draw_rect(Rect2(sx - 38, base - h - 14, 76, 18), hi)
		draw_rect(Rect2(sx - 38, base - 14, 76, 14), hi)
	# lintel fragment
	draw_rect(Rect2(pc.x - portal_radius * 1.7 - 38, base - 350, portal_radius * 1.0, 22), col)
	draw_rect(Rect2(pc.x - portal_radius * 1.7 - 38, base - 350, portal_radius * 1.0, 6), hi)
	# floating stones
	for i in 5:
		var a := _t * 0.4 + i * 1.3
		var p := Vector2(pc.x + cos(a) * portal_radius * 1.4, pc.y - 40 + sin(a * 1.3) * 90.0 - 60.0 + i * 20.0)
		draw_rect(Rect2(_snap(p.x), _snap(p.y), 16 + i * 4, 12), col)
		draw_rect(Rect2(_snap(p.x), _snap(p.y), 16 + i * 4, 4), hi)
