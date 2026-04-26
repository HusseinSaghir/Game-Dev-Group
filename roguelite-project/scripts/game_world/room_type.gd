class_name RoomType
extends RefCounted

const MIN_WIDTH := 10
const MAX_WIDTH := 20
const MIN_HEIGHT := 10
const MAX_HEIGHT := 20

func get_dimensions() -> Vector2i:
	assert(false, "RoomType.get_dimensions() must be overridden by subclass.")
	return Vector2i.ZERO

func get_ore_data() -> Resource:
	assert(false, "RoomType.get_ore_data must be overridden by subclass.")
	return null
