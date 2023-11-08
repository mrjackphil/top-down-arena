@tool

extends Area3D
class_name HitboxComponent

@export var _health_components: Array[HealthComponent]

signal hit(damage: int)

func _ready():
	for health_component in _health_components:
		hit.connect(health_component.hurt)

	area_entered.connect(_on_hit)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []

	if _health_components.size() == 0:
		warnings.push_front("Components need HealthComponents provided")

	return warnings

func _on_hit(c: Node3D):
	if c is Bullet:
		hit.emit(c.get_damage())
		c.hit()
