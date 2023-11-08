extends Marker3D


@export var step_target: Node3D
@export var step_distance: float = 3.0

@export var adjacent_target: Node3D

var is_stepping := false

func _process(_delta):
	if !is_stepping and !adjacent_target.is_stepping and abs(global_position.distance_to(step_target.global_position)) > step_distance:
		step()

func step():
	var target_pos = step_target.global_position
	var half_way = (global_position + step_target.global_position) / 2

	is_stepping = true

	var t = create_tween()
	t.tween_property(self, "global_position", half_way + owner.basis.y, 0.1)
	t.tween_property(self, "global_position", target_pos, 0.1)
	t.tween_callback(unstep)

func unstep():
	is_stepping = false
