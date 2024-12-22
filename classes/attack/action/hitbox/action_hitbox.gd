class_name AttackActionHitbox extends AttackAction

@export var inflictor: DamageInflictor
var hitboxes: Array[CollisionShape3D]

func _ready() -> void:
	for child in get_children(): if child is CollisionShape3D:
		hitboxes.append(child)
		child.disabled = true

func _trigger_start() -> void:
	for hitbox in hitboxes:
		remove_child(hitbox)
		inflictor.add_child(hitbox)
		hitbox.disabled = false

func _trigger_end() -> void:
	for hitbox in hitboxes:
		inflictor.remove_child(hitbox)
		add_child(hitbox)
		hitbox.disabled = true

func flip() -> void:
	for h in hitboxes:
		h.position *= -1
