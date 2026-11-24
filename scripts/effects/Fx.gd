class_name Fx
extends Node2D
## One lightweight node type for all combat visual effects (drawn procedurally) + particle helpers.

var kind := ""
var data: Dictionary = {}
var age := 0.0
var life := 0.25


static func spawn(parent: Node, fx_kind: String, pos: Vector2, fx_data: Dictionary = {}) -> void:
	match fx_kind:
		"dust":
			_particles(parent, pos, Color(0.8, 0.8, 0.85, 0.8), int(fx_data.get("count", 4)), 0.35, 60.0, 140.0, Vector2(0, -1), 40.0, 3.0)
		"burst":
			_particles(parent, pos, fx_data.get("color", Color.WHITE), int(fx_data.get("count", 10)), 0.5, 80.0, 260.0, Vector2.ZERO, 180.0, 4.0)
		"damage":
			_damage_number(parent, pos, fx_data)
		"text":
			_text(parent, pos, str(fx_data.get("text", "")), fx_data.get("color", Color.WHITE), int(fx_data.get("size", 22)))
		_:
			var fx := Fx.new()
			fx.kind = fx_kind
			fx.data = fx_data
			fx.position = pos
			fx.z_index = 20
			match fx_kind:
				"slash":
					fx.life = 0.2
				"ring":
					fx.life = 0.4
				"shockwave":
					fx.life = 0.45
				"trail":
					fx.life = 0.25
				"muzzle":
					fx.life = 0.14
				"spin":
					fx.life = float(fx_data.get("dur", 0.5))
				"hit":
					fx.life = 0.24
					var hdir := Vector2(float(fx_data.get("dir", 0.0)), -0.25)
					var hc: Color = fx_data.get("color", Color.WHITE)
					var heavy_hit := bool(fx_data.get("heavy", false))
					var has_dir := hdir.x != 0.0
					_particles(parent, pos, hc, 9 if heavy_hit else 6, 0.4, 140.0, 360.0, hdir if has_dir else Vector2.UP, 70.0 if has_dir else 180.0, 4.0)
					_particles(parent, pos, Color.WHITE, 4, 0.22, 200.0, 420.0, hdir if has_dir else Vector2.UP, 40.0, 3.0)
				"ghost":
					fx.life = 0.28
				"warn":
					fx.life = float(fx_data.get("dur", 0.4))
				"ult":
					fx.life = 0.7
				"bolt_line":
					fx.life = 0.22
				"casing":
					fx.life = 0.4
				"rune":
					fx.life = 0.55
				_:
					fx.life = 0.2
			parent.add_child(fx)


static func _particles(parent: Node, pos: Vector2, color: Color, count: int, lifetime: float, vmin: float, vmax: float, dir: Vector2, spread: float, size: float) -> void:
	var p := CPUParticles2D.new()
	p.position = pos
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = maxi(count, 1)
	p.lifetime = lifetime
	p.direction = dir if dir != Vector2.ZERO else Vector2.UP
	p.spread = spread
	p.initial_velocity_min = vmin
	p.initial_velocity_max = vmax
	p.gravity = Vector2(0, 500)
	p.scale_amount_min = size
	p.scale_amount_max = size * 1.6
	var g := Gradient.new()
	g.set_color(0, color)
	g.set_color(1, Color(color, 0.0))
	p.color_ramp = g
	p.z_index = 15
	parent.add_child(p)
	var timer := p.get_tree().create_timer(lifetime + 0.1)
	timer.timeout.connect(p.queue_free)


static func _damage_number(parent: Node, pos: Vector2, d: Dictionary) -> void:
	var amount := int(round(float(d.get("amount", 0))))
	if amount <= 0:
		return
	var heavy := amount >= 15
	_text(parent, pos + Vector2(randf_range(-14, 14), 0), str(amount), Color("#ffe066") if heavy else Color.WHITE, 30 if heavy else 22)


static func _text(parent: Node, pos: Vector2, text: String, color: Color, size: int) -> void:
	var l := PixelUI.label(text, size, color, HORIZONTAL_ALIGNMENT_CENTER)
	l.z_index = 30
	l.position = pos - Vector2(80, 0)
	l.custom_minimum_size = Vector2(160, 0)
	l.size = Vector2(160, 30)
	parent.add_child(l)
	var tw := l.create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "position:y", pos.y - 60.0, 0.7).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.7).set_delay(0.25)
	tw.chain().tween_callback(l.queue_free)


func _process(delta: float) -> void:
	age += delta
	if age >= life:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var f := clampf(age / life, 0.0, 1.0)
	var c: Color = data.get("color", Color.WHITE)
	match kind:
		"slash":
			var dir := float(data.get("dir", 1))
			var w := float(data.get("w", 80.0))
			var a0 := -1.2 + f * 0.8
			var pts := PackedVector2Array()
			for i in 9:
				var a := a0 + i * 0.22
				pts.append(Vector2(cos(a) * w * 0.8 * dir - dir * 20.0, sin(a) * w * 0.75))
			draw_polyline(pts, Color(c, 0.35 * (1.0 - f)), 22.0 * (1.0 - f) + 4.0)
			draw_polyline(pts, Color(c, 1.0 - f), 9.0 * (1.0 - f) + 2.0)
			draw_polyline(pts, Color(1, 1, 1, 0.8 * (1.0 - f)), 3.0)
			draw_circle(pts[pts.size() - 1], 6.0 * (1.0 - f), Color(1, 1, 1, 0.9))
		"ring":
			var r := float(data.get("radius", 100.0)) * (0.25 + 0.75 * f)
			draw_arc(Vector2.ZERO, r, 0.0, TAU, 40, Color(c, 1.0 - f), 8.0 * (1.0 - f) + 2.0)
			draw_circle(Vector2.ZERO, r, Color(c, 0.12 * (1.0 - f)))
		"shockwave":
			var r2 := float(data.get("radius", 120.0)) * f
			draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.3))
			draw_arc(Vector2.ZERO, r2, 0.0, TAU, 32, Color(c, 1.0 - f), 8.0)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			for k in 6:   # ground cracks radiating out
				var sgn := -1.0 if k % 2 == 0 else 1.0
				var cx := sgn * r2 * (0.25 + 0.12 * (k / 2))
				draw_line(Vector2(cx, 0), Vector2(cx + sgn * 26.0, 8.0 + 4.0 * (k / 2)), Color(c, 1.0 - f), 4.0)
		"trail":
			var dir2 := float(data.get("dir", 1))
			for i in 5:
				var y := -70.0 + i * 16.0
				draw_rect(Rect2(-dir2 * (30.0 + f * 70.0) - 40.0 + (40.0 if dir2 > 0.0 else 0.0), y, 70.0 * (1.0 - f), 4), Color(c, 0.7 * (1.0 - f)))
		"muzzle":
			var dir3 := float(data.get("dir", 1))
			draw_rect(Rect2(0, -6, dir3 * 26.0 * (1.0 - f), 12), Color(c, 1.0 - f))
			draw_circle(Vector2.ZERO, 12.0 * (1.0 - f), Color.WHITE)
			var ms := 18.0 * (1.0 - f)
			draw_line(Vector2(-ms * 0.5, -ms), Vector2(dir3 * ms * 1.5, 0), Color(c, 0.9 * (1.0 - f)), 3.0)
			draw_line(Vector2(-ms * 0.5, ms), Vector2(dir3 * ms * 1.5, 0), Color(c, 0.9 * (1.0 - f)), 3.0)
		"spin":
			var r3 := float(data.get("radius", 100.0))
			var rot := f * TAU * 3.0
			draw_arc(Vector2.ZERO, r3, rot, rot + 2.4, 16, Color(c, 0.9 * (1.0 - f * 0.5)), 8.0)
			draw_arc(Vector2.ZERO, r3, rot + PI, rot + PI + 2.4, 16, Color(c, 0.9 * (1.0 - f * 0.5)), 8.0)
		"hit":
			var s := 26.0 * (1.0 - f)
			var cls := str(data.get("cls", ""))
			var big := 1.35 if bool(data.get("heavy", false)) else 1.0
			s *= big
			draw_circle(Vector2.ZERO, 22.0 * (1.0 - f) * big, Color(1, 1, 1, 0.55 * (1.0 - f)))
			match cls:
				"vanguard":   # blunt impact ring + cracks
					draw_arc(Vector2.ZERO, 14.0 + 34.0 * f * big, 0.0, TAU, 20, Color(c, 1.0 - f), 6.0)
					for k in 5:
						var ang := k * TAU / 5.0 + 0.4
						draw_line(Vector2(cos(ang), sin(ang)) * 10.0, Vector2(cos(ang), sin(ang)) * (22.0 + 26.0 * f) * big, Color.WHITE, 4.0)
				"duelist":    # thin crossing slashes
					draw_line(Vector2(-s * 1.6, -s * 0.8), Vector2(s * 1.6, s * 0.8), Color.WHITE, 3.0)
					draw_line(Vector2(-s * 1.6, s * 0.2), Vector2(s * 1.6, -s * 1.0), c, 3.0)
				"ranger":     # precise vertical pierce
					draw_line(Vector2(0, -s * 1.8), Vector2(0, s * 1.8), Color.WHITE, 3.0)
					draw_line(Vector2(-s * 1.1, 0), Vector2(s * 1.1, 0), c, 3.0)
				"gunslinger": # starburst
					for k in 8:
						var ang2 := k * TAU / 8.0
						draw_line(Vector2(cos(ang2), sin(ang2)) * 6.0, Vector2(cos(ang2), sin(ang2)) * s * 1.5, Color("#ffd66b") if k % 2 == 0 else Color.WHITE, 3.0)
				"arcanist":   # rune ring
					draw_arc(Vector2.ZERO, 12.0 + 26.0 * f, 0.0, TAU, 16, Color(c, 1.0 - f), 4.0)
					draw_arc(Vector2.ZERO, 6.0 + 14.0 * f, f * 6.0, f * 6.0 + 4.0, 10, Color.WHITE, 3.0)
				"shadeweaver": # dark tendrils
					for k in 4:
						var ang3 := k * TAU / 4.0 + f * 2.0
						draw_line(Vector2.ZERO, Vector2(cos(ang3), sin(ang3)) * s * 1.7, Color(0.15, 0.0, 0.25, 1.0 - f), 7.0)
						draw_line(Vector2.ZERO, Vector2(cos(ang3), sin(ang3)) * s * 1.7, c, 3.0)
				_:
					draw_line(Vector2(-s, 0), Vector2(s, 0), Color.WHITE, 4.0)
					draw_line(Vector2(0, -s), Vector2(0, s), Color.WHITE, 4.0)
					draw_line(Vector2(-s * 0.7, -s * 0.7), Vector2(s * 0.7, s * 0.7), c, 3.0)
					draw_line(Vector2(-s * 0.7, s * 0.7), Vector2(s * 0.7, -s * 0.7), c, 3.0)
		"ghost":   # dash afterimage: simple class-coloured silhouette
			var gd := float(data.get("dir", 1.0))
			var ga := 0.5 * (1.0 - f)
			draw_rect(Rect2(-9, -56, 18, 56), Color(c, ga))
			draw_rect(Rect2(-9, -78, 18, 22), Color(c.lightened(0.3), ga))
			draw_rect(Rect2(gd * 10.0 + (0.0 if gd > 0.0 else -40.0), -40, 40, 5), Color(1, 1, 1, ga))
		"rune":    # casting circle on the ground
			var rr := float(data.get("radius", 60.0)) * (0.5 + 0.5 * minf(f * 3.0, 1.0))
			draw_set_transform(Vector2(0, -2), 0.0, Vector2(1.0, 0.3))
			draw_arc(Vector2.ZERO, rr, 0.0, TAU, 32, Color(c, 0.9 * (1.0 - f)), 5.0)
			draw_arc(Vector2.ZERO, rr * 0.66, f * 5.0, f * 5.0 + TAU * 0.7, 24, Color(1, 1, 1, 0.8 * (1.0 - f)), 3.0)
			for k in 6:
				var ra := f * 3.0 + k * TAU / 6.0
				draw_rect(Rect2(cos(ra) * rr - 3, sin(ra) * rr - 3, 6, 6), Color(c, 1.0 - f))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		"warn":    # telegraph: pulsing ground ring that fills up over the wind-up
			var wr := float(data.get("radius", 80.0))
			draw_set_transform(Vector2(0, -2), 0.0, Vector2(1.0, 0.32))
			draw_arc(Vector2.ZERO, wr, 0.0, TAU, 36, Color(c, 0.55 + 0.4 * sin(age * 28.0)), 5.0)
			draw_circle(Vector2.ZERO, wr * f, Color(c, 0.18))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		"ult":     # ultimate activation: rising beam + double ring in the class colour
			var uh := 420.0 * minf(f * 3.0, 1.0)
			draw_rect(Rect2(-26.0 * (1.0 - f), -uh, 52.0 * (1.0 - f), uh), Color(c, 0.35 * (1.0 - f)))
			draw_rect(Rect2(-10.0 * (1.0 - f), -uh, 20.0 * (1.0 - f), uh), Color(1, 1, 1, 0.7 * (1.0 - f)))
			draw_set_transform(Vector2(0, -2), 0.0, Vector2(1.0, 0.3))
			draw_arc(Vector2.ZERO, 40.0 + 160.0 * f, 0.0, TAU, 32, Color(c, 1.0 - f), 8.0)
			draw_arc(Vector2.ZERO, 20.0 + 100.0 * f, 0.0, TAU, 32, Color(1, 1, 1, 1.0 - f), 4.0)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		"bolt_line":   # chain lightning segment between two points
			var to: Vector2 = data.get("to", Vector2.ZERO) - position
			var pts := PackedVector2Array([Vector2.ZERO])
			for k in range(1, 6):
				var tt := float(k) / 6.0
				pts.append(to * tt + Vector2(0, (randf() - 0.5) * 36.0 * (1.0 - tt)))
			pts.append(to)
			draw_polyline(pts, Color(c, 1.0 - f), 7.0 * (1.0 - f) + 2.0)
			draw_polyline(pts, Color(1, 1, 1, 1.0 - f), 2.0)
		"casing":  # ejected shell
			var cd := float(data.get("dir", 1.0))
			draw_rect(Rect2(-cd * (8.0 + 30.0 * f) - 2, -6.0 - 30.0 * f + 70.0 * f * f, 5, 3), Color("#e8c060", 1.0 - f))
		"pillar":
			var h := 520.0
			draw_rect(Rect2(-float(data.get("radius", 60.0)) * (1.0 - f), -h, float(data.get("radius", 60.0)) * 2.0 * (1.0 - f), h), Color(c, 0.6 * (1.0 - f)))
