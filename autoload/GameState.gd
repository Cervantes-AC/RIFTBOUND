extends Node
## Global game state: the pending MatchConfig, last result and the match-setup helpers.
## MatchConfig layout (Dictionary):
##   mode: "campaign" | "quick" | "online"      arena: "forest"|"cavern"|"citadel"|"shadow"|"sanctuary"
##   time: float seconds   level_id: int (campaign)   objective: String   lose_text: String   hints: Array
##   local_slot: int       online_role: "" | "host" | "guest"
##   fighters: [ {slot, team, class_id, controller: "local"|"ai"|"remote"|"puppet", name, hp_mult, ai: {...}} ]

const MATCH_SCENE := "res://scenes/levels/Match.tscn"
const ARENA_IDS := ["forest", "cavern", "citadel", "shadow", "sanctuary"]
const ARENA_NAMES := {
	"forest": "Forgotten Forest", "cavern": "Molten Cavern", "citadel": "Frozen Citadel",
	"shadow": "Shadow Realm", "sanctuary": "Rift Sanctuary",
}
const ARENA_SCENES := {
	"forest": "ForgottenForest", "cavern": "MoltenCavern", "citadel": "FrozenCitadel",
	"shadow": "ShadowRealm", "sanctuary": "RiftSanctuary",
}
const AI_PRESETS := {
	"easy": {"reaction": 0.5, "aggression": 0.4, "speed": 0.9, "damage": 0.8, "dodge": 0.15, "skill": 0.3},
	"normal": {"reaction": 0.32, "aggression": 0.6, "speed": 1.0, "damage": 1.0, "dodge": 0.3, "skill": 0.5},
	"hard": {"reaction": 0.2, "aggression": 0.8, "speed": 1.08, "damage": 1.1, "dodge": 0.5, "skill": 0.75},
}

var pending_match: Dictionary = {}
var pending_flow: Dictionary = {}
var last_result: Dictionary = {}
var selected_class: String = "vanguard"
var quick_team_size: int = 1
var quick_difficulty: String = "normal"
var online_arena: String = "forest"
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_register_input_actions()
	selected_class = SaveManager.player_class


# ---------------------------------------------------------------- input map
func _register_input_actions() -> void:
	var defs := {
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN],
		"jump": [KEY_SPACE, KEY_K], "attack": [KEY_J, KEY_Z], "dodge": [KEY_L, KEY_X],
		"skill1": [KEY_U, KEY_1], "skill2": [KEY_I, KEY_2], "skill3": [KEY_O, KEY_3],
		"pause": [KEY_ESCAPE, KEY_P],
	}
	for action in defs:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in defs[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)


# ---------------------------------------------------------------- match setup
func _fighter(slot: int, team: int, class_id: String, controller: String, name: String, ai: Dictionary = {}, hp_mult: float = 1.0) -> Dictionary:
	return {"slot": slot, "team": team, "class_id": class_id, "controller": controller,
		"name": name, "ai": ai, "hp_mult": hp_mult}


## Builds the campaign config. Returns {} (and refuses to start) when the level is locked,
## so progression cannot be bypassed through direct scene loading either.
func build_campaign_config(level_id: int, player_class: String) -> Dictionary:
	if not SaveManager.is_level_unlocked(level_id):
		return {}
	var lvl := Library.get_level(level_id)
	if lvl.is_empty():
		return {}
	return {
		"mode": "campaign", "level_id": level_id, "arena": lvl["arena"], "time": float(lvl["time"]),
		"objective": lvl["objective"], "lose_text": lvl["lose_text"], "hints": lvl.get("hints", []),
		"level_name": lvl["name"], "local_slot": 0, "online_role": "",
		"fighters": [
			_fighter(0, 0, player_class, "local", "You"),
			_fighter(1, 1, lvl["enemy_class"], "ai", lvl["enemy_name"], lvl["ai"], float(lvl["enemy_hp_mult"])),
		],
	}


func build_quick_config(team_size: int, player_class: String, difficulty: String, arena: String) -> Dictionary:
	var ai: Dictionary = AI_PRESETS.get(difficulty, AI_PRESETS["normal"])
	var classes := Library.class_ids().duplicate()
	var fighters: Array = [_fighter(0, 0, player_class, "local", "You")]
	var slot := 1
	for i in range(team_size - 1):
		fighters.append(_fighter(slot, 0, classes[_rng.randi() % classes.size()], "ai", "Ally %d" % (i + 1), ai))
		slot += 1
	for i in range(team_size):
		fighters.append(_fighter(slot, 1, classes[_rng.randi() % classes.size()], "ai", "Rival %d" % (i + 1), ai))
		slot += 1
	var label := "%dv%d" % [team_size, team_size]
	return {
		"mode": "quick", "level_id": 0, "arena": arena, "time": 90.0 + 15.0 * (team_size - 1),
		"objective": "%s: eliminate every opponent before time runs out." % label,
		"lose_text": "Your team loses if all of you fall or the other team has more health when time ends.",
		"hints": [], "level_name": "%s - %s" % [label, ARENA_NAMES.get(arena, arena)],
		"local_slot": 0, "online_role": "", "fighters": fighters,
	}


func build_online_config(host_class: String, guest_class: String, arena: String, role: String) -> Dictionary:
	var is_host := role == "host"
	return {
		"mode": "online", "level_id": 0, "arena": arena, "time": 90.0,
		"objective": "Online duel: defeat your opponent!",
		"lose_text": "The host decides the winner.", "hints": [],
		"level_name": "Online Duel - %s" % ARENA_NAMES.get(arena, arena),
		"local_slot": 0 if is_host else 1, "online_role": role,
		"fighters": [
			_fighter(0, 0, host_class, "local" if is_host else "puppet", "Host"),
			_fighter(1, 1, guest_class, "remote" if is_host else "local_puppet", "Guest"),
		],
	}


func start_match(config: Dictionary) -> bool:
	if config.is_empty():
		UIManager.toast("That level is locked. Clear the previous level first!")
		return false
	pending_match = config
	UIManager.go(MATCH_SCENE)
	return true


func start_campaign_level(level_id: int, player_class: String) -> bool:
	selected_class = player_class
	SaveManager.set_setting("player_class", player_class)
	return start_match(build_campaign_config(level_id, player_class))
