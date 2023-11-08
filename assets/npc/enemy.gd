@tool
extends CharacterBody3D

@onready var bullet_scene: PackedScene = preload("res://assets/mech/bullet/bullet.tscn")
@onready var particle_explosion: PackedScene = preload("res://assets/effects/explosion/particle_explosion.tscn")
@onready var healthbar: Sprite3D = $healthbar
@export var _health_component: HealthComponent
@export var _shoot_component: ShootComponent
@export var _move_component: MovementComponent
@export var _rotate_component: MechRotationComponent
@export var _mech_constructor: MechConstructor
@export var _character_body: CharacterBody3D

@onready var damage_timer = Timer.new()

var target: Node3D

func shoot():
	_shoot_component.shoot(true)

func die():
	var particle = particle_explosion.instantiate()
	particle.position = position
	particle.emitting = true
	get_tree().root.get_node("World").call_deferred("add_child", particle)
	queue_free()

func _ready():
	var TIME_TO_SHOOT = 2

	if _health_component:
		_health_component.died.connect(die)
		_health_component.hp_changed.connect(_update_hp_bar)
		# _health_component.hp_changed.connect(on_hurt)

	add_to_group("enemy")

	add_child(damage_timer)
	damage_timer.timeout.connect(shoot)

	damage_timer.start(TIME_TO_SHOOT)

func _update_target():
	var players = get_tree().get_nodes_in_group("player")

	for p in players:
		target = p

func _process(delta):
	if _character_body.is_on_floor():
		_move_to_player(delta)

func _move_to_player(delta: float):
	if not target:
		_update_target()
		return

	var dir_to_move_v3 = (position - target.position).normalized()
	var dir_to_move_v2 = Vector2(dir_to_move_v3.x, dir_to_move_v3.z) * -1

	if _move_component:
		_move_component.move_dir = dir_to_move_v2
	
	if _rotate_component:
		var input_dir = dir_to_move_v2
		var legs_direction = (_mech_constructor.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		_rotate_component.update_body_direction(target.position)
		_rotate_component.update_legs_direction(legs_direction)

func _update_hp_bar(hp: int):
	healthbar.scale.x = float(hp) / float(_health_component.get_max_health())

func _get_configuration_warnings():
	var warnings = []

	if not _health_component:
		warnings.append("Provide health component")

	if not _move_component:
		warnings.append("Provide move component")

	if not _rotate_component:
		warnings.append("Provide rotate component")

	if not _mech_constructor:
		warnings.append("Provide mesh constructor component")

	return warnings
