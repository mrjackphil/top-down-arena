extends Node

var _main_menu_scene: PackedScene = preload("res://assets/ui/scenes/MainMenuView.tscn")

func go_to_main_menu():
	game_over()

func game_over():
	get_tree().change_scene_to_packed(_main_menu_scene)

func _process(_delta):
	if Input.is_action_just_pressed("menu"):
		go_to_main_menu()