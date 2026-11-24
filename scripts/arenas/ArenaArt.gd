class_name ArenaArt
extends Node2D
## PLACEHOLDER ART: procedural pixel-style backgrounds, floors, platforms and hazards for the 5 arenas.
## Drawn far beyond 1280x720 so any phone aspect ratio shows scenery instead of empty borders.

var arena: Arena
var _t := 0.0
var _decor: Array = []
var _redraw_acc := 0.0

const X0 := -900.0
const X1 := 2180.0
const Y0 := -500.0
const Y1 := 1300.0


static func theme_for(id: String) -> Dictionary:
	match id:
		"cavern":
			return {"sky_a": Color("#1a0805"), "sky_b": Color("#5a1a0a"), "far": Color("#2a0f0a"), "near": Color("#12060a"), "top": Color("#6b4a3a"), "body": Color("#2a1612"), "plat": Color("#8a5a42"), "glow": Color("#ff7a2a")}
		"citadel":
			return {"sky_a": Color("#0a1830"), "sky_b": Color("#5a8ac0"), "far": Color("#3a5a88"), "near": Color("#1e3458"), "top": Color("#d8f0ff"), "body": Color("#5a86b8"), "plat": Color("#a8d8f0"), "glow": Color("#9fe8ff")}
		"shadow":
			return {"sky_a": Color("#050210"), "sky_b": Color("#2a1048"), "far": Color("#1a0a30"), "near": Color("#0c0518"), "top": Color("#5a3a8a"), "body": Color("#1e1038"), "plat": Color("#7a4ab0"), "glow": Color("#d84ad0")}
		"sanctuary":
			return {"sky_a": Color("#10061e"), "sky_b": Color("#5a2a7a"), "far": Color("#3a1a58"), "near": Color("#1e0c34"), "top": Color("#e8d8ff"), "body": Color("#4a3070"), "plat": Color("#c8b0f0"), "glow": Color("#ffd24a")}
		_:
			return {"sky_a": Color("#0a1a1a"), "sky_b": Color("#2a5a4a"), "far": Color("#16382e"), "near": Color("#0a1e1a"), "top": Color("#4fae4a"), "body": Color("#4a3320"), "plat": Color("#7a5a38"), "glow": Color("#b8ff7a")}


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(arena.arena_id)
	for i in 80:
		_decor.append(Vector4(rng.randf(), rng.randf(), rng.randf(), rng.randf()))


func _process(delta: float) -> void:
	# retro 20 fps background animation: 3x cheaper on phones than redrawing every frame
	_t += delta
	_redraw_acc += delta
	if _redraw_acc >= 0.05:
		_redraw_acc = 0.0
		queue_redraw()


func _draw() -> void:
	if arena == null:
		return
	var th := arena.theme
	var id := arena.arena_id
	# sky bands
	var bands := 24
	for i in bands:
		var f := float(i) / (bands - 1)
		draw_rect(Rect2(X0, Y0 + (Y1 - Y0) * i / bands, X1 - X0, (Y1 - Y0) / bands + 2), th["sky_a"].lerp(th["sky_b"], pow(f, 1.4)))
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
	_foreground(id)


# ---------------------------------------------------------------- shared pieces
func _floor() -> void:
	var th := arena.theme
	var fy := arena.floor_y
	var segs: Array = []
	if arena.has_pit():
		segs = [Vector2(X0, arena.pit.x), Vector2(arena.pit.y, X1)]
	else:
		segs = [Vector2(X0, X1)]
	for s in segs:
		draw_rect(Rect2(s.x, fy, s.y - s.x, Y1 - fy), th["body"])
		draw_rect(Rect2(s.x, fy, s.y - s.x, 16), th["top"])
		draw_rect(Rect2(s.x, fy + 16, s.y - s.x, 4), Color(0, 0, 0, 0.35))
		var x := floorf(s.x / 96.0) * 96.0
		while x < s.y:
			var row := 0
			var y := fy + 28.0
			while y < fy + 130.0:
				var off := 48.0 if row % 2 else 0.0
				draw_rect(Rect2(x + off, y, 2, 32), Color(0, 0, 0, 0.18))
				draw_rect(Rect2(x, y + 32, 96, 2), Color(0, 0, 0, 0.18))
				y += 34.0
				row += 1
			x += 96.0
	if arena.has_pit():
		var pw: float = arena.pit.y - arena.pit.x
		draw_rect(Rect2(arena.pit.x, fy + 60, pw, Y1), Color("#7a1a08"))
		for i in 14:
			var wave := sin(_t * 3.0 + i) * 4.0
			draw_rect(Rect2(arena.pit.x + i * pw / 14.0, fy + 60 + wave, pw / 14.0 + 1, 22), Color("#ff6a1a") if i % 2 else Color("#ffa030"))
		draw_rect(Rect2(arena.pit.x, fy + 82, pw, 40), Color("#d83a0a"))
		draw_rect(Rect2(arena.pit.x - 6, fy, 6, 70), Color("#2a1008"))
		draw_rect(Rect2(arena.pit.y, fy, 6, 70), Color("#2a1008"))
		for i in 6:
			var by := fy + 70 - fmod(_t * 60.0 + i * 37.0, 120.0)
			draw_rect(Rect2(arena.pit.x + 14 + i * pw / 6.5, by, 6, 6), Color(1, 0.8, 0.3, 0.8))


func _platforms() -> void:
	var th := arena.theme
	for p in arena.platforms:
		draw_rect(Rect2(p.position.x - 4, p.position.y - 4, p.size.x + 8, p.size.y + 8), Color("#08050f"))
		draw_rect(p, th["plat"].darkened(0.35))
		draw_rect(Rect2(p.position.x, p.position.y, p.size.x, 7), th["plat"])
		draw_rect(Rect2(p.position.x, p.position.y + 7, p.size.x, 3), th["plat"].lightened(0.1))
		var x := p.position.x + 10
		while x < p.end.x - 6:
			draw_rect(Rect2(x, p.position.y + 12, 3, 6), Color(0, 0, 0, 0.3))
			x += 28.0


func _orbs() -> void:
	for o in arena.orbs:
		var pos := arena.orb_position(o, arena.time)
		for i in 6:
			var tp := arena.orb_position(o, arena.time - i * 0.06)
			draw_circle(tp, float(o["r"]) * (1.0 - i * 0.12), Color(0.75, 0.3, 1.0, 0.10 + 0.04 * (6 - i)))
		draw_circle(pos, float(o["r"]) + 8.0, Color(0.7, 0.2, 1.0, 0.25))
		draw_circle(pos, float(o["r"]), Color("#6a1ab0"))
		draw_circle(pos, float(o["r"]) * 0.6, Color("#d84ad0"))
		draw_circle(pos, float(o["r"]) * 0.28, Color.WHITE)


func _layer_hills(color: Color, base: float, amp: float, scale: float, speed: float) -> void:
	var pts := PackedVector2Array([Vector2(X0, Y1)])
	var x := X0
	while x <= X1:
		var h := amp * (0.55 + 0.45 * sin((x + _t * speed) * scale)) + amp * 0.35 * sin((x + _t * speed) * scale * 2.7 + 1.3)
		pts.append(Vector2(floorf(x / 16.0) * 16.0, base - h))
		x += 32.0
	pts.append(Vector2(X1, Y1))
	draw_colored_polygon(pts, color)


# ---------------------------------------------------------------- per-arena scenery
func _forest() -> void:
	var th := arena.theme
	draw_circle(Vector2(980, 120), 60, Color("#e8f4d0"))
	draw_circle(Vector2(1000, 110), 56, th["sky_a"].lerp(th["sky_b"], 0.15))
	_layer_hills(th["far"], 560.0, 120.0, 0.004, 0.0)
	for layer in 2:
		var col: Color = th["far"].darkened(0.2 * (layer + 1))
		var x := X0 + layer * 55.0
		while x < X1:
			var h := 220.0 + 120.0 * float(_decor[int(x / 64.0 + 40) % 80].x) + layer * 40.0
			var base := 640.0
			draw_rect(Rect2(x, base - h, 26, h), col.darkened(0.2))
			draw_rect(Rect2(x - 60, base - h - 30, 146, 50), col)
			draw_rect(Rect2(x - 34, base - h - 74, 94, 50), col)
			draw_rect(Rect2(x - 8, base - h - 108, 42, 40), col)
			x += 150.0 + layer * 40.0
	for i in 18:
		var d: Vector4 = _decor[i]
		var fx := d.x * 1500.0 - 100.0 + sin(_t * 0.8 + i) * 30.0
		var fy := 250.0 + d.y * 330.0 + cos(_t * 0.6 + i * 2.0) * 20.0
		var a := 0.4 + 0.5 * sin(_t * 2.0 + i)
		draw_rect(Rect2(floorf(fx / 4) * 4, floorf(fy / 4) * 4, 6, 6), Color(0.8, 1.0, 0.4, a))
	draw_rect(Rect2(X0, 560, X1 - X0, 60), Color(0.7, 0.9, 0.8, 0.07))


func _cavern() -> void:
	var th := arena.theme
	_layer_hills(Color("#3a120a"), 640.0, 160.0, 0.006, 0.0)
	_layer_hills(Color("#1c0a08"), 660.0, 110.0, 0.009, 0.0)
	var x := X0
	while x < X1:
		var d: Vector4 = _decor[int((x - X0) / 90.0) % 80]
		var h := 70.0 + d.x * 150.0
		draw_colored_polygon(PackedVector2Array([Vector2(x, Y0), Vector2(x + 70, Y0), Vector2(x + 35, 40 + h)]), Color("#120808"))
		draw_colored_polygon(PackedVector2Array([Vector2(x + 14, Y0), Vector2(x + 56, Y0), Vector2(x + 35, 20 + h)]), Color("#241210"))
		x += 90.0
	var glow := 0.18 + 0.06 * sin(_t * 2.0)
	for i in 5:
		draw_rect(Rect2(X0, 560 + i * 14, X1 - X0, 16), Color(1.0, 0.4, 0.1, glow * (1.0 - i * 0.15)))
	for i in 24:
		var d2: Vector4 = _decor[i]
		var ey := 700.0 - fmod(_t * (20.0 + d2.z * 40.0) + d2.y * 700.0, 700.0)
		draw_rect(Rect2(d2.x * 1500.0 - 100.0 + sin(_t + i) * 14.0, ey, 4, 4), Color(1, 0.55, 0.2, 0.8))


func _citadel() -> void:
	var th := arena.theme
	for i in 40:
		var d: Vector4 = _decor[i]
		draw_rect(Rect2(floorf(d.x * 3000.0 - 900.0), floorf(d.y * 400.0 - 100.0), 4, 4), Color(1, 1, 1, 0.3 + 0.6 * abs(sin(_t + i))))
	_layer_hills(th["far"], 600.0, 150.0, 0.005, 0.0)
	# castle towers
	var x := X0 + 40.0
	while x < X1:
		var d: Vector4 = _decor[int((x - X0) / 120.0) % 80]
		var h := 200.0 + d.x * 180.0
		var w := 70.0 + d.y * 50.0
		draw_rect(Rect2(x, 640 - h, w, h), th["near"].lightened(0.1))
		draw_rect(Rect2(x - 6, 640 - h - 20, w + 12, 20), th["near"].lightened(0.18))
		for k in 3:
			draw_rect(Rect2(x - 6 + k * (w / 2.0), 640 - h - 38, 14, 18), th["near"].lightened(0.18))
		draw_rect(Rect2(x + w * 0.4, 640 - h + 30, 14, 26), Color("#ffe8a0", 0.6 + 0.3 * sin(_t + x)))
		draw_colored_polygon(PackedVector2Array([Vector2(x + w * 0.2, 640 - h - 20), Vector2(x + w * 0.5, 640 - h - 90), Vector2(x + w * 0.8, 640 - h - 20)]), th["near"])
		x += w + 80.0 + d.z * 70.0
	for i in 40:
		var d3: Vector4 = _decor[i]
		var sx := fmod(d3.x * 1800.0 + _t * (20.0 + d3.z * 30.0) - 300.0, 1800.0) - 300.0
		var sy := fmod(d3.y * 900.0 + _t * (50.0 + d3.w * 60.0), 900.0) - 100.0
		draw_rect(Rect2(floorf(sx / 4) * 4, floorf(sy / 4) * 4, 4, 4), Color(1, 1, 1, 0.8))


func _shadow() -> void:
	var th := arena.theme
	for i in 50:
		var d: Vector4 = _decor[i % 80]
		draw_rect(Rect2(floorf(d.x * 3000.0 - 900.0), floorf(d.y * 800.0 - 100.0), 4, 4), Color(0.8, 0.5, 1.0, 0.2 + 0.5 * abs(sin(_t * 1.5 + i))))
	# giant watching eye
	var ec := Vector2(640, 190)
	draw_circle(ec, 120, Color("#1a0a30"))
	draw_circle(ec, 96, Color("#2e1450"))
	var look := Vector2(sin(_t * 0.5) * 22.0, cos(_t * 0.4) * 10.0)
	draw_circle(ec + look, 52, Color("#d84ad0"))
	draw_circle(ec + look, 26, Color("#0a0414"))
	draw_circle(ec + look + Vector2(-10, -10), 8, Color.WHITE)
	# floating islands
	for i in 7:
		var d: Vector4 = _decor[i]
		var ix := d.x * 1700.0 - 250.0
		var iy := 140.0 + d.y * 340.0 + sin(_t * 0.8 + i) * 12.0
		var w := 90.0 + d.z * 120.0
		draw_colored_polygon(PackedVector2Array([Vector2(ix, iy), Vector2(ix + w, iy), Vector2(ix + w * 0.7, iy + 50), Vector2(ix + w * 0.5, iy + 90), Vector2(ix + w * 0.3, iy + 50)]), th["far"])
		draw_rect(Rect2(ix, iy - 6, w, 8), th["top"].darkened(0.4))
	_layer_hills(th["near"], 680.0, 100.0, 0.007, 0.0)
	# rift cracks
	for k in 3:
		var cx := 160.0 + k * 480.0
		var pts := PackedVector2Array()
		for j in 8:
			pts.append(Vector2(cx + sin(j * 1.9 + k) * 26.0, 40.0 + j * 70.0))
		draw_polyline(pts, Color("#d84ad0", 0.35 + 0.2 * sin(_t * 2.0 + k)), 3.0)


func _sanctuary() -> void:
	var th := arena.theme
	for i in 50:
		var d: Vector4 = _decor[i % 80]
		draw_rect(Rect2(floorf(d.x * 3000.0 - 900.0), floorf(d.y * 700.0 - 100.0), 4, 4), Color(1, 0.9, 0.6, 0.2 + 0.5 * abs(sin(_t + i))))
	# the great Rift portal
	var pc := Vector2(640, 250)
	for i in 8:
		var r := 200.0 - i * 20.0
		var col := Color("#b04cff") if i % 2 == 0 else Color("#4a1a90")
		draw_arc(pc, r, _t * (0.4 + i * 0.1), _t * (0.4 + i * 0.1) + TAU * 0.8, 36, Color(col, 0.5 + i * 0.05), 8.0)
	draw_circle(pc, 70, Color("#1a0638"))
	draw_circle(pc, 40, Color("#ffd24a", 0.55 + 0.25 * sin(_t * 3.0)))
	# pillars
	var x := X0 + 30.0
	while x < X1:
		var d: Vector4 = _decor[int((x - X0) / 100.0) % 80]
		draw_rect(Rect2(x, 150, 54, 500), th["far"])
		draw_rect(Rect2(x - 10, 130, 74, 26), th["far"].lightened(0.12))
		draw_rect(Rect2(x - 10, 620, 74, 20), th["far"].lightened(0.12))
		for k in 5:
			draw_rect(Rect2(x + 10 + k * 8, 170, 3, 440), Color(0, 0, 0, 0.18))
		x += 260.0 + d.x * 40.0
	for i in 12:
		var d2: Vector4 = _decor[i]
		var rx := d2.x * 1500.0 - 100.0
		var ry := 120.0 + d2.y * 380.0 + sin(_t + i) * 14.0
		draw_rect(Rect2(floorf(rx / 4) * 4, floorf(ry / 4) * 4, 14, 14), Color("#ffd24a", 0.35))
		draw_rect(Rect2(floorf(rx / 4) * 4 + 4, floorf(ry / 4) * 4 + 4, 6, 6), Color("#ffd24a", 0.7))


func _foreground(id: String) -> void:
	if id == "citadel":
		# icy glaze on the floor
		draw_rect(Rect2(X0, arena.floor_y, X1 - X0, 6), Color(1, 1, 1, 0.35))
		for i in 12:
			var d: Vector4 = _decor[i]
			draw_rect(Rect2(d.x * 1200.0 + 40.0 + fmod(_t * 8.0, 30.0), arena.floor_y + 2, 36, 3), Color(1, 1, 1, 0.5))
	elif id == "forest":
		var x := X0
		while x < X1:
			draw_rect(Rect2(x, arena.floor_y - 8, 4, 8), arena.theme["top"].lightened(0.2))
			draw_rect(Rect2(x + 10, arena.floor_y - 12, 4, 12), arena.theme["top"].lightened(0.1))
			x += 38.0
