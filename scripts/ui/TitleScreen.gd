extends Control
## Title screen: logo, two fighters facing off, "tap to start".

var _tap: Label
var _t := 0.0
var _logo: Label


func _ready() -> void:
	PixelUI.screen(self)
	AudioManager.play_music("menu")
	var left := ClassPreview.new()
	left.position = Vector2(400, 610)
	left.scale = Vector2(2.4, 2.4)
	add_child(left)
	left.show_class("vanguard", 1)
	var right := ClassPreview.new()
	right.position = Vector2(880, 610)
	right.scale = Vector2(2.4, 2.4)
	add_child(right)
	right.show_class("arcanist", -1)
	_logo = PixelUI.label("RIFTBOUND", 88, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_logo.add_theme_constant_override("outline_size", 14)
	_logo.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_logo.position = Vector2(-500, 90)
	_logo.custom_minimum_size = Vector2(1000, 0)
	_logo.size = Vector2(1000, 110)
	_logo.pivot_offset = Vector2(500, 55)
	add_child(_logo)
	var sub := PixelUI.label("ARENA CLASH", 34, PixelUI.C_RIFT, HORIZONTAL_ALIGNMENT_CENTER)
	sub.add_theme_constant_override("outline_size", 8)
	sub.set_anchors_preset(Control.PRESET_CENTER_TOP)
	sub.position = Vector2(-400, 215)
	sub.custom_minimum_size = Vector2(800, 0)
	sub.size = Vector2(800, 50)
	add_child(sub)
	_tap = PixelUI.label("TAP TO START", 26, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_tap.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_tap.position = Vector2(-400, 330)
	_tap.custom_minimum_size = Vector2(800, 0)
	_tap.size = Vector2(800, 40)
	add_child(_tap)
	var ver := PixelUI.label("ITSD 85 lab project  -  Godot 4  -  v0.1", 14, PixelUI.C_DIM, HORIZONTAL_ALIGNMENT_CENTER)
	ver.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	ver.position = Vector2(-300, -34)
	ver.custom_minimum_size = Vector2(600, 0)
	ver.size = Vector2(600, 20)
	add_child(ver)
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.5)


func _process(delta: float) -> void:
	_t += delta
	_tap.modulate.a = 0.35 + 0.65 * absf(sin(_t * 2.4))
	_logo.scale = Vector2.ONE * (1.0 + 0.012 * sin(_t * 2.0))


func _gui_input(event: InputEvent) -> void:
	var go := false
	if event is InputEventMouseButton and event.pressed:
		go = true
	elif event is InputEventScreenTouch and event.pressed:
		go = true
	elif event is InputEventKey and event.pressed:
		go = true
	if go:
		AudioManager.play_sfx("click")
		set_process_input(false)
		UIManager.go("res://scenes/ui/MainMenu.tscn")
		accept_event()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		_gui_input(event)
