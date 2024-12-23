class_name Player extends Actor

@onready var health: Node = $Health
@onready var input: Node = $Input
@onready var attack_machine: AttackMachine = $AttackMachine

var is_crouching := false
