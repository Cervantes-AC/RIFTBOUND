class_name SkillManager
extends Node
## Cooldown bookkeeping for the basic (0), special (1), signature (2), ultimate (3) and mobility (4).

const SLOTS := 5

var cooldown_left: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
var cooldown_total: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]


func is_ready(slot: int) -> bool:
	return cooldown_left[slot] <= 0.0


func start_cooldown(slot: int, seconds: float) -> void:
	cooldown_left[slot] = seconds
	cooldown_total[slot] = seconds


func remaining(slot: int) -> float:
	return cooldown_left[slot]


func fraction_left(slot: int) -> float:
	if cooldown_total[slot] <= 0.0:
		return 0.0
	return clampf(cooldown_left[slot] / cooldown_total[slot], 0.0, 1.0)


func reduce_all(seconds: float, except_slot: int = -1) -> void:
	for i in SLOTS:
		if i != except_slot:
			cooldown_left[i] = maxf(cooldown_left[i] - seconds, 0.0)


func update(delta: float) -> void:
	for i in SLOTS:
		if cooldown_left[i] > 0.0:
			cooldown_left[i] = maxf(cooldown_left[i] - delta, 0.0)


func reset() -> void:
	for i in SLOTS:
		cooldown_left[i] = 0.0
