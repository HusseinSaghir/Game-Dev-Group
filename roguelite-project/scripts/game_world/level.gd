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
#CONSTANTS FOR ITEMS AND ENEMIES
#---------------------------------------------------------------------------------------------------
const SLOT_MACHINE = preload("res://scenes/items/slotMachine/slots.tscn")
const WEAPON_SWORD = preload("res://scenes/items/weapon_items/weapon_sword_item.tscn")
const WEAPON_SHORTBOW = preload("res://scenes/items/weapon_items/weapon_shortbow_item.tscn")
const WEAPON_STAFF = preload("res://scenes/items/weapon_items/weapon_staff_item.tscn")
const WEAPON_PISTOL = preload("res://scenes/items/weapon_items/weapon_pistol_item.tscn")
const CRICKETS_HEAD = preload("res://scenes/items/cricketshead.tscn")
const ENEMY_SCENE = preload("res://scenes/enemy/enemy.tscn")
#---------------------------------------------------------------------------------------------------
#NODE REFERENCES
#---------------------------------------------------------------------------------------------------
@onready var rock_container: Node2D = $RockContainer
@onready var current_map: Node2D = $Map
@onready var player: CharacterBody2D = $Player
@onready var item_container: Node2D = $ItemContainer

#Tracks current floor.
var current_floor := 1

#---------------------------------------------------------------------------------------------------
#READY FUNCTION
#---------------------------------------------------------------------------------------------------
func _ready() -> void:
	var prop_layer: TileMapLayer = current_map.get_node("Props")
	prop_layer.clear()
	item_container.z_index = 10 
	_place_player()
	spawn_items()  
	current_map.exit_reached.connect(_on_exit_reached)
	
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
	current_map.generate_sequence()
	current_map.generate_dungeon(current_floor)
	_place_player()
	call_deferred("spawn_items")  # Defer spawning until after physics frame  

#---------------------------------------------------------------------------------------------------
#GENERATE ROCKS (Never called, hold for other props.)
#---------------------------------------------------------------------------------------------------
func generateRocks() -> void:
	for child in rock_container.get_children():                    #Clear existing rocks in container.
		child.queue_free()
		
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
			
func spawn_items() -> void:
	# Clear previous items
	if item_container:
		for child in item_container.get_children():
			child.queue_free()
	
	# Get all valid spawn positions from rooms
	var spawn_positions = _get_all_spawn_positions()
	if spawn_positions.size() < 10:
		print("Not enough spawn positions!")
		return
	
	spawn_positions.shuffle()  # Randomize positions
	
	var used_positions: Array[Vector2] = []
	
	# Spawn slot machine (1)
	_spawn_item(SLOT_MACHINE, spawn_positions, used_positions)
	
	# Spawn weapons (1 of each)
	_spawn_item(WEAPON_SWORD, spawn_positions, used_positions)
	_spawn_item(WEAPON_SHORTBOW, spawn_positions, used_positions)
	_spawn_item(WEAPON_STAFF, spawn_positions, used_positions)
	_spawn_item(WEAPON_PISTOL, spawn_positions, used_positions)
	
	# Spawn crickets head (1)
	_spawn_item(CRICKETS_HEAD, spawn_positions, used_positions)
	
	# Spawn enemies (2) - far from player
	_spawn_enemy(spawn_positions, used_positions)
	_spawn_enemy(spawn_positions, used_positions)

func _get_all_spawn_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	var ground_layer: TileMapLayer = current_map.get_node("Ground")
	var rooms: Array = current_map.get_rooms()
	
	# Get positions from all rooms
	for room in rooms:
		var origin: Vector2i = room["origin"]
		var width: int = room["width"]
		var height: int = room["height"]
		
		# Iterate through room tiles (skip edges for better spawning)
		for x in range(origin.x + 1, origin.x + width - 1):
			for y in range(origin.y + 1, origin.y + height - 1):
				var cell := Vector2i(x, y)
				var tile_data = ground_layer.get_cell_tile_data(cell)
				
				# Check if it's a walkable floor tile
				if tile_data:
					var local_pos = ground_layer.map_to_local(cell)
					positions.append(local_pos)
	
	return positions

func _spawn_item(item_scene: PackedScene, available_positions: Array[Vector2], used_positions: Array[Vector2]) -> void:
	if available_positions.size() == 0:
		print("No available positions!")
		return
	
	# Find unused position
	var spawn_pos: Vector2
	var attempts = 0
	while attempts < 100:
		spawn_pos = available_positions.pick_random()
		if not used_positions.has(spawn_pos):
			break
		attempts += 1
	
	# Spawn the item
	var item = item_scene.instantiate()
	item.global_position = spawn_pos
	item_container.add_child(item)
	used_positions.append(spawn_pos)

func _spawn_enemy(available_positions: Array[Vector2], used_positions: Array[Vector2]) -> void:
	if available_positions.size() == 0:
		print("No available positions for enemy!")
		return
	
	# Find position far from player
	var player_pos = player.global_position
	var best_pos: Vector2
	var max_distance = 0.0
	
	# Check 20 random positions and pick the farthest from player
	for i in range(20):
		var test_pos = available_positions.pick_random()
		if used_positions.has(test_pos):
			continue
		
		var distance = player_pos.distance_to(test_pos)
		if distance > max_distance:
			max_distance = distance
			best_pos = test_pos
	
	# Spawn enemy
	var enemy = ENEMY_SCENE.instantiate()
	enemy.global_position = best_pos
	enemy.player = player  # Set player reference automatically
	item_container.add_child(enemy)
	used_positions.append(best_pos)
