extends CharacterBody3D
class_name Player


# Distance from camera from player to mouse.
@export var camera_distance = 5

# Needs for dynamic camera
@onready var _camera_position: Node3D = $CameraRoot/CameraPosition
@export var _mech_model: Mech
@export var _legs_model: Node3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _gravity: Variant = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	if !_mech_model:
		_mech_model = $Model


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= _gravity * delta
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = _mech_model.jump_velocity
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var input_gameplay = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var combined_input_dir = input_dir + input_gameplay
	var direction = (transform.basis * Vector3(combined_input_dir.x, 0, combined_input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * _mech_model.mech_speed
		velocity.z = direction.z * _mech_model.mech_speed
		
		_legs_model.rotation.y = lerp_angle(atan2(-direction.z, direction.x), _legs_model.rotation.y, 0.9)
		
	else:
		velocity.x = move_toward(velocity.x, 0, _mech_model.mech_speed)
		velocity.z = move_toward(velocity.z, 0, _mech_model.mech_speed)
	
	var viewport = get_viewport()
	var mouse_position = viewport.get_mouse_position()
	var body_direction = Vector3(mouse_position.y - viewport.size.y / 2, 0, mouse_position.x - viewport.size.x / 2).normalized()
	var camera_direction = Vector3(mouse_position.x - viewport.size.x / 2, 0, mouse_position.y - viewport.size.y / 2).normalized()
	
	move_and_slide()
	_mech_model.update_body_direction(body_direction)
	_mech_model.update_weapons_direction(body_direction)
	_update_camera_offset(camera_direction)
	
	if Input.is_action_pressed("shoot"):
		if _mech_model.reloaded:
			_mech_model.spawn_bullet()


# Move camera toward the mouse
func _update_camera_offset(dir: Vector3) -> void:
	if _camera_position == null:
		print("Camera not found.")
		set_physics_process(false)
		return
	
	_camera_position.position = lerp(_camera_position.position, dir * camera_distance, 0.1)
