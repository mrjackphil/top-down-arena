extends Node

@export @onready var cell: PackedScene = preload("res://assets/map/plane.tscn")

var root_node = get_node("/root")

# Map -> Cell -> Tile

const MAP_HEIGHT = 5
const MAP_WIDTH  = 5

const CELL_HEIGHT = 5
const CELL_WIDTH  = 5  

const TILE_SIZE   = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_map()
	
func generate_map():
	root_node = get_node("/root")
	
	if root_node == null:
		return
	
	for y in range(-MAP_HEIGHT, MAP_HEIGHT):
		for x in range(-MAP_WIDTH, MAP_WIDTH):
			generate_cell(x, y) 
	
func generate_cell(cell_x: int, cell_y: int):
	for y in range(0, CELL_HEIGHT):
		for x in range(0, CELL_WIDTH):
			var tile_x = cell_x * TILE_SIZE * CELL_HEIGHT + x * TILE_SIZE
			var tile_y = cell_y * TILE_SIZE * CELL_WIDTH + y * TILE_SIZE
			generate_tile(tile_x, tile_y)
	
func generate_tile(x: int, y: int):
	if root_node == null:
		return
		
	var cell_instance = cell.instantiate()
	cell_instance.position.x = x
	cell_instance.position.z = y
	
	if (x != 0 or y != 0) and randi_range(1, 6) > 5:
		cell_instance.size.y = randi_range(0, 10)
	
	root_node.call_deferred("add_child", cell_instance)
