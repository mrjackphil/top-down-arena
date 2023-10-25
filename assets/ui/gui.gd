extends CanvasLayer

@export var player: Node3D
@export var minimap_camera: Camera3D

func _process(_delta):
	minimap_camera.position.x = player.position.x
	minimap_camera.position.z = player.position.z
