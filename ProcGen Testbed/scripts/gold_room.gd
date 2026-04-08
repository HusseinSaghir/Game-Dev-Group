class_name GoldRoom
extends RoomType

const GOLD_DATA = preload("res://Data/Rocks/gold.tres")

func get_dimensions() -> Vector2i:
	var side := randi_range(8, 10)
	return Vector2i(side, side)
	
func get_ore_data() -> Resource:
	return GOLD_DATA
