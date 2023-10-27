extends Node
class_name MechRotationComponent

@export var _input_component: UserInputComponent
@export var _mech_constructor: MechConstructor

@onready var _mech_body: Base = _mech_constructor.equipped_base
@onready var _mech_legs: Node3D = _mech_constructor.legs

# Max rotation degree for body. Degrees for human reading.
@export_range(5, 30, 0.5) var body_rotation_speed: float = 20 : 
	get:
		return body_rotation_speed
	set(value):
		body_rotation_speed = value
		_body_rotation_speed_rad = deg_to_rad(value)

# Max rotation degree for weapons. Should be less than body rotation speed. Degrees for human reading.
@export_range(1, 30, 0.5) var weapons_rotation_speed: float = 7 :
	get:
		return weapons_rotation_speed
	set(value):
		weapons_rotation_speed = value
		_weapons_rotation_speed_rad = deg_to_rad(value)

# Max rotation rad for body.
var _body_rotation_speed_rad: float = deg_to_rad(body_rotation_speed)
# Max rotation rad for weapons. Should be less than body rotation speed.
var _weapons_rotation_speed_rad: float = deg_to_rad(weapons_rotation_speed)

func update_legs_direction(dir: Vector3):
	_mech_legs.rotation.y = lerp_angle(atan2(-dir.z, dir.x), _mech_legs.rotation.y, 0.9)

# Changes body direction to dir vector.
func update_body_direction(dir: Vector3) -> void:
	if _mech_body.global_transform.origin.dot(dir) != 0:
		_mech_body.look_at(dir)
		_mech_body.rotate_object_local(Vector3(0, -1, 0), -PI / 2.0)
	else:
		_mech_body.set_rotation(dir)


# Changes weapons direction to mouse.
func update_weapons_direction(dir: Vector3) -> void:
	pass
	# if _mech_body == null:
	# 	print("Mech body is not found. Disabling ", name, " instance.")
	# 	set_physics_process(false)
	# 	return
	
	# if _mech_weapon_left == null or _mech_weapon_right == null:
	# 	print("Mech weapons are not found. Disabling ", name, " instance.")
	# 	set_physics_process(false)
	# 	return
	
	# var left_weapon_new_angle = -atan2(dir.x, dir.z)
	# var left_weapon_diff = _fmod(_mech_weapon_left.global_rotation.y - left_weapon_new_angle + PI, TAU) - PI
	# if absf(left_weapon_diff) > _weapons_rotation_speed_rad:
	# 	left_weapon_new_angle = _mech_body.rotation.y - sign(left_weapon_diff) * _weapons_rotation_speed_rad
	
	# var right_weapon_new_angle = -atan2(dir.x, dir.z)
	# var right_weapon_diff = _fmod(_mech_weapon_right.global_rotation.y - right_weapon_new_angle + PI, TAU) - PI
	# if absf(right_weapon_diff) > _weapons_rotation_speed_rad:
	# 	right_weapon_new_angle = _mech_body.rotation.y - sign(right_weapon_diff) * _weapons_rotation_speed_rad
	
	# _mech_weapon_left.global_rotation.y = lerp_angle(left_weapon_new_angle, _mech_weapon_left.global_rotation.y, 0.9)
	# _mech_weapon_right.global_rotation.y = lerp_angle(right_weapon_new_angle, _mech_weapon_right.global_rotation.y, 0.9)

# Custom fmod to get non negative modulo with negative lhs.
# TODO: move to common script file. 
func _fmod(lhs: float, rhs: float) -> float:
	return lhs - floor(lhs / rhs) * rhs
