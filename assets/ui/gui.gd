extends CanvasLayer

@export var player: Node3D
@export var minimap_camera: Camera3D
@export var progress_bar: ProgressBar
@export var enemy_count: Label
@export var enemy_counter: Node3D

func _ready():
	for c in player.get_children(false):
		if c is HealthComponent:
			c.hp_changed.connect(_set_progress)

func _set_progress(value: int):
	progress_bar.value = value

func _process(_delta):
	minimap_camera.position.x = player.position.x
	minimap_camera.position.z = player.position.z
	enemy_count.text = str(enemy_counter.enemy_count)
