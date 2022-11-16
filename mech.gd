extends CharacterBody3D


const SPEED = 20.0
const JUMP_VELOCITY = 4.5

const CAMERA_DISTANCE = 5

@onready var mech_model: Node3D = $Model
@onready var mech_body: Node3D = mech_model.get_node("body")
@onready var mech_legs: Node3D = mech_model.get_node("legs")

# Needs for shooting mechanic
@onready var bullet_spawner_l: Node3D = mech_model.get_node("body/weapon_l/bullet_spawn_l")
@onready var bullet_spawner_r: Node3D = mech_model.get_node("body/weapon_r/bullet_spawn_r")
@onready var bullet_node = preload("res://assets/bullet.tscn")

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
	_update_body_direction()
	_update_camera_offset(direction)
	
	if Input.is_action_just_pressed("shoot"):
		_spawn_bullet(direction)


# Changes body direction to dir vector.
func _update_body_direction() -> void:
	if mech_body == null:
		print("Mech body is not found. Disabling ", name, " instance.")
		set_physics_process(false)
		return
	
	var camera = $CameraRoot/CameraPosition/Camera
	
	var space_state = get_world_3d().direct_space_state
	
	var ray_length = 2000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var intersection = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	
	if not intersection.is_empty():
		var pos = intersection.position
		mech_body.look_at(Vector3(pos.x, mech_body.position.y, pos.z))
		mech_body.rotate_y(PI/2)


# Changes legs direction to dir vector.
func _update_legs_direction(dir: Vector3) -> void:
	if mech_legs == null:
		print("Mech legs are not found. Disabling ", name, " instance.")
		set_physics_process(false)
		return
	
	var viewport = get_viewport()
	mech_legs.rotation.y = lerp_angle(atan2(-dir.x, -dir.z), mech_legs.rotation.y, 0.9)

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
	if bullet_spawner_l == null:
		return
		
	var viewport = get_viewport()
	var mouse_position = viewport.get_mouse_position()
	var mouse_position_vect = Vector3(mouse_position.y - viewport.size.y / 2, 0, mouse_position.x - viewport.size.x / 2).normalized()
	
	var bullet = bullet_node.instantiate()
	get_node("/root/World").add_child(bullet)
	bullet.position = bullet_spawner_l.global_position
	bullet.rotation.y = -atan2(mouse_position_vect.x, mouse_position_vect.z) + PI / 2
	
