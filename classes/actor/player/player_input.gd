extends Node

@export var jump_force := 20.0
@export var disable_input := false
@onready var player: Player = owner


func _physics_process(_delta: float) -> void:
	_basic_movement()
	_attacking()
	disable_input = false

func _process(_delta: float) -> void:
	if player.attack_machine.is_attacking():
		disable_input = true


func _basic_movement() -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var jump_input := Input.is_action_pressed("move_jump") and player.is_on_floor()
	var jump_release := Input.is_action_just_released("move_jump") and player.velocity.y > 0
	if Input.is_action_just_pressed("move_crouch"):
		player.is_crouching = true
		player.speed_multiplier *= 0.5
	if Input.is_action_just_released("move_crouch"):
		player.is_crouching = false
		player.speed_multiplier *= 2
	
	if disable_input:
		return
	
	player.movement_dir = player.basis.x * direction.x + player.basis.z * direction.y
	player.velocity_add.y = int(jump_input) * jump_force
	player.velocity_add.y -= int(jump_release) * jump_force / 2
	if direction.x:
		player.sprite.flip_h = direction.x < 0


func _attacking() -> void:
	if disable_input:
		return
	
	if Input.is_action_pressed("attack_light"):
		if player.is_on_floor():
			player.attack_machine.make_attack(player.attack_machine.by_name("Grounded1"))
		else:
			if player.velocity.y > 0:
				player.attack_machine.make_attack(player.attack_machine.by_name("Uppercut"))
			else:
				player.attack_machine.make_attack(player.attack_machine.by_name("Aerial1"))
