class_name Player extends Actor

@onready var input: Node = $Input
@onready var attack_machine: AttackMachine = $AttackMachine

@export var game_hud: GameHUD
@export var weapon_list: Array[Weapon]
var active_weapon := 0 :
	set(value):
		active_weapon = value % weapon_list.size()
		while active_weapon < 0:
			active_weapon = weapon_list.size() + active_weapon
		if game_hud:
			game_hud.change_weapon_slot(weapon_list[active_weapon])


var is_crouching := false

func _ready() -> void:
	super()
	if game_hud:
		if not game_hud.is_node_ready():
			await game_hud.ready
	active_weapon = active_weapon
