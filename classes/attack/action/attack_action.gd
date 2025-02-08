@icon("res://_editor_stuff/class_icons/attack_action.svg")
class_name AttackAction extends Node3D
## Abstract class for adding functionality to an [Attack].
##
## Don't add this node directly to the SceneTree, it won't do anything.
##[br] Instead, extend this class and change the [code]_trigger_*[/code] functions


@export var delay := 0.001 : ## Time to wait until the action is triggered.
	set(value):
		delay = max(0.001, value)
@export var duration := 0.001 : ## Duration that the action is active.
	set(value):
		duration = max(0.001, value)

var _delay_timer := Timer.new()
var _duration_timer := Timer.new()

## Activates the action and runs the respective [code]_trigger_*[/code] at their right times. By default, or when [param delay_override] or [param duration_override] are negative, the velues in [member delay] or [member duration] will be used.
##[br] Preferably, do not override this function, but if necessary, make sure to call [method super].
func trigger(delay_override := -1.0, duration_override := -1.0) -> void:
	_delay_timer.wait_time = delay_override if delay_override >= 0 else delay
	_delay_timer.one_shot = true
	_duration_timer.wait_time = duration_override if duration_override >= 0 else duration
	_duration_timer.one_shot = true
	
	_delay_timer.start()

## Executed when the action is first triggered.
func _trigger_start() -> void:
	pass

## Executed every process tick while active.
func _trigger_process(_delta: float) -> void:
	pass

## Executed every physics process tick while active.
func _trigger_physics_process(_delta: float) -> void:
	pass

## Executed when the action stops, or when the duration timer runs out.
func _trigger_end() -> void:
	pass

## Handles the way that the action is flipped. Does nothing originally, and should be overriden to acommodate the extended action class. Notably used by [AttackMachine].
func flip(_axis: int) -> void:
	pass

## Returns whether the action is being played. I.e. after it's delay and before it's duration end.
func is_active() -> bool:
	return _duration_timer.time_left

## Used internally to connect the delay and duration timer's signals. If it's necessary for this function to be overriden, use [method super]!
func _ready() -> void:
	if not _delay_timer.is_inside_tree():
		add_child(_delay_timer)
	if not _delay_timer.timeout.is_connected(_trigger_start):
		_delay_timer.timeout.connect(_trigger_start)
	if not _delay_timer.timeout.is_connected(_duration_timer.start):
		_delay_timer.timeout.connect(_duration_timer.start)
	
	if not _duration_timer.is_inside_tree():
		add_child(_duration_timer)
	if not _duration_timer.timeout.is_connected(_trigger_end):
		_duration_timer.timeout.connect(_trigger_end)

## Used internally to run [method _trigger_process]. If it's necessary for this function to be overriden, use [method super]!
func _process(delta: float) -> void:
	if is_active() and not Engine.is_editor_hint():
		_trigger_process(delta)
## Used internally to run [method _trigger_physics_process]. If it's necessary for this function to be overriden, use [method super]!
func _physics_process(delta: float) -> void:
	if is_active() and not Engine.is_editor_hint():
		_trigger_physics_process(delta)
