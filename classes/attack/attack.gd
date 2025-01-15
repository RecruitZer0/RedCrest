@icon("res://_editor_stuff/class_icons/attack.svg")
class_name Attack extends Node3D
## An animation-like node that defines an attack and how it should work. Should preferably be a child of an [AttackMachine]
##
## In order to work, it should have at least one [AttackAction] as a child, but it can have any type node as a child for general-purpose.


@export_group("Combo")
@export var next_in_combo: Array[Attack] ## An optional amount of attacks that will be played instead of this one if it is inside a combo, works in a sequence. See [method AttackMachine.make_attack]
@export var combo_timer: Timer ## A Timer that defines if the attack is inside a combo. Having a [member next_in_combo] defined without a timer defined will raise an error when attacking.

@export_group("Visuals")
@export var play_animation := true ## If the respective animation should be played. Be careful when setting to false, since [method AttackMachine.is_playing] is dependent on animations!

var _actions: Array[AttackAction]

func _ready() -> void:
	child_order_changed.connect(_register_children)
	_register_children()

## Triggers all the [AttackAction] children (see [method AttackAction.trigger]) after each respective [member AttackAction.delay], and starts the [member combo_timer]
func play() -> void:
	for action in _actions:
		action.trigger()
	if combo_timer:
		combo_timer.start()

## Stops this attack and all its [AttackAction]s.
func stop() -> void:
	for action in _actions:
		if not action.is_active():
			action._delay_timer.stop()
		else:
			action._duration_timer.stop()
			action._duration_timer.timeout.emit()

## Returns whether the attack is active.
func is_attacking() -> bool:
	for action in _actions:
		if action.is_active():
			return true
	return false


func _register_children() -> void:
	_actions.clear()
	for child in get_children(): if child is AttackAction:
		_actions.append(child)
