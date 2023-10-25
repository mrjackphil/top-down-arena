extends Node
class_name MovementComponent

@export var _character_body: CharacterBody3D
@export var _input_component: UserInputComponent

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _gravity: Variant = ProjectSettings.get_setting("physics/3d/default_gravity")

# Mech movement speed.
@export_range(5, 50, 0.2) var mech_speed: float = 10.0
# Mech velocity on jumping.
@export_range(3, 20, 0.5) var jump_velocity: float = 4.5

func _ready():
	if _input_component:
		_input_component.connect(_input_component.jump_pressed.get_name(), _jump)

	if not _character_body:
		printerr("CharacterBody3D not provided for MovementComponent in", owner)
		printerr("Movement component works only with CharacterBody3D")

func _jump():
	if _character_body.is_on_floor():
		_character_body.velocity.y = jump_velocity

func _physics_process(delta):
	if not _character_body:
		return

	# Add the gravity.
	if not _character_body.is_on_floor():
		_character_body.velocity.y -= _gravity * delta
		
	var input_dir = Vector3.ZERO

	if _input_component && _input_component.input_direction:
		input_dir = _input_component.input_direction
	
	var direction = (_character_body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		_character_body.velocity.x = direction.x * mech_speed
		_character_body.velocity.z = direction.z * mech_speed
		
		# _legs_model.rotation.y = lerp_angle(atan2(-direction.z, direction.x), _legs_model.rotation.y, 0.9)
		
	else:
		_character_body.velocity.x = move_toward(_character_body.velocity.x, 0, mech_speed)
		_character_body.velocity.z = move_toward(_character_body.velocity.z, 0, mech_speed)
	
	# var viewport = get_viewport()
	# var mouse_position = viewport.get_mouse_position()
	# var body_direction = Vector3(mouse_position.y - viewport.size.y / 2, 0, mouse_position.x - viewport.size.x / 2).normalized()
	# var camera_direction = Vector3(mouse_position.x - viewport.size.x / 2, 0, mouse_position.y - viewport.size.y / 2).normalized()
	
	_character_body.move_and_slide()
	# _mech_model.update_body_direction(body_direction)
	# _mech_model.update_weapons_direction(body_direction)
	# _update_camera_offset(camera_direction)
	
	# if Input.is_action_pressed("shoot"):
	# 	if _mech_model.reloaded:
	# 		_mech_model.spawn_bullet()
	pass
