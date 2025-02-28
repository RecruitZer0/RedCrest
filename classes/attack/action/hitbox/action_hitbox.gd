class_name AttackActionHitbox extends AttackAction
## An AttackAction that creates damaging hitboxes and adds them to a [DamageInflictor].
##
## Should have [CollisionShape3D] as children.

@export var inflictor: DamageInflictor ## The inflictor that the hitboxes will be added to.
var _hitboxes: Array[CollisionShape3D]

func _ready() -> void:
	for child in get_children(): if child is CollisionShape3D:
		_hitboxes.append(child)
		child.disabled = true
	super()

func _trigger_start() -> void:
	for hitbox in _hitboxes:
		remove_child(hitbox)
		inflictor.add_child(hitbox)
		hitbox.disabled = false

func _trigger_end() -> void:
	for hitbox in _hitboxes:
		inflictor.remove_child(hitbox)
		add_child(hitbox)
		hitbox.disabled = true

## Mirrors all the hitboxes positions on the respective axis.
func flip(axis: int) -> void:
	for h in _hitboxes:
		h.position[axis] *= -1
	if self == get_parent().get_children().filter(_has_the_same_inflictor)[0]:
		inflictor.generator.knockback_direction[axis] *= -1


func _has_the_same_inflictor(node: Node) -> bool:
	if node.get("inflictor"):
		return node.inflictor == inflictor
	else:
		return false
