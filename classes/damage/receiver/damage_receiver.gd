@tool
@icon("res://_editor_stuff/class_icons/damage_receiver.svg")
class_name DamageReceiver extends Area3D
## The node responsible for handling damage taken from [DamageInflictor], as well as knockback and damage text.

## Emitted before the damage/knockback is processed, allowing for changes in the properties of [param damage].
signal before_damaged(damage: Damage)
## Emitted after the damage/knockback is processed, but still before the damage text is shown, allowing for changes in that.
signal after_damaged(damage: Damage)

## The minimum time between a knockback and another. Prevents velocity accumulation.
@export var knockback_cooldown: Timer
## If the damage text should be shown.
@export var show_damage_text := true

## Applies damage to this receiver.
func receive_damage(damage: Damage) -> void:
	before_damaged.emit(damage)
	if knockback_cooldown.is_stopped() and owner is Actor:
		if damage.knockback_direction:
			owner.velocity_add = damage.knockback_direction * damage.knockback_force
		else:
			owner.velocity_add = (damage.inflictor.global_position.direction_to(global_position) + Vector3.UP).normalized() * damage.knockback_force
	if damage.knockback_cooldown_override > 0:
		knockback_cooldown.start(damage.knockback_cooldown_override)
	else:
		knockback_cooldown.start()
	
	after_damaged.emit(damage)
	_make_number(damage)

func _make_number(damage: Damage) -> void:
	if not show_damage_text: return
	var label := Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.render_priority = 2
	label.text = str(damage.damage)
	label.layers = 16
	label.font_size = 160
	if damage.is_crit:
		label.modulate = Color.RED
		label.text += "\nCrit!"
	add_child(label)
	label.top_level = true
	var tween := label.create_tween().set_trans(Tween.TRANS_CIRC)
	tween.tween_property(label, "global_position:x", label.global_position.x + 2, 0.4).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "global_position:y", label.global_position.y + 2, 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "global_position:y", label.global_position.y + 1, 0.2).set_ease(Tween.EASE_IN)
	tween.tween_property(label, "modulate:a", 0, 1)
	tween.tween_callback(func(): label.queue_free())
	


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		collision_layer = 16
		collision_mask = 32
		return
