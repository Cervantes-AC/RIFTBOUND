class_name PixelBox
extends StyleBox
## Chunky bevelled pixel-art panel/button frame: notched corners, edge colour, top highlight, bottom shade,
## and a hard drop shadow (dropped when `pressed`, so the button visibly sinks).

var color := Color("#2c2250")
var edge := Color("#7a5cff")
var pressed := false
var ring_only := false           # focus frame: only the gold ring, button stays visible
var glow := 0.0                 # 0..1 extra edge brightness (hover / focus pulse)
const OUTLINE := Color("#08050f")
const B := 4.0                  # border thickness (one "pixel")


static func make(fill: Color, edge_color: Color, is_pressed := false, margin_v := 10.0) -> PixelBox:
	var s := PixelBox.new()
	s.color = fill
	s.edge = edge_color
	s.pressed = is_pressed
	s.content_margin_left = 16.0
	s.content_margin_right = 16.0
	s.content_margin_top = margin_v + (4.0 if is_pressed else 0.0)
	s.content_margin_bottom = margin_v + (0.0 if is_pressed else 4.0)
	return s


func _notched(ci: RID, r: Rect2, c: Color, n: float) -> void:
	RenderingServer.canvas_item_add_rect(ci, Rect2(r.position.x, r.position.y + n, r.size.x, r.size.y - n * 2.0), c)
	RenderingServer.canvas_item_add_rect(ci, Rect2(r.position.x + n, r.position.y, r.size.x - n * 2.0, r.size.y), c)


func _draw(ci: RID, rect: Rect2) -> void:
	if ring_only:
		for r in [Rect2(rect.position.x, rect.position.y, rect.size.x, 4), Rect2(rect.position.x, rect.end.y - 8, rect.size.x, 4), Rect2(rect.position.x, rect.position.y, 4, rect.size.y - 4), Rect2(rect.end.x - 4, rect.position.y, 4, rect.size.y - 4)]:
			RenderingServer.canvas_item_add_rect(ci, r, edge)
		return
	var body := Rect2(rect.position + Vector2(0, 4.0 if pressed else 0.0), rect.size - Vector2(0, 4.0))
	if not pressed:
		_notched(ci, Rect2(body.position + Vector2(0, 4), body.size), Color(0, 0, 0, 0.5), B)
	_notched(ci, body, OUTLINE, B)
	_notched(ci, body.grow(-B), edge.lightened(glow * 0.5), B * 0.5)
	var inner := body.grow(-B - 2.0)
	_notched(ci, inner, color, B * 0.5)
	# top highlight + bottom shade give the bevel
	RenderingServer.canvas_item_add_rect(ci, Rect2(inner.position.x + 2.0, inner.position.y, inner.size.x - 4.0, 4.0), color.lightened(0.22))
	RenderingServer.canvas_item_add_rect(ci, Rect2(inner.position.x + 2.0, inner.end.y - 4.0, inner.size.x - 4.0, 4.0), color.darkened(0.28))
