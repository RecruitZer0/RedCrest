class_name Damage extends Resource

var damage: int
var knockback_force: float
var knockback_direction: Vector3
var knockback_cooldown_override: float
var knockback_ignore_cooldown: bool
var is_crit := false
var crit_multiplier := 2.0
var lift_enabled: bool
var lift_force: float
var inflictor: DamageInflictor
