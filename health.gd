extends Node

class_name Health

var max_health: float = 100.0
var current_health: float = 100.0

signal health_changed(old_value: float, new_value: float)
signal health_depleted

func take_damage(amount: float) -> void:
	var old_health: float = current_health
	current_health -= amount

	if current_health <= 0:
		health_depleted.emit()
	elif current_health > max_health:
		current_health = max_health
		health_changed.emit(old_health, current_health)
	else:
		health_changed.emit(old_health, current_health)

func is_max_health() -> bool:
	return max_health == current_health

func is_below_percent_health(percent: float) -> bool:
	var current_percent: float = current_health / max_health
	return percent > current_percent
