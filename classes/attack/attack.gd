class_name Attack extends Node3D

@export_category("Combo")
@export var next_in_combo: Attack
@export var combo_timer: Timer

@export_category("Visuals")
@export var play_animation := true

var hitboxes: Array[AttackHitbox]
var inflictors: Array[DamageInflictor]

func _ready() -> void:
	child_order_changed.connect(_register_children)
	_register_children()
	for h in hitboxes:
		h.disabled = true

func play() -> void:
	for h in hitboxes:
		var delay_timer := get_tree().create_timer(h.delay, false, true)
		delay_timer.timeout.connect(func():
			remove_child(h)
			h.inflictor.add_child(h)
			h.disabled = false
			
			var duration_timer := get_tree().create_timer(h.duration, false, true)
			duration_timer.timeout.connect(func():
				h.inflictor.remove_child(h)
				add_child(h)
				h.disabled = true
			)
		)
	if combo_timer:
		combo_timer.start()



func _register_children() -> void:
	hitboxes.clear()
	for child in get_children():
		if child is AttackHitbox:
			hitboxes.append(child)
		elif child is DamageInflictor:
			inflictors.append(child)
