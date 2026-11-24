class_name Mechanic
extends RefCounted
## Per-class signature mechanic (Bulwark, Momentum, Hunter's Mark, Ammo, Elements, Shadow).
## One instance per Fighter. The Fighter calls these hooks, so the shared movement/combat code stays
## identical for every class. Only the authority (offline game / online host) mutates state;
## guests receive `serialize()` data through the snapshot and only use it for HUD and visuals.

var f: Fighter
var res := 0.0            # primary resource value (HUD bar = res / max_res)
var max_res := 100.0
var aux := 0.0            # secondary value (element index, echo timer, reload timer ...)
var extra := 0.0          # third synced value (echo x position ...)
var label := ""           # HUD label
var color := Color.WHITE
var fire_mult := 1.0      # damage multiplier for the skill currently being fired


static func create(id: String, fighter: Fighter) -> Mechanic:
	var m: Mechanic
	match id:
		"vanguard":
			m = VanguardMech.new()
		"duelist":
			m = DuelistMech.new()
		"ranger":
			m = RangerMech.new()
		"gunslinger":
			m = GunslingerMech.new()
		"arcanist":
			m = ArcanistMech.new()
		"shadeweaver":
			m = ShadeweaverMech.new()
		_:
			m = Mechanic.new()
	m.f = fighter
	m.setup()
	return m


func setup() -> void:
	pass


func tick(_dt: float) -> void:
	pass


## Resource gate: can this skill be used right now (cooldown/ultimate meter are checked by the Fighter)?
func can_use(_slot: int, _sk: SkillData) -> bool:
	return true


## Pays the cost / records state when a skill starts.
func on_use(_slot: int, _sk: SkillData) -> void:
	pass


func begin_fire(_sk: SkillData) -> void:
	fire_mult = 1.0


func end_fire() -> void:
	fire_mult = 1.0


## Attacker side, before damage is applied. May edit `hit` (dmg, status, stun ...).
func shape_hit(_hit: Dictionary, _target: Fighter) -> void:
	pass


## Attacker side, after the hit connected.
func on_hit_dealt(_hit: Dictionary, _target: Fighter, _dealt: float) -> void:
	pass


## Defender side, before damage is applied.
func filter_incoming(_hit: Dictionary) -> void:
	pass


func on_damaged(_dealt: float, _hit: Dictionary) -> void:
	pass


func outgoing_bonus() -> float:
	return 1.0


func speed_bonus() -> float:
	return 1.0


## Tint for projectiles / hits of a skill (Arcanist changes colour with the element).
func hit_color(sk: SkillData) -> Color:
	return sk.color


## Tag stored in hit dictionaries ("fire", "frost", ...) for combo rules.
func element_for(_sk: SkillData) -> String:
	return ""


func fraction() -> float:
	return clampf(res / maxf(max_res, 0.01), 0.0, 1.0)


func hud_text() -> String:
	return ""


func serialize() -> Array:
	return [res, aux, extra]


func apply(a: Array) -> void:
	res = float(a[0])
	aux = float(a[1])
	extra = float(a[2])


func is_still() -> bool:
	return f.is_on_floor() and absf(f.velocity.x) < 20.0 and f.state == Fighter.State.IDLE
