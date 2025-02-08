class_name FollowNPC extends Actor
## The most basic and versatile type of NPC.
##
## It uses [NavigationAgent3D] (defined in [member nav]) to follow and attack any [Actor] by their tags.

@onready var nav: NavigationAgent3D = $NavigationAgent ## The NavigationAgent3D used to move.
@onready var ray_wall: RayCast3D = $RayWall ## The [Raycast3D] used to detect walls in front of it to jump.
@onready var ray_ground: RayCast3D = $RayGround ## The [Raycast3D] used to detect holes in front of it to jump.

@export_group("Follow")
@export var follow_targets: Array[Actor.Tags] = [] ## An Array of [enum Actor.Tags] that the NPC should follow and target its attacks.
@export var follow_blacklist: Array[Actor.Tags] = [Actor.Tags.PROJECTILE] ## An Array of [enum Actor.Tags] that the NPC will not target at all. Even if an Actor with one of these tags attacks this NPC with [member switch_to_attacker] enabled. The default value includes PROJECTILE tag.
@export var minimum_distance: float = 2 ## A minimum distance the NPC will try to maintain when following the target.
@export var automatically_target := true ## If true, the NPC will be constantly trying to target whichever valid target is the closest when it doesn't have one already (see [method is_valid_target]). Note that the NPC will only do that when it is on screen.
@export var switch_to_attacker := true ## If true, the NPC will switch its target to whoever last attacked them.
@export_subgroup("Align", "align_")
@export_flags("X", "Y", "Z") var align_axis := 1 ## When set, the NPC will try to get it's respective axis as close as possible to the target's axis.
@export var align_margin: float = 0.4 ## To avoid the NPC trying to make it's [member align_axis] [i]exactly[/i] equal to the target, this margin provides a threshold that counts as equal value.
@export_subgroup("Jumping", "jump_")
@export var jump_force := 20.0 ## Force of the jump.
@export var jump_wall_distance := 3.0 ## The distance the [member ray_wall] will check forward for collisions.
@export var jump_ground_distance := 2.0 ## The distance the [member ray_ground] will check forward for collisions.
@export var jump_ground_depth := 10.0 ## The distance that the [member ray_ground] will check down for collisions.

var targeting: Actor


func _physics_process(delta: float) -> void:
	if targeting:
		_handle_pathing()
	elif is_on_screen() and automatically_target:
		targeting = find_nearest_target()
	
	super(delta)


func find_nearest_target() -> Actor:
	var actors := get_tree().get_nodes_in_group("Actor")
	actors = actors.filter(is_valid_target)
	if actors.is_empty():
		return null
	actors.sort_custom(func(a, b): return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position))
	return actors.front()

## Returns if [param actor] is a valid and safe target for this NPC. I.e., the Actor is on screen and it has one of the tags in [member follow_targets].
## Note that even though the NPC only searches for targets when itself is on screen, this action doesn't consider that. (see [member automatically_target])
func is_valid_target(actor: Actor) -> bool:
	if not actor.is_on_screen():
		return false
	if actor.has_tags(follow_blacklist):
		return false
	
	return actor.has_tags(follow_targets)

## Returns if both the [NavigationServer] has started completely and [NavigationAgent3D] has not reached it's destination.
func is_ai_ready() -> bool:
	if NavigationServer3D.map_get_iteration_id(nav.get_navigation_map()) == 0:
		return false
	if nav.is_navigation_finished():
		return false
	return true

func _switch_to_attacker(damage: Damage) -> void:
	if not switch_to_attacker: return
	if damage.inflictor.owner is Actor:
		if damage.inflictor.owner.has_tags(follow_blacklist):
			return
		targeting = damage.inflictor.owner

func _handle_pathing() -> void:
	if damage_receiver.is_stunned():
		return
	
	if align_axis:
		var align_byte := String.num_int64(align_axis, 2).pad_zeros(3)
		var align_vector := Vector3.ZERO
		for i in range(3):
			align_vector[i] = align_byte[~i].to_int() * minimum_distance
		align_vector *= (global_position - targeting.global_position).sign()
		nav.target_position = targeting.global_position + align_vector
		nav.target_desired_distance = align_margin
	else:
		nav.target_position = targeting.global_position
		nav.target_desired_distance = minimum_distance
	
	if is_ai_ready():
		var relative_path_position := nav.get_next_path_position()
		relative_path_position.y = global_position.y
		
		nav.path_height_offset = shadow_sprite.position.y
		movement_dir = global_position.direction_to(relative_path_position)
		
		ray_wall.target_position = global_position.direction_to(relative_path_position) * jump_wall_distance
		ray_ground.position = global_position.direction_to(relative_path_position) * jump_ground_distance + Vector3.UP
		ray_ground.target_position = Vector3.DOWN * jump_ground_depth + Vector3.DOWN
		
		if (ray_wall.is_colliding() or not ray_ground.is_colliding()) and is_on_floor():
			if is_equal_approx(velocity.x, 0) or is_equal_approx(velocity.z, 0):
				movement_dir *= -1
			else:
				velocity_add.y += jump_force
