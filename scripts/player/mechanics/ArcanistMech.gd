class_name ArcanistMech
extends Mechanic
## ELEMENTS: Attune cycles Fire / Frost / Storm; spells cost mana.
##  Fire: +20% damage, scorches.  Frost: -15% damage, slows.  Storm: chains to a nearby enemy.
##  Combos: Fire on a slowed enemy = SHATTER (x1.5, clears the slow). Storm on a slowed enemy stuns 0.4s.
## Passive Arcane Reserve: mana regenerates twice as fast while standing still.

const NAMES := ["FIRE", "FROST", "STORM"]
const TAGS := ["fire", "frost", "storm"]
const COLORS := [Color("#ff7a3a"), Color("#7fe0ff"), Color("#c8a0ff")]
const ELEMENT_SKILLS := ["arcanist_basic", "arcane_bolt"]


func setup() -> void:
	label = "MANA"
	color = Color("#7fb8ff")
	res = 100.0


func element() -> int:
	return int(aux) % 3


func tick(dt: float) -> void:
	res = minf(res + 10.0 * (2.0 if is_still() else 1.0) * dt, max_res)


func can_use(_slot: int, sk: SkillData) -> bool:
	return res >= float(sk.p("cost", 0))


func on_use(_slot: int, sk: SkillData) -> void:
	res -= float(sk.p("cost", 0))
	if sk.kind == "attune":
		aux = float((element() + 1) % 3)
		if f.world:
			f.world.fx("ring", f.global_position + Vector2(0, -50), {"color": COLORS[element()], "radius": 70.0})
			f.world.fx("text", f.global_position + Vector2(0, -120), {"text": NAMES[element()], "color": COLORS[element()], "size": 20})


func hit_color(sk: SkillData) -> Color:
	return COLORS[element()] if sk.id in ELEMENT_SKILLS else sk.color


func element_for(sk: SkillData) -> String:
	return TAGS[element()] if sk.id in ELEMENT_SKILLS else ""


func shape_hit(hit: Dictionary, target: Fighter) -> void:
	var el := str(hit.get("element", ""))
	var dmg := float(hit.get("dmg", 0.0))
	match el:
		"fire":
			dmg *= 1.2
			if target.has_status("slow"):
				dmg *= 1.5
				target.status_t.erase("slow")
				target.status_v.erase("slow")
				if f.world:
					f.world.fx("text", target.global_position + Vector2(0, -110), {"text": "SHATTER!", "color": Color("#ffd24a"), "size": 24})
					f.world.fx("burst", target.center(), {"color": Color("#9fe8ff"), "count": 16})
					f.world.shake(6.0)
			hit["status"] = "scorch"
			hit["status_dur"] = 1.5
		"frost":
			dmg *= 0.85
			hit["status"] = "slow"
			hit["status_dur"] = 1.8
		"storm":
			if target.has_status("slow"):
				hit["stun"] = maxf(float(hit.get("stun", 0.0)), 0.4)
	hit["dmg"] = dmg


func on_hit_dealt(hit: Dictionary, target: Fighter, dealt: float) -> void:
	if str(hit.get("element", "")) != "storm" or f.world == null:
		return
	for e in f.world.fighters:
		if e == target or e.team == f.team or e.is_dead():
			continue
		if e.global_position.distance_to(target.global_position) <= 220.0:
			e.receive_hit({"attacker": f, "dmg": dealt * 0.5, "kb": 0.0, "kb_up": 0.0, "stun": 0.0, "from_x": target.global_position.x, "source": "chain", "chain": true, "color": COLORS[2]})
			f.world.fx("bolt_line", target.center(), {"to": e.center(), "color": COLORS[2]})
			break


func hud_text() -> String:
	return NAMES[element()]
