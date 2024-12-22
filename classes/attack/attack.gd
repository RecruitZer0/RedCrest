class_name Attack extends Node3D

@export_group("Combo")
@export var next_in_combo: Attack
@export var combo_timer: Timer

@export_group("Visuals")
@export var play_animation := true

var actions: Array[AttackAction]

func _ready() -> void:
	child_order_changed.connect(_register_children)
	_register_children()

func play() -> void:
	for action in actions:
		var delay_timer := get_tree().create_timer(action.delay, false, true)
		delay_timer.timeout.connect(action.trigger)
	if combo_timer:
		combo_timer.start()



func _register_children() -> void:
	actions.clear()
	for child in get_children(): if child is AttackAction:
		actions.append(child)
