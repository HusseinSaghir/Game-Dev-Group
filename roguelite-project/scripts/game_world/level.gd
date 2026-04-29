extends Node2D

#---------------------------------------------------------------------------------------------------
#CONSTANTS FOR PROP GENERATION AND FLOOR GENERATION
#---------------------------------------------------------------------------------------------------
const ENEMY_FILL_PERCENTAGE: float = 0.05
const COIN_FILL_PERCENTAGE: float = 0.05
const KEY_SCENE = preload("res://scenes/items/pickups/pickup_key.tscn")
const TEST_WEAPON_SCENE = preload("res://scenes/items/weapon_items/weapon_pistol_item.tscn")
const COIN_SCENE = preload("res://scenes/items/pickups/pickup_coin.tscn")
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
const DAMAGE_GEM = preload("res://scenes/items/damage_gem.tscn")
const CHEESE = preload("res://scenes/items/cheese.tscn")
const FEATHER = preload("res://scenes/items/feather.tscn")
const MEDBREW = preload("res://scenes/items/medbrew.tscn")
const ENEMY_SCENE = preload("res://scenes/enemy/enemy.tscn")

const PASSIVE_ITEMS = [DAMAGE_GEM, CHEESE, FEATHER, MEDBREW]

# --- ENEMY SPAWNING TUNING (edit in Inspector) ---
@export var enemy_count: int = 5
@export var min_enemy_distance_from_player: float = 150.0
@export var min_enemy_spacing: float = 120.0
#---------------------------------------------------------------------------------------------------
#NODE REFERENCES
#---------------------------------------------------------------------------------------------------
@onready var enemy_container: Node2D = $enemy_container
@onready var current_map: Node2D = $Map
@onready var player: CharacterBody2D = $Player
@onready var item_container: Node2D = $ItemContainer

#Tracks current floor.
var current_floor := 1

#---------------------------------------------------------------------------------------------------
#READY FUNCTION
#---------------------------------------------------------------------------------------------------
func _ready() -> void:
	#for child in enemy_container.get_children():                 #Clears rock container.
		#child.queue_free()
	#var prop_layer: TileMapLayer = current_map.get_node("Props")#Clears prop layer.
	#prop_layer.clear()
	#_place_player()
	#generateRocks()                                             #Places player.
	#current_map.exit_reached.connect(_on_exit_reached)          #Listens for "exit_reached" signal
																#From room_generator.gd.
	var prop_layer: TileMapLayer = current_map.get_node("Props")
	prop_layer.clear()
	item_container.z_index = 10 
	_place_player()
	spawn_items()
	#generateRocks()  
	spawn_troom_items()
	current_map.exit_reached.connect(_on_exit_reached)
	
#---------------------------------------------------------------------------------------------------
#PLACES PLAYER AT SPAWN
#---------------------------------------------------------------------------------------------------
func _place_player() -> void:
	var spawn: Marker2D = current_map.get_node("PlayerSpawn")
	player.global_position = spawn.global_position
	#var test_weapon = TEST_WEAPON_SCENE.instantiate()
	#test_weapon.position = spawn.global_position + Vector2(32, 0)
	#add_child(test_weapon)

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
	#current_map.generate_sequence()            #Generate room type sequence.
	#current_map.generate_dungeon(current_floor)#Generate new floor, pass current_floor number.
	#_place_player()                            #Place player at new floor spawn point.
	current_map.generate_sequence()
	current_map.generate_dungeon(current_floor)
	_place_player()
	call_deferred("spawn_items")# Defer spawning until after physics frame
	#call_deferred("generateRocks")
	call_deferred("spawn_troom_items")    

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
		available_cells = _get_all_spawn_positions()
					
		available_cells.shuffle()                                  #Shuffle available_cells to randomize.
		
		#var numEnemies = (available_cells.size() * ENEMY_FILL_PERCENTAGE)
		var numCoins = (available_cells.size() * COIN_FILL_PERCENTAGE)  #NumRocks equivalent to 40% of
																   #available cells.
		#for n in range(numEnemies):                                  #Place rocks.
			#var cell = available_cells.pop_front()
			#var entity = ENEMY_SCENE.instantiate()
		
			#rock.data = room["room_type"].get_ore_data()           #Set rock data
		
			#var local_pos = ground_layer.map_to_local(cell)        #Get local position from tilemap.
		
			#entity.position = ground_layer.map_to_local(cell)                              #Place rock, add to container.
			#container.add_child(entity)
			#entity.player = player
			#container.child_exiting_tree.connect(_check_room_clear.bind(i))
		
		for n in range(numCoins):
			var cell = available_cells.pop_front()
			var coin = COIN_SCENE.instantiate()
			
			coin.position = ground_layer.map_to_local(cell)
			item_container.add_child(coin)
			
func _check_room_clear(node: Node, room_index: int) -> void:
	var room = current_map.get_rooms()[room_index]
	var container = room["enemy_container"]
	
	if container.get_child_count() <= 1:
		if room["room_gate"] != null:
			room["room_gate"].get_node("CollisionShape2D").queue_free()
			print("Room ", room_index, " cleared. Door opened.")
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
	
	# Spawn crickets head (1) #Recommending commenting out so that passive items only spawn in treasure rooms. 
	_spawn_item(DAMAGE_GEM, spawn_positions, used_positions)
	_spawn_item(CHEESE, spawn_positions, used_positions)
	_spawn_item(FEATHER, spawn_positions, used_positions)
	_spawn_item(MEDBREW, spawn_positions, used_positions)
	
	var num_coins := (spawn_positions.size() * COIN_FILL_PERCENTAGE)
	for i in range(num_coins):
		_spawn_item(COIN_SCENE, spawn_positions, used_positions)
	
	# Spawn enemies
	var enemy_positions: Array[Vector2] = []
	print_debug("[Level] Spawning ", enemy_count, " enemies. Candidate pool: ", spawn_positions.size())
	for i in range(enemy_count):
		_spawn_enemy(spawn_positions, used_positions, enemy_positions)


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
				if tile_data and tile_data.get_custom_data("canSpawnEnemies") == true:
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

func _spawn_enemy(available_positions: Array[Vector2], used_positions: Array[Vector2], enemy_positions: Array[Vector2]) -> void:
	if available_positions.size() == 0:
		print_debug("[Level] No available positions for enemy!")
		return

	var player_pos = player.global_position

	# Build a filtered candidate list: not too close to player, not too close to other enemies
	var candidates: Array[Vector2] = []
	for pos in available_positions:
		if used_positions.has(pos):
			continue
		if pos.distance_to(player_pos) < min_enemy_distance_from_player:
			continue
		var too_close_to_enemy := false
		for ep in enemy_positions:
			if pos.distance_to(ep) < min_enemy_spacing:
				too_close_to_enemy = true
				break
		if not too_close_to_enemy:
			candidates.append(pos)

	if candidates.size() == 0:
		print_debug("[Level] No valid spread position found for enemy — skipping")
		return

	# Pick randomly from valid candidates instead of always grabbing the farthest
	var spawn_pos: Vector2 = candidates.pick_random()

	var enemy = ENEMY_SCENE.instantiate()
	enemy.global_position = spawn_pos
	enemy.player = player
	item_container.add_child(enemy)
	used_positions.append(spawn_pos)
	enemy_positions.append(spawn_pos)
	print_debug("[Level] Enemy spawned at ", spawn_pos, " (", candidates.size(), " candidates available)")

#-------------------------------------------------------------------------------
#SPAWN TREASURE ROOM LOOT
#-------------------------------------------------------------------------------
func spawn_troom_items() -> void:
	var ground_layer: TileMapLayer = current_map.get_node("Ground")
	for troom_origin in current_map.get_troom_origins():
		var center_tile: Vector2i = troom_origin + Vector2i(2, 2)
		var world_pos := ground_layer.map_to_local(center_tile)
		var item_scene: PackedScene = PASSIVE_ITEMS[randi() % PASSIVE_ITEMS.size()]
		var item = item_scene.instantiate()
		item.global_position = world_pos
		item_container.add_child(item)		
