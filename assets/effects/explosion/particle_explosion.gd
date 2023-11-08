extends GPUParticles3D


func _physics_process(_d):
	if not emitting: queue_free()
