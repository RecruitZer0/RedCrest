class_name AttackActionSummon extends AttackAction
## The AttackAction that creates a [Node] and adds it to the scene.
##
## Either a projectile or a summoned minion, this Node has all the flexible tools to satisfy most needs that involve creating another Node.
##[br] Note that [member AttackAction.duration] on this AttackAction acts differently. If the duration is set to anything higher than default (0.001), the [member summoned_node] will be deleted when the duration ends.
##[br] Big part of the power of this AttackAction comes from the Transfer Variables/Arguments (see [member transfer_variables]), as well as their suffixes (see [constant SUFFIX_FLIP])


@export var summon_scene: PackedScene ## The Scene that will be instantiated and added to the scene. By default, the Node's global position will be set to this Node's global position, if the summoned has this variable. When succesfully added, the instance of this scene will set [member summoned_node].
@export var summon_target: Node ## The target of the [member summoned_node], what this means is that when the [member summoned_node] is going to be added to the scene, it will be added as a [b]sibling[/b] of the target.
@export_group("Transfer Values", "transfer_")
@export var transfer_variables: Dictionary ## This is a transfer Dictionary, it's keys must be [StringName]s and they have support for [b]suffixes[/b].[br] The values of this Dictionary will set the [member summoned_node]'s according to the key's names. The Variables are set before the [member summoned_node] is added to the [SceneTree]. 
@export var transfer_start_arguments: Dictionary ## This is a transfer Dictionary, it's keys must be [StringName]s and they have support for [b]suffixes[/b].[br] The name set on the keys don't matter, except for the use of suffixes. The order that the keys are arranged matter.[br] Sets the arguments to be passed to the [member summoned_node]'s start function (see [constant SUMMON_START_FUNCTION]). The Start Function is executed after the [member summoned_node] is added to the [SceneTree]. 
@export var transfer_end_arguments: Dictionary ## This is a transfer Dictionary, it's keys must be [StringName]s and they have support for [b]suffixes[/b].[br] The name set on the keys don't matter, except for the use of suffixes. The order that the keys are arranged matter.[br] Sets the arguments to be passed to the [member summoned_node]'s end function. (see [constant SUMMON_END_FUNCTION])

var summoned_node: Node ## References the last summoned Node, even if [AttackAction.duration] is set to default (0.001).

var _flipped_vector := Vector3.ONE

const SUMMON_START_FUNCTION = "_attack_summon_trigger_start" ## The name of the function that [member summoned_node] must have for it to be executed when added to the [SceneTree]
const SUMMON_END_FUNCTION = "_attack_summon_trigger_end" ## The name of the function that [member summoned_node] must have for it to be executed when [AttackAction.duration] ends. This doesn't happen if [AttackAction.duration] is set to default (0.001).

## [b]Compatible with:[/b]
##[br] - [Vector3]
##[br] Makes this variable compatible with [method AttackAction.flip].
const SUFFIX_FLIP = "flip"
## [b]Compatible with:[/b]
##[br] - [int]
##[br] If the set value is 0, overrides it by [method randi].[br] If anything higher, the value is set to [method randi] % value.
const SUFFIX_RANDI = "randi"
## [b]Compatible with:[/b]
##[br] - [float]
##[br] - [int]
##[br] Multiplies the set value by [method randf].
const SUFFIX_RANDF = "randf"
## [b]Compatible with:[/b]
##[br] - [Vector2]
##[br] Multiplies each set axis value by [method randf].
const SUFFIX_RANDVEC2 = "randvec2"
## [b]Compatible with:[/b]
##[br] - [Vector3]
##[br] Multiplies each set axis value by [method randf].
const SUFFIX_RANDVEC3 = "randvec3"

func _trigger_start() -> void:
	summoned_node = summon_scene.instantiate()
	send_summon_variables(summoned_node)
	
	summon_target.add_sibling(summoned_node)
	
	if "global_position" in summoned_node:
		summoned_node.global_position = global_position
	
	call_start_function(summoned_node)

func _trigger_end() -> void:
	if duration == 0.001:
		return
	call_end_function(summoned_node)
	summoned_node.queue_free()

## Flips it's own relative position, as well as all Transfer Variables/Arguments on the respective axis.
func flip(axis: int) -> void:
	position[axis] *= -1
	_flipped_vector[axis] *= -1

## Sets the [param node]'s variable according to [member transfer_variables].
func send_summon_variables(node: Node) -> void:
	var variables := parsed_dictionary(transfer_variables)
	
	for var_name in variables.keys():
		if var_name in node:
			var var_value = variables[var_name]
			node.set(var_name, var_value)

## Calls the [param node]'s start function (see [constant SUMMON_START_FUNCTION]) with [member transfer_start_arguments].
func call_start_function(node: Node) -> void:
	if not node.has_method(SUMMON_START_FUNCTION):
		return
	
	var args := parsed_dictionary(transfer_start_arguments)
	
	node.callv(SUMMON_START_FUNCTION, args.values())

## Calls the [param node]'s end function (see [constant SUMMON_END_FUNCTION]) with [member transfer_end_arguments].
func call_end_function(node: Node) -> void:
	if not node.has_method(SUMMON_END_FUNCTION):
		return
	
	var args := parsed_dictionary(transfer_end_arguments)
	
	node.callv(SUMMON_END_FUNCTION, args.values())

## Returns a new Dictionary after calculating the [param raw_dictionary]'s suffixes, as well as other things like converting [NodePath] to [Node].
func parsed_dictionary(raw_dictionary: Dictionary) -> Dictionary:
	var dictionary := raw_dictionary.duplicate(true)
	for var_name in dictionary.keys():
		var name_array: PackedStringArray = var_name.split("+")
		var var_value = dictionary[var_name]
		
		for suffix in name_array:
			if suffix == name_array[0]:
				continue
			match suffix:
				SUFFIX_FLIP:
					dictionary[var_name] *= _flipped_vector
				SUFFIX_RANDF:
					randomize()
					dictionary[var_name] *= randf()
				SUFFIX_RANDI:
					randomize()
					if var_value == 0:
						dictionary[var_name] = randi()
					else:
						dictionary[var_name] = randi() % var_value
				SUFFIX_RANDVEC2:
					randomize()
					dictionary[var_name] *= Vector2(randf(), randf())
				SUFFIX_RANDVEC3:
					randomize()
					dictionary[var_name] *= Vector3(randf(), randf(), randf())
		
		
		if typeof(var_value) == TYPE_NODE_PATH:
			dictionary[var_name] = get_node(var_value)
		
		if StringName(name_array[0]) != var_name:
			dictionary[StringName(name_array[0])] = dictionary[var_name]
			dictionary.erase(var_name)
	
	return dictionary

#func ordered_values(dict: Dictionary) -> Array:
	#var returning := []
	#for i in range(dict.size()):
		#returning.append(dict.get(StringName(str(i))))
	#return returning
