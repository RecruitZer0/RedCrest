@tool
@icon("res://_editor_stuff/class_icons/damage_inflictor.svg")
class_name DamageInflictor extends Area3D
## The node responsible for colliding with [DamageReceiver]s and inflicting damage.

## Emitted after hitting a [DamageReceiver]
signal hit(receiver: DamageReceiver)

## The generator that will create the damage applied to other [DamageReceiver]s.
@export var generator: DamageGenerator
## 
@export var ignored_receivers: Array[DamageReceiver] = []

var _areas_in: Dictionary = {}


func _ready() -> void:
	if Engine.is_editor_hint(): return
	area_entered.connect(_area_entered)
	area_exited.connect(_area_exited)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		collision_layer = 32
		collision_mask = 16
		return
	for area in _areas_in.keys(): if area not in ignored_receivers:
		_areas_in[area] = move_toward(_areas_in[area], 0, delta)
		if _areas_in[area]: continue
		_areas_in[area] = generator.stun_duration
		hit.emit(area)
		area.receive_damage(generator.generate(self))

func _area_entered(area: Area3D) -> void:
	if area is DamageReceiver and (owner != area.owner) and area not in ignored_receivers:
		_areas_in[area] = generator.stun_duration
		hit.emit(area)
		area.receive_damage(generator.generate(self))

func _area_exited(area: Area3D) -> void:
	if area is DamageReceiver:
		_areas_in.erase(area)
