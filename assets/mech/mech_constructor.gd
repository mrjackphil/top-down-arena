extends Node3D
class_name MechConstructor

@export var base: PackedScene
@export var weapons: Array[PackedScene]
@export var legs: Node3D

@onready var equipped_base: Base = $Base
var equipped_weapons: Array[Weapon] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_weapons()

	if equipped_base:
		_update_base()

func _update_base():
	if not equipped_base:
		printerr("Base not provided")
		return

	var new_base = base.instantiate() as Base
	new_base.position = equipped_base.position

	add_child(new_base)

	equipped_base.queue_free()
	equipped_base = new_base

	_update_weapons()

func _update_weapons():
	equipped_weapons = []

	for i in equipped_base.weapon_placements.size():
		if not weapons[i]:
			continue

		var weapon_instance: Weapon = weapons[i].instantiate() as Weapon

		equipped_weapons.append(weapon_instance)
		equipped_base.weapon_placements[i].add_child(weapon_instance)
