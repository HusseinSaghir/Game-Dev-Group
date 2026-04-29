extends Area2D

class_name Pickup

@export var resource_type : Resource


# Called when the node enters the scene tree for the first time.
#Connects the body_entered node of the scene to the function _on_body_entered() function
#This will make it so any pickup item (not passive item) can use this file and class
func _ready() -> void:
	connect("body_entered", _on_body_entered)

#When the Player runs into the pickup it will see if the Player has a inventory
#If there is a inventory it will call the function add_resource() and add the resource to the inventory
func _on_body_entered(body : Node2D):
	if not body.is_in_group("Player"):
		return
	var inventory = body.find_child("Inventory")
	
	if(inventory):
		inventory.add_resources(resource_type, 1)
		queue_free()
