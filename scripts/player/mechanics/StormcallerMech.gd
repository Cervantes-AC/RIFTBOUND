class_name StormcallerMech
extends Mechanic
## CHARGE: Spark and Lightning Bolt hits add Charge. Discharge spends ALL of it (min 30) as chain lightning.
## Passive Static Field: standing within 350px of an enemy builds +4 Charge per second.

var spent := 0.0


func setup() -> void:
	label = "CHARGE"
	color = Color("#f2e04a")


func tick(dt: float) -> void:
	if f.world == null:
		return
	for e in f.world.fighters:
		if e.team != f.team and not e.is_dead() and e.global_position.distance_to(f.global_position) <= 350.0:
			res = minf(res + 4.0 * dt, max_res)
			return


func can_use(_slot: int, sk: SkillData) -> bool:
	return sk.kind != "discharge" or res >= float(sk.p("min", 30))


func on_use(slot: int, sk: SkillData) -> void:
	if sk.kind == "discharge":
		spent = res
		res = 0.0
	elif slot == 4:
		res = minf(res + float(sk.p("gain", 0)), max_res)


func on_hit_dealt(hit: Dictionary, _target: Fighter, _dealt: float) -> void:
	var s := Library.get_skill(str(hit.get("source", "")))
	if s != null:
		res = minf(res + float(s.p("gain", 0)), max_res)


func hud_text() -> String:
	return "%d" % int(res)
