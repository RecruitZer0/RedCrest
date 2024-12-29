@icon("res://_editor_stuff/class_icons/damage_generator.svg")
class_name DamageGenerator extends Resource
## A resource that creates and defines [Damage] resources, with a random damage in range.


@export var min_damage: int ## The minimum damage to be randomized into the final damage (inclusive).
@export var max_damage: int ## The maximum damage to be randomized into the final damage (inclusive).
@export var damage_cooldown := 0.2 ## The time needed to do damage again.

@export_group("Knockback", "knockback_")
@export var knockback_force := 5.0 ## The strenght of the knockback applied to the victim.
@export var knockback_direction := Vector3.ZERO ## Direction that the victim will be knocked back, if set to [constant Vector3.ZERO], the direction will be away from the attacker.
@export var knockback_cooldown_override := 0.0 ## The time needed to do knockback again, by default (set to 0) will use the time set in the [DamageReceiver].
@export var knockback_ignore_cooldown := false ## If true, will knockback the victim even if it's knockback cooldown is active.

@export_group("Critical Hit", "crit_")
@export_range(0, 1, 0.1) var crit_chance := 0.1 ## Chance to land a critical hit, between 0 and 1.
@export var crit_multiplier := 2.0 ## How much the damage will be multiplied by when landing a critical hit.



## Creates a [Damage] resource with the values defined in the properties and returns it.
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
	
	resource.inflictor = inflictor
	return resource
