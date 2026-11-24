class_name PixelUI
extends RefCounted
## Shared look-and-feel helpers: hard-edged "pixel" panels and buttons, palette, font.

const MIN_FONT := 14
const FONT: Font = preload("res://assets/fonts/PressStart2P-Regular.ttf")

const C_BG := Color("#0d0a1a")
const C_PANEL := Color("#1d1533")
const C_PANEL_LIGHT := Color("#2c2250")
const C_BORDER := Color("#08050f")
const C_EDGE := Color("#7a5cff")
const C_TEXT := Color("#f4efff")
const C_DIM := Color("#9d92c4")
const C_GOLD := Color("#ffd24a")
const C_RED := Color("#e8484f")
const C_GREEN := Color("#4fd36b")
const C_RIFT := Color("#b04cff")


static func box(bg: Color, edge: Color = C_BORDER, border: int = 4, shadow: int = 4) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = edge
	s.set_border_width_all(border)
	s.set_corner_radius_all(0)
	s.anti_aliasing = false
	s.shadow_color = Color(0, 0, 0, 0.55)
	s.shadow_size = 0
	s.shadow_offset = Vector2(0, shadow)
	if shadow > 0:
		s.shadow_size = 1
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s


static func style_button(b: Button, color: Color = C_PANEL_LIGHT, font_size: int = 18) -> void:
	b.add_theme_font_override("font", FONT)
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", C_TEXT)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", C_GOLD)
	b.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.58))
	b.add_theme_constant_override("outline_size", 4)
	b.add_theme_color_override("font_outline_color", C_BORDER)
	b.add_theme_stylebox_override("normal", box(color, C_EDGE))
	b.add_theme_stylebox_override("hover", box(color.lightened(0.18), C_GOLD))
	var pressed := box(color.darkened(0.2), C_GOLD, 4, 0)
	pressed.content_margin_top = 14
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("disabled", box(color.darkened(0.55), Color(0.2, 0.2, 0.25)))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


static func button(text: String, color: Color = C_PANEL_LIGHT, font_size: int = 18, min_size: Vector2 = Vector2(0, 64)) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	style_button(b, color, font_size)
	return b


static func panel(color: Color = C_PANEL, edge: Color = C_EDGE) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", box(color, edge))
	return p


static func label(text: String, size: int = 16, color: Color = C_TEXT, align: int = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	size = maxi(size, MIN_FONT)  # readable on small phone screens (lab R10)
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = align as HorizontalAlignment
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_constant_override("outline_size", maxi(2, size / 6))
	l.add_theme_color_override("font_outline_color", C_BORDER)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	return l


static func wrap_label(text: String, size: int = 16, color: Color = C_TEXT, align: int = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := label(text, size, color, align)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


## Full-rect screen root with the animated rift backdrop; returns the content margin container.
static func screen(owner_control: Control, margin_v: int = 28) -> MarginContainer:
	owner_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bd := MenuBackdrop.new()
	owner_control.add_child(bd)
	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		m.add_theme_constant_override("margin_" + side, 56)
	m.add_theme_constant_override("margin_top", margin_v)
	m.add_theme_constant_override("margin_bottom", margin_v)
	owner_control.add_child(m)
	return m


static func class_color(class_id: String) -> Color:
	return Library.get_class_data(class_id).color


## Left/right insets (in canvas pixels) for phone notches / rounded corners. Zero on desktop.
static func safe_insets(vp: Viewport) -> Vector2:
	if not OS.has_feature("mobile"):
		return Vector2.ZERO
	var win := DisplayServer.window_get_size()
	var safe := DisplayServer.get_display_safe_area()
	if win.x <= 0 or safe.size.x <= 0:
		return Vector2.ZERO
	var k := vp.get_visible_rect().size.x / float(win.x)
	return Vector2(maxf(safe.position.x * k, 0.0), maxf((win.x - safe.end.x) * k, 0.0))
