class_name ControlLayout
extends RefCounted
## Touch-control layouts. Each button is anchored to the bottom-right ("br") or bottom-left ("bl") corner of
## the screen and positioned by an offset, so layouts adapt to any aspect ratio / safe area.
## Presets: "standard" and "compact". Dragging a button in the control editor switches to "custom",
## which stores one offset per button in SaveManager.ctl_custom (saved in user://save.cfg).

const NAMES := ["attack", "special", "signature", "mobility", "ultimate"]   # jump = push the stick up
const ACTIONS := {"attack": "attack", "special": "skill1", "signature": "skill2", "mobility": "dodge", "ultimate": "skill3"}
const LABELS := {"attack": "ATTACK", "special": "SPECIAL", "signature": "SIGNATURE", "mobility": "MOBILITY", "ultimate": "ULTIMATE"}
const PRESETS := {
	"standard": {
		"attack": {"anchor": "br", "o": Vector2(-120, -108), "r": 62.0},
		"mobility": {"anchor": "br", "o": Vector2(-96, -252), "r": 46.0},
		"signature": {"anchor": "br", "o": Vector2(-232, -222), "r": 46.0},
		"special": {"anchor": "br", "o": Vector2(-266, -96), "r": 46.0},
		"ultimate": {"anchor": "br", "o": Vector2(-392, -190), "r": 44.0},
	},
	"compact": {
		"attack": {"anchor": "br", "o": Vector2(-100, -96), "r": 54.0},
		"mobility": {"anchor": "br", "o": Vector2(-82, -212), "r": 40.0},
		"signature": {"anchor": "br", "o": Vector2(-190, -186), "r": 40.0},
		"special": {"anchor": "br", "o": Vector2(-214, -84), "r": 40.0},
		"ultimate": {"anchor": "br", "o": Vector2(-304, -150), "r": 38.0},
	},
}
const MIN_SCALE := 0.7
const MAX_SCALE := 1.35


static func preset_names() -> Array:
	return ["standard", "compact"]


## Resolved button specs for the current settings: name -> {anchor, o (scaled offset), r (scaled radius)}.
static func resolve(preset: String, custom: Dictionary, scale: float) -> Dictionary:
	var base: Dictionary = PRESETS.get(preset, PRESETS["standard"])
	var out := {}
	for n in NAMES:
		var spec: Dictionary = base[n] if preset != "custom" or not custom.has(n) else {"anchor": base[n]["anchor"], "o": _to_vec(custom[n]), "r": base[n]["r"]}
		out[n] = {"anchor": spec["anchor"], "o": (spec["o"] as Vector2) * scale, "r": float(spec["r"]) * scale}
	return out


static func _to_vec(v: Variant) -> Vector2:
	if v is Vector2:
		return v
	if v is Array and v.size() >= 2:
		return Vector2(float(v[0]), float(v[1]))
	return Vector2.ZERO


## Screen position of a resolved button for a given screen size and left/right safe insets.
static func center(spec: Dictionary, screen: Vector2, insets: Vector2) -> Vector2:
	var o: Vector2 = spec["o"]
	if spec["anchor"] == "br":
		return Vector2(screen.x - insets.y, screen.y) + o
	return Vector2(insets.x, screen.y) + o


## Inverse of `center`: the unscaled offset to store for a button dropped at `pos`.
static func offset_for(anchor: String, pos: Vector2, screen: Vector2, insets: Vector2, scale: float) -> Vector2:
	var origin := Vector2(screen.x - insets.y, screen.y) if anchor == "br" else Vector2(insets.x, screen.y)
	return (pos - origin) / maxf(scale, 0.01)


## True if no two buttons overlap (used by the tests for every preset).
static func overlaps(specs: Dictionary, screen: Vector2) -> Array:
	var bad := []
	for i in NAMES.size():
		for j in range(i + 1, NAMES.size()):
			var a: Dictionary = specs[NAMES[i]]
			var b: Dictionary = specs[NAMES[j]]
			if center(a, screen, Vector2.ZERO).distance_to(center(b, screen, Vector2.ZERO)) < float(a["r"]) + float(b["r"]) + 6.0:
				bad.append("%s/%s" % [NAMES[i], NAMES[j]])
	return bad
