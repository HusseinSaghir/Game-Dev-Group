extends Node

class_name Inventory

#Creates a Dictionary for all the resources
@export var resources : Dictionary = { }

signal resource_count_changed(type : ResourceItem, new_count : int)

#When this function is called it will add the resource into the inventory
#If the resource is already in the inventory then it will just add another number to the count
#If the resource is not already in the inventory then it will 
func add_resources(type : ResourceItem, amount : int):
	if(resources.has(type)):
		resources[type] = resources[type] + amount
	else:
		resources[type] = amount
	emit_signal("resource_count_changed", type, resources[type])
