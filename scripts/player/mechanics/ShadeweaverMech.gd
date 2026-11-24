class_name ShadeweaverMech
extends Mechanic
## SHADOW: starts at 40, builds slowly (+2.5/s), quickly while moving (+10/s) and on hits (+6). Spent on Binding Chains and Shadow Echo.
## Shadow Echo: teleport forward leaving an echo (3s). Press again to swap back to it; an unused echo bursts.
## Passive Umbral Drift: +8% speed (+10% more at 50+ Shadow); basic attacks deal up to +40% as Shadow fills.

var swapping := false
var echo_pos := Vector2.ZERO


func setup() -> void:
	label = "SHADOW"
	color = Color("#d84ad0")
	extra = -9999.0
	res = 40.0


func tick(dt: float) -> void:
	res = minf(res + 2.5 * dt, max_res)   # slow baseline so a stationary Shadeweaver is never completely dry
	if absf(f.velocity.x) > 60.0:
		res = minf(res + 10.0 * dt, max_res)
	if aux > 0.0:
		aux -= dt
		if aux <= 0.0:
			_expire()


func _expire() -> void:
	extra = -9999.0
	if f.combat != null and not f.is_dead():
		f.combat.burst_at(echo_pos, 9.0, 95.0, color)


func can_use(_slot: int, sk: SkillData) -> bool:
	if sk.kind == "echo" and aux > 0.0:
		return true   # swap back is free
	return res >= float(sk.p("cost", 0))


func on_use(_slot: int, sk: SkillData) -> void:
	if sk.kind == "echo":
		swapping = aux > 0.0
		if not swapping:
			res -= float(sk.p("cost", 0))
		return
	var c := float(sk.p("cost", 0))
	if c > 0.0:
		res -= c
	res = minf(res + float(sk.p("gain", 0)), max_res)


func place_echo(pos: Vector2, life: float) -> void:
	echo_pos = pos
	aux = life
	extra = pos.x


func clear_echo() -> void:
	aux = 0.0
	extra = -9999.0


func begin_fire(sk: SkillData) -> void:
	fire_mult = 1.0 + res / 250.0 if sk.id == "shadeweaver_basic" else 1.0


func speed_bonus() -> float:
	return 1.08 + (0.1 if res >= 50.0 else 0.0)


func on_hit_dealt(_hit: Dictionary, _target: Fighter, _dealt: float) -> void:
	res = minf(res + 6.0, max_res)


func hud_text() -> String:
	return "ECHO" if aux > 0.0 else "%d" % int(res)
