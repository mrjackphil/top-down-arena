extends CharacterBody3D


const SPEED = 20.0
const JUMP_VELOCITY = 4.5

@onready var mech_model: Node3D = $mech

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var input_gameplay = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var combined_input_dir = input_dir + input_gameplay
	var direction = (transform.basis * Vector3(combined_input_dir.x, 0, combined_input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		if velocity.x > 0:
			mech_model.rotation.y = lerp(mech_model.rotation.y, 0.1, 0.1)
			
		if velocity.x < 0:
			mech_model.rotation.y = lerp(mech_model.rotation.y, 3.14, 0.1)
			
		if velocity.z < 0:
			mech_model.rotation.y = lerp(mech_model.rotation.y, 1.57, 0.1)
			
		if velocity.z > 0:
			mech_model.rotation.y = lerp(mech_model.rotation.y, -1.57, 0.1)
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
