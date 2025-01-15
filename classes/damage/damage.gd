@icon("res://_editor_stuff/class_icons/damage.svg")
class_name Damage extends Resource
## A resource that stores damage information, used by [DamageReceiver] and created by [DamageGenerator].
##
## This resource should preferably not be created directly, instead, use a [DamageGenerator].
## Any description or information on the properties can be read on the [DamageGenerator] documentation.


var damage: int
var stun_duration: float
var knockback_force: float
var knockback_direction: Vector3
var knockback_cooldown_override: float
var knockback_ignore_cooldown: bool
var is_crit := false
var crit_multiplier := 2.0
var inflictor: DamageInflictor
