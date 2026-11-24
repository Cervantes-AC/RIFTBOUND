class_name ClassData
extends Resource
## Data definition of a playable class (or a "planned" roster entry that is displayed but cannot be played). Loaded from resources/classes/classes.json.

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
@export var title := ""
@export var role := ""
@export var difficulty := 1
@export var lore := ""
@export var mech_id := ""
@export var mech_name := ""
@export var mech_desc := ""
@export var passive_name := ""
@export var passive_desc := ""
@export var strengths := ""
@export var weaknesses := ""
@export var strategy := ""
@export var planned := false       # designed but not implemented: shown as locked, never playable
var basic: SkillData
var mobility: SkillData
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
	c.title = str(d.get("title", ""))
	c.role = str(d.get("role", ""))
	c.difficulty = int(d.get("difficulty", 1))
	c.lore = str(d.get("lore", ""))
	c.mech_id = str(d.get("mech", ""))
	c.mech_name = str(d.get("mech_name", ""))
	c.mech_desc = str(d.get("mech_desc", ""))
	c.passive_name = str(d.get("passive_name", ""))
	c.passive_desc = str(d.get("passive_desc", ""))
	c.strengths = str(d.get("strengths", ""))
	c.weaknesses = str(d.get("weaknesses", ""))
	c.strategy = str(d.get("strategy", ""))
	c.planned = bool(d.get("planned", false))
	if c.planned:
		return c
	c.basic = skill_lookup[str(d["basic"])]
	c.mobility = skill_lookup[str(d["mobility"])]
	for sid in d.get("skills", []):
		c.skills.append(skill_lookup[str(sid)])
	return c
