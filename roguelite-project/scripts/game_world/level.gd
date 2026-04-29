extends Node2D

#---------------------------------------------------------------------------------------------------
#CONSTANTS FOR PROP GENERATION AND FLOOR GENERATION
#---------------------------------------------------------------------------------------------------
const ENEMY_FILL_PERCENTAGE: float = 0.05
const COIN_FILL_PERCENTAGE: float = 0.1
const ENEMY_SCENE = preload("res://scenes/enemy/enemy.tscn")
const KEY_SCENE = preload("res://scenes/items/pickups/pickup_key.tscn")
const TEST_WEAPON_SCENE = preload("res://scenes/items/weapon_items/weapon_pistol_item.tscn")
const COIN_SCENE = preload("res://scenes/items/pickups/pickup_coin.tscn")
#const GOLD_DATA = preload("res://Data/Rocks/gold.tres")
const MAX_FLOORS := 3

#---------------------------------------------------------------------------------------------------
#NODE REFERENCES
#---------------------------------------------------------------------------------------------------
@onready var enemy_container: Node2D = $enemy_container
@onready var current_map: Node2D = $Map
@onready var player: CharacterBody2D = $Player

#Tracks current floor.
var current_floor := 1

#---------------------------------------------------------------------------------------------------
#READY FUNCTION
#---------------------------------------------------------------------------------------------------
func _ready() -> void:
	#for child in enemy_container.get_children():                 #Clears rock container.
		#child.queue_free()
	var prop_layer: TileMapLayer = current_map.get_node("Props")#Clears prop layer.
	prop_layer.clear()
	_place_player()
	generateRocks()                                             #Places player.
	current_map.exit_reached.connect(_on_exit_reached)          #Listens for "exit_reached" signal
																#From room_generator.gd.
	
#---------------------------------------------------------------------------------------------------
#PLACES PLAYER AT SPAWN
#---------------------------------------------------------------------------------------------------
func _place_player() -> void:
	var spawn: Marker2D = current_map.get_node("PlayerSpawn")
	player.global_position = spawn.global_position
	var test_weapon = TEST_WEAPON_SCENE.instantiate()
	test_weapon.position = spawn.global_position + Vector2(32, 0)
	add_child(test_weapon)

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
	for child in current_map.get_children():
		if child is TroomDoor or child is RoomGate:
			child.queue_free()
	current_map.generate_sequence()            #Generate room type sequence.
	current_map.generate_dungeon(current_floor)#Generate new floor, pass current_floor number.
	_place_player()
	generateRocks()                            #Place player at new floor spawn point.

#---------------------------------------------------------------------------------------------------
#GENERATE ROCKS (Never called, hold for other props.)
#---------------------------------------------------------------------------------------------------
func generateRocks() -> void:
	for child in enemy_container.get_children():                    #Clear existing rocks in container.
		child.queue_free()
		
	var ground_layer: TileMapLayer = current_map.get_node("Ground")#Get tile layers.
	var prop_layer: TileMapLayer = current_map.get_node("Props")
	var ground_cells := ground_layer.get_used_cells()              #Gets cells with tiles.
	var rooms: Array = current_map.get_rooms()                     #Gets rooms.
	
	prop_layer.clear()  
												  #Clears prop layer.
	for i in range(rooms.size()):                                             #For each room, cycle through all
		var room = rooms[i]
		
		var container = Node2D.new()
		container.name = "Room_" + str(i) + "_Enemies"
		current_map.add_child(container)
		room["enemy_container"] = container 
		
		var available_cells := []                                #cells, append to available_cells
																   #if canSpawnRocks = true.
		for x in range(room["origin"].x, room["origin"].x + room["width"]):
			for y in range(room["origin"].y, room["origin"].y + room["height"]):
				var cell := Vector2i(x, y)
				var tile_data = ground_layer.get_cell_tile_data(cell)
				if tile_data and tile_data.get_custom_data("canSpawnEnemies") == true:
					available_cells.append(cell)
					
		available_cells.shuffle()                                  #Shuffle available_cells to randomize.
		
		var numEnemies = (available_cells.size() * ENEMY_FILL_PERCENTAGE)
		var numCoins = (available_cells.size() * COIN_FILL_PERCENTAGE)  #NumRocks equivalent to 40% of
																   #available cells.
		for n in range(numEnemies):                                  #Place rocks.
			var cell = available_cells.pop_front()
			var entity = ENEMY_SCENE.instantiate()
		
			#rock.data = room["room_type"].get_ore_data()           #Set rock data
		
			#var local_pos = ground_layer.map_to_local(cell)        #Get local position from tilemap.
		
			entity.position = ground_layer.map_to_local(cell)                              #Place rock, add to container.
			container.add_child(entity)
			#entity.player = player
			container.child_exiting_tree.connect(_check_room_clear.bind(i))
		
		for n in range(numCoins):
			var cell = available_cells.pop_front()
			var coin = COIN_SCENE.instantiate()
			
			coin.position = ground_layer.map_to_local(cell)
			add_child(coin)
			
func _check_room_clear(node: Node, room_index: int) -> void:
	var room = current_map.get_rooms()[room_index]
	var container = room["enemy_container"]
	
	if container.get_child_count() <= 1:
		if room["room_gate"] != null:
			room["room_gate"].get_node("CollisionShape2D").queue_free()
			print("Room ", room_index, " cleared. Door opened.")
