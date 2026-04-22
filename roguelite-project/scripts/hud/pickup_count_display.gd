extends HBoxContainer

class_name PickupCountDisplay

#Variables for the picture of the pickup item and the label
@onready var texture_rect : TextureRect = $TextureRect
@onready var label : Label = $Label

#This is for setting the sprite on the Hud
var resource_type : ResourceItem :
	set(new_type):
		
		resource_type = new_type 
		texture_rect.texture = resource_type.texture

#Whenever a pickup is collected it will change the text within the label
func update_count(count : int):
	label.text = str(count)
