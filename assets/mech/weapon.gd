extends Node3D
class_name Weapon

@onready var root = get_tree().root
@export var bullet_hole: Node3D
@export var bullet: PackedScene

func shoot():
	var bullet_instance = bullet.instantiate() as Node3D
	bullet_instance.position = bullet_hole.global_position
	bullet_instance.rotation = bullet_hole.global_rotation
	root.add_child(bullet_instance)
