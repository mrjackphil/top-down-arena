extends Area3D
class_name Bullet

const DESTROY_TIMER = 30
var timer = DESTROY_TIMER
@export var DAMAGE = 10

@onready var particle_explosion: GPUParticles3D = preload("res://assets/effects/explosion/particle_explosion.tscn").instantiate()

func get_damage():
	return DAMAGE

# Logic when bullet hit the target
func hit():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	translate(Vector3(delta * 60, 0, 0))
	
	if timer < 0:
		queue_free()

	timer -= 1
