class_name ReaperMech
extends Mechanic
## SOULS: every hit gathers Souls (+8, Soul Rend +10 more). Spend them on Soul Siphon (heal) or hit with Soul Rend (burst).
## ALL healing (Soul Tithe, Siphon, Death's Harvest) shares one limit: 25 HP per ~10 seconds (BUDGET, recovering 2.5/s).
## Passive Soul Tithe: basic attacks heal 8% of the damage they deal.

const BUDGET := 25.0

var spent := 0.0
var _quiet := 0.0
var _used := 0.0


func setup() -> void:
	label = "SOULS"
	color = Color("#ff5a6a")


func tick(dt: float) -> void:
	_used = maxf(_used - 2.5 * dt, 0.0)
	_quiet += dt
	if _quiet > 6.0:
		res = maxf(res - 3.0 * dt, 0.0)


func can_use(_slot: int, sk: SkillData) -> bool:
	return sk.kind != "siphon" or res >= float(sk.p("min", 30))


func on_use(_slot: int, sk: SkillData) -> void:
	if sk.kind == "siphon":
		spent = res
		res = 0.0


## Heals the Reaper, limited by the shared budget. Returns the HP actually restored.
func heal(amount: float) -> float:
	var h := minf(minf(amount, maxf(BUDGET - _used, 0.0)), f.health.max_health - f.health.current)
	if h <= 0.0 or f.is_dead():
		return 0.0
	f.health.current += h
	f.health.changed.emit(f.health.current, f.health.max_health)
	_used += h
	if f.world and h >= 2.0:
		f.world.fx("text", f.global_position + Vector2(0, -120), {"text": "+%d" % int(round(h)), "color": Color("#7fe8a0"), "size": 20})
	return h


func on_hit_dealt(hit: Dictionary, _target: Fighter, dealt: float) -> void:
	var src := str(hit.get("source", ""))
	var s := Library.get_skill(src)
	res = minf(res + 8.0 + (float(s.p("bonus_souls", 0)) if s != null else 0.0), max_res)
	_quiet = 0.0
	if src == "reaper_basic":
		heal(dealt * 0.08)
	elif s != null and float(s.p("lifesteal", 0)) > 0.0:
		heal(dealt * float(s.p("lifesteal", 0)))


func hud_text() -> String:
	return "%d" % int(res)
