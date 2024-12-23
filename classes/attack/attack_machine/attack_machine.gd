@tool
@icon("res://_editor_stuff/class_icons/attack_machine.svg")
class_name AttackMachine extends Node3D
## A State-Machine-based system of making and playing attacks.[br]
##
## It should only have [Attack]s as children, with each one having an unique name, as it is important for animations and functions like [method by_name]

signal attacked(attack: Attack) ## Emitted when an attack is made.Note that this is only at the [b]start[/b] of the attack, not the end. For that, use [signal AnimationMixer.animation_finished].


## The respective [AnimationTree] that will play the animations of the attacks. This variable is obligatory, not having it set will cause an instant error.
##[br] This AnimationTree [b]must[/b] follow some standards:
##[br] 1. It's [member AnimationTree.tree_root] must be a [AnimationNodeBlendTree]
##[br] 2. The blend tree must have a StateMachine named after the AttackMachine. So change that when renaming this node. That's where the attack animations will be.
##[br] 3. Similar to the last one, the blend tree must have a Blend2 named after this node suffixed with "Blend", example: [code]AttackMachineBlend[/code]. That's responsible for making the attack animations override other animations.
##[br][br] Inside the StateMachine, you put animations for each attack. The name standard is: "attack_" + name.
## Assuming you're following Godot's naming standards as well, it should be in snakecase. Example: [code]attack_grounded_1[/code].
##[br] Finally, if you named everything correctly, the animation nodes will automatically be linked to the "End" node, that means everything is working properly!
@export var animation_tree: AnimationTree
var _blend_tree: AnimationNodeBlendTree
var _playback: AnimationNodeStateMachinePlayback

@export_group("Flipping attacks", "flipping_")
@export var flipping_node: Node = null : ## Used in conjunction with [member flipping_property] to define if the attacks should flip or not. When defined, [member flipping_property] will change to list the boolean variables of the selected node. You can set it to [code]null[/code] to prevent flipping.
	set(value):
		if not value == flipping_node:
			notify_property_list_changed()
		flipping_node = value
@export_enum(" ") var flipping_property: String = "" ## Used in conjunction with [member flipping_node] to define if the attacks should flip or not. It's the boolean variable that will be used to flip the attacks. Note: the flipping works by checking if the variable was changed, it does not use the value directly.
@export_enum("X", "Y", "Z") var flipping_axis: int ## The axis that the attacks will be flipped over.
var _flipping: bool
var _flipping_update: bool


## Executes the attack defined in [param attack], running its [method Attack.play] method.
##[br] - [param ignore_combo] Makes the respective attack be executed even if it's inside a combo and has a defined [member Attack.next_in_combo].
##[br] - [param play_animation] Defines if the animation should be played. Be careful when setting to false, since [method is_playing] is dependent on animations!
##[br] - [param override] Makes the attack be executed even if another attack is already being played.
func make_attack(attack: Attack, ignore_combo := false, play_animation := true, override := false) -> void:
	if is_attacking() and not override:
		return
	
	if attack.next_in_combo and is_in_combo(attack) and not ignore_combo:
		attack.combo_timer.stop()
		make_attack(attack.next_in_combo, ignore_combo, play_animation)
		return
	attack.play()
	if play_animation and attack.play_animation:
		_playback.stop()
		_playback.start("attack_%s" % attack.name.to_snake_case())
	
	attacked.emit(attack)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if flipping_node:
		if not flipping_node.is_node_ready():
			await flipping_node.ready
		_flipping = flipping_node.get(flipping_property)
		_flipping_update = _flipping

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if not animation_tree: return
		var sm := animation_tree.tree_root.get_node(name) as AnimationNodeStateMachine
		if not sm: return
		var trans := AnimationNodeStateMachineTransition.new()
		trans.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
		trans.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
		if not sm.has_transition("Start", "End"):
			sm.add_transition("Start", "End", trans)
		for child in get_children():
			if sm.has_transition("attack_%s" % child.name.to_snake_case(), "End"):
				continue
			sm.add_transition("attack_%s" % child.name.to_snake_case(), "End", trans)
		return
	
	
	_blend_tree = animation_tree.tree_root
	_playback = animation_tree.get("parameters/%s/playback" % name)
	
	animation_tree.set("parameters/%sBlend/blend_amount" % name, int(is_attacking()))
	
	_handle_flipping()

## Returns [code]true[/code] if an attack animation is being played.
func is_attacking() -> bool:
	return _playback.get_current_node() != "End"

## Returns [code]true[/code] if the defined attack is inside an active combo. It is recursive.
func is_in_combo(attack: Attack) -> bool:
	if not attack.combo_timer:
		return false
	if attack.combo_timer.time_left:
		return true
	if attack.next_in_combo:
		return is_in_combo(attack.next_in_combo)
	return false

## Returns an [Attack] child by the specified name or [code]null[/code]
func by_name(attack_name: NodePath) -> Attack:
	return get_node_or_null(attack_name)

func _handle_flipping() -> void:
	if not flipping_node: return
	if not flipping_node.is_node_ready(): return
	
	_flipping = flipping_node.get(flipping_property)
	if _flipping_update != _flipping:
		for attack in get_children(): if attack is Attack:
			for action in attack._actions:
				action.flip(flipping_axis)
		_flipping_update = _flipping



func _validate_property(property: Dictionary) -> void:
	if property.name == "flipping_property":
		if flipping_node:
			var bool_properties: Array[String]
			for a in flipping_node.get_property_list():
				if a["type"] == TYPE_BOOL:
					bool_properties.append(a["name"])
			property.hint_string = ",".join(bool_properties)
		else:
			property.hint_string = ""
