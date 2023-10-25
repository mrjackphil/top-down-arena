extends Node3D
class_name WeaponPlacement

@export var weapon: Weapon

func _ready():
    if weapon:
        add_child(weapon)

func place_weapon(w: Weapon):
    var children = get_children()

    for c in children:
        c.queue_free()

    add_child(w)
    weapon = w
