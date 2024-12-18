class_name AttackMachine extends Node3D

signal attacked(attack: Attack)

@export var animation_tree: AnimationTree
var blend_tree: AnimationNodeBlendTree
var playback: AnimationNodeStateMachinePlayback

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


func _process(_delta: float) -> void:
	blend_tree = animation_tree.tree_root
	playback = animation_tree.get("parameters/%s/playback" % name)
	
	animation_tree.set("parameters/%sBlend/blend_amount" % name, int(is_attacking()))

func is_in_combo(attack: Attack) -> bool:
	if not attack.combo_timer:
		return false
	if not attack.combo_timer.is_stopped():
		return true
	if attack.next_in_combo:
		return is_in_combo(attack.next_in_combo)
	return false

func get_attack_by_name(attack_name: NodePath) -> Attack:
	return get_node_or_null(attack_name)

func is_attacking() -> bool:
	return playback.get_current_node() != "End"
