class_name RiftbladeMech
extends Mechanic
## PHASE: builds slowly (+1.5/s) and on every hit (+10). Rift Step costs 40 and tears a rift that exits BEHIND the
## nearest enemy. Passive Phase Edge: hits from behind the target deal +30%.


func setup() -> void:
	label = "PHASE"
	color = Color("#33e0d0")
	res = 30.0


func tick(dt: float) -> void:
	res = minf(res + 1.5 * dt, max_res)


func can_use(_slot: int, sk: SkillData) -> bool:
	return res >= float(sk.p("cost", 0))


func on_use(_slot: int, sk: SkillData) -> void:
	res -= float(sk.p("cost", 0))


func shape_hit(hit: Dictionary, target: Fighter) -> void:
	if hit.has("chain"):
		return
	# behind = the attacker stands on the side the target is NOT facing
	if (target.global_position.x - f.global_position.x) * float(target.facing) > 0.0:
		hit["dmg"] = float(hit.get("dmg", 0.0)) * 1.3
		if f.world:
			f.world.fx("text", target.global_position + Vector2(0, -120), {"text": "BACKSTAB", "color": Color("#8affef"), "size": 16})


func on_hit_dealt(_hit: Dictionary, _target: Fighter, _dealt: float) -> void:
	res = minf(res + 10.0, max_res)


func hud_text() -> String:
	return "%d" % int(res)
