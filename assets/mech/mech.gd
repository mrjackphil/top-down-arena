extends Node3D
class_name Mech


# Mech movement speed.
@export_range(10, 50, 0.2) var mech_speed: float = 20.0
# Mech velocity on jumping.
@export_range(3, 20, 0.5) var jump_velocity: float = 4.5

# Weapons reload time in seconds.
@export_range(0.01, 5) var reload_time_sec: float = 0.2

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


# Is mech ready to fire.
var reloaded: bool = true

# Max rotation rad for body.
var _body_rotation_speed_rad: float = deg_to_rad(body_rotation_speed)
# Max rotation rad for weapons. Should be less than body rotation speed.
var _weapons_rotation_speed_rad: float = deg_to_rad(weapons_rotation_speed)


# Model parts for faster loading.
@onready var _mech_body: Node3D = $body
@onready var _mech_legs: Node3D = $legs
@onready var _mech_weapon_left: Node3D = $body/weapon_l
@onready var _mech_weapon_right: Node3D = $body/weapon_r

# Needs for shooting mechanic
@onready var _bullet_spawner_l: Node3D = $body/weapon_l/bullet_spawn_l
@onready var _bullet_spawner_r: Node3D = $body/weapon_r/bullet_spawn_r
@onready var _bullet_node = preload("res://assets/mech/bullet/bullet.tscn")

# Current bullet spawner. Changes when a new bullet spawned.
@onready var _bullet_spawner_to_shoot: Node3D = _bullet_spawner_l


# Changes body direction to dir vector.
func update_body_direction(dir: Vector3) -> void:
	if _mech_body == null:
		print("Mech body is not found. Disabling ", name, " instance.")
		set_physics_process(false)
		return
	
	var new_angle = -atan2(dir.x, dir.z)
	var diff = _fmod(_mech_body.rotation.y - new_angle + PI, TAU) - PI
	if absf(diff) > _body_rotation_speed_rad:
		new_angle = _mech_body.rotation.y - sign(diff) * _body_rotation_speed_rad
	
	_mech_body.rotation.y = lerp_angle(new_angle, _mech_body.rotation.y, 0.9)


# Changes weapons direction to mouse.
func update_weapons_direction(dir: Vector3) -> void:
	if _mech_body == null:
		print("Mech body is not found. Disabling ", name, " instance.")
		set_physics_process(false)
		return
	
	if _mech_weapon_left == null or _mech_weapon_right == null:
		print("Mech weapons are not found. Disabling ", name, " instance.")
		set_physics_process(false)
		return
	
	var left_weapon_new_angle = -atan2(dir.x, dir.z)
	var left_weapon_diff = _fmod(_mech_weapon_left.global_rotation.y - left_weapon_new_angle + PI, TAU) - PI
	if absf(left_weapon_diff) > _weapons_rotation_speed_rad:
		left_weapon_new_angle = _mech_body.rotation.y - sign(left_weapon_diff) * _weapons_rotation_speed_rad
	
	var right_weapon_new_angle = -atan2(dir.x, dir.z)
	var right_weapon_diff = _fmod(_mech_weapon_right.global_rotation.y - right_weapon_new_angle + PI, TAU) - PI
	if absf(right_weapon_diff) > _weapons_rotation_speed_rad:
		right_weapon_new_angle = _mech_body.rotation.y - sign(right_weapon_diff) * _weapons_rotation_speed_rad
	
	_mech_weapon_left.global_rotation.y = lerp_angle(left_weapon_new_angle, _mech_weapon_left.global_rotation.y, 0.9)
	_mech_weapon_right.global_rotation.y = lerp_angle(right_weapon_new_angle, _mech_weapon_right.global_rotation.y, 0.9)


# Changes legs direction to dir vector.
func update_legs_direction(dir: Vector3) -> void:
	if _mech_legs == null:
		print("Mech legs are not found. Disabling ", name, " instance.")
		set_physics_process(false)
		return
	
	var viewport = get_viewport()
	_mech_legs.rotation.y = lerp_angle(atan2(-dir.z, dir.x), _mech_legs.rotation.y, 0.9)


# Spawns bullet and fires it to weapons direction.
func spawn_bullet() -> void:
	if !reloaded:
		return
	
	reloaded = false
	if _bullet_spawner_l == null or _bullet_spawner_r == null:
		print_debug('Bullet spawners not found')
		return
	
	var bullet = _bullet_node.instantiate()
	get_node("/root/World").add_child(bullet)
	
	bullet.position = _bullet_spawner_to_shoot.global_position
	$reload_timer.start(reload_time_sec)
	
	if _bullet_spawner_to_shoot == _bullet_spawner_l:
		_bullet_spawner_to_shoot = _bullet_spawner_r
		bullet.rotation.y = _mech_weapon_left.global_rotation.y + PI / 2
	else: 
		_bullet_spawner_to_shoot = _bullet_spawner_l
		bullet.rotation.y = _mech_weapon_left.global_rotation.y + PI / 2


# Custom fmod to get non negative modulo with negative lhs.
# TODO: move to common script file. 
func _fmod(lhs: float, rhs: float) -> float:
	return lhs - floor(lhs / rhs) * rhs


# Reload weapons by timer.
func _on_reload_timer_timeout():
	reloaded = true
