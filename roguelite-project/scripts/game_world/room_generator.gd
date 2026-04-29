extends Node2D

#---------------------------------------------------------------------------------------------------
#EXIT SIGNAL
#---------------------------------------------------------------------------------------------------
signal exit_reached

#---------------------------------------------------------------------------------------------------
#TUNABLE PARAMETERS
#---------------------------------------------------------------------------------------------------
const ROOM_SPACING := 4 #Tiles between one room's right wall and the next room's left wall.
const VOID_BORDER := 20 #Void tiles painted beyond room edges.
const MAX_FLOORS := 3

#---------------------------------------------------------------------------------------------------
#TILE SOURCE IDS
#---------------------------------------------------------------------------------------------------
const FLOOR_SOURCE_ID := 0
const VOID_SOURCE_ID := 1
const SPAWN_SOURCE_ID := 2

#---------------------------------------------------------------------------------------------------
#FLOOR TILE COORDINATES
#---------------------------------------------------------------------------------------------------
const TILE_FLOOR := Vector2i(2, 8)
const TILE_SPAWN := Vector2i(1, 1)

#---------------------------------------------------------------------------------------------------
#EDGE TILE COORDINATES
#---------------------------------------------------------------------------------------------------
const TILE_TOP_LEFT := Vector2i(1, 7)
const TILE_TOP := Vector2i(2, 7)
const TILE_TOP_RIGHT := Vector2i(3, 7)
const TILE_LEFT := Vector2i(1, 8)
const TILE_RIGHT := Vector2i(3, 8)
const TILE_BOT_LEFT := Vector2i(11, 7)
const TILE_BOTTOM := Vector2i(10, 6)
const TILE_BOT_RIGHT := Vector2i(9, 7)
const TILE_TOP_RIGHT_OUT := Vector2i(11, 6)
const TILE_TOP_LEFT_OUT := Vector2i(9, 6)
const TILE_BOT_RIGHT_OUT := Vector2i(7, 9)
const TILE_BOT_LEFT_OUT := Vector2i(5, 9)
const TILE_GATE_CLOSED := Vector2i(10, 25)
const TILE_GATE_OPEN := Vector2i(6, 25)
const TILE_GATE_SIDE := Vector2i(3, 21)

#---------------------------------------------------------------------------------------------------
#BOTTOM DROP-OFF TILE COORDINATES (row below the bottom edge)
#---------------------------------------------------------------------------------------------------
const TILE_BOT_LEFT_DROP  := Vector2i(11, 7)  # your atlas coords for the lower-left drop-off tile
const TILE_BOTTOM_DROP    := Vector2i(10, 6)  # your atlas coords for the lower-center drop-off tile
const TILE_BOT_RIGHT_DROP := Vector2i(9, 7)  # your atlas coords for the lower-right drop-off tile

#---------------------------------------------------------------------------------------------------
#VOID TILE COORDINATE
#---------------------------------------------------------------------------------------------------
const TILE_VOID := Vector2i(1,1)

#---------------------------------------------------------------------------------------------------
#NODE REFERENCES
#---------------------------------------------------------------------------------------------------
@onready var ground_layer: TileMapLayer = $Ground
@onready var player_spawn: Marker2D = $PlayerSpawn

const TROOM_DOOR_SCENE = preload("res://scenes/rooms/troom_door.tscn")
const ROOM_GATE_SCENE = preload("res://scenes/rooms/room_gate.tscn")

#---------------------------------------------------------------------------------------------------
#VARIABLES
#---------------------------------------------------------------------------------------------------
var num_rooms := randi_range(5, 8) #Random number of rooms between 5 and 8
var _room_sequence: Array = []     #Stores sequence of room types.
var _rooms: Array = []             #Stores each room by origin, width, and height.
var _room_types: Array = []  
var _troom_origins: Array[Vector2i] = []      #Stores possible room types.

#---------------------------------------------------------------------------------------------------
#READY FUNCTION
#---------------------------------------------------------------------------------------------------
func _ready() -> void:
	_room_types = [StoneRoom.new(), IronRoom.new()] #Set possible room types
	generate_sequence()                             #Generate sequence of room types.
	generate_dungeon()                              #Generate floor.
	
#---------------------------------------------------------------------------------------------------
#ROOM TYPE SEQUENCE GENERATION
#---------------------------------------------------------------------------------------------------
func generate_sequence() -> void:
	_room_sequence.clear()                                             #Clear previous sequence.
	var room_type: RoomType                                            #Room type variable.
	for i in range(num_rooms - 1):
		room_type = _room_types[randi_range(0, _room_types.size() - 1)]#Chooses random room type.
		_room_sequence.append(room_type)                               #Appends room type.
	_room_sequence.append(GoldRoom.new())                              #Adds square room to end of
																	   # sequence.

#---------------------------------------------------------------------------------------------------
#FLOOR GENERATION
#---------------------------------------------------------------------------------------------------
func generate_dungeon(floor_number: int = 1) -> void:
	_troom_origins.clear()
	ground_layer.clear()                            #Clear previous tiles and rooms.
	_rooms.clear()
	
	for node in get_children():                     #Clear previous exit door.
		if node.is_in_group("exit_doors"):
			node.queue_free()
	
	var cursor_x := 0                               #X-coordinate where the next room starts.
	
	for i in range(num_rooms):
		var room_type: RoomType = _room_sequence[i] #Set room type according to sequence.
		var dimensions := room_type.get_dimensions()#Set room width and height.
		var w := dimensions.x                       
		var h := dimensions.y
		var y_offset := randi_range(0, 10)          #Set y-coordinate for room start.
		var origin := Vector2i(cursor_x, y_offset)  #Set room origin (upper left corner).
		var has_troom := true                       #Determines presence of treasure room.
		if randi() % 2:
			has_troom = false
		
		#Fully randomized: randi_range(origin.y + 1, total_height - 3) #Set entrance and exit tiles.
		var total_height := origin.y + h                               #Fully randomized solution
		var exit_tile := Vector2i(origin.x + w - 1, origin.y + h / 2)  # included.
		var entrance_tile := Vector2i(origin.x, origin.y + h / 2)
		
		_rooms.append({                                                #Append room to array.
			"origin": origin,
			"width": w,
			"height": h,
			"exit": exit_tile,
			"entrance": entrance_tile,
			"room_type": room_type,
			"has_troom": has_troom,
			"enemy_container": null,
			"room_gate": null
		})
		
		cursor_x += w + ROOM_SPACING                                  #Set cursor_x for next room.
		
	var total_width := cursor_x + VOID_BORDER                         #Set total width and height of
	var total_height := 26 + VOID_BORDER * 2                          # map for _paint_void. 26 
	_paint_void(total_width, total_height)                            # derived from MAX_HEIGHT 
																	  # (16 in room_type.gd) + 10.
	#for i in range(1, _rooms.size()):
		#var room = _rooms[i]
		#var exit_tile = room["exit"]
		#var exit_top = Vector2i(exit_tile.x + 1, exit_tile.y)
		#var exit_bottom = Vector2i(exit_tile.x + 1, exit_tile.y + 1)
		#room["room_gate"] = _spawn_room_gate(exit_top, exit_bottom)
	
	for room in _rooms:
		_paint_room(room["origin"], room["width"], room["height"], room["has_troom"]) #Paint room
																					  # over void.
	var passage := PassageGenerator.new()                                 #Passage between rooms.
	for i in range(_rooms.size() - 1):
		var from_tile : Vector2i = _rooms[i]["exit"]
		var to_tile : Vector2i = _rooms[i + 1]["entrance"]
		passage.draw(ground_layer, from_tile, to_tile)                    #Execute .draw() in
																		  # PassageGenerator.
	var first : Dictionary = _rooms[0]                                    #Center player spawn in
	_center_player_spawn(first["origin"], first["width"], first["height"])# first room, paint exit
	paint_exit_door(_rooms.back(), floor_number)                          # door in last room.
	
#---------------------------------------------------------------------------------------------------
#PAINT VOID TILES
#---------------------------------------------------------------------------------------------------
func _paint_void(total_width: int, total_height: int) -> void: #Paints void tiles across entire area
	var x_start := -VOID_BORDER                                # encompassing the map. Not much more
	var y_start := -VOID_BORDER                                # to it.
	var x_end := total_width
	var y_end := total_height
	for x in range(x_start, x_end):
		for y in range(y_start, y_end):
			ground_layer.set_cell(Vector2i(x, y), VOID_SOURCE_ID, TILE_VOID)
			
#---------------------------------------------------------------------------------------------------
#PAINT ROOM TILES
#---------------------------------------------------------------------------------------------------
func _paint_room(origin: Vector2i, width: int, height: int, has_troom: bool) -> void:
	# Erase void tiles covering the lower half of the 2-tall bottom edge tiles.
	for x in range(width):
		ground_layer.erase_cell(origin + Vector2i(x, height))
		for y in range(height):
			var coord := origin + Vector2i(x, y)
			var is_left := x == 0
			var is_right := x == width - 1
			var is_top := y == 0
			var is_bottom := y == height - 1
			
			if is_top and is_left:
				ground_layer.set_cell(coord, FLOOR_SOURCE_ID, TILE_TOP_LEFT)
			elif is_top and is_right:
				ground_layer.set_cell(coord, FLOOR_SOURCE_ID, TILE_TOP_RIGHT)
			elif is_bottom and is_left:
				ground_layer.set_cell(coord, FLOOR_SOURCE_ID, TILE_BOT_LEFT)
			elif is_bottom and is_right:
				ground_layer.set_cell(coord, FLOOR_SOURCE_ID, TILE_BOT_RIGHT)
			elif is_top:
				ground_layer.set_cell(coord, FLOOR_SOURCE_ID, TILE_TOP)
			elif is_bottom:
				ground_layer.set_cell(coord, FLOOR_SOURCE_ID, TILE_BOTTOM)
			elif is_left:
				ground_layer.set_cell(coord, FLOOR_SOURCE_ID, TILE_LEFT)
			elif is_right:
				ground_layer.set_cell(coord, FLOOR_SOURCE_ID, TILE_RIGHT)
			else:
				ground_layer.set_cell(coord, FLOOR_SOURCE_ID, TILE_FLOOR)
		
	#-----------------------------------------------------------------------------------------------
	#TREASURE ROOM GENERATION
	#-----------------------------------------------------------------------------------------------
	if has_troom:
		var troom_entrance: Vector2i               #Establish troom entrance variable.
		var troom_top := true                      #Determine if troom at top or bottom of room.
		if randi() % 2:
			troom_top = false
		var troom_offset_left := true              #Determine if troom entrance offset left or right.
		if randi() % 2:
			troom_offset_left = false
		var troom_entrance_left: Vector2i          #Troom entrance consists of two tiles, side by side.
		var troom_entrance_right: Vector2i         #These are the coordinates of those tiles.
		var troom_hall_length := randi_range(1, 11)#Randomize troom length.
			
		if troom_top:                              
			troom_entrance = Vector2i(origin.x + width / 2, origin.y)#Troom generation algorithm
			if troom_offset_left:                                    # determines if top/bottom,
				troom_entrance_right = troom_entrance                # left/right, triggers generate_troom_hall().
				troom_entrance_left = Vector2i(troom_entrance.x - 1, troom_entrance.y)
				generate_troom_hall(troom_entrance_left, troom_entrance_right, troom_hall_length, troom_top)
			else:
				troom_entrance_right = Vector2i(troom_entrance.x + 1, troom_entrance.y)
				troom_entrance_left = troom_entrance
				generate_troom_hall(troom_entrance_left, troom_entrance_right, troom_hall_length, troom_top)
		else:
			troom_entrance = Vector2i(origin.x + width / 2, origin.y + height - 1)
			if troom_offset_left: 
				troom_entrance_right = troom_entrance
				troom_entrance_left = Vector2i(troom_entrance.x - 1, troom_entrance.y)
				generate_troom_hall(troom_entrance_left, troom_entrance_right, troom_hall_length, troom_top)
			else:
				troom_entrance_right = Vector2i(troom_entrance.x + 1, troom_entrance.y)
				troom_entrance_left = troom_entrance
				generate_troom_hall(troom_entrance_left, troom_entrance_right, troom_hall_length, troom_top)

#---------------------------------------------------------------------------------------------------
#TREASURE ROOM HALL GENERATION
#---------------------------------------------------------------------------------------------------
func generate_troom_hall(troom_entrance_left: Vector2i, troom_entrance_right: Vector2i, troom_hall_length: int, troom_top: bool) -> void:
	var x_left = troom_entrance_left.x
	var x_right = troom_entrance_right.x
	var entrance_y: int
	var troom_origin: Vector2i
	var troom_left = true                #Determines if troom extends to the left or right from the corridor exit.
	if randi() % 2:                      #Algorithm sets corners for the entrance of the hall, left and right
		troom_left = false               # edges for the walls, for as long as the corridor extends.
	if troom_top:                        #Triggers _paint_room for troom, sets appropriate tiles for hall exit.
		ground_layer.set_cell(troom_entrance_right, FLOOR_SOURCE_ID, TILE_BOT_LEFT_OUT)
		ground_layer.set_cell(troom_entrance_left, FLOOR_SOURCE_ID, TILE_BOT_RIGHT_OUT)
		for y in range(troom_hall_length):
			entrance_y = troom_entrance_left.y - 1
			ground_layer.set_cell(Vector2i(x_left, entrance_y - y), FLOOR_SOURCE_ID, TILE_LEFT)
			ground_layer.set_cell(Vector2i(x_right, entrance_y - y), FLOOR_SOURCE_ID, TILE_RIGHT)
		if troom_left:
			troom_origin = Vector2i(x_right - 4, entrance_y - troom_hall_length - 4)
			_paint_room(troom_origin, 5, 5, false)
			ground_layer.set_cell(Vector2i(x_left, entrance_y - troom_hall_length), FLOOR_SOURCE_ID, TILE_TOP_RIGHT_OUT)
			ground_layer.set_cell(Vector2i(x_right, entrance_y - troom_hall_length), FLOOR_SOURCE_ID, TILE_RIGHT)
		else:
			troom_origin = Vector2i(x_left, entrance_y - troom_hall_length - 4)
			_paint_room(troom_origin, 5, 5, false)
			ground_layer.set_cell(Vector2i(x_left, entrance_y - troom_hall_length), FLOOR_SOURCE_ID, TILE_LEFT)
			ground_layer.set_cell(Vector2i(x_right, entrance_y - troom_hall_length), FLOOR_SOURCE_ID, TILE_TOP_LEFT_OUT)
	else:
		ground_layer.set_cell(troom_entrance_left, FLOOR_SOURCE_ID, TILE_TOP_RIGHT_OUT)
		ground_layer.set_cell(troom_entrance_right, FLOOR_SOURCE_ID, TILE_TOP_LEFT_OUT)
		for y in range(troom_hall_length):
			entrance_y = troom_entrance_left.y + 1
			ground_layer.set_cell(Vector2i(x_left, entrance_y + y), FLOOR_SOURCE_ID, TILE_LEFT)
			ground_layer.set_cell(Vector2i(x_right, entrance_y + y), FLOOR_SOURCE_ID, TILE_RIGHT)
		if troom_left:
			troom_origin = Vector2i(x_right - 4, entrance_y + troom_hall_length)
			_paint_room(troom_origin, 5, 5, false)
			ground_layer.set_cell(Vector2i(x_left, entrance_y + troom_hall_length), FLOOR_SOURCE_ID, TILE_BOT_RIGHT_OUT)
			ground_layer.set_cell(Vector2i(x_right, entrance_y + troom_hall_length), FLOOR_SOURCE_ID, TILE_RIGHT)
		else:
			troom_origin = Vector2i(x_left, entrance_y + troom_hall_length)
			_paint_room(troom_origin, 5, 5, false)
			ground_layer.set_cell(Vector2i(x_left, entrance_y + troom_hall_length), FLOOR_SOURCE_ID, TILE_LEFT)
			ground_layer.set_cell(Vector2i(x_right, entrance_y + troom_hall_length), FLOOR_SOURCE_ID, TILE_BOT_LEFT_OUT)
	_spawn_troom_door(troom_entrance_left, troom_entrance_right)
	_troom_origins.append(troom_origin)
	
#---------------------------------------------------------------------------------------------------
#TREASURE ROOM DOOR AND ROOM GATE GENERATORS
#---------------------------------------------------------------------------------------------------

func _spawn_troom_door(entrance_left: Vector2i, entrance_right: Vector2i) -> void:
	var door = TROOM_DOOR_SCENE.instantiate()
	var left_tile = ground_layer.map_to_local(entrance_left)
	var right_tile = ground_layer.map_to_local(entrance_right)
	door.position = (left_tile + right_tile) / 2.0
	add_child(door)

func _spawn_room_gate(exit_top: Vector2i, exit_bottom: Vector2i) -> Node2D:
	var door = ROOM_GATE_SCENE.instantiate()
	var top_tile = ground_layer.map_to_local(exit_top)
	var bottom_tile = ground_layer.map_to_local(exit_bottom)
	door.position = (top_tile + bottom_tile) / 2.0
	add_child(door)
	return door

#---------------------------------------------------------------------------------------------------
#PLAYER SPAWN AT CENTER OF ROOM
#---------------------------------------------------------------------------------------------------
func _center_player_spawn(origin: Vector2i, width: int, height: int) -> void:
	#Move the spawn point to the center of the room.
	var center_tile := Vector2i(origin.x + width / 2, origin.y + height / 2)
	ground_layer.set_cell(center_tile, SPAWN_SOURCE_ID, TILE_SPAWN)
	player_spawn.position = ground_layer.map_to_local(center_tile)

#---------------------------------------------------------------------------------------------------
#PAINT EXIT DOOR IN FINAL ROOM
#---------------------------------------------------------------------------------------------------
func paint_exit_door(last_room: Dictionary, floor_number: int) -> void:
	if floor_number >= MAX_FLOORS:                          #Doesn't paint door if at final room.
		return
	
	var exit: Vector2i = last_room["exit"]                  #Places exit at exit tile of final room.
	ground_layer.set_cell(exit, SPAWN_SOURCE_ID, TILE_SPAWN)
	
	var area := Area2D.new()                                #Creates a collision shape that signals
	var shape := CollisionShape2D.new()                     # "exit_reached" to level.gd when entered
	var rect := RectangleShape2D.new()                      # by player.
	rect.size = Vector2(16, 16)
	shape.shape = rect
	area.add_child(shape)
	area.position = ground_layer.map_to_local(exit)
	add_child(area)
	area.add_to_group("exit_doors")
	area.body_entered.connect(_on_exit_entered)
	
#---------------------------------------------------------------------------------------------------
#EXIT FLOOR BEHAVIOR
#---------------------------------------------------------------------------------------------------
func _on_exit_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		emit_signal("exit_reached")

#---------------------------------------------------------------------------------------------------
#GET ROOMS (Self-explanatory)
#---------------------------------------------------------------------------------------------------
func get_rooms() -> Array:
	return _rooms

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
#---------------------------------------------------------------------------------------------------
#GET TREASURE ROOM ORIGINS (Self-explanatory)
#---------------------------------------------------------------------------------------------------
func get_troom_origins() -> Array[Vector2i]:
	return _troom_origins
