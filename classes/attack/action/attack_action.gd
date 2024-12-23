@icon("res://_editor_stuff/class_icons/attack_action.svg")
class_name AttackAction extends Node3D
## Abstract class for adding functionality to an [Attack]
##
## Don't add this node directly to the SceneTree, it won't do anything.
##[br] Instead, extend this class and change the [code]_trigger_*[/code] functions


@export var delay := 0.0 ## Time to wait until the action is triggered, used by [Attack], not used by [method trigger]
@export var duration := 1.0 ## Duration that the action is active.

var _duration_timer := Timer.new()

## Activates the action and runs the respective [code]_trigger_*[/code] at their right times. This function does not consider [member delay].
##[br] Preferably, do not override this function, but if necessary, make sure to call [method super].
func trigger(duration_override := 0.0) -> void:
	if not _duration_timer.is_inside_tree():
		add_child(_duration_timer)
	_duration_timer.wait_time = duration
	_duration_timer.one_shot = true
	if duration_override > 0:
		_duration_timer.start(duration_override)
	else:
		_duration_timer.start()
	_trigger_start()
	if not _duration_timer.timeout.is_connected(_trigger_end):
		_duration_timer.timeout.connect(_trigger_end)

## Executed when the action is first triggered.
func _trigger_start() -> void:
	pass

## Executed every process tick while active.
func _trigger_process(_delta: float) -> void:
	pass

## Executed every physics process tick while active.
func _trigger_physics_process(_delta: float) -> void:
	pass

## Executed when the action get deactivated, or when the duration timer runs out.
func _trigger_end() -> void:
	pass

## Handles the way that the action is flipped. Does nothing originally, and should be overriden to acommodate the extended action class. Notably used by [AttackMachine]
func flip(_axis: int) -> void:
	pass


func _process(delta: float) -> void:
	if _duration_timer.time_left:
		_trigger_process(delta)
func _physics_process(delta: float) -> void:
	if _duration_timer.time_left:
		_trigger_physics_process(delta)
