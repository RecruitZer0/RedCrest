class_name DamageGenerator extends Resource

@export var min_damage: int
@export var max_damage: int
@export var knockback := 8.0
@export var knockback_direction := Vector3.ZERO
@export_range(0, 1, 0.1) var crit_chance := 0.1
@export var crit_multiplier := 2.0
@export var override_damage_cooldown := 0.0


func generate(inflictor: DamageInflictor) -> Damage:
	var resource := Damage.new()
	resource.damage = randi_range(min_damage, max_damage)
	if randf() < crit_chance:
		resource.damage = ceili(resource.damage * crit_multiplier)
		resource.is_crit = true
	resource.knockback = knockback
	resource.knockback_direction = knockback_direction.normalized()
	resource.crit_multiplier = crit_multiplier
	resource.override_damage_cooldown = override_damage_cooldown
	resource.inflictor = inflictor
	return resource
