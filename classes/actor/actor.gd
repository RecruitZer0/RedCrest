class_name Actor extends CharacterBody3D
## The base class for 2.5D objects
##
## Has code for gravity, movement and shadow. All can be disabled.

enum Tags {
	PLAYER,
	PROJECTILE,
	SOLDIER,
	NEUTRAL,
}

@onready var sprite: Sprite3D = $Sprite
@onready var shadow: RayCast3D = $Shadow
@onready var shadow_sprite: Sprite3D = $Shadow/ShadowSprite
@onready var collision: CollisionShape3D = $Collision
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var damage_receiver: DamageReceiver = $DamageReceiver
@onready var visible_on_screen: VisibleOnScreenNotifier3D = $VisibleOnScreen


@export_group("Movement")
@export var max_speed := 8.0
@export var acceleration := 100.0
@export var gravity := 30.0
@export var speed_multiplier := 1.0
@export var should_move := true
@export var can_fly := false
var movement_dir: Vector3
var velocity_add: Vector3

@export_group("Visuals")
@export var shadow_radius := 1.0
@export var should_flip_offset := true ## If true, when the [member sprite]'s [param flip_h] or [param flip_h] are true, its [member SpriteBase3D.offset] will be flipped as well.

@export_group("")
@export var tags: Array[Tags] = [] ## An Array of [enum Tags] that represents what Tags this Actor is included in.

## Returns whether this Actor is on screen. It uses [method VisibleOnScreenNotifier3D.is_on_screen]
func is_on_screen() -> bool:
	return visible_on_screen.is_on_screen()

## Returns an Array of all Actors that either:
##[br] - Have at least one of the tags in [param check_tags], if [param restrictive] is false. (default)
##[br] - Have all of the tags in [param check_tags], if [param restrictive] is true.
static func get_by_tags(check_tags: Array[Tags], restrictive := false) -> Array[Actor]:
	var raw_actors: Array[Node] = Engine.get_main_loop().get_nodes_in_group("Actor")
	var actors: Array[Actor]
	for node in raw_actors: if node is Actor:
		if node.has_tags(check_tags, restrictive):
			actors.append(node)
	return actors

func has_tags(check_tags: Array[Tags], restrictive := false) -> bool:
	if restrictive:
		for check in check_tags:
			if not tags.has(check):
				return false
		return true
	else:
		for check in check_tags:
			if tags.has(check):
				return true
		return false


func _ready() -> void:
	animation_tree.active = true
	animation_player.active = false

func _process(_delta: float) -> void:
	if should_flip_offset and not animation_tree.mixer_applied.is_connected(_flip_offset):
		animation_tree.mixer_applied.connect(_flip_offset)
	if not should_flip_offset and animation_tree.mixer_applied.is_connected(_flip_offset):
		animation_tree.mixer_applied.disconnect(_flip_offset)
	visible_on_screen.layers = sprite.layers


func _physics_process(delta: float) -> void:
	if is_on_floor() or can_fly:
		velocity = velocity.move_toward(movement_dir * max_speed * speed_multiplier, acceleration * delta * speed_multiplier)
	else:
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
		shadow_sprite.position = pos + (Vector3.UP * 0.1)
		shadow_sprite.scale = Vector3.ONE * remap(pos.y, 0, -15, 1, 0) * shadow_radius
		shadow_sprite.modulate.a = remap(pos.y, 0, -15, 1, 0)

func _flip_offset() -> void:
	if sprite.flip_h:
		sprite.offset.x *= -1
	if sprite.flip_v:
		sprite.offset.y *= -1
