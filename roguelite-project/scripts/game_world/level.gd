extends Node2D

#---------------------------------------------------------------------------------------------------
#CONSTANTS FOR PROP GENERATION AND FLOOR GENERATION
#---------------------------------------------------------------------------------------------------
const FILL_PERCENTAGE: float = 0.4
#const ROCK_SCENE = preload("res://scenes/rock.tscn")
#const STONE_DATA = preload("res://Data/Rocks/stone.tres")
#const IRON_DATA = preload("res://Data/Rocks/iron.tres")
#const GOLD_DATA = preload("res://Data/Rocks/gold.tres")
const MAX_FLOORS := 3

#---------------------------------------------------------------------------------------------------
#NODE REFERENCES
#---------------------------------------------------------------------------------------------------
#@onready var rock_container: Node2D = $RockContainer
@onready var current_map: Node2D = $Map
@onready var player: CharacterBody2D = $Player

#Tracks current floor.
var current_floor := 1

#---------------------------------------------------------------------------------------------------
#READY FUNCTION
#---------------------------------------------------------------------------------------------------
func _ready() -> void:
	#for child in rock_container.get_children():                 #Clears rock container.
		#child.queue_free()
	var prop_layer: TileMapLayer = current_map.get_node("Props")#Clears prop layer.
	prop_layer.clear()
	_place_player()                                             #Places player.
	current_map.exit_reached.connect(_on_exit_reached)          #Listens for "exit_reached" signal
																#From room_generator.gd.
	
#---------------------------------------------------------------------------------------------------
#PLACES PLAYER AT SPAWN
#---------------------------------------------------------------------------------------------------
func _place_player() -> void:
	var spawn: Marker2D = current_map.get_node("PlayerSpawn")
	player.global_position = spawn.global_position

#---------------------------------------------------------------------------------------------------
#EXIT BEHAVIOR
#---------------------------------------------------------------------------------------------------
func _on_exit_reached() -> void:
	if current_floor >= MAX_FLOORS: #Once floor 3 is reached, skip _next_floor and end game.
		return
	current_floor += 1              #Increment current_floor by one.
	_next_floor()                   #Execute _next_floor().

#---------------------------------------------------------------------------------------------------
#GENERATE NEW FLOOR
#---------------------------------------------------------------------------------------------------
func _next_floor() -> void:
	current_map.generate_sequence()            #Generate room type sequence.
	current_map.generate_dungeon(current_floor)#Generate new floor, pass current_floor number.
	_place_player()                            #Place player at new floor spawn point.

#---------------------------------------------------------------------------------------------------
#GENERATE ROCKS (Never called, hold for other props.)
#---------------------------------------------------------------------------------------------------
func generateRocks() -> void:
	#for child in rock_container.get_children():                    #Clear existing rocks in container.
		#child.queue_free()
		
	var ground_layer: TileMapLayer = current_map.get_node("Ground")#Get tile layers.
	var prop_layer: TileMapLayer = current_map.get_node("Props")
	var ground_cells := ground_layer.get_used_cells()              #Gets cells with tiles.
	var rooms: Array = current_map.get_rooms()                     #Gets rooms.
	
	prop_layer.clear()                                             #Clears prop layer.
	
	for room in rooms:                                             #For each room, cycle through all
		var available_cells := []                                  #cells, append to available_cells
																   #if canSpawnRocks = true.
		for x in range(room["origin"].x, room["origin"].x + room["width"]):
			for y in range(room["origin"].y, room["origin"].y + room["height"]):
				var cell := Vector2i(x, y)
				var tile_data = ground_layer.get_cell_tile_data(cell)
				if tile_data and tile_data.get_custom_data("canSpawnRocks") == true:
					available_cells.append(cell)
					
		available_cells.shuffle()                                  #Shuffle available_cells to randomize.
		
		var numRocks = (available_cells.size() * FILL_PERCENTAGE)  #NumRocks equivalent to 40% of
																   #available cells.
		for i in range(numRocks):                                  #Place rocks.
			var cell = available_cells.pop_front()
			#var rock = ROCK_SCENE.instantiate()
		
			#rock.data = room["room_type"].get_ore_data()           #Set rock data
		
			var local_pos = ground_layer.map_to_local(cell)        #Get local position from tilemap.
		
			#rock.position = local_pos                              #Place rock, add to container.
			#rock_container.add_child(rock)
