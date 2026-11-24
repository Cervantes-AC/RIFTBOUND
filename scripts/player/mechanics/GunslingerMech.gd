class_name GunslingerMech
extends Mechanic
## AMMO: six rounds. Pistol 1, Quick Burst 3, Explosive Round 2. Empty = 1.6s forced reload.
## Rounds also trickle back after 1.2s without shooting. Passive Quick Draw: Tactical Roll reloads 2.

var _idle := 0.0


func setup() -> void:
	label = "AMMO"
	color = Color("#ffd66b")
	max_res = 6.0
	res = 6.0


func tick(dt: float) -> void:
	if aux > 0.0:
		aux -= dt
		if aux <= 0.0:
			res = max_res
		return
	_idle += dt
	if res < max_res and _idle > 1.0:
		res = minf(res + dt / 0.25, max_res)


func _cost(sk: SkillData) -> float:
	return float(sk.p("cost", 0))


func can_use(_slot: int, sk: SkillData) -> bool:
	var c := _cost(sk)
	if c <= 0.0 or f.has_status("deadeye"):
		return true
	return aux <= 0.0 and res >= c


func on_use(slot: int, sk: SkillData) -> void:
	if slot == 4 and float(sk.p("reload", 0)) > 0.0:
		res = minf(res + float(sk.p("reload", 0)), max_res)
		aux = 0.0
		return
	var c := _cost(sk)
	if c > 0.0 and not f.has_status("deadeye"):
		res -= c
		_idle = 0.0
		if res < 1.0:
			res = 0.0
			aux = 1.6   # forced reload
	elif c > 0.0:
		_idle = 0.0


func outgoing_bonus() -> float:
	return 1.25 if f.has_status("deadeye") else 1.0


func hud_text() -> String:
	return "RELOAD" if aux > 0.0 else "%d/6" % int(res)
