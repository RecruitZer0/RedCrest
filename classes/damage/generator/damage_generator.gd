class_name DamageGenerator extends Resource

@export var min_damage: int
@export var max_damage: int
@export var damage_cooldown := 0.2

@export_group("Knockback", "knockback_")
@export var knockback_force := 5.0
@export var knockback_direction := Vector3.ZERO
@export var knockback_cooldown_override := 0.0
@export var knockback_ignore_cooldown := false

@export_group("Critical", "crit_")
@export_range(0, 1, 0.1) var crit_chance := 0.1
@export var crit_multiplier := 2.0

@export_group("Lift", "lift_")
@export var lift_enabled := false
@export var lift_force := 2.0


func generate(inflictor: DamageInflictor) -> Damage:
	var resource := Damage.new()
	resource.damage = randi_range(min_damage, max_damage)
	
	if randf() < crit_chance:
		resource.damage = ceili(resource.damage * crit_multiplier)
		resource.is_crit = true
		
	resource.knockback_force = knockback_force
	resource.knockback_direction = knockback_direction.normalized()
	resource.knockback_cooldown_override = knockback_cooldown_override
	resource.knockback_ignore_cooldown = knockback_ignore_cooldown
	
	resource.crit_multiplier = crit_multiplier
	
	resource.lift_enabled = lift_enabled
	resource.lift_force = lift_force
	
	resource.inflictor = inflictor
	return resource
