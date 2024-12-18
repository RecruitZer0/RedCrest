class_name Damage extends Resource

@export var damage: int
@export var knockback: float
@export var knockback_direction: Vector3
@export var is_crit := false
@export var crit_multiplier := 2.0
@export var override_damage_cooldown: float
var inflictor: DamageInflictor
