class_name AreaEffect
extends Node2D
## Delayed / repeating ground effect (Arrow Rain, Meteor Fall, arena rift surges).
## The authority applies damage; `visual_only` copies (online guest) just play the animation.

var spec: Dictionary = {}
var world = null
var visual_only := false
var _age := 0.0
var _ticks_done := 0
var _next_tick := 0.0
var _shape := CircleShape2D.new()
var _impacted := false


func setup(p_spec: Dictionary, p_world, p_visual_only: bool) -> void:
	spec = p_spec
	world = p_world
	visual_only = p_visual_only
	position = spec["pos"]
	_shape.radius = float(spec["radius"])
	_next_tick = float(spec["delay"])
	z_index = 4


func _physics_process(delta: float) -> void:
	_age += delta
	queue_redraw()
	var ticks := int(spec["ticks"])
	if _ticks_done < ticks and _age >= _next_tick:
		_ticks_done += 1
		_next_tick += float(spec["interval"])
		_impact()
	var end_time := float(spec["delay"]) + float(spec["interval"]) * maxi(ticks - 1, 0) + 0.45
	if _age >= end_time:
		queue_free()


func _impact() -> void:
	var style := str(spec["style"])
	if world:
		world.fx("burst", global_position + Vector2(randf_range(-0.6, 0.6) * float(spec["radius"]), -10.0), {"color": spec["color"], "count": 10})
		if style == "surge":
			world.fx("pillar", global_position, {"color": spec["color"], "radius": float(spec["radius"])})
			world.shake(8.0)
		if style == "meteor":
			world.fx("shockwave", global_position, {"color": spec["color"], "radius": float(spec["radius"]) * 1.3})
			world.shake(12.0)
	AudioManager.play_sfx("meteor" if style == "meteor" else "hit", 1.0)
	if visual_only:
		return
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = _shape
	params.transform = Transform2D(0.0, global_position + Vector2(0, -30))
	params.collision_mask = Fighter.LAYER_FIGHTER
	params.collide_with_bodies = true
	for r in get_world_2d().direct_space_state.intersect_shape(params, 12):
		var target = r["collider"]
		if not (target is Fighter) or target.is_dead():
			continue
		if int(spec["team"]) >= 0 and target.team == int(spec["team"]):
			continue
		var attacker = world.fighter_by_slot(int(spec["owner"])) if (world and int(spec["owner"]) >= 0) else null
		var h := {
			"attacker": attacker, "dmg": spec["dmg"], "kb": spec["kb"], "kb_up": spec["kb_up"],
			"stun": spec["stun"], "status": spec.get("status", ""), "status_dur": spec.get("status_dur", 1.0),
			"from_x": global_position.x, "source": spec.get("source", ""), "color": spec["color"],
		}
		if target.receive_hit(h) and world:
			world.on_hit_landed(attacker, target, h)


func _draw() -> void:
	var r := float(spec["radius"])
	var c: Color = spec["color"]
	var delay := float(spec["delay"])
	var style := str(spec["style"])
	if _age < delay:
		# telegraph: pulsing ground ring that fills up
		var f := _age / maxf(delay, 0.01)
		draw_arc(Vector2(0, -2), r, 0.0, TAU, 40, Color(c, 0.5 + 0.4 * sin(_age * 20.0)), 4.0)
		draw_circle(Vector2(0, -2), r * f, Color(c, 0.12))
		if style == "meteor":
			var y := -520.0 * (1.0 - f) - 20.0
			draw_circle(Vector2(0, y), 34, Color("#3a1a10"))
			draw_circle(Vector2(0, y), 26, c)
			draw_circle(Vector2(0, y), 12, Color("#fff2a0"))
			for i in 5:
				draw_rect(Rect2(-10 + i * 5, y - 40 - i * 22, 10, 22), Color(c, 0.5 - i * 0.08))
		elif style == "arrows":
			for i in 5:
				var ax := -r * 0.8 + i * r * 0.4
				var ay := -300.0 + 300.0 * f
				draw_rect(Rect2(ax - 2, ay - 30, 4, 30), Color("#8a6a3a"))
				draw_rect(Rect2(ax - 4, ay - 4, 8, 8), c)
	else:
		var f2 := clampf((_age - delay) / 0.4, 0.0, 1.0)
		draw_circle(Vector2(0, -2), r * (0.6 + 0.4 * f2), Color(c, 0.35 * (1.0 - f2)))
		if style == "arrows":
			for i in 5:
				var ax2 := -r * 0.8 + i * r * 0.4
				draw_rect(Rect2(ax2 - 2, -36, 4, 36), Color("#8a6a3a", 1.0 - f2))
