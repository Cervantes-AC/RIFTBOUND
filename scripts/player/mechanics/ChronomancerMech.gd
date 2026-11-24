class_name ChronomancerMech
extends Mechanic
## TEMPO: Time energy (+8/s) pays for Time Snare, Temporal Bubble and Time Skip, so nothing can be spammed.
## Temporal Bubble slows enemies inside (status "slow") and enemy projectiles that enter it (x0.35, once each).
## Passive Borrowed Time: cooldowns tick 15% faster. Everything is deterministic and host-simulated.
## Synced state: aux = bubble time left, extra = bubble x.

const RADIUS := 160.0


func setup() -> void:
	label = "TIME"
	color = Color("#9affe8")
	res = 60.0
	extra = -9999.0


func cooldown_rate() -> float:
	return 1.15


func tick(dt: float) -> void:
	res = minf(res + 8.0 * dt, max_res)
	if aux <= 0.0 or f.world == null:
		return
	aux -= dt
	if aux <= 0.0:
		extra = -9999.0
		return
	var floor_y: float = f.world.arena.floor_y if f.world.arena else f.global_position.y
	for e in f.world.fighters:
		if e.team != f.team and not e.is_dead() and absf(e.global_position.x - extra) <= RADIUS and e.global_position.y > floor_y - 280.0:
			e.set_status("slow", 0.3)
	for p in f.world.get_projectiles():
		if p.visual_only or int(p.spec["team"]) == f.team or p.has_meta("slowed"):
			continue
		if p.global_position.distance_to(Vector2(extra, floor_y - 60.0)) <= RADIUS + 40.0:
			p.velocity *= 0.35
			p.set_meta("slowed", true)


func can_use(_slot: int, sk: SkillData) -> bool:
	return res >= float(sk.p("cost", 0))


func on_use(_slot: int, sk: SkillData) -> void:
	res -= float(sk.p("cost", 0))


func place_bubble(x: float, life: float) -> void:
	aux = life
	extra = x


func on_hit_dealt(hit: Dictionary, _target: Fighter, _dealt: float) -> void:
	var s := Library.get_skill(str(hit.get("source", "")))
	if s != null:
		res = minf(res + float(s.p("gain", 0)), max_res)


func hud_text() -> String:
	return "BUBBLE" if aux > 0.0 else "%d" % int(res)
