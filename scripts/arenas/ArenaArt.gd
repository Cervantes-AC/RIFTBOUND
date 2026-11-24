class_name ArenaArt
extends Node2D
## Procedural pixel-style scenery for the 5 arenas (original art, no image assets).
## Layers, back to front: sky, far silhouettes, mid architecture, landmark (portal/eye/castle), ambient FX,
## floor + platforms + hazards. A second node (`_fore`) draws edge-only foreground ABOVE the fighters.
## Rule: nothing here touches collision; scenery stays darker/lower-contrast than fighters and hazard
## telegraphs are the only saturated warning colours.

var arena: Arena
var _t := 0.0
var _decor: Array = []
var _redraw_acc := 0.0
var _ci: CanvasItem            # canvas currently being drawn into (this node or the foreground node)
var _fore: Node2D
var _cracks: Array = []        # pre-baked jagged polylines (floor / wall cracks)

const X0 := -900.0
const X1 := 2180.0
const Y0 := -500.0
const Y1 := 1300.0


static func theme_for(id: String) -> Dictionary:
	match id:
		"cavern":
			return {"sky_a": Color("#140605"), "sky_b": Color("#6a2008"), "far": Color("#2a0f0a"), "near": Color("#12060a"), "top": Color("#6b4a3a"), "body": Color("#2a1612"), "plat": Color("#8a5a42"), "glow": Color("#ff7a2a")}
		"citadel":
			return {"sky_a": Color("#070d28"), "sky_b": Color("#4a5aa8"), "far": Color("#2e4a80"), "near": Color("#1a2a58"), "top": Color("#d8f0ff"), "body": Color("#4a78b0"), "plat": Color("#a8d8f0"), "glow": Color("#9fe8ff")}
		"shadow":
			return {"sky_a": Color("#05020e"), "sky_b": Color("#40103c"), "far": Color("#1a0a30"), "near": Color("#0c0518"), "top": Color("#6a3a8a"), "body": Color("#1e1038"), "plat": Color("#7a4ab0"), "glow": Color("#ff3a6a")}
		"sanctuary":
			return {"sky_a": Color("#0e0620"), "sky_b": Color("#5a2a7a"), "far": Color("#3a1a58"), "near": Color("#1e0c34"), "top": Color("#e8d8ff"), "body": Color("#4a3070"), "plat": Color("#c8b0f0"), "glow": Color("#ffd24a")}
		_:
			return {"sky_a": Color("#08181c"), "sky_b": Color("#2e6a4a"), "far": Color("#16382e"), "near": Color("#0a1e1a"), "top": Color("#4fae4a"), "body": Color("#4a3320"), "plat": Color("#7a5a38"), "glow": Color("#b8ff7a")}


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(arena.arena_id)
	for i in 80:
		_decor.append(Vector4(rng.randf(), rng.randf(), rng.randf(), rng.randf()))
	for k in 14:
		var pts := PackedVector2Array()
		var p := Vector2(rng.randf_range(X0, X1), rng.randf_range(-200.0, 560.0))
		var dir := rng.randf_range(0.0, TAU)
		for j in 7:
			pts.append(p)
			dir += rng.randf_range(-0.9, 0.9)
			p += Vector2(cos(dir), sin(dir)) * rng.randf_range(30.0, 70.0)
		_cracks.append(pts)
	_fore = Node2D.new()
	_fore.z_as_relative = false
	_fore.z_index = 8   # above fighters (3), below effects (15+)
	_fore.draw.connect(_draw_fore)
	add_child(_fore)


func _process(delta: float) -> void:
	# retro 20 fps scenery animation: 3x cheaper on phones than redrawing every frame
	_t += delta
	_redraw_acc += delta
	if _redraw_acc >= 0.05:
		_redraw_acc = 0.0
		queue_redraw()
		_fore.queue_redraw()


func _c(key: String) -> Color:
	return arena.theme[key]


# ---------------------------------------------------------------- draw helpers
func _px(x: float, y: float, w: float, h: float, c: Color) -> void:
	_ci.draw_rect(Rect2(floorf(x / 4.0) * 4.0, floorf(y / 4.0) * 4.0, maxf(floorf(w / 4.0) * 4.0, 4.0), maxf(floorf(h / 4.0) * 4.0, 4.0)), c)


func _poly(pts: Array, c: Color) -> void:
	_ci.draw_colored_polygon(PackedVector2Array(pts), c)


func _glow(p: Vector2, r: float, c: Color) -> void:
	for i in 3:
		_ci.draw_circle(p, r * (1.0 - i * 0.3), Color(c.r, c.g, c.b, c.a * (0.3 + i * 0.3)))


func _hills(color: Color, base: float, amp: float, scale: float, speed: float, cap: Color = Color(0, 0, 0, 0)) -> void:
	var pts := PackedVector2Array([Vector2(X0, Y1)])
	var x := X0
	while x <= X1:
		var h := amp * (0.55 + 0.45 * sin((x + _t * speed) * scale)) + amp * 0.35 * sin((x + _t * speed) * scale * 2.7 + 1.3)
		pts.append(Vector2(floorf(x / 16.0) * 16.0, base - h))
		x += 32.0
	pts.append(Vector2(X1, Y1))
	_ci.draw_colored_polygon(pts, color)
	if cap.a > 0.0:
		for i in range(1, pts.size() - 1):
			_ci.draw_rect(Rect2(pts[i].x, pts[i].y, 32, 8), cap)


func _flicker(i: int, speed: float = 2.0) -> float:
	return 0.5 + 0.5 * sin(_t * speed + i * 1.9)


func _draw() -> void:
	if arena == null:
		return
	_ci = self
	var id := arena.arena_id
	var bands := 24
	for i in bands:
		var f := float(i) / (bands - 1)
		draw_rect(Rect2(X0, Y0 + (Y1 - Y0) * i / bands, X1 - X0, (Y1 - Y0) / bands + 2), _c("sky_a").lerp(_c("sky_b"), pow(f, 1.4)))
	match id:
		"forest":
			_forest()
		"cavern":
			_cavern()
		"citadel":
			_citadel()
		"shadow":
			_shadow()
		"sanctuary":
			_sanctuary()
	_floor()
	_platforms()
	_orbs()


# ---------------------------------------------------------------- floor, platforms, hazards
func _floor() -> void:
	var id := arena.arena_id
	var fy := arena.floor_y
	var segs: Array = []
	if arena.has_pit():
		segs = [Vector2(X0, arena.pit.x), Vector2(arena.pit.y, X1)]
	else:
		segs = [Vector2(X0, X1)]
	for s in segs:
		var sx: float = s.x
		var sw: float = s.y - s.x
		draw_rect(Rect2(sx, fy, sw, Y1 - fy), _c("body"))
		draw_rect(Rect2(sx, fy, sw, 16), _c("top"))
		draw_rect(Rect2(sx, fy + 16, sw, 4), Color(0, 0, 0, 0.35))
		var x := floorf(sx / 96.0) * 96.0
		while x < sx + sw:
			var row := 0
			var y := fy + 28.0
			while y < fy + 130.0:
				var off := 48.0 if row % 2 else 0.0
				draw_rect(Rect2(x + off, y, 2, 32), Color(0, 0, 0, 0.18))
				draw_rect(Rect2(x, y + 32, 96, 2), Color(0, 0, 0, 0.18))
				y += 34.0
				row += 1
			x += 96.0
		match id:
			"forest":
				x = floorf(sx / 60.0) * 60.0
				while x < sx + sw:      # moss patches
					var d: Vector4 = _decor[int(absf(x) / 60.0) % 80]
					_px(x + d.x * 20.0, fy + 16, 16 + d.y * 30.0, 8, Color("#3a8a3a"))
					x += 60.0
			"cavern":
				for c in _cracks:        # glowing magma cracks in the rock
					var a := 0.35 + 0.3 * sin(_t * 1.6 + c[0].x)
					for j in range(1, 4):
						var p0: Vector2 = c[j - 1]
						var p1: Vector2 = c[j]
						var q0 := Vector2(p0.x, fy + 30.0 + fmod(absf(p0.y), 90.0))
						var q1 := Vector2(p1.x, fy + 30.0 + fmod(absf(p1.y), 90.0))
						if q0.x >= sx and q1.x <= sx + sw:
							draw_line(q0, q1, Color(1.0, 0.45, 0.1, a), 3.0)
			"citadel":
				draw_rect(Rect2(sx, fy, sw, 6), Color(1, 1, 1, 0.45))
				x = floorf(sx / 150.0) * 150.0
				while x < sx + sw:      # slippery glints
					var ph := fmod(_t * 40.0 + x, 150.0)
					draw_rect(Rect2(x + ph, fy + 4, 40, 3), Color(1, 1, 1, 0.55))
					draw_rect(Rect2(x + ph + 10, fy + 22, 24, 2), Color(0.7, 0.95, 1.0, 0.3))
					x += 150.0
			"shadow":
				draw_rect(Rect2(sx, fy - 2, sw, 5), Color(1.0, 0.2, 0.4, 0.35 + 0.2 * sin(_t * 2.0)))
				x = floorf(sx / 110.0) * 110.0
				while x < sx + sw:      # corruption tendrils
					var d: Vector4 = _decor[int(absf(x) / 110.0) % 80]
					var pts := PackedVector2Array()
					for j in 5:
						pts.append(Vector2(x + sin(_t * 1.2 + j + d.x * 9.0) * 8.0, fy + 18.0 + j * 18.0))
					draw_polyline(pts, Color(0.55, 0.1, 0.35, 0.5), 3.0)
					x += 110.0
			"sanctuary":
				draw_rect(Rect2(sx, fy + 20, sw, 3), Color(1.0, 0.82, 0.3, 0.55))
				x = floorf(sx / 128.0) * 128.0
				while x < sx + sw:      # inlaid glyphs
					var a2 := 0.3 + 0.4 * _flicker(int(x / 128.0), 1.4)
					draw_rect(Rect2(x + 48, fy + 44, 24, 4), Color(1.0, 0.82, 0.3, a2))
					draw_rect(Rect2(x + 58, fy + 36, 4, 20), Color(1.0, 0.82, 0.3, a2))
					x += 128.0
	if arena.has_pit():
		_pit(fy)


func _pit(fy: float) -> void:
	var px: float = arena.pit.x
	var pw: float = arena.pit.y - arena.pit.x
	draw_rect(Rect2(px, fy + 60, pw, Y1), Color("#7a1a08"))
	for i in 14:
		var wave := sin(_t * 3.0 + i) * 4.0
		draw_rect(Rect2(px + i * pw / 14.0, fy + 60 + wave, pw / 14.0 + 1, 22), Color("#ff6a1a") if i % 2 else Color("#ffa030"))
	draw_rect(Rect2(px, fy + 82, pw, 40), Color("#d83a0a"))
	draw_rect(Rect2(px - 6, fy, 6, 70), Color("#2a1008"))
	draw_rect(Rect2(arena.pit.y, fy, 6, 70), Color("#2a1008"))
	for i in 6:
		var by := fy + 70 - fmod(_t * 60.0 + i * 37.0, 120.0)
		draw_rect(Rect2(px + 14 + i * pw / 6.5, by, 6, 6), Color(1, 0.8, 0.3, 0.8))
	# WARNING: pulsing heat glow above the pit + hazard signs on both rims
	var pulse := 0.5 + 0.5 * sin(_t * 4.0)
	for k in 5:
		draw_rect(Rect2(px, fy - 20 - k * 22, pw, 22), Color(1.0, 0.35, 0.05, (0.20 - k * 0.035) * (0.6 + 0.4 * pulse)))
	for sx2 in [px - 40.0, arena.pit.y + 40.0]:
		var sxf: float = sx2
		draw_rect(Rect2(sxf - 2, fy - 54, 4, 54), Color("#1a0c08"))
		_poly([Vector2(sxf, fy - 100), Vector2(sxf + 26, fy - 74), Vector2(sxf, fy - 48), Vector2(sxf - 26, fy - 74)], Color("#08050f"))
		_poly([Vector2(sxf, fy - 94), Vector2(sxf + 20, fy - 74), Vector2(sxf, fy - 54), Vector2(sxf - 20, fy - 74)], Color("#ffb020") if pulse > 0.35 else Color("#ff7a10"))
		draw_rect(Rect2(sxf - 2, fy - 86, 4, 16), Color("#08050f"))
		draw_rect(Rect2(sxf - 2, fy - 64, 4, 4), Color("#08050f"))
	# occasional splash column
	var cycle := fmod(_t, 3.2)
	if cycle < 0.7:
		var k2 := cycle / 0.7
		var cx := px + pw * (0.3 + 0.4 * fmod(floorf(_t / 3.2) * 0.37, 1.0))
		draw_rect(Rect2(cx - 8, fy + 60 - 90.0 * sin(k2 * PI), 16, 90.0 * sin(k2 * PI)), Color(1.0, 0.6, 0.2, 0.8 * (1.0 - k2)))


func _platforms() -> void:
	var id := arena.arena_id
	for p in arena.platforms:
		# underside decoration first (behind the slab)
		match id:
			"forest":
				for k in 4:
					var rx := p.position.x + 16.0 + k * (p.size.x - 32.0) / 3.0
					_px(rx, p.end.y, 4, 14 + (k % 2) * 12, Color("#3a2a18"))
			"citadel":
				for k in 6:
					var ix := p.position.x + 10.0 + k * (p.size.x - 30.0) / 5.0
					_poly([Vector2(ix, p.end.y), Vector2(ix + 14, p.end.y), Vector2(ix + 7, p.end.y + 18 + (k % 3) * 8)], Color("#c8ecff"))
			"sanctuary":
				var cx2 := p.position.x + p.size.x * 0.5
				_poly([Vector2(p.position.x + 10, p.end.y), Vector2(p.end.x - 10, p.end.y), Vector2(cx2 + 20, p.end.y + 40), Vector2(cx2, p.end.y + 78), Vector2(cx2 - 22, p.end.y + 38)], Color("#2a1850"))
				_poly([Vector2(p.position.x + 24, p.end.y), Vector2(p.end.x - 24, p.end.y), Vector2(cx2 + 12, p.end.y + 34), Vector2(cx2 - 14, p.end.y + 32)], Color("#4a3070"))
				draw_rect(Rect2(cx2 - 3, p.end.y + 18, 6, 22), Color(1.0, 0.82, 0.3, 0.4 + 0.4 * _flicker(int(p.position.x), 2.0)))
			"shadow":
				_glow(Vector2(p.position.x + p.size.x * 0.5, p.end.y + 6), p.size.x * 0.4, Color(1.0, 0.2, 0.4, 0.10))
		draw_rect(Rect2(p.position.x - 4, p.position.y - 4, p.size.x + 8, p.size.y + 8), Color("#08050f"))
		draw_rect(p, _c("plat").darkened(0.35))
		draw_rect(Rect2(p.position.x, p.position.y, p.size.x, 7), _c("plat"))
		draw_rect(Rect2(p.position.x, p.position.y + 7, p.size.x, 3), _c("plat").lightened(0.1))
		var x := p.position.x + 10
		while x < p.end.x - 6:
			draw_rect(Rect2(x, p.position.y + 12, 3, 6), Color(0, 0, 0, 0.3))
			x += 28.0
		match id:
			"forest":
				_px(p.position.x, p.position.y - 4, p.size.x, 6, Color("#3a8a3a"))
				_px(p.position.x + 20, p.position.y - 8, 24, 6, Color("#4fae4a"))
				_px(p.end.x - 50, p.position.y - 8, 18, 6, Color("#4fae4a"))
			"cavern":
				draw_line(Vector2(p.position.x + 30, p.position.y + 4), Vector2(p.position.x + 60, p.position.y + 15), Color(1.0, 0.45, 0.1, 0.7), 3.0)
				draw_line(Vector2(p.end.x - 70, p.position.y + 15), Vector2(p.end.x - 36, p.position.y + 4), Color(1.0, 0.45, 0.1, 0.7), 3.0)
			"citadel":
				draw_rect(Rect2(p.position.x, p.position.y, p.size.x, 3), Color(1, 1, 1, 0.8))
			"shadow":
				draw_rect(Rect2(p.position.x, p.position.y, p.size.x, 3), Color(1.0, 0.3, 0.5, 0.8))
			"sanctuary":
				draw_rect(Rect2(p.position.x + 8, p.position.y + 3, p.size.x - 16, 2), Color(1.0, 0.82, 0.3, 0.8))


func _orbs() -> void:
	for o in arena.orbs:
		# TELEGRAPH: faint dots show where the orb will be over the next ~1.2 s
		for k in range(1, 13):
			var fp := arena.orb_position(o, arena.time + k * 0.1)
			draw_circle(fp, 4.0 + (13 - k) * 0.25, Color(1.0, 0.25, 0.7, 0.05 + 0.2 * (1.0 - k / 13.0)))
		var pos := arena.orb_position(o, arena.time)
		for i in 6:
			var tp := arena.orb_position(o, arena.time - i * 0.06)
			draw_circle(tp, float(o["r"]) * (1.0 - i * 0.12), Color(0.75, 0.3, 1.0, 0.10 + 0.04 * (6 - i)))
		var halo := 8.0 + 4.0 * sin(_t * 8.0)
		draw_circle(pos, float(o["r"]) + halo + 8.0, Color(1.0, 0.2, 0.6, 0.12))
		draw_circle(pos, float(o["r"]) + halo, Color(0.7, 0.2, 1.0, 0.25))
		draw_circle(pos, float(o["r"]), Color("#6a1ab0"))
		draw_circle(pos, float(o["r"]) * 0.6, Color("#d84ad0"))
		draw_circle(pos, float(o["r"]) * 0.28, Color.WHITE)
		for k in 6:   # orbiting sparks
			var a := _t * 5.0 + k * TAU / 6.0
			draw_rect(Rect2(pos.x + cos(a) * (float(o["r"]) + 12.0) - 2, pos.y + sin(a) * (float(o["r"]) + 12.0) - 2, 4, 4), Color(1.0, 0.7, 1.0, 0.9))


# ---------------------------------------------------------------- shared scenery pieces
func _pillar(x: float, base: float, w: float, h: float, stone: Color, moss: Color) -> void:
	_px(x - 6, base - h - 14, w + 12, 16, stone.lightened(0.08))    # capital
	_px(x, base - h, w, h, stone)
	_px(x + w * 0.7, base - h, w * 0.3, h, stone.darkened(0.2))
	_px(x - 6, base - 14, w + 12, 14, stone.lightened(0.05))        # plinth
	for k in 3:
		_px(x + 6 + k * w * 0.22, base - h + 10, 3, h - 30, Color(0, 0, 0, 0.18))
	if moss.a > 0.0:
		_px(x, base - h, w * 0.6, 6, moss)
		_px(x + w * 0.2, base - h * 0.5, 8, 16, moss)


func _ruin(x: float, base: float, s: float, stone: Color, moss: Color, glow: Color, seed: float) -> void:
	_pillar(x, base, 44.0 * s, 190.0 * s, stone, moss)
	_pillar(x + 190.0 * s, base, 44.0 * s, 120.0 * s, stone, moss)
	_px(x - 8.0 * s, base - 190.0 * s - 34.0 * s, 150.0 * s, 20.0 * s, stone.lightened(0.05))      # broken lintel
	_px(x + 150.0 * s, base - 120.0 * s - 28.0 * s, 24.0 * s, 12.0 * s, stone)                       # fallen chunk
	_px(x + 70.0 * s, base - 20.0 * s, 40.0 * s, 20.0 * s, stone.darkened(0.15))                      # rubble
	_px(x + 118.0 * s, base - 10.0 * s, 26.0 * s, 10.0 * s, stone)
	if glow.a > 0.0:
		var a := 0.35 + 0.45 * sin(_t * 1.5 + seed)
		_px(x + 14.0 * s, base - 120.0 * s, 14.0 * s, 26.0 * s, Color(glow.r, glow.g, glow.b, a))
		_px(x + 204.0 * s, base - 80.0 * s, 12.0 * s, 22.0 * s, Color(glow.r, glow.g, glow.b, a * 0.8))


func _swirl(c: Vector2, r: float, rings: int, col_a: Color, col_b: Color, speed: float, w: float) -> void:
	for i in rings:
		var rr := r - i * (r / (rings + 1.0))
		var a0 := _t * (speed + i * 0.12) * (1.0 if i % 2 == 0 else -1.0)
		var col := col_a if i % 2 == 0 else col_b
		draw_arc(c, rr, a0, a0 + TAU * 0.72, 40, Color(col.r, col.g, col.b, col.a * (0.5 + i * 0.5 / rings)), w)


func _snow(count: int, speed: float, size: float, alpha: float, seed_off: int = 0) -> void:
	for i in count:
		var d: Vector4 = _decor[(i + seed_off) % 80]
		var sx := fmod(d.x * 3200.0 + sin(_t * 0.7 + i) * 24.0 + _t * 14.0 * (0.4 + d.z), 3200.0) + X0
		var sy := fmod(d.y * 1800.0 + _t * speed * (0.6 + d.w * 0.8), 1800.0) + Y0
		_px(sx, sy, size, size, Color(1, 1, 1, alpha))


# ---------------------------------------------------------------- per-arena scenery
func _forest() -> void:
	var far := _c("far")
	_glow(Vector2(1010, 118), 100, Color("#d8f0b0", 0.16))
	draw_circle(Vector2(1010, 118), 52, Color("#eaf6c8"))
	draw_circle(Vector2(1032, 106), 48, _c("sky_a").lerp(_c("sky_b"), 0.2))
	for i in 5:   # god rays
		var rx := -100.0 + i * 300.0 + sin(_t * 0.3 + i) * 24.0
		var a := 0.03 + 0.025 * sin(_t * 0.8 + i * 1.7)
		draw_colored_polygon(PackedVector2Array([Vector2(rx, -60), Vector2(rx + 70, -60), Vector2(rx + 300, 620), Vector2(rx + 140, 620)]), Color(0.85, 1.0, 0.6, a))
	_hills(far.lightened(0.05), 570.0, 110.0, 0.004, 2.0)
	# distant giant trees
	var x := X0 + 40.0
	while x < X1:
		var d: Vector4 = _decor[int((x - X0) / 300.0) % 80]
		_px(x, -100, 60.0 + d.x * 30.0, 760, far.darkened(0.15))
		_px(x + 38.0, -100, 14, 760, far.darkened(0.32))
		x += 280.0 + d.y * 120.0
	# canopy
	x = X0
	while x < X1:
		var d2: Vector4 = _decor[int((x - X0) / 110.0) % 80]
		var bob := sin(_t * 0.5 + x * 0.01) * 4.0
		_px(x, -70 + bob, 150, 70 + d2.x * 70.0, far.darkened(0.35))
		_px(x + 30, -20 + bob, 90, 40 + d2.y * 50.0, far.darkened(0.25))
		x += 110.0
	# mid: overgrown ruins + background rift portal
	var pc := Vector2(640, 250)
	_glow(pc, 150, Color(0.5, 1.0, 0.8, 0.07))
	draw_arc(pc, 96, 0, TAU, 40, Color("#08050f"), 22.0)
	draw_arc(pc, 96, 0, TAU, 40, far.lightened(0.28), 14.0)
	for k in 8:   # ring glyphs
		var a2 := k * TAU / 8.0
		_px(pc.x + cos(a2) * 96.0 - 4, pc.y + sin(a2) * 96.0 - 4, 8, 8, Color(0.6, 1.0, 0.8, 0.4 + 0.5 * _flicker(k, 1.6)))
	draw_circle(pc, 82, Color(0.05, 0.12, 0.16, 0.9))
	_swirl(pc, 78, 5, Color(0.5, 1.0, 0.8, 0.8), Color(0.7, 0.5, 1.0, 0.8), 0.8, 5.0)
	draw_circle(pc, 14 + 3.0 * sin(_t * 3.0), Color(0.85, 1.0, 0.95, 0.9))
	for k in 5:
		var rx2 := -150.0 + k * 700.0
		_ruin(rx2, 626, 1.0 + 0.2 * float(_decor[k].x), far.lightened(0.22), Color("#2e6a3a"), Color(0.6, 1.0, 0.8, 1.0), float(k))
	# glowing flora (low, behind the fight line)
	x = X0
	while x < X1:
		var d3: Vector4 = _decor[int((x - X0) / 70.0) % 80]
		var hgt := 14.0 + d3.x * 34.0
		var gc := Color("#6affc8") if d3.y < 0.4 else (Color("#c08aff") if d3.y < 0.75 else Color("#c8ff6a"))
		var gp := 0.5 + 0.5 * sin(_t * 1.8 + d3.z * 9.0)
		_px(x, 612 - hgt, 4, hgt, Color("#1e4a34"))
		_glow(Vector2(x + 2, 612 - hgt), 16, Color(gc.r, gc.g, gc.b, 0.12 + 0.12 * gp))
		_px(x - 6, 612 - hgt - 8, 16, 10, gc)
		x += 70.0 + d3.w * 40.0
	for i in 26:   # fireflies
		var d4: Vector4 = _decor[i]
		var fx := d4.x * 1400.0 - 60.0 + sin(_t * 0.8 + i) * 30.0
		var fy := 230.0 + d4.y * 360.0 + cos(_t * 0.6 + i * 2.0) * 20.0
		var a3 := 0.3 + 0.6 * _flicker(i, 2.3)
		_glow(Vector2(fx, fy), 9, Color(0.85, 1.0, 0.4, 0.12 * a3))
		_px(fx, fy, 6, 6, Color(0.9, 1.0, 0.5, a3))
	draw_rect(Rect2(X0, 548, X1 - X0, 72), Color(0.7, 0.95, 0.85, 0.07))


func _cavern() -> void:
	_hills(Color("#3a120a"), 640.0, 170.0, 0.006, 0.0)
	# glowing lava veins in the back wall
	for c in _cracks:
		var a := 0.25 + 0.25 * sin(_t * 1.4 + float(c[0].x))
		draw_polyline(PackedVector2Array(c), Color(1.0, 0.4, 0.08, a), 4.0)
		draw_polyline(PackedVector2Array(c), Color(1.0, 0.8, 0.3, a * 0.6), 1.0)
	_hills(Color("#1c0a08"), 664.0, 110.0, 0.009, 0.0)
	# basalt columns
	var x := X0 + 60.0
	while x < X1:
		var d: Vector4 = _decor[int((x - X0) / 260.0) % 80]
		var w := 70.0 + d.x * 40.0
		_px(x, 200.0 + d.y * 160.0, w, 460, Color("#1a0c0a"))
		_px(x + w * 0.7, 200.0 + d.y * 160.0, w * 0.3, 460, Color("#10060a"))
		for k in 5:
			_px(x + 6, 230.0 + d.y * 160.0 + k * 70.0, 4, 26, Color(1.0, 0.4, 0.1, 0.25 + 0.2 * _flicker(k + int(x), 1.5)))
		x += 250.0 + d.z * 150.0
	# lava falls
	for fx in [180.0, 1110.0, 1700.0, -420.0]:
		var fxf: float = fx
		_glow(Vector2(fxf + 18, 300), 130, Color(1.0, 0.4, 0.1, 0.06))
		_px(fxf, Y0, 36, 1100, Color("#7a280a"))
		var yy := fmod(_t * 160.0, 80.0) + Y0
		while yy < 600.0:
			_px(fxf + 6, yy, 24, 40, Color(1.0, 0.65, 0.2, 0.55))
			yy += 80.0
		_px(fxf - 20, 590, 76, 14, Color(1.0, 0.7, 0.3, 0.5 + 0.3 * sin(_t * 5.0)))   # splash
	# stalactites with drips
	x = X0
	while x < X1:
		var d2: Vector4 = _decor[int((x - X0) / 90.0) % 80]
		var h := 70.0 + d2.x * 150.0
		_poly([Vector2(x, Y0), Vector2(x + 70, Y0), Vector2(x + 35, 40 + h)], Color("#120808"))
		_poly([Vector2(x + 14, Y0), Vector2(x + 56, Y0), Vector2(x + 35, 20 + h)], Color("#241210"))
		var dy := fmod(_t * 90.0 + d2.z * 300.0, 300.0)
		if dy < 200.0:
			_px(x + 33, 40 + h + dy, 4, 6, Color(1.0, 0.6, 0.2, 0.9 - dy / 260.0))
		x += 90.0
	# distant magma river glow + heat shimmer
	var glow := 0.18 + 0.06 * sin(_t * 2.0)
	for i in 5:
		draw_rect(Rect2(X0, 560 + i * 14, X1 - X0, 16), Color(1.0, 0.4, 0.1, glow * (1.0 - i * 0.15)))
	for k in 4:
		var pts := PackedVector2Array()
		var yb := 520.0 - k * 26.0
		var xx := X0
		while xx <= X1:
			pts.append(Vector2(xx, yb + sin(xx * 0.03 + _t * 3.0 + k) * 3.0))
			xx += 48.0
		draw_polyline(pts, Color(1.0, 0.7, 0.4, 0.05), 6.0)
	for i in 30:   # embers
		var d3: Vector4 = _decor[i]
		var ey := 700.0 - fmod(_t * (20.0 + d3.z * 40.0) + d3.y * 700.0, 700.0)
		_px(d3.x * 1500.0 - 100.0 + sin(_t + i) * 14.0, ey, 4, 4, Color(1, 0.55, 0.2, 0.8))


func _citadel() -> void:
	var near := _c("near")
	for i in 40:
		var d: Vector4 = _decor[i]
		_px(d.x * 3000.0 - 900.0, d.y * 380.0 - 100.0, 4, 4, Color(1, 1, 1, 0.3 + 0.6 * absf(sin(_t + i))))
	# aurora ribbons
	for r in 3:
		var col := [Color(0.3, 1.0, 0.8, 0.10), Color(0.6, 0.4, 1.0, 0.10), Color(1.0, 0.5, 0.9, 0.07)][r] as Color
		var top := PackedVector2Array()
		var bot := PackedVector2Array()
		var xx := X0
		while xx <= X1:
			var yy := 90.0 + r * 55.0 + sin(xx * 0.004 + _t * 0.35 + r * 2.0) * 50.0
			top.append(Vector2(xx, yy))
			bot.insert(0, Vector2(xx, yy + 60.0 + sin(xx * 0.01 + _t * 0.5) * 18.0))
			xx += 80.0
		top.append_array(bot)
		draw_colored_polygon(top, col)
	_glow(Vector2(260, 130), 90, Color(0.8, 0.9, 1.0, 0.12))
	draw_circle(Vector2(260, 130), 44, Color("#dce8ff"))
	draw_circle(Vector2(246, 120), 8, Color("#b4c4e8"))
	_hills(_c("far"), 600.0, 150.0, 0.005, 0.0, Color(0.9, 0.96, 1.0, 0.55))
	# the frozen citadel: central keep + flanking towers
	_castle(640.0, 640.0, 1.0, near)
	_castle(60.0, 640.0, 0.7, near.darkened(0.15))
	_castle(1250.0, 640.0, 0.7, near.darkened(0.15))
	_castle(-700.0, 640.0, 0.85, near.darkened(0.2))
	_castle(1900.0, 640.0, 0.85, near.darkened(0.2))
	# crystal clusters
	for cx in [40.0, 1235.0, 360.0, 930.0, -380.0, 1660.0]:
		var cxf: float = cx
		_crystals(cxf, 620.0, 1.0 if absf(cxf - 640.0) > 500.0 else 0.6)
	_snow(40, 55.0, 4.0, 0.75)
	_snow(24, 90.0, 6.0, 0.5, 30)


func _castle(cx: float, base: float, s: float, col: Color) -> void:
	var lit := col.lightened(0.14)
	var dark := col.darkened(0.12)
	var w := 300.0 * s
	var h := 330.0 * s
	_px(cx - w * 0.5, base - h, w, h, col)
	_px(cx - w * 0.5, base - h, w * 0.35, h, lit)               # lit face
	_px(cx + w * 0.2, base - h, w * 0.3, h, dark)               # shaded face
	for k in 5:                                                  # battlements
		_px(cx - w * 0.5 + k * w / 4.5, base - h - 22 * s, w / 9.0, 22 * s, lit)
	# central spire and two towers with pointed roofs
	for tx in [-0.34, 0.0, 0.34]:
		var txf: float = tx
		var tw := 56.0 * s
		var th := h * (0.55 if txf == 0.0 else 0.35)
		_px(cx + txf * w - tw * 0.5, base - h - th, tw, th, lit if txf <= 0.0 else dark)
		_poly([Vector2(cx + txf * w - tw * 0.7, base - h - th), Vector2(cx + txf * w + tw * 0.7, base - h - th), Vector2(cx + txf * w, base - h - th - 110 * s)], Color("#c8e4ff", 0.85) if txf == 0.0 else col.lightened(0.28))
	# arched windows
	for k in 4:
		var wx := cx - w * 0.38 + k * w * 0.25
		var wa := 0.55 + 0.35 * sin(_t * 0.9 + k * 1.3 + cx)
		_px(wx, base - h * 0.78, 18 * s, 34 * s, Color(0.65, 0.95, 1.0, wa))
		_px(wx + 4 * s, base - h * 0.78 - 8 * s, 10 * s, 10 * s, Color(0.65, 0.95, 1.0, wa))
		_px(wx, base - h * 0.4, 18 * s, 34 * s, Color(0.8, 0.6, 1.0, wa * 0.8))
	# gate
	_px(cx - 26 * s, base - 80 * s, 52 * s, 80 * s, Color("#060a1c"))
	_px(cx - 18 * s, base - 100 * s, 36 * s, 24 * s, Color("#060a1c"))


func _crystals(x: float, base: float, s: float) -> void:
	var pulse := 0.5 + 0.5 * sin(_t * 1.6 + x * 0.01)
	_glow(Vector2(x, base - 60 * s), 90 * s, Color(0.5, 0.8, 1.0, 0.09 + 0.05 * pulse))
	var specs := [[-30.0, 70.0, 20.0, Color("#6ad8ff")], [0.0, 120.0, 26.0, Color("#9fe8ff")], [34.0, 84.0, 22.0, Color("#b890ff")], [-58.0, 44.0, 16.0, Color("#b890ff")], [58.0, 50.0, 16.0, Color("#6ad8ff")]]
	for sp in specs:
		var cxx: float = x + float(sp[0]) * s
		var hh: float = float(sp[1]) * s
		var ww: float = float(sp[2]) * s
		var cc: Color = sp[3]
		_poly([Vector2(cxx - ww, base), Vector2(cxx - ww * 0.7, base - hh * 0.8), Vector2(cxx, base - hh), Vector2(cxx + ww * 0.7, base - hh * 0.8), Vector2(cxx + ww, base)], cc.darkened(0.35))
		_poly([Vector2(cxx - ww, base), Vector2(cxx - ww * 0.7, base - hh * 0.8), Vector2(cxx, base - hh), Vector2(cxx, base)], cc.darkened(0.1))
		_ci.draw_line(Vector2(cxx - ww * 0.4, base - hh * 0.3), Vector2(cxx - ww * 0.4, base - hh * 0.75), Color(1, 1, 1, 0.5 + 0.4 * pulse), 3.0)


func _shadow() -> void:
	for i in 50:
		var d: Vector4 = _decor[i % 80]
		_px(d.x * 3000.0 - 900.0, d.y * 800.0 - 100.0, 4, 4, Color(1.0, 0.5, 0.8, 0.2 + 0.5 * absf(sin(_t * 1.5 + i))))
	# the Watcher: giant eye
	var ec := Vector2(640, 190)
	_glow(ec, 220, Color(1.0, 0.1, 0.4, 0.07))
	draw_circle(ec, 124, Color("#10061e"))
	draw_circle(ec, 104, Color("#2e1450"))
	var look := Vector2(sin(_t * 0.5) * 24.0, cos(_t * 0.4) * 10.0)
	draw_circle(ec + look, 58, Color("#e0204a"))
	draw_circle(ec + look, 44, Color("#ff5a3a"))
	var blink := clampf(absf(fmod(_t, 7.0) - 3.5) * 5.0, 0.08, 1.0)
	draw_colored_polygon(PackedVector2Array([ec + look + Vector2(0, -42.0 * blink), ec + look + Vector2(10, 0), ec + look + Vector2(0, 42.0 * blink), ec + look + Vector2(-10, 0)]), Color("#08020c"))
	draw_circle(ec + look + Vector2(-18, -18), 7, Color(1, 1, 1, 0.85))
	for k in 12:   # veins
		var a := k * TAU / 12.0
		draw_line(ec + Vector2(cos(a), sin(a)) * 104.0, ec + Vector2(cos(a), sin(a)) * 150.0, Color(0.6, 0.1, 0.3, 0.35), 3.0)
	# floating fragments
	for i in 8:
		var d2: Vector4 = _decor[i]
		var ix := d2.x * 1800.0 - 300.0
		var iy := 120.0 + d2.y * 360.0 + sin(_t * 0.8 + i) * 14.0
		var w := 90.0 + d2.z * 110.0
		_poly([Vector2(ix, iy), Vector2(ix + w, iy), Vector2(ix + w * 0.7, iy + 50), Vector2(ix + w * 0.5, iy + 92), Vector2(ix + w * 0.3, iy + 50)], _c("far"))
		_px(ix, iy - 6, w, 8, _c("top").darkened(0.4))
		_px(ix + w * 0.5 - 2, iy + 30, 4, 28, Color(1.0, 0.2, 0.4, 0.3 + 0.3 * _flicker(i, 1.8)))
	# distorted architecture: leaning broken towers + hanging arches
	var x := X0 + 80.0
	while x < X1:
		var d3: Vector4 = _decor[int((x - X0) / 230.0) % 80]
		var lean := (d3.x - 0.5) * 70.0
		var th := 260.0 + d3.y * 200.0
		var w2 := 70.0 + d3.z * 40.0
		_poly([Vector2(x, 640), Vector2(x + w2, 640), Vector2(x + w2 + lean, 640 - th), Vector2(x + lean + w2 * 0.4, 640 - th - 40), Vector2(x + lean, 640 - th + 14)], _c("near").lightened(0.04))
		_poly([Vector2(x + w2 * 0.6, 640), Vector2(x + w2, 640), Vector2(x + w2 + lean, 640 - th), Vector2(x + w2 * 0.8 + lean, 640 - th)], _c("near").darkened(0.3))
		var wa := 0.35 + 0.5 * _flicker(int(x), 1.2)
		_px(x + w2 * 0.35 + lean * 0.5, 640 - th * 0.55, 10, 22, Color(1.0, 0.25, 0.45, wa))
		x += 220.0 + d3.w * 90.0
	_hills(_c("near"), 680.0, 100.0, 0.007, 0.0)
	# unstable portals
	for pi in 3:
		var pp := [Vector2(170, 330), Vector2(1110, 290), Vector2(640, 520)][pi] as Vector2
		var fl := 0.55 + 0.45 * sin(_t * 9.0 + pi * 2.0) * sin(_t * 3.1 + pi)
		_glow(pp, 60, Color(1.0, 0.2, 0.6, 0.10 * fl))
		_swirl(pp, 40.0 + 4.0 * fl, 3, Color(1.0, 0.3, 0.6, fl), Color(0.7, 0.3, 1.0, fl), 1.4, 3.0)
		draw_circle(pp, 6.0, Color(1, 0.8, 0.9, 0.8 * fl))
	for k in 3:   # rift cracks
		var cx := 160.0 + k * 480.0
		var pts := PackedVector2Array()
		for j in 8:
			pts.append(Vector2(cx + sin(j * 1.9 + k) * 26.0, 40.0 + j * 70.0))
		draw_polyline(pts, Color("#ff3a6a", 0.30 + 0.2 * sin(_t * 2.0 + k)), 3.0)


func _sanctuary() -> void:
	var gold := Color("#ffd24a")
	for i in 50:
		var d: Vector4 = _decor[i % 80]
		_px(d.x * 3000.0 - 900.0, d.y * 700.0 - 100.0, 4, 4, Color(1, 0.9, 0.6, 0.2 + 0.5 * absf(sin(_t + i))))
	# the great Rift: massive, layered
	var pc := Vector2(640, 250)
	_glow(pc, 360, Color(0.7, 0.3, 1.0, 0.07))
	_glow(pc, 240, Color(1.0, 0.8, 0.3, 0.06))
	for i in 8:
		var r := 210.0 - i * 21.0
		var col := Color("#b04cff") if i % 2 == 0 else Color("#4a1a90")
		var a0 := _t * (0.4 + i * 0.1) * (1.0 if i % 2 == 0 else -1.0)
		draw_arc(pc, r, a0, a0 + TAU * 0.8, 36, Color(col, 0.5 + i * 0.05), 9.0)
	draw_circle(pc, 66, Color("#12042a"))
	draw_circle(pc, 40 + 4.0 * sin(_t * 3.0), Color(gold, 0.6))
	draw_circle(pc, 18, Color(1, 1, 0.9, 0.9))
	# rotating ancient ring segments around the rift
	for k in 6:
		var a1 := _t * 0.15 + k * TAU / 6.0
		var rp := pc + Vector2(cos(a1), sin(a1)) * 262.0
		_px(rp.x - 22, rp.y - 8, 44, 16, Color("#2a1850"))
		_px(rp.x - 18, rp.y - 4, 36, 8, Color(gold, 0.35 + 0.4 * _flicker(k, 1.5)))
	# lightning arcs from the rift (re-rolled twice a second)
	var seed_i := int(_t * 2.5)
	for k in 3:
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_i * 7 + k * 131
		var ang := rng.randf() * TAU
		var life := 1.0 - fmod(_t * 2.5, 1.0)
		var p := pc + Vector2(cos(ang), sin(ang)) * 70.0
		var pts := PackedVector2Array([p])
		for j in 6:
			ang += rng.randf_range(-0.5, 0.5)
			p += Vector2(cos(ang), sin(ang)) * 42.0
			pts.append(p)
		draw_polyline(pts, Color(0.9, 0.7, 1.0, 0.6 * life), 4.0)
		draw_polyline(pts, Color(1, 1, 1, 0.8 * life), 1.5)
	# pillars with glyphs + dais steps
	var x := X0 + 30.0
	while x < X1:
		var d2: Vector4 = _decor[int((x - X0) / 100.0) % 80]
		_pillar(x, 640.0, 54.0, 470.0, _c("far"), Color(0, 0, 0, 0))
		for k in 4:
			_px(x + 18, 190.0 + k * 80.0, 18, 6, Color(gold, 0.25 + 0.5 * _flicker(k + int(x), 1.3)))
			_px(x + 24, 184.0 + k * 80.0, 6, 18, Color(gold, 0.25 + 0.5 * _flicker(k + int(x), 1.3)))
		x += 260.0 + d2.x * 40.0
	for k in 3:
		_px(480 - k * 24, 612 - k * 0, 320 + k * 48, 8, Color("#2a1850"))
	for i in 18:   # energy motes streaming up
		var d3: Vector4 = _decor[i]
		var ry := 700.0 - fmod(_t * (24.0 + d3.z * 40.0) + d3.y * 700.0, 760.0)
		_px(d3.x * 1500.0 - 100.0 + sin(_t + i) * 12.0, ry, 6, 6, Color(gold, 0.55))


# ---------------------------------------------------------------- foreground (above fighters, edges only)
func _draw_fore() -> void:
	if arena == null or _decor.is_empty():
		return
	_ci = _fore
	var id := arena.arena_id
	var fy := arena.floor_y
	match id:
		"forest":
			var x := X0
			while x < X1:   # grass blades along the floor lip (below the feet line)
				var d: Vector4 = _decor[int((x - X0) / 38.0) % 80]
				_px(x, fy + 12, 4, 14 + d.x * 10.0, Color("#4fae4a"))
				_px(x + 10, fy + 12, 4, 10 + d.y * 12.0, Color("#6ad060"))
				x += 38.0
			for k in 7:   # hanging vines at the very top
				var vx := -60.0 + k * 230.0 + float(_decor[k].x) * 60.0
				var vl := 60.0 + float(_decor[k].y) * 70.0
				_px(vx + sin(_t + k) * 4.0, -20, 4, vl, Color("#1e5a2e"))
				_px(vx - 6 + sin(_t + k) * 4.0, -20 + vl, 16, 8, Color("#2e8a3e"))
			for k in 9:   # falling leaves
				var d2: Vector4 = _decor[k + 40]
				var lx := fmod(d2.x * 1400.0 + _t * 30.0, 1400.0) - 60.0
				var ly := fmod(d2.y * 800.0 + _t * 40.0, 800.0) - 40.0
				_px(lx + sin(_t * 2.0 + k) * 20.0, ly, 8, 6, Color("#8ad060", 0.8))
		"cavern":
			_poly([Vector2(X0, 760), Vector2(X0, 560), Vector2(70, 640), Vector2(160, 760)], Color("#0a0405"))
			_poly([Vector2(X1, 760), Vector2(X1, 540), Vector2(1220, 640), Vector2(1120, 760)], Color("#0a0405"))
			for k in 14:
				var d3: Vector4 = _decor[k + 20]
				var ey := 760.0 - fmod(_t * (60.0 + d3.z * 70.0) + d3.y * 760.0, 800.0)
				_px(d3.x * 1400.0 - 60.0 + sin(_t * 1.5 + k) * 18.0, ey, 6, 6, Color(1, 0.6, 0.25, 0.7))
		"citadel":
			_snow(14, 130.0, 8.0, 0.35, 50)
			_fore.draw_rect(Rect2(X0, fy + 6, X1 - X0, 4), Color(0.8, 0.95, 1.0, 0.3))
		"shadow":
			var x2 := X0
			while x2 < X1:
				var d4: Vector4 = _decor[int((x2 - X0) / 90.0) % 80]
				var pts := PackedVector2Array()
				for j in 5:
					pts.append(Vector2(x2 + sin(_t * 1.5 + j + d4.x * 9.0) * 10.0, 740.0 - j * 16.0))
				_fore.draw_polyline(pts, Color(0.3, 0.04, 0.2, 0.7), 5.0)
				x2 += 90.0
			for k in 10:
				var d5: Vector4 = _decor[k + 30]
				_px(d5.x * 1400.0 + sin(_t + k) * 30.0, fmod(d5.y * 700.0 + _t * 20.0, 700.0), 4, 4, Color(1.0, 0.4, 0.7, 0.45))
		"sanctuary":
			for k in 14:
				var d6: Vector4 = _decor[k + 10]
				var ry := 760.0 - fmod(_t * (50.0 + d6.z * 60.0) + d6.y * 760.0, 800.0)
				_px(d6.x * 1400.0 - 60.0, ry, 4, 4, Color(1.0, 0.85, 0.4, 0.6))
