extends Area3D

const DESTROY_TIMER = 30
var timer = DESTROY_TIMER

@onready var particle_explosion: GPUParticles3D = preload("res://assets/effects/explosion/particle_explosion.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	translate(Vector3(0, 0, 1))
	
	if timer < 0:
		queue_free()

	timer -= 1


func _on_body_entered(body) -> void:
	if (body && body.has_method("queue_free")):
		particle_explosion.position = position
		particle_explosion.emitting = true
		get_tree().root.add_child(particle_explosion)
		body.queue_free()
		queue_free()
		
