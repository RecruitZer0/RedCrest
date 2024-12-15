extends Node

@export var jump_force := 20.0
@onready var player: Player = owner

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var jump_input := Input.is_action_pressed("move_jump") and player.is_on_floor()
	var jump_release := Input.is_action_just_released("move_jump") and player.velocity.y > 0
	
	player.movement_dir = player.basis.x * direction.x + player.basis.z * direction.y
	player.velocity_add.y = int(jump_input) * jump_force
	player.velocity_add.y -= int(jump_release) * jump_force / 2
	if direction.x:
		player.sprite.flip_h = direction.x < 0
