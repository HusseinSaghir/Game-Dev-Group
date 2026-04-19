class_name PassageGenerator
extends RefCounted #What is this?

const PASSAGE_WIDTH := 2
const FLOOR_SOURCE_ID := 0
const VOID_SOURCE_ID := 3
const TILE_FLOOR := Vector2i(1, 1)
const TILE_VOID := Vector2i(1, 1)
const TILE_TOP_LEFT := Vector2i(0, 0)
const TILE_TOP := Vector2i(1, 0)
const TILE_TOP_RIGHT := Vector2i(2, 0)
const TILE_LEFT := Vector2i(0, 1)
const TILE_RIGHT := Vector2i(2, 1)
const TILE_BOT_LEFT := Vector2i(0, 2)
const TILE_BOTTOM := Vector2i(1, 2)
const TILE_BOT_RIGHT := Vector2i(2, 2)
const TILE_BOT_LEFT_IN := Vector2i(3, 1)
const TILE_BOT_RIGHT_IN := Vector2i(4, 1)
const TILE_TOP_LEFT_IN := Vector2i(3, 0)
const TILE_TOP_RIGHT_IN := Vector2i(4, 0)

#The "bounding rect" of this passage, used by the parent function for void painting.
var bounds : Rect2i

func draw (layer: TileMapLayer, from_tile: Vector2i, to_tile: Vector2i) -> void:
	#Strategy: Go horizontal first, then vertical. This produces an L-shaped corridor.
	var min_x := mini(from_tile.x, to_tile.x)
	var max_x := maxi(from_tile.x, to_tile.x)
	var min_y := mini(from_tile.y, to_tile.y)
	var max_y := maxi(from_tile.y, to_tile.y)

	var goes_down := to_tile.y >= from_tile.y
	
	#Open entrances and exits
	layer.set_cell(from_tile, FLOOR_SOURCE_ID, TILE_BOT_LEFT_IN)
	layer.set_cell(Vector2i(from_tile.x, from_tile.y + 1), FLOOR_SOURCE_ID, TILE_TOP_LEFT_IN)
	layer.set_cell(to_tile, FLOOR_SOURCE_ID, TILE_BOT_RIGHT_IN)
	layer.set_cell(Vector2i(to_tile.x, to_tile.y + 1), FLOOR_SOURCE_ID, TILE_TOP_RIGHT_IN)
	
	if (!goes_down):
		
		#Corners
		layer.set_cell(Vector2i(to_tile.x - 1, to_tile.y + 1), FLOOR_SOURCE_ID, TILE_TOP_LEFT_IN)
		layer.set_cell(Vector2i(to_tile.x - 1, to_tile.y), FLOOR_SOURCE_ID, TILE_TOP)
		layer.set_cell(Vector2i(to_tile.x - 2, to_tile.y), FLOOR_SOURCE_ID, TILE_TOP_LEFT)
		layer.set_cell(Vector2i(to_tile.x - 1, from_tile.y + 1), FLOOR_SOURCE_ID, TILE_BOT_RIGHT)
		layer.set_cell(Vector2i(to_tile.x - 2, from_tile.y), FLOOR_SOURCE_ID, TILE_BOT_RIGHT_IN)
		
		#Vertical arm
		for y in range(to_tile.y + 1, from_tile.y):
			layer.set_cell(Vector2i(to_tile.x - 2, y), FLOOR_SOURCE_ID, TILE_LEFT)
		for y in range(to_tile.y + 2, from_tile.y + 1):
			layer.set_cell(Vector2i(to_tile.x - 1, y), FLOOR_SOURCE_ID, TILE_RIGHT)
			
		#Horizontal arm
		for x in range(from_tile.x + 1, to_tile.x - 2):
			layer.set_cell(Vector2i(x, from_tile.y), FLOOR_SOURCE_ID, TILE_TOP)
		for x in range(from_tile.x + 1, to_tile.x - 1):
			layer.set_cell(Vector2i(x, from_tile.y + 1), FLOOR_SOURCE_ID, TILE_BOTTOM)
	
	elif (goes_down):
		
		if (to_tile.y > from_tile.y):
			#Corners
			layer.set_cell(Vector2i(to_tile.x - 1, to_tile.y), FLOOR_SOURCE_ID, TILE_BOT_LEFT_IN)
			layer.set_cell(Vector2i(to_tile.x - 1, to_tile.y + 1), FLOOR_SOURCE_ID, TILE_BOTTOM)
			layer.set_cell(Vector2i(to_tile.x - 2, to_tile.y + 1), FLOOR_SOURCE_ID, TILE_BOT_LEFT)
			layer.set_cell(Vector2i(to_tile.x - 1, from_tile.y), FLOOR_SOURCE_ID, TILE_TOP_RIGHT)
			layer.set_cell(Vector2i(to_tile.x - 2, from_tile.y + 1), FLOOR_SOURCE_ID, TILE_TOP_RIGHT_IN)
		
		
			#Vertical Arm
			for y in range(from_tile.y + 1, to_tile.y):
				layer.set_cell(Vector2i(to_tile.x - 1, y), FLOOR_SOURCE_ID, TILE_RIGHT)
			for y in range(from_tile.y + 2, to_tile.y + 1):
				layer.set_cell(Vector2i(to_tile.x - 2, y), FLOOR_SOURCE_ID, TILE_LEFT)
			
			#Horizontal Arm
			for x in range(from_tile.x + 1, to_tile.x - 1):
				layer.set_cell(Vector2i(x, from_tile.y), FLOOR_SOURCE_ID, TILE_TOP)
			for x in range(from_tile.x + 1, to_tile.x - 2):
				layer.set_cell(Vector2i(x, from_tile.y + 1), FLOOR_SOURCE_ID, TILE_BOTTOM)
		
		elif (to_tile.y == from_tile.y):
			for x in range(from_tile.x + 1, to_tile.x):
				layer.set_cell(Vector2i(x, to_tile.y), FLOOR_SOURCE_ID, TILE_TOP)
				layer.set_cell(Vector2i(x, to_tile.y + 1), FLOOR_SOURCE_ID, TILE_BOTTOM)
		
	
	#Store bounds so parent can extend void painting over this passage.
	bounds = Rect2i(min_x, min_y, max_x - min_x + PASSAGE_WIDTH, max_y - min_y + PASSAGE_WIDTH)
