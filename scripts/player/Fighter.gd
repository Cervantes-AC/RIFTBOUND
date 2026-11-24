class_name Fighter
extends CharacterBody2D
## The single reusable character controller for all six classes (and AI/remote players).
## Class differences are data (ClassData/SkillData); who drives it is a controller returning an Intent.

signal damaged(fighter: Fighter, amount: float, pos: Vector2)
signal eliminated(fighter: Fighter)
signal action_started(fighter: Fighter, skill: SkillData)

enum State { IDLE, RUN, AIR, ACTION, DODGE, HURT, DEAD }

const GRAVITY := 1500.0
const MAX_FALL := 1000.0
const BODY := Vector2(34, 78)
const LAYER_FIGHTER := 2
const LAYER_PLATFORM := 4
const ACT_STYLES: Array[String] = ["", "slash", "slam", "shoot", "cast", "cast_up", "spin", "guard", "dash"]
const STATUS_BITS := {"shield": 1, "invuln": 2, "slow": 4, "root": 8, "haste": 16, "empower": 32}

var slot: int = 0
var team: int = 0
var display_name: String = ""
var data: ClassData
var controller = null  # any object with update(fighter, delta) -> Intent
var world = null       # MatchManager (optional in unit tests)
var is_puppet := false
var input_enabled := true

var health: HealthComponent
var skills: SkillManager
var combat: CombatComponent
var visual: Node2D

var state: State = State.IDLE
var facing: int = 1
var anim_time := 0.0
var act_style := ""
var act_progress := 0.0
var flash_t := 0.0
var speed_mult := 1.0
var damage_mult := 1.0
var cd_scale := 1.0
var enraged := false
var is_boss := false

var status_t: Dictionary = {}
var status_v: Dictionary = {}

var action_skill: SkillData
var action_slot := -1
var action_phase := ""
var action_t := 0.0
var action_active_time := 0.0

var _intent: Intent = Intent.new()
var _coyote := 0.0
var _jump_buffer := 0.0
var _air_jumps_left := 0
var _dodge_cd := 0.0
var _stun_t := 0.0
var _combo_hits := 0
var _combo_reset := 0.0
var _drop_t := 0.0
var _dash_vel := 0.0
var _dash_t := 0.0
var _puppet_target := Vector2.ZERO
var _puppet_has_target := false
var _dead_time := 0.0


func setup(p_slot: int, p_team: int, p_data: ClassData, p_name: String, hp_mult: float, p_world) -> void:
	slot = p_slot
	team = p_team
	data = p_data
	display_name = p_name
	world = p_world
	collision_layer = LAYER_FIGHTER
	collision_mask = 1 | LAYER_PLATFORM
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	floor_snap_length = 8.0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = BODY * data.body_scale
	shape.shape = rect
	shape.position = Vector2(0, -rect.size.y * 0.5)
	add_child(shape)
	health = HealthComponent.new()
	add_child(health)
	health.setup(data.max_health * hp_mult)
	health.died.connect(_die)
	skills = SkillManager.new()
	add_child(skills)
	combat = CombatComponent.new()
	combat.setup(self)
	add_child(combat)
	visual = CharacterVisual.new()
	visual.fighter = self
	add_child(visual)
	add_to_group("fighters")
	_air_jumps_left = data.max_jumps - 1


# ----------------------------------------------------------------- queries
func is_dead() -> bool:
	return state == State.DEAD


func has_status(status_name: String) -> bool:
	return status_t.get(status_name, 0.0) > 0.0


func set_status(status_name: String, duration: float, value: float = 0.0) -> void:
	status_t[status_name] = maxf(duration, status_t.get(status_name, 0.0))
	status_v[status_name] = value


func effective_speed() -> float:
	var s := data.move_speed * speed_mult
	if has_status("slow"):
		s *= 0.5
	if has_status("haste"):
		s *= float(status_v.get("haste", 1.3))
	return s


func skill_for_slot(s: int) -> SkillData:
	return data.basic if s == 0 else data.skills[s - 1]


func center() -> Vector2:
	return global_position + Vector2(0, -BODY.y * data.body_scale * 0.5)


func is_attacking() -> bool:
	return state == State.ACTION


func action_total_time() -> float:
	if action_skill == null:
		return 0.0
	return action_skill.windup + action_active_time + action_skill.recover


# ----------------------------------------------------------------- main loop
func _physics_process(delta: float) -> void:
	anim_time += delta
	flash_t = maxf(flash_t - delta, 0.0)
	if is_puppet:
		_puppet_step(delta)
		return
	_tick_timers(delta)
	_intent = _read_intent(delta)
	match state:
		State.DEAD:
			_dead_time += delta
			velocity.x = move_toward(velocity.x, 0.0, 1800.0 * delta)
		State.HURT:
			_step_hurt(delta)
		State.DODGE:
			_step_dodge(delta)
		State.ACTION:
			_step_action(delta, _intent)
		_:
			_step_free(delta, _intent)
	_integrate(delta)


func _read_intent(delta: float) -> Intent:
	if controller == null or not input_enabled or state == State.DEAD:
		_intent.clear()
		return _intent
	var it = controller.update(self, delta)
	return it if it != null else _intent


func _tick_timers(delta: float) -> void:
	skills.update(delta)
	_dodge_cd = maxf(_dodge_cd - delta, 0.0)
	_coyote = maxf(_coyote - delta, 0.0)
	_jump_buffer = maxf(_jump_buffer - delta, 0.0)
	_drop_t = maxf(_drop_t - delta, 0.0)
	_combo_reset = maxf(_combo_reset - delta, 0.0)
	if _combo_reset <= 0.0:
		_combo_hits = 0
	for k in status_t.keys():
		status_t[k] -= delta
		if status_t[k] <= 0.0:
			status_t.erase(k)
			status_v.erase(k)
	if _drop_t <= 0.0:
		collision_mask = 1 | LAYER_PLATFORM


# ----------------------------------------------------------------- states
func _step_free(delta: float, it: Intent) -> void:
	if it.dodge_pressed and try_dodge(it.move):
		return
	if it.attack_pressed and try_skill(0):
		return
	for i in 3:
		if it.skill_pressed[i] and try_skill(i + 1):
			return
	var rooted := has_status("root")
	if it.jump_pressed:
		_jump_buffer = 0.12
	if _jump_buffer > 0.0 and not rooted:
		if it.down and is_on_floor() and _standing_on_platform():
			_drop_t = 0.25
			collision_mask = 1
			position.y += 2.0
			_jump_buffer = 0.0
		elif is_on_floor() or _coyote > 0.0:
			_do_jump()
		elif _air_jumps_left > 0:
			_air_jumps_left -= 1
			_do_jump()
	if not it.jump_held and velocity.y < -180.0:
		velocity.y += GRAVITY * 1.4 * delta  # short hop when button released
	var target := 0.0 if rooted else it.move * effective_speed()
	_accelerate(target, delta, 1.0)
	if absf(it.move) > 0.2 and not rooted:
		facing = 1 if it.move > 0.0 else -1
	state = State.AIR if not is_on_floor() else (State.RUN if absf(velocity.x) > 20.0 and absf(it.move) > 0.1 else State.IDLE)


func _step_action(delta: float, it: Intent) -> void:
	action_t += delta
	var sk := action_skill
	match action_phase:
		"windup":
			if action_t >= sk.windup:
				action_phase = "active"
				action_t = 0.0
				action_active_time = combat.fire(sk, self, it)
		"active":
			if action_t >= action_active_time:
				action_phase = "recover"
				action_t = 0.0
				combat.end_active(self)
		"recover":
			if action_t >= sk.recover:
				_end_action()
	var total := maxf(action_total_time(), 0.01)
	var done := 0.0
	match action_phase:
		"windup":
			done = action_t
		"active":
			done = sk.windup + action_t
		"recover":
			done = sk.windup + action_active_time + action_t
	act_progress = clampf(done / total, 0.0, 1.0)
	_accelerate(0.0 if has_status("root") else it.move * effective_speed() * 0.2, delta, 0.8)


func _step_dodge(delta: float) -> void:
	action_t += delta
	_accelerate(0.0, delta, 1.0)
	if action_t >= 0.2:
		state = State.AIR if not is_on_floor() else State.IDLE
		velocity.x *= 0.3


func _step_hurt(delta: float) -> void:
	_stun_t -= delta
	_accelerate(0.0, delta, 0.5)
	if _stun_t <= 0.0:
		state = State.AIR if not is_on_floor() else State.IDLE


func _accelerate(target: float, delta: float, control: float) -> void:
	if _dash_t > 0.0:
		velocity.x = _dash_vel
		_dash_t -= delta
		if _dash_t <= 0.0:
			velocity.x *= 0.25
		return
	var friction: float = world.arena.floor_friction if (world and world.arena) else 1.0
	var on_floor := is_on_floor()
	var accel: float
	if on_floor:
		accel = (3600.0 if absf(target) > 1.0 else 3000.0) * friction
	else:
		accel = 1900.0 * control
	velocity.x = move_toward(velocity.x, target, accel * delta)


func _integrate(delta: float) -> void:
	var g := GRAVITY
	if _dash_t > 0.0:
		g *= 0.15
	velocity.y = minf(velocity.y + g * delta, MAX_FALL)
	var was_on_floor := is_on_floor()
	move_and_slide()
	if is_on_floor():
		_coyote = 0.1
		_air_jumps_left = data.max_jumps - 1
		if not was_on_floor and velocity.y >= 0.0:
			if world:
				world.fx("dust", global_position, {"count": 4})
	elif was_on_floor:
		_coyote = 0.1
	if world and world.arena:
		var b: Rect2 = world.arena.bounds
		if global_position.x < b.position.x:
			global_position.x = b.position.x
			velocity.x = maxf(velocity.x, 0.0)
		elif global_position.x > b.end.x:
			global_position.x = b.end.x
			velocity.x = minf(velocity.x, 0.0)
		if global_position.y > b.end.y + 400.0:  # safety net: never fall out of the world
			global_position = Vector2(clampf(global_position.x, b.position.x, b.end.x), world.arena.floor_y - 200.0)
			velocity = Vector2.ZERO


func _standing_on_platform() -> bool:
	for i in get_slide_collision_count():
		var c := get_slide_collision(i).get_collider()
		if c is CollisionObject2D and (c.collision_layer & LAYER_PLATFORM) != 0 and (c.collision_layer & 1) == 0:
			return true
	return false


func _do_jump() -> void:
	velocity.y = -data.jump_velocity
	_jump_buffer = 0.0
	_coyote = 0.0
	AudioManager.play_sfx("jump", 1.0 + 0.1 * randf())
	if world:
		world.fx("dust", global_position, {"count": 3})


# ----------------------------------------------------------------- actions
func auto_face_enemy() -> void:
	if world == null:
		return
	var e = world.nearest_enemy(self)
	if e != null and absf(e.global_position.x - global_position.x) < 560.0:
		facing = 1 if e.global_position.x >= global_position.x else -1


func try_skill(slot_index: int) -> bool:
	if state == State.DEAD or state == State.HURT or state == State.ACTION or state == State.DODGE:
		return false
	if not skills.is_ready(slot_index):
		return false
	var sk := skill_for_slot(slot_index)
	skills.start_cooldown(slot_index, sk.cooldown * cd_scale)
	auto_face_enemy()
	action_skill = sk
	action_slot = slot_index
	action_phase = "windup"
	action_t = 0.0
	action_active_time = 0.0
	act_progress = 0.0
	act_style = CombatComponent.style_for(sk)
	state = State.ACTION
	anim_time = 0.0
	action_started.emit(self, sk)
	return true


func try_dodge(move_dir: float) -> bool:
	if _dodge_cd > 0.0 or state == State.DEAD or state == State.HURT or state == State.ACTION or state == State.DODGE:
		return false
	_dodge_cd = data.dodge_cooldown
	var dir := facing
	if absf(move_dir) > 0.2:
		dir = 1 if move_dir > 0.0 else -1
	state = State.DODGE
	action_t = 0.0
	anim_time = 0.0
	set_status("invuln", 0.22)
	start_dash(dir * 200.0 / 0.2, 0.2)
	AudioManager.play_sfx("dodge")
	if world:
		world.fx("dust", global_position, {"count": 5})
	return true


func start_dash(vx: float, duration: float) -> void:
	_dash_vel = vx
	_dash_t = duration


func cancel_dash() -> void:
	_dash_t = 0.0


func dodge_cooldown_left() -> float:
	return _dodge_cd


func _end_action() -> void:
	action_skill = null
	action_slot = -1
	action_phase = ""
	act_style = ""
	state = State.AIR if not is_on_floor() else State.IDLE


## True if the hit connected (not dodged / dead).
func receive_hit(hit: Dictionary) -> bool:
	if state == State.DEAD or has_status("invuln"):
		return false
	var dmg: float = float(hit.get("dmg", 0.0))
	var attacker = hit.get("attacker")
	var reduction := 0.0
	var armored := has_status("shield")
	if armored:
		reduction = float(status_v.get("shield", 0.7))
	dmg *= (1.0 - reduction)
	var dealt := health.apply_damage(dmg)
	flash_t = 0.15
	var from_x: float = hit.get("from_x", global_position.x - facing)
	var dir := 1.0 if global_position.x >= from_x else -1.0
	var kb_x: float = float(hit.get("kb", 0.0))
	var kb_up: float = float(hit.get("kb_up", 0.0))
	if armored:
		kb_x *= 0.15
		kb_up *= 0.15
	if state != State.DEAD:
		velocity.x = dir * kb_x
		if kb_up > 0.0:
			velocity.y = -kb_up
		var stun: float = float(hit.get("stun", 0.0))
		if stun > 0.0 and not armored:
			_combo_hits += 1
			_combo_reset = 1.5
			stun *= maxf(0.3, 1.0 - 0.2 * (_combo_hits - 1))
			combat.cancel(self)
			if state == State.ACTION:
				_end_action()
			cancel_dash()
			_stun_t = stun
			state = State.HURT
			anim_time = 0.0
		var st: String = str(hit.get("status", ""))
		if st != "":
			set_status(st, float(hit.get("status_dur", 1.0)))
	if attacker != null and is_instance_valid(attacker):
		attacker.on_dealt_hit()
	damaged.emit(self, dealt, global_position + Vector2(0, -70))
	return true


## Empower buff (Phantom Step) is consumed by the next damaging hit this fighter lands.
func on_dealt_hit() -> void:
	if has_status("empower"):
		status_t.erase("empower")
		status_v.erase("empower")


func outgoing_multiplier() -> float:
	var m := damage_mult
	if has_status("empower"):
		m *= float(status_v.get("empower", 1.5))
	return m


func apply_enrage() -> void:
	if enraged:
		return
	enraged = true
	speed_mult *= 1.12
	cd_scale *= 0.7
	damage_mult *= 1.15
	flash_t = 0.5
	if world:
		world.fx("ring", global_position + Vector2(0, -40), {"color": Color("#ff5a5a"), "radius": 160.0})
		world.shake(10.0)


func _die() -> void:
	if state == State.DEAD:
		return
	combat.cancel(self)
	_end_action()
	state = State.DEAD
	anim_time = 0.0
	_dead_time = 0.0
	collision_layer = 0
	status_t.clear()
	status_v.clear()
	cancel_dash()
	velocity = Vector2(velocity.x * 0.5, -280.0)
	AudioManager.play_sfx("death")
	eliminated.emit(self)


# ----------------------------------------------------------------- network
func to_snapshot() -> Array:
	var bits := 0
	for k in STATUS_BITS:
		if has_status(k):
			bits |= int(STATUS_BITS[k])
	return [global_position.x, global_position.y, velocity.x, velocity.y, facing, int(state),
		health.current, health.max_health, bits, ACT_STYLES.find(act_style), act_progress,
		skills.cooldown_left[0], skills.cooldown_left[1], skills.cooldown_left[2], skills.cooldown_left[3],
		_dodge_cd, 1 if enraged else 0]


func from_snapshot(a: Array) -> void:
	_puppet_target = Vector2(a[0], a[1])
	if not _puppet_has_target:
		global_position = _puppet_target
		_puppet_has_target = true
	velocity = Vector2(a[2], a[3])
	facing = int(a[4])
	var new_state := int(a[5]) as State
	if new_state != state:
		anim_time = 0.0
		if new_state == State.DEAD and state != State.DEAD:
			collision_layer = 0
	state = new_state
	health.current = a[6]
	health.max_health = a[7]
	health.changed.emit(health.current, health.max_health)
	var bits := int(a[8])
	for k in STATUS_BITS:
		if bits & int(STATUS_BITS[k]):
			status_t[k] = 0.15
		else:
			status_t.erase(k)
	var si := int(a[9])
	act_style = ACT_STYLES[si] if si >= 0 and si < ACT_STYLES.size() else ""
	act_progress = a[10]
	for i in 4:
		skills.cooldown_left[i] = a[11 + i]
	_dodge_cd = a[15]
	enraged = int(a[16]) == 1


func _puppet_step(delta: float) -> void:
	if _puppet_has_target:
		global_position = global_position.lerp(_puppet_target + velocity * 0.03, clampf(delta * 18.0, 0.0, 1.0))
	for i in 4:
		skills.cooldown_left[i] = maxf(skills.cooldown_left[i] - delta, 0.0)
