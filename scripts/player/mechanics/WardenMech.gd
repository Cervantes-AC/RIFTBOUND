class_name WardenMech
extends Mechanic
## WARDS: Ward energy (+3/s) pays for Guardian Ward, a zone where allies (and you) take less damage.
## The ultimate dome is bigger and stronger. Passive Guardian Link: allies within 300px take 10% less damage.
## Synced state: aux = ward time left, extra = ward x (+10000 marks the large dome so guests can draw its radius).

var ward_x := 0.0
var ward_t := 0.0
var ward_r := 170.0
var ward_red := 0.35


func setup() -> void:
	label = "WARD"
	color = Color("#ffe28a")
	res = 60.0
	extra = -9999.0


func tick(dt: float) -> void:
	res = minf(res + 3.0 * dt, max_res)
	if ward_t > 0.0:
		ward_t -= dt
		aux = maxf(ward_t, 0.0)
		if ward_t <= 0.0:
			extra = -9999.0


func can_use(_slot: int, sk: SkillData) -> bool:
	return res >= float(sk.p("cost", 0))


func on_use(_slot: int, sk: SkillData) -> void:
	res -= float(sk.p("cost", 0))


func place_ward(x: float, life: float, radius: float, reduction: float) -> void:
	ward_x = x
	ward_t = life
	ward_r = radius
	ward_red = reduction
	aux = life
	extra = x + (10000.0 if radius > 200.0 else 0.0)


## Damage reduction (0..1) this Warden grants to `t` right now. Called by MatchManager on the authority only.
func ward_reduction_for(t: Fighter) -> float:
	if t.team != f.team or f.is_dead():
		return 0.0
	var r := 0.0
	if ward_t > 0.0 and absf(t.global_position.x - ward_x) <= ward_r:
		r = ward_red
	if t != f and t.global_position.distance_to(f.global_position) <= 300.0:
		r = maxf(r, 0.1)
	return r


## Visual helpers for guests (they only know aux / extra).
func vis_active() -> bool:
	return aux > 0.0 and extra > -9000.0


func vis_x() -> float:
	return extra - 10000.0 if extra >= 5000.0 else extra


func vis_radius() -> float:
	return 260.0 if extra >= 5000.0 else 170.0


func hud_text() -> String:
	return "WARD" if aux > 0.0 else "%d" % int(res)
