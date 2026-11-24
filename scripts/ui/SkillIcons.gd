class_name SkillIcons
extends RefCounted
## Tiny procedural pixel-style glyphs for skills (placeholder icon set, no image files needed).


static func draw(ci: CanvasItem, icon: String, c: Vector2, r: float, col: Color) -> void:
	var k := r * 0.55
	var dark := Color("#08050f")
	match icon:
		"sword", "slash", "scythe":
			ci.draw_line(c + Vector2(-k, k), c + Vector2(k, -k), dark, r * 0.32)
			ci.draw_line(c + Vector2(-k, k), c + Vector2(k, -k), col, r * 0.2)
			ci.draw_line(c + Vector2(-k * 0.5, -k * 0.1), c + Vector2(k * 0.1, k * 0.5), col.darkened(0.2), r * 0.14)
			if icon == "slash":
				ci.draw_line(c + Vector2(-k, k * 0.2), c + Vector2(k * 0.6, -k * 1.0), Color(col, 0.6), r * 0.1)
		"rush", "dash", "roll", "phantom", "blink":
			for i in 2:
				var o := (i - 0.5) * k * 0.9
				ci.draw_polyline(PackedVector2Array([c + Vector2(o - k * 0.3, -k * 0.8), c + Vector2(o + k * 0.5, 0), c + Vector2(o - k * 0.3, k * 0.8)]), col, r * 0.22)
		"slam":
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-k, k), c + Vector2(-k * 0.5, -k * 0.2), c + Vector2(0, k), c + Vector2(k * 0.4, -k), c + Vector2(k, k)]), col)
		"shield":
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-k * 0.9, -k), c + Vector2(k * 0.9, -k), c + Vector2(k * 0.9, k * 0.2), c + Vector2(0, k * 1.1), c + Vector2(-k * 0.9, k * 0.2)]), col)
			ci.draw_rect(Rect2(c.x - k * 0.15, c.y - k * 0.7, k * 0.3, k * 1.3), col.darkened(0.45))
		"spin":
			ci.draw_arc(c, k, 0.3, 3.0, 12, col, r * 0.2)
			ci.draw_arc(c, k, 3.5, 6.1, 12, col, r * 0.2)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(k, -k * 0.3), c + Vector2(k * 1.4, k * 0.3), c + Vector2(k * 0.6, k * 0.4)]), col)
		"arrow", "pierce", "bullet", "burst":
			var n := 3 if icon == "burst" else 1
			for i in n:
				var y := (i - (n - 1) * 0.5) * k * 0.6
				ci.draw_line(c + Vector2(-k, y), c + Vector2(k * 0.6, y), col, r * 0.14)
				ci.draw_colored_polygon(PackedVector2Array([c + Vector2(k * 0.5, y - k * 0.28), c + Vector2(k * 1.1, y), c + Vector2(k * 0.5, y + k * 0.28)]), col)
		"rain":
			for i in 3:
				var x := (i - 1) * k * 0.7
				ci.draw_line(c + Vector2(x - k * 0.3, -k), c + Vector2(x + k * 0.2, k), col, r * 0.13)
		"bomb", "orb", "dark", "bolt", "meteor":
			ci.draw_circle(c, k * 0.9, dark)
			ci.draw_circle(c, k * 0.75, col)
			ci.draw_circle(c + Vector2(-k * 0.2, -k * 0.2), k * 0.25, Color(1, 1, 1, 0.8))
			if icon == "meteor":
				ci.draw_line(c + Vector2(-k * 1.2, -k * 1.2), c + Vector2(-k * 0.5, -k * 0.5), col, r * 0.18)
			if icon == "bolt":
				ci.draw_line(c + Vector2(-k * 1.2, 0), c + Vector2(-k * 0.6, 0), col, r * 0.15)
		"frost":
			for i in 3:
				var a := i * PI / 3.0
				ci.draw_line(c + Vector2(cos(a), sin(a)) * k, c - Vector2(cos(a), sin(a)) * k, col, r * 0.13)
		"chain":
			ci.draw_arc(c + Vector2(-k * 0.4, 0), k * 0.5, 0, TAU, 10, col, r * 0.14)
			ci.draw_arc(c + Vector2(k * 0.4, 0), k * 0.5, 0, TAU, 10, col, r * 0.14)
		"jump":
			ci.draw_polyline(PackedVector2Array([c + Vector2(-k, k * 0.2), c + Vector2(0, -k * 0.8), c + Vector2(k, k * 0.2)]), col, r * 0.22)
			ci.draw_line(c + Vector2(0, -k * 0.6), c + Vector2(0, k * 0.9), col, r * 0.2)
		"dodge":
			ci.draw_arc(c, k, 0.5, 5.6, 14, col, r * 0.2)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(k * 0.5, -k * 1.2), c + Vector2(k * 1.2, -k * 0.5), c + Vector2(k * 0.1, -k * 0.3)]), col)
		_:
			ci.draw_circle(c, k * 0.6, col)
