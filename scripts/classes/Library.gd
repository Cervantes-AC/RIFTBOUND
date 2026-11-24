class_name Library
extends RefCounted
## Static access to all game data (classes, skills, campaign levels). Loaded once, lazily.

const CLASSES_PATH := "res://resources/classes/classes.json"
const SKILLS_PATH := "res://resources/skills/skills.json"
const LEVELS_PATH := "res://resources/levels/levels.json"
const CLASS_ORDER := ["vanguard", "duelist", "ranger", "gunslinger", "arcanist", "shadeweaver",
	"riftblade", "warden", "stormcaller", "reaper", "chronomancer", "beastbound"]   # playable
const PLANNED_ORDER := []   # designed but not implemented (none at the moment)

static var _loaded := false
static var _skills: Dictionary = {}
static var _classes: Dictionary = {}
static var _levels: Array = []


static func _read_json(path: String) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Library: cannot open %s" % path)
		return null
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed == null:
		push_error("Library: invalid JSON in %s" % path)
	return parsed


static func ensure_loaded() -> void:
	if _loaded:
		return
	var skills_raw: Dictionary = _read_json(SKILLS_PATH)
	for sid in skills_raw:
		_skills[sid] = SkillData.from_dict(sid, skills_raw[sid])
	var classes_raw: Dictionary = _read_json(CLASSES_PATH)
	for cid in classes_raw:
		_classes[cid] = ClassData.from_dict(cid, classes_raw[cid], _skills)
	_levels = _read_json(LEVELS_PATH)
	_loaded = true


static func get_class_data(class_id: String) -> ClassData:
	ensure_loaded()
	return _classes.get(class_id, _classes["vanguard"])


static func class_ids() -> Array:
	ensure_loaded()
	return CLASS_ORDER


## All roster entries in display order: playable first, then any planned ones.
static func roster_ids() -> Array:
	ensure_loaded()
	return CLASS_ORDER + PLANNED_ORDER


static func get_skill(skill_id: String) -> SkillData:
	ensure_loaded()
	return _skills.get(skill_id)


static func level_count() -> int:
	ensure_loaded()
	return _levels.size()


static func get_level(level_id: int) -> Dictionary:
	ensure_loaded()
	for l in _levels:
		if int(l["id"]) == level_id:
			return l
	return {}
