class_name Hitbox
extends Node2D
## A short-lived attack volume. Overlap is tested against the fighters' collision shapes (their hurtboxes).
## Every target can be hit only ONCE per hitbox (or once per `interval` for multi-hit attacks),
## so one swing can never damage the same opponent every frame.

var attacker: Fighter
var hit: Dictionary = {}
var size := Vector2(60, 60)
var lifetime := 0.1
var interval := 0.0
var circle := false
var debug_draw := false
var _hit_ids: Dictionary = {}
var _age := 0.0
var _interval_t := 0.0
var _shape: Shape2D
var hits_landed := 0


func setup(p_attacker: Fighter, p_hit: Dictionary, p_size: Vector2, p_lifetime: float, p_interval: float, p_circle: bool) -> void:
	attacker = p_attacker
	hit = p_hit
	size = p_size
	lifetime = p_lifetime
	interval = p_interval
	circle = p_circle
	if circle:
		var c := CircleShape2D.new()
		c.radius = size.x
		_shape = c
	else:
		var r := RectangleShape2D.new()
		r.size = size
		_shape = r


func _physics_process(delta: float) -> void:
	if attacker == null or not is_instance_valid(attacker) or attacker.is_dead():
		queue_free()
		return
	_check_overlaps()
	_age += delta
	if interval > 0.0:
		_interval_t += delta
		if _interval_t >= interval:
			_interval_t -= interval
			_hit_ids.clear()
	if _age >= lifetime:
		queue_free()


func _check_overlaps() -> void:
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = _shape
	params.transform = global_transform
	params.collision_mask = Fighter.LAYER_FIGHTER
	params.collide_with_bodies = true
	params.collide_with_areas = false
	var results := get_world_2d().direct_space_state.intersect_shape(params, 16)
	for r in results:
		var target = r["collider"]
		if not (target is Fighter):
			continue
		if target == attacker or target.team == attacker.team or target.is_dead():
			continue
		var id: int = target.get_instance_id()
		if _hit_ids.has(id):
			continue
		_hit_ids[id] = true
		var h := hit.duplicate()
		h["from_x"] = attacker.global_position.x
		if target.receive_hit(h):
			hits_landed += 1
			if attacker.world:
				attacker.world.on_hit_landed(attacker, target, h)
