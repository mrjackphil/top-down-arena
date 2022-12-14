extends CharacterBody3D
class_name NPC


enum Attitude {
	ENEMY,
	ALLY,
}

# The attitude of the NPC towards the player.
@export var attitude: Attitude = Attitude.ENEMY

@onready var _mech_model: Mech = $Model
@onready var _state_machine: StateMachine = $AI

func _ready() -> void:
	_state_machine.mech = _mech_model
	_state_machine.npc = self
	match attitude:
		Attitude.ENEMY:
			_mech_model.set_color(Color(1, 0, 0))
			add_to_group(GLOBALS.ENEMY_GROUP)
			_state_machine.enemy_group = GLOBALS.ALLY_GROUP
		Attitude.ALLY:
			_mech_model.set_color(Color(0, 1, 0))
			add_to_group(GLOBALS.ALLY_GROUP)
			_state_machine.enemy_group = GLOBALS.ENEMY_GROUP
		_:
			print('Unable to get ', name, ' attitude')


func _physics_process(delta: float) -> void:
	move_and_slide()
