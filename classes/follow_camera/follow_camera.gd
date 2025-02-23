class_name FollowCamera extends Camera3D

@export_group("Follow", "follow_")
@export var follow_tags: Array[Actor.Tags] = [] ## The Actor Tags that the camera will focus, when multiple Actors are present, the position taken is the average of their global positions.
@export var follow_restrictive := false ## If the Actor Tag search must be restrictive (all defined tags should be present) (see [method Actor.get_by_tags]).
@export_flags("X", "Y", "Z") var follow_lock_axis := 4 ## Each chosen flag will automatically set this camera's target_position's respective axis to 0 (this is different from setting the camera's position to 0).
@export_group("Movement", "move_")
@export var move_distance := 15.0 ## How much the camera will move back from to it's target position.
@export var move_offset := Vector3(0, 7.5, 0) ## An offset added to the camera's position after moving because of [member move_distance]
@export_range(0.1, 1, 0.01) var move_speed := 0.3 ## How fast the camera smooths out it's movement


func _physics_process(_delta: float) -> void:
	var target_position := get_target_position()
	var binary_axis := String.num_uint64(follow_lock_axis, 2)
	for i in range(binary_axis.length()):
		var bit := binary_axis[~i].to_int()
		if bit:
			target_position[i] = 0
	global_position = global_position.lerp(target_position + (global_basis.z * move_distance) + move_offset, move_speed)

## Returns the camera's target_position. This takes into account [member follow_tags] and [member follow_restrictive], but it does not consider [member follow_lock_axis].
func get_target_position() -> Vector3:
	var result := Vector3.ZERO
	var i = 0
	for actor in Actor.get_by_tags(follow_tags, follow_restrictive):
		result += actor.shadow_sprite.global_position
		i += 1
	return result/i
