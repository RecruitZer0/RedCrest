class_name DamageReceiver extends Area3D

signal damaged(damage: Damage)

@export var cooldown: Timer
@export var show_text := true


func receive_damage(damage: Damage) -> void:
	if not cooldown.is_stopped(): return
	if owner is Actor:
		if damage.knockback_direction:
			owner.velocity_add = damage.knockback_direction * damage.knockback
		else:
			owner.velocity_add = (damage.inflictor.global_position.direction_to(owner.global_position) + Vector3.UP).normalized() * damage.knockback
	
	_make_number(damage)
	damaged.emit(damage)
	if damage.override_damage_cooldown > 0:
		cooldown.start(damage.override_damage_cooldown)
	else:
		cooldown.start()

func _make_number(damage: Damage) -> void:
	var label := Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.render_priority = 2
	label.text = str(damage.damage)
	label.layers = 16
	label.font_size = 180
	if damage.is_crit: label.modulate = Color.RED
	add_child(label)
	label.top_level = true
	var tween := label.create_tween().set_trans(Tween.TRANS_CIRC)
	tween.tween_property(label, "global_position:x", label.global_position.x + 2, 0.4).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "global_position:y", label.global_position.y + 2, 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "global_position:y", label.global_position.y + 1, 0.2).set_ease(Tween.EASE_IN)
	tween.tween_property(label, "modulate:a", 0, 1)
	tween.tween_callback(func(): label.queue_free())
	
