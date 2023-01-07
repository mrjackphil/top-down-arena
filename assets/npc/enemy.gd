extends CharacterBody3D

@onready var particle_explosion: GPUParticles3D = preload("res://assets/effects/explosion/particle_explosion.tscn").instantiate()
@onready var healthbar: Sprite3D = $healthbar

const MAX_HEALTH: float = 10
var health: float = 10

func on_hurt(dmg: int = 1) -> void:
	health -= dmg
	
	healthbar.scale.x = health / MAX_HEALTH
	
	if health <= 0:
		particle_explosion.position = position
		particle_explosion.emitting = true
		get_tree().root.add_child(particle_explosion)
		queue_free()
