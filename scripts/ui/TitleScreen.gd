extends Control
## Title screen: logo, two fighters facing off, "tap to start".

var _tap: Label
var _t := 0.0
var _logo: Control


func _ready() -> void:
	PixelUI.screen(self, 28, true)
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
	var logo := RiftLogo.new()
	logo.font_size = 88
	logo.sub_size = 30
	logo.set_anchors_preset(Control.PRESET_CENTER_TOP)
	logo.position = Vector2(-410, 50)
	add_child(logo)
	_logo = logo
	_tap = PixelUI.label("TAP TO START", 26, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_tap.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_tap.position = Vector2(-400, 400)
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
