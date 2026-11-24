extends Node
## Persistent offline progression + settings, stored with ConfigFile in user://save.cfg.
## Online matches never touch campaign progress (see record_match).

signal settings_changed

const MAX_LEVEL := 5
const DEFAULT_PATH := "user://save.cfg"

var save_path: String = DEFAULT_PATH

# Campaign progress
var highest_unlocked: int = 1
var best_stars: Dictionary = {}  # level id (int) -> stars (int)
# Statistics
var matches_played: int = 0
var wins: int = 0
var losses: int = 0
var online_matches: int = 0
var online_wins: int = 0
# Settings
var sound_on: bool = true
var music_on: bool = true
var vibration_on: bool = true
var master_volume: float = 0.8
var music_volume: float = 0.6
var sfx_volume: float = 0.8
var last_ip: String = ""
var player_class: String = "vanguard"


func _ready() -> void:
	load_save()


## Pure helper so tests/UI use the same rule: 1 star = clear, 2 = >=30% health, 3 = >=60% health.
static func stars_for_health(health_ratio: float) -> int:
	if health_ratio >= 0.6:
		return 3
	if health_ratio >= 0.3:
		return 2
	return 1


func reset_to_defaults() -> void:
	highest_unlocked = 1
	best_stars = {}
	matches_played = 0
	wins = 0
	losses = 0
	online_matches = 0
	online_wins = 0
	sound_on = true
	music_on = true
	vibration_on = true
	master_volume = 0.8
	music_volume = 0.6
	sfx_volume = 0.8
	last_ip = ""
	player_class = "vanguard"


func load_save() -> void:
	reset_to_defaults()
	var cfg := ConfigFile.new()
	if cfg.load(save_path) != OK:
		return  # fresh install: defaults (only level 1 unlocked)
	highest_unlocked = clampi(int(cfg.get_value("progress", "highest_unlocked", 1)), 1, MAX_LEVEL)
	for lvl in range(1, MAX_LEVEL + 1):
		var s := clampi(int(cfg.get_value("stars", "level_%d" % lvl, 0)), 0, 3)
		if s > 0:
			best_stars[lvl] = s
	# Anti-tamper / corruption guard: you cannot be unlocked past (highest cleared + 1).
	var highest_cleared := 0
	for lvl in best_stars:
		highest_cleared = maxi(highest_cleared, int(lvl))
	highest_unlocked = mini(highest_unlocked, mini(highest_cleared + 1, MAX_LEVEL))
	highest_unlocked = maxi(highest_unlocked, 1)
	matches_played = int(cfg.get_value("stats", "matches_played", 0))
	wins = int(cfg.get_value("stats", "wins", 0))
	losses = int(cfg.get_value("stats", "losses", 0))
	online_matches = int(cfg.get_value("stats", "online_matches", 0))
	online_wins = int(cfg.get_value("stats", "online_wins", 0))
	sound_on = bool(cfg.get_value("settings", "sound_on", true))
	music_on = bool(cfg.get_value("settings", "music_on", true))
	vibration_on = bool(cfg.get_value("settings", "vibration_on", true))
	master_volume = clampf(float(cfg.get_value("settings", "master_volume", 0.8)), 0.0, 1.0)
	music_volume = clampf(float(cfg.get_value("settings", "music_volume", 0.6)), 0.0, 1.0)
	sfx_volume = clampf(float(cfg.get_value("settings", "sfx_volume", 0.8)), 0.0, 1.0)
	last_ip = str(cfg.get_value("settings", "last_ip", ""))
	player_class = str(cfg.get_value("settings", "player_class", "vanguard"))


func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "highest_unlocked", highest_unlocked)
	cfg.set_value("progress", "total_stars", total_stars())
	for lvl in range(1, MAX_LEVEL + 1):
		cfg.set_value("stars", "level_%d" % lvl, get_stars(lvl))
	cfg.set_value("stats", "matches_played", matches_played)
	cfg.set_value("stats", "wins", wins)
	cfg.set_value("stats", "losses", losses)
	cfg.set_value("stats", "online_matches", online_matches)
	cfg.set_value("stats", "online_wins", online_wins)
	cfg.set_value("settings", "sound_on", sound_on)
	cfg.set_value("settings", "music_on", music_on)
	cfg.set_value("settings", "vibration_on", vibration_on)
	cfg.set_value("settings", "master_volume", master_volume)
	cfg.set_value("settings", "music_volume", music_volume)
	cfg.set_value("settings", "sfx_volume", sfx_volume)
	cfg.set_value("settings", "last_ip", last_ip)
	cfg.set_value("settings", "player_class", player_class)
	var err := cfg.save(save_path)
	if err != OK:
		push_warning("SaveManager: could not write %s (error %d)" % [save_path, err])


func is_level_unlocked(level_id: int) -> bool:
	return level_id >= 1 and level_id <= MAX_LEVEL and (level_id == 1 or level_id <= highest_unlocked)


func get_stars(level_id: int) -> int:
	return int(best_stars.get(level_id, 0))


func total_stars() -> int:
	var t := 0
	for lvl in best_stars:
		t += int(best_stars[lvl])
	return t


## Called by the campaign result flow only. Saves immediately.
func complete_level(level_id: int, stars: int) -> void:
	if level_id < 1 or level_id > MAX_LEVEL:
		return
	stars = clampi(stars, 1, 3)
	if stars > get_stars(level_id):
		best_stars[level_id] = stars
	highest_unlocked = maxi(highest_unlocked, mini(level_id + 1, MAX_LEVEL))
	save()


## online matches are tallied separately and never change campaign progress.
func record_match(won: bool, online: bool, campaign_or_quick: bool = true) -> void:
	if online:
		online_matches += 1
		if won:
			online_wins += 1
	elif campaign_or_quick:
		matches_played += 1
		if won:
			wins += 1
		else:
			losses += 1
	save()


func set_setting(key: String, value: Variant) -> void:
	set(key, value)
	save()
	settings_changed.emit()
