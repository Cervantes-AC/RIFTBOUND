class_name SkillData
extends Resource
## Data definition of one attack/skill. Loaded from resources/skills/skills.json.
## `kind` selects the behaviour implemented in SkillExecutor; every other tunable lives in `params`.

@export var id: String = ""
@export var display_name: String = ""
@export var kind: String = "melee"
@export var cooldown: float = 1.0
@export var damage: float = 5.0
@export var windup: float = 0.1
@export var recover: float = 0.2
@export var color: Color = Color.WHITE
@export var icon: String = ""
@export var params: Dictionary = {}


static func from_dict(skill_id: String, d: Dictionary) -> SkillData:
	var s := SkillData.new()
	s.id = skill_id
	s.display_name = str(d.get("name", skill_id))
	s.kind = str(d.get("kind", "melee"))
	s.cooldown = float(d.get("cd", 1.0))
	s.damage = float(d.get("dmg", 0.0))
	s.windup = float(d.get("windup", 0.1))
	s.recover = float(d.get("recover", 0.2))
	s.color = Color.from_string(str(d.get("color", "#ffffff")), Color.WHITE)
	s.icon = str(d.get("icon", ""))
	s.params = d
	return s


func p(key: String, default: Variant = 0.0) -> Variant:
	return params.get(key, default)
