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


## Vertical distance from the fighter's feet down to the arena floor (zones and the wolf live on the floor).
func _ground_offset() -> float:
	var w = fighter.world
	return w.arena.floor_y - fighter.global_position.y if (w != null and w.arena != null) else 0.0


## Beastbound's companion: a small pixel wolf, facing away from its owner's side of travel.
func _draw_wolf(at: Vector2, frenzy: bool, t: float) -> void:
	var enemy = fighter.world.nearest_enemy(fighter) if fighter.world else null
	var dir := float(fighter.facing)
	if enemy != null:
		dir = 1.0 if enemy.global_position.x >= fighter.global_position.x + at.x else -1.0
	var fur := Color("#b0603a") if frenzy else Color("#8a7a66")
	var dark := Color("#120a1c")
	draw_set_transform(at, 0.0, Vector2(dir, 1.0))
	if frenzy:
		draw_circle(Vector2(0, -18), 34.0, Color(1.0, 0.45, 0.15, 0.2))
	for i in 4:   # legs
		var lx := -18.0 + i * 11.0
		var step := sin(t * 18.0 + i * 1.7) * 3.0
		draw_rect(Rect2(lx - 2 + step, -14, 8, 14), dark)
		draw_rect(Rect2(lx + step, -14, 4, 12), fur.darkened(0.2))
	draw_rect(Rect2(-25, -31, 44, 21), dark)   # body
	draw_rect(Rect2(-22, -28, 38, 15), fur)
	draw_rect(Rect2(10, -43, 24, 22), dark)    # head
	draw_rect(Rect2(13, -40, 18, 16), fur.lightened(0.1))
	draw_rect(Rect2(28, -33, 12, 9), dark)     # snout
	draw_rect(Rect2(28, -31, 9, 5), fur.lightened(0.2))
	draw_rect(Rect2(14, -51, 6, 11), dark)     # ears
	draw_rect(Rect2(23, -50, 6, 10), dark)
	draw_rect(Rect2(24, -37, 4, 4), Color("#ffd24a"))
	draw_line(Vector2(-23, -26), Vector2(-37, -36 + sin(t * 8.0) * 4.0), dark, 9.0)
	draw_line(Vector2(-23, -26), Vector2(-36, -35 + sin(t * 8.0) * 4.0), fur, 5.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


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
	match f.data.id:
		"riftblade":
			if m.res >= 40.0:   # Rift Step ready: torn space at the feet
				for i in 2:
					draw_arc(Vector2(0, -4), 26.0 + i * 8.0, t * (3.0 - i * 5.0), t * (3.0 - i * 5.0) + 2.2, 12, Color(0.3, 1.0, 0.9, 0.7), 2.0)
		"warden":
			var w := m as WardenMech
			if w.vis_active():   # the ward: floor line, translucent dome and turning glyphs
				var wc := Vector2(w.vis_x() - f.global_position.x, _ground_offset())
				var rr := w.vis_radius()
				draw_arc(wc, rr, PI, TAU, 40, Color(1.0, 0.88, 0.45, 0.65), 4.0)
				draw_circle(wc, rr * 0.06, Color(1.0, 0.9, 0.5, 0.6))
				draw_line(wc + Vector2(-rr, 0), wc + Vector2(rr, 0), Color(1.0, 0.85, 0.35, 0.8), 5.0)
				for i in 6:
					var ang := PI + fmod(t * 0.5 + i * PI / 6.0, PI)
					draw_rect(Rect2(wc + Vector2(cos(ang), sin(ang)) * rr - Vector2(5, 5), Vector2(10, 10)), Color(1.0, 0.95, 0.7, 0.7))
		"stormcaller":
			for i in int(m.res / 25.0):   # crackling arcs, one per 25 Charge
				var ang2 := floorf(t * 14.0) * 2.3 + i * 1.7
				var p0 := c + Vector2(cos(ang2), sin(ang2)) * 22.0
				var p1 := c + Vector2(cos(ang2 + 0.5), sin(ang2 + 0.5)) * 34.0
				var p2 := c + Vector2(cos(ang2 + 0.2), sin(ang2 + 0.2)) * 46.0
				draw_polyline(PackedVector2Array([p0, p1, p2]), Color(1.0, 0.95, 0.4, 0.85), 2.0)
		"reaper":
			for i in int(m.res / 20.0):   # orbiting souls
				var ang3 := -t * 2.5 + i * TAU / 5.0
				var sp := c + Vector2(cos(ang3) * 36.0, sin(ang3) * 12.0)
				draw_circle(sp, 6.0, Color(1.0, 0.35, 0.45, 0.35))
				draw_circle(sp, 3.0, Color(1.0, 0.8, 0.85, 0.95))
		"chronomancer":
			if m.aux > 0.0 and m.extra > -9000.0:   # Temporal Bubble with clock ticks
				var bc := Vector2(m.extra - f.global_position.x, _ground_offset() - 60.0)
				var br := ChronomancerMech.RADIUS
				draw_circle(bc, br, Color(0.6, 1.0, 0.9, 0.08))
				draw_arc(bc, br, 0.0, TAU, 48, Color(0.65, 1.0, 0.9, 0.7), 3.0)
				for i in 12:
					var d12 := Vector2(cos(i * TAU / 12.0), sin(i * TAU / 12.0))
					draw_line(bc + d12 * (br - 14.0), bc + d12 * (br - 4.0), Color(1.0, 0.95, 0.65, 0.8), 3.0)
				draw_line(bc, bc + Vector2(cos(t * 0.8), sin(t * 0.8)) * br * 0.6, Color(1.0, 0.95, 0.65, 0.4), 3.0)
		"beastbound":
			if m.res > 0.0 and m.extra > -9000.0:
				_draw_wolf(Vector2(m.extra - f.global_position.x, _ground_offset()), m.aux > 0.0, t)
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
