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
					fx.life = 0.1
				"spin":
					fx.life = float(fx_data.get("dur", 0.5))
				"hit":
					fx.life = 0.16
					_particles(parent, pos, fx_data.get("color", Color.WHITE), 7, 0.35, 120.0, 300.0, Vector2.ZERO, 180.0, 4.0)
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
			draw_polyline(pts, Color(c, 1.0 - f), 9.0 * (1.0 - f) + 2.0)
			draw_polyline(pts, Color(1, 1, 1, 0.8 * (1.0 - f)), 3.0)
		"ring":
			var r := float(data.get("radius", 100.0)) * (0.25 + 0.75 * f)
			draw_arc(Vector2.ZERO, r, 0.0, TAU, 40, Color(c, 1.0 - f), 8.0 * (1.0 - f) + 2.0)
			draw_circle(Vector2.ZERO, r, Color(c, 0.12 * (1.0 - f)))
		"shockwave":
			var r2 := float(data.get("radius", 120.0)) * f
			draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.3))
			draw_arc(Vector2.ZERO, r2, 0.0, TAU, 32, Color(c, 1.0 - f), 8.0)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		"trail":
			var dir2 := float(data.get("dir", 1))
			for i in 5:
				var y := -70.0 + i * 16.0
				draw_rect(Rect2(-dir2 * (30.0 + f * 70.0) - 40.0 + (40.0 if dir2 > 0.0 else 0.0), y, 70.0 * (1.0 - f), 4), Color(c, 0.7 * (1.0 - f)))
		"muzzle":
			var dir3 := float(data.get("dir", 1))
			draw_rect(Rect2(0, -6, dir3 * 26.0 * (1.0 - f), 12), Color(c, 1.0 - f))
			draw_circle(Vector2.ZERO, 12.0 * (1.0 - f), Color.WHITE)
		"spin":
			var r3 := float(data.get("radius", 100.0))
			var rot := f * TAU * 3.0
			draw_arc(Vector2.ZERO, r3, rot, rot + 2.4, 16, Color(c, 0.9 * (1.0 - f * 0.5)), 8.0)
			draw_arc(Vector2.ZERO, r3, rot + PI, rot + PI + 2.4, 16, Color(c, 0.9 * (1.0 - f * 0.5)), 8.0)
		"hit":
			var s := 26.0 * (1.0 - f)
			draw_line(Vector2(-s, 0), Vector2(s, 0), Color.WHITE, 4.0)
			draw_line(Vector2(0, -s), Vector2(0, s), Color.WHITE, 4.0)
			draw_line(Vector2(-s * 0.7, -s * 0.7), Vector2(s * 0.7, s * 0.7), c, 3.0)
			draw_line(Vector2(-s * 0.7, s * 0.7), Vector2(s * 0.7, -s * 0.7), c, 3.0)
		"pillar":
			var h := 520.0
			draw_rect(Rect2(-float(data.get("radius", 60.0)) * (1.0 - f), -h, float(data.get("radius", 60.0)) * 2.0 * (1.0 - f), h), Color(c, 0.6 * (1.0 - f)))
