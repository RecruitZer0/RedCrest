class_name Actor extends CharacterBody3D

@onready var sprite: Sprite3D = $Sprite
@onready var shadow: Decal = $Shadow
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: StateMachine = $StateMachine
@onready var hurtbox: CollisionShape3D = $Hurtbox
@onready var hitbox: Area3D = $Hitbox


@export_category("Actor Movement")
@export var max_speed := 8.0
@export var acceleration := 40.0
@export var gravity := 30.0
@export var speed_multiplier := 1.0
@export var should_move := true
var movement_dir: Vector3
var velocity_add: Vector3

func _ready() -> void:
	animation_tree.active = true

func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity = velocity.move_toward(movement_dir * max_speed * speed_multiplier, acceleration * delta * speed_multiplier)
	velocity.y -= gravity * delta
	velocity += velocity_add
	if should_move:
		move_and_slide()
	movement_dir = Vector3.ZERO
	velocity_add = Vector3.ZERO
