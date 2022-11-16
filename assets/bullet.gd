extends Node3D

const DESTROY_TIMER = 30
var timer = DESTROY_TIMER

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	translate(Vector3(0, 0, 1))
	
	if timer < 0:
		queue_free()

	timer -= 1