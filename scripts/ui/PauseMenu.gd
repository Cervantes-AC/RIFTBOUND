class_name PauseMenu
extends CanvasLayer
## Pause overlay: Resume, Restart, Sound on/off, Music on/off, Quit to menu (lab requirement R10).

signal resume_pressed
signal restart_pressed
signal quit_pressed

var allow_restart := true
var guide_class := "vanguard"
var _sound_btn: Button
var _music_btn: Button


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.01, 0.06, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PixelUI.panel()
	panel.custom_minimum_size = Vector2(520, 0)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	box.add_child(PixelUI.label("PAUSED", 36, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var resume := PixelUI.button("RESUME", Color("#2f7a4a"), 20, Vector2(0, 66))
	resume.pressed.connect(func(): resume_pressed.emit())
	box.add_child(resume)
	var moves := PixelUI.button("MOVES & GUIDE", Color("#3a5aa8"), 18, Vector2(0, 60))
	moves.pressed.connect(func():
		AudioManager.play_sfx("click")
		MoveGuide.open(self, guide_class))
	box.add_child(moves)
	if allow_restart:
		var restart := PixelUI.button("RESTART", PixelUI.C_PANEL_LIGHT, 20, Vector2(0, 66))
		restart.pressed.connect(func(): restart_pressed.emit())
		box.add_child(restart)
	var toggles := HBoxContainer.new()
	toggles.add_theme_constant_override("separation", 12)
	box.add_child(toggles)
	_sound_btn = PixelUI.button("", PixelUI.C_PANEL_LIGHT, 16, Vector2(0, 64))
	_sound_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sound_btn.pressed.connect(func():
		SaveManager.set_setting("sound_on", not SaveManager.sound_on)
		AudioManager.play_sfx("click")
		_refresh())
	toggles.add_child(_sound_btn)
	_music_btn = PixelUI.button("", PixelUI.C_PANEL_LIGHT, 16, Vector2(0, 64))
	_music_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_music_btn.pressed.connect(func():
		SaveManager.set_setting("music_on", not SaveManager.music_on)
		_refresh())
	toggles.add_child(_music_btn)
	var quit := PixelUI.button("QUIT TO MENU", Color("#8a3a3a"), 18, Vector2(0, 66))
	quit.pressed.connect(func(): quit_pressed.emit())
	box.add_child(quit)
	_refresh()


func _refresh() -> void:
	_sound_btn.text = "SOUND: %s" % ("ON" if SaveManager.sound_on else "OFF")
	_music_btn.text = "MUSIC: %s" % ("ON" if SaveManager.music_on else "OFF")
