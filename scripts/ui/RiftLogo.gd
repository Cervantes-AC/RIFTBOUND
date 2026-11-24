class_name RiftLogo
extends Control
## RIFTBOUND wordmark: layered pixel lettering (rift-violet shadow, dark outline, gold face with a light top half)
## plus an "ARENA CLASH" strap flanked by cracks. Drawn in code, no image asset.

var font_size := 52
var sub_size := 18
var _t := 0.0
var _hi: Control


class HighHalf extends Control:
	var logo: RiftLogo

	func _draw() -> void:
		logo._face(self, Color("#fff2a8"))


func _ready() -> void:
	custom_minimum_size = Vector2(font_size * 9 + 16, font_size + sub_size + 46)
	_hi = HighHalf.new()
	_hi.logo = self
	_hi.clip_contents = true
	_hi.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hi.position = Vector2.ZERO
	_hi.size = Vector2(custom_minimum_size.x, font_size * 0.62 + 6.0)
	add_child(_hi)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if _hi:
		_hi.queue_redraw()


func _face(ci: CanvasItem, col: Color) -> void:
	ci.draw_string(PixelUI.FONT, Vector2(6, font_size + 6), "RIFTBOUND", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, col)


func _draw() -> void:
	var f := PixelUI.FONT
	var base := Vector2(6, font_size + 6)
	var pulse := 0.5 + 0.5 * sin(_t * 1.6)
	# violet rift glow behind the letters
	for i in 3:
		draw_string_outline(f, base + Vector2(0, 8), "RIFTBOUND", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 22 - i * 6, Color(0.7, 0.3, 1.0, (0.10 + 0.05 * pulse) * (i + 1)))
	draw_string_outline(f, base + Vector2(0, 8), "RIFTBOUND", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 12, Color("#2a0f55"))
	draw_string(f, base + Vector2(0, 8), "RIFTBOUND", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color("#8a2fd0"))
	draw_string_outline(f, base, "RIFTBOUND", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 10, Color("#08050f"))
	draw_string(f, base, "RIFTBOUND", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color("#ffb52a"))
	# a rift tear running through the word
	var w := custom_minimum_size.x
	var cx := fmod(_t * 90.0, w + 200.0) - 100.0
	draw_rect(Rect2(cx, 4, 14, font_size + 4), Color(1, 1, 1, 0.10))
	# strap
	var y := font_size + 30.0
	var txt := "ARENA CLASH"
	var tw := f.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, sub_size).x
	var sx := (w - tw) * 0.5
	draw_string_outline(f, Vector2(sx, y + sub_size), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, sub_size, 8, Color("#08050f"))
	draw_string(f, Vector2(sx, y + sub_size), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, sub_size, Color("#d58aff"))
	for side in [-1.0, 1.0]:
		var x0 := sx - 14.0 if side < 0.0 else sx + tw + 14.0
		for k in 4:
			var xx: float = x0 + side * k * 22.0
			draw_rect(Rect2(xx - (16.0 if side < 0.0 else 0.0), y + sub_size * 0.5 + (k % 2) * 4.0, 16, 4), Color(0.75, 0.35, 1.0, 0.8 - k * 0.2))
