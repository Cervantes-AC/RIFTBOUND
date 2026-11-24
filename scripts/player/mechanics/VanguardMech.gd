class_name VanguardMech
extends Mechanic
## BULWARK: damage taken charges the meter; Retaliate spends all of it for a counter-strike.
## Passive Stalwart: -25% knockback, and -10% damage while Bulwark >= 50.

var spent := 0.0
var _quiet := 0.0


func setup() -> void:
	label = "BULWARK"
	color = Color("#6fb0ff")


func tick(dt: float) -> void:
	_quiet += dt
	if _quiet > 3.0:
		res = maxf(res - 5.0 * dt, 0.0)


func can_use(_slot: int, sk: SkillData) -> bool:
	return sk.kind != "retaliate" or res >= float(sk.p("min", 30))


func on_use(_slot: int, sk: SkillData) -> void:
	if sk.kind == "retaliate":
		spent = res
		res = 0.0


func filter_incoming(hit: Dictionary) -> void:
	hit["kb"] = float(hit.get("kb", 0.0)) * 0.75
	hit["kb_up"] = float(hit.get("kb_up", 0.0)) * 0.75
	if res >= 50.0:
		hit["dmg"] = float(hit.get("dmg", 0.0)) * 0.9


func on_damaged(dealt: float, _hit: Dictionary) -> void:
	res = minf(res + dealt * 1.3 + 2.0, max_res)
	_quiet = 0.0


func on_hit_dealt(hit: Dictionary, _target: Fighter, _dealt: float) -> void:
	if str(hit.get("source", "")) == "vanguard_basic":
		res = minf(res + 4.0, max_res)
		_quiet = 0.0


func hud_text() -> String:
	return "%d" % int(res)
