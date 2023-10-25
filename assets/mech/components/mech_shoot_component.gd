extends Node
class_name ShootComponent

@export var _input_component: UserInputComponent
@export var _mech_constructor: MechConstructor

var _active_weapon_index = 0
var _timer: Timer = Timer.new()

var is_reloading = false

# TODO: Move logic to weapons
@export_range(0.01, 5) var reload_time_sec: float = 0.2

func _ready():
	if _input_component:
		_input_component.connect(_input_component.shoot_pressed.get_name(), _shoot)

	_timer.one_shot = true
	_timer.timeout.connect(func (): is_reloading = false)
	add_child(_timer)

func _shoot():
	if is_reloading:
		return

	if _active_weapon_index >= _mech_constructor.equipped_weapons.size():
		_active_weapon_index = 0

	_mech_constructor.equipped_weapons[_active_weapon_index].shoot()

	_active_weapon_index += 1
		
	_timer.start(reload_time_sec)
	is_reloading = true
		
