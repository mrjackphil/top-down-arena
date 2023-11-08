extends Node

@export var start_game_btn: Button
@export var options_btn: Button
@export var exit_game_btn: Button

@export var scene_to_load: PackedScene = preload("res://Test_Scene.tscn")

func _ready():
	start_game_btn.pressed.connect(_start_game)
	exit_game_btn.pressed.connect(_exit_game)

func _start_game():
	get_tree().change_scene_to_packed(scene_to_load)

func _exit_game():
	get_tree().quit()
