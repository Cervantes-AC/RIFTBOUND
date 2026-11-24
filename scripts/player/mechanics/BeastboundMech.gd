class_name BeastboundMech
extends Mechanic
## COMPANION: a wolf summoned for 10s. It follows you and bites the nearest enemy (5 dmg every 0.9s). Sic 'Em orders a lunge.
## Alpha Howl summons it and starts a 6s FRENZY (x2 damage, faster bites). The wolf is a lightweight host-simulated
## entity (no physics body): position = `extra`, time left = `res`, frenzy time = `aux` (all synced to guests).
## Passive Pack Bond: while the wolf is out you move 8% faster and deal 10% more damage.

const LIFE := 10.0
const BITE_RANGE := 85.0

var wolf_x := 0.0
var _bite := 0.0


func setup() -> void:
	label = "WOLF"
	color = Color("#e8c070")
	max_res = LIFE
	extra = -9999.0


func active() -> bool:
	return res > 0.0


func summon(life: float) -> void:
	if res <= 0.0:
		wolf_x = f.global_position.x - f.facing * 40.0
	res = minf(maxf(res, life), max_res)
	extra = wolf_x
	if f.world:
		f.world.fx("burst", Vector2(wolf_x, f.global_position.y - 20.0), {"color": color, "count": 14})


func can_use(_slot: int, sk: SkillData) -> bool:
	return sk.kind != "command" or active()


func outgoing_bonus() -> float:
	return 1.1 if active() else 1.0


func speed_bonus() -> float:
	return 1.08 if active() else 1.0


func tick(dt: float) -> void:
	if aux > 0.0:
		aux = maxf(aux - dt, 0.0)
	if res <= 0.0 or f.world == null:
		return
	res -= dt
	if res <= 0.0:
		res = 0.0
		extra = -9999.0
		f.world.fx("burst", Vector2(wolf_x, f.global_position.y - 20.0), {"color": color, "count": 10})
		return
	var frenzy := aux > 0.0
	var floor_y: float = f.world.arena.floor_y if f.world.arena else f.global_position.y
	var target: Fighter = null
	var best := 520.0
	for e in f.world.fighters:
		if e.team != f.team and not e.is_dead() and e.global_position.y >= floor_y - 130.0 and absf(e.global_position.x - wolf_x) < best:
			target = e
			best = absf(e.global_position.x - wolf_x)
	var goal := wolf_x
	if target != null:
		goal = target.global_position.x - signf(target.global_position.x - wolf_x) * 45.0
	elif absf(wolf_x - f.global_position.x) > 100.0:
		goal = f.global_position.x - f.facing * 60.0
	wolf_x = move_toward(wolf_x, goal, 340.0 * (1.5 if frenzy else 1.0) * dt)
	_bite -= dt
	if target != null and _bite <= 0.0 and absf(target.global_position.x - wolf_x) < BITE_RANGE:
		_bite = 0.5 if frenzy else 0.9
		var dmg := 5.0 * (2.0 if frenzy else 1.0) * f.outgoing_multiplier()
		var h := {"attacker": f, "dmg": dmg, "kb": 90.0, "kb_up": 40.0, "stun": 0.12, "from_x": wolf_x, "source": "wolf", "color": color}
		if target.receive_hit(h):
			f.world.on_hit_landed(f, target, h)
		f.world.fx("slash", Vector2(wolf_x, f.global_position.y - 30.0), {"dir": 1 if target.global_position.x > wolf_x else -1, "color": color, "w": 60.0})
	extra = wolf_x


func hud_text() -> String:
	if not active():
		return "NO WOLF"
	return "FRENZY" if aux > 0.0 else "%ds" % int(ceil(res))
