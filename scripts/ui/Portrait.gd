class_name Portrait
extends RefCounted
## Draws a class's head-and-shoulders portrait (original pixel art, drawn in code) into any CanvasItem.
## Used by the battle HUD, class cards and the result screen.

const OUT := Color("#08050f")
const SKIN := Color("#f0c8a0")


static func draw(ci: CanvasItem, d: ClassData, r: Rect2, dim := false) -> void:
	var k := r.size.x / 52.0
	ci.draw_rect(r.grow(3.0), OUT)
	ci.draw_rect(r, d.color.darkened(0.6))
	ci.draw_rect(Rect2(r.position.x, r.end.y - 6.0 * k, r.size.x, 6.0 * k), d.color.darkened(0.3))
	var cx := r.position.x + r.size.x * 0.5
	var by := r.end.y
	ci.draw_rect(Rect2(cx - 21.0 * k, by - 12.0 * k, 42.0 * k, 12.0 * k), OUT)
	ci.draw_rect(Rect2(cx - 19.0 * k, by - 11.0 * k, 38.0 * k, 11.0 * k), d.color)
	ci.draw_rect(Rect2(cx - 19.0 * k, by - 4.0 * k, 38.0 * k, 3.0 * k), d.accent)
	var face := Rect2(cx - 12.0 * k, by - 40.0 * k, 24.0 * k, 28.0 * k)
	ci.draw_rect(face.grow(2.0 * k), OUT)
	ci.draw_rect(face, SKIN)
	ci.draw_rect(Rect2(cx + 2.0 * k, by - 29.0 * k, 6.0 * k, 5.0 * k), Color.WHITE)
	ci.draw_rect(Rect2(cx + 5.0 * k, by - 28.0 * k, 3.0 * k, 3.0 * k), OUT)
	match d.id:
		"vanguard":
			ci.draw_rect(Rect2(cx - 14.0 * k, by - 48.0 * k, 28.0 * k, 22.0 * k), OUT)
			ci.draw_rect(Rect2(cx - 12.0 * k, by - 46.0 * k, 24.0 * k, 18.0 * k), d.accent)
			ci.draw_rect(Rect2(cx - 2.0 * k, by - 30.0 * k, 14.0 * k, 5.0 * k), OUT)   # visor slit
			ci.draw_rect(Rect2(cx - 3.0 * k, by - 56.0 * k, 6.0 * k, 10.0 * k), d.color)  # crest
		"duelist":
			ci.draw_rect(Rect2(cx - 13.0 * k, by - 46.0 * k, 26.0 * k, 10.0 * k), d.hair)
			ci.draw_rect(Rect2(cx - 15.0 * k, by - 40.0 * k, 6.0 * k, 16.0 * k), d.hair)
			ci.draw_rect(Rect2(cx - 17.0 * k, by - 54.0 * k, 4.0 * k, 16.0 * k), d.accent)   # feather
		"ranger":
			ci.draw_rect(Rect2(cx - 15.0 * k, by - 50.0 * k, 30.0 * k, 24.0 * k), OUT)
			ci.draw_rect(Rect2(cx - 13.0 * k, by - 48.0 * k, 26.0 * k, 22.0 * k), d.color.darkened(0.1))
			ci.draw_rect(Rect2(cx - 4.0 * k, by - 38.0 * k, 16.0 * k, 14.0 * k), SKIN)
			ci.draw_rect(Rect2(cx + 2.0 * k, by - 32.0 * k, 6.0 * k, 5.0 * k), Color.WHITE)
			ci.draw_rect(Rect2(cx + 5.0 * k, by - 31.0 * k, 3.0 * k, 3.0 * k), OUT)
		"gunslinger":
			ci.draw_rect(Rect2(cx - 20.0 * k, by - 46.0 * k, 40.0 * k, 6.0 * k), OUT)
			ci.draw_rect(Rect2(cx - 18.0 * k, by - 45.0 * k, 36.0 * k, 4.0 * k), d.accent)   # brim
			ci.draw_rect(Rect2(cx - 10.0 * k, by - 58.0 * k, 20.0 * k, 14.0 * k), d.accent)  # crown
			ci.draw_rect(Rect2(cx - 10.0 * k, by - 48.0 * k, 20.0 * k, 3.0 * k), d.color)
		"arcanist":
			ci.draw_rect(Rect2(cx - 16.0 * k, by - 46.0 * k, 32.0 * k, 7.0 * k), d.color.darkened(0.15))
			ci.draw_rect(Rect2(cx - 10.0 * k, by - 62.0 * k, 20.0 * k, 17.0 * k), d.color)
			ci.draw_rect(Rect2(cx - 5.0 * k, by - 72.0 * k, 10.0 * k, 12.0 * k), d.color.lightened(0.1))
			ci.draw_rect(Rect2(cx - 10.0 * k, by - 50.0 * k, 20.0 * k, 3.0 * k), d.accent)
		"riftblade":
			ci.draw_rect(Rect2(cx - 13.0 * k, by - 46.0 * k, 26.0 * k, 9.0 * k), d.hair)
			ci.draw_rect(Rect2(cx - 12.0 * k, by - 23.0 * k, 24.0 * k, 11.0 * k), d.color.darkened(0.35))
			ci.draw_rect(Rect2(cx - 1.0 * k, by - 31.0 * k, 14.0 * k, 5.0 * k), d.accent)
		"warden":
			ci.draw_rect(Rect2(cx - 14.0 * k, by - 50.0 * k, 28.0 * k, 16.0 * k), d.color)
			ci.draw_rect(Rect2(cx - 19.0 * k, by - 56.0 * k, 9.0 * k, 12.0 * k), d.accent)
			ci.draw_rect(Rect2(cx + 10.0 * k, by - 56.0 * k, 9.0 * k, 12.0 * k), d.accent)
		"stormcaller":
			ci.draw_rect(Rect2(cx - 12.0 * k, by - 44.0 * k, 24.0 * k, 9.0 * k), d.hair)
			for spike in 4:
				ci.draw_rect(Rect2(cx + (-12.0 + spike * 7.0) * k, by - (56.0 - (spike % 2) * 5.0) * k, 4.0 * k, 14.0 * k), d.hair)
			ci.draw_rect(Rect2(cx - 12.0 * k, by - 37.0 * k, 24.0 * k, 3.0 * k), d.color)
		"reaper":
			ci.draw_rect(Rect2(cx - 15.0 * k, by - 50.0 * k, 30.0 * k, 32.0 * k), d.color.darkened(0.35))
			ci.draw_rect(Rect2(cx - 6.0 * k, by - 40.0 * k, 17.0 * k, 24.0 * k), Color("#e8e0d0"))
			ci.draw_rect(Rect2(cx + 1.0 * k, by - 33.0 * k, 6.0 * k, 6.0 * k), d.color)
		"chronomancer":
			ci.draw_rect(Rect2(cx - 13.0 * k, by - 45.0 * k, 26.0 * k, 8.0 * k), d.hair)
			ci.draw_rect(Rect2(cx - 9.0 * k, by - 57.0 * k, 18.0 * k, 13.0 * k), d.color)
			ci.draw_arc(Vector2(cx + 5.0 * k, by - 27.0 * k), 6.0 * k, 0.0, TAU, 12, d.accent, 2.0 * k)
		"beastbound":
			ci.draw_rect(Rect2(cx - 13.0 * k, by - 46.0 * k, 26.0 * k, 11.0 * k), d.hair)
			ci.draw_colored_polygon(PackedVector2Array([Vector2(cx - 13.0 * k, by - 45.0 * k), Vector2(cx - 9.0 * k, by - 58.0 * k), Vector2(cx - 2.0 * k, by - 45.0 * k)]), Color("#5a4630"))
			ci.draw_colored_polygon(PackedVector2Array([Vector2(cx + 2.0 * k, by - 45.0 * k), Vector2(cx + 9.0 * k, by - 58.0 * k), Vector2(cx + 13.0 * k, by - 45.0 * k)]), Color("#5a4630"))
			ci.draw_rect(Rect2(cx - 2.0 * k, by - 21.0 * k, 14.0 * k, 3.0 * k), d.color.darkened(0.3))
		"shadeweaver":
			ci.draw_rect(Rect2(cx - 15.0 * k, by - 50.0 * k, 30.0 * k, 28.0 * k), OUT)
			ci.draw_rect(Rect2(cx - 13.0 * k, by - 48.0 * k, 26.0 * k, 26.0 * k), d.color.darkened(0.2))
			ci.draw_rect(Rect2(cx - 4.0 * k, by - 38.0 * k, 16.0 * k, 16.0 * k), Color("#0a0610"))
			ci.draw_rect(Rect2(cx + 2.0 * k, by - 32.0 * k, 5.0 * k, 5.0 * k), d.accent)   # glowing eye
	if dim:
		ci.draw_rect(r, Color(0, 0, 0, 0.6))
