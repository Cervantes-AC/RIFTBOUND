class_name ClassData
extends Resource
## Data definition of a playable class. Loaded from resources/classes/classes.json.

@export var id: String = ""
@export var display_name: String = ""
@export var archetype: String = "Melee"
@export var description: String = ""
@export var color: Color = Color.WHITE
@export var accent: Color = Color.WHITE
@export var hair: Color = Color.BLACK
@export var weapon: String = "sword"
@export var max_health: float = 100.0
@export var move_speed: float = 240.0
@export var jump_velocity: float = 580.0
@export var max_jumps: int = 1
@export var dodge_cooldown: float = 1.0
@export var body_scale: float = 1.0
var basic: SkillData
var skills: Array[SkillData] = []


static func from_dict(class_id: String, d: Dictionary, skill_lookup: Dictionary) -> ClassData:
	var c := ClassData.new()
	c.id = class_id
	c.display_name = str(d.get("name", class_id))
	c.archetype = str(d.get("archetype", "Melee"))
	c.description = str(d.get("desc", ""))
	c.color = Color.from_string(str(d.get("color", "#ffffff")), Color.WHITE)
	c.accent = Color.from_string(str(d.get("accent", "#ffffff")), Color.WHITE)
	c.hair = Color.from_string(str(d.get("hair", "#000000")), Color.BLACK)
	c.weapon = str(d.get("weapon", "sword"))
	c.max_health = float(d.get("hp", 100))
	c.move_speed = float(d.get("speed", 240))
	c.jump_velocity = float(d.get("jump", 580))
	c.max_jumps = int(d.get("jumps", 1))
	c.dodge_cooldown = float(d.get("dodge_cd", 1.0))
	c.body_scale = float(d.get("size", 1.0))
	c.basic = skill_lookup[str(d["basic"])]
	for sid in d.get("skills", []):
		c.skills.append(skill_lookup[str(sid)])
	return c
