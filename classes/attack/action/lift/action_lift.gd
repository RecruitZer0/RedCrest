@tool
class_name AttackActionLift extends AttackAction
## Sets Y velocity to a [CharacterBody3D] when succesfully lands an attack.
##
## It overrides the [member character]'s [member CharacterBody3D.velocity].
## The effect only happens while the Action is active.


@export var character: CharacterBody3D : ## The character that will have its velocity overriden.
	set(value):
		character = value
		update_configuration_warnings()
@export var inflictor: DamageInflictor : ## The inflictor that will have its hit signal connected.
	set(value):
		inflictor = value
		update_configuration_warnings()
@export var lift_direction := Vector3.UP : ## The direction that [member character] will be launched toward. Is automatically normalized in run-time, but not in editor.
	set(value):
		if Engine.is_editor_hint():
			lift_direction = value
		else:
			lift_direction = value.normalized()
@export var lift_force := 5.0 ## The force of the lift.

var _flip := Vector3.ONE

func _apply_force(_receiver: DamageReceiver) -> void:
	if not character.is_on_floor():
		character.velocity *= Vector3.ONE - lift_direction
		character.velocity += lift_direction * lift_force * _flip

func _trigger_start() -> void:
	inflictor.hit.connect(_apply_force)

func _trigger_end() -> void:
	inflictor.hit.disconnect(_apply_force)

## Mirrors [member lift_direction] on the respective axis.
func flip(axis: int) -> void:
	_flip[axis] *= -1
