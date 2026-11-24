class_name MenuBackdrop
extends Control
## Animated dark-fantasy backdrop shared by all menu screens (procedural pixel art, no image assets).

var _t := 0.0
var _stars: Array[Vector3] = []


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rng := RandomNumberGenerator.new()
	rng.seed = 1337
	for i in 90:
		_stars.append(Vector3(rng.randf(), rng.randf() * 0.75, rng.randf() * 6.28))


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var sz := size
	# banded night sky
	var bands := 18
	for i in bands:
		var f := float(i) / bands
		var c := Color("#0b0820").lerp(Color("#3a1a5e"), f * f)
		draw_rect(Rect2(0, sz.y * f, sz.x, sz.y / bands + 1), c)
	# stars
	for s in _stars:
		var tw := 0.5 + 0.5 * sin(_t * 2.0 + s.z)
		draw_rect(Rect2(floor(s.x * sz.x / 4) * 4, floor(s.y * sz.y / 4) * 4, 4, 4), Color(1, 1, 1, 0.25 + 0.6 * tw))
	# the Rift: a glowing jagged crack
	var cx := sz.x * 0.5
	var pulse := 0.5 + 0.5 * sin(_t * 1.3)
	for layer in 4:
		var w := (22.0 - layer * 5.0) * (0.8 + 0.3 * pulse)
		var col := Color(0.7, 0.3, 1.0, 0.10 + layer * 0.12)
		var pts := PackedVector2Array()
		var y := 0.0
		var step := 36.0
		var left: Array[Vector2] = []
		var right: Array[Vector2] = []
		while y <= sz.y + step:
			var jx := sin(y * 0.021 + 1.7) * 38.0 + sin(y * 0.057) * 14.0
			left.append(Vector2(cx + jx - w, y))
			right.append(Vector2(cx + jx + w, y))
			y += step
		for p in left:
			pts.append(p)
		right.reverse()
		for p in right:
			pts.append(p)
		draw_colored_polygon(pts, col)
	# distant mountain silhouettes
	for layer in 2:
		var base := sz.y * (0.80 + layer * 0.08)
		var col2 := Color("#120a22") if layer == 0 else Color("#07040f")
		var pts2 := PackedVector2Array([Vector2(0, sz.y)])
		var x := 0.0
		while x <= sz.x + 48:
			var h := 40.0 + 36.0 * absf(sin(x * 0.011 + layer * 2.3)) + 18.0 * sin(x * 0.043)
			pts2.append(Vector2(floor(x / 8) * 8, base - h))
			x += 48.0
		pts2.append(Vector2(sz.x, sz.y))
		draw_colored_polygon(pts2, col2)
	# drifting embers
	for i in 22:
		var ph := fmod(_t * (14.0 + i * 1.7) + i * 97.0, sz.y + 40.0)
		var ex := fmod(i * 173.0, sz.x) + sin(_t + i) * 20.0
		draw_rect(Rect2(floor(ex / 4) * 4, sz.y - ph, 4, 4), Color(1.0, 0.6, 1.0, 0.5))
