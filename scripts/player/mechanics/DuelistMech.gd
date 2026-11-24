class_name DuelistMech
extends Mechanic
## MOMENTUM: every hit adds a stack (max 5): +5% damage, +3% speed each. Getting hit halves the stacks.
## Passive Riposte Footwork: each hit shortens the Sidestep cooldown by 0.25s.

var stacks := 0
var _t := 0.0


func setup() -> void:
	label = "MOMENTUM"
	color = Color("#f2d27a")


func tick(dt: float) -> void:
	if stacks > 0:
		_t -= dt
		if _t <= 0.0:
			stacks = 0
			res = 0.0


func on_hit_dealt(_hit: Dictionary, _target: Fighter, _dealt: float) -> void:
	stacks = mini(stacks + 1, 5)
	_t = 3.0
	res = stacks * 20.0
	f.skills.cooldown_left[4] = maxf(f.skills.cooldown_left[4] - 0.25, 0.0)


func on_damaged(_dealt: float, _hit: Dictionary) -> void:
	stacks /= 2
	res = stacks * 20.0


func on_use(_slot: int, sk: SkillData) -> void:
	if sk.id == "phantom_step" and stacks >= 3:
		f.skills.cooldown_left[1] = 0.0   # refund Quick Slash


func outgoing_bonus() -> float:
	return 1.0 + 0.05 * stacks


func speed_bonus() -> float:
	return 1.0 + 0.03 * stacks


func apply(a: Array) -> void:
	super.apply(a)
	stacks = int(round(res / 20.0))


func hud_text() -> String:
	return "x%d" % stacks
