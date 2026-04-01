class_name StoneRoom
extends RoomType

const STONE_DATA = preload("res://Data/Rocks/stone.tres")

func get_dimensions() -> Vector2i:
	var h := randi_range(MIN_HEIGHT, MAX_HEIGHT / 2)
	var w := randi_range(h + 1, MAX_WIDTH)
	return Vector2i(w, h)
	
func get_ore_data() -> Resource:
	return STONE_DATA
