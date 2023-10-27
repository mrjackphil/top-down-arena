extends Node
class_name FractionComponent

# Script for some cpecific fractions types and methods.
# NOTE: maybe should be transformed to simple global common script.

@export var _target_object: CharacterBody3D
@export var _target_side: FractionComponent.fraction = fraction.ALLIES

# Fraction of player and npc's.
# NOTE: maybe there should be more than 2 fraction.
enum fraction {
	ENEMIES,
	ALLIES,
}

# Helper to name and organize a subset of nodes.
var groups: Dictionary = {
	fraction.ENEMIES: "enemies",
	fraction.ALLIES:  "allies",
}

func _ready() -> void:
	if _target_object == null:
		print('FractionComponent: unable to add target to group - target is null')
		return
	
	_target_object.add_to_group(groups[_target_side])


# Change target fraction.
func change_side(new_side: fraction) -> void:
	_target_object.remove_from_group(groups[_target_side])
	_target_object.add_to_group(groups[new_side])
	_target_side = new_side


# Current target fraction.
func side() -> fraction:
	return _target_side
