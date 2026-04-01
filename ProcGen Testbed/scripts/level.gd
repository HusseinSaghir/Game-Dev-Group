extends Node2D

const FILL_PERCENTAGE: float = 0.4
const ROCK_SCENE = preload("res://scenes/rock.tscn")
const STONE_DATA = preload("res://Data/Rocks/stone.tres")
const IRON_DATA = preload("res://Data/Rocks/iron.tres")
const GOLD_DATA = preload("res://Data/Rocks/gold.tres")

@onready var rock_container: Node2D = $RockContainer
@onready var current_map: Node2D = $Map
@onready var player: CharacterBody2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generateRocks()
	_place_player()
	
func _place_player() -> void:
	var spawn: Marker2D = current_map.get_node("PlayerSpawn")
	player.position = spawn.global_position

func generateRocks() -> void:
	#Clear existing rocks.
	for child in rock_container.get_children():
		child.queue_free()
		
	#Get tilemap layers from current map.
	var ground_layer: TileMapLayer = current_map.get_node("Ground")
	var prop_layer: TileMapLayer = current_map.get_node("Props")
	var ground_cells := ground_layer.get_used_cells()
	var rooms: Array = current_map.get_rooms()
	
	prop_layer.clear()
	
	for room in rooms:
		var available_cells := []
		
		for x in range(room["origin"].x, room["origin"].x + room["width"]):
			for y in range(room["origin"].y, room["origin"].y + room["height"]):
				var cell := Vector2i(x, y)
				var tile_data = ground_layer.get_cell_tile_data(cell)
				if tile_data and tile_data.get_custom_data("canSpawnRocks") == true:
					available_cells.append(cell)
					
		available_cells.shuffle()
		
		var numRocks = (available_cells.size() * FILL_PERCENTAGE)

		for i in range(numRocks):
			var cell = available_cells.pop_front()
			var rock = ROCK_SCENE.instantiate()
		
			#Set rock data
			rock.data = room["room_type"].get_ore_data()
		
			#Get local position from tilemap.
			var local_pos = ground_layer.map_to_local(cell)
		
			rock.position = local_pos
			rock_container.add_child(rock)
