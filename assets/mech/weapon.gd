extends Node3D
class_name Weapon

@onready var root = get_tree().root.get_node("World")
@export var bullet_hole: Node3D
@export var bullet: PackedScene

func shoot(is_enemy_shooting: bool = false):
	var bullet_instance = bullet.instantiate() as Bullet
	bullet_instance.position = bullet_hole.global_position
	bullet_instance.rotation = bullet_hole.global_rotation

	if is_enemy_shooting:
		bullet_instance.set_collision_layer_value(3, true)
	else:
		bullet_instance.set_collision_layer_value(2, true)

	root.add_child(bullet_instance)
