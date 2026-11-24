class_name MechOverlay
extends Node2D
## Unflipped overlay drawn over a fighter: class-mechanic feedback (Bulwark aura, Momentum trail,
## Focus lens, ammo flash, element ring, Shadow echo) and status markers (Hunter's Mark, Dead Eye).
## Purely visual; reads Fighter.mech, which guests receive through the snapshot.

var fighter: Fighter


func _ready() -> void:
	z_index = 4


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var f := fighter
	if f == null or f.is_dead() or f.mech == null:
		return
	var t := f.anim_time
	var s := f.data.body_scale
	var c := Vector2(0, -42.0 * s)
	var m := f.mech
	match f.data.id:
		"vanguard":
			if m.res >= 30.0:   # Bulwark glow grows with the meter
				var k := m.fraction()
				draw_arc(c, 40.0 * s, 0.0, TAU, 28, Color(0.45, 0.75, 1.0, 0.15 + 0.5 * k), 2.0 + 4.0 * k)
				if m.res >= 50.0:
					draw_arc(c, 46.0 * s, t * 2.0, t * 2.0 + 1.6, 12, Color(1.0, 0.85, 0.4, 0.8), 3.0)
		"duelist":
			var st := int(round(m.res / 20.0))
			for i in st:   # momentum pips orbiting the head
				var a := t * 4.0 + i * TAU / 5.0
				draw_rect(Rect2(cos(a) * 26.0 - 3, -86.0 * s + sin(a) * 6.0 - 3, 6, 6), Color("#f2d27a"))
		"ranger":
			if m.res >= 100.0:   # Steady Aim lens + aim line
				draw_arc(c + Vector2(f.facing * 30.0, -8.0), 9.0, 0.0, TAU, 12, Color(0.6, 1.0, 0.6, 0.9), 2.0)
				draw_line(c + Vector2(f.facing * 40.0, -8.0), c + Vector2(f.facing * 360.0, -8.0), Color(0.6, 1.0, 0.6, 0.18), 2.0)
			elif m.res > 10.0:
				draw_arc(c + Vector2(f.facing * 30.0, -8.0), 9.0, -PI / 2.0, -PI / 2.0 + TAU * m.fraction(), 12, Color(0.6, 1.0, 0.6, 0.6), 2.0)
		"arcanist":
			var ec: Color = ArcanistMech.COLORS[int(m.aux) % 3]
			draw_arc(c, 34.0 * s, t * 3.0, t * 3.0 + 2.4, 14, Color(ec, 0.85), 3.0)
			draw_arc(c, 34.0 * s, t * 3.0 + PI, t * 3.0 + PI + 2.4, 14, Color(ec, 0.85), 3.0)
		"gunslinger":
			if m.aux > 0.0:   # reloading: spinning cylinder over the head
				draw_arc(Vector2(0, -92.0 * s), 12.0, t * 10.0, t * 10.0 + 4.0, 10, Color("#ffd66b"), 3.0)
		"shadeweaver":
			if m.extra > -9000.0:   # the echo: dark silhouette where you were
				var ex: float = m.extra - f.global_position.x
				var a2 := 0.35 + 0.2 * sin(t * 8.0)
				draw_rect(Rect2(ex - 10, -60, 20, 60), Color(0.3, 0.05, 0.4, a2))
				draw_rect(Rect2(ex - 10, -82, 20, 22), Color(0.6, 0.2, 0.7, a2))
				draw_arc(Vector2(ex, -40), 36.0, 0.0, TAU, 20, Color(0.85, 0.3, 0.8, a2 + 0.2), 2.0)
	if f.has_status("deadeye"):
		draw_arc(c, 36.0 * s, 0.0, TAU, 20, Color(1.0, 0.3, 0.2, 0.55 + 0.3 * sin(t * 14.0)), 3.0)
	if f.has_status("mark"):   # Hunter's Mark: reticle above the head
		var mp := Vector2(0, -104.0 * s + sin(t * 6.0) * 3.0)
		draw_arc(mp, 11.0, 0.0, TAU, 14, Color("#ffd24a"), 3.0)
		draw_line(mp + Vector2(-16, 0), mp + Vector2(-6, 0), Color("#ffd24a"), 3.0)
		draw_line(mp + Vector2(6, 0), mp + Vector2(16, 0), Color("#ffd24a"), 3.0)
	if f.has_status("scorch"):
		draw_circle(c + Vector2(0, -10), 8.0, Color(1.0, 0.45, 0.1, 0.6))
	if f.counter_t > 0.0:   # counter window glint
		draw_arc(c, 30.0 * s, 0.0, TAU, 16, Color(1.0, 0.9, 0.4, 0.4 + 0.4 * sin(t * 20.0)), 3.0)
