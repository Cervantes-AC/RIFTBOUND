class_name HealthComponent
extends Node
## Hit points. Health can never go below zero or above max.

signal changed(current: float, maximum: float)
signal died

var max_health: float = 100.0
var current: float = 100.0


func setup(max_hp: float) -> void:
	max_health = max_hp
	current = max_hp
	changed.emit(current, max_health)


func is_dead() -> bool:
	return current <= 0.0


func ratio() -> float:
	return current / maxf(max_health, 0.001)


## Returns the damage actually removed (0 if already dead).
func apply_damage(amount: float) -> float:
	if current <= 0.0 or amount <= 0.0:
		return 0.0
	var before := current
	current = maxf(current - amount, 0.0)
	changed.emit(current, max_health)
	if current <= 0.0:
		died.emit()
	return before - current


func heal(amount: float) -> void:
	if current <= 0.0:
		return
	current = minf(current + amount, max_health)
	changed.emit(current, max_health)


func set_current(value: float) -> void:
	var was_dead := current <= 0.0
	current = clampf(value, 0.0, max_health)
	changed.emit(current, max_health)
	if current <= 0.0 and not was_dead:
		died.emit()
