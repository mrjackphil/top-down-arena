extends Node
class_name UserInputComponent

signal jump_pressed
signal shoot_pressed

var input_direction: Vector2 = Vector2.ZERO

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		jump_pressed.emit()

	if Input.is_action_pressed("shoot"):
		shoot_pressed.emit()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var input_gameplay = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	input_direction = input_dir + input_gameplay
