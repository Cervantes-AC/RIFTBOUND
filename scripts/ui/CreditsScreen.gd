extends Control
## Credits. Keep in sync with docs/CREDITS.md.

const LINES := [
	["RIFTBOUND: ARENA CLASH", 26, "#ffd24a"],
	["ITSD 85 laboratory project", 12, "#9d92c4"],
	["", 10, "#ffffff"],
	["DEVELOPER", 14, "#b04cff"],
	["Aaron Clyde C. Cervantes", 12, "#f4efff"],
	["", 10, "#ffffff"],
	["ENGINE", 14, "#b04cff"],
	["Godot Engine 4 - MIT license", 12, "#f4efff"],
	["godotengine.org", 10, "#9d92c4"],
	["", 10, "#ffffff"],
	["FONT", 14, "#b04cff"],
	["Press Start 2P", 12, "#f4efff"],
	["(c) 2012 The Press Start 2P Project Authors", 10, "#9d92c4"],
	["SIL Open Font License 1.1", 10, "#9d92c4"],
	["", 10, "#ffffff"],
	["ART (placeholder)", 14, "#b04cff"],
	["All characters, arenas, icons and effects are", 10, "#f4efff"],
	["original procedural pixel art drawn by code.", 10, "#f4efff"],
	["", 10, "#ffffff"],
	["AUDIO (placeholder)", 14, "#b04cff"],
	["All sound effects and music are synthesised", 10, "#f4efff"],
	["at runtime by the game. No third-party audio.", 10, "#f4efff"],
	["", 10, "#ffffff"],
	["Thanks for playing!", 16, "#ffd24a"],
]


func _ready() -> void:
	var m := PixelUI.screen(self)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	m.add_child(v)
	v.add_child(PixelUI.label("CREDITS", 36, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 6)
	scroll.add_child(box)
	for line in LINES:
		var l := PixelUI.label(line[0], line[1], Color(line[2]), HORIZONTAL_ALIGNMENT_CENTER)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.add_child(l)
	var back := PixelUI.button("BACK", PixelUI.C_PANEL_LIGHT, 18, Vector2(220, 60))
	back.pressed.connect(_on_back)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(back)
	UIManager.back_requested.connect(_on_back)


func _exit_tree() -> void:
	if UIManager.back_requested.is_connected(_on_back):
		UIManager.back_requested.disconnect(_on_back)


func _on_back() -> void:
	AudioManager.play_sfx("back")
	UIManager.go("res://scenes/ui/MainMenu.tscn")
