extends Node3D

var _enemy = preload("res://assets/npc/npc.tscn")
var enemy_count = 0

func start_waves():
	pass

func spawn_enemies(size: int = 10):
	for i in size:
		var instance = _enemy.instantiate() as Node3D
		instance.position = Vector3(randi_range(-100, 100), randi_range(20, 50), randi_range(-100, 100))
		add_child(instance)
		enemy_count += 1

func check_wave():
	var enemies = get_tree().get_nodes_in_group("enemy")

	enemy_count = enemies.size()

	if enemy_count == 0:
		spawn_enemies()

func next_wave():
	pass

func stop_waves():
	pass

func _process(_delta):
	check_wave()