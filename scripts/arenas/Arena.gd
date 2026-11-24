class_name Arena
extends Node2D
## One fighting arena: collision geometry (floor, walls, one-way platforms), hazards and spawn points.
## Layouts are data-driven by `arena_id`, so five arenas share one reusable script. Drawing is in ArenaArt.

@export var arena_id: String = "forest"

const FLOOR_Y := 620.0
const LAVA_COOLDOWN := 0.9

var floor_y := FLOOR_Y
var floor_friction := 1.0
var bounds := Rect2(70, -200, 1140, 960)
var time := 0.0                       # arena clock; moving hazards are a pure function of it (easy to sync online)
var platforms: Array[Rect2] = []      # x, y(top), w, h
var pit := Vector2.ZERO               # lava pit x range (0,0 = none)
var orbs: Array = []                  # moving rift orbs
var surges := false                   # periodic rift surges (final arena)
var theme: Dictionary = {}
var world = null
var _lava_cd: Dictionary = {}
var _orb_cd: Dictionary = {}
var art: Node2D


func _ready() -> void:
	configure(arena_id)


func configure(id: String) -> void:
	arena_id = id
	platforms.clear()
	orbs.clear()
	pit = Vector2.ZERO
	surges = false
	floor_friction = 1.0
	match id:
		"forest":
			_add_platform(300, 500, 220)
			_add_platform(980, 500, 220)
			_add_platform(640, 385, 240)
		"cavern":
			pit = Vector2(555, 725)
			_add_platform(640, 495, 210)
			_add_platform(230, 495, 200)
			_add_platform(1050, 495, 200)
		"citadel":
			floor_friction = 0.13
			_add_platform(320, 500, 260)
			_add_platform(960, 500, 260)
			_add_platform(640, 385, 200)
		"shadow":
			_add_platform(250, 500, 200)
			_add_platform(1030, 500, 200)
			_add_platform(640, 410, 220)
			orbs.append({"cx": 640.0, "cy": 520.0, "ax": 380.0, "ay": 70.0, "w": 0.9, "ph": 0.0, "r": 26.0})
			orbs.append({"cx": 640.0, "cy": 330.0, "ax": 300.0, "ay": 40.0, "w": 1.25, "ph": 2.4, "r": 22.0})
		"sanctuary":
			floor_friction = 0.45
			pit = Vector2(565, 715)
			surges = true
			_add_platform(250, 495, 200)
			_add_platform(1030, 495, 200)
			_add_platform(640, 480, 170)
			_add_platform(640, 350, 220)
			orbs.append({"cx": 640.0, "cy": 540.0, "ax": 430.0, "ay": 60.0, "w": 1.0, "ph": 1.0, "r": 24.0})
	theme = ArenaArt.theme_for(id)
	_build_collision()
	if art == null:
		art = ArenaArt.new()
		art.arena = self
		art.z_index = -50
		add_child(art)
	art.queue_redraw()


func _add_platform(cx: float, y: float, w: float) -> void:
	platforms.append(Rect2(cx - w * 0.5, y, w, 18.0))


func _build_collision() -> void:
	for c in get_children():
		if c is StaticBody2D:
			c.queue_free()
	# floor (split around the lava pit if there is one)
	if pit.y > pit.x:
		_solid(Rect2(-900, floor_y, pit.x + 900, 400))
		_solid(Rect2(pit.y, floor_y, 2200 - pit.y, 400))
	else:
		_solid(Rect2(-900, floor_y, 3100, 400))
	_solid(Rect2(bounds.position.x - 60, -600, 60, 1800))   # left wall
	_solid(Rect2(bounds.end.x, -600, 60, 1800))             # right wall
	for p in platforms:
		var sb := StaticBody2D.new()
		sb.collision_layer = Fighter.LAYER_PLATFORM
		sb.collision_mask = 0
		var cs := CollisionShape2D.new()
		var r := RectangleShape2D.new()
		r.size = Vector2(p.size.x, 14)
		cs.shape = r
		cs.one_way_collision = true
		cs.position = p.position + Vector2(p.size.x * 0.5, 7)
		sb.add_child(cs)
		add_child(sb)


func _solid(rect: Rect2) -> void:
	var sb := StaticBody2D.new()
	sb.collision_layer = 1
	sb.collision_mask = 0
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = rect.size
	cs.shape = r
	cs.position = rect.position + rect.size * 0.5
	sb.add_child(cs)
	add_child(sb)


func spawn_point(team: int, index: int) -> Vector2:
	var x := 300.0 + index * 90.0 if team == 0 else 980.0 - index * 90.0
	return Vector2(x, floor_y)


func orb_position(o: Dictionary, t: float) -> Vector2:
	return Vector2(o["cx"] + o["ax"] * sin(t * o["w"] + o["ph"]), o["cy"] + o["ay"] * sin(t * o["w"] * 1.7 + o["ph"]))


func has_pit() -> bool:
	return pit.y > pit.x


## Authority-only hazard resolution (lava + orbs). Visuals are drawn by ArenaArt from `time`.
func update_hazards(delta: float, fighters: Array) -> void:
	time += delta
	for k in _lava_cd.keys():
		_lava_cd[k] -= delta
		if _lava_cd[k] <= 0.0:
			_lava_cd.erase(k)
	for k in _orb_cd.keys():
		_orb_cd[k] -= delta
		if _orb_cd[k] <= 0.0:
			_orb_cd.erase(k)
	for f in fighters:
		if f.is_dead():
			continue
		var id: int = f.get_instance_id()
		if has_pit() and f.global_position.y > floor_y + 30.0 and f.global_position.x > pit.x - 30.0 and f.global_position.x < pit.y + 30.0:
			if not _lava_cd.has(id):
				_lava_cd[id] = LAVA_COOLDOWN
				f.receive_hit({"dmg": 9.0, "kb": 0.0, "kb_up": 0.0, "stun": 0.35, "source": "lava", "from_x": f.global_position.x})
				var mid := (pit.x + pit.y) * 0.5
				var dir := 1.0 if f.global_position.x >= mid else -1.0
				f.velocity = Vector2(dir * 300.0, -950.0)
				AudioManager.play_sfx("lava")
				if world:
					world.fx("burst", f.global_position, {"color": Color("#ff8a2a"), "count": 14})
					world.shake(8.0)
		for o in orbs:
			var op := orb_position(o, time)
			if f.center().distance_to(op) < float(o["r"]) + 30.0 and not _orb_cd.has(id):
				_orb_cd[id] = 1.1
				f.receive_hit({"dmg": 10.0, "kb": 380.0, "kb_up": 260.0, "stun": 0.35, "source": "orb", "from_x": op.x})
				AudioManager.play_sfx("hit_heavy")
				if world:
					world.fx("burst", op, {"color": Color("#c04cff"), "count": 10})
