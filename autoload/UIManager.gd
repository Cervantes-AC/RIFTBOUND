extends Node
## Scene transitions (fade), toast messages and haptics. Used by every screen.

signal back_requested

var _fade: ColorRect
var _toast_label: Label
var _toast_tween: Tween
var _busy := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_fade = ColorRect.new()
	_fade.color = Color(0.03, 0.02, 0.07, 1.0)
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.modulate.a = 0.0
	layer.add_child(_fade)
	_toast_label = PixelUI.label("", 16, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_toast_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_toast_label.add_theme_color_override("font_color", PixelUI.C_GOLD)
	_toast_label.position = Vector2(-400, 640)
	_toast_label.custom_minimum_size = Vector2(800, 0)
	_toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast_label.modulate.a = 0.0
	layer.add_child(_toast_label)


## Fade out, swap scene, fade in.
func go(path: String) -> void:
	if _busy:
		return
	_busy = true
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var t := create_tween()
	t.tween_property(_fade, "modulate:a", 1.0, 0.18)
	await t.finished
	get_tree().paused = false
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("UIManager: cannot load scene %s (%d)" % [path, err])
	await get_tree().process_frame
	await get_tree().process_frame
	var t2 := create_tween()
	t2.tween_property(_fade, "modulate:a", 0.0, 0.22)
	await t2.finished
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false


func toast(text: String, seconds: float = 2.4) -> void:
	_toast_label.text = text
	if _toast_tween:
		_toast_tween.kill()
	_toast_label.modulate.a = 1.0
	_toast_tween = create_tween()
	_toast_tween.tween_interval(seconds)
	_toast_tween.tween_property(_toast_label, "modulate:a", 0.0, 0.4)


func vibrate(ms: int = 40) -> void:
	if SaveManager.vibration_on and OS.has_feature("mobile"):
		Input.vibrate_handheld(ms)


func _notification(what: int) -> void:
	# Android back button (project setting quit_on_go_back is off, screens decide what "back" means)
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		back_requested.emit()
