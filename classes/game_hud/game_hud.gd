class_name GameHUD extends CanvasLayer
## The main HUD used in levels in-game.
##
## It has a health_bar (see [member health_actor]), and a weapon slot.


@onready var health_bar: ProgressBar = %HealthBar
@onready var weapon_icon: TextureRect = %WeaponIcon
@onready var weapon_label: Label = %WeaponLabel

## Defines the Actor that will have it's health monitored. It automatically connects [signal ActorHealth.health_changed] and sets the health bar's value to the percentage of the remaining health.
@export var health_actor: Actor :
	set(value):
		if not value.is_node_ready():
			await value.ready
		
		if health_actor:
			if health_actor.health.health_changed.is_connected(_update_health_bar):
				health_actor.health.health_changed.disconnect(_update_health_bar)
		if value == null:
			return
		health_actor = value
		value.health.health_changed.connect(_update_health_bar)

func _update_health_bar(health: ActorHealth, _damage: Damage) -> void:
	health_bar.value = health.health * 100.0 / health.max_health

## Changes the icon on the slot to the corresponding weapon, also shows the weapon's name and changes the tooltip to the weapon's description. All of this is cosmetic only.
func change_weapon_slot(weapon: Weapon) -> void:
	weapon_icon.texture = weapon.icon
	_weapon_label_anim(weapon.name, weapon.color)


func _weapon_label_anim(weapon_name: String, weapon_color: Color) -> void:
	weapon_label.text = weapon_name
	weapon_label.modulate = weapon_color
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(weapon_label, "modulate:a", 1, 0)
	tween.tween_property(weapon_label, "position:y", 57.5, 0)
	tween.chain().tween_property(weapon_label, "modulate:a", 0, 1.5)
	tween.tween_property(weapon_label, "position:y", -4, 1.5)
	
