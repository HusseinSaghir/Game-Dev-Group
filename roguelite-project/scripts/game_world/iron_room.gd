class_name IronRoom
extends RoomType

#const IRON_DATA = preload("res://Data/Rocks/iron.tres")

func get_dimensions() -> Vector2i:
	var w := randi_range(MIN_WIDTH, MAX_WIDTH / 2)
	var h := w * (1+sqrt(5))/2
	return Vector2i(w, h)
	
#func get_ore_data() -> Resource:
	#return IRON_DATA
