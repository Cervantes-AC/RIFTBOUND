class_name RangerMech
extends Mechanic
## HUNTER'S MARK: marked enemies take +25% from the Ranger and charge the ultimate faster.
## Passive Steady Aim: standing still 0.7s lines up the next basic arrow for +50% damage.

var _aim_boost := false


func setup() -> void:
	label = "FOCUS"
	color = Color("#9fff9a")


func tick(dt: float) -> void:
	if is_still():
		res = minf(res + dt / 0.7 * 100.0, 100.0)
	else:
		res = maxf(res - dt * 300.0, 0.0)


func on_use(slot: int, _sk: SkillData) -> void:
	if slot == 0 and res >= 100.0:
		_aim_boost = true
		res = 0.0


func begin_fire(sk: SkillData) -> void:
	fire_mult = 1.5 if (sk.id == "ranger_basic" and _aim_boost) else 1.0
	if sk.id == "ranger_basic":
		_aim_boost = false


func shape_hit(hit: Dictionary, target: Fighter) -> void:
	if target.has_status("mark"):
		hit["dmg"] = float(hit.get("dmg", 0.0)) * 1.25


func on_hit_dealt(_hit: Dictionary, target: Fighter, dealt: float) -> void:
	if target.has_status("mark"):
		f.ult_gain(dealt * 0.5)


func hud_text() -> String:
	return "AIMED" if res >= 100.0 else ""
