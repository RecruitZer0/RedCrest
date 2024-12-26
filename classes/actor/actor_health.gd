@tool
extends Node

@export var max_health: int :
	set(value):
		if value != max_health:
			max_health = value
		if max_health < 0:
			max_health = 0
@export var health: int :
	set(value):
		if value != health:
			health = value
		if health > max_health:
			health = max_health

signal health_changed()
signal died(damage: Damage)


func _handle_damage(damage: Damage) -> void:
	health -= damage.damage
	health_changed.emit()
	if health <= 0:
		died.emit()
