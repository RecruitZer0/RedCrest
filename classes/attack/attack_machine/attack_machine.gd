@tool
class_name AttackMachine extends Node3D

signal attacked(attack: Attack)

@export var animation_tree: AnimationTree
var blend_tree: AnimationNodeBlendTree
var playback: AnimationNodeStateMachinePlayback

@export_group("Flipping attacks", "flipping_")
@export var flipping_node: Node = null :
	set(value):
		if not value == flipping_node:
			notify_property_list_changed()
		flipping_node = value
@export_enum(" ") var flipping_property: String = ""
@export_enum("X", "Y", "Z") var flipping_axis: int
var _flipping: bool
var _flipping_update: bool

func make_attack(attack: Attack, ignore_combo := false, play_animation := true, override := false) -> void:
	if is_attacking() and not override:
		return
	
	if attack.next_in_combo and is_in_combo(attack) and not ignore_combo:
		attack.combo_timer.stop()
		make_attack(attack.next_in_combo, ignore_combo, play_animation)
		return
	attack.play()
	if play_animation and attack.play_animation:
		playback.stop()
		playback.start("attack_%s" % attack.name.to_snake_case())
	
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
		return
	
	blend_tree = animation_tree.tree_root
	playback = animation_tree.get("parameters/%s/playback" % name)
	
	animation_tree.set("parameters/%sBlend/blend_amount" % name, int(is_attacking()))
	_handle_flipping()


func is_attacking() -> bool:
	return playback.get_current_node() != "End"
	
func is_in_combo(attack: Attack) -> bool:
	if not attack.combo_timer:
		return false
	if not attack.combo_timer.is_stopped():
		return true
	if attack.next_in_combo:
		return is_in_combo(attack.next_in_combo)
	return false

func by_name(attack_name: NodePath) -> Attack:
	return get_node_or_null(attack_name)

func _handle_flipping() -> void:
	if not flipping_node: return
	if not flipping_node.is_node_ready(): return
	
	_flipping = flipping_node.get(flipping_property)
	if _flipping_update != _flipping:
		for attack in get_children(): if attack is Attack:
			for action in attack.actions:
				action.flip()
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
