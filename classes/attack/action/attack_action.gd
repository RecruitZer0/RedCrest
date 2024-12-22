class_name AttackAction extends Node3D

@export var delay := 0.0
@export var duration := 1.0

var duration_timer := Timer.new()

func trigger(duration_override := 0.0) -> void:
	if not duration_timer.is_inside_tree():
		add_child(duration_timer)
	duration_timer.wait_time = duration
	duration_timer.one_shot = true
	if duration_override > 0:
		duration_timer.start(duration_override)
	else:
		duration_timer.start()
	_trigger_start()
	if not duration_timer.timeout.is_connected(_trigger_end):
		duration_timer.timeout.connect(_trigger_end)

func _trigger_start() -> void:
	pass

func _trigger_process() -> void:
	pass

func _trigger_physics_process() -> void:
	pass

func _trigger_end() -> void:
	pass


func flip() -> void:
	pass


func _process(_delta: float) -> void:
	if duration_timer.time_left:
		_trigger_process()
func _physics_process(_delta: float) -> void:
	if duration_timer.time_left:
		_trigger_physics_process()
