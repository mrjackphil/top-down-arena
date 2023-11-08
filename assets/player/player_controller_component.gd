extends Node
class_name PlayerControllerComponent

@export var _mech_rotation_component: MechRotationComponent
@export var _user_input_component: UserInputComponent
@export var _mech_constructor: MechConstructor
@export var _game_camera: GameCamera
@export var _health_component: HealthComponent

func die():
	GameManager.game_over()

func _ready():
	_health_component.died.connect(die)
	get_parent().add_to_group("player")

func _process(_delta: float):
	_rotate()

# Rotate mech with its components.
func _rotate() -> void:
	_rotate_base()
	_rotate_legs()


# Rotate base and weapons to mouse position.
func _rotate_base() -> void:
	var mouse_position = get_viewport().get_mouse_position()
	
	var _camera: Camera3D = _game_camera.camera
	var rayOrigin = _camera.project_ray_origin(mouse_position)
	var rayEnd = rayOrigin + _camera.project_ray_normal(mouse_position) * 2000
	
	var query = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd)
	var intersection = _mech_constructor.get_world_3d().direct_space_state.intersect_ray(query)
	
	if not intersection.is_empty():
		# TODO: set y as height of mech if player looking too low
		var pos = Vector3(intersection.position.x, 0, intersection.position.z)
		_mech_rotation_component.update_body_direction(pos)
		_mech_rotation_component.update_weapons_direction(pos)


# Rotate legs to movement direction.
func _rotate_legs() -> void:
	var input_dir = _user_input_component.input_direction
	var legs_direction = (_mech_constructor.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	_mech_rotation_component.update_legs_direction(legs_direction)
