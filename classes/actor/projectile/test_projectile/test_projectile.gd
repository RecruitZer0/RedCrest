extends Actor

@export var direction: Vector3

@onready var damage_inflictor: DamageInflictor = $DamageInflictor

func _physics_process(delta: float) -> void:
	sprite.flip_h = direction.x < 0
	direction.y -= 0.008
	sprite.rotation.z += 15 * delta
	movement_dir = direction.normalized()
	super(delta)
	if get_slide_collision_count():
		queue_free()

func _attack_summon_trigger_start(ignored_node: Node) -> void:
	if ignored_node is Actor:
		damage_inflictor.ignored_receivers.append(ignored_node.damage_receiver)
