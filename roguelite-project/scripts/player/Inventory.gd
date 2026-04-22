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
	#This checks to see if the item that was picked up is a Pickup item or a Passive item for iventory stuff
	if(type.group == "Pickup"):
		emit_signal("resource_count_changed", type, resources[type])

# When this function is called it will check the inventory for any pick up and if it has it
# It will remove the amount from that pick up
# It will also check to see if the pickup in the inventory is at 0 or not and if it is the function will pass through it
# Make sure when you call this function from another file to make sure that the string variable matches up perfecting with the resource
# If there is any space in the string variable it will not work
func remove_resrouces(type : String, amount : int):
	for i in resources:
		if (i.display_name == type):
			if(resources[i] > 0):
				resources[i] = resources[i] - amount
				
				emit_signal("resource_count_changed", i, resources[i])
				return "passed"
	return "no_passed"
	
