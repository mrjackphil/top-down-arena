extends CharacterBody3D


const SPEED = 20.0
const JUMP_VELOCITY = 4.5

const CAMERA_DISTANCE = 5
const RELOAD_MAX_TIME: int = 10

# Max rotation rad for body.
# TODO: move to export var list.
# NOTE: should be in degrees and convert to rad on _init() function for visibility from editor.
const MAX_BODY_ROTATION_RAD: float = deg_to_rad(20)
# Max rotation rad for weapons.
# TODO: move to export var list.
# NOTE: should be in degrees and convert to rad on _init() function for visibility from editor.
const MAX_WEAPONS_ROTATION_RAD: float = deg_to_rad(7)

@onready var mech_model: Node3D = $Model
@onready var mech_body: Node3D = mech_model.get_node("body")
@onready var mech_legs: Node3D = mech_model.get_node("legs")
@onready var mech_weapon_left: Node3D = mech_body.get_node("weapon_l")
@onready var mech_weapon_right: Node3D = mech_body.get_node("weapon_r")

# Needs for shooting mechanic
@onready var bullet_spawner_l: Node3D = mech_model.get_node("body/weapon_l/bullet_spawn_l")
@onready var bullet_spawner_r: Node3D = mech_model.get_node("body/weapon_r/bullet_spawn_r")
@onready var bullet_node = preload("res://assets/bullet.tscn")

@onready var bullet_spawner_to_shoot = bullet_spawner_l

var reload_timer: int = 0

# Needs for dynamic camera
@onready var camera_position: Node3D = $CameraRoot/CameraPosition

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta


	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var input_gameplay = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var combined_input_dir = input_dir + input_gameplay
	var direction = (transform.basis * Vector3(combined_input_dir.x, 0, combined_input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		_update_legs_direction(direction)
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	_update_body_direction(direction)
	_update_camera_offset(direction)
	_update_weapons_direction()
	
	if reload_timer > 0:
		reload_timer -= 1
	
	if Input.is_action_pressed("shoot"):
		if reload_timer <= 0:
			_spawn_bullet(direction)


# Changes body direction to dir vector.
func _update_body_direction(dir: Vector3) -> void:
	if mech_body == null:
		print("Mech body is not found. Disabling ", name, " instance.")
		set_physics_process(false)
		return
	
	var viewport = get_viewport()
	var mouse_position = viewport.get_mouse_position()
	var mouse_position_vect = Vector3(mouse_position.y - viewport.size.y / 2, 0, mouse_position.x - viewport.size.x / 2).normalized()
	
	var new_angle = -atan2(mouse_position_vect.x, mouse_position_vect.z)
	var diff = _fmod(mech_body.rotation.y - new_angle + PI, TAU) - PI
	if absf(diff) > MAX_BODY_ROTATION_RAD:
		new_angle = mech_body.rotation.y - sign(diff) * MAX_BODY_ROTATION_RAD
	
	mech_body.rotation.y = lerp_angle(new_angle, mech_body.rotation.y, 0.9)


# Changes weapons direction to mouse.
func _update_weapons_direction() -> void:
	if mech_body == null:
		print("Mech body is not found. Disabling ", name, " instance.")
		set_physics_process(false)
		return
	
	if mech_weapon_left == null || mech_weapon_right == null:
		print("Mech weapons are not found. Disabling ", name, " instance.")
		set_physics_process(false)
		return
	
	var viewport = get_viewport()
	var mouse_position = viewport.get_mouse_position()
	var mouse_position_vect = Vector3(mouse_position.y - viewport.size.y / 2, 0, mouse_position.x - viewport.size.x / 2).normalized()
	
	var left_weapon_new_angle = -atan2(mouse_position_vect.x, mouse_position_vect.z)
	var left_weapon_diff = _fmod(mech_weapon_left.global_rotation.y - left_weapon_new_angle + PI, TAU) - PI
	if absf(left_weapon_diff) > MAX_WEAPONS_ROTATION_RAD:
		left_weapon_new_angle = mech_body.rotation.y - sign(left_weapon_diff) * MAX_WEAPONS_ROTATION_RAD
	
	var right_weapon_new_angle = -atan2(mouse_position_vect.x, mouse_position_vect.z)
	var right_weapon_diff = _fmod(mech_weapon_right.global_rotation.y - right_weapon_new_angle + PI, TAU) - PI
	if absf(right_weapon_diff) > MAX_WEAPONS_ROTATION_RAD:
		right_weapon_new_angle = mech_body.rotation.y - sign(right_weapon_diff) * MAX_WEAPONS_ROTATION_RAD
	
	mech_weapon_left.global_rotation.y = lerp_angle(left_weapon_new_angle, mech_weapon_left.global_rotation.y, 0.9)
	mech_weapon_right.global_rotation.y = lerp_angle(right_weapon_new_angle, mech_weapon_right.global_rotation.y, 0.9)


# Custom fmod to get non negative modulo with negative lhs.
# TODO: move to common script file. 
func _fmod(lhs: float, rhs: float) -> float:
	return lhs - floor(lhs / rhs) * rhs


# Changes legs direction to dir vector.
func _update_legs_direction(dir: Vector3) -> void:
	if mech_legs == null:
		print("Mech legs are not found. Disabling ", name, " instance.")
		set_physics_process(false)
		return
	
	var viewport = get_viewport()
	mech_legs.rotation.y = lerp_angle(atan2(-dir.z, dir.x), mech_legs.rotation.y, 0.9)

# Move camera toward the mouse
func _update_camera_offset(dir: Vector3) -> void:
	if camera_position == null:
		print("Camera not found.")
		set_physics_process(false)
		return
	
	var viewport = get_viewport()
	var mouse_position = viewport.get_mouse_position()
	var mouse_position_vect = Vector3(
		mouse_position.x - viewport.size.x / 2,
		0,
		mouse_position.y - viewport.size.y / 2).normalized()
		
	camera_position.position = lerp(camera_position.position, mouse_position_vect * CAMERA_DISTANCE, 0.1)


func _spawn_bullet(dir: Vector3) -> void:
	if bullet_spawner_l == null or bullet_spawner_r == null:
		print_debug('Bullet spawners not found')
		return
		
	var viewport = get_viewport()
	var mouse_position = viewport.get_mouse_position()
	var mouse_position_vect = Vector3(mouse_position.y - viewport.size.y / 2, 0, mouse_position.x - viewport.size.x / 2).normalized()
	
	var bullet = bullet_node.instantiate()
	get_node("/root/World").add_child(bullet)
	
	bullet.position = bullet_spawner_to_shoot.global_position
	bullet.rotation.y = -atan2(mouse_position_vect.x, mouse_position_vect.z) + PI / 2
	reload_timer = RELOAD_MAX_TIME
	
	if bullet_spawner_to_shoot == bullet_spawner_l:
		bullet_spawner_to_shoot = bullet_spawner_r
	else: 
		bullet_spawner_to_shoot = bullet_spawner_l
