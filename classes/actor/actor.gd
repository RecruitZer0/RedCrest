class_name Actor extends CharacterBody3D
## The base class for 2.5D objects
##
## Has code for gravity, movement and shadow. All can be disabled.


@onready var sprite: Sprite3D = $Sprite
@onready var shadow: RayCast3D = $Shadow
@onready var shadow_sprite: Sprite3D = $Shadow/ShadowSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var damage_receiver: DamageReceiver = $DamageReceiver


@export_category("Actor Movement")
@export var max_speed := 8.0
@export var acceleration := 40.0
@export var gravity := 30.0
@export var speed_multiplier := 1.0
@export var should_move := true
var movement_dir: Vector3
var velocity_add: Vector3

@export_category("Visuals")
@export var shadow_radius := 1.0
@export var should_flip_offset := true ## If true, when the [member sprite]'s [param flip_h] or [param flip_h] are true, its [member SpriteBase3D.offset] will be flipped as well.



func _ready() -> void:
	animation_tree.active = true
	animation_player.active = false

func _process(_delta: float) -> void:
	if should_flip_offset and not animation_tree.mixer_applied.is_connected(_flip_offset):
		animation_tree.mixer_applied.connect(_flip_offset)
	if not should_flip_offset and animation_tree.mixer_applied.is_connected(_flip_offset):
		animation_tree.mixer_applied.disconnect(_flip_offset)


func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity = velocity.move_toward(movement_dir * max_speed * speed_multiplier, acceleration * delta * speed_multiplier)
	velocity.y -= gravity * delta
	velocity += velocity_add
	if should_move:
		move_and_slide()
	movement_dir = Vector3.ZERO
	velocity_add = Vector3.ZERO
	
	_handle_shadow()

func _handle_shadow() -> void:
	shadow_sprite.visible = shadow.is_colliding()
	if shadow.is_colliding():
		var pos := shadow.get_collision_point() - global_position
		shadow_sprite.position = pos + (Vector3.UP * 0.5) + (Vector3.BACK)
		shadow_sprite.scale = Vector3.ONE * remap(pos.y, 0, -15, 1, 0) * shadow_radius
		shadow_sprite.modulate.a = remap(pos.y, 0, -15, 1, 0)

func _flip_offset() -> void:
	#await get_tree().process_frame
	if sprite.flip_h:
		sprite.offset.x *= -1
	if sprite.flip_v:
		sprite.offset.y *= -1
