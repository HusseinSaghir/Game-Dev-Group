extends Node2D

signal exit_reached

#TUNABLE PARAMETERS
const ROOM_SPACING := 4 #Tiles between one room's right wall and the next room's left wall.
const VOID_BORDER := 20 #Void tiles painted beyond room edges.
const MAX_FLOORS := 3

#TILE SOURCE IDS
const FLOOR_SOURCE_ID := 0
const VOID_SOURCE_ID := 3
const SPAWN_SOURCE_ID := 4

#FLOOR
const TILE_FLOOR := Vector2i(1, 1)
const TILE_SPAWN := Vector2i(1, 1)

#EDGES
const TILE_TOP_LEFT := Vector2i(0, 0)
const TILE_TOP := Vector2i(1, 0)
const TILE_TOP_RIGHT := Vector2i(2, 0)
const TILE_LEFT := Vector2i(0, 1)
const TILE_RIGHT := Vector2i(2, 1)
const TILE_BOT_LEFT := Vector2i(0, 2)
const TILE_BOTTOM := Vector2i(1, 2)
const TILE_BOT_RIGHT := Vector2i(2, 2)
const TILE_TOP_RIGHT_OUT := Vector2i(4, 0)
const TILE_TOP_LEFT_OUT := Vector2i(3, 0)
const TILE_BOT_RIGHT_OUT := Vector2i(4, 1)
const TILE_BOT_LEFT_OUT := Vector2i(3, 1)

#VOID
const TILE_VOID := Vector2i(1,1)

@onready var ground_layer: TileMapLayer = $Ground
@onready var player_spawn: Marker2D = $PlayerSpawn

var num_rooms := randi_range(5, 8)
var current_floor := 1
var _room_sequence: Array = []
var _rooms: Array = [] #Stores each room by origin, width, and height.
var _room_types: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_room_types = [StoneRoom.new(), IronRoom.new()]
	generate_sequence()
	generate_dungeon()
	
func generate_sequence() -> void:
	_room_sequence.clear()
	var room_type: RoomType
	for i in range(num_rooms - 1):
		room_type = _room_types[randi_range(0, _room_types.size() - 1)]
		_room_sequence.append(room_type)
	_room_sequence.append(GoldRoom.new())
	
func generate_dungeon() -> void:
	#1). Clear the scene and rooms dictionary.
	ground_layer.clear()
	_rooms.clear()
	
	for node in get_children():
		if node.is_in_group("exit_doors"):
			node.queue_free()
	
	var cursor_x := 0 #Where the next room starts (in tile coordinates)
	
	for i in range(num_rooms):
		var room_type: RoomType = _room_sequence[i]
		var dimensions := room_type.get_dimensions()
		var w := dimensions.x
		var h := dimensions.y
		var y_offset := randi_range(0, 10)
		var origin := Vector2i(cursor_x, y_offset)
		var has_troom := true
		if randi() % 2:
			has_troom = false
		
		#Fully randomized: randi_range(origin.y + 1, total_height - 3)
		var total_height := origin.y + h
		var exit_tile := Vector2i(origin.x + w - 1, origin.y + h / 2)
		var entrance_tile := Vector2i(origin.x, origin.y + h / 2)
		
		_rooms.append({
			"origin": origin,
			"width": w,
			"height": h,
			"exit": exit_tile,
			"entrance": entrance_tile,
			"room_type": room_type,
			"has_troom": has_troom
		})
		
		cursor_x += w + ROOM_SPACING
		
	var total_width := cursor_x + VOID_BORDER
	var total_height := 26 + VOID_BORDER * 2 #26 derived from MAX_HEIGHT (16 in room_type.gd) + 10
	_paint_void(total_width, total_height)
	
	for room in _rooms:
		_paint_room(room["origin"], room["width"], room["height"], room["has_troom"])

	var passage := PassageGenerator.new()
	for i in range(_rooms.size() - 1):
		var from_tile : Vector2i = _rooms[i]["exit"]
		var to_tile : Vector2i = _rooms[i + 1]["entrance"]
		passage.draw(ground_layer, from_tile, to_tile)
		
	var first : Dictionary = _rooms[0]
	_center_player_spawn(first["origin"], first["width"], first["height"])
	paint_exit_door(_rooms.back())
	
	
func _paint_void(total_width: int, total_height: int) -> void:
	var x_start := -VOID_BORDER
	var y_start := -VOID_BORDER
	var x_end := total_width
	var y_end := total_height
	for x in range(x_start, x_end):
		for y in range(y_start, y_end):
			ground_layer.set_cell(Vector2i(x, y), VOID_SOURCE_ID, TILE_VOID)
			
func _paint_room(origin: Vector2i, width: int, height: int, has_troom: bool) -> void:
	for x in range(width):
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
		var troom_entrance: Vector2i
		var troom_top := true
		if randi() % 2:
			troom_top = false
		var troom_offset_left := true
		if randi() % 2:
			troom_offset_left = false
		var troom_entrance_left: Vector2i
		var troom_entrance_right: Vector2i
		var troom_hall_length := randi_range(1, 11)
			
		if troom_top:
			troom_entrance = Vector2i(origin.x + width / 2, origin.y)
			if troom_offset_left: 
				troom_entrance_right = troom_entrance
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

func generate_troom_hall(troom_entrance_left: Vector2i, troom_entrance_right: Vector2i, troom_hall_length: int, troom_top: bool) -> void:
	var x_left = troom_entrance_left.x
	var x_right = troom_entrance_right.x
	var entrance_y: int
	var troom_origin: Vector2i
	var troom_left = true
	if randi() % 2:
		troom_left = false
	if troom_top:
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
		
func _center_player_spawn(origin: Vector2i, width: int, height: int) -> void:
	#Move the spawn point to the center of the room.
	var center_tile := Vector2i(origin.x + width / 2, origin.y + height / 2)
	ground_layer.set_cell(center_tile, SPAWN_SOURCE_ID, TILE_SPAWN)
	player_spawn.position = ground_layer.map_to_local(center_tile)

func paint_exit_door(last_room: Dictionary) -> void:
	if current_floor >= MAX_FLOORS:
		return
	
	var exit: Vector2i = last_room["exit"]
	ground_layer.set_cell(exit, SPAWN_SOURCE_ID, TILE_SPAWN)
	
	var area := Area2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	shape.shape = rect
	area.add_child(shape)
	area.position = ground_layer.map_to_local(exit)
	add_child(area)
	area.add_to_group("exit_doors")
	area.body_entered.connect(_on_exit_entered)
	
func _on_exit_entered(body: Node2D) -> void:
	if body is Player:
		emit_signal("exit_reached")

func get_rooms() -> Array:
	return _rooms

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
