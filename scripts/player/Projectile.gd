class_name Projectile
extends Node2D
## Flying attack. The authority simulates hits; a `visual_only` copy (online guest) just flies and is
## removed when the host says it ended. Each target is hit at most once per projectile.

var spec: Dictionary = {}
var velocity := Vector2.ZERO
var visual_only := false
var net_id := -1
var _age := 0.0
var _pierce_left := 0
var _hit_ids: Dictionary = {}
var _shape := CircleShape2D.new()
var _trail: Array[Vector2] = []
var world = null
var finished := false
var _speed := 0.0


func setup(p_spec: Dictionary, p_world, p_visual_only: bool) -> void:
	spec = p_spec
	world = p_world
	visual_only = p_visual_only
	position = spec["pos"]
	velocity = spec["vel"]
	_speed = velocity.length()
	_pierce_left = int(spec.get("pierce", 0))
	_shape.radius = float(spec.get("radius", 12.0))
	z_index = 5
	rotation = velocity.angle() if str(spec["style"]) != "wave" else 0.0


func _physics_process(delta: float) -> void:
	if finished:
		return
	_age += delta
	if float(spec.get("homing", 0.0)) > 0.0 and not visual_only and world:
		var t = world.nearest_enemy_to(int(spec["team"]), global_position)
		if t != null:
			var want: Vector2 = (t.center() - global_position).normalized() * velocity.length()
			velocity = velocity.lerp(want, clampf(float(spec["homing"]) * delta, 0.0, 1.0))
			velocity = velocity.normalized() * _speed
	global_position += velocity * delta
	if str(spec["style"]) != "wave":
		rotation = velocity.angle()
	_trail.append(global_position)
	if _trail.size() > 6:
		_trail.pop_front()
	queue_redraw()
	var out_of_bounds := false
	if world and world.arena:
		var b: Rect2 = world.arena.bounds
		out_of_bounds = global_position.x < b.position.x - 40.0 or global_position.x > b.end.x + 40.0
	if visual_only:
		if _age >= float(spec["life"]) + 0.3 or out_of_bounds:
			_finish(false)
		return
	_check_hits()
	if finished:
		return
	if out_of_bounds or _age >= float(spec["life"]):
		_finish(float(spec.get("explode", 0.0)) > 0.0 and str(spec["style"]) != "wave")


func _check_hits() -> void:
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = _shape
	params.transform = Transform2D(0.0, global_position)
	params.collision_mask = Fighter.LAYER_FIGHTER
	params.collide_with_bodies = true
	for r in get_world_2d().direct_space_state.intersect_shape(params, 8):
		var target = r["collider"]
		if not (target is Fighter) or target.team == int(spec["team"]) or target.is_dead():
			continue
		var id: int = target.get_instance_id()
		if _hit_ids.has(id):
			continue
		_hit_ids[id] = true
		var attacker = world.fighter_by_slot(int(spec["owner"])) if world else null
		var h := {
			"attacker": attacker, "dmg": spec["dmg"], "kb": spec["kb"], "kb_up": spec["kb_up"],
			"stun": spec["stun"], "status": spec.get("status", ""), "status_dur": spec.get("status_dur", 1.0),
			"from_x": global_position.x - sign(velocity.x) * 20.0, "source": spec.get("source", ""), "color": spec["color"],
			"element": spec.get("element", ""),
		}
		var connected: bool = target.receive_hit(h)
		if connected and world:
			world.on_hit_landed(attacker, target, h)
		if float(spec.get("explode", 0.0)) > 0.0:
			_finish(true)
			return
		if connected:
			if _pierce_left > 0:
				_pierce_left -= 1
			elif str(spec["style"]) != "wave":
				_finish(false)
				return


func _finish(explode: bool) -> void:
	if finished:
		return
	finished = true
	if explode and not visual_only and world:
		world.explode_at(spec, global_position)
	if world and not visual_only:
		world.projectile_ended(net_id, global_position, explode)
	queue_free()


func _draw() -> void:
	var c: Color = spec.get("color", Color.WHITE)
	var style := str(spec.get("style", "orb"))
	var t := _age * 12.0
	match style:
		"arrow", "arrow_big":
			var len := 34.0 if style == "arrow" else 56.0
			var w := 4.0 if style == "arrow" else 6.0
			draw_rect(Rect2(-len, -w * 0.5, len, w), Color("#8a6a3a"))
			draw_rect(Rect2(0, -w, 8, w * 2), c)
			draw_rect(Rect2(-len, -w, 8, w * 2), c.darkened(0.2))
			if style == "arrow_big":
				draw_rect(Rect2(-len - 24, -3, 24, 6), Color(c, 0.35))
		"rift":    # crescent of torn space
			draw_arc(Vector2(-10, 0), 22.0, -1.3, 1.3, 14, Color(c, 0.4), 12.0)
			draw_arc(Vector2(-8, 0), 22.0, -1.2, 1.2, 14, c, 6.0)
			draw_arc(Vector2(-6, 0), 22.0, -0.9, 0.9, 10, Color.WHITE, 2.0)
		"mark":
			draw_rect(Rect2(-30, -2, 30, 4), Color(c, 0.5))
			draw_colored_polygon(PackedVector2Array([Vector2(14, 0), Vector2(0, -9), Vector2(-6, 0), Vector2(0, 9)]), c)
			draw_circle(Vector2.ZERO, 3.0, Color.WHITE)
		"bullet":
			draw_rect(Rect2(-18, -3, 18, 6), Color(c, 0.4))
			draw_rect(Rect2(-6, -4, 12, 8), c)
			draw_rect(Rect2(0, -2, 6, 4), Color.WHITE)
		"shell":
			draw_circle(Vector2.ZERO, 12, Color("#3a2a1a"))
			draw_circle(Vector2.ZERO, 9, c)
			draw_rect(Rect2(-18 - 8 * sin(t), -3, 14, 6), Color(1.0, 0.8, 0.3, 0.8))
		"orb":
			draw_circle(Vector2.ZERO, 16, Color(c, 0.25))
			draw_circle(Vector2.ZERO, 11, c)
			draw_circle(Vector2.ZERO, 5, Color.WHITE)
		"bolt":
			for i in _trail.size():
				var p := to_local(_trail[i])
				draw_rect(Rect2(p.x - 6, p.y - 6, 12, 12), Color(c, 0.06 * i))
			draw_circle(Vector2.ZERO, 14, Color(c, 0.35))
			draw_rect(Rect2(-16, -8, 32, 16), c)
			draw_rect(Rect2(-8, -4, 22, 8), Color.WHITE)
		"dark":
			for i in _trail.size():
				var p2 := to_local(_trail[i])
				draw_circle(p2, 8.0 * i / 6.0, Color(c, 0.12 * i))
			draw_circle(Vector2.ZERO, 15, Color("#1a0a24"))
			draw_circle(Vector2.ZERO, 10, c)
		"chain":
			for i in 6:
				var cx := -i * 14.0
				draw_rect(Rect2(cx - 7, -5 + (3.0 if i % 2 else -3.0), 14, 8), c if i % 2 else c.darkened(0.3))
			draw_circle(Vector2.ZERO, 11, Color("#2a2a40"))
			draw_circle(Vector2.ZERO, 6, c)
		"wave":
			var f := signf(velocity.x)
			for i in 5:
				var h := 36.0 - i * 6.0 + 8.0 * sin(t + i)
				draw_rect(Rect2(-f * i * 16.0 - 8, -h, 16, h), c.darkened(0.1 * i))
		_:
			draw_circle(Vector2.ZERO, 10, c)
