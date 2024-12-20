@tool
class_name DamageInflictor extends Area3D

signal hit(area: DamageReceiver)

@export var generator: DamageGenerator

var _areas_in: Array[DamageReceiver] = []


func _ready() -> void:
	if Engine.is_editor_hint(): return
	area_entered.connect(_area_entered)
	area_exited.connect(_area_exited)

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		collision_layer = 32
		collision_mask = 16
		return
	for area in _areas_in:
		area.receive_damage(generator.generate(self))
		hit.emit(area)

func _area_entered(area: Area3D) -> void:
	if area is DamageReceiver and (owner != area.owner):
		_areas_in.append(area)
		area.receive_damage(generator.generate(self))
		hit.emit(area)

func _area_exited(area: Area3D) -> void:
	if area is DamageReceiver:
		_areas_in.erase(area)
