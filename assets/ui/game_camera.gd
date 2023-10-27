extends Node3D
class_name GameCamera

# Distance from camera from player to mouse.
@export var camera_distance = 5

@onready var camera: Camera3D = $CameraPosition/Camera
@onready var _camera_position: Node3D = $CameraPosition

func _physics_process(_delta):
	var viewport = get_viewport()
	var mouse_position = viewport.get_mouse_position()
	var camera_direction = Vector3(mouse_position.x - viewport.size.x / 2, 0, mouse_position.y - viewport.size.y / 2).normalized()
	_camera_position.position = lerp(_camera_position.position, camera_direction * camera_distance, 0.1)
